import 'package:flutter/material.dart';

/// 🎨 InputAccessoryView 디자인 시스템
///
/// Figma 스펙:
/// - Property 1=Anything: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/졸업작품?node-id=2318-8248
/// - Property 1=Variant5: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/졸업작품?node-id=2792-40499
/// - Property 1=Touched_Anything: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/졸업작품?node-id=2318-8249
/// - Property 1=Task: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/졸업작품?node-id=2318-8250
/// - Property 1=Schedule: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/졸업작품?node-id=2318-8251
/// - Background Blur: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/졸업작품?node-id=2480-73456
///
/// 이거를 설정하고 → 모든 Figma CSS/iOS 스펙을 토큰화해서
/// 이거를 해서 → 일관된 디자인 시스템을 구축하고
/// 이거는 이래서 → 어디서든 접근 가능한 중앙화된 관리가 가능하다
class InputAccessoryDesign {
  // ========================================
  // 🎨 색상 시스템
  // ========================================

  /// Frame 701 배경색 (Figma: #FFFFFF)
  static const Color containerBackground = Color(0xFFFFFFFF);

  /// Frame 701 테두리 (Figma: rgba(17, 17, 17, 0.08))
  static const Color containerBorder = Color(0x14111111);

  /// 추가 버튼 활성화 배경 (Figma: #111111)
  static const Color addButtonActiveBackground = Color(0xFF111111);

  /// 추가 버튼 비활성화 배경 (Figma: #DDDDDD)
  static const Color addButtonInactiveBackground = Color(0xFFDDDDDD);

  /// 추가 버튼 텍스트/아이콘 (Figma: #FAFAFA)
  static const Color addButtonText = Color(0xFFFAFAFA);

  /// 비활성 아이콘/텍스트 (Figma: #AAAAAA)
  static const Color inactiveIcon = Color(0xFFAAAAAA);

  /// Placeholder 텍스트 (Figma: #7A7A7A)
  static const Color placeholderText = Color(0xFF7A7A7A);

  /// 입력된 텍스트 (Figma: #111111)
  static const Color inputText = Color(0xFF111111);

  /// 타입 선택기 배경 (Figma: #FFFFFF)
  static const Color typeSelectorBackground = Color(0xFFFFFFFF);

  /// 타입 선택기 테두리 (Figma: rgba(17, 17, 17, 0.1))
  static const Color typeSelectorBorder = Color(0x1A111111);

  /// 비활성 아이콘 (Figma: rgba(186, 186, 186, 0.54))
  static const Color iconInactive = Color(0x8ABABABA);

  /// 활성 아이콘 (Figma: #3B3B3B)
  static const Color iconActive = Color(0xFF3B3B3B);

  /// Frame 705 배경 (Figma: #FFFFFF)
  static const Color popupBackground = Color(0xFFFFFFFF);

  /// Frame 705 텍스트 (Figma: #262626)
  static const Color popupText = Color(0xFF262626);

  /// QuickDetail 텍스트 (Figma: #7A7A7A)
  static const Color detailOptionText = Color(0xFF7A7A7A);

  /// QuickDetail 아이콘 (Figma: #656565)
  static const Color detailOptionIcon = Color(0xFF656565);

  // ========================================
  // 📐 크기 시스템
  // ========================================

  /// 전체 컨테이너 너비 (Figma: 393px)
  static const double containerWidth = 393.0;

  /// 전체 컨테이너 높이 - 기본 (Figma: 192px)
  static const double containerHeightDefault = 192.0;

  /// 전체 컨테이너 높이 - 타입 선택 팝업 (Figma: 312px)
  static const double containerHeightWithPopup = 312.0;

  /// Frame 701 너비 (Figma: 365px)
  static const double frame701Width = 365.0;

  /// Frame 701 높이 - 기본 (Figma: 132px)
  static const double frame701HeightDefault = 132.0;

  /// Frame 701 높이 - 일정 선택 시 (Figma: 132px - 변화 없음)
  static const double frame701HeightSchedule = 132.0;

  /// Frame 701 높이 - 할일 선택 시 (Figma: 132px - 변화 없음)
  static const double frame701HeightTask = 132.0;

  /// Frame 700 높이 (Figma: 52px)
  static const double frame700Height = 52.0;

