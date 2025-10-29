import 'package:rrule/rrule.dart';

void main() {
  print('=== DateTime 상수 확인 ===');
  print('DateTime.monday: ${DateTime.monday}');
  print('DateTime.tuesday: ${DateTime.tuesday}');
  print('DateTime.wednesday: ${DateTime.wednesday}');
  print('DateTime.thursday: ${DateTime.thursday}');
  print('DateTime.friday: ${DateTime.friday}');
  print('DateTime.saturday: ${DateTime.saturday}');
  print('DateTime.sunday: ${DateTime.sunday}');
  
  print('\n=== ByWeekDayEntry 생성 테스트 ===');
  final friday = ByWeekDayEntry(DateTime.friday);
  final saturday = ByWeekDayEntry(DateTime.saturday);
  
  print('Friday ByWeekDayEntry: $friday');
  print('Saturday ByWeekDayEntry: $saturday');
  
  print('\n=== RecurrenceRule 생성 ===');
  final rrule = RecurrenceRule(
    frequency: Frequency.weekly,
    byWeekDays: [friday, saturday],
  );
  
  print('Generated RRULE: ${rrule.toString()}');
  
  print('\n=== 인스턴스 생성 (2025-10-25 시작) ===');
  final dtstart = DateTime.utc(2025, 10, 25); // 토요일
  print('DTSTART: $dtstart (${_getWeekdayName(dtstart.weekday)})');
  
  final instances = rrule.getInstances(start: dtstart).take(5).toList();
  for (var instance in instances) {
    print('${instance.toIso8601String().substring(0, 10)} (${_getWeekdayName(instance.weekday)})');
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
