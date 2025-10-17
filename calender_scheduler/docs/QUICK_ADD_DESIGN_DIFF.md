# 🎨 Quick Add Input Accessory View - Figma vs 현재 구현 차이점 분석

## 📋 분석 개요

Figma 디자인 스펙과 현재 Flutter 구현을 비교하여 차이점을 정리했습니다.

---

## 🎯 주요 차이점 요약

### ✅ 현재 잘 구현된 부분
1. ✅ TextField 플레이스홀더 및 입력 처리
2. ✅ 追加 버튼 활성화/비활성화 로직
3. ✅ 타입 선택 기능 (일정/할일/습관)
4. ✅ 애니메이션 높이 확장/축소
5. ✅ 직접 저장 로직

### ❌ Figma 디자인과 다른 부분 (수정 필요)

---

## 📐 1. 레이아웃 구조 차이

### Figma 디자인 (정확한 구조)
```
┌─ Property 1=Anything (393×192px) ───────────────┐
│  padding: 0px 14px, gap: 8px                    │
│  ┌─ Frame 701 (365×132px) ──────────────────┐   │
│  │  background: #FFFFFF                      │   │
│  │  border-radius: 28px                      │   │
│  │  ┌─ Frame 700 (365×52px) ──────────────┐ │   │
│  │  │  padding: 30px 0px 0px              │ │   │
│  │  │  ┌─ Quick_Add_TextArea (365×22) ───┐│ │   │
│  │  │  │  padding: 0px 26px               ││ │   │
│  │  │  │  "なんでも入力できます" (#7A7A7A)││ │   │
│  │  │  └──────────────────────────────────┘│ │   │
│  │  └───────────────────────────────────────┘ │   │
│  │  ┌─ Frame 702 (122×80px) ──────────────┐ │   │
│  │  │  padding: 18px                       │ │   │
│  │  │  position: absolute (right, bottom)  │ │   │
│  │  │  ┌─ QuickAdd_AddButton (86×44px) ──┐│ │   │
│  │  │  │  padding: 10px 12px, gap: 4px   ││ │   │
│  │  │  │  background: #111111 or #DDDDDD  ││ │   │
│  │  │  │  border-radius: 16px             ││ │   │
│  │  │  │  追加 ↑                          ││ │   │
│  │  │  └──────────────────────────────────┘│ │   │
│  │  └───────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────┘   │
│  gap: 8px                                           │
│  ┌─ Frame 704 (220×52px) ──────────────────────┐   │
│  │  padding: 0px 4px                           │   │
│  │  ┌─ QuickAdd_ActionType (212×52px) ──────┐ │   │
│  │  │  padding: 2px 20px, gap: 8px          │ │   │
│  │  │  border-radius: 34px                  │ │   │
│  │  │  ┌──┐ ┌──┐ ┌──┐ (52×48px each)       │ │   │
│  │  │  │📅│ │✅│ │🔄│ 일정/할일/습관       │ │   │
│  │  │  └──┘ └──┘ └──┘                       │ │   │
│  │  └─────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────┘
```

### 현재 구현 구조
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Stack( // ❌ Frame 701이 Stack 내부에 있음
      children: [
        Container( // Frame 701
          child: Column(
            children: [
              _buildTopArea(), // Frame 700 + Frame 702
              if (_selectedType != null) _buildQuickDetails(),
            ],
          ),
        ),
        if (_showDetailPopup) QuickDetailPopup(...), // ❌ 위치 불일치
      ],
    ),
    SizedBox(height: 8),
    _buildTypeSelector(), // Frame 704
  ],
)
```

### 🔧 수정 필요 사항

#### ❌ 문제점 1: Frame 702 위치가 부정확
- **Figma**: Frame 702는 Frame 701의 **우측 하단 절대 위치** (padding: 18px)
- **현재**: `_buildTopArea()` 내부의 `Positioned(right: 16, bottom: -38)`
- **문제**: bottom: -38은 임의 값이며, Figma 스펙과 불일치

#### ✅ 수정안 1
```dart
// Frame 701을 Stack으로 감싸고 Frame 702를 Positioned로 배치
Stack(
  children: [
    Container(
      width: QuickAddDimensions.frameWidth, // 365px
      height: _heightAnimation.value, // 132px
      decoration: QuickAddWidgets.frame701Decoration,
      child: Column(
        children: [
          _buildTextInputArea(), // ✅ TextField만 포함
          if (_selectedType != null) _buildQuickDetails(),
        ],
      ),
    ),
    // ✅ Figma 스펙: Frame 702 위치 (우측 하단)
    Positioned(
      right: QuickAddSpacing.addButtonContainerPadding.right, // 18px
      bottom: QuickAddSpacing.addButtonContainerPadding.bottom, // 18px
      child: _buildAddButton(),
    ),
  ],
)
```

---

## 🎨 2. 디자인 토큰 불일치

### ❌ 문제점: 하드코딩된 색상 값

#### 현재 코드
```dart
color: const Color(0xFF111111) // ❌ 하드코딩
color: const Color(0xFFE0E0E0) // ❌ Figma와 다름 (정확한 값: #DDDDDD)
color: const Color(0xFF7A7A7A) // ❌ 하드코딩
```

#### ✅ 수정안: Design System 사용
```dart
color: QuickAddColors.addButtonActiveBackground // #111111
color: QuickAddColors.addButtonInactiveBackground // #DDDDDD
color: QuickAddColors.placeholderText // #7A7A7A
```

### ❌ 문제점: 그림자 값 불일치

#### Figma 스펙
```css
box-shadow: 0px 2px 8px rgba(186, 186, 186, 0.08);
```

#### 현재 코드
```dart
BoxShadow(
  color: const Color(0xFFBABABA).withOpacity(0.08), // ✅ 색상 맞음
  offset: const Offset(0, 2), // ✅ offset 맞음
  blurRadius: 8, // ✅ blurRadius 맞음
)
```
→ **이 부분은 정확함**

---

## 📏 3. 크기 및 스페이싱 차이

### ❌ 문제점: 추가 버튼 비활성화 색상

#### Figma 스펙
- **활성화**: `background: #111111`
- **비활성화**: `background: #DDDDDD`

