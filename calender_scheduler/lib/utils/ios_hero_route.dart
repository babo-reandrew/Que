import 'package:flutter/material.dart';
import 'dart:math' show exp, cos, pi;

/// iOS 네이티브 스타일 Hero 전환 애니메이션
/// SwiftUI의 .smooth spring 파라미터를 Flutter로 재현
/// - stiffness: 170-180
/// - damping: 24-26
/// - response: 0.5
/// - dampingFraction: 0.825

/// iOS 네이티브 Spring Curve
/// SwiftUI의 spring(response: 0.5, dampingFraction: 0.825) 재현
class IOSSpringCurve extends Curve {
  const IOSSpringCurve();

  @override
  double transform(double t) {
    // iOS의 기본 spring: response=0.5, dampingFraction=0.825
    const damping = 0.825;
    const omega = 2 * pi / 0.5;

    // Spring 물리 공식
    return 1 - (exp(-damping * omega * t) * cos(omega * t));
  }
}

/// iOS 네이티브 스타일 Hero Route Builder
/// 이거를 설정하고 → iOS 기본 전환 애니메이션을 재현해서
/// 이거를 해서 → Hero 애니메이션과 함께 부드러운 전환을 제공한다
class IOSHeroPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  IOSHeroPageRoute({required this.builder})
    : super(
        // iOS 기본 전환 타이밍
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),

        // 페이지 빌더
        pageBuilder: (context, animation, secondaryAnimation) {
          return builder(context);
        },

        // iOS 스타일 전환 애니메이션
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 메인 애니메이션 (iOS spring curve)
          final springCurve = CurvedAnimation(
            parent: animation,
            curve: const IOSSpringCurve(),
          );

          // iOS 네이티브 parallax 효과 (백그라운드가 살짝 이동)
          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(0.3, 0.0), // iOS의 백그라운드 이동량
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: Curves.linearToEaseOut,
                ),
              );

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: springCurve, child: child),
          );
        },
      );
}

/// iOS 네이티브 스타일 카드 전환 (Cupertino 스타일)
/// Hero 대신 사용 → Slidable과 충돌 없음
/// CupertinoPageRoute의 네이티브 전환 사용
class IOSCardPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final bool fullscreenDialog;

  IOSCardPageRoute({required this.builder, this.fullscreenDialog = false});

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // ✅ Material ancestor 제공 (TextField 등을 위해 필수)
    return Material(type: MaterialType.transparency, child: builder(context));
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // iOS 네이티브 spring curve
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: const IOSSpringCurve(),
      reverseCurve: Curves.easeInOut,
    );

    // iOS 스타일 슬라이드 전환 (오른쪽에서 왼쪽으로)
    final slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    return SlideTransition(position: slideAnimation, child: child);
  }
}

/// iOS 네이티브 스타일 바텀시트 Route
/// 이거를 설정하고 → 카드가 확대되면서 바텀시트로 전환되는 효과
/// 이거를 해서 → Hero 애니메이션과 함께 자연스러운 전환 제공
class IOSBottomSheetRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  IOSBottomSheetRoute({required this.builder});

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // ✅ Material ancestor 제공 (TextField 등을 위해 필수)
    return Material(type: MaterialType.transparency, child: builder(context));
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // iOS spring curve 적용
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: const IOSSpringCurve(),
      reverseCurve: Curves.easeInOut,
    );

    // 슬라이드 애니메이션 (아래에서 위로)
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    // 페이드 애니메이션
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }
}

/// Hero 애니메이션용 커스텀 Rect Tween (iOS 스타일)
/// 이거를 설정하고 → 카드가 자연스럽게 확대되는 경로를 계산
class IOSStyleRectTween extends RectTween {
  IOSStyleRectTween({required Rect? begin, required Rect? end})
    : super(begin: begin, end: end);

  @override
  Rect? lerp(double t) {
    // iOS spring curve 적용
    const curve = IOSSpringCurve();
    final curvedT = curve.transform(t);

    return Rect.lerp(begin, end, curvedT);
  }
}

/// iOS 스타일 Hero Flight Shuttle Builder
/// 이거를 설정하고 → Hero 전환 중 보이는 위젯을 커스터마이징
Widget iOSStyleHeroFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  // 전환 중에는 목적지 위젯을 사용 (더 자연스러운 애니메이션)
  final Hero toHero = toHeroContext.widget as Hero;

  return RepaintBoundary(
    child: Material(type: MaterialType.transparency, child: toHero.child),
  );
}
