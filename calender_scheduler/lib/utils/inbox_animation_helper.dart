import 'package:flutter/animation.dart';

/// Inbox 모드 전환 애니메이션을 관리하는 헬퍼 클래스
/// 이거를 설정하고 → Inbox 진입/종료 타이밍을 중앙에서 관리해서
/// 이거를 해서 → 일관된 애니메이션 경험을 제공하고
/// 이거는 이래서 → 사용자가 seamless한 전환을 느낄 수 있다
class InboxAnimationHelper {
  // ─── 타이밍 설정 ───────────────────────────────────────────────────

  /// Inbox 진입 시 네비게이션 바 전환 지속 시간
  /// 이거를 설정하고 → Apple 스타일 spring 애니메이션 시간으로
  /// 이거는 이래서 → 자연스러운 전환을 만든다
  static const Duration navBarTransitionDuration = Duration(milliseconds: 400);

  /// 서랍 아이콘 등장 딜레이 (네비게이션 바 전환 후)
  /// 이거를 설정하고 → 네비게이션 바가 전환된 후 약간의 여유를 두고
  /// 이거는 이래서 → 사용자가 전환을 인지할 수 있다
  static const Duration drawerIconsDelay = Duration(milliseconds: 250);

  /// 개별 서랍 아이콘 간 stagger 딜레이
  /// 이거를 설정하고 → 각 아이콘이 순차적으로 나타나게 해서
  /// 이거는 이래서 → 쫀득한 애니메이션 느낌을 준다
  static const Duration iconStaggerDelay = Duration(milliseconds: 50);

  /// Inbox 종료 시 아이콘 사라짐 지속 시간
  /// 이거를 설정하고 → 빠르게 사라지도록 해서
  /// 이거는 이래서 → 사용자가 답답함을 느끼지 않는다
  static const Duration drawerIconsExitDuration = Duration(milliseconds: 200);

  /// Inbox 종료 시 네비게이션 바 전환 딜레이
  /// 이거를 설정하고 → 아이콘이 사라진 후 네비게이션 바를 전환해서
  /// 이거는 이래서 → 자연스러운 순서를 만든다
  static const Duration navBarExitDelay = Duration(milliseconds: 100);

  // ─── Spring 애니메이션 커브 ─────────────────────────────────────────

  /// 네비게이션 바 전환용 Spring 커브
  /// 이거를 설정하고 → response: 0.4, dampingFraction: 0.75로 설정해서
  /// 이거는 이래서 → 부드러우면서도 정확한 전환을 만든다
  /// 참고: Apple iOS 17+ 스타일
  static const Curve navBarSpringCurve = Curves.easeInOutCubic;

  /// 서랍 아이콘용 쫀득한 Spring 커브
  /// 이거를 설정하고 → response: 0.5, dampingFraction: 0.6으로 설정해서
  /// 이거는 이래서 → 살짝 바운스하는 쫀득한 느낌을 준다
  static const Curve drawerIconSpringCurve = Curves.elasticOut;

  // ─── 스케일 & 불투명도 설정 ─────────────────────────────────────────

  /// 서랍 아이콘 시작 스케일 (작은 상태)
  /// 이거를 설정하고 → 30% 크기에서 시작해서
  /// 이거는 이래서 → 큰 변화로 임팩트를 준다
  static const double drawerIconStartScale = 0.3;

  /// 서랍 아이콘 종료 스케일 (정상 크기)
  /// 이거를 설정하고 → 100% 크기로 끝나서
  /// 이거는 이래서 → 정확한 크기로 안착한다
  static const double drawerIconEndScale = 1.0;

  /// 서랍 아이콘 시작 불투명도 (투명)
  /// 이거를 설정하고 → 완전 투명에서 시작해서
  /// 이거는 이래서 → 페이드 인 효과를 준다
  static const double drawerIconStartOpacity = 0.0;

  /// 서랍 아이콘 종료 불투명도 (불투명)
  /// 이거를 설정하고 → 완전 불투명으로 끝나서
  /// 이거는 이래서 → 명확하게 보이도록 한다
  static const double drawerIconEndOpacity = 1.0;

  // ─── 배경 블러 설정 ────────────────────────────────────────────────

