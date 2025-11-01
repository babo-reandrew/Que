import 'package:drift/drift.dart';
import '../Database/schedule_database.dart';

/// ✅ every! (완료 기준 반복) 로직 구현
///
/// **목적:**
/// Todoist의 `every!` 또는 Asana의 "완료 시 복제" 로직을 구현하여
/// 완료 시점 기준으로 다음 인스턴스를 동적으로 생성한다.
///
/// **핵심 개념:**
/// - ABSOLUTE: 일정한 시간 간격으로 반복 (예: 매주 월요일)
/// - RELATIVE_ON_COMPLETION: 완료 시점 기준으로 반복 (예: 완료 후 3일마다)
///
/// **동작 방식:**
/// 1. 생성 시: 첫 PENDING 인스턴스만 생성
/// 2. 완료 시: 다음 날짜 계산 → 새 PENDING 인스턴스 생성
/// 3. 항상 PENDING 인스턴스 1개만 유지
///
/// **지원 엔티티:**
/// - Task (할일): executionDate 기반
/// - Habit (습관): completedDate 기반

// ==================== RELATIVE Task 생성 ====================

/// ✅ RELATIVE_ON_COMPLETION Task 생성
/// - Task + RecurringPattern (recurrence_mode='RELATIVE_ON_COMPLETION') 생성
/// - 첫 번째 PENDING 인스턴스는 생성하지 않음 (Task.executionDate로 관리)
Future<int> createRelativeRecurringTask({
  required AppDatabase db,
  required TaskCompanion task,
  required String rrule, // "FREQ=DAILY;INTERVAL=3" (완료 후 3일마다)
  required DateTime startDate,
}) async {
  int taskId = -1;

  await db.transaction(() async {
    // 1. Task 생성
    taskId = await db.createTask(task);

    // 2. RecurringPattern 생성 (recurrence_mode='RELATIVE_ON_COMPLETION')
    await db.createRecurringPattern(
      RecurringPatternCompanion.insert(
        entityType: 'task',
        entityId: taskId,
        rrule: rrule,
        dtstart: startDate,
        recurrenceMode: const Value('RELATIVE_ON_COMPLETION'), // 🔥 핵심
      ),
    );
  });

  return taskId;
}

/// ✅ RELATIVE Task 완료 처리 (다음 인스턴스 생성)
/// - 현재 Task를 완료 처리하지 않고, executionDate만 업데이트
/// - 완료 기록은 TaskCompletion에 저장
Future<void> completeRelativeRecurringTask({
  required AppDatabase db,
  required TaskData task,
  required DateTime completedDate,
}) async {
  await db.transaction(() async {
    // 1. RecurringPattern 조회
    final pattern = await db.getRecurringPattern(
      entityType: 'task',
      entityId: task.id,
    );

    if (pattern == null ||
        pattern.recurrenceMode != 'RELATIVE_ON_COMPLETION') {
      throw Exception('RELATIVE_ON_COMPLETION 패턴이 아닙니다');
    }

    // 2. 완료 기록 저장
    await db.recordTaskCompletion(task.id, completedDate);

    // 3. RRULE 기반 다음 날짜 계산
    final nextDate = _calculateNextRelativeDate(
      rrule: pattern.rrule,
      completionTime: DateTime.now(),
    );

    // 4. Task의 executionDate를 다음 날짜로 업데이트
    await (db.update(db.task)..where((tbl) => tbl.id.equals(task.id))).write(
      TaskCompanion(
        executionDate: Value(nextDate),
      ),
    );
  });
}

// ==================== RELATIVE Habit 생성 ====================

/// ✅ RELATIVE_ON_COMPLETION Habit 생성
/// - Habit + RecurringPattern (recurrence_mode='RELATIVE_ON_COMPLETION') 생성
/// - 첫 번째 PENDING 인스턴스는 생성하지 않음 (HabitCompletion으로 관리)
Future<int> createRelativeRecurringHabit({
  required AppDatabase db,
  required HabitCompanion habit,
  required String rrule, // "FREQ=DAILY;INTERVAL=3" (완료 후 3일마다)
  required DateTime startDate,
}) async {
  int habitId = -1;

  await db.transaction(() async {
    // 1. Habit 생성
    habitId = await db.createHabit(habit);

    // 2. RecurringPattern 생성 (recurrence_mode='RELATIVE_ON_COMPLETION')
    await db.createRecurringPattern(
      RecurringPatternCompanion.insert(
        entityType: 'habit',
        entityId: habitId,
        rrule: rrule,
        dtstart: startDate,
        recurrenceMode: const Value('RELATIVE_ON_COMPLETION'), // 🔥 핵심
      ),
    );
  });

  return habitId;
}