#### 현재 코드
```dart
color: hasText
  ? const Color(0xFF111111) // ✅ 활성화 맞음
  : const Color(0xFFE0E0E0), // ❌ 비활성화 틀림 (#E0E0E0 → #DDDDDD)
```

#### ✅ 수정안
```dart
color: hasText
  ? QuickAddColors.addButtonActiveBackground
  : QuickAddColors.addButtonInactiveBackground, // #DDDDDD
```

---

## 🎭 4. 상태별 UI 차이

### 📌 State 1: 기본 상태 (Property 1=Anything)

#### Figma 스펙
- Frame 701: `width: 365px`, `height: 132px`
- 플레이스홀더: `"なんでも入力できます"`, `color: #7A7A7A`
- 追加 버튼: **비활성화** (`background: #DDDDDD`)
- Frame 704 (타입 선택): **항상 표시**

#### 현재 구현
- ✅ Frame 701 크기 맞음
- ✅ 플레이스홀더 텍스트 맞음
- ❌ 追加 버튼 비활성화 색상 틀림 (#E0E0E0 → #DDDDDD)
- ✅ Frame 704 항상 표시됨

---

### 📌 State 2: 텍스트 입력 후 (Property 1=Variant5)

#### Figma 스펙
- 입력 텍스트: `color: #111111` (플레이스홀더 → 검정색 전환)
- 追加 버튼: **활성화** (`background: #111111`)
- Frame 704: **그대로 표시** (숨김 없음)
- QuickDetailPopup: **표시 안 됨** (Figma에서 보이지 않음)

#### 현재 구현
- ✅ 입력 텍스트 색상 맞음
- ✅ 追加 버튼 활성화 맞음
- ✅ Frame 704 유지됨
- ❌ `_showDetailPopup` 로직이 있지만 Figma에서는 이 시점에 팝업 없음

#### ✅ 수정안
```dart
onChanged: (text) {
  setState(() {
    _isAddButtonActive = text.isNotEmpty;
    // ❌ 이 시점에서는 팝업 표시 안 함
    // _showDetailPopup = false; // 명시적으로 false
  });
},
```

---

### 📌 State 3: 追加 버튼 클릭 후 (Property 1=Touched_Anything)

#### Figma 스펙
- **키보드**: 내려감
- **Frame 701**: 기존 위치 고정 (`left: 440px, top: 27px`)
- **Frame 704**: `display: none` (**숨김**)
- **Frame 705** (타입 선택 팝업): **표시** (`width: 220px, height: 172px`)
  - 위치: Frame 701 좌측 하단
  - 구조:
    ```
    ┌─ Frame 705 (220×172px) ────────┐
    │  padding: 0px 4px              │
    │  ┌─ Frame 653 (212×172px) ───┐│
    │  │  padding: 10-12-10-10px   ││
    │  │  border-radius: 24px      ││
    │  │  ┌─ Frame 650 (48px) ────┐││
    │  │  │ 📅 今日のスケジュール ││
    │  │  └──────────────────────┘││
    │  │  ┌─ Frame 651 (48px) ────┐││
    │  │  │ ✅ タスク            │││
    │  │  └──────────────────────┘││
    │  │  ┌─ Frame 652 (48px) ────┐││
    │  │  │ 🔄 ルーティン        │││
    │  │  └──────────────────────┘││
    │  └──────────────────────────┘│
    │└────────────────────────────┘
    ```

#### 현재 구현
```dart
void _handleDirectAdd() {
  _showDirectAddPopup(); // ❌ Overlay 사용 (위치 부정확)
}

void _showDirectAddPopup() {
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      left: 24, // ❌ 임의 값
      bottom: MediaQuery.of(context).viewInsets.bottom + 80, // ❌ 임의 값
      child: Material(...),
    ),
  );
}
```

#### ✅ 수정안: State 관리로 팝업 표시
```dart
// State 변수 추가
bool _showTypeSelectionPopup = false;

void _handleDirectAdd() {
  setState(() {
    _showTypeSelectionPopup = true;
    // ✅ Figma: 키보드 내리기
    FocusScope.of(context).unfocus();
  });
}

// build() 메서드에서
if (_showTypeSelectionPopup)
  Positioned(
    // ✅ Figma 스펙: Frame 705 위치
    left: QuickAddSpacing.typeSelectorContainerPadding.left, // 4px
    bottom: QuickAddDimensions.popupHeight, // 172px
    child: _buildTypeSelectionPopup(),
  ),
```

---

### 📌 State 4: 할일 타입 선택 (Property 1=Task)

#### Figma 스펙
- Frame 701: `height: 132px` (확장 없음)
- Frame 704 (타입 선택): **숨김** (`display: none`)
- Frame 705 (팝업): **숨김**
- **Frame 711** (세부 옵션): **표시**
  ```
  ┌─ Frame 711 (365×80px) ───────────────────────────────┐
  │  justify-content: space-between                      │
  │  ┌─ Frame 709 (226×40px) ──────┐  ┌─ Frame 702 ───┐│
  │  │  padding: 0px 18px, gap: 6px│  │  padding: 12-18││
  │  │  ┌─┐ ┌──────┐ ┌─┐          │  │  ┌───────────┐││
  │  │  │📌│ │締め切り│ │⋯│          │  │  │ ↑ (40×40) │││
  │  │  └─┘ └──────┘ └─┘          │  │  └───────────┘││
  │  └─────────────────────────────┘  └───────────────┘│
  └──────────────────────────────────────────────────────┘
  ```
- **Frame 688** (선택된 타입 표시): 할일 아이콘 강조 (`border: 2px solid #3B3B3B`)

#### 현재 구현
- ✅ `_buildTaskDetails()` 함수 존재
- ✅ QuickDetailButton 사용
- ❌ Frame 704 숨김 로직 없음
- ❌ DirectAddButton이 56×56px이어야 하는데 현재 44×44px

#### ✅ 수정안
```dart
// Frame 704 숨김 처리
Widget _buildTypeSelector() {
  // ✅ 타입 선택되면 숨김
  if (_selectedType != null) return const SizedBox.shrink();
  
  return Container(...);
}

// DirectAddButton 크기 수정
Widget _buildDirectAddButton() {
  return Container(
    width: QuickAddDimensions.directAddButtonSize, // 56px
    height: QuickAddDimensions.directAddButtonSize, // 56px
    padding: QuickAddSpacing.directAddButtonPadding, // 8px
    child: Container(
      width: QuickAddDimensions.directAddButtonInnerSize, // 40px
      height: QuickAddDimensions.directAddButtonInnerSize, // 40px
      decoration: QuickAddWidgets.directAddButtonDecoration,
      child: Icon(
        Icons.arrow_upward,
        size: QuickAddDimensions.iconSize, // 24px
        color: QuickAddColors.iconAddButton,
      ),
    ),
  );
}
```

---

### 📌 State 5: 일정 타입 선택 (Property 1=Schedule)

#### Figma 스펙
- Frame 701: `height: 132px` (확장 없음 - **현재 196px은 잘못됨**)
- Frame 704: **숨김**
- Frame 705: **숨김**
- **Frame 711**: 세부 옵션 표시
  ```
  ┌─ Frame 711 (365×80px) ───────────────────────────────┐
  │  ┌─ Frame 709 (233×40px) ──────────┐  ┌─ Frame 702 ┐│
  │  │  padding: 0px 18px, gap: 6px    │  │  (56×56px) ││
  │  │  ┌─┐ ┌──────────┐ ┌─┐          │  │  ↑         ││
  │  │  │📌│ │開始-終了│ │⋯│          │  │            ││
  │  │  └─┘ └──────────┘ └─┘          │  └────────────┘│
  │  └─────────────────────────────────┘                │
  └──────────────────────────────────────────────────────┘
  ```

#### 현재 구현
```dart
case QuickAddType.schedule:
  targetHeight = QuickAddConfig.controlBoxScheduleHeight; // 196px
```

#### ❌ 문제점
- Figma에서는 **높이 확장 없음** (132px 유지)
- 현재는 196px로 확장됨 (잘못된 로직)

#### ✅ 수정안
```dart
case QuickAddType.schedule:
case QuickAddType.task:
  // ✅ Figma: 타입 선택 시 높이 확장 없음
  targetHeight = QuickAddDimensions.frameHeight; // 132px
  setState(() {
    _startDateTime = startTime;
    _endDateTime = endTime;
  });
  break;
```

---

## 🎬 5. 백그라운드 블러 누락

### Figma 스펙 (node-id=2480-73456)
```css
/* Rectangle 385 */
width: 393px;
height: 534px;
background: linear-gradient(180deg, rgba(255, 255, 255, 0) 0%, rgba(240, 240, 240, 0.95) 50%);
backdrop-filter: blur(4px);
```

### 현재 구현
- ❌ **백그라운드 블러 컴포넌트 없음**

### ✅ 추가 필요
```dart
// lib/widgets/quick_add_background_blur.dart
class QuickAddBackgroundBlur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: QuickAddDimensions.containerWidth, // 393px
      height: QuickAddDimensions.backgroundBlurHeight, // 534px
      decoration: BoxDecoration(
        gradient: QuickAddBackgroundBlur.gradient,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: QuickAddBackgroundBlur.blurSigma, // 4px
          sigmaY: QuickAddBackgroundBlur.blurSigma,
        ),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
```

---

## 📝 6. 타이포그래피 불일치

### ❌ 문제점: 폰트 패밀리 누락

#### Figma 스펙
```css
font-family: 'LINE Seed JP App_TTF';
font-weight: 700; /* Bold */
letter-spacing: -0.005em;
```

#### 현재 코드
```dart
TextStyle(
  fontFamily: 'LINE Seed JP App_TTF', // ✅ 있음
  fontWeight: FontWeight.w700, // ✅ 맞음
  letterSpacing: -0.08, // ✅ -0.005em * 16px
)
```
→ **타이포그래피는 정확함**

---

## 🔄 7. 애니메이션 차이

### Figma 디자인 의도
1. **텍스트 입력**: 애니메이션 없음
2. **追加 버튼 클릭**: 키보드 내려가며 팝업 표시
3. **타입 선택**: Frame 704 숨김, Frame 711 표시

### 현재 구현
- ✅ `heightExpandDuration: 350ms` 적절
- ✅ `easeInOutCubic` 커브 적절
- ❌ **타입 선택 시 높이 확장** (Figma에는 없음)

### ✅ 수정안
```dart
void _onTypeSelected(QuickAddType type) {
  setState(() {
    _selectedType = type;
    _showDetailPopup = false;
    _showTypeSelectionPopup = false; // ✅ 팝업 숨김
  });
  
  // ❌ 높이 애니메이션 제거 (Figma에 없음)
  // _heightAnimationController.forward(from: 0.0);
  
  HapticFeedback.lightImpact();
}
```

---

## 📊 수정 우선순위

### 🔴 Critical (즉시 수정 필요)
1. **추가 버튼 비활성화 색상**: #E0E0E0 → #DDDDDD
2. **타입 선택 시 높이 확장 제거**: 132px 고정
3. **Frame 704 숨김 처리**: 타입 선택 시 숨김
4. **DirectAddButton 크기**: 44px → 56px (타입 선택 시)

### 🟡 High (다음 단계)
5. **Frame 702 절대 위치**: bottom: -38 → 정확한 위치 계산
6. **타입 선택 팝업 위치**: Overlay → State 기반 Positioned
7. **백그라운드 블러 추가**: Rectangle 385 구현

### 🟢 Medium (개선 사항)
8. **디자인 토큰 일관성**: 하드코딩 → Design System 사용
9. **플레이스홀더 텍스트**: 타입별 다른 텍스트 (현재는 공통)

---

## ✅ 수정 체크리스트

- [ ] 추가 버튼 비활성화 색상 수정 (#DDDDDD)
- [ ] 타입 선택 시 높이 확장 제거
- [ ] Frame 704 숨김 로직 추가
- [ ] DirectAddButton 크기 수정 (56×56px)
- [ ] Frame 702 절대 위치 재계산
- [ ] 타입 선택 팝업 State 기반 재구현
- [ ] 백그라운드 블러 컴포넌트 추가
- [ ] Design System 적용 (하드코딩 제거)
- [ ] 플레이스홀더 텍스트 타입별 분리

---

## 📌 참고 자료

- Figma 디자인: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/
- Design System: `/lib/design_system/quick_add_design_system.dart`
- 현재 구현: `/lib/component/quick_add/quick_add_control_box.dart`
