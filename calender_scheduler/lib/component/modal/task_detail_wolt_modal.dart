import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';

import '../../Database/schedule_database.dart';
import '../../providers/bottom_sheet_controller.dart';
import '../../providers/task_form_controller.dart';
import '../../design_system/wolt_helpers.dart';

/// 할일 상세 Wolt Modal Sheet
///
/// **Figma Design Spec:**
///
/// **Modal Container:**
/// - Size: 393 x 615px (isEmpty) / 584px (isPresent)
/// - Background: #FCFCFC
/// - Border: 1px solid rgba(17, 17, 17, 0.1)
/// - Shadow: 0px 2px 20px rgba(165, 165, 165, 0.2)
/// - Border radius: 36px 36px 0px 0px
///
/// **TopNavi (60px):**
/// - Padding: 28px 28px 9px 28px
/// - Title: "タスク" - Bold 16px, #505050 (isEmpty) / #7A7A7A (isPresent)
/// - Button: "完了" - ExtraBold 13px, #FAFAFA on #111111, 74x42px
///
/// **TextField:**
/// - Padding: 12px 0px, inner: 0px 28px (24px 아님!)
/// - Placeholder: "タスクを入力" - Bold 19px, #AAAAAA
/// - Text: ExtraBold 19px, #111111
///
/// **Deadline Label:**
/// - Padding: 4px 28px
/// - Icon: 19x19px flag
/// - Text: "締め切り" - Bold 13px, #111111
///
/// **Deadline Display:**
/// - Padding: 0px 28px → 0px 24px (inner)
/// - Date: "08.24." - ExtraBold 33px, #111111
/// - Year: "2025" - ExtraBold 19px, #E75858 (빨간색!)
///
/// **DetailOptions:**
/// - Padding: 0px 48px
/// - Repeat: "月火\n水木" (줄바꿈)
/// - Reminder: "15:30"
/// - Color: icon
void showTaskDetailWoltModal(
  BuildContext context, {
  required TaskData? task,
  required DateTime selectedDate,
}) {
  // Provider 초기화 (모달 띄우기 전에!)
  final taskController = Provider.of<TaskFormController>(
    context,
    listen: false,
  );
  final bottomSheetController = Provider.of<BottomSheetController>(
    context,
    listen: false,
  );

  if (task != null) {
    // 기존 할일 수정
    taskController.titleController.text = task.title;
    if (task.dueDate != null) {
      taskController.setDueDate(task.dueDate!);
    }

    bottomSheetController.updateColor(task.colorId);
    bottomSheetController.updateReminder(task.reminder);
    bottomSheetController.updateRepeatRule(task.repeatRule);
  } else {
    // 새 할일 생성
    taskController.reset();
  }

  debugPrint('✅ [TaskWolt] Provider 초기화 완료');

  WoltModalSheet.show(
    context: context,
    pageListBuilder: (context) => [
      _buildTaskDetailPage(context, task: task, selectedDate: selectedDate),
    ],
    modalTypeBuilder: (context) => WoltModalType.bottomSheet(),
    onModalDismissedWithBarrierTap: () {
      debugPrint('✅ [TaskWolt] Modal dismissed');
    },
  );
}

// ========================================
// Task Detail Page Builder
// ========================================

SliverWoltModalSheetPage _buildTaskDetailPage(
  BuildContext context, {
  required TaskData? task,
  required DateTime selectedDate,
}) {
  return SliverWoltModalSheetPage(
    hasTopBarLayer: false,

    mainContentSliversBuilder: (context) => [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== TopNavi (60px) ==========
            _buildTopNavi(context, task: task, selectedDate: selectedDate),

            // ========== TextField (51px) ==========
            _buildTextField(context),

            const SizedBox(height: 24), // gap
            // ========== Deadline Label (32px) ==========
            _buildDeadlineLabel(context),

            const SizedBox(height: 12), // gap
            // ========== Deadline Picker (94px or 63px) ==========
            _buildDeadlinePicker(context),

            const SizedBox(height: 36), // gap
            // ========== DetailOptions (64px) ==========
            _buildDetailOptions(context, selectedDate: selectedDate),

            const SizedBox(height: 48), // gap
            // ========== Delete Button (52px) ==========
            if (task != null) _buildDeleteButton(context, task: task),

            const SizedBox(height: 40), // bottom
          ],
        ),
      ),
    ],

    backgroundColor: const Color(0xFFFCFCFC),
    surfaceTintColor: Colors.transparent,
  );
}

