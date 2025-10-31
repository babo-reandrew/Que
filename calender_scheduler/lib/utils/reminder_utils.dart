import 'dart:convert';

/// 리마인더 유틸리티 클래스
/// 이거를 설정하고 → 리마인더 JSON을 파싱하고 생성하는 함수를 제공해서
/// 이거를 해서 → 일정/할일/습관에서 리마인더를 쉽게 처리할 수 있다
/// 이거는 이래서 → DB 저장 및 UI 표시를 일관되게 관리한다
class ReminderUtils {
  /// 리마인더 JSON을 파싱하는 함수
  /// 이거를 설정하고 → JSON 문자열을 받아서
  /// 이거를 해서 → Map<String, dynamic>으로 변환한다
  static Map<String, dynamic>? parseReminder(String? reminder) {
    if (reminder == null || reminder.isEmpty) {
      return null;
    }

    try {
      return json.decode(reminder) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 리마인더를 표시 문자열로 변환하는 함수
  /// 이거를 설정하고 → 리마인더 JSON을 받아서
  /// 이거를 해서 → 사용자에게 표시할 문자열을 반환한다
  /// 예: {"label":"10分前","value":"10min","minutes":10} → "10분 전"
  static String getDisplayText(String? reminder) {
    final parsed = parseReminder(reminder);
    if (parsed == null) {
      return '알림 없음';
    }

    final label = parsed['label'] as String?;
    if (label == null) {
      return '알림 없음';
    }

    // 일본어 → 한글 변환
    return _convertToKorean(label);
  }

  /// 일본어 라벨을 한글로 변환하는 함수
  static String _convertToKorean(String japaneseLabel) {
    const labelMap = {
      '定時': '정시',
      '5分前': '5분 전',
      '10分前': '10분 전',
      '15分前': '15분 전',
      '30分前': '30분 전',
      '1時間前': '1시간 전',
      '1日前': '1일 전',
    };

    return labelMap[japaneseLabel] ?? japaneseLabel;
  }

  /// 리마인더가 비어있는지 확인하는 함수
  /// 이거를 설정하고 → 리마인더 JSON을 받아서
  /// 이거를 해서 → 비어있으면 true를 반환한다
  static bool isEmpty(String? reminder) {
    if (reminder == null || reminder.isEmpty) {
      return true;
    }

    final parsed = parseReminder(reminder);
    if (parsed == null) {
      return true;
    }

    final label = parsed['label'] as String?;
    return label == null || label.isEmpty;
  }

  /// 리마인더 시간을 계산하는 함수
  /// 이거를 설정하고 → 일정 시작 시간과 리마인더 설정을 받아서
  /// 이거를 해서 → 실제 알림 시간을 계산한다
  static DateTime? calculateReminderTime(DateTime eventTime, String? reminder) {
    final parsed = parseReminder(reminder);
    if (parsed == null) {
      return null;
    }

    final minutes = parsed['minutes'] as int?;
    if (minutes == null) {
      return null;
    }

    // 이벤트 시간에서 minutes만큼 빼기
    return eventTime.subtract(Duration(minutes: minutes));
  }

  /// 리마인더 생성 함수
  /// 이거를 설정하고 → 라벨, 값, 분을 받아서
  /// 이거를 해서 → JSON 문자열로 변환한다
  static String createReminder({
    required String label,
    required String value,
    required int minutes,
  }) {
    return '{"label":"$label","value":"$value","minutes":$minutes}';
  }

  /// 기본 리마인더 생성 (10분 전)
  static String createDefaultReminder() {
    return createReminder(label: '10分前', value: '10min', minutes: 10);
  }
}
