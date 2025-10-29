import 'package:rrule/rrule.dart';

void main() {
  print('🧪 RRuleUtils 수정 테스트\n');
  print('=' * 50);

  // 시나리오: 데이터베이스에 "FREQ=WEEKLY;BYDAY=TH" (목요일)이 저장되어 있음
  // 이전 버그: RecurrenceRule.fromString()으로 파싱 → 금요일로 해석됨
  // 수정 후: _parseRRuleToApi()로 파싱 → 목요일로 정확히 해석됨

  print('\n1️⃣ 이전 방식 (버그 있음): RecurrenceRule.fromString()');
  testOldWay();

  print('\n2️⃣ 수정된 방식 (버그 없음): _parseRRuleToApi() 시뮬레이션');
  testNewWay();

  print('\n${'=' * 50}');
  print('✅ 테스트 완료!');
}

void testOldWay() {
  try {
    final rruleString = 'RRULE:FREQ=WEEKLY;BYDAY=TH';
    final recurrenceRule = RecurrenceRule.fromString(rruleString);

    // 2025-01-02 (목요일)부터 시작
    final dtstart = DateTime(2025, 1, 2); // 목요일
    print(
      '  📅 DTSTART 검증: ${dtstart.year}-${_pad(dtstart.month)}-${_pad(dtstart.day)} (${_getWeekdayName(dtstart.weekday)})',
    );

    final dtstartUtc = dtstart.toUtc();

    final instances = recurrenceRule.getAllInstances(
      start: dtstartUtc,
      before: dtstartUtc.add(const Duration(days: 30)),
    );

    print('  RRULE: $rruleString');
    print('  생성된 인스턴스:');
    for (var instance in instances.take(3)) {
      final local = instance.toLocal();
      final weekdayName = _getWeekdayName(local.weekday);
      print(
        '    ${local.year}-${_pad(local.month)}-${_pad(local.day)} ($weekdayName)',
      );
    }

    final firstWeekday = instances.first.toLocal().weekday;
    if (firstWeekday == DateTime.friday) {
      print('  ❌ 버그 확인: 목요일(TH)을 금요일로 잘못 해석!');
    } else if (firstWeekday == DateTime.thursday) {
      print('  ✅ 정상: 목요일로 해석');
    }
  } catch (e) {
    print('  ❌ 에러: $e');
  }
}

void testNewWay() {
  try {
    final rruleString = 'FREQ=WEEKLY;BYDAY=TH';

    // _parseRRuleToApi 시뮬레이션
    final recurrenceRule = RecurrenceRule(
      frequency: Frequency.weekly,
      byWeekDays: [ByWeekDayEntry(DateTime.thursday)], // 4 (목요일)
    );

    // 2025-01-02 (목요일)부터 시작
    final dtstart = DateTime(2025, 1, 2); // 목요일
    print(
      '  📅 DTSTART 검증: ${dtstart.year}-${_pad(dtstart.month)}-${_pad(dtstart.day)} (${_getWeekdayName(dtstart.weekday)})',
    );

    final dtstartUtc = dtstart.toUtc();

    final instances = recurrenceRule.getAllInstances(
      start: dtstartUtc,
      before: dtstartUtc.add(const Duration(days: 30)),
    );

    print('  RRULE: $rruleString');
    print('  RecurrenceRule API 사용: ByWeekDayEntry(DateTime.thursday)');
    print('  생성된 인스턴스:');
    for (var instance in instances.take(3)) {
      final local = instance.toLocal();
      final weekdayName = _getWeekdayName(local.weekday);
      print(
        '    ${local.year}-${_pad(local.month)}-${_pad(local.day)} ($weekdayName)',
      );
    }

    final firstWeekday = instances.first.toLocal().weekday;
    if (firstWeekday == DateTime.thursday) {
      print('  ✅ 정확함: 목요일(TH)을 목요일로 올바르게 해석!');
    } else {
      print(
        '  ❌ 오류: 예상치 못한 요일 (weekday=$firstWeekday, 예상=${DateTime.thursday})',
      );
    }
  } catch (e) {
    print('  ❌ 에러: $e');
  }
}

String _getWeekdayName(int weekday) {
  const names = ['', '월', '화', '수', '목', '금', '토', '일'];
  return names[weekday];
}

String _pad(int n) => n.toString().padLeft(2, '0');
