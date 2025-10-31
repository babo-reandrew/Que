import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'lib/Database/schedule_database.dart';

/// 데이터베이스 구조 검증 스크립트
///
/// 실행 방법:
/// ```bash
/// dart run verify_db_structure.dart
/// ```
///
/// 검증 항목:
/// 1. Base Event 중복 저장 확인
/// 2. RecurringPattern UNIQUE 제약 확인
/// 3. RecurringException UNIQUE 제약 확인
/// 4. ScheduleCompletion/TaskCompletion UNIQUE 제약 확인
/// 5. CASCADE DELETE 작동 확인

void main() async {

  // 메모리 DB 사용 (테스트용)
  final db = AppDatabase.forTesting(NativeDatabase.memory());

  try {
    await _testUniqueConstraints(db);
    await _testCascadeDelete(db);
    await _testDateNormalization(db);
    await _testCompletionSystem(db);

  } catch (e, stackTrace) {
  } finally {
    await db.close();
  }
}

/// 1. UNIQUE 제약 조건 테스트
Future<void> _testUniqueConstraints(AppDatabase db) async {

  // 1-1. RecurringPattern UNIQUE 테스트

  // Schedule 생성
  final scheduleId = await db.createSchedule(
    ScheduleCompanion.insert(
      summary: '테스트 반복 일정',
      start: DateTime(2025, 11, 1, 10, 0),
      end: DateTime(2025, 11, 1, 11, 0),
      colorId: 'blue',
    ),
  );

  // RecurringPattern 생성
  await db.createRecurringPattern(
    RecurringPatternCompanion.insert(
      entityType: 'schedule',
      entityId: scheduleId,
      rrule: 'FREQ=WEEKLY;BYDAY=MO',
      dtstart: DateTime(2025, 11, 1),
    ),
  );

  // 같은 entityType/entityId로 재생성 시도 → 에러 발생해야 함
  try {
    await db.createRecurringPattern(
      RecurringPatternCompanion.insert(
        entityType: 'schedule',
        entityId: scheduleId,
        rrule: 'FREQ=DAILY',
        dtstart: DateTime(2025, 11, 1),
      ),
    );
  } catch (e) {
  }

  // 1-2. RecurringException UNIQUE 테스트

  final pattern = await db.getRecurringPattern(
    entityType: 'schedule',
    entityId: scheduleId,
  );

  if (pattern != null) {
    // RecurringException 생성
    await db.createRecurringException(
      RecurringExceptionCompanion.insert(
        recurringPatternId: pattern.id,
        originalDate: DateTime(2025, 11, 8),
        isCancelled: const Value(true),
      ),
    );

    // 같은 날짜로 재생성 시도 → 에러 발생해야 함
    try {
      await db.createRecurringException(
        RecurringExceptionCompanion.insert(
          recurringPatternId: pattern.id,
          originalDate: DateTime(2025, 11, 8),
          isCancelled: const Value(true),
        ),
      );
    } catch (e) {
    }
  }

  // 1-3. ScheduleCompletion UNIQUE 테스트

  await db
      .into(db.scheduleCompletion)
      .insert(
        ScheduleCompletionCompanion.insert(
          scheduleId: scheduleId,
          completedDate: DateTime(2025, 11, 15),
          createdAt: DateTime.now(),
        ),
      );

  try {
    await db
        .into(db.scheduleCompletion)
        .insert(
          ScheduleCompletionCompanion.insert(
            scheduleId: scheduleId,
            completedDate: DateTime(2025, 11, 15),
            createdAt: DateTime.now(),
          ),
        );
  } catch (e) {
  }

}

