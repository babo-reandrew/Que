/// 🎨 Detached Bottom Sheet Type
///
/// iOS 스타일의 "떠있는(detached)" 바텀시트 타입
/// AirPods 배터리 표시 모달과 같은 스타일
///
/// **⚠️ 공통 레이아웃 규칙 (절대 변경 금지!):**
/// ┌─────────────────────────────────────────┐
/// │ 좌우 패딩: 16pt (고정)                    │
/// │ 하단 위치: 화면 바텀에서 16pt (고정)        │
/// │ Corner radius: 42pt                      │
/// │ 높이: 내부 콘텐츠에 따라 동적으로 변경      │
/// └─────────────────────────────────────────┘
///
/// **Apple 공식 디자인 스펙:**
/// - Corner radius: 42pt (iOS Continuous Corners)
/// - 전체 여백 (좌우하단): 16pt 통일
/// - Continuous curve 적용
/// - Glassmorphism blur 효과
/// - 2-layer shadow (떠있는 느낌)
///
/// **iOS Safe Area 지원:**
/// - iPhone X 이상: Safe Area 내부에서 16pt 여백 유지
/// - 홈 인디케이터 영역은 Safe Area로 처리
///
/// **사용 예시:**
/// ```dart
/// WoltModalSheet.show(
///   context: context,
///   modalTypeBuilder: (_) => DetachedBottomSheetType(),
///   pageListBuilder: (context) => [...],
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:figma_squircle/figma_squircle.dart';

class DetachedBottomSheetType extends WoltBottomSheetType {
  DetachedBottomSheetType()
    : super(
        // ===================================================================
        // Apple 공식 스펙 + Figma Squircle
        // ===================================================================
        shapeBorder: SmoothRectangleBorder(
          // Corner Radius: 42pt (iOS Continuous Corners)
          // Smoothness: 0.6 (Figma Squircle 60%)
          borderRadius: SmoothBorderRadius(
            cornerRadius: 42,
            cornerSmoothing: 0.6, // Figma Squircle 60%
          ),
        ),
        barrierDismissible: true, // 배경 탭으로 닫기 가능
        showDragHandle: false, // 드래그 핸들 숨김
        dismissDirection: WoltModalDismissDirection.down, // 아래로 드래그하여 닫기
      );

  /// 페이지 컨텐츠를 iOS 스타일로 데코레이션
  ///
  /// **⚠️ 절대 변경 금지! 모든 Detached 바텀시트 공통 규칙:**
  /// - 좌우 패딩: 16pt (고정)
  /// - 하단 패딩: 16pt (화면 바텀에서 16pt 떨어짐, 고정)
  /// - 높이: 내부 콘텐츠(child)에 따라 자동 조절 (동적)
  /// - Safe Area: 무시 (수동으로 정확한 16pt 적용)
  @override
  Widget decoratePageContent(
    BuildContext context,
    Widget child,
    bool useSafeArea,
  ) {
    // ===================================================================
    // ⚠️ 공통 레이아웃 규칙 (절대 변경 금지!)
    // 좌우: 16pt, 하단: 16pt (고정값)
    // 높이: child 콘텐츠에 따라 자동 결정
    // ===================================================================
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0, // 좌측 패딩 (고정)
        right: 16.0, // 우측 패딩 (고정)
        bottom: 16.0, // 화면 바텀에서 16pt 떨어짐 (고정)
      ),
      child: child, // useSafeArea 무시하고 직접 child 반환
    );
  }
}
