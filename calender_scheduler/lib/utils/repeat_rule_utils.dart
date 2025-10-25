import 'dart:convert';

/// 반복 규칙 유틸리티 클래스
/// 이거를 설정하고 → 반복 규칙 JSON을 파싱하고 생성하는 함수를 제공해서
/// 이거를 해서 → 일정/할일/습관에서 반복 규칙을 쉽게 처리할 수 있다
/// 이거는 이래서 → DB 저장 및 UI 표시를 일관되게 관리한다
class RepeatRuleUtils {
  /// 반복 규칙 JSON을 파싱하는 함수
  /// 이거를 설정하고 → JSON 문자열을 받아서
  /// 이거를 해서 → Map<String, dynamic>으로 변환한다
  static Map<String, dynamic>? parseRepeatRule(String? repeatRule) {
    if (repeatRule == null || repeatRule.isEmpty) {
      return null;
    }

    try {
      return json.decode(repeatRule) as Map<String, dynamic>;
    } catch (e) {
      print('❌ [RepeatRule] 파싱 실패: $e');
      return null;
    }
  }

  /// 반복 규칙을 표시 문자열로 변환하는 함수
  /// 이거를 설정하고 → 반복 규칙 JSON을 받아서
  /// 이거를 해서 → 사용자에게 표시할 문자열을 반환한다
  /// 예: {"type":"daily","display":"평일"} → "평일"
  static String getDisplayText(String? repeatRule) {
    final parsed = parseRepeatRule(repeatRule);
    if (parsed == null) {
      return '반복 없음';
    }

    final type = parsed['type'] as String?;

    switch (type) {
      case 'daily':
        // 매일: display 필드 사용
        return parsed['display'] as String? ?? '매일';

      case 'monthly':
        // 매월: 선택된 날짜 표시
        final days = parsed['days'] as List<dynamic>?;
        if (days == null || days.isEmpty) {
          return '매월';
        }
        return '매월 ${days.join(", ")}일';

      case 'interval':
        // 간격: value 필드 사용
        return parsed['value'] as String? ?? '간격';

      default:
        return '반복 없음';
    }
  }

  /// 매일 반복 규칙 생성 (요일 선택)
  /// 이거를 설정하고 → 선택된 요일 리스트를 받아서
  /// 이거를 해서 → JSON 문자열로 변환한다
  static String createDailyRule(Set<int> weekdays) {
    if (weekdays.isEmpty) {
      return '{"type":"daily","weekdays":[]}';
    }

    // 모든 요일 선택 → "매일"
    if (weekdays.length == 7) {
      return '{"type":"daily","display":"매일"}';
    }

    // 월~금 선택 → "평일"
    if (weekdays.containsAll([1, 2, 3, 4, 5]) && weekdays.length == 5) {
      return '{"type":"daily","display":"평일"}';
    }

    // 토~일 선택 → "주말"
    if (weekdays.containsAll([6, 7]) && weekdays.length == 2) {
      return '{"type":"daily","display":"주말"}';
    }

    // 그 외 → 선택한 요일 표시
    final weekdayLabels = ['', '월', '화', '수', '목', '금', '토', '일'];
    final display = weekdays.map((day) => weekdayLabels[day]).join('');

    return '{"type":"daily","weekdays":${weekdays.toList()},"display":"$display"}';
  }

  /// 매월 반복 규칙 생성 (날짜 선택)
  /// 이거를 설정하고 → 선택된 날짜 리스트를 받아서
  /// 이거를 해서 → JSON 문자열로 변환한다
  static String createMonthlyRule(Set<int> days) {
    if (days.isEmpty) {
      return '{"type":"monthly","days":[]}';
    }

    return '{"type":"monthly","days":${days.toList()}}';
  }

  /// 간격 반복 규칙 생성
  /// 이거를 설정하고 → 선택된 간격 문자열을 받아서
  /// 이거를 해서 → JSON 문자열로 변환한다
  static String createIntervalRule(String interval) {
    return '{"type":"interval","value":"$interval"}';
  }

  /// 반복 규칙이 비어있는지 확인하는 함수
  /// 이거를 설정하고 → 반복 규칙 JSON을 받아서
  /// 이거를 해서 → 비어있으면 true를 반환한다
  static bool isEmpty(String? repeatRule) {
    if (repeatRule == null || repeatRule.isEmpty) {
      return true;
    }

    final parsed = parseRepeatRule(repeatRule);
    if (parsed == null) {
      return true;
    }

    final type = parsed['type'] as String?;
    if (type == null) {
      return true;
    }

    // 매일/매월: weekdays/days가 비어있으면 비어있음
    if (type == 'daily') {
      final weekdays = parsed['weekdays'] as List<dynamic>?;
      return weekdays == null || weekdays.isEmpty;
    }

    if (type == 'monthly') {
      final days = parsed['days'] as List<dynamic>?;
      return days == null || days.isEmpty;
    }

    // 간격: value가 없으면 비어있음
    if (type == 'interval') {
      final value = parsed['value'] as String?;
      return value == null || value.isEmpty;
    }

    return false;
  }

