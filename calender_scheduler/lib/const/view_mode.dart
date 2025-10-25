/// 홈 화면의 뷰 모드를 정의하는 enum
/// 이거를 설정하고 → 월뷰와 Inbox 모드를 구분해서
/// 이거를 해서 → 상태에 따라 다른 UI를 표시하고
/// 이거는 이래서 → 사용자가 seamless하게 모드를 전환할 수 있다
enum ViewMode {
  /// 일반 월간 캘린더 뷰 (기본 모드)
  /// 이거를 설정하고 → TableCalendar를 표시하고
  /// 이거는 이래서 → 사용자가 일정을 확인할 수 있다
  normal,

  /// Inbox 모드 (서랍 뷰)
  /// 이거를 설정하고 → Inbox 네비게이션 바와 서랍 아이콘을 표시하고
  /// 이거는 이래서 → 사용자가 빠르게 항목에 접근할 수 있다
  inbox,
}

/// ViewMode 확장 기능
extension ViewModeExtension on ViewMode {
  /// 현재 모드가 Inbox인지 확인
  /// 이거를 설정하고 → enum을 boolean으로 변환해서
  /// 이거는 이래서 → 조건부 렌더링을 쉽게 할 수 있다
  bool get isInbox => this == ViewMode.inbox;

  /// 현재 모드가 Normal인지 확인
  /// 이거를 설정하고 → enum을 boolean으로 변환해서
  /// 이거는 이래서 → 조건부 렌더링을 쉽게 할 수 있다
  bool get isNormal => this == ViewMode.normal;

  /// 디버그용 문자열 표현
  /// 이거를 설정하고 → enum을 읽기 쉬운 문자열로 변환해서
  /// 이거는 이래서 → 콘솔 로그에서 쉽게 확인할 수 있다
  String get displayName {
    switch (this) {
      case ViewMode.normal:
        return '월간 뷰';
      case ViewMode.inbox:
        return 'Inbox 뷰';
    }
  }
}
