import 'package:flutter/animation.dart';

/// 애플 스타일 모션 설정을 중앙에서 관리하는 설정 클래스
/// iOS의 Core Animation 타이밍 함수와 물리 매개변수를 Flutter에서 재현한다
/// 참고: Apple Human Interface Guidelines - Motion
class MotionConfig {
  // ─── 애플 스타일 Cubic Bezier 곡선 ───────────────────────────────────

  /// 애플 기본 타이밍 함수: cubic-bezier(0.25, 0.1, 0.25, 1.0)
  /// 가장 자연스러운 기본 애니메이션 커브로, 대부분의 UI 전환에 사용된다
  /// 특징: 부드러운 가속 후 자연스러운 감속
  static const Cubic appleDefault = Cubic(0.25, 0.1, 0.25, 1.0);

  /// 애플 EaseOut 함수: cubic-bezier(0.0, 0.0, 0.58, 1.0)
  /// 빠르게 시작해서 부드럽게 감속하는 커브
  /// 용도: 사라지는 애니메이션, 종료 전환
  static const Cubic appleEaseOut = Cubic(0.0, 0.0, 0.58, 1.0);

  /// 애플 EaseIn 함수: cubic-bezier(0.42, 0.0, 1.0, 1.0)
  /// 천천히 시작해서 빠르게 가속하는 커브
  /// 용도: 나타나는 애니메이션, 시작 전환
  static const Cubic appleEaseIn = Cubic(0.42, 0.0, 1.0, 1.0);

  /// 애플 EaseInOut 함수: cubic-bezier(0.42, 0.0, 0.58, 1.0)
  /// 가속 후 감속하는 대칭적 커브
  /// 용도: 양방향 전환, 모달 애니메이션
  static const Cubic appleEaseInOut = Cubic(0.42, 0.0, 0.58, 1.0);

  // ─── 애니메이션 지속 시간 ───────────────────────────────────────────

  /// 셀 확장 애니메이션 지속 시간
  /// iOS 스타일 확장 전환에 최적화된 시간 (400ms)
  static const Duration cellExpansion = Duration(milliseconds: 400);

  /// 페이지 전환 애니메이션 지속 시간
  /// 일반적인 화면 전환에 사용 (300ms)
  static const Duration pageTransition = Duration(milliseconds: 300);

  /// 빠른 애니메이션 지속 시간
  /// 버튼 피드백, 작은 UI 변화에 사용 (200ms)
  static const Duration quick = Duration(milliseconds: 200);

  // ─── iOS 블러 효과 설정 ───────────────────────────────────────────

  /// 배경 블러 강도 (Backdrop Blur)
  /// iOS의 UIVisualEffectView.blurEffect와 동일한 수준
  /// sigmaX, sigmaY 값으로 사용됨
  static const double backdropBlurAmount = 20.0;

  /// 배경 블러 틴트 색상
  /// iOS 스타일의 반투명 어두운 오버레이
  /// 40은 약 25% 불투명도 (0x40 = 64/255 ≈ 25%)
  static const Color backdropTintColor = Color(0x40000000);

  /// 블러 효과 최대 강도
  /// 모달이나 팝업에서 사용하는 최대 블러 수준
  static const double backdropBlurMax = 30.0;

  // ─── 애플 스타일 스프링 물리 매개변수 ─────────────────────────────

  /// 스프링 강성 (Stiffness)
  /// iOS 17+ SwiftUI 기본값: 280.0
  /// 스프링이 얼마나 빠르게 반응하는지 결정
  static const double springStiffness = 280.0;

  /// 감쇠 (Damping)
  /// iOS 17+ SwiftUI 기본값: 20.5
  /// 바운스 정도를 결정 (낮을수록 더 많이 바운스)
  static const double springDamping = 20.5;

  /// 질량 (Mass)
  /// 일반적으로 1.0 고정
  /// 애니메이션의 무게감을 결정
  static const double springMass = 1.0;

  /// 초기 속도 (Initial Velocity)
  /// 제스처 기반 애니메이션에서 사용
  static const double springInitialVelocity = 0.0;

  // ─── Hero 애니메이션 설정 ─────────────────────────────────────────

  /// Hero 애니메이션에 사용할 커브
  /// 셀 확장 시 부드러운 전환을 위해 appleDefault 사용
  static const Curve heroTransitionCurve = appleDefault;

  /// Hero 플라이트 셔틀 빌더 설정
  /// 애니메이션 중간 위젯의 모양을 결정
  static const bool useDefaultHeroFlight = false;

  // ─── 오늘 날짜 버튼 Hero 애니메이션 (셀 → 앱바 버튼) ─────────────

  /// 오늘 날짜 셀이 앱바 버튼으로 이동하는 애니메이션 커브
  /// Apple Default: cubic-bezier(0.25, 0.1, 0.25, 1.0)
  /// 특징: 가장 자연스러운 기본값, 부드러운 가속 + 정확한 안착
  static const Cubic todayButtonHeroCurve = Cubic(0.25, 0.1, 0.25, 1.0);

