/// 🎯 반복 이벤트 시간 보존 테스트 스크립트
///
/// 실행: dart run test_recurring_time_preservation.dart
///
/// 테스트 시나리오:
/// 1. "매일 오전 8시 운동" 반복 일정 생성
/// 2. RecurringPattern에 RRULE 저장 확인
/// 3. 디테일뷰에서 모든 날짜에 정확히 8:00 표시 확인
/// 4. 월뷰에서 시간 정보 유지 확인

import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'lib/Database/schedule_database.dart';
import 'lib/model/schedule.dart';
import 'lib/model/entities.dart';

void main() async {
  print('🎯 반복 이벤트 시간 보존 테스트 시작\n');

  // 테스트용 인메모리 DB
  final db = AppDatabase.forTesting(NativeDatabase.memory());

  // ============================================================================
  // 테스트 1: "매일 오전 8시 운동" 반복 일정 생성
  // ============================================================================
  print('📝 테스트 1: 반복 일정 생성');

  final startTime = DateTime(2025, 11, 1, 8, 0); // 2025-11-01 08:00
  final endTime = DateTime(2025, 11, 1, 9, 0); // 2025-11-01 09:00

  final scheduleId = await db.createSchedule(
    ScheduleCompanion.insert(
      summary: '아침 운동',
      start: startTime,
      end: endTime,
      colorId: 'blue',
      description: const Value('매일 아침 운동'),
      timezone: const Value('Asia/Seoul'),
    ),
  );

  print('  ✅ Schedule 생성 완료 (ID: $scheduleId)');

  // Schedule이 originalHour/originalMinute를 자동으로 저장했는지 확인
  final schedule = await db.getSchedule(scheduleId);
  print('  📋 저장된 Schedule:');
  print('     - summary: ${schedule?.summary}');
  print('     - start: ${schedule?.start}');
  print('     - originalHour: ${schedule?.originalHour}');
  print('     - originalMinute: ${schedule?.originalMinute}');
  print('     - timezone: ${schedule?.timezone}');

  if (schedule?.originalHour == 8 && schedule?.originalMinute == 0) {
    print('  ✅ 원본 시간 자동 저장 성공! (8:00)\n');
  } else {
    print('  ❌ 원본 시간 저장 실패!\n');
    return;
  }

  // RecurringPattern 생성
  print('📝 테스트 2: RecurringPattern 생성 (매일 반복)');

  await db.createRecurringPattern(
    RecurringPatternCompanion.insert(
      entityType: 'schedule',
      entityId: scheduleId,
      rrule: 'FREQ=DAILY',
      dtstart: startTime,
      timezone: const Value('Asia/Seoul'),
    ),
  );

  final pattern = await db.getRecurringPattern(
    entityType: 'schedule',
    entityId: scheduleId,
  );

  print('  ✅ RecurringPattern 생성 완료');
  print('     - RRULE: ${pattern?.rrule}');
  print('     - DTSTART: ${pattern?.dtstart}');
  print('     - Timezone: ${pattern?.timezone}\n');

  // ============================================================================
  // 테스트 3: 디테일뷰 - 특정 날짜의 반복 인스턴스 조회
  // ============================================================================
  print('📝 테스트 3: 디테일뷰 - 11월 5일 인스턴스 확인');

  final nov5 = DateTime(2025, 11, 5);
  final schedulesOnNov5 = await db.watchSchedulesWithRepeat(nov5).first;

  if (schedulesOnNov5.isNotEmpty) {
    final instance = schedulesOnNov5.first;
    print('  ✅ 인스턴스 생성됨:');
    print('     - summary: ${instance.summary}');
    print('     - start: ${instance.start}');
    print(
      '     - 시간: ${instance.start.hour}:${instance.start.minute.toString().padLeft(2, '0')}',
    );

    if (instance.start.hour == 8 && instance.start.minute == 0) {
      print('  ✅ 시간 보존 성공! (8:00으로 정확히 복원됨)\n');
    } else {
      print(
        '  ❌ 시간 보존 실패! (기대: 8:00, 실제: ${instance.start.hour}:${instance.start.minute})\n',
      );
    }
  } else {
    print('  ❌ 인스턴스 생성 실패!\n');
  }

  // ============================================================================
  // 테스트 4: 월뷰 - 한 달치 인스턴스 확인
  // ============================================================================
  print('📝 테스트 4: 월뷰 - 11월 1일~7일 인스턴스 확인');

  for (int day = 1; day <= 7; day++) {
    final date = DateTime(2025, 11, day);
    final instances = await db.watchSchedulesWithRepeat(date).first;

    if (instances.isNotEmpty) {
      final inst = instances.first;
      final timeStr =
          '${inst.start.hour}:${inst.start.minute.toString().padLeft(2, '0')}';
      print('  📅 11/$day → $timeStr (${inst.summary})');

      if (inst.start.hour != 8 || inst.start.minute != 0) {
        print('     ❌ 시간 불일치!');
      }
    } else {
      print('  📅 11/$day → ❌ 인스턴스 없음');
    }
  }

  print('\n🎉 모든 테스트 완료!');

  // DB 닫기
  await db.close();
}
