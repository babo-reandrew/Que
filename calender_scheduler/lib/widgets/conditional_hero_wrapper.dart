import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../utils/ios_hero_route.dart';

/// 조건부 Hero Wrapper - Slidable 상태에 따라 Hero 활성화/비활성화
///
/// 이거를 설정하고 → Slidable이 열려있을 때는 Hero를 비활성화해서
/// 이거를 해서 → "Hero cannot be descendant of another Hero" 에러를 방지하고
/// 이거는 이래서 → Slidable과 Hero를 동시에 사용할 수 있다
/// 이거라면 → 사용자가 스와이프와 터치를 모두 자연스럽게 사용할 수 있다
///
/// 작동 원리:
/// 1. Slidable이 닫혀있을 때 (ratio = 0.0)
///    → Hero 활성화 ✅
///    → 카드 터치 시 Hero 애니메이션으로 상세 페이지 열림
///
/// 2. Slidable이 열려있을 때 (ratio > 0.0)
///    → Hero 비활성화 ❌
///    → 스와이프 액션만 작동 (완료/삭제)
///
/// 3. Slidable이 닫히는 중 (ratio 감소 중)
///    → Hero 비활성화 유지 ❌
///    → 애니메이션 충돌 방지
///
/// 4. Slidable이 완전히 닫힌 후 (ratio = 0.0)
///    → Hero 다시 활성화 ✅
///    → 다음 터치에 Hero 애니메이션 가능
class ConditionalHeroWrapper extends StatefulWidget {
  final String heroTag; // Hero 태그 (고유 식별자)
  final Widget child; // 실제 카드 위젯
  final VoidCallback onTap; // 터치 이벤트 콜백
  final String? slidableKey; // Slidable의 Key (상태 감지용)

  const ConditionalHeroWrapper({
    super.key,
    required this.heroTag,
    required this.child,
    required this.onTap,
    this.slidableKey,
  });

  @override
  State<ConditionalHeroWrapper> createState() => _ConditionalHeroWrapperState();
}

class _ConditionalHeroWrapperState extends State<ConditionalHeroWrapper> {
  // Slidable 상태 추적
  bool _isSlidableOpen = false; // Slidable이 열려있는지 여부
  bool _isAnimating = false; // 애니메이션 중인지 여부

  @override
  void initState() {
    super.initState();

    // Slidable 상태 감지 리스너 등록
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSlidableListener();
    });
  }

  /// Slidable 상태 감지 리스너 설정
  /// 이거를 설정하고 → Slidable의 열림/닫힘 상태를 실시간으로 감지해서
  /// 이거를 해서 → Hero 활성화 여부를 동적으로 결정한다
  void _setupSlidableListener() {
    try {
      // Slidable의 SlidableController에 접근
      final slidableController = Slidable.of(context);

      if (slidableController != null) {
        // ActionPane의 ratio 값을 감지 (0.0 = 닫힘, 1.0 = 완전히 열림)
        slidableController.animation.addListener(() {
          final ratio = slidableController.ratio;
          final wasOpen = _isSlidableOpen;
          final isOpen = ratio.abs() > 0.01; // 0.01 이상이면 열린 것으로 간주

          if (wasOpen != isOpen) {
            setState(() {
              _isSlidableOpen = isOpen;
              _isAnimating = ratio.abs() > 0.0 && ratio.abs() < 1.0;
            });

          }
        });
      }
    } catch (e) {
      // Slidable이 없는 경우에도 정상 작동 (Hero만 사용)
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hero 활성화 조건:
    // 1. Slidable이 완전히 닫혀있어야 함 (!_isSlidableOpen)
    // 2. 애니메이션 중이 아니어야 함 (!_isAnimating)
    final shouldEnableHero = !_isSlidableOpen && !_isAnimating;

    if (shouldEnableHero) {
      // ✅ Hero 활성화: Slidable이 닫혀있을 때
      return Hero(
        tag: widget.heroTag,
        createRectTween: (begin, end) {
          return IOSStyleRectTween(begin: begin, end: end);
        },
        flightShuttleBuilder: iOSStyleHeroFlightShuttleBuilder,
        child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            onTap: () {
              // 터치 시 Slidable 상태 재확인
              final slidableController = Slidable.of(context);
              final isReallyOpen =
                  slidableController?.actionPaneType.value != null;

              if (!isReallyOpen) {
                widget.onTap();
              } else {
              }
            },
            child: widget.child,
          ),
        ),
      );
    } else {
      // ❌ Hero 비활성화: Slidable이 열려있을 때

      return GestureDetector(
        onTap: () {
          // Slidable이 열려있을 때는 터치 무시
        },
        child: widget.child,
      );
    }
  }
}

/// 간편 사용을 위한 Extension
extension ConditionalHeroExtension on Widget {
  /// Widget을 조건부 Hero로 감싸는 헬퍼 메서드
  Widget withConditionalHero({
    required String heroTag,
    required VoidCallback onTap,
    String? slidableKey,
  }) {
    return ConditionalHeroWrapper(
      heroTag: heroTag,
      onTap: onTap,
      slidableKey: slidableKey,
      child: this,
    );
  }
}
