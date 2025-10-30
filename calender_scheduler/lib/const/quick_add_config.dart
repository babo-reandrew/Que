import 'package:flutter/material.dart';
import '../utils/spring_curve.dart';

// ========================================
// ✅ Quick Add 타입 정의 (클래스 외부로 이동)
// ========================================

/// Quick Add 타입 열거형
enum QuickAddType {
  schedule, // 일정
  task, // 할일
  habit, // 습관
}

/// Quick Add 상태 열거형
enum QuickAddState {
  initial, // 기본 상태
  expanded, // 확장 상태 (일정/할일/습관 선택됨)
  colorPicker, // 색상 선택 모달
  dateTimePicker, // 일정 선택 모달
}

/// Quick_Add 시스템 관련 상수 정의
/// 이거를 설정하고 → 피그마 디자인의 모든 수치를 상수로 정의해서
/// 이거를 해서 → 코드 전체에서 일관된 값을 사용하고
/// 이거는 이래서 → 디자인 변경 시 한 곳만 수정하면 전체에 반영된다
/// 이거라면 → 유지보수가 쉽고 일관성이 보장된다
class QuickAddConfig {
  // ========================================
  // 색상 (피그마 기반)
  // ========================================

  /// Quick_Add_ControlBox 배경색 (피그마: #ffffff)
  static const Color controlBoxBackground = Color(0xFFFFFFFF);

  /// Quick_Add_ControlBox 테두리 색상 (피그마: #111111, opacity 8%)
  static const Color controlBoxBorder = Color(0x14111111);

  /// Modal 배경색 (피그마: #fcfcfc)
  static const Color modalBackground = Color(0xFFFCFCFC);

  /// Modal 테두리 색상 (피그마: #111111, opacity 10%)
  static const Color modalBorder = Color(0x1A111111);

  /// 추가 버튼 활성화 색상 (피그마: #111111)
  static const Color buttonActive = Color(0xFF111111);

  /// 추가 버튼 비활성화 색상 (피그마: #dddddd)
  static const Color buttonInactive = Color(0xFFDDDDDD);

  /// 플레이스홀더 텍스트 색상 (피그마: #7a7a7a)
  static const Color placeholderText = Color(0xFF7A7A7A);

  /// 일반 텍스트 색상 (피그마: #262626)
  static const Color normalText = Color(0xFF262626);

  /// 제목 텍스트 색상 (피그마: #111111)
  static const Color titleText = Color(0xFF111111);

  /// 보조 텍스트 색상 (피그마: #505050)
  static const Color subText = Color(0xFF505050);

  /// Wheel Picker 선택 배경 (피그마: #cfcfcf, opacity 30%)
  static const Color wheelPickerSelected = Color(0x4DCFCFCF);

  /// 삭제 버튼 색상 (피그마: #f74a4a)
  static const Color deleteButtonColor = Color(0xFFF74A4A);

  // ========================================
  // 크기 (피그마 기반)
  // ========================================

  /// Quick_Add_ControlBox 기본 높이 (상단 24px + TextField + 버튼 영역)
  static const double controlBoxInitialHeight = 140.0;

  /// Quick_Add_ControlBox 확장 높이 - 일정 모드 (상단 24px + TextField + 옵션 버튼)
  static const double controlBoxScheduleHeight = 140.0;

  /// Quick_Add_ControlBox 확장 높이 - 할일 모드 (상단 24px + TextField + 옵션 버튼)
  static const double controlBoxTaskHeight = 140.0;

  /// 색상 선택 모달 높이 (피그마: 414px)
  static const double colorPickerModalHeight = 414.0;

  /// 일정 선택 모달 높이 (피그마: 508px)
  static const double dateTimePickerModalHeight = 508.0;

  /// 습관 바텀시트 높이 (피그마: 553px)
  static const double habitPopupHeight = 553.0;

  /// Quick_Add_ControlBox 너비 (피그마: 365px)
  static const double controlBoxWidth = 365.0;

  /// Modal 너비 (피그마: 364px)
  static const double modalWidth = 364.0;

  /// TopNavi 높이 (피그마: 54px)
  static const double topNaviHeight = 54.0;

