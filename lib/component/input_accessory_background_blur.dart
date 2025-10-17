import 'package:flutter/material.dart';
import 'dart:ui';
import '../design_system/input_accessory_design_system.dart';

/// Rectangle 385 스펙 - 백그라운드 블러 오버레이
///
/// Figma: https://www.figma.com/design/oIi8TtLEDhGxMIjyyoDqsp/OMO-Calendar?node-id=1172-11348&node-type=frame&t=XSLcW7fW0WxGTmPy-0
///
/// 디자인 스펙:
/// - 크기: 390 x 844 (전체 화면)
/// - 블러 효과: backdrop-filter: blur(8px)
/// - 그라디언트 배경:
///   * linear-gradient(180deg, rgba(0, 0, 0, 0.00) 0%, rgba(0, 0, 0, 0.72) 100%)
///   * background: var(--shade-white-a-24, rgba(255, 255, 255, 0.24))
/// - 상단 정렬 (배경 전체를 덮음)
class InputAccessoryBackgroundBlur extends StatelessWidget {
  /// 백그라운드 블러가 표시될지 여부
  final bool isVisible;

  /// 페이드 애니메이션 지속 시간
  final Duration fadeDuration;

  /// 탭했을 때 콜백 (배경 탭 시 키보드 닫기 등)
  final VoidCallback? onTap;

  const InputAccessoryBackgroundBlur({
    super.key,
    this.isVisible = true,
    this.fadeDuration = const Duration(milliseconds: 200),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: fadeDuration,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: InputAccessoryDesign.backgroundBlurWidth,
          height: InputAccessoryDesign.backgroundBlurHeight,
          decoration: BoxDecoration(
            gradient: InputAccessoryDesign.backgroundBlurGradient,
          ),
          child: BackdropFilter(
            filter: InputAccessoryDesign.backgroundBlurFilter,
            child: Container(
              decoration: BoxDecoration(
                color: InputAccessoryDesign.backgroundBlurOverlay,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 키보드와 함께 표시되는 백그라운드 블러 (전체 화면 오버레이)
///
/// 사용 예시:
/// ```dart
/// Stack(
///   children: [
///     // 기존 콘텐츠
///     YourContentWidget(),
///
///     // 키보드가 올라올 때 백그라운드 블러
///     if (isKeyboardVisible)
///       const InputAccessoryBackgroundBlur(
///         isVisible: true,
///         onTap: () {
///           // 배경 탭 시 키보드 닫기
///           FocusScope.of(context).unfocus();
///         },
///       ),
///   ],
/// )
/// ```
class InputAccessoryBackgroundBlurOverlay extends StatelessWidget {
  /// 키보드가 표시되는지 여부 (MediaQuery로 자동 감지)
  final bool? forceVisible;

  /// 배경 탭 시 키보드 자동으로 닫기
  final bool dismissKeyboardOnTap;

  /// 추가 탭 콜백
  final VoidCallback? onTap;

  const InputAccessoryBackgroundBlurOverlay({
    super.key,
    this.forceVisible,
    this.dismissKeyboardOnTap = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = forceVisible ?? (keyboardHeight > 0);

    return InputAccessoryBackgroundBlur(
      isVisible: isKeyboardVisible,
      onTap: () {
        if (dismissKeyboardOnTap) {
          FocusScope.of(context).unfocus();
        }
        onTap?.call();
      },
    );
  }
}
