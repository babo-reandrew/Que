/// 🎨 Wolt Modal Sheet 테마 설정
///
/// wolt_modal_sheet의 글로벌 테마를 정의합니다.
/// WoltDesignTokens 기반으로 일관된 스타일 적용
library;

import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'wolt_design_tokens.dart';

/// Wolt 모달 시트 앱 테마
class WoltAppTheme {
  WoltAppTheme._();

  /// 글로벌 Wolt 테마
  ///
  /// **Phase 6-2 & 6-3 최적화 적용:**
  /// - 애니메이션: easeInOutCubic, 250ms
  /// - Background: 부드러운 리사이즈
  /// - SafeArea: iOS 노치 대응
  static WoltModalSheetThemeData get theme {
    return WoltModalSheetThemeData(
      // ==================== 배경 설정 ====================
      backgroundColor: WoltDesignTokens.backgroundColor,

      // ==================== Elevation (그림자) ====================
      // Figma 디자인: 그림자 없음 (0)
      // 부드러운 배경 전환을 위해 elevation 0으로 설정
      modalElevation: 0,

      // ==================== 드래그 핸들 ====================
      // Figma 디자인: 드래그 핸들 없음
      showDragHandle: false,
      dragHandleColor: Colors.transparent,
      dragHandleSize: const Size(0, 0),

      // ==================== 세이프 에리어 설정 ====================
      // ✅ Phase 6-3: Background resize 최적화
      // - enableDrag: true (사용자 제스처 허용)
      // - useSafeArea: true (iOS 노치 영역 자동 처리)
      // - resizeToAvoidBottomInset: true (키보드 올라올 때 자동 리사이즈)
      enableDrag: true,
      useSafeArea: true,
      resizeToAvoidBottomInset: true,

      // ==================== 배리어 (백드롭) 색상 ====================
      // 모달 뒤 어두운 오버레이 (50% 투명도)
      modalBarrierColor: Colors.black.withOpacity(0.5),

      // ==================== 애니메이션 스타일 ====================
      // Phase 6-2에서 최적화된 애니메이션 적용
      animationStyle: animationStyle,

      // ==================== 모달 타입 빌더 (반응형) ====================
      modalTypeBuilder: modalTypeBuilder,
    );
  }

  /// 애니메이션 스타일 (커스텀 설정 가능)
  ///
  /// **Phase 6-2 최적화:**
  /// - Duration: 250ms (부드러운 전환)
  /// - Curve: easeInOutCubic (더 자연스러운 가속/감속)
  /// - Modal Height Transition: easeInOutCubic (높이 변화 부드럽게)
  static WoltModalSheetAnimationStyle get animationStyle {
    return const WoltModalSheetAnimationStyle(
      // ==================== 페이지 전환 애니메이션 ====================
      paginationAnimationStyle: WoltModalSheetPaginationAnimationStyle(
        // ✅ 페이지 전환 속도: 250ms (Figma 스펙)
        paginationDuration: Duration(milliseconds: 250),

        // ✅ 모달 높이 전환 곡선: easeInOutCubic (더 부드러운 전환)
        // 366px → 576px → 662px 높이 변화 시 자연스러운 애니메이션
        modalSheetHeightTransitionCurve: Curves.easeInOutCubic,

        // ✅ 메인 컨텐츠 슬라이드 인 곡선: easeOutCubic
        // 새 페이지가 들어올 때 부드럽게 감속
        mainContentIncomingSlidePositionCurve: Curves.easeOutCubic,

        // ✅ 메인 컨텐츠 슬라이드 아웃 곡선: easeInCubic
        // 이전 페이지가 나갈 때 부드럽게 가속
        mainContentOutgoingSlidePositionCurve: Curves.easeInCubic,

        // ✅ 메인 컨텐츠 Opacity 전환 (Incoming): easeIn
        // 페이드 인 효과
        mainContentIncomingOpacityCurve: Curves.easeIn,

        // ✅ 메인 컨텐츠 Opacity 전환 (Outgoing): easeOut
        // 페이드 아웃 효과
        mainContentOutgoingOpacityCurve: Curves.easeOut,
      ),

      // ==================== 스크롤 애니메이션 ====================
      scrollAnimationStyle: WoltModalSheetScrollAnimationStyle(
        // 히어로 이미지 스케일 (스크롤 시작)
        heroImageScaleStart: 1.0,

        // 히어로 이미지 스케일 (스크롤 종료)
        heroImageScaleEnd: 0.9,

        // Top Bar 등장 애니메이션
        topBarOpacityStart: 0.0,
        topBarOpacityEnd: 1.0,
      ),
    );
  }

  /// 모달 타입 빌더 (반응형)
  ///
  /// - 모바일 (width < 768): BottomSheet
  /// - 태블릿/데스크탑 (width >= 768): Dialog (centerSheet)
  static WoltModalType modalTypeBuilder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 768) {
      // 모바일: 하단 바텀시트
      return WoltModalType.bottomSheet();
    } else {
      // 태블릿/데스크탑: 중앙 다이얼로그
      return WoltModalType.dialog();
    }
  }

  /// SafeArea 패딩 계산
  ///
  /// iOS 노치, 홈 인디케이터 영역을 고려한 하단 패딩 계산
  static double getBottomPadding(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // 키보드가 올라온 경우
    if (bottomInset > 0) {
      return WoltDesignTokens.paddingBottomSheetBottomKeyboard;
    }

    // 기본 하단 패딩 (홈 인디케이터 영역 포함)
    return WoltDesignTokens.paddingBottomSheetBottomDefault + bottomPadding;
  }
}
