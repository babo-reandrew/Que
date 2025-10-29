import 'package:rrule/rrule.dart';

void main() {
  // 테스트: 2025-10-24 목요일부터 시작하는 목금 반복 (실제로는 금토)
  print('=== 원래 코드: BYDAY=FR,SA ===');
  final rruleOriginal = RecurrenceRule.fromString(
    'RRULE:FREQ=WEEKLY;WKST=MO;BYDAY=FR,SA',
  );
  testRRule(rruleOriginal, 'FREQ=WEEKLY;WKST=MO;BYDAY=FR,SA');

  print('\n=== 수정된 코드: BYDAY=TH,FR (하루 앞당김) ===');
  final rruleFixed = RecurrenceRule.fromString(
    'RRULE:FREQ=WEEKLY;WKST=MO;BYDAY=TH,FR',
  );
  testRRule(rruleFixed, 'FREQ=WEEKLY;WKST=MO;BYDAY=TH,FR');
}

void testRRule(RecurrenceRule rrule, String ruleString) {
  final dtstart = DateTime(2025, 10, 25); // 2025-10-25
  final dtstartUtc = dtstart.toUtc();

  print('DTSTART: $dtstart (요일: ${_getWeekdayName(dtstart.weekday)})');
  print('RRULE: $ruleString');
  print('');

  // 2025-10-25 ~ 2025-11-08 범위의 인스턴스 생성
  final rangeStart = DateTime(2025, 10, 25);
  final rangeEnd = DateTime(2025, 11, 8, 23, 59, 59);

  final after = rangeStart.toUtc().subtract(const Duration(seconds: 1));
  final before = rangeEnd.toUtc();

  final instances = rrule.getAllInstances(
    start: dtstartUtc,
    after: after,
    before: before,
  );

  print('생성된 인스턴스 (${instances.length}개):');
  for (final inst in instances) {
    final local = inst.toLocal();
    print(
      '  ${local.toString().split(' ')[0]} (${_getWeekdayName(local.weekday)})',
    );
  }
}

String _getWeekdayName(int weekday) {
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
      return '알 수 없음';
  }
}
