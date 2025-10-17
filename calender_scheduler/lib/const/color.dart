import 'package:flutter/material.dart';

// ─── Grayscale Palette (무채색 기반 팔레트) ───

// 가장 밝은(배경, 디폴트 surface)
const Color gray050 = Color(0xFFF7F7F7); // Figma 기본 배경색 (#F7F7F7)
const Color gray100 = Color(0xFFE4E4E4); // 약간 어두운 배경, 인풋 border, divider
const Color gray200 = Color(0xFFCFCFCF); // 카드 바탕, 서브 surface
const Color gray300 = Color(0xFFBABABA); // 비활성 상태, disabled 텍스트, hover 배경
const Color gray400 = Color(0xFFA5A5A5); // 보조 텍스트, 아이콘 비활성, divider
const Color gray500 = Color(0xFF909090); // 세컨더리 텍스트, secondary icon
const Color gray600 = Color(0xFF7A7A7A); // placeholder, secondary action
const Color gray700 = Color(0xFF656565); // 선택 날짜, 강조 텍스트, primary icon
const Color gray800 = Color(0xFF505050); // 오늘 날짜, 값 강조, title
const Color gray900 = Color(0xFF3B3B3B); // 헤더, 액션 버튼, 강조 bgcolor
const Color gray950 = Color(0xFF262626); // modal background, 깊은 그림자
const Color gray1000 = Color(0xFF111111); // 최상위 강조, 다크모드 text

// ─── Calendar Specific Color Role ───

// 날짜 선택(선택된 날짜의 배경/테두리): 실제로 gray700을 씀
const Color selectedDateBg = gray700; // 선택된 날짜의 배경 (calendar, datePicker)
const Color selectedDateBorder = gray800; // 선택된 날짜 테두리 (calendar, datePicker)

// 오늘 날짜 강조
const Color currentDateBg = gray800; // 오늘 날짜의 배경색 (calendar)
const Color currentDateBorder = gray900; // 오늘 날짜의 테두리 (calendar)

// 비활성, 날짜 없음 (빈 칸 등)
const Color dateDisabledBg = gray050; // 비활성 날짜의 배경색
const Color dateDisabledText = gray300; // 비활성 날짜 텍스트색

// Hover 등 상호작용 상태
const Color selectedDateHoverBg = gray400; // hover 시 선택된 날짜 배경
const Color currentDateHoverBg = gray500; // hover 시 오늘 날짜 배경

// ─── 캘린더 전용 색상 상수들 ───
const Color calendarSelectedBg = gray1000; // 선택된 날짜 배경색
const Color calendarSelectedText = Color(0xFFF7F7F7); // 선택된 날짜 텍스트 색상
const Color calendarTodayBg = Color(0xFF111111); // 오늘 날짜 배경색 (검은색)
const Color calendarTodayText = Color(0xFFFAFAFA); // 오늘 날짜 텍스트 색상 (#FAFAFA)
const Color calendarOutsideText = gray500; // 이전 달/다음 달 날짜 텍스트 색상

// ─── Usage Example ───
// e.g. Container(color: selectedDateBg)
// e.g. TextStyle(color: gray800)

/*
  주요 사용처:
    - gray050 ~ gray1000 : 전체 UI surface, 텍스트, 아이콘, divider 등 컴포넌트별 배경 및 역할별 구분
    - selectedDateBg/border : 캘린더, datePicker 등에서 날짜 선택 시 강조
    - currentDateBg/border : 오늘(현재) 날짜 강조 처리
    - dateDisabledBg/text : 캘린더에서 비활성(날짜 없는 셀) 표현
    - (Hover 변수들) : 마우스오버, 인터랙션 강조
*/

// ─── User Category Colors (유저 카테고리 색상) ───

// 카테고리: 빨강 (Red Category)
const Color categoryRed = Color(0xFFD73131);
const Color categoryRedLight = Color(0xFFE56E6E);
const Color categoryRedDark = Color(0xFFA82525);

