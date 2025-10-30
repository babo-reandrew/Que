import 'package:drift/drift.dart';
import '../Database/schedule_database.dart';
import '../model/entities.dart';
import '../model/schedule.dart';

/// 반복 이벤트 수정/삭제 헬퍼 함수
/// 이거를 설정하고 → Schedule, Task, Habit의 반복 이벤트 처리를 통합해서
/// 이거를 해서 → 오늘만/이후/전체 수정/삭제를 RFC 5545 표준으로 처리하고
/// 이거는 이래서 → 코드 중복을 줄이고 일관된 동작을 보장한다

// ==================== Schedule 수정 헬퍼 함수 ====================

/// ✅ この回のみ 수정: RFC 5545 RecurringException으로 예외 처리
Future<void> updateScheduleThisOnly({
  required AppDatabase db,
  required ScheduleData schedule,
  required DateTime selectedDate,
  required ScheduleCompanion updatedSchedule,
}) async {
  // 1. RecurringPattern 조회
  final pattern = await db.getRecurringPattern(
    entityType: 'schedule',
    entityId: schedule.id,
  );

  if (pattern == null) {
    print('⚠️ [Schedule] RecurringPattern 없음');
    return;
  }

  // 2. RecurringException 생성 (수정된 내용 저장)
  print('🔥 [RecurringHelpers] updateScheduleThisOnly 실행');
  print('   - Schedule ID: ${schedule.id}');
  print('   - Pattern ID: ${pattern.id}');
  print('   - selectedDate (originalDate): $selectedDate');
  print('   - schedule.start: ${schedule.start}');

  await db.createRecurringException(
    RecurringExceptionCompanion(
      recurringPatternId: Value(pattern.id),
      originalDate: Value(
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      ), // 날짜만 저장
      isCancelled: const Value(false),
      isRescheduled: const Value(true),
      newStartDate: updatedSchedule.start.present
          ? updatedSchedule.start
          : const Value(null),
      newEndDate: updatedSchedule.end.present
          ? updatedSchedule.end
          : const Value(null),
      modifiedTitle: updatedSchedule.summary.present
          ? updatedSchedule.summary
          : const Value(null),
      modifiedDescription: updatedSchedule.description.present
          ? updatedSchedule.description
          : const Value(null),
      modifiedLocation: updatedSchedule.location.present
          ? updatedSchedule.location
          : const Value(null),
      modifiedColorId: updatedSchedule.colorId.present
          ? updatedSchedule.colorId
          : const Value(null),
    ),
  );

  print('✅ [Schedule] この回のみ 수정 완료 (RFC 5545 RecurringException)');
  print('   - Schedule ID: ${schedule.id}');
  print('   - Pattern ID: ${pattern.id}');
  print('   - Original Date: $selectedDate');
}

/// ✅ この予定以降 수정: RRULE 분할 (기존은 어제까지, 새로운 규칙 생성)
Future<void> updateScheduleFuture({
  required AppDatabase db,
  required ScheduleData schedule,
  required DateTime selectedDate,
  required ScheduleCompanion updatedSchedule,
  required String? newRRule,
}) async {
  // 1. RecurringPattern 조회
  final pattern = await db.getRecurringPattern(
    entityType: 'schedule',
    entityId: schedule.id,
  );

  if (pattern == null) {
    print('⚠️ [Schedule] RecurringPattern 없음');
    return;
  }

  print('🔥 [RecurringHelpers] updateScheduleFuture 실행');
  print('   - Schedule ID: ${schedule.id}');
  print('   - selectedDate: $selectedDate');
  print('   - schedule.start: ${schedule.start}');

  // 2. 기존 패턴의 UNTIL을 어제로 설정 (선택 날짜 이전까지만 유효)
  final yesterday = selectedDate.subtract(const Duration(days: 1));
  print('   - 기존 패턴 UNTIL 설정: ${yesterday}');

  await db.updateRecurringPattern(
    RecurringPatternCompanion(
      id: Value(pattern.id),
      until: Value(
        DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
      ),
    ),
  );

  // 3. 새로운 Schedule 생성 (오늘부터 시작)
  final newScheduleId = await db.createSchedule(updatedSchedule);
  print('   - 새 Schedule 생성: ID=$newScheduleId');

  // 4. 새로운 RecurringPattern 생성
  if (newRRule != null) {
    await db.createRecurringPattern(
      RecurringPatternCompanion.insert(
        entityType: 'schedule',
        entityId: newScheduleId,
        rrule: newRRule,
        dtstart: selectedDate,
      ),
    );
    print('   - 새 RecurringPattern 생성: dtstart=$selectedDate');
  }

  print('✅ [Schedule] この予定以降 수정 완료 (RRULE 분할)');
  print('   - 기존 Schedule ID: ${schedule.id} (${yesterday}까지)');
  print('   - 새 Schedule ID: $newScheduleId ($selectedDate부터)');
}

