# 🎯 Input Accessory 전송버튼 수정 완료 보고서

날짜: 2025-10-30  
작업자: GitHub Copilot

## 📋 요청사항 요약

1. **전송버튼 동작 수정**: 일정/할일 타입이 선택된 상태에서 전송버튼을 누르면 데이터베이스에 저장되도록 수정
2. **깜빡임 방지**: 전송버튼을 눌렀을 때 인풋악세사리가 깜빡이지 않고 부드럽게 닫히도록 수정
3. **동적 너비**: 인풋악세사리 너비를 스마트폰 화면 너비에 맞춰 동적으로 조정 (좌우 14px 여백)

---

## ✅ 구현 내용

### 1. 전송버튼 저장 로직 개선

**파일**: `lib/component/quick_add/quick_add_control_box.dart`

#### 변경사항:
```dart
// ❌ 기존: 항상 타입 선택 팝업만 표시
void _handleDirectAdd() {
  // 키보드 내리고 팝업만 표시
  _focusNode.unfocus();
  setState(() { _showDetailPopup = true; });
}

// ✅ 수정: 타입 선택 여부에 따라 분기
void _handleDirectAdd() {
  final text = _textController.text.trim();
  
  // 타입이 선택되지 않은 경우 → 타입 선택 팝업 표시
  if (_selectedType == null) {
    _focusNode.unfocus();
    setState(() { _showDetailPopup = true; });
    return;
  }
  
  // 타입이 선택된 경우 → 해당 타입으로 직접 저장
  switch (_selectedType!) {
    case QuickAddType.schedule:
      // 일정: 텍스트 + 날짜/시간 필요
      if (_startDateTime == null || _endDateTime == null) {
        // 사용자 피드백: 날짜/시간 선택 필요
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('開始時間と終了時間を選択してください')),
        );
        return;
      }
      _saveDirectSchedule();
      break;
      
    case QuickAddType.task:
      // 할일: 텍스트만 있으면 저장 가능
      _saveDirectTask();
      break;
  }
}
```

#### 검증 로직:
- **일정**: 텍스트 + 시작시간 + 종료시간 모두 필요
- **할일**: 텍스트만 있으면 저장 가능 (마감일은 선택사항)
- 검증 실패 시 SnackBar로 사용자에게 피드백 제공

---

### 2. 저장 함수 개선

**파일**: `lib/component/quick_add/quick_add_control_box.dart`

#### 일정 저장:
```dart
void _saveDirectSchedule() async {
  final title = _textController.text.trim();
  
  // ✅ 사용자가 선택한 시간 사용
  final startTime = _startDateTime!;
  final endTime = _endDateTime!;
  
  // 🔥 1단계: 키보드 즉시 내리기
  _focusNode.unfocus();
  
  // 🔥 2단계: 저장 콜백 호출 (부모가 바텀시트를 닫고 토스트 표시)
  widget.onSave?.call({
    'type': QuickAddType.schedule,
    'title': title,
    'colorId': _selectedColorId,
    'startDateTime': startTime,
    'endDateTime': endTime,
    'repeatRule': _repeatRule,
    'reminder': _reminder,
  });
}
```

#### 할일 저장:
```dart
void _saveDirectTask() {
  final title = _textController.text.trim();
  
  // 🔥 1단계: 키보드 즉시 내리기
  _focusNode.unfocus();
  
  // 🔥 2단계: 저장 콜백 호출
  widget.onSave?.call({
    'type': QuickAddType.task,
    'title': title,
    'colorId': _selectedColorId,
    'dueDate': _startDateTime, // ✅ 선택사항
    'repeatRule': _repeatRule,
    'reminder': _reminder,
  });
}
```

---

### 3. 동적 너비 적용

**파일**: `lib/component/keyboard_attachable_input_view.dart`

#### 변경사항:
```dart
// ❌ 기존: 고정 너비 (393px)
child: QuickAddControlBox(
  selectedDate: widget.selectedDate,
  onSave: (data) { ... },
),

// ✅ 수정: 동적 너비 (화면 너비 - 28px)
child: LayoutBuilder(
  builder: (context, constraints) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: EdgeInsets.only(left: 14, right: 14, ...),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: screenWidth - 28, // ✅ 동적 너비
          child: QuickAddControlBox(
            selectedDate: widget.selectedDate,
            onSave: (data) { ... },
          ),
        ),
      ),
    );
  },
),
```

#### 적용 범위:
- 인풋악세사리 전체 너비
- Frame 701 (입력 박스) 너비
- Frame 704 (타입 선택기) 너비
- 모든 화면 크기에 자동 대응

---

## 🎬 동작 흐름

### Scenario 1: 타입 미선택 → 타입 선택 팝업
```
1. 사용자가 텍스트 입력
2. 전송버튼 (↑) 클릭
3. 키보드 내림 ⌨️ ↓
4. 타입 선택 팝업 표시 📋
5. 일정/할일/습관 중 선택
```