/// ✅ RELATIVE Habit 완료 처리 (다음 인스턴스 생성)
/// - 현재 날짜 완료 기록 저장
/// - 다음 날짜는 자동으로 표시되지 않음 (ABSOLUTE와 다르게 동작)
///
/// **NOTE:** RELATIVE Habit은 완료 시점 기준으로 "다음에 해야 할 날짜"를 계산하지만,
/// 캘린더에 미리 표시하지 않습니다. 대신 "마지막 완료 + INTERVAL" 이후부터만 표시됩니다.
Future<void> completeRelativeRecurringHabit({
  required AppDatabase db,
  required HabitData habit,
  required DateTime completedDate,
}) async {
  await db.transaction(() async {
    // 1. RecurringPattern 조회
    final pattern = await db.getRecurringPattern(
      entityType: 'habit',
      entityId: habit.id,
    );

    if (pattern == null ||
        pattern.recurrenceMode != 'RELATIVE_ON_COMPLETION') {
      throw Exception('RELATIVE_ON_COMPLETION 패턴이 아닙니다');
    }

    // 2. 완료 기록 저장
    await db.recordHabitCompletion(habit.id, completedDate);

    // 3. RRULE 기반 다음 날짜 계산 (참고용)
    // Habit의 경우 다음 날짜를 명시적으로 저장하지 않고,
    // 조회 시점에 "마지막 완료 + INTERVAL" 이후인지 확인하여 표시
    final nextDate = _calculateNextRelativeDate(
      rrule: pattern.rrule,
      completionTime: completedDate,
    );

    // 4. (선택) RecurringPattern의 dtstart를 업데이트하여 다음 시작 날짜 기록
    // 이렇게 하면 조회 로직에서 dtstart 이후 날짜만 표시 가능
    await db.updateRecurringPattern(
      RecurringPatternCompanion(
        id: Value(pattern.id),
        dtstart: Value(nextDate),
      ),
    );
  });
}

// ==================== RRULE 기반 다음 날짜 계산 ====================

/// ✅ RRULE 기반 다음 상대적 날짜 계산
/// - "FREQ=DAILY;INTERVAL=3" → completionTime + 3일
/// - "FREQ=WEEKLY;INTERVAL=1" → completionTime + 1주
/// - "FREQ=MONTHLY;INTERVAL=1" → completionTime + 1개월
DateTime _calculateNextRelativeDate({
  required String rrule,
  required DateTime completionTime,
}) {
  // RRULE 파싱
  final params = <String, String>{};
  for (final part in rrule.split(';')) {
    final kv = part.split('=');
    if (kv.length == 2) {
      params[kv[0]] = kv[1];
    }
  }

  final freq = params['FREQ'] ?? 'DAILY';
  final interval = int.tryParse(params['INTERVAL'] ?? '1') ?? 1;

  // 다음 날짜 계산
  switch (freq) {
    case 'DAILY':
      return completionTime.add(Duration(days: interval));

    case 'WEEKLY':
      return completionTime.add(Duration(days: 7 * interval));

    case 'MONTHLY':
      return DateTime(
        completionTime.year,
        completionTime.month + interval,
        completionTime.day,
      );

    case 'YEARLY':
      return DateTime(
        completionTime.year + interval,
        completionTime.month,
        completionTime.day,
      );

    default:
      return completionTime.add(Duration(days: interval));
  }
}

// ==================== RELATIVE 패턴 조회 로직 ====================

/// ✅ RELATIVE Task 조회 로직 (특정 날짜 기준)
/// - ABSOLUTE: RRULE로 모든 인스턴스 생성
/// - RELATIVE_ON_COMPLETION: executionDate만 확인
///
/// **NOTE:** Task의 경우 executionDate로 관리하므로 별도 로직 불필요
/// 기존 watchTasksWithRepeat()에서 자동 처리됨

