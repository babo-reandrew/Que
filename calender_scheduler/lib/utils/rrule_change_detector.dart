// ✅ RRULE 변경 감지 로직
//
// **목적:**
// UI에서 반복 일정 수정 시 어떤 옵션을 표시할지 결정한다.
//
// **규칙:**
// 1. RRULE만 변경: ["이후 일정만", "모든 일정"] 표시
//    - "오늘만" 옵션 숨김 (RRULE 변경은 전체 시리즈에 영향)
// 2. 다른 속성만 변경: ["오늘만", "이후 일정만", "모든 일정"] 모두 표시
//
// **사용 예시:**
// ```dart
// final detector = RRuleChangeDetector();
// final options = detector.getAvailableOptions(
//   originalRRule: 'FREQ=DAILY;INTERVAL=1',
//   newRRule: 'FREQ=WEEKLY;INTERVAL=1',
//   otherPropertiesChanged: false,
// );
// // options = [ModifyOption.future, ModifyOption.all]
// ```

enum ModifyOption {
  thisOnly, // 오늘만
  future, // 이후 일정만
  all, // 모든 일정
}

class RRuleChangeDetector {
  /// ✅ RRULE 변경 여부 확인
  /// - 두 RRULE 문자열을 비교하여 변경 여부 반환
  /// - null 체크 포함
  bool isRRuleChanged({
    required String? originalRRule,
    required String? newRRule,
  }) {
    // null 처리: 둘 다 null이면 변경 없음
    if (originalRRule == null && newRRule == null) {
      return false;
    }

    // 하나만 null이면 변경됨
    if (originalRRule == null || newRRule == null) {
      return true;
    }

    // 빈 문자열 정규화 (빈 문자열과 null을 동일하게 처리)
    final normalizedOriginal = originalRRule.trim().isEmpty ? null : originalRRule;
    final normalizedNew = newRRule.trim().isEmpty ? null : newRRule;

    // 정규화 후 다시 비교
    if (normalizedOriginal == null && normalizedNew == null) {
      return false;
    }

    if (normalizedOriginal == null || normalizedNew == null) {
      return true;
    }

    // 문자열 비교
    return normalizedOriginal != normalizedNew;
  }

  /// ✅ 사용 가능한 수정 옵션 반환
  /// - RRULE만 변경: [future, all]
  /// - 다른 속성만 변경: [thisOnly, future, all]
  /// - RRULE + 다른 속성 변경: [future, all]
  List<ModifyOption> getAvailableOptions({
    required String? originalRRule,
    required String? newRRule,
    required bool otherPropertiesChanged,
  }) {
    final rruleChanged = isRRuleChanged(
      originalRRule: originalRRule,
      newRRule: newRRule,
    );

    if (rruleChanged) {
      // RRULE이 변경되면 "오늘만" 옵션 숨김
      return [ModifyOption.future, ModifyOption.all];
    } else if (otherPropertiesChanged) {
      // 다른 속성만 변경되면 모든 옵션 표시
      return [ModifyOption.thisOnly, ModifyOption.future, ModifyOption.all];
    } else {
      // 아무것도 변경되지 않음 (정상적으로는 이 경우가 없어야 함)
      return [];
    }
  }

  /// ✅ Schedule에 대한 변경 감지
  /// - summary, start, end, colorId, alertSetting, description, location 비교
  bool hasSchedulePropertiesChanged({
    required String? originalSummary,
    required String? newSummary,
    required DateTime? originalStart,
    required DateTime? newStart,
    required DateTime? originalEnd,
    required DateTime? newEnd,
    required String? originalColorId,
    required String? newColorId,
    required String? originalAlertSetting,
    required String? newAlertSetting,
    required String? originalDescription,
    required String? newDescription,
    required String? originalLocation,
    required String? newLocation,
  }) {
    return originalSummary != newSummary ||
        originalStart != newStart ||
        originalEnd != newEnd ||
        originalColorId != newColorId ||
        originalAlertSetting != newAlertSetting ||
        originalDescription != newDescription ||
        originalLocation != newLocation;
  }

