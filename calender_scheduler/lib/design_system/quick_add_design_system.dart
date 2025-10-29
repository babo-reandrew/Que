import 'package:flutter/material.dart';

/// ========================================
/// 🎨 Quick Add Input Accessory View Design System
/// ========================================
///
/// Figma 디자인을 100% 재현하기 위한 완전한 디자인 시스템
///
/// 참고 Figma 링크:
/// - 기본 상태: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2318-8248
/// - 텍스트 입력 후: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2792-40499
/// - 추가 버튼 클릭 후: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2318-8249
/// - 할일 타입 선택: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2318-8250
/// - 일정 타입 선택: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2318-8251
/// - 백그라운드 블러: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2480-73456

// ========================================
// 🎨 색상 시스템 (Figma Color Tokens)
// ========================================

class QuickAddColors {
  // === Container Background ===
  /// Frame 701 배경색 (Figma: #FFFFFF)
  static const Color containerBackground = Color(0xFFFFFFFF);

  // === Borders ===
  /// Frame 701 테두리 (Figma: rgba(17, 17, 17, 0.08))
  static const Color containerBorder = Color(0x14111111);

  /// QuickAdd_ActionType 테두리 (Figma: rgba(17, 17, 17, 0.1))
  static const Color actionTypeBorder = Color(0x1A111111);

  /// Frame 688 테두리 (Figma: rgba(17, 17, 17, 0.08))
  static const Color detailPopupBorder = Color(0x14111111);

  // === Shadows ===
  /// Frame 701 그림자 (Figma: 0px 2px 8px rgba(186, 186, 186, 0.08))
  static const Color containerShadow = Color(0x14BABABA);

  /// QuickAdd_ActionType 그림자 (Figma: 0px 2px 8px rgba(186, 186, 186, 0.08))
  static const Color actionTypeShadow = Color(0x14BABABA);

  /// Frame 688 그림자 (Figma: 0px 4px 20px rgba(0, 0, 0, 0.06))
  static const Color detailPopupShadow = Color(0x0F000000);

  // === Text Colors ===
  /// 플레이스홀더 텍스트 (Figma: #7A7A7A)
  static const Color placeholderText = Color(0xFF7A7A7A);

  /// 입력된 텍스트 (Figma: #111111)
  static const Color inputText = Color(0xFF111111);

  /// 추가 버튼 텍스트 (Figma: #FAFAFA)
  static const Color addButtonText = Color(0xFFFAFAFA);

  /// 타입 선택 팝업 텍스트 (Figma: #262626)
  static const Color popupItemText = Color(0xFF262626);

  // === Button Colors ===
  /// 추가 버튼 활성화 배경 (Figma: #111111)
  static const Color addButtonActiveBackground = Color(0xFF111111);

  /// 추가 버튼 비활성화 배경 (Figma: #DDDDDD)
  static const Color addButtonInactiveBackground = Color(0x0ffddddd);

  // === Icon Colors ===
  /// 기본 아이콘 (Figma: rgba(186, 186, 186, 0.54))
  static const Color iconDefault = Color(0x8ABABABA);

  /// 선택된 아이콘 (Figma: #3B3B3B)
  static const Color iconSelected = Color(0xFF3B3B3B);

  /// 추가 버튼 아이콘 (Figma: #FAFAFA)
  static const Color iconAddButton = Color(0xFFFAFAFA);

  /// 세부 옵션 아이콘 (Figma: #7A7A7A)
  static const Color iconDetail = Color(0xFF7A7A7A);

  /// 우선순위 아이콘 (Figma: #656565)
  static const Color iconPriority = Color(0xFF656565);

  // === Background Blur (Gradient) ===
  /// 백그라운드 블러 그라데이션 시작 (Figma: rgba(255, 255, 255, 0))
  static const Color blurGradientStart = Color(0x00FFFFFF);

  /// 백그라운드 블러 그라데이션 끝 (Figma: rgba(240, 240, 240, 0.95))
  static const Color blurGradientEnd = Color(0xF2F0F0F0);
}

// ========================================
// 📏 크기 및 스페이싱 (Figma Dimensions)
// ========================================

class QuickAddDimensions {
  // === Container Sizes ===
  /// Input Accessory View 전체 너비 (Figma: 393px)
  static const double containerWidth = 393.0;

  /// Input Accessory View 기본 높이 (Figma: 192px)
  static const double containerHeight = 192.0;

