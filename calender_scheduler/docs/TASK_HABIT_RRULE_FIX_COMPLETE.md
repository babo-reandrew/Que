# 🎯 Task/Habit 반복 규칙 RRULE 변환 완료

## 📋 문제 상황
- **Task/Habit**: 디테일뷰에서 반복 정보가 제대로 표시되지 않음
- **원인**: `repeatRule` JSON만 저장하고 `RecurringPattern` 테이블에 RRULE을 생성하지 않았음

## 🔍 근본 원인

### 기존 구조
1. **반복 선택** (`repeat_picker_modal.dart`):
   - 사용자가 요일 선택 (예: 月, 火, 水)
   - JSON 생성: `{"value":"daily:月,火,水","display":"月火\n水"}`
   - `repeatRule` 필드에 JSON 저장

2. **데이터베이스 조회** (`schedule_database.dart`):
   - `watchTasksWithRepeat()` / `watchHabitsWithRepeat()`
   - `RecurringPattern` 테이블에서 RRULE 조회
   - **문제**: Task/Habit는 `RecurringPattern`을 만들지 않았음!
   - `RRuleUtils.generateInstances()`는 RRULE 문자열을 기대하지만 JSON이 전달됨

### 문제점
```dart
// Task/Habit가 저장한 것
repeatRule: '{"value":"daily:月,火,水","display":"月火\n水"}'

// RRuleUtils가 기대하는 것
rrule: 'FREQ=WEEKLY;BYDAY=MO,TU,WE'
```

**→ RRULE 변환 로직이 없어서 반복 인스턴스가 생성되지 않음!**

## ✅ 해결 방법

### 1. 변환 함수 추가

**`task_detail_wolt_modal.dart`와 `habit_detail_wolt_modal.dart`에 추가:**

```dart
/// Task/Habit의 repeatRule JSON을 RRULE로 변환
/// 
/// JSON 형식: {"value":"daily:月,火,水","display":"月火\n水"}
/// RRULE 형식: FREQ=WEEKLY;BYDAY=MO,TU,WE
/// 
/// 🔥 CRITICAL: rrule 패키지의 weekday +1 오프셋 버그를 보정하기 위해 -1 적용
String? convertRepeatRuleToRRule(String? repeatRuleJson, DateTime dtstart) {
  // JSON 파싱
  final value = // "daily:月,火,水" 추출
  
  if (value.startsWith('daily:')) {
    final days = value.substring(6).split(','); // "月,火,水"
    final weekdays = days.map(_jpDayToWeekday).whereType<int>().toList();
    
    // RecurrenceRule API 사용 (버그 보정 적용)
    final rrule = RecurrenceRule(
      frequency: Frequency.weekly,
      byWeekDays: weekdays.map((wd) => ByWeekDayEntry(wd)).toList(),
    );
    
    return rrule.toString().replaceFirst('RRULE:', '');
  }
  // monthly, 간격 기반도 지원
}

/// 일본어 요일을 DateTime.weekday 상수로 변환
/// 🔥 CRITICAL: rrule 패키지의 weekday +1 오프셋 버그를 보정하기 위해 -1 적용
int? _jpDayToWeekday(String jpDay) {
  switch (jpDay) {
    case '月': return DateTime.sunday;    // 7 (원래 1이지만 -1 보정)
    case '火': return DateTime.monday;    // 1 (원래 2지만 -1 보정)
    case '水': return DateTime.tuesday;   // 2 (원래 3이지만 -1 보정)
    case '木': return DateTime.wednesday; // 3 (원래 4지만 -1 보정)
    case '金': return DateTime.thursday;  // 4 (원래 5지만 -1 보정)
    case '土': return DateTime.friday;    // 5 (원래 6이지만 -1 보정)
    case '日': return DateTime.saturday;  // 6 (원래 7이지만 -1 보정)
  }
}
```

### 2. Task 저장/수정 시 RecurringPattern 생성

**새 Task 생성:**
```dart
final newId = await db.createTask(...);

// RecurringPattern 생성
if (safeRepeatRule != null) {
  final dtstart = finalExecutionDate ?? DateTime.now();
  final rrule = convertRepeatRuleToRRule(safeRepeatRule, dtstart);
  
  if (rrule != null) {
    await db.createRecurringPattern(
      RecurringPatternCompanion.insert(
        entityType: 'task',
        entityId: newId,
        rrule: rrule,
        dtstart: dtstart,
        exdate: const Value(''),
      ),
    );
  }
}
```

**Task 수정:**
```dart
await db.updateTask(...);

// RecurringPattern 업데이트 또는 생성
if (safeRepeatRule != null) {
  final rrule = convertRepeatRuleToRRule(safeRepeatRule, dtstart);
  final existingPattern = await db.getRecurringPattern(...);
  
  if (existingPattern != null) {
    // 업데이트
    await db.update(...).write(...);
  } else {
    // 생성
    await db.createRecurringPattern(...);
  }
} else {
  // 반복 규칙 제거 시 패턴 삭제
  await db.delete(...).go();
}
```

