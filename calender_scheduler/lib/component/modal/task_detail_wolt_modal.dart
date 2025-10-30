import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:rrule/rrule.dart';

import '../../Database/schedule_database.dart';
import '../../providers/bottom_sheet_controller.dart';
import '../../providers/task_form_controller.dart';
import '../../design_system/wolt_helpers.dart';
import '../../utils/temp_input_cache.dart'; // ✅ 임시 캐시
import '../../utils/recurring_event_helpers.dart'
    as RecurringHelpers; // ✅ 반복 이벤트 헬퍼
import 'package:flutter_svg/flutter_svg.dart'; // ✅ SVG 지원
import '../../const/color.dart'; // ✅ 색상 맵핑
import 'deadline_picker_modal.dart'; // ✅ 마감일 선택 바텀시트
import 'discard_changes_modal.dart'; // ✅ 변경 취소 확인 모달
import 'delete_confirmation_modal.dart'; // ✅ 삭제 확인 모달
import 'delete_repeat_confirmation_modal.dart'; // ✅ 반복 삭제 확인 모달
import 'edit_repeat_confirmation_modal.dart'; // ✅ 반복 수정 확인 모달
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
Future<void> showTaskDetailWoltModal(
  BuildContext context, {
  required TaskData? task,
  required DateTime selectedDate,
}) async {
  print('');
  print('╔═══════════════════════════════════════════════════════════════╗');
  print('║  🚀 [MODAL OPEN] showTaskDetailWoltModal() 시작             ║');
  print('╚═══════════════════════════════════════════════════════════════╝');
  print(
    '📋 Task: ${task != null ? '${task.id} - ${task.title}' : 'null (신규)'}',
  );
  print('📅 Selected Date: $selectedDate');
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

    // 🎯 통합 캐시에서 공통 데이터 복원
    final commonData = await TempInputCache.getCommonData();

    if (commonData['title'] != null && commonData['title']!.isNotEmpty) {
      taskController.titleController.text = commonData['title']!;
      debugPrint('✅ [TaskWolt] 통합 제목 복원: ${commonData['title']}');
    }

    if (commonData['colorId'] != null && commonData['colorId']!.isNotEmpty) {
      bottomSheetController.updateColor(commonData['colorId']!);
      debugPrint('✅ [TaskWolt] 통합 색상 복원: ${commonData['colorId']}');
    }

    if (commonData['reminder'] != null && commonData['reminder']!.isNotEmpty) {
      bottomSheetController.updateReminder(commonData['reminder']!);
      debugPrint('✅ [TaskWolt] 통합 리마인더 복원: ${commonData['reminder']}');
    }

    if (commonData['repeatRule'] != null &&
        commonData['repeatRule']!.isNotEmpty) {
      bottomSheetController.updateRepeatRule(commonData['repeatRule']!);
      debugPrint('✅ [TaskWolt] 통합 반복규칙 복원: ${commonData['repeatRule']}');
    }

    // 🎯 통합 캐시에서 할일 전용 데이터 복원
    final taskData = await TempInputCache.getTaskData();
    if (taskData != null) {
      if (taskData['executionDate'] != null) {
        taskController.setExecutionDate(taskData['executionDate']!);
        debugPrint('✅ [TaskWolt] 통합 실행일 복원: ${taskData['executionDate']}');
      }
      if (taskData['dueDate'] != null) {
        taskController.setDueDate(taskData['dueDate']!);
        debugPrint('✅ [TaskWolt] 통합 마감일 복원: ${taskData['dueDate']}');
      }
    }
  }

  debugPrint('✅ [TaskWolt] Provider 초기화 완료');
  print('✅ Provider 초기화 완료');

  // 🎯 자동 캐시 저장: 제목 변경 시
  void autoSaveTitle() {
    if (task == null) {
      // 새 항목일 때만 캐시 저장
      TempInputCache.saveCommonData(
        title: taskController.titleController.text,
        colorId: bottomSheetController.selectedColor,
        reminder: bottomSheetController.reminder,
        repeatRule: bottomSheetController.repeatRule,
      );
    }
  }

  // 🎯 자동 캐시 저장: 날짜 변경 시
  void autoSaveTaskData() {
    if (task == null) {
      // 새 항목일 때만 캐시 저장
      TempInputCache.saveTaskData(
        executionDate: taskController.executionDate,
        dueDate: taskController.dueDate,
      );
    }
  }

  // 리스너 등록
  taskController.titleController.addListener(autoSaveTitle);
  taskController.addListener(autoSaveTaskData);
  bottomSheetController.addListener(autoSaveTitle);

  // ✅ 초기 값 저장 (변경사항 감지용)
  final initialTitle = taskController.titleController.text;
  final initialDueDate = taskController.dueDate;
  final initialExecutionDate = taskController.executionDate;
  final initialColor = bottomSheetController.selectedColor;
  final initialReminder = bottomSheetController.reminder;
  final initialRepeatRule = bottomSheetController.repeatRule;

  print('📊 초기 상태:');
  print('   Title: $initialTitle');
  print('   DueDate: $initialDueDate');
  print('   ExecutionDate: $initialExecutionDate');
  print('   Color: $initialColor');
  print('   Reminder: $initialReminder');
  print('   RepeatRule: $initialRepeatRule');

  // ✅ 드래그 방향 추적 변수
  double? previousExtent;
  bool isDismissing = false; // 팝업 중복 방지

  print('🔓 showModalBottomSheet 호출 시작...');
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.3), // ✅ 약간 어둡게 (터치 감지용)
    isDismissible: false, // ✅ 기본 드래그 닫기 비활성화
    enableDrag: false, // ✅ 기본 드래그 비활성화 (수동으로 처리)
    builder: (sheetContext) => WillPopScope(
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
      child: Stack(
        children: [
          // ✅ 배리어 영역 (전체 화면)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                // ✅ 배리어 영역 터치 시
                print('');
                print(
                  '╔═══════════════════════════════════════════════════════════════╗',
                );
                print('║  🎯 [BARRIER TAP] 배리어 영역 터치 감지                    ║');
                print(
                  '╚═══════════════════════════════════════════════════════════════╝',
                );
                debugPrint('🐛 [TaskWolt] 배리어 터치 감지');

                final hasChanges =
                    initialTitle != taskController.titleController.text ||
                    initialDueDate != taskController.dueDate ||
                    initialExecutionDate != taskController.executionDate ||
                    initialColor != bottomSheetController.selectedColor ||
                    initialReminder != bottomSheetController.reminder ||
                    initialRepeatRule != bottomSheetController.repeatRule;

                print('📊 변경사항 감지: $hasChanges');

                if (hasChanges) {
                  print('⚠️ 변경사항 있음 - 확인 모달 표시');
                  // ✅ 변경사항 있으면 확인 모달
                  final confirmed = await showDiscardChangesModal(context);
                  print('✅ 사용자 확인 결과: $confirmed');
                  if (confirmed == true && sheetContext.mounted) {
                    print('❌ 모달 닫기 - Navigator.pop() 호출');
                    Navigator.of(sheetContext).pop();
                    print('✅ Navigator.pop() 완료');
                  } else {
                    print('ℹ️ 사용자가 취소 - 모달 유지');
                  }
                } else {
                  print('ℹ️ 변경사항 없음 - 바로 닫기');
                  // ✅ 변경사항 없으면 바로 닫기
                  if (sheetContext.mounted) {
                    print('❌ 모달 닫기 - Navigator.pop() 호출');
                    Navigator.of(sheetContext).pop();
                    print('✅ Navigator.pop() 완료');
                  }
                }
                print('');
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
                print('');
                print(
                  '╔═══════════════════════════════════════════════════════════════╗',
                );
                print('║  ⬇️ [DRAG DOWN] 아래로 드래그 닫기 감지                   ║');
                print(
                  '╚═══════════════════════════════════════════════════════════════╝',
                );
                debugPrint('🐛 [TaskWolt] 아래로 드래그 닫기 감지');
                print('📊 Extent: ${notification.extent}');
                print('📊 MinExtent: ${notification.minExtent}');

                isDismissing = true; // ✅ 즉시 플래그 설정하여 중복 호출 방지
                print('🔒 isDismissing 플래그 설정: true');

                // ✅ 변경사항 확인
                final hasChanges =
                    initialTitle != taskController.titleController.text ||
                    initialDueDate != taskController.dueDate ||
                    initialExecutionDate != taskController.executionDate ||
                    initialColor != bottomSheetController.selectedColor ||
                    initialReminder != bottomSheetController.reminder ||
                    initialRepeatRule != bottomSheetController.repeatRule;

                print('📊 변경사항 감지: $hasChanges');

                if (hasChanges) {
                  print('⚠️ 변경사항 있음 - 확인 모달 표시 (PostFrameCallback)');
                  // ✅ 변경사항 있으면 확인 모달 띄우기
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (sheetContext.mounted) {
                      final confirmed = await showDiscardChangesModal(context);
                      print('✅ 사용자 확인 결과: $confirmed');
                      if (confirmed == true && sheetContext.mounted) {
                        print('❌ 모달 닫기 - Navigator.pop() 호출');
                        Navigator.of(sheetContext).pop();
                        print('✅ Navigator.pop() 완료');
                      } else {
                        print('ℹ️ 사용자가 취소 - 모달 유지, isDismissing 리셋');
                        // ✅ 사용자가 취소한 경우에만 플래그 리셋
                        isDismissing = false;
                      }
                    }
                  });
                  print('');
                  return true; // ✅ 드래그 이벤트 소비 (닫기 방지)
                } else {
                  print('ℹ️ 변경사항 없음 - 바로 닫기 (PostFrameCallback)');
                  // ✅ 변경사항 없으면 바로 닫기
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (sheetContext.mounted) {
                      try {
                        print('❌ 모달 닫기 - Navigator.pop() 호출');
                        Navigator.of(sheetContext, rootNavigator: false).pop();
                        print('✅ Navigator.pop() 완료');
                        // ✅ pop 성공 후에는 리셋하지 않음 (이미 dispose됨)
                      } catch (e) {
                        debugPrint('❌ 바텀시트 닫기 실패: $e');
                        print('❌ 닫기 실패: $e - isDismissing 리셋');
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
                  debugPrint('🐛 [TaskWolt] 바텀시트 내부 터치');
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
                  child: _buildTaskDetailPage(
                    context,
                    scrollController: scrollController,
                    task: task,
                    selectedDate: selectedDate,
                    initialTitle: initialTitle,
                    initialExecutionDate: initialExecutionDate,
                    initialDueDate: initialDueDate,
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
// Task Detail Page Builder
// ========================================

Widget _buildTaskDetailPage(
  BuildContext context, {
  required ScrollController scrollController,
  required TaskData? task,
  required DateTime selectedDate,
  required String initialTitle,
  required DateTime? initialExecutionDate,
  required DateTime? initialDueDate,
  required String initialColor,
  required String initialReminder,
  required String initialRepeatRule,
}) {
  return ListView(
    controller: scrollController,
    padding: EdgeInsets.zero,
    children: [
      // ========== TopNavi (60px) ==========
      _buildTopNavi(
        context,
        task: task,
        selectedDate: selectedDate,
        initialTitle: initialTitle,
        initialExecutionDate: initialExecutionDate,
        initialDueDate: initialDueDate,
        initialColor: initialColor,
        initialReminder: initialReminder,
        initialRepeatRule: initialRepeatRule,
      ),

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
      if (task != null)
        _buildDeleteButton(
          context,
          task: task,
          selectedDate: selectedDate,
        ), // ✅ 수정

      const SizedBox(height: 20), // ✅ 하단 패딩 20px (최대 확장 시 바텀시트 끝에서 20px 여백)
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
  required String initialTitle,
  required DateTime? initialExecutionDate,
  required DateTime? initialDueDate,
  required String initialColor,
  required String initialReminder,
  required String initialRepeatRule,
}) {
  final taskController = Provider.of<TaskFormController>(
    context,
    listen: false,
  );

  return ValueListenableBuilder<TextEditingValue>(
    valueListenable: taskController.titleController,
    builder: (context, titleValue, child) {
      return Consumer2<TaskFormController, BottomSheetController>(
        builder: (context, taskController, bottomSheetController, child) {
          // 🎯 필수 항목 체크 (할일: 제목만 필수)
          final hasRequiredFields = titleValue.text.trim().isNotEmpty;

          // ✅ 변경사항 감지 (초기값과 비교)
          final hasChanges =
              initialTitle != titleValue.text ||
              initialExecutionDate != taskController.executionDate ||
              initialDueDate != taskController.dueDate ||
              initialColor != bottomSheetController.selectedColor.toString() ||
              initialReminder != bottomSheetController.reminder ||
              initialRepeatRule != bottomSheetController.repeatRule;

          // 🎯 保存 버튼 표시 조건:
          // 1. 새 항목: 제목이 입력됨
          // 2. 기존 항목: 제목 있음 + 변경사항 있음
          final showSaveButton = task == null
              ? hasRequiredFields // 새 항목
              : (hasRequiredFields && hasChanges); // 기존 항목

          // 텍스트 입력 여부에 따라 색상 변경
          final hasTitle = taskController.hasTitle;
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

                // 🎯 조건부 버튼: 조건 충족하면 完了, 아니면 X 아이콘
                showSaveButton
                    ? GestureDetector(
                        onTap: () => _handleSave(
                          context,
                          task: task,
                          selectedDate: selectedDate,
                        ),
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

  print('');
  print('╔═══════════════════════════════════════════════════════════════╗');
  print('║  ❌ [MODAL CLOSED] showModalBottomSheet 완료 - 모달 닫힘    ║');
  print('╚═══════════════════════════════════════════════════════════════╝');
  print('⏰ 모달 닫힌 시각: ${DateTime.now()}');
  print('');
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

Widget _buildDeleteButton(
  BuildContext context, {
  required TaskData task,
  required DateTime selectedDate,
}) {
  // ✅ 추가
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: GestureDetector(
      onTap: () => _handleDelete(
        context,
        task: task,
        selectedDate: selectedDate,
      ), // ✅ 수정
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
    if (task != null && task.id != -1) {
      // ========== 🔄 RecurringPattern 테이블에서 실제 반복 여부 확인 ==========
      final recurringPattern = await db.getRecurringPattern(
        entityType: 'task',
        entityId: task.id,
      );
      final hadRepeatRule = recurringPattern != null;

      debugPrint(
        '🔍 [TaskWolt] 저장 시 반복 확인: Task #${task.id} → ${hadRepeatRule ? "반복 있음" : "반복 없음"}',
      );

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
          // ✅ 반복 할일 수정 확인 모달 표시
          await showEditRepeatConfirmationModal(
            context,
            onEditThis: () async {
              // ✅ この回のみ 수정: RecurringException 생성
              debugPrint(
                '🔥 [TaskWolt] updateTaskThisOnly 호출 - selectedDate: $selectedDate',
              ); // ✅ 추가
              await RecurringHelpers.updateTaskThisOnly(
                db: db,
                task: task,
                selectedDate: selectedDate, // ✅ 수정
                updatedTask: TaskCompanion(
                  id: Value(task.id),
                  title: Value(taskController.title.trim()),
                  dueDate: Value(finalDueDate),
                  executionDate: Value(finalExecutionDate),
                  colorId: Value(finalColor),
                  reminder: Value(safeReminder ?? ''),
                ),
              );
              debugPrint('✅ [TaskWolt] この回のみ 수정 완료');
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
              debugPrint(
                '🔥 [TaskWolt] updateTaskFuture 호출 - selectedDate: $selectedDate',
              ); // ✅ 추가
              final newRRule =
                  safeRepeatRule != null && safeRepeatRule.isNotEmpty
                  ? _convertJsonRepeatRuleToRRule(
                      safeRepeatRule,
                      selectedDate,
                    ) // ✅ 수정
                  : null;

              await RecurringHelpers.updateTaskFuture(
                db: db,
                task: task,
                selectedDate: selectedDate, // ✅ 수정
                updatedTask: TaskCompanion.insert(
                  title: taskController.title.trim(),
                  createdAt: DateTime.now(),
                  completed: const Value(false),
                  listId: Value(task.listId),
                  dueDate: Value(finalDueDate),
                  executionDate: Value(finalExecutionDate),
                  colorId: Value(finalColor),
                  reminder: Value(safeReminder ?? ''),
                  repeatRule: Value(safeRepeatRule ?? ''),
                ),
                newRRule: newRRule,
              );
              debugPrint('✅ [TaskWolt] この予定以降 수정 완료');
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
              final newRRule =
                  safeRepeatRule != null && safeRepeatRule.isNotEmpty
                  ? _convertJsonRepeatRuleToRRule(
                      safeRepeatRule,
                      finalExecutionDate ?? DateTime.now(),
                    )
                  : null;

              await RecurringHelpers.updateTaskAll(
                db: db,
                task: task,
                updatedTask: TaskCompanion(
                  id: Value(task.id),
                  title: Value(taskController.title.trim()),
                  createdAt: Value(task.createdAt),
                  completed: Value(task.completed),
                  listId: Value(task.listId),
                  dueDate: Value(finalDueDate),
                  executionDate: Value(finalExecutionDate),
                  colorId: Value(finalColor),
                  reminder: Value(safeReminder ?? ''),
                  repeatRule: Value(safeRepeatRule ?? ''),
                ),
                newRRule: newRRule,
              );
            },
          );

          return; // ✅ 모달 작업 완료 후 함수 종료
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

      // ========== RecurringPattern 업데이트 ==========
      if (safeRepeatRule != null && safeRepeatRule.isNotEmpty) {
        final dtstart = finalExecutionDate ?? task.createdAt;
        final rrule = convertRepeatRuleToRRule(safeRepeatRule, dtstart);

        // 🔥 날짜만 추출 (시간은 00:00:00으로 통일)
        final dtstartDateOnly = DateTime(
          dtstart.year,
          dtstart.month,
          dtstart.day,
        );

        if (rrule != null) {
          // 기존 패턴 확인
          final existingPattern = await db.getRecurringPattern(
            entityType: 'task',
            entityId: task.id,
          );

          if (existingPattern != null) {
            // 업데이트
            await (db.update(
              db.recurringPattern,
            )..where((tbl) => tbl.id.equals(existingPattern.id))).write(
              RecurringPatternCompanion(
                rrule: Value(rrule),
                dtstart: Value(dtstartDateOnly),
              ),
            );
            debugPrint('✅ [TaskWolt] RecurringPattern 업데이트 완료');
          } else {
            // 생성
            await db.createRecurringPattern(
              RecurringPatternCompanion.insert(
                entityType: 'task',
                entityId: task.id,
                rrule: rrule,
                dtstart: dtstartDateOnly,
                exdate: const Value(''),
              ),
            );
            debugPrint('✅ [TaskWolt] RecurringPattern 생성 완료');
          }
          debugPrint('   - RRULE: $rrule');
          debugPrint('   - DTSTART: $dtstartDateOnly (날짜만)');
        }
      } else {
        // 반복 규칙이 없으면 기존 패턴 삭제
        final existingPattern = await db.getRecurringPattern(
          entityType: 'task',
          entityId: task.id,
        );
        if (existingPattern != null) {
          await (db.delete(
            db.recurringPattern,
          )..where((tbl) => tbl.id.equals(existingPattern.id))).go();
          debugPrint('✅ [TaskWolt] RecurringPattern 삭제 완료');
        }
      }

      // 🎯 수정 완료 후 통합 캐시 클리어
      await TempInputCache.clearCacheForType('task');
      debugPrint('🗑️ [TaskWolt] 할일 통합 캐시 클리어 완료');

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

      // ========== 5.5단계: RecurringPattern 생성 (반복 규칙이 있으면) ==========
      if (safeRepeatRule != null && safeRepeatRule.isNotEmpty) {
        final dtstart = finalExecutionDate ?? DateTime.now();
        final rrule = convertRepeatRuleToRRule(safeRepeatRule, dtstart);

        // 🔥 날짜만 추출 (시간은 00:00:00으로 통일)
        final dtstartDateOnly = DateTime(
          dtstart.year,
          dtstart.month,
          dtstart.day,
        );

        if (rrule != null) {
          await db.createRecurringPattern(
            RecurringPatternCompanion.insert(
              entityType: 'task',
              entityId: newId,
              rrule: rrule,
              dtstart: dtstartDateOnly,
              exdate: const Value(''),
            ),
          );
          debugPrint('✅ [TaskWolt] RecurringPattern 생성 완료');
          debugPrint('   - RRULE: $rrule');
          debugPrint('   - DTSTART: $dtstartDateOnly (날짜만)');
        } else {
          debugPrint('⚠️ [TaskWolt] RRULE 변환 실패');
        }
      }

      // ========== 6단계: 통합 캐시 클리어 ==========
      await TempInputCache.clearCacheForType('task');
      debugPrint('🗑️ [TaskWolt] 할일 통합 캐시 클리어 완료');

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

void _handleDelete(
  BuildContext context, {
  required TaskData task,
  required DateTime selectedDate,
}) async {
  // ✅ 추가
  final db = GetIt.I<AppDatabase>();

  // ✅ RecurringPattern 테이블에서 실제 반복 여부 확인
  final recurringPattern = await db.getRecurringPattern(
    entityType: 'task',
    entityId: task.id,
  );
  final hasRepeat = recurringPattern != null;

  debugPrint(
    '🔍 [TaskWolt] 삭제 시 반복 확인: Task #${task.id} → ${hasRepeat ? "반복 있음" : "반복 없음"}',
  );

  if (hasRepeat) {
    // ✅ 반복 있으면 → 반복 삭제 모달
    await showDeleteRepeatConfirmationModal(
      context,
      onDeleteThis: () async {
        // ✅ この回のみ 삭제: RecurringException 생성
        debugPrint(
          '🔥 [TaskWolt] deleteTaskThisOnly 호출 - selectedDate: $selectedDate',
        ); // ✅ 추가
        await RecurringHelpers.deleteTaskThisOnly(
          db: db,
          task: task,
          selectedDate: selectedDate, // ✅ 수정
        );
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
        debugPrint(
          '🔥 [TaskWolt] deleteTaskFuture 호출 - selectedDate: $selectedDate',
        ); // ✅ 추가
        await RecurringHelpers.deleteTaskFuture(
          db: db,
          task: task,
          selectedDate: selectedDate, // ✅ 수정
        );
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
        await RecurringHelpers.deleteTaskAll(db: db, task: task);
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

// ==================== RRULE 변환 헬퍼 함수 ====================

/// JSON repeatRule을 RRULE 문자열로 변환
String? _convertJsonRepeatRuleToRRule(String jsonRepeatRule, DateTime dtstart) {
  try {
    final json = jsonDecode(jsonRepeatRule) as Map<String, dynamic>;
    final value = json['value'] as String?;

    if (value == null || value.isEmpty) {
      debugPrint('⚠️ [RRuleConvert] value 필드 없음');
      return null;
    }

    debugPrint('🔍 [RRuleConvert] 파싱 시작: $value');

    final parts = value.split(':');
    final freq = parts[0];
    final daysStr = parts.length > 1 ? parts[1] : null;

    switch (freq) {
      case 'daily':
        if (daysStr != null && daysStr.isNotEmpty) {
          final days = daysStr.split(',');
          final weekdays = days.map(_jpDayToWeekday).whereType<int>().toList();

          if (weekdays.isEmpty) {
            debugPrint('⚠️ [RRuleConvert] 요일 변환 실패: $daysStr');
            return null;
          }

          final rrule = RecurrenceRule(
            frequency: Frequency.weekly,
            byWeekDays: weekdays.map((wd) => ByWeekDayEntry(wd)).toList(),
          );

          final rruleString = rrule.toString();
          debugPrint('✅ [RRuleConvert] API 변환 완료: $rruleString');
          return rruleString.replaceFirst('RRULE:', '');
        } else {
          debugPrint('✅ [RRuleConvert] 매일 반복');
          return 'FREQ=DAILY';
        }

      case 'weekly':
        if (daysStr != null && daysStr.isNotEmpty) {
          final days = daysStr.split(',');
          final weekdays = days.map(_jpDayToWeekday).whereType<int>().toList();

          if (weekdays.isEmpty) {
            debugPrint('⚠️ [RRuleConvert] 요일 변환 실패: $daysStr');
            return null;
          }

          final rrule = RecurrenceRule(
            frequency: Frequency.weekly,
            byWeekDays: weekdays.map((wd) => ByWeekDayEntry(wd)).toList(),
          );

          final rruleString = rrule.toString();
          debugPrint('✅ [RRuleConvert] API 변환 완료: $rruleString');
          return rruleString.replaceFirst('RRULE:', '');
        } else {
          final weekday = dtstart.weekday;
          final rrule = RecurrenceRule(
            frequency: Frequency.weekly,
            byWeekDays: [ByWeekDayEntry(weekday)],
          );
          debugPrint('✅ [RRuleConvert] 매주 반복');
          return rrule.toString().replaceFirst('RRULE:', '');
        }

      case 'monthly':
        debugPrint('✅ [RRuleConvert] 매월 ${dtstart.day}일');
        return 'FREQ=MONTHLY;BYMONTHDAY=${dtstart.day}';

      case 'yearly':
        debugPrint('✅ [RRuleConvert] 매년 ${dtstart.month}월 ${dtstart.day}일');
        return 'FREQ=YEARLY;BYMONTH=${dtstart.month};BYMONTHDAY=${dtstart.day}';

      default:
        debugPrint('⚠️ [RRuleConvert] 알 수 없는 빈도: $freq');
        return null;
    }
  } catch (e) {
    debugPrint('⚠️ [RRuleConvert] JSON 파싱 실패: $e');
    return null;
  }
}

/// 일본어/한국어 요일 → DateTime.weekday 변환
int? _jpDayToWeekday(String jpDay) {
  switch (jpDay) {
    case '月':
    case '월':
      return DateTime.monday;
    case '火':
    case '화':
      return DateTime.tuesday;
    case '水':
    case '수':
      return DateTime.wednesday;
    case '木':
    case '목':
      return DateTime.thursday;
    case '金':
    case '금':
      return DateTime.friday;
    case '土':
    case '토':
      return DateTime.saturday;
    case '日':
    case '일':
      return DateTime.sunday;
    default:
      debugPrint('⚠️ [RRuleConvert] 알 수 없는 요일: $jpDay');
      return null;
  }
}

// ==================== 삭제 헬퍼 함수 ====================

/// ✅ この回のみ 삭제: 오늘만 제외하고 내일부터 다시 시작
/// ✅ この回のみ 삭제: RFC 5545 EXDATE로 예외 처리
Future<void> _deleteTaskThisOnly(AppDatabase db, TaskData task) async {
  // 1. RecurringPattern 조회
  final pattern = await db.getRecurringPattern(
    entityType: 'task',
    entityId: task.id,
  );

  if (pattern == null) {
    debugPrint('⚠️ [TaskWolt] RecurringPattern 없음');
    return;
  }

  // 2. 현재 날짜 (선택된 인스턴스의 originalDate)
  final originalDate = task.executionDate ?? DateTime.now();

  // 3. RecurringException 생성 (취소 표시)
  await db.createRecurringException(
    RecurringExceptionCompanion(
      recurringPatternId: Value(pattern.id),
      originalDate: Value(originalDate),
      isCancelled: const Value(true), // 취소 (삭제)
      isRescheduled: const Value(false),
    ),
  );

  debugPrint('✅ [TaskWolt] この回のみ 삭제 완료 (RFC 5545 EXDATE)');
  debugPrint('   - Task ID: ${task.id}');
  debugPrint('   - Pattern ID: ${pattern.id}');
  debugPrint('   - Original Date: $originalDate');
}

/// ✅ この予定以降 삭제: RFC 5545 UNTIL로 종료일 설정
Future<void> _deleteTaskFuture(AppDatabase db, TaskData task) async {
  // 1. RecurringPattern 조회
  final pattern = await db.getRecurringPattern(
    entityType: 'task',
    entityId: task.id,
  );

  if (pattern == null) {
    debugPrint('⚠️ [TaskWolt] RecurringPattern 없음');
    return;
  }

  // 2. ✅ 선택된 날짜(executionDate) 포함 이후 모두 삭제 → 어제가 마지막 발생
  final selectedDate = task.executionDate ?? DateTime.now();
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

  debugPrint('✅ [TaskWolt] この予定以降 삭제 완료 (RFC 5545 UNTIL)');
  debugPrint('   - Task ID: ${task.id}');
  debugPrint('   - Pattern ID: ${pattern.id}');
  debugPrint('   - Selected Date: $dateOnly');
  debugPrint('   - UNTIL (종료일): $until');
}

// ========================================
// Task/Habit repeatRule JSON → RRULE 변환
// ========================================

/// Task/Habit의 repeatRule JSON을 RRULE로 변환
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

      debugPrint('🐛 [TaskWolt-RepeatConvert] daysStr: $daysStr');
      debugPrint('🐛 [TaskWolt-RepeatConvert] days split: $days');

      // 일본어 요일 → DateTime.weekday (with -1 보정)
      final weekdays = days.map(_jpDayToWeekday).whereType<int>().toList();

      debugPrint('🐛 [TaskWolt-RepeatConvert] weekdays 변환: $weekdays');

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

/// ✅ この回のみ 수정: RFC 5545 RecurringException으로 예외 처리
Future<void> _editTaskThisOnly(
  AppDatabase db,
  TaskData task,
  TaskFormController controller,
  DateTime? dueDate,
  DateTime? executionDate,
  String color,
  String? reminder,
) async {
  // 1. RecurringPattern 조회
  final pattern = await db.getRecurringPattern(
    entityType: 'task',
    entityId: task.id,
  );

  if (pattern == null) {
    debugPrint('⚠️ [TaskWolt] RecurringPattern 없음');
    return;
  }

  // 2. 현재 날짜 (선택된 인스턴스의 originalDate)
  final originalDate = task.executionDate ?? DateTime.now();

  // 3. RecurringException 생성 (수정된 내용 저장)
  await db.createRecurringException(
    RecurringExceptionCompanion(
      recurringPatternId: Value(pattern.id),
      originalDate: Value(originalDate),
      isCancelled: const Value(false),
      isRescheduled: Value(executionDate != task.executionDate),
      newStartDate: Value(executionDate),
      newEndDate: Value(dueDate),
      modifiedTitle: Value(controller.title.trim()),
      modifiedColorId: Value(color),
    ),
  );

  debugPrint('✅ [TaskWolt] この回のみ 수정 완료 (RFC 5545 Exception)');
  debugPrint('   - Task ID: ${task.id}');
  debugPrint('   - Pattern ID: ${pattern.id}');
  debugPrint('   - Original Date: $originalDate');
  debugPrint('   - Modified Title: ${controller.title.trim()}');
}

/// ✅ この予定以降 수정: RFC 5545 RRULE 분할
Future<void> _editTaskFuture(
  AppDatabase db,
  TaskData task,
  TaskFormController controller,
  DateTime? dueDate,
  DateTime? executionDate,
  String color,
  String? reminder,
  String? repeatRule,
) async {
  // 1. 기존 RecurringPattern 조회
  final oldPattern = await db.getRecurringPattern(
    entityType: 'task',
    entityId: task.id,
  );

  if (oldPattern == null) {
    debugPrint('⚠️ [TaskWolt] RecurringPattern 없음');
    return;
  }

  // 2. ✅ 선택된 날짜(executionDate) 포함 이후 모두 수정 → 어제가 마지막 발생
  final selectedDate = task.executionDate ?? DateTime.now();
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

  // 4. 새로운 Task 생성 (선택 날짜부터 시작)
  final newTaskId = await db.createTask(
    TaskCompanion(
      title: Value(controller.title.trim()),
      dueDate: Value(dueDate),
      executionDate: Value(executionDate),
      colorId: Value(color),
      repeatRule: Value(repeatRule ?? ''),
      listId: Value(task.listId),
      completed: const Value(false),
    ),
  );

  // 5. 새로운 RecurringPattern 생성 (반복 규칙이 있으면)
  if (repeatRule != null && repeatRule.isNotEmpty) {
    final rruleString = convertRepeatRuleToRRule(
      repeatRule,
      executionDate ?? DateTime.now(),
    );

    if (rruleString != null) {
      await db.createRecurringPattern(
        RecurringPatternCompanion(
          entityType: const Value('task'),
          entityId: Value(newTaskId),
          rrule: Value(rruleString),
          dtstart: Value(executionDate ?? DateTime.now()),
          until: Value(oldPattern.until), // 기존 종료일 유지
        ),
      );
    }
  }

  debugPrint('✅ [TaskWolt] この予定以降 수정 완료 (RFC 5545 Split)');
  debugPrint('   - Old Task ID: ${task.id} (UNTIL: $yesterday)');
  debugPrint('   - New Task ID: $newTaskId (Start: $executionDate)');
}
