import 'package:rrule/rrule.dart';

void main() {
  print('🔧 -1 오프셋 보정 테스트\n');
  print('=' * 60);

  // 테스트 1: 금요일 (5 → 4로 보정)
  print('\n📅 테스트 1: 금요일 (FR) - DateTime.thursday (4) 사용');
  testCase(DateTime.thursday, DateTime(2025, 1, 3), '금요일'); // 금요일

  // 테스트 2: 목요일 (4 → 3으로 보정)
  print('\n📅 테스트 2: 목요일 (TH) - DateTime.wednesday (3) 사용');
  testCase(DateTime.wednesday, DateTime(2025, 1, 2), '목요일'); // 목요일

  // 테스트 3: 월요일 (1 → 7로 보정)
  print('\n📅 테스트 3: 월요일 (MO) - DateTime.sunday (7) 사용');
  testCase(DateTime.sunday, DateTime(2024, 12, 30), '월요일'); // 월요일

  // 테스트 4: 토요일 (6 → 5로 보정)
  print('\n📅 테스트 4: 토요일 (SA) - DateTime.friday (5) 사용');
  testCase(DateTime.friday, DateTime(2025, 1, 4), '토요일'); // 토요일

  print('\n${'=' * 60}');
}

void testCase(int weekdayConstant, DateTime dtstart, String expectedName) {
  try {
    print('  입력:');
    print('    RecurrenceRule API: ByWeekDayEntry($weekdayConstant)');
    print(
      '    DTSTART: ${formatDate(dtstart)} (${getWeekdayName(dtstart.weekday)})',
    );
    print('    예상 결과: $expectedName');

    // RecurrenceRule API로 직접 생성 (-1 보정 적용)
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
        print('  ✅ 정확함: -1 보정으로 $expectedName 생성 성공!');
      } else {
        final offset = firstWeekday - expectedWeekday;
        print(
          '  ❌ 오류: 예상 $expectedName ($expectedWeekday)인데 ${getWeekdayName(firstWeekday)} ($firstWeekday)로 생성됨',
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
