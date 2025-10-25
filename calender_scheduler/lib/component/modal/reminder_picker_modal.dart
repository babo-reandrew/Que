import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/bottom_sheet_controller.dart';
import '../../utils/temp_input_cache.dart';

/// 리마인더 선택 바텀시트 모달 표시
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
  // Figma 디자인: 7개 리마인더 옵션
  final reminderOptions = [
    {'value': 'ontime', 'label': '定時'},
    {'value': '5min', 'label': '5分前'},
    {'value': '10min', 'label': '10分前'},
    {'value': '15min', 'label': '15分前'},
    {'value': '30min', 'label': '30分前'},
    {'value': '1hour', 'label': '1時間前'},
    {'value': '2hour', 'label': '2時間前'},
  ];

  // ✅ 로컬 상태로 선택된 값 관리
  String? _selectedValue;
  String? _selectedLabel;

  @override
  void initState() {
    super.initState();
    // ✅ 초기값: 현재 controller에서 가져오기
    if (widget.controller.reminder.isNotEmpty) {
      try {
        final reminderData = widget.controller.reminder;
        if (reminderData.contains('"value":"')) {
          final startIndex = reminderData.indexOf('"value":"') + 9;
          final endIndex = reminderData.indexOf('"', startIndex);
          _selectedValue = reminderData.substring(startIndex, endIndex);
        }
        if (reminderData.contains('"display":"')) {
          final startIndex = reminderData.indexOf('"display":"') + 11;
          final endIndex = reminderData.indexOf('"', startIndex);
          _selectedLabel = reminderData.substring(startIndex, endIndex);
        }
      } catch (e) {
        debugPrint('리마인더 초기값 파싱 오류: $e');
      }
    }
  }

  // ✅ "完了" 버튼 클릭 시 최종 저장
  Future<void> _saveReminder() async {
    if (_selectedValue != null && _selectedLabel != null) {
      // JSON 형식으로 저장
      final reminderJson =
          '{"value":"$_selectedValue","display":"$_selectedLabel"}';
      widget.controller.updateReminder(reminderJson);

      // ✅ 임시 캐시에 저장
      await TempInputCache.saveTempReminder(reminderJson);
      debugPrint('💾 [ReminderPicker] 임시 캐시에 리마인더 저장: $reminderJson');
    }

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
                  // 리마인더 옵션 리스트 (스크롤 가능)
                  SizedBox(
                    height: 336, // Figma: RemindScroll height
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        itemCount: reminderOptions.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final option = reminderOptions[index];
                          final value = option['value'] as String;
                          final label = option['label'] as String;
                          final isSelected = _selectedValue == value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // ✅ 로컬 상태만 업데이트 (여러 번 변경 가능)
                                  setState(() {
                                    _selectedValue = value;
                                    _selectedLabel = label;
                                  });
                                  debugPrint('🔘 [ReminderPicker] 선택: $label');
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFF5F5F5)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    width: 313,
                                    height: 48,
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Label Text
                                        Text(
                                          label,
                                          style: TextStyle(
                                            fontFamily: 'LINE Seed JP App_TTF',
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            height: 1.4, // line-height: 140%
                                            letterSpacing:
                                                -0.065, // -0.005em * 13px
                                            color: isSelected
                                                ? const Color(0xFF111111)
                                                : const Color(0xFF555555),
                                          ),
                                        ),

                                        // Check Icon (visible when selected)
                                        if (isSelected)
                                          SvgPicture.asset(
                                            'asset/icon/Check_icon.svg',
                                            width: 24,
                                            height: 24,
                                            colorFilter: const ColorFilter.mode(
                                              Color(0xFF111111),
                                              BlendMode.srcIn,
                                            ),
                                          )
                                        else
                                          const SizedBox(
                                            width: 24,
                                            height: 24,
                                          ), // Placeholder
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
