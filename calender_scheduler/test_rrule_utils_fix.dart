import 'package:rrule/rrule.dart';

void main() {

  // 시나리오: 데이터베이스에 "FREQ=WEEKLY;BYDAY=TH" (목요일)이 저장되어 있음
  // 이전 버그: RecurrenceRule.fromString()으로 파싱 → 금요일로 해석됨
  // 수정 후: _parseRRuleToApi()로 파싱 → 목요일로 정확히 해석됨

  testOldWay();

  testNewWay();

}

void testOldWay() {
  try {
    final rruleString = 'RRULE:FREQ=WEEKLY;BYDAY=TH';
    final recurrenceRule = RecurrenceRule.fromString(rruleString);

    // 2025-01-02 (목요일)부터 시작
    final dtstart = DateTime(2025, 1, 2); // 목요일

    final dtstartUtc = dtstart.toUtc();

    final instances = recurrenceRule.getAllInstances(
      start: dtstartUtc,
      before: dtstartUtc.add(const Duration(days: 30)),
    );

    for (var instance in instances.take(3)) {
      final local = instance.toLocal();
      final weekdayName = _getWeekdayName(local.weekday);
    }

    final firstWeekday = instances.first.toLocal().weekday;
    if (firstWeekday == DateTime.friday) {
    } else if (firstWeekday == DateTime.thursday) {
    }
  } catch (e) {
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

    final dtstartUtc = dtstart.toUtc();

    final instances = recurrenceRule.getAllInstances(
      start: dtstartUtc,
      before: dtstartUtc.add(const Duration(days: 30)),
    );

    for (var instance in instances.take(3)) {
      final local = instance.toLocal();
      final weekdayName = _getWeekdayName(local.weekday);
    }

    final firstWeekday = instances.first.toLocal().weekday;
    if (firstWeekday == DateTime.thursday) {
    } else {
    }
  } catch (e) {
  }
}

String _getWeekdayName(int weekday) {
  const names = ['', '월', '화', '수', '목', '금', '토', '일'];
  return names[weekday];
}

String _pad(int n) => n.toString().padLeft(2, '0');
