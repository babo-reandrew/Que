import 'package:rrule/rrule.dart';

void main() {
  print('🔍 RecurrenceRule.fromString() 버그 재검증\n');
  print('=' * 60);

  // 테스트 1: 금요일 RRULE을 금요일부터 시작
  print('\n📅 테스트 1: BYDAY=FR (금요일), DTSTART=2025-01-03 (금요일)');
  testCase('RRULE:FREQ=WEEKLY;BYDAY=FR', DateTime(2025, 1, 3)); // 금요일

  // 테스트 2: 목요일 RRULE을 목요일부터 시작
  print('\n📅 테스트 2: BYDAY=TH (목요일), DTSTART=2025-01-02 (목요일)');
  testCase('RRULE:FREQ=WEEKLY;BYDAY=TH', DateTime(2025, 1, 2)); // 목요일

  // 테스트 3: 월요일 RRULE을 월요일부터 시작
  print('\n📅 테스트 3: BYDAY=MO (월요일), DTSTART=2024-12-30 (월요일)');
  testCase('RRULE:FREQ=WEEKLY;BYDAY=MO', DateTime(2024, 12, 30)); // 월요일

  print('\n${'=' * 60}');
}

void testCase(String rruleString, DateTime dtstart) {
  try {
    print('  입력:');
    print('    RRULE: $rruleString');
    print(
      '    DTSTART: ${formatDate(dtstart)} (${getWeekdayName(dtstart.weekday)})',
    );

    final recurrenceRule = RecurrenceRule.fromString(rruleString);
    final dtstartUtc = dtstart.toUtc();

    // after를 dtstart - 1초로 설정하여 dtstart 포함
    final afterUtc = dtstartUtc.subtract(const Duration(seconds: 1));

    final instances = recurrenceRule.getAllInstances(
      start: dtstartUtc,
      after: afterUtc,
      before: dtstartUtc.add(const Duration(days: 21)),
    );

    print('  결과:');
    for (var instance in instances.take(3)) {
      final local = instance.toLocal();
      final weekdayName = getWeekdayName(local.weekday);
      print('    ${formatDate(local)} ($weekdayName)');
    }

    if (instances.isNotEmpty) {
      final firstWeekday = instances.first.toLocal().weekday;
      final expectedWeekday = dtstart.weekday;

      if (firstWeekday == expectedWeekday) {
        print('  ✅ 정상: BYDAY와 생성된 요일이 일치');
      } else {
        final offset = firstWeekday - expectedWeekday;
        print(
          '  ❌ 버그: BYDAY=${getWeekdayCode(expectedWeekday)}인데 ${getWeekdayName(firstWeekday)}로 생성됨 (오프셋: +$offset일)',
        );
      }
    }
  } catch (e) {
    print('  ❌ 에러: $e');
  }
}

String formatDate(DateTime dt) {
  return '${dt.year}-${pad(dt.month)}-${pad(dt.day)}';
}

String getWeekdayName(int weekday) {
  const names = ['', '월', '화', '수', '목', '금', '토', '일'];
  return names[weekday];
}

String getWeekdayCode(int weekday) {
  const codes = ['', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  return codes[weekday];
}

String pad(int n) => n.toString().padLeft(2, '0');
