# ✅ 할일(Task) Wolt Modal 마이그레이션 완료

**날짜**: 2025.10.17  
**작업**: 할일 상세 모달을 Wolt 디자인 시스템으로 마이그레이션  
**완료**: ✅ 0 compile errors

---

## 📋 작업 요약

### 생성된 파일
- ✅ `/lib/component/modal/task_detail_wolt_modal.dart` (700+ lines)

### 주요 변경사항

#### 1. **Wolt Modal 구조 적용**
```dart
SliverWoltModalSheetPage(
  hasTopBarLayer: false,
  mainContentSliversBuilder: (context) => [
    SliverToBoxAdapter(
      child: Column(
        children: [
          TopNavi,
          TextField,
          DeadlineLabel,
          DeadlinePicker,
          DetailOptions,
          DeleteButton,
        ],
      ),
    ),
  ],
)
```

#### 2. **일정과의 차이점**

| 구분 | 일정 (Schedule) | 할일 (Task) |
|------|----------------|-------------|
| **타이틀** | "スケジュール" | "タスク" |
| **TextField** | "予定を追加" | "タスクを入力" |
| **Padding** | 24px | 28px |
| **FontWeight** | Bold | ExtraBold |
| **종일 토글** | ✅ | ❌ |
| **시간 선택** | ✅ 시작/종료 | ❌ |
| **마감일** | ❌ | ✅ 締め切り |
| **DB 필드** | start/end | dueDate |

#### 3. **마감일 표시 (2가지 상태)**

**미선택 상태 (isEmpty)**:
```css
- 크기: 64 x 94px
- Stack(배경 숫자 "10" #EEEEEE + + 버튼 오버레이)
- 버튼: 32x32px, #262626, border-radius: 100px
```

**선택됨 상태 (isPresent)**:
```css
- 날짜: "08.24." - ExtraBold 33px, #111111
- 연도: "2025" - ExtraBold 19px, #E75858 (빨간색!)
- Padding: 0px 28px → 0px 24px (inner)
```

#### 4. **DetailOptions (동일)**
```dart
- 반복: showWoltRepeatOption()
- 리마인더: showWoltReminderOption()
- 색상: showWoltColorPicker()
```

---

## 🎨 Figma 디자인 스펙

### Modal Container
- **Size**: 393 x 615px (isEmpty) / 584px (isPresent)
- **Background**: #FCFCFC
- **Border**: 1px solid rgba(17, 17, 17, 0.1)
- **Shadow**: 0px 2px 20px rgba(165, 165, 165, 0.2)
- **Border radius**: 36px 36px 0px 0px

### TopNavi (60px)
- **Padding**: 28px 28px 9px 28px
- **Title**: "タスク" - Bold 16px
  - isEmpty: #505050
  - isPresent: #7A7A7A
- **Button**: "完了" - ExtraBold 13px, #FAFAFA on #111111, 74x42px

### TextField (51px)
- **Padding**: 12px 0px, inner: 0px 28px ✨
- **Placeholder**: "タスクを入力" - Bold 19px, #AAAAAA
- **Text**: ExtraBold 19px, #111111 ✨

### Deadline Label (32px)
- **Padding**: 4px 28px
- **Icon**: 19x19px flag, #111111
- **Text**: "締め切り" - Bold 13px, #111111

