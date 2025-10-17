import 'package:flutter/material.dart';

/// 다국어 지원 폰트 설정 클래스
class MultilingualFonts {
  // 기본 폰트 패밀리 (안전한 fallback 설정)
  static const String primaryEnglish = 'Gilroy';
  static const String primaryKorean = 'Gmarket Sans';
  static const String primaryJapanese = 'LINE Seed JP App_TTF';
  static const String fallbackSans = 'Inter';
  static const String systemFallback = 'NotoSansKR'; // 시스템 기본 폰트

  // 폰트 fallback 체인 (안전한 순서로 설정)
  static const List<String> displayFallback = [
    primaryEnglish,
    primaryKorean,
    primaryJapanese,
    systemFallback, // 시스템 기본 폰트 추가
    'sans-serif',
  ];

  static const List<String> bodyFallback = [
    fallbackSans,
    primaryKorean,
    primaryJapanese,
    systemFallback, // 시스템 기본 폰트 추가
    'sans-serif',
  ];
}

/// 언어별 폰트 크기 조정 계수
class FontScalingFactors {
  static const double english = 1.0; // 기준값
  static const double korean = 0.92; // 92%
  static const double japanese = 0.86; // 86%
}

/// 캘린더 관련 타이포그래피 상수들
class CalendarTypography {
  // 기본 캘린더 텍스트 스타일 (안전한 폰트 fallback)
  static const TextStyle calendarText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w900,
    fontFamily: 'NotoSansKR', // 기본 폰트를 NotoSansKR로 설정
    fontFamilyFallback: MultilingualFonts.displayFallback,
    letterSpacing: -0.005,
  );

  // 헤더 텍스트 스타일 (안전한 폰트 fallback)
  static const TextStyle headerText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    fontFamily: 'NotoSansKR', // 기본 폰트를 NotoSansKR로 설정
    fontFamilyFallback: MultilingualFonts.displayFallback,
    letterSpacing: -0.005,
    height: 1.2,
  );
}

/// 다국어 지원 타이포그래피 시스템 (Apple HIG 기반)
class MultilingualTypography {
  /// 현재 로케일에 따른 폰트 크기 조정
  static double _getScaledFontSize(double baseFontSize, Locale? locale) {
    if (locale == null) return baseFontSize;

    switch (locale.languageCode) {
      case 'ko':
        return baseFontSize * FontScalingFactors.korean;
      case 'ja':
        return baseFontSize * FontScalingFactors.japanese;
      default:
        return baseFontSize * FontScalingFactors.english;
    }
  }

  /// 현재 로케일에 따른 폰트 패밀리 선택
  static List<String> _getFontFallback(bool isDisplayText) {
    return isDisplayText
        ? MultilingualFonts.displayFallback
        : MultilingualFonts.bodyFallback;
  }

  // MARK: - Display Styles (브랜딩, 앱 타이틀)

  /// Display Large - 33pt (앱 타이틀, 브랜딩)
  static TextStyle displayLarge({
    Color color = const Color(0xFF262626),
    FontWeight fontWeight = FontWeight.w900,
    Locale? locale,
  }) {
    return TextStyle(
      fontSize: _getScaledFontSize(33.0, locale),
      fontWeight: fontWeight,
      color: color,
      fontFamily: 'NotoSansKR', // 기본 폰트 설정
      fontFamilyFallback: _getFontFallback(true),
      letterSpacing: -0.005,
      height: 1.2,
    );
  }

  // MARK: - Headline Styles (헤더)

  /// Headline Large - 27pt (주요 헤더)
  static TextStyle headlineLarge({
    Color color = const Color(0xFF262626),
    FontWeight fontWeight = FontWeight.w900,
    Locale? locale,
  }) {
    return TextStyle(
      fontSize: _getScaledFontSize(27.0, locale),
      fontWeight: fontWeight,
      color: color,
      fontFamilyFallback: _getFontFallback(true),
      letterSpacing: -0.005,
      height: 1.2,
    );
  }

  /// Headline Medium - 22pt (섹션 헤더)
  static TextStyle headlineMedium({
    Color color = const Color(0xFF262626),
    FontWeight fontWeight = FontWeight.w700,
    Locale? locale,
  }) {
    return TextStyle(
      fontSize: _getScaledFontSize(22.0, locale),
      fontWeight: fontWeight,
      color: color,
      fontFamilyFallback: _getFontFallback(true),
      letterSpacing: -0.005,
      height: 1.2,
    );
  }

