import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ TextInputFormatter
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column; // ✅ Column 충돌 방지
import 'package:get_it/get_it.dart'; // ✅ GetIt import
import 'package:figma_squircle/figma_squircle.dart';
import 'package:rrule/rrule.dart';

import '../../design_system/wolt_helpers.dart';
import '../../Database/schedule_database.dart'; // ScheduleData, AppDatabase
import '../../providers/bottom_sheet_controller.dart';
import '../../providers/habit_form_controller.dart';
import '../../utils/temp_input_cache.dart'; // ✅ 임시 캐시
import 'package:flutter_svg/flutter_svg.dart'; // ✅ SVG 지원
import '../../const/color.dart'; // ✅ 색상 맵핑
import 'discard_changes_modal.dart'; // ✅ 변경 취소 확인 모달
import 'delete_confirmation_modal.dart'; // ✅ 삭제 확인 모달
import 'delete_repeat_confirmation_modal.dart'; // ✅ 반복 삭제 확인 모달
import 'edit_repeat_confirmation_modal.dart'; // ✅ 반복 수정 확인 모달
import '../toast/action_toast.dart'; // ✅ 변경 토스트
import '../toast/save_toast.dart'; // ✅ 저장 토스트

/// 습관 상세 Wolt Modal Sheet
///
/// **Figma Design Spec (ULTRA PRECISE - 100% Match):**
///
/// **Modal Container:**
/// - Size: 393 x 409px
/// - Background: #FCFCFC
/// - Border: 1px solid rgba(17, 17, 17, 0.1)
/// - Shadow: 0px 2px 20px rgba(165, 165, 165, 0.2)
/// - Border radius: 36px 36px 0px 0px
///
/// **TopNavi (60px):**
/// - Padding: 9px 28px
/// - Gap: 205px (space-between)
/// - Title: "ルーティン" - Bold 16px, #505050
/// - Button: "完了" - ExtraBold 13px, #FAFAFA on #111111, 74x42px, radius 16px
///
/// **Main Layout:**
/// - Padding: 32px 0px 66px
/// - Gap: 12px between sections
/// - Align: flex-start (좌측 정렬)
///
/// **TextField:**
/// - Padding: 12px 0px (vertical only)
/// - Inner padding: 0px 24px (horizontal)
/// - Placeholder: "新しいルーティンを記録" - Bold 19px, #AAAAAA
/// - Text: Bold 19px, #111111
///
/// **DetailOptions:**
/// - Container padding: 0px 22px
/// - Gap: 8px between buttons
/// - Align: 좌측 정렬
/// - Button size: 64x64px
/// - Order: 반복(repeat) → 리마인더(notification) → 색상(palette)
///
/// **Delete Button:**
/// - Container padding: 0px 24px
/// - Size: 100x52px
/// - Padding: 16px 24px
/// - Gap: 6px (icon + text)
/// - Icon: 20x20px, #F74A4A
/// - Text: "削除" - Bold 13px, #F74A4A
/// Figma Design Spec (ULTRA PRECISE - 100% Match)
Future<void> showHabitDetailWoltModal(
  BuildContext context, {
  required HabitData? habit, // ✅ nullable로 변경 (새 습관 생성 지원)
  required DateTime selectedDate,
}) async {
  // Provider 초기화 (모달 띄우기 전에!)
  final habitController = Provider.of<HabitFormController>(
    context,
    listen: false,
  );
  final bottomSheetController = Provider.of<BottomSheetController>(
    context,
    listen: false,
  );

  if (habit != null) {
    // 기존 습관 수정
    habitController.titleController.text = habit.title;
    habitController.setHabitTime(habit.createdAt); // 생성일을 시간으로 사용
    bottomSheetController.updateColor(habit.colorId);
    bottomSheetController.updateReminder(habit.reminder);
    bottomSheetController.updateRepeatRule(habit.repeatRule);
  } else {
    // 새 습관 생성
    habitController.reset();
    bottomSheetController.reset(); // ✅ Provider 초기화

    // 🎯 통합 캐시에서 공통 데이터 복원
    final commonData = await TempInputCache.getCommonData();

    if (commonData['title'] != null && commonData['title']!.isNotEmpty) {
      habitController.titleController.text = commonData['title']!;
      debugPrint('✅ [HabitWolt] 통합 제목 복원: ${commonData['title']}');
    }

    if (commonData['colorId'] != null && commonData['colorId']!.isNotEmpty) {
      bottomSheetController.updateColor(commonData['colorId']!);
      debugPrint('✅ [HabitWolt] 통합 색상 복원: ${commonData['colorId']}');
    }

    if (commonData['reminder'] != null && commonData['reminder']!.isNotEmpty) {
      bottomSheetController.updateReminder(commonData['reminder']!);
      debugPrint('✅ [HabitWolt] 통합 리마인더 복원: ${commonData['reminder']}');
    }

    // 🎯 습관은 항상 반복규칙 필수
    // 1. 통합 캐시에 반복규칙이 있으면 복원
    // 2. 없으면 기본값(매일) 사용
    if (commonData['repeatRule'] != null &&
        commonData['repeatRule']!.isNotEmpty) {
      bottomSheetController.updateRepeatRule(commonData['repeatRule']!);
      debugPrint('✅ [HabitWolt] 통합 반복규칙 복원: ${commonData['repeatRule']}');
    } else {
      // 기본 반복 규칙: 매일 (주 7일 전체)
      final defaultRepeatRule =
          '{"type":"daily","weekdays":[1,2,3,4,5,6,7],"display":"毎日"}';
      bottomSheetController.updateRepeatRule(defaultRepeatRule);
      debugPrint('✅ [HabitWolt] 기본 반복 규칙 설정: 毎日 (7일)');
    }

    // 🎯 통합 캐시에서 습관 전용 데이터 복원
    final habitData = await TempInputCache.getHabitData();
    if (habitData != null && habitData['habitTime'] != null) {
      habitController.setHabitTime(habitData['habitTime']);
      debugPrint('✅ [HabitWolt] 통합 습관 시간 복원: ${habitData['habitTime']}');
    }
  }

  debugPrint('✅ [HabitWolt] Provider 초기화 완료');

  // 🎯 자동 캐시 저장: 제목 변경 시
  void autoSaveTitle() {
    if (habit == null) {
      // 새 항목일 때만 캐시 저장
      TempInputCache.saveCommonData(
        title: habitController.titleController.text,
        colorId: bottomSheetController.selectedColor,
        reminder: bottomSheetController.reminder,
        repeatRule: bottomSheetController.repeatRule,
      );
    }
  }

  // 🎯 자동 캐시 저장: 습관 시간 변경 시
  void autoSaveHabitData() {
    if (habit == null && habitController.habitTime != null) {
      // 새 항목일 때만 캐시 저장
      TempInputCache.saveHabitData(habitTime: habitController.habitTime!);
    }
  }

  // 리스너 등록
  habitController.titleController.addListener(autoSaveTitle);
  habitController.addListener(autoSaveHabitData);
  bottomSheetController.addListener(autoSaveTitle);

  // ✅ 초기 값 저장 (변경사항 감지용)
  final initialTitle = habitController.titleController.text;
  final initialColor = bottomSheetController.selectedColor;
  final initialReminder = bottomSheetController.reminder;
  final initialRepeatRule = bottomSheetController.repeatRule;

  // ✅ 드래그 방향 추적 변수
  double? previousExtent;
  bool isDismissing = false; // 팝업 중복 방지

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.3), // ✅ 약간 어둡게 (터치 감지용)
    isDismissible: false, // ✅ 기본 드래그 닫기 비활성화
    enableDrag: false, // ✅ 기본 드래그 비활성화 (수동으로 처리)
    useRootNavigator: false, // ✅ 현재 네비게이터 사용 (부모 화면과 제스처 충돌 방지)
    builder: (sheetContext) => WillPopScope(
      onWillPop: () async {
        // ✅ 변경사항 감지
        final hasChanges =
            initialTitle != habitController.titleController.text ||
            initialColor != bottomSheetController.selectedColor ||
            initialReminder != bottomSheetController.reminder ||
            initialRepeatRule != bottomSheetController.repeatRule;

        if (hasChanges) {
          // ✅ 변경사항 있으면 확인 모달
          final confirmed = await showDiscardChangesModal(context);
          return confirmed == true;
        }
        // ✅ 변경사항 없으면 바로 닫기
        return true;
      },
      child: Stack(
        children: [
          // ✅ 배리어 영역 (전체 화면)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                // ✅ 배리어 영역 터치 시
                debugPrint('🐛 [HabitWolt] 배리어 터치 감지');

                final hasChanges =
                    initialTitle != habitController.titleController.text ||
                    initialColor != bottomSheetController.selectedColor ||
                    initialReminder != bottomSheetController.reminder ||
                    initialRepeatRule != bottomSheetController.repeatRule;

                if (hasChanges) {
                  // ✅ 변경사항 있으면 확인 모달
                  final confirmed = await showDiscardChangesModal(context);
                  if (confirmed == true && sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                } else {
                  // ✅ 변경사항 없으면 바로 닫기
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                }
              },
            ),
          ),
          // ✅ 바텀시트 (배리어 위에)
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              // ✅ 바텀시트를 minChildSize 이하로 내릴 때 감지
              // ✅ 드래그 방향 감지 (아래로만)
              final isMovingDown =
                  previousExtent != null &&
                  notification.extent < previousExtent!;
              previousExtent = notification.extent;

              // ✅ 바텀시트를 아래로 드래그하여 minChildSize 이하로 내릴 때만
              if (isMovingDown &&
                  notification.extent <= notification.minExtent + 0.05 &&
                  !isDismissing) {
                debugPrint('🐛 [TaskWolt] 아래로 드래그 닫기 감지');

                isDismissing = true; // ✅ 즉시 플래그 설정하여 중복 호출 방지

                // ✅ 변경사항 확인
                final hasChanges =
                    initialTitle != habitController.titleController.text ||
                    initialColor != bottomSheetController.selectedColor ||
                    initialReminder != bottomSheetController.reminder ||
                    initialRepeatRule != bottomSheetController.repeatRule;

                if (hasChanges) {
                  // ✅ 변경사항 있으면 확인 모달 띄우기
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (sheetContext.mounted) {
                      final confirmed = await showDiscardChangesModal(context);
                      if (confirmed == true && sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      } else {
                        // ✅ 사용자가 취소한 경우에만 플래그 리셋
                        isDismissing = false;
                      }
                    }
                  });
                  return true; // ✅ 드래그 이벤트 소비 (닫기 방지)
                } else {
                  // ✅ 변경사항 없으면 바로 닫기
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (sheetContext.mounted) {
                      try {
                        Navigator.of(sheetContext, rootNavigator: false).pop();
                        // ✅ pop 성공 후에는 리셋하지 않음 (이미 dispose됨)
                      } catch (e) {
                        debugPrint('❌ 바텀시트 닫기 실패: $e');
                        isDismissing = false; // ✅ 실패한 경우에만 리셋
                      }
                    }
                  });
                  return false;
                }
              }
              return false;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              snap: true,
              snapSizes: const [0.5, 0.7, 0.95],
              builder: (context, scrollController) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // ✅ 바텀시트 내부 터치는 아무것도 안함 (포커스 해제 등)
                  debugPrint('🐛 [HabitWolt] 바텀시트 내부 터치');
                },
                child: Container(
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFCFCFC),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 36,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: _buildHabitDetailPage(
                    context,
                    scrollController: scrollController,
                    habit: habit,
                    selectedDate: selectedDate,
                    initialTitle: initialTitle,
                    initialColor: initialColor,
                    initialReminder: initialReminder,
                    initialRepeatRule: initialRepeatRule,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ========================================
// Habit Detail Page Builder
// ========================================

Widget _buildHabitDetailPage(
  BuildContext context, {
  required ScrollController scrollController,
  required HabitData? habit, // ✅ nullable로 변경
  required DateTime selectedDate,
  required String initialTitle,
  required String initialColor,
  required String initialReminder,
  required String initialRepeatRule,
}) {
  debugPrint('⌨️ [HabitWolt] 하단 패딩: 0px');

  return ListView(
    controller: scrollController,
    padding: EdgeInsets.zero,
    children: [
      // ========== TopNavi (60px) - 컨텐츠 최상단 ==========
      _buildTopNavi(
        context,
        habit: habit,
        selectedDate: selectedDate,
        initialTitle: initialTitle,
        initialColor: initialColor,
        initialReminder: initialReminder,
        initialRepeatRule: initialRepeatRule,
      ),

      // ========== TextField Section (Frame 776) ==========
      _buildTextField(context),

      const SizedBox(height: 24), // Figma: gap 24px
      // ========== DetailOptions (64px) ==========
      _buildDetailOptions(context, selectedDate: selectedDate),

      const SizedBox(height: 48), // Figma: gap 48px
      // ========== Delete Button (기존 습관만 표시) ==========
      if (habit != null)
        _buildDeleteButton(context, habit: habit, selectedDate: selectedDate),

      const SizedBox(height: 20), // ✅ 하단 패딩 20px (최대 확장 시 바텀시트 끝에서 20px 여백)
    ],
  );
}

// ========================================
// TopNavi Component (60px)
// ========================================

Widget _buildTopNavi(
  BuildContext context, {
  required HabitData? habit, // ✅ nullable로 변경
  required DateTime selectedDate,
  required String initialTitle,
  required String initialColor,
  required String initialReminder,
  required String initialRepeatRule,
}) {
  // Figma: padding 28px 28px 9px 28px (top만 28px!)
  // Height: 60px total (28 + 9 + content)
  final habitController = Provider.of<HabitFormController>(
    context,
    listen: false,
  );

  return ValueListenableBuilder<TextEditingValue>(
    valueListenable: habitController.titleController,
    builder: (context, titleValue, child) {
      return Consumer2<HabitFormController, BottomSheetController>(
        builder: (context, habitController, bottomSheetController, child) {
          // 🎯 필수 항목 체크 (습관: 제목 + 반복규칙 필수)
          final hasRequiredFields =
              titleValue.text.trim().isNotEmpty &&
              bottomSheetController.repeatRule.isNotEmpty;

          // ✅ 변경사항 감지 (초기값과 비교)
          final hasChanges =
              initialTitle != titleValue.text ||
              initialColor != bottomSheetController.selectedColor.toString() ||
              initialReminder != bottomSheetController.reminder ||
              initialRepeatRule != bottomSheetController.repeatRule;

          // 🎯 保存 버튼 표시 조건:
          // 1. 새 항목: 제목 + 반복규칙이 입력됨
          // 2. 기존 항목: 필수 항목 있음 + 변경사항 있음
          final showSaveButton = habit == null
              ? hasRequiredFields // 새 항목
              : (hasRequiredFields && hasChanges); // 기존 항목

          return Padding(
            padding: const EdgeInsets.fromLTRB(
              28,
              28,
              28,
              9,
            ), // 🎯 Figma: 28px 28px 9px 28px
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Figma: space-between
              children: [
                // ========== "ルーティン" 타이틀 (좌측) ==========
                // Figma: Bold 16px, #505050, letter-spacing: -0.005em
                const Text(
                  'ルーティン', // 🎯 Figma: "ルーティン" (習慣 아님!)
                  style: TextStyle(
                    fontFamily: 'LINE Seed JP App_TTF',
                    fontSize: 16,
                    fontWeight: FontWeight.w700, // Bold (700)
                    height: 1.4, // line-height: 140%
                    letterSpacing: -0.08, // -0.005em = -0.08px
                    color: Color(0xFF505050),
                  ),
                ),

                // 🎯 조건부 버튼: 조건 충족하면 完了, 아니면 X 아이콘
                showSaveButton
                    ? GestureDetector(
                        onTap: () => _handleSave(
                          context,
                          habit: habit,
                          selectedDate: selectedDate,
                        ),
                        child: Container(
                          width: 74,
                          height: 42,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ), // Figma: 12px 24px
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111), // #111111
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(186, 186, 186, 0.08),
                                offset: Offset(0, -2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '完了',
                            style: TextStyle(
                              fontFamily: 'LINE Seed JP App_TTF',
                              fontSize: 13,
                              fontWeight: FontWeight.w800, // ExtraBold (800)
                              height: 1.4, // line-height: 140%
                              letterSpacing: -0.065, // -0.005em = -0.065px
                              color: Color(0xFFFAFAFA), // #FAFAFA
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4E4E4).withOpacity(0.9),
                            border: Border.all(
                              color: const Color(0xFF111111).withOpacity(0.02),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'asset/icon/X_icon.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF111111),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      );
    },
  );
}

// ========================================
// TextField Component (Frame 780 + DetailView_Title)
// ========================================

Widget _buildTextField(BuildContext context) {
  final habitController = Provider.of<HabitFormController>(
    context,
    listen: false,
  );

  // Figma: Frame 780 → DetailView_Title
  // padding: 12px 0px (Frame 780) → 0px 24px (DetailView_Title)
  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 12,
    ), // Figma: Frame 780 - 12px 0px
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ), // Figma: DetailView_Title - 0px 24px
      child: TextField(
        controller: habitController.titleController,
        autofocus: true, // ✅ QuickAdd에서 전환 시 키보드 자동 활성화
        // Figma: Bold 19px, #111111
        style: const TextStyle(
          fontFamily: 'LINE Seed JP App_TTF',
          fontSize: 19,
          fontWeight: FontWeight.w700, // Bold (700)
          height: 1.4, // line-height: 140%
          letterSpacing: -0.095, // -0.005em = -0.095px
          color: Color(0xFF111111),
        ),
        decoration: InputDecoration(
          // Figma: "新しいルーティンを記録" - #AAAAAA
          hintText: '新しいルーティンを記録', // 🎯 정확한 플레이스홀더
          hintStyle: const TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 19,
            fontWeight: FontWeight.w700, // Bold (700)
            height: 1.4, // line-height: 140%
            letterSpacing: -0.095, // -0.005em = -0.095px
            color: Color(0xFFAAAAAA), // #AAAAAA
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero, // 내부 여백 제거
        ),
        minLines: 1, // ✅ 최소 1행
        maxLines: 2, // ✅ 최대 2행까지 입력 가능
        inputFormatters: [
          // ✅ 개행 문자를 1개로 제한 (2행까지만 가능)
          TextInputFormatter.withFunction((oldValue, newValue) {
            final newLineCount = '\n'.allMatches(newValue.text).length;
            if (newLineCount > 1) {
              return oldValue;
            }
            return newValue;
          }),
        ],
      ),
    ),
  );
}

// ========================================
// DetailOptions Component (DetailOption/Box)
// ========================================

Widget _buildDetailOptions(
  BuildContext context, {
  required DateTime selectedDate,
}) {
  // Figma: padding 0px 22px, gap 8px
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 22), // Figma: 0px 22px
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start, // 🎯 좌측 정렬
      children: [
        // 🎯 순서: 반복 → 리마인더 → 색상

        // 1️⃣ 반복 버튼 (repeat)
        _buildRepeatOptionButton(context),

        const SizedBox(width: 8), // Figma: gap 8px
        // 2️⃣ 리마인더 버튼 (notification)
        _buildReminderOptionButton(context),

        const SizedBox(width: 8), // Figma: gap 8px
        // 3️⃣ 색상 버튼 (palette)
        _buildColorOptionButton(context),
      ],
    ),
  );
}

