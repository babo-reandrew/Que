import 'package:drift/drift.dart' hide Column;
import '../Database/schedule_database.dart';
import '../utils/rrule_utils.dart';

/// 반복 일정 서비스
/// 이거를 설정하고 → 반복 규칙을 기반으로 동적으로 인스턴스를 생성해서
/// 이거를 해서 → 특정 날짜 범위의 일정/할일/습관을 조회하고
/// 이거는 이래서 → 메모리 효율적으로 무한 반복도 지원한다

class RecurringEventService {
  final AppDatabase _db;

  RecurringEventService(this._db);

  /// 반복 일정 생성 (일정 + 반복 규칙)
  /// 이거를 설정하고 → 일정과 반복 규칙을 함께 생성해서
  /// 이거를 해서 → Base Event 1개 + RRULE 1개로 저장한다
  Future<int> createRecurringSchedule({
    required ScheduleCompanion scheduleData,
    required String rrule,
    DateTime? until,
    int? count,
    String timezone = 'UTC',
  }) async {
    // 1. Base Event 생성
    final scheduleId = await _db.createSchedule(scheduleData);

    // 2. 반복 규칙 생성
    await _db.createRecurringPattern(
      RecurringPatternCompanion.insert(
        entityType: 'schedule',
        entityId: scheduleId,
        rrule: rrule,
        dtstart: scheduleData.start.value,
        until: Value(until),
        count: Value(count),
        timezone: Value(timezone),
      ),
    );

    return scheduleId;
  }

  /// 반복 할일 생성 (할일 + 반복 규칙)
  Future<int> createRecurringTask({
    required TaskCompanion taskData,
    required String rrule,
    DateTime? until,
    int? count,
    String timezone = 'UTC',
  }) async {
    // 1. Base Task 생성
    final taskId = await _db.createTask(taskData);

    // 2. 반복 규칙 생성
    final executionDate = taskData.executionDate.value ?? DateTime.now();
    await _db.createRecurringPattern(
      RecurringPatternCompanion.insert(
        entityType: 'task',
        entityId: taskId,
        rrule: rrule,
        dtstart: executionDate,
        until: Value(until),
        count: Value(count),
        timezone: Value(timezone),
      ),
    );

    return taskId;
  }

  /// 반복 습관 생성 (습관 + 반복 규칙)
  Future<int> createRecurringHabit({
    required HabitCompanion habitData,
    required String rrule,
    DateTime? until,
    int? count,
    String timezone = 'UTC',
  }) async {
    // 1. Base Habit 생성
    final habitId = await _db.createHabit(habitData);

    // 2. 반복 규칙 생성
    await _db.createRecurringPattern(
      RecurringPatternCompanion.insert(
        entityType: 'habit',
        entityId: habitId,
        rrule: rrule,
        dtstart: habitData.createdAt.value,
        until: Value(until),
        count: Value(count),
        timezone: Value(timezone),
      ),
    );

    return habitId;
  }

