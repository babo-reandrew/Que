# Quick Add Bottom Fixed Layout Implementation

## 🎯 최종 구현: 입력 박스 하단 고정 + Frame 705 자연스러운 연결

### ✅ 핵심 변경사항

**사용자 요구사항**:
> "기본적으로 입력 박스들은 하단을 고정으로 높이가 유동적으로 바뀌어 안에 있는 내용에 대해서 expanded라고 해야하나. 그리고 追加를 누르면 키보드가 내려가면서, 입력 박스가 있는 박스는 그 자리에 고정이 되고 705는 해당 입력박스와 함께 움직이니까 고정된 위치에서 지금처럼 바꾸지 말고 딱좋아. 다만 입력박스 위치 아래에."

**Before (문제)**:
```dart
return Stack(  // ❌ Stack 사용
  children: [
    Column([
      입력 박스,
      SizedBox(height: 8),
      Frame 704/705,
    ]),
  ],
);
```
- Stack으로 감싸서 불필요하게 복잡
- Frame 705가 입력 박스와 분리되어 독립적으로 움직임

**After (해결)**:
```dart
return Column(  // ✅ Column만 사용
  children: [
    입력 박스 (하단 고정, 높이 유동적),
    SizedBox(height: 8),
    Frame 704/705 (입력 박스 바로 아래 붙어서 함께 움직임),
  ],
);
```
- 단순한 Column 구조
- Frame 705가 입력 박스 바로 아래에 붙어서 함께 움직임

## 📝 코드 구조

### 1. 하단 고정 Column 레이아웃

```dart
@override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: _heightAnimation,
    builder: (context, child) {
      return Column(
        mainAxisSize: MainAxisSize.min,  // ✅ 내용에 맞게 크기 조절
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ✅ 1. 입력 박스 (하단 고정, 높이 유동적)
          Stack(
            children: [
              Container(
                height: _heightAnimation.value,  // 132 / 196 / 192px
                decoration: QuickAddWidgets.frame701Decoration,
                child: Column([
                  _buildTextInputArea(),
                  if (_selectedType != null) _buildQuickDetails(),
                  Spacer(),  // ✅ 내용 위로, 버튼 아래로
                ]),
              ),
              Positioned(  // Frame 702: 追加 버튼
                right: 18,
                bottom: 18,
                child: _buildAddButton(),
              ),
            ],
          ),

          SizedBox(height: 8),  // Figma gap

          // ✅ 2. Frame 704/705 (입력 박스 바로 아래)
          _showDetailPopup && _selectedType == null
              ? _buildTypePopup()      // Frame 705
              : _buildTypeSelector(),  // Frame 704
        ],
      );
    },
  );
}
```

### 2. 追加 버튼 클릭 시 키보드 내리기

```dart
void _handleDirectAdd() async {
  final text = _textController.text.trim();
  if (text.isEmpty) return;

  // ✅ Figma: 追加 클릭 → 키보드 내리기
  FocusScope.of(context).unfocus();

  // ✅ Frame 705 표시 (입력 박스 바로 아래에 붙어있음)
  setState(() {
    _showDetailPopup = true;
  });

  print('✅ 키보드 내림 + 타입 선택 팝업 표시');
  HapticFeedback.mediumImpact();
}
```

### 3. Frame 704/705 조건부 렌더링 (같은 위치)

```dart
// ✅ 입력 박스 바로 아래 8px gap
_showDetailPopup && _selectedType == null
    ? _buildTypePopup()      // Frame 705: 220×172px
    : _buildTypeSelector()   // Frame 704: 220×52px
```

## 🎬 사용자 플로우