  /// Frame 701 너비 (Figma: 365px)
  static const double frameWidth = 365.0;

  /// Frame 701 높이 (Figma: 132px)
  static const double frameHeight = 132.0;

  /// Frame 701 높이 - 타입 선택 팝업 표시 시 (Figma: 312px)
  static const double frameHeightWithPopup = 312.0;

  // === Text Input Area ===
  /// Quick_Add_TextArea 너비 (Figma: 365px)
  static const double textAreaWidth = 365.0;

  /// Quick_Add_TextArea 높이 (Figma: 22px)
  static const double textAreaHeight = 22.0;

  // === Add Button ===
  /// QuickAdd_AddButton 너비 (Figma: 86px)
  static const double addButtonWidth = 86.0;

  /// QuickAdd_AddButton 높이 (Figma: 44px)
  static const double addButtonHeight = 44.0;

  // === Action Type Selector ===
  /// QuickAdd_ActionType 너비 (Figma: 212px)
  static const double actionTypeWidth = 212.0;

  /// QuickAdd_ActionType 높이 (Figma: 52px)
  static const double actionTypeHeight = 52.0;

  /// 각 타입 버튼 크기 (Figma: 52x48px)
  static const double typeButtonWidth = 52.0;
  static const double typeButtonHeight = 48.0;

  // === Type Selection Popup ===
  /// Frame 653 너비 (Figma: 212px)
  static const double popupWidth = 212.0;

  /// Frame 653 높이 (Figma: 172px)
  static const double popupHeight = 172.0;

  /// 팝업 아이템 높이 (Figma: 48px)
  static const double popupItemHeight = 48.0;

  // === Detail Buttons (Task/Schedule) ===
  /// QuickDetail 버튼 높이 (Figma: 40px)
  static const double detailButtonHeight = 40.0;

  /// QuickAdd_DirectAddButton 크기 (Figma: 56x56px)
  static const double directAddButtonSize = 56.0;

  /// QuickAdd_DirectAddButton 내부 Frame 크기 (Figma: 40x40px)
  static const double directAddButtonInnerSize = 40.0;

  // === Background Blur ===
  /// 백그라운드 블러 높이 (Figma: 534px)
  static const double backgroundBlurHeight = 534.0;

  // === Icon Sizes ===
  /// 기본 아이콘 크기 (Figma: 24x24px)
  static const double iconSize = 24.0;
}

// ========================================
// 📐 패딩 및 마진 (Figma Spacing)
// ========================================

class QuickAddSpacing {
  // === Container Padding ===
  /// 전체 컨테이너 패딩 (Figma: padding: 0px 14px, gap: 8px)
  static const EdgeInsets containerPadding = EdgeInsets.symmetric(
    horizontal: 14.0,
  );
  static const double containerGap = 8.0;

  // === Frame 701 ===
  /// Frame 700 패딩 (Figma: padding: 30px 0px 0px)
  static const EdgeInsets frame700Padding = EdgeInsets.only(top: 30.0);

  // === Text Area ===
  /// Quick_Add_TextArea 패딩 (Figma: padding: 0px 26px)
  static const EdgeInsets textAreaPadding = EdgeInsets.symmetric(
    horizontal: 26.0,
  );

  // === Add Button Container (Frame 702) ===
  /// Frame 702 패딩 (Figma: padding: 18px)
  static const EdgeInsets addButtonContainerPadding = EdgeInsets.all(18.0);

