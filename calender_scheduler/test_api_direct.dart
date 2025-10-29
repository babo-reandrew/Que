import 'package:rrule/rrule.dart';

void main() {
  print('✅ _parseRRuleToApi 검증 (RecurrenceRule API 직접 사용)\n');
  print('=' * 60);

  // 테스트 1: 금요일 RRULE을 금요일부터 시작
  print('\n📅 테스트 1: BYDAY=FR (금요일), DTSTART=2025-01-03 (금요일)');
  testCase(DateTime.friday, DateTime(2025, 1, 3)); // 금요일

  // 테스트 2: 목요일 RRULE을 목요일부터 시작
  print('\n📅 테스트 2: BYDAY=TH (목요일), DTSTART=2025-01-02 (목요일)');
  testCase(DateTime.thursday, DateTime(2025, 1, 2)); // 목요일

  // 테스트 3: 월요일 RRULE을 월요일부터 시작
  print('\n📅 테스트 3: BYDAY=MO (월요일), DTSTART=2024-12-30 (월요일)');
  testCase(DateTime.monday, DateTime(2024, 12, 30)); // 월요일

  print('\n${'=' * 60}');
}

void testCase(int weekdayConstant, DateTime dtstart) {
  try {
    print('  입력:');
    print('    RecurrenceRule API: ByWeekDayEntry($weekdayConstant)');
    print(
      '    DTSTART: ${formatDate(dtstart)} (${getWeekdayName(dtstart.weekday)})',
    );

    // RecurrenceRule API로 직접 생성 (버그 없음!)
    final recurrenceRule = RecurrenceRule(
      frequency: Frequency.weekly,
      byWeekDays: [ByWeekDayEntry(weekdayConstant)],
    );

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
        print('  ✅ 정확함: ByWeekDayEntry($weekdayConstant)와 생성된 요일이 일치!');
      } else {
        final offset = firstWeekday - expectedWeekday;
        print(
          '  ❌ 오류: 예상 ${getWeekdayName(expectedWeekday)}인데 ${getWeekdayName(firstWeekday)}로 생성됨 (오프셋: +$offset일)',
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

String pad(int n) => n.toString().padLeft(2, '0');