  /// 특정 날짜 범위의 반복 일정 인스턴스 생성
  /// 이거를 설정하고 → Base Event + RRULE을 읽어서
  /// 이거를 해서 → 런타임에 동적으로 발생 날짜를 계산하고
  /// 이거는 이래서 → 예외(수정/삭제)를 적용하여 최종 목록을 반환한다
  Future<List<ScheduleInstance>> getScheduleInstances({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final instances = <ScheduleInstance>[];

    // 1. 모든 일정 조회 (일반 + 반복 모두)
    final schedules = await _db.getSchedules();

    for (final schedule in schedules) {
      // 2. 반복 규칙 확인
      final pattern = await _db.getRecurringPattern(
        entityType: 'schedule',
        entityId: schedule.id,
      );

      if (pattern == null) {
        // 일반 일정: 범위 내에 있으면 추가
        if (schedule.start.isBefore(rangeEnd) &&
            schedule.end.isAfter(rangeStart)) {
          instances.add(
            ScheduleInstance(
              baseSchedule: schedule,
              occurrenceDate: schedule.start,
              isModified: false,
            ),
          );
        }
      } else {
        // 반복 일정: RRULE로 인스턴스 생성
        final dates = RRuleUtils.generateInstancesFromPattern(
          pattern: pattern,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
        );

        // 3. 예외 조회 (수정/삭제된 인스턴스)
        final exceptions = await _db.getRecurringExceptions(pattern.id);
        final exceptionMap = {for (var e in exceptions) e.originalDate: e};

        for (final date in dates) {
          final exception = exceptionMap[date];

          if (exception != null) {
            // 예외 처리
            if (exception.isCancelled) {
              // 취소됨: 스킵
              continue;
            } else if (exception.isRescheduled) {
              // 시간 변경: 새 시간으로 추가
              instances.add(
                ScheduleInstance(
                  baseSchedule: schedule,
                  occurrenceDate: exception.newStartDate!,
                  originalDate: date,
                  isModified: true,
                  exception: exception,
                ),
              );
            } else {
              // 내용 변경: 원래 시간 + 수정된 내용
              instances.add(
                ScheduleInstance(
                  baseSchedule: schedule,
                  occurrenceDate: date,
                  isModified: true,
                  exception: exception,
                ),
              );
            }
          } else {
            // 정상 발생: Base Event 그대로
            instances.add(
              ScheduleInstance(
                baseSchedule: schedule,
                occurrenceDate: date,
                isModified: false,
              ),
            );
          }
        }
      }
    }

    // 4. 시작 시간 순 정렬
    instances.sort((a, b) => a.occurrenceDate.compareTo(b.occurrenceDate));

    return instances;
  }

  /// 특정 날짜의 반복 할일 인스턴스 생성
  Future<List<TaskInstance>> getTaskInstances({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final instances = <TaskInstance>[];

    // 1. 모든 할일 조회
    final tasks = await _db.watchTasks().first;

    for (final task in tasks) {
      // 2. 반복 규칙 확인
      final pattern = await _db.getRecurringPattern(
        entityType: 'task',
        entityId: task.id,
      );

      if (pattern == null) {
        // 일반 할일: executionDate가 범위 내에 있으면 추가
        if (task.executionDate != null &&
            task.executionDate!.isBefore(rangeEnd) &&
            task.executionDate!.isAfter(rangeStart)) {
          instances.add(
            TaskInstance(
              baseTask: task,
              occurrenceDate: task.executionDate!,
              isModified: false,
            ),
          );
        }
      } else {
        // 반복 할일: RRULE로 인스턴스 생성
        final dates = RRuleUtils.generateInstancesFromPattern(
          pattern: pattern,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
        );

        final exceptions = await _db.getRecurringExceptions(pattern.id);
        final exceptionMap = {for (var e in exceptions) e.originalDate: e};

        for (final date in dates) {
          final exception = exceptionMap[date];

          if (exception != null && exception.isCancelled) {
            continue;
          }

          instances.add(
            TaskInstance(
              baseTask: task,
              occurrenceDate: date,
              isModified: exception != null,
              exception: exception,
            ),
          );
        }
      }
    }

    instances.sort((a, b) => a.occurrenceDate.compareTo(b.occurrenceDate));

    return instances;
  }

  /// 특정 날짜의 반복 습관 인스턴스 생성
  Future<List<HabitInstance>> getHabitInstances({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final instances = <HabitInstance>[];

    // 1. 모든 습관 조회
    final habits = await _db.watchHabits().first;

    for (final habit in habits) {
      // 2. 반복 규칙 확인
      final pattern = await _db.getRecurringPattern(
        entityType: 'habit',
        entityId: habit.id,
      );

      if (pattern != null) {
        // 반복 습관: RRULE로 인스턴스 생성
        final dates = RRuleUtils.generateInstancesFromPattern(
          pattern: pattern,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
        );

        for (final date in dates) {
          instances.add(HabitInstance(baseHabit: habit, occurrenceDate: date));
        }
      }
    }

    instances.sort((a, b) => a.occurrenceDate.compareTo(b.occurrenceDate));

    return instances;
  }

  /// 단일 인스턴스 삭제 (EXDATE 또는 Exception 생성)
  /// 이거를 설정하고 → 특정 발생을 취소 처리해서
  /// 이거를 해서 → RecurringException에 isCancelled=true로 저장한다
  Future<bool> cancelSingleInstance({
    required String entityType,
    required int entityId,
    required DateTime originalDate,
  }) async {
    // 1. 반복 규칙 조회
    final pattern = await _db.getRecurringPattern(
      entityType: entityType,
      entityId: entityId,
    );

    if (pattern == null) {
      return false;
    }

    // 2. 예외 생성 (취소)
    await _db.createRecurringException(
      RecurringExceptionCompanion.insert(
        recurringPatternId: pattern.id,
        originalDate: originalDate,
        isCancelled: const Value(true),
      ),
    );

    return true;
  }

  /// 단일 인스턴스 시간 변경 (Reschedule)
  Future<bool> rescheduleSingleInstance({
    required String entityType,
    required int entityId,
    required DateTime originalDate,
    required DateTime newStartDate,
    required DateTime newEndDate,
  }) async {
    final pattern = await _db.getRecurringPattern(
      entityType: entityType,
      entityId: entityId,
    );

    if (pattern == null) return false;

    await _db.createRecurringException(
      RecurringExceptionCompanion.insert(
        recurringPatternId: pattern.id,
        originalDate: originalDate,
        isRescheduled: const Value(true),
        newStartDate: Value(newStartDate),
        newEndDate: Value(newEndDate),
      ),
    );

    return true;
  }

  /// 단일 인스턴스 내용 변경
  Future<bool> modifySingleInstance({
    required String entityType,
    required int entityId,
    required DateTime originalDate,
    String? modifiedTitle,
    String? modifiedDescription,
    String? modifiedLocation,
    String? modifiedColorId,
  }) async {
    final pattern = await _db.getRecurringPattern(
      entityType: entityType,
      entityId: entityId,
    );

    if (pattern == null) return false;

    await _db.createRecurringException(
      RecurringExceptionCompanion.insert(
        recurringPatternId: pattern.id,
        originalDate: originalDate,
        modifiedTitle: Value(modifiedTitle),
        modifiedDescription: Value(modifiedDescription),
        modifiedLocation: Value(modifiedLocation),
        modifiedColorId: Value(modifiedColorId),
      ),
    );

    return true;
  }
}

/// 일정 인스턴스 (동적 생성된 발생)
class ScheduleInstance {
  final ScheduleData baseSchedule;
  final DateTime occurrenceDate;
  final DateTime? originalDate;
  final bool isModified;
  final RecurringExceptionData? exception;

  ScheduleInstance({
    required this.baseSchedule,
    required this.occurrenceDate,
    this.originalDate,
    required this.isModified,
    this.exception,
  });

  /// 표시할 제목 (수정된 경우 수정된 제목 사용)
  String get displayTitle => exception?.modifiedTitle ?? baseSchedule.summary;

  /// 표시할 설명
  String get displayDescription =>
      exception?.modifiedDescription ?? baseSchedule.description;

  /// 표시할 장소
  String get displayLocation =>
      exception?.modifiedLocation ?? baseSchedule.location;

  /// 표시할 색상
  String get displayColorId =>
      exception?.modifiedColorId ?? baseSchedule.colorId;
}

/// 할일 인스턴스
class TaskInstance {
  final TaskData baseTask;
  final DateTime occurrenceDate;
  final bool isModified;
  final RecurringExceptionData? exception;

  TaskInstance({
    required this.baseTask,
    required this.occurrenceDate,
    required this.isModified,
    this.exception,
  });

  String get displayTitle => exception?.modifiedTitle ?? baseTask.title;
  String get displayColorId => exception?.modifiedColorId ?? baseTask.colorId;
}

/// 습관 인스턴스
class HabitInstance {
  final HabitData baseHabit;
  final DateTime occurrenceDate;

  HabitInstance({required this.baseHabit, required this.occurrenceDate});
}