// ========================================
// TopNavi Component (60px)
// ========================================

Widget _buildTopNavi(
  BuildContext context, {
  required TaskData? task,
  required DateTime selectedDate,
}) {
  return Consumer<TaskFormController>(
    builder: (context, controller, child) {
      // 텍스트 입력 여부에 따라 색상 변경
      final hasTitle = controller.hasTitle;
      final titleColor = hasTitle
          ? const Color(0xFF7A7A7A)
          : const Color(0xFF505050);

      return Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title
            Text(
              'タスク',
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: -0.08,
                color: titleColor,
              ),
            ),

            // Save Button
            GestureDetector(
              onTap: () =>
                  _handleSave(context, task: task, selectedDate: selectedDate),
              child: Container(
                width: 74,
                height: 42,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
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
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                    letterSpacing: -0.065,
                    color: Color(0xFFFAFAFA),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// ========================================
// TextField Component (51px)
// ========================================

Widget _buildTextField(BuildContext context) {
  final taskController = Provider.of<TaskFormController>(
    context,
    listen: false,
  );

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ), // 🎯 28px (일정은 24px!)
      child: TextField(
        controller: taskController.titleController,
        autofocus: false,
        style: const TextStyle(
          fontFamily: 'LINE Seed JP App_TTF',
          fontSize: 19,
          fontWeight: FontWeight.w800, // 🎯 ExtraBold (일정은 Bold!)
          height: 1.4,
          letterSpacing: -0.095,
          color: Color(0xFF111111),
        ),
        decoration: const InputDecoration(
          hintText: 'タスクを入力', // 🎯 할일 placeholder
          hintStyle: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 19,
            fontWeight: FontWeight.w700, // Bold (placeholder)
            height: 1.4,
            letterSpacing: -0.095,
            color: Color(0xFFAAAAAA),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        maxLines: 1,
      ),
    ),
  );
}

// ========================================
// Deadline Label Component (32px)
// ========================================

Widget _buildDeadlineLabel(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 28,
      vertical: 4,
    ), // 🎯 4px vertical
    child: Row(
      children: [
        // Flag Icon
        Container(
          width: 19,
          height: 19,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF111111), width: 1.5),
          ),
          child: const Icon(
            Icons.flag_outlined,
            size: 14,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(width: 8),
        // Text
        const Text(
          '締め切り',
          style: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.4,
            letterSpacing: -0.065,
            color: Color(0xFF111111),
          ),
        ),
      ],
    ),
  );
}

// ========================================
// Deadline Picker Component
// ========================================

Widget _buildDeadlinePicker(BuildContext context) {
  return Consumer<TaskFormController>(
    builder: (context, controller, child) {
      final dueDate = controller.dueDate;

      if (dueDate == null) {
        // 미선택 상태
        return _buildEmptyDeadline(context);
      } else {
        // 선택됨 상태
        return _buildSelectedDeadline(context, dueDate);
      }
    },
  );
}

Widget _buildEmptyDeadline(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 48),
    child: SizedBox(
      width: 64,
      height: 94,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 숫자
          const Text(
            '10',
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 50,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.25,
              color: Color(0xFFEEEEEE),
            ),
          ),

          // + 버튼
          Positioned(
            top: 16,
            child: GestureDetector(
              onTap: () => _handleDeadlinePicker(context),
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  border: Border.all(
                    color: const Color.fromRGBO(17, 17, 17, 0.06),
                  ),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(186, 186, 186, 0.08),
                      offset: Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  size: 24,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSelectedDeadline(BuildContext context, DateTime deadline) {
  // 날짜 포맷: MM.DD.
  final dateText =
      '${deadline.month.toString().padLeft(2, '0')}.${deadline.day.toString().padLeft(2, '0')}.';

  // 연도 포맷: YYYY
  final yearText = deadline.year.toString();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: GestureDetector(
      onTap: () => _handleDeadlinePicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 (크게)
            Text(
              dateText,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 33,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.165,
                color: Color(0xFF111111),
              ),
            ),

            const SizedBox(height: 8),

            // 연도 (작게, 빨간색!)
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Text(
                yearText,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.095,
                  color: Color(0xFFE75858), // 🎯 빨간색!
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ========================================
// DetailOptions Component (64px)
// ========================================

Widget _buildDetailOptions(
  BuildContext context, {
  required DateTime selectedDate,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 48),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 반복
        _buildDetailOptionButton(
          context,
          icon: Icons.repeat,
          onTap: () => _handleRepeatPicker(context),
        ),
        const SizedBox(width: 8),

        // 리마인더
        _buildDetailOptionButton(
          context,
          icon: Icons.notifications_outlined,
          onTap: () => _handleReminderPicker(context),
        ),
        const SizedBox(width: 8),

        // 색상
        _buildDetailOptionButton(
          context,
          icon: Icons.palette_outlined,
          onTap: () => _handleColorPicker(context),
        ),
      ],
    ),
  );
}

Widget _buildDetailOptionButton(
  BuildContext context, {
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
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
      child: Icon(icon, size: 24, color: const Color(0xFF111111)),
    ),
  );
}

