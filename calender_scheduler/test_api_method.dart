import 'package:rrule/rrule.dart';

void main() {
  print('=== RecurrenceRule API 테스트 ===\n');
  
  // 금요일, 토요일 반복
  final rrule = RecurrenceRule(
    frequency: Frequency.weekly,
    byWeekDays: [
      ByWeekDayEntry(DateTime.friday),    // 5
      ByWeekDayEntry(DateTime.saturday),  // 6
    ],
  );
  
  final rruleString = rrule.toString();
  print('생성된 RRULE: $rruleString');
  print('접두사 제거: ${rruleString.replaceFirst("RRULE:", "")}\n');
  
  // 2025-10-25 (토요일) 시작
  final dtstart = DateTime.utc(2025, 10, 25);
  print('DTSTART: $dtstart (${_getWeekdayName(dtstart.weekday)})\n');
  
  // 인스턴스 생성
  final instances = rrule.getInstances(start: dtstart).take(5).toList();
  print('생성된 인스턴스:');
  for (var instance in instances) {
    print('  ${instance.toIso8601String().substring(0, 10)} (${_getWeekdayName(instance.weekday)})');
  }
}

String _getWeekdayName(int weekday) {
  switch (weekday) {
    case DateTime.monday: return '월';
    case DateTime.tuesday: return '화';
    case DateTime.wednesday: return '수';
    case DateTime.thursday: return '목';
    case DateTime.friday: return '금';
    case DateTime.saturday: return '토';
    case DateTime.sunday: return '일';
    default: return '?';
  }
}
