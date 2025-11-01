import '../Database/schedule_database.dart';
import 'rrule_utils.dart';

// ✅ Timezone 기반 인스턴스 생성 개선 (경량 구현)
//
// **문제점:**
// - 기존: DateTime.now() 사용 시 항상 로컬 타임존
// - UTC 저장만 하면 DST 전환 시 "벽시계 시간" 유지 불가
//
// **해결책 (현재 구현):**
// 1. RecurringPattern.timezone 필드에 TZID 저장 (예: "America/New_York", "UTC+9")
// 2. 인스턴스 생성 시 기본은 UTC 기준으로 계산
// 3. 향후 확장: timezone 패키지 추가 시 full DST 지원 가능
//
// **RFC 5545 표준:**
// - DTSTART;TZID=America/New_York:20250101T090000
// - RRULE:FREQ=DAILY
// → 매일 9:00 AM (뉴욕 시간, DST 전환 시 UTC 오프셋 자동 변경)
//
// **NOTE:**
// 현재는 간소화된 구현으로, 모든 시간을 UTC 기준으로 처리합니다.
// timezone 필드는 저장되지만 실제 DST 계산은 하지 않습니다.
// 향후 'timezone' 패키지 추가 시 완전한 TZID/DST 지원 가능합니다.

class TimezoneInstanceGenerator {
  /// ✅ Timezone 인식 인스턴스 생성
  /// - 현재: pattern.timezone 값을 무시하고 UTC로 계산
  /// - 향후: timezone 패키지 추가 시 TZID 기반 계산으로 업그레이드
  static List<DateTime> generateInstancesWithTimezone({
    required RecurringPatternData pattern,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    // 현재는 기존 로직 사용 (UTC 기준)
    // timezone 필드는 저장만 하고 실제로는 사용하지 않음
    return RRuleUtils.generateInstancesFromPattern(
      pattern: pattern,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );

    // 🔮 향후 구현 (timezone 패키지 추가 시):
    /*
    final tzid = pattern.timezone;
    if (tzid.isEmpty || tzid == 'UTC') {
      return RRuleUtils.generateInstancesFromPattern(...);
    }

    // timezone 패키지 사용
    final location = tz.getLocation(tzid);
    final tzdtstart = tz.TZDateTime.from(pattern.dtstart, location);
    final tzRangeStart = tz.TZDateTime.from(rangeStart, location);
    final tzRangeEnd = tz.TZDateTime.from(rangeEnd, location);

    return RRuleUtils.generateInstances(
      rruleString: pattern.rrule,
      dtstart: tzdtstart,
      rangeStart: tzRangeStart,
      rangeEnd: tzRangeEnd,
      exdates: pattern.exdate.isEmpty ? [] : RRuleUtils.parseExdate(pattern.exdate),
    );
    */
  }

  /// ✅ "벽시계 시간" 유지 인스턴스 생성
  /// - 현재: UTC 기준으로 계산
  /// - 향후: DST 전환 시에도 로컬 시간(9:00 AM)을 유지
  static List<DateTime> generateWallClockInstances({
    required RecurringPatternData pattern,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    return generateInstancesWithTimezone(
      pattern: pattern,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }

  /// ✅ UTC 오프셋 기반 간단한 변환
  /// - 예: "UTC+9" → 9시간 추가
  /// - 예: "UTC-5" → 5시간 빼기
  /// - NOTE: DST는 고려하지 않음
  static DateTime applySimpleOffset({
    required DateTime utcDateTime,
    required String timezoneOffset,
  }) {
    // "UTC+9", "UTC-5" 형식 파싱
    if (!timezoneOffset.startsWith('UTC')) {
      return utcDateTime; // 파싱 실패 시 원본 반환
    }

    final offsetString = timezoneOffset.substring(3); // "+9" 또는 "-5"
    if (offsetString.isEmpty) {
      return utcDateTime;
    }

    try {
      final hours = int.parse(offsetString);
      return utcDateTime.add(Duration(hours: hours));
    } catch (e) {
      return utcDateTime;
    }
  }
}

/// ✅ Timezone 유틸리티
class TimezoneUtils {
  /// 일반적으로 사용되는 Timezone 목록
  /// - 현재: 간단한 UTC 오프셋 표기
  /// - 향후: IANA TZID 표기 (timezone 패키지 추가 시)
  static const commonTimezones = [
    'UTC',
    'UTC+9', // 한국, 일본
    'UTC+8', // 중국, 싱가포르
    'UTC-5', // 미국 동부 (EST, 겨울)
    'UTC-4', // 미국 동부 (EDT, 여름)
    'UTC-8', // 미국 서부 (PST, 겨울)
    'UTC-7', // 미국 서부 (PDT, 여름)
    'UTC+0', // 영국 (GMT, 겨울)
    'UTC+1', // 유럽 중부 (CET, 겨울)
  ];

  /// 🔮 향후 timezone 패키지 추가 시 IANA TZID로 업그레이드:
  /*
  static const commonTimezones = [
    'UTC',
    'America/New_York', // EST/EDT
    'America/Chicago', // CST/CDT
    'America/Denver', // MST/MDT
    'America/Los_Angeles', // PST/PDT
    'Europe/London', // GMT/BST
    'Europe/Paris', // CET/CEST
    'Asia/Tokyo', // JST
    'Asia/Shanghai', // CST
    'Asia/Seoul', // KST
    'Australia/Sydney', // AEST/AEDT
  ];
  */

  /// Timezone 이름을 사용자 친화적 형식으로 변환
  static String formatTimezoneName(String tzid) {
    if (tzid == 'UTC') return 'UTC';
    if (tzid.startsWith('UTC')) return tzid; // UTC+9 → UTC+9

    // 향후 IANA TZID 파싱:
    // "America/New_York" → "New York (EST/EDT)"
    final parts = tzid.split('/');
    if (parts.length < 2) return tzid;

    final city = parts.last.replaceAll('_', ' ');
    return city;
  }

  /// 현재 시스템 Timezone 가져오기
  /// - 현재: UTC 오프셋으로 반환
  /// - 향후: IANA TZID로 반환
  static String getSystemTimezone() {
    final now = DateTime.now();
    final utcNow = now.toUtc();
    final offsetMinutes = now.difference(utcNow).inMinutes;
    final offsetHours = offsetMinutes / 60;

    if (offsetHours == 0) {
      return 'UTC';
    } else if (offsetHours > 0) {
      return 'UTC+${offsetHours.toInt()}';
    } else {
      return 'UTC${offsetHours.toInt()}';
    }
  }
}

// ✅ 향후 개선 계획
//
// **Phase 1 (현재):**
// - RecurringPattern.timezone 필드 저장 (사용하지는 않음)
// - 모든 계산은 UTC 기준
// - 간단한 UTC 오프셋 변환 지원
//
// **Phase 2 (timezone 패키지 추가 시):**
// 1. pubspec.yaml에 추가:
//    ```yaml
//    dependencies:
//      timezone: ^0.9.0
//    ```
//
// 2. 초기화 코드 추가 (main.dart):
//    ```dart
//    import 'package:timezone/data/latest.dart' as tz;
//    void main() {
//      tz.initializeTimeZones();
//      runApp(MyApp());
//    }
//    ```
//
// 3. TimezoneInstanceGenerator.generateInstancesWithTimezone() 주석 해제
//
// 4. 전체 IANA TZID 지원 + DST 자동 처리
//
// **참고:**
// - timezone 패키지 크기: ~2MB (IANA 데이터베이스 포함)
// - 대부분의 앱에서는 UTC만으로도 충분함
// - 글로벌 서비스에서만 필요
