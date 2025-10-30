import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'quick_add/quick_add_control_box.dart';

/// 키보드에 붙는 InputAccessoryView - Platform별 최적화 버전
///
/// **iOS와 Android에서 각각 최적의 blur 구현 사용**
/// - iOS: BackdropFilter (native 지원 우수)
/// - Android: 더 강한 blur sigma + 추가 레이어
/// - Apple Spring Animation 적용
class InputAccessoryWithBlurPlatform extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback? onSaveComplete;
  final VoidCallback? onCancel;

  const InputAccessoryWithBlurPlatform({
    super.key,
    required this.selectedDate,
    this.onSaveComplete,
    this.onCancel,
  });

  @override
  State<InputAccessoryWithBlurPlatform> createState() =>
      _InputAccessoryWithBlurPlatformState();
}

class _InputAccessoryWithBlurPlatformState
    extends State<InputAccessoryWithBlurPlatform>
    with SingleTickerProviderStateMixin {
  double _savedKeyboardHeight = 0.0;
  late AnimationController _springController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<double>(
      begin: 80.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _springController,
        curve: const Cubic(0.05, 0.7, 0.1, 1.0),
        reverseCurve: const Cubic(0.3, 0.0, 0.8, 0.15),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _springController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    if (keyboardHeight > 0) {
      _savedKeyboardHeight = keyboardHeight;
    }

    final extraBottomPadding = (keyboardHeight == 0 && _savedKeyboardHeight > 0)
        ? _savedKeyboardHeight
        : 0.0;

    // Platform별 blur sigma 조정
    final blurSigma = Platform.isIOS ? 12.0 : 20.0; // Android는 더 강하게

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          // 컨텐츠 (먼저 배치)
          AnimatedBuilder(
            animation: _springController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              );
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardHeight),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 14,
                    right: 14,
                    bottom: 0 + extraBottomPadding,
                  ),
                  child: SafeArea(
                    top: false,
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
              ),
            ),
          ),

          // Blur 레이어 (Platform별)
          if (Platform.isIOS)
            // iOS: BackdropFilter (최적)
            _buildIOSBlur(keyboardHeight, blurSigma)
          else
            // Android: 다중 레이어 blur
            _buildAndroidBlur(keyboardHeight, blurSigma),
        ],
      ),
    );
  }

  Widget _buildIOSBlur(double keyboardHeight, double blurSigma) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final safeAreaBottom = MediaQuery.of(context).padding.bottom;
        final quickAddTop =
            constraints.maxHeight - keyboardHeight - safeAreaBottom - 14 - 52;
        final blurHeight = constraints.maxHeight - quickAddTop;

        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: blurHeight,
          child: IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00FFFFFF),
                      Color(0xF2F0F0F0),
                    ],
                    stops: [0.0, 0.5],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAndroidBlur(double keyboardHeight, double blurSigma) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final safeAreaBottom = MediaQuery.of(context).padding.bottom;
        final quickAddTop =
            constraints.maxHeight - keyboardHeight - safeAreaBottom - 14 - 52;
        final blurHeight = constraints.maxHeight - quickAddTop;

        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: blurHeight,
          child: IgnorePointer(
            child: Stack(
              children: [
                // 첫 번째 blur 레이어
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurSigma,
                    sigmaY: blurSigma,
                  ),
                  child: Container(color: Colors.transparent),
                ),
                // 두 번째 blur 레이어 (더 강하게)
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurSigma / 2,
                    sigmaY: blurSigma / 2,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00FFFFFF),
                          Color(0xF2F0F0F0),
                        ],
                        stops: [0.0, 0.5],
                      ),
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

  Future<void> _animateOut(VoidCallback onComplete) async {
    await _springController.reverse();
    onComplete();
  }
}