  /// Inbox 모드 시 캘린더 블러 강도
  /// 이거를 설정하고 → 약간의 블러를 적용해서
  /// 이거는 이래서 → Inbox에 집중하도록 만든다
  static const double calendarBlurRadius = 2.0;

  /// 블러 효과 전환 지속 시간
  /// 이거를 설정하고 → 부드럽게 블러가 적용되도록 해서
  /// 이거는 이래서 → 갑작스러운 변화를 방지한다
  static const Duration blurTransitionDuration = Duration(milliseconds: 300);

  // ─── 헬퍼 함수 ─────────────────────────────────────────────────────

  /// 특정 인덱스의 아이콘이 나타나는 총 딜레이 계산
  /// 이거를 설정하고 → 기본 딜레이 + (인덱스 * stagger 딜레이)를 계산해서
  /// 이거는 이래서 → 순차적인 애니메이션을 만든다
  static Duration calculateIconDelay(int index) {
    // 이거를 설정하고 → 네비게이션 바 전환이 끝난 후 시작하고
    // 이거를 해서 → 각 아이콘마다 50ms씩 딜레이를 주면
    // 이거는 이래서 → 자연스러운 순차 등장을 만든다
    return drawerIconsDelay + (iconStaggerDelay * index);
  }

  /// 전체 Inbox 진입 애니메이션 완료 시간 계산 (4개 아이콘 기준)
  /// 이거를 설정하고 → 네비 바 + 딜레이 + (아이콘 개수 * stagger)를 계산해서
  /// 이거는 이래서 → 전체 애니메이션 시간을 알 수 있다
  static Duration get totalEnterDuration {
    // 이거를 설정하고 → 네비 바 400ms + 딜레이 250ms + (4개 * 50ms) = 850ms로
    // 이거는 이래서 → 약 0.85초 안에 모든 전환이 완료된다
    const iconCount = 4;
    return navBarTransitionDuration +
        drawerIconsDelay +
        (iconStaggerDelay * iconCount);
  }

  /// 전체 Inbox 종료 애니메이션 완료 시간 계산
  /// 이거를 설정하고 → 아이콘 사라짐 + 딜레이 + 네비 바 전환을 계산해서
  /// 이거는 이래서 → 전체 종료 시간을 알 수 있다
  static Duration get totalExitDuration {
    // 이거를 설정하고 → 아이콘 200ms + 딜레이 100ms + 네비 바 400ms = 700ms로
    // 이거는 이래서 → 약 0.7초 안에 모든 종료가 완료된다
    return drawerIconsExitDuration + navBarExitDelay + navBarTransitionDuration;
  }

  // ─── 디버그 로깅 ───────────────────────────────────────────────────

  /// Inbox 진입 애니메이션 시작 로그
  /// 이거를 설정하고 → 콘솔에 진입 시작을 출력해서
  /// 이거는 이래서 → 개발 중 디버깅을 쉽게 한다
  static void logEnterStart() {
    print('🚪 [Inbox 애니메이션] 진입 시작');
    print('   → 네비게이션 바 전환: ${navBarTransitionDuration.inMilliseconds}ms');
    print('   → 서랍 아이콘 딜레이: ${drawerIconsDelay.inMilliseconds}ms');
    print('   → 예상 완료 시간: ${totalEnterDuration.inMilliseconds}ms');
  }

  /// Inbox 종료 애니메이션 시작 로그
  /// 이거를 설정하고 → 콘솔에 종료 시작을 출력해서
  /// 이거는 이래서 → 개발 중 디버깅을 쉽게 한다
  static void logExitStart() {
    print('🚪 [Inbox 애니메이션] 종료 시작');
    print('   → 아이콘 사라짐: ${drawerIconsExitDuration.inMilliseconds}ms');
    print('   → 네비게이션 바 딜레이: ${navBarExitDelay.inMilliseconds}ms');
    print('   → 예상 완료 시간: ${totalExitDuration.inMilliseconds}ms');
  }

  /// 서랍 아이콘 애니메이션 완료 로그
  /// 이거를 설정하고 → 각 아이콘이 완료될 때마다 출력해서
  /// 이거는 이래서 → 타이밍 검증을 쉽게 한다
  static void logIconAnimationComplete(int index) {
    print('✅ [Inbox 애니메이션] 아이콘 ${index + 1} 등장 완료');
  }
}