/// ✅ すべての回 수정: Base Event + RecurringPattern 업데이트
Future<void> updateScheduleAll({
  required AppDatabase db,
  required ScheduleData schedule,
  required ScheduleCompanion updatedSchedule,
  required String? newRRule,
}) async {
  // 1. Base Schedule 업데이트
  await db.updateSchedule(updatedSchedule);

  // 2. RecurringPattern 업데이트 (RRULE 변경 시)
  if (newRRule != null) {
    final pattern = await db.getRecurringPattern(
      entityType: 'schedule',
      entityId: schedule.id,
    );

    if (pattern != null) {
      await db.updateRecurringPattern(
        RecurringPatternCompanion(
          id: Value(pattern.id),
          rrule: Value(newRRule),
        ),
      );
    }
  }

  print('✅ [Schedule] すべての回 수정 완료');
  print('   - Schedule ID: ${schedule.id}');
}

// ==================== Schedule 삭제 헬퍼 함수 ====================

/// ✅ この回のみ 삭제: RFC 5545 RecurringException으로 취소 표시
Future<void> deleteScheduleThisOnly({
  required AppDatabase db,
  required ScheduleData schedule,
  required DateTime selectedDate,
}) async {
  final pattern = await db.getRecurringPattern(
    entityType: 'schedule',
    entityId: schedule.id,
  );

  if (pattern == null) {
    print('⚠️ [Schedule] RecurringPattern 없음');
    return;
  }

  print('🔥 [RecurringHelpers] deleteScheduleThisOnly 실행');
  print('   - Schedule ID: ${schedule.id}');
  print('   - selectedDate (originalDate): $selectedDate');
  print('   - schedule.start: ${schedule.start}');

  await db.createRecurringException(
    RecurringExceptionCompanion(
      recurringPatternId: Value(pattern.id),
      originalDate: Value(
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      ), // 날짜만 저장
      isCancelled: const Value(true),
      isRescheduled: const Value(false),
    ),
  );

  print('✅ [Schedule] この回のみ 삭제 완료 (RFC 5545 EXDATE)');
}

/// ✅ この予定以降 삭제: RFC 5545 UNTIL로 종료일 설정
Future<void> deleteScheduleFuture({
  required AppDatabase db,
  required ScheduleData schedule,
  required DateTime selectedDate,
}) async {
  final pattern = await db.getRecurringPattern(
    entityType: 'schedule',
    entityId: schedule.id,
  );

  if (pattern == null) {
    print('⚠️ [Schedule] RecurringPattern 없음');
    return;
  }

  print('🔥 [RecurringHelpers] deleteScheduleFuture 실행');
  print('   - Schedule ID: ${schedule.id}');
  print('   - selectedDate: $selectedDate');
  print('   - schedule.start: ${schedule.start}');

  final yesterday = selectedDate.subtract(const Duration(days: 1));
  final until = DateTime(
    yesterday.year,
    yesterday.month,
    yesterday.day,
    23,
    59,
    59,
  );
  print('   - UNTIL 설정: $until');

  await db.updateRecurringPattern(
    RecurringPatternCompanion(id: Value(pattern.id), until: Value(until)),
  );

  print('✅ [Schedule] この予定以降 삭제 완료 (RFC 5545 UNTIL)');
}

/// ✅ すべての回 삭제: RecurringPattern + Base Schedule 삭제
Future<void> deleteScheduleAll({
  required AppDatabase db,
  required ScheduleData schedule,
}) async {
  // RecurringPattern도 CASCADE로 자동 삭제됨
  await db.deleteSchedule(schedule.id);
  print('✅ [Schedule] すべての回 삭제 완료');
}

// ==================== Task 수정 헬퍼 함수 ====================

