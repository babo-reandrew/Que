/// 📝 Queue 앱 타이포그래피 시스템
///
/// ⚠️ 중요: 이 파일이 Queue 앱의 모든 텍스트 스타일의 기준입니다.
///
/// 설계 철학:
/// - iOS 중심(iPhone 16) 모바일 앱에 최적화
/// - Apple HIG의 11개 타이포그래피 역할 기반
/// - 가독성을 위한 큰 글자(헤더)와 작은 글자(본문/캡션)의 대비 강화
/// - 총 30개 타입 스타일 (Display/Headline/Title/Body/Label × 3가지 무게)
///
/// 다국어 폰트 정책:
/// - 한국어 설정 → Gmarket Sans 폰트로 한글/영문 모두 표시
/// - 영어 설정 → Gilroy 폰트로 한글/영문 모두 표시
/// - 일본어 설정 → LINE Seed JP 폰트로 한글/영문/일본어 모두 표시
/// - ⚠️ 언어 설정에 따라 폰트가 변경되며, 같은 언어 설정 내에서는 한 폰트로 통일
///
/// 한국어 폰트 상세 스펙 (Gmarket Sans):
/// - displayLarge: 35pt, 46px(1.2x), 0%, Light/Medium/Bold, 사용 안 함(너무 큼)
/// - headlineLarge: 29pt, 37px(1.2x), -0.25%, Light/Medium/Bold, 사용 안 함(헤더 전용)
/// - headlineMedium: 23pt, 30px(1.2x), -0.25%, Light/Medium/Bold, 사용 안 함(헤더 전용)
/// - headlineSmall: 20pt, 26px(1.2x), 0.15%, Light/Medium/Bold, 사용 안 함(헤더 전용)
/// - titleLarge: 18pt, 23px(1.2x), -0.5%, Light/Medium/Bold, 큰 버튼(e.g. "제출")
/// - bodyLarge: 16pt, 25px(1.5x), -0.5%, Light/Medium/Bold, 표준 버튼(e.g. "확인")
/// - bodyMedium: 14pt, 23px(1.5x), 0%, Light/Medium/Bold, 보조 버튼(e.g. "취소")
/// - bodySmall: 13pt, 21px(1.5x), 0%, Light/Medium/Bold, 작은 버튼(아이콘)
/// - labelLarge: 12pt, 20px(1.5x), 0.5%, Light/Medium/Bold, 기본 버튼(e.g. "로그인")
/// - labelMedium: 10pt, 17px(1.5x), 0.5%, Light/Medium/Bold, 아주 작은 버튼(태그)
/// - labelSmall: 9pt, 15px(1.5x), 0.5%, Light/Medium/Bold, 피함(가독성 저하)
///
/// 영어 폰트 상세 스펙 (Gilroy):
/// - displayLarge: 38pt, 46px(1.2x), 0%, Light/Medium/Heavy, 사용 안 함(너무 큼)
/// - headlineLarge: 31pt, 37px(1.2x), -0.25%, Light/Medium/Heavy, 사용 안 함(헤더 전용)
/// - headlineMedium: 25pt, 30px(1.2x), -0.25%, Light/Medium/Heavy, 사용 안 함(헤더 전용)
/// - headlineSmall: 22pt, 26px(1.2x), 0.15%, Light/Medium/Heavy, 사용 안 함(헤더 전용)
/// - titleLarge: 19pt, 23px(1.2x), -0.5%, Light/Medium/Heavy, 큰 버튼(e.g. "Submit")
/// - bodyLarge: 17pt, 25px(1.5x), -0.5%, Light/Medium/Heavy, 표준 버튼(e.g. "OK")
/// - bodyMedium: 15pt, 23px(1.5x), 0%, Light/Medium/Heavy, 보조 버튼(e.g. "Cancel")
/// - bodySmall: 14pt, 21px(1.5x), 0%, Light/Medium/Heavy, 작은 버튼(아이콘)
/// - labelLarge: 13pt, 20px(1.5x), 0.5%, Light/Medium/Heavy, 기본 버튼(e.g. "Login")
/// - labelMedium: 11pt, 17px(1.5x), 0.5%, Light/Medium/Heavy, 아주 작은 버튼(태그)
/// - labelSmall: 10pt, 15px(1.5x), 0.5%, Light/Medium/Heavy, 피함(가독성 저하)
///
/// 일본어 폰트 상세 스펙 (LINE Seed JP):
/// - displayLarge: 33pt, 46px(1.39), -0.5%, 버튼 사용 안 함
/// - headlineLarge: 27pt, 37px(1.37), -0.5%, 사용 안 함(헤더 전용)
/// - headlineMedium: 22pt, 30px(1.36), -0.5%, 사용 안 함(헤더 전용)
/// - headlineSmall: 19pt, 26px(1.37), -0.5%, 사용 안 함(헤더 전용)
/// - titleLarge: 16pt, 23px(1.44), -0.5%, 큰 버튼(e.g. "送信")
/// - bodyLarge: 15pt, 25px(1.67), -0.5%, 표준 버튼(e.g. "OK")
/// - bodyMedium: 13pt, 23px(1.77), -0.5%, 보조 버튼(e.g. "キャンセル")
/// - bodySmall: 12pt, 21px(1.75), -0.5%, 작은 버튼
/// - labelLarge: 11pt, 20px(1.82), -0.5%, 기본 버튼(e.g. "ログイン")
/// - labelMedium: 9pt, 17px(1.89), -0.5%, 아주 작은 버튼
/// - labelSmall: 9pt, 15px(1.67), -0.5%, 피함(가독성 저하)
///
/// 사용 규칙:
/// 1. 새로운 텍스트 스타일이 필요하면 여기 있는 30개 중 가장 가까운 것 사용
/// 2. 여기에 없는 스타일은 절대 임의로 생성 금지
/// 3. 모든 UI는 반드시 이 타이포그래피 시스템 기반으로 구현
/// 4. 언어별로 크기가 다르므로 언어 설정에 따라 적절한 스펙 적용
///
/// 참고:
/// - 한국어/영어: Line Height 1.2x(헤더), 1.5x(본문/라벨)
/// - 일본어: Line Height 1.2x~1.9x (역할별 차등)
library;

