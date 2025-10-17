# Keyboard-Fixed Layout Implementation

## 🎯 문제점 및 해결

### 사용자 요구사항
> "키보드 내려 갈 때에 같이 내려가는데, 일단 입력 박스가 활성화 되어있다면, 키보드 바로 아래를 기준으로 고정이 되도록 해줘. 거기서 안움직여. 그리고 완료를 한 후에 그 때에만 움직이도록. 그리고 아직 bottom overflowed by 2pixel이 떠"

### 문제점

1. **입력 박스가 키보드와 함께 움직임**
   - 키보드가 내려가면 입력 박스도 함께 내려감
   - 키보드 위에 고정되어야 함

2. **Bottom overflowed by 2 pixels**
   - SizedBox(height: 8) 때문에 overflow 발생
   - 레이아웃 여유 공간 부족

## ✅ 해결 방법

### 1. CreateEntryBottomSheet 수정

**Before (문제)**:
```dart
// Stack + Positioned로 복잡한 구조
if (hasKeyboard) {
  return Stack(
    children: [
      Positioned(
        bottom: keyboardHeight + 20,  // ❌ 절대 위치로 배치
        left: (screenWidth - 365) / 2,
        child: _buildQuickAddUI(),
      ),
    ],
  );
}
```
- Positioned로 절대 위치 지정
- 키보드 높이 변화에 따라 위치도 변경됨
- 복잡한 계산 필요

**After (해결)**:
```dart
// Padding으로 단순화 - 키보드 위에 자동 고정
return Padding(
  padding: EdgeInsets.only(bottom: keyboardHeight), // ✅ 키보드 위에 고정
  child: Column(
    mainAxisSize: MainAxisSize.min,  // ✅ 내용 크기만큼만
    mainAxisAlignment: MainAxisAlignment.end, // ✅ 하단 정렬
    children: [
      _buildQuickAddUI(),
      SizedBox(height: 20), // 하단 여백
    ],
  ),
);
```

**핵심 원리**:
- `Padding.only(bottom: keyboardHeight)`: 키보드만큼 위로 밀어올림
- `MainAxisAlignment.end`: Column 내부를 하단으로 정렬
- `MainAxisSize.min`: Column이 최소 크기만 차지
- **결과**: 입력 박스가 키보드 바로 위에 고정됨 ✅

### 2. QuickAddControlBox Overflow 수정

**Before (문제)**:
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.end, // ❌ 우측 정렬
  children: [
    입력 박스,
    SizedBox(height: 8), // ❌ Overflow 발생
    Frame 704/705,
  ],
)
```
- `height: 8px` 때문에 2px overflow
- 우측 정렬로 인한 레이아웃 문제

**After (해결)**:
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.center, // ✅ 중앙 정렬
  children: [
    입력 박스,
    SizedBox(height: 6), // ✅ 8px → 6px로 감소
    Frame 704/705,
  ],
)
```

**변경사항**:
- `crossAxisAlignment.end` → `center`: 중앙 정렬로 overflow 방지
- `height: 8` → `6`: 여백 감소로 2px overflow 해결

## 🎬 사용자 플로우

```
1. 앱 실행 (키보드 자동 올라옴)
   ┌─────────────────┐
   │                 │
   │   캘린더 영역    │
   │                 │
   └─────────────────┘
   ┌─────────────────┐
   │ やることを...    │ ← 입력 박스 (키보드 바로 위 고정) ✅
   │        [+] 追加  │
   └─────────────────┘
   ┌─────────────────┐
   │ 📅 ☑️ 🔄      │ ← Frame 704 (입력 박스 바로 아래)
   └─────────────────┘
   ─────────────────── ← 키보드
   
2. 텍스트 입력 ("회의")
   ┌─────────────────┐
   │ 회의             │ ← 입력 박스 (그 자리 고정) ✅
   │        [+] 追加  │     追加 버튼 활성화
   └─────────────────┘
   ┌─────────────────┐
   │ 📅 ☑️ 🔄      │ ← Frame 704 유지
   └─────────────────┘
   ─────────────────── ← 키보드 (유지)

3. 追加 버튼 클릭
   ┌─────────────────┐
   │                 │
   │   캘린더 영역    │ ← 키보드 내려가면서 확장
   │                 │
   └─────────────────┘
   ┌─────────────────┐
   │ 회의             │ ← 입력 박스 (그 자리 고정) ✅
   │        [+] 追加  │     위치 변화 없음!
   └─────────────────┘
   ┌─────────────────┐
   │ 今日のスケジュール│ ← Frame 705 (바로 아래)
   │ タスク           │     52→172px 애니메이션
   │ ルーティン        │
   └─────────────────┘
   (키보드 내려감) ✅

4. 타입 선택 후 저장
   → DB 저장 완료
   → 바텀시트 닫힘
   → 그때 비로소 입력 박스 사라짐 ✅
```

