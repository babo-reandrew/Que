/// ➖ DashedDivider 위젯
///
/// Figma 디자인: Vector 88
/// 점선 구분선 (일정 / 할일·습관 구분)
///
/// 이거를 설정하고 → CustomPaint로 점선을 그려서
/// 이거를 해서 → Figma 디자인대로 시각적 구분을 명확히 한다

import 'package:flutter/material.dart';
import '../design_system/wolt_design_tokens.dart';

class DashedDivider extends StatelessWidget {
  final double width; // 구분선 너비
  final EdgeInsets padding; // 좌우 패딩

  const DashedDivider({
    super.key,
    this.width = 313, // Figma: 345 - 32 (16px * 2)
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CustomPaint(size: Size(width, 1), painter: _DashedLinePainter()),
    );
  }
}

/// 점선 페인터
/// 이거를 설정하고 → dash 패턴으로 선을 그려서
/// 이거를 해서 → Figma의 Vector 88 스타일을 재현한다
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = WoltDesignTokens.dashedLinePaint;

    // 이거를 설정하고 → dash 패턴 (5px 선, 3px 공백)
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    // 이거를 해서 → 전체 너비를 dash로 채운다
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
