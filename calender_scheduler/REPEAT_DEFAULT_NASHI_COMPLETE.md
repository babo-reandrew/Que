# ✅ 일정/할일 반복 옵션 기본값 "なし" 설정 완료

## 📋 개요

일정(Schedule)과 할일(Task) 생성 시 **반복 옵션의 기본값을 "なし" (없음)**로 표시하도록 수정 완료.

## 🎯 구현 내용

### 1. 반복 버튼 UI - "なし" 표시 추가

**기존 문제:**
- 반복 옵션이 비어있을 때 아이콘만 표시됨
- 사용자가 기본값이 무엇인지 명확히 알 수 없음

**해결:**
- 반복 옵션이 비어있을 때 **"なし"** 텍스트 표시
- Schedule과 Task 모두 적용

**수정 파일:**
1. `lib/component/modal/schedule_detail_wolt_modal.dart` (line 1280-1330)
2. `lib/component/modal/task_detail_wolt_modal.dart` (line 1345-1395)

```dart
// ✅ Before: 아이콘만 표시
child: displayText == null
    ? const Icon(
        Icons.repeat,
        size: 24,
        color: Color(0xFF111111),
      )
    : null,

// ✅ After: "なし" 텍스트 표시
child: displayText == null
    ? Center(
        child: Text(
          'なし', // ✅ 반복 없음 표시
          style: const TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.4,
            letterSpacing: -0.06,
            color: Color(0xFF111111),
          ),
        ),
      )
    : null,
```

### 2. 기본값 로직 (이미 구현됨)

**BottomSheetController 초기화:**
```dart
void reset() {
  _selectedColor = 'gray';
  _repeatRule = ''; // ✅ 기본값: 빈 문자열
  _reminder = '';
  notifyListeners();
}
```

**Schedule/Task 저장 시:**
```dart
// Provider에서 반복 규칙 가져오기
final safeRepeatRule = bottomSheetController.repeatRule.isNotEmpty
    ? bottomSheetController.repeatRule
    : null; // ✅ 비어있으면 null로 저장

// 데이터베이스 저장
repeatRule: Value(safeRepeatRule ?? ''), // ✅ null이면 빈 문자열
```

**데이터베이스 컬럼 정의:**
```dart
// lib/model/schedule.dart
TextColumn get repeatRule =>
    text().withDefault(const Constant(''))()); // ✅ 기본값: 빈 문자열
```

### 3. Habit은 기존대로 유지

**Habit은 항상 반복 필수:**
- Habit 생성 시 기본값: "毎日" (매일)
- 반복 없는 습관은 의미가 없기 때문

```dart
// lib/component/modal/habit_detail_wolt_modal.dart (line 118-122)
// 기본 반복 규칙: 매일 (주 7일 전체)
final defaultRepeatRule =
    '{"type":"daily","weekdays":[1,2,3,4,5,6,7],"display":"毎日"}';
bottomSheetController.updateRepeatRule(defaultRepeatRule);
debugPrint('✅ [HabitWolt] 기본 반복 규칙 설정: 毎日 (7日)');
```

## 📊 데이터 흐름

### Schedule/Task 생성

```
[새 일정/할일 생성]
       ↓
[BottomSheetController.reset()]
  _repeatRule = '' // ✅ 빈 문자열
       ↓
[UI 표시]
  반복 버튼: "なし" 표시 // ✅ 명확한 기본값
       ↓
[사용자가 반복 선택 안 함]
       ↓
[저장 버튼 클릭]
  safeRepeatRule = null
  repeatRule = '' // ✅ 빈 문자열 저장
       ↓
[데이터베이스]
  repeatRule = '' // ✅ 반복 없음
  RecurringPattern 테이블에 레코드 없음
       ↓
[UI 표시]
  반복 아이콘 없음, 단일 일정/할일로 표시
```

### Habit 생성

```
[새 습관 생성]
       ↓
[BottomSheetController.reset()]
       ↓
[기본 반복 규칙 설정]
  _repeatRule = '{"type":"daily","weekdays":[1,2,3,4,5,6,7],"display":"毎日"}'
       ↓
[UI 표시]
  반복 버튼: "毎日" 표시
       ↓
[저장]
  반복 규칙: 매일 (7일)
```

