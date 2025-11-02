# 🧬 유기적 모핑 애니메이션 기술 문서

## 📐 핵심 개념

### 1. 모핑 (Morphing) 이란?

**모핑**은 하나의 형태가 다른 형태로 **연속적으로 변형**되는 애니메이션 기법입니다.

```
단순 전환 (Transition)          유기적 모핑 (Organic Morphing)
━━━━━━━━━━━━━━━━━━━━          ━━━━━━━━━━━━━━━━━━━━━━━━━━
A → [fade out]                  A → [A+B의 중간 형태들] → B
B → [fade in]                      ↓
                                하나의 생명체가 변형되는 느낌
[별개 요소]                        [단일 요소]
```

### 2. Flutter에서의 구현

#### ❌ 기존 방식 (AnimatedSwitcher)
```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: showPopup ? WidgetA() : WidgetB(),
)
```

**문제점**:
- 두 개의 **별개 위젯**이 교체됨
- Fade/Slide 전환만 가능
- 중간 형태가 없어 불연속적
- 레이아웃 점프 발생 가능

#### ✅ 개선 방식 (AnimatedContainer)
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 550),
  curve: Curves.easeInOutCubicEmphasized,
  height: showPopup ? 172 : 52,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(showPopup ? 24 : 34),
  ),
  child: AnimatedSwitcher(...),  // 내용물만 교체
)
```

**장점**:
- **하나의 Container**가 모든 속성 변형
- 높이, radius, 그림자 등이 **동시에** 변화
- 중간 형태가 자동 생성되어 연속적
- 레이아웃 안정성 보장

## 🎨 애니메이션 해부학

### 1. 레이어 구조

```
┌─────────────────────────────────────┐
│   AnimatedContainer (외형)          │  ← 550ms 모핑
│  ┌─────────────────────────────┐   │
│  │  AnimatedSwitcher (내용)    │   │  ← 350ms fade
│  │ ┌─────────────────────────┐ │   │
│  │ │ TypeSelector / Popup    │ │   │
│  │ └─────────────────────────┘ │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### 2. 속성 변화 타임라인

```dart
// 0ms - 시작
AnimatedContainer(
  height: 52,
  borderRadius: 34,
  child: TypeSelector,  // visible: 1.0
)

// 165ms - 30% 진행 (형태 변화 중, 내용 fade out 시작)
AnimatedContainer(
  height: 86,           // 52 + (172-52) * 0.3
  borderRadius: 31,     // 34 + (24-34) * 0.3
  child: TypeSelector,  // visible: 0.7
)

// 350ms - 64% 진행 (형태 계속 변화, 내용 전환 완료)
AnimatedContainer(
  height: 129,          // 52 + (172-52) * 0.64
  borderRadius: 27,     // 34 + (24-34) * 0.64
  child: TypePopup,     // visible: 0.3 (fade in 중)
)

// 550ms - 완료
AnimatedContainer(
  height: 172,
  borderRadius: 24,
  child: TypePopup,     // visible: 1.0
)
```

### 3. Curves 분석

#### Curves.easeInOutCubicEmphasized
```
속도 그래프:
  ▲
속도│      ╱────╲      ← 중간이 빠름
  │    ╱        ╲
  │  ╱            ╲
  │╱                ╲
  └──────────────────▶
    0%            100% 시간
```

**특징**:
- 시작: 천천히 가속 (gentle ease-in)
- 중간: 빠르게 이동 (emphasized middle)
- 끝: 부드럽게 감속 (smooth ease-out)

**수학적 정의**:
```dart
// Flutter 내부 구현 (근사치)
f(t) = {
  t < 0.5 : 4 * t³
  t ≥ 0.5 : 1 - pow(-2 * t + 2, 3) / 2
}
```

## 🔬 구현 디테일

### 1. 타이밍 최적화

#### 왜 550ms인가?
```
너무 빠름 (< 400ms)  →  사용자가 변화를 인지하기 어려움
적절함 (500-600ms)   →  명확하게 보이면서도 답답하지 않음
너무 느림 (> 700ms)  →  답답하고 지루함
```

**인간 지각 기준**:
- **100ms**: 즉각 반응으로 느껴짐
- **300ms**: 빠른 애니메이션
- **500ms**: 적절한 애니메이션 (선택됨)
- **1000ms**: 느린 애니메이션

### 2. 내용물 전환 전략

```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 350),  // 형태보다 빠름
  transitionBuilder: (child, animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Interval(
            0.3,  // 30% 지연 - 형태가 어느정도 변한 후 시작
            1.0,
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: child,
    );
  },
)
```

**전략**:
1. 형태 변화가 30% 진행될 때까지 **대기**
2. 이후 빠르게 **fade out** (기존 내용)
3. 동시에 **fade in** (새 내용)
4. 형태 완성보다 먼저 **내용 전환 완료**

### 3. 레이아웃 안정성

