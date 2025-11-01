import '../Database/schedule_database.dart';
import '../utils/rrule_utils.dart';

// ✅ 연체(Overdue) 작업 표시 로직
//
// **목적:**
// Google Tasks/Todoist와 같은 작업 관리 앱의 핵심 기능인
// "마감일이 지난 작업"을 명확히 표시하고 관리한다.
//
// **보고서 섹션 V.C 참조:**
// "연체된 작업은 별도 상태로 처리해야 하며,
//  (생성된 인스턴스) - (완료된 인스턴스)의 차집합을 계산하여 표시"
//
// **사용 예시:**
// ```dart
// // Google Tasks 스타일: "지난 30일간 연체 작업"
// final overdueTasks = await getOverdueTasks(db, daysBack: 30);
//
// // Todoist 스타일: "오늘 또는 기한이 지난 작업"
// final todayAndOverdue = await getTodayAndOverdueTasks(db);
// ```

/// ✅ 연체 작업 조회 (기본)
/// - executionDate < today AND completed = false
/// - 반복 작업 포함 (ABSOLUTE 모드)
Future<List<TaskData>> getOverdueTasks(
  AppDatabase db, {
  DateTime? referenceDate,
  int? daysBack,
}) async {
  final today = referenceDate ?? DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  // 조회 시작 날짜 계산 (기본: 제한 없음)
  final startDate = daysBack != null
      ? todayStart.subtract(Duration(days: daysBack))
      : DateTime(1900, 1, 1); // 충분히 과거 날짜

  // 1. 모든 미완료 작업 조회
  final allTasks = await db.watchTasks().first;

  // 2. 연체 필터링
  final overdueTasks = allTasks.where((task) {
    // 완료된 작업 제외
    if (task.completed) return false;

    // executionDate가 없으면 제외
    if (task.executionDate == null) return false;

    final executionDate = DateTime(
      task.executionDate!.year,
      task.executionDate!.month,
      task.executionDate!.day,
    );

    // 오늘 이전 + daysBack 범위 내
    return executionDate.isBefore(todayStart) &&
        executionDate.isAfter(startDate);
  }).toList();

  // 3. 오래된 순서로 정렬 (가장 오래된 연체가 먼저)
  overdueTasks.sort((a, b) => a.executionDate!.compareTo(b.executionDate!));

  return overdueTasks;
}

/// ✅ 오늘 + 연체 작업 조회 (Todoist 스타일)
/// - "오늘 또는 기한이 지난" 필터
Future<List<TaskData>> getTodayAndOverdueTasks(
  AppDatabase db, {
  DateTime? referenceDate,
}) async {
  final today = referenceDate ?? DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

  final allTasks = await db.watchTasks().first;

  final filteredTasks = allTasks.where((task) {
    if (task.completed) return false;
    if (task.executionDate == null) return false;

    final executionDate = DateTime(
      task.executionDate!.year,
      task.executionDate!.month,
      task.executionDate!.day,
    );

    // 오늘 이전 OR 오늘
    return executionDate.isBefore(todayEnd) ||
        executionDate.isAtSameMomentAs(todayStart);
  }).toList();

  // 날짜순 정렬
  filteredTasks.sort((a, b) => a.executionDate!.compareTo(b.executionDate!));

  return filteredTasks;
}