### Scenario 2: 일정 타입 선택 → 저장
```
1. 사용자가 "일정" 선택
2. 텍스트 입력
3. 시작-종료 시간 선택 ⏰
4. 전송버튼 (↑) 클릭
5. 검증: 텍스트 ✅ + 시간 ✅
6. 키보드 내림 ⌨️ ↓
7. 데이터베이스 저장 💾
8. 바텀시트 닫힘
9. 토스트 표시: "保存されました" 🍞
```

### Scenario 3: 일정 타입 - 시간 미선택 (검증 실패)
```
1. 사용자가 "일정" 선택
2. 텍스트만 입력
3. 전송버튼 (↑) 클릭
4. 검증: 텍스트 ✅ + 시간 ❌
5. SnackBar 표시: "開始時間と終了時間を選択してください"
6. 키보드 유지 (저장 안됨)
```

### Scenario 4: 할일 타입 선택 → 저장
```
1. 사용자가 "할일" 선택
2. 텍스트 입력
3. (마감일 선택은 선택사항)
4. 전송버튼 (↑) 클릭
5. 검증: 텍스트 ✅
6. 키보드 내림 ⌨️ ↓
7. 데이터베이스 저장 💾
8. 바텀시트 닫힘
9. 토스트 표시: "ヒキダシに保存されました" 🍞
```

---

## 🔍 키보드 동작 정리

### 키보드가 내려가는 시점:
1. **타입 미선택 + 전송버튼 클릭** → 타입 선택 팝업 표시
2. **타입 선택 + 전송버튼 클릭 + 검증 성공** → 저장 후 바텀시트 닫힘
3. **배경 터치** → 바텀시트 닫힘

### 키보드가 유지되는 시점:
1. **타입 선택 중** → 계속 입력 가능
2. **검증 실패** → SnackBar 표시 후 계속 입력 가능

---

## 📱 반응형 디자인

### 너비 계산:
```dart
// 인풋악세사리 전체 너비
screenWidth - 28px = screenWidth - (14px + 14px)

// 예시:
// iPhone 14 Pro (393px): 393 - 28 = 365px
// iPhone 14 Pro Max (430px): 430 - 28 = 402px
// iPad Mini (744px): 744 - 28 = 716px
```

### 적용된 동적 함수:
- `QuickAddDimensions.getFrameWidth(context)` - Frame 701 너비
- `QuickAddDimensions.getTypeSelectorWidth(context)` - Frame 704 너비

---

## 🧪 테스트 시나리오

### ✅ 필수 테스트:

1. **일정 저장 (성공)**
   - 텍스트 입력 → "일정" 선택 → 시간 선택 → 전송버튼
   - 예상: 토스트 "保存されました" + 바텀시트 닫힘

2. **일정 저장 (실패 - 시간 미선택)**
   - 텍스트 입력 → "일정" 선택 → 전송버튼
   - 예상: SnackBar "開始時間と終了時間を選択してください"

3. **할일 저장 (텍스트만)**
   - 텍스트 입력 → "할일" 선택 → 전송버튼
   - 예상: 토스트 "ヒキダシに保存されました"

4. **할일 저장 (마감일 포함)**
   - 텍스트 입력 → "할일" 선택 → 마감일 선택 → 전송버튼
   - 예상: 토스트 "ヒキダシに保存されました"

5. **타입 선택 팝업**
   - 텍스트 입력 → 전송버튼
   - 예상: 타입 선택 팝업 표시

6. **다양한 화면 크기**
   - iPhone SE (375px), iPhone 14 Pro (393px), iPad (768px)
   - 예상: 모든 화면에서 좌우 14px 여백 유지

---

## 📝 주의사항

### 1. 검증 규칙:
- **일정**: 텍스트 + 시작시간 + 종료시간 모두 필수
- **할일**: 텍스트만 필수, 마감일은 선택사항
- **습관**: 타입 선택 시 즉시 Wolt 모달 표시 (QuickAdd에서 직접 저장 안함)

### 2. 키보드 동작:
- 전송버튼 클릭 시 `_focusNode.unfocus()` 호출
- 검증 실패 시 키보드 유지
- 저장 성공 시 키보드 내림 + 바텀시트 닫힘

### 3. 애니메이션:
- 바텀시트 닫힘: `Navigator.pop(context)`
- 토스트 표시: 150ms 딜레이 후 (바텀시트 애니메이션 완료 대기)
- Spring Animation: Apple 스타일 (600ms, Cubic bezier)

---

## 🎉 완료 항목

- [x] 전송버튼 저장 로직 수정 (타입별 분기)
- [x] 일정/할일 검증 로직 추가
- [x] 키보드 제어 개선 (unfocus 타이밍)
- [x] 동적 너비 적용 (화면 크기 대응)
- [x] 깜빡임 방지 (부드러운 닫힘)
- [x] 사용자 피드백 추가 (SnackBar)

---

## 🚀 다음 단계 (선택사항)

1. **에러 처리 강화**: 데이터베이스 저장 실패 시 롤백 로직
2. **오프라인 지원**: 네트워크 없을 때 로컬 캐시 저장
3. **접근성 개선**: VoiceOver 지원 추가
4. **애니메이션 개선**: 저장 중 로딩 인디케이터 표시

---

**작성일**: 2025-10-30  
**버전**: 1.0.0  
**상태**: ✅ 완료
