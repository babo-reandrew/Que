# Keyboard Position Lock Implementation

## 🎯 핵심 요구사항

> **"키보드 올라오고 올라온 그곳이야!! 그곳의 중심값을 화면의 y값에 고정"**

입력박스는 **키보드 상단 Y 좌표에 고정**되며, 追加 버튼 클릭 시:
1. 키보드는 내려감
2. 입력박스는 그 자리에 고정
3. Frame 705는 입력박스 바로 아래 표시

## 📐 시각화

### 상태 1: 키보드 올라옴 (입력 중)
```
┌─────────────────────────────┐
│      Calendar View          │
│    (Scrollable Content)     │
├─────────────────────────────┤ ← Y=500 (키보드 상단)
│  ┌─────────────────────┐   │
│  │ やることをパッと入力  │   │ 입력박스
│  └─────────────────────┘   │
│  [일정][할일][습관]        │ Frame 704
├─────────────────────────────┤
│     🎹 Keyboard (Up)       │
└─────────────────────────────┘
```

### 상태 2: 追加 클릭 → 키보드 내려감
```
┌─────────────────────────────┐
│      Calendar View          │
│    (Scrollable Content)     │
├─────────────────────────────┤ ← Y=500 (똑같은 위치!!)
│  ┌─────────────────────┐   │
│  │ やることをパッと入力  │   │ 입력박스 (고정)
│  └─────────────────────┘   │
│  ┌─────────────────────┐   │
│  │ 今日のスケジュール    │   │ Frame 705
│  │ タスク              │   │
│  │ ルーティン           │   │
│  └─────────────────────┘   │
│                             │
│                             │ 키보드 내려간 빈 공간
└─────────────────────────────┘
```

### 상태 3: 타입 선택 후 → 위치 고정 해제
```
┌─────────────────────────────┐
│      Calendar View          │
│                             │
│    (Scrollable Content)     │
│                             │
│                             │
│         (입력박스             │
│          아래로 슬라이드)     │
└─────────────────────────────┘
```

## 🔧 구현 코드

### 1. 상태 변수 추가

```dart
class _QuickAddControlBoxState extends State<QuickAddControlBox> {
  // ✅ 키보드 Y 좌표 고정
  double? _fixedYPosition;      // 키보드 올라온 후 고정된 Y 좌표
  bool _isPositionLocked = false; // 追加 클릭 후 위치 고정 여부
```

### 2. 追加 버튼 클릭 시 위치 고정

```dart
void _handleDirectAdd() async {
  final text = _textController.text.trim();
  if (text.isEmpty) return;

  // ✅ 현재 키보드 위치를 Y 좌표로 고정
  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  final screenHeight = MediaQuery.of(context).size.height;
  
  setState(() {
    _fixedYPosition = screenHeight - keyboardHeight; // 키보드 상단 Y 좌표
    _isPositionLocked = true; // 위치 고정 활성화
    _showDetailPopup = true;  // Frame 705 표시
  });

  // 키보드 내리기
  FocusScope.of(context).unfocus();
  
  HapticFeedback.mediumImpact();
}
```

### 3. AnimatedPositioned로 부드러운 전환

```dart
@override
Widget build(BuildContext context) {
  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  final screenHeight = MediaQuery.of(context).size.height;
  
  // ✅ 위치 계산: 고정된 Y 좌표 또는 키보드 상단
  final bottomPosition = _isPositionLocked && _fixedYPosition != null
      ? screenHeight - _fixedYPosition! // 고정된 Y 좌표 사용
      : keyboardHeight;                  // 키보드 상단

  return AnimatedPositioned(
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeInOutCubic, // ✅ Apple-style
    left: 0,
    right: 0,
    bottom: bottomPosition, // ✅ 동적 또는 고정 위치
    child: Column(
      children: [
        // 입력박스 (Frame 701)
        _buildInputBox(),
        
        const SizedBox(height: 8),
        
        // 타입 선택기/팝업 (Frame 704/705)
        _showDetailPopup 
          ? _buildTypePopup() 
          : _buildTypeSelector(),
      ],
    ),
  );
}
```

### 4. 저장 후 위치 고정 해제

```dart
void _saveDirectSchedule() async {
  // ... 저장 로직 ...

  // ✅ 저장 후 위치 고정 해제
  setState(() {
    _isPositionLocked = false;
    _fixedYPosition = null;
  });
}

void _saveDirectTask() {
  // ... 저장 로직 ...

  setState(() {
    _isPositionLocked = false;
    _fixedYPosition = null;
  });
}

void _saveDirectHabit() {
  // ... 저장 로직 ...

  setState(() {
    _isPositionLocked = false;
    _fixedYPosition = null;
  });
}
```

## 🎬 애니메이션 플로우

