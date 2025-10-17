# Y 좌표 고정 구현 완료 보고서

## 🎯 구현 목표

**입력박스를 키보드 상단에 절대 Y 좌표로 고정하고, 키보드가 내려가도 그 자리 유지**

## ✅ 핵심 로직

### Y 좌표 계산 공식

```dart
Y = 키보드상단위치 - 8 - 타입박스높이 - 8 - 입력박스높이

구체적으로:
- 키보드상단위치 = screenHeight - keyboardHeight
- 타입박스높이 = 52px (기본) 또는 172px (팝업)
- 입력박스높이 = 132px (기본) / 196px (일정) / 192px (할일)

예시 계산:
- 화면 높이: 844px
- 키보드 높이: 300px
- 키보드 상단: 844 - 300 = 544px
- Y 좌표: 544 - 8 - 52 - 8 - 132 = 344px ← 여기 고정!
```

## 🎬 동작 흐름

### 1. 키보드 올라올 때 (초기 상태)

```dart
keyboardHeight > 0 && _fixedYPosition == null
→ Y 좌표 계산 후 _fixedYPosition에 저장
→ _isVisible = true

결과: 입력박스가 키보드 상단에 딱 맞게 위치
```

### 2. 追加 버튼 클릭 (키보드 내리기)

```dart
void _handleDirectAdd() {
  FocusScope.of(context).unfocus(); // 키보드 내리기
  
  setState(() {
    _showDetailPopup = true; // Frame 705 표시
  });
  
  // ✅ _fixedYPosition은 그대로!
  // ✅ 입력박스는 Y=344px 위치 유지
}

결과: 키보드만 내려가고, 입력박스는 고정된 Y 좌표 유지
```

### 3. 입력 취소 (숨기기)

```dart
void hideInputBox() {
  setState(() {
    _isVisible = false; // 화면 밖으로
    _fixedYPosition = null; // 초기화
  });
}

결과: Y → screenHeight로 애니메이션되며 화면 아래로 사라짐
```

## 📝 코드 구조

### 상태 변수

```dart
double? _fixedYPosition; // 입력박스 고정 Y 좌표
bool _isVisible = true;   // 입력박스 표시 여부
```

### build() 메서드

```dart
@override
Widget build(BuildContext context) {
  // 1. 키보드 높이 감지
  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  final screenHeight = MediaQuery.of(context).size.height;
  
  // 2. Y 좌표 계산
  final typeBoxHeight = _showDetailPopup ? 172.0 : 52.0;
  final inputBoxHeight = _heightAnimation.value;
  final targetY = keyboardHeight > 0
      ? screenHeight - keyboardHeight - 8 - typeBoxHeight - 8 - inputBoxHeight
      : screenHeight; // 키보드 없으면 화면 밖
  
  // 3. 키보드 올라올 때 Y 좌표 고정
  if (keyboardHeight > 0 && _fixedYPosition == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _fixedYPosition = targetY;
        _isVisible = true;
      });
    });
  }
  
  // 4. 사용할 Y 좌표 (고정값 우선)
  final yPosition = _fixedYPosition ?? targetY;
  
  // 5. AnimatedPositioned로 부드러운 애니메이션
  return AnimatedPositioned(
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeInOutCubic, // 애플스러운 커브
    top: _isVisible ? yPosition : screenHeight,
    left: (MediaQuery.of(context).size.width - 393) / 2,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      opacity: _isVisible ? 1.0 : 0.0,
      child: Column(
        children: [
          // 입력박스 + 타입박스
        ],
      ),
    ),
  );
}
```

## 🎨 시각화

### 상태 1: 키보드 올라옴
```
┌─────────────────────────────┐ 0px
│      Calendar View          │
│                             │
│                             │
├─────────────────────────────┤ Y=344px ← 고정!
│  ┌─────────────────────┐   │
│  │ やることをパッと入力  │   │ 입력박스
│  └─────────────────────┘   │
│  ┌─────────────────────┐   │
│  │ [일정][할일][습관]  │   │ 타입박스 (52px)
│  └─────────────────────┘   │
├─────────────────────────────┤ Y=544px (키보드상단)
│     🎹 Keyboard            │
│        300px               │
└─────────────────────────────┘ 844px
```

