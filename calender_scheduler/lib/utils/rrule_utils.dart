import 'package:rrule/rrule.dart';
import '../Database/schedule_database.dart';

/// RRULE (Recurrence Rule) 유틸리티 - 간소화 버전
/// 이거를 설정하고 → RFC 5545 표준의 RRULE을 파싱하고 생성해서
/// 이거를 해서 → 구글 캘린더와 동일한 방식으로 반복 일정을 처리하고
/// 이거는 이래서 → 런타임에 동적으로 인스턴스를 생성하여 메모리 효율을 높인다
///
/// **주의:** rrule 0.2.17 패키지의 API 제한으로 인해 간소화된 구현

class RRuleUtils {
  /// RRULE 문자열로부터 반복 인스턴스 생성
  ///
  /// @param rruleString RRULE 문자열 (예: "FREQ=DAILY;COUNT=10")
  /// @param dtstart 반복 시작일
  /// @param rangeStart 조회 범위 시작
  /// @param rangeEnd 조회 범위 종료
  /// @param exdates 제외할 날짜 목록
  /// @return 반복 발생 날짜 리스트
  static List<DateTime> generateInstances({
    required String rruleString,
    required DateTime dtstart,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    List<DateTime>? exdates,
  }) {
    try {
      // 1. RRULE: 접두사 제거 (파싱용)
      final rruleClean = rruleString.startsWith('RRULE:')
          ? rruleString.substring(6)
          : rruleString;

      print('🔍 [RRuleUtils] RRULE 파싱: $rruleClean');
      print('   DTSTART: $dtstart');

      // 2. 🔥 CRITICAL FIX: RecurrenceRule.fromString()은 weekday 오프셋 버그가 있음!
      //    대신 RRULE 문자열을 파싱해서 RecurrenceRule API로 재구성
      final recurrenceRule = _parseRRuleToApi(rruleClean);

      // 3. 🔥 CRITICAL: 날짜만 추출하고 UTC로 변환
      //    rrule 패키지는 UTC DateTime만 허용하므로,
      //    로컬 날짜를 그대로 UTC로 해석 (시간대 변환 없이)
      final dtstartDateOnly = DateTime.utc(
        dtstart.year,
        dtstart.month,
        dtstart.day,
      );
      final rangeStartDateOnly = DateTime.utc(
        rangeStart.year,
        rangeStart.month,
        rangeStart.day,
      );
      final rangeEndDateOnly = DateTime.utc(
        rangeEnd.year,
        rangeEnd.month,
        rangeEnd.day,
        23,
        59,
        59,
      );

      // 4. 🔥 CRITICAL FIX: after 파라미터는 EXCLUSIVE!
      //    getAllInstances(after: X)는 X보다 큰 인스턴스만 반환
      //    따라서 rangeStart - 1초를 사용하여 rangeStart 당일도 포함되도록 함
      //    BUT: after >= start 제약이 있으므로, after는 항상 start 이상이어야 함
      final targetAfter = rangeStartDateOnly.subtract(
        const Duration(seconds: 1),
      );
      final adjustedRangeStart = targetAfter.isBefore(dtstartDateOnly)
          ? dtstartDateOnly // ✅ after < start이면 after = start (동일하게 설정)
          : targetAfter;

      print(
        '🔍 [RRuleUtils] 날짜만 추출 (UTC 형식): dtstart=${dtstartDateOnly.toString().split(' ')[0]}, rangeStart=${rangeStartDateOnly.toString().split(' ')[0]}',
      );
      print(
        '   범위: ${rangeStartDateOnly.toString()} ~ ${rangeEndDateOnly.toString()}',
      );
      print(
        '   after=${adjustedRangeStart.toString()}, before=${rangeEndDateOnly.toString()}',
      );

      // 5. RRULE 인스턴스 생성 (UTC DateTime 사용)
      final instances = recurrenceRule.getAllInstances(
        start: dtstartDateOnly,
        after: adjustedRangeStart,
        before: rangeEndDateOnly,
      );

      // 6. 결과를 로컬 날짜로 변환 (UTC → 로컬 해석)
      final localInstances = instances.map((d) {
        // 🔥 UTC DateTime의 날짜 부분을 로컬 날짜로 해석
        // 예: 2025-11-08 00:00:00 UTC → 2025-11-08 00:00:00 Local
        return DateTime(d.year, d.month, d.day);
      }).toList();

      // 7. ✅ CRITICAL FIX: dtstart 이전 날짜 필터링
      //    반복 일정은 생성된 시점(dtstart) 이전에는 존재하지 않음
      //    로컬 날짜로 비교
      final dtstartLocal = DateTime(dtstart.year, dtstart.month, dtstart.day);
      final filteredInstances = localInstances.where((instance) {
        return !instance.isBefore(dtstartLocal);
      }).toList();

      // 8. ✅ EXDATE 필터링 (삭제된 날짜 제외)
      if (exdates != null && exdates.isNotEmpty) {
        final exdateNormalized = exdates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
        final finalInstances = filteredInstances.where((instance) {
          final instanceDate = DateTime(instance.year, instance.month, instance.day);
          return !exdateNormalized.contains(instanceDate);
        }).toList();

        print('✅ [RRuleUtils] EXDATE 필터링: ${exdates.length}개 날짜 제외');
        print('   생성된 인스턴스 개수: ${finalInstances.length}');
        if (finalInstances.isNotEmpty) {
          print('   첫 번째: ${finalInstances.first.toString().split(' ')[0]}');
          if (finalInstances.length > 1) {
            print('   마지막: ${finalInstances.last.toString().split(' ')[0]}');
          }
        }
        return finalInstances;
      }

      print('✅ [RRuleUtils] 생성된 인스턴스 개수: ${filteredInstances.length}');
      if (filteredInstances.isNotEmpty) {
        print('   첫 번째: ${filteredInstances.first.toString().split(' ')[0]}');
        if (filteredInstances.length > 1) {
          print('   마지막: ${filteredInstances.last.toString().split(' ')[0]}');
        }
      }

      return filteredInstances;
    } catch (e, stack) {
      print('⚠️ [RRuleUtils] RRULE 파싱 실패: $e');
      print('   Stack: $stack');
      print('   폴백: dtstart 반환');
      return [dtstart];
    }
  }