  /// Headline Small - 19pt (소제목)
  static TextStyle headlineSmall({
    Color color = const Color(0xFF262626),
    FontWeight fontWeight = FontWeight.w700,
    Locale? locale,
  }) {
    return TextStyle(
      fontSize: _getScaledFontSize(19.0, locale),
      fontWeight: fontWeight,
      color: color,
      fontFamilyFallback: _getFontFallback(true),
      letterSpacing: -0.005,
      height: 1.2,
    );
  }

  // MARK: - Title Styles (제목)

  /// Title Large - 16pt (카드 제목)
  static TextStyle titleLarge({
    Color color = const Color(0xFF262626),
    FontWeight fontWeight = FontWeight.w700,
    Locale? locale,
  }) {
    return TextStyle(
      fontSize: _getScaledFontSize(16.0, locale),
      fontWeight: fontWeight,
      color: color,
      fontFamilyFallback: _getFontFallback(true),
      letterSpacing: -0.005,
      height: 1.2,
    );
  }

  // MARK: - Body Styles (본문)

  /// Body Large - 15pt (긴 텍스트 본문)
  static TextStyle bodyLarge({
    Color color = const Color(0xFF505050),
    FontWeight fontWeight = FontWeight.w500,
    Locale? locale,
  }) {
    return TextStyle(
      fontSize: _getScaledFontSize(15.0, locale),
      fontWeight: fontWeight,
      color: color,
      fontFamilyFallback: _getFontFallback(false),
      letterSpacing: -0.005,
      height: 1.5,
    );
  }

  /// Body Medium - 13pt (기본 텍스트)
  static TextStyle bodyMedium({
    Color color = const Color(0xFF656565),
    FontWeight fontWeight = FontWeight.w400,
    Locale? locale,
  }) {
    return TextStyle(
      fontSize: _getScaledFontSize(13.0, locale),
      fontWeight: fontWeight,
      color: color,
      fontFamilyFallback: _getFontFallback(false),
      letterSpacing: -0.005,
      height: 1.5,
    );
  }

  /// Body Small - 12pt (보조 텍스트)
  static TextStyle bodySmall({
    Color color = const Color(0xFF656565),
    FontWeight fontWeight = FontWeight.w400,
    Locale? locale,
  }) {
    return TextStyle(
      fontSize: _getScaledFontSize(12.0, locale),
      fontWeight: fontWeight,
      color: color,
      fontFamilyFallback: _getFontFallback(false),
      letterSpacing: -0.005,
      height: 1.5,
    );
  }

  // MARK: - Label Styles (라벨, 버튼)

  /// Label Large - 11pt (버튼, 탭)
  static TextStyle labelLarge({
    Color color = const Color(0xFF909090),
    FontWeight fontWeight = FontWeight.w500,
    Locale? locale,
  }) {
    return TextStyle(
      fontSize: _getScaledFontSize(11.0, locale),
      fontWeight: fontWeight,
      color: color,
      fontFamilyFallback: _getFontFallback(false),
      letterSpacing: -0.005,
      height: 1.5,
    );
  }

  /// Label Medium - 9pt (캡션, 라벨)
  static TextStyle labelMedium({
    Color color = const Color(0xFF909090),
    FontWeight fontWeight = FontWeight.w500,
    Locale? locale,
  }) {
    return TextStyle(
      fontSize: _getScaledFontSize(9.0, locale),
      fontWeight: fontWeight,
      color: color,
      fontFamilyFallback: _getFontFallback(false),
      letterSpacing: -0.005,
      height: 1.5,
    );
  }
}

/// 접근성을 고려한 Dynamic Type 지원 헬퍼
class AccessibleTypography {
  /// 접근성을 위한 텍스트 크기 제한 (최소 1.0, 최대 1.5)
  static TextStyle constrainTextScale(
    TextStyle baseStyle,
    BuildContext context,
  ) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double textScaleFactor = mediaQuery.textScaler.scale(1.0);
    final double constrainedScale = textScaleFactor.clamp(1.0, 1.5);