```
1. 키보드 올라옴
   └─> bottomPosition = keyboardHeight
       └─> 입력박스가 키보드 위로 올라감 (350ms easeInOutCubic)

2. 追加 클릭
   ├─> _fixedYPosition = screenHeight - keyboardHeight
   ├─> _isPositionLocked = true
   ├─> FocusScope.unfocus() (키보드 내림)
   └─> bottomPosition = screenHeight - _fixedYPosition (고정!)
       └─> 입력박스는 그 자리 유지, 키보드만 내려감

3. Frame 705 표시
   └─> _showDetailPopup = true
       └─> Frame 704 → Frame 705 전환 (52px → 172px)

4. 타입 선택 후 저장
   ├─> _isPositionLocked = false
   ├─> _fixedYPosition = null
   └─> bottomPosition = keyboardHeight (다시 키보드 추적)
       └─> 입력박스가 아래로 슬라이드 (350ms easeInOutCubic)
```

## 📊 위치 계산 로직

### 변수 설명

- **`keyboardHeight`**: `MediaQuery.of(context).viewInsets.bottom`
  - 키보드가 차지하는 화면 하단 높이
  - 키보드 올라옴: 300px (예시)
  - 키보드 내려감: 0px

- **`screenHeight`**: `MediaQuery.of(context).size.height`
  - 전체 화면 높이: 812px (iPhone 13 예시)

- **`_fixedYPosition`**: 고정된 Y 좌표
  - 계산: `screenHeight - keyboardHeight`
  - 예: 812 - 300 = 512px (화면 상단에서 512px 지점)

- **`bottomPosition`**: AnimatedPositioned의 bottom 값
  - 고정 전: `keyboardHeight` (키보드 추적)
  - 고정 후: `screenHeight - _fixedYPosition` (Y 좌표 고정)

### 예시 계산

```
screenHeight = 812px
keyboardHeight = 300px (키보드 올라옴)

1. 키보드 올라옴:
   bottomPosition = keyboardHeight = 300px
   → 입력박스는 화면 하단에서 300px 위

2. 追加 클릭:
   _fixedYPosition = 812 - 300 = 512px
   키보드 내려감 → keyboardHeight = 0px
   bottomPosition = 812 - 512 = 300px
   → 입력박스는 여전히 화면 하단에서 300px 위! (고정)

3. 저장 후:
   _fixedYPosition = null
   bottomPosition = keyboardHeight = 0px
   → 입력박스가 화면 하단으로 이동 (슬라이드 다운)
```

## ✅ 체크리스트

- [x] 키보드 올라올 때 입력박스가 키보드 위로 이동
- [x] 追加 클릭 시 현재 Y 좌표 저장
- [x] 키보드 내려가도 입력박스는 고정 위치 유지
- [x] Frame 705가 입력박스 바로 아래 표시
- [x] 타입 선택 후 위치 고정 해제
- [x] 350ms easeInOutCubic 애니메이션 (Apple-style)
- [x] 최소한의 코드 수정 (AnimatedPositioned + 상태 변수 2개)

## 🧪 테스트 시나리오

### Test 1: 키보드 추적
1. 입력박스 클릭 → 키보드 올라옴
2. **예상**: 입력박스가 키보드 위로 부드럽게 이동 (350ms)
3. **검증**: `bottomPosition == keyboardHeight`

### Test 2: 위치 고정
1. "회의" 입력 → 追加 클릭
2. **예상**: 키보드 내려가지만 입력박스는 그 자리 유지
3. **검증**: `_fixedYPosition != null && _isPositionLocked == true`

### Test 3: Frame 705 표시
1. 追加 클릭 후
2. **예상**: Frame 705가 입력박스 바로 아래 표시 (52→172px)
3. **검증**: `_showDetailPopup == true`

### Test 4: 위치 고정 해제
1. Frame 705에서 "今日のスケジュール" 선택
2. **예상**: 저장 후 입력박스가 아래로 슬라이드 다운
3. **검증**: `_isPositionLocked == false && _fixedYPosition == null`

## 🎨 UX 개선 포인트

1. **Apple-style 애니메이션**: `Curves.easeInOutCubic` (350ms)
2. **햅틱 피드백**: `HapticFeedback.mediumImpact()` on 追加 click
3. **부드러운 전환**: `AnimatedPositioned`로 위치 변경 애니메이션
4. **직관적 동작**: 키보드 내려가도 입력박스는 고정 (사용자 기대에 부합)

---

**Implementation Date**: 2024-10-16
**Key Feature**: Keyboard Y-position locking with AnimatedPositioned
**Files Modified**: `quick_add_control_box.dart` (최소 수정)
**Animation**: 350ms easeInOutCubic (Apple-style)