  /// TopNavi 높이 (모달용) (피그마: 60px)
  static const double topNaviModalHeight = 60.0;

  /// CTA 버튼 높이 (피그마: 56px)
  static const double ctaButtonHeight = 56.0;

  /// QuickDetail 버튼 크기 (피그마: 40×40px)
  static const double quickDetailSize = 40.0;

  /// DirectAddButton 크기 (피그마: 40×40px)
  static const double directAddButtonSize = 40.0;

  /// DetailOption 버튼 크기 (피그마: 64×64px)
  static const double detailOptionSize = 64.0;

  /// 색상 미리보기 크기 (피그마: 100×100px)
  static const double colorPreviewSize = 100.0;

  /// 색상 선택 원형 크기 (피그마: 32×32px)
  static const double colorCircleSize = 32.0;

  /// Wheel Picker 크기 (피그마: 253×105px)
  static const double wheelPickerWidth = 253.0;
  static const double wheelPickerHeight = 105.0;

  /// Wheel Picker 선택 영역 높이 (피그마: 36px)
  static const double wheelPickerRowHeight = 36.0;

  // ========================================
  // Border Radius (피그마 기반)
  // ========================================

  /// Quick_Add_ControlBox radius (피그마: 28px)
  static const double controlBoxRadius = 28.0;

  /// Modal radius (피그마: 36px)
  static const double modalRadius = 36.0;

  /// DirectAddButton radius (피그마: 16px)
  static const double directAddButtonRadius = 16.0;

  /// DetailOption radius (피그마: 24px)
  static const double detailOptionRadius = 24.0;

  /// 타입 선택 박스 radius (피그마: 34px)
  static const double typeSelectorRadius = 34.0;

  /// Wheel Picker 선택 영역 radius (피그마: 8px)
  static const double wheelPickerRowRadius = 8.0;

  /// 삭제 버튼 radius (피그마: 16px)
  static const double deleteButtonRadius = 16.0;

  // ========================================
  // 애니메이션 (iOS 네이티브 스타일)
  // ========================================

  /// Quick_Add → Modal 전환 애니메이션 시간
  static const Duration morphingDuration = Duration(milliseconds: 450);

  /// 키보드와 동기화된 슬라이드 업 시간
  static const Duration slideUpDuration = Duration(milliseconds: 300);

  /// 높이 확장 애니메이션 시간 (Apple 스프링 애니메이션)
  static const Duration heightExpandDuration = Duration(milliseconds: 600);

  /// Morphing 애니메이션 Curve (Spring-Based)
  static const Curve morphingCurve = AppleSpringCurves.smooth;

  /// 슬라이드 업 Curve
  static const Curve slideUpCurve = Curves.easeOutCubic;

  /// 높이 확장 Curve (Apple 스프링 애니메이션)
  static const Curve heightExpandCurve = AppleSpringCurves.smooth;

  // ========================================
  // 패딩 및 마진 (피그마 기반)
  // ========================================

  /// Quick_Add_ControlBox 좌우 마진 (피그마: 14px)
  static const double controlBoxHorizontalMargin = 14.0;

  /// Modal TopNavi 좌측 패딩 (피그마: 28px)
  static const double modalTopNaviLeftPadding = 28.0;

  /// Modal TopNavi 우측 패딩 (피그마: 28px)
  static const double modalTopNaviRightPadding = 28.0;

  /// QuickDetail 버튼 간격 (피그마: 6px)
  static const double quickDetailSpacing = 6.0;

  /// 색상 원형 간격 (피그마: 16px)
  static const double colorCircleSpacing = 16.0;

  /// DetailOption 간격 (피그마: 8px)
  static const double detailOptionSpacing = 8.0;

  // ========================================
  // 텍스트 스타일 (피그마 기반)
  // ========================================

