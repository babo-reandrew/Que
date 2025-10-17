import '../validators/validation_result.dart';
import '../validators/date_time_validators.dart';
import '../../Database/schedule_database.dart'; // ⭐️ DB 통합: Drift의 ScheduleData 사용
import '../../const/color.dart'; // categoryColorMap을 사용하기 위한 import

/// 이벤트(스케줄) 전용 검증 로직을 담당하는 클래스
/// Schedule 모델의 모든 필드에 대한 포괄적인 검증을 제공한다
class EventValidators {
  // ===== 필수 정보 검증 =====

  /// 제목(summary)을 검증하는 함수 - null/빈값, 길이 제한, XSS 방지를 수행한다
  static String? validateTitle(String? value) {
    // 1. null 또는 빈 문자열 체크 - 제목은 필수 입력 사항이다
    if (value == null || value.trim().isEmpty) {
      return '제목을 입력해주세요';
    }

    // 2. 공백만 있는지 체크 - 실제 내용이 있어야 한다
    if (value.trim().isEmpty) {
      return '제목에 내용을 입력해주세요';
    }

    // 3. 최소 길이 검증 - 너무 짧은 제목을 방지한다
    if (value.trim().length < 2) {
      return '제목은 최소 2자 이상이어야 합니다';
    }

    // 4. 최대 길이 검증 - 데이터베이스 제한과 UI 표시를 고려한다
    if (value.length > 100) {
      return '제목은 최대 100자까지 입력 가능합니다 (현재: ${value.length}자)';
    }

    // 5. XSS 방지 - 위험한 HTML 태그가 있는지 확인한다
    final dangerousPattern = RegExp(
      r'<script|<iframe|javascript:|onerror=',
      caseSensitive: false,
    );
    if (dangerousPattern.hasMatch(value)) {
      return '제목에 허용되지 않는 문자가 포함되어 있습니다';
    }

    // 6. 특수문자 과다 사용 경고 - 너무 많은 특수문자는 스팸으로 간주될 수 있다
    final specialCharCount = value
        .replaceAll(RegExp(r'[a-zA-Z0-9가-힣\s]'), '')
        .length;
    if (specialCharCount > value.length * 0.3) {
      return '특수문자가 너무 많습니다';
    }

    // 7. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 시작 시간을 검증하는 함수 - null 체크와 유효성을 확인한다
  static String? validateStartTime(DateTime? startTime) {
    // 1. null 체크 - 시작 시간은 필수다
    if (startTime == null) {
      return '시작 시간을 입력해주세요';
    }

    // 2. DateTime 유효성을 검증한다
    return DateTimeValidators.validateDateTime(startTime);
  }

  /// 종료 시간을 검증하는 함수 - null 체크와 유효성을 확인한다
  static String? validateEndTime(DateTime? endTime) {
    // 1. null 체크 - 종료 시간은 필수다
    if (endTime == null) {
      return '종료 시간을 입력해주세요';
    }

    // 2. DateTime 유효성을 검증한다
    return DateTimeValidators.validateDateTime(endTime);
  }

  // ===== 시간 유효성 검증 =====

  /// 시간 순서를 검증하는 함수 - 시작 시간이 종료 시간보다 이전인지 확인한다
  static String? validateTimeOrder(DateTime? startTime, DateTime? endTime) {
    return DateTimeValidators.validateTimeOrder(startTime, endTime);
  }

  /// 과거 시간 생성을 방지하는 함수 - 선택적으로 과거 일정을 차단한다
  static String? validateFutureTime(
    DateTime? dateTime, {
    bool allowPast = true, // 기본적으로 과거 일정을 허용한다
  }) {
    return DateTimeValidators.validateFutureTime(
      dateTime,
      allowPast: allowPast,
    );
  }

  /// 이벤트 지속 시간을 검증하는 함수 - 적절한 일정 길이인지 확인한다
  static String? validateEventDuration(DateTime? startTime, DateTime? endTime) {
    // 1. 최소 지속 시간 5분, 최대 지속 시간 168시간(7일)으로 설정한다
    return DateTimeValidators.validateEventDuration(
      startTime,
      endTime,
      minDuration: const Duration(minutes: 5), // 최소 5분
      maxDuration: const Duration(days: 7), // 최대 7일
    );
  }

  // ===== 데이터 형식 검증 =====

  /// 설명(description)을 검증하는 함수 - 최대 길이와 위험한 문자를 체크한다
  static String? validateDescription(String? value) {
    // 1. null 체크 - description은 선택 사항이므로 null이어도 된다
    if (value == null || value.isEmpty) {
      return null; // 선택 필드이므로 비어있어도 괜찮다
    }

    // 2. 최대 길이 검증 - 너무 긴 설명을 방지한다
    if (value.length > 1000) {
      return '설명은 최대 1000자까지 입력 가능합니다 (현재: ${value.length}자)';
    }

    // 3. 위험한 문자 필터링 - XSS 공격을 방지한다
    final filteredError = filterDangerousCharacters(value);
    if (filteredError != null) {
      return filteredError;
    }

    // 4. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 위치(location)를 검증하는 함수 - 주소 형식을 기본적으로 검증한다
  static String? validateLocation(String? value) {
    // 1. null 체크 - location은 선택 사항이므로 null이어도 된다
    if (value == null || value.isEmpty) {
      return null; // 선택 필드이므로 비어있어도 괜찮다
    }

    // 2. 최대 길이 검증 - 너무 긴 주소를 방지한다
    if (value.length > 200) {
      return '위치는 최대 200자까지 입력 가능합니다 (현재: ${value.length}자)';
    }

    // 3. 위험한 문자 필터링 - XSS 공격을 방지한다
    final filteredError = filterDangerousCharacters(value);
    if (filteredError != null) {
      return filteredError;
    }

    // 4. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 위험한 문자를 필터링하는 함수 - 스크립트 태그, SQL 인젝션 등을 방지한다
  static String? filterDangerousCharacters(String? value) {
    // 1. null 체크 - null이면 null을 반환한다
    if (value == null || value.isEmpty) {
      return null;
    }

    // 2. HTML/Script 태그 검증 - XSS 공격을 방지한다
    final scriptPattern = RegExp(
      r'<script|</script|<iframe|</iframe|javascript:|onerror=|onclick=|onload=',
      caseSensitive: false,
    );
    if (scriptPattern.hasMatch(value)) {
      return '허용되지 않는 HTML 태그나 스크립트가 포함되어 있습니다';
    }

    // 3. SQL 인젝션 패턴 검증 - 데이터베이스 공격을 방지한다
    final sqlPattern = RegExp(
      r"('(''|[^'])*')|(;)|(\b(ALTER|CREATE|DELETE|DROP|EXEC(UTE)?|INSERT( +INTO)?|MERGE|SELECT|UPDATE|UNION( +ALL)?)\b)",
      caseSensitive: false,
    );
    if (sqlPattern.hasMatch(value)) {
      return '허용되지 않는 SQL 명령어가 포함되어 있습니다';
    }

    // 4. 제어 문자 검증 - null 문자나 제어 문자를 방지한다
    if (value.contains(RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F]'))) {
      return '허용되지 않는 제어 문자가 포함되어 있습니다';
    }

    // 5. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  // ===== 논리적 일관성 검증 =====

  /// 종일 이벤트를 검증하는 함수 - 종일 이벤트의 시간 설정이 올바른지 확인한다
  static String? validateAllDayEvent(
    bool isAllDay,
    DateTime? startTime,
    DateTime? endTime,
  ) {
    // 1. 종일 이벤트가 아니면 검증하지 않는다
    if (!isAllDay) {
      return null;
    }

    // 2. null 체크 - 종일 이벤트도 시간이 필요하다
    if (startTime == null || endTime == null) {
      return '종일 이벤트도 시작 시간과 종료 시간이 필요합니다';
    }

    // 3. 종일 이벤트는 시간이 00:00이어야 한다
    if (startTime.hour != 0 || startTime.minute != 0) {
      return '종일 이벤트의 시작 시간은 00:00이어야 합니다';
    }

    // 4. 종일 이벤트는 종료 시간이 23:59 또는 다음날 00:00이어야 한다
    final isValidEndTime =
        (endTime.hour == 23 && endTime.minute == 59) ||
        (endTime.hour == 0 && endTime.minute == 0);
    if (!isValidEndTime) {
      return '종일 이벤트의 종료 시간은 23:59 또는 다음날 00:00이어야 합니다';
    }

    // 5. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 반복 패턴을 검증하는 함수 - 반복 일정의 유효성을 확인한다
  static String? validateRecurrence(
    String? recurrencePattern,
    DateTime? endDate,
  ) {
    // 1. null 체크 - 반복 패턴이 없으면 검증하지 않는다
    if (recurrencePattern == null || recurrencePattern.isEmpty) {
      return null; // 선택 필드이므로 비어있어도 괜찮다
    }

    // 2. 유효한 반복 패턴인지 확인한다
    final validPatterns = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];
    if (!validPatterns.contains(recurrencePattern.toUpperCase())) {
      return '유효하지 않은 반복 패턴입니다 (DAILY, WEEKLY, MONTHLY, YEARLY 중 선택)';
    }

    // 3. 반복 일정에는 종료 날짜가 권장된다
    if (endDate == null) {
      return null; // 경고로 처리할 수 있지만, 여기서는 허용한다
    }

    // 4. 종료 날짜가 미래여야 한다
    final now = DateTime.now();
    if (endDate.isBefore(now)) {
      return '반복 일정의 종료 날짜는 현재보다 미래여야 합니다';
    }

    // 5. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 우선순위를 검증하는 함수 - 1-5 범위 내의 값인지 확인한다
  static String? validatePriority(int? priority) {
    // 1. null 체크 - priority는 선택 사항이므로 null이어도 된다
    if (priority == null) {
      return null; // 선택 필드이므로 비어있어도 괜찮다
    }

    // 2. 우선순위 범위 검증 - 1(낮음)부터 5(높음)까지만 유효하다
    if (priority < 1 || priority > 5) {
      return '우선순위는 1(낮음)부터 5(높음) 사이여야 합니다';
    }

    // 3. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 색상 ID를 검증하는 함수 - 유효한 색상인지 확인한다
  static String? validateColorId(String? colorId) {
    // 1. null 체크 - colorId는 선택 사항이므로 null이어도 된다
    if (colorId == null || colorId.isEmpty) {
      print('🎨 색상 검증: colorId가 null 또는 빈 값 → 기본값 사용 가능'); // 디버깅: null/빈값 케이스
      return null; // 선택 필드이므로 비어있어도 괜찮다
    }

    // 2. 유효한 색상 ID 목록 - categoryColorMap의 key들을 사용한다
    // 이렇게 하면 실제 color.dart에 정의된 색상들만 허용된다
    final validColorIds = categoryColorMap.keys.toList();
    print('🎨 색상 검증: 허용된 색상 목록 = $validColorIds'); // 디버깅: 허용된 색상 목록 출력

    // 3. 입력된 색상 ID를 소문자로 변환한다
    final normalizedColorId = colorId.toLowerCase();
    print(
      '🎨 색상 검증: 입력된 colorId = "$colorId" → 정규화 = "$normalizedColorId"',
    ); // 디버깅: 정규화 과정 출력

    // 4. 색상 ID가 유효한지 확인한다
    if (!validColorIds.contains(normalizedColorId)) {
      print('❌ 색상 검증 실패: "$normalizedColorId"는 허용된 색상이 아님'); // 디버깅: 검증 실패
      return '유효하지 않은 색상입니다';
    }

    // 5. 모든 검증을 통과하면 null을 반환한다
    print('✅ 색상 검증 성공: "$normalizedColorId"는 유효한 색상'); // 디버깅: 검증 성공
    return null;
  }

  /// 상태(status)를 검증하는 함수 - 유효한 상태 값인지 확인한다
  static String? validateStatus(String? status) {
    // 1. null 체크 - status는 선택 사항이므로 null이어도 된다
    if (status == null || status.isEmpty) {
      return null; // 선택 필드이므로 비어있어도 괜찮다
    }

    // 2. 유효한 상태 값 목록 - 구글 캘린더 API 표준 참고
    final validStatuses = ['confirmed', 'tentative', 'cancelled'];

    // 3. 상태 값이 유효한지 확인한다
    if (!validStatuses.contains(status.toLowerCase())) {
      return '유효하지 않은 상태입니다 (confirmed, tentative, cancelled 중 선택)';
    }

    // 4. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 가시성(visibility)을 검증하는 함수 - 유효한 가시성 설정인지 확인한다
  static String? validateVisibility(String? visibility) {
    // 1. null 체크 - visibility는 선택 사항이므로 null이어도 된다
    if (visibility == null || visibility.isEmpty) {
      return null; // 선택 필드이므로 비어있어도 괜찮다
    }

    // 2. 유효한 가시성 값 목록 - 구글 캘린더 API 표준 참고
    final validVisibilities = ['default', 'public', 'private', 'confidential'];

    // 3. 가시성 값이 유효한지 확인한다
    if (!validVisibilities.contains(visibility.toLowerCase())) {
      return '유효하지 않은 가시성 설정입니다 (default, public, private, confidential 중 선택)';
    }

    // 4. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  // ===== 충돌 검증 =====

  /// 시간 충돌을 검증하는 함수 - 기존 일정과 시간이 겹치는지 확인한다
  static String? validateTimeConflict(
    DateTime startTime,
    DateTime endTime,
    List<ScheduleData> existingEvents,
  ) {
    // 1. 기존 이벤트가 없으면 충돌이 없다
    if (existingEvents.isEmpty) {
      return null;
    }

    // 2. 각 기존 이벤트와 시간이 겹치는지 확인한다
    for (final event in existingEvents) {
      // 시간 겹침 조건:
      // - 새로운 일정의 시작이 기존 일정 중간에 있거나
      // - 새로운 일정의 종료가 기존 일정 중간에 있거나
      // - 새로운 일정이 기존 일정을 완전히 포함하거나
      final hasConflict =
          (startTime.isBefore(event.end) && endTime.isAfter(event.start));

      if (hasConflict) {
        // 충돌하는 일정의 제목과 시간을 포함한 구체적인 에러 메시지를 반환한다
        final conflictTitle = event.summary; // ⭐️ DB 통합: summary는 non-nullable
        final conflictTime = DateTimeValidators.formatTime(event.start);
        return '기존 일정과 시간이 겹칩니다: "$conflictTitle" ($conflictTime)';
      }
    }

    // 3. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  /// 중요 이벤트 충돌 경고를 생성하는 함수 - 중요한 일정과 겹치면 경고를 제공한다
  static List<String> getConflictWarnings(
    DateTime startTime,
    DateTime endTime,
    List<ScheduleData> importantEvents,
  ) {
    final warnings = <String>[];

    // 1. 중요 이벤트가 없으면 경고가 없다
    if (importantEvents.isEmpty) {
      return warnings;
    }

    // 2. 각 중요 이벤트와 시간이 겹치는지 확인한다
    for (final event in importantEvents) {
      final hasConflict =
          (startTime.isBefore(event.end) && endTime.isAfter(event.start));

      if (hasConflict) {
        // 중요 일정과 겹친다는 경고를 추가한다
        final conflictTitle = event.summary; // ⭐️ DB 통합: summary는 non-nullable
        final conflictTime = DateTimeValidators.formatTime(event.start);
        warnings.add('⚠️ 중요 일정과 시간이 겹칩니다: "$conflictTitle" ($conflictTime)');
      }
    }

    // 3. 모든 경고를 반환한다
    return warnings;
  }

  /// 동시 이벤트 개수를 검증하는 함수 - 같은 시간에 너무 많은 일정이 있으면 경고한다
  static String? validateConcurrentEventsLimit(
    DateTime startTime,
    DateTime endTime,
    List<ScheduleData> existingEvents, {
    int maxConcurrentEvents = 3, // 최대 동시 이벤트 개수
  }) {
    // 1. 겹치는 이벤트 개수를 센다
    int concurrentCount = 0;
    for (final event in existingEvents) {
      final hasOverlap =
          (startTime.isBefore(event.end) && endTime.isAfter(event.start));
      if (hasOverlap) {
        concurrentCount++;
      }
    }

    // 2. 최대 개수를 초과하면 경고를 반환한다
    if (concurrentCount >= maxConcurrentEvents) {
      return '같은 시간대에 이미 $concurrentCount개의 일정이 있습니다. 일정 관리에 어려움이 있을 수 있습니다.';
    }

    // 3. 모든 검증을 통과하면 null을 반환한다
    return null;
  }

  // ===== 종합 검증 메소드 =====

  /// 완전한 이벤트를 종합적으로 검증하는 함수
  /// 모든 필드를 검증하고 ValidationResult 객체를 반환한다
  static ValidationResult validateCompleteEvent({
    required String? title, // 제목 (필수)
    String? description, // 설명 (선택)
    String? location, // 위치 (선택)
    required DateTime? startTime, // 시작 시간 (필수)
    required DateTime? endTime, // 종료 시간 (필수)
    bool isAllDay = false, // 종일 이벤트 여부
    String? recurrencePattern, // 반복 패턴
    DateTime? recurrenceEndDate, // 반복 종료 날짜
    int? priority, // 우선순위
    String? colorId, // 색상 ID
    String? status, // 상태
    String? visibility, // 가시성
    List<ScheduleData> existingEvents = const [], // 기존 이벤트 목록
    List<ScheduleData> importantEvents = const [], // 중요 이벤트 목록
    bool allowPastEvents = true, // 과거 이벤트 허용 여부
  }) {
    // 1. 에러 맵과 경고 리스트를 초기화한다
    final Map<String, String> errors = {};
    final List<String> warnings = [];

    // 2. 필수 필드 검증 - title, startTime, endTime
    final titleError = validateTitle(title);
    if (titleError != null) {
      errors['title'] = titleError; // 제목 에러를 맵에 추가한다
    }

    final startTimeError = validateStartTime(startTime);
    if (startTimeError != null) {
      errors['startTime'] = startTimeError; // 시작 시간 에러를 맵에 추가한다
    }

    final endTimeError = validateEndTime(endTime);
    if (endTimeError != null) {
      errors['endTime'] = endTimeError; // 종료 시간 에러를 맵에 추가한다
    }

    // 3. 시간 순서 검증 - 시작 시간이 종료 시간보다 이전인지 확인한다
    if (startTime != null && endTime != null) {
      final timeOrderError = validateTimeOrder(startTime, endTime);
      if (timeOrderError != null) {
        errors['timeOrder'] = timeOrderError;
      }

      // 4. 이벤트 지속 시간 검증 - 적절한 길이인지 확인한다
      final durationError = validateEventDuration(startTime, endTime);
      if (durationError != null) {
        errors['duration'] = durationError;
      }

      // 5. 권장 지속 시간 검증 - 24시간을 초과하면 경고를 추가한다
      final durationWarning = DateTimeValidators.validateRecommendedDuration(
        startTime,
        endTime,
      );
      if (durationWarning != null) {
        warnings.add(durationWarning);
      }

      // 6. 타임존 일관성 검증 - 시작과 종료의 타임존이 같은지 확인한다
      final timezoneError = DateTimeValidators.validateTimezoneConsistency(
        startTime,
        endTime,
      );
      if (timezoneError != null) {
        errors['timezone'] = timezoneError;
      }
    }

    // 7. 선택 필드 검증 - description, location
    final descriptionError = validateDescription(description);
    if (descriptionError != null) {
      errors['description'] = descriptionError;
    }

    final locationError = validateLocation(location);
    if (locationError != null) {
      errors['location'] = locationError;
    }

    // 8. 논리적 일관성 검증 - 종일 이벤트, 반복 패턴, 우선순위
    final allDayError = validateAllDayEvent(isAllDay, startTime, endTime);
    if (allDayError != null) {
      errors['allDay'] = allDayError;
    }

    final recurrenceError = validateRecurrence(
      recurrencePattern,
      recurrenceEndDate,
    );
    if (recurrenceError != null) {
      errors['recurrence'] = recurrenceError;
    }

    final priorityError = validatePriority(priority);
    if (priorityError != null) {
      errors['priority'] = priorityError;
    }

    final colorError = validateColorId(colorId);
    if (colorError != null) {
      errors['colorId'] = colorError;
    }

    final statusError = validateStatus(status);
    if (statusError != null) {
      errors['status'] = statusError;
    }

    final visibilityError = validateVisibility(visibility);
    if (visibilityError != null) {
      errors['visibility'] = visibilityError;
    }

    // 9. 과거 시간 검증 - allowPastEvents가 false면 과거 일정을 차단한다
    if (startTime != null && !allowPastEvents) {
      final pastTimeError = validateFutureTime(startTime, allowPast: false);
      if (pastTimeError != null) {
        errors['pastTime'] = pastTimeError;
      }
    }

    // 10. 충돌 검증 - 기존 이벤트와 시간이 겹치는지 확인한다
    if (startTime != null && endTime != null && existingEvents.isNotEmpty) {
      final conflictError = validateTimeConflict(
        startTime,
        endTime,
        existingEvents,
      );
      if (conflictError != null) {
        errors['conflict'] = conflictError;
      }

      // 11. 동시 이벤트 개수 경고 - 너무 많은 일정이 겹치면 경고한다
      final concurrentWarning = validateConcurrentEventsLimit(
        startTime,
        endTime,
        existingEvents,
      );
      if (concurrentWarning != null) {
        warnings.add(concurrentWarning);
      }
    }

    // 12. 중요 이벤트 충돌 경고 - 중요한 일정과 겹치면 경고한다
    if (startTime != null && endTime != null && importantEvents.isNotEmpty) {
      final conflictWarnings = getConflictWarnings(
        startTime,
        endTime,
        importantEvents,
      );
      warnings.addAll(conflictWarnings);
    }

    // 13. 주말 일정 경고 - 주말에 일정을 추가하면 알림을 제공한다
    if (startTime != null && DateTimeValidators.isWeekend(startTime)) {
      warnings.add('주말에 일정이 추가됩니다');
    }

    // 14. 공휴일 일정 경고 - 공휴일에 일정을 추가하면 알림을 제공한다
    if (startTime != null && DateTimeValidators.isHoliday(startTime)) {
      warnings.add('공휴일에 일정이 추가됩니다');
    }

    // 15. ValidationResult 객체를 생성해서 반환한다
    final isValid = errors.isEmpty; // 에러가 없으면 검증 성공

    return ValidationResult(
      isValid: isValid,
      errors: errors,
      warnings: warnings,
    );
  }

  // ===== 빠른 검증 헬퍼 메소드 =====

  /// 제목만 빠르게 검증하는 함수 - 실시간 검증에 사용한다
  static bool isValidTitle(String? value) {
    return validateTitle(value) == null;
  }

  /// 시간 순서만 빠르게 검증하는 함수 - 실시간 검증에 사용한다
  static bool isValidTimeOrder(DateTime? startTime, DateTime? endTime) {
    return validateTimeOrder(startTime, endTime) == null;
  }

  /// 전체 이벤트가 유효한지 빠르게 확인하는 함수 - 최소 요구사항만 체크한다
  static bool isValidEvent({
    required String? title,
    required DateTime? startTime,
    required DateTime? endTime,
  }) {
    // 필수 필드만 검증한다
    return validateTitle(title) == null &&
        validateStartTime(startTime) == null &&
        validateEndTime(endTime) == null &&
        validateTimeOrder(startTime, endTime) == null;
  }

  // ===== 디버깅 헬퍼 메소드 =====

  /// 검증 결과를 콘솔에 출력하는 함수 - 디버깅 시 사용한다
  static void printValidationResult(ValidationResult result) {
    print('=== 검증 결과 ===');
    print('✅ 검증 성공: ${result.isValid}');

    if (result.hasErrors) {
      print('❌ 에러:');
      result.errors.forEach((field, message) {
        print('  - $field: $message');
      });
    }

    if (result.hasWarnings) {
      print('⚠️ 경고:');
      for (final warning in result.warnings) {
        print('  - $warning');
      }
    }

    if (result.isPerfect) {
      print('🎉 완벽합니다! 에러도 경고도 없습니다.');
    }

    print('=== 검증 결과 끝 ===\n');
  }
}