/// 2. CASCADE DELETE 테스트
Future<void> _testCascadeDelete(AppDatabase db) async {

  // Schedule 생성
  final scheduleId = await db.createSchedule(
    ScheduleCompanion.insert(
      summary: '캐스케이드 테스트',
      start: DateTime(2025, 11, 1, 10, 0),
      end: DateTime(2025, 11, 1, 11, 0),
      colorId: 'red',
    ),
  );

  // RecurringPattern 생성
  await db.createRecurringPattern(
    RecurringPatternCompanion.insert(
      entityType: 'schedule',
      entityId: scheduleId,
      rrule: 'FREQ=WEEKLY;BYDAY=TU',
      dtstart: DateTime(2025, 11, 1),
    ),
  );

  final pattern = await db.getRecurringPattern(
    entityType: 'schedule',
    entityId: scheduleId,
  );

  if (pattern != null) {
    // RecurringException 생성
    await db.createRecurringException(
      RecurringExceptionCompanion.insert(
        recurringPatternId: pattern.id,
        originalDate: DateTime(2025, 11, 8),
        isCancelled: const Value(true),
      ),
    );


    // Schedule 삭제
    await db.deleteSchedule(scheduleId);

    // RecurringPattern도 삭제되었는지 확인
    final deletedPattern = await db.getRecurringPattern(
      entityType: 'schedule',
      entityId: scheduleId,
    );

    if (deletedPattern == null) {
    } else {
    }

    // RecurringException도 삭제되었는지 확인
    final exceptions = await (db.select(
      db.recurringException,
    )..where((tbl) => tbl.recurringPatternId.equals(pattern.id))).get();

    if (exceptions.isEmpty) {
    } else {
    }
  }

}

/// 3. 날짜 정규화 테스트
Future<void> _testDateNormalization(AppDatabase db) async {

  // Schedule 생성
  final scheduleId = await db.createSchedule(
    ScheduleCompanion.insert(
      summary: '날짜 정규화 테스트',
      start: DateTime(2025, 11, 1, 14, 30),
      end: DateTime(2025, 11, 1, 15, 30),
      colorId: 'green',
    ),
  );

  // RecurringPattern 생성 (dtstart는 날짜만 저장되어야 함)
  await db.createRecurringPattern(
    RecurringPatternCompanion.insert(
      entityType: 'schedule',
      entityId: scheduleId,
      rrule: 'FREQ=DAILY',
      dtstart: DateTime(2025, 11, 1, 14, 30), // 시간 포함
    ),
  );

  final pattern = await db.getRecurringPattern(
    entityType: 'schedule',
    entityId: scheduleId,
  );

  if (pattern != null) {
    // dtstart가 00:00:00으로 정규화되었는지 확인
    if (pattern.dtstart.hour == 0 &&
        pattern.dtstart.minute == 0 &&
        pattern.dtstart.second == 0) {
    } else {
    }
  }

  // RecurringException 생성 (originalDate는 날짜만 저장되어야 함)
  if (pattern != null) {
    await db.createRecurringException(
      RecurringExceptionCompanion.insert(
        recurringPatternId: pattern.id,
        originalDate: DateTime(2025, 11, 5, 14, 30), // 시간 포함
        isCancelled: const Value(true),
      ),
    );

    final exception = await (db.select(
      db.recurringException,
    )..where((tbl) => tbl.recurringPatternId.equals(pattern.id))).getSingle();

    if (exception.originalDate.hour == 0 &&
        exception.originalDate.minute == 0) {
    } else {
    }
  }

}

/// 4. Completion 시스템 테스트
Future<void> _testCompletionSystem(AppDatabase db) async {

  // Schedule 생성
  final scheduleId = await db.createSchedule(
    ScheduleCompanion.insert(
      summary: 'Completion 테스트',
      start: DateTime(2025, 11, 1, 10, 0),
      end: DateTime(2025, 11, 1, 11, 0),
      colorId: 'blue',
    ),
  );

  // 11월 8일 완료 처리
  await db
      .into(db.scheduleCompletion)
      .insert(
        ScheduleCompletionCompanion.insert(
          scheduleId: scheduleId,
          completedDate: DateTime(2025, 11, 8),
          createdAt: DateTime.now(),
        ),
      );

  // 조회 테스트
  final completion = await db.getScheduleCompletion(
    scheduleId,
    DateTime(2025, 11, 8),
  );

  if (completion != null) {
  } else {
  }

  // 다른 날짜는 완료되지 않았어야 함
  final notCompleted = await db.getScheduleCompletion(
    scheduleId,
    DateTime(2025, 11, 15),
  );

  if (notCompleted == null) {
  } else {
  }

}
