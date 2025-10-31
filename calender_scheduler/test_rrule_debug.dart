import 'package:rrule/rrule.dart';

void main() {

  // 테스트 1: FREQ=WEEKLY;BYDAY=FR,SA (RRULE: 프리픽스 필요!)
  final rrule = RecurrenceRule.fromString('RRULE:FREQ=WEEKLY;BYDAY=FR,SA');
  final dtstart = DateTime(2025, 10, 31, 15, 0, 0); // 금요일


  // 조회 범위: 10월 25일 ~ 11월 30일
  final after = DateTime(2025, 10, 25);
  final before = DateTime(2025, 11, 30);


  try {
    final instances = rrule.getAllInstances(
      start: dtstart,
      after: after.subtract(const Duration(days: 1)),
      includeAfter: true,
      before: before,
      includeBefore: false,
    );

    for (var i = 0; i < instances.length && i < 20; i++) {
      final date = instances[i];
    }
  } catch (e, stack) {
  }
}

String _weekdayName(int weekday) {
  const names = ['', '월', '화', '수', '목', '금', '토', '일'];
  return names[weekday];
}