/// ✅ RELATIVE Habit 조회 로직 (특정 날짜 기준)
/// - dtstart 이후 날짜만 표시
/// - 마지막 완료 기록 확인하여 "다음 날짜" 이후인지 검증
Future<bool> shouldShowRelativeHabit({
  required AppDatabase db,
  required HabitData habit,
  required RecurringPatternData pattern,
  required DateTime targetDate,
}) async {
  // 1. dtstart 이후 날짜만 표시
  final dtstart = DateTime(
    pattern.dtstart.year,
    pattern.dtstart.month,
    pattern.dtstart.day,
  );
  if (targetDate.isBefore(dtstart)) {
    return false;
  }

  // 2. 마지막 완료 기록 조회
  final query = db.select(db.habitCompletion)
    ..where((tbl) => tbl.habitId.equals(habit.id))
    ..orderBy([
      (tbl) =>
          OrderingTerm(expression: tbl.completedDate, mode: OrderingMode.desc),
    ])
    ..limit(1);

  final completions = await query.get();

  if (completions.isEmpty) {
    // 완료 기록 없음 → dtstart 이후부터 표시
    return true;
  }

  // 3. 마지막 완료 + INTERVAL 계산
  final lastCompletion = completions.first.completedDate;
  final nextDate = _calculateNextRelativeDate(
    rrule: pattern.rrule,
    completionTime: lastCompletion,
  );

  // 4. targetDate가 nextDate 이후인지 확인
  return targetDate.isAfter(nextDate) ||
      targetDate.isAtSameMomentAs(nextDate);
}

// ==================== RELATIVE 완료 취소(uncomplete) 로직 ====================

/// ✅ RELATIVE Task 완료 취소
/// - 현재 executionDate를 이전 완료 날짜로 되돌림
/// - TaskCompletion에서 해당 완료 기록 삭제
/// - 트랜잭션으로 원자성 보장
Future<void> uncompleteRelativeRecurringTask({
  required AppDatabase db,
  required TaskData task,
  required DateTime completedDateToUndo,
}) async {
  await db.transaction(() async {
    // 1. RecurringPattern 조회
    final pattern = await db.getRecurringPattern(
      entityType: 'task',
      entityId: task.id,
    );

    if (pattern == null ||
        pattern.recurrenceMode != 'RELATIVE_ON_COMPLETION') {
      throw Exception('RELATIVE_ON_COMPLETION 패턴이 아닙니다');
    }

    // 2. 완료 기록 삭제
    await (db.delete(db.taskCompletion)
          ..where(
            (tbl) =>
                tbl.taskId.equals(task.id) &
                tbl.completedDate.equals(completedDateToUndo),
          ))
        .go();

    // 3. Task의 executionDate를 이전 날짜로 되돌림
    // completedDateToUndo가 이전 executionDate였으므로, 그 날짜로 복원
    await (db.update(db.task)..where((tbl) => tbl.id.equals(task.id))).write(
      TaskCompanion(
        executionDate: Value(completedDateToUndo),
      ),
    );
  });
}

/// ✅ RELATIVE Habit 완료 취소
/// - RecurringPattern의 dtstart를 이전 완료 날짜로 되돌림
/// - HabitCompletion에서 해당 완료 기록 삭제
/// - 트랜잭션으로 원자성 보장
Future<void> uncompleteRelativeRecurringHabit({
  required AppDatabase db,
  required HabitData habit,
  required DateTime completedDateToUndo,
}) async {
  await db.transaction(() async {
    // 1. RecurringPattern 조회
    final pattern = await db.getRecurringPattern(
      entityType: 'habit',
      entityId: habit.id,
    );

    if (pattern == null ||
        pattern.recurrenceMode != 'RELATIVE_ON_COMPLETION') {
      throw Exception('RELATIVE_ON_COMPLETION 패턴이 아닙니다');
    }

    // 2. 완료 기록 삭제
    await (db.delete(db.habitCompletion)
          ..where(
            (tbl) =>
                tbl.habitId.equals(habit.id) &
                tbl.completedDate.equals(completedDateToUndo),
          ))
        .go();

    // 3. 이전 완료 기록 조회 (완료 취소 후 가장 최근 완료)
    final query = db.select(db.habitCompletion)
      ..where((tbl) => tbl.habitId.equals(habit.id))
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.completedDate, mode: OrderingMode.desc),
      ])
      ..limit(1);

    final previousCompletions = await query.get();

    DateTime previousDtstart;
    if (previousCompletions.isEmpty) {
      // 완료 기록이 없으면 원래 dtstart로 되돌림
      // 완료 취소된 날짜를 dtstart로 설정
      previousDtstart = DateTime(
        completedDateToUndo.year,
        completedDateToUndo.month,
        completedDateToUndo.day,
      );
    } else {
      // 이전 완료가 있으면 그 다음 날짜 계산
      final lastCompletion = previousCompletions.first.completedDate;
      previousDtstart = _calculateNextRelativeDate(
        rrule: pattern.rrule,
        completionTime: lastCompletion,
      );
    }

    // 4. RecurringPattern의 dtstart를 이전 값으로 되돌림
    await db.updateRecurringPattern(
      RecurringPatternCompanion(
        id: Value(pattern.id),
        dtstart: Value(previousDtstart),
      ),
    );
  });
}
