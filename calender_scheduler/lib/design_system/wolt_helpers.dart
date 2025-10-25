import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/bottom_sheet_controller.dart';
import '../component/modal/reminder_picker_modal.dart'; // ✅ 새로운 리마인더 바텀시트
import '../component/modal/repeat_picker_modal.dart'; // ✅ 새로운 반복 바텀시트

/// Wolt Modal Sheet Helper Functions
///
/// Wolt Modal Sheet을 쉽게 사용할 수 있도록 도와주는 헬퍼 함수 모음입니다.
/// 기존의 showModalBottomSheet 호출을 간단하게 대체할 수 있습니다.

// ========================================
// 리마인더 옵션 모달
// ========================================

/// 리마인더 설정 바텀시트 표시 (Figma 디자인 적용)
///
/// [context]: BuildContext
/// [initialReminder]: 초기 리마인더 설정값 (JSON 문자열, optional)
///
/// 사용법:
/// ```dart
/// showWoltReminderOption(context);
/// ```
///
/// **Figma Design Spec:**
/// - Size: 364 x 534px
/// - 7개 옵션: 定時, 5分前, 10分前, 15分前, 30分前, 1時間前, 2時間前
/// - 선택 시 체크마크 표시
/// - 임시 캐시 저장 지원
void showWoltReminderOption(BuildContext context, {String? initialReminder}) {
  debugPrint('🔔 [WoltHelper] 리마인더 바텀시트 표시');

  // ✅ 새로운 Figma 디자인 바텀시트 사용
  showReminderPickerModal(context, initialReminder: initialReminder);
}

// ========================================
// 반복 옵션 모달
// ========================================
// 반복 설정 모달 (3개 토글 페이지)
// ========================================

/// 반복 설정 Wolt 모달 표시 (3개 페이지: 毎日/毎月/間隔)
///
/// [context]: BuildContext
/// [initialRepeatRule]: 초기 반복 규칙 설정값 (JSON 문자열, optional)
///
/// **Figma 디자인:**
/// - 페이지 1: 毎日 (요일 선택)
/// - 페이지 2: 毎月 (날짜 그리드)
/// - 페이지 3: 間隔 (간격 리스트)
///
/// 사용법:
/// ```dart
/// showWoltRepeatOption(context);
/// ```
Future<void> showWoltRepeatOption(
  BuildContext context, {
  String? initialRepeatRule,
}) async {
  // Provider에서 BottomSheetController 가져오기
  final controller = Provider.of<BottomSheetController>(context, listen: false);

  // 초기값 설정 (전달된 값이 있으면 사용)
  if (initialRepeatRule != null && initialRepeatRule.isNotEmpty) {
    controller.updateRepeatRule(initialRepeatRule);
  }

  debugPrint('🔄 [Helper] 반복 선택 SmoothSheet 표시');

  // ✅ 새로운 스무스 바텀시트 사용
  await showRepeatPickerModal(context, initialRepeatRule: initialRepeatRule);

  debugPrint('🔄 [Helper] 반복 선택 SmoothSheet 닫힘');
}

// ========================================
// 색상 선택 모달
// ========================================

/// 색상 선택 SmoothSheet 모달 표시
///
/// [context]: BuildContext
/// [initialColorId]: 초기 색상 ID (String, optional) - 'gray', 'blue', 'green' 등
///
/// 사용법:
/// ```dart
/// await showWoltColorPicker(context, initialColorId: 'blue');
/// ```
Future<void> showWoltColorPicker(
  BuildContext context, {
  String? initialColorId,
}) async {
  // Provider에서 BottomSheetController 가져오기
  final controller = Provider.of<BottomSheetController>(context, listen: false);

  // 초기값 설정 (전달된 값이 있으면 사용)
  if (initialColorId != null) {
    controller.updateColor(initialColorId);
  }

  debugPrint('🎨 [Helper] 색상 선택 SmoothSheet 표시');

  // ✅ 바텀시트가 닫힐 때까지 대기
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ColorPickerSheet(controller: controller),
  );

  debugPrint('🎨 [Helper] 색상 선택 SmoothSheet 닫힘');
}