// ========================================
// Delete Button Component (52px)
// ========================================

Widget _buildDeleteButton(BuildContext context, {required TaskData task}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: GestureDetector(
      onTap: () => _handleDelete(context, task: task),
      child: Container(
        width: 100,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          border: Border.all(color: const Color.fromRGBO(186, 186, 186, 0.08)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(17, 17, 17, 0.03),
              offset: Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            const Icon(
              Icons.delete_outline,
              size: 20,
              color: Color(0xFFF74A4A),
            ),
            const SizedBox(width: 6),
            // Text
            const Text(
              '削除',
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: -0.065,
                color: Color(0xFFF74A4A),
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

void _handleSave(
  BuildContext context, {
  required TaskData? task,
  required DateTime selectedDate,
}) async {
  final taskController = Provider.of<TaskFormController>(
    context,
    listen: false,
  );
  final bottomSheetController = Provider.of<BottomSheetController>(
    context,
    listen: false,
  );

  if (!taskController.hasTitle) {
    debugPrint('⚠️ [TaskWolt] 제목 없음');
    return;
  }

  final db = GetIt.I<AppDatabase>();

  try {
    if (task != null) {
      // 기존 할일 수정
      await (db.update(db.task)..where((tbl) => tbl.id.equals(task.id))).write(
        TaskCompanion(
          title: Value(taskController.title),
          dueDate: Value(taskController.dueDate),
          colorId: Value(bottomSheetController.selectedColor),
          reminder: Value(bottomSheetController.reminder),
          repeatRule: Value(bottomSheetController.repeatRule),
        ),
      );
      debugPrint('✅ [TaskWolt] 할일 수정 완료');
    } else {
      // 새 할일 생성
      await db.createTask(
        TaskCompanion.insert(
          title: taskController.title,
          createdAt: selectedDate,
          listId: const Value('default'), // 기본 리스트
          dueDate: Value(taskController.dueDate),
          colorId: Value(bottomSheetController.selectedColor),
          reminder: Value(bottomSheetController.reminder),
          repeatRule: Value(bottomSheetController.repeatRule),
        ),
      );
      debugPrint('✅ [TaskWolt] 새 할일 생성 완료');
    }

    Navigator.pop(context);
  } catch (e) {
    debugPrint('❌ [TaskWolt] 저장 실패: $e');
  }
}

void _handleDelete(BuildContext context, {required TaskData task}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('할일 삭제'),
      content: const Text('이 할일을 삭제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('삭제', style: TextStyle(color: Color(0xFFF74A4A))),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final db = GetIt.I<AppDatabase>();
    await db.deleteTask(task.id);
    debugPrint('✅ [TaskWolt] 할일 삭제 완료');
    Navigator.pop(context);
  }
}

void _handleDeadlinePicker(BuildContext context) async {
  final controller = Provider.of<TaskFormController>(context, listen: false);

  final picked = await showDatePicker(
    context: context,
    initialDate: controller.dueDate ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );

  if (picked != null) {
    controller.setDueDate(picked);
  }
}

void _handleRepeatPicker(BuildContext context) {
  final bottomSheetController = Provider.of<BottomSheetController>(
    context,
    listen: false,
  );
  showWoltRepeatOption(
    context,
    initialRepeatRule: bottomSheetController.repeatRule.isNotEmpty
        ? bottomSheetController.repeatRule
        : null,
  );
}

void _handleReminderPicker(BuildContext context) {
  final bottomSheetController = Provider.of<BottomSheetController>(
    context,
    listen: false,
  );
  showWoltReminderOption(
    context,
    initialReminder: bottomSheetController.reminder.isNotEmpty
        ? bottomSheetController.reminder
        : null,
  );
}

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
