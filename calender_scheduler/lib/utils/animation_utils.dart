import 'package:flutter/material.dart';
import 'common_functions.dart';

/// 애니메이션 관련 유틸리티 함수들을 모아놓은 클래스
/// 일관된 애니메이션 효과를 위해 중앙화해서 관리한다
class AnimationUtils {
  // 기본 페이지 전환 애니메이션을 생성하는 함수 - 부드러운 화면 전환을 위해 사용한다
  static Route<T> createPageRoute<T>({
    required Widget page, // 전환할 페이지를 받는다
    Duration? duration, // 애니메이션 지속시간을 받는다
    Curve? curve, // 애니메이션 커브를 받는다
  }) {
    return PageRouteBuilder<T>(
      // 페이지 라우트 빌더를 생성한다
      pageBuilder: (context, animation, secondaryAnimation) =>
          page, // 페이지를 빌드한다
      transitionDuration:
          duration ??
          CommonFunctions.createAnimationDuration(), // 애니메이션 지속시간을 설정한다
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 애니메이션 효과를 설정한다
        return _buildSlideTransition(
          animation,
          child,
          curve,
        ); // 슬라이드 전환 효과를 적용한다
      },
    );
  }

  // 슬라이드 전환 애니메이션을 구성하는 함수 - 오른쪽에서 왼쪽으로 슬라이드한다
  static Widget _buildSlideTransition(
    Animation<double> animation, // 애니메이션 값을 받는다
    Widget child, // 자식 위젯을 받는다
    Curve? curve, // 커브를 받는다
  ) {
    // 슬라이드 애니메이션을 생성한다
    final slideAnimation =
        Tween<Offset>(
          begin: const Offset(1.0, 0.0), // 오른쪽에서 시작한다
          end: Offset.zero, // 가운데로 이동한다
        ).animate(
          CurvedAnimation(
            parent: animation, // 부모 애니메이션을 설정한다
            curve: curve ?? Curves.easeInOut, // 기본 커브를 설정한다
          ),
        );

    // 페이드 애니메이션을 생성한다
    final fadeAnimation =
        Tween<double>(
          begin: 0.0, // 투명에서 시작한다
          end: 1.0, // 불투명으로 끝난다
        ).animate(
          CurvedAnimation(
            parent: animation, // 부모 애니메이션을 설정한다
            curve: curve ?? Curves.easeInOut, // 기본 커브를 설정한다
          ),
        );

    return SlideTransition(
      // 슬라이드 전환을 적용한다
      position: slideAnimation, // 슬라이드 애니메이션을 설정한다
      child: FadeTransition(
        // 페이드 전환을 적용한다
        opacity: fadeAnimation, // 페이드 애니메이션을 설정한다
        child: child, // 자식 위젯을 표시한다
      ),
    );
  }

  // 날짜 박스 확대 애니메이션을 생성하는 함수 - 날짜 클릭 시 확대 효과를 위해 사용한다
  static Widget createScaleAnimation({
    required Widget child, // 애니메이션을 적용할 위젯을 받는다
    required AnimationController controller, // 애니메이션 컨트롤러를 받는다
    double? scale, // 확대 비율을 받는다
    Duration? duration, // 애니메이션 지속시간을 받는다
  }) {
    // 스케일 애니메이션을 생성한다
    final scaleAnimation =
        Tween<double>(
          begin: 1.0, // 원래 크기에서 시작한다
          end: scale ?? 1.1, // 확대된 크기로 끝난다
        ).animate(
          CurvedAnimation(
            parent: controller, // 애니메이션 컨트롤러를 설정한다
            curve: Curves.elasticOut, // 탄성 효과를 적용한다
          ),
        );

    return AnimatedBuilder(
      // 애니메이션 빌더를 생성한다
      animation: scaleAnimation, // 스케일 애니메이션을 설정한다
      builder: (context, child) {
        return Transform.scale(
          // 스케일 변환을 적용한다
          scale: scaleAnimation.value, // 애니메이션 값을 적용한다
          child: child, // 자식 위젯을 표시한다
        );
      },
      child: child, // 애니메이션을 적용할 위젯을 설정한다
    );
  }

  // 페이드 인 애니메이션을 생성하는 함수 - 요소가 나타날 때 페이드 인 효과를 적용한다
  static Widget createFadeInAnimation({
    required Widget child, // 애니메이션을 적용할 위젯을 받는다
    required AnimationController controller, // 애니메이션 컨트롤러를 받는다
    Duration? delay, // 지연 시간을 받는다
  }) {
    // 페이드 애니메이션을 생성한다
    final fadeAnimation =
        Tween<double>(
          begin: 0.0, // 투명에서 시작한다
          end: 1.0, // 불투명으로 끝난다
        ).animate(
          CurvedAnimation(
            parent: controller, // 애니메이션 컨트롤러를 설정한다
            curve: Curves.easeIn, // 페이드 인 커브를 설정한다
          ),
        );

    return AnimatedBuilder(
      // 애니메이션 빌더를 생성한다
      animation: fadeAnimation, // 페이드 애니메이션을 설정한다
      builder: (context, child) {
        return Opacity(
          // 투명도를 설정한다
          opacity: fadeAnimation.value, // 애니메이션 값을 적용한다
          child: child, // 자식 위젯을 표시한다
        );
      },
      child: child, // 애니메이션을 적용할 위젯을 설정한다
    );
  }

  // 리스트 아이템 애니메이션을 생성하는 함수 - 리스트 아이템들이 순차적으로 나타나는 효과를 적용한다
  static Widget createStaggeredListAnimation({
    required Widget child, // 애니메이션을 적용할 위젯을 받는다
    required int index, // 아이템 인덱스를 받는다
    required AnimationController controller, // 애니메이션 컨트롤러를 받는다
    Duration? staggerDelay, // 순차 지연 시간을 받는다
  }) {
    // 순차 애니메이션을 생성한다
    final staggerAnimation =
        Tween<double>(
          begin: 0.0, // 투명에서 시작한다
          end: 1.0, // 불투명으로 끝난다
        ).animate(
          CurvedAnimation(
            parent: controller, // 애니메이션 컨트롤러를 설정한다
            curve: Interval(
              // 구간을 설정한다
              (index * (staggerDelay?.inMilliseconds ?? 100)) /
                  controller.duration!.inMilliseconds, // 시작 구간을 계산한다
              1.0, // 끝 구간을 설정한다
              curve: Curves.easeOut, // 커브를 설정한다
            ),
          ),
        );

    return AnimatedBuilder(
      // 애니메이션 빌더를 생성한다
      animation: staggerAnimation, // 순차 애니메이션을 설정한다
      builder: (context, child) {
        return Transform.translate(
          // 이동 변환을 적용한다
          offset: Offset(0, 20 * (1 - staggerAnimation.value)), // 아래에서 위로 이동한다
          child: Opacity(
            // 투명도를 설정한다
            opacity: staggerAnimation.value, // 애니메이션 값을 적용한다
            child: child, // 자식 위젯을 표시한다
          ),
        );
      },
      child: child, // 애니메이션을 적용할 위젯을 설정한다
    );
  }
}
