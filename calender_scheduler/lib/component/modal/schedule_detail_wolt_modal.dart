import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ✅ SVG 지원
import 'dart:convert'; // ✅ JSON 파싱
import 'package:rrule/rrule.dart'; // ✅ RecurrenceRule API

import '../../Database/schedule_database.dart';
import '../../providers/bottom_sheet_controller.dart';
import '../../providers/schedule_form_controller.dart';
import '../../design_system/wolt_helpers.dart'; // ✅ Wolt 최신 모달
import '../../utils/temp_input_cache.dart'; // ✅ 임시 캐시
import '../../const/color.dart'; // ✅ 색상 맵핑
import 'date_time_picker_modal.dart'; // ✅ 스무스 바텀시트 날짜/시간 선택기
import 'discard_changes_modal.dart'; // ✅ 변경 취소 확인 모달
import 'delete_confirmation_modal.dart'; // ✅ 삭제 확인 모달
import 'delete_repeat_confirmation_modal.dart'; // ✅ 반복 삭제 확인 모달
import 'edit_repeat_confirmation_modal.dart'; // ✅ 반복 수정 확인 모달
import '../toast/action_toast.dart'; // ✅ 변경 토스트
import '../toast/save_toast.dart'; // ✅ 저장 토스트
import '../../utils/recurring_event_helpers.dart'
    as RecurringHelpers; // ✅ 반복 이벤트 헬퍼

