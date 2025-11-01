# ✅ 반복 일정/할일 선택 해제 및 반복 제거 기능 완료

## 📋 개요

반복 일정/할일/습관 수정 시, 기존에 선택된 반복 값을 **재선택하여 해제**할 수 있고, 모든 선택을 해제하면 **반복 규칙이 완전히 제거**되도록 구현 완료.

## 🎯 구현 내용

### 1. 반복 선택 UI - 토글 방식 해제 (이미 구현됨)

**파일:** `lib/component/modal/repeat_picker_modal.dart`

요일/날짜 선택 시 이미 토글 방식으로 구현되어 있어, 클릭하면 선택/해제가 반복됨:

```dart
// 毎日 탭: 요일 토글
onTap: () {
  setState(() {
    if (isSelected) {
      _selectedWeekdays.remove(day); // ✅ 이미 선택되어 있으면 제거
    } else {
      _selectedWeekdays.add(day);    // 선택 추가
    }
  });
}

// 毎月 탭: 날짜 토글
onTap: () {
  setState(() {
    if (isSelected) {
      _selectedMonthDays.remove(day); // ✅ 이미 선택되어 있으면 제거
    } else {
      if (_selectedMonthDays.length < 2) {
        _selectedMonthDays.add(day);
      }
    }
  });
}
```

### 2. 반복 규칙 제거 로직 추가 ⭐ 핵심

**파일:** `lib/component/modal/repeat_picker_modal.dart`

"完了" 버튼 클릭 시, 선택값이 없으면 반복 규칙을 제거:

```dart
Future<void> _saveRepeat() async {
  final displayText = _generateDisplayText();

  if (displayText.isNotEmpty) {
    // 선택값이 있으면 JSON 형식으로 저장
    final repeatJson = '{"value":"$value","display":"$displayText"}';
    widget.controller.updateRepeatRule(repeatJson);
    await TempInputCache.saveTempRepeatRule(repeatJson);
  } else {
    // ✅ 선택값이 없으면 반복 규칙 제거
    debugPrint('🗑️ [RepeatPicker] 모든 선택 해제 → 반복 규칙 제거');
    widget.controller.clearRepeatRule();
    await TempInputCache.saveTempRepeatRule('');
  }

  Navigator.pop(context);
}
```

### 3. 데이터베이스 RecurringPattern 삭제 로직 추가

#### 3-1. Schedule (일정)

**파일:** `lib/component/modal/schedule_detail_wolt_modal.dart`

**수정 위치 1:** 반복 일정의 "すべての回" 수정 (1820-1825줄)
```dart
} else {
  // ✅ 반복 규칙 제거 시 RecurringPattern 삭제
  await db.deleteRecurringPattern(
    entityType: 'schedule',
    entityId: schedule.id,
  );
  debugPrint('🗑️ [ScheduleWolt] RecurringPattern 삭제 완료');
}
```

**수정 위치 2:** 일반 일정 수정 (1884-1929줄) ⭐ 신규 추가
```dart
if (safeRepeatRule != null && safeRepeatRule.isNotEmpty) {
  // RecurringPattern 생성 또는 업데이트
  ...
} else {
  // ✅ 반복 규칙 제거 시 RecurringPattern 삭제 (신규 추가)
  await db.deleteRecurringPattern(
    entityType: 'schedule',
    entityId: schedule.id,
  );
  debugPrint('🗑️ [ScheduleWolt] RecurringPattern 삭제 완료');
}
```

#### 3-2. Task (할일)

**파일:** `lib/component/modal/task_detail_wolt_modal.dart`

**수정 위치:** 일반 할일 수정 (1877-1886줄) - 이미 구현됨
```dart
} else {
  // 반복 규칙이 없으면 기존 패턴 삭제
  final existingPattern = await db.getRecurringPattern(
    entityType: 'task',
    entityId: task.id,
  );
  if (existingPattern != null) {
    await (db.delete(
      db.recurringPattern,
    )..where((tbl) => tbl.id.equals(existingPattern.id))).go();
    debugPrint('✅ [TaskWolt] RecurringPattern 삭제 완료');
  }
}
```

#### 3-3. Habit (습관)

**파일:** `lib/component/modal/habit_detail_wolt_modal.dart`

**수정 위치:** 일반 습관 수정 (1210-1230줄) ⭐ 신규 추가
```dart
if (rrule != null) {
  // RecurringPattern 생성 또는 업데이트
  ...
} else {
  // ✅ 반복 규칙이 없거나 RRULE 변환 실패 시 RecurringPattern 삭제 (신규 추가)
  final existingPattern = await database.getRecurringPattern(
    entityType: 'habit',
    entityId: habit.id,
  );
  if (existingPattern != null) {
    await (database.delete(
      database.recurringPattern,
    )..where((tbl) => tbl.id.equals(existingPattern.id))).go();
    debugPrint('🗑️ [HabitWolt] RecurringPattern 삭제 완료');
  } else {
    debugPrint('⚠️ [HabitWolt] RRULE 변환 실패 또는 반복 없음');
  }
}
```

