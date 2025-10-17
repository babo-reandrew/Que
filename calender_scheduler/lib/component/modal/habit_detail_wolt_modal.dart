import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:drift/drift.dart' hide Column; // ✅ Column 충돌 방지
import 'package:get_it/get_it.dart'; // ✅ GetIt import

import '../../design_system/wolt_helpers.dart';
import '../../Database/schedule_database.dart'; // ScheduleData, AppDatabase
import '../../providers/bottom_sheet_controller.dart';
import '../../providers/habit_form_controller.dart';

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
}) {
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
  }

  debugPrint('✅ [HabitWolt] Provider 초기화 완료');

  WoltModalSheet.show(
    context: context,
    pageListBuilder: (context) => [
      _buildHabitDetailPage(context, habit: habit, selectedDate: selectedDate),
    ],
    modalTypeBuilder: (context) => WoltModalType.bottomSheet(),
    onModalDismissedWithBarrierTap: () {
      FocusScope.of(context).unfocus(); // ✅ 키보드 닫기
      debugPrint('✅ [HabitWolt] Modal dismissed with tap');
    },
    onModalDismissedWithDrag: () {
      FocusScope.of(context).unfocus(); // ✅ 키보드 닫기
      debugPrint('✅ [HabitWolt] Modal dismissed with drag');
    },
    useSafeArea: false, // ✅ SafeArea 비활성화 (키보드 영역까지 사용)
  );
}

// ========================================
// Habit Detail Page Builder
// ========================================

SliverWoltModalSheetPage _buildHabitDetailPage(
  BuildContext context, {
  required HabitData? habit, // ✅ nullable로 변경
  required DateTime selectedDate,
}) {
  // ✅ 하단 패딩 제거 (키보드 여부 무관하게 0px)
  debugPrint('⌨️ [HabitWolt] 하단 패딩: 0px');

  return SliverWoltModalSheetPage(
    // ==================== TopBar 비활성화 (Figma: TopNavi는 컨텐츠 안에 포함) ====================
    hasTopBarLayer: false, // 🎯 앱바 레이어 비활성화
    // ==================== 메인 컨텐츠 ====================
    // Figma: 전체 구조
    // - TopNavi: height 60px (padding 28px 28px 9px 28px)
    // - TextField: padding 12px 0px → 0px 24px
    // - DetailOptions: padding 0px 22px
    // - Delete: padding 0px 24px
    mainContentSliversBuilder: (context) => [
      SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC), // ✅ Figma 배경색
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(36),
              topRight: Radius.circular(36),
            ),
            border: Border.all(
              color: const Color(0xFF111111).withOpacity(0.1), // #111111 10%
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(36),
              topRight: Radius.circular(36),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 🎯 좌측 정렬
              children: [
                // ========== TopNavi (60px) - 컨텐츠 최상단 ==========
                // Figma: padding 28px 28px 9px 28px (top만 28px!)
                _buildTopNavi(
                  context,
                  habit: habit,
                  selectedDate: selectedDate,
                ),

                // ========== TextField Section (Frame 776) ==========
                // Figma: padding 12px 0px (vertical)
                _buildTextField(context),

                const SizedBox(height: 24), // Figma: gap 24px (Frame 777)
                // ========== DetailOptions (64px) ==========
                _buildDetailOptions(context, selectedDate: selectedDate),

                const SizedBox(height: 48), // Figma: gap 48px (Frame 778)
                // ========== Delete Button (기존 습관만 표시) ==========
                if (habit != null) _buildDeleteButton(context, habit: habit),

                // ✅ 하단 패딩 제거
              ],
            ),
          ),
        ),
      ),
    ],

    // ✅ 배경색 투명 (Container가 배경색 처리)
    backgroundColor: Colors.transparent,

    // Figma: 투명 surface tint
    surfaceTintColor: Colors.transparent,
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
        _buildDetailOptionButton(
          context,
          icon: Icons.repeat,
          onTap: () => _handleRepeatPicker(context),
        ),

        const SizedBox(width: 8), // Figma: gap 8px
        // 2️⃣ 리마인더 버튼 (notification)
        _buildDetailOptionButton(
          context,
          icon: Icons.notifications_outlined,
          onTap: () => _handleReminderPicker(context),
        ),

        const SizedBox(width: 8), // Figma: gap 8px
        // 3️⃣ 색상 버튼 (palette)
        _buildDetailOptionButton(
          context,
          icon: Icons.palette_outlined,
          onTap: () => _handleColorPicker(context),
        ),
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
  final database = GetIt.I<AppDatabase>();

  // Validation: Title required
  if (habitController.titleController.text.trim().isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('習慣名を入力してください')));
    return;
  }

  if (habit != null) {
    // 기존 습관 수정
    final updatedHabit = HabitCompanion(
      id: Value(habit.id),
      title: Value(habitController.titleController.text.trim()),
      createdAt: Value(habit.createdAt),
      reminder: Value(bottomSheetController.reminder),
      repeatRule: Value(bottomSheetController.repeatRule),
      colorId: Value(bottomSheetController.selectedColor),
    );
    await database.updateHabit(updatedHabit);
  } else {
    // 새 습관 생성
    final newHabit = HabitCompanion(
      title: Value(habitController.titleController.text.trim()),
      createdAt: Value(selectedDate),
      reminder: Value(bottomSheetController.reminder),
      repeatRule: Value(bottomSheetController.repeatRule),
      colorId: Value(bottomSheetController.selectedColor),
    );
    await database.createHabit(newHabit);
  }

  // Close modal
  Navigator.of(context).pop();

  debugPrint(
    '✅ [HabitWolt] Saved: ${habitController.titleController.text.trim()}',
  );
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
  // Confirmation dialog
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('削除確認'),
      content: const Text('この習慣を削除しますか？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('削除', style: TextStyle(color: Color(0xFFF74A4A))),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final database = GetIt.I<AppDatabase>();
    await database.deleteHabit(habit.id);
    Navigator.of(context).pop(); // Close modal
    debugPrint('🗑️ [HabitWolt] Deleted: ${habit.title}');
  }
}
