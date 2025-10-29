import 'package:rrule/rrule.dart';

void main() {
  print('=== RRULE 테스트 시작 ===');

  // 테스트 1: FREQ=WEEKLY;BYDAY=FR,SA (RRULE: 프리픽스 필요!)
  final rrule = RecurrenceRule.fromString('RRULE:FREQ=WEEKLY;BYDAY=FR,SA');
  final dtstart = DateTime(2025, 10, 31, 15, 0, 0); // 금요일

  print('DTSTART: $dtstart (${_weekdayName(dtstart.weekday)})');
  print('RRULE: FREQ=WEEKLY;BYDAY=FR,SA');
  print('');

  // 조회 범위: 10월 25일 ~ 11월 30일
  final after = DateTime(2025, 10, 25);
  final before = DateTime(2025, 11, 30);

  print('조회 범위: $after ~ $before');
  print('');

  try {
    final instances = rrule.getAllInstances(
      start: dtstart,
      after: after.subtract(const Duration(days: 1)),
      includeAfter: true,
      before: before,
      includeBefore: false,
    );

    print('✅ 생성된 인스턴스: ${instances.length}개');
    for (var i = 0; i < instances.length && i < 20; i++) {
      final date = instances[i];
      print(
        '  ${i + 1}. ${date.toString().split(' ')[0]} (${_weekdayName(date.weekday)})',
      );
    }
  } catch (e, stack) {
    print('❌ 에러 발생: $e');
    print('Stack: ${stack.toString().split('\n').take(5).join('\n')}');
  }
}

String _weekdayName(int weekday) {
  const names = ['', '월', '화', '수', '목', '금', '토', '일'];
  return names[weekday];
}
