import 'package:flutter/material.dart';

/// 캘린더 설정 상수들
class CalendarConfig {
  // 셀 크기 설정
  static const double cellSize = 22.0;

  // 모서리 둥글기 설정
  static const double borderRadius = 8.0;

  // 폰트 크기 설정
  static const double fontSize = 11.0;

  // 헤더 폰트 크기 설정
  static const double headerFontSize = 24.0;

  // 스무딩 코너 설정 (60% 스무딩)
  static const double cornerSmoothing = 0.6;
}

/// 자동 높이 계산 유틸리티 클래스
class HeightCalculationUtils {
  /// 일정 카드 높이 자동 계산
  /// 제목과 시간 정보의 높이를 기반으로 카드 높이를 자동으로 계산하는 함수
  static double calculateScheduleCardHeight() {
    const double titleFontSize = 16.0; // 제목 폰트 크기
    const double timeFontSize = 13.0; // 시간 폰트 크기
    const double fontSizeMultiplier = 1.4; // 폰트 크기의 140%를 적용
    const double spacingBetween = 8.0; // 제목과 시간 사이의 간격
    const double verticalPadding = 20.0; // 상하 패딩

    // 제목 높이 + 간격 + 시간 높이 + 상하 패딩 + 추가 여유 공간을 계산해서 전체 카드 높이를 반환
    return (titleFontSize * fontSizeMultiplier) +
        spacingBetween +
        (timeFontSize * fontSizeMultiplier) +
        (verticalPadding * 2); // 선 + 제목 + 시간 내용보다 16픽셀 더 크게 만들어서 여유 공간을 확보
  }

  /// 세로 선 높이 자동 계산
  /// 제목 + 간격 + 시간 + 2픽셀을 계산해서 세로 선의 높이를 자동으로 설정하는 함수
  static double calculateVerticalLineHeight() {
    const double titleFontSize = 16.0; // 제목 폰트 크기
    const double timeFontSize = 13.0; // 시간 폰트 크기
    const double fontSizeMultiplier = 1.4; // 폰트 크기의 140%를 적용
    const double spacingBetween = 8.0; // 제목과 시간 사이의 간격
    const double additionalPadding = 0.0; // 추가 패딩 2픽셀

    // 제목 높이 + 간격 + 시간 높이 + 추가 패딩을 계산해서 세로 선의 높이를 반환
    return (titleFontSize * fontSizeMultiplier) +
        spacingBetween +
        (timeFontSize * fontSizeMultiplier) +
        additionalPadding;
  }
}

/// 안전한 스무딩 위젯 유틸리티 클래스
class SmoothWidgetUtils {
  /// 스무딩 카드 컨테이너 생성
  /// 어디서든지 쉽게 사용할 수 있는 스무딩 카드 위젯을 만드는 함수
  static Widget createSmoothCard({
    required Widget child, // 카드 안에 들어갈 자식 위젯
    double borderRadius = 24, // 둥근 모서리 반지름 (기본값 24픽셀)
    Color? backgroundColor, // 배경색 (null이면 흰색)
    Color? borderColor, // 테두리 색상 (null이면 테두리 없음)
    double? borderWidth, // 테두리 두께 (null이면 테두리 없음)
    EdgeInsetsGeometry? padding, // 내부 패딩 (null이면 패딩 없음)
    EdgeInsetsGeometry? margin, // 외부 마진 (null이면 마진 없음)
    double? height, // 고정 높이 (null이면 자동 크기 조정)
  }) {
    return Container(
      // 컨테이너를 생성해서 카드의 기본 구조를 만듦
      height: height, // 고정 높이를 설정 (null이면 자동 크기 조정)
      margin: margin, // 외부 마진을 설정 (null이면 마진 없음)
      decoration: BoxDecoration(
        // 카드의 스타일을 설정하는 데코레이션
        color: backgroundColor ?? Colors.white, // 배경색을 설정 (null이면 흰색으로 기본값 설정)
        borderRadius: BorderRadius.circular(
          borderRadius,
        ), // 둥근 모서리를 설정해서 부드러운 모양을 만듦
        border:
            borderColor != null &&
                borderWidth !=
                    null // 테두리 색상과 두께가 모두 있으면 테두리를 생성
            ? Border.all(
                color: borderColor,
                width: borderWidth,
              ) // 테두리 색상과 두께를 설정
            : null, // 테두리가 없으면 테두리 없음으로 설정
      ),
      padding: padding, // 내부 패딩을 설정 (null이면 패딩 없음)
      child: child, // 자식 위젯을 전달
    );
  }

