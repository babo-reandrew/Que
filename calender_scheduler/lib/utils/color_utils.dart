import 'package:flutter/material.dart';
import '../const/color.dart';

/// 색상 관련 유틸리티 함수 모음
/// - Color 객체를 문자열로 변환하는 기능 제공
/// - categoryColorMap의 역매핑을 통해 색상 이름을 찾는다
class ColorUtils {
  /// Color 객체를 색상 이름 문자열로 변환하는 함수
  ///
  /// 작동 방식:
  /// 1. categoryColorMap을 순회하면서 입력된 Color와 일치하는 항목을 찾는다
  /// 2. 찾으면 해당 색상의 이름(key)을 반환한다
  /// 3. 못 찾으면 기본값인 'gray'를 반환한다
  ///
  /// 사용 예시:
  /// ```dart
  /// Color myColor = categoryRed;
  /// String colorName = ColorUtils.colorToString(myColor); // 'red' 반환
  /// ```
  static String colorToString(Color color) {
    // categoryColorMap을 순회하면서 일치하는 색상을 찾는다
    for (final entry in categoryColorMap.entries) {
      // 현재 entry의 색상 값이 입력된 color와 일치하는지 확인한다
      if (entry.value == color) {
        // 일치하면 해당 색상의 이름(key)을 반환한다
        print('🎨 색상 변환: $color -> ${entry.key}'); // 디버깅: 변환 과정 출력
        return entry.key;
      }
    }

    // 일치하는 색상을 못 찾으면 기본값인 'gray'를 반환한다
    print('⚠️ 색상 변환 실패, 기본값 사용: $color -> gray'); // 디버깅: 실패 시 기본값 사용
    return 'gray';
  }

  /// 색상 이름 문자열을 Color 객체로 변환하는 함수
  ///
  /// 작동 방식:
  /// 1. categoryColorMap에서 색상 이름으로 Color 객체를 찾는다
  /// 2. 찾으면 해당 Color 객체를 반환한다
  /// 3. 못 찾으면 기본값인 categoryGray를 반환한다
  ///
  /// 사용 예시:
  /// ```dart
  /// String colorName = 'red';
  /// Color myColor = ColorUtils.stringToColor(colorName); // categoryRed 반환
  /// ```
  static Color stringToColor(String colorName) {
    // categoryColorMap에서 색상 이름으로 Color 객체를 찾는다
    final color = categoryColorMap[colorName.toLowerCase()];

    if (color != null) {
      // 찾으면 해당 Color 객체를 반환한다
      print('🎨 문자열 -> 색상 변환: $colorName -> $color'); // 디버깅: 변환 과정 출력
      return color;
    } else {
      // 못 찾으면 기본값인 categoryGray를 반환한다
      print(
        '⚠️ 문자열 -> 색상 변환 실패, 기본값 사용: $colorName -> categoryGray',
      ); // 디버깅: 실패 시 기본값 사용
      return categoryGray;
    }
  }

  /// 색상이 현재 선택된 색상인지 확인하는 함수
  ///
  /// 작동 방식:
  /// 1. Color 객체를 문자열로 변환한다
  /// 2. 선택된 색상 문자열과 비교한다
  /// 3. 일치하면 true, 아니면 false를 반환한다
  ///
  /// 사용 예시:
  /// ```dart
  /// bool isSelected = ColorUtils.isColorSelected(categoryRed, 'red'); // true 반환
  /// ```
  static bool isColorSelected(Color color, String selectedColor) {
    // Color 객체를 문자열로 변환해서 선택된 색상과 비교한다
    final colorName = colorToString(color);
    final isSelected = colorName == selectedColor;

    print(
      '🔍 색상 선택 확인: $colorName == $selectedColor ? $isSelected',
    ); // 디버깅: 비교 과정 출력
    return isSelected;
  }
}
