/// 🎨 Wolt 디자인 시스템 토큰
///
/// Figma 디자인 분석 기반으로 생성된 통합 디자인 시스템
/// 모든 바텀시트와 모달에서 일관되게 사용됩니다.
///
/// 분석 출처: FIGMA_DESIGN_ANALYSIS.md
library;

import 'dart:ui';
import 'package:flutter/material.dart';

/// 디자인 토큰 클래스
class WoltDesignTokens {
  WoltDesignTokens._();

  // ==================== 컬러 팔레트 ====================

  /// 배경색
  static const Color backgroundColor = Color(0xFFFCFCFC);

  /// 메인 검정색 (텍스트, 테두리)
  static const Color primaryBlack = Color(0xFF111111);

  /// 회색 계열
  static const Color gray900 = Color(0xFF262626); // 버튼 배경
  static const Color gray800 = Color(0xFF505050); // 서브 타이틀
  static const Color gray700 = Color(0xFF656565); // 설명 텍스트
  static const Color gray600 = Color(0xFF7A7A7A); // 비활성 상태
  static const Color gray500 = Color(0xFFAAAAAA); // 플레이스홀더
  static const Color gray400 = Color(0xFFBBBBBB); // 라벨
  static const Color gray300 = Color(0xFFE4E4E4); // 토글 배경
  static const Color gray200 = Color(0xFFEEEEEE); // 비활성 숫자
  static const Color gray100 = Color(0xFFFAFAFA); // 흰색 버튼

  /// 액션 컬러
  static const Color primaryBlue = Color(0xFF0000FF); // 이동 버튼
  static const Color dangerRed = Color(0xFFFF0000); // 삭제 버튼 (진한)
  static const Color subRed = Color(0xFFF74A4A); // 삭제 아이콘 (연한)

  // ==================== DateDetailView 컬러 (Figma: Caldender_Basic_View_Date) ====================

  /// 날짜 헤더 강조색 (8月)
  static const Color accentRed = Color(0xFFFF4444); // #FF4444 - 월 표시

  /// 요일 회색
  static const Color dayOfWeekGray = Color(0xFF999999); // #999999 - 금曜日

  /// 완료 섹션 배경
  static const Color completedBackground = Color(0xFFE4E4E4); // #E4E4E4

  /// 카드 배경
  static const Color cardBackground = Color(0xFFFFFFFF); // #FFFFFF

  /// 구분선 색상
  static const Color dividerGray = Color(0xFFE6E6E6); // #E6E6E6 - solid
  static const Color dividerDashed = Color(0xFFE4E4E4); // #E4E4E4 - dashed

  /// 화면 배경색 (DateDetailView)
  static const Color screenBackground = Color(0xFFF7F7F7); // #F7F7F7

  // ==================== 투명도 컬러 ====================

  /// Border 투명도
  static Color get border10 => primaryBlack.withOpacity(0.1); // 10%
  static Color get border08 => primaryBlack.withOpacity(0.08); // 8%
  static Color get border06 => primaryBlack.withOpacity(0.06); // 6%
  static Color get border02 => primaryBlack.withOpacity(0.02); // 2%
  static Color get border01 => primaryBlack.withOpacity(0.01); // 1%

  /// Shadow 투명도
  static Color get shadow20 =>
      const Color(0xFFA5A5A5).withOpacity(0.2); // 메인 그림자
  static Color get shadow08Gray =>
      const Color(0xFFBABABA).withOpacity(0.08); // 버튼 그림자
  static Color get shadow02Black => Colors.black.withOpacity(0.02); // 서브 그림자
  static Color get shadow03Black => primaryBlack.withOpacity(0.03); // 삭제 버튼
  static Color get shadow04Black => Colors.black.withOpacity(0.04); // 닫기 버튼
  static Color get shadow10Black => Colors.black.withOpacity(0.1); // 텍스트 그림자

  /// Background 투명도
  static Color get modalClose => const Color(0xFFE4E4E4).withOpacity(0.9);

  // ==================== 반경 시스템 ====================

  /// Border Radius
  static const double radiusBottomSheet = 36.0; // 바텀시트 (상단만)
  static const double radiusModal = 36.0; // 모달 (전체)
  static const double radiusCTA = 24.0; // CTA 버튼
  static const double radiusDetailOption = 24.0; // DetailOption 버튼
  static const double radiusButton = 16.0; // 완료/삭제 버튼
  static const double radiusCircle = 100.0; // 원형 버튼/토글

