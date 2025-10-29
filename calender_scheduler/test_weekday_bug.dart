import 'package:rrule/rrule.dart';

void main() {
  print('=== 요일 변환 테스트 ===\n');

  // DateTime 상수 확인
  print('DateTime.monday: ${DateTime.monday}'); // 1
  print('DateTime.tuesday: ${DateTime.tuesday}'); // 2
  print('DateTime.wednesday: ${DateTime.wednesday}'); // 3
  print('DateTime.thursday: ${DateTime.thursday}'); // 4
  print('DateTime.friday: ${DateTime.friday}'); // 5
  print('DateTime.saturday: ${DateTime.saturday}'); // 6
  print('DateTime.sunday: ${DateTime.sunday}'); // 7

  print('\n=== 토요일만 선택 테스트 ===');

  // 토요일(土) = DateTime.saturday = 6
  final saturdayOnly = RecurrenceRule(
    frequency: Frequency.weekly,
    byWeekDays: [ByWeekDayEntry(DateTime.saturday)], // [6]
  );

  final rruleStr = saturdayOnly.toString().replaceFirst('RRULE:', '');
  print('Input: [DateTime.saturday] = [6]');
  print('RRULE 결과: $rruleStr');

  // RRULE 파싱해서 확인
  final parsed = RecurrenceRule.fromString('RRULE:$rruleStr');
  print('Parsed byWeekDays: ${parsed.byWeekDays}');

  // 실제 발생 날짜 확인 (3주간)
  final startDate = DateTime(2025, 10, 20); // 월요일
  final instances = saturdayOnly.getInstances(start: startDate);

  print('\n첫 10개 발생 날짜:');
  var count = 0;
  for (final instance in instances) {
    print(
      '  ${instance.year}-${instance.month.toString().padLeft(2, '0')}-${instance.day.toString().padLeft(2, '0')} (${_weekdayName(instance.weekday)})',
    );
    count++;
    if (count >= 10) break;
  }

  print('\n=== 일요일만 선택 테스트 ===');

  final sundayOnly = RecurrenceRule(
    frequency: Frequency.weekly,
    byWeekDays: [ByWeekDayEntry(DateTime.sunday)], // [7]
  );

  final rruleStr2 = sundayOnly.toString().replaceFirst('RRULE:', '');
  print('Input: [DateTime.sunday] = [7]');
  print('RRULE 결과: $rruleStr2');

  final parsed2 = RecurrenceRule.fromString('RRULE:$rruleStr2');
  print('Parsed byWeekDays: ${parsed2.byWeekDays}');

  final instances2 = sundayOnly.getInstances(start: startDate);

  print('\n첫 10개 발생 날짜:');
  count = 0;
  for (final instance in instances2) {
    print(
      '  ${instance.year}-${instance.month.toString().padLeft(2, '0')}-${instance.day.toString().padLeft(2, '0')} (${_weekdayName(instance.weekday)})',
    );
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