  /// 플레이스홀더 스타일 (Bold 16px, #7a7a7a)
  static const TextStyle placeholderStyle = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: placeholderText,
    letterSpacing: -0.08,
    height: 1.4,
  );

  /// TopNavi 제목 스타일 (Bold 19px, #111111)
  static const TextStyle topNaviTitleStyle = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: titleText,
    letterSpacing: -0.095,
    height: 1.4,
  );

  /// CTA 버튼 텍스트 스타일 (Bold 15px, #fafafa)
  static const TextStyle ctaButtonStyle = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Color(0xFFFAFAFA),
    letterSpacing: -0.075,
    height: 1.4,
  );

  /// QuickDetail 텍스트 스타일 (Bold 14px, #7a7a7a)
  static const TextStyle quickDetailStyle = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: placeholderText,
    letterSpacing: -0.07,
    height: 1.4,
  );

  /// Wheel Picker 선택 텍스트 (Bold 19px, #111111)
  static const TextStyle wheelPickerSelectedStyle = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: titleText,
    letterSpacing: -0.095,
    height: 1.4,
  );

  /// Wheel Picker 비선택 텍스트 (Regular 19px, #000000 opacity 30%)
  static const TextStyle wheelPickerUnselectedStyle = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontSize: 19,
    fontWeight: FontWeight.w400,
    color: Color(0x4D000000),
    letterSpacing: -0.095,
    height: 1.4,
  );

  /// 삭제 버튼 텍스트 (Bold 13px, #f74a4a)
  static const TextStyle deleteButtonStyle = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: deleteButtonColor,
    letterSpacing: -0.065,
    height: 1.4,
  );

  // ========================================
  // 색상 팔레트 (피그마 기반)
  // ========================================

  /// 색상 선택 모달의 5가지 색상 (피그마 순서대로)
  static const List<Color> modalColorPalette = [
    Color(0xFFD22D2D), // 빨강
    Color(0xFFF57C00), // 주황
    Color(0xFF1976D2), // 파랑
    Color(0xFFF7BD11), // 노랑
    Color(0xFF54C8A1), // 초록
  ];

  /// 색상 ID 매핑 (기존 시스템과 호환)
  /// 이거를 설정하고 → Color 객체를 문자열 ID로 매핑해서
  /// 이거를 해서 → DB 저장 시 문자열로 변환한다
  static final Map<Color, String> colorToIdMap = {
    Color(0xFFD22D2D): 'red',
    Color(0xFFF57C00): 'orange',
    Color(0xFF1976D2): 'blue',
    Color(0xFFF7BD11): 'yellow',
    Color(0xFF54C8A1): 'green',
  };

  // ========================================
  // 플레이스홀더 텍스트 (Figma 기반)
  // ========================================

  /// 기본 플레이스홀더 (Figma: "なんでも入力できます")
  static const String placeholderDefault = 'なんでも入力できます';

  /// 일정 플레이스홀더 (Figma: "予定を追加")
  static const String placeholderSchedule = '予定を追加';

  /// 할일 플레이스홀더 (Figma: "やることをパッと入力")
  static const String placeholderTask = 'やることをパッと入力';

  /// 습관 플레이스홀더 (Figma: "新しいルーティンを記録")
  static const String placeholderHabit = '新しいルーティンを記録';

  // ========================================
  // QuickDetail 옵션 텍스트 (피그마 기반)
  // ========================================

  /// 일정: 시작-종료 (피그마: "開始-終了")
  static const String quickDetailScheduleTime = '開始-終了';

  /// 할일: 마감일 (피그마: "締め切り")
  static const String quickDetailTaskDeadline = '締め切り';

  // ========================================
  // Modal 제목 (피그마 기반)
  // ========================================

  /// 색상 선택 모달 제목 (피그마: "色")
  static const String modalTitleColor = '色';

  /// 일정 선택 모달 제목 (피그마: "日付")
  static const String modalTitleDateTime = '日付';

  /// 습관 바텀시트 제목 (피그마: "ルーティン")
  static const String modalTitleHabit = 'ルーティン';

  // ========================================
  // 버튼 텍스트 (피그마 기반)
  // ========================================

  /// 추가 버튼 (피그마: "追加")
  static const String buttonAdd = '追加';

  /// 완료 버튼 (피그마: "完了")
  static const String buttonComplete = '完了';

  /// 삭제 버튼 (피그마: "削除")
  static const String buttonDelete = '削除';
}
