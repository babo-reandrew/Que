import 'package:rrule/rrule.dart';

void main() {

  // DateTime 상수 확인

  final rruleStr = saturdayOnly.toString().replaceFirst('RRULE:', '');

  // RRULE 파싱해서 확인
  final parsed = RecurrenceRule.fromString('RRULE:$rruleStr');

  // 실제 발생 날짜 확인 (3주간)
  final startDate = DateTime(2025, 10, 20); // 월요일
  final instances = saturdayOnly.getInstances(start: startDate);

  var count = 0;
  for (final instance in instances) {
    count++;
    if (count >= 10) break;
  }


  final sundayOnly = RecurrenceRule(
    frequency: Frequency.weekly,
    byWeekDays: [ByWeekDayEntry(DateTime.sunday)], // [7]
  );

  final rruleStr2 = sundayOnly.toString().replaceFirst('RRULE:', '');

  final parsed2 = RecurrenceRule.fromString('RRULE:$rruleStr2');

  final instances2 = sundayOnly.getInstances(start: startDate);

  count = 0;
  for (final instance in instances2) {
    count++;
    if (count >= 10) break;
  }
}

String _weekdayName(int weekday) {
  switch (weekday) {
    case 1:
      return '월요일';
    case 2:
      return '화요일';
    case 3:
      return '수요일';
    case 4:
      return '목요일';
    case 5:
      return '금요일';
    case 6:
      return '토요일';
    case 7:
      return '일요일';
    default:
      return '???';
  }
}