  // === Add Button ===
  /// QuickAdd_AddButton 패딩 (Figma: padding: 10px 12px, gap: 4px)
  static const EdgeInsets addButtonPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 10.0,
  );
  static const double addButtonGap = 4.0;

  /// Frame 659 패딩 (Figma: padding: 0px 0px 0px 8px)
  static const EdgeInsets addButtonTextPadding = EdgeInsets.only(left: 8.0);

  // === Action Type Selector ===
  /// QuickAdd_ActionType 패딩 (Figma: padding: 2px 20px, gap: 8px)
  static const EdgeInsets actionTypePadding = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 2.0,
  );
  static const double actionTypeGap = 8.0;

  /// 각 타입 버튼 패딩 (Figma: padding: 12px 14px)
  static const EdgeInsets typeButtonPadding = EdgeInsets.symmetric(
    horizontal: 14.0,
    vertical: 12.0,
  );

  // === Type Selection Popup (Frame 653) ===
  /// Frame 653 패딩 (Figma: padding: 10px 12px 10px 10px, gap: 4px)
  static const EdgeInsets popupPadding = EdgeInsets.fromLTRB(
    10.0,
    10.0,
    12.0,
    10.0,
  );
  static const double popupGap = 4.0;

  /// 팝업 아이템 패딩 (Figma: padding: 12px 16px, gap: 12px)
  static const EdgeInsets popupItemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  static const double popupItemGap = 12.0;

  // === Detail Buttons (Task/Schedule) ===
  /// Frame 709 패딩 (Figma: padding: 0px 18px, gap: 6px)
  static const EdgeInsets detailButtonsContainerPadding = EdgeInsets.symmetric(
    horizontal: 18.0,
  );
  static const double detailButtonsGap = 6.0;

  /// QuickDetail 버튼 패딩 (Figma: padding: 8px, gap: 2px)
  static const EdgeInsets detailButtonPadding = EdgeInsets.all(8.0);
  static const double detailButtonGap = 2.0;

  /// QuickAdd_DirectAddButton 컨테이너 패딩 (Figma: padding: 12px 18px)
  static const EdgeInsets directAddButtonContainerPadding =
      EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0);

  /// QuickAdd_DirectAddButton 패딩 (Figma: padding: 8px)
  static const EdgeInsets directAddButtonPadding = EdgeInsets.all(8.0);

  // === Frame 704 (Type Selector Container) ===
  /// Frame 704 패딩 (Figma: padding: 0px 4px)
  static const EdgeInsets typeSelectorContainerPadding = EdgeInsets.symmetric(
    horizontal: 4.0,
  );
}

// ========================================
// 🔤 타이포그래피 (Figma Text Styles)
// ========================================

class QuickAddTextStyles {
  /// 플레이스홀더 텍스트 스타일
  /// Figma: LINE Seed JP App_TTF, Bold, 16px, line-height 140%, letter-spacing -0.005em, #7A7A7A
  static const TextStyle placeholder = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontWeight: FontWeight.w700,
    fontSize: 16.0,
    height: 1.4, // 140% line-height
    letterSpacing: -0.08, // -0.005em * 16px
    color: QuickAddColors.placeholderText,
  );

  /// 입력된 텍스트 스타일
  /// Figma: LINE Seed JP App_TTF, Bold, 16px, line-height 140%, letter-spacing -0.005em, #111111
  static const TextStyle inputText = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontWeight: FontWeight.w700,
    fontSize: 16.0,
    height: 1.4,
    letterSpacing: -0.08,
    color: QuickAddColors.inputText,
  );

  /// 추가 버튼 텍스트 스타일 (追加)
  /// Figma: LINE Seed JP App_TTF, Bold, 13px, line-height 140%, letter-spacing -0.005em, #FAFAFA
  static const TextStyle addButton = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontWeight: FontWeight.w700,
    fontSize: 13.0,
    height: 1.4,
    letterSpacing: -0.065, // -0.005em * 13px
    color: QuickAddColors.addButtonText,
  );

  /// 타입 선택 팝업 아이템 텍스트 스타일
  /// Figma: LINE Seed JP App_TTF, Bold, 14px, line-height 140%, letter-spacing -0.005em, #262626
  static const TextStyle popupItem = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontWeight: FontWeight.w700,
    fontSize: 14.0,
    height: 1.4,
    letterSpacing: -0.07, // -0.005em * 14px
    color: QuickAddColors.popupItemText,
  );

  /// 세부 옵션 텍스트 스타일 (締め切り, 開始-終了)
  /// Figma: LINE Seed JP App_TTF, Bold, 14px, line-height 140%, letter-spacing -0.005em, #7A7A7A
  static const TextStyle detailOption = TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontWeight: FontWeight.w700,
    fontSize: 14.0,
    height: 1.4,
    letterSpacing: -0.07,
    color: QuickAddColors.iconDetail,
  );
}

// ========================================
// 🎭 보더 반경 (Figma Border Radius)
// ========================================

class QuickAddBorderRadius {
  /// Frame 701 보더 반경 (Figma: 28px)
  static const double containerRadius = 28.0;

  /// QuickAdd_AddButton 보더 반경 (Figma: 16px)
  static const double addButtonRadius = 16.0;

