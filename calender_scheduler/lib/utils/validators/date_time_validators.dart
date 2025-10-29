/// 날짜와 시간 검증을 담당하는 유틸리티 클래스
/// 모든 메소드는 순수 함수로 구현되어 테스트가 용이하고 재사용이 가능하다
class DateTimeValidators {
  /// 윤년인지 확인하는 함수 - 2월 29일의 유효성을 검증할 때 사용한다
  /// 윤년 조건: 4로 나누어떨어지고, 100으로 나누어떨어지지 않거나, 400으로 나누어떨어진다
  static bool isLeapYear(int year) {
    // 1. 400으로 나누어떨어지면 무조건 윤년이다 (예: 2000년)
    if (year % 400 == 0) return true;

    // 2. 100으로 나누어떨어지면 윤년이 아니다 (예: 1900년)
    if (year % 100 == 0) return false;

    // 3. 4로 나누어떨어지면 윤년이다 (예: 2024년)
    if (year % 4 == 0) return true;

    // 4. 그 외에는 평년이다
    return false;
  }

  /// 특정 연도와 월의 최대 일수를 반환하는 함수
  /// 월별로 다른 최대 일수를 계산하고, 2월의 경우 윤년을 고려한다
  static int getDaysInMonth(int year, int month) {
    // 1. 월이 유효한 범위(1-12)인지 확인한다
    if (month < 1 || month > 12) return 0;

    // 2. 각 월별 최대 일수를 정의한다
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    // 3. 기본 일수를 가져온다 (인덱스는 0부터 시작하므로 month - 1)
    int days = daysInMonth[month - 1];

    // 4. 2월이고 윤년이면 29일로 설정한다
    if (month == 2 && isLeapYear(year)) {
      days = 29;
    }

    return days;
  }