  // ==================== DateDetailView Border Radius ====================

  /// 일정 카드 (Frame 665)
  static const double radiusScheduleCard = 24.0; // #24px

  /// 할일 카드 (Frame 671)
  static const double radiusTaskCard = 19.0; // #19px

  /// 습관 카드 (Frame 671)
  static const double radiusHabitCard = 24.0; // #24px

  /// 완료 섹션 (Complete_ActionData)
  static const double radiusCompletedSection = 16.0; // #16px

  /// 설정 버튼 (원형)
  static const double radiusSettingsButton = 100.0; // #100px

  // ==================== 간격 시스템 ====================

  /// Padding
  static const EdgeInsets paddingBottomSheetTop = EdgeInsets.only(
    top: 32,
  ); // 바텀시트 상단
  static const EdgeInsets paddingBottomSheetHorizontal = EdgeInsets.symmetric(
    horizontal: 0,
  ); // 바텀시트 좌우
  static const double paddingBottomSheetBottomDefault = 56.0; // 기본 하단
  static const double paddingBottomSheetBottomMedium = 66.0; // 중간 하단
  static const double paddingBottomSheetBottomLarge = 98.0; // 큰 하단
  static const double paddingBottomSheetBottomKeyboard = 210.0; // 키보드 올라올 때

  /// Gap
  static const double gap48 = 48.0; // Frame 778 (메인 컨텐츠)
  static const double gap36 = 36.0; // Frame 777 (폼 필드 그룹)
  static const double gap24 = 24.0; // Frame 776 (입력 영역)
  static const double gap20 = 20.0; // 텍스트 행간
  static const double gap12 = 12.0; // 주요 간격
  static const double gap10 = 10.0; // 서브 간격
  static const double gap8 = 8.0; // DetailOption 간격
  static const double gap6 = 6.0; // 버튼 내부 간격
  static const double gap2 = 2.0; // 텍스트 행간 (작은)

  // ==================== DateDetailView 간격 (Figma) ====================

  /// 상단 패딩 (Frame 838)
  static const double paddingTopDetailView = 172.0; // #172px

  /// 스크롤 컨텐츠 간격 (Frame 838)
  static const double gapScrollContent = 32.0; // #32px

  /// 일정 카드 사이 간격 (Frame 835)
  static const double gapScheduleCards = 4.0; // #4px

  /// 할일/습관 카드 사이 간격 (Frame 836)
  static const double gapTaskCards = 4.0; // #4px

  /// 일정/할일 구분선 여백 (Vector 88)
  static const EdgeInsets paddingDivider = EdgeInsets.symmetric(
    horizontal: 16.0,
  ); // #16px

  /// 날짜 헤더 내부 간격 (Frame 823)
  static const double gapDateHeader = 6.0; // #6px

  /// 날짜 숫자와 뱃지 간격 (Frame 829)
  static const double gapDateBadge = 4.0; // #4px

  // ==================== 크기 ====================