  /// 다음 반복 날짜를 계산하는 함수
  /// 이거를 설정하고 → 현재 날짜와 반복 규칙을 받아서
  /// 이거를 해서 → 다음 반복 날짜를 계산한다
  /// TODO: 실제 반복 로직 구현 (향후 확장)
  static DateTime? getNextRepeatDate(DateTime currentDate, String? repeatRule) {
    final parsed = parseRepeatRule(repeatRule);
    if (parsed == null) {
      return null;
    }

    final type = parsed['type'] as String?;

    switch (type) {
      case 'daily':
        // 매일: 다음날 반환
        return currentDate.add(const Duration(days: 1));

      case 'monthly':
        // 매월: 다음달 같은 날짜 반환
        return DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );

      case 'interval':
        // 간격: 간격만큼 더한 날짜 반환
        // TODO: 간격 파싱 및 계산 로직 구현
        return currentDate.add(const Duration(days: 2));

      default:
        return null;
    }
  }

  /// 🎯 특정 날짜에 항목이 반복 규칙에 의해 표시되어야 하는지 확인
  ///
  /// [targetDate]: 확인할 날짜
  /// [baseDate]: 기준 날짜 (Schedule의 start, Task의 executionDate, Habit의 createdAt)
  /// [repeatRule]: 반복 규칙 JSON 문자열
  ///
  /// 반환: true이면 해당 날짜에 표시해야 함
  static bool shouldShowOnDate({
    required DateTime targetDate,
    required DateTime baseDate,
    required String? repeatRule,
  }) {
    // 반복 규칙이 없으면 기준 날짜와 같은지만 확인
    if (repeatRule == null || repeatRule.isEmpty) {
      return _isSameDate(targetDate, baseDate);
    }

    final parsed = parseRepeatRule(repeatRule);
    if (parsed == null) {
      return _isSameDate(targetDate, baseDate);
    }

    final type = parsed['type'] as String?;

    switch (type) {
      case 'daily':
        return _checkDailyRepeat(targetDate, baseDate, parsed);

      case 'monthly':
        return _checkMonthlyRepeat(targetDate, baseDate, parsed);

      case 'interval':
        return _checkIntervalRepeat(targetDate, baseDate, parsed);

      default:
        return _isSameDate(targetDate, baseDate);
    }
  }

  /// 매일 반복 규칙 확인
  static bool _checkDailyRepeat(
    DateTime targetDate,
    DateTime baseDate,
    Map<String, dynamic> parsed,
  ) {
    // targetDate가 baseDate보다 이전이면 표시 안 함
    if (targetDate.isBefore(_dateOnly(baseDate))) {
      return false;
    }

    // weekdays가 있으면 해당 요일만 표시
    final weekdays = parsed['weekdays'] as List<dynamic>?;
    if (weekdays != null && weekdays.isNotEmpty) {
      // targetDate의 요일 (월=1, 일=7)
      final targetWeekday = targetDate.weekday;
      return weekdays.contains(targetWeekday);
    }

    // weekdays가 없거나 비어있으면 매일 표시 (baseDate 이후)
    return true;
  }

  /// 매월 반복 규칙 확인
  static bool _checkMonthlyRepeat(
    DateTime targetDate,
    DateTime baseDate,
    Map<String, dynamic> parsed,
  ) {
    // targetDate가 baseDate보다 이전이면 표시 안 함
    if (targetDate.isBefore(_dateOnly(baseDate))) {
      return false;
    }

    final days = parsed['days'] as List<dynamic>?;
    if (days == null || days.isEmpty) {
      return false;
    }

    // targetDate의 일(day)이 선택된 날짜 목록에 있으면 표시
    return days.contains(targetDate.day);
  }

  /// 간격 반복 규칙 확인
  static bool _checkIntervalRepeat(
    DateTime targetDate,
    DateTime baseDate,
    Map<String, dynamic> parsed,
  ) {
    // targetDate가 baseDate보다 이전이면 표시 안 함
    if (targetDate.isBefore(_dateOnly(baseDate))) {
      return false;
    }

    final value = parsed['value'] as String?;
    if (value == null || value.isEmpty) {
      return false;
    }

    // "2day", "3day" 등 파싱
    final match = RegExp(r'(\d+)day').firstMatch(value);
    if (match == null) {
      return false;
    }

    final intervalDays = int.tryParse(match.group(1) ?? '');
    if (intervalDays == null || intervalDays <= 0) {
      return false;
    }

    // baseDate부터 targetDate까지의 일수 차이 계산
    final baseDateOnly = _dateOnly(baseDate);
    final targetDateOnly = _dateOnly(targetDate);
    final daysDiff = targetDateOnly.difference(baseDateOnly).inDays;

    // 간격의 배수이면 표시
    return daysDiff >= 0 && daysDiff % intervalDays == 0;
  }

  /// 두 DateTime이 같은 날짜인지 확인 (시간 무시)
  static bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// DateTime에서 시간을 제거하고 날짜만 반환
  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
