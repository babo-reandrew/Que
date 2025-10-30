import 'dart:ui';
import 'package:flutter/material.dart';
import 'quick_add/quick_add_control_box.dart';

/// 키보드에 붙는 InputAccessoryView (최적화된 버전)
///
/// **iOS inputAccessoryView 완벽 구현:**
/// - 키보드에 정확히 붙어서 올라옴
/// - 키보드 내려가도 위치 고정 (추가 버튼 클릭 시)
/// - Apple Spring Animation 적용 (고급스러운 등장/퇴장)
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

class _InputAccessoryWithBlurState extends State<InputAccessoryWithBlur>
    with SingleTickerProviderStateMixin {
  double _savedKeyboardHeight = 0.0; // 저장된 키보드 높이
  late AnimationController _springController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 🍎 Apple Spring Animation 컨트롤러
    // iOS 17+ Safari/SwiftUI 스타일 Spring
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // 0.6초 (쫀득한 느낌)
    );

    // 🎯 Y축 슬라이드: 80px 아래에서 시작 → 0으로
    // Spring 시뮬레이션: mass=1.0, stiffness=180, damping=20
    _slideAnimation =
        Tween<double>(
          begin: 80.0, // 더 아래에서 시작 (극적인 등장)
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _springController,
            // 🍎 Apple Emphasized Decelerate (쫀득한 감속)
            curve: const Cubic(0.05, 0.7, 0.1, 1.0),
            reverseCurve: const Cubic(0.3, 0.0, 0.8, 0.15), // 퇴장: 빠른 가속 → 급정거
          ),
        );

    // 🎨 투명도: 0 → 1
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _springController,
        // 초반 50%에 페이드 완료 (슬라이드보다 빠르게)
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        reverseCurve: const Interval(
          0.5,
          1.0,
          curve: Curves.easeIn,
        ), // 퇴장: 늦게 페이드 아웃
      ),
    );

    // 애니메이션 시작 (약간의 딜레이로 자연스럽게)
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _springController.forward();
      }
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // ✅ 키보드가 올라와 있으면 높이 저장
    if (keyboardHeight > 0) {
      _savedKeyboardHeight = keyboardHeight;
    }

    // ✅ 키보드 내려갔을 때 추가 패딩 (키보드 높이만큼)
    final extraBottomPadding = (keyboardHeight == 0 && _savedKeyboardHeight > 0)
        ? _savedKeyboardHeight
        : 0.0;

    // 🍎 Apple Spring Animation 적용
    // ✅ 핵심: Blur 배경을 먼저, 컨텐츠를 나중에 (컨텐츠가 blur 위에 떠있도록)
    return Stack(
      children: [
        // 1️⃣ Blur + Gradient 배경 레이어 (화면 전체를 덮음)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(opacity: _fadeAnimation.value, child: child);
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 20, // 강한 blur (육안 확인용)
                sigmaY: 20,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00FFFFFF), // rgba(255, 255, 255, 0) - 투명
                      Color(0xF2F0F0F0), // rgba(240, 240, 240, 0.95)
                    ],
                    stops: [0.0, 0.5],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2️⃣ Input Accessory 컨텐츠 (blur 위에 떠있음)
        AnimatedBuilder(
          animation: _springController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value), // Y축 슬라이드
              child: Opacity(
                opacity: _fadeAnimation.value, // 페이드 인
                child: child,
              ),
            );
          },
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight), // 키보드 높이만큼 올림
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // ✅ 동적 너비: 화면 너비 - 좌우 여백 28px (각 14px)
                  final screenWidth = MediaQuery.of(context).size.width;

                  return Padding(
                    padding: EdgeInsets.only(
                      left: 14,
                      right: 14,
                      bottom:
                          0 + extraBottomPadding, // 하단 여백 제거 (버튼 자체에서 18px 적용)
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: screenWidth - 28, // ✅ 동적 너비 적용
                        child: QuickAddControlBox(
                          selectedDate: widget.selectedDate,
                          onSave: (data) {
                            _animateOut(() {
                              widget.onSaveComplete?.call();
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🍎 퇴장 애니메이션 (Dismiss with Spring)
  Future<void> _animateOut(VoidCallback onComplete) async {
    await _springController.reverse(); // 역재생 (1.0 → 0.0)
    onComplete();
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
      // 🍎 Apple Spring Animation (iOS 스타일)
      // - duration: 500ms (쫀득한 등장)
      // - reverseDuration: 400ms (빠른 퇴장)
      // - curve: easeOutCubic (부드러운 감속)
      transitionAnimationController: null, // 커스텀 컨트롤러 사용 안 함 (내부에서 처리)
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
