import 'package:flutter/material.dart';

/// 🎯 Interactive Dismissal을 지원하는 Custom Route
/// 
/// Apple 카드 프레젠테이션 스타일:
/// - 드래그 중에는 DateDetailView 내부에서 Transform.scale로 처리
/// - 손을 떼면 threshold 체크 후 이 Route의 애니메이션으로 dismiss 또는 복귀
class InteractiveDetailRoute<T> extends PageRoute<T> {
  InteractiveDetailRoute({
    required this.builder,
    RouteSettings? settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;

  @override
  bool get opaque => false; // 🎯 투명 배경 (월뷰가 뒤에 보이도록)

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.0); // 🎯 배경 완전 투명

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 550);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 400);

  /// 🎯 현재 상태에서 애니메이션 완료 (dismiss)
  /// DateDetailView에서 threshold 초과 시 호출
  void completeDismiss() {
    if (controller != null && mounted) {
      // 🎯 현재 위치에서 부드럽게 dismiss
      controller!.reverse().then((_) {
        // 애니메이션 완료 후 자동으로 pop
        if (mounted) {
          navigator?.pop();
        }
      });
    }
  }

  /// 🎯 현재 상태에서 원래 위치로 복귀
  /// DateDetailView에서 threshold 미달 시 호출
  void cancelDismiss() {
    if (controller != null && mounted) {
      // 🎯 현재 위치에서 부드럽게 복귀
      controller!.forward();
    }
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 🎯 기본 fade transition (DateDetailView 내부에서 scale 처리)
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