import 'package:flutter/material.dart';

class Typography {
  Typography._();

  static const String fontFamilyKorean = 'Gmarket Sans';
  static const String fontFamilyEnglish = 'Gilroy';
  static const String fontFamilyJapanese = 'LINE Seed JP App_TTF';
  static const String fontFamily = fontFamilyKorean;

  // ==================== Display (가장 큰 제목) ====================  /// Display Large / Bold (Heavy)
  /// 한국어: 35pt, 46px(1.2x), 0%, Bold
  /// 영어: 38pt, 46px(1.2x), 0%, Heavy
  /// 일본어: 33pt, 46px(1.39), -0.5%
  /// 용도: 가장 큰 제목 (버튼 사용 안 함)
  static const TextStyle displayLargeExtraBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight:
        FontWeight.bold, // Korean: Bold, English: Heavy, Japanese: Medium
    fontSize: 35, // Korean: 35, English: 38, Japanese: 33
    height: 46 / 35, // Korean: 1.31, English: 1.21, Japanese: 1.39
    letterSpacing: 0, // Korean/English: 0%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Display Large / Medium
  /// 한국어: 35pt, 46px(1.2x), 0%, Medium
  /// 영어: 38pt, 46px(1.2x), 0%, Medium
  /// 일본어: 33pt, 46px(1.39), -0.5%
  static const TextStyle displayLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500, // Korean/English: Medium, Japanese: Medium
    fontSize: 35, // Korean: 35, English: 38, Japanese: 33
    height: 46 / 35, // Korean: 1.31, English: 1.21, Japanese: 1.39
    letterSpacing: 0, // Korean/English: 0%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Display Large / Light
  /// 한국어: 35pt, 46px(1.2x), 0%, Light
  /// 영어: 38pt, 46px(1.2x), 0%, Light
  /// 일본어: 33pt, 46px(1.39), -0.5%
  static const TextStyle displayLargeRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300, // Korean/English/Japanese: Light
    fontSize: 35, // Korean: 35, English: 38, Japanese: 33
    height: 46 / 35, // Korean: 1.31, English: 1.21, Japanese: 1.39
    letterSpacing: 0, // Korean/English: 0%, Japanese: -0.5%
    color: Colors.black,
  );

  // ==================== Headline (주요 제목) ====================

  /// Headline Large / Bold (Heavy)
  /// 한국어: 29pt, 37px(1.2x), -0.25%, Bold
  /// 영어: 31pt, 37px(1.2x), -0.25%, Heavy
  /// 일본어: 27pt, 37px(1.37), -0.5%
  /// 용도: 섹션 주제목 (헤더 전용, 버튼 사용 안 함)
  static const TextStyle headlineLargeExtraBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 29, // Korean: 29, English: 31, Japanese: 27
    height: 37 / 29, // Korean: 1.28, English: 1.19, Japanese: 1.37
    letterSpacing: -0.0025 * 29, // Korean/English: -0.25%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Headline Large / Medium
  /// 한국어: 29pt, 37px(1.2x), -0.25%, Medium
  /// 영어: 31pt, 37px(1.2x), -0.25%, Medium
  /// 일본어: 27pt, 37px(1.37), -0.5%
  static const TextStyle headlineLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 29, // Korean: 29, English: 31, Japanese: 27
    height: 37 / 29, // Korean: 1.28, English: 1.19, Japanese: 1.37
    letterSpacing: -0.0025 * 29, // Korean/English: -0.25%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Headline Large / Light
  /// 한국어: 29pt, 37px(1.2x), -0.25%, Light
  /// 영어: 31pt, 37px(1.2x), -0.25%, Light
  /// 일본어: 27pt, 37px(1.37), -0.5%
  static const TextStyle headlineLargeRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 29, // Korean: 29, English: 31, Japanese: 27
    height: 37 / 29, // Korean: 1.28, English: 1.19, Japanese: 1.37
    letterSpacing: -0.0025 * 29, // Korean/English: -0.25%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Headline Medium / Bold (Heavy)
  /// 한국어: 23pt, 30px(1.2x), -0.25%, Bold
  /// 영어: 25pt, 30px(1.2x), -0.25%, Heavy
  /// 일본어: 22pt, 30px(1.36), -0.5%
  /// 용도: 중형 섹션 제목 (헤더 전용)
  static const TextStyle headlineMediumExtraBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 23, // Korean: 23, English: 25, Japanese: 22
    height: 30 / 23, // Korean: 1.30, English: 1.20, Japanese: 1.36
    letterSpacing: -0.0025 * 23, // Korean/English: -0.25%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Headline Medium / Medium
  /// 한국어: 23pt, 30px(1.2x), -0.25%, Medium
  /// 영어: 25pt, 30px(1.2x), -0.25%, Medium
  /// 일본어: 22pt, 30px(1.36), -0.5%
  static const TextStyle headlineMediumBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 23, // Korean: 23, English: 25, Japanese: 22
    height: 30 / 23, // Korean: 1.30, English: 1.20, Japanese: 1.36
    letterSpacing: -0.0025 * 23, // Korean/English: -0.25%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Headline Medium / Light
  /// 한국어: 23pt, 30px(1.2x), -0.25%, Light
  /// 영어: 25pt, 30px(1.2x), -0.25%, Light
  /// 일본어: 22pt, 30px(1.36), -0.5%
  static const TextStyle headlineMediumRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 23, // Korean: 23, English: 25, Japanese: 22
    height: 30 / 23, // Korean: 1.30, English: 1.20, Japanese: 1.36
    letterSpacing: -0.0025 * 23, // Korean/English: -0.25%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Headline Small / Bold (Heavy)
  /// 한국어: 20pt, 26px(1.2x), 0.15%, Bold
  /// 영어: 22pt, 26px(1.2x), 0.15%, Heavy
  /// 일본어: 19pt, 26px(1.37), -0.5%
  /// 용도: 소형 섹션 제목 (헤더 전용)
  static const TextStyle headlineSmallExtraBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 20, // Korean: 20, English: 22, Japanese: 19
    height: 26 / 20, // Korean: 1.30, English: 1.18, Japanese: 1.37
    letterSpacing: 0.0015 * 20, // Korean/English: 0.15%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Headline Small / Medium
  /// 한국어: 20pt, 26px(1.2x), 0.15%, Medium
  /// 영어: 22pt, 26px(1.2x), 0.15%, Medium
  /// 일본어: 19pt, 26px(1.37), -0.5%
  static const TextStyle headlineSmallBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 20, // Korean: 20, English: 22, Japanese: 19
    height: 26 / 20, // Korean: 1.30, English: 1.18, Japanese: 1.37
    letterSpacing: 0.0015 * 20, // Korean/English: 0.15%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Headline Small / Light
  /// 한국어: 20pt, 26px(1.2x), 0.15%, Light
  /// 영어: 22pt, 26px(1.2x), 0.15%, Light
  /// 일본어: 19pt, 26px(1.37), -0.5%
  static const TextStyle headlineSmallRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 20, // Korean: 20, English: 22, Japanese: 19
    height: 26 / 20, // Korean: 1.30, English: 1.18, Japanese: 1.37
    letterSpacing: 0.0015 * 20, // Korean/English: 0.15%, Japanese: -0.5%
    color: Colors.black,
  );

  // ==================== Title (부제목) ====================

  /// Title Large / Bold (Heavy)
  /// 한국어: 18pt, 23px(1.2x), -0.5%, Bold
  /// 영어: 19pt, 23px(1.2x), -0.5%, Heavy
  /// 일본어: 16pt, 23px(1.44), -0.5%
  /// 용도: 큰 버튼 텍스트 (e.g. "제출", "Submit", "送信")
  static const TextStyle titleLargeExtraBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 18, // Korean: 18, English: 19, Japanese: 16
    height: 23 / 18, // Korean: 1.28, English: 1.21, Japanese: 1.44
    letterSpacing: -0.005 * 18, // Korean/English/Japanese: -0.5%
    color: Colors.black,
  );

  /// Title Large / Medium
  /// 한국어: 18pt, 23px(1.2x), -0.5%, Medium
  /// 영어: 19pt, 23px(1.2x), -0.5%, Medium
  /// 일본어: 16pt, 23px(1.44), -0.5%
  static const TextStyle titleLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 18, // Korean: 18, English: 19, Japanese: 16
    height: 23 / 18, // Korean: 1.28, English: 1.21, Japanese: 1.44
    letterSpacing: -0.005 * 18, // Korean/English/Japanese: -0.5%
    color: Colors.black,
  );

  /// Title Large / Light
  /// 한국어: 18pt, 23px(1.2x), -0.5%, Light
  /// 영어: 19pt, 23px(1.2x), -0.5%, Light
  /// 일본어: 16pt, 23px(1.44), -0.5%
  static const TextStyle titleLargeRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 18, // Korean: 18, English: 19, Japanese: 16
    height: 23 / 18, // Korean: 1.28, English: 1.21, Japanese: 1.44
    letterSpacing: -0.005 * 18, // Korean/English/Japanese: -0.5%
    color: Colors.black,
  );

  // ==================== Body (본문) ====================

  /// Body Large / Bold (Heavy)
  /// 한국어: 16pt, 25px(1.5x), -0.5%, Bold
  /// 영어: 17pt, 25px(1.5x), -0.5%, Heavy
  /// 일본어: 15pt, 25px(1.67), -0.5%
  /// 용도: 표준 버튼 텍스트 (e.g. "확인", "OK")
  static const TextStyle bodyLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 16, // Korean: 16, English: 17, Japanese: 15
    height: 25 / 16, // Korean: 1.56, English: 1.47, Japanese: 1.67
    letterSpacing: -0.005 * 16, // Korean/English/Japanese: -0.5%
    color: Colors.black,
  );

  /// Body Large / Medium
  /// 한국어: 16pt, 25px(1.5x), -0.5%, Medium
  /// 영어: 17pt, 25px(1.5x), -0.5%, Medium
  /// 일본어: 15pt, 25px(1.67), -0.5%
  static const TextStyle bodyLargeMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16, // Korean: 16, English: 17, Japanese: 15
    height: 25 / 16, // Korean: 1.56, English: 1.47, Japanese: 1.67
    letterSpacing: -0.005 * 16, // Korean/English/Japanese: -0.5%
    color: Colors.black,
  );

  /// Body Large / Light
  /// 한국어: 16pt, 25px(1.5x), -0.5%, Light
  /// 영어: 17pt, 25px(1.5x), -0.5%, Light
  /// 일본어: 15pt, 25px(1.67), -0.5%
  static const TextStyle bodyLargeRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 16, // Korean: 16, English: 17, Japanese: 15
    height: 25 / 16, // Korean: 1.56, English: 1.47, Japanese: 1.67
    letterSpacing: -0.005 * 16, // Korean/English/Japanese: -0.5%
    color: Colors.black,
  );

  /// Body Medium / Bold (Heavy)
  /// 한국어: 14pt, 23px(1.5x), 0%, Bold
  /// 영어: 15pt, 23px(1.5x), 0%, Heavy
  /// 일본어: 13pt, 23px(1.77), -0.5%
  /// 용도: 보조 버튼 텍스트 (e.g. "취소", "Cancel", "キャンセル")
  static const TextStyle bodyMediumBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 14, // Korean: 14, English: 15, Japanese: 13
    height: 23 / 14, // Korean: 1.64, English: 1.53, Japanese: 1.77
    letterSpacing: 0, // Korean/English: 0%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Body Medium / Medium
  /// 한국어: 14pt, 23px(1.5x), 0%, Medium
  /// 영어: 15pt, 23px(1.5x), 0%, Medium
  /// 일본어: 13pt, 23px(1.77), -0.5%
  static const TextStyle bodyMediumMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14, // Korean: 14, English: 15, Japanese: 13
    height: 23 / 14, // Korean: 1.64, English: 1.53, Japanese: 1.77
    letterSpacing: 0, // Korean/English: 0%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Body Medium / Light
  /// 한국어: 14pt, 23px(1.5x), 0%, Light
  /// 영어: 15pt, 23px(1.5x), 0%, Light
  /// 일본어: 13pt, 23px(1.77), -0.5%
  static const TextStyle bodyMediumRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 14, // Korean: 14, English: 15, Japanese: 13
    height: 23 / 14, // Korean: 1.64, English: 1.53, Japanese: 1.77
    letterSpacing: 0, // Korean/English: 0%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Body Small / Bold (Heavy)
  /// 한국어: 13pt, 21px(1.5x), 0%, Bold
  /// 영어: 14pt, 21px(1.5x), 0%, Heavy
  /// 일본어: 12pt, 21px(1.75), -0.5%
  /// 용도: 작은 버튼 텍스트 (아이콘 버튼)
  static const TextStyle bodySmallBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 13, // Korean: 13, English: 14, Japanese: 12
    height: 21 / 13, // Korean: 1.62, English: 1.50, Japanese: 1.75
    letterSpacing: 0, // Korean/English: 0%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Body Small / Medium
  /// 한국어: 13pt, 21px(1.5x), 0%, Medium
  /// 영어: 14pt, 21px(1.5x), 0%, Medium
  /// 일본어: 12pt, 21px(1.75), -0.5%
  static const TextStyle bodySmallMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 13, // Korean: 13, English: 14, Japanese: 12
    height: 21 / 13, // Korean: 1.62, English: 1.50, Japanese: 1.75
    letterSpacing: 0, // Korean/English: 0%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Body Small / Light
  /// 한국어: 13pt, 21px(1.5x), 0%, Light
  /// 영어: 14pt, 21px(1.5x), 0%, Light
  /// 일본어: 12pt, 21px(1.75), -0.5%
  static const TextStyle bodySmallRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 13, // Korean: 13, English: 14, Japanese: 12
    height: 21 / 13, // Korean: 1.62, English: 1.50, Japanese: 1.75
    letterSpacing: 0, // Korean/English: 0%, Japanese: -0.5%
    color: Colors.black,
  );

  // ==================== Label (라벨/캡션) ====================

  /// Label Large / Bold (Heavy)
  /// 한국어: 12pt, 20px(1.5x), 0.5%, Bold
  /// 영어: 13pt, 20px(1.5x), 0.5%, Heavy
  /// 일본어: 11pt, 20px(1.82), -0.5%
  /// 용도: 기본 버튼 텍스트 (e.g. "로그인", "Login", "ログイン")
  static const TextStyle labelLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 12, // Korean: 12, English: 13, Japanese: 11
    height: 20 / 12, // Korean: 1.67, English: 1.54, Japanese: 1.82
    letterSpacing: 0.005 * 12, // Korean/English: 0.5%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Label Large / Medium
  /// 한국어: 12pt, 20px(1.5x), 0.5%, Medium
  /// 영어: 13pt, 20px(1.5x), 0.5%, Medium
  /// 일본어: 11pt, 20px(1.82), -0.5%
  static const TextStyle labelLargeMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12, // Korean: 12, English: 13, Japanese: 11
    height: 20 / 12, // Korean: 1.67, English: 1.54, Japanese: 1.82
    letterSpacing: 0.005 * 12, // Korean/English: 0.5%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Label Large / Light
  /// 한국어: 12pt, 20px(1.5x), 0.5%, Light
  /// 영어: 13pt, 20px(1.5x), 0.5%, Light
  /// 일본어: 11pt, 20px(1.82), -0.5%
  static const TextStyle labelLargeRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 12, // Korean: 12, English: 13, Japanese: 11
    height: 20 / 12, // Korean: 1.67, English: 1.54, Japanese: 1.82
    letterSpacing: 0.005 * 12, // Korean/English: 0.5%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Label Medium / Bold (Heavy)
  /// 한국어: 10pt, 17px(1.5x), 0.5%, Bold
  /// 영어: 11pt, 17px(1.5x), 0.5%, Heavy
  /// 일본어: 9pt, 17px(1.89), -0.5%
  /// 용도: 아주 작은 버튼 (태그)
  static const TextStyle labelMediumBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 10, // Korean: 10, English: 11, Japanese: 9
    height: 17 / 10, // Korean: 1.70, English: 1.55, Japanese: 1.89
    letterSpacing: 0.005 * 10, // Korean/English: 0.5%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Label Medium / Medium
  /// 한국어: 10pt, 17px(1.5x), 0.5%, Medium
  /// 영어: 11pt, 17px(1.5x), 0.5%, Medium
  /// 일본어: 9pt, 17px(1.89), -0.5%
  static const TextStyle labelMediumMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 10, // Korean: 10, English: 11, Japanese: 9
    height: 17 / 10, // Korean: 1.70, English: 1.55, Japanese: 1.89
    letterSpacing: 0.005 * 10, // Korean/English: 0.5%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Label Medium / Light
  /// 한국어: 10pt, 17px(1.5x), 0.5%, Light
  /// 영어: 11pt, 17px(1.5x), 0.5%, Light
  /// 일본어: 9pt, 17px(1.89), -0.5%
  static const TextStyle labelMediumRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 10, // Korean: 10, English: 11, Japanese: 9
    height: 17 / 10, // Korean: 1.70, English: 1.55, Japanese: 1.89
    letterSpacing: 0.005 * 10, // Korean/English: 0.5%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Label Small / Bold (Heavy)
  /// 한국어: 9pt, 15px(1.5x), 0.5%, Bold
  /// 영어: 10pt, 15px(1.5x), 0.5%, Heavy
  /// 일본어: 9pt, 15px(1.67), -0.5%
  /// 용도: 피함 (가독성 저하)
  static const TextStyle labelSmallBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 9, // Korean: 9, English: 10, Japanese: 9
    height: 15 / 9, // Korean: 1.67, English: 1.50, Japanese: 1.67
    letterSpacing: 0.005 * 9, // Korean/English: 0.5%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Label Small / Medium
  /// 한국어: 9pt, 15px(1.5x), 0.5%, Medium
  /// 영어: 10pt, 15px(1.5x), 0.5%, Medium
  /// 일본어: 9pt, 15px(1.67), -0.5%
  static const TextStyle labelSmallMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 9, // Korean: 9, English: 10, Japanese: 9
    height: 15 / 9, // Korean: 1.67, English: 1.50, Japanese: 1.67
    letterSpacing: 0.005 * 9, // Korean/English: 0.5%, Japanese: -0.5%
    color: Colors.black,
  );

  /// Label Small / Light
  /// 한국어: 9pt, 15px(1.5x), 0.5%, Light
  /// 영어: 10pt, 15px(1.5x), 0.5%, Light
  /// 일본어: 9pt, 15px(1.67), -0.5%
  static const TextStyle labelSmallRegular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 9, // Korean: 9, English: 10, Japanese: 9
    height: 15 / 9, // Korean: 1.67, English: 1.50, Japanese: 1.67
    letterSpacing: 0.005 * 9, // Korean/English: 0.5%, Japanese: -0.5%
    color: Colors.black,
  );
}
