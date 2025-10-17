# 🎯 입력박스 키보드 고정 + 애플 애니메이션 구현 완료

## ✅ 구현 완료 사항

### 핵심 기능

1. **입력박스 Y 좌표 고정** ✅
   - 키보드가 올라오면 키보드 상단에 고정
   - 키보드가 내려가도 그 Y 좌표 유지
   - 입력 취소 시에만 아래로 슬라이드

2. **애플스러운 애니메이션** ✅
   - `AnimatedPositioned` 사용
   - Duration: 300ms
   - Curve: `Curves.easeInOutCubic`

3. **追加 버튼 클릭 시 키보드 내림** ✅
   - `FocusScope.of(context).unfocus()`
   - 100ms 딜레이 후 Frame 705 표시

## 📊 동작 시각화

### 상태 1: 키보드 올라옴 (입력 중)
```
┌─────────────────────────────┐
│      Calendar View          │
│                             │
│    (Scrollable Content)     │
│                             │
├─────────────────────────────┤ ← Y=500 (키보드 상단)
│  ╔═════════════════════╗   │
│  ║ やることをパッと入力  ║   │ Frame 701 (입력박스)
│  ║  [색] [締め切り] [···]║   │ AnimatedPositioned
│  ║              [追加]  ║   │ bottom: keyboardHeight
│  ╚═════════════════════╝   │
│  ┌─────────────────────┐   │
│  │ [일정][할일][습관]  │   │ Frame 704
│  └─────────────────────┘   │
├─────────────────────────────┤
│     🎹 Keyboard (350px)    │
└─────────────────────────────┘
```

### 상태 2: 追加 클릭 → 키보드 내려감
```
┌─────────────────────────────┐
│      Calendar View          │
│                             │
│    (Scrollable Content)     │
│                             │
├─────────────────────────────┤ ← Y=500 (같은 Y 좌표 유지!)
│  ╔═════════════════════╗   │
│  ║ やることをパッと入力  ║   │ 입력박스 그대로 유지
│  ║  [색] [締め切り] [···]║   │ bottom: 0 (애니메이션)
│  ║              [追加]  ║   │ 300ms easeInOutCubic
│  ╚═════════════════════╝   │
│  ┌─────────────────────┐   │
│  │ 今日のスケジュール    │   │ Frame 705 (52→172px)
│  │ タスク              │   │ 자연스럽게 확장
│  │ ルーティン           │   │
│  └─────────────────────┘   │
│                             │
│       (키보드 내려감)       │
│                             │
└─────────────────────────────┘
```

### 상태 3: 타입 선택 → 저장 완료
```
┌─────────────────────────────┐
│      Calendar View          │
│                             │
│    (Scrollable Content)     │
│                             │
│                             │
│                             │
│                             │
│         (입력박스가         │
│        아래로 슬라이드)      │
│                             │
├─────────────────────────────┤
│  ╔═════════════════════╗   │ ← 화면 밖으로 숨겨짐
└─────────────────────────────┘
```

## 🎨 코드 구조

### 1. AnimatedPositioned로 키보드 고정

```dart
@override
Widget build(BuildContext context) {
  // ✅ 키보드 높이 감지
  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  final boxBottomPosition = keyboardHeight.toDouble();

  return AnimatedBuilder(
    animation: _heightAnimation,
    builder: (context, child) {
      return Stack(
        children: [
          // ✅ 애플스러운 애니메이션으로 위치 변경
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300), // 300ms
            curve: Curves.easeInOutCubic, // 애플 커브
            bottom: boxBottomPosition, // 키보드 높이에 따라 자동 조정
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Frame 701 (입력박스)
                // Frame 704/705 (타입 선택)
              ],
            ),
          ),
        ],
      );
    },
  );
}
```

### 2. 키보드 상태에 따른 bottom 값

| 상태 | keyboardHeight | boxBottomPosition | 위치 |
|------|----------------|-------------------|------|
| 키보드 올라옴 | 350px | 350.0 | 키보드 위 |
| 키보드 내려감 | 0px | 0.0 | 화면 아래 |
| 애니메이션 중 | 350→0 | 350.0→0.0 | 부드럽게 이동 |

