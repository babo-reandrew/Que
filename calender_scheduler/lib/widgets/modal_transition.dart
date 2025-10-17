import 'package:flutter/material.dart';
import '../const/quick_add_config.dart';

/// Quick_Add → Modal 전환 애니메이션
/// 이거를 설정하고 → Spring-Based Morphing 애니메이션을 구현해서
/// 이거를 해서 → Quick_Add_ControlBox가 모달로 부드럽게 변형되고
/// 이거는 이래서 → 애플 네이티브한 UX를 제공한다
/// 이거라면 → 사용자가 자연스러운 전환 효과를 경험한다
class ModalTransition extends PageRouteBuilder {
  final Widget child;
  final Offset beginOffset; // Quick_Add_ControlBox의 시작 위치
  final Offset endOffset; // Modal의 최종 위치
  final Size beginSize; // Quick_Add_ControlBox의 시작 크기
  final Size endSize; // Modal의 최종 크기

  ModalTransition({
    required this.child,
    required this.beginOffset,
    required this.endOffset,
    required this.beginSize,
    required this.endSize,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: QuickAddConfig.morphingDuration, // 450ms
         reverseTransitionDuration: QuickAddConfig.morphingDuration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // ✅ Spring-Based Curve 적용 (피그마: 애플 네이티브 스타일)
           final curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: QuickAddConfig.morphingCurve, // easeInOutCubic
             reverseCurve: QuickAddConfig.morphingCurve,
           );

           // ✅ 크기 변환 애니메이션
           final sizeTween = SizeTween(begin: beginSize, end: endSize);

           // ✅ 위치 변환 애니메이션
           final offsetTween = Tween<Offset>(
             begin: beginOffset,
             end: endOffset,
           );

           // ✅ Border Radius 변환 애니메이션
           final radiusTween = Tween<double>(
             begin: QuickAddConfig.controlBoxRadius, // 28px
             end: QuickAddConfig.modalRadius, // 36px
           );

           // ✅ 배경색 전환 애니메이션
           final colorTween = ColorTween(
             begin: QuickAddConfig.controlBoxBackground, // #ffffff
             end: QuickAddConfig.modalBackground, // #fcfcfc
           );

           // ✅ 페이드 애니메이션 (내용 전환)
           final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
             CurvedAnimation(
               parent: animation,
               curve: const Interval(0.3, 1.0), // 30% 시점부터 페이드인
             ),
           );

           return AnimatedBuilder(
             animation: curvedAnimation,
             builder: (context, child) {
               final currentSize = sizeTween.evaluate(curvedAnimation)!;
               final currentOffset = offsetTween.evaluate(curvedAnimation);
               final currentRadius = radiusTween.evaluate(curvedAnimation);
               final currentColor = colorTween.evaluate(curvedAnimation)!;

               return Stack(
                 children: [
                   // ✅ 배경 딤 처리
                   Positioned.fill(
                     child: Container(
                       color: Colors.black.withOpacity(
                         curvedAnimation.value * 0.3, // 최대 30% 투명도
                       ),
                     ),
                   ),

                   // ✅ 모핑되는 컨테이너
                   Positioned(
                     left: currentOffset.dx,
                     top: currentOffset.dy,
                     child: Container(
                       width: currentSize.width,
                       height: currentSize.height,
                       decoration: BoxDecoration(
                         color: currentColor,
                         borderRadius: BorderRadius.circular(currentRadius),
                         border: Border.all(
                           color: QuickAddConfig.modalBorder,
                           width: 1,
                         ),
                       ),
                       child: Opacity(
                         opacity: fadeAnimation.value,
                         child: child,
                       ),
                     ),
                   ),
                 ],
               );
             },
             child: child,
           );
         },
       );
}

/// 슬라이드 업 전환 (키보드와 동기화)
/// 이거를 설정하고 → 하단에서 위로 슬라이드하는 애니메이션을 구현해서
/// 이거를 해서 → 키보드와 함께 Quick_Add_ControlBox가 올라온다
class SlideUpTransition extends PageRouteBuilder {
  final Widget child;

  SlideUpTransition({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: QuickAddConfig.slideUpDuration, // 300ms
        reverseTransitionDuration: QuickAddConfig.slideUpDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // ✅ easeOutCubic Curve 적용
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: QuickAddConfig.slideUpCurve,
            reverseCurve: Curves.easeInCubic,
          );

          // ✅ 하단에서 위로 슬라이드
          final offsetTween = Tween<Offset>(
            begin: const Offset(0, 1), // 화면 하단
            end: Offset.zero, // 원래 위치
          );

          return SlideTransition(
            position: offsetTween.animate(curvedAnimation),
            child: child,
          );
        },
      );
}
