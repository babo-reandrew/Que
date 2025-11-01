import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/bottom_sheet_controller.dart';
import '../../utils/temp_input_cache.dart';

/// 일정/습관 전용 리마인더 선택 바텀시트 모달 (선택지 리스트 방식)
///
/// 색상 선택 바텀시트와 동일한 구조
Future<void> showReminderPickerModal(
  BuildContext context, {
  String? initialReminder,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ReminderPickerSheet(
      controller: Provider.of<BottomSheetController>(context, listen: false),
    ),
  );
}

class _ReminderPickerSheet extends StatefulWidget {
  final BottomSheetController controller;

  const _ReminderPickerSheet({required this.controller});

  @override
  State<_ReminderPickerSheet> createState() => _ReminderPickerSheetState();
}

class _ReminderPickerSheetState extends State<_ReminderPickerSheet> {
  // ✅ 선택 가능한 리마인더 옵션 리스트
  final List<Map<String, String>> _reminderOptions = [
    {'value': '{"value":"none","display":"なし"}', 'display': 'なし'},
    {'value': '{"value":"0","display":"イベント発生時"}', 'display': 'イベント発生時'},
    {'value': '{"value":"5","display":"5分前"}', 'display': '5分前'},
    {'value': '{"value":"10","display":"10分前"}', 'display': '10分前'},
    {'value': '{"value":"15","display":"15分前"}', 'display': '15分前'},
    {'value': '{"value":"30","display":"30分前"}', 'display': '30分前'},
    {'value': '{"value":"60","display":"1時間前"}', 'display': '1時間前'},
    {'value': '{"value":"120","display":"2時間前"}', 'display': '2時間前'},
    {'value': '{"value":"1440","display":"1日前"}', 'display': '1日前'},
    {'value': '{"value":"2880","display":"2日前"}', 'display': '2日前'},
    {'value': '{"value":"10080","display":"1週間前"}', 'display': '1週間前'},
  ];

  String _selectedReminder = '';

  @override
  void initState() {
    super.initState();
    _selectedReminder = widget.controller.reminder;
  }

  // ✅ "完了" 버튼 클릭 시 최종 저장
  Future<void> _saveReminder() async {
    widget.controller.updateReminder(_selectedReminder);

    // ✅ 임시 캐시에 저장
    await TempInputCache.saveTempReminder(_selectedReminder);
    debugPrint('💾 [ReminderPicker] 임시 캐시에 리마인더 저장: $_selectedReminder');

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
            // 메인 컨텐츠 - 리마인더 옵션 리스트
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 400, // 최대 높이 제한
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _reminderOptions.length,
                itemBuilder: (context, index) {
                  final option = _reminderOptions[index];
                  final value = option['value']!;
                  final display = option['display']!;
                  final isSelected = _selectedReminder == value;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedReminder = value;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.transparent, // ✅ 항상 투명 배경
                        // ✅ border 제거
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            display,
                            style: TextStyle(
                              fontFamily: 'LINE Seed JP',
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: Color(0xFF111111),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // CTA 버튼 ("完了")
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: GestureDetector(
                onTap: _saveReminder,
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
    ); // ✅ Padding 닫기
  }
}