  /// ✅ Task에 대한 변경 감지
  /// - title, executionDate, dueDate, colorId, reminder 비교
  bool hasTaskPropertiesChanged({
    required String? originalTitle,
    required String? newTitle,
    required DateTime? originalExecutionDate,
    required DateTime? newExecutionDate,
    required DateTime? originalDueDate,
    required DateTime? newDueDate,
    required String? originalColorId,
    required String? newColorId,
    required String? originalReminder,
    required String? newReminder,
  }) {
    return originalTitle != newTitle ||
        originalExecutionDate != newExecutionDate ||
        originalDueDate != newDueDate ||
        originalColorId != newColorId ||
        originalReminder != newReminder;
  }

  /// ✅ Habit에 대한 변경 감지
  /// - title, colorId, reminder 비교
  bool hasHabitPropertiesChanged({
    required String? originalTitle,
    required String? newTitle,
    required String? originalColorId,
    required String? newColorId,
    required String? originalReminder,
    required String? newReminder,
  }) {
    return originalTitle != newTitle ||
        originalColorId != newColorId ||
        originalReminder != newReminder;
  }
}

/// ✅ Schedule 수정 옵션 결정
List<ModifyOption> getScheduleModifyOptions({
  required String? originalRRule,
  required String? newRRule,
  required String? originalSummary,
  required String? newSummary,
  required DateTime? originalStart,
  required DateTime? newStart,
  required DateTime? originalEnd,
  required DateTime? newEnd,
  required String? originalColorId,
  required String? newColorId,
  required String? originalAlertSetting,
  required String? newAlertSetting,
  required String? originalDescription,
  required String? newDescription,
  required String? originalLocation,
  required String? newLocation,
}) {
  final detector = RRuleChangeDetector();

  final otherPropertiesChanged = detector.hasSchedulePropertiesChanged(
    originalSummary: originalSummary,
    newSummary: newSummary,
    originalStart: originalStart,
    newStart: newStart,
    originalEnd: originalEnd,
    newEnd: newEnd,
    originalColorId: originalColorId,
    newColorId: newColorId,
    originalAlertSetting: originalAlertSetting,
    newAlertSetting: newAlertSetting,
    originalDescription: originalDescription,
    newDescription: newDescription,
    originalLocation: originalLocation,
    newLocation: newLocation,
  );

  return detector.getAvailableOptions(
    originalRRule: originalRRule,
    newRRule: newRRule,
    otherPropertiesChanged: otherPropertiesChanged,
  );
}

/// ✅ Task 수정 옵션 결정
List<ModifyOption> getTaskModifyOptions({
  required String? originalRRule,
  required String? newRRule,
  required String? originalTitle,
  required String? newTitle,
  required DateTime? originalExecutionDate,
  required DateTime? newExecutionDate,
  required DateTime? originalDueDate,
  required DateTime? newDueDate,
  required String? originalColorId,
  required String? newColorId,
  required String? originalReminder,
  required String? newReminder,
}) {
  final detector = RRuleChangeDetector();

  final otherPropertiesChanged = detector.hasTaskPropertiesChanged(
    originalTitle: originalTitle,
    newTitle: newTitle,
    originalExecutionDate: originalExecutionDate,
    newExecutionDate: newExecutionDate,
    originalDueDate: originalDueDate,
    newDueDate: newDueDate,
    originalColorId: originalColorId,
    newColorId: newColorId,
    originalReminder: originalReminder,
    newReminder: newReminder,
  );

  return detector.getAvailableOptions(
    originalRRule: originalRRule,
    newRRule: newRRule,
    otherPropertiesChanged: otherPropertiesChanged,
  );
}

/// ✅ Habit 수정 옵션 결정
List<ModifyOption> getHabitModifyOptions({
  required String? originalRRule,
  required String? newRRule,
  required String? originalTitle,
  required String? newTitle,
  required String? originalColorId,
  required String? newColorId,
  required String? originalReminder,
  required String? newReminder,
}) {
  final detector = RRuleChangeDetector();

  final otherPropertiesChanged = detector.hasHabitPropertiesChanged(
    originalTitle: originalTitle,
    newTitle: newTitle,
    originalColorId: originalColorId,
    newColorId: newColorId,
    originalReminder: originalReminder,
    newReminder: newReminder,
  );

  return detector.getAvailableOptions(
    originalRRule: originalRRule,
    newRRule: newRRule,
    otherPropertiesChanged: otherPropertiesChanged,
  );
}
