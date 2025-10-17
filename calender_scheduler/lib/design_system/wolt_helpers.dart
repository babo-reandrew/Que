import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../providers/bottom_sheet_controller.dart';
import 'wolt_page_builders.dart';

/// Wolt Modal Sheet Helper Functions
///
/// Wolt Modal Sheet을 쉽게 사용할 수 있도록 도와주는 헬퍼 함수 모음입니다.
/// 기존의 showModalBottomSheet 호출을 간단하게 대체할 수 있습니다.

// ========================================
// 리마인더 옵션 모달
// ========================================

/// 리마인더 설정 Wolt 모달 표시
///
/// [context]: BuildContext
/// [initialReminder]: 초기 리마인더 설정값 (JSON 문자열, optional)
///
/// 사용법:
/// ```dart
/// showWoltReminderOption(context);
/// ```
void showWoltReminderOption(BuildContext context, {String? initialReminder}) {
  // Provider에서 BottomSheetController 가져오기
  final controller = Provider.of<BottomSheetController>(context, listen: false);

  // 초기값 설정 (전달된 값이 있으면 사용)
  if (initialReminder != null && initialReminder.isNotEmpty) {
    controller.updateReminder(initialReminder);
  }

  // Wolt Modal Sheet 표시
  WoltModalSheet.show(
    context: context,
    pageListBuilder: (context) => [buildReminderOptionPage(context)],
    modalTypeBuilder: (context) {
      return WoltModalType.bottomSheet();
    },
    onModalDismissedWithBarrierTap: () {
      debugPrint('🔔 [WoltHelper] 리마인더 모달 닫힘 (배경 탭)');
    },
  );
}

// ========================================
// 반복 옵션 모달
// ========================================
// 반복 설정 모달 (3개 토글 페이지)
// ========================================

/// 반복 설정 Wolt 모달 표시 (3개 페이지: 毎日/毎月/間隔)
///
/// [context]: BuildContext
/// [initialRepeatRule]: 초기 반복 규칙 설정값 (JSON 문자열, optional)
///
/// **Figma 디자인:**
/// - 페이지 1: 毎日 (요일 선택)
/// - 페이지 2: 毎月 (날짜 그리드)
/// - 페이지 3: 間隔 (간격 리스트)
///
/// 사용법:
/// ```dart
/// showWoltRepeatOption(context);
/// ```
void showWoltRepeatOption(BuildContext context, {String? initialRepeatRule}) {
  // Provider에서 BottomSheetController 가져오기
  final controller = Provider.of<BottomSheetController>(context, listen: false);

  // 초기값 설정 (전달된 값이 있으면 사용)
  if (initialRepeatRule != null && initialRepeatRule.isNotEmpty) {
    controller.updateRepeatRule(initialRepeatRule);
  }

  // 페이지 인덱스 관리
  final pageIndexNotifier = ValueNotifier<int>(0);

  // Wolt Modal Sheet 표시 (다중 페이지)
  WoltModalSheet.show(
    context: context,
    pageIndexNotifier: pageIndexNotifier,
    pageListBuilder: (context) => [
      buildRepeatDailyPage(context, pageIndexNotifier), // 0: 毎日
      buildRepeatMonthlyPage(context, pageIndexNotifier), // 1: 毎月
      buildRepeatIntervalPage(context, pageIndexNotifier), // 2: 間隔
    ],
    modalTypeBuilder: (context) {
      return WoltModalType.bottomSheet();
    },
    onModalDismissedWithBarrierTap: () {
      debugPrint('🔄 [WoltHelper] 반복 모달 닫힘 (배경 탭)');
      pageIndexNotifier.dispose();
    },
  );
}

// ========================================
// 색상 선택 모달
// ========================================

/// 색상 선택 Wolt 모달 표시
///
/// [context]: BuildContext
/// [initialColorId]: 초기 색상 ID (String, optional) - 'gray', 'blue', 'green' 등
///
/// 사용법:
/// ```dart
/// showWoltColorPicker(context, initialColorId: 'blue');
/// ```
void showWoltColorPicker(BuildContext context, {String? initialColorId}) {
  // Provider에서 BottomSheetController 가져오기
  final controller = Provider.of<BottomSheetController>(context, listen: false);

  // 초기값 설정 (전달된 값이 있으면 사용)
  if (initialColorId != null) {
    controller.updateColor(initialColorId);
  }

  // Wolt Modal Sheet 표시
  WoltModalSheet.show(
    context: context,
    pageListBuilder: (context) => [buildColorPickerPage(context)],
    modalTypeBuilder: (context) {
      return WoltModalType.bottomSheet();
    },
    onModalDismissedWithBarrierTap: () {
      debugPrint('🎨 [WoltHelper] 색상 선택 모달 닫힘 (배경 탭)');
    },
  );
}
