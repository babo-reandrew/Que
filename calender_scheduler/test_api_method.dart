import 'package:rrule/rrule.dart';

void main() {
  
  // 금요일, 토요일 반복
  final rrule = RecurrenceRule(
    frequency: Frequency.weekly,
    byWeekDays: [
      ByWeekDayEntry(DateTime.friday),    // 5
      ByWeekDayEntry(DateTime.saturday),  // 6
    ],
  );
  
  final rruleString = rrule.toString();
  
  // 2025-10-25 (토요일) 시작
  final dtstart = DateTime.utc(2025, 10, 25);
  
  // 인스턴스 생성
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