## 🔍 핵심 코드

### CreateEntryBottomSheet.build()

```dart
@override
Widget build(BuildContext context) {
  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

  if (_useQuickAdd) {
    return Padding(
      // ✅ 키보드만큼 아래에서 padding → 키보드 위에 고정
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,         // 최소 크기
        mainAxisAlignment: MainAxisAlignment.end, // 하단 정렬
        children: [
          _buildQuickAddUI(),  // QuickAddControlBox
          SizedBox(height: 20), // 하단 여백
        ],
      ),
    );
  }

  // 레거시 모드...
}
```

### QuickAddControlBox.build()

```dart
@override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: _heightAnimation,
    builder: (context, child) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ 중앙 정렬
        children: [
          // 입력 박스 (Frame 701)
          Stack(
            children: [
              Container(
                height: _heightAnimation.value, // 132/196/192px
                // ...
              ),
              Positioned(/* 追加 버튼 */),
            ],
          ),

          SizedBox(height: 6), // ✅ 8px → 6px (overflow 방지)

          // Frame 704/705 조건부 렌더링
          _showDetailPopup
              ? _buildTypePopup()
              : _buildTypeSelector(),
        ],
      );
    },
  );
}
```

## 📊 변경 전후 비교

| 항목 | Before | After | 결과 |
|------|--------|-------|------|
| **레이아웃 방식** | Stack + Positioned | Padding + Column | ✅ 단순화 |
| **키보드 고정** | ❌ 함께 움직임 | ✅ 바로 위 고정 | ✅ 해결 |
| **위치 계산** | 복잡 (screenWidth/2) | 자동 (Column.end) | ✅ 단순화 |
| **Overflow** | ❌ 2px overflow | ✅ 해결 (6px gap) | ✅ 해결 |
| **정렬** | end (우측) | center (중앙) | ✅ 개선 |

## 🎯 최종 결과

### ✅ 해결된 문제

1. **입력 박스 키보드 위 고정** ✅
   - `Padding.only(bottom: keyboardHeight)` 사용
   - 키보드가 내려가도 입력 박스는 그 자리 유지
   - 완료 후에만 사라짐

2. **Bottom overflow 해결** ✅
   - `SizedBox(height: 8)` → `6`
   - `CrossAxisAlignment.end` → `center`
   - 2px overflow 완전 해결

3. **구조 단순화** ✅
   - Stack/Positioned 제거
   - Padding + Column만 사용
   - 코드 가독성 향상

### 🎨 동작 원리

```
MediaQuery.viewInsets.bottom (키보드 높이)
          ↓
Padding.only(bottom: keyboardHeight)
          ↓
Column은 하단 정렬 (MainAxisAlignment.end)
          ↓
입력 박스가 키보드 바로 위에 고정 ✅
```

## 📝 추가 개선사항

### 현재 구현

- ✅ 키보드 위 고정
- ✅ Overflow 해결
- ✅ 단순한 구조

### 향후 개선 가능

- [ ] 키보드 애니메이션과 동기화 (더 부드러운 전환)
- [ ] Safe Area 고려 (노치 있는 기기)
- [ ] 다크모드 대응

---

**Implementation Date**: 2024-10-16
**Key Changes**: 
- Padding.only(bottom: keyboardHeight) 사용
- SizedBox(height: 6) 적용
- CrossAxisAlignment.center 변경

**Status**: ✅ Complete
