import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import '../model/schedule.dart';
import '../model/entities.dart'; // ✅ Task, Habit, HabitCompletion 추가
import '../model/temp_extracted_items.dart'; // ✅ 임시 추출 항목 테이블
import '../utils/rrule_utils.dart'; // ✅ RRULE 유틸리티 추가
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';

//part '../const/color.dart'; //part파일은 완전히 다른 파일을 하나의 파일 처럼 관리를 할 수 있ㄱ 된다.
//즉, 데이터베이스 파일과 color.dart를 하나의 파일처럼 관리를 하라는 것이다.
//그래서 우리가 color.dart에 있는 값을 임포트 하지 않아도 쓸 수 있다.
part 'schedule_database.g.dart'; //g.을 붙이는 건 생성된 파일이라는 의미를 전달한다.
//g.를 붙여주면 즉, 자동으로 설치가 되거나 실행이 될 때 자동으로 설치도도록 한다.

// ✅ 12개 테이블: Schedule, Task, Habit, HabitCompletion, ScheduleCompletion, TaskCompletion, DailyCardOrder, AudioContents, TranscriptLines, RecurringPattern, RecurringException, TempExtractedItems
// ⚠️ AudioProgress 제거됨 → AudioContents에 재생 상태 통합
@DriftDatabase(
  tables: [
    Schedule,
    Task,
    Habit,
    HabitCompletion,
    ScheduleCompletion, // ✅ 새로 추가: 일정 완료 기록 (반복 일정 완료 처리용)
    TaskCompletion, // ✅ 새로 추가: 할일 완료 기록 (반복 할일 완료 처리용)
    DailyCardOrder,
    AudioContents,
    TranscriptLines,
    RecurringPattern,
    RecurringException,
    TempExtractedItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // ✅ 테스트용 생성자 추가
  AppDatabase.forTesting(super.e);

  // ==================== 🔧 마이그레이션 함수 ====================

  /// RecurringPattern의 dtstart를 날짜만으로 정규화 (시간 제거)
  /// 🔥 UTC 변환 시 날짜가 밀리는 문제를 해결하기 위한 마이그레이션
  Future<void> normalizeDtstartDates() async {
    // 모든 RecurringPattern 조회
    final patterns = await select(recurringPattern).get();

    for (final pattern in patterns) {
      // 날짜만 추출 (시간은 00:00:00으로)
      final normalizedDate = DateTime(
        pattern.dtstart.year,
        pattern.dtstart.month,
        pattern.dtstart.day,
      );

      // dtstart가 이미 00:00:00이면 스킵
      if (pattern.dtstart.hour == 0 &&
          pattern.dtstart.minute == 0 &&
          pattern.dtstart.second == 0) {
        continue;
      }

      // 업데이트
      await (update(recurringPattern)
            ..where((tbl) => tbl.id.equals(pattern.id)))
          .write(RecurringPatternCompanion(dtstart: Value(normalizedDate)));
    }
  }

  // ==================== 조회 함수 ====================

  /// 전체 일정을 조회하는 함수 (일회성 조회)
  /// 이거를 설정하고 → select(schedule)로 테이블 전체를 선택해서
  /// 이거를 해서 → get()으로 데이터를 가져온다
  Future<List<ScheduleData>> getSchedules() async {
    final result = await select(schedule).get();
    return result;
  }

  /// 특정 ID의 일정 조회
  Future<ScheduleData?> getScheduleById(int id) async {
    final result = await (select(
      schedule,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return result;
  }

  /// 특정 날짜의 일정만 조회하는 함수 (메모리 효율적)
  /// 이거를 설정하고 → 선택한 날짜의 00:00부터 다음날 00:00 전까지의 범위를 계산해서
  /// 이거를 해서 → 해당 구간과 겹치는 일정만 DB에서 필터링한다
  /// 이거는 이래서 → 메모리 부담 없이 필요한 데이터만 가져온다
  /// 이거라면 → 월뷰나 디테일뷰에서 특정 날짜만 조회할 때 사용한다
  Future<List<ScheduleData>> getSchedulesByDate(DateTime selectedDate) async {
    final dayStart = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final dayEnd = dayStart.add(const Duration(days: 1));

    final result =
        await (select(schedule)
              ..where((tbl) => tbl.start.isBiggerThanValue(dayStart))
              ..where((tbl) => tbl.start.isSmallerThanValue(dayEnd)))
            .get();

    return result;
  }

  /// 전체 일정을 실시간으로 관찰하는 함수 (Stream 반환)
  /// 이거는 이래서 → DB가 변경될 때마다 자동으로 새로운 데이터를 전달한다
  /// 이거라면 → UI에서 StreamBuilder로 받아서 자동 갱신이 가능하다
  /// 이거를 설정하고 → orderBy로 시작시간 오름차순, 같으면 제목 오름차순으로 정렬한다
  Stream<List<ScheduleData>> watchSchedules() {
    return (select(schedule)..orderBy([
          (tbl) => OrderingTerm(expression: tbl.start, mode: OrderingMode.asc),
          (tbl) =>
              OrderingTerm(expression: tbl.summary, mode: OrderingMode.asc),
        ]))
        .watch();
  }

  /// 특정 날짜 범위의 일정을 실시간으로 관찰하는 함수 (캘린더 최적화용)
  /// 이거를 설정하고 → 캘린더에 보이는 범위(시작일~종료일)의 일정만 가져온다
  /// 이거는 이래서 → 1000개가 아닌 30~60개 정도만 로드해서 성능 향상
  Stream<List<ScheduleData>> watchSchedulesInRange(
    DateTime startDate,
    DateTime endDate,
  ) async* {
    // 모든 일정을 실시간으로 관찰
    await for (final schedules in watchSchedules()) {
      final result = <ScheduleData>[];

      for (final schedule in schedules) {
        // 1. 반복 규칙 조회
        final pattern = await getRecurringPattern(
          entityType: 'schedule',
          entityId: schedule.id,
        );

        if (pattern == null) {
          // 일반 일정: 날짜 범위 체크
          if (schedule.end.isAfter(startDate) &&
              schedule.start.isBefore(endDate)) {
            result.add(schedule);
          }
        } else {
          // 반복 일정: RRULE로 범위 내 인스턴스 확인
          try {
            final instances = await _generateRRuleInstances(
              rrule: pattern.rrule,
              dtstart: pattern.dtstart,
              rangeStart: startDate,
              rangeEnd: endDate,
              exdates: pattern.exdate.isEmpty
                  ? null
                  : pattern.exdate
                        .split(',')
                        .map((s) {
                          try {
                            return DateTime.parse(s.trim());
                          } catch (e) {
                            return null;
                          }
                        })
                        .whereType<DateTime>()
                        .toList(),
              until: pattern.until, // ✅ UNTIL 전달
            );

            // 예외 처리 (취소된 인스턴스 제외)
            final exceptions = await getRecurringExceptions(pattern.id);
            final cancelledDates = exceptions
                .where((e) => e.isCancelled)
                .map((e) => _normalizeDate(e.originalDate))
                .toSet();

            final validInstances = instances
                .where((date) => !cancelledDates.contains(_normalizeDate(date)))
                .toList();

            if (validInstances.isNotEmpty) {
              result.add(schedule);
            }
          } catch (e) {
            // 실패 시 원본 날짜 기준으로 폴백
            if (schedule.end.isAfter(startDate) &&
                schedule.start.isBefore(endDate)) {
              result.add(schedule);
            }
          }
        }
      }

      yield result;
    }
  }

  /// 특정 날짜의 일정만 조회하는 함수 (일회성 조회)
  /// 이거를 설정하고 → 선택한 날짜의 00:00부터 다음날 00:00 전까지의 범위를 계산해서
  /// 이거를 해서 → 해당 구간과 겹치는 일정만 필터링한다
  /// 이거는 이래서 → 구글 캘린더처럼 종일/다일 이벤트도 정확히 포함된다
  Future<List<ScheduleData>> getByDay(DateTime selected) async {
    final dayStart = DateTime(selected.year, selected.month, selected.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final result =
        await (select(schedule)..where(
              (tbl) =>
                  tbl.end.isBiggerThanValue(dayStart) &
                  tbl.start.isSmallerThanValue(dayEnd),
            ))
            .get();

    return result;
  }

  /// 특정 날짜의 일정을 실시간으로 관찰하는 함수 (Stream 반환)
  /// 이거라면 → DateDetailView에서 사용해 해당 날짜 일정만 실시간 갱신한다
  /// 이거를 설정하고 → orderBy로 시작시간 오름차순, 같으면 제목 오름차순으로 정렬한다
  Stream<List<ScheduleData>> watchByDay(DateTime selected) {
    final dayStart = DateTime(selected.year, selected.month, selected.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return (select(schedule)
          ..where(
            (tbl) =>
                tbl.end.isBiggerThanValue(dayStart) &
                tbl.start.isSmallerThanValue(dayEnd),
          )
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.start, mode: OrderingMode.asc),
            (tbl) =>
                OrderingTerm(expression: tbl.summary, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  // ==================== 생성 함수 ====================

  /// 새로운 일정을 생성하는 함수
  /// 이거를 설정하고 → ScheduleCompanion 데이터를 받아서
  /// 이거를 해서 → into(schedule)로 테이블에 삽입하고
  /// 이거는 이래서 → 삽입된 행의 id를 int로 반환한다 (자동 생성)
  Future<int> createSchedule(ScheduleCompanion data) async {
    // 🔥 반복 일정일 경우 원본 시간 자동 저장
    ScheduleCompanion finalData = data;

    if (data.start.present &&
        (data.originalHour.present == false ||
            data.originalHour.value == null)) {
      final startTime = data.start.value;
      finalData = data.copyWith(
        originalHour: Value(startTime.hour),
        originalMinute: Value(startTime.minute),
      );
    }

    final id = await into(schedule).insert(finalData);
    return id;
  }

  // ==================== 수정 함수 ====================

  /// 기존 일정을 수정하는 함수
  /// 이거를 설정하고 → ScheduleCompanion에 id와 변경할 필드를 담아서
  /// 이거를 해서 → update로 해당 id의 행을 업데이트한다
  /// 이거라면 → 성공 시 true를 반환한다
  Future<bool> updateSchedule(ScheduleCompanion data) async {
    final result = await update(schedule).replace(data);
    if (result) {}
    return result;
  }

  // ==================== 삭제 함수 ====================

  /// 특정 일정을 삭제하는 함수
  /// 이거를 설정하고 → 삭제할 일정의 id를 받아서
  /// 이거를 해서 → delete로 해당 id의 행을 삭제한다
  /// 이거는 이래서 → 삭제된 행의 개수를 반환한다 (보통 1 또는 0)
  Future<int> deleteSchedule(int id) async {
    final count = await (delete(
      schedule,
    )..where((tbl) => tbl.id.equals(id))).go();
    return count;
  }

  // ==================== 완료 처리 함수 ====================
  // ==================== Task (할일) 함수 ====================

  /// 할일 생성
  /// 이거를 설정하고 → TaskCompanion 데이터를 받아서
  /// 이거를 해서 → into(task).insert()로 DB에 저장한다
  Future<int> createTask(TaskCompanion data) async {
    final id = await into(task).insert(data);
    return id;
  }

  /// 특정 ID의 할일 조회
  Future<TaskData?> getTaskById(int id) async {
    final result = await (select(
      task,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return result;
  }

  /// 할일 목록 조회 (스트림)
  /// 이거를 설정하고 → task 테이블을 watch()로 구독해서
  /// 이거를 해서 → 실시간으로 할일 목록을 받는다
  /// 이거는 이래서 → executionDate가 있으면 그 날짜로 정렬하고, 없으면 인박스에만 표시
  Stream<List<TaskData>> watchTasks() {
    return (select(task)..orderBy([
          (tbl) => OrderingTerm(expression: tbl.completed), // 미완료 먼저
          (tbl) => OrderingTerm(
            expression: tbl.executionDate,
          ), // 실행일 순 (executionDate 우선)
          (tbl) => OrderingTerm(expression: tbl.dueDate), // 마감일 순
          (tbl) => OrderingTerm(expression: tbl.title), // 제목 순
        ]))
        .watch();
  }

  /// 할일 완료 처리
  /// 이거를 설정하고 → completed를 true로 업데이트하고
  /// 이거를 해서 → completedAt에 현재 시간을 기록한다
  Future<int> completeTask(int id) async {
    final now = DateTime.now();
    final count = await (update(task)..where((tbl) => tbl.id.equals(id))).write(
      TaskCompanion(completed: const Value(true), completedAt: Value(now)),
    );
    return count;
  }

  /// 할일 완료 해제
  /// 이거를 설정하고 → completed를 false로 업데이트하고
  /// 이거를 해서 → completedAt을 null로 초기화한다
  Future<int> uncompleteTask(int id) async {
    final count = await (update(task)..where((tbl) => tbl.id.equals(id))).write(
      const TaskCompanion(completed: Value(false), completedAt: Value(null)),
    );
    return count;
  }

  /// 할일 삭제
  /// 이거를 설정하고 → 특정 id의 할일을 삭제해서
  /// 이거를 해서 → DB에서 영구 제거한다
  Future<int> deleteTask(int id) async {
    final count = await (delete(task)..where((tbl) => tbl.id.equals(id))).go();
    return count;
  }

  /// 일정 완료 처리
  /// 이거를 설정하고 → completed를 true로 업데이트하고
  /// 이거를 해서 → completedAt에 현재 시간을 기록한다
  Future<int> completeSchedule(int id) async {
    final now = DateTime.now();
    final count = await (update(schedule)..where((tbl) => tbl.id.equals(id)))
        .write(
          ScheduleCompanion(
            completed: const Value(true),
            completedAt: Value(now),
          ),
        );
    return count;
  }

  /// 일정 완료 해제
  /// 이거를 설정하고 → completed를 false로 업데이트하고
  /// 이거를 해서 → completedAt을 null로 초기화한다
  Future<int> uncompleteSchedule(int id) async {
    final count = await (update(schedule)..where((tbl) => tbl.id.equals(id)))
        .write(
          const ScheduleCompanion(
            completed: Value(false),
            completedAt: Value(null),
          ),
        );
    return count;
  }

  /// 🎯 할일 날짜 업데이트 (드래그 앤 드롭용)
  /// 이거를 설정하고 → 특정 id의 할일의 executionDate를 새로운 날짜로 업데이트해서
  /// 이거를 해서 → 인박스에서 캘린더로 드래그 시 해당 날짜로 이동하고
  /// 이거는 이래서 → DetailView에 표시되며, executionDate가 없으면 Inbox에만 표시된다
  Future<int> updateTaskDate(int id, DateTime newDate) async {
    final count = await (update(task)..where((tbl) => tbl.id.equals(id))).write(
      TaskCompanion(executionDate: Value(newDate)), // ✅ executionDate로 변경
    );
    return count;
  }

  /// 📥 할일을 인박스로 이동 (executionDate 제거)
  /// 이거를 설정하고 → 특정 id의 할일의 executionDate를 null로 설정해서
  /// 이거를 해서 → 해당 할일을 인박스로 이동시키고
  /// 이거는 이래서 → 캘린더 날짜에서 제거되고 Inbox에만 표시된다
  Future<int> moveTaskToInbox(int id) async {
    final count = await (update(task)..where((tbl) => tbl.id.equals(id))).write(
      const TaskCompanion(
        executionDate: Value(null),
      ), // ✅ executionDate를 null로 설정
    );
    return count;
  }

  /// 📥 인박스 할일 순서 업데이트 (드래그 앤 드롭용)
  /// 이거를 설정하고 → 인박스의 모든 할일의 inboxOrder를 일괄 업데이트해서
  /// 이거를 해서 → 사용자가 드래그 앤 드롭으로 정한 순서를 저장하고
  /// 이거는 이래서 → 다음에 인박스를 열 때 같은 순서로 표시된다
  Future<void> updateInboxTasksOrder(List<int> taskIds) async {
    await transaction(() async {
      for (int i = 0; i < taskIds.length; i++) {
        final taskId = taskIds[i];
        await (update(task)..where((tbl) => tbl.id.equals(taskId))).write(
          TaskCompanion(inboxOrder: Value(i)),
        );
      }
    });
  }

  // ==================== Habit (습관) 함수 ====================

  /// 습관 생성
  /// 이거를 설정하고 → HabitCompanion 데이터를 받아서
  /// 이거를 해서 → into(habit).insert()로 DB에 저장한다
  Future<int> createHabit(HabitCompanion data) async {
    final id = await into(habit).insert(data);
    return id;
  }

  /// 특정 ID의 습관 조회
  Future<HabitData?> getHabitById(int id) async {
    final result = await (select(
      habit,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return result;
  }

  /// 습관 목록 조회 (스트림)
  /// 이거를 설정하고 → habit 테이블을 watch()로 구독해서
  /// 이거를 해서 → 실시간으로 습관 목록을 받는다
  Stream<List<HabitData>> watchHabits() {
    return (select(habit)..orderBy([
          (tbl) =>
              OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  /// 습관 완료 기록 추가
  /// 이거를 설정하고 → 특정 날짜에 습관을 완료했다고 기록해서
  /// 이거를 해서 → HabitCompletion 테이블에 저장한다
  Future<int> recordHabitCompletion(int habitId, DateTime date) async {
    final companion = HabitCompletionCompanion.insert(
      habitId: habitId,
      completedDate: date,
      createdAt: DateTime.now(),
    );
    final id = await into(habitCompletion).insert(companion);
    return id;
  }

  /// 습관 완료 기록 삭제 (완료 해제용)
  /// 이거를 설정하고 → 특정 날짜의 특정 습관 완료 기록을 삭제해서
  /// 이거를 해서 → 완료 상태를 해제한다
  Future<int> deleteHabitCompletion(int habitId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final count =
        await (delete(habitCompletion)..where(
              (tbl) =>
                  tbl.habitId.equals(habitId) &
                  tbl.completedDate.isBiggerOrEqualValue(startOfDay) &
                  tbl.completedDate.isSmallerOrEqualValue(endOfDay),
            ))
            .go();
    return count;
  }

  /// 특정 날짜의 습관 완료 기록 조회
  /// 이거를 설정하고 → 특정 날짜의 완료 기록을 조회해서
  /// 이거를 해서 → 오늘 완료한 습관 목록을 확인한다
  Future<List<HabitCompletionData>> getHabitCompletionsByDate(
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result =
        await (select(habitCompletion)..where(
              (tbl) =>
                  tbl.completedDate.isBiggerOrEqualValue(startOfDay) &
                  tbl.completedDate.isSmallerOrEqualValue(endOfDay),
            ))
            .get();

    return result;
  }

  /// 특정 날짜의 습관 완료 기록 실시간 감지
  /// 이거를 설정하고 → 특정 날짜의 완료 기록을 실시간으로 감시해서
  /// 이거를 해서 → HabitCard가 완료 상태를 즉시 반영한다
  Stream<List<HabitCompletionData>> watchHabitCompletionsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return (select(habitCompletion)..where(
          (tbl) =>
              tbl.completedDate.isBiggerOrEqualValue(startOfDay) &
              tbl.completedDate.isSmallerOrEqualValue(endOfDay),
        ))
        .watch();
  }

  /// 습관 삭제
  /// 이거를 설정하고 → 특정 id의 습관을 삭제해서
  /// 이거를 해서 → DB에서 영구 제거한다
  Future<int> deleteHabit(int id) async {
    // 1. 습관 완료 기록도 함께 삭제
    await (delete(
      habitCompletion,
    )..where((tbl) => tbl.habitId.equals(id))).go();

    // 2. 습관 삭제
    final count = await (delete(habit)..where((tbl) => tbl.id.equals(id))).go();
    return count;
  }

  // ==================== ScheduleCompletion (일정 완료 기록) 함수 ====================

  /// 일정 완료 기록 추가
  /// 이거를 설정하고 → 특정 날짜에 일정을 완료했다고 기록해서
  /// 이거를 해서 → ScheduleCompletion 테이블에 저장한다
  /// 이거는 이래서 → 반복 일정의 특정 인스턴스만 완료 처리한다
  Future<int> recordScheduleCompletion(int scheduleId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final companion = ScheduleCompletionCompanion.insert(
      scheduleId: scheduleId,
      completedDate: dateOnly,
      createdAt: DateTime.now(),
    );
    final id = await into(scheduleCompletion).insert(companion);
    return id;
  }

  /// 일정 완료 기록 삭제 (완료 해제용)
  /// 이거를 설정하고 → 특정 날짜의 특정 일정 완료 기록을 삭제해서
  /// 이거를 해서 → 완료 상태를 해제한다
  Future<int> deleteScheduleCompletion(int scheduleId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final count =
        await (delete(scheduleCompletion)..where(
              (tbl) =>
                  tbl.scheduleId.equals(scheduleId) &
                  tbl.completedDate.equals(dateOnly),
            ))
            .go();
    return count;
  }

  /// 특정 날짜의 일정 완료 기록 조회
  /// 이거를 설정하고 → 특정 날짜의 완료 기록을 조회해서
  /// 이거를 해서 → 오늘 완료한 일정 목록을 확인한다
  Future<List<ScheduleCompletionData>> getScheduleCompletionsByDate(
    DateTime date,
  ) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final result = await (select(
      scheduleCompletion,
    )..where((tbl) => tbl.completedDate.equals(dateOnly))).get();

    return result;
  }

  /// 특정 일정의 특정 날짜 완료 기록 조회 (단일)
  /// 이거를 설정하고 → 특정 일정이 특정 날짜에 완료되었는지 확인해서
  /// 이거를 해서 → 월뷰에서 완료된 일정을 숨긴다
  Future<ScheduleCompletionData?> getScheduleCompletion(
    int scheduleId,
    DateTime date,
  ) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final result =
        await (select(scheduleCompletion)..where(
              (tbl) =>
                  tbl.scheduleId.equals(scheduleId) &
                  tbl.completedDate.equals(dateOnly),
            ))
            .getSingleOrNull();

    return result;
  }

  // ==================== TaskCompletion (할일 완료 기록) 함수 ====================

  /// 할일 완료 기록 추가
  /// 이거를 설정하고 → 특정 날짜에 할일을 완료했다고 기록해서
  /// 이거를 해서 → TaskCompletion 테이블에 저장한다
  /// 이거는 이래서 → 반복 할일의 특정 인스턴스만 완료 처리한다
  Future<int> recordTaskCompletion(int taskId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final companion = TaskCompletionCompanion.insert(
      taskId: taskId,
      completedDate: dateOnly,
      createdAt: DateTime.now(),
    );
    final id = await into(taskCompletion).insert(companion);
    return id;
  }

  /// 할일 완료 기록 삭제 (완료 해제용)
  /// 이거를 설정하고 → 특정 날짜의 특정 할일 완료 기록을 삭제해서
  /// 이거를 해서 → 완료 상태를 해제한다
  Future<int> deleteTaskCompletion(int taskId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final count =
        await (delete(taskCompletion)..where(
              (tbl) =>
                  tbl.taskId.equals(taskId) &
                  tbl.completedDate.equals(dateOnly),
            ))
            .go();
    return count;
  }

  /// 특정 날짜의 할일 완료 기록 조회
  /// 이거를 설정하고 → 특정 날짜의 완료 기록을 조회해서
  /// 이거를 해서 → 오늘 완료한 할일 목록을 확인한다
  Future<List<TaskCompletionData>> getTaskCompletionsByDate(
    DateTime date,
  ) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final result = await (select(
      taskCompletion,
    )..where((tbl) => tbl.completedDate.equals(dateOnly))).get();

    return result;
  }

  /// 특정 날짜의 할일 완료 기록 실시간 감지
  /// 이거를 설정하고 → 특정 날짜의 완료 기록을 실시간으로 감시해서
  /// 이거를 해서 → TaskCard가 완료 상태를 즉시 반영한다
  Stream<List<TaskCompletionData>> watchTaskCompletionsByDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    return (select(
      taskCompletion,
    )..where((tbl) => tbl.completedDate.equals(dateOnly))).watch();
  }

  /// 특정 할일의 특정 날짜 완료 기록 조회 (단일)
  /// 이거를 설정하고 → 특정 할일이 특정 날짜에 완료되었는지 확인해서
  /// 이거를 해서 → 월뷰에서 완료된 할일을 숨긴다
  Future<TaskCompletionData?> getTaskCompletion(
    int taskId,
    DateTime date,
  ) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final result =
        await (select(taskCompletion)..where(
              (tbl) =>
                  tbl.taskId.equals(taskId) &
                  tbl.completedDate.equals(dateOnly),
            ))
            .getSingleOrNull();

    return result;
  }

  // ==================== RecurringPattern (반복 규칙) 함수 ====================

  /// 반복 규칙 생성
  /// 이거를 설정하고 → RecurringPatternCompanion 데이터를 받아서
  /// 이거를 해서 → 일정/할일/습관에 반복 규칙을 설정하고
  /// 이거는 이래서 → RRULE 표준으로 반복 패턴을 저장한다
  Future<int> createRecurringPattern(RecurringPatternCompanion data) async {
    final id = await into(recurringPattern).insert(data);
    return id;
  }

  /// 특정 엔티티의 반복 규칙 조회
  /// 이거를 설정하고 → entityType과 entityId로 조회해서
  /// 이거를 해서 → 해당 일정/할일/습관의 반복 규칙을 가져온다
  Future<RecurringPatternData?> getRecurringPattern({
    required String entityType,
    required int entityId,
  }) async {
    final result =
        await (select(recurringPattern)..where(
              (tbl) =>
                  tbl.entityType.equals(entityType) &
                  tbl.entityId.equals(entityId),
            ))
            .getSingleOrNull();

    return result;
  }

  /// 반복 규칙 수정
  /// 이거를 설정하고 → 기존 반복 규칙을 업데이트해서
  /// 이거를 해서 → RRULE, UNTIL, COUNT 등을 변경한다
  Future<bool> updateRecurringPattern(RecurringPatternCompanion data) async {
    // ✅ FIX: write()를 사용하여 부분 업데이트 지원 (replace는 모든 필드 필요)
    final count = await (update(
      recurringPattern,
    )..where((tbl) => tbl.id.equals(data.id.value))).write(data);
    return count > 0;
  }

  /// 반복 규칙 삭제
  /// 이거를 설정하고 → 특정 엔티티의 반복 규칙을 삭제해서
  /// 이거를 해서 → 일반 일정/할일/습관으로 변경한다
  Future<int> deleteRecurringPattern({
    required String entityType,
    required int entityId,
  }) async {
    final count =
        await (delete(recurringPattern)..where(
              (tbl) =>
                  tbl.entityType.equals(entityType) &
                  tbl.entityId.equals(entityId),
            ))
            .go();

    return count;
  }

  /// EXDATE 추가 (단일 인스턴스 삭제)
  /// 이거를 설정하고 → 기존 EXDATE 문자열에 새 날짜를 추가해서
  /// 이거를 해서 → 특정 발생을 제외한다
  Future<bool> addExdate({
    required String entityType,
    required int entityId,
    required DateTime dateToExclude,
  }) async {
    final pattern = await getRecurringPattern(
      entityType: entityType,
      entityId: entityId,
    );

    if (pattern == null) {
      return false;
    }

    // 기존 EXDATE 파싱
    final existingExdates = pattern.exdate.isEmpty
        ? <String>[]
        : pattern.exdate.split(',');

    // 새 날짜 포맷 (YYYYMMDDTHHMMSSZ)
    final newExdate = _formatDateTime(dateToExclude);

    // 중복 체크
    if (existingExdates.contains(newExdate)) {
      return false;
    }

    // EXDATE 문자열 업데이트
    existingExdates.add(newExdate);
    final updatedExdate = existingExdates.join(',');

    // DB 업데이트
    final result =
        await (update(recurringPattern)
              ..where((tbl) => tbl.id.equals(pattern.id)))
            .write(RecurringPatternCompanion(exdate: Value(updatedExdate)));

    return result > 0;
  }

  /// 날짜 포맷 헬퍼 (iCalendar 형식)
  /// ✅ 로컬 날짜 사용 (UTC 변환하지 않음)
  String _formatDateTime(DateTime dt) {
    // 🔥 중요: 날짜만 사용하므로 로컬 날짜 그대로 포맷
    // UTC 변환하면 시간대 차이로 날짜가 밀리는 문제 발생
    return '${dt.year}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}'
        'T'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}'
        'Z';
  }

  // ==================== RecurringException (예외 인스턴스) 함수 ====================

  /// 반복 예외 생성 (단일 인스턴스 수정/삭제)
  /// 이거를 설정하고 → RecurringExceptionCompanion 데이터를 받아서
  /// 이거를 해서 → 특정 발생을 수정하거나 취소한다
  Future<int> createRecurringException(RecurringExceptionCompanion data) async {
    final id = await into(recurringException).insert(data);
    return id;
  }

  /// 특정 반복 규칙의 예외 목록 조회
  /// 이거를 설정하고 → recurringPatternId로 조회해서
  /// 이거를 해서 → 수정/삭제된 인스턴스 목록을 가져온다
  Future<List<RecurringExceptionData>> getRecurringExceptions(
    int recurringPatternId,
  ) async {
    final result =
        await (select(recurringException)
              ..where(
                (tbl) => tbl.recurringPatternId.equals(recurringPatternId),
              )
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.originalDate,
                  mode: OrderingMode.asc,
                ),
              ]))
            .get();

    return result;
  }

  /// 특정 날짜의 예외 조회
  /// 이거를 설정하고 → 특정 날짜의 예외를 조회해서
  /// 이거를 해서 → 해당 날짜가 수정/취소되었는지 확인한다
  Future<RecurringExceptionData?> getRecurringExceptionByDate({
    required int recurringPatternId,
    required DateTime originalDate,
  }) async {
    final result =
        await (select(recurringException)..where(
              (tbl) =>
                  tbl.recurringPatternId.equals(recurringPatternId) &
                  tbl.originalDate.equals(originalDate),
            ))
            .getSingleOrNull();

    return result;
  }

  /// 반복 예외 삭제
  /// 이거를 설정하고 → 특정 예외를 삭제해서
  /// 이거를 해서 → 해당 날짜를 원래 반복 규칙대로 복원한다
  Future<int> deleteRecurringException(int id) async {
    final count = await (delete(
      recurringException,
    )..where((tbl) => tbl.id.equals(id))).go();
    return count;
  }

  // ==================== DailyCardOrder (날짜별 카드 순서) 함수 ====================

  /// 습관 수정
  /// 이거를 설정하고 → HabitCompanion에 id와 변경할 필드를 담아서
  /// 이거를 해서 → update로 해당 id의 행을 업데이트한다
  /// 이거라면 → 성공 시 true를 반환한다
  Future<bool> updateHabit(HabitCompanion data) async {
    final result = await update(habit).replace(data);
    if (result) {}
    return result;
  }

  // ==================== DailyCardOrder (날짜별 카드 순서) 함수 ====================

  /// 특정 날짜의 카드 순서 조회 (실시간 스트림)
  /// 이거를 설정하고 → date를 받아서 해당 날짜의 모든 카드 순서를 실시간으로 가져오고
  /// 이거를 해서 → sortOrder 기준으로 정렬된 DailyCardOrderData를 반환한다
  /// 이거는 이래서 → 사용자가 설정한 커스텀 순서를 복원할 수 있다
  Stream<List<DailyCardOrderData>> watchDailyCardOrder(DateTime date) {
    // 이거를 설정하고 → 날짜를 00:00:00으로 정규화해서
    // 이거를 해서 → 시간 상관없이 같은 날짜로 인식되도록 한다
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // 이거를 설정하고 → dailyCardOrder 테이블에서 해당 날짜 필터링해서
    // 이거를 해서 → sortOrder 오름차순으로 정렬하고
    // 이거는 이래서 → 실시간으로 순서 변경을 감지한다
    return (select(dailyCardOrder)
          ..where((tbl) => tbl.date.equals(normalizedDate))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.sortOrder, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  /// 날짜별 카드 순서 저장 (전체 교체)
  /// 이거를 설정하고 → 날짜와 UnifiedListItem 리스트를 받아서
  /// 이거를 해서 → 기존 순서를 삭제하고 새로운 순서로 저장한다
  /// 이거는 이래서 → 드래그앤드롭 재정렬 시 호출된다
  /// 이거라면 → 트랜잭션으로 원자성을 보장한다
  Future<void> saveDailyCardOrder(
    DateTime date,
    List<Map<String, dynamic>> items,
  ) async {
    // 이거를 설정하고 → 날짜를 00:00:00으로 정규화해서
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // 이거를 설정하고 → transaction()으로 묶어서
    // 이거를 해서 → 삭제와 삽입이 하나의 단위로 실행되고
    // 이거는 이래서 → 에러 발생 시 자동 롤백된다
    await transaction(() async {
      // 1️⃣ 기존 순서 삭제
      // 이거를 설정하고 → 해당 날짜의 모든 순서 데이터를 삭제해서
      // 이거를 해서 → 깨끗한 상태에서 새로 저장한다
      final deleteCount = await (delete(
        dailyCardOrder,
      )..where((tbl) => tbl.date.equals(normalizedDate))).go();

      // 2️⃣ 새로운 순서 삽입
      // 이거를 설정하고 → items를 순회하면서
      // 이거를 해서 → 각 카드의 순서 정보를 DB에 저장한다
      int insertCount = 0;
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final type = item['type'] as String;
        final id = item['id'] as int?;

        // 이거를 설정하고 → divider, completed는 제외해서
        // 이거를 해서 → 실제 카드 데이터만 저장한다
        // 이거는 이래서 → 점선이나 완료 섹션은 동적으로 삽입되기 때문
        if (type == 'divider' || type == 'completed' || id == null) {
          continue;
        }

        // 이거를 설정하고 → DailyCardOrderCompanion을 생성해서
        // 이거를 해서 → 날짜, 타입, ID, 순서를 DB에 저장한다
        await into(dailyCardOrder).insert(
          DailyCardOrderCompanion(
            date: Value(normalizedDate),
            cardType: Value(type),
            cardId: Value(id),
            sortOrder: Value(i),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
        insertCount++;
      }
    });
  }

  /// 특정 카드의 순서만 업데이트 (단일 업데이트)
  /// 이거를 설정하고 → 하나의 카드만 순서를 변경할 때 사용해서
  /// 이거를 해서 → 전체 삭제/삽입 없이 효율적으로 업데이트한다
  /// 이거는 이래서 → 미세 조정 시 성능이 좋다
  Future<void> updateCardOrder(
    DateTime date,
    String cardType,
    int cardId,
    int newOrder,
  ) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // 이거를 설정하고 → update로 특정 카드만 찾아서
    // 이거를 해서 → sortOrder와 updatedAt만 업데이트한다
    final count =
        await (update(dailyCardOrder)..where(
              (tbl) =>
                  tbl.date.equals(normalizedDate) &
                  tbl.cardType.equals(cardType) &
                  tbl.cardId.equals(cardId),
            ))
            .write(
              DailyCardOrderCompanion(
                sortOrder: Value(newOrder),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
  }

  /// 특정 날짜의 카드 순서 초기화 (삭제)
  /// 이거를 설정하고 → 날짜별 커스텀 순서를 리셋할 때 사용해서
  /// 이거를 해서 → 해당 날짜의 모든 순서 데이터를 삭제하고
  /// 이거는 이래서 → 기본 순서(createdAt)로 돌아간다
  Future<int> resetDailyCardOrder(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // 이거를 설정하고 → delete로 해당 날짜의 모든 순서를 삭제해서
    // 이거를 해서 → 커스텀 순서를 제거한다
    final count = await (delete(
      dailyCardOrder,
    )..where((tbl) => tbl.date.equals(normalizedDate))).go();

    return count;
  }

  /// 특정 카드 삭제 시 모든 날짜의 순서에서 제거
  /// 이거를 설정하고 → Schedule/Task/Habit 삭제 시 함께 호출해서
  /// 이거를 해서 → 모든 날짜의 DailyCardOrder에서 해당 카드를 제거하고
  /// 이거는 이래서 → 고아 레코드(orphan record)를 방지한다
  Future<int> deleteCardFromAllOrders(String cardType, int cardId) async {
    // 이거를 설정하고 → cardType과 cardId로 필터링해서
    // 이거를 해서 → 모든 날짜의 해당 카드 순서를 삭제한다
    final count =
        await (delete(dailyCardOrder)..where(
              (tbl) =>
                  tbl.cardType.equals(cardType) & tbl.cardId.equals(cardId),
            ))
            .go();

    return count;
  }

  // ============================================================================
  // 📄 페이지네이션 - 화면에 보이는 데이터만 로드
  // ============================================================================

  /// 🎯 특정 날짜의 할일 조회 (executionDate 기준)
  /// 이거를 설정하고 → executionDate가 지정된 날짜인 할일만 가져와서
  /// 이거를 해서 → DetailView에 해당 날짜의 할일을 표시하고
  /// 이거는 이래서 → executionDate가 없으면 Inbox에만 표시된다
  Stream<List<TaskData>> watchTasksByExecutionDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return (select(task)
          ..where(
            (tbl) =>
                tbl.executionDate.isBiggerOrEqualValue(startOfDay) &
                tbl.executionDate.isSmallerOrEqualValue(endOfDay),
          )
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.completed), // 미완료 먼저
            (tbl) => OrderingTerm(expression: tbl.executionDate), // 실행일 순
            (tbl) => OrderingTerm(expression: tbl.dueDate), // 마감일 순
            (tbl) => OrderingTerm(expression: tbl.title), // 제목 순
          ]))
        .watch();
  }

  /// 📥 Inbox 할일 조회 (완료되지 않은 것만)
  /// 이거를 설정하고 → completed가 false인 할일만 가져와서
  /// 이거를 해서 → Inbox에만 표시한다
  /// ✅ inboxOrder로 정렬 (사용자 커스텀 순서 반영)
  Stream<List<TaskData>> watchInboxTasks() {
    return (select(task)
          ..where((tbl) => tbl.completed.equals(false)) // ✅ 완료되지 않은 것만
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.inboxOrder,
              mode: OrderingMode.asc,
            ), // ✅ 인박스 순서 오름차순 (드래그 앤 드롭 순서)
            (tbl) => OrderingTerm(
              expression: tbl.dueDate,
              mode: OrderingMode.asc,
            ), // 마감일 오름차순 (보조 정렬)
            (tbl) => OrderingTerm(
              expression: tbl.title,
              mode: OrderingMode.asc,
            ), // 제목 오름차순 (보조 정렬)
          ]))
        .watch();
  }

  /// 📄 할일 페이지네이션 (화면에 보이는 것만 로드)
  /// 이거를 설정하고 → limit과 offset으로 필요한 만큼만 가져와서
  /// 이거를 해서 → 성능을 최적화하고
  /// 이거는 이래서 → 대량의 할일이 있어도 빠르게 로드된다
  Stream<List<TaskData>> watchTasksPaginated({
    required int limit,
    required int offset,
  }) {
    return (select(task)
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.completed), // 미완료 먼저
            (tbl) => OrderingTerm(expression: tbl.executionDate), // 실행일 순
            (tbl) => OrderingTerm(expression: tbl.dueDate), // 마감일 순
            (tbl) => OrderingTerm(expression: tbl.title), // 제목 순
          ])
          ..limit(limit, offset: offset))
        .watch();
  }

  /// 📄 습관 페이지네이션 (화면에 보이는 것만 로드)
  /// 이거를 설정하고 → limit과 offset으로 필요한 만큼만 가져와서
  /// 이거를 해서 → 성능을 최적화하고
  /// 이거는 이래서 → 대량의 습관이 있어도 빠르게 로드된다
  Stream<List<HabitData>> watchHabitsPaginated({
    required int limit,
    required int offset,
  }) {
    return (select(habit)
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.createdAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit, offset: offset))
        .watch();
  }

  // ==================== 완료된 항목 조회 함수들 ====================

  /// ✅ 특정 날짜의 완료된 할일 조회 (TaskCompletion 기준)
  /// 이거를 설정하고 → TaskCompletion 테이블에서 해당 날짜에 완료된 할일 ID를 조회하고
  /// 이거를 해서 → 완료된 할일들의 상세 정보를 Task 테이블에서 가져와서
  /// 이거는 이래서 → 반복 할일의 특정 날짜 완료도 정확하게 표시된다
  Stream<List<TaskData>> watchCompletedTasksByDay(DateTime date) async* {
    final dateOnly = DateTime(date.year, date.month, date.day);

    // 1️⃣ TaskCompletion 테이블에서 해당 날짜의 완료 기록을 실시간 감지
    await for (final completions
        in (select(taskCompletion)
              ..where((tbl) => tbl.completedDate.equals(dateOnly))
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                  mode: OrderingMode.desc,
                ), // 완료 시간 역순
              ]))
            .watch()) {
      // 완료된 할일 ID 리스트
      final taskIds = completions.map((c) => c.taskId).toSet();

      // 2️⃣ Task 테이블에서 TaskCompletion에 있는 할일들 조회
      List<TaskData> tasks = [];
      if (taskIds.isNotEmpty) {
        tasks = await (select(
          task,
        )..where((tbl) => tbl.id.isIn(taskIds.toList()))).get();
      }

      // 3️⃣ 일반 할일 중 completed=true이고 executionDate가 해당 날짜인 것도 조회
      final completedNormalTasks =
          await (select(task)..where(
                (tbl) =>
                    tbl.completed.equals(true) &
                    tbl.executionDate.equals(dateOnly),
              ))
              .get();

      // 4️⃣ 두 리스트 합치기 (중복 제거)
      final allCompletedTasks = <TaskData>[];

      // TaskCompletion 기반 할일 추가
      for (final completion in completions) {
        try {
          final taskData = tasks.firstWhere((t) => t.id == completion.taskId);
          if (!allCompletedTasks.any((t) => t.id == taskData.id)) {
            allCompletedTasks.add(taskData);
          }
        } catch (e) {
          // Task가 삭제된 경우 스킵
          continue;
        }
      }

      // 일반 완료 할일 추가
      for (final completedTask in completedNormalTasks) {
        if (!allCompletedTasks.any((t) => t.id == completedTask.id)) {
          allCompletedTasks.add(completedTask);
        }
      }

      yield allCompletedTasks;
    }
  }

  /// ✅ 특정 날짜의 완료된 습관 조회 (HabitCompletion 기준)
  /// 이거를 설정하고 → HabitCompletion 테이블에서 해당 날짜에 완료된 습관 ID를 조회하고
  /// 이거를 해서 → 해당 습관들의 상세 정보를 Habit 테이블에서 가져와서
  /// 이거는 이래서 → 완료된 습관을 완료 시간 역순으로 표시한다
  Stream<List<HabitData>> watchCompletedHabitsByDay(DateTime date) async* {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // HabitCompletion 테이블에서 해당 날짜의 완료 기록을 실시간 감지
    await for (final completions
        in (select(habitCompletion)
              ..where(
                (tbl) =>
                    tbl.completedDate.isBiggerOrEqualValue(startOfDay) &
                    tbl.completedDate.isSmallerOrEqualValue(endOfDay),
              )
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.completedDate,
                  mode: OrderingMode.desc,
                ), // 완료 시간 역순
              ]))
            .watch()) {
      // 완료된 습관 ID 리스트
      final habitIds = completions.map((c) => c.habitId).toSet().toList();

      if (habitIds.isEmpty) {
        yield [];
        continue;
      }

      // Habit 테이블에서 해당 습관들의 정보 조회
      final habits = await (select(
        habit,
      )..where((tbl) => tbl.id.isIn(habitIds))).get();

      // completedDate 순서대로 정렬
      final sortedHabits = <HabitData>[];
      for (final completion in completions) {
        final habitData = habits.firstWhere((h) => h.id == completion.habitId);
        if (!sortedHabits.any((h) => h.id == habitData.id)) {
          sortedHabits.add(habitData);
        }
      }

      yield sortedHabits;
    }
  }

  /// ✅ 특정 날짜의 완료된 일정 조회 (ScheduleCompletion 기준)
  /// 이거를 설정하고 → ScheduleCompletion 테이블에서 해당 날짜에 완료된 일정 ID를 조회하고
  /// 이거를 해서 → 완료된 일정들의 상세 정보를 Schedule 테이블에서 가져와서
  /// 이거는 이래서 → 반복 일정의 특정 날짜 완료도 정확하게 표시된다
  /// 🔥 추가: 일반 일정(completed=true)도 함께 조회
  Stream<List<ScheduleData>> watchCompletedSchedulesByDay(
    DateTime date,
  ) async* {
    final dateOnly = DateTime(date.year, date.month, date.day);

    // 1️⃣ ScheduleCompletion 테이블에서 해당 날짜의 완료 기록을 실시간 감지
    await for (final completions
        in (select(scheduleCompletion)
              ..where((tbl) => tbl.completedDate.equals(dateOnly))
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                  mode: OrderingMode.desc,
                ), // 완료 시간 역순
              ]))
            .watch()) {
      // 완료된 일정 ID 리스트
      final scheduleIds = completions.map((c) => c.scheduleId).toSet();

      // 2️⃣ Schedule 테이블에서 ScheduleCompletion에 있는 일정들 조회
      List<ScheduleData> schedules = [];
      if (scheduleIds.isNotEmpty) {
        schedules = await (select(
          schedule,
        )..where((tbl) => tbl.id.isIn(scheduleIds.toList()))).get();
      }

      // 3️⃣ 일반 일정 중 completed=true인 것도 조회
      // (해당 날짜에 시작하는 일반 일정만)
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final completedNormalSchedules =
          await (select(schedule)..where(
                (tbl) =>
                    tbl.completed.equals(true) &
                    tbl.start.isBiggerOrEqualValue(startOfDay) &
                    tbl.start.isSmallerOrEqualValue(endOfDay),
              ))
              .get();

      // 4️⃣ 두 리스트 합치기 (중복 제거)
      final allCompletedSchedules = <ScheduleData>[];

      // ScheduleCompletion 기반 일정 추가
      for (final completion in completions) {
        try {
          final scheduleData = schedules.firstWhere(
            (s) => s.id == completion.scheduleId,
          );
          if (!allCompletedSchedules.any((s) => s.id == scheduleData.id)) {
            allCompletedSchedules.add(scheduleData);
          }
        } catch (e) {
          // Schedule이 삭제된 경우 스킵
          continue;
        }
      }

      // 일반 완료 일정 추가
      for (final completedSchedule in completedNormalSchedules) {
        if (!allCompletedSchedules.any((s) => s.id == completedSchedule.id)) {
          allCompletedSchedules.add(completedSchedule);
        }
      }

      yield allCompletedSchedules;
    }
  }

  /// 📊 할일 총 개수 조회 (페이지네이션용)
  /// 이거를 설정하고 → 전체 할일 개수를 세어서
  /// 이거를 해서 → 페이지네이션 계산에 사용한다
  Future<int> getTasksCount() async {
    final query = selectOnly(task)..addColumns([task.id.count()]);
    final result = await query.getSingle();
    final count = result.read(task.id.count()) ?? 0;
    return count;
  }

  /// 📊 습관 총 개수 조회 (페이지네이션용)
  /// 이거를 설정하고 → 전체 습관 개수를 세어서
  /// 이거를 해서 → 페이지네이션 계산에 사용한다
  Future<int> getHabitsCount() async {
    final query = selectOnly(habit)..addColumns([habit.id.count()]);
    final result = await query.getSingle();
    final count = result.read(habit.id.count()) ?? 0;
    return count;
  }

  // ============================================================================
  // 🔁 반복 규칙 필터링 (RepeatRuleUtils 사용)
  // ============================================================================

  /// 🎯 특정 날짜의 Schedule (반복 규칙 고려)
  ///
  /// 🔁 특정 날짜의 Schedule (RRULE 반복 규칙 고려)
  ///
  /// **동작 방식:**
  /// 1. DB에서 모든 Schedule 조회
  /// 2. 각 Schedule에 RecurringPattern이 있는지 확인
  /// 3. RRULE로 인스턴스 생성 + 예외 처리
  /// 4. targetDate에 표시되어야 하는 Schedule만 반환
  ///
  /// **RRULE 기반 (RFC 5545 표준):**
  /// - RecurringPattern 테이블에서 RRULE 조회
  /// - RRuleUtils로 동적 인스턴스 생성
  /// - RecurringException으로 수정/삭제 처리
  Stream<List<ScheduleData>> watchSchedulesWithRepeat(
    DateTime targetDate,
  ) async* {
    // 날짜 정규화 (00:00:00)
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final targetEnd = target.add(const Duration(days: 1));

    await for (final schedules in watchSchedules()) {
      // 🔥 해당 날짜의 완료 기록 조회
      final completions = await getScheduleCompletionsByDate(target);
      final completedIds = completions.map((c) => c.scheduleId).toSet();

      final result = <ScheduleData>[];

      for (final schedule in schedules) {
        // 1. 반복 규칙 조회
        final pattern = await getRecurringPattern(
          entityType: 'schedule',
          entityId: schedule.id,
        );

        if (pattern == null) {
          // 일반 일정: 날짜 범위 체크 + 완료 여부 확인
          if (schedule.start.isBefore(targetEnd) &&
              schedule.end.isAfter(target)) {
            // 🔥 일반 일정은 schedule.completed 필드로 확인
            if (!schedule.completed) {
              result.add(schedule);
            }
          }
        } else {
          // 반복 일정: RRULE로 인스턴스 생성
          try {
            final instances = await _generateScheduleInstancesForDate(
              schedule: schedule,
              pattern: pattern,
              targetDate: target,
            );

            if (instances.isNotEmpty) {
              // ✅ FIX: RecurringException의 수정 사항을 적용
              final exceptions = await getRecurringExceptions(pattern.id);
              final targetNormalized = _normalizeDate(target);

              // 해당 날짜의 예외 찾기
              RecurringExceptionData? exception;
              for (final e in exceptions) {
                if (_normalizeDate(e.originalDate) == targetNormalized) {
                  exception = e;
                  break;
                }
              }

              // 표시할 일정 데이터 결정
              ScheduleData displaySchedule = schedule;

              if (exception != null && !exception.isCancelled) {
                // ✅ 수정된 필드를 적용한 새 ScheduleData 생성
                displaySchedule = ScheduleData(
                  id: schedule.id,
                  summary: exception.modifiedTitle ?? schedule.summary,
                  start: exception.newStartDate ?? schedule.start,
                  end: exception.newEndDate ?? schedule.end,
                  description:
                      exception.modifiedDescription ?? schedule.description,
                  location: exception.modifiedLocation ?? schedule.location,
                  colorId: exception.modifiedColorId ?? schedule.colorId,
                  completed: schedule.completed,
                  completedAt: schedule.completedAt,
                  repeatRule: schedule.repeatRule,
                  alertSetting: schedule.alertSetting,
                  createdAt: schedule.createdAt,
                  status: schedule.status,
                  visibility: schedule.visibility,
                  timezone: schedule.timezone,
                  originalHour: schedule.originalHour,
                  originalMinute: schedule.originalMinute,
                );
              } else {
                // 🔥 예외가 없으면 원본 시간을 복원하여 표시
                // originalHour/originalMinute가 있으면 그 시간을 사용
                if (schedule.originalHour != null &&
                    schedule.originalMinute != null) {
                  final instanceStartTime = DateTime(
                    target.year,
                    target.month,
                    target.day,
                    schedule.originalHour!,
                    schedule.originalMinute!,
                  );
                  final duration = schedule.end.difference(schedule.start);
                  final instanceEndTime = instanceStartTime.add(duration);

                  displaySchedule = ScheduleData(
                    id: schedule.id,
                    summary: schedule.summary,
                    start: instanceStartTime,
                    end: instanceEndTime,
                    description: schedule.description,
                    location: schedule.location,
                    colorId: schedule.colorId,
                    completed: schedule.completed,
                    completedAt: schedule.completedAt,
                    repeatRule: schedule.repeatRule,
                    alertSetting: schedule.alertSetting,
                    createdAt: schedule.createdAt,
                    status: schedule.status,
                    visibility: schedule.visibility,
                    timezone: schedule.timezone,
                    originalHour: schedule.originalHour,
                    originalMinute: schedule.originalMinute,
                  );
                }
              }

              // 🔥 Phase 2 - Task 2: 날짜 이동된 예외 처리
              // FROM 날짜: 이동된 경우 제외 (newStartDate가 오늘이 아니면 표시 안 함)
              bool shouldSkip = false;
              if (exception != null &&
                  exception.isRescheduled &&
                  exception.newStartDate != null) {
                final movedToDate = _normalizeDate(exception.newStartDate!);
                if (movedToDate != targetNormalized) {
                  shouldSkip = true; // 다른 날짜로 이동됨, 오늘은 표시 안 함
                }
              }

              // 🔥 반복 일정은 ScheduleCompletion 테이블로 완료 확인
              if (!shouldSkip && !completedIds.contains(schedule.id)) {
                result.add(displaySchedule); // ✅ 수정된 일정 추가
              }
            }
          } catch (e) {
            // 실패 시 원본 날짜 기준으로 폴백
            if (schedule.start.isBefore(targetEnd) &&
                schedule.end.isAfter(target)) {
              if (!completedIds.contains(schedule.id)) {
                result.add(schedule);
              }
            }
          }
        }
      }

      // 🔥 Phase 2 - Task 2: TO 날짜 처리
      // 다른 날짜에서 오늘로 이동된 반복 일정 추가
      for (final schedule in schedules) {
        final pattern = await getRecurringPattern(
          entityType: 'schedule',
          entityId: schedule.id,
        );

        if (pattern != null) {
          final exceptions = await getRecurringExceptions(pattern.id);

          for (final exception in exceptions) {
            // 날짜가 이동되고 + 취소되지 않은 경우
            if (exception.isRescheduled &&
                !exception.isCancelled &&
                exception.newStartDate != null) {
              final movedToDate = _normalizeDate(exception.newStartDate!);
              final originalDate = _normalizeDate(exception.originalDate);

              // 다른 날짜에서 오늘로 이동된 경우
              if (movedToDate == target && originalDate != target) {
                // 수정된 일정 데이터 생성
                final duration = schedule.end.difference(schedule.start);
                final displaySchedule = ScheduleData(
                  id: schedule.id,
                  summary: exception.modifiedTitle ?? schedule.summary,
                  start: exception.newStartDate!,
                  end:
                      exception.newEndDate ??
                      exception.newStartDate!.add(duration),
                  description:
                      exception.modifiedDescription ?? schedule.description,
                  location: exception.modifiedLocation ?? schedule.location,
                  colorId: exception.modifiedColorId ?? schedule.colorId,
                  completed: schedule.completed,
                  completedAt: schedule.completedAt,
                  repeatRule: schedule.repeatRule,
                  alertSetting: schedule.alertSetting,
                  createdAt: schedule.createdAt,
                  status: schedule.status,
                  visibility: schedule.visibility,
                  timezone: schedule.timezone,
                  originalHour: schedule.originalHour,
                  originalMinute: schedule.originalMinute,
                );

                // 완료 확인 후 추가
                if (!completedIds.contains(schedule.id)) {
                  result.add(displaySchedule);
                }
              }
            }
          }
        }
      }

      yield result;
    }
  }

  /// RRULE 인스턴스 생성 헬퍼 (Schedule)
  Future<List<DateTime>> _generateScheduleInstancesForDate({
    required ScheduleData schedule,
    required RecurringPatternData pattern,
    required DateTime targetDate,
  }) async {
    // EXDATE 파싱
    final exdates = pattern.exdate.isEmpty
        ? <DateTime>[]
        : pattern.exdate
              .split(',')
              .map((s) {
                try {
                  return DateTime.parse(s.trim());
                } catch (e) {
                  return null;
                }
              })
              .whereType<DateTime>()
              .toList();

    // RRULE 인스턴스 생성 (targetDate 당일만)
    // 🔥 rangeEnd는 targetDate 당일의 마지막 시각 (23:59:59)
    final instances = await _generateRRuleInstances(
      rrule: pattern.rrule,
      dtstart: pattern.dtstart,
      rangeStart: targetDate,
      rangeEnd: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        23,
        59,
        59,
      ),
      exdates: exdates,
    );

    // 예외 처리 (취소된 인스턴스 제외)
    final exceptions = await getRecurringExceptions(pattern.id);
    final cancelledDates = exceptions
        .where((e) => e.isCancelled)
        .map((e) => _normalizeDate(e.originalDate))
        .toSet();

    return instances
        .where((date) => !cancelledDates.contains(_normalizeDate(date)))
        .toList();
  }

  /// RRULE 인스턴스 생성 (내부 헬퍼)
  Future<List<DateTime>> _generateRRuleInstances({
    required String rrule,
    required DateTime dtstart,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    List<DateTime>? exdates,
    DateTime? until, // ✅ UNTIL 파라미터 추가
  }) async {
    // RRuleUtils 사용 (이미 구현된 유틸리티)
    try {
      // Note: RRuleUtils는 동기 함수이므로 직접 호출
      return await Future.value(
        _parseRRuleSync(
          rrule: rrule,
          dtstart: dtstart,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
          exdates: exdates,
          until: until, // ✅ UNTIL 전달
        ),
      );
    } catch (e) {
      return [];
    }
  }

  /// RRULE 동기 파싱 (RRuleUtils 연동)
  List<DateTime> _parseRRuleSync({
    required String rrule,
    required DateTime dtstart,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    List<DateTime>? exdates,
    DateTime? until, // ✅ UNTIL 파라미터 추가
  }) {
    try {
      // ✅ UNTIL이 있으면 RRULE 문자열에 추가
      String rruleWithUntil = rrule;
      if (until != null && !rrule.contains('UNTIL=')) {
        final untilStr = _formatDateTime(until);
        rruleWithUntil = rrule.contains(';')
            ? '$rrule;UNTIL=$untilStr'
            : '$rrule;UNTIL=$untilStr';
      }

      // RRuleUtils.generateInstances() 호출 (EXDATE 전달)
      return RRuleUtils.generateInstances(
        rruleString: rruleWithUntil,
        dtstart: dtstart,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        exdates: exdates,
      );
    } catch (e) {
      return [];
    }
  }

  /// 날짜 정규화 (시간 제거)
  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// 🎯 특정 날짜의 Task (반복 규칙 고려)
  ///
  /// 조건:
  /// 🔁 특정 날짜의 Task (RRULE 반복 규칙 고려)
  ///
  /// **조건:**
  /// - executionDate가 null이면 제외 (Inbox 전용)
  /// - executionDate가 있고 RecurringPattern 없으면 해당 날짜만
  /// - RecurringPattern이 있으면 RRULE 기반 인스턴스 생성
  Stream<List<TaskData>> watchTasksWithRepeat(DateTime targetDate) async* {
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);

    await for (final tasks in watchTasks()) {
      // 🔥 해당 날짜의 완료 기록 조회
      final completions = await getTaskCompletionsByDate(target);
      final completedIds = completions.map((c) => c.taskId).toSet();

      final result = <TaskData>[];

      for (final task in tasks) {
        // executionDate가 null이면 Inbox 전용
        if (task.executionDate == null) {
          continue;
        }

        // 1. 반복 규칙 조회
        final pattern = await getRecurringPattern(
          entityType: 'task',
          entityId: task.id,
        );

        if (pattern == null) {
          // 일반 할일: executionDate 기준 + 완료 여부 확인
          final taskDate = _normalizeDate(task.executionDate!);
          if (taskDate.isAtSameMomentAs(target)) {
            // 🔥 일반 할일은 task.completed 필드로 확인
            if (!task.completed) {
              result.add(task);
            }
          }
        } else {
          // 반복 할일: recurrenceMode에 따라 다르게 처리
          // ✅ RELATIVE_ON_COMPLETION (every!) vs ABSOLUTE (every) 구분
          if (pattern.recurrenceMode == 'RELATIVE_ON_COMPLETION') {
            // 🔥 every! 모드: RRULE 확장하지 않고 현재 executionDate만 표시
            // 완료 시 executionDate가 다음 날짜로 자동 업데이트됨
            final taskDate = _normalizeDate(task.executionDate!);
            if (taskDate.isAtSameMomentAs(target)) {
              // 완료 여부 확인 (반복 할일은 TaskCompletion 테이블로 확인)
              if (!completedIds.contains(task.id)) {
                result.add(task);
              }
            }
          } else {
            // ABSOLUTE 모드: RRULE로 인스턴스 생성 (기존 로직)
            try {
              final instances = await _generateTaskInstancesForDate(
                task: task,
                pattern: pattern,
                targetDate: target,
              );

              // ✅ FIX: RecurringException의 수정 사항을 먼저 확인
              final exceptions = await getRecurringExceptions(pattern.id);
              final targetNormalized = _normalizeDate(target);

              // 해당 날짜와 관련된 예외 찾기
              RecurringExceptionData? exception;
              for (final e in exceptions) {
                final originalDateNormalized = _normalizeDate(e.originalDate);
                final newStartDateNormalized = e.newStartDate != null
                    ? _normalizeDate(e.newStartDate!)
                    : null;

                // 1. originalDate가 target과 일치하거나
                // 2. newStartDate가 target과 일치하면 해당 exception 사용
                if (originalDateNormalized == targetNormalized ||
                    newStartDateNormalized == targetNormalized) {
                  exception = e;
                  break;
                }
              }

              // 🔥 표시 조건:
              // 1. RRULE 인스턴스가 있고 취소되지 않았으며 날짜 변경되지 않았거나
              // 2. exception의 newStartDate가 target과 일치 (다른 날짜에서 이동해온 경우)
              final hasInstance = instances.isNotEmpty;
              final isCancelled = exception?.isCancelled ?? false;
              final isMovedToThisDate =
                  exception?.newStartDate != null &&
                  _normalizeDate(exception!.newStartDate!) == targetNormalized;
              final isMovedFromThisDate =
                  exception?.newStartDate != null &&
                  _normalizeDate(exception!.originalDate) == targetNormalized &&
                  _normalizeDate(exception.newStartDate!) != targetNormalized;

              final shouldDisplay =
                  (hasInstance && !isCancelled && !isMovedFromThisDate) ||
                  isMovedToThisDate;

              if (shouldDisplay) {
                // 🔥 반복 할일: 각 인스턴스마다 해당 날짜를 executionDate로 설정
                // 🔥 실행일 결정 우선순위:
                // 1. exception.newStartDate (유저가 특정 인스턴스의 실행일을 수정한 경우)
                // 2. target (해당 날짜)
                DateTime finalExecutionDate = exception?.newStartDate ?? target;

                // 🔥 마감일 결정 우선순위:
                // 1. exception.newEndDate (유저가 특정 인스턴스의 마감일을 수정한 경우)
                // 2. 자동 계산된 마감일 (원본 실행일-마감일 차이를 새 실행일에 적용)
                // 3. 원본 마감일 (executionDate가 없었던 경우)
                DateTime? finalDueDate;

                if (exception?.newEndDate != null) {
                  // 🔥 유저가 수정한 마감일이 있으면 그것을 사용
                  finalDueDate = exception!.newEndDate;
                } else if (task.dueDate != null && task.executionDate != null) {
                  // 자동 계산: 원본 실행일과 마감일의 차이 계산
                  final originalExecDate = DateTime(
                    task.executionDate!.year,
                    task.executionDate!.month,
                    task.executionDate!.day,
                  );
                  final originalDueDate = DateTime(
                    task.dueDate!.year,
                    task.dueDate!.month,
                    task.dueDate!.day,
                  );
                  final daysDifference = originalDueDate
                      .difference(originalExecDate)
                      .inDays;

                  // 새 실행일(finalExecutionDate)에 동일한 차이를 적용
                  finalDueDate = finalExecutionDate.add(
                    Duration(days: daysDifference),
                  );

                  // 시간 정보는 원본 마감일의 시간 유지
                  finalDueDate = DateTime(
                    finalDueDate.year,
                    finalDueDate.month,
                    finalDueDate.day,
                    task.dueDate!.hour,
                    task.dueDate!.minute,
                    task.dueDate!.second,
                  );
                } else if (task.dueDate != null) {
                  // executionDate가 없었던 경우 원본 마감일 유지
                  finalDueDate = task.dueDate;
                }

                TaskData displayTask = TaskData(
                  id: task.id,
                  title: exception?.modifiedTitle ?? task.title,
                  colorId: exception?.modifiedColorId ?? task.colorId,
                  completed: task.completed,
                  completedAt: task.completedAt,
                  dueDate: finalDueDate, // 🔥 최종 마감일 (유저 수정 > 자동 계산 > 원본)
                  executionDate:
                      finalExecutionDate, // 🔥 최종 실행일 (유저 수정 > target)
                  listId: task.listId,
                  createdAt: task.createdAt,
                  repeatRule: task.repeatRule,
                  reminder: task.reminder,
                  inboxOrder: task.inboxOrder,
                );

                // 🔥 반복 할일은 TaskCompletion 테이블로 완료 확인
                if (!completedIds.contains(task.id)) {
                  result.add(displayTask); // ✅ 수정된 할일 추가
                } else {}
              }
            } catch (e) {}
          } // ABSOLUTE 모드 종료
        } // 반복 할일 종료
      }

      // 🎯 완료된 Task는 이미 필터링되었으므로 정렬 불필요
      // result는 모두 미완료 Task만 포함

      yield result;
    }
  }

  /// RRULE 인스턴스 생성 헬퍼 (Task)
  Future<List<DateTime>> _generateTaskInstancesForDate({
    required TaskData task,
    required RecurringPatternData pattern,
    required DateTime targetDate,
  }) async {
    final exdates = pattern.exdate.isEmpty
        ? <DateTime>[]
        : pattern.exdate
              .split(',')
              .map((s) {
                try {
                  return DateTime.parse(s.trim());
                } catch (e) {
                  return null;
                }
              })
              .whereType<DateTime>()
              .toList();

    // RRULE 인스턴스 생성 (targetDate 당일만)
    // 🔥 rangeEnd는 targetDate 당일의 마지막 시각 (23:59:59)
    final instances = await _generateRRuleInstances(
      rrule: pattern.rrule,
      dtstart: pattern.dtstart,
      rangeStart: targetDate,
      rangeEnd: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        23,
        59,
        59,
      ),
      exdates: exdates,
    );

    final exceptions = await getRecurringExceptions(pattern.id);
    final cancelledDates = exceptions
        .where((e) => e.isCancelled)
        .map((e) => _normalizeDate(e.originalDate))
        .toSet();

    return instances
        .where((date) => !cancelledDates.contains(_normalizeDate(date)))
        .toList();
  }

  /// 🔁 특정 날짜의 Habit (RRULE 반복 규칙 고려)
  ///
  /// **조건:**
  /// - Habit은 항상 RecurringPattern이 있어야 함 (기본: 매일)
  /// - createdAt 날짜 이후로 반복 규칙에 따라 표시
  Stream<List<HabitData>> watchHabitsWithRepeat(DateTime targetDate) async* {
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);

    await for (final habits
        in (select(habit)..orderBy([
              (tbl) => OrderingTerm(
                expression: tbl.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .watch()) {
      final result = <HabitData>[];

      for (final habitItem in habits) {
        // createdAt 이전 날짜에는 표시 안 함
        final createdDate = _normalizeDate(habitItem.createdAt);
        if (target.isBefore(createdDate)) {
          continue;
        }

        // 1. 반복 규칙 조회
        final pattern = await getRecurringPattern(
          entityType: 'habit',
          entityId: habitItem.id,
        );

        if (pattern == null) {
          // RecurringPattern 없으면 표시 안 함 (Habit은 반복 필수)
          continue;
        }

        // 반복 습관: recurrenceMode에 따라 다르게 처리
        // ✅ RELATIVE_ON_COMPLETION (every!) vs ABSOLUTE (every) 구분
        if (pattern.recurrenceMode == 'RELATIVE_ON_COMPLETION') {
          // 🔥 every! 모드: dtstart가 다음 표시 날짜를 나타냄
          // 완료 시 dtstart가 다음 날짜로 자동 업데이트됨
          final showDate = _normalizeDate(pattern.dtstart);
          if (showDate.isAtSameMomentAs(target)) {
            // 완료 여부 확인
            final completions = await getHabitCompletionsByDate(target);
            if (!completions.any((c) => c.habitId == habitItem.id)) {
              result.add(habitItem);
            }
          }
        } else {
          // ABSOLUTE 모드: RRULE로 인스턴스 생성 (기존 로직)
          try {
            final instances = await _generateHabitInstancesForDate(
              habit: habitItem,
              pattern: pattern,
              targetDate: target,
            );

            if (instances.isNotEmpty) {
              // ✅ FIX: RecurringException의 수정 사항을 적용
              final exceptions = await getRecurringExceptions(pattern.id);
              final targetNormalized = _normalizeDate(target);

              // 해당 날짜의 예외 찾기
              RecurringExceptionData? exception;
              for (final e in exceptions) {
                if (_normalizeDate(e.originalDate) == targetNormalized) {
                  exception = e;
                  break;
                }
              }

              // 표시할 습관 데이터 결정
              HabitData displayHabit = habitItem;

              if (exception != null && !exception.isCancelled) {
                // ✅ 수정된 필드를 적용한 새 HabitData 생성
                displayHabit = HabitData(
                  id: habitItem.id,
                  title: exception.modifiedTitle ?? habitItem.title,
                  colorId: exception.modifiedColorId ?? habitItem.colorId,
                  createdAt: habitItem.createdAt,
                  repeatRule: habitItem.repeatRule,
                  reminder: habitItem.reminder,
                );
              }

              // 🔥 Phase 2 - Task 2: FROM 날짜 처리
              bool shouldSkip = false;
              if (exception != null &&
                  exception.isRescheduled &&
                  exception.newStartDate != null) {
                final movedToDate = _normalizeDate(exception.newStartDate!);
                if (movedToDate != targetNormalized) {
                  shouldSkip = true; // 다른 날짜로 이동됨, 오늘은 표시 안 함
                }
              }

              if (!shouldSkip) {
                result.add(displayHabit); // ✅ 수정된 습관 추가
              }
            }
          } catch (e) {}
        } // ABSOLUTE 모드 종료
      }

      // 🔥 Phase 2 - Task 2: TO 날짜 처리
      // 다른 날짜에서 오늘로 이동된 반복 습관 추가
      for (final habitItem in habits) {
        final pattern = await getRecurringPattern(
          entityType: 'habit',
          entityId: habitItem.id,
        );

        if (pattern != null) {
          final exceptions = await getRecurringExceptions(pattern.id);

          for (final exception in exceptions) {
            // 날짜가 이동되고 + 취소되지 않은 경우
            if (exception.isRescheduled &&
                !exception.isCancelled &&
                exception.newStartDate != null) {
              final movedToDate = _normalizeDate(exception.newStartDate!);
              final originalDate = _normalizeDate(exception.originalDate);

              // 다른 날짜에서 오늘로 이동된 경우
              if (movedToDate == target && originalDate != target) {
                // 수정된 습관 데이터 생성
                final displayHabit = HabitData(
                  id: habitItem.id,
                  title: exception.modifiedTitle ?? habitItem.title,
                  colorId: exception.modifiedColorId ?? habitItem.colorId,
                  createdAt: habitItem.createdAt,
                  repeatRule: habitItem.repeatRule,
                  reminder: habitItem.reminder,
                );

                // 완료 확인 후 추가
                final completions = await getHabitCompletionsByDate(target);
                if (!completions.any((c) => c.habitId == habitItem.id)) {
                  result.add(displayHabit);
                }
              }
            }
          }
        }
      }

      yield result;
    }
  }

  /// RRULE 인스턴스 생성 헬퍼 (Habit)
  Future<List<DateTime>> _generateHabitInstancesForDate({
    required HabitData habit,
    required RecurringPatternData pattern,
    required DateTime targetDate,
  }) async {
    final exdates = pattern.exdate.isEmpty
        ? <DateTime>[]
        : pattern.exdate
              .split(',')
              .map((s) {
                try {
                  return DateTime.parse(s.trim());
                } catch (e) {
                  return null;
                }
              })
              .whereType<DateTime>()
              .toList();

    // RRULE 인스턴스 생성 (targetDate 당일만)
    // 🔥 rangeEnd는 targetDate 당일의 마지막 시각 (23:59:59)
    final instances = await _generateRRuleInstances(
      rrule: pattern.rrule,
      dtstart: pattern.dtstart,
      rangeStart: targetDate,
      rangeEnd: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        23,
        59,
        59,
      ),
      exdates: exdates,
    );

    final exceptions = await getRecurringExceptions(pattern.id);
    final cancelledDates = exceptions
        .where((e) => e.isCancelled)
        .map((e) => _normalizeDate(e.originalDate))
        .toSet();

    return instances
        .where((date) => !cancelledDates.contains(_normalizeDate(date)))
        .toList();
  }

  // ==================== 🎵 Insight Player 함수 (Phase 1) ====================

  /// 특정 날짜의 인사이트 조회
  /// 이거를 설정하고 → targetDate로 정확한 날짜 매칭해서
  /// 이거를 해서 → 해당 날짜에 연결된 오디오 콘텐츠를 반환한다
  Future<AudioContentData?> getInsightForDate(DateTime date) async {
    // 날짜 정규화 (시간 부분 제거)
    final normalized = DateTime(date.year, date.month, date.day);

    final result = await (select(
      audioContents,
    )..where((t) => t.targetDate.equals(normalized))).getSingleOrNull();

    if (result != null) {
    } else {}

    return result;
  }

  /// 인사이트의 스크립트 라인 조회 (실시간 스트림)
  /// 이거를 설정하고 → audioContentId로 필터링해서
  /// 이거를 해서 → sequence 순서대로 정렬된 스크립트를 watch한다
  Stream<List<TranscriptLineData>> watchTranscriptLines(int audioContentId) {
    return (select(transcriptLines)
          ..where((t) => t.audioContentId.equals(audioContentId))
          ..orderBy([(t) => OrderingTerm(expression: t.sequence)]))
        .watch();
  }

  /// 현재 재생 위치에 해당하는 스크립트 라인 찾기 (성능 최적화)
  /// 이거를 설정하고 → startTimeMs <= positionMs 조건으로 필터링해서
  /// 이거를 해서 → 가장 최근 startTime을 가진 라인을 반환한다
  Future<TranscriptLineData?> getCurrentLine(
    int audioContentId,
    int positionMs,
  ) async {
    return await (select(transcriptLines)
          ..where(
            (t) =>
                t.audioContentId.equals(audioContentId) &
                t.startTimeMs.isSmallerOrEqualValue(positionMs),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.startTimeMs,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// 재생 진행 상태 업데이트
  /// 이거를 설정하고 → AudioContents의 lastPositionMs와 lastPlayedAt을 업데이트해서
  /// 이거를 해서 → 사용자가 어디까지 들었는지 기록한다
  Future<void> updateAudioProgress(int audioContentId, int positionMs) async {
    await (update(
      audioContents,
    )..where((t) => t.id.equals(audioContentId))).write(
      AudioContentsCompanion(
        lastPositionMs: Value(positionMs),
        lastPlayedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 인사이트 완료 처리
  /// 이거를 설정하고 → isCompleted를 true로 설정하고
  /// 이거를 해서 → completedAt 타임스탬프를 기록한다
  Future<void> markInsightAsCompleted(int audioContentId) async {
    await (update(
      audioContents,
    )..where((t) => t.id.equals(audioContentId))).write(
      AudioContentsCompanion(
        isCompleted: const Value(true),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 재생 횟수 증가
  /// 이거를 설정하고 → playCount를 +1 증가시켜서
  /// 이거를 해서 → 몇 번 재생했는지 추적한다
  Future<void> incrementPlayCount(int audioContentId) async {
    final current = await (select(
      audioContents,
    )..where((t) => t.id.equals(audioContentId))).getSingle();

    await (update(
      audioContents,
    )..where((t) => t.id.equals(audioContentId))).write(
      AudioContentsCompanion(playCount: Value((current.playCount ?? 0) + 1)),
    );
  }

  /// 샘플 인사이트 데이터 삽입 (초기화 시 자동 실행)
  /// 이거를 설정하고 → Figma 텍스트 기반 LRC 데이터를 생성해서
  /// 이거를 해서 → 2025-10-18 날짜에 샘플 인사이트를 추가한다
  Future<void> seedInsightData() async {
    // 이미 데이터가 있는지 확인
    final existing = await getInsightForDate(DateTime(2025, 10, 18));
    if (existing != null) {
      return;
    }

    // 1. 오디오 콘텐츠 생성
    final audioId = await into(audioContents).insert(
      AudioContentsCompanion.insert(
        title: '過去データから見える自分可能性',
        subtitle: 'インサイト',
        audioPath: 'asset/audio/insight_001.mp3', // Flutter asset 경로
        durationSeconds: 84, // 1분 24초
        targetDate: DateTime(2025, 10, 18),
        // 재생 상태는 기본값 사용 (lastPositionMs=0, isCompleted=false, playCount=0)
      ),
    );

    // 2. 스크립트 라인 삽입 (Figma 텍스트 기반)
    final lines = [
      (0, 5500, 'こんにちは。あなたの週訪時間にインサイトをお届けする「脳の賢者たち」です。'),
      (5500, 12000, 'こんにちは。脳科学と心理学であなたの今日を応援するWです。'),
      (
        12000,
        18500,
        'Wさん、今日とても興味深いのToDoリストを見たんです。旅行の準備、部屋の掃除、メモの整理みたいに、明確で小さな目標はさらんと終わらせていました。',
      ),
      (
        18500,
        28000,
        'でも「価値観を整理する」とか、大事な「業務テスト」みたいな大きくて抽象的なことは全然手をつけられていなかったんです。…これ、すごく見覚えがありませんか？',
      ),
      (
        28000,
        33500,
        'あー、ありますね。それは私たちの脳にとって、とても自然を特徴なんです。脳は課題をひとつずつ終わらせるために、「ドーハミン」という興奮ホルモンをくれるんですよ。',
      ),
      (
        33500,
        43500,
        'これが私たちが感じる達成感の正体です。小さくて具体的な作業は、このドーハミンを早く、簡単に得られるとても良い方法なんです。だから、ToDoリストにチェックを入れて快感を味わうのは、脳の正常な機能そのものなんですね。',
      ),
      (
        43500,
        50000,
        'そうですよね。心理学では「スモール・ウィンズ（小さな成功）」戦略の力が大く強調されますよね。でも問題は、終わっていない大きな課題が、心のどこかでずっと引っかかってしまうことです。',
      ),
      (
        50000,
        60000,
        'これを心理学ルーン効果といいまして、未完了の課題が脳のメモリーを占有し続けて、他のことに集中するのを邪魔したり、無意識のストレスを与えてしまうんです。',
      ),
      (
        60000,
        68000,
        'そんなときは、脳にちょっとしたトリックが必要です。「価値観を整理する」という大きな目標が重く感じるなら、「今日は大事だと思った価値を1つだけ書いてみる」といったらどうでできる小さな第一歩にかけるんですね。',
      ),
      (
        68000,
        76000,
        '「業務テスト」がハードル高く感じる場合も、「まずはテストの第一項目だけ決める」から始めるんですね。一度エンジンがかかれば、脳は慣性の法則によって、そのまま続けたくなる傾向があります から。',
      ),
      (
        76000,
        84000,
        '本当にいい方法ですね。大きな岩を小石に砕くしたですね。この方のリストを見たら、韓国旅行の準備、外国語の勉強、マラソンの申し込みまで計画していて、未来に向けずはらしい計画を立て、ちゃんと実行しているあなたたどうかがります。',
      ),
    ];

    for (var i = 0; i < lines.length; i++) {
      await into(transcriptLines).insert(
        TranscriptLinesCompanion.insert(
          audioContentId: audioId,
          sequence: i,
          startTimeMs: lines[i].$1,
          endTimeMs: lines[i].$2,
          content: lines[i].$3,
        ),
      );
    }

    // ⚠️ AudioProgress 제거: 재생 상태는 AudioContents에 통합됨
    // 기본값으로 lastPositionMs=0, isCompleted=false, playCount=0 자동 설정
  }

  @override
  int get schemaVersion => 12; // ✅ 스키마 버전 12: Schedule에 timezone, originalHour, originalMinute 추가 (DST 대응)

  // ✅ [마이그레이션 전략 추가]
  // 이거를 설정하고 → onCreate에서 테이블을 생성하고
  // 이거를 해서 → onUpgrade에서 스키마 변경 시 마이그레이션 로직을 실행한다
  // 이거는 이래서 → Drift가 데이터베이스 초기화 및 업그레이드를 안전하게 처리한다
  // 이거라면 → 앱 재실행 시 마이그레이션 오류가 발생하지 않는다
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // v2 → v3: Task와 Habit 테이블에 반복/리마인더 컬럼 추가
      if (from == 2 && to == 3) {
        await m.addColumn(task, task.repeatRule);
        await m.addColumn(task, task.reminder);
        await m.addColumn(habit, habit.reminder);
      }

      // v3 → v4: DailyCardOrder 테이블 추가 (날짜별 카드 순서 관리)
      if (from == 3 && to == 4) {
        await m.createTable(dailyCardOrder);
      }

      // v4 → v5: Insight Player 테이블 추가 (AudioContents만, 재생 상태 통합)
      if (from == 4 && to >= 5) {
        await m.createTable(audioContents);
        await m.createTable(transcriptLines);
      }

      // v5 → v6: Task 테이블에 executionDate (실행일) 컬럼 추가
      if (from == 5 && to >= 6) {
        await m.addColumn(task, task.executionDate);
      }

      // v6 → v7: RecurringPattern, RecurringException 테이블 추가 (반복 일정 지원)
      if (from == 6 && to >= 7) {
        await m.createTable(recurringPattern);
        await m.createTable(recurringException);
      }

      // v7 → v8: Schedule 테이블에 completed, completedAt 컬럼 추가
      if (from == 7 && to >= 8) {
        await m.addColumn(schedule, schedule.completed);
        await m.addColumn(schedule, schedule.completedAt);
      }

      // v8 → v9: Task 테이블에 inboxOrder 컬럼 추가 (인박스 순서 관리)
      if (from == 8 && to >= 9) {
        await m.addColumn(task, task.inboxOrder);
      }

      // v9 → v10: ScheduleCompletion, TaskCompletion 테이블 추가 (반복 이벤트 완료 처리)
      if (from == 9 && to >= 10) {
        await m.createTable(scheduleCompletion);
        await m.createTable(taskCompletion);
      }

      // v10 → v11: RecurringPattern에 recurrenceMode 컬럼 추가 (every vs every! 지원)
      if (from == 10 && to >= 11) {
        await customStatement(
          'ALTER TABLE recurring_pattern ADD COLUMN recurrence_mode TEXT NOT NULL DEFAULT "ABSOLUTE"',
        );
      }

      // v11 → v12: Schedule에 timezone, originalHour, originalMinute 추가 (DST 대응)
      if (from == 11 && to >= 12) {
        await m.addColumn(schedule, schedule.timezone);
        await m.addColumn(schedule, schedule.originalHour);
        await m.addColumn(schedule, schedule.originalMinute);

        // 🔥 기존 데이터 마이그레이션: 기존 start에서 시간 추출
        await customStatement('''
          UPDATE schedule
          SET 
            original_hour = CAST(strftime('%H', start) AS INTEGER),
            original_minute = CAST(strftime('%M', start) AS INTEGER),
            timezone = ''
          WHERE original_hour IS NULL
        ''');
      }
    },
    beforeOpen: (details) async {
      // 외래키 제약조건 활성화 등
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // ============================================================================
  // 🔥 Phase 2 - Task 4: 완료 확인 우선순위 헬퍼 함수
  // ============================================================================
  //
  // **목적:**
  // - 중복된 완료 확인 로직을 통합하여 유지보수성 향상
  // - 완료 확인 우선순위를 명확히 정의
  //
  // **우선순위:**
  // 1순위: Completion 테이블 (반복 일정/할일/습관)
  // 2순위: completed 필드 (일반 일정/할일)
  //
  // **사용처:**
  // - date_detail_view.dart의 StreamBuilder 내부
  // - UnifiedItemList 빌드 시 필터링
  //
  // **데이터베이스 구조 변경 없음** (읽기 전용)

  /// ✅ Task 완료 여부 확인 (동기)
  /// - 반복 할일: TaskCompletion 테이블 확인 (1순위)
  /// - 일반 할일: Task.completed 필드 확인 (2순위)
  bool isTaskCompletedSync(
    TaskData task,
    List<TaskCompletionData> completions,
  ) {
    if (task.repeatRule.isNotEmpty) {
      // 반복 할일: TaskCompletion 테이블에서 확인
      return completions.any((c) => c.taskId == task.id);
    }
    // 일반 할일: completed 필드 확인
    return task.completed;
  }

  /// ✅ Schedule 완료 여부 확인 (동기)
  /// - 반복 일정: ScheduleCompletion 테이블 확인 (1순위)
  /// - 일반 일정: Schedule.completed 필드 확인 (2순위)
  bool isScheduleCompletedSync(
    ScheduleData schedule,
    List<ScheduleCompletionData> completions,
  ) {
    if (schedule.repeatRule.isNotEmpty) {
      // 반복 일정: ScheduleCompletion 테이블에서 확인
      return completions.any((c) => c.scheduleId == schedule.id);
    }
    // 일반 일정: completed 필드 확인
    return schedule.completed;
  }

  /// ✅ Habit 완료 여부 확인 (동기)
  /// - Habit은 항상 HabitCompletion 테이블 사용
  bool isHabitCompletedSync(
    HabitData habit,
    List<HabitCompletionData> completions,
  ) {
    // Habit은 항상 HabitCompletion 테이블에서 확인
    return completions.any((c) => c.habitId == habit.id);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder =
        await getApplicationDocumentsDirectory(); //이거는 닥큐멘트 드렉토리를 가져옴. 앱에 지정된 문팡리이다.
    //p.join은 경로를 합쳐준다.
    //어떠한 결로를 합칠 건가?
    //dbFolder.path는 앱의 문서 폴더 경로이다. 시스템에서 자동으로 지정해주는 경로
    //'db.sqlite'는 데이터베이스 (예시)파일 이름이다.
    //합쳐서 /users/appuser/documents/db.sqlite 경로를 만든다.
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions(); // 'sqlite3' 포함
    }

    final cachedDatabase = await getTemporaryDirectory(); //이거는 임시 폴더를 가져오는 것이다.

    sqlite3.tempDirectory = cachedDatabase.path; //임시폴더를 써서 캐시를 저장할 곳이 필요하다.

    return NativeDatabase.createInBackground(file);
    //오픈커넥트 함수를 실행을 하면, 해당 파일경로 위치에 데이터베이스를 생성한다라는 뜻
  });
}