/// 일정 상세 Wolt Modal Sheet
///
/// **Figma Design Spec (ULTRA PRECISE - 100% Match):**
///
/// **Modal Container:**
/// - Size: 393 x 583px
/// - Background: #FCFCFC
/// - Border: 1px solid rgba(17, 17, 17, 0.1)
/// - Shadow: 0px 2px 20px rgba(165, 165, 165, 0.2)
/// - Border radius: 36px 36px 0px 0px
///
/// **TopNavi (60px):**
/// - Padding: 28px 28px 9px 28px
/// - Title: "スケジュール" - Bold 16px, #505050
/// - Button: "完了" - ExtraBold 13px, #FAFAFA on #111111, 74x42px, radius 16px
///
/// **TextField (51px):**
/// - Padding: 12px 0px (vertical)
/// - Inner padding: 0px 24px (horizontal)
/// - Placeholder: "予定を追加" - Bold 19px, #AAAAAA
/// - Text: Bold 19px, #111111
///
/// **AllDay Toggle (32px):**
/// - Padding: 0px 24px
/// - Icon: 19x19px, #111111 border 1.5px
/// - Text: "終日" - Bold 13px, #111111
/// - Toggle: 40x24px, #E4E4E4, circle 16px #FAFAFA
///
/// **Time Picker (94px):**
/// - Padding: 0px 50px
/// - Gap: 32px between start/end
/// - Label: "開始" - Bold 16px, #BBBBBB
/// - Value: "10" - ExtraBold 50px, #EEEEEE (inactive) / #111111 (active)
/// - Edit Button: 32x32px circle, #262626, icon 24x24px #FFFFFF
///
/// **DetailOptions (64px):**
/// - Padding: 0px 48px (습관은 0px 22px!)
/// - Gap: 8px between buttons
/// - Button size: 64x64px
/// - Order: 반복 → 리마인더 → 색상
///
/// **Delete Button (52px):**
/// - Padding: 0px 24px
/// - Size: 100x52px
/// - Icon: 20x20px, #F74A4A
/// - Text: "削除" - Bold 13px, #F74A4A
Future<void> showScheduleDetailWoltModal(
  BuildContext context, {
  required ScheduleData? schedule,
  required DateTime selectedDate,
}) async {
  final scheduleController = Provider.of<ScheduleFormController>(
    context,
    listen: false,
  );
  final bottomSheetController = Provider.of<BottomSheetController>(
    context,
    listen: false,
  );

  if (schedule != null) {
    // 기존 일정 수정
    scheduleController.titleController.text = schedule.summary;
    scheduleController.setStartDate(schedule.start);
    scheduleController.setEndDate(schedule.end);

    // 시간 설정
    scheduleController.setStartTime(TimeOfDay.fromDateTime(schedule.start));
    scheduleController.setEndTime(TimeOfDay.fromDateTime(schedule.end));

    bottomSheetController.updateColor(schedule.colorId);
    bottomSheetController.updateReminder(schedule.alertSetting);
    bottomSheetController.updateRepeatRule(schedule.repeatRule);
  } else {
    // 새 일정 생성
    scheduleController.reset();
    bottomSheetController.reset(); // ✅ Provider 초기화

    // 🎯 통합 캐시에서 공통 데이터 복원
    final commonData = await TempInputCache.getCommonData();

    if (commonData['title'] != null && commonData['title']!.isNotEmpty) {
      scheduleController.titleController.text = commonData['title']!;
      debugPrint('✅ [ScheduleWolt] 통합 제목 복원: ${commonData['title']}');
    }

    if (commonData['colorId'] != null && commonData['colorId']!.isNotEmpty) {
      bottomSheetController.updateColor(commonData['colorId']!);
      debugPrint('✅ [ScheduleWolt] 통합 색상 복원: ${commonData['colorId']}');
    }

    if (commonData['reminder'] != null && commonData['reminder']!.isNotEmpty) {
      bottomSheetController.updateReminder(commonData['reminder']!);
      debugPrint('✅ [ScheduleWolt] 통합 리마인더 복원: ${commonData['reminder']}');
    }

    if (commonData['repeatRule'] != null &&
        commonData['repeatRule']!.isNotEmpty) {
      bottomSheetController.updateRepeatRule(commonData['repeatRule']!);
      debugPrint('✅ [ScheduleWolt] 통합 반복규칙 복원: ${commonData['repeatRule']}');
    }

    // 🎯 통합 캐시에서 일정 전용 데이터 복원
    final scheduleData = await TempInputCache.getScheduleData();
    if (scheduleData != null) {
      final cachedStart = scheduleData['startDateTime'] as DateTime?;
      final cachedEnd = scheduleData['endDateTime'] as DateTime?;

      if (cachedStart != null && cachedEnd != null) {
        scheduleController.setStartDate(cachedStart);
        scheduleController.setEndDate(cachedEnd);
        scheduleController.setStartTime(TimeOfDay.fromDateTime(cachedStart));
        scheduleController.setEndTime(TimeOfDay.fromDateTime(cachedEnd));
        debugPrint(
          '✅ [ScheduleWolt] 통합 일정 날짜/시간 복원: $cachedStart ~ $cachedEnd',
        );
      } else {
        // 캐시가 없으면 기본값 사용
        scheduleController.setStartDate(selectedDate);
        scheduleController.setEndDate(selectedDate);
      }
    } else {
      // 캐시가 없으면 기본값 사용
      scheduleController.setStartDate(selectedDate);
      scheduleController.setEndDate(selectedDate);
    }
  }

  debugPrint('✅ [ScheduleWolt] Provider 초기화 완료');

  // 🎯 자동 캐시 저장: 제목 변경 시
  void autoSaveTitle() {
    if (schedule == null) {
      // 새 항목일 때만 캐시 저장
      TempInputCache.saveCommonData(
        title: scheduleController.titleController.text,
        colorId: bottomSheetController.selectedColor,
        reminder: bottomSheetController.reminder,
        repeatRule: bottomSheetController.repeatRule,
      );
    }
  }

  // 🎯 자동 캐시 저장: 날짜/시간 변경 시
  void autoSaveScheduleData() {
    if (schedule == null &&
        scheduleController.startDate != null &&
        scheduleController.endDate != null &&
        scheduleController.startTime != null &&
        scheduleController.endTime != null) {
      // 새 항목일 때만 캐시 저장
      final startDateTime = DateTime(
        scheduleController.startDate!.year,
        scheduleController.startDate!.month,
        scheduleController.startDate!.day,
        scheduleController.startTime!.hour,
        scheduleController.startTime!.minute,
      );
      final endDateTime = DateTime(
        scheduleController.endDate!.year,
        scheduleController.endDate!.month,
        scheduleController.endDate!.day,
        scheduleController.endTime!.hour,
        scheduleController.endTime!.minute,
      );

      TempInputCache.saveScheduleData(
        startDateTime: startDateTime,
        endDateTime: endDateTime,
      );
    }
  }

  // 리스너 등록
  scheduleController.titleController.addListener(autoSaveTitle);
  scheduleController.addListener(autoSaveScheduleData);
  bottomSheetController.addListener(autoSaveTitle);

  debugPrint('✅ [ScheduleWolt] Provider 초기화 완료');

  // ✅ 초기 값 저장 (변경사항 감지용)
  final initialTitle = scheduleController.titleController.text;
  final initialStartDate = scheduleController.startDate;
  final initialEndDate = scheduleController.endDate;
  final initialStartTime = scheduleController.startTime;
  final initialEndTime = scheduleController.endTime;
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
            initialTitle != scheduleController.titleController.text ||
            initialStartDate != scheduleController.startDate ||
            initialEndDate != scheduleController.endDate ||
            initialStartTime != scheduleController.startTime ||
            initialEndTime != scheduleController.endTime ||
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
                debugPrint('🐛 [ScheduleWolt] 배리어 터치 감지');

                final hasChanges =
                    initialTitle != scheduleController.titleController.text ||
                    initialStartDate != scheduleController.startDate ||
                    initialEndDate != scheduleController.endDate ||
                    initialStartTime != scheduleController.startTime ||
                    initialEndTime != scheduleController.endTime ||
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
              // ❌ 드래그 핸들러 제거: 배리어는 터치만 처리
              child: Container(color: Colors.transparent),
            ),
          ),
          // ✅ 바텀시트 (배리어 위에)
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              // ✅ 드래그 방향 감지 (아래로만)
              final isMovingDown =
                  previousExtent != null &&
                  notification.extent < previousExtent!;
              previousExtent = notification.extent;

              debugPrint(
                '🔥 [BOTTOM SHEET DRAG] extent=${notification.extent.toStringAsFixed(2)}, minExtent=${notification.minExtent.toStringAsFixed(2)}, isMovingDown=$isMovingDown',
              );

              // ✅ 바텀시트를 아래로 드래그하여 minChildSize 이하로 내릴 때만
              if (isMovingDown &&
                  notification.extent <= notification.minExtent + 0.05 &&
                  !isDismissing) {
                debugPrint('🐛 [ScheduleWolt] 아래로 드래그 닫기 감지 - DISMISS 시작');

                isDismissing = true; // ✅ 즉시 플래그 설정하여 중복 호출 방지

                // ✅ 변경사항 확인
                final hasChanges =
                    initialTitle != scheduleController.titleController.text ||
                    initialStartDate != scheduleController.startDate ||
                    initialEndDate != scheduleController.endDate ||
                    initialStartTime != scheduleController.startTime ||
                    initialEndTime != scheduleController.endTime ||
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
                    debugPrint('🔥 [BOTTOM SHEET] Navigator.pop() 실행 시작');
                    if (sheetContext.mounted) {
                      try {
                        Navigator.of(sheetContext, rootNavigator: false).pop();
                        debugPrint('🔥 [BOTTOM SHEET] Navigator.pop() 완료');
                        // ✅ pop 성공 후에는 리셋하지 않음 (이미 dispose됨)
                      } catch (e) {
                        debugPrint('❌ 바텀시트 닫기 실패: $e');
                        isDismissing = false; // ✅ 실패한 경우에만 리셋
                      }
                    }
                  });
                  return true; // ✅ 이벤트 소비하여 부모로 전파 방지
                }
              }
              return true; // ✅ 모든 드래그 이벤트 소비 (부모 DateDetailView로 전파 방지)
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              snap: true,
              snapSizes: const [0.5, 0.7, 0.95],
              builder: (context, scrollController) => GestureDetector(
                // 🔥 중요: 바텀시트 내부 터치는 부모로 전파 방지
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // ✅ 바텀시트 내부 터치는 아무것도 안함 (포커스 해제 등)
                  debugPrint('🐛 [ScheduleWolt] 바텀시트 내부 터치');
                },
                // ❌ onVerticalDrag* 제거: DraggableScrollableSheet가 직접 처리
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
                  child: _buildScheduleDetailPage(
                    context,
                    scrollController: scrollController,
                    schedule: schedule,
                    selectedDate: selectedDate,
                    initialTitle: initialTitle,
                    initialStartDate: initialStartDate,
                    initialEndDate: initialEndDate,
                    initialStartTime: initialStartTime,
                    initialEndTime: initialEndTime,
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
// Schedule Detail Page Builder
// ========================================

Widget _buildScheduleDetailPage(
  BuildContext context, {
  required ScrollController scrollController,
  required ScheduleData? schedule,
  required DateTime selectedDate,
  required String initialTitle,
  required DateTime? initialStartDate,
  required DateTime? initialEndDate,
  required TimeOfDay? initialStartTime,
  required TimeOfDay? initialEndTime,
  required String initialColor,
  required String initialReminder,
  required String initialRepeatRule,
}) {
  return ListView(
    controller: scrollController,
    padding: EdgeInsets.zero,
    children: [
      const SizedBox(height: 32), // ✅ Figma: 상단 여백 32px
      // ========== TopNavi (60px) ==========
      _buildTopNavi(
        context,
        schedule: schedule,
        selectedDate: selectedDate,
        initialTitle: initialTitle,
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        initialStartTime: initialStartTime,
        initialEndTime: initialEndTime,
        initialColor: initialColor,
        initialReminder: initialReminder,
        initialRepeatRule: initialRepeatRule,
      ),

      const SizedBox(height: 4), // ✅ TextField 상단 여백 4px
      // ========== TextField (51px) ==========
      _buildTextField(context),

      const SizedBox(height: 24), // gap
      // ========== AllDay Toggle (32px) ==========
      _buildAllDayToggle(context),

      const SizedBox(height: 12), // gap
      // ========== Time Picker (94px ~ 97px) ==========
      _buildTimePicker(context),

      const SizedBox(height: 36), // gap
      // ========== DetailOptions (64px) ==========
      _buildDetailOptions(context, selectedDate: selectedDate),

      const SizedBox(height: 48), // gap
      // ========== Delete Button (52px) ==========
      if (schedule != null)
        _buildDeleteButton(
          context,
          schedule: schedule,
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
  required ScheduleData? schedule,
  required DateTime selectedDate,
  required String initialTitle,
  required DateTime? initialStartDate,
  required DateTime? initialEndDate,
  required TimeOfDay? initialStartTime,
  required TimeOfDay? initialEndTime,
  required String initialColor,
  required String initialReminder,
  required String initialRepeatRule,
}) {
  final scheduleController = Provider.of<ScheduleFormController>(
    context,
    listen: false,
  );

  return ValueListenableBuilder<TextEditingValue>(
    valueListenable: scheduleController.titleController,
    builder: (context, titleValue, child) {
      return Consumer2<ScheduleFormController, BottomSheetController>(
        builder: (context, scheduleController, bottomSheetController, child) {
          // 🎯 필수 항목 체크 (일정: 제목 + 시작시간 + 종료시간)
          final hasRequiredFields =
              titleValue.text.trim().isNotEmpty &&
              scheduleController.startDateTime != null &&
              scheduleController.endDateTime != null;

          // ✅ 변경사항 감지 (초기값과 비교)
          final hasChanges =
              initialTitle != titleValue.text ||
              initialStartDate != scheduleController.startDate ||
              initialEndDate != scheduleController.endDate ||
              initialStartTime != scheduleController.startTime ||
              initialEndTime != scheduleController.endTime ||
              initialColor != bottomSheetController.selectedColor.toString() ||
              initialReminder != bottomSheetController.reminder ||
              initialRepeatRule != bottomSheetController.repeatRule;

          // 🎯 保存 버튼 표시 조건:
          // 1. 새 항목: 필수 항목이 모두 입력됨
          // 2. 기존 항목: 필수 항목 있음 + 변경사항 있음
          final showSaveButton = schedule == null
              ? hasRequiredFields // 새 항목
              : (hasRequiredFields && hasChanges); // 기존 항목

          return Container(
            width: 393,
            height: 60,
            padding: const EdgeInsets.fromLTRB(28, 9, 28, 9), // Figma: 9px 28px
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                const Text(
                  'スケジュール',
                  style: TextStyle(
                    fontFamily: 'LINE Seed JP App_TTF',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.4, // 140%
                    letterSpacing: -0.005 * 16, // -0.005em
                    color: Color(0xFF505050),
                  ),
                ),

                // 🎯 조건부 버튼: 조건 충족하면 完了, 아니면 X 아이콘
                showSaveButton
                    ? GestureDetector(
                        onTap: () => _handleSave(
                          context,
                          schedule: schedule,
                          selectedDate: selectedDate,
                        ),
                        child: Container(
                          width: 74,
                          height: 42,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ), // 12px 24px
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
                              height: 1.4, // 140%
                              letterSpacing: -0.005 * 13, // -0.005em
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
}

// ========================================
// TextField Component (51px)
// ========================================

Widget _buildTextField(BuildContext context) {
  final scheduleController = Provider.of<ScheduleFormController>(
    context,
    listen: false,
  );

  return Container(
    width: 393,
    height: 51,
    padding: const EdgeInsets.only(
      top: 16,
      bottom: 12,
    ), // ✅ 상단 16px (12+4), 하단 12px
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24), // Figma: 0px 24px
      child: TextField(
        controller: scheduleController.titleController,
        autofocus: false,
        style: const TextStyle(
          fontFamily: 'LINE Seed JP App_TTF',
          fontSize: 19,
          fontWeight: FontWeight.w700,
          height: 1.4, // 140%
          letterSpacing: -0.005 * 19, // -0.005em
          color: Color(0xFF111111),
        ),
        decoration: const InputDecoration(
          hintText: 'スケジュールを入力',
          hintStyle: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            height: 1.4, // 140%
            letterSpacing: -0.005 * 19, // -0.005em
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
// AllDay Toggle Component (32px)
// ========================================

Widget _buildAllDayToggle(BuildContext context) {
  return Container(
    width: 393,
    height: 32,
    padding: const EdgeInsets.only(left: 24, right: 28), // ✅ 좌측 24px, 우측 28px
    child: Consumer<ScheduleFormController>(
      builder: (context, controller, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Icon + Text (Frame 715)
            Row(
              children: [
                // Icon - SVG 사용
                SvgPicture.asset(
                  'asset/icon/Schedule_AllDay.svg', // ✅ 대소문자 수정
                  width: 19,
                  height: 19,
                ),
                const SizedBox(width: 8), // Figma: gap 8px
                // Text
                const Text(
                  '終日',
                  style: TextStyle(
                    fontFamily: 'LINE Seed JP App_TTF',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.4, // 140%
                    letterSpacing: -0.005 * 13, // -0.005em
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),

            // Right: Toggle (Frame 749)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                8,
                4,
                0,
                4,
              ), // Figma: 4px 0px 4px 8px
              child: GestureDetector(
                onTap: controller.toggleAllDay,
                child: Container(
                  width: 40,
                  height: 24,
                  decoration: BoxDecoration(
                    color: controller.isAllDay
                        ? const Color(0xFF111111)
                        : const Color(0xFFE4E4E4),
                    border: Border.all(
                      color: controller.isAllDay
                          ? const Color(0xFF111111)
                          : const Color(0xFFE4E4E4),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: controller.isAllDay
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFAFA),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

// ========================================
// Time Picker Component (94px ~ 97px)
// ========================================

Widget _buildTimePicker(BuildContext context) {
  return Consumer<ScheduleFormController>(
    builder: (context, controller, child) {
      final isAllDay = controller.isAllDay;
      final startDate = controller.startDate;
      final startTime = controller.startTime;
      final endDate = controller.endDate;
      final endTime = controller.endTime;

      return Padding(
        padding: const EdgeInsets.only(
          left: 48,
          right: 48,
        ), // ✅ 날짜 피커와 동일: 좌우 48px
        child: Stack(
          children: [
            // 좌측: 開始
            Align(
              alignment: Alignment.centerLeft,
              child: _buildTimeObject(
                context,
                label: '開始',
                date: startDate,
                time: startTime,
                isAllDay: isAllDay,
                onTap: () => _handleDateTimePicker(context),
              ),
            ),

            // 중앙: 화살표
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 20), // ✅ 날짜 피커와 동일
                child: SvgPicture.asset(
                  'asset/icon/Date_Picker_arrow.svg',
                  width: 8,
                  height: 46,
                ),
              ),
            ),

            // 우측: 終了
            Align(
              alignment: Alignment.centerRight,
              child: _buildTimeObject(
                context,
                label: '終了',
                date: endDate,
                time: endTime,
                isAllDay: isAllDay,
                onTap: () => _handleDateTimePicker(context),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildTimeObject(
  BuildContext context, {
  required String label,
  required DateTime? date,
  required TimeOfDay? time,
  required bool isAllDay,
  required VoidCallback onTap,
}) {
  // 동적 width 계산
  double width;
  if (isAllDay) {
    width = 83; // 종일
  } else if (time != null) {
    width = 99; // 시간 선택됨
  } else {
    width = 64; // 미선택
  }

  // 상태별 높이
  final height = (time != null || isAllDay) ? 97.0 : 94.0;

  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Label ==========
          _buildLabel(label, time, isAllDay),

          const SizedBox(height: 12),

          // ========== Content ==========
          // ✅ 終日일 때는 시간이 있어도 날짜만 표시
          if (isAllDay && date != null)
            _buildAllDayContent(date)
          else if (time != null && !isAllDay)
            _buildTimeSelectedContent(date!, time, isAllDay)
          else
            _buildEmptyContent(onTap),
        ],
      ),
    ),
  );
}

// ========================================
// Label Component
// ========================================

Widget _buildLabel(String label, TimeOfDay? time, bool isAllDay) {
  // 색상 결정
  Color labelColor;
  if (time != null || isAllDay) {
    labelColor = const Color(0xFF7A7A7A); // 선택됨
  } else {
    labelColor = const Color(0xFFBBBBBB); // 미선택
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3), // Figma: 0px 3px
    child: Text(
      label,
      style: TextStyle(
        fontFamily: 'LINE Seed JP App_TTF',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.4, // 140%
        letterSpacing: -0.005 * 16, // -0.005em
        color: labelColor,
      ),
    ),
  );
}

// ========================================
// Empty State (초기 상태 - Stack)
// ========================================

Widget _buildEmptyContent(VoidCallback onTap) {
  return SizedBox(
    width: 64,
    height: 60,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // 배경 숫자 (회색)
        Text(
          '10',
          style: const TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 50,
            fontWeight: FontWeight.w800,
            height: 1.2, // 120%
            letterSpacing: -0.005 * 50, // -0.005em
            color: Color(0xFFEEEEEE), // 회색
          ),
        ),

        // + 버튼 (위에 겹침!)
        Positioned(
          top: 16, // calc(50% - 32px/2 + 16px)
          child: GestureDetector(
            onTap: onTap,
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
              child: const Icon(Icons.add, size: 24, color: Color(0xFFFFFFFF)),
            ),
          ),
        ),
      ],
    ),
  );
}

// ========================================
// Time Selected Content (시간 선택됨)
// ========================================

Widget _buildTimeSelectedContent(DateTime date, TimeOfDay time, bool isAllDay) {
  if (isAllDay) {
    return _buildAllDayContent(date);
  }

  // 날짜 포맷: YY. M. DD
  final dateText =
      '${date.year.toString().substring(2)}. ${date.month}. ${date.day}';

  // 시간 포맷: HH:mm
  final timeText =
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  return SizedBox(
    height: 65,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start, // ✅ 좌측 정렬 유지
      children: [
        // 날짜 (작게)
        Text(
          dateText,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: const TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            height: 1.2, // 120%
            letterSpacing: -0.005 * 19, // -0.005em
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

        // 시간 (크게) - ✅ width 제거하여 좌측 기준으로 정렬
        Text(
          timeText,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: const TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 33,
            fontWeight: FontWeight.w800,
            height: 1.2, // 120%
            letterSpacing: -0.005 * 33, // -0.005em
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
  );
}

// ========================================
// All Day Content (종일)
// ========================================

Widget _buildAllDayContent(DateTime date) {
  // 연도 포맷: YYYY
  final yearText = date.year.toString();

  // 날짜 포맷: M.DD
  final dateText = '${date.month}.${date.day}';

  return SizedBox(
    height: 63,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start, // ✅ 좌측 정렬 유지
      children: [
        // 연도 (작게)
        Text(
          yearText,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: const TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            height: 1.2, // 120%
            letterSpacing: -0.005 * 19, // -0.005em
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

        // 날짜 + 종일 표시
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
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
                height: 1.2, // 120%
                letterSpacing: -0.005 * 33, // -0.005em
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
            const SizedBox(width: 8),
            // 🎯 "終日" 표시 추가
            const Text(
              '終日',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.005 * 16,
                color: Color(0xFF888888), // 회색으로 표시
              ),
            ),
          ],
        ),
      ],
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
  return Container(
    width: 256, // Figma: 256px
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 24), // Figma: 0px 24px
    child: Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // Figma: justify-content: center
      children: [
        // 반복
        _buildRepeatOptionButton(context),
        const SizedBox(width: 8), // Figma: gap 8px
        // 리마인더
        _buildReminderOptionButton(context),
        const SizedBox(width: 8), // Figma: gap 8px
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
// Delete Button Component (52px)
// ========================================

Widget _buildDeleteButton(
  BuildContext context, {
  required ScheduleData schedule,
  required DateTime selectedDate, // ✅ 추가
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24), // Figma: 0px 24px
    child: GestureDetector(
      onTap: () => _handleDelete(
        context,
        schedule: schedule,
        selectedDate: selectedDate,
      ), // ✅ 수정
      child: Container(
        width: 100,
        height: 52,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ), // Figma: 16px 24px
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
            SvgPicture.asset(
              'asset/icon/trash_icon.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFFF74A4A),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6), // Figma: gap 6px
            // Text
            const Text(
              '削除',
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.4, // 140%
                letterSpacing: -0.005 * 13, // -0.005em
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
  required ScheduleData? schedule,
  required DateTime selectedDate,
}) async {
  final scheduleController = Provider.of<ScheduleFormController>(
    context,
    listen: false,
  );
  final bottomSheetController = Provider.of<BottomSheetController>(
    context,
    listen: false,
  );

  // ========== 1단계: 필수 필드 검증 ==========
  // 제목 검증
  if (!scheduleController.hasTitle) {
    debugPrint('⚠️ [ScheduleWolt] 제목 없음');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('タイトルを入力してください'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // 시작 날짜/시간 검증
  if (scheduleController.startDateTime == null) {
    debugPrint('⚠️ [ScheduleWolt] 시작 날짜/시간 없음');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('開始日時を選択してください'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // 종료 날짜/시간 검증
  if (scheduleController.endDateTime == null) {
    debugPrint('⚠️ [ScheduleWolt] 종료 날짜/시간 없음');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('終了日時を選択してください'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // 시작 < 종료 검증
  if (scheduleController.startDateTime!.isAfter(
    scheduleController.endDateTime!,
  )) {
    debugPrint('⚠️ [ScheduleWolt] 시작 시간이 종료 시간보다 늦음');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('開始日時は終了日時より前である必要があります'),
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

  final db = GetIt.I<AppDatabase>();

  try {
    if (schedule != null && schedule.id != -1) {
      // ========== 🔄 RecurringPattern 테이블에서 실제 반복 여부 확인 ==========
      final recurringPattern = await db.getRecurringPattern(
        entityType: 'schedule',
        entityId: schedule.id,
      );
      final hadRepeatRule = recurringPattern != null;

      debugPrint(
        '🔍 [ScheduleWolt] 저장 시 반복 확인: Schedule #${schedule.id} → ${hadRepeatRule ? "반복 있음" : "반복 없음"}',
      );

      if (hadRepeatRule) {
        // 변경사항이 있는지 확인
        final hasChanges =
            schedule.summary != scheduleController.title.trim() ||
            schedule.start != scheduleController.startDateTime ||
            schedule.end != scheduleController.endDateTime ||
            schedule.colorId != finalColor ||
            schedule.alertSetting != (safeReminder ?? '') ||
            schedule.repeatRule != (safeRepeatRule ?? '');

        if (hasChanges) {
          // ✅ 반복 일정 수정 확인 모달 표시
          await showEditRepeatConfirmationModal(
            context,
            onEditThis: () async {
              // ✅ この回のみ 수정: RecurringException 생성
              try {
                debugPrint(
                  '🔥 [ScheduleWolt] updateScheduleThisOnly 호출 - selectedDate: $selectedDate',
                );
                await RecurringHelpers.updateScheduleThisOnly(
                  db: db,
                  schedule: schedule,
                  selectedDate: selectedDate, // ✅ 수정: 사용자가 선택한 날짜 사용
                  updatedSchedule: ScheduleCompanion(
                    id: Value(schedule.id),
                    summary: Value(scheduleController.title.trim()),
                    start: Value(scheduleController.startDateTime!),
                    end: Value(scheduleController.endDateTime!),
                    colorId: Value(finalColor),
                    alertSetting: Value(safeReminder ?? ''),
                    description: Value(schedule.description),
                    location: Value(schedule.location),
                  ),
                );
                debugPrint('✅ [ScheduleWolt] この回のみ 수정 완료');
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
              } catch (e, stackTrace) {
                debugPrint('❌ [ScheduleWolt] この回のみ 수정 실패: $e');
                debugPrint('❌ 스택: $stackTrace');
                if (context.mounted) {
                  Navigator.pop(context); // 확인 모달 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('エラーが発生しました: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            onEditFuture: () async {
              // ✅ この予定以降 수정: RRULE 분할
              try {
                final newRRule =
                    safeRepeatRule != null && safeRepeatRule.isNotEmpty
                    ? _convertJsonRepeatRuleToRRule(
                        safeRepeatRule,
                        scheduleController.startDateTime!,
                      )
                    : null;

                debugPrint(
                  '🔥 [ScheduleWolt] updateScheduleFuture 호출 - selectedDate: $selectedDate',
                );
                await RecurringHelpers.updateScheduleFuture(
                  db: db,
                  schedule: schedule,
                  selectedDate: selectedDate, // ✅ 수정: 사용자가 선택한 날짜 사용
                  updatedSchedule: ScheduleCompanion.insert(
                    summary: scheduleController.title.trim(),
                    start: scheduleController.startDateTime!,
                    end: scheduleController.endDateTime!,
                    colorId: finalColor,
                    alertSetting: Value(safeReminder ?? ''),
                    repeatRule: Value(safeRepeatRule ?? ''),
                    description: Value(schedule.description),
                    location: Value(schedule.location),
                    status: Value(schedule.status),
                    visibility: Value(schedule.visibility),
                  ),
                  newRRule: newRRule,
                );
                debugPrint('✅ [ScheduleWolt] この予定以降 수정 완료');
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
              } catch (e, stackTrace) {
                debugPrint('❌ [ScheduleWolt] この予定以降 수정 실패: $e');
                debugPrint('❌ 스택: $stackTrace');
                if (context.mounted) {
                  Navigator.pop(context); // 확인 모달 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('エラーが発生しました: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            onEditAll: () async {
              // ✅ すべての回 수정: Base Event + RRULE 업데이트
              try {
                final newRRule =
                    safeRepeatRule != null && safeRepeatRule.isNotEmpty
                    ? _convertJsonRepeatRuleToRRule(
                        safeRepeatRule,
                        scheduleController.startDateTime!,
                      )
                    : null;

                await RecurringHelpers.updateScheduleAll(
                  db: db,
                  schedule: schedule,
                  updatedSchedule: ScheduleCompanion(
                    id: Value(schedule.id),
                    summary: Value(scheduleController.title.trim()),
                    start: Value(scheduleController.startDateTime!),
                    end: Value(scheduleController.endDateTime!),
                    colorId: Value(finalColor),
                    alertSetting: Value(safeReminder ?? ''),
                    repeatRule: Value(safeRepeatRule ?? ''),
                    createdAt: Value(schedule.createdAt),
                    status: Value(schedule.status),
                    visibility: Value(schedule.visibility),
                    description: Value(schedule.description),
                    location: Value(schedule.location),
                  ),
                  newRRule: newRRule,
                );
                debugPrint('✅ [ScheduleWolt] すべての回 수정 완료');

                // ========== 🔄 RecurringPattern 테이블 업데이트 ==========
                if (safeRepeatRule != null && safeRepeatRule.isNotEmpty) {
                  try {
                    final rrule = _convertJsonRepeatRuleToRRule(
                      safeRepeatRule,
                      scheduleController.startDateTime!,
                    );

                    if (rrule != null) {
                      // 기존 패턴 삭제 후 재생성
                      await db.deleteRecurringPattern(
                        entityType: 'schedule',
                        entityId: schedule.id,
                      );

                      await db.createRecurringPattern(
                        RecurringPatternCompanion.insert(
                          entityType: 'schedule',
                          entityId: schedule.id,
                          rrule: rrule,
                          dtstart: DateTime(
                            scheduleController.startDateTime!.year,
                            scheduleController.startDateTime!.month,
                            scheduleController.startDateTime!.day,
                          ), // 🔥 날짜만 저장 (시간은 00:00:00으로 통일)
                          until: const Value(null),
                          count: const Value(null),
                          exdate: const Value(''),
                          timezone: const Value('Asia/Seoul'),
                        ),
                      );
                      debugPrint(
                        '🔄 [ScheduleWolt] RecurringPattern 업데이트 완료: $rrule',
                      );
                    }
                  } catch (e) {
                    debugPrint(
                      '⚠️ [ScheduleWolt] RecurringPattern 업데이트 실패: $e',
                    );
                  }
                } else {
                  // 반복 규칙 제거 시 RecurringPattern 삭제
                  await db.deleteRecurringPattern(
                    entityType: 'schedule',
                    entityId: schedule.id,
                  );
                  debugPrint('🗑️ [ScheduleWolt] RecurringPattern 삭제 완료');
                }

                // ✅ 모달 닫기
                if (context.mounted) {
                  Navigator.pop(context); // 확인 모달 닫기
                  Navigator.pop(context, true); // Detail modal 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('すべての回を変更しました'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e, stackTrace) {
                debugPrint('❌ [ScheduleWolt] すべての回 수정 실패: $e');
                debugPrint('❌ 스택: $stackTrace');
                if (context.mounted) {
                  Navigator.pop(context); // 확인 모달 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('エラーが発生しました: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          );

          return; // ✅ 모달 작업 완료 후 함수 종료
        } else {
          debugPrint('ℹ️ [ScheduleWolt] 변경사항 없음');
        }
      } else {
        // 반복 없는 일반 일정 수정
        await db.updateSchedule(
          ScheduleCompanion(
            id: Value(schedule.id),
            summary: Value(scheduleController.title.trim()),
            start: Value(scheduleController.startDateTime!),
            end: Value(scheduleController.endDateTime!),
            colorId: Value(finalColor),
            alertSetting: Value(safeReminder ?? ''),
            repeatRule: Value(safeRepeatRule ?? ''),
            // ✅ 기존 필드 유지
            createdAt: Value(schedule.createdAt),
            status: Value(schedule.status),
            visibility: Value(schedule.visibility),
            description: Value(schedule.description),
            location: Value(schedule.location),
          ),
        );
        debugPrint('✅ [ScheduleWolt] 일정 수정 완료');

        // ========== 🔄 RecurringPattern 테이블 업데이트 (일반 일정) ==========
        if (safeRepeatRule != null && safeRepeatRule.isNotEmpty) {
          try {
            final rrule = _convertJsonRepeatRuleToRRule(
              safeRepeatRule,
              scheduleController.startDateTime!,
            );

            if (rrule != null) {
              // 기존 패턴 삭제 후 재생성
              await db.deleteRecurringPattern(
                entityType: 'schedule',
                entityId: schedule.id,
              );

              await db.createRecurringPattern(
                RecurringPatternCompanion.insert(
                  entityType: 'schedule',
                  entityId: schedule.id,
                  rrule: rrule,
                  dtstart: DateTime(
                    scheduleController.startDateTime!.year,
                    scheduleController.startDateTime!.month,
                    scheduleController.startDateTime!.day,
                  ), // 🔥 날짜만 저장 (시간은 00:00:00으로 통일)
                  until: const Value(null),
                  count: const Value(null),
                  exdate: const Value(''),
                  timezone: const Value('Asia/Seoul'),
                ),
              );
              debugPrint('🔄 [ScheduleWolt] RecurringPattern 생성 완료: $rrule');
            }
          } catch (e) {
            debugPrint('⚠️ [ScheduleWolt] RecurringPattern 생성 실패: $e');
          }
        }

        // ✅ 변경 토스트 표시
        if (context.mounted) {
          showActionToast(context, type: ToastType.change);
        }
      }

      debugPrint('   - 제목: ${scheduleController.title}');
      debugPrint('   - 시작: ${scheduleController.startDateTime}');
      debugPrint('   - 종료: ${scheduleController.endDateTime}');
      debugPrint('   - 반복 규칙: ${safeRepeatRule ?? "(없음)"}');

      // 🎯 수정 완료 후 통합 캐시 클리어
      await TempInputCache.clearCacheForType('schedule');
      debugPrint('🗑️ [ScheduleWolt] 일정 통합 캐시 클리어 완료');
    } else {
      // ========== 5단계: 새 일정 생성 (createdAt 명시) ==========
      final newId = await db.createSchedule(
        ScheduleCompanion.insert(
          summary: scheduleController.title.trim(),
          start: scheduleController.startDateTime!,
          end: scheduleController.endDateTime!,
          colorId: finalColor,
          alertSetting: (safeReminder != null && safeReminder.isNotEmpty)
              ? Value(safeReminder)
              : const Value.absent(), // ✅ 리마인더: 사용자가 설정한 경우에만 저장
          repeatRule: (safeRepeatRule != null && safeRepeatRule.isNotEmpty)
              ? Value(safeRepeatRule)
              : const Value.absent(), // ✅ 반복 규칙: 사용자가 설정한 경우에만 저장
          createdAt: Value(DateTime.now()), // ✅ 명시적 생성 시간
        ),
      );
      debugPrint('✅ [ScheduleWolt] 새 일정 생성 완료');
      debugPrint('   - 제목: ${scheduleController.title}');
      debugPrint('   - 색상: $finalColor');
      debugPrint('   - 반복: ${safeRepeatRule ?? "(미설정)"}');
      debugPrint('   - 리마인더: ${safeReminder ?? "(미설정)"}');

      // ========== 🔄 반복 규칙이 있으면 RecurringPattern 테이블에 저장 ==========
      if (safeRepeatRule != null && safeRepeatRule.isNotEmpty) {
        try {
          final rrule = _convertJsonRepeatRuleToRRule(
            safeRepeatRule,
            scheduleController.startDateTime!,
          );

          if (rrule != null) {
            await db.createRecurringPattern(
              RecurringPatternCompanion.insert(
                entityType: 'schedule',
                entityId: newId,
                rrule: rrule,
                dtstart: DateTime(
                  scheduleController.startDateTime!.year,
                  scheduleController.startDateTime!.month,
                  scheduleController.startDateTime!.day,
                ), // 🔥 날짜만 저장 (시간은 00:00:00으로 통일)
                until: const Value(null),
                count: const Value(null),
                exdate: const Value(''),
                timezone: const Value('Asia/Seoul'),
              ),
            );
            debugPrint('🔄 [ScheduleWolt] RecurringPattern 저장 완료: $rrule');
          }
        } catch (e) {
          debugPrint('⚠️ [ScheduleWolt] RecurringPattern 저장 실패: $e');
        }
      }

      // ========== 6단계: 통합 캐시 클리어 ==========
      await TempInputCache.clearCacheForType('schedule');
      debugPrint('🗑️ [ScheduleWolt] 일정 통합 캐시 클리어 완료');

      // ✅ 저장 토스트 표시 (캘린더에 저장됨)
      if (context.mounted) {
        showSaveToast(
          context,
          toInbox: false,
          onTap: () async {
            // 토스트 탭 시 해당 일정의 상세 모달 다시 열기
            final createdSchedule = await db.getScheduleById(newId);
            if (createdSchedule != null && context.mounted) {
              showScheduleDetailWoltModal(
                context,
                schedule: createdSchedule,
                selectedDate: createdSchedule.start,
              );
            }
          },
        );
      }
    }

    Navigator.pop(context);
  } catch (e, stackTrace) {
    debugPrint('❌ [ScheduleWolt] 저장 실패: $e');
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
  required ScheduleData schedule,
  required DateTime selectedDate, // ✅ 추가: 선택된 날짜 파라미터
}) async {
  final db = GetIt.I<AppDatabase>();

  // ✅ RecurringPattern 테이블에서 실제 반복 여부 확인
  final recurringPattern = await db.getRecurringPattern(
    entityType: 'schedule',
    entityId: schedule.id,
  );
  final hasRepeat = recurringPattern != null;

  debugPrint(
    '🔍 [ScheduleWolt] 삭제 시 반복 확인: Schedule #${schedule.id} → ${hasRepeat ? "반복 있음" : "반복 없음"}',
  );

  if (hasRepeat) {
    // ✅ 반복 있으면 → 반복 삭제 모달
    await showDeleteRepeatConfirmationModal(
      context,
      onDeleteThis: () async {
        // ✅ この回のみ 삭제: RecurringException 생성
        try {
          debugPrint(
            '🔥 [ScheduleWolt] deleteScheduleThisOnly 호출 - selectedDate: $selectedDate',
          );
          await RecurringHelpers.deleteScheduleThisOnly(
            db: db,
            schedule: schedule,
            selectedDate: selectedDate, // ✅ 수정: 사용자가 선택한 날짜 사용
          );
          if (context.mounted) {
            // ✅ 1. 확인 모달 닫기
            Navigator.pop(context);
            // ✅ 2. Detail modal 닫기 (변경 신호 전달)
            Navigator.pop(context, true);
            // Toast 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('この回のみ削除しました'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e, stackTrace) {
          debugPrint('❌ [ScheduleWolt] この回のみ 삭제 실패: $e');
          debugPrint('❌ 스택: $stackTrace');
          if (context.mounted) {
            Navigator.pop(context); // 확인 모달 닫기
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('削除に失敗しました: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      onDeleteFuture: () async {
        // ✅ この予定以降 삭제: UNTIL 설정
        try {
          debugPrint(
            '🔥 [ScheduleWolt] deleteScheduleFuture 호출 - selectedDate: $selectedDate',
          );
          await RecurringHelpers.deleteScheduleFuture(
            db: db,
            schedule: schedule,
            selectedDate: selectedDate, // ✅ 수정: 사용자가 선택한 날짜 사용
          );
          if (context.mounted) {
            // ✅ 1. 확인 모달 닫기
            Navigator.pop(context);
            // ✅ 2. Detail modal 닫기 (변경 신호 전달)
            Navigator.pop(context, true);
            // Toast 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('この予定以降を削除しました'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e, stackTrace) {
          debugPrint('❌ [ScheduleWolt] この予定以降 삭제 실패: $e');
          debugPrint('❌ 스택: $stackTrace');
          if (context.mounted) {
            Navigator.pop(context); // 확인 모달 닫기
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('削除に失敗しました: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      onDeleteAll: () async {
        // すべての回 삭제 (전체 삭제)
        await RecurringHelpers.deleteScheduleAll(db: db, schedule: schedule);
        if (context.mounted) {
          // ✅ 1. 확인 모달 닫기
          Navigator.pop(context);
          // ✅ 2. Detail modal 닫기 (변경 신호 전달)
          Navigator.pop(context, true);
          // Toast 표시
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
        debugPrint('✅ [ScheduleWolt] 일정 삭제 완료');
        await db.deleteSchedule(schedule.id);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }
}

void _handleDateTimePicker(BuildContext context) async {
  final controller = Provider.of<ScheduleFormController>(
    context,
    listen: false,
  );

  // 현재 날짜와 시간을 DateTime으로 통합
  final startDateTime = DateTime(
    controller.startDate?.year ?? DateTime.now().year,
    controller.startDate?.month ?? DateTime.now().month,
    controller.startDate?.day ?? DateTime.now().day,
    controller.startTime?.hour ?? 0,
    controller.startTime?.minute ?? 0,
  );

  final endDateTime = DateTime(
    controller.endDate?.year ?? DateTime.now().year,
    controller.endDate?.month ?? DateTime.now().month,
    controller.endDate?.day ?? DateTime.now().day,
    controller.endTime?.hour ?? 0,
    controller.endTime?.minute ?? 0,
  );

  // 새로운 스무스 바텀시트 모달 호출
  await showDateTimePickerModal(
    context,
    initialStartDateTime: startDateTime,
    initialEndDateTime: endDateTime,
    isAllDay: controller.isAllDay, // ✅ 終日 모드 전달
    onDateTimeSelected: (start, end) {
      controller.setStartDate(start);
      controller.setStartTime(TimeOfDay.fromDateTime(start));
      controller.setEndDate(end);
      controller.setEndTime(TimeOfDay.fromDateTime(end));
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

// ==================== RRULE 변환 헬퍼 함수 ====================

/// JSON repeatRule을 RRULE 문자열로 변환
/// 실제 형식: {"value":"daily:金,土","display":"金土"} 또는 {"value":"weekly:月,水","display":"月水"}
String? _convertJsonRepeatRuleToRRule(String jsonRepeatRule, DateTime dtstart) {
  try {
    final json = jsonDecode(jsonRepeatRule) as Map<String, dynamic>;
    final value = json['value'] as String?;

    if (value == null || value.isEmpty) {
      debugPrint('⚠️ [RRuleConvert] value 필드 없음');
      return null;
    }

    debugPrint('🔍 [RRuleConvert] 파싱 시작: $value');

    // value 형식: "daily:金,土" 또는 "weekly:月,水" 또는 "monthly" 등
    final parts = value.split(':');
    final freq = parts[0]; // 'daily', 'weekly', 'monthly', 'yearly'
    final daysStr = parts.length > 1 ? parts[1] : null;

    switch (freq) {
      case 'daily':
        if (daysStr != null && daysStr.isNotEmpty) {
          // "daily:金,土" → 특정 요일만 반복 (실제로는 weekly)
          final days = daysStr.split(',');
          final weekdays = days.map(_jpDayToWeekday).whereType<int>().toList();

          if (weekdays.isEmpty) {
            debugPrint('⚠️ [RRuleConvert] 요일 변환 실패: $daysStr');
            return null;
          }

          // ✅ RecurrenceRule API 사용 (정확함!)
          final rrule = RecurrenceRule(
            frequency: Frequency.weekly,
            byWeekDays: weekdays.map((wd) => ByWeekDayEntry(wd)).toList(),
          );

          final rruleString = rrule.toString();
          debugPrint('✅ [RRuleConvert] API 변환 완료: $rruleString');
          return rruleString.replaceFirst('RRULE:', ''); // RRULE: 접두사 제거
        } else {
          // 매일 반복
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

          // ✅ RecurrenceRule API 사용 (정확함!)
          final rrule = RecurrenceRule(
            frequency: Frequency.weekly,
            byWeekDays: weekdays.map((wd) => ByWeekDayEntry(wd)).toList(),
          );

          final rruleString = rrule.toString();
          debugPrint('✅ [RRuleConvert] API 변환 완료: $rruleString');
          return rruleString.replaceFirst('RRULE:', ''); // RRULE: 접두사 제거
        } else {
          // 매주 (dtstart 요일 기준)
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