## 🎨 UI 변경사항

### Before (기존)
**Schedule/Task:**
- 반복 버튼: 반복 아이콘(🔁)만 표시
- 사용자가 기본값을 모름

**Habit:**
- 반복 버튼: "毎日" 표시 (기본값)

### After (개선)
**Schedule/Task:**
- 반복 버튼: **"なし"** 표시 ✅
- 사용자가 기본값이 "없음"임을 명확히 인식
- 필요시 반복 옵션을 선택할 수 있음

**Habit:**
- 변경 없음 (기존대로 "毎日")

## ✅ 테스트 체크리스트

### Schedule (일정)

#### 새 일정 생성 - 기본값 확인
1. [ ] 새 일정 생성 모달 열기
2. [ ] **검증:**
   - [ ] 반복 버튼에 "なし" 표시됨
   - [ ] 아이콘이 아닌 텍스트로 표시됨

#### 새 일정 저장 - 반복 없음
1. [ ] 새 일정 생성
2. [ ] 반복 옵션 선택하지 않음 (기본값 유지)
3. [ ] 저장
4. [ ] **검증:**
   - [ ] 데이터베이스 `repeatRule = ''` (빈 문자열)
   - [ ] `recurring_pattern` 테이블에 레코드 없음
   - [ ] 일정 목록에서 반복 아이콘 표시 안 됨

#### 반복 옵션 선택 후 저장
1. [ ] 새 일정 생성
2. [ ] 반복 옵션 선택 (예: "毎日")
3. [ ] 저장
4. [ ] **검증:**
   - [ ] 반복 버튼에 "毎日" 표시됨
   - [ ] 데이터베이스 `repeatRule` 값 저장됨
   - [ ] `recurring_pattern` 테이블에 레코드 생성됨

### Task (할일)

#### 새 할일 생성 - 기본값 확인
1. [ ] 새 할일 생성 모달 열기
2. [ ] **검증:**
   - [ ] 반복 버튼에 "なし" 표시됨

#### 새 할일 저장 - 반복 없음
1. [ ] 새 할일 생성
2. [ ] 반복 옵션 선택하지 않음
3. [ ] 저장
4. [ ] **검증:**
   - [ ] 데이터베이스 `repeatRule = ''`
   - [ ] 반복 아이콘 표시 안 됨

### Habit (습관)

#### 새 습관 생성 - 기본값 확인
1. [ ] 새 습관 생성 모달 열기
2. [ ] **검증:**
   - [ ] 반복 버튼에 "毎日" 표시됨 (변경 없음)

## 🔍 핵심 수정 파일

1. **`schedule_detail_wolt_modal.dart`** (line 1280-1330)
   - 반복 버튼에 "なし" 표시 추가

2. **`task_detail_wolt_modal.dart`** (line 1345-1395)
   - 반복 버튼에 "なし" 표시 추가

## 📝 기존 로직 (수정 없음)

1. **`providers/bottom_sheet_controller.dart`**
   - `reset()`: `_repeatRule = ''` (이미 빈 문자열)

2. **`model/schedule.dart`, `model/task.dart`**
   - `repeatRule` 컬럼: 기본값 빈 문자열

3. **저장 로직**
   - 비어있으면 빈 문자열로 저장
   - RecurringPattern 테이블에 레코드 생성 안 함

## 🎯 결론

✅ **사용자 경험 개선:**
- Schedule과 Task의 기본 반복 옵션이 "なし"로 명확히 표시됨
- 사용자가 반복이 없음을 직관적으로 인식할 수 있음

✅ **데이터 정합성:**
- 기본값이 빈 문자열로 데이터베이스에 저장됨
- RecurringPattern 테이블에 불필요한 레코드 생성 안 함

✅ **Habit 구분:**
- Habit은 항상 반복 필수이므로 기본값 "毎日" 유지
- 일정/할일과 습관의 특성을 명확히 구분

✅ **최소한의 코드 수정:**
- UI 표시 부분만 수정 (아이콘 → "なし" 텍스트)
- 기존 로직은 이미 올바르게 구현되어 있음
