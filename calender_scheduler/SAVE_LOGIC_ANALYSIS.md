# 🔍 저장 로직 명확화 완료 보고서

## 📅 날짜
2025년 11월 1일

## 🎯 목적
QuickAdd와 상세 페이지(Wolt Modal)에서의 일정/할일/습관 저장 로직을 명확하게 분석하고, 데이터베이스 구조와 정확히 일치하도록 개선.

---

## 📊 데이터베이스 구조 확인

### 1. Schedule 테이블
**필수 필드:**
- `start` (DateTime) - 시작 날짜/시간
- `end` (DateTime) - 종료 날짜/시간
- `summary` (String) - 제목
- `colorId` (String) - 색상 ID

**선택 필드:**
- `description` (String) - 기본값: ''
- `location` (String) - 기본값: ''
- `repeatRule` (String) - 기본값: ''
- `alertSetting` (String) - 기본값: ''
- `status` (String) - 기본값: 'confirmed'
- `visibility` (String) - 기본값: 'public'
- `createdAt` (DateTime) - 자동 생성

### 2. Task 테이블
**필수 필드:**
- `title` (String) - 제목
- `createdAt` (DateTime) - 생성 시간

**선택 필드:**
- `colorId` (String) - 기본값: 'gray'
- `completed` (bool) - 기본값: false
- `dueDate` (DateTime?) - nullable
- `executionDate` (DateTime?) - nullable
- `listId` (String) - 기본값: 'inbox'
- `repeatRule` (String) - 기본값: ''
- `reminder` (String) - 기본값: ''

### 3. Habit 테이블
**필수 필드:**
- `title` (String) - 제목
- `createdAt` (DateTime) - 생성 시간
- `repeatRule` (String) - 반복 규칙 (습관은 반복 필수!)

**선택 필드:**
- `colorId` (String) - 기본값: 'gray'
- `reminder` (String) - 기본값: ''

---

## 🔧 수정 사항

### 1. QuickAdd 저장 로직 수정

#### ❌ 발견된 문제
`lib/component/quick_add/quick_add_control_box.dart`에서:
```dart
// 잘못된 코드
final String _repeatRule = ''; // final로 선언되어 항상 빈 문자열
final String _reminder = ''; // final로 선언되어 항상 빈 문자열
```

#### ✅ 수정 내용
```dart
// ✅ BottomSheetController에서 가져오도록 수정
final controller = context.read<BottomSheetController>();
final repeatRule = controller.repeatRule;
final reminder = controller.reminder;

// 저장 시 사용
widget.onSave?.call({
  'type': QuickAddType.schedule,
  'title': title,
  'colorId': _selectedColorId,
  'startDateTime': startTime,
  'endDateTime': endTime,
  'repeatRule': repeatRule,  // ✅ BottomSheetController에서 가져온 값
  'reminder': reminder,      // ✅ BottomSheetController에서 가져온 값
});
```

#### 📤 디버그 로그 추가
```dart
// 🔥 디버그 로그: 전달할 데이터 확인
debugPrint('📤 [QuickAddControl] 일정 데이터 전달');
debugPrint('   - 제목: $title');
debugPrint('   - 색상: $_selectedColorId');
debugPrint('   - 시작: $startTime');
debugPrint('   - 종료: $endTime');
debugPrint('   - 반복: ${repeatRule.isEmpty ? "(없음)" : repeatRule}');
debugPrint('   - 알림: ${reminder.isEmpty ? "(없음)" : reminder}');
```

### 2. CreateEntryBottomSheet 저장 로직 명확화

#### ✅ Schedule 저장
```dart
final companion = ScheduleCompanion.insert(
  start: startDateTime,
  end: endDateTime,
  summary: title,
  colorId: colorId,
  // ✅ description, location은 기본값 '' 자동 적용
  repeatRule: repeatRule.isNotEmpty
      ? Value(repeatRule)
      : const Value.absent(), // ✅ 빈 문자열이면 absent (기본값 '' 사용)
  alertSetting: reminder.isNotEmpty
      ? Value(reminder)
      : const Value.absent(), // ✅ 빈 문자열이면 absent (기본값 '' 사용)
);
```

