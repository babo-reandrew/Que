import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:drift/drift.dart' hide Column; // ✅ Column 충돌 방지
import 'package:get_it/get_it.dart'; // ✅ GetIt import
import 'package:figma_squircle/figma_squircle.dart';

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
void showHabitDetailWoltModal(
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

    // 🎯 기본 반복 규칙: 매일 (주 7일 전체)
    final defaultRepeatRule =
        '{"type":"daily","weekdays":[1,2,3,4,5,6,7],"display":"毎日"}';
    bottomSheetController.updateRepeatRule(defaultRepeatRule);
    debugPrint('✅ [HabitWolt] 기본 반복 규칙 설정: 毎日 (7일)');

    // ✅ 임시 캐시에서 색상 복원 (새 습관일 때만)
    final cachedColor = await TempInputCache.getTempColor();
    if (cachedColor != null && cachedColor.isNotEmpty) {
      bottomSheetController.updateColor(cachedColor);
      debugPrint('✅ [HabitWolt] 임시 색상 복원: $cachedColor');
    }

    // ✅ 임시 캐시에서 리마인더 복원 (기본값 10분전)
    final cachedReminder = await TempInputCache.getTempReminder();
    if (cachedReminder != null && cachedReminder.isNotEmpty) {
      bottomSheetController.updateReminder(cachedReminder);
      debugPrint('✅ [HabitWolt] 임시 리마인더 복원: $cachedReminder');
    }

    // ⚠️ 반복 규칙은 캐시에서 복원하지 않음 (기본값 매일만 사용)
  }

  debugPrint('✅ [HabitWolt] Provider 초기화 완료');

  // ✅ 초기 값 저장 (변경사항 감지용)
  final initialTitle = habitController.titleController.text;
  final initialColor = bottomSheetController.selectedColor;
  final initialReminder = bottomSheetController.reminder;
  final initialRepeatRule = bottomSheetController.repeatRule;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false, // ✅ 기본 드래그 닫기 비활성화
    enableDrag: true, // ✅ 드래그는 활성화
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
      child: GestureDetector(
        onTap: () async {
          // ✅ 바깥 영역 터치 시 변경사항 확인
          final hasChanges =
              initialTitle != habitController.titleController.text ||
              initialColor != bottomSheetController.selectedColor ||
              initialReminder != bottomSheetController.reminder ||
              initialRepeatRule != bottomSheetController.repeatRule;

          if (hasChanges) {
            final confirmed = await showDiscardChangesModal(context);
            if (confirmed == true && sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
            }
          } else {
            Navigator.of(sheetContext).pop();
          }
        },
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          onTap: () {}, // ✅ 내부 터치는 무시 (이벤트 버블링 방지)
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              // ✅ 바텀시트를 minChildSize 이하로 내릴 때 감지
              if (notification.extent <= notification.minExtent + 0.05) {
                // ✅ 변경사항 확인
                final hasChanges =
                    initialTitle != habitController.titleController.text ||
                    initialColor != bottomSheetController.selectedColor ||
                    initialReminder != bottomSheetController.reminder ||
                    initialRepeatRule != bottomSheetController.repeatRule;

                if (hasChanges) {
                  // ✅ 변경사항 있으면 확인 모달
                  showDiscardChangesModal(context).then((confirmed) {
                    if (confirmed == true && sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  });
                  return true; // ✅ 이벤트 소비 (기본 닫기 방지)
                } else {
                  // ✅ 변경사항 없으면 바로 닫기
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
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
              builder: (context, scrollController) => Container(
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
                ),
              ),
            ),
          ),
        ),
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
}) {
  debugPrint('⌨️ [HabitWolt] 하단 패딩: 0px');

  return ListView(
    controller: scrollController,
    padding: EdgeInsets.zero,
    children: [
      // ========== TopNavi (60px) - 컨텐츠 최상단 ==========
      _buildTopNavi(context, habit: habit, selectedDate: selectedDate),

      // ========== TextField Section (Frame 776) ==========
      _buildTextField(context),

      const SizedBox(height: 24), // Figma: gap 24px
      // ========== DetailOptions (64px) ==========
      _buildDetailOptions(context, selectedDate: selectedDate),

      const SizedBox(height: 48), // Figma: gap 48px
      // ========== Delete Button (기존 습관만 표시) ==========
      if (habit != null) _buildDeleteButton(context, habit: habit),

      const SizedBox(height: 32), // ✅ 하단 패딩
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
}) {
  // Figma: padding 28px 28px 9px 28px (top만 28px!)
  // Height: 60px total (28 + 9 + content)
  return Padding(
    padding: const EdgeInsets.fromLTRB(
      28,
      28,
      28,
      9,
    ), // 🎯 Figma: 28px 28px 9px 28px
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Figma: space-between
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

        // ========== "完了" 버튼 (우측) ==========
        // Figma: 74x42px, ExtraBold 13px, #FAFAFA on #111111, radius 16px
        GestureDetector(
          onTap: () =>
              _handleSave(context, habit: habit, selectedDate: selectedDate),
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
        ),
      ],
    ),
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
        keyboardType: TextInputType.multiline, // ✅ 개행 지원 키보드
        textInputAction: TextInputAction.newline, // ✅ 완료 대신 개행 버튼
        maxLines: null, // ✅ 여러 줄 입력 가능
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

Widget _buildDeleteButton(BuildContext context, {required HabitData habit}) {
  // Figma: Frame 872 - padding 0px 24px
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24), // Figma: 0px 24px
    child: GestureDetector(
      onTap: () => _handleDelete(context, habit: habit),
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
    if (habit != null) {
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

      // ✅ 수정 완료 후 캐시 클리어
      await TempInputCache.clearTempInput();
      debugPrint('🗑️ [HabitWolt] 캐시 클리어 완료');

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

      // ========== 6단계: 캐시 클리어 ==========
      await TempInputCache.clearTempInput();
      debugPrint('🗑️ [HabitWolt] 캐시 클리어 완료');

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
void _handleDelete(BuildContext context, {required HabitData habit}) async {
  // ✅ 반복 여부 확인 (습관은 항상 반복이 있음)
  final hasRepeat =
      habit.repeatRule.isNotEmpty &&
      habit.repeatRule != '{}' &&
      habit.repeatRule != '[]';

  final database = GetIt.I<AppDatabase>();

  if (hasRepeat) {
    // ✅ 반복 있으면 → 반복 삭제 모달
    await showDeleteRepeatConfirmationModal(
      context,
      onDeleteThis: () async {
        // ✅ この回のみ 삭제: 내일부터 시작하도록 변경
        await _deleteHabitThisOnly(database, habit);
        if (context.mounted) Navigator.pop(context);
      },
      onDeleteFuture: () async {
        // ✅ この予定以降 삭제: 어제까지로 종료
        await _deleteHabitFuture(database, habit);
        if (context.mounted) Navigator.pop(context);
      },
      onDeleteAll: () async {
        // すべての回 삭제 (전체 삭제)
        debugPrint('✅ [HabitWolt] すべての回 삭제');
        await database.deleteHabit(habit.id);
        if (context.mounted) Navigator.pop(context);
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
Future<void> _deleteHabitThisOnly(AppDatabase db, HabitData habit) async {
  // 1. 오늘을 제외한 새로운 시작일 계산
  final today = DateTime.now();
  final tomorrow = DateTime(today.year, today.month, today.day + 1);

  // 2. createdAt을 내일로 변경하여 업데이트
  await (db.update(db.habit)..where((tbl) => tbl.id.equals(habit.id))).write(
    HabitCompanion(id: Value(habit.id), createdAt: Value(tomorrow)),
  );

  debugPrint('✅ [HabitWolt] この回のみ 삭제 완료');
  debugPrint('   - ID: ${habit.id}');
  debugPrint('   - 새 시작일: $tomorrow');
}

/// ✅ この予定以降 삭제: 어제까지만 유지하고 이후 반복 종료
Future<void> _deleteHabitFuture(AppDatabase db, HabitData habit) async {
  // 1. 어제 날짜 계산
  final today = DateTime.now();
  final yesterday = DateTime(today.year, today.month, today.day - 1);

  // 2. 반복 규칙에서 endDate를 어제로 설정
  // TODO: repeatRule JSON 파싱 및 endDate 추가 로직 필요
  // 현재는 단순히 반복 제거로 처리 (임시)
  await (db.update(db.habit)..where((tbl) => tbl.id.equals(habit.id))).write(
    HabitCompanion(
      id: Value(habit.id),
      repeatRule: const Value(''), // 반복 제거 (임시)
    ),
  );

  debugPrint('✅ [HabitWolt] この予定以降 삭제 완료');
  debugPrint('   - ID: ${habit.id}');
  debugPrint('   - 종료일: $yesterday');
  debugPrint('   ⚠️ TODO: repeatRule endDate 설정 필요');
}