  /// RecurringPatternData로부터 반복 인스턴스 생성
  static List<DateTime> generateInstancesFromPattern({
    required RecurringPatternData pattern,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    // EXDATE 파싱 (쉼표로 구분된 ISO 8601 날짜)
    final exdates = pattern.exdate.isEmpty
        ? <DateTime>[]
        : parseExdate(pattern.exdate);

    return generateInstances(
      rruleString: pattern.rrule,
      dtstart: pattern.dtstart,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      exdates: exdates,
    );
  }

  /// RRULE 문자열 빌더 (간소화 버전)
  static String buildRRule({
    required String frequency, // 'DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'
    int? interval,
    DateTime? until,
    int? count,
    List<String>? byWeekDays, // ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU']
    List<int>? byMonthDays,
    List<int>? byMonths,
  }) {
    final parts = <String>['FREQ=$frequency'];

    if (interval != null && interval > 1) {
      parts.add('INTERVAL=$interval');
    }

    if (until != null) {
      parts.add('UNTIL=${_formatDateTime(until)}');
    } else if (count != null) {
      parts.add('COUNT=$count');
    }

    if (byWeekDays != null && byWeekDays.isNotEmpty) {
      parts.add('BYDAY=${byWeekDays.join(',')}');
    }

    if (byMonthDays != null && byMonthDays.isNotEmpty) {
      parts.add('BYMONTHDAY=${byMonthDays.join(',')}');
    }

    if (byMonths != null && byMonths.isNotEmpty) {
      parts.add('BYMONTH=${byMonths.join(',')}');
    }

    return parts.join(';');
  }

  /// 날짜를 iCalendar 형식으로 포맷 (YYYYMMDDTHHMMSSZ)
  static String _formatDateTime(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return '${utc.year}${_pad(utc.month)}${_pad(utc.day)}'
        'T${_pad(utc.hour)}${_pad(utc.minute)}${_pad(utc.second)}Z';
  }

  /// 숫자를 2자리로 패딩
  static String _pad(int n) => n.toString().padLeft(2, '0');

  /// 일반적인 반복 패턴 템플릿
  static const Map<String, String> commonPatterns = {
    'daily': 'FREQ=DAILY',
    'weekdays': 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
    'weekly': 'FREQ=WEEKLY',
    'biweekly': 'FREQ=WEEKLY;INTERVAL=2',
    'monthly': 'FREQ=MONTHLY',
    'yearly': 'FREQ=YEARLY',
  };

  /// 반복 패턴 설명 생성 (한국어) - 간소화 버전
  static String getDescription(String rruleString, {String locale = 'ko'}) {
    try {
      // 간단한 파싱으로 설명 생성
      final parts = rruleString.split(';');
      String description = '';

      for (final part in parts) {
        if (part.startsWith('FREQ=')) {
          final freq = part.substring(5);
          switch (freq) {
            case 'DAILY':
              description = '매일';
              break;
            case 'WEEKLY':
              description = '매주';
              break;
            case 'MONTHLY':
              description = '매월';
              break;
            case 'YEARLY':
              description = '매년';
              break;
          }
        } else if (part.startsWith('INTERVAL=')) {
          final interval = int.tryParse(part.substring(9)) ?? 1;
          if (interval > 1) {
            description = description.replaceAll('매', '$interval');
          }
        } else if (part.startsWith('BYDAY=')) {
          final days = part.substring(6).split(',');
          final dayNames = days.map((d) => _getDayName(d)).join(', ');
          description += ' $dayNames요일';
        } else if (part.startsWith('COUNT=')) {
          final count = part.substring(6);
          description += ' ($count회)';
        } else if (part.startsWith('UNTIL=')) {
          final until = part.substring(6);
          description += ' ($until까지)';
        }
      }

      return description.isEmpty ? rruleString : description;
    } catch (e) {
      print('⚠️ [RRuleUtils] 설명 생성 실패: $e');
      return rruleString;
    }
  }

  /// 요일 이름 변환
  static String _getDayName(String day) {
    const dayNames = {
      'MO': '월',
      'TU': '화',
      'WE': '수',
      'TH': '목',
      'FR': '금',
      'SA': '토',
      'SU': '일',
    };
    return dayNames[day] ?? day;
  }

  /// 🔥 CRITICAL FIX: RRULE 문자열을 파싱해서 RecurrenceRule API로 재구성
  /// RecurrenceRule.fromString()은 weekday 오프셋 버그가 있기 때문에 사용하지 않음!
  static RecurrenceRule _parseRRuleToApi(String rruleString) {
    final parts = rruleString.split(';');
    Frequency? frequency;
    int? interval;
    DateTime? until;
    int? count;
    List<ByWeekDayEntry>? byWeekDays;
    List<int>? byMonthDays;
    List<int>? byMonths;

    for (final part in parts) {
      if (part.startsWith('FREQ=')) {
        final freq = part.substring(5);
        switch (freq) {
          case 'DAILY':
            frequency = Frequency.daily;
            break;
          case 'WEEKLY':
            frequency = Frequency.weekly;
            break;
          case 'MONTHLY':
            frequency = Frequency.monthly;
            break;
          case 'YEARLY':
            frequency = Frequency.yearly;
            break;
        }
      } else if (part.startsWith('INTERVAL=')) {
        interval = int.tryParse(part.substring(9));
      } else if (part.startsWith('COUNT=')) {
        count = int.tryParse(part.substring(6));
      } else if (part.startsWith('UNTIL=')) {
        // UNTIL 파싱 (예: 20251231T000000Z)
        final untilStr = part.substring(6);
        try {
          until = DateTime.parse(untilStr);
        } catch (e) {
          print('⚠️ [RRuleUtils] UNTIL 파싱 실패: $untilStr');
        }
      } else if (part.startsWith('BYDAY=')) {
        // 🔥 CRITICAL: BYDAY를 DateTime.weekday 상수로 변환
        final days = part.substring(6).split(',');
        byWeekDays = days
            .map((d) => _rruleCodeToWeekday(d))
            .whereType<int>()
            .map((wd) => ByWeekDayEntry(wd))
            .toList();
      } else if (part.startsWith('BYMONTHDAY=')) {
        final days = part.substring(11).split(',');
        byMonthDays = days
            .map((d) => int.tryParse(d))
            .whereType<int>()
            .toList();
      } else if (part.startsWith('BYMONTH=')) {
        final months = part.substring(8).split(',');
        byMonths = months.map((m) => int.tryParse(m)).whereType<int>().toList();
      }
    }

    if (frequency == null) {
      throw Exception('RRULE에 FREQ가 없습니다: $rruleString');
    }

    // RecurrenceRule API로 생성 (버그 없음!)
    return RecurrenceRule(
      frequency: frequency,
      interval: interval ?? 1,
      until: until,
      count: count,
      byWeekDays: byWeekDays ?? [],
      byMonthDays: byMonthDays ?? [],
      byMonths: byMonths ?? [],
    );
  }

  /// RRULE 코드를 DateTime.weekday 상수로 변환
  /// ⚠️ RecurrenceRule API를 사용하므로 보정 불필요
  static int? _rruleCodeToWeekday(String code) {
    switch (code) {
      case 'MO':
        return DateTime.monday; // 1
      case 'TU':
        return DateTime.tuesday; // 2
      case 'WE':
        return DateTime.wednesday; // 3
      case 'TH':
        return DateTime.thursday; // 4
      case 'FR':
        return DateTime.friday; // 5
      case 'SA':
        return DateTime.saturday; // 6
      case 'SU':
        return DateTime.sunday; // 7
      default:
        print('⚠️ [RRuleUtils] 알 수 없는 요일 코드: $code');
        return null;
    }
  }

  /// 다음 발생 날짜 조회
  static DateTime? getNextOccurrence({
    required String rruleString,
    required DateTime dtstart,
    DateTime? after,
    List<DateTime>? exdates,
  }) {
    final instances = generateInstances(
      rruleString: rruleString,
      dtstart: dtstart,
      rangeStart: after ?? DateTime.now(),
      rangeEnd: (after ?? DateTime.now()).add(const Duration(days: 365)),
    );

    return instances.isNotEmpty ? instances.first : null;
  }

  /// EXDATE 문자열 생성
  static String buildExdate(List<DateTime> dates) {
    return dates.map(_formatDateTime).join(',');
  }

  /// EXDATE 문자열 파싱
  static List<DateTime> parseExdate(String exdateString) {
    if (exdateString.isEmpty) return [];

    return exdateString
        .split(',')
        .map((dateStr) {
          try {
            return DateTime.parse(dateStr.trim());
          } catch (e) {
            print('⚠️ [RRuleUtils] EXDATE 파싱 실패: $dateStr');
            return null;
          }
        })
        .whereType<DateTime>()
        .toList();
  }
}

/// 반복 빈도
enum RecurringFrequency {
  daily, // 매일
  weekly, // 매주
  monthly, // 매월
  yearly, // 매년
}
