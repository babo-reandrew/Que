import 'package:flutter/material.dart';
import '../const/color.dart';
import 'font_utils.dart';

/// 공통으로 사용되는 함수들을 모아놓은 유틸리티 클래스
/// 재사용 가능한 함수들을 중앙화해서 관리한다
class CommonFunctions {
  // 기본 텍스트 스타일을 생성하는 함수 - copyWith로 세부사항만 변경 가능
  static TextStyle createBaseTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return FontUtils.createBaseTextStyle(
      fontSize: fontSize ?? 11, // 기본 폰트 크기를 11로 설정한다
      fontWeight: fontWeight ?? FontWeight.w900, // 기본 폰트 굵기를 900으로 설정한다
      color: color ?? gray950, // 기본 텍스트 색상을 gray950으로 설정한다
    );
  }

  // 제목용 텍스트 스타일을 생성하는 함수 - 헤더나 중요한 텍스트에 사용한다
  static TextStyle createTitleTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return FontUtils.createTitleTextStyle(
      fontSize: fontSize ?? 24, // 기본 폰트 크기를 24로 설정한다
      fontWeight: fontWeight ?? FontWeight.w900, // 기본 폰트 굵기를 900으로 설정한다
      color: color ?? gray1000, // 기본 텍스트 색상을 gray1000으로 설정한다
    );
  }

  // 카드 스타일을 생성하는 함수 - 일관된 카드 디자인을 위해 사용한다
  static BoxDecoration createCardDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    double? borderWidth,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? Colors.white, // 기본 배경색을 흰색으로 설정한다
      border: Border.all(
        color: borderColor ?? gray200, // 기본 테두리 색상을 gray200으로 설정한다
        width: borderWidth ?? 1.0, // 기본 테두리 두께를 1픽셀로 설정한다
      ),
      borderRadius: BorderRadius.circular(
        borderRadius ?? 12.0,
      ), // 기본 모서리 반지름을 12로 설정한다
    );
  }

  // 패딩을 생성하는 함수 - 일관된 여백을 위해 사용한다
  static EdgeInsets createPadding({
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    if (all != null) {
      return EdgeInsets.all(all); // 모든 방향에 동일한 패딩을 적용한다
    }
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 16.0, // 기본 좌우 패딩을 16픽셀로 설정한다
      vertical: vertical ?? 8.0, // 기본 상하 패딩을 8픽셀로 설정한다
    );
  }

  // 애니메이션 지속시간을 설정하는 함수 - 일관된 애니메이션을 위해 사용한다
  static Duration createAnimationDuration({int milliseconds = 300}) {
    return Duration(milliseconds: milliseconds); // 기본 애니메이션 지속시간을 300ms로 설정한다
  }

  // 화면 크기에 따른 반응형 레이아웃을 생성하는 함수 - 다양한 화면 크기에 대응한다
  static Widget createResponsiveLayout({
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity, // 전체 너비를 사용한다
      constraints: maxWidth != null
          ? BoxConstraints(maxWidth: maxWidth)
          : null, // 최대 너비 제한을 설정한다
      padding: padding ?? createPadding(), // 기본 패딩을 적용한다
      child: child, // 자식 위젯을 배치한다
    );
  }
}