  /// 날짜의 유효성을 검증하는 함수 - 년/월/일이 실제로 존재하는 날짜인지 확인한다
  static String? validateDate(int? year, int? month, int? day) {
    // 1. null 체크 - 년, 월, 일 중 하나라도 null이면 에러를 반환한다
    if (year == null || month == null || day == null) {
      return '날짜를 모두 입력해주세요';
    }

    // 2. 연도 범위 검증 - 너무 과거나 미래의 날짜는 허용하지 않는다
    if (year < 1900 || year > 2200) {
      return '연도는 1900년부터 2200년 사이여야 합니다';
    }

    // 3. 월 범위 검증 - 1월부터 12월까지만 유효하다
    if (month < 1 || month > 12) {
      return '월은 1부터 12 사이여야 합니다';
    }

    // 4. 일 범위 검증 - 해당 월의 최대 일수를 넘으면 안된다
    final maxDay = getDaysInMonth(year, month);
    if (day < 1 || day > maxDay) {
      // 윤년을 고려한 구체적인 에러 메시지를 제공한다
      if (month == 2 && day == 29 && !isLeapYear(year)) {
        return '$year년은 윤년이 아니므로 2월 29일은 존재하지 않습니다';
      }
      return '일은 1부터 $maxDay 사이여야 합니다';
    }

    // 5. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 시간의 유효성을 검증하는 함수 - 시간과 분이 유효한 범위인지 확인한다
  static String? validateTime(int? hour, int? minute) {
    // 1. null 체크 - 시간과 분 중 하나라도 null이면 에러를 반환한다
    if (hour == null || minute == null) {
      return '시간을 모두 입력해주세요';
    }

    // 2. 시간 범위 검증 - 0시부터 23시까지만 유효하다 (24시간 형식)
    if (hour < 0 || hour > 23) {
      return '시간은 0부터 23 사이여야 합니다';
    }

    // 3. 분 범위 검증 - 0분부터 59분까지만 유효하다
    if (minute < 0 || minute > 59) {
      return '분은 0부터 59 사이여야 합니다';
    }

    // 4. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 날짜 문자열 형식을 검증하는 함수 - YYYY-MM-DD 형식을 확인한다
  static String? validateDateFormat(String? dateString) {
    // 1. null 또는 빈 문자열 체크 - 비어있으면 에러를 반환한다
    if (dateString == null || dateString.isEmpty) {
      return '날짜를 입력해주세요';
    }

    // 2. 기본 형식 검증 - YYYY-MM-DD 또는 YYYY/MM/DD 형식인지 확인한다
    final dateRegex = RegExp(r'^\d{4}[-/]\d{2}[-/]\d{2}$');
    if (!dateRegex.hasMatch(dateString)) {
      return '날짜 형식이 올바르지 않습니다 (YYYY-MM-DD)';
    }

    // 3. 날짜 파싱 시도 - 실제로 파싱 가능한 날짜인지 확인한다
    try {
      final parts = dateString.split(RegExp(r'[-/]'));
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      // 4. 파싱된 날짜의 유효성을 검증한다
      return validateDate(year, month, day);
    } catch (e) {
      // 5. 파싱 실패 시 에러를 반환한다
      return '올바른 날짜가 아닙니다';
    }
  }

  /// 시간 문자열 형식을 검증하는 함수 - HH:MM 형식을 확인한다
  static String? validateTimeFormat(String? timeString) {
    // 1. null 또는 빈 문자열 체크 - 비어있으면 에러를 반환한다
    if (timeString == null || timeString.isEmpty) {
      return '시간을 입력해주세요';
    }

    // 2. 기본 형식 검증 - HH:MM 형식인지 확인한다
    final timeRegex = RegExp(r'^\d{1,2}:\d{2}$');
    if (!timeRegex.hasMatch(timeString)) {
      return '시간 형식이 올바르지 않습니다 (HH:MM)';
    }

    // 3. 시간 파싱 시도 - 실제로 파싱 가능한 시간인지 확인한다
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // 4. 파싱된 시간의 유효성을 검증한다
      return validateTime(hour, minute);
    } catch (e) {
      // 5. 파싱 실패 시 에러를 반환한다
      return '올바른 시간이 아닙니다';
    }
  }

  /// DateTime 객체의 유효성을 검증하는 함수 - DateTime 객체가 유효한지 확인한다
  static String? validateDateTime(DateTime? dateTime) {
    // 1. null 체크 - null이면 에러를 반환한다
    if (dateTime == null) {
      return '날짜와 시간을 입력해주세요';
    }

    // 2. 연도 범위 검증 - 유효한 범위 내의 날짜인지 확인한다
    if (dateTime.year < 1900 || dateTime.year > 2200) {
      return '유효하지 않은 날짜입니다';
    }

    // 3. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 시작 시간이 종료 시간보다 이전인지 검증하는 함수
  /// 이벤트의 논리적 일관성을 확인한다
  static String? validateTimeOrder(DateTime? startTime, DateTime? endTime) {
    // 1. null 체크 - 둘 중 하나라도 null이면 에러를 반환한다
    if (startTime == null || endTime == null) {
      return '시작 시간과 종료 시간을 모두 입력해주세요';
    }

    // 2. 시간 순서 검증 - 시작 시간이 종료 시간보다 이후면 에러를 반환한다
    if (startTime.isAfter(endTime)) {
      return '시작 시간이 종료 시간보다 늦을 수 없습니다';
    }

    // 3. 같은 시간 검증 - 시작 시간과 종료 시간이 같으면 에러를 반환한다
    if (startTime.isAtSameMomentAs(endTime)) {
      return '시작 시간과 종료 시간이 같을 수 없습니다';
    }

    // 4. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 과거 시간인지 검증하는 함수 - 과거 일정 생성을 방지할 때 사용한다 (선택적)
  static String? validateFutureTime(
    DateTime? dateTime, {
    bool allowPast = true,
  }) {
    // 1. null 체크 - null이면 에러를 반환한다
    if (dateTime == null) {
      return '날짜와 시간을 입력해주세요';
    }

    // 2. 과거 시간 허용 여부에 따라 검증한다
    if (!allowPast) {
      final now = DateTime.now();
      // 현재 시간보다 이전이면 에러를 반환한다
      if (dateTime.isBefore(now)) {
        return '과거 시간으로 일정을 생성할 수 없습니다';
      }
    }

    // 3. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 이벤트 지속 시간을 검증하는 함수 - 적절한 일정 길이인지 확인한다
  static String? validateEventDuration(
    DateTime? startTime,
    DateTime? endTime, {
    Duration? minDuration, // 최소 지속 시간
    Duration? maxDuration, // 최대 지속 시간
    Duration? recommendedDuration, // 권장 지속 시간
  }) {
    // 1. null 체크 - 둘 중 하나라도 null이면 에러를 반환한다
    if (startTime == null || endTime == null) {
      return '시작 시간과 종료 시간을 모두 입력해주세요';
    }

    // 2. 지속 시간을 계산한다
    final duration = endTime.difference(startTime);

    // 3. 최소 지속 시간 검증 - 너무 짧은 일정을 방지한다
    if (minDuration != null && duration < minDuration) {
      final minMinutes = minDuration.inMinutes;
      return '일정은 최소 $minMinutes분 이상이어야 합니다';
    }

    // 4. 최대 지속 시간 검증 - 너무 긴 일정을 방지한다
    if (maxDuration != null && duration > maxDuration) {
      final maxHours = maxDuration.inHours;
      return '일정은 최대 $maxHours시간을 초과할 수 없습니다';
    }

    // 5. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 24시간 이내 권장 검증 함수 - 너무 긴 일정에 대해 경고를 제공한다
  static String? validateRecommendedDuration(
    DateTime? startTime,
    DateTime? endTime,
  ) {
    // 1. null 체크 - 둘 중 하나라도 null이면 null을 반환한다 (경고이므로 에러는 아님)
    if (startTime == null || endTime == null) {
      return null;
    }

    // 2. 지속 시간을 계산한다
    final duration = endTime.difference(startTime);

    // 3. 24시간을 초과하면 경고 메시지를 반환한다
    if (duration.inHours > 24) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      return '일정이 $days일 $hours시간으로 길어요. 여러 일정으로 나누는 것이 좋습니다.';
    }

    // 4. 권장 범위 내면 null을 반환한다
    return null;
  }

  /// 날짜 범위가 유효한지 검증하는 함수 - 반복 일정이나 여러 날에 걸친 일정을 검증한다
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    // 1. null 체크 - 둘 중 하나라도 null이면 에러를 반환한다
    if (startDate == null || endDate == null) {
      return '시작 날짜와 종료 날짜를 모두 입력해주세요';
    }

    // 2. 날짜 순서 검증 - 시작 날짜가 종료 날짜보다 이후면 에러를 반환한다
    if (startDate.isAfter(endDate)) {
      return '시작 날짜가 종료 날짜보다 늦을 수 없습니다';
    }

    // 3. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 타임존 일관성을 검증하는 함수 - 시작 시간과 종료 시간이 같은 타임존인지 확인한다
  static String? validateTimezoneConsistency(
    DateTime? startTime,
    DateTime? endTime,
  ) {
    // 1. null 체크 - 둘 중 하나라도 null이면 null을 반환한다
    if (startTime == null || endTime == null) {
      return null;
    }

    // 2. 타임존 일관성 검증 - 둘 다 UTC이거나 둘 다 로컬이어야 한다
    if (startTime.isUtc != endTime.isUtc) {
      return '시작 시간과 종료 시간의 타임존이 일치하지 않습니다';
    }

    // 3. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 특정 날짜가 주말인지 확인하는 헬퍼 함수 - 주말 일정에 대한 경고를 제공할 때 사용한다
  static bool isWeekend(DateTime date) {
    // 토요일(6) 또는 일요일(7)이면 주말이다
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// 특정 날짜가 공휴일인지 확인하는 헬퍼 함수 - 공휴일 일정에 대한 경고를 제공할 때 사용한다
  /// (현재는 기본 구현만 제공, 추후 공휴일 API 연동 가능)
  static bool isHoliday(DateTime date) {
    // TODO: 실제 공휴일 API와 연동하거나 공휴일 데이터베이스를 사용한다
    // 현재는 간단한 고정 공휴일만 체크한다

    // 신정 (1월 1일)
    if (date.month == 1 && date.day == 1) return true;

    // 크리스마스 (12월 25일)
    if (date.month == 12 && date.day == 25) return true;

    // 그 외에는 평일로 처리한다
    return false;
  }

  /// 날짜를 정규화하는 헬퍼 함수 - UTC 00:00:00 형태로 변환한다
  /// 시간 정보를 제거하고 날짜만 비교할 때 사용한다
  static DateTime normalizeDate(DateTime date) {
    // UTC 형식으로 변환하고 시간을 00:00:00으로 설정한다
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// 두 날짜가 같은 날인지 확인하는 헬퍼 함수 - 시간을 무시하고 날짜만 비교한다
  static bool isSameDay(DateTime? date1, DateTime? date2) {
    // 1. null 체크 - 둘 중 하나라도 null이면 false를 반환한다
    if (date1 == null || date2 == null) return false;

    // 2. 연도, 월, 일이 모두 같으면 같은 날이다
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 시간 문자열을 DateTime으로 파싱하는 헬퍼 함수 - HH:MM 형식을 DateTime으로 변환한다
  static DateTime? parseTimeString(String? timeString, DateTime baseDate) {
    // 1. null 또는 빈 문자열 체크 - 비어있으면 null을 반환한다
    if (timeString == null || timeString.isEmpty) {
      return null;
    }

    // 2. 시간 형식을 검증한다 - 유효하지 않으면 null을 반환한다
    final validationError = validateTimeFormat(timeString);
    if (validationError != null) {
      return null;
    }

    // 3. 시간 파싱 시도
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // 4. baseDate에 시간을 결합해서 DateTime 객체를 생성한다
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
      );
    } catch (e) {
      // 5. 파싱 실패 시 null을 반환한다
      return null;
    }
  }

  /// 날짜를 사용자 친화적인 형식으로 포맷하는 헬퍼 함수
  static String formatDate(DateTime date) {
    // YYYY년 MM월 DD일 형식으로 변환한다
    return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
  }

  /// 시간을 사용자 친화적인 형식으로 포맷하는 헬퍼 함수
  static String formatTime(DateTime time) {
    // HH:MM 형식으로 변환한다
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 날짜와 시간을 모두 포맷하는 헬퍼 함수
  static String formatDateTime(DateTime dateTime) {
    // YYYY년 MM월 DD일 HH:MM 형식으로 변환한다
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }
}
