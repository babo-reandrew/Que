import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/bottom_sheet_controller.dart';
import '../../utils/temp_input_cache.dart';

/// 할일 전용 리마인더 선택 바텀시트 모달 (시간 선택 방식)
///
/// 24시간:분 형식의 타임피커
Future<void> showTaskReminderPickerModal(
  BuildContext context, {
  String? initialReminder,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TaskReminderPickerSheet(
      controller: Provider.of<BottomSheetController>(context, listen: false),
    ),
  );
}

class _TaskReminderPickerSheet extends StatefulWidget {
  final BottomSheetController controller;

  const _TaskReminderPickerSheet({required this.controller});

  @override
  State<_TaskReminderPickerSheet> createState() =>
      _TaskReminderPickerSheetState();
}

class _TaskReminderPickerSheetState extends State<_TaskReminderPickerSheet> {
  // ✅ 시간 선택을 위한 상태
  int _selectedHour = 9; // 기본값: 9시
  int _selectedMinute = 0; // 기본값: 0분

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();

    // ✅ 초기값: 현재 controller에서 시간 파싱
    if (widget.controller.reminder.isNotEmpty) {
      try {
        final reminderData = widget.controller.reminder;
        // "HH:MM" 형식 파싱
        if (reminderData.contains(':')) {
          final parts = reminderData.split(':');
          if (parts.length == 2) {
            _selectedHour = int.parse(parts[0]);
            _selectedMinute = int.parse(parts[1]);
          }
        }
      } catch (e) {
        debugPrint('리마인더 초기값 파싱 오류: $e');
      }
    }

    // 스크롤 컨트롤러 초기화
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  // ✅ "完了" 버튼 클릭 시 최종 저장
  Future<void> _saveReminder() async {
    // HH:MM 형식으로 저장
    final reminderTime =
        '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
    widget.controller.updateReminder(reminderTime);

    // ✅ 임시 캐시에 저장
    await TempInputCache.saveTempReminder(reminderTime);
    debugPrint('💾 [TaskReminderPicker] 임시 캐시에 리마인더 저장: $reminderTime');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // ✅✅✅ 핵심: Padding으로 전체 Container를 감싸서 바텀시트 자체가 위로 올라가도록!
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        decoration: ShapeDecoration(
          color: const Color(0xFFFCFCFC),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.only(
              topLeft: SmoothRadius(cornerRadius: 36, cornerSmoothing: 0.6),
              topRight: SmoothRadius(cornerRadius: 36, cornerSmoothing: 0.6),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32), // ✅ 상단 패딩 32px
            // 헤더 (TopNavi) - Figma 스펙: 364×54px, padding 9px 28px
            Container(
              width: 364,
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // "リマインダー" 타이틀 - Figma: 19px, Bold, LINE Seed JP App_TTF
                  const Text(
                    'リマインダー',
                    style: TextStyle(
                      fontFamily: 'LINE Seed JP App_TTF',
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      height: 1.4, // line-height: 140%
                      letterSpacing: -0.005,
                      color: Color(0xFF111111),
                    ),
                  ),
                  // 닫기 버튼 (Modal Control Buttons) - Figma: 36×36px
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      padding: const EdgeInsets.all(8), // ✅ 8px 패딩
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFE4E4E4,
                        ).withOpacity(0.9), // rgba(228, 228, 228, 0.9)
                        border: Border.all(
                          color: const Color(0xFF111111).withOpacity(0.02),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'asset/icon/X_icon.svg', // ✅ X_icon.svg 사용
                        width: 20, // ✅ 20×20px
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
            ),
            // 메인 컨텐츠
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 16),
              child: Column(
                children: [
                  // ✅ 시간 선택 피커 (iOS 스타일)
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 시간 피커 (0-23)
                        SizedBox(
                          width: 80,
                          child: ListWheelScrollView.useDelegate(
                            controller: _hourController,
                            itemExtent: 40,
                            perspective: 0.005,
                            diameterRatio: 1.2,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedHour = index;
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                if (index < 0 || index > 23) return null;
                                final isSelected = index == _selectedHour;
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontFamily: 'LINE Seed JP',
                                      fontSize: isSelected ? 24 : 18,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? const Color(0xFF111111)
                                          : const Color(0xFFAAAAAA),
                                    ),
                                  ),
                                );
                              },
                              childCount: 24,
                            ),
                          ),
                        ),

                        // 구분자
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontFamily: 'LINE Seed JP',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ),

                        // 분 피커 (0-59)
                        SizedBox(
                          width: 80,
                          child: ListWheelScrollView.useDelegate(
                            controller: _minuteController,
                            itemExtent: 40,
                            perspective: 0.005,
                            diameterRatio: 1.2,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedMinute = index;
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                if (index < 0 || index > 59) return null;
                                final isSelected = index == _selectedMinute;
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontFamily: 'LINE Seed JP',
                                      fontSize: isSelected ? 24 : 18,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? const Color(0xFF111111)
                                          : const Color(0xFFAAAAAA),
                                    ),
                                  ),
                                );
                              },
                              childCount: 60,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // CTA 버튼 ("完了")
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 20, // ✅ 버튼 하단에 직접 20px 패딩
                    ),
                    child: GestureDetector(
                      onTap: _saveReminder, // ✅ 최종 저장 함수 호출
                      child: Container(
                        width: 333,
                        height: 56,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          border: Border.all(
                            color: const Color(0xFF111111).withOpacity(0.01),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Text(
                            '完了',
                            style: TextStyle(
                              fontFamily: 'LINE Seed JP',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              letterSpacing: -0.005,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ); // ✅ Padding 닫기
  }
}
