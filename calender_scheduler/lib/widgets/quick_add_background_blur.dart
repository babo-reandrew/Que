import 'dart:ui';
import 'package:flutter/material.dart';
import '../design_system/quick_add_design_system.dart';

/// ========================================
/// 🎨 Quick Add Background Blur
/// ========================================
///
/// Figma: Rectangle 385
/// https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2480-73456
///
/// 월뷰나 디테일뷰에서 Quick Add Input Accessory View를 표시할 때
/// 하단부터 Input Accessory View 상단까지 그라데이션 블러를 적용하여
/// 뒤의 컨텐츠가 약간 흐려지도록 하는 백그라운드 컴포넌트
///
/// Figma 스펙:
/// - width: 393px
/// - height: 534px
/// - background: linear-gradient(180deg, rgba(255,255,255,0) 0%, rgba(240,240,240,0.95) 50%)
/// - backdrop-filter: blur(4px)

class QuickAddBackgroundBlurWidget extends StatelessWidget {
  const QuickAddBackgroundBlurWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: QuickAddDimensions.backgroundBlurHeight, // 534px
      child: Container(
        decoration: const BoxDecoration(
          gradient: QuickAddBackgroundBlur.gradient,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: QuickAddBackgroundBlur.blurSigma, // 4.0
            sigmaY: QuickAddBackgroundBlur.blurSigma, // 4.0
          ),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