  /// QuickAdd_ActionType 보더 반경 (Figma: 34px)
  static const double actionTypeRadius = 34.0;

  /// Frame 688 보더 반경 (Figma: 100px - 완전한 pill 형태)
  static const double actionTypeSelectedRadius = 100.0;

  /// Frame 653 보더 반경 (Figma: 24px)
  static const double popupRadius = 24.0;

  /// QuickAdd_DirectAddButton 내부 Frame 보더 반경 (Figma: 16px)
  static const double directAddButtonRadius = 16.0;

  /// Frame 688 (타입 선택됨) 보더 반경 (Figma: 18px)
  static const double typeSelectedContainerRadius = 18.0;
}

// ========================================
// 🎨 그림자 스타일 (Figma Box Shadows)
// ========================================

class QuickAddShadows {
  /// Frame 701 그림자
  /// Figma: 0px 2px 8px rgba(186, 186, 186, 0.08)
  static const List<BoxShadow> containerShadow = [
    BoxShadow(
      color: QuickAddColors.containerShadow,
      offset: Offset(0, 2),
      blurRadius: 8.0,
      spreadRadius: 0,
    ),
  ];

  /// QuickAdd_ActionType 그림자
  /// Figma: 0px 2px 8px rgba(186, 186, 186, 0.08)
  static const List<BoxShadow> actionTypeShadow = [
    BoxShadow(
      color: QuickAddColors.actionTypeShadow,
      offset: Offset(0, 2),
      blurRadius: 8.0,
      spreadRadius: 0,
    ),
  ];

  /// Frame 688 (타입 선택됨) 그림자
  /// Figma: 0px 4px 20px rgba(0, 0, 0, 0.06)
  static const List<BoxShadow> detailPopupShadow = [
    BoxShadow(
      color: QuickAddColors.detailPopupShadow,
      offset: Offset(0, 4),
      blurRadius: 20.0,
      spreadRadius: 0,
    ),
  ];

  /// Frame 653 (타입 선택 팝업) 그림자
  /// Figma: 0px 2px 8px rgba(186, 186, 186, 0.08)
  static const List<BoxShadow> typePopupShadow = [
    BoxShadow(
      color: QuickAddColors.containerShadow,
      offset: Offset(0, 2),
      blurRadius: 8.0,
      spreadRadius: 0,
    ),
  ];
}

// ========================================
// ⏱️ 애니메이션 설정 (Transition & Duration)
// ========================================

class QuickAddAnimations {
  /// 높이 확장/축소 애니메이션 지속 시간
  static const Duration heightExpandDuration = Duration(milliseconds: 350);

  /// 높이 확장/축소 애니메이션 커브
  static const Curve heightExpandCurve = Curves.easeInOutCubic;

  /// 타입 선택 팝업 표시/숨김 애니메이션 지속 시간
  static const Duration popupFadeDuration = Duration(milliseconds: 200);

  /// 타입 선택 팝업 애니메이션 커브
  static const Curve popupFadeCurve = Curves.easeOut;

  /// 추가 버튼 활성화/비활성화 애니메이션 지속 시간
  static const Duration buttonStateDuration = Duration(milliseconds: 150);

  /// 추가 버튼 애니메이션 커브
  static const Curve buttonStateCurve = Curves.easeInOut;

  /// 아이콘 상태 변경 애니메이션 지속 시간
  static const Duration iconStateDuration = Duration(milliseconds: 200);

  /// 아이콘 애니메이션 커브
  static const Curve iconStateCurve = Curves.easeInOut;
}

// ========================================
// 🎬 백그라운드 블러 (Figma: Rectangle 385)
// ========================================

class QuickAddBackgroundBlur {
  /// 백그라운드 블러 그라데이션
  /// Figma: linear-gradient(180deg, rgba(255, 255, 255, 0) 0%, rgba(240, 240, 240, 0.95) 50%)
  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5],
    colors: [QuickAddColors.blurGradientStart, QuickAddColors.blurGradientEnd],
  );

  /// 백드롭 필터 블러 강도 (Figma: backdrop-filter: blur(4px))
  static const double blurSigma = 4.0;
}

// ========================================
// 📍 레이아웃 포지션 (Figma Position)
// ========================================

class QuickAddPositions {
  // === Figma Frame Positions ===
  /// 기본 상태 위치 (Figma: left: 20px, top: 27px)
  static const Offset defaultPosition = Offset(20, 27);