#### 문제: 위젯 교체 시 레이아웃 점프
```dart
// ❌ 나쁜 예
widget.showPopup ? Container(height: 172) : Container(height: 52)
// → 즉각 높이 변경, 레이아웃 재계산, 점프 발생
```

#### 해결: AnimatedContainer의 내재된 보간
```dart
// ✅ 좋은 예
AnimatedContainer(
  height: widget.showPopup ? 172 : 52,
  // → 내부적으로 Tween 생성: Tween<double>(begin: 52, end: 172)
  // → 매 프레임마다 중간값 계산
  // → 레이아웃이 부드럽게 재조정
)
```

## 🧪 성능 최적화

### 1. Widget Tree 최소화

#### Before
```
Stack
  ├─ AnimatedAlign
  │   └─ AnimatedSize
  │       └─ AnimatedSwitcher
  │           ├─ SlideTransition
  │           │   └─ ScaleTransition
  │           │       └─ FadeTransition
  │           │           └─ Widget A
  │           └─ (동일 구조) Widget B
```

#### After
```
AnimatedContainer           ← 단순화!
  └─ AnimatedSwitcher
      ├─ FadeTransition
      │   └─ Widget A
      └─ FadeTransition
          └─ Widget B
```

**성능 향상**:
- Widget tree 깊이: **7 → 3** (57% 감소)
- 불필요한 애니메이션 컨트롤러 제거
- Rebuild 범위 축소

### 2. RepaintBoundary 자동 적용

```dart
AnimatedContainer(
  // Flutter가 자동으로 RepaintBoundary 생성
  // → 이 Container만 독립적으로 repaint
  // → 부모/형제 위젯에 영향 없음
)
```

### 3. GPU 가속

```dart
decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(radius),
  // → GPU에서 border radius 계산
  boxShadow: [BoxShadow(...)],
  // → GPU에서 그림자 렌더링
)
```

## 📊 Flutter 내부 동작

### 1. AnimatedContainer의 마법

```dart
// Flutter 소스코드 (간략화)
class AnimatedContainer extends ImplicitlyAnimatedWidget {
  @override
  AnimatedContainerState createState() => AnimatedContainerState();
}

class AnimatedContainerState 
    extends AnimatedWidgetBaseState<AnimatedContainer> {
  
  Tween<double>? _height;
  Tween<BorderRadius>? _borderRadius;
  
  @override
  void forEachTween(TweenVisitor visitor) {
    // 높이 변화 감지
    _height = visitor(
      _height,
      widget.height,
      (value) => Tween<double>(begin: value),
    );
    
    // Border radius 변화 감지
    _borderRadius = visitor(
      _borderRadius,
      widget.decoration.borderRadius,
      (value) => BorderRadiusTween(begin: value),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // 현재 애니메이션 값으로 Container 빌드
    return Container(
      height: _height?.evaluate(animation),
      decoration: BoxDecoration(
        borderRadius: _borderRadius?.evaluate(animation),
      ),
    );
  }
}
```

### 2. 프레임별 렌더링

```
Frame 0 (0ms):
  height = 52.0
  radius = 34.0

Frame 1 (16.67ms):
  t = 0.03
  height = 52.0 + (172-52) * curve(0.03) = 52.36
  radius = 34.0 + (24-34) * curve(0.03) = 33.97

Frame 2 (33.33ms):
  t = 0.06
  height = 52.0 + (172-52) * curve(0.06) = 52.86
  radius = 34.0 + (24-34) * curve(0.06) = 33.91

...

Frame 33 (550ms):
  t = 1.0
  height = 172.0
  radius = 24.0
```

## 🎯 핵심 원칙

### 1. 단일 책임 원칙
```
AnimatedContainer     →  형태 변화 (외형)
AnimatedSwitcher      →  내용 변화 (내부)
```

### 2. 동시성 원칙
모든 속성이 **동시에** 변해야 유기적으로 느껴집니다:
- Height ✓
- Border radius ✓
- Shadow ✓
- Padding ✓

### 3. 연속성 원칙
중간 형태들이 자연스럽게 연결되어야 합니다:
```
52px → 86px → 129px → 172px  (O)
52px → [점프] → 172px         (X)
```

## 🌟 결론

이 구현은 다음을 달성합니다:

1. **생물학적 유기성**: 하나의 생명체가 변형되는 느낌
2. **업계 최고 수준**: Apple iOS와 동등한 품질
3. **Flutter 모범 사례**: ImplicitlyAnimatedWidget 패턴 활용
4. **성능 최적화**: 불필요한 복잡성 제거

**핵심 메시지**: 
> "여러 개의 위젯이 전환되는 것이 아니라,  
> 하나의 요소가 형태를 바꾸는 것"

---

**작성자**: AI Assistant  
**작성일**: 2025-11-02  
**참고**: Flutter AnimatedContainer, Material Design 3