/// 색상 선택 바텀시트 위젯
class _ColorPickerSheet extends StatefulWidget {
  final BottomSheetController controller;

  const _ColorPickerSheet({required this.controller});

  @override
  State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _savedColorName = ''; // ✅ 저장된 색상 이름

  // Figma: 5개 색상 (정확한 hex 값)
  final colorOptions = [
    {'value': 'red', 'color': const Color(0xFFD22D2D), 'label': '赤'},
    {'value': 'orange', 'color': const Color(0xFFF57C00), 'label': 'オレンジ'},
    {'value': 'blue', 'color': const Color(0xFF1976D2), 'label': '青'},
    {'value': 'yellow', 'color': const Color(0xFFF7BD11), 'label': '黄'},
    {'value': 'green', 'color': const Color(0xFF54C8A1), 'label': '緑'},
  ];

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveColorName() {
    setState(() {
      _savedColorName = _textController.text.trim();
    });
    debugPrint('🎨 색상 이름 저장: $_savedColorName');
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
                  // "色" 타이틀 - Figma: 19px, Bold, LINE Seed JP App_TTF
                  const Text(
                    '色',
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
                    onTap: () {
                      _saveColorName(); // ✅ 저장 후 닫기
                      Navigator.pop(context);
                    },
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
                  // 중앙 큰 색상 미리보기 (100×100px) + TextField
                  Column(
                    children: [
                      // 색상 원 + TextField 겹치기
                      Consumer<BottomSheetController>(
                        builder: (context, ctrl, _) {
                          final selectedOption = colorOptions.firstWhere(
                            (opt) => opt['value'] == ctrl.selectedColor,
                            orElse: () => colorOptions[0],
                          );
                          final selectedColor =
                              selectedOption['color'] as Color;

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // 배경 색상 원
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: selectedColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // TextField (원 중앙에 배치)
                              Container(
                                width: 80,
                                height: 80, // ✅ 원 안에서 넘치지 않도록 제한
                                alignment: Alignment.center, // ✅ 상하좌우 중앙 정렬
                                child: TextField(
                                  controller: _textController,
                                  focusNode: _focusNode,
                                  textAlign: TextAlign.center, // ✅ 가로 중앙
                                  textAlignVertical:
                                      TextAlignVertical.center, // ✅ 수직 중앙
                                  maxLines: null, // ✅ 자동 개행 허용
                                  maxLength: 8, // ✅ 최대 8자
                                  buildCounter:
                                      (
                                        context, {
                                        required currentLength,
                                        required isFocused,
                                        maxLength,
                                      }) => null, // ✅ 글자 수 카운터 숨기기
                                  onSubmitted: (_) =>
                                      _saveColorName(), // ✅ 엔터 시 저장
                                  style: TextStyle(
                                    fontFamily: 'LINE Seed JP',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700, // ✅ Bold
                                    height: 1.3,
                                    letterSpacing: -0.005,
                                    color: const Color(
                                      0xFFFFFFFF,
                                    ).withOpacity(0.6),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'カテゴリー名', // ✅ '入力' 제거, 개행 제거
                                    hintStyle: TextStyle(
                                      fontFamily: 'LINE Seed JP',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700, // ✅ Bold
                                      height: 1.3,
                                      letterSpacing: -0.005,
                                      color: const Color(
                                        0xFFFFFFFF,
                                      ).withOpacity(0.6),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 하단 5개 색상 버튼
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < colorOptions.length; i++) ...[
                          Consumer<BottomSheetController>(
                            builder: (context, ctrl, _) {
                              final option = colorOptions[i];
                              final colorValue = option['value'] as String;
                              final color = option['color'] as Color;
                              final isSelected =
                                  ctrl.selectedColor == colorValue;

                              return GestureDetector(
                                onTap: () {
                                  widget.controller.updateColor(colorValue);
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: const Color(0xFF111111),
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (i < colorOptions.length - 1)
                            const SizedBox(width: 16),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 52),

                  // CTA 버튼 ("完了")
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 20, // ✅ 버튼 하단에 직접 20px 패딩
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _saveColorName(); // ✅ 저장 후 닫기
                        Navigator.pop(context);
                      },
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
