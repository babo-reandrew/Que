import 'package:flutter/material.dart';
import 'quick_add/quick_add_control_box.dart';

/// 키보드에 붙는 InputAccessoryView (최적화된 버전)
///
/// **iOS inputAccessoryView 완벽 구현:**
/// - 키보드에 정확히 붙어서 올라옴
/// - 키보드 내려가도 위치 고정 (추가 버튼 클릭 시)
class InputAccessoryWithBlur extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback? onSaveComplete;
  final VoidCallback? onCancel;

  const InputAccessoryWithBlur({
    super.key,
    required this.selectedDate,
    this.onSaveComplete,
    this.onCancel,
  });

  @override
  State<InputAccessoryWithBlur> createState() => _InputAccessoryWithBlurState();
}

class _InputAccessoryWithBlurState extends State<InputAccessoryWithBlur> {
  double _savedKeyboardHeight = 0.0; // 저장된 키보드 높이

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // ✅ 키보드가 올라와 있으면 높이 저장
    if (keyboardHeight > 0) {
      _savedKeyboardHeight = keyboardHeight;
    }

    // ✅ 키보드 내려갔을 때 추가 패딩 (키보드 높이만큼)
    final extraBottomPadding = (keyboardHeight == 0 && _savedKeyboardHeight > 0)
        ? _savedKeyboardHeight
        : 0.0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardHeight), // 키보드 높이만큼 올림
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            width: screenWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFFFFFF).withOpacity(0.0),
                  const Color(0xFFF0F0F0).withOpacity(0.95),
                ],
                stops: const [0.0, 0.5],
              ),
            ),
            // ✅ 그라데이션 박스의 하단 패딩만 늘림
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              bottom: 6 + extraBottomPadding, // 키보드 내려가면 패딩 증가!
            ),
            child: SafeArea(
              top: false,
              child: QuickAddControlBox(
                selectedDate: widget.selectedDate,
                onSave: (data) {
                  widget.onSaveComplete?.call();
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 간단한 사용을 위한 헬퍼 함수들
///
/// **기존 코드와 병행 사용 가능!**
/// 기존 CreateEntryBottomSheet 제거 전까지 둘 다 유지
class InputAccessoryHelper {
  /// KeyboardAttachable 방식으로 QuickAdd 표시
  ///
  /// 기존:
  /// ```dart
  /// CreateEntryBottomSheet.show(context, selectedDate: date);
  /// ```
  ///
  /// 신규 (병행 사용):
  /// ```dart
  /// InputAccessoryHelper.showQuickAdd(context, selectedDate: date);
  /// ```
  static void showQuickAdd(
    BuildContext context, {
    required DateTime selectedDate,
    VoidCallback? onSaveComplete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      elevation: 0,
      enableDrag: true,
      isDismissible: true,
      useRootNavigator: false,
      // ⚡ 초고속 애니메이션: 200ms → 100ms
      sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 150),
      ),
      builder: (context) => InputAccessoryWithBlur(
        selectedDate: selectedDate,
        onSaveComplete: onSaveComplete,
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// 디버그: 5가지 Figma 상태 확인용
  static void testAllStates(BuildContext context) {
    print('=== InputAccessory 5가지 상태 테스트 ===');
    print('1. Anything (기본)');
    print('2. Variant5 (버튼만)');
    print('3. Touched_Anything (확장)');
    print('4. Task');
    print('5. Schedule');
  }
}