/// ✅ 연체 습관 조회 (Habit용)
/// - ABSOLUTE 반복 습관 중 완료되지 않은 과거 날짜
/// - RELATIVE_ON_COMPLETION 습관은 제외 (완료 기준 반복이므로 "연체" 개념 없음)
Future<List<OverdueHabitInstance>> getOverdueHabits(
  AppDatabase db, {
  DateTime? referenceDate,
  int? daysBack,
}) async {
  final today = referenceDate ?? DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  final startDate = daysBack != null
      ? todayStart.subtract(Duration(days: daysBack))
      : DateTime(1900, 1, 1);

  final overdueInstances = <OverdueHabitInstance>[];

  // 모든 습관 조회
  final habits = await db.watchHabits().first;

  for (final habit in habits) {
    // 반복 패턴 조회
    final pattern = await db.getRecurringPattern(
      entityType: 'habit',
      entityId: habit.id,
    );

    if (pattern == null) continue;

    // RELATIVE_ON_COMPLETION은 "연체" 개념 없음
    if (pattern.recurrenceMode == 'RELATIVE_ON_COMPLETION') continue;

    // ABSOLUTE 반복만 처리
    // startDate ~ 어제까지의 인스턴스 생성
    final yesterday = todayStart.subtract(const Duration(days: 1));

    final instances = RRuleUtils.generateInstancesFromPattern(
      pattern: pattern,
      rangeStart: startDate,
      rangeEnd: yesterday,
    );

    // 완료 기록 조회
    final completionQuery = db.select(db.habitCompletion)
      ..where((tbl) => tbl.habitId.equals(habit.id));
    final completions = await completionQuery.get();
    final completedDates = completions.map((c) {
      final d = c.completedDate;
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    // 완료되지 않은 인스턴스 = 연체
    for (final instanceDate in instances) {
      final dateOnly = DateTime(
        instanceDate.year,
        instanceDate.month,
        instanceDate.day,
      );

      if (!completedDates.contains(dateOnly)) {
        overdueInstances.add(
          OverdueHabitInstance(habit: habit, missedDate: dateOnly),
        );
      }
    }
  }

  // 오래된 순서로 정렬
  overdueInstances.sort((a, b) => a.missedDate.compareTo(b.missedDate));

  return overdueInstances;
}

/// ✅ 연체 작업 통계
/// - UI에서 "30개의 연체된 작업" 같은 요약 표시용
Future<OverdueTaskStats> getOverdueTaskStats(
  AppDatabase db, {
  DateTime? referenceDate,
}) async {
  final overdueTasks = await getOverdueTasks(db, referenceDate: referenceDate);

  if (overdueTasks.isEmpty) {
    return OverdueTaskStats(count: 0, oldestDate: null, averageDaysOverdue: 0);
  }

  final today = referenceDate ?? DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  // 평균 연체 일수 계산
  int totalDaysOverdue = 0;
  for (final task in overdueTasks) {
    final executionDate = DateTime(
      task.executionDate!.year,
      task.executionDate!.month,
      task.executionDate!.day,
    );
    totalDaysOverdue += todayStart.difference(executionDate).inDays;
  }

  return OverdueTaskStats(
    count: overdueTasks.length,
    oldestDate: overdueTasks.first.executionDate,
    averageDaysOverdue: (totalDaysOverdue / overdueTasks.length).round(),
  );
}

/// ✅ 연체 여부 확인 (단일 작업)
/// - UI에서 작업 카드에 "연체" 배지 표시용
bool isTaskOverdue(TaskData task, {DateTime? referenceDate}) {
  if (task.completed) return false;
  if (task.executionDate == null) return false;

  final today = referenceDate ?? DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  final executionDate = DateTime(
    task.executionDate!.year,
    task.executionDate!.month,
    task.executionDate!.day,
  );

  return executionDate.isBefore(todayStart);
}

/// ✅ 연체 일수 계산
/// - "3일 연체" 같은 표시용
int getDaysOverdue(TaskData task, {DateTime? referenceDate}) {
  if (!isTaskOverdue(task, referenceDate: referenceDate)) return 0;

  final today = referenceDate ?? DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  final executionDate = DateTime(
    task.executionDate!.year,
    task.executionDate!.month,
    task.executionDate!.day,
  );

  return todayStart.difference(executionDate).inDays;
}

// ==================== 데이터 클래스 ====================

/// 연체 습관 인스턴스
class OverdueHabitInstance {
  final HabitData habit;
  final DateTime missedDate;

  OverdueHabitInstance({required this.habit, required this.missedDate});
}

/// 연체 작업 통계
class OverdueTaskStats {
  final int count;
  final DateTime? oldestDate;
  final int averageDaysOverdue;

  OverdueTaskStats({
    required this.count,
    required this.oldestDate,
    required this.averageDaysOverdue,
  });

  /// 요약 문자열 생성
  /// - 예: "30개의 연체된 작업 (평균 5일 지연)"
  String getSummary() {
    if (count == 0) return '연체된 작업 없음';
    if (count == 1) return '1개의 연체된 작업 ($averageDaysOverdue일 지연)';
    return '$count개의 연체된 작업 (평균 $averageDaysOverdue일 지연)';
  }
}