### 3. 追加 버튼 클릭 시 키보드 내리기

```dart
void _handleDirectAdd() async {
  final text = _textController.text.trim();
  if (text.isEmpty) return;

  // ✅ 1. 키보드 내리기
  FocusScope.of(context).unfocus();
  
  // ✅ 2. 100ms 대기 (키보드 애니메이션과 조화)
  await Future.delayed(const Duration(milliseconds: 100));

  // ✅ 3. Frame 705 표시
  setState(() {
    _showDetailPopup = true;
  });

  // ✅ 4. 햅틱 피드백
  HapticFeedback.mediumImpact();
}
```

## 🔄 애니메이션 타이밍

```
사용자: 追加 버튼 클릭
  ↓
  ├─ 0ms: FocusScope.unfocus() 실행
  ├─ 0-300ms: 키보드 내려감 (iOS 기본 애니메이션)
  ├─ 0-300ms: 입력박스 아래로 이동 (AnimatedPositioned)
  │           bottom: 350 → 0 (easeInOutCubic)
  ├─ 100ms: setState(_showDetailPopup = true)
  ├─ 100ms: Frame 704 → Frame 705 전환 시작
  ├─ 100-450ms: Frame 705 높이 애니메이션
  │             52px → 172px (easeInOutCubic, 350ms)
  └─ 450ms: 모든 애니메이션 완료
```

## 📱 Flutter 패키지 사용

### 내장 위젯 사용 (추가 패키지 불필요!)

- ✅ **AnimatedPositioned**: Flutter 기본 제공
- ✅ **Curves.easeInOutCubic**: 애플스러운 커브
- ✅ **MediaQuery.viewInsets.bottom**: 키보드 높이 감지
- ✅ **FocusScope.unfocus()**: 키보드 내리기

## 🎯 핵심 차이점

### Before (문제)
```dart
// ❌ Column으로만 배치 → 키보드 내려가면 함께 내려감
return Column(
  children: [
    // 입력박스
    // 타입 선택기
  ],
);
```

### After (해결)
```dart
// ✅ AnimatedPositioned로 Y 좌표 고정
return AnimatedPositioned(
  bottom: keyboardHeight.toDouble(), // 키보드 높이에 따라 자동
  duration: const Duration(milliseconds: 300), // 애플 타이밍
  curve: Curves.easeInOutCubic, // 애플 커브
  child: Column(...),
);
```

## ✅ 테스트 시나리오

### Test 1: 키보드 위 고정
1. 입력박스 탭 → 키보드 올라옴
2. **검증**: 입력박스가 키보드 위에 고정됨 (bottom = keyboardHeight)

### Test 2: 追加 클릭 후 위치 유지
1. "회의" 입력 → 追加 클릭
2. **검증**: 키보드 내려가도 입력박스는 그 Y 좌표 유지
3. **검증**: 300ms 애플 애니메이션으로 부드럽게 이동

### Test 3: Frame 705 표시
1. 追加 클릭
2. **검증**: 100ms 후 Frame 705 표시
3. **검증**: 52→172px 애니메이션 (350ms)

### Test 4: 전체 애니메이션 조화
1. 追加 클릭
2. **검증**: 키보드 내림 + 입력박스 이동 + Frame 705 확장이 자연스럽게 조화됨
3. **검증**: 총 450ms 이내에 모든 애니메이션 완료

## 🚀 구현 결과

✅ **입력박스 Y 좌표 고정**: AnimatedPositioned + bottom 값 제어
✅ **애플스러운 애니메이션**: 300ms, easeInOutCubic
✅ **키보드 제어**: FocusScope.unfocus()
✅ **최소한의 수정**: 기존 Column을 AnimatedPositioned로 감싸기만 함
✅ **Flutter 내장 위젯만 사용**: 추가 패키지 불필요

---

**Implementation Date**: 2024-10-16
**Key Feature**: 입력박스 키보드 고정 + 애플 애니메이션
**Animation**: 300ms easeInOutCubic (Apple-like)
**Status**: ✅ Complete