/// DetailOption 개별 버튼 (64x64px)
///
/// Figma Spec:
/// - Size: 64x64px
/// - Background: #FFFFFF
/// - Border: 1px solid rgba(17, 17, 17, 0.08)
/// - Shadow: 0px 2px 8px rgba(186, 186, 186, 0.08), 0px 4px 20px rgba(0, 0, 0, 0.02)
/// - Radius: 24px
/// - Icon: 24x24px, #111111, stroke 2px
Widget _buildDetailOptionButton(
  BuildContext context, {
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 64, // Figma: 64px
      height: 64, // Figma: 64px
      padding: const EdgeInsets.all(20), // Figma: padding 20px
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // #FFFFFF
        borderRadius: BorderRadius.circular(24), // Figma: 24px radius
        border: Border.all(
          color: const Color.fromRGBO(17, 17, 17, 0.08), // rgba(17,17,17,0.08)
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(
              186,
              186,
              186,
              0.08,
            ), // rgba(186,186,186,0.08)
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02), // rgba(0,0,0,0.02)
            offset: Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 24, // Figma: 24x24px icon
        color: const Color(0xFF111111), // #111111
        // weight: 2 (stroke 2px) - Flutter는 직접 지원 안함
      ),
    ),
  );
}

// ✅ 리마인더 버튼 (선택된 리마인더 텍스트 표시)
Widget _buildReminderOptionButton(BuildContext context) {
  return Consumer<BottomSheetController>(
    builder: (context, controller, _) {
      // 선택된 리마인더 표시 텍스트 추출
      String? displayText;
      if (controller.reminder.isNotEmpty) {
        try {
          final reminderData = controller.reminder;
          if (reminderData.contains('"display":"')) {
            final startIndex = reminderData.indexOf('"display":"') + 11;
            final endIndex = reminderData.indexOf('"', startIndex);
            displayText = reminderData.substring(startIndex, endIndex);
          }
        } catch (e) {
          debugPrint('리마인더 파싱 오류: $e');
        }
      }

      return GestureDetector(
        onTap: () => _handleReminderPicker(context),
        child: Container(
          width: 64,
          height: 64,
          padding: displayText != null
              ? const EdgeInsets.all(8)
              : const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            border: Border.all(color: const Color.fromRGBO(17, 17, 17, 0.08)),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(186, 186, 186, 0.08),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.02),
                offset: Offset(0, 4),
                blurRadius: 20,
              ),
            ],
          ),
          child: displayText != null
              ? Center(
                  child: Text(
                    displayText,
                    style: const TextStyle(
                      fontFamily: 'LINE Seed JP App_TTF',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.4, // line-height: 140%
                      letterSpacing: -0.065, // -0.005em * 13px
                      color: Color(0xFF111111),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : const Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: Color(0xFF111111),
                ),
        ),
      );
    },
  );
}