  /// 오늘 날짜 버튼 Hero 애니메이션 지속 시간
  /// iOS 17+ Snappy: 0.4초 (400ms)
  /// 용도: 빠르면서도 자연스러운 UI 전환
  static const Duration todayButtonHeroDuration = Duration(milliseconds: 400);

  /// 오늘 날짜 버튼 크기 변화 애니메이션
  /// 셀 크기: 22px → 버튼 크기: 36px
  /// 애니메이션 중 부드러운 스케일 전환을 위한 커브
  static const Cubic todayButtonScaleCurve = Cubic(0.25, 0.1, 0.25, 1.0);

  // ─── OpenContainer 애니메이션 설정 (Apple 쫀득한 스타일) ─────────────

  /// OpenContainer 전환 애니메이션 지속 시간
  /// Apple Maps/Safari: 약 500-550ms (실제 측정값)
  /// Material Design 3: 500ms (card expansion 권장)
  /// 최적값: 520ms - 쫀득하면서도 적당한 속도감
  static const Duration openContainerDuration = Duration(milliseconds: 520);

  /// OpenContainer 닫힘 애니메이션 지속 시간
  /// 닫힐 때는 약간 더 빠르게 (480ms)
  /// Apple 철학: 닫히는 것은 열리는 것보다 살짝 빠른 게 자연스러움
  static const Duration openContainerCloseDuration = Duration(
    milliseconds: 480,
  );

  /// OpenContainer 전환 커브 (Apple 스타일)
  /// cubic-bezier(0.05, 0.7, 0.1, 1.0) - Material Design 3 "Emphasized Decelerate"
  /// 특징: 천천히 시작 → 급격한 가속 → 매우 부드러운 감속
  /// "쫀득한" Apple 느낌의 핵심: 끝부분의 긴 감속 구간
  static const Cubic openContainerCurve = Cubic(0.05, 0.7, 0.1, 1.0);

  /// OpenContainer 역방향 전환 커브 (닫힐 때)
  /// cubic-bezier(0.05, 0.7, 0.1, 1.0) - 동일한 커브 사용
  /// Apple iOS: 열리기/닫히기 동일한 느낌으로 일관성 유지
  static const Cubic openContainerReverseCurve = Cubic(0.05, 0.7, 0.1, 1.0);

  /// OpenContainer Scrim 색상 (배경 오버레이)
  /// iOS 스타일과 유사한 반투명 검은색
  /// 40 = 약 25% 불투명도 (0x40 = 64/255 ≈ 25%)
  static const Color openContainerScrimColor = Color(0x40000000);

  /// OpenContainer 닫힌 상태 Elevation (그림자 높이)
  /// 0dp로 설정하여 그림자 애니메이션으로 인한 부자연스러움 제거
  static const double openContainerClosedElevation = 0.0;

  /// OpenContainer 열린 상태 Elevation
  /// Material Design: 0dp (전체 화면이므로 그림자 불필요)
  static const double openContainerOpenElevation = 0.0;

  /// OpenContainer Middle Color (fadeThrough 전환 중간 색상)
  /// fadeThrough 타입 사용 시 완전히 페이드 아웃되는 중간 단계의 배경색
  /// #F7F7F7로 통일하여 자연스러운 전환
  static const Color openContainerMiddleColor = Color(0xFFF7F7F7);

  /// OpenContainer Shape 보간 타입
  /// ContainerTransitionType.fade: 내용이 크로스페이드
  /// ContainerTransitionType.fadeThrough: 중간에 빈 상태 존재 (역방향 더 부드러움)
  static const bool useOpenContainerFade =
      false; // true: fade, false: fadeThrough

  // ─── Safari 스타일 스프링 애니메이션 (Pull-to-dismiss) ─────────────

  /// Pull-to-dismiss 임계값: 진행률 (0.0 ~ 1.0)
  /// 30% 이상 드래그 시 dismiss 실행
  static const double dismissThresholdProgress = 0.3;

  /// Pull-to-dismiss 임계값: 속도 (px/s)
  /// 500px/s 이상 속도로 스와이프 시 dismiss 실행
  static const double dismissThresholdVelocity = 500.0;

  /// 참고: Safari 스프링 파라미터는 기존 spring* 값 재사용
  /// - springMass = 1.0
  /// - springStiffness = 180.0 (Safari Standard)
  /// - springDamping = 20.0 (dampingRatio ≈ 0.745)
  ///
  /// Safari 스프링 프리셋:
  /// - Standard: stiffness=180, damping=20 (현재 사용 중) ✓
  /// - Subtle: stiffness=250, damping=25 (빠르고 섬세)
  /// - Playful: stiffness=150, damping=18 (느리고 바운스)
}