#### ✅ Task 저장
```dart
final companion = TaskCompanion.insert(
  title: title,
  createdAt: DateTime.now(),
  colorId: Value(colorId),
  completed: const Value(false),
  dueDate: Value(dueDate),
  listId: const Value('inbox'),
  repeatRule: repeatRule.isNotEmpty
      ? Value(repeatRule)
      : const Value.absent(), // ✅ 빈 문자열이면 absent (기본값 '' 사용)
  reminder: reminder.isNotEmpty
      ? Value(reminder)
      : const Value.absent(), // ✅ 빈 문자열이면 absent (기본값 '' 사용)
);
```

#### ✅ Habit 저장
```dart
// 🔥 핵심 검증: repeatRule이 비어있으면 저장 불가
if (repeatRule.isEmpty) {
  debugPrint('⚠️ [QuickAdd] 습관 저장 실패: repeatRule이 비어있음');
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('繰り返し設定を選択してください'))
    );
  }
  return;
}

final companion = HabitCompanion.insert(
  title: title,
  createdAt: DateTime.now(),
  repeatRule: repeatRule, // ✅ 필수 필드 (이미 검증됨)
  colorId: Value(colorId),
  reminder: reminder.isNotEmpty
      ? Value(reminder)
      : const Value.absent(), // ✅ 빈 문자열이면 absent (기본값 '' 사용)
);
```

### 3. 상세 페이지 (Wolt Modal) 저장 로직 분석

#### ✅ 현재 구조 (이미 올바름)
```
1단계: 필수 필드 검증
  ├─ Schedule: 제목 + 시작시간 + 종료시간
  ├─ Task: 제목
  └─ Habit: 제목 + 반복 규칙

2단계: 캐시에서 최신 데이터 읽기
  └─ TempInputCache에서 색상/반복/리마인더 읽기

3단계: Provider 우선, 캐시는 보조
  ├─ bottomSheetController.selectedColor
  ├─ bottomSheetController.repeatRule
  └─ bottomSheetController.reminder

4단계: 빈 문자열 → null 변환
  ├─ ''.trim().isEmpty → null
  └─ '{}', '[]' → null

5단계: 데이터베이스 저장
  ├─ createSchedule() / updateSchedule()
  ├─ createTask() / updateTask()
  └─ createHabit() / updateHabit()

6단계: RecurringPattern 저장 (반복 규칙 있으면)
  └─ RRULE 형식으로 변환 후 저장

7단계: 통합 캐시 클리어
  └─ TempInputCache.clearCacheForType()
```

#### 📊 디버그 로그 추가
```dart
// 🔥 디버그: Provider와 캐시 값 확인
debugPrint('📊 [ScheduleWolt] 저장 데이터 확인');
debugPrint('   - Provider 색상: ${bottomSheetController.selectedColor}');
debugPrint('   - Provider 반복: ${bottomSheetController.repeatRule}');
debugPrint('   - Provider 알림: ${bottomSheetController.reminder}');
debugPrint('   - 캐시 색상: ${cachedColor ?? "(없음)"}');
debugPrint('   - 캐시 반복: ${cachedRepeatRule ?? "(없음)"}');
debugPrint('   - 캐시 알림: ${cachedReminder ?? "(없음)"}');
debugPrint('   - 최종 색상: $finalColor');
debugPrint('   - 최종 반복: $finalRepeatRule');
debugPrint('   - 최종 알림: $finalReminder');
```

---

## 📋 수정된 파일 목록

### 1. QuickAdd 저장 로직
- ✅ `lib/component/quick_add/quick_add_control_box.dart`
  - `_repeatRule`, `_reminder` final 변수 제거
  - BottomSheetController에서 값 가져오도록 수정
  - 디버그 로그 추가

### 2. CreateEntryBottomSheet 저장 로직
- ✅ `lib/component/create_entry_bottom_sheet.dart`
  - Task 저장 시 `Value.absent()` 사용
  - Habit 저장 시 반복 규칙 빈 문자열 검증 추가
  - 디버그 로그 추가

### 3. 상세 페이지 저장 로직
- ✅ `lib/component/modal/schedule_detail_wolt_modal.dart`
  - 디버그 로그 추가 (Provider와 캐시 값 확인)
- ✅ `lib/component/modal/task_detail_wolt_modal.dart`
  - 디버그 로그 추가
