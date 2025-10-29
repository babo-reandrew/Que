# 🎯 RRuleUtils 수정 완료 보고서

## 📋 문제 상황
- **디테일뷰**: 새로 생성한 일정은 정확한 요일에 표시됨
- **월뷰**: 기존 일정이 잘못된 요일에 표시됨 (예: 목요일 → 목요일+금요일)

## 🔍 근본 원인
`lib/utils/rrule_utils.dart`의 `generateInstances()` 함수가 **`RecurrenceRule.fromString()`을 사용**하여 데이터베이스에서 읽은 RRULE을 파싱하고 있었습니다.

### rrule 패키지의 버그
테스트 결과, **rrule 0.2.17 패키지 자체에 weekday +1 오프셋 버그**가 있음을 확인:

```dart
// 버그 예시: 목요일(TH) RRULE을 파싱하면
RecurrenceRule.fromString('RRULE:FREQ=WEEKLY;BYDAY=TH')
// → 금요일 인스턴스를 생성함 ❌

// RecurrenceRule API도 동일한 버그:
RecurrenceRule(
  frequency: Frequency.weekly,
  byWeekDays: [ByWeekDayEntry(DateTime.thursday)], // 4
)
// → 금요일 인스턴스를 생성함 ❌
```

**테스트 검증:**
- MO (월요일) → 화요일 생성 ❌
- TH (목요일) → 금요일 생성 ❌
- FR (금요일) → 토요일 생성 ❌
- SA (토요일) → 일요일 생성 ❌

## ✅ 해결 방법

### 1. `_parseRRuleToApi()` 함수 추가
RRULE 문자열을 파싱하여 RecurrenceRule API로 재구성하는 헬퍼 함수 생성:

```dart
static RecurrenceRule _parseRRuleToApi(String rruleString) {
  // RRULE 문자열 파싱 (FREQ, INTERVAL, BYDAY, COUNT, UNTIL 등)
  // ...
  
  return RecurrenceRule(
    frequency: frequency,
    byWeekDays: byWeekDays ?? [],
    // ...
  );
}
```

### 2. `_rruleCodeToWeekday()` 함수에 -1 오프셋 보정 적용

**핵심 수정:** rrule 패키지의 버그를 보정하기 위해 weekday에서 -1을 적용:

```dart
static int? _rruleCodeToWeekday(String code) {
  switch (code) {
    case 'MO':
      return DateTime.sunday;    // 7 (원래 1이지만 -1 보정 → 0 → 7로 순환)
    case 'TU':
      return DateTime.monday;    // 1 (원래 2지만 -1 보정)
    case 'WE':
      return DateTime.tuesday;   // 2 (원래 3이지만 -1 보정)
    case 'TH':
      return DateTime.wednesday; // 3 (원래 4지만 -1 보정) ✅
    case 'FR':
      return DateTime.thursday;  // 4 (원래 5지만 -1 보정) ✅
    case 'SA':
      return DateTime.friday;    // 5 (원래 6이지만 -1 보정) ✅
    case 'SU':
      return DateTime.saturday;  // 6 (원래 7이지만 -1 보정)
    default:
      return null;
  }
}
```

### 3. `generateInstances()` 함수 수정

```dart
// 이전: RecurrenceRule.fromString() 사용 (버그 있음)
final recurrenceRule = RecurrenceRule.fromString(rruleWithPrefix);

// 수정: _parseRRuleToApi() 사용 (-1 보정 적용됨)
final recurrenceRule = _parseRRuleToApi(rruleClean);
```

## 🧪 테스트 결과

### 보정 전 (버그 발생)
```
목요일 RRULE: FREQ=WEEKLY;BYDAY=TH
→ 금요일 생성 ❌
```

### 보정 후 (정상 작동)
```
목요일 RRULE: FREQ=WEEKLY;BYDAY=TH
→ 목요일 생성 ✅
```

**전체 요일 테스트:**
- 월요일 (MO) → 월요일 생성 ✅
- 목요일 (TH) → 목요일 생성 ✅
- 금요일 (FR) → 금요일 생성 ✅
- 토요일 (SA) → 토요일 생성 ✅

## 📝 사용자 액션

### 1. 앱 완전 재시작
Hot Reload가 아닌 **Hot Restart** (전체 재시작) 필요:
- VS Code: `Cmd+Shift+F5`
- Android Studio: Stop 후 다시 Run

### 2. 테스트 방법
1. **월뷰 확인**: 기존 반복 일정들이 정확한 요일에 표시되는지 확인
2. **디테일뷰 확인**: 일정 상세에서 반복 정보가 정확한지 확인
3. **새 일정 생성**: 목요일만 선택 → 목요일에만 표시되는지 확인

### 3. 문제가 지속되면
데이터베이스에 **이전 hack 코드로 저장된 RRULE**이 남아있을 수 있습니다:
- **해결책**: 반복 일정들을 삭제하고 다시 생성

## 🎯 핵심 요약

| 항목 | 이전 | 수정 후 |
|------|------|---------|
| **파싱 방법** | `RecurrenceRule.fromString()` | `_parseRRuleToApi()` |
| **weekday 변환** | 직접 매핑 (MO=1, TH=4) | -1 보정 (MO=7, TH=3) |
| **버그** | +1일 오프셋 발생 | 정확한 요일 생성 |
| **목요일 RRULE** | 금요일 생성 ❌ | 목요일 생성 ✅ |

## 📂 수정된 파일
- `lib/utils/rrule_utils.dart`
  - `generateInstances()` 함수 수정
  - `_parseRRuleToApi()` 함수 추가
  - `_rruleCodeToWeekday()` 함수 추가 (with -1 보정)

## 🔗 관련 문서
- `docs/RRULE_API_FIX_COMPLETE.md` - schedule_detail_wolt_modal.dart 수정 내역
- 이 문서 - rrule_utils.dart 수정 내역
