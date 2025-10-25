import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';
import 'package:figma_squircle/figma_squircle.dart';

import '../../Database/schedule_database.dart';
import '../../providers/bottom_sheet_controller.dart';
import '../../providers/task_form_controller.dart';
import '../../design_system/wolt_helpers.dart';
import '../../utils/temp_input_cache.dart'; // ✅ 임시 캐시
import 'package:flutter_svg/flutter_svg.dart'; // ✅ SVG 지원
import '../../const/color.dart'; // ✅ 색상 맵핑
import 'deadline_picker_modal.dart'; // ✅ 마감일 선택 바텀시트
import 'discard_changes_modal.dart'; // ✅ 변경 취소 확인 모달
import 'delete_confirmation_modal.dart'; // ✅ 삭제 확인 모달
import 'delete_repeat_confirmation_modal.dart'; // ✅ 반복 삭제 확인 모달
import 'change_repeat_confirmation_modal.dart'; // ✅ 반복 변경 확인 모달
import '../toast/action_toast.dart'; // ✅ 변경 토스트
import '../toast/save_toast.dart'; // ✅ 저장 토스트

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
}) async {
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
    if (task.executionDate != null) {
      taskController.setExecutionDate(task.executionDate!);
    }

    bottomSheetController.updateColor(task.colorId);
    bottomSheetController.updateReminder(task.reminder);
    bottomSheetController.updateRepeatRule(task.repeatRule);
  } else {
    // 새 할일 생성
    taskController.reset();
    bottomSheetController.reset(); // ✅ Provider 초기화

    // ✅ 임시 캐시에서 제목 복원 (새 할일일 때만)
    final cachedTitle = await TempInputCache.getTempTitle();
    if (cachedTitle != null && cachedTitle.isNotEmpty) {
      taskController.titleController.text = cachedTitle;
      debugPrint('✅ [TaskWolt] 임시 제목 복원: $cachedTitle');
    }

    // ✅ 임시 캐시에서 색상 복원 (새 할일일 때만)
    final cachedColor = await TempInputCache.getTempColor();
    if (cachedColor != null && cachedColor.isNotEmpty) {
      bottomSheetController.updateColor(cachedColor);
      debugPrint('✅ [TaskWolt] 임시 색상 복원: $cachedColor');
    }

    // ✅ 임시 캐시에서 실행일 복원
    final cachedExecutionDate = await TempInputCache.getTempExecutionDate();
    if (cachedExecutionDate != null) {
      taskController.setExecutionDate(cachedExecutionDate);
      debugPrint('✅ [TaskWolt] 임시 실행일 복원: $cachedExecutionDate');
    }

    // ✅ 임시 캐시에서 마감일 복원
    final cachedDueDate = await TempInputCache.getTempDueDate();
    if (cachedDueDate != null) {
      taskController.setDueDate(cachedDueDate);
      debugPrint('✅ [TaskWolt] 임시 마감일 복원: $cachedDueDate');
    }

    // ✅ 임시 캐시에서 리마인더 복원 (기본값 10분전)
    final cachedReminder = await TempInputCache.getTempReminder();
    if (cachedReminder != null && cachedReminder.isNotEmpty) {
      bottomSheetController.updateReminder(cachedReminder);
      debugPrint('✅ [TaskWolt] 임시 리마인더 복원: $cachedReminder');
    }

    // ⚠️ 반복 규칙은 캐시에서 복원하지 않음 (사용자가 명시적으로 선택해야 함)
  }

  debugPrint('✅ [TaskWolt] Provider 초기화 완료');

  // ✅ 초기 값 저장 (변경사항 감지용)
  final initialTitle = taskController.titleController.text;
  final initialDueDate = taskController.dueDate;
  final initialExecutionDate = taskController.executionDate;
  final initialColor = bottomSheetController.selectedColor;
  final initialReminder = bottomSheetController.reminder;
  final initialRepeatRule = bottomSheetController.repeatRule;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false, // ✅ 기본 드래그 닫기 비활성화
    enableDrag: true, // ✅ 드래그는 활성화
    builder: (sheetContext) {
      // ✅ DraggableScrollableController 생성
      final scrollableController = DraggableScrollableController();

      return WillPopScope(
        onWillPop: () async {
          // ✅ 변경사항 감지
          final hasChanges =
              initialTitle != taskController.titleController.text ||
              initialDueDate != taskController.dueDate ||
              initialExecutionDate != taskController.executionDate ||
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
                initialTitle != taskController.titleController.text ||
                initialDueDate != taskController.dueDate ||
                initialExecutionDate != taskController.executionDate ||
                initialColor != bottomSheetController.selectedColor ||
                initialReminder != bottomSheetController.reminder ||
                initialRepeatRule != bottomSheetController.repeatRule;

            if (hasChanges) {
              final confirmed = await showDiscardChangesModal(context);
              if (confirmed == true && sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
              // ✅ 취소했으면 아무것도 하지 않음 (바텀시트 유지)
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
                      initialTitle != taskController.titleController.text ||
                      initialDueDate != taskController.dueDate ||
                      initialExecutionDate != taskController.executionDate ||
                      initialColor != bottomSheetController.selectedColor ||
                      initialReminder != bottomSheetController.reminder ||
                      initialRepeatRule != bottomSheetController.repeatRule;

                  if (hasChanges) {
                    // ✅ 변경사항 있으면 확인 모달
                    showDiscardChangesModal(context).then((confirmed) {
                      if (confirmed == true && sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      } else if (confirmed == false) {
                        // ✅ 취소했으면 바텀시트를 다시 올림
                        try {
                          scrollableController.animateTo(
                            0.7, // initialChildSize로 복귀
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        } catch (e) {
                          debugPrint('❌ 바텀시트 복귀 실패: $e');
                        }
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
                controller: scrollableController, // ✅ 컨트롤러 연결
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
                  child: _buildTaskDetailPage(
                    context,
                    scrollController: scrollController,
                    task: task,
                    selectedDate: selectedDate,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ========================================
// Task Detail Page Builder
// ========================================

Widget _buildTaskDetailPage(
  BuildContext context, {
  required ScrollController scrollController,
  required TaskData? task,
  required DateTime selectedDate,
}) {
  return ListView(
    controller: scrollController,
    padding: EdgeInsets.zero,
    children: [
      // ========== TopNavi (60px) ==========
      _buildTopNavi(context, task: task, selectedDate: selectedDate),

      // ========== TextField (51px) ==========
      _buildTextField(context),

      const SizedBox(height: 24), // gap
      // ========== Date Selection Section (締切 + 実行日) ==========
      _buildDateSelectionSection(context),

      const SizedBox(height: 36), // gap
      // ========== DetailOptions (64px) ==========
      _buildDetailOptions(context, selectedDate: selectedDate),

      const SizedBox(height: 48), // gap
      // ========== Delete Button (52px) ==========
      if (task != null) _buildDeleteButton(context, task: task),

      const SizedBox(height: 32), // ✅ 하단 패딩 32px
    ],
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
// Date Selection Section (締切 + 実行日)
// ========================================

Widget _buildDateSelectionSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(right: 32), // ✅ 우측 32px 여백
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 期間 라벨 (아이콘 + 텍스트)
        _buildDeadlineLabel(context),

        const SizedBox(height: 12),

        // Row: 실행일(좌) + 마감일(우)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 좌측: 実行日만 표시
            Expanded(child: _buildExecutionDatePicker(context)),

            const SizedBox(width: 32),

            // 우측: 締め切り만 표시
            Expanded(child: _buildDeadlinePicker(context)),
          ],
        ),
      ],
    ),
  );
}

// ========================================
// Period Label Component (期間)
// ========================================

Widget _buildDeadlineLabel(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 4, 0, 4), // ✅ 좌측 24px만
    child: Row(
      children: [
        SvgPicture.asset(
          'asset/icon/calender-time.svg', // ✅ calender-time 아이콘
          width: 19,
          height: 19,
          colorFilter: const ColorFilter.mode(
            Color(0xFFFF5555), // ✅ 빨간색으로 변경해서 확실히 보이도록
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '期間',
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
// Execution Date Label Component
// ========================================

Widget _buildExecutionDateLabel(BuildContext context) {
  // ✅ 우측 섹션: 라벨 없음 (빈 위젯 반환)
  return const SizedBox.shrink();
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
        // 선택됨 상태 - 締め切り만 표시
        return _buildSelectedDeadline(context, dueDate);
      }
    },
  );
}

Widget _buildEmptyDeadline(BuildContext context) {
  // ✅ Figma: Frame 782 (padding 0px 24px)
  // DetailView_Object: width 64px, height 94px
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24), // ✅ 좌우 24px
    child: SizedBox(
      width: 64, // ✅ Figma: 64px
      height: 94, // ✅ Figma: 94px
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ✅ 締め切り label (회색)
          Positioned(
            top: 0,
            left: 3,
            child: Text(
              '締め切り', // ✅ 締め切り
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: -0.08,
                color: Color(0xFFBBBBBB), // ✅ 회색 #BBBBBB
              ),
            ),
          ),

          // ✅ Figma: 배경 숫자 "10" (50px, #EEEEEE)
          const Positioned(
            bottom: 0,
            child: Text(
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
          ),

          // ✅ + 버튼 (32x32px) - 가로세로 중앙 정렬
          Center(
            // ✅ Stack의 alignment.center와 함께 완전 중앙
            child: GestureDetector(
              onTap: () => _handleDueDatePicker(context), // ✅ 締め切り는 DueDate
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  border: Border.all(
                    color: const Color.fromRGBO(17, 17, 17, 0.06),
                    width: 1,
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

Widget _buildSelectedDeadline(BuildContext context, DateTime dueDate) {
  // ✅ 締め切り만 표시
  return Padding(
    padding: const EdgeInsets.only(left: 24, right: 0),
    child: _buildDeadlineCompactObject(
      context,
      label: '締め切り',
      date: dueDate,
      onTap: () => _handleDueDatePicker(context),
    ),
  );
}

// ========================================
// Compact Deadline Object (Row용 - 라벨과 날짜만)
// ========================================

Widget _buildDeadlineCompactObject(
  BuildContext context, {
  required String label,
  required DateTime date,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨 (実行日 또는 締め切り)
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.4,
            letterSpacing: -0.08,
            color: Color(0xFF7A7A7A),
          ),
        ),

        const SizedBox(height: 8),

        // 날짜 (M.DD 형식)
        Text(
          '${date.month}.${date.day}',
          style: const TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.12,
            color: Color(0xFF111111),
          ),
        ),

        const SizedBox(height: 4),

        // 연도 (빨간색)
        Text(
          date.year.toString(),
          style: const TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.005,
            color: Color(0xFFE75858), // ✅ 빨간색
          ),
        ),
      ],
    ),
  );
}

// ========================================
// Deadline Time Object (일정 스타일)
// ========================================

Widget _buildDeadlineTimeObject(
  BuildContext context, {
  required String label,
  required DateTime date,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 83, // ✅ 일정의 종일 모드 width와 동일
      height: 97, // ✅ 일정의 선택됨 높이와 동일
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Label ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: -0.08,
                color: Color(0xFF7A7A7A), // ✅ 선택됨 색상
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ========== Content (종일 스타일) ==========
          SizedBox(
            height: 63,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 연도 (작게)
                Text(
                  date.year.toString(),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontFamily: 'LINE Seed JP App_TTF',
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.095,
                    color: Color(0xFF111111),
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: Offset(0, 4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),

                // 날짜 (크게)
                Text(
                  '${date.month}.${date.day}',
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
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: Offset(0, 4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ========================================
// Execution Date Picker Component (実行日)
// ========================================

Widget _buildExecutionDatePicker(BuildContext context) {
  return Consumer<TaskFormController>(
    builder: (context, controller, child) {
      final executionDate = controller.executionDate; // ✅ executionDate 사용

      if (executionDate == null) {
        // 미선택 상태
        return _buildEmptyExecutionDate(context);
      } else {
        // 선택됨 상태
        return _buildSelectedExecutionDate(context, executionDate);
      }
    },
  );
}

Widget _buildEmptyExecutionDate(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24), // ✅ 좌우 24px
    child: SizedBox(
      width: 64,
      height: 94,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 実行日 라벨
          Positioned(
            top: 0,
            left: 3,
            child: Text(
              '実行日', // ✅ 実行日
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: -0.08,
                color: Color(0xFFBBBBBB),
              ),
            ),
          ),

          // 배경 숫자 "10"
          const Positioned(
            bottom: 0,
            child: Text(
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
          ),

          // ✅ + 버튼 - 가로세로 중앙 정렬
          Center(
            child: GestureDetector(
              onTap: () => _handleExecutionDatePicker(context),
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  border: Border.all(
                    color: const Color.fromRGBO(17, 17, 17, 0.06),
                    width: 1,
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

Widget _buildSelectedExecutionDate(
  BuildContext context,
  DateTime executionDate,
) {
  // ✅ 実行日 라벨 + 날짜 + 연도
  return Padding(
    padding: const EdgeInsets.only(left: 28, right: 0), // ✅ 좌측 28px
    child: GestureDetector(
      onTap: () => _handleExecutionDatePicker(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 실행일 라벨
          const Text(
            '実行日',
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.08,
              color: Color(0xFF7A7A7A),
            ),
          ),

          const SizedBox(height: 8),

          // 날짜 (M.DD 형식)
          Text(
            '${executionDate.month}.${executionDate.day}',
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.12,
              color: Color(0xFF111111),
            ),
          ),

          const SizedBox(height: 4),

          // 연도 (빨간색)
          Text(
            executionDate.year.toString(),
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.005,
              color: Color(0xFFE75858), // ✅ 빨간색
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildExecutionDateTimeObject(
  BuildContext context, {
  required String label,
  required DateTime date,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 83,
      height: 97,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: -0.08,
                color: Color(0xFF7A7A7A),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Content
          SizedBox(
            height: 63,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 연도
                Text(
                  date.year.toString(),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontFamily: 'LINE Seed JP App_TTF',
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.095,
                    color: Color(0xFF111111),
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: Offset(0, 4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),

                // 날짜
                Text(
                  '${date.month}.${date.day}',
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
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: Offset(0, 4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
        _buildRepeatOptionButton(context),
        const SizedBox(width: 8),

        // 리마인더
        _buildReminderOptionButton(context),
        const SizedBox(width: 8),

        // 색상
        _buildColorOptionButton(context),
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
      debugPrint('🔄 [RepeatButton] 리빌드: ${controller.repeatRule}');

      // 선택된 반복 규칙에서 display 텍스트 추출
      String? displayText;
      if (controller.repeatRule.isNotEmpty) {
        try {
          final repeatData = controller.repeatRule;
          if (repeatData.contains('"display":"')) {
            final startIndex = repeatData.indexOf('"display":"') + 11;
            final endIndex = repeatData.indexOf('"', startIndex);
            displayText = repeatData.substring(startIndex, endIndex);
            debugPrint('🔄 [RepeatButton] 표시 텍스트: $displayText');
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

  // ========== 1단계: 필수 필드 검증 ==========
  // 제목 검증
  if (!taskController.hasTitle) {
    debugPrint('⚠️ [TaskWolt] 제목 없음');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('タイトルを入力してください'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // 실행일과 마감일 관계 검증 (둘 다 있을 때만)
  if (taskController.executionDate != null && taskController.dueDate != null) {
    if (taskController.executionDate!.isAfter(taskController.dueDate!)) {
      debugPrint('⚠️ [TaskWolt] 실행일이 마감일보다 늦음');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('実行日は締め切りより前である必要があります'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
  }

  // ========== 2단계: 캐시에서 최신 데이터 읽기 ==========
  final cachedColor = await TempInputCache.getTempColor();
  final cachedRepeatRule = await TempInputCache.getTempRepeatRule();
  final cachedReminder = await TempInputCache.getTempReminder();
  final cachedExecutionDate = await TempInputCache.getTempExecutionDate();
  final cachedDueDate = await TempInputCache.getTempDueDate();

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
  final finalExecutionDate =
      cachedExecutionDate ?? taskController.executionDate;
  final finalDueDate = cachedDueDate ?? taskController.dueDate;

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

  final db = GetIt.I<AppDatabase>();

  try {
    if (task != null) {
      // ========== 🔄 기존에 반복 규칙이 있었거나, 반복 규칙을 제거하려는 경우 ==========
      final hadRepeatRule =
          task.repeatRule.isNotEmpty &&
          task.repeatRule != '{}' &&
          task.repeatRule != '[]';

      if (hadRepeatRule) {
        // 변경사항이 있는지 확인
        final hasChanges =
            task.title != taskController.title.trim() ||
            task.dueDate != finalDueDate ||
            task.executionDate != finalExecutionDate ||
            task.colorId != finalColor ||
            task.reminder != (safeReminder ?? '') ||
            task.repeatRule != (safeRepeatRule ?? '');

        if (hasChanges) {
          // 변경 확인 모달 표시
          await showChangeRepeatConfirmationModal(
            context,
            type: RepeatItemType.task,
            onChangeThis: () async {
              // ✅ この回のみ: 현재 할일만 포크해서 별도 항목으로 분리
              await _updateTaskThisOnly(
                db: db,
                originalTask: task,
                title: taskController.title.trim(),
                dueDate: finalDueDate,
                executionDate: finalExecutionDate,
                colorId: finalColor,
                reminder: safeReminder,
                selectedDate: selectedDate,
              );
            },
            onChangeFuture: () async {
              // ✅ この予定以降: 원본은 현재 날짜 전까지, 새 항목은 현재 날짜부터
              await _updateTaskFuture(
                db: db,
                originalTask: task,
                title: taskController.title.trim(),
                dueDate: finalDueDate,
                executionDate: finalExecutionDate,
                colorId: finalColor,
                reminder: safeReminder,
                repeatRule: safeRepeatRule,
                selectedDate: selectedDate,
              );
            },
            onChangeAll: () async {
              // ✅ すべての回: 원본 항목의 모든 필드 업데이트 (포크 없음)
              await _updateTaskAll(
                db: db,
                task: task,
                title: taskController.title.trim(),
                dueDate: finalDueDate,
                executionDate: finalExecutionDate,
                colorId: finalColor,
                reminder: safeReminder,
                repeatRule: safeRepeatRule,
              );
            },
          );

          // ✅ 캐시 클리어
          await TempInputCache.clearTempInput();
          debugPrint('🗑️ [TaskWolt] 캐시 클리어 완료');

          // 성공 피드백
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('タスクを更新しました'),
                duration: Duration(seconds: 1),
              ),
            );
          }
          return; // ✅ 모달 처리 완료 후 리턴
        }
      }

      // ========== 반복 규칙이 없거나 변경사항이 없는 경우: 일반 업데이트 ==========
      await (db.update(db.task)..where((tbl) => tbl.id.equals(task.id))).write(
        TaskCompanion(
          id: Value(task.id),
          title: Value(taskController.title.trim()),
          createdAt: Value(task.createdAt), // ✅ 기존 생성일 유지
          completed: Value(task.completed), // ✅ 완료 상태 유지
          listId: Value(task.listId), // ✅ 리스트 ID 유지
          dueDate: Value(finalDueDate),
          executionDate: Value(finalExecutionDate),
          colorId: Value(finalColor),
          reminder: Value(safeReminder ?? ''),
          repeatRule: Value(safeRepeatRule ?? ''),
        ),
      );
      debugPrint('✅ [TaskWolt] 할일 수정 완료');
      debugPrint('   - 제목: ${taskController.title}');
      debugPrint('   - 완료 상태 유지: ${task.completed}');
      debugPrint('   - 실행일: $finalExecutionDate');
      debugPrint('   - 마감일: $finalDueDate');

      // ✅ 수정 완료 후 캐시 클리어
      await TempInputCache.clearTempInput();
      debugPrint('🗑️ [TaskWolt] 캐시 클리어 완료');

      // ✅ 변경 토스트 표시
      if (context.mounted) {
        showActionToast(context, type: ToastType.change);
      }
    } else {
      // ========== 5단계: 새 할일 생성 (createdAt 명시) ==========
      final newId = await db.createTask(
        TaskCompanion.insert(
          title: taskController.title.trim(),
          createdAt: DateTime.now(), // ✅ 명시적 생성 시간 (로컬 시간)
          listId: const Value('default'), // 기본 리스트
          dueDate: Value(finalDueDate),
          executionDate: Value(finalExecutionDate),
          colorId: Value(finalColor),
          reminder: Value(safeReminder ?? ''),
          repeatRule: Value(safeRepeatRule ?? ''),
        ),
      );
      debugPrint('✅ [TaskWolt] 새 할일 생성 완료');
      debugPrint('   - 제목: ${taskController.title}');
      debugPrint('   - 색상: $finalColor');
      debugPrint('   - 실행일: $finalExecutionDate');
      debugPrint('   - 마감일: $finalDueDate');
      debugPrint('   - 반복: $safeRepeatRule');
      debugPrint('   - 리마인더: $safeReminder');
      debugPrint(
        '   ⚠️ executionDate가 ${finalExecutionDate == null ? "NULL → Inbox에 표시됨" : "설정됨 → DetailView에 표시됨"}',
      );

      // ========== 6단계: 캐시 클리어 ==========
      await TempInputCache.clearTempInput();
      debugPrint('🗑️ [TaskWolt] 캐시 클리어 완료');

      // ✅ 저장 토스트 표시 (인박스 or 캘린더)
      final toInbox = finalExecutionDate == null;
      if (context.mounted) {
        showSaveToast(
          context,
          toInbox: toInbox,
          onTap: () async {
            // 토스트 탭 시 해당 할일의 상세 모달 다시 열기
            final createdTask = await db.getTaskById(newId);
            if (createdTask != null && context.mounted) {
              showTaskDetailWoltModal(
                context,
                task: createdTask,
                selectedDate: finalExecutionDate ?? DateTime.now(),
              );
            }
          },
        );
      }
    }

    Navigator.pop(context);
  } catch (e, stackTrace) {
    debugPrint('❌ [TaskWolt] 저장 실패: $e');
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

void _handleDelete(BuildContext context, {required TaskData task}) async {
  // ✅ 반복 여부 확인
  final hasRepeat =
      task.repeatRule.isNotEmpty &&
      task.repeatRule != '{}' &&
      task.repeatRule != '[]';

  final db = GetIt.I<AppDatabase>();

  if (hasRepeat) {
    // ✅ 반복 있으면 → 반복 삭제 모달
    await showDeleteRepeatConfirmationModal(
      context,
      onDeleteThis: () async {
        // ✅ この回のみ 삭제: 내일부터 시작하도록 변경
        await _deleteTaskThisOnly(db, task);
        if (context.mounted) Navigator.pop(context);
      },
      onDeleteFuture: () async {
        // ✅ この予定以降 삭제: 어제까지로 종료
        await _deleteTaskFuture(db, task);
        if (context.mounted) Navigator.pop(context);
      },
      onDeleteAll: () async {
        // すべての回 삭제 (전체 삭제)
        debugPrint('✅ [TaskWolt] すべての回 삭제');
        await db.deleteTask(task.id);
        if (context.mounted) Navigator.pop(context);
      },
    );
  } else {
    // ✅ 반복 없으면 → 일반 삭제 모달
    await showDeleteConfirmationModal(
      context,
      onDelete: () async {
        debugPrint('✅ [TaskWolt] 할일 삭제 완료');
        await db.deleteTask(task.id);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }
}

void _handleExecutionDatePicker(BuildContext context) async {
  final controller = Provider.of<TaskFormController>(context, listen: false);

  // ✅ 実行日 선택 바텀시트 표시
  await showDeadlinePickerModal(
    context,
    initialDeadline: controller.executionDate ?? DateTime.now(),
    onDeadlineSelected: (selectedDate) {
      controller.setExecutionDate(selectedDate); // ✅ 실행일만 설정
      // ✅ 임시 캐시에 저장
      TempInputCache.saveTempExecutionDate(selectedDate);
    },
  );
}

void _handleDueDatePicker(BuildContext context) async {
  final controller = Provider.of<TaskFormController>(context, listen: false);

  // ✅ 締め切り(마감일) 선택 바텀시트 표시
  await showDeadlinePickerModal(
    context,
    initialDeadline: controller.dueDate ?? DateTime.now(),
    onDeadlineSelected: (selectedDate) {
      controller.setDueDate(selectedDate); // ✅ 마감일만 설정
      // ✅ 임시 캐시에 저장
      TempInputCache.saveTempDueDate(selectedDate);
    },
  );
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

// ========================================
// 반복 Task 변경 헬퍼 함수들
// ========================================

/// ✅ この回のみ: 현재 할일만 포크해서 별도 항목으로 분리
Future<void> _updateTaskThisOnly({
  required AppDatabase db,
  required TaskData originalTask,
  required String title,
  required DateTime? dueDate,
  required DateTime? executionDate,
  required String colorId,
  required String? reminder,
  required DateTime selectedDate,
}) async {
  // 1. 새로운 할일 생성 (포크) - repeatRule 제거
  await db.createTask(
    TaskCompanion.insert(
      title: title,
      createdAt: DateTime.now(),
      listId: Value(originalTask.listId),
      dueDate: Value(dueDate),
      executionDate: Value(executionDate),
      colorId: Value(colorId),
      reminder: Value(reminder ?? ''),
      repeatRule: const Value(''), // ✅ 반복 규칙 제거 (독립 항목)
      completed: Value(originalTask.completed),
    ),
  );

  debugPrint('✅ [TaskWolt] この回のみ: 포크 생성 완료');
  debugPrint('   - 원본 ID: ${originalTask.id}');
  debugPrint('   - 새 제목: $title');
  debugPrint('   - 반복 규칙: 제거됨 (독립 항목)');
}

/// ✅ この予定以降: 원본은 현재 날짜 전까지, 새 항목은 현재 날짜부터
Future<void> _updateTaskFuture({
  required AppDatabase db,
  required TaskData originalTask,
  required String title,
  required DateTime? dueDate,
  required DateTime? executionDate,
  required String colorId,
  required String? reminder,
  required String? repeatRule,
  required DateTime selectedDate,
}) async {
  // 1. 원본 할일: 어제까지만 표시되도록 설정
  final today = DateTime.now();
  final yesterday = DateTime(today.year, today.month, today.day - 1);

  await (db.update(
    db.task,
  )..where((tbl) => tbl.id.equals(originalTask.id))).write(
    TaskCompanion(
      id: Value(originalTask.id),
      dueDate: Value(yesterday), // 마감일을 어제로
      repeatRule: const Value(''), // 반복 제거
    ),
  );

  // 2. 새 항목 생성 (오늘부터 시작)
  await db.createTask(
    TaskCompanion.insert(
      title: title,
      createdAt: DateTime.now(),
      listId: Value(originalTask.listId),
      dueDate: Value(dueDate),
      executionDate: Value(executionDate ?? today), // 오늘부터
      colorId: Value(colorId),
      reminder: Value(reminder ?? ''),
      repeatRule: Value(repeatRule ?? ''),
      completed: const Value(false),
    ),
  );

  debugPrint('✅ [TaskWolt] この予定以降: 원본 종료 + 새 항목 생성 완료');
  debugPrint('   - 원본 ID: ${originalTask.id} → 종료일: $yesterday');
  debugPrint('   - 새 항목: $title (시작일: $today)');
  debugPrint('   - 반복 규칙: $repeatRule');
  debugPrint('   ⚠️ TODO: 원본 종료일 설정 필요');
}

/// ✅ すべての回: 원본 항목의 모든 필드 업데이트 (포크 없음)
Future<void> _updateTaskAll({
  required AppDatabase db,
  required TaskData task,
  required String title,
  required DateTime? dueDate,
  required DateTime? executionDate,
  required String colorId,
  required String? reminder,
  required String? repeatRule,
}) async {
  // 원본 할일 업데이트 (모든 필드)
  await (db.update(db.task)..where((tbl) => tbl.id.equals(task.id))).write(
    TaskCompanion(
      id: Value(task.id),
      title: Value(title),
      createdAt: Value(task.createdAt), // 생성일 유지
      completed: Value(task.completed), // 완료 상태 유지
      listId: Value(task.listId), // 리스트 ID 유지
      dueDate: Value(dueDate),
      executionDate: Value(executionDate),
      colorId: Value(colorId),
      reminder: Value(reminder ?? ''),
      repeatRule: Value(repeatRule ?? ''),
    ),
  );

  debugPrint('✅ [TaskWolt] すべての回: 원본 업데이트 완료');
  debugPrint('   - ID: ${task.id}');
  debugPrint('   - 새 제목: $title');
  debugPrint('   - 반복 규칙: $repeatRule');
}

// ==================== 삭제 헬퍼 함수 ====================

/// ✅ この回のみ 삭제: 오늘만 제외하고 내일부터 다시 시작
Future<void> _deleteTaskThisOnly(AppDatabase db, TaskData task) async {
  // 1. 오늘을 제외한 새로운 시작일 계산
  final today = DateTime.now();
  final tomorrow = DateTime(today.year, today.month, today.day + 1);

  // 2. executionDate를 내일로 변경하여 업데이트
  await (db.update(db.task)..where((tbl) => tbl.id.equals(task.id))).write(
    TaskCompanion(id: Value(task.id), executionDate: Value(tomorrow)),
  );

  debugPrint('✅ [TaskWolt] この回のみ 삭제 완료');
  debugPrint('   - ID: ${task.id}');
  debugPrint('   - 새 시작일: $tomorrow');
}

/// ✅ この予定以降 삭제: 어제까지만 유지하고 이후 반복 종료
Future<void> _deleteTaskFuture(AppDatabase db, TaskData task) async {
  // 1. 어제 날짜 계산
  final today = DateTime.now();
  final yesterday = DateTime(today.year, today.month, today.day - 1);

  // 2. 반복 규칙에서 endDate를 어제로 설정
  // TODO: repeatRule JSON 파싱 및 endDate 추가 로직 필요
  // 현재는 단순히 오늘부터 표시 안 되도록 executionDate를 과거로 변경
  await (db.update(db.task)..where((tbl) => tbl.id.equals(task.id))).write(
    TaskCompanion(
      id: Value(task.id),
      dueDate: Value(yesterday), // 마감일을 어제로 변경
      repeatRule: const Value(''), // 반복 제거 (임시)
    ),
  );

  debugPrint('✅ [TaskWolt] この予定以降 삭제 완료');
  debugPrint('   - ID: ${task.id}');
  debugPrint('   - 종료일: $yesterday');
  debugPrint('   ⚠️ TODO: repeatRule endDate 설정 필요');
}
