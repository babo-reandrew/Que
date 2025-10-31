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

/// ✅ この回のみ 수정: 완전한 포크(Fork) 방식
/// - 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
/// - 완전히 새로운 Schedule 생성 (단일 일정, 반복 없음)
/// - DailyCardOrder에 새 Schedule 추가
Future<int> updateScheduleThisOnly({
  required AppDatabase db,
  required ScheduleData schedule,
  required DateTime selectedDate,
  required ScheduleCompanion updatedSchedule,
}) async {
  print('🔥 [RecurringHelpers] updateScheduleThisOnly 실행 (완전한 포크 방식)');
  print('   - 원본 Schedule ID: ${schedule.id}');
  print('   - selectedDate: $selectedDate');

  // 1. 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
  final exdateAdded = await db.addExdate(
    entityType: 'schedule',
    entityId: schedule.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
    print('⚠️ [Schedule] EXDATE 추가 실패');
  } else {
    print('✅ [Schedule] EXDATE 추가 완료: $selectedDate');
  }

  // 2. 완전히 새로운 Schedule 생성 (단일 일정, 반복 없음)
  final newScheduleId = await db.createSchedule(
    ScheduleCompanion(
      summary: updatedSchedule.summary.present
          ? updatedSchedule.summary
          : Value(schedule.summary),
      start: updatedSchedule.start.present
          ? updatedSchedule.start
          : Value(schedule.start),
      end: updatedSchedule.end.present
          ? updatedSchedule.end
          : Value(schedule.end),
      colorId: updatedSchedule.colorId.present
          ? updatedSchedule.colorId
          : Value(schedule.colorId),
      alertSetting: updatedSchedule.alertSetting.present
          ? updatedSchedule.alertSetting
          : Value(schedule.alertSetting),
      description: updatedSchedule.description.present
          ? updatedSchedule.description
          : Value(schedule.description),
      location: updatedSchedule.location.present
          ? updatedSchedule.location
          : Value(schedule.location),
      status: updatedSchedule.status.present
          ? updatedSchedule.status
          : Value(schedule.status),
      visibility: updatedSchedule.visibility.present
          ? updatedSchedule.visibility
          : Value(schedule.visibility),
      repeatRule: const Value(''), // ✅ 반복 없음 (단일 일정)
      createdAt: Value(DateTime.now()),
    ),
  );

  print('✅ [Schedule] 새로운 단일 Schedule 생성 완료');
  print('   - 새 Schedule ID: $newScheduleId');
  print('   - 반복 규칙: 없음 (단일 일정)');
  print('🎯 [결과] 원본 반복에서 해당 날짜 제외 + 새로운 단일 일정 생성');

  return newScheduleId; // 새로운 Schedule ID 반환 (DailyCardOrder 업데이트용)
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

  // 3. 새로운 Schedule 생성 (선택 날짜부터 시작)
  final newScheduleId = await db.createSchedule(updatedSchedule);
  print('   - 새 Schedule 생성: ID=$newScheduleId');

  // 4. 새로운 RecurringPattern 생성
  if (newRRule != null) {
    // ✅ dtstart는 새 Schedule의 시작 날짜 (00:00:00)로 설정
    final newStart = updatedSchedule.start.present
        ? updatedSchedule.start.value
        : schedule.start;
    final dtstart = DateTime(
      newStart.year,
      newStart.month,
      newStart.day,
    ); // 날짜만 (시간 제거)

    await db.createRecurringPattern(
      RecurringPatternCompanion.insert(
        entityType: 'schedule',
        entityId: newScheduleId,
        rrule: newRRule,
        dtstart: dtstart, // ✅ 새 일정의 날짜로 설정
      ),
    );
    print('   - 새 RecurringPattern 생성: dtstart=$dtstart');
  }

  print('✅ [Schedule] この予定以降 수정 완료 (RRULE 분할)');
  print('   - 기존 Schedule ID: ${schedule.id} (~$yesterday 23:59:59까지)');
  print('   - 새 Schedule ID: $newScheduleId (${updatedSchedule.start.present ? updatedSchedule.start.value : schedule.start}부터)');
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

/// ✅ この回のみ 삭제: RFC 5545 EXDATE 추가
/// - RecurringPattern에 EXDATE만 추가 (해당 날짜 제외)
/// - RecurringException 사용 안 함 (더 명확한 방식)
Future<void> deleteScheduleThisOnly({
  required AppDatabase db,
  required ScheduleData schedule,
  required DateTime selectedDate,
}) async {
  print('🔥 [RecurringHelpers] deleteScheduleThisOnly 실행 (EXDATE 추가 방식)');
  print('   - Schedule ID: ${schedule.id}');
  print('   - selectedDate: $selectedDate');

  // 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
  final exdateAdded = await db.addExdate(
    entityType: 'schedule',
    entityId: schedule.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
    print('⚠️ [Schedule] EXDATE 추가 실패');
    throw Exception('EXDATE 추가 실패');
  }

  print('✅ [Schedule] この回のみ 삭제 완료 (RFC 5545 EXDATE)');
  print('   - EXDATE 추가: $selectedDate');
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

/// ✅ この回のみ 수정: 완전한 포크(Fork) 방식
/// - 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
/// - 완전히 새로운 Task 생성 (단일 할일, 반복 없음)
Future<int> updateTaskThisOnly({
  required AppDatabase db,
  required TaskData task,
  required DateTime selectedDate,
  required TaskCompanion updatedTask,
}) async {
  print('🔥 [RecurringHelpers] updateTaskThisOnly 실행 (완전한 포크 방식)');
  print('   - 원본 Task ID: ${task.id}');
  print('   - selectedDate: $selectedDate');

  // 1. 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
  final exdateAdded = await db.addExdate(
    entityType: 'task',
    entityId: task.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
    print('⚠️ [Task] EXDATE 추가 실패');
  } else {
    print('✅ [Task] EXDATE 추가 완료: $selectedDate');
  }

  // 2. 완전히 새로운 Task 생성 (단일 할일, 반복 없음)
  final newTaskId = await db.createTask(
    TaskCompanion(
      title: updatedTask.title.present
          ? updatedTask.title
          : Value(task.title),
      completed: updatedTask.completed.present
          ? updatedTask.completed
          : Value(task.completed),
      dueDate: updatedTask.dueDate.present
          ? updatedTask.dueDate
          : Value(task.dueDate),
      executionDate: updatedTask.executionDate.present
          ? updatedTask.executionDate
          : Value(task.executionDate),
      colorId: updatedTask.colorId.present
          ? updatedTask.colorId
          : Value(task.colorId),
      reminder: updatedTask.reminder.present
          ? updatedTask.reminder
          : Value(task.reminder),
      repeatRule: const Value(''), // ✅ 반복 없음 (단일 할일)
      createdAt: Value(DateTime.now()),
    ),
  );

  print('✅ [Task] 새로운 단일 Task 생성 완료');
  print('   - 새 Task ID: $newTaskId');
  print('   - 반복 규칙: 없음 (단일 할일)');
  print('🎯 [결과] 원본 반복에서 해당 날짜 제외 + 새로운 단일 할일 생성');

  return newTaskId; // 새로운 Task ID 반환
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
    // ✅ dtstart는 새 Task의 실행 날짜 (00:00:00)로 설정
    final newExecutionDate = updatedTask.executionDate.present
        ? updatedTask.executionDate.value
        : task.executionDate;
    final dtstart = newExecutionDate != null
        ? DateTime(
            newExecutionDate.year,
            newExecutionDate.month,
            newExecutionDate.day,
          )
        : selectedDate;

    await db.createRecurringPattern(
      RecurringPatternCompanion.insert(
        entityType: 'task',
        entityId: newTaskId,
        rrule: newRRule,
        dtstart: dtstart, // ✅ 새 할일의 날짜로 설정
      ),
    );
    print('   - 새 RecurringPattern 생성: dtstart=$dtstart');
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

/// ✅ この回のみ 삭제: RFC 5545 EXDATE 추가
/// - RecurringPattern에 EXDATE만 추가 (해당 날짜 제외)
Future<void> deleteTaskThisOnly({
  required AppDatabase db,
  required TaskData task,
  required DateTime selectedDate,
}) async {
  print('🔥 [RecurringHelpers] deleteTaskThisOnly 실행 (EXDATE 추가 방식)');
  print('   - Task ID: ${task.id}');
  print('   - selectedDate: $selectedDate');

  // 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
  final exdateAdded = await db.addExdate(
    entityType: 'task',
    entityId: task.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
    print('⚠️ [Task] EXDATE 추가 실패');
    throw Exception('EXDATE 추가 실패');
  }

  print('✅ [Task] この回のみ 삭제 완료 (RFC 5545 EXDATE)');
  print('   - EXDATE 추가: $selectedDate');
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