  /// 텍스트 입력 후 위치 (Figma: left: 20px, top: 262px)
  static const Offset textInputPosition = Offset(20, 262);

  /// 추가 버튼 클릭 후 위치 (Figma: left: 440px, top: 27px)
  static const Offset addButtonClickedPosition = Offset(440, 27);

  /// 할일 타입 선택 위치 (Figma: left: 862px, top: 20px)
  static const Offset taskSelectedPosition = Offset(862, 20);

  /// 일정 타입 선택 위치 (Figma: left: 884px, top: 268px)
  static const Offset scheduleSelectedPosition = Offset(884, 268);
}

// ========================================
// 🧩 위젯 헬퍼 함수
// ========================================

class QuickAddWidgets {
  /// Frame 701 컨테이너 데코레이션
  static BoxDecoration get frame701Decoration => BoxDecoration(
    color: QuickAddColors.containerBackground,
    border: Border.all(color: QuickAddColors.containerBorder, width: 1.0),
    borderRadius: BorderRadius.circular(QuickAddBorderRadius.containerRadius),
    boxShadow: QuickAddShadows.containerShadow,
  );

  /// QuickAdd_ActionType 데코레이션
  static BoxDecoration get actionTypeDecoration => BoxDecoration(
    color: QuickAddColors.containerBackground,
    border: Border.all(color: QuickAddColors.actionTypeBorder, width: 1.0),
    borderRadius: BorderRadius.circular(QuickAddBorderRadius.actionTypeRadius),
    boxShadow: QuickAddShadows.actionTypeShadow,
  );

  /// 추가 버튼 활성화 데코레이션
  static BoxDecoration get addButtonActiveDecoration => BoxDecoration(
    color: QuickAddColors.addButtonActiveBackground,
    borderRadius: BorderRadius.circular(QuickAddBorderRadius.addButtonRadius),
  );

  /// 추가 버튼 비활성화 데코레이션
  static BoxDecoration get addButtonInactiveDecoration => BoxDecoration(
    color: QuickAddColors.addButtonInactiveBackground,
    borderRadius: BorderRadius.circular(QuickAddBorderRadius.addButtonRadius),
  );

  /// 타입 선택 팝업 (Frame 653) 데코레이션
  static BoxDecoration get typePopupDecoration => BoxDecoration(
    color: QuickAddColors.containerBackground,
    border: Border.all(color: QuickAddColors.detailPopupBorder, width: 1.0),
    borderRadius: BorderRadius.circular(QuickAddBorderRadius.popupRadius),
    boxShadow: QuickAddShadows.typePopupShadow,
  );

  /// 선택된 타입 컨테이너 (Frame 688) 데코레이션
  static BoxDecoration get selectedTypeDecoration => BoxDecoration(
    color: QuickAddColors.containerBackground,
    border: Border.all(color: QuickAddColors.actionTypeBorder, width: 1.0),
    borderRadius: BorderRadius.circular(
      QuickAddBorderRadius.actionTypeSelectedRadius,
    ),
    boxShadow: QuickAddShadows.detailPopupShadow,
  );

  /// Direct Add Button (Frame 699) 데코레이션
  static BoxDecoration get directAddButtonDecoration => BoxDecoration(
    color: QuickAddColors.addButtonActiveBackground,
    borderRadius: BorderRadius.circular(
      QuickAddBorderRadius.directAddButtonRadius,
    ),
  );
}

// ========================================
// 📝 상수 문자열 (Figma Text Content)
// ========================================

class QuickAddStrings {
  /// 플레이스홀더 텍스트 (Figma: なんでも入力できます)
  static const String placeholder = 'なんでも入力できます';

  /// 추가 버튼 텍스트 (Figma: 追加)
  static const String addButton = '追加';

  /// 일정 타입 텍스트 (Figma: 今日のスケジュール)
  static const String typeSchedule = '今日のスケジュール';

  /// 할일 타입 텍스트 (Figma: タスク)
  static const String typeTask = 'タスク';

  /// 습관 타입 텍스트 (Figma: ルーティン)
  static const String typeHabit = 'ルーティン';

  /// 마감일 텍스트 (Figma: 締め切り)
  static const String deadline = '締め切り';

  /// 시작-종료 텍스트 (Figma: 開始-終了)
  static const String startEnd = '開始-終了';
}
