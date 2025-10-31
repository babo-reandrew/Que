/// EntityValidators - Task와 Habit의 검증 로직 통합
/// 이거를 설정하고 → 공통 검증 로직을 하나의 파일로 통합해서
/// 이거를 해서 → 코드 중복을 최소화하고
/// 이거는 이래서 → 유지보수가 쉬워진다
class EntityValidators {
  // ========================================
  // Task (할일) 검증
  // ========================================

  /// 할일 제목 검증
  /// 이거를 설정하고 → 제목이 비어있지 않은지 확인해서
  /// 이거를 해서 → 필수 입력을 보장한다
  static String? validateTaskTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return '할일 제목을 입력해주세요';
    }
    if (title.trim().length > 200) {
      return '제목은 200자 이내로 입력해주세요';
    }
    return null; // 검증 통과
  }

  /// 할일 마감일 검증
  /// 이거를 설정하고 → 마감일이 유효한지 확인해서
  /// 이거를 해서 → 논리적으로 올바른 날짜를 보장한다
  static String? validateTaskDueDate(DateTime? dueDate) {
    // 마감일은 선택사항이므로 null 허용
    if (dueDate == null) return null;

    // 과거 날짜 경고 (허용은 하되 경고만)
    final now = DateTime.now();
    if (dueDate.isBefore(now)) {
      return '마감일이 과거입니다. 계속하시겠습니까?';
    }

    return null; // 검증 통과
  }

  /// 할일 전체 검증
  /// 이거를 설정하고 → 모든 필드를 종합적으로 검증해서
  /// 이거를 해서 → 저장 전 완전한 유효성을 보장한다
  static Map<String, dynamic> validateCompleteTask({
    required String? title,
    required DateTime? dueDate,
    required String colorId,
  }) {
    final errors = <String, String>{};
    final warnings = <String>[];

    // 1. 제목 검증
    final titleError = validateTaskTitle(title);
    if (titleError != null) {
      errors['title'] = titleError;
    }

    // 2. 마감일 검증
    final dueDateWarning = validateTaskDueDate(dueDate);
    if (dueDateWarning != null) {
      warnings.add(dueDateWarning);
    }

    // 3. 색상 ID 검증
    if (colorId.isEmpty) {
      errors['colorId'] = '색상을 선택해주세요';
    }

    return {'isValid': errors.isEmpty, 'errors': errors, 'warnings': warnings};
  }

  // ========================================
  // Habit (습관) 검증
  // ========================================

  /// 습관 제목 검증
  /// 이거를 설정하고 → 제목이 비어있지 않은지 확인해서
  /// 이거를 해서 → 필수 입력을 보장한다
  static String? validateHabitTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return '습관 제목을 입력해주세요';
    }
    if (title.trim().length > 200) {
      return '제목은 200자 이내로 입력해주세요';
    }
    return null; // 검증 통과
  }

  /// 습관 반복 주기 검증
  /// 이거를 설정하고 → 반복 주기 JSON이 유효한지 확인해서
  /// 이거를 해서 → 올바른 형식을 보장한다
  static String? validateHabitRepeatRule(String? repeatRule) {
    if (repeatRule == null || repeatRule.trim().isEmpty) {
      return '반복 주기를 설정해주세요';
    }

    // JSON 형식 검증 (간단히 {} 포함 여부 확인)
    if (!repeatRule.contains('{') || !repeatRule.contains('}')) {
      return '반복 주기 형식이 올바르지 않습니다';
    }

    return null; // 검증 통과
  }

  /// 습관 전체 검증
  /// 이거를 설정하고 → 모든 필드를 종합적으로 검증해서
  /// 이거를 해서 → 저장 전 완전한 유효성을 보장한다
  static Map<String, dynamic> validateCompleteHabit({
    required String? title,
    required String? repeatRule,
    required String colorId,
  }) {
    final errors = <String, String>{};
    final warnings = <String>[];

    // 1. 제목 검증
    final titleError = validateHabitTitle(title);
    if (titleError != null) {
      errors['title'] = titleError;
    }

    // 2. 반복 주기 검증
    final repeatError = validateHabitRepeatRule(repeatRule);
    if (repeatError != null) {
      errors['repeatRule'] = repeatError;
    }

    // 3. 색상 ID 검증
    if (colorId.isEmpty) {
      errors['colorId'] = '색상을 선택해주세요';
    }

    return {'isValid': errors.isEmpty, 'errors': errors, 'warnings': warnings};
  }

  // ========================================
  // 디버깅 헬퍼
  // ========================================

  /// 검증 결과를 콘솔에 출력
  static void printValidationResult(Map<String, dynamic> result, String type) {

    final errors = result['errors'] as Map<String, String>;
    if (errors.isNotEmpty) {
      errors.forEach((field, message) {
      });
    }

    final warnings = result['warnings'] as List<String>;
    if (warnings.isNotEmpty) {
      for (var warning in warnings) {
      }
    }

  }
}
