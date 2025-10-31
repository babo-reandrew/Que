import 'package:flutter/material.dart';

// ===================================================================
// ⭐️ Responsive Utility: 반응형 레이아웃 지원
// ===================================================================
// 이거를 설정하고 → MediaQuery를 활용해서 화면 크기를 감지하고
// 이거를 해서 → 기기별로 적절한 크기와 비율을 계산한다
// 이거는 이래서 → 모든 기기에서 일관된 UX를 제공한다
// 이거라면 → 고정 크기 대신 비율 기반 레이아웃을 사용한다

class Responsive {
  // ===================================================================
  // 기준 화면 크기 (iPhone 13 Pro)
  // ===================================================================
  static const double baseWidth = 390.0; // iPhone 13 Pro 너비
  static const double baseHeight = 844.0; // iPhone 13 Pro 높이

  // ===================================================================
  // 화면 크기 비율 계산
  // ===================================================================

  /// 현재 화면의 너비 비율을 계산한다
  /// 이거를 설정하고 → 현재 화면 너비를 기준 너비로 나눠서
  /// 이거를 해서 → 기기별 너비 비율을 구한다
  /// 이거는 이래서 → 같은 비율로 UI 요소를 확대/축소할 수 있다
  static double getWidthRatio(BuildContext context) {
    return MediaQuery.of(context).size.width / baseWidth;
  }

  /// 현재 화면의 높이 비율을 계산한다
  static double getHeightRatio(BuildContext context) {
    return MediaQuery.of(context).size.height / baseHeight;
  }

  // ===================================================================
  // 반응형 크기 계산
  // ===================================================================

  /// 기준 크기를 화면 너비에 맞게 조정한다
  /// 이거를 설정하고 → 기준 크기에 너비 비율을 곱해서
  /// 이거를 해서 → 현재 화면에 맞는 크기를 계산한다
  /// 이거는 이래서 → 모든 기기에서 비례적으로 보이는 UI를 만든다
  /// 이거라면 → 작은 화면에서는 작게, 큰 화면에서는 크게 표시된다
  static double scaledWidth(BuildContext context, double baseSize) {
    return baseSize * getWidthRatio(context);
  }

  /// 기준 크기를 화면 높이에 맞게 조정한다
  static double scaledHeight(BuildContext context, double baseSize) {
    return baseSize * getHeightRatio(context);
  }

  /// 너비와 높이 중 작은 비율을 사용해서 조정한다
  /// 이거를 설정하고 → 너비/높이 비율 중 작은 값을 선택해서
  /// 이거를 해서 → 가로/세로 모드 변경 시에도 안정적인 크기를 유지한다
  /// 이거는 이래서 → 정사각형 요소나 아이콘이 찌그러지지 않는다
  static double scaledSize(BuildContext context, double baseSize) {
    final widthRatio = getWidthRatio(context);
    final heightRatio = getHeightRatio(context);
    final minRatio = widthRatio < heightRatio ? widthRatio : heightRatio;
    return baseSize * minRatio;
  }

  // ===================================================================
  // 반응형 패딩/마진 계산
  // ===================================================================

  /// 좌우 여백을 화면 너비의 비율로 계산한다
  /// 이거를 설정하고 → 화면 너비에 비율을 곱해서
  /// 이거를 해서 → 화면 크기에 맞는 여백을 만든다
  /// 이거는 이래서 → 작은 화면에서는 적은 여백, 큰 화면에서는 많은 여백
  static double horizontalPadding(BuildContext context, {double ratio = 0.04}) {
    return MediaQuery.of(context).size.width * ratio; // 기본 4%
  }

  /// 상하 여백을 화면 높이의 비율로 계산한다
  static double verticalPadding(BuildContext context, {double ratio = 0.02}) {
    return MediaQuery.of(context).size.height * ratio; // 기본 2%
  }

  // ===================================================================
  // 화면 크기 분류
  // ===================================================================

  /// 현재 기기가 작은 화면인지 확인한다 (iPhone SE 등)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 375;
  }

  /// 현재 기기가 큰 화면인지 확인한다 (iPad 등)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  /// 현재 기기가 태블릿인지 확인한다
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  // ===================================================================
  // Safe Area 영역 계산
  // ===================================================================

  /// 상단 Safe Area 높이 (노치 영역)
  static double topSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// 하단 Safe Area 높이 (홈 인디케이터 영역)
  static double bottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  // ===================================================================
  // 디버깅용 유틸리티
  // ===================================================================

  /// 현재 화면 정보를 콘솔에 출력한다
  static void printScreenInfo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

  }
}

// ===================================================================
// ⭐️ Responsive Container Widget: 자동 패딩 적용 컨테이너
// ===================================================================
// 이거를 설정하고 → 화면 크기에 맞는 패딩을 자동으로 적용하는 컨테이너를 만들어서
// 이거를 해서 → 모든 화면에서 일관된 여백을 유지한다
// 이거는 이래서 → 수동으로 패딩을 계산할 필요가 없다
// 이거라면 → 코드가 간결해지고 유지보수가 쉬워진다

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double horizontalRatio;
  final double verticalRatio;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.horizontalRatio = 0.04, // 기본 4%
    this.verticalRatio = 0.02, // 기본 2%
  });

  @override
  Widget build(BuildContext context) {
    // 이거를 설정하고 → padding이 제공되지 않으면 자동으로 계산하고
    // 이거를 해서 → 화면 크기에 비례하는 패딩을 적용한다
    final effectivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: Responsive.horizontalPadding(
            context,
            ratio: horizontalRatio,
          ),
          vertical: Responsive.verticalPadding(context, ratio: verticalRatio),
        );

    return Container(padding: effectivePadding, child: child);
  }
}

// ===================================================================
// ⭐️ Responsive Text: 자동 크기 조절 텍스트
// ===================================================================
// 이거를 설정하고 → 화면 크기에 맞게 텍스트 크기를 자동으로 조절해서
// 이거를 해서 → 모든 기기에서 읽기 좋은 크기를 유지한다
// 이거는 이래서 → 작은 화면에서 글자가 너무 크거나 큰 화면에서 너무 작은 문제를 방지한다

class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.baseFontSize = 14.0,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // 이거를 설정하고 → 기본 폰트 크기를 화면 크기에 맞게 조절해서
    // 이거를 해서 → 적절한 크기의 텍스트를 표시한다
    final scaledFontSize = Responsive.scaledWidth(context, baseFontSize);

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: scaledFontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