// ✅ 반복 버튼 (선택된 반복 규칙 표시)
Widget _buildRepeatOptionButton(BuildContext context) {
  return Consumer<BottomSheetController>(
    builder: (context, controller, _) {
      // 선택된 반복 규칙에서 display 텍스트 추출
      String? displayText;
      if (controller.repeatRule.isNotEmpty) {
        try {
          final repeatData = controller.repeatRule;
          if (repeatData.contains('"display":"')) {
            final startIndex = repeatData.indexOf('"display":"') + 11;
            final endIndex = repeatData.indexOf('"', startIndex);
            displayText = repeatData.substring(startIndex, endIndex);
            // ✅ 개행 문자는 그대로 유지 (박스 안에서 중앙 정렬)
          }
        } catch (e) {
          debugPrint('반복 규칙 파싱 오류: $e');
        }
      }

      return GestureDetector(
        onTap: () => _handleRepeatPicker(context),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            clipBehavior: Clip.none, // ✅ 텍스트가 박스 밖으로 나갈 수 있음
            children: [
              // 배경 박스 (64×64 정사각형)
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(
                    color: const Color.fromRGBO(17, 17, 17, 0.08),
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(186, 186, 186, 0.08),
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.02),
                      offset: Offset(0, 4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: displayText == null
                    ? const Icon(
                        Icons.repeat,
                        size: 24,
                        color: Color(0xFF111111),
                      )
                    : null,
              ),
              // 텍스트 (박스 안에서 가로세로 중앙 정렬)
              if (displayText != null)
                Positioned.fill(
                  child: Center(
                    child: Text(
                      displayText,
                      style: const TextStyle(
                        fontFamily: 'LINE Seed JP App_TTF',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        letterSpacing: -0.06,
                        color: Color(0xFF111111),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2, // ✅ 최대 2행 (개행 허용)
                      overflow: TextOverflow.clip, // ✅ 박스 안에서만 표시
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

// ✅ 색상 버튼 (선택된 색상 표시)
Widget _buildColorOptionButton(BuildContext context) {
  return Consumer<BottomSheetController>(
    builder: (context, controller, _) {
      // 선택된 색상 가져오기
      final selectedColorId = controller.selectedColor;
      final Color? selectedColor = categoryColorMap[selectedColorId];
      final bool hasColor = selectedColor != null;

      return GestureDetector(
        onTap: () => _handleColorPicker(context),
        child: Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            border: Border.all(color: const Color.fromRGBO(17, 17, 17, 0.08)),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(186, 186, 186, 0.08),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.02),
                offset: Offset(0, 4),
                blurRadius: 20,
              ),
            ],
          ),
          child: hasColor
              ? SvgPicture.asset(
                  'asset/icon/Color_Selected_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
                )
              : SvgPicture.asset(
                  'asset/icon/color_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF111111),
                    BlendMode.srcIn,
                  ),
                ),
        ),
      );
    },
  );
}

// ========================================
// Delete Button Component (Frame 872 + Frame 774)
// ========================================

Widget _buildDeleteButton(
  BuildContext context, {
  required HabitData habit,
  required DateTime selectedDate,
}) {
  // Figma: Frame 872 - padding 0px 24px
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24), // Figma: 0px 24px
    child: GestureDetector(
      onTap: () =>
          _handleDelete(context, habit: habit, selectedDate: selectedDate),
      child: Container(
        width: 100, // Figma: 100px width
        height: 52, // Figma: 52px height
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ), // Figma: 16px 24px
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA), // #FAFAFA
          borderRadius: BorderRadius.circular(16), // Figma: 16px radius
          border: Border.all(
            color: const Color.fromRGBO(
              186,
              186,
              186,
              0.08,
            ), // rgba(186,186,186,0.08)
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(17, 17, 17, 0.03), // rgba(17,17,17,0.03)
              offset: Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 🎯 삭제 아이콘 (20x20px)
            const Icon(
              Icons.delete_outline,
              size: 20, // Figma: 20x20px
              color: Color(0xFFF74A4A), // #F74A4A
            ),

            const SizedBox(width: 6), // Figma: gap 6px
            // 🎯 "削除" 텍스트
            const Text(
              '削除',
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 13,
                fontWeight: FontWeight.w700, // Bold (700)
                height: 1.4, // line-height: 140%
                letterSpacing: -0.065, // -0.005em = -0.065px
                color: Color(0xFFF74A4A), // #F74A4A
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ========================================
// Event Handlers
// ========================================

/// Save Button Handler
void _handleSave(
  BuildContext context, {
  required HabitData? habit, // ✅ nullable로 변경
  required DateTime selectedDate,
}) async {
  final habitController = Provider.of<HabitFormController>(
    context,
    listen: false,
  );
  final bottomSheetController = Provider.of<BottomSheetController>(
    context,
    listen: false,
  );

  // ========== 1단계: 필수 필드 검증 ==========
  // 제목 검증
  if (habitController.titleController.text.trim().isEmpty) {
    debugPrint('⚠️ [HabitWolt] 제목 없음');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('習慣名を入力してください'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // ========== 2단계: 캐시에서 최신 데이터 읽기 ==========
  final cachedColor = await TempInputCache.getTempColor();
  final cachedRepeatRule = await TempInputCache.getTempRepeatRule();
  final cachedReminder = await TempInputCache.getTempReminder();

  // ========== 3단계: Provider 우선, 캐시는 보조 (반복/리마인더는 Provider 최신값 사용) ==========
  final finalColor = cachedColor ?? bottomSheetController.selectedColor;
  // ✅ 반복 규칙은 Provider 우선 (사용자가 선택한 최신 값)
  final finalRepeatRule = bottomSheetController.repeatRule.isNotEmpty
      ? bottomSheetController.repeatRule
      : (cachedRepeatRule ?? '');
  // ✅ 리마인더도 Provider 우선
  final finalReminder = bottomSheetController.reminder.isNotEmpty
      ? bottomSheetController.reminder
      : (cachedReminder ?? '');

  // ========== 4단계: 빈 문자열 → null 변환 ==========
  String? safeRepeatRule = finalRepeatRule.trim().isEmpty
      ? null
      : finalRepeatRule;
  String? safeReminder = finalReminder.trim().isEmpty ? null : finalReminder;

  // JSON 형식이면 빈 객체/배열 체크
  if (safeRepeatRule != null &&
      (safeRepeatRule == '{}' || safeRepeatRule == '[]')) {
    safeRepeatRule = null;
  }
  if (safeReminder != null && (safeReminder == '{}' || safeReminder == '[]')) {
    safeReminder = null;
  }

  // 🎯 반복 규칙 필수 검증 (습관은 반복이 필수!)
  if (safeRepeatRule == null || safeRepeatRule.isEmpty) {
    debugPrint('⚠️ [HabitWolt] 반복 규칙 없음 (습관은 반복 필수)');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('繰り返しを設定してください'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  final database = GetIt.I<AppDatabase>();

  try {
    if (habit != null && habit.id != -1) {
      // ========== 🔄 RecurringPattern 테이블에서 실제 반복 여부 확인 ==========
      final recurringPattern = await database.getRecurringPattern(
        entityType: 'habit',
        entityId: habit.id,
      );
      final hadRepeatRule = recurringPattern != null;

      debugPrint(
        '🔍 [HabitWolt] 저장 시 반복 확인: Habit #${habit.id} → ${hadRepeatRule ? "반복 있음" : "반복 없음"}',
      );

      if (hadRepeatRule) {
        // 변경사항이 있는지 확인
        final hasChanges =
            habit.title != habitController.titleController.text.trim() ||
            habit.colorId != finalColor ||
            habit.reminder != (safeReminder ?? '') ||
            habit.repeatRule != safeRepeatRule;

        if (hasChanges) {
          // ✅ 반복 습관 수정 확인 모달 표시
          await showEditRepeatConfirmationModal(
            context,
            onEditThis: () async {
              // ✅ この回のみ 수정: RecurringException 생성
              await _editHabitThisOnly(
                database,
                habit,
                habitController,
                finalColor,
                safeReminder,
              );
              debugPrint('✅ [HabitWolt] この回のみ 수정 완료');
              if (context.mounted) {
                // ✅ 1. 확인 모달 닫기
                Navigator.pop(context);
                // ✅ 2. Detail modal 닫기 (변경 신호 전달)
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('この回のみ変更しました'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            onEditFuture: () async {
              // ✅ この予定以降 수정: RRULE 분할
              await _editHabitFuture(
                database,
                habit,
                habitController,
                finalColor,
                safeReminder,
                safeRepeatRule,
                selectedDate,
              );
              debugPrint('✅ [HabitWolt] この予定以降 수정 완료');
              if (context.mounted) {
                // ✅ 1. 확인 모달 닫기
                Navigator.pop(context);
                // ✅ 2. Detail modal 닫기 (변경 신호 전달)
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('この予定以降を変更しました'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            onEditAll: () async {
              // ✅ すべての回 수정: Base Event + RecurringPattern 업데이트
              final updatedHabit = HabitCompanion(
                id: Value(habit.id),
                title: Value(habitController.titleController.text.trim()),
                createdAt: Value(habit.createdAt),
                reminder: Value(safeReminder ?? ''),
                repeatRule: Value(safeRepeatRule!), // ✅ null 체크 완료 (위에서 검증됨)
                colorId: Value(finalColor),
              );
              await database.updateHabit(updatedHabit);
              debugPrint('✅ [HabitWolt] すべての回 수정 완료');

              // ========== RecurringPattern 업데이트 ==========
              final dtstart = habit.createdAt;
              final rrule = convertRepeatRuleToRRule(safeRepeatRule, dtstart);

              // 🔥 날짜만 추출 (시간은 00:00:00으로 통일)
              final dtstartDateOnly = DateTime(
                dtstart.year,
                dtstart.month,
                dtstart.day,
              );

              if (rrule != null) {
                // 기존 패턴 업데이트
                await (database.update(
                  database.recurringPattern,
                )..where((tbl) => tbl.id.equals(recurringPattern.id))).write(
                  RecurringPatternCompanion(
                    rrule: Value(rrule),
                    dtstart: Value(dtstartDateOnly),
                  ),
                );
                debugPrint('✅ [HabitWolt] RecurringPattern 업데이트 완료');
                debugPrint('   - RRULE: $rrule');
                debugPrint('   - DTSTART: $dtstartDateOnly (날짜만)');
              }
            },
          );

          return; // ✅ 모달 작업 완료 후 함수 종료
        }
      }

      // ========== 반복이 없거나 변경사항이 없는 경우: 일반 업데이트 ==========
      // 기존 습관 수정
      final updatedHabit = HabitCompanion(
        id: Value(habit.id),
        title: Value(habitController.titleController.text.trim()),
        createdAt: Value(habit.createdAt),
        reminder: Value(safeReminder ?? ''),
        repeatRule: Value(safeRepeatRule), // ✅ null 체크 완료
        colorId: Value(finalColor),
      );
      await database.updateHabit(updatedHabit);
      debugPrint('✅ [HabitWolt] 습관 수정 완료');
      debugPrint('   - 제목: ${habitController.titleController.text.trim()}');
      debugPrint('   - 색상: $finalColor');
      debugPrint('   - 반복: $safeRepeatRule');

      // ========== RecurringPattern 업데이트 ==========
      final dtstart = habit.createdAt;
      final rrule = convertRepeatRuleToRRule(safeRepeatRule, dtstart);

      // 🔥 날짜만 추출 (시간은 00:00:00으로 통일)
      final dtstartDateOnly = DateTime(
        dtstart.year,
        dtstart.month,
        dtstart.day,
      );

      if (rrule != null) {
        // 기존 패턴 확인
        final existingPattern = await database.getRecurringPattern(
          entityType: 'habit',
          entityId: habit.id,
        );

        if (existingPattern != null) {
          // 업데이트
          await (database.update(
            database.recurringPattern,
          )..where((tbl) => tbl.id.equals(existingPattern.id))).write(
            RecurringPatternCompanion(
              rrule: Value(rrule),
              dtstart: Value(dtstartDateOnly),
            ),
          );
          debugPrint('✅ [HabitWolt] RecurringPattern 업데이트 완료');
        } else {
          // 생성
          await database.createRecurringPattern(
            RecurringPatternCompanion.insert(
              entityType: 'habit',
              entityId: habit.id,
              rrule: rrule,
              dtstart: dtstartDateOnly,
              exdate: const Value(''),
            ),
          );
          debugPrint('✅ [HabitWolt] RecurringPattern 생성 완료');
        }
        debugPrint('   - RRULE: $rrule');
        debugPrint('   - DTSTART: $dtstartDateOnly (날짜만)');
      } else {
        debugPrint('⚠️ [HabitWolt] RRULE 변환 실패');
      }

      // 🎯 수정 완료 후 통합 캐시 클리어
      await TempInputCache.clearCacheForType('habit');
      debugPrint('🗑️ [HabitWolt] 습관 통합 캐시 클리어 완료');

      // ✅ 변경 토스트 표시
      if (context.mounted) {
        showActionToast(context, type: ToastType.change);
      }
    } else {
      // ========== 5단계: 새 습관 생성 (createdAt 명시) ==========
      final newHabit = HabitCompanion(
        title: Value(habitController.titleController.text.trim()),
        createdAt: Value(DateTime.now()), // ✅ 명시적 생성 시간 (로컬 시간)
        reminder: Value(safeReminder ?? ''),
        repeatRule: Value(safeRepeatRule), // ✅ null 체크 완료 (반복 필수)
        colorId: Value(finalColor),
      );
      final newId = await database.createHabit(newHabit);
      debugPrint('✅ [HabitWolt] 새 습관 생성 완료');
      debugPrint('   - 제목: ${habitController.titleController.text.trim()}');
      debugPrint('   - 색상: $finalColor');
      debugPrint('   - 반복: $safeRepeatRule');
      debugPrint('   - 리마인더: $safeReminder');
      debugPrint(
        '   - createdAt: ${DateTime.now().toString().split(' ')[0]} (오늘부터 표시)',
      );

      // ========== 5.5단계: RecurringPattern 생성 (습관은 반복 필수) ==========
      final dtstart = DateTime.now();
      final rrule = convertRepeatRuleToRRule(safeRepeatRule, dtstart);

      // 🔥 날짜만 추출 (시간은 00:00:00으로 통일)
      final dtstartDateOnly = DateTime(
        dtstart.year,
        dtstart.month,
        dtstart.day,
      );

      if (rrule != null) {
        await database.createRecurringPattern(
          RecurringPatternCompanion.insert(
            entityType: 'habit',
            entityId: newId,
            rrule: rrule,
            dtstart: dtstartDateOnly,
            exdate: const Value(''),
          ),
        );
        debugPrint('✅ [HabitWolt] RecurringPattern 생성 완료');
        debugPrint('   - RRULE: $rrule');
        debugPrint('   - DTSTART: $dtstartDateOnly (날짜만)');
      } else {
        debugPrint('⚠️ [HabitWolt] RRULE 변환 실패');
      }

      // ========== 6단계: 통합 캐시 클리어 ==========
      await TempInputCache.clearCacheForType('habit');
      debugPrint('🗑️ [HabitWolt] 습관 통합 캐시 클리어 완료');

      // ✅ 저장 토스트 표시 (캘린더에 저장됨)
      if (context.mounted) {
        showSaveToast(
          context,
          toInbox: false,
          onTap: () async {
            // 토스트 탭 시 해당 습관의 상세 모달 다시 열기
            final createdHabit = await database.getHabitById(newId);
            if (createdHabit != null && context.mounted) {
              showHabitDetailWoltModal(
                context,
                habit: createdHabit,
                selectedDate: DateTime.now(),
              );
            }
          },
        );
      }
    }

    // Close modal
    Navigator.of(context).pop();
  } catch (e, stackTrace) {
    debugPrint('❌ [HabitWolt] 저장 실패: $e');
    debugPrint('❌ 스택 트레이스: $stackTrace');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存に失敗しました: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFFF74A4A),
        ),
      );
    }
  }
}

/// Color Picker Handler
void _handleColorPicker(BuildContext context) {
  final bottomSheetController = Provider.of<BottomSheetController>(
    context,
    listen: false,
  );
  showWoltColorPicker(
    context,
    initialColorId: bottomSheetController.selectedColor,
  );
}

/// Reminder Picker Handler
void _handleReminderPicker(BuildContext context) {
  final bottomSheetController = Provider.of<BottomSheetController>(
    context,
    listen: false,
  );
  showWoltReminderOption(
    context,
    initialReminder: bottomSheetController.reminder,
  );
}

/// Repeat Picker Handler
void _handleRepeatPicker(BuildContext context) {
  final bottomSheetController = Provider.of<BottomSheetController>(
    context,
    listen: false,
  );
  showWoltRepeatOption(
    context,
    initialRepeatRule: bottomSheetController.repeatRule,
  );
}

/// Delete Button Handler
void _handleDelete(
  BuildContext context, {
  required HabitData habit,
  required DateTime selectedDate,
}) async {
  final database = GetIt.I<AppDatabase>();

  // ✅ RecurringPattern 테이블에서 실제 반복 여부 확인
  final recurringPattern = await database.getRecurringPattern(
    entityType: 'habit',
    entityId: habit.id,
  );
  final hasRepeat = recurringPattern != null;

  debugPrint(
    '🔍 [HabitWolt] 삭제 시 반복 확인: Habit #${habit.id} → ${hasRepeat ? "반복 있음" : "반복 없음"}',
  );

  if (hasRepeat) {
    // ✅ 반복 있으면 → 반복 삭제 모달
    await showDeleteRepeatConfirmationModal(
      context,
      onDeleteThis: () async {
        // ✅ この回のみ 삭제: RecurringException 생성
        await _deleteHabitThisOnly(database, habit);
        if (context.mounted) {
          // ✅ 1. 확인 모달 닫기
          Navigator.pop(context);
          // ✅ 2. Detail modal 닫기 (변경 신호 전달)
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('この回のみ削除しました'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      onDeleteFuture: () async {
        // ✅ この予定以降 삭제: UNTIL 설정
        await _deleteHabitFuture(database, habit, selectedDate);
        if (context.mounted) {
          // ✅ 1. 확인 모달 닫기
          Navigator.pop(context);
          // ✅ 2. Detail modal 닫기 (변경 신호 전달)
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('この予定以降を削除しました'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      onDeleteAll: () async {
        // すべての回 삭제 (전체 삭제)
        debugPrint('✅ [HabitWolt] すべての回 삭제');
        await database.deleteHabit(habit.id);
        if (context.mounted) {
          // ✅ 1. 확인 모달 닫기
          Navigator.pop(context);
          // ✅ 2. Detail modal 닫기 (변경 신호 전달)
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('すべての回を削除しました'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  } else {
    // ✅ 반복 없으면 → 일반 삭제 모달
    await showDeleteConfirmationModal(
      context,
      onDelete: () async {
        debugPrint('✅ [HabitWolt] 습관 삭제 완료');
        await database.deleteHabit(habit.id);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }
}

// ==================== 삭제 헬퍼 함수 ====================

/// ✅ この回のみ 삭제: 오늘만 제외하고 내일부터 다시 시작
/// ✅ この回のみ 삭제: RFC 5545 EXDATE로 예외 처리
Future<void> _deleteHabitThisOnly(AppDatabase db, HabitData habit) async {
  // 1. RecurringPattern 조회
  final pattern = await db.getRecurringPattern(
    entityType: 'habit',
    entityId: habit.id,
  );

  if (pattern == null) {
    debugPrint('⚠️ [HabitWolt] RecurringPattern 없음');
    return;
  }

  // 2. 현재 날짜 (선택된 인스턴스의 originalDate)
  final originalDate = DateTime.now();

  // 3. RecurringException 생성 (취소 표시)
  await db.createRecurringException(
    RecurringExceptionCompanion(
      recurringPatternId: Value(pattern.id),
      originalDate: Value(originalDate),
      isCancelled: const Value(true), // 취소 (삭제)
      isRescheduled: const Value(false),
    ),
  );

  debugPrint('✅ [HabitWolt] この回のみ 삭제 완료 (RFC 5545 EXDATE)');
  debugPrint('   - Habit ID: ${habit.id}');
  debugPrint('   - Pattern ID: ${pattern.id}');
  debugPrint('   - Original Date: $originalDate');
}

/// ✅ この予定以降 삭제: RFC 5545 UNTIL로 종료일 설정
Future<void> _deleteHabitFuture(
  AppDatabase db,
  HabitData habit,
  DateTime selectedDate,
) async {
  // 1. RecurringPattern 조회
  final pattern = await db.getRecurringPattern(
    entityType: 'habit',
    entityId: habit.id,
  );

  if (pattern == null) {
    debugPrint('⚠️ [HabitWolt] RecurringPattern 없음');
    return;
  }

  // 2. ✅ 선택된 날짜(selectedDate) 포함 이후 모두 삭제 → 어제가 마지막 발생
  final dateOnly = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final yesterday = dateOnly.subtract(const Duration(days: 1));
  final until = DateTime(
    yesterday.year,
    yesterday.month,
    yesterday.day,
    23,
    59,
    59,
  );

  // 3. RRULE에 UNTIL 파라미터 추가 (RecurringPattern 업데이트)
  await db.updateRecurringPattern(
    RecurringPatternCompanion(
      id: Value(pattern.id),
      until: Value(until), // UNTIL 설정
    ),
  );

  debugPrint('✅ [HabitWolt] この予定以降 삭제 완료 (RFC 5545 UNTIL)');
  debugPrint('   - Habit ID: ${habit.id}');
  debugPrint('   - Pattern ID: ${pattern.id}');
  debugPrint('   - Selected Date: $dateOnly');
  debugPrint('   - UNTIL (종료일): $until');
}

// ========================================
// Habit repeatRule JSON → RRULE 변환
// ========================================

/// Habit의 repeatRule JSON을 RRULE로 변환
///
/// JSON 형식:
///   - 새 형식: {"value":"daily:月,火,水","display":"月火\n水"}
///   - 구 형식: {"type":"daily","weekdays":[1,2,3,4,5,6,7],"display":"毎日"}
/// RRULE 형식: FREQ=WEEKLY;BYDAY=MO,TU,WE
String? convertRepeatRuleToRRule(String? repeatRuleJson, DateTime dtstart) {
  if (repeatRuleJson == null || repeatRuleJson.trim().isEmpty) {
    return null;
  }

  try {
    // 구 형식: {"type":"daily","weekdays":[1,2,3,4,5,6,7],"display":"毎日"}
    if (repeatRuleJson.contains('"type":"') &&
        repeatRuleJson.contains('"weekdays":[')) {
      debugPrint('🔍 [RepeatConvert] 구 형식 감지');

      // type 추출
      final typeStart = repeatRuleJson.indexOf('"type":"') + 8;
      final typeEnd = repeatRuleJson.indexOf('"', typeStart);
      final type = repeatRuleJson.substring(typeStart, typeEnd);

      if (type == 'daily') {
        // weekdays 배열 추출
        final weekdaysStart = repeatRuleJson.indexOf(
          '[',
          repeatRuleJson.indexOf('"weekdays":'),
        );
        final weekdaysEnd = repeatRuleJson.indexOf(']', weekdaysStart);
        final weekdaysStr = repeatRuleJson.substring(
          weekdaysStart + 1,
          weekdaysEnd,
        );
        final weekdays = weekdaysStr
            .split(',')
            .map((s) => int.tryParse(s.trim()))
            .whereType<int>()
            .toList();

        if (weekdays.isEmpty) {
          debugPrint('⚠️ [RepeatConvert] 유효한 요일 없음');
          return null;
        }

        debugPrint('🔍 [RepeatConvert] weekdays 추출: $weekdays');

        // RecurrenceRule API 사용
        final rrule = RecurrenceRule(
          frequency: Frequency.weekly,
          byWeekDays: weekdays.map((wd) => ByWeekDayEntry(wd)).toList(),
        );

        final rruleString = rrule.toString();
        final result = rruleString.replaceFirst('RRULE:', '');

        debugPrint('✅ [RepeatConvert] RRULE 생성 (구 형식): $result');
        return result;
      }

      return null;
    }

    // 새 형식: {"value":"daily:月,火,水","display":"月火\n水"}
    if (!repeatRuleJson.contains('"value":"')) {
      debugPrint('⚠️ [RepeatConvert] 알 수 없는 형식: $repeatRuleJson');
      return null;
    }

    final startIndex = repeatRuleJson.indexOf('"value":"') + 9;
    final endIndex = repeatRuleJson.indexOf('"', startIndex);
    final value = repeatRuleJson.substring(startIndex, endIndex);

    debugPrint('🔍 [RepeatConvert] value 추출: $value');

    // daily: 요일 기반 반복
    if (value.startsWith('daily:')) {
      final daysStr = value.substring(6); // "月,火,水"
      final days = daysStr
          .split(',')
          .map((d) => d.trim())
          .where((d) => d.isNotEmpty)
          .toList();

      debugPrint('🐛 [HabitWolt-RepeatConvert] daysStr: $daysStr');
      debugPrint('🐛 [HabitWolt-RepeatConvert] days split: $days');

      // 일본어 요일 → DateTime.weekday (with -1 보정)
      final weekdays = days.map(_jpDayToWeekday).whereType<int>().toList();

      debugPrint('🐛 [HabitWolt-RepeatConvert] weekdays 변환: $weekdays');

      if (weekdays.isEmpty) {
        debugPrint('⚠️ [RepeatConvert] 유효한 요일 없음');
        return null;
      }

      // RecurrenceRule API 사용 (버그 보정 적용)
      final rrule = RecurrenceRule(
        frequency: Frequency.weekly,
        byWeekDays: weekdays.map((wd) => ByWeekDayEntry(wd)).toList(),
      );

      final rruleString = rrule.toString();
      final result = rruleString.replaceFirst('RRULE:', '');

      debugPrint('✅ [RepeatConvert] RRULE 생성: $result');
      return result;
    }
    // monthly: 날짜 기반 반복
    else if (value.startsWith('monthly:')) {
      final daysStr = value.substring(8); // "1,15"
      final days = daysStr
          .split(',')
          .map((d) => int.tryParse(d))
          .whereType<int>()
          .toList();

      if (days.isEmpty) {
        debugPrint('⚠️ [RepeatConvert] 유효한 날짜 없음');
        return null;
      }

      // RecurrenceRule API 사용
      final rrule = RecurrenceRule(
        frequency: Frequency.monthly,
        byMonthDays: days,
      );

      final rruleString = rrule.toString();
      final result = rruleString.replaceFirst('RRULE:', '');

      debugPrint('✅ [RepeatConvert] RRULE 생성: $result');
      return result;
    }
    // 간격 기반 (2日毎, 1週間毎, etc.)
    else if (value.contains('日毎')) {
      // "2日毎" → FREQ=DAILY;INTERVAL=2
      final intervalStr = value.replaceAll('日毎', '');
      final interval = int.tryParse(intervalStr) ?? 1;

      final rrule = RecurrenceRule(
        frequency: Frequency.daily,
        interval: interval,
      );

      final rruleString = rrule.toString();
      final result = rruleString.replaceFirst('RRULE:', '');

      debugPrint('✅ [RepeatConvert] RRULE 생성: $result');
      return result;
    } else if (value.contains('週間毎')) {
      // "1週間毎" → FREQ=WEEKLY
      final intervalStr = value.replaceAll('週間毎', '');
      final interval = int.tryParse(intervalStr) ?? 1;

      final rrule = RecurrenceRule(
        frequency: Frequency.weekly,
        interval: interval,
        byWeekDays: [ByWeekDayEntry(dtstart.weekday - 1)], // -1 보정
      );

      final rruleString = rrule.toString();
      final result = rruleString.replaceFirst('RRULE:', '');

      debugPrint('✅ [RepeatConvert] RRULE 생성: $result');
      return result;
    }

    debugPrint('⚠️ [RepeatConvert] 알 수 없는 형식: $value');
    return null;
  } catch (e) {
    debugPrint('❌ [RepeatConvert] 변환 실패: $e');
    return null;
  }
}

/// 일본어 요일을 DateTime.weekday 상수로 변환
/// ⚠️ 보정 없이 정확한 weekday 반환 (RRuleUtils에서 -1 보정 적용)
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
      debugPrint('⚠️ [RepeatConvert] 알 수 없는 요일: $jpDay');
      return null;
  }
}

/// ✅ この回のみ 수정: RFC 5545 RecurringException으로 예외 처리
Future<void> _editHabitThisOnly(
  AppDatabase db,
  HabitData habit,
  HabitFormController controller,
  String color,
  String? reminder,
) async {
  // 1. RecurringPattern 조회
  final pattern = await db.getRecurringPattern(
    entityType: 'habit',
    entityId: habit.id,
  );

  if (pattern == null) {
    debugPrint('⚠️ [HabitWolt] RecurringPattern 없음');
    return;
  }

  // 2. 현재 날짜 (선택된 인스턴스의 originalDate)
  final originalDate = DateTime.now();

  // 3. RecurringException 생성 (수정된 내용 저장)
  await db.createRecurringException(
    RecurringExceptionCompanion(
      recurringPatternId: Value(pattern.id),
      originalDate: Value(originalDate),
      isCancelled: const Value(false),
      isRescheduled: const Value(false), // Habit은 시간 변경 없음
      modifiedTitle: Value(controller.titleController.text.trim()),
      modifiedColorId: Value(color),
    ),
  );

  debugPrint('✅ [HabitWolt] この回のみ 수정 완료 (RFC 5545 Exception)');
  debugPrint('   - Habit ID: ${habit.id}');
  debugPrint('   - Pattern ID: ${pattern.id}');
  debugPrint('   - Original Date: $originalDate');
  debugPrint('   - Modified Title: ${controller.titleController.text.trim()}');
}

/// ✅ この予定以降 수정: RFC 5545 RRULE 분할
Future<void> _editHabitFuture(
  AppDatabase db,
  HabitData habit,
  HabitFormController controller,
  String color,
  String? reminder,
  String? repeatRule,
  DateTime selectedDate,
) async {
  // 1. 기존 RecurringPattern 조회
  final oldPattern = await db.getRecurringPattern(
    entityType: 'habit',
    entityId: habit.id,
  );

  if (oldPattern == null) {
    debugPrint('⚠️ [HabitWolt] RecurringPattern 없음');
    return;
  }

  // 2. ✅ 선택된 날짜(selectedDate) 포함 이후 모두 수정 → 어제가 마지막 발생
  final dateOnly = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final yesterday = dateOnly.subtract(const Duration(days: 1));
  final until = DateTime(
    yesterday.year,
    yesterday.month,
    yesterday.day,
    23,
    59,
    59,
  );

  // 3. 기존 패턴에 UNTIL 설정 (선택 날짜 전까지만)
  await db.updateRecurringPattern(
    RecurringPatternCompanion(id: Value(oldPattern.id), until: Value(until)),
  );

  // 4. 새로운 Habit 생성 (선택 날짜부터 시작)
  final newHabitId = await db.createHabit(
    HabitCompanion(
      title: Value(controller.titleController.text.trim()),
      createdAt: Value(selectedDate),
      reminder: Value(reminder ?? ''),
      repeatRule: Value(repeatRule ?? ''),
      colorId: Value(color),
    ),
  );

  // 5. 새로운 RecurringPattern 생성 (반복 규칙이 있으면)
  if (repeatRule != null && repeatRule.isNotEmpty) {
    final rruleString = convertRepeatRuleToRRule(repeatRule, selectedDate);

    if (rruleString != null) {
      await db.createRecurringPattern(
        RecurringPatternCompanion(
          entityType: const Value('habit'),
          entityId: Value(newHabitId),
          rrule: Value(rruleString),
          dtstart: Value(selectedDate),
          until: Value(oldPattern.until), // 기존 종료일 유지
        ),
      );
    }
  }

  debugPrint('✅ [HabitWolt] この予定以降 수정 완료 (RFC 5545 Split)');
  debugPrint('   - Old Habit ID: ${habit.id} (UNTIL: $until)');
  debugPrint('   - New Habit ID: $newHabitId (Start: $selectedDate)');
}