// 카테고리: 주황 (Orange Category)
const Color categoryOrange = Color(0xFFF5821E);
const Color categoryOrangeLight = Color(0xFFF8A05F);
const Color categoryOrangeDark = Color(0xFFC46818);

// 카테고리: 노랑 (Yellow Category)
const Color categoryYellow = Color(0xFFF6B300);
const Color categoryYellowLight = Color(0xFFF8C84D);
const Color categoryYellowDark = Color(0xFFC48F00);

// 카테고리: 초록 (Green Category)
const Color categoryGreen = Color(0xFF6BD5A5);
const Color categoryGreenLight = Color(0xFF95E0BE);
const Color categoryGreenDark = Color(0xFF50AA84);

// 카테고리: 파랑 (Blue Category)
const Color categoryBlue = Color(0xFF3593D1);
const Color categoryBlueLight = Color(0xFF6BAEE0);
const Color categoryBlueDark = Color(0xFF2876A7);

// 카테고리: 보라 (Purple Category)
const Color categoryPurple = Color(0xFF9774D6);
const Color categoryPurpleLight = Color(0xFFB597E3);
const Color categoryPurpleDark = Color(0xFF785BAB);

// 카테고리: 회색 (Gray Category)
const Color categoryGray = Color(0xFF989898);
const Color categoryGrayLight = Color(0xFFB8B8B8);
const Color categoryGrayDark = Color(0xFF787878);

// ─── Category Color List (카테고리 색상 리스트) ───

/// 모든 카테고리 기본 색상 리스트 (UI에서 선택 가능한 색상들)
/// 사용 예시: GridView, ColorPicker 등에서 반복 렌더링
const List<Color> categoryColors = [
  categoryRed,
  categoryOrange,
  categoryYellow,
  categoryGreen,
  categoryBlue,
  categoryPurple,
  categoryGray,
];

/// 카테고리 색상 맵 (문자열 key로 색상 접근)
/// 사용 예시: Map<String, Color> 형태로 DB에 저장된 색상 이름으로 색상 객체 가져오기
const Map<String, Color> categoryColorMap = {
  'red': categoryRed,
  'orange': categoryOrange,
  'yellow': categoryYellow,
  'green': categoryGreen,
  'blue': categoryBlue,
  'purple': categoryPurple,
  'gray': categoryGray,
};

/// 카테고리 색상 전체 변형 맵 (light, base, dark)
/// 사용 예시: hover, active, disabled 상태 표현 시 활용
const Map<String, Map<String, Color>> categoryColorVariants = {
  'red': {
    'light': categoryRedLight,
    'base': categoryRed,
    'dark': categoryRedDark,
  },
  'orange': {
    'light': categoryOrangeLight,
    'base': categoryOrange,
    'dark': categoryOrangeDark,
  },
  'yellow': {
    'light': categoryYellowLight,
    'base': categoryYellow,
    'dark': categoryYellowDark,
  },
  'green': {
    'light': categoryGreenLight,
    'base': categoryGreen,
    'dark': categoryGreenDark,
  },
  'blue': {
    'light': categoryBlueLight,
    'base': categoryBlue,
    'dark': categoryBlueDark,
  },
  'purple': {
    'light': categoryPurpleLight,
    'base': categoryPurple,
    'dark': categoryPurpleDark,
  },
  'gray': {
    'light': categoryGrayLight,
    'base': categoryGray,
    'dark': categoryGrayDark,
  },
};

// ─── Usage Example ───
/*
  주요 사용처:
    1. Container(color: categoryRed) - 단일 색상 적용
    2. categoryColors.map((color) => ColorWidget(color)) - 색상 선택 UI
    3. categoryColorMap['red'] - 문자열 key로 색상 조회
    4. categoryColorVariants['blue']!['light'] - 변형 색상 접근
    5. Firebase/DB 저장 시: 'red', 'blue' 등 문자열로 저장 후 조회
*/