  /// Quick_Add_TextArea 높이 (Figma: 22px)
  static const double textAreaHeight = 22.0;

  /// Frame 702 너비 (Figma: 122px)
  static const double frame702Width = 122.0;

  /// Frame 702 높이 (Figma: 80px)
  static const double frame702Height = 80.0;

  /// 추가 버튼 너비 - 기본 (Figma: 86px)
  static const double addButtonWidthDefault = 86.0;

  /// 추가 버튼 높이 - 기본 (Figma: 44px)
  static const double addButtonHeightDefault = 44.0;

  /// DirectAddButton 크기 (Figma: 56×56px)
  static const double directAddButtonSize = 56.0;

  /// DirectAddButton 내부 Frame 크기 (Figma: 40×40px)
  static const double directAddButtonInnerSize = 40.0;

  /// 아이콘 크기 (Figma: 24×24px)
  static const double iconSize = 24.0;

  /// Frame 704 너비 (Figma: 220px)
  static const double frame704Width = 220.0;

  /// Frame 704 높이 (Figma: 52px)
  static const double frame704Height = 52.0;

  /// QuickAdd_ActionType 너비 (Figma: 212px)
  static const double actionTypeWidth = 212.0;

  /// QuickAdd_ActionType 높이 (Figma: 52px)
  static const double actionTypeHeight = 52.0;

  /// 타입 아이콘 버튼 크기 (Figma: 52×48px)
  static const double typeIconWidth = 52.0;
  static const double typeIconHeight = 48.0;

  /// Frame 705 너비 (Figma: 220px)
  static const double frame705Width = 220.0;

  /// Frame 705 높이 (Figma: 172px)
  static const double frame705Height = 172.0;

  /// Frame 653 너비 (Figma: 212px)
  static const double frame653Width = 212.0;

  /// Frame 653 높이 (Figma: 172px)
  static const double frame653Height = 172.0;

  /// Frame 650/651/652 너비 (Figma: 190px)
  static const double popupItemWidth = 190.0;

  /// Frame 650/651/652 높이 (Figma: 48px)
  static const double popupItemHeight = 48.0;

  /// Frame 711 높이 (Figma: 80px)
  static const double frame711Height = 80.0;

  /// Frame 709 너비 - 할일 (Figma: 226px)
  static const double frame709WidthTask = 226.0;

  /// Frame 709 너비 - 일정 (Figma: 233px)
  static const double frame709WidthSchedule = 233.0;

  /// Frame 709 높이 (Figma: 40px)
  static const double frame709Height = 40.0;

  /// QuickDetail 버튼 크기 (Figma: 40×40px)
  static const double quickDetailButtonSize = 40.0;

  // ========================================
  // 📏 스페이싱 시스템
  // ========================================

  /// 전체 컨테이너 패딩 (Figma: 0px 14px, gap: 8px)
  static const EdgeInsets containerPadding = EdgeInsets.symmetric(
    horizontal: 14.0,
  );
  static const double containerGap = 8.0;

  /// Frame 700 패딩 (Figma: 30px 0px 0px)
  static const EdgeInsets frame700Padding = EdgeInsets.only(top: 30.0);

  /// Quick_Add_TextArea 패딩 (Figma: 0px 26px)
  static const EdgeInsets textAreaPadding = EdgeInsets.symmetric(
    horizontal: 26.0,
  );

  /// Frame 702 패딩 (Figma: 18px)
  static const EdgeInsets frame702Padding = EdgeInsets.all(18.0);

