import 'package:rrule/rrule.dart';

void main() {
  
  final friday = ByWeekDayEntry(DateTime.friday);
  final saturday = ByWeekDayEntry(DateTime.saturday);
  
  
  final rrule = RecurrenceRule(
    frequency: Frequency.weekly,
    byWeekDays: [friday, saturday],
  );
  
  
  final dtstart = DateTime.utc(2025, 10, 25); // 토요일
  
  final instances = rrule.getInstances(start: dtstart).take(5).toList();
  for (var instance in instances) {
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
