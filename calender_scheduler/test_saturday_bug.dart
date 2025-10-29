import 'package:rrule/rrule.dart';

// Task에서 복사한 함수들
int? _jpDayToWeekday(String jpDay) {
  switch (jpDay) {
    case '月':
      return DateTime.monday; // 1
    case '火':
      return DateTime.tuesday; // 2
    case '水':
      return DateTime.wednesday; // 3
    case '木':
      return DateTime.thursday; // 4
    case '金':
      return DateTime.friday; // 5
    case '土':
      return DateTime.saturday; // 6
    case '日':
      return DateTime.sunday; // 7
    default:
      print('⚠️ [RepeatConvert] 알 수 없는 요일: $jpDay');
      return null;
  }
}

String? convertRepeatRuleToRRule(String? repeatRuleJson, DateTime dtstart) {
  if (repeatRuleJson == null || repeatRuleJson.trim().isEmpty) {
    return null;
  }

  try {
    // 새 형식: {"value":"daily:月,火,水","display":"月火\n水"}
    if (!repeatRuleJson.contains('"value":"')) {
      print('⚠️ [RepeatConvert] 알 수 없는 형식: $repeatRuleJson');
      return null;
    }

    final startIndex = repeatRuleJson.indexOf('"value":"') + 9;
    final endIndex = repeatRuleJson.indexOf('"', startIndex);
    final value = repeatRuleJson.substring(startIndex, endIndex);

    print('🔍 [RepeatConvert] value 추출: $value');

    // daily: 요일 기반 반복
    if (value.startsWith('daily:')) {
      final daysStr = value.substring(6); // "月,火,水"
      final days = daysStr.split(',');

      print('🔍 [RepeatConvert] days split: $days');

      // 일본어 요일 → DateTime.weekday
      final weekdays = days.map(_jpDayToWeekday).whereType<int>().toList();

      print('🔍 [RepeatConvert] weekdays 변환: $weekdays');

      if (weekdays.isEmpty) {
        print('⚠️ [RepeatConvert] 유효한 요일 없음');
        return null;
      }

      // RecurrenceRule API 사용
      final rrule = RecurrenceRule(
        frequency: Frequency.weekly,
        byWeekDays: weekdays.map((wd) => ByWeekDayEntry(wd)).toList(),
      );

      final rruleString = rrule.toString();
      final result = rruleString.replaceFirst('RRULE:', '');

      print('✅ [RepeatConvert] RRULE 생성: $result');
      return result;
    }

    return null;
  } catch (e) {
    print('❌ [RepeatConvert] 에러: $e');
    return null;
  }
}

void main() {
  print('=== 토요일만 선택 테스트 ===\n');

  // 사용자가 UI에서 토요일만 선택했을 때 저장되는 JSON
  final saturdayJson = '{"value":"daily:土","display":"土"}';
  print('입력 JSON: $saturdayJson');

  final dtstart = DateTime(2025, 10, 20);
  final rrule = convertRepeatRuleToRRule(saturdayJson, dtstart);

  print('\n결과 RRULE: $rrule');

  if (rrule != null) {
    final parsed = RecurrenceRule.fromString('RRULE:$rrule');
    print('Parsed byWeekDays: ${parsed.byWeekDays}');

    final instances = parsed.getInstances(start: dtstart);
    print('\n첫 5개 발생 날짜:');
    var count = 0;
    for (final instance in instances) {
      print(
        '  ${instance.year}-${instance.month.toString().padLeft(2, '0')}-${instance.day.toString().padLeft(2, '0')} (${_weekdayName(instance.weekday)})',
      );
      count++;
      if (count >= 5) break;
    }
  }

  print('\n\n=== 토일 선택 테스트 ===\n');

  // 사용자가 UI에서 토일 선택했을 때
  final weekendJson = '{"value":"daily:土,日","display":"土日"}';
  print('입력 JSON: $weekendJson');

  final rrule2 = convertRepeatRuleToRRule(weekendJson, dtstart);

  print('\n결과 RRULE: $rrule2');

  if (rrule2 != null) {
    final parsed2 = RecurrenceRule.fromString('RRULE:$rrule2');
    print('Parsed byWeekDays: ${parsed2.byWeekDays}');

    final instances2 = parsed2.getInstances(start: dtstart);
    print('\n첫 5개 발생 날짜:');
    var count2 = 0;
    for (final instance in instances2) {
      print(
        '  ${instance.year}-${instance.month.toString().padLeft(2, '0')}-${instance.day.toString().padLeft(2, '0')} (${_weekdayName(instance.weekday)})',
      );
      count2++;
      if (count2 >= 5) break;
    }
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