### Deadline Display
**미선택**:
- Width: 64px, Height: 94px
- Stack(background "10" #EEEEEE + button)

**선택됨**:
- Date: "08.24." - ExtraBold 33px, #111111, height: 1.2
- Year: "2025" - ExtraBold 19px, #E75858 🎯

### DetailOptions (64px)
- **Padding**: 0px 48px
- **Button**: 64x64px, white, border-radius: 24px
- **Icons**: 24x24px, #111111
- **Gap**: 8px between buttons

### Delete Button (52px)
- **Size**: 100x52px
- **Background**: #FAFAFA
- **Icon**: delete_outline, 20px, #F74A4A
- **Text**: "削除" - Bold 13px, #F74A4A

---

## 🔧 기술 구현

### Provider 구조
```dart
TaskFormController:
  - titleController: TextEditingController
  - dueDate: DateTime? (마감일)
  - completed: bool

BottomSheetController:
  - selectedColor: String
  - reminder: String
  - repeatRule: String
```

### DB 연동
```dart
// 생성
await db.createTask(
  TaskCompanion.insert(
    title: taskController.title,
    createdAt: selectedDate,
    listId: const Value('default'),
    dueDate: Value(taskController.dueDate),
    colorId: Value(bottomSheetController.selectedColor),
    reminder: Value(bottomSheetController.reminder),
    repeatRule: Value(bottomSheetController.repeatRule),
  ),
);

// 수정
await (db.update(db.task)..where((tbl) => tbl.id.equals(task.id))).write(
  TaskCompanion(
    title: Value(taskController.title),
    dueDate: Value(taskController.dueDate),
    colorId: Value(bottomSheetController.selectedColor),
    reminder: Value(bottomSheetController.reminder),
    repeatRule: Value(bottomSheetController.repeatRule),
  ),
);

// 삭제
await db.deleteTask(task.id);
```

---

## ✅ 검증 체크리스트

### 기본 기능
- [ ] 할일 제목 입력
- [ ] 마감일 선택/해제
- [ ] 마감일 표시 (날짜 + 연도 빨간색)
- [ ] 반복 옵션 선택
- [ ] 리마인더 설정
- [ ] 색상 선택
- [ ] 할일 저장 (생성/수정)
- [ ] 할일 삭제

### UI/UX
- [ ] TopNavi 제목 색상 변경 (isEmpty/isPresent)
- [ ] TextField 28px padding 확인
- [ ] 마감일 미선택 시 Stack 구조 확인
- [ ] 마감일 선택 시 연도 빨간색 확인
- [ ] DetailOptions 3개 버튼 확인
- [ ] 삭제 버튼 빨간색 확인

### Provider/DB
- [ ] TaskFormController dueDate 업데이트
- [ ] BottomSheetController 옵션 업데이트
- [ ] DB createTask 정상 동작
- [ ] DB update 정상 동작
- [ ] DB deleteTask 정상 동작

---

## 🎯 핵심 차이점 정리

### 일정 → 할일 변경사항

1. **TextField**
   - Padding: 24px → 28px ✨
   - FontWeight: Bold → ExtraBold ✨

2. **시간 → 마감일**
   - 시작/종료 시간 → 단일 마감일
   - Stack 구조 유지 (미선택 시)
   - 연도 빨간색 강조 (#E75858) 🎯

3. **DB 필드**
   - start/end → dueDate
   - alertSetting → reminder
   - 동일: colorId, repeatRule

4. **종일 토글 제거**
   - 일정: isAllDay 토글 있음
   - 할일: 토글 없음 (마감일만)

---

## 📝 사용 방법

```dart
// 새 할일 생성
showTaskDetailWoltModal(
  context,
  task: null,
  selectedDate: DateTime.now(),
);

// 기존 할일 수정
showTaskDetailWoltModal(
  context,
  task: existingTask,
  selectedDate: DateTime.now(),
);
```

---

## 🚀 마이그레이션 완료!

### ✅ 삭제된 파일
- ❌ `/lib/component/full_task_bottom_sheet.dart` (800+ lines)

### ✅ 수정된 파일
1. **`/lib/screen/date_detail_view.dart`**
   ```dart
   // Before
   import '../component/full_task_bottom_sheet.dart';
   Navigator.of(context).push(
     IOSCardPageRoute(
       builder: (context) => FullTaskBottomSheet(selectedDate: _currentDate),
     ),
   );
   
   // After
   import '../component/modal/task_detail_wolt_modal.dart';
   showTaskDetailWoltModal(
     context,
     task: task,
     selectedDate: _currentDate,
   );
   ```

2. **`/lib/component/quick_add/quick_add_control_box.dart`**
   ```dart
   // Before
   import '../full_task_bottom_sheet.dart';
   showModalBottomSheet(
     context: context,
     builder: (context) => FullTaskBottomSheet(...),
   );
   
   // After
   import '../modal/task_detail_wolt_modal.dart';
   showTaskDetailWoltModal(
     context,
     task: null,
     selectedDate: widget.selectedDate,
   );
   ```

### 🎯 테스트 체크리스트
- [ ] Quick Add에서 할일 추가 동작 확인
- [ ] 날짜 상세에서 할일 클릭 → 모달 표시
- [ ] 마감일 선택 (미선택/선택) 동작 확인
- [ ] 연도 빨간색 표시 확인 (#E75858)
- [ ] 반복/리마인더/색상 옵션 동작 확인
- [ ] 할일 저장/수정/삭제 DB 확인

---

**마이그레이션 완료 상태**: ✅ **SUCCESS**  
**컴파일 에러**: **0개**  
**삭제된 라인**: ~800 lines  
**새 파일**: task_detail_wolt_modal.dart (700+ lines)