/// ✅ この回のみ 수정: RFC 5545 RecurringException으로 예외 처리
Future<void> updateTaskThisOnly({
  required AppDatabase db,
  required TaskData task,
  required DateTime selectedDate,
  required TaskCompanion updatedTask,
}) async {
  final pattern = await db.getRecurringPattern(
    entityType: 'task',
    entityId: task.id,
  );

  if (pattern == null) {
    print('⚠️ [Task] RecurringPattern 없음');
    return;
  }

  await db.createRecurringException(
    RecurringExceptionCompanion(
      recurringPatternId: Value(pattern.id),
      originalDate: Value(selectedDate),
      isCancelled: const Value(false),
      isRescheduled: const Value(true),
      modifiedTitle: updatedTask.title.present
          ? updatedTask.title
          : const Value(null),
      modifiedColorId: updatedTask.colorId.present
          ? updatedTask.colorId
          : const Value(null),
    ),
  );

  print('✅ [Task] この回のみ 수정 완료 (RFC 5545 RecurringException)');
}

/// ✅ この予定以降 수정: RRULE 분할
Future<void> updateTaskFuture({
  required AppDatabase db,
  required TaskData task,
  required DateTime selectedDate,
  required TaskCompanion updatedTask,
  required String? newRRule,
}) async {
  final pattern = await db.getRecurringPattern(
    entityType: 'task',
    entityId: task.id,
  );

  if (pattern == null) {
    print('⚠️ [Task] RecurringPattern 없음');
    return;
  }

  final yesterday = selectedDate.subtract(const Duration(days: 1));
  await db.updateRecurringPattern(
    RecurringPatternCompanion(
      id: Value(pattern.id),
      until: Value(
        DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
      ),
    ),
  );

  final newTaskId = await db.createTask(updatedTask);

  if (newRRule != null) {
    await db.createRecurringPattern(
      RecurringPatternCompanion.insert(
        entityType: 'task',
        entityId: newTaskId,
        rrule: newRRule,
        dtstart: selectedDate,
      ),
    );
  }

  print('✅ [Task] この予定以降 수정 완료 (RRULE 분할)');
}

/// ✅ すべての回 수정: Base Event + RecurringPattern 업데이트
Future<void> updateTaskAll({
  required AppDatabase db,
  required TaskData task,
  required TaskCompanion updatedTask,
  required String? newRRule,
}) async {
  // Task 업데이트 (update 함수가 없으므로 직접 처리)
  await (db.update(
    db.task,
  )..where((tbl) => tbl.id.equals(task.id))).write(updatedTask);

  if (newRRule != null) {
    final pattern = await db.getRecurringPattern(
      entityType: 'task',
      entityId: task.id,
    );

    if (pattern != null) {
      await db.updateRecurringPattern(
        RecurringPatternCompanion(
          id: Value(pattern.id),
          rrule: Value(newRRule),
        ),
      );
    }
  }

  print('✅ [Task] すべての回 수정 완료');
}

// ==================== Task 삭제 헬퍼 함수 ====================

/// ✅ この回のみ 삭제: RFC 5545 RecurringException으로 취소 표시
Future<void> deleteTaskThisOnly({
  required AppDatabase db,
  required TaskData task,
  required DateTime selectedDate,
}) async {
  final pattern = await db.getRecurringPattern(
    entityType: 'task',
    entityId: task.id,
  );

  if (pattern == null) {
    print('⚠️ [Task] RecurringPattern 없음');
    return;
  }

  await db.createRecurringException(
    RecurringExceptionCompanion(
      recurringPatternId: Value(pattern.id),
      originalDate: Value(selectedDate),
      isCancelled: const Value(true),
      isRescheduled: const Value(false),
    ),
  );

  print('✅ [Task] この回のみ 삭제 완료 (RFC 5545 EXDATE)');
}

/// ✅ この予定以降 삭제: RFC 5545 UNTIL로 종료일 설정
Future<void> deleteTaskFuture({
  required AppDatabase db,
  required TaskData task,
  required DateTime selectedDate,
}) async {
  final pattern = await db.getRecurringPattern(
    entityType: 'task',
    entityId: task.id,
  );

  if (pattern == null) {
    print('⚠️ [Task] RecurringPattern 없음');
    return;
  }

  final yesterday = selectedDate.subtract(const Duration(days: 1));
  final until = DateTime(
    yesterday.year,
    yesterday.month,
    yesterday.day,
    23,
    59,
    59,
  );

  await db.updateRecurringPattern(
    RecurringPatternCompanion(id: Value(pattern.id), until: Value(until)),
  );

  print('✅ [Task] この予定以降 삭제 완료 (RFC 5545 UNTIL)');
}

/// ✅ すべての回 삭제: RecurringPattern + Base Task 삭제
Future<void> deleteTaskAll({
  required AppDatabase db,
  required TaskData task,
}) async {
  await db.deleteTask(task.id);
  print('✅ [Task] すべての回 삭제 완료');
}