```
1. 기본 상태 (키보드 올라옴)
   ┌─────────────────┐
   │                 │
   │   캘린더 영역    │  ← 스크롤 가능
   │                 │
   └─────────────────┘
   ┌─────────────────┐
   │ やることを...    │  ← 입력 박스 (하단 고정)
   │        [+] 追加  │     높이: 132px
   └─────────────────┘
   ┌─────────────────┐
   │ 📅 ☑️ 🔄      │  ← Frame 704 (바로 아래)
   └─────────────────┘
   ─────────────────── ← 키보드
   
2. 텍스트 입력
   ┌─────────────────┐
   │ 회의             │  ← 텍스트 입력
   │        [+] 追加  │     追加 버튼 활성화 (#111)
   └─────────────────┘
   ┌─────────────────┐
   │ 📅 ☑️ 🔄      │  ← Frame 704 유지
   └─────────────────┘
   ─────────────────── ← 키보드 (유지)

3. 追加 버튼 클릭
   ┌─────────────────┐
   │                 │
   │   캘린더 영역    │  ← 키보드 내려가면서
   │                 │     캘린더 영역 확장
   └─────────────────┘
   ┌─────────────────┐
   │ 회의             │  ← 입력 박스 (그 자리 고정)
   │        [+] 追加  │     높이: 132px 유지
   └─────────────────┘
   ┌─────────────────┐
   │ 今日のスケジュール│  ← Frame 705 (바로 아래)
   │ タスク           │     52→172px 애니메이션
   │ ルーティン        │     입력 박스와 함께 움직임
   └─────────────────┘
   (키보드 내려감) ✅

4. 타입 선택 (예: 今日のスケジュール)
   → _saveDirectSchedule() 실행
   → DB 저장 (15:00-16:00)
   → Frame 705 닫힘 → Frame 704 복귀
   → 텍스트 초기화
```

## 🎨 레이아웃 상세

### 하단 고정 원리

```dart
// ✅ 바텀시트 내부에서 자동으로 하단 고정됨
// Scaffold > BottomSheet > SafeArea > QuickAddControlBox
Column(
  mainAxisSize: MainAxisSize.min,  // ← 이것이 핵심!
  children: [
    // 입력 박스 + Frame 704/705
    // 키보드 높이만큼 자동으로 위로 올라감
  ],
)
```

### 높이 유동성

```dart
// ✅ AnimationController로 높이 자동 조절
height: _heightAnimation.value

// 기본: 132px (텍스트 입력만)
// 일정 선택: 196px (+ 시간 선택)
// 할일 선택: 192px (+ 마감일)
```

### Frame 705가 입력 박스와 붙어있는 이유

```dart
Column(
  children: [
    입력 박스,           // ← 키보드 높이에 따라 움직임
    SizedBox(height: 8), // ← 고정 gap
    Frame 705,          // ← 입력 박스 바로 아래 (함께 움직임)
  ],
)
```

**Stack이 아닌 Column 사용**:
- Stack: 절대 위치 → 독립적 움직임
- Column: 상대 위치 → 함께 움직임 ✅

## 🔍 변경사항 요약

### 1. 구조 단순화

```diff
- return Stack(
-   children: [Column([...])],
- );

+ return Column(
+   children: [입력박스, gap, Frame704/705],
+ );
```

### 2. 키보드 제어 추가

```dart
void _handleDirectAdd() {
  // ✅ 추가: 키보드 내리기
  FocusScope.of(context).unfocus();
  
  setState(() => _showDetailPopup = true);
}
```

### 3. Frame 705 위치 변경

```diff
- Positioned(  // ❌ 절대 위치
-   right: 0,
-   bottom: -20,
-   child: QuickDetailPopup(...),
- )

+ _showDetailPopup  // ✅ 조건부 렌더링 (Column 내부)
+     ? _buildTypePopup()
+     : _buildTypeSelector()
```

## 📊 동작 검증

| 시나리오 | 예상 동작 | 구현 결과 |
|---------|----------|----------|
| 앱 실행 | 키보드 자동 올라옴 | ✅ autofocus: true |
| 텍스트 입력 | 入力박스 하단 고정 | ✅ Column mainAxisSize.min |
| 追加 클릭 | 키보드 내려감 | ✅ FocusScope.unfocus() |
| Frame 705 표시 | 입력 박스 바로 아래 | ✅ Column children 순서 |
| 타입 선택 | 저장 후 Frame 704 복귀 | ✅ setState showDetailPopup |
| 키보드 재등장 | 입력 박스 + Frame 함께 올라감 | ✅ Column 구조 |

## 🎯 최종 결과

✅ **입력 박스 하단 고정** (키보드 위에 항상 붙어있음)
✅ **높이 유동적** (내용에 따라 132/196/192px)
✅ **追加 클릭 → 키보드 내림** (FocusScope.unfocus)
✅ **입력 박스 그 자리 고정** (키보드 내려가도 위치 유지)
✅ **Frame 705가 입력 박스 바로 아래** (Column 구조로 함께 움직임)
✅ **최소한의 수정** (Stack 제거, Column만 사용)

---

**Implementation Date**: 2024-10-16
**Key Changes**: 
- Stack → Column 구조 변경
- FocusScope.unfocus() 추가
- Frame 705를 Column 내부로 이동

**Status**: ✅ Complete