  /// 스무딩 버튼 생성
  /// 어디서든지 쉽게 사용할 수 있는 스무딩 버튼 위젯을 만드는 함수
  static Widget createSmoothButton({
    required Widget child, // 버튼 안에 들어갈 자식 위젯
    required VoidCallback? onPressed, // 버튼을 눌렀을 때 실행될 함수
    double borderRadius = 24, // 둥근 모서리 반지름 (기본값 24픽셀)
    Color? backgroundColor, // 배경색 (null이면 기본 색상)
    Color? borderColor, // 테두리 색상 (null이면 테두리 없음)
    double? borderWidth, // 테두리 두께 (null이면 테두리 없음)
    EdgeInsetsGeometry? padding, // 내부 패딩 (null이면 기본 패딩)
  }) {
    return ElevatedButton(
      // ElevatedButton을 생성해서 버튼의 기본 기능을 만듦
      onPressed: onPressed, // 버튼을 눌렀을 때 실행될 함수를 설정
      style: ElevatedButton.styleFrom(
        // 버튼의 스타일을 설정
        backgroundColor: backgroundColor, // 배경색을 설정 (null이면 기본 색상 사용)
        padding: padding, // 내부 패딩을 설정 (null이면 기본 패딩 사용)
        shape: RoundedRectangleBorder(
          // 둥근 모서리 모양을 설정
          borderRadius: BorderRadius.circular(
            borderRadius,
          ), // 둥근 모서리를 설정해서 부드러운 모양을 만듦
          side:
              borderColor != null &&
                  borderWidth !=
                      null // 테두리 색상과 두께가 모두 있으면 테두리를 생성
              ? BorderSide(
                  color: borderColor,
                  width: borderWidth,
                ) // 테두리 색상과 두께를 설정
              : BorderSide.none, // 테두리가 없으면 테두리 없음으로 설정
        ),
        elevation: 0, // 그림자를 제거해서 평면적인 모양을 만듦
      ),
      child: child, // 자식 위젯을 전달
    );
  }

  /// 스무딩 컨테이너 생성 (가장 기본적인 형태)
  /// 어디서든지 쉽게 사용할 수 있는 스무딩 컨테이너 위젯을 만드는 함수
  static Widget createSmoothContainer({
    required Widget child, // 컨테이너 안에 들어갈 자식 위젯
    double borderRadius = 24, // 둥근 모서리 반지름 (기본값 24픽셀)
    Color? backgroundColor, // 배경색 (null이면 투명)
    Color? borderColor, // 테두리 색상 (null이면 테두리 없음)
    double? borderWidth, // 테두리 두께 (null이면 테두리 없음)
    EdgeInsetsGeometry? padding, // 내부 패딩 (null이면 패딩 없음)
    EdgeInsetsGeometry? margin, // 외부 마진 (null이면 마진 없음)
    double? width, // 너비 (null이면 자동 크기 조정)
    double? height, // 높이 (null이면 자동 크기 조정)
  }) {
    return Container(
      // 컨테이너를 생성해서 기본 구조를 만듦
      width: width, // 너비를 설정 (null이면 자동 크기 조정)
      height: height, // 높이를 설정 (null이면 자동 크기 조정)
      margin: margin, // 외부 마진을 설정 (null이면 마진 없음)
      padding: padding, // 내부 패딩을 설정 (null이면 패딩 없음)
      decoration: BoxDecoration(
        // 컨테이너의 스타일을 설정하는 데코레이션
        color: backgroundColor, // 배경색을 설정 (null이면 투명 배경)
        borderRadius: BorderRadius.circular(
          borderRadius,
        ), // 둥근 모서리를 설정해서 부드러운 모양을 만듦
        border:
            borderColor != null &&
                borderWidth !=
                    null // 테두리 색상과 두께가 모두 있으면 테두리를 생성
            ? Border.all(
                color: borderColor,
                width: borderWidth,
              ) // 테두리 색상과 두께를 설정
            : null, // 테두리가 없으면 테두리 없음으로 설정
      ),
      child: child, // 자식 위젯을 전달
    );
  }
}