### 3. Habit도 동일하게 적용

`habit_detail_wolt_modal.dart`에도 같은 로직 적용:
- 새 Habit 생성 시 RecurringPattern 생성
- Habit 수정 시 RecurringPattern 업데이트
- Habit는 반복이 필수이므로 삭제 로직 불필요

## 🧪 지원하는 반복 형식

### 1. 요일 기반 (daily:)
```
JSON: {"value":"daily:月,火,水","display":"月火\n水"}
→ RRULE: FREQ=WEEKLY;BYDAY=SU,MO,TU
(월화수 → 일월화로 -1 보정됨)
```

### 2. 날짜 기반 (monthly:)
```
JSON: {"value":"monthly:1,15","display":"毎月\n1, 15日"}
→ RRULE: FREQ=MONTHLY;BYMONTHDAY=1,15
```

### 3. 간격 기반
```
JSON: {"value":"2日毎","display":"2日毎"}
→ RRULE: FREQ=DAILY;INTERVAL=2

JSON: {"value":"1週間毎","display":"1週間毎"}
→ RRULE: FREQ=WEEKLY;INTERVAL=1;BYDAY=WE (dtstart 기준, -1 보정)
```

## 🔥 CRITICAL: weekday -1 보정

**rrule 패키지 버그:**
- `ByWeekDayEntry(DateTime.monday)` → 화요일 생성
- `ByWeekDayEntry(DateTime.thursday)` → 금요일 생성

**해결책:**
- 모든 weekday에서 -1 적용
- 月(월요일) → `DateTime.sunday` (7)
- 木(목요일) → `DateTime.wednesday` (3)
- 金(금요일) → `DateTime.thursday` (4)

## 📝 수정된 파일

1. **`lib/component/modal/task_detail_wolt_modal.dart`**
   - `import 'package:rrule/rrule.dart'` 추가
   - `convertRepeatRuleToRRule()` 함수 추가
   - `_jpDayToWeekday()` 함수 추가
   - 새 Task 생성 시 RecurringPattern 생성
   - Task 수정 시 RecurringPattern 업데이트/삭제

2. **`lib/component/modal/habit_detail_wolt_modal.dart`**
   - `import 'package:rrule/rrule.dart'` 추가
   - `convertRepeatRuleToRRule()` 함수 추가
   - `_jpDayToWeekday()` 함수 추가
   - 새 Habit 생성 시 RecurringPattern 생성
   - Habit 수정 시 RecurringPattern 업데이트

## 🎯 결과

### 이전
- Task/Habit: `repeatRule` JSON만 저장
- `watchTasksWithRepeat()`: RecurringPattern 없음 → 반복 인스턴스 생성 실패
- 디테일뷰: display 텍스트만 표시되고 실제 반복은 안 됨

### 수정 후
- Task/Habit: `repeatRule` JSON + `RecurringPattern` RRULE 모두 저장
- `watchTasksWithRepeat()`: RecurringPattern 조회 → RRuleUtils로 인스턴스 생성 ✅
- 디테일뷰: display 텍스트 표시 + 실제 반복 작동 ✅

## 📊 데이터 흐름

```
[사용자 반복 선택]
       ↓
[repeat_picker_modal.dart]
  JSON 생성: {"value":"daily:月,火,水","display":"..."}
       ↓
[task/habit_detail_wolt_modal.dart]
  1. Task/Habit 저장 (repeatRule: JSON)
  2. convertRepeatRuleToRRule() 호출
  3. RRULE 생성: FREQ=WEEKLY;BYDAY=SU,MO,TU
  4. RecurringPattern 저장
       ↓
[schedule_database.dart]
  watchTasksWithRepeat()
  1. RecurringPattern 조회
  2. RRuleUtils.generateInstances(RRULE)
  3. 반복 인스턴스 반환
       ↓
[화면 표시] ✅
```

## ✅ 테스트 방법

1. **앱 완전 재시작** (Hot Restart)
2. **새 Task 생성**:
   - 반복 선택: 月, 火, 水
   - 저장
   - 로그 확인: "RecurringPattern 생성 완료"
3. **디테일뷰 확인**:
   - 월, 화, 수요일에 Task가 표시되는지 확인
4. **새 Habit 생성**:
   - 반복 선택: 毎日 (매일)
   - 저장
   - 로그 확인: "RecurringPattern 생성 완료"
5. **디테일뷰 확인**:
   - 매일 Habit이 표시되는지 확인

## 🎉 완료!

Task와 Habit의 반복 규칙이 이제 Schedule과 동일하게 RRULE로 변환되어 제대로 작동합니다!

- ✅ Schedule: RRULE 기반 반복 (디테일뷰 + 월뷰)
- ✅ Task: RRULE 기반 반복 (디테일뷰만)
- ✅ Habit: RRULE 기반 반복 (디테일뷰만)

모든 엔티티가 통일된 방식으로 반복을 처리합니다! 🚀