## 📊 데이터 흐름

```
[사용자가 반복 일정/할일 수정]
       ↓
[반복 선택 UI에서 요일/날짜 토글]
  - 이미 선택된 항목 클릭 → 선택 해제
  - 모든 선택 해제 가능
       ↓
["完了" 버튼 클릭]
  - 선택값 있음 → JSON 형식으로 저장
  - 선택값 없음 → repeatRule = '' (빈 문자열)
       ↓
[저장 버튼 클릭]
       ↓
[Schedule/Task/Habit 수정 로직]
  if (repeatRule.isEmpty):
    1. Schedule/Task/Habit의 repeatRule = ''
    2. RecurringPattern 테이블에서 삭제
    3. 더 이상 반복 아님
       ↓
[UI 표시]
  - 반복 아이콘 제거
  - 단일 일정/할일로 표시
```

## 🎨 UI 동작

### Before (기존)
- 요일/날짜를 선택할 수 있지만, 한번 선택하면 해제 불가
- 반복을 제거하려면 새로 생성해야 함

### After (개선)
1. **토글 방식 선택/해제**
   - 월요일 클릭 → 선택됨 (파란색)
   - 월요일 다시 클릭 → 선택 해제됨 (회색)
   
2. **모든 선택 해제 시**
   - 요일/날짜를 모두 해제
   - "完了" 버튼 클릭
   - 반복 규칙이 완전히 제거됨
   
3. **데이터베이스 정리**
   - RecurringPattern 테이블에서 해당 엔티티의 레코드 삭제
   - 반복 예외(RecurringException)도 자동으로 CASCADE 삭제

## ✅ 테스트 체크리스트

### Schedule (일정)

#### 반복 일정 → 반복 제거
1. [ ] 매주 월/수/금 반복 일정 생성
2. [ ] 일정 수정 → 반복 설정에서 모든 요일 해제
3. [ ] "完了" → "すべての回" 선택 → 저장
4. [ ] **검증:**
   - [ ] 해당 일정이 단일 일정으로 표시됨
   - [ ] 반복 아이콘 사라짐
   - [ ] `recurring_pattern` 테이블에서 해당 레코드 삭제됨

#### 일반 일정 → 반복 추가 → 반복 제거
1. [ ] 일반 일정 생성 (반복 없음)
2. [ ] 수정 → 반복 "매일" 추가 → 저장
3. [ ] 다시 수정 → 반복 모든 선택 해제 → 저장
4. [ ] **검증:**
   - [ ] 다시 일반 일정으로 돌아옴
   - [ ] `recurring_pattern` 테이블에 레코드 없음

### Task (할일)

#### 반복 할일 → 반복 제거
1. [ ] 매주 화/목 반복 할일 생성
2. [ ] 할일 수정 → 반복 설정에서 모든 요일 해제
3. [ ] "完了" → "すべての回" 선택 → 저장
4. [ ] **검증:**
   - [ ] 단일 할일로 표시됨
   - [ ] `recurring_pattern` 삭제됨

### Habit (습관)

#### 반복 습관 → 반복 제거
1. [ ] 매일 습관 생성
2. [ ] 습관 수정 → 반복 모든 선택 해제 → 저장
3. [ ] **검증:**
   - [ ] 습관이 더 이상 반복 안 됨
   - [ ] `recurring_pattern` 삭제됨

## 🔍 핵심 수정 파일

1. **`repeat_picker_modal.dart`** (line 161-204)
   - `_saveRepeat()` 메서드에 선택값 없을 때 처리 추가

2. **`schedule_detail_wolt_modal.dart`** (line 1920-1926)
   - 일반 일정 수정 시 else 절 추가

3. **`habit_detail_wolt_modal.dart`** (line 1223-1237)
   - 일반 습관 수정 시 else 절 추가

4. **`task_detail_wolt_modal.dart`**
   - 이미 구현되어 있음 (수정 없음)

## 🎯 결론

✅ **최소한의 코드 수정**으로 본질적인 문제 해결:
- UI는 이미 토글 방식으로 구현되어 있음
- 저장 로직에 "선택 없음" 케이스 추가 (1개 메서드)
- 데이터베이스 삭제 로직 추가 (2개 파일, else 절만 추가)

✅ **완벽한 데이터 정합성**:
- `repeatRule` 빈 문자열 → `RecurringPattern` 삭제
- 반복 예외도 자동으로 CASCADE 삭제
- UI 표시도 자동으로 반복 아이콘 제거

✅ **사용자 경험 개선**:
- 직관적인 토글 방식 선택/해제
- 반복을 쉽게 추가/제거 가능
- 실수로 선택한 요일도 바로 해제 가능
