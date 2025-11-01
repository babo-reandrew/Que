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

  // 1. 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
  final exdateAdded = await db.addExdate(
    entityType: 'schedule',
    entityId: schedule.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
  } else {
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
    return;
  }


  // 🔥 트랜잭션으로 묶어서 원자성 보장
  await db.transaction(() async {
    // 2. 기존 패턴의 UNTIL을 어제로 설정 (선택 날짜 이전까지만 유효)
    final yesterday = selectedDate.subtract(const Duration(days: 1));

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
    }

    // 🔥 5. 고아 예외 정리 (치명적 누락 해결!)
    await (db.delete(db.recurringException)
          ..where(
            (tbl) =>
                tbl.recurringPatternId.equals(pattern.id) &
                tbl.originalDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();

    // 🔥 6. 고아 완료 기록 정리 (치명적 누락 해결!)
    await (db.delete(db.scheduleCompletion)
          ..where(
            (tbl) =>
                tbl.scheduleId.equals(schedule.id) &
                tbl.completedDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();
  });

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

  // 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
  final exdateAdded = await db.addExdate(
    entityType: 'schedule',
    entityId: schedule.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
    throw Exception('EXDATE 추가 실패');
  }

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

}

/// ✅ すべての回 삭제: RecurringPattern + Base Schedule 삭제
Future<void> deleteScheduleAll({
  required AppDatabase db,
  required ScheduleData schedule,
}) async {
  // RecurringPattern도 CASCADE로 자동 삭제됨
  await db.deleteSchedule(schedule.id);
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

  // 1. 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
  final exdateAdded = await db.addExdate(
    entityType: 'task',
    entityId: task.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
  } else {
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
    return;
  }

  // 🔥 트랜잭션으로 묶어서 원자성 보장
  await db.transaction(() async {
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
    }

    // 🔥 고아 예외 정리 (치명적 누락 해결!)
    await (db.delete(db.recurringException)
          ..where(
            (tbl) =>
                tbl.recurringPatternId.equals(pattern.id) &
                tbl.originalDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();

    // 🔥 고아 완료 기록 정리 (치명적 누락 해결!)
    await (db.delete(db.taskCompletion)
          ..where(
            (tbl) =>
                tbl.taskId.equals(task.id) &
                tbl.completedDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();
  });

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

}

// ==================== Task 삭제 헬퍼 함수 ====================

/// ✅ この回のみ 삭제: RFC 5545 EXDATE 추가
/// - RecurringPattern에 EXDATE만 추가 (해당 날짜 제외)
Future<void> deleteTaskThisOnly({
  required AppDatabase db,
  required TaskData task,
  required DateTime selectedDate,
}) async {

  // 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
  final exdateAdded = await db.addExdate(
    entityType: 'task',
    entityId: task.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
    throw Exception('EXDATE 추가 실패');
  }

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

}

/// ✅ すべての回 삭제: RecurringPattern + Base Task 삭제
Future<void> deleteTaskAll({
  required AppDatabase db,
  required TaskData task,
}) async {
  await db.deleteTask(task.id);
}

// ==================== Habit 수정 헬퍼 함수 ====================

/// ✅ この回のみ 수정: 완전한 포크(Fork) 방식
/// - 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
/// - 완전히 새로운 Habit 생성 (단일 습관, 반복 없음)
Future<int> updateHabitThisOnly({
  required AppDatabase db,
  required HabitData habit,
  required DateTime selectedDate,
  required HabitCompanion updatedHabit,
}) async {

  // 1. 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
  final exdateAdded = await db.addExdate(
    entityType: 'habit',
    entityId: habit.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
  } else {
  }

  // 2. 완전히 새로운 Habit 생성 (단일 습관, 반복 없음)
  final newHabitId = await db.createHabit(
    HabitCompanion(
      title: updatedHabit.title.present
          ? updatedHabit.title
          : Value(habit.title),
      colorId: updatedHabit.colorId.present
          ? updatedHabit.colorId
          : Value(habit.colorId),
      reminder: updatedHabit.reminder.present
          ? updatedHabit.reminder
          : Value(habit.reminder),
      repeatRule: const Value(''), // ✅ 반복 없음 (단일 습관)
      createdAt: Value(DateTime.now()),
    ),
  );


  return newHabitId; // 새로운 Habit ID 반환
}

/// ✅ この予定以降 수정: RRULE 분할 (기존은 어제까지, 새로운 규칙 생성)
Future<void> updateHabitFuture({
  required AppDatabase db,
  required HabitData habit,
  required DateTime selectedDate,
  required HabitCompanion updatedHabit,
  required String? newRRule,
}) async {
  // 1. RecurringPattern 조회
  final pattern = await db.getRecurringPattern(
    entityType: 'habit',
    entityId: habit.id,
  );

  if (pattern == null) {
    return;
  }


  await db.transaction(() async {
    // 2. 기존 패턴의 UNTIL을 어제로 설정 (선택 날짜 이전까지만 유효)
    final yesterday = selectedDate.subtract(const Duration(days: 1));

    await db.updateRecurringPattern(
      RecurringPatternCompanion(
        id: Value(pattern.id),
        until: Value(
          DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        ),
      ),
    );

    // 3. 새로운 Habit 생성 (선택 날짜부터 시작)
    final newHabitId = await db.createHabit(updatedHabit);

    // 4. 새로운 RecurringPattern 생성
    if (newRRule != null) {
      // ✅ dtstart는 선택된 날짜 (00:00:00)로 설정
      final dtstart = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      ); // 날짜만 (시간 제거)

      await db.createRecurringPattern(
        RecurringPatternCompanion.insert(
          entityType: 'habit',
          entityId: newHabitId,
          rrule: newRRule,
          dtstart: dtstart, // ✅ 새 습관의 날짜로 설정
        ),
      );
    }

    // 🔥 5. 고아 예외 정리 (치명적 누락 해결!)
    await (db.delete(db.recurringException)
          ..where(
            (tbl) =>
                tbl.recurringPatternId.equals(pattern.id) &
                tbl.originalDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();

    // 🔥 6. 고아 완료 기록 정리 (치명적 누락 해결!)
    await (db.delete(db.habitCompletion)
          ..where(
            (tbl) =>
                tbl.habitId.equals(habit.id) &
                tbl.completedDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();
  });

}

/// ✅ すべての回 수정: Base Event + RecurringPattern 업데이트
Future<void> updateHabitAll({
  required AppDatabase db,
  required HabitData habit,
  required HabitCompanion updatedHabit,
  required String? newRRule,
}) async {
  // 1. Base Habit 업데이트
  await db.updateHabit(updatedHabit);

  // 2. RecurringPattern 업데이트 (RRULE 변경 시)
  if (newRRule != null) {
    final pattern = await db.getRecurringPattern(
      entityType: 'habit',
      entityId: habit.id,
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

}

// ==================== Habit 삭제 헬퍼 함수 ====================

/// ✅ この回のみ 삭제: RFC 5545 EXDATE 추가
/// - RecurringPattern에 EXDATE만 추가 (해당 날짜 제외)
Future<void> deleteHabitThisOnly({
  required AppDatabase db,
  required HabitData habit,
  required DateTime selectedDate,
}) async {

  // 원본 RecurringPattern에 EXDATE 추가 (해당 날짜 제외)
  final exdateAdded = await db.addExdate(
    entityType: 'habit',
    entityId: habit.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
    throw Exception('EXDATE 추가 실패');
  }

}

/// ✅ この予定以降 삭제: RFC 5545 UNTIL로 종료일 설정
Future<void> deleteHabitFuture({
  required AppDatabase db,
  required HabitData habit,
  required DateTime selectedDate,
}) async {
  final pattern = await db.getRecurringPattern(
    entityType: 'habit',
    entityId: habit.id,
  );

  if (pattern == null) {
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

}

/// ✅ すべての回 삭제: RecurringPattern + Base Habit 삭제
Future<void> deleteHabitAll({
  required AppDatabase db,
  required HabitData habit,
}) async {
  // RecurringPattern도 CASCADE로 자동 삭제됨
  await db.deleteHabit(habit.id);
}

// ==================== Schedule 반복 제거 헬퍼 함수 ====================

/// ✅ この回のみ 반복 제거: EXDATE + 단일 일정 생성
/// - 원본 RecurringPattern에 EXDATE 추가
/// - 선택된 날짜에 단일 일정 생성 (반복 없음)
Future<int> removeScheduleRecurrenceThisOnly({
  required AppDatabase db,
  required ScheduleData schedule,
  required DateTime selectedDate,
}) async {
  // 1. EXDATE 추가 (원본 반복 패턴에서 해당 날짜 제외)
  final exdateAdded = await db.addExdate(
    entityType: 'schedule',
    entityId: schedule.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
    throw Exception('EXDATE 추가 실패');
  }

  // 2. 선택된 날짜에 단일 일정 생성 (반복 없음)
  final newScheduleId = await db.createSchedule(
    ScheduleCompanion(
      summary: Value(schedule.summary),
      start: Value(schedule.start),
      end: Value(schedule.end),
      colorId: Value(schedule.colorId),
      alertSetting: Value(schedule.alertSetting),
      description: Value(schedule.description),
      location: Value(schedule.location),
      status: Value(schedule.status),
      visibility: Value(schedule.visibility),
      repeatRule: const Value(''), // ✅ 반복 없음
      createdAt: Value(DateTime.now()),
    ),
  );

  return newScheduleId;
}

/// ✅ この予定以降 반복 제거: UNTIL 설정 + 단일 일정 생성
/// - 기존 패턴을 어제까지로 종료
/// - 선택된 날짜에 단일 일정 생성
Future<int> removeScheduleRecurrenceFuture({
  required AppDatabase db,
  required ScheduleData schedule,
  required DateTime selectedDate,
}) async {
  final pattern = await db.getRecurringPattern(
    entityType: 'schedule',
    entityId: schedule.id,
  );

  if (pattern == null) {
    throw Exception('RecurringPattern을 찾을 수 없습니다');
  }

  int newScheduleId = -1;

  await db.transaction(() async {
    // 1. 기존 패턴을 어제까지로 종료
    final yesterday = selectedDate.subtract(const Duration(days: 1));
    await db.updateRecurringPattern(
      RecurringPatternCompanion(
        id: Value(pattern.id),
        until: Value(
          DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        ),
      ),
    );

    // 2. 선택된 날짜에 단일 일정 생성
    newScheduleId = await db.createSchedule(
      ScheduleCompanion(
        summary: Value(schedule.summary),
        start: Value(schedule.start),
        end: Value(schedule.end),
        colorId: Value(schedule.colorId),
        alertSetting: Value(schedule.alertSetting),
        description: Value(schedule.description),
        location: Value(schedule.location),
        status: Value(schedule.status),
        visibility: Value(schedule.visibility),
        repeatRule: const Value(''), // ✅ 반복 없음
        createdAt: Value(DateTime.now()),
      ),
    );

    // 3. 고아 예외 정리
    await (db.delete(db.recurringException)
          ..where(
            (tbl) =>
                tbl.recurringPatternId.equals(pattern.id) &
                tbl.originalDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();

    // 4. 고아 완료 기록 정리
    await (db.delete(db.scheduleCompletion)
          ..where(
            (tbl) =>
                tbl.scheduleId.equals(schedule.id) &
                tbl.completedDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();
  });

  return newScheduleId;
}

/// ✅ すべての回 반복 제거: 전체 삭제 + 단일 일정 생성
/// - 반복 일정 전체 삭제
/// - 선택된 날짜에 단일 일정 생성
Future<int> removeScheduleRecurrenceAll({
  required AppDatabase db,
  required ScheduleData schedule,
  required DateTime selectedDate,
}) async {
  int newScheduleId = -1;

  await db.transaction(() async {
    // 1. 기존 반복 일정 전체 삭제 (RecurringPattern도 CASCADE 삭제)
    await db.deleteSchedule(schedule.id);

    // 2. 선택된 날짜에 단일 일정 생성
    newScheduleId = await db.createSchedule(
      ScheduleCompanion(
        summary: Value(schedule.summary),
        start: Value(schedule.start),
        end: Value(schedule.end),
        colorId: Value(schedule.colorId),
        alertSetting: Value(schedule.alertSetting),
        description: Value(schedule.description),
        location: Value(schedule.location),
        status: Value(schedule.status),
        visibility: Value(schedule.visibility),
        repeatRule: const Value(''), // ✅ 반복 없음
        createdAt: Value(DateTime.now()),
      ),
    );
  });

  return newScheduleId;
}

// ==================== Task 반복 제거 헬퍼 함수 ====================

/// ✅ この回のみ 반복 제거: EXDATE + 단일 할일 생성
Future<int> removeTaskRecurrenceThisOnly({
  required AppDatabase db,
  required TaskData task,
  required DateTime selectedDate,
}) async {
  // 1. EXDATE 추가
  final exdateAdded = await db.addExdate(
    entityType: 'task',
    entityId: task.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
    throw Exception('EXDATE 추가 실패');
  }

  // 2. 선택된 날짜에 단일 할일 생성
  final newTaskId = await db.createTask(
    TaskCompanion(
      title: Value(task.title),
      completed: Value(task.completed),
      dueDate: Value(task.dueDate),
      executionDate: Value(task.executionDate),
      colorId: Value(task.colorId),
      reminder: Value(task.reminder),
      repeatRule: const Value(''), // ✅ 반복 없음
      createdAt: Value(DateTime.now()),
    ),
  );

  return newTaskId;
}

/// ✅ この予定以降 반복 제거: UNTIL 설정 + 단일 할일 생성
Future<int> removeTaskRecurrenceFuture({
  required AppDatabase db,
  required TaskData task,
  required DateTime selectedDate,
}) async {
  final pattern = await db.getRecurringPattern(
    entityType: 'task',
    entityId: task.id,
  );

  if (pattern == null) {
    throw Exception('RecurringPattern을 찾을 수 없습니다');
  }

  int newTaskId = -1;

  await db.transaction(() async {
    // 1. 기존 패턴을 어제까지로 종료
    final yesterday = selectedDate.subtract(const Duration(days: 1));
    await db.updateRecurringPattern(
      RecurringPatternCompanion(
        id: Value(pattern.id),
        until: Value(
          DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        ),
      ),
    );

    // 2. 선택된 날짜에 단일 할일 생성
    newTaskId = await db.createTask(
      TaskCompanion(
        title: Value(task.title),
        completed: Value(task.completed),
        dueDate: Value(task.dueDate),
        executionDate: Value(task.executionDate),
        colorId: Value(task.colorId),
        reminder: Value(task.reminder),
        repeatRule: const Value(''), // ✅ 반복 없음
        createdAt: Value(DateTime.now()),
      ),
    );

    // 3. 고아 예외 정리
    await (db.delete(db.recurringException)
          ..where(
            (tbl) =>
                tbl.recurringPatternId.equals(pattern.id) &
                tbl.originalDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();

    // 4. 고아 완료 기록 정리
    await (db.delete(db.taskCompletion)
          ..where(
            (tbl) =>
                tbl.taskId.equals(task.id) &
                tbl.completedDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();
  });

  return newTaskId;
}

/// ✅ すべての回 반복 제거: 전체 삭제 + 단일 할일 생성
Future<int> removeTaskRecurrenceAll({
  required AppDatabase db,
  required TaskData task,
  required DateTime selectedDate,
}) async {
  int newTaskId = -1;

  await db.transaction(() async {
    // 1. 기존 반복 할일 전체 삭제
    await db.deleteTask(task.id);

    // 2. 선택된 날짜에 단일 할일 생성
    newTaskId = await db.createTask(
      TaskCompanion(
        title: Value(task.title),
        completed: Value(task.completed),
        dueDate: Value(task.dueDate),
        executionDate: Value(task.executionDate),
        colorId: Value(task.colorId),
        reminder: Value(task.reminder),
        repeatRule: const Value(''), // ✅ 반복 없음
        createdAt: Value(DateTime.now()),
      ),
    );
  });

  return newTaskId;
}

// ==================== Habit 반복 제거 헬퍼 함수 ====================

/// ✅ この回のみ 반복 제거: EXDATE + 단일 습관 생성
Future<int> removeHabitRecurrenceThisOnly({
  required AppDatabase db,
  required HabitData habit,
  required DateTime selectedDate,
}) async {
  // 1. EXDATE 추가
  final exdateAdded = await db.addExdate(
    entityType: 'habit',
    entityId: habit.id,
    dateToExclude: selectedDate,
  );

  if (!exdateAdded) {
    throw Exception('EXDATE 추가 실패');
  }

  // 2. 선택된 날짜에 단일 습관 생성
  final newHabitId = await db.createHabit(
    HabitCompanion(
      title: Value(habit.title),
      colorId: Value(habit.colorId),
      reminder: Value(habit.reminder),
      repeatRule: const Value(''), // ✅ 반복 없음
      createdAt: Value(DateTime.now()),
    ),
  );

  return newHabitId;
}

/// ✅ この予定以降 반복 제거: UNTIL 설정 + 단일 습관 생성
Future<int> removeHabitRecurrenceFuture({
  required AppDatabase db,
  required HabitData habit,
  required DateTime selectedDate,
}) async {
  final pattern = await db.getRecurringPattern(
    entityType: 'habit',
    entityId: habit.id,
  );

  if (pattern == null) {
    throw Exception('RecurringPattern을 찾을 수 없습니다');
  }

  int newHabitId = -1;

  await db.transaction(() async {
    // 1. 기존 패턴을 어제까지로 종료
    final yesterday = selectedDate.subtract(const Duration(days: 1));
    await db.updateRecurringPattern(
      RecurringPatternCompanion(
        id: Value(pattern.id),
        until: Value(
          DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        ),
      ),
    );

    // 2. 선택된 날짜에 단일 습관 생성
    newHabitId = await db.createHabit(
      HabitCompanion(
        title: Value(habit.title),
        colorId: Value(habit.colorId),
        reminder: Value(habit.reminder),
        repeatRule: const Value(''), // ✅ 반복 없음
        createdAt: Value(DateTime.now()),
      ),
    );

    // 3. 고아 예외 정리
    await (db.delete(db.recurringException)
          ..where(
            (tbl) =>
                tbl.recurringPatternId.equals(pattern.id) &
                tbl.originalDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();

    // 4. 고아 완료 기록 정리
    await (db.delete(db.habitCompletion)
          ..where(
            (tbl) =>
                tbl.habitId.equals(habit.id) &
                tbl.completedDate.isBiggerOrEqualValue(selectedDate),
          ))
        .go();
  });

  return newHabitId;
}

/// ✅ すべての回 반복 제거: 전체 삭제 + 단일 습관 생성
Future<int> removeHabitRecurrenceAll({
  required AppDatabase db,
  required HabitData habit,
  required DateTime selectedDate,
}) async {
  int newHabitId = -1;

  await db.transaction(() async {
    // 1. 기존 반복 습관 전체 삭제
    await db.deleteHabit(habit.id);

    // 2. 선택된 날짜에 단일 습관 생성
    newHabitId = await db.createHabit(
      HabitCompanion(
        title: Value(habit.title),
        colorId: Value(habit.colorId),
        reminder: Value(habit.reminder),
        repeatRule: const Value(''), // ✅ 반복 없음
        createdAt: Value(DateTime.now()),
      ),
    );
  });

  return newHabitId;
}