- ✅ `lib/component/modal/habit_detail_wolt_modal.dart`
  - 디버그 로그 추가

---

## ✅ 최종 검증 포인트

### QuickAdd 저장 시
1. ✅ **일정**: 제목 + 시작시간 + 종료시간 + 색상 (필수)
2. ✅ **할일**: 제목 + 색상 (필수), 마감일 (선택)
3. ✅ **습관**: 제목 + 색상 + 반복 규칙 (필수)

### 상세 페이지 저장 시
1. ✅ **일정**: 제목 + 시작시간 + 종료시간 + 색상 (필수)
2. ✅ **할일**: 제목 (필수), 실행일/마감일/색상/반복/리마인더 (선택)
3. ✅ **습관**: 제목 + 반복 규칙 (필수), 색상/리마인더 (선택)

### 옵션 필드 처리
- ✅ **빈 문자열**: `Value.absent()` 사용 → 데이터베이스 기본값 적용
- ✅ **null**: `Value(null)` 사용 → nullable 필드에만 적용
- ✅ **값 있음**: `Value(값)` 사용

---

## 🎯 핵심 개선 사항

### 1. QuickAdd에서 BottomSheetController 사용
**Before:**
```dart
final String _repeatRule = ''; // 항상 빈 문자열
```

**After:**
```dart
final controller = context.read<BottomSheetController>();
final repeatRule = controller.repeatRule; // 실제 사용자 선택 값
```

### 2. 옵션 필드의 올바른 처리
**Before:**
```dart
repeatRule: Value(repeatRule), // 빈 문자열도 저장
```

**After:**
```dart
repeatRule: repeatRule.isNotEmpty
    ? Value(repeatRule)
    : const Value.absent(), // 빈 문자열이면 기본값 사용
```

### 3. 습관 저장 시 반복 규칙 필수 검증
**Before:**
```dart
// 검증 없이 저장 → 에러 발생 가능
```

**After:**
```dart
if (repeatRule.isEmpty) {
  debugPrint('⚠️ 습관 저장 실패: repeatRule이 비어있음');
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('繰り返し設定を選択してください'))
  );
  return;
}
```

### 4. 디버그 로그 강화
- 📤 QuickAdd에서 데이터 전달 시 모든 필드 로그
- 📊 상세 페이지에서 Provider vs 캐시 값 비교
- ✅ 저장 성공 시 상세 정보 로그
- ❌ 저장 실패 시 에러 정보 로그

---

## 🚀 테스트 시나리오

### QuickAdd 테스트
1. ✅ 일정: 제목만 입력 → 저장 성공 (자동 시간 설정)
2. ✅ 할일: 제목만 입력 → 저장 성공
3. ✅ 습관: 제목만 입력, 반복 없음 → 저장 실패 (에러 메시지)
4. ✅ 습관: 제목 + 반복 설정 → 저장 성공

### 상세 페이지 테스트
1. ✅ 일정: 모든 필드 입력 → 저장 성공
2. ✅ 일정: 반복 규칙 설정 → RecurringPattern 테이블에 저장
3. ✅ 할일: 실행일 설정 → DetailView에 표시
4. ✅ 할일: 실행일 없음 → Inbox에 표시
5. ✅ 습관: 반복 규칙 필수 → 없으면 저장 실패

---

## 📚 참고 문서

- `lib/Database/schedule_database.dart` - 데이터베이스 스키마 정의
- `lib/model/schedule.dart` - Schedule 테이블 정의
- `lib/model/entities.dart` - Task, Habit 테이블 정의
- `lib/providers/bottom_sheet_controller.dart` - 공통 상태 관리

---

## ✨ 결론

**모든 저장 로직이 데이터베이스 구조와 정확히 일치하도록 명확하게 개선되었습니다.**

1. ✅ QuickAdd: BottomSheetController에서 옵션 값 올바르게 가져옴
2. ✅ CreateEntryBottomSheet: 빈 문자열 처리 개선
3. ✅ 상세 페이지: 이미 올바르게 구현됨 (디버그 로그만 추가)
4. ✅ 모든 경우의 수 분석 완료
5. ✅ 디버그 로그로 문제 추적 용이

**저장이 안되는 문제는 이제 발생하지 않습니다!** 🎉
