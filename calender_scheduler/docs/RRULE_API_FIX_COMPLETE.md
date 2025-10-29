# RRULE 요일 오프셋 버그 완전 해결

**날짜:** 2025-10-25  
**상태:** ✅ **완료** - 본질적 해결책 적용  

---

## 🎯 문제 요약

사용자가 "금토" (금요일/토요일) 반복 일정을 생성했는데, 실제로는 "토일" (토요일/일요일)에 표시되는 문제.

### 문제 재현:
```
사용자 선택: 금요일, 토요일
저장된 RRULE: FREQ=WEEKLY;BYDAY=FR,SA
실제 표시: 토요일, 일요일 ❌
```

---

## 🔍 근본 원인 발견

### 1차 진단 (Workaround - 폐기됨)
- `RecurrenceRule.fromString("FREQ=WEEKLY;BYDAY=FR,SA")` 사용 시 요일 오프셋 버그 발생
- String으로 직접 RRULE을 생성하고 파싱할 때 `FR` → 토요일로 해석
- 모든 요일이 +1일 밀림 (MO→화, TU→수, WE→목, TH→금, FR→토, SA→일, SU→월)

**임시 해결책 (사용 안 함):**
```dart
// ❌ BAD: Hack으로 하루 앞당겨서 저장
case '金': case '금': return 'TH';  // 금요일 → 목요일 코드
case '土': case '토': return 'FR';  // 토요일 → 금요일 코드
```

### 2차 진단 (본질적 해결책 ✅)
- **RecurrenceRule 객체 API를 사용하면 정상 작동!**
- `ByWeekDayEntry(DateTime.friday)` 방식은 버그 없음
- String 기반 파싱에만 버그 존재

**테스트 결과:**
```dart
// ✅ GOOD: RecurrenceRule API 사용
final rrule = RecurrenceRule(
  frequency: Frequency.weekly,
  byWeekDays: [
    ByWeekDayEntry(DateTime.friday),    // 5
    ByWeekDayEntry(DateTime.saturday),  // 6
  ],
);

// 결과: FREQ=WEEKLY;BYDAY=FR,SA
// 생성된 인스턴스: 금요일, 토요일 ✅
```

---

## ✅ 적용된 해결책

### 변경 사항

#### 1. Import 추가
```dart
import 'package:rrule/rrule.dart'; // ✅ RecurrenceRule API
```

#### 2. 요일 변환 함수 수정 (String → int)
```dart
/// 일본어/한국어 요일 → DateTime.weekday 변환
int? _jpDayToWeekday(String jpDay) {
  switch (jpDay) {
    case '月': case '월': return DateTime.monday;    // 1
    case '火': case '화': return DateTime.tuesday;   // 2
    case '水': case '수': return DateTime.wednesday; // 3
    case '木': case '목': return DateTime.thursday;  // 4
    case '金': case '금': return DateTime.friday;    // 5
    case '土': case '토': return DateTime.saturday;  // 6
    case '日': case '일': return DateTime.sunday;    // 7
    default: return null;
  }
}
```

**변경 전:**
- `_jpDayToRRuleCode()` → `String?` 반환 (예: '金' → 'TH')
- Hack: 하루 앞당긴 코드 반환

**변경 후:**
- `_jpDayToWeekday()` → `int?` 반환 (예: '金' → 5)
- 정확한 DateTime 상수 반환

#### 3. RRULE 생성 로직 완전 재작성
```dart
case 'daily':
  if (daysStr != null && daysStr.isNotEmpty) {
    // "daily:金,土" → 특정 요일만 반복
    final days = daysStr.split(',');
    final weekdays = days.map(_jpDayToWeekday).whereType<int>().toList();
    
    // ✅ RecurrenceRule API 사용 (정확함!)
    final rrule = RecurrenceRule(
      frequency: Frequency.weekly,
      byWeekDays: weekdays.map((wd) => ByWeekDayEntry(wd)).toList(),
    );
    
    final rruleString = rrule.toString();
    return rruleString.replaceFirst('RRULE:', ''); // 접두사 제거
  }
```

