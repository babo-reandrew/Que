import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';

import '../../Database/schedule_database.dart';
import '../../providers/bottom_sheet_controller.dart';
import '../../providers/schedule_form_controller.dart';
import '../../design_system/wolt_helpers.dart'; // ✅ Wolt 최신 모달

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
void showScheduleDetailWoltModal(
  BuildContext context, {
  required ScheduleData? schedule,
  required DateTime selectedDate,
}) {
  // Provider 초기화
  WidgetsBinding.instance.addPostFrameCallback((_) {
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
      scheduleController.setStartDate(selectedDate);
      scheduleController.setEndDate(selectedDate);
    }

    debugPrint('✅ [ScheduleWolt] Provider 초기화 완료');
  });

  WoltModalSheet.show(
    context: context,
    pageListBuilder: (context) => [
      _buildScheduleDetailPage(
        context,
        schedule: schedule,
        selectedDate: selectedDate,
      ),
    ],
    modalTypeBuilder: (context) => WoltModalType.bottomSheet(),
    onModalDismissedWithBarrierTap: () {
      FocusScope.of(context).unfocus(); // ✅ 키보드 닫기
      debugPrint('✅ [ScheduleWolt] Modal dismissed with tap');
    },
    onModalDismissedWithDrag: () {
      FocusScope.of(context).unfocus(); // ✅ 키보드 닫기
      debugPrint('✅ [ScheduleWolt] Modal dismissed with drag');
    },
    useSafeArea: false, // ✅ SafeArea 비활성화
  );
}

// ========================================
// Schedule Detail Page Builder
// ========================================

SliverWoltModalSheetPage _buildScheduleDetailPage(
  BuildContext context, {
  required ScheduleData? schedule,
  required DateTime selectedDate,
}) {
  return SliverWoltModalSheetPage(
    hasTopBarLayer: false, // TopNavi를 컨텐츠 안에 포함

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== TopNavi (60px) ==========
                _buildTopNavi(
                  context,
                  schedule: schedule,
                  selectedDate: selectedDate,
                ),

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
                  _buildDeleteButton(context, schedule: schedule),

                const SizedBox(height: 32), // ✅ 하단 패딩 32px
              ],
            ),
          ),
        ),
      ),
    ],

    // ✅ 배경색 투명 (Container가 배경색 처리)
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
  );
}

// ========================================
// TopNavi Component (60px)
// ========================================

