import 'dart:ui';
import 'package:flutter/material.dart';
import 'quick_add/quick_add_control_box.dart';

/// 키보드에 붙는 InputAccessoryView - ImageFiltered 버전 (대체 구현)
///
/// **BackdropFilter가 작동하지 않을 때 사용하는 버전**
/// - ImageFiltered 위젯 사용: BackdropFilter보다 강력한 blur
/// - 전체 화면을 blur하는 방식 (성능은 약간 낮지만 확실히 작동)
/// - Apple Spring Animation 적용
class InputAccessoryWithBlurV2 extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback? onSaveComplete;
  final VoidCallback? onCancel;

  const InputAccessoryWithBlurV2({
    super.key,
    required this.selectedDate,
    this.onSaveComplete,
    this.onCancel,
  });

  @override
  State<InputAccessoryWithBlurV2> createState() => _InputAccessoryWithBlurV2State();
}

class _InputAccessoryWithBlurV2State extends State<InputAccessoryWithBlurV2>
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

    // 방법 7: ImageFiltered로 전체 화면 blur (확실히 작동)
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 12,
        sigmaY: 12,
        tileMode: TileMode.decal,
      ),
      child: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            // 그라디언트 오버레이
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00FFFFFF), // rgba(255, 255, 255, 0)
                      Color(0xF2F0F0F0), // rgba(240, 240, 240, 0.95)
                    ],
                    stops: [0.0, 0.5],
                  ),
                ),
              ),
            ),

            // Input Accessory 컨텐츠
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
          ],
        ),
      ),
    );
  }

  Future<void> _animateOut(VoidCallback onComplete) async {
    await _springController.reverse();
    onComplete();
  }
}