  /// TopNavi
  static const double topNaviHeight = 60.0;
  static const EdgeInsets topNaviPadding = EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 9,
  );

  /// 버튼
  static const Size sizeDetailOption = Size(64, 64); // DetailOption 버튼
  static const Size sizeCloseButton = Size(36, 36); // 닫기 버튼
  static const Size sizeDateTimeButton = Size(32, 32); // 날짜/시간 선택 버튼
  static const Size sizeCompleteButton = Size(74, 42); // 완료 버튼 (최소)
  static const Size sizeDeleteButton = Size(100, 52); // 삭제 버튼 (작은)

  /// 토글
  static const Size sizeToggleSwitch = Size(40, 24);
  static const double sizeToggleThumb = 16.0;

  /// 아이콘
  static const double iconSizeLarge = 24.0; // DetailOption, 날짜/시간
  static const double iconSizeMedium = 20.0; // 닫기, 삭제
  static const double iconSizeSmall = 19.0; // 종일, 마감일 라벨

  // ==================== 모달 크기 ====================

  /// 작은 모달
  static const double modalWidthSmall = 370.0;
  static const double modalHeightChange = 437.0; // 변경 확인
  static const double modalHeightMove = 438.0; // 이동 확인
  static const double modalHeightCancel = 299.0; // 취소 확인
  static const double modalHeightDelete = 438.0; // 삭제 확인
  static const double modalHeightCancelShort = 303.0; // 짧은 취소

  /// 바텀시트
  static const double bottomSheetWidth = 393.0;
  static const double bottomSheetHeightScheduleEmpty = 583.0;
  static const double bottomSheetHeightScheduleKeyboard = 773.0;
  static const double bottomSheetHeightTaskEmpty = 615.0;
  static const double bottomSheetHeightTaskKeyboard = 727.0;
  static const double bottomSheetHeightHabitEmpty = 409.0;
  static const double bottomSheetHeightHabitKeyboard = 553.0;
  static const double bottomSheetHeightSchedulePresent = 576.0;
  static const double bottomSheetHeightTaskPresent = 584.0;

  // ==================== BoxShadow 프리셋 ====================

  /// 메인 바텀시트 그림자
  static List<BoxShadow> get shadowBottomSheet => [
    BoxShadow(
      color: shadow20,
      offset: const Offset(0, 2),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  /// DetailOption 버튼 그림자
  static List<BoxShadow> get shadowDetailOption => [
    BoxShadow(color: shadow08Gray, offset: const Offset(0, 2), blurRadius: 8),
    BoxShadow(color: shadow02Black, offset: const Offset(0, 4), blurRadius: 20),
  ];

  /// 완료 버튼 그림자
  static List<BoxShadow> get shadowCompleteButton => [
    BoxShadow(color: shadow08Gray, offset: const Offset(0, -2), blurRadius: 8),
  ];

  /// 삭제 버튼 그림자
  static List<BoxShadow> get shadowDeleteButton => [
    BoxShadow(color: shadow03Black, offset: const Offset(0, 4), blurRadius: 20),
  ];

  /// 닫기 버튼 그림자
  static List<BoxShadow> get shadowCloseButton => [
    BoxShadow(color: shadow04Black, offset: const Offset(0, 4), blurRadius: 20),
  ];

  /// 날짜/시간 선택 버튼 그림자
  static List<BoxShadow> get shadowDateTimeButton => [
    BoxShadow(color: shadow08Gray, offset: const Offset(0, -2), blurRadius: 8),
  ];

  // ==================== 텍스트 그림자 ====================

  /// 날짜/시간 텍스트 그림자
  static List<Shadow> get shadowDateTime => [
    Shadow(color: shadow10Black, offset: const Offset(0, 4), blurRadius: 20),
  ];

  // ==================== Border 프리셋 ====================

  /// 메인 바텀시트 테두리
  static Border get borderBottomSheet => Border.all(color: border10, width: 1);

  /// DetailOption 버튼 테두리
  static Border get borderDetailOption => Border.all(color: border08, width: 1);

  /// CTA 버튼 테두리
  static Border get borderCTA => Border.all(color: border01, width: 1);

  /// 닫기 버튼 테두리
  static Border get borderCloseButton => Border.all(color: border02, width: 1);

  /// 날짜/시간 선택 버튼 테두리
  static Border get borderDateTimeButton =>
      Border.all(color: border06, width: 1);

  /// 삭제 버튼 테두리
  static Border get borderDeleteButton =>
      Border.all(color: const Color(0xFFBABABA).withOpacity(0.08), width: 1);

  // ==================== BoxDecoration 프리셋 ====================

  /// 메인 바텀시트 컨테이너
  static BoxDecoration get decorationBottomSheet => BoxDecoration(
    color: backgroundColor,
    border: borderBottomSheet,
    boxShadow: shadowBottomSheet,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(radiusBottomSheet),
      topRight: Radius.circular(radiusBottomSheet),
    ),
  );

  /// 작은 모달 컨테이너
  static BoxDecoration get decorationModal => BoxDecoration(
    color: backgroundColor,
    border: borderBottomSheet,
    boxShadow: shadowBottomSheet,
    borderRadius: BorderRadius.circular(radiusModal),
  );

  /// DetailOption 버튼
  static BoxDecoration get decorationDetailOption => BoxDecoration(
    color: Colors.white,
    border: borderDetailOption,
    boxShadow: shadowDetailOption,
    borderRadius: BorderRadius.circular(radiusDetailOption),
  );

  /// CTA 버튼 (Primary - Blue)
  static BoxDecoration get decorationCTAPrimary => BoxDecoration(
    color: primaryBlue,
    border: borderCTA,
    borderRadius: BorderRadius.circular(radiusCTA),
  );

  /// CTA 버튼 (Danger - Red)
  static BoxDecoration get decorationCTADanger => BoxDecoration(
    color: dangerRed,
    border: borderCTA,
    borderRadius: BorderRadius.circular(radiusCTA),
  );

  /// 완료 버튼
  static BoxDecoration get decorationCompleteButton => BoxDecoration(
    color: primaryBlack,
    boxShadow: shadowCompleteButton,
    borderRadius: BorderRadius.circular(radiusButton),
  );

  /// 삭제 버튼 (작은)
  static BoxDecoration get decorationDeleteButton => BoxDecoration(
    color: gray100,
    border: borderDeleteButton,
    boxShadow: shadowDeleteButton,
    borderRadius: BorderRadius.circular(radiusButton),
  );

  /// 닫기 버튼
  static BoxDecoration get decorationCloseButton => BoxDecoration(
    color: modalClose,
    border: borderCloseButton,
    boxShadow: shadowCloseButton,
    borderRadius: BorderRadius.circular(radiusCircle),
  );

  /// 날짜/시간 선택 버튼
  static BoxDecoration get decorationDateTimeButton => BoxDecoration(
    color: gray900,
    border: borderDateTimeButton,
    boxShadow: shadowDateTimeButton,
    borderRadius: BorderRadius.circular(radiusCircle),
  );

  // ==================== 토글 스위치 ====================

  /// 토글 OFF 배경
  static BoxDecoration get decorationToggleOff => BoxDecoration(
    color: gray300,
    border: Border.all(color: gray300, width: 1),
    borderRadius: BorderRadius.circular(radiusCircle),
  );

  // ==================== DateDetailView BoxDecoration 프리셋 ====================

  /// 일정 카드 (Figma: Block)
  /// 이거를 설정하고 → 흰색 배경에 그림자와 테두리를 추가해서
  /// 이거를 해서 → Figma 디자인과 동일한 카드 스타일을 만든다
  static BoxDecoration get decorationScheduleCard => BoxDecoration(
    color: cardBackground,
    border: Border.all(color: border08, width: 1),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFBABABA).withOpacity(0.08),
        offset: const Offset(0, -2),
        blurRadius: 8,
      ),
    ],
    borderRadius: BorderRadius.circular(radiusScheduleCard),
  );

  /// 할일 카드 (Figma: Frame 671 - Task)
  /// 이거를 설정하고 → 작은 radius로 할일 카드 스타일을 만든다
  static BoxDecoration get decorationTaskCard => BoxDecoration(
    color: cardBackground,
    border: Border.all(color: border08, width: 1),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFBABABA).withOpacity(0.08),
        offset: const Offset(0, -2),
        blurRadius: 8,
      ),
    ],
    borderRadius: BorderRadius.circular(radiusTaskCard),
  );

  /// 습관 카드 (Figma: Frame 671 - Habit)
  /// 이거를 설정하고 → 일정과 같은 radius로 습관 카드 스타일을 만든다
  static BoxDecoration get decorationHabitCard => BoxDecoration(
    color: cardBackground,
    border: Border.all(color: border08, width: 1),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFBABABA).withOpacity(0.08),
        offset: const Offset(0, -2),
        blurRadius: 8,
      ),
    ],
    borderRadius: BorderRadius.circular(radiusHabitCard),
  );

  /// 완료 섹션 (Figma: Complete_ActionData)
  /// 이거를 설정하고 → 회색 배경으로 완료된 항목을 구분한다
  static BoxDecoration get decorationCompletedSection => BoxDecoration(
    color: completedBackground,
    border: Border.all(color: border08, width: 1),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFBABABA).withOpacity(0.08),
        offset: const Offset(0, -2),
        blurRadius: 8,
      ),
    ],
    borderRadius: BorderRadius.circular(radiusCompletedSection),
  );

  /// 설정 버튼 (Figma: Frame 892)
  /// 이거를 설정하고 → 원형 배경에 테두리를 추가한다
  static BoxDecoration get decorationSettingsButton => BoxDecoration(
    color: gray100, // #FAFAFA
    border: Border.all(color: primaryBlack.withOpacity(0.05), width: 1),
    borderRadius: BorderRadius.circular(radiusSettingsButton),
  );

  // ==================== 점선 Border (Dashed Line) ====================

  /// 점선 구분선 페인터 생성 함수
  /// 이거를 설정하고 → CustomPainter로 dashed line을 그린다
  /// 이거를 해서 → Figma의 Vector 88 스타일을 재현한다
  static Paint get dashedLinePaint => Paint()
    ..color = dividerDashed
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;
}
