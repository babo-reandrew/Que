import 'package:rrule/rrule.dart';

void main() {

  // 테스트 1: 금요일 RRULE을 금요일부터 시작
  testCase('RRULE:FREQ=WEEKLY;BYDAY=FR', DateTime(2025, 1, 3)); // 금요일

  // 테스트 2: 목요일 RRULE을 목요일부터 시작
  testCase('RRULE:FREQ=WEEKLY;BYDAY=TH', DateTime(2025, 1, 2)); // 목요일

  // 테스트 3: 월요일 RRULE을 월요일부터 시작
  testCase('RRULE:FREQ=WEEKLY;BYDAY=MO', DateTime(2024, 12, 30)); // 월요일

}

void testCase(String rruleString, DateTime dtstart) {
  try {

    final recurrenceRule = RecurrenceRule.fromString(rruleString);
    final dtstartUtc = dtstart.toUtc();

    // after를 dtstart - 1초로 설정하여 dtstart 포함
    final afterUtc = dtstartUtc.subtract(const Duration(seconds: 1));

    final instances = recurrenceRule.getAllInstances(
      start: dtstartUtc,
      after: afterUtc,
      before: dtstartUtc.add(const Duration(days: 21)),
    );

    for (var instance in instances.take(3)) {
      final local = instance.toLocal();
      final weekdayName = getWeekdayName(local.weekday);
    }

    if (instances.isNotEmpty) {
      final firstWeekday = instances.first.toLocal().weekday;
      final expectedWeekday = dtstart.weekday;

      if (firstWeekday == expectedWeekday) {
      } else {
        final offset = firstWeekday - expectedWeekday;
      }
    }
  } catch (e) {
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
