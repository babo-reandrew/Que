import 'dart:ui';
import 'package:flutter/material.dart';
import '../const/motion_config.dart';

/// 애플 스타일 셀 확장 애니메이션을 구현하는 커스텀 PageRoute
/// iOS의 zoom transition과 유사한 효과를 제공한다
///
/// 동작 방식:
/// 1. 배경에 블러 효과 적용 (BackdropFilter)
/// 2. Hero 애니메이션으로 셀이 전체 화면으로 확장
/// 3. 애플 스타일 Cubic Bezier 커브 적용
class AppleExpansionRoute<T> extends PageRoute<T> {
  /// 목적지 위젯을 생성하는 빌더
  final WidgetBuilder builder;

  /// 애니메이션 지속 시간 (기본값: 400ms)
  final Duration duration;

  /// 애니메이션 커브 (기본값: 애플 기본 커브)
  final Curve curve;

  AppleExpansionRoute({
    required this.builder,
    this.duration = MotionConfig.cellExpansion,
    this.curve = MotionConfig.appleDefault,
    super.settings,
  });

  @override
  Color? get barrierColor => null; // 배경 터치 차단 없음

  @override
  String? get barrierLabel => null; // 접근성 라벨 없음

  @override
  bool get maintainState => true; // 이전 화면 상태 유지

  @override
  Duration get transitionDuration => duration; // 애니메이션 지속 시간 설정

  @override
  Duration get reverseTransitionDuration => duration; // 뒤로가기 애니메이션도 동일한 시간

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // builder로 전달받은 위젯을 생성한다
    // 이 위젯이 Hero 애니메이션의 목적지가 된다
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // ⭐️ 애플 스타일 전환 효과를 구현하는 핵심 함수
    // 1. 블러 배경 오버레이
    // 2. Hero 애니메이션 (자동으로 처리됨)
    // 3. Fade 효과 추가

    return Stack(
      children: [
        // 1. ⭐️ 배경 블러 효과 (iOS UIVisualEffectView 스타일)
        // BackdropFilter를 사용해서 뒤의 콘텐츠를 블러 처리한다
        // animation.value에 따라 블러 강도가 0 → 20으로 증가한다
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return BackdropFilter(
              // ImageFilter.blur로 가우시안 블러를 적용한다
              // sigmaX, sigmaY: 블러 강도 (0 = 블러 없음, 20 = 강한 블러)
              // animation.value가 0→1로 변하면서 블러가 점진적으로 증가한다
              filter: ImageFilter.blur(
                sigmaX: MotionConfig.backdropBlurAmount * animation.value,
                sigmaY: MotionConfig.backdropBlurAmount * animation.value,
              ),
              // 블러 위에 반투명 검정 오버레이를 추가한다
              // iOS의 vibrancy effect를 재현한다
              child: Container(
                color: MotionConfig.backdropTintColor.withOpacity(
                  animation.value,
                ),
              ),
            );
          },
        ),

        // 2. ⭐️ 메인 콘텐츠 전환 (Hero 애니메이션)
        // Hero 위젯이 자동으로 셀 → 전체 화면으로 확장한다
        // FadeTransition으로 부드러운 페이드 효과를 추가한다
        FadeTransition(
          // opacity는 0 → 1로 변하면서 위젯이 서서히 나타난다
          // CurvedAnimation을 사용해서 애플 스타일 커브를 적용한다
          opacity: CurvedAnimation(
            parent: animation,
            curve: curve, // MotionConfig.appleDefault 커브 사용
          ),
          child: child, // Hero 애니메이션이 적용된 child
        ),
      ],
    );
  }
}