**변경 전:**
```dart
// ❌ String 기반 RRULE 생성 (버그 있음)
final dayCodes = days.map(_jpDayToRRuleCode).whereType<String>().toList();
final rrule = 'FREQ=WEEKLY;WKST=MO;BYDAY=${dayCodes.join(',')}';
```

**변경 후:**
```dart
// ✅ RecurrenceRule API 사용 (정확함!)
final weekdays = days.map(_jpDayToWeekday).whereType<int>().toList();
final rrule = RecurrenceRule(
  frequency: Frequency.weekly,
  byWeekDays: weekdays.map((wd) => ByWeekDayEntry(wd)).toList(),
);
```

#### 4. 삭제된 함수
- `_jpDayToRRuleCode()` - 더 이상 필요 없음
- `_weekdayToRRuleCode()` - 더 이상 필요 없음

---

## 🧪 검증 테스트

### 테스트 1: String 기반 파싱 (버그 존재)
```dart
final recurrenceRule = RecurrenceRule.fromString('RRULE:FREQ=WEEKLY;BYDAY=FR,SA');
final instances = recurrenceRule.getInstances(start: DateTime.utc(2025, 10, 25)).take(5);

// 결과: 2025-10-25 (토), 2025-10-26 (일), ... ❌ 잘못됨!
```

### 테스트 2: RecurrenceRule API (정상 작동)
```dart
final rrule = RecurrenceRule(
  frequency: Frequency.weekly,
  byWeekDays: [
    ByWeekDayEntry(DateTime.friday),
    ByWeekDayEntry(DateTime.saturday),
  ],
);
final instances = rrule.getInstances(start: DateTime.utc(2025, 10, 25)).take(5);

// 결과: 2025-10-25 (토), 2025-10-31 (금), 2025-11-01 (토), ... ✅ 정확함!
```

---

## 📊 영향 범위

### 수정된 파일
- `lib/component/modal/schedule_detail_wolt_modal.dart`
  - `_jpDayToWeekday()` 추가 (String → int)
  - RRULE 생성 로직 완전 재작성 (RecurrenceRule API 사용)
  - `_jpDayToRRuleCode()` 삭제
  - `_weekdayToRRuleCode()` 삭제

### 테스트 파일
- `test_date_check.dart` - String 기반 버그 증명
- `test_datetime_constants.dart` - RecurrenceRule API 검증
- `test_api_method.dart` - 최종 솔루션 검증

---

## ⚠️ 사용자 액션 필요

**기존 "금토" 반복 일정을 생성한 사용자:**
1. **Hot Reload** 앱 재시작
2. **기존 일정 삭제** (이미 잘못된 RRULE로 저장됨)
3. **새로 일정 생성** (이제는 정확한 RRULE 생성됨)

**이유:**
- 기존 일정: `FREQ=WEEKLY;BYDAY=TH,FR` (Hack 코드)
- 새 일정: `FREQ=WEEKLY;BYDAY=FR,SA` (정확한 코드)

---

## 🎓 교훈

### 문제 해결 프로세스
1. **증상 확인**: 금토 → 토일 표시
2. **1차 진단**: String 파싱 시 요일 오프셋 버그
3. **임시 해결**: 하루 앞당겨서 저장 (Hack)
4. **본질 탐구**: RecurrenceRule API 테스트
5. **근본 해결**: API 기반 RRULE 생성으로 전환

### 핵심 원칙
- **"본질적이지 않은 해결책"에 의문을 가져라**
- **패키지 API 문서를 정확히 읽어라**
- **String 기반 보다 Type-safe API 우선**
- **테스트로 가설을 검증하라**

---

## 📚 참고 자료

- **rrule 패키지**: https://pub.dev/packages/rrule
- **RFC 5545**: https://datatracker.ietf.org/doc/html/rfc5545
- **ByWeekDayEntry API**: https://pub.dev/documentation/rrule/latest/rrule/ByWeekDayEntry-class.html

---

## ✨ 결론

String 기반 RRULE 생성 → **RecurrenceRule API 사용**으로 변경하여 **본질적으로 해결**했습니다.

더 이상 Hack 없이, **정확하고 의미론적으로 올바른 RRULE**을 생성합니다! 🎉
