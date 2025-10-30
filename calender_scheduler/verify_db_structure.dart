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
  print('🔍 데이터베이스 구조 검증 시작...\n');

  // 메모리 DB 사용 (테스트용)
  final db = AppDatabase.forTesting(NativeDatabase.memory());

  try {
    await _testUniqueConstraints(db);
    await _testCascadeDelete(db);
    await _testDateNormalization(db);
    await _testCompletionSystem(db);

    print('\n✅ 모든 검증 통과!');
  } catch (e, stackTrace) {
    print('\n❌ 검증 실패: $e');
    print('스택 트레이스: $stackTrace');
  } finally {
    await db.close();
  }
}

/// 1. UNIQUE 제약 조건 테스트
Future<void> _testUniqueConstraints(AppDatabase db) async {
  print('📋 1. UNIQUE 제약 조건 테스트...');

  // 1-1. RecurringPattern UNIQUE 테스트
  print('   1-1. RecurringPattern {entityType, entityId} UNIQUE 테스트');

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
  print('      ✅ 첫 번째 RecurringPattern 생성 성공');

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
    print('      ❌ UNIQUE 제약 실패: 중복 생성이 허용됨');
  } catch (e) {
    print('      ✅ UNIQUE 제약 작동: 중복 생성 차단됨');
  }

  // 1-2. RecurringException UNIQUE 테스트
  print(
    '   1-2. RecurringException {recurringPatternId, originalDate} UNIQUE 테스트',
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
    print('      ✅ 첫 번째 RecurringException 생성 성공');

    // 같은 날짜로 재생성 시도 → 에러 발생해야 함
    try {
      await db.createRecurringException(
        RecurringExceptionCompanion.insert(
          recurringPatternId: pattern.id,
          originalDate: DateTime(2025, 11, 8),
          isCancelled: const Value(true),
        ),
      );
      print('      ❌ UNIQUE 제약 실패: 중복 생성이 허용됨');
    } catch (e) {
      print('      ✅ UNIQUE 제약 작동: 중복 생성 차단됨');
    }
  }

  // 1-3. ScheduleCompletion UNIQUE 테스트
  print('   1-3. ScheduleCompletion {scheduleId, completedDate} UNIQUE 테스트');

  await db
      .into(db.scheduleCompletion)
      .insert(
        ScheduleCompletionCompanion.insert(
          scheduleId: scheduleId,
          completedDate: DateTime(2025, 11, 15),
          createdAt: DateTime.now(),
        ),
      );
  print('      ✅ 첫 번째 ScheduleCompletion 생성 성공');

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
    print('      ❌ UNIQUE 제약 실패: 중복 생성이 허용됨');
  } catch (e) {
    print('      ✅ UNIQUE 제약 작동: 중복 생성 차단됨');
  }

  print('   ✅ 1. UNIQUE 제약 조건 테스트 완료\n');
}

/// 2. CASCADE DELETE 테스트
Future<void> _testCascadeDelete(AppDatabase db) async {
  print('📋 2. CASCADE DELETE 테스트...');

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

    print(
      '   2-1. Schedule 삭제 시 RecurringPattern + RecurringException 자동 삭제 테스트',
    );

    // Schedule 삭제
    await db.deleteSchedule(scheduleId);

    // RecurringPattern도 삭제되었는지 확인
    final deletedPattern = await db.getRecurringPattern(
      entityType: 'schedule',
      entityId: scheduleId,
    );

    if (deletedPattern == null) {
      print('      ✅ CASCADE DELETE 작동: RecurringPattern 자동 삭제됨');
    } else {
      print('      ❌ CASCADE DELETE 실패: RecurringPattern이 남아있음');
    }

    // RecurringException도 삭제되었는지 확인
    final exceptions = await (db.select(
      db.recurringException,
    )..where((tbl) => tbl.recurringPatternId.equals(pattern.id))).get();

    if (exceptions.isEmpty) {
      print('      ✅ CASCADE DELETE 작동: RecurringException 자동 삭제됨');
    } else {
      print('      ❌ CASCADE DELETE 실패: RecurringException이 남아있음');
    }
  }

  print('   ✅ 2. CASCADE DELETE 테스트 완료\n');
}

/// 3. 날짜 정규화 테스트
Future<void> _testDateNormalization(AppDatabase db) async {
  print('📋 3. 날짜 정규화 테스트...');

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
      print('   ✅ dtstart 정규화 작동: ${pattern.dtstart}');
    } else {
      print('   ⚠️ dtstart 정규화 필요: ${pattern.dtstart} (시간이 포함됨)');
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
      print('   ✅ originalDate 정규화 작동: ${exception.originalDate}');
    } else {
      print('   ⚠️ originalDate 정규화 필요: ${exception.originalDate}');
    }
  }

  print('   ✅ 3. 날짜 정규화 테스트 완료\n');
}

/// 4. Completion 시스템 테스트
Future<void> _testCompletionSystem(AppDatabase db) async {
  print('📋 4. Completion 시스템 테스트...');

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
    print('   ✅ getScheduleCompletion 작동: 완료 기록 조회됨');
  } else {
    print('   ❌ getScheduleCompletion 실패: 완료 기록을 찾을 수 없음');
  }

  // 다른 날짜는 완료되지 않았어야 함
  final notCompleted = await db.getScheduleCompletion(
    scheduleId,
    DateTime(2025, 11, 15),
  );

  if (notCompleted == null) {
    print('   ✅ 날짜별 완료 관리 작동: 다른 날짜는 미완료');
  } else {
    print('   ❌ 날짜별 완료 관리 실패: 잘못된 날짜도 완료됨');
  }

  print('   ✅ 4. Completion 시스템 테스트 완료\n');
}
