/// 🔤 Wolt 타이포그래피 시스템
///
/// LINE Seed JP App_TTF 폰트 패밀리 기반
/// Figma 디자인 분석에서 추출한 모든 텍스트 스타일
library;

import 'package:flutter/material.dart';
import 'wolt_design_tokens.dart';

class WoltTypography {
  WoltTypography._();

  /// 폰트 패밀리
  static const String fontFamily = 'LINE Seed JP App_TTF';

  /// Letter Spacing 계산 함수
  /// Figma: letter-spacing: -0.005em
  /// Flutter: fontSize * -0.005
  static double letterSpacing(double fontSize) => fontSize * -0.005;

  // ==================== 타이틀 스타일 ====================

  /// 메인 타이틀 (스케줄명, 할일명)
  /// font-weight: 800, font-size: 19px, line-height: 140%
  static TextStyle get mainTitle => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 19,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(19),
    color: WoltDesignTokens.primaryBlack,
  );

  /// 모달 타이틀 (변경/삭제 확인)
  /// font-weight: 800, font-size: 22px, line-height: 130%
  static TextStyle get modalTitle => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 22,
    height: 1.3, // 130%
    letterSpacing: letterSpacing(22),
    color: WoltDesignTokens.gray900,
  );

  // ==================== 서브 타이틀 ====================

  /// 서브 타이틀 (スケジュール, タスク, ルーティン)
  /// font-weight: 700, font-size: 16px, line-height: 140%
  static TextStyle get subTitle => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(16),
    color: WoltDesignTokens.gray800,
  );

  /// 라벨 텍스트 (開始, 終了, 締め切り)
  /// font-weight: 700, font-size: 16px, line-height: 140%
  static TextStyle get label => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(16),
    color: WoltDesignTokens.gray400,
  );

  // ==================== 본문 스타일 ====================

  /// 옵션 텍스트 (２日毎, 10分前, 終日)
  /// font-weight: 700, font-size: 13px, line-height: 140%
  static TextStyle get optionText => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 13,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(13),
    color: WoltDesignTokens.primaryBlack,
  );

  /// 설명 텍스트 (一回削除したものは、戻すことができません。)
  /// font-weight: 400, font-size: 13px, line-height: 140%
  static TextStyle get description => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(13),
    color: WoltDesignTokens.gray700,
  );

  // ==================== 플레이스홀더 ====================

  /// 일정/할일 제목 플레이스홀더 (予定を追加)
  /// font-weight: 700, font-size: 24px, line-height: 140%
  static TextStyle get schedulePlaceholder => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(24),
    color: WoltDesignTokens.gray500, // #AAAAAA
  );

  /// 플레이스홀더 (スケジュールを入力)
  /// font-weight: 700, font-size: 19px, line-height: 140%
  static TextStyle get placeholder => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 19,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(19),
    color: WoltDesignTokens.gray500,
  );

  // ==================== 일정/할일 제목 ====================

  /// 일정/할일 제목 입력 텍스트
  /// font-weight: 700, font-size: 24px, line-height: 140%
  static TextStyle get scheduleTitle => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(24),
    color: WoltDesignTokens.primaryBlack, // #111111
  );

  /// 할일 제목 입력 텍스트
  /// font-weight: 400, font-size: 22px, line-height: 150%
  static TextStyle get taskTitle => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 22,
    height: 1.5, // 150%
    letterSpacing: letterSpacing(22),
    color: WoltDesignTokens.primaryBlack, // #111111
  );

  /// 할일 제목 플레이스홀더 (やることをパッと入力)
  /// font-weight: 400, font-size: 22px, line-height: 150%
  static TextStyle get taskPlaceholder => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 22,
    height: 1.5, // 150%
    letterSpacing: letterSpacing(22),
    color: WoltDesignTokens.gray400, // #CCCCCC
  );

  // ==================== 대형 숫자 (날짜/시간) ====================

  /// 날짜 표시 (25. 7. 30)
  /// font-weight: 800, font-size: 19px, line-height: 120%
  /// text-shadow: 0px 4px 20px rgba(0, 0, 0, 0.1)
  static TextStyle get dateText => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 19,
    height: 1.2, // 120%
    letterSpacing: letterSpacing(19),
    color: WoltDesignTokens.primaryBlack,
    shadows: WoltDesignTokens.shadowDateTime,
  );

  /// 시간 표시 (15:30)
  /// font-weight: 800, font-size: 33px, line-height: 120%
  /// text-shadow: 0px 4px 20px rgba(0, 0, 0, 0.1)
  static TextStyle get timeText => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 33,
    height: 1.2, // 120%
    letterSpacing: letterSpacing(33),
    color: WoltDesignTokens.primaryBlack,
    shadows: WoltDesignTokens.shadowDateTime,
  );

  /// 대형 플레이스홀더 (10)
  /// font-weight: 800, font-size: 50px, line-height: 120%
  static TextStyle get largePlaceholder => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 50,
    height: 1.2, // 120%
    letterSpacing: letterSpacing(50),
    color: WoltDesignTokens.gray200,
  );

  // ==================== 버튼 텍스트 ====================

  /// CTA 버튼 텍스트 (移動する, 削除する)
  /// font-weight: 700, font-size: 15px, line-height: 140%
  static TextStyle get ctaButton => const TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 15,
    height: 1.4, // 140%
    letterSpacing: -0.075, // 15 * -0.005
    color: Colors.white,
  );

  /// 완료 버튼 텍스트 (完了)
  /// font-weight: 800, font-size: 13px, line-height: 140%
  static TextStyle get completeButton => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 13,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(13),
    color: WoltDesignTokens.gray100,
  );

  /// 삭제 버튼 텍스트 (削除)
  /// font-weight: 700, font-size: 13px, line-height: 140%
  static TextStyle get deleteButton => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 13,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(13),
    color: WoltDesignTokens.subRed,
  );

  // ==================== 상태별 변형 ====================

  /// 비활성 상태 (opacity: 0.3)
  static TextStyle inactive(TextStyle baseStyle) {
    return baseStyle.copyWith(color: baseStyle.color?.withOpacity(0.3));
  }

  /// 에러 상태 (color: red)
  static TextStyle error(TextStyle baseStyle) {
    return baseStyle.copyWith(color: WoltDesignTokens.subRed);
  }

  /// 성공 상태 (color: blue)
  static TextStyle success(TextStyle baseStyle) {
    return baseStyle.copyWith(color: WoltDesignTokens.primaryBlue);
  }

  // ==================== InputDecoration 프리셋 ====================

  /// 타이틀 입력 필드 스타일
  static InputDecoration get inputTitle => InputDecoration(
    hintText: 'スケジュールを入力',
    hintStyle: placeholder,
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 28),
    isDense: true,
  );

  /// 멀티라인 입력 필드 스타일
  static InputDecoration get inputMultiline => InputDecoration(
    hintText: '詳細を入力',
    hintStyle: placeholder,
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    isDense: false,
  );

  // ==================== DateDetailView 타이포그래피 (Figma) ====================

  /// 날짜 큰 숫자 (11)
  /// font-weight: 800, font-size: 48px, line-height: 120%
  static TextStyle get dateNumberLarge => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 48,
    height: 1.2, // 120%
    letterSpacing: letterSpacing(48),
    color: WoltDesignTokens.primaryBlack, // #111111
  );

  /// 월 표시 (8月) - 빨강 강조
  /// font-weight: 700, font-size: 15px, line-height: 120%
  static TextStyle get monthText => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 15,
    height: 1.2, // 120%
    letterSpacing: letterSpacing(15),
    color: WoltDesignTokens.accentRed, // #FF4444
  );

  /// 요일 표시 (金曜日) - 회색
  /// font-weight: 700, font-size: 15px, line-height: 120%
  static TextStyle get dayOfWeekText => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 15,
    height: 1.2, // 120%
    letterSpacing: letterSpacing(15),
    color: WoltDesignTokens.dayOfWeekGray, // #999999
  );

  /// "今日" 뱃지
  /// font-weight: 700, font-size: 13px, line-height: 140%
  static TextStyle get todayBadge => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 13,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(13),
    color: WoltDesignTokens.primaryBlack, // #222222
  );

  /// 일정/할일/습관 제목 (スケジュール名, タスク名, ルーティン名)
  /// font-weight: 800, font-size: 16px, line-height: 140%
  static TextStyle get cardTitle => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 16,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(16),
    color: WoltDesignTokens.primaryBlack, // #111111
  );

  /// 일정/할일/습관 제목 - 완료 상태 (취소선)
  /// font-weight: 800, font-size: 16px, line-height: 140%
  static TextStyle get cardTitleCompleted => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 16,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(16),
    color: WoltDesignTokens.primaryBlack, // #111111
    decoration: TextDecoration.lineThrough, // 취소선
    decorationColor: WoltDesignTokens.primaryBlack,
  );

  /// 시간 표시 (17時 - 18時)
  /// font-weight: 700, font-size: 13px, line-height: 140%
  static TextStyle get cardTime => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 13,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(13),
    color: WoltDesignTokens.gray900, // #262626
  );

  /// 메타 정보 (10分前, 月火水木)
  /// font-weight: 400, font-size: 11px, line-height: 140%
  static TextStyle get cardMeta => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(11),
    color: WoltDesignTokens.gray800, // #505050
  );

  /// 완료 섹션 텍스트 (完了)
  /// font-weight: 800, font-size: 13px, line-height: 140%
  static TextStyle get completedSectionText => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 13,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(13),
    color: WoltDesignTokens.primaryBlack, // #111111
  );

  /// 설정 제목 (設定)
  /// font-weight: 800, font-size: 26px, line-height: 140%
  static TextStyle get settingsTitle => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 26,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(26),
    color: WoltDesignTokens.primaryBlack, // #111111
  );

  /// 설정 항목 제목 (時間ガイド表示)
  /// font-weight: 700, font-size: 16px, line-height: 140%
  static TextStyle get settingsItemTitle => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.4, // 140%
    letterSpacing: letterSpacing(16),
    color: WoltDesignTokens.primaryBlack, // #111111
  );

  /// 설정 항목 설명
  /// font-weight: 400, font-size: 11px, line-height: 140%
  static TextStyle get settingsItemDescription => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 1.4, // 140%
    color: WoltDesignTokens.gray500, // #AAAAAA
  );
}