    return baseStyle.copyWith(
      fontSize:
          (baseStyle.fontSize ?? 14.0) * (constrainedScale / textScaleFactor),
    );
  }

  /// RichText용 텍스트 스케일 팩터 가져오기
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0).clamp(1.0, 1.5);
  }
}

/// 공통 폰트 스타일 함수들 (기존 호환성 유지)
class CommonTypography {
  /// 기본 텍스트 스타일을 생성하는 함수
  static TextStyle createTextStyle({
    double fontSize = 14,
    Color color = const Color(0xFF262626),
    FontWeight fontWeight = FontWeight.w400,
    Locale? locale,
  }) {
    return MultilingualTypography.bodyMedium(
      color: color,
      fontWeight: fontWeight,
      locale: locale,
    ).copyWith(
      fontSize: MultilingualTypography._getScaledFontSize(fontSize, locale),
    );
  }

  /// 제목용 텍스트 스타일
  static TextStyle createTitleStyle({
    double fontSize = 18,
    Color color = const Color(0xFF262626),
    FontWeight fontWeight = FontWeight.w900,
    Locale? locale,
  }) {
    return MultilingualTypography.headlineSmall(
      color: color,
      fontWeight: fontWeight,
      locale: locale,
    ).copyWith(
      fontSize: MultilingualTypography._getScaledFontSize(fontSize, locale),
    );
  }

  /// 부제목용 텍스트 스타일
  static TextStyle createSubtitleStyle({
    double fontSize = 16,
    Color color = const Color(0xFF505050),
    FontWeight fontWeight = FontWeight.w700,
    Locale? locale,
  }) {
    return MultilingualTypography.titleLarge(
      color: color,
      fontWeight: fontWeight,
      locale: locale,
    ).copyWith(
      fontSize: MultilingualTypography._getScaledFontSize(fontSize, locale),
    );
  }

  /// 본문용 텍스트 스타일
  static TextStyle createBodyStyle({
    double fontSize = 14,
    Color color = const Color(0xFF656565),
    FontWeight fontWeight = FontWeight.w400,
    Locale? locale,
  }) {
    return MultilingualTypography.bodyMedium(
      color: color,
      fontWeight: fontWeight,
      locale: locale,
    ).copyWith(
      fontSize: MultilingualTypography._getScaledFontSize(fontSize, locale),
    );
  }

  /// 캡션용 텍스트 스타일
  static TextStyle createCaptionStyle({
    double fontSize = 12,
    Color color = const Color(0xFF909090),
    FontWeight fontWeight = FontWeight.w300,
    Locale? locale,
  }) {
    return MultilingualTypography.labelLarge(
      color: color,
      fontWeight: fontWeight,
      locale: locale,
    ).copyWith(
      fontSize: MultilingualTypography._getScaledFontSize(fontSize, locale),
    );
  }
}

// ===================================================================
// ⭐️ Typography Extension: copyWith 패턴으로 스타일 재사용
// ===================================================================
// 이거를 설정하고 → TextStyle에 extension을 추가해서
// 이거를 해서 → 기본 스타일에서 필요한 속성만 변경할 수 있다
// 이거는 이래서 → 코드 중복을 줄이고 일관성을 유지한다
// 이거라면 → 모든 텍스트가 같은 기준으로 스타일링된다

extension TypographyExtension on TextStyle {
  /// 색상만 변경
  TextStyle withColor(Color color) => copyWith(color: color);

  /// 크기만 변경
  TextStyle withSize(double size) => copyWith(fontSize: size);

  /// 폰트 두께만 변경
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);

  /// Bold 스타일 적용
  TextStyle bold() => copyWith(fontWeight: FontWeight.bold);

  /// Medium 스타일 적용
  TextStyle medium() => copyWith(fontWeight: FontWeight.w500);

  /// Regular 스타일 적용
  TextStyle regular() => copyWith(fontWeight: FontWeight.w400);

  /// Light 스타일 적용
  TextStyle light() => copyWith(fontWeight: FontWeight.w300);

  /// 투명도 조절
  TextStyle withOpacity(double opacity) =>
      copyWith(color: color?.withOpacity(opacity));

  /// 행간 조절
  TextStyle withHeight(double height) => copyWith(height: height);

  /// 자간 조절
  TextStyle withLetterSpacing(double spacing) =>
      copyWith(letterSpacing: spacing);
}