  /// 추가 버튼 패딩 (Figma: 10px 12px, gap: 4px)
  static const EdgeInsets addButtonPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 10.0,
  );
  static const double addButtonGap = 4.0;

  /// Frame 659 패딩 (Figma: 0px 0px 0px 8px)
  static const EdgeInsets frame659Padding = EdgeInsets.only(left: 8.0);

  /// DirectAddButton 패딩 (Figma: 8px)
  static const EdgeInsets directAddButtonPadding = EdgeInsets.all(8.0);

  /// Frame 704 패딩 (Figma: 0px 4px)
  static const EdgeInsets frame704Padding = EdgeInsets.symmetric(
    horizontal: 4.0,
  );

  /// QuickAdd_ActionType 패딩 (Figma: 2px 20px, gap: 8px)
  static const EdgeInsets actionTypePadding = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 2.0,
  );
  static const double actionTypeGap = 8.0;

  /// 타입 아이콘 버튼 패딩 (Figma: 12px 14px)
  static const EdgeInsets typeIconPadding = EdgeInsets.symmetric(
    horizontal: 14.0,
    vertical: 12.0,
  );

  /// Frame 653 패딩 (Figma: 10px 12px 10px 10px, gap: 4px)
  static const EdgeInsets frame653Padding = EdgeInsets.fromLTRB(
    10.0,
    10.0,
    12.0,
    10.0,
  );
  static const double frame653Gap = 4.0;

  /// Frame 650/651/652 패딩 (Figma: 12px 16px, gap: 12px)
  static const EdgeInsets popupItemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  static const double popupItemGap = 12.0;

  /// Frame 709 패딩 (Figma: 0px 18px, gap: 6px)
  static const EdgeInsets frame709Padding = EdgeInsets.symmetric(
    horizontal: 18.0,
  );
  static const double frame709Gap = 6.0;

  /// QuickDetail 버튼 패딩 (Figma: 8px, gap: 2px)
  static const EdgeInsets quickDetailPadding = EdgeInsets.all(8.0);
  static const double quickDetailGap = 2.0;

  /// Frame 702 (DirectAddButton 컨테이너) 패딩 (Figma: 12px 18px)
  static const EdgeInsets frame702DirectAddPadding = EdgeInsets.symmetric(
    horizontal: 18.0,
    vertical: 12.0,
  );

  // ========================================
  // 🎨 보더 반경
  // ========================================

  /// Frame 701 보더 반경 (Figma: 28px)
  static const double frame701BorderRadius = 28.0;

  /// 추가 버튼 보더 반경 (Figma: 16px)
  static const double addButtonBorderRadius = 16.0;

  /// DirectAddButton 내부 Frame 보더 반경 (Figma: 16px)
  static const double directAddButtonInnerRadius = 16.0;

  /// QuickAdd_ActionType 보더 반경 (Figma: 34px)
  static const double actionTypeBorderRadius = 34.0;

  /// Frame 653 보더 반경 (Figma: 24px)
  static const double frame653BorderRadius = 24.0;

  /// Frame 688 보더 반경 - 타입 선택 시 (Figma: 100px - pill 형태)
  static const double frame688BorderRadiusSelected = 100.0;

  /// Frame 688 보더 반경 - 컨테이너 (Figma: 18px)
  static const double frame688ContainerRadius = 18.0;

  // ========================================
  // 🎨 그림자
  // ========================================

  /// Frame 701 그림자 (Figma: 0px 2px 8px rgba(186, 186, 186, 0.08))
  static const List<BoxShadow> frame701Shadow = [
    BoxShadow(
      color: Color(0x14BABABA),
      offset: Offset(0, 2),
      blurRadius: 8.0,
      spreadRadius: 0,
    ),
  ];

  /// QuickAdd_ActionType 그림자 (Figma: 0px 2px 8px rgba(186, 186, 186, 0.08))
  static const List<BoxShadow> actionTypeShadow = [
    BoxShadow(
      color: Color(0x14BABABA),
      offset: Offset(0, 2),
      blurRadius: 8.0,
      spreadRadius: 0,
    ),
  ];

  /// Frame 653 그림자 (Figma: 0px 2px 8px rgba(186, 186, 186, 0.08))
  static const List<BoxShadow> frame653Shadow = [
    BoxShadow(
      color: Color(0x14BABABA),
      offset: Offset(0, 2),
      blurRadius: 8.0,
      spreadRadius: 0,
    ),
  ];

  /// Frame 688 그림자 - 타입 선택 시 (Figma: 0px 4px 20px rgba(0, 0, 0, 0.06))
  static const List<BoxShadow> frame688ShadowSelected = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 20.0,
      spreadRadius: 0,
    ),
  ];

  // ========================================
  // 🎨 타이포그래피
  // ========================================

  /// 기본 폰트 패밀리 (Figma: LINE Seed JP App_TTF)
  static const String fontFamily = 'LINE Seed JP App_TTF';

  /// Placeholder 텍스트 스타일 (Figma: Bold 16px, #7A7A7A)
  static const TextStyle placeholderStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    height: 1.4, // 140% line-height
    letterSpacing: -0.08, // -0.005em
    color: placeholderText,
  );

  /// 입력된 텍스트 스타일 (Figma: Bold 16px, #111111)
  static const TextStyle inputTextStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.08,
    color: inputText,
  );

  /// 추가 버튼 텍스트 스타일 (Figma: Bold 13px, #FAFAFA)
  static const TextStyle addButtonTextStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.065, // -0.005em
    color: addButtonText,
  );

  /// Frame 705 메뉴 텍스트 스타일 (Figma: Bold 14px, #262626)
  static const TextStyle popupItemTextStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.07,
    color: popupText,
  );

  /// QuickDetail 텍스트 스타일 (Figma: Bold 14px, #7A7A7A)
  static const TextStyle detailOptionTextStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.07,
    color: detailOptionText,
  );

  // ========================================
  // 📍 Position 시스템 (Absolute Positioning)
  // ========================================

  /// Frame 702 절대 위치 (Figma: right: 18px, bottom: 18px)
  static const double frame702PositionRight = 18.0;
  static const double frame702PositionBottom = 18.0;

  // ========================================
  // 🎨 백그라운드 블러 (Rectangle 385)
  // ========================================

  /// 백그라운드 블러 너비 (Figma: 393px)
  static const double blurBackgroundWidth = 393.0;

  /// 백그라운드 블러 높이 (Figma: 534px)
  static const double blurBackgroundHeight = 534.0;

  /// 백그라운드 그라데이션 (Figma: linear-gradient(180deg, rgba(255, 255, 255, 0) 0%, rgba(240, 240, 240, 0.95) 50%))
  static const LinearGradient blurBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00FFFFFF), // rgba(255, 255, 255, 0)
      Color(0xF2F0F0F0), // rgba(240, 240, 240, 0.95)
    ],
    stops: [0.0, 0.5],
  );

  /// 백그라운드 블러 강도 (Figma: blur(4px))
  static const double blurSigma = 4.0;

  // ========================================
  // 🎨 Helper Functions
  // ========================================

  /// Frame 701 Decoration
  static BoxDecoration get frame701Decoration => BoxDecoration(
    color: containerBackground,
    border: Border.all(color: containerBorder, width: 1.0),
    borderRadius: BorderRadius.circular(frame701BorderRadius),
    boxShadow: frame701Shadow,
  );

  /// 추가 버튼 Decoration (활성화)
  static BoxDecoration get addButtonActiveDecoration => BoxDecoration(
    color: addButtonActiveBackground,
    borderRadius: BorderRadius.circular(addButtonBorderRadius),
  );

  /// 추가 버튼 Decoration (비활성화)
  static BoxDecoration get addButtonInactiveDecoration => BoxDecoration(
    color: addButtonInactiveBackground,
    borderRadius: BorderRadius.circular(addButtonBorderRadius),
  );

  /// DirectAddButton 내부 Frame Decoration
  static BoxDecoration get directAddButtonInnerDecoration => BoxDecoration(
    color: addButtonActiveBackground,
    borderRadius: BorderRadius.circular(directAddButtonInnerRadius),
  );

  /// QuickAdd_ActionType Decoration
  static BoxDecoration get actionTypeDecoration => BoxDecoration(
    color: typeSelectorBackground,
    border: Border.all(color: typeSelectorBorder, width: 1.0),
    borderRadius: BorderRadius.circular(actionTypeBorderRadius),
    boxShadow: actionTypeShadow,
  );

  /// Frame 653 Decoration
  static BoxDecoration get frame653Decoration => BoxDecoration(
    color: popupBackground,
    border: Border.all(color: typeSelectorBorder, width: 1.0),
    borderRadius: BorderRadius.circular(frame653BorderRadius),
    boxShadow: frame653Shadow,
  );

  /// Frame 688 Decoration (타입 선택 시)
  static BoxDecoration get frame688SelectedDecoration => BoxDecoration(
    color: typeSelectorBackground,
    border: Border.all(color: typeSelectorBorder, width: 1.0),
    borderRadius: BorderRadius.circular(frame688BorderRadiusSelected),
    boxShadow: frame688ShadowSelected,
  );

  /// 백그라운드 블러 Decoration
  static BoxDecoration get blurBackgroundDecoration =>
      const BoxDecoration(gradient: blurBackgroundGradient);
}
