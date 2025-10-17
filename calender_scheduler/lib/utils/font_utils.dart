import 'package:flutter/material.dart';

/// 폰트 관련 유틸리티 함수들을 모아놓은 클래스
/// 안전한 폰트 fallback을 위해 사용한다
class FontUtils {
  // 기본 폰트 패밀리 설정
  static const String defaultFontFamily = 'NotoSansKR';

  // 안전한 폰트 fallback 체인
  static const List<String> safeFontFallback = [
    'NotoSansKR', // 기본 폰트
    'Gilroy', // 영어 폰트
    'Gmarket Sans', // 한국어 폰트
    'LINE Seed JP App_TTF', // 일본어 폰트
    'Inter', // 대체 폰트
    'sans-serif', // 시스템 기본 폰트
  ];

  // 안전한 TextStyle을 생성하는 함수 - 폰트 에러를 방지한다
  static TextStyle createSafeTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.0, // 기본 폰트 크기를 14로 설정한다
      fontWeight: fontWeight ?? FontWeight.w400, // 기본 폰트 굵기를 400으로 설정한다
      color: color ?? const Color(0xFF262626), // 기본 색상을 설정한다
      fontFamily: fontFamily ?? defaultFontFamily, // 기본 폰트 패밀리를 설정한다
      fontFamilyFallback:
          fontFamilyFallback ?? safeFontFallback, // 안전한 fallback을 설정한다
      letterSpacing: letterSpacing ?? -0.005, // 기본 자간을 설정한다
      height: height ?? 1.2, // 기본 줄 높이를 설정한다
      decoration: decoration, // 텍스트 장식을 설정한다
    );
  }

  // 기본 텍스트 스타일을 생성하는 함수 - copyWith로 세부사항만 변경 가능
  static TextStyle createBaseTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    String? fontFamily,
  }) {
    return createSafeTextStyle(
      fontSize: fontSize ?? 14.0, // 기본 폰트 크기를 14로 설정한다
      fontWeight: fontWeight ?? FontWeight.w400, // 기본 폰트 굵기를 400으로 설정한다
      color: color ?? const Color(0xFF262626), // 기본 색상을 설정한다
      fontFamily: fontFamily ?? defaultFontFamily, // 기본 폰트 패밀리를 설정한다
    );
  }

  // 제목용 텍스트 스타일을 생성하는 함수 - 헤더나 중요한 텍스트에 사용한다
  static TextStyle createTitleTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    String? fontFamily,
  }) {
    return createSafeTextStyle(
      fontSize: fontSize ?? 24.0, // 기본 폰트 크기를 24로 설정한다
      fontWeight: fontWeight ?? FontWeight.w900, // 기본 폰트 굵기를 900으로 설정한다
      color: color ?? const Color(0xFF262626), // 기본 색상을 설정한다
      fontFamily: fontFamily ?? defaultFontFamily, // 기본 폰트 패밀리를 설정한다
    );
  }

  // 본문용 텍스트 스타일을 생성하는 함수 - 일반 텍스트에 사용한다
  static TextStyle createBodyTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    String? fontFamily,
  }) {
    return createSafeTextStyle(
      fontSize: fontSize ?? 16.0, // 기본 폰트 크기를 16으로 설정한다
      fontWeight: fontWeight ?? FontWeight.w400, // 기본 폰트 굵기를 400으로 설정한다
      color: color ?? const Color(0xFF505050), // 기본 색상을 설정한다
      fontFamily: fontFamily ?? defaultFontFamily, // 기본 폰트 패밀리를 설정한다
    );
  }

  // 캡션용 텍스트 스타일을 생성하는 함수 - 작은 텍스트에 사용한다
  static TextStyle createCaptionTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    String? fontFamily,
  }) {
    return createSafeTextStyle(
      fontSize: fontSize ?? 12.0, // 기본 폰트 크기를 12로 설정한다
      fontWeight: fontWeight ?? FontWeight.w400, // 기본 폰트 굵기를 400으로 설정한다
      color: color ?? const Color(0xFF909090), // 기본 색상을 설정한다
      fontFamily: fontFamily ?? defaultFontFamily, // 기본 폰트 패밀리를 설정한다
    );
  }

  // 폰트가 사용 가능한지 확인하는 함수 - 폰트 에러를 방지한다
  static bool isFontAvailable(String fontFamily) {
    // 실제로는 런타임에 확인해야 하지만, 여기서는 기본 폰트들만 확인한다
    const availableFonts = [
      'NotoSansKR',
      'Gilroy',
      'Gmarket Sans',
      'LINE Seed JP App_TTF',
      'Inter',
    ];
    return availableFonts.contains(fontFamily);
  }

  // 안전한 폰트 패밀리를 반환하는 함수 - 사용 불가능한 폰트를 대체한다
  static String getSafeFontFamily(String? preferredFont) {
    if (preferredFont != null && isFontAvailable(preferredFont)) {
      return preferredFont; // 선호하는 폰트가 사용 가능하면 반환한다
    }
    return defaultFontFamily; // 기본 폰트를 반환한다
  }
}