### 상태 2: 追加 클릭 → 키보드 내려감
```
┌─────────────────────────────┐ 0px
│      Calendar View          │
│                             │
│                             │
├─────────────────────────────┤ Y=344px ← 여전히 고정!
│  ┌─────────────────────┐   │
│  │ やることをパッと入力  │   │ 입력박스 (같은 위치)
│  └─────────────────────┘   │
│  ┌─────────────────────┐   │
│  │ 今日のスケジュール    │   │ 타입박스 (172px 확장)
│  │ タスク              │   │
│  │ ルーティン           │   │
│  └─────────────────────┘   │
│                             │
│     (빈 공간)              │
│                             │
└─────────────────────────────┘ 844px
```

### 상태 3: 입력 취소
```
┌─────────────────────────────┐ 0px
│      Calendar View          │
│                             │
│                             │
│                             │
│                             │
│                             │
│                             │
│                             │
│                             │
│                             │
│  ┌─────────────────────┐   │ ← 아래로 슬라이드
│  │ (사라짐)            │   │   Y → 844px
└─────────────────────────────┘ 844px
```

## ✨ 애니메이션

### AnimatedPositioned

```dart
AnimatedPositioned(
  duration: const Duration(milliseconds: 350), // 350ms
  curve: Curves.easeInOutCubic,                // 애플스러운 커브
  top: _isVisible ? yPosition : screenHeight,   // Y 좌표 변화
  // ...
)
```

### AnimatedOpacity

```dart
AnimatedOpacity(
  duration: const Duration(milliseconds: 350),
  opacity: _isVisible ? 1.0 : 0.0, // 페이드 인/아웃
  // ...
)
```

## 🔍 변경사항 요약

### 추가된 코드

```dart
// ✅ 상태 변수
double? _fixedYPosition; // Y 좌표 고정
bool _isVisible = true;   // 표시 여부

// ✅ 키보드 감지 및 Y 좌표 계산
final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
final targetY = screenHeight - keyboardHeight - 8 - typeBoxHeight - 8 - inputBoxHeight;

// ✅ 키보드 올라올 때 고정
if (keyboardHeight > 0 && _fixedYPosition == null) {
  _fixedYPosition = targetY;
  _isVisible = true;
}

// ✅ AnimatedPositioned로 감싸기
return AnimatedPositioned(
  top: _isVisible ? yPosition : screenHeight,
  child: Column(...), // 기존 Stack → Column
);

// ✅ 키보드 내리기
void _handleDirectAdd() {
  FocusScope.of(context).unfocus(); // 키보드 내리기
  setState(() => _showDetailPopup = true);
}

// ✅ 숨기기 메서드
void hideInputBox() {
  setState(() {
    _isVisible = false;
    _fixedYPosition = null;
  });
}
```

### 수정된 코드

```dart
// Before: Stack 구조
return AnimatedBuilder(
  child: Stack(
    children: [Column(...)],
  ),
);

// After: AnimatedPositioned로 감싸기
return AnimatedPositioned(
  top: yPosition,
  child: Column(...), // Stack 제거
);
```

## 🧪 테스트 시나리오

### Test 1: 키보드 올라옴
1. 입력박스 클릭 → 키보드 올라옴
2. **검증**: 입력박스가 키보드 상단에 딱 맞게 위치
3. **검증**: Y 좌표가 `_fixedYPosition`에 저장됨

### Test 2: 追加 클릭
1. "회의" 입력 → 追加 클릭
2. **검증**: 키보드만 내려감
3. **검증**: 입력박스는 Y=344px(예시) 위치 유지
4. **검증**: Frame 705 표시됨

### Test 3: 입력 취소
1. `hideInputBox()` 호출
2. **검증**: 입력박스가 화면 아래로 슬라이드 (350ms)
3. **검증**: `_fixedYPosition = null` 초기화

## 📊 Overflow 해결

**Before**:
```
❌ BOTTOM OVERFLOWED BY 2.0 PIXELS
```

**After**:
```
✅ AnimatedPositioned로 절대 위치 지정
✅ MediaQuery로 정확한 키보드 높이 감지
✅ Y 좌표 고정으로 레이아웃 충돌 없음
```

## 🎯 최종 결과

✅ **입력박스 Y 좌표 고정** (키보드 상단 기준)
✅ **키보드 내려가도 위치 유지**
✅ **애플스러운 애니메이션** (350ms easeInOutCubic)
✅ **Overflow 에러 해결**
✅ **최소한의 코드 수정**

---

**Implementation Date**: 2024-10-16
**Key Changes**: AnimatedPositioned + Y 좌표 고정
**Status**: ✅ Complete