Widget _buildTopNavi(
  BuildContext context, {
  required ScheduleData? schedule,
  required DateTime selectedDate,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(28, 28, 28, 9),
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
            height: 1.4,
            letterSpacing: -0.08,
            color: Color(0xFF505050),
          ),
        ),

        // Save Button
        GestureDetector(
          onTap: () => _handleSave(
            context,
            schedule: schedule,
            selectedDate: selectedDate,
          ),
          child: Container(
            width: 74,
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
}

// ========================================
// TextField Component (51px)
// ========================================

Widget _buildTextField(BuildContext context) {
  final scheduleController = Provider.of<ScheduleFormController>(
    context,
    listen: false,
  );

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: scheduleController.titleController,
        autofocus: false,
        style: const TextStyle(
          fontFamily: 'LINE Seed JP App_TTF',
          fontSize: 19,
          fontWeight: FontWeight.w700,
          height: 1.4,
          letterSpacing: -0.095,
          color: Color(0xFF111111),
        ),
        decoration: const InputDecoration(
          hintText: '予定を追加',
          hintStyle: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 19,
            fontWeight: FontWeight.w700,
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
// AllDay Toggle Component (32px)
// ========================================

Widget _buildAllDayToggle(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Consumer<ScheduleFormController>(
      builder: (context, controller, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Icon + Text
            Row(
              children: [
                // Icon
                Container(
                  width: 19,
                  height: 19,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF111111),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                // Text
                const Text(
                  '終日',
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

            // Right: Toggle
            GestureDetector(
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
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      shape: BoxShape.circle,
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

      // 시간 선택 여부
      final hasStartTime = startTime != null;
      final hasEndTime = endTime != null;

      // 동적 패딩 계산
      double horizontalPadding;
      if (isAllDay) {
        horizontalPadding = 48; // 종일
      } else if (hasStartTime || hasEndTime) {
        horizontalPadding = 54; // 시간 선택됨
      } else {
        horizontalPadding = 50; // 미선택
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Start Time
            _buildTimeObject(
              context,
              label: '開始',
              date: startDate,
              time: startTime,
              isAllDay: isAllDay,
              onTap: () => _handleStartTimePicker(context),
            ),

            // Divider
            _buildDivider(),

            // End Time
            _buildTimeObject(
              context,
              label: '終了',
              date: endDate,
              time: endTime,
              isAllDay: isAllDay,
              onTap: () => _handleEndTimePicker(context),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildDivider() {
  return SizedBox(
    width: 8,
    height: 46,
    child: Center(
      child: Container(
        width: 8,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            width: 2,
          ),
        ),
      ),
    ),
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
          if (time != null)
            _buildTimeSelectedContent(date!, time, isAllDay)
          else if (isAllDay && date != null)
            _buildAllDayContent(date)
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
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: 'LINE Seed JP App_TTF',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: -0.08,
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
            height: 1.2,
            letterSpacing: -0.25,
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
    width: 99,
    height: 65,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
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

        // 시간 (크게)
        Text(
          timeText,
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
    width: 83,
    height: 63,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
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
// DetailOptions Component (64px)
// ========================================

Widget _buildDetailOptions(
  BuildContext context, {
  required DateTime selectedDate,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 48), // 일정은 48px!
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

Widget _buildDeleteButton(
  BuildContext context, {
  required ScheduleData schedule,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: GestureDetector(
      onTap: () => _handleDelete(context, schedule: schedule),
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

  if (!scheduleController.hasTitle) {
    debugPrint('⚠️ [ScheduleWolt] 제목 없음');
    return;
  }

  final db = GetIt.I<AppDatabase>();

  try {
    if (schedule != null) {
      // 기존 일정 수정
      await db.updateSchedule(
        ScheduleCompanion(
          id: Value(schedule.id),
          summary: Value(scheduleController.title),
          start: Value(scheduleController.startDateTime!),
          end: Value(scheduleController.endDateTime!),
          colorId: Value(bottomSheetController.selectedColor),
          alertSetting: Value(bottomSheetController.reminder),
          repeatRule: Value(bottomSheetController.repeatRule),
        ),
      );
      debugPrint('✅ [ScheduleWolt] 일정 수정 완료');
    } else {
      // 새 일정 생성
      await db.createSchedule(
        ScheduleCompanion.insert(
          summary: scheduleController.title,
          start: scheduleController.startDateTime!,
          end: scheduleController.endDateTime!,
          colorId: bottomSheetController.selectedColor,
          alertSetting: bottomSheetController.reminder,
          repeatRule: bottomSheetController.repeatRule,
          status: 'confirmed',
          visibility: 'default',
        ),
      );
      debugPrint('✅ [ScheduleWolt] 새 일정 생성 완료');
    }

    Navigator.pop(context);
  } catch (e) {
    debugPrint('❌ [ScheduleWolt] 저장 실패: $e');
  }
}

void _handleDelete(
  BuildContext context, {
  required ScheduleData schedule,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('일정 삭제'),
      content: const Text('이 일정을 삭제하시겠습니까?'),
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
    await db.deleteSchedule(schedule.id);
    debugPrint('✅ [ScheduleWolt] 일정 삭제 완료');
    Navigator.pop(context);
  }
}

void _handleStartTimePicker(BuildContext context) async {
  final controller = Provider.of<ScheduleFormController>(
    context,
    listen: false,
  );

  final picked = await showTimePicker(
    context: context,
    initialTime: controller.startTime ?? TimeOfDay.now(),
  );

  if (picked != null) {
    controller.setStartTime(picked);
  }
}

void _handleEndTimePicker(BuildContext context) async {
  final controller = Provider.of<ScheduleFormController>(
    context,
    listen: false,
  );

  final picked = await showTimePicker(
    context: context,
    initialTime: controller.endTime ?? TimeOfDay.now(),
  );

  if (picked != null) {
    controller.setEndTime(picked);
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
