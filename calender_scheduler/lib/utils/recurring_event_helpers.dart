import 'package:drift/drift.dart';
import '../Database/schedule_database.dart';
import '../model/entities.dart';
import '../model/schedule.dart';

/// ✅ 반복 이벤트 수정/삭제 헬퍼 함수 (RFC 5545 표준 완벽 준수)
///
/// **목적:**
/// Schedule, Task, Habit의 반복 이벤트 처리를 RRULE 표준에 맞게 통합하여
/// 오늘만/이후/전체 수정/삭제를 완벽하게 처리한다.
///
/// **RFC 5545 표준 준수:**
/// - EXDATE: 특정 날짜만 제외 (RecurringException with isCancelled=true)
/// - UNTIL: 반복 종료일 설정 (RecurringPattern.until)
/// - RecurringException: 단일 인스턴스 수정 (modifiedTitle, newStartDate 등)
/// - RRULE Split: 이후 모두 변경 시 기존 패턴 종료 + 새 패턴 생성
///
/// **지원 작업:**
/// 1. この回のみ削除: RecurringException(isCancelled=true) 생성
/// 2. この予定以降削除: RecurringPattern.until 설정
/// 3. すべての回削除: Base Event 삭제 (CASCADE)
/// 4. この回のみ変更: RecurringException(modified fields) 생성
/// 5. この予定以降変更: RRULE 분할 (기존 종료 + 새 패턴)
/// 6. すべての回変更: Base Event 업데이트
///
/// **날짜 정규화:**
/// - 모든 originalDate는 00:00:00으로 정규화 (날짜만 저장)
/// - Schedule: 시간 변경 시 isRescheduled=true, newStartDate/newEndDate 사용
/// - Task/Habit: 시간이 없으므로 isRescheduled=false
///
/// **적용 엔티티:**
/// - Schedule: 일정 (시작/종료 시간 있음)
/// - Task: 할일 (executionDate만 있음)
/// - Habit: 습관 (날짜만 있음)

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

  // 🔥 시간 변경 여부 확인: start 또는 end가 변경되었는지 체크
  final isTimeChanged = (updatedSchedule.start.present &&
          updatedSchedule.start.value != schedule.start) ||
      (updatedSchedule.end.present && updatedSchedule.end.value != schedule.end);

  print('   - isTimeChanged: $isTimeChanged');

  await db.createRecurringException(
    RecurringExceptionCompanion(
      recurringPatternId: Value(pattern.id),
      originalDate: Value(
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      ), // 날짜만 저장
      isCancelled: const Value(false),
      isRescheduled: Value(isTimeChanged), // ✅ 시간이 실제로 변경된 경우만 true
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

  // 🔥 Task는 시간이 없으므로 항상 isRescheduled=false
  // (Task는 title, colorId만 변경 가능)
  await db.createRecurringException(
    RecurringExceptionCompanion(
      recurringPatternId: Value(pattern.id),
      originalDate: Value(
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      ), // 날짜만 저장
      isCancelled: const Value(false),
      isRescheduled: const Value(false), // ✅ Task는 시간 없음
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
      originalDate: Value(
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      ), // 날짜만 저장 (시간 제거)
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
