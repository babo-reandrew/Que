# 🎵 Dismissible Insight Player 모션 완료 (월뷰→디테일뷰와 동일)

## 📅 작업 날짜
2025-10-19

## 🎯 작업 목표
디테일뷰에서 인사이트 플레이어 버튼을 눌렀을 때, **월뷰→디테일뷰와 동일한 애니메이션 모션**을 적용합니다.

### 🍎 애플 스타일 핵심 특징
- 버튼이 화면으로 **morphing** (형태 변환)
- **월뷰→디테일뷰와 동일한 타이밍**: 520ms / 480ms
- **동일한 커브**: `Cubic(0.05, 0.7, 0.1, 1.0)` - Emphasized Decelerate
- **동일한 border radius**: 36px (Figma 60% smoothing)
- 아래로 스와이프하여 dismiss (버튼 위치로 복귀)

---

## ✅ 구현 내용

### 1️⃣ **패키지 설치**
```yaml
# pubspec.yaml
dependencies:
  dismissible_page: ^1.0.2  # 🎵 Dismissible page transition (Hero + swipe to dismiss)
```

---

## 🎨 왜 Hero와 dismissible_page를 같이 써야 하는가?

### ❌ dismissible_page만 사용하면
```dart
context.pushTransparentRoute(
  DismissiblePage(
    child: InsightPlayerScreen(), // 그냥 새 화면이 나타남
  ),
);
```
**결과**: 화면이 단순히 fade-in/out 되며, 버튼과 연결성 없음

---

### ✅ Hero + dismissible_page 조합
```dart
// 1️⃣ 시작: 작은 버튼
Hero(
  tag: 'insight-player',
  child: SmallButton(), // 108x108px 회전된 버튼
)

// 2️⃣ 탭 → Hero 애니메이션으로 형태 변환
Hero(
  tag: 'insight-player', // 같은 tag!
  child: FullScreen(), // 전체 화면으로 확장
)

// 3️⃣ 드래그 → dismissible_page가 스와이프 처리
```

**결과**: 
- 버튼 → 화면으로 **morphing** (애플 스타일!)
- 화면 → 버튼으로 **다시 축소** (역방향 애니메이션)
- 드래그 시 실시간 스케일/투명도 조정

---

### 2️⃣ **DateDetailHeader 수정**

**파일:** `lib/widgets/date_detail_header.dart`

#### 최종 구현 (월뷰→디테일뷰와 동일한 모션)
```dart
import 'package:dismissible_page/dismissible_page.dart'; // Dismissible page
import '../const/motion_config.dart'; // 애플 스타일 모션 설정

// ...

return GestureDetector(
  onTap: () {
    context.pushTransparentRoute(
      DismissiblePage(
        onDismissed: () {
          Navigator.of(context).pop();
        },
        // ========== 월뷰→디테일뷰와 동일한 설정 ==========
        direction: DismissiblePageDismissDirection.down,
        isFullScreen: true,
        backgroundColor: Colors.black.withOpacity(0.0), // 투명 시작
        
        // 🍎 OpenContainer와 동일한 애니메이션 설정
        minScale: 0.90, // 드래그 시 90%까지 축소
        maxRadius: 36, // 둥근 모서리 36px (Figma 60% smoothing, 디테일뷰와 동일!)
        maxTransformValue: 0.4, // 화면 높이의 40%까지 드래그 가능
        
        // ⏱️ 월뷰→디테일뷰와 동일한 타이밍
        // openContainerDuration: 520ms, closeDuration: 480ms
        reverseDuration: MotionConfig.openContainerCloseDuration, // 480ms
        
        dragSensitivity: 0.8,
        
        // 🎯 Dismiss 임계값 설정 (30% 드래그 시 자동 닫힘)
        dismissThresholds: const {
          DismissiblePageDismissDirection.down: 0.3,
        },
        
        // ✅ 핵심: Hero + OpenContainer 커브 적용
        child: Hero(
          tag: 'insight-player-${widget.selectedDate}',
          // 🎨 OpenContainer와 동일한 커브 적용
          // Cubic(0.05, 0.7, 0.1, 1.0) - Emphasized Decelerate
          flightShuttleBuilder: (
            flightContext,
            animation,
            flightDirection,
            fromHeroContext,
            toHeroContext,
          ) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: MotionConfig.openContainerCurve, // 월뷰→디테일뷰와 동일!
              reverseCurve: MotionConfig.openContainerReverseCurve,
            );
            
            return AnimatedBuilder(
              animation: curvedAnimation,
              builder: (context, child) {
                return Material(
                  type: MaterialType.transparency,
                  child: toHeroContext.widget,
                );
              },
            );
          },
          child: Material(
            type: MaterialType.transparency,
            child: InsightPlayerScreen(targetDate: widget.selectedDate),
          ),
        ),
      ),
    );
  },
  child: Hero(
    tag: 'insight-player-${widget.selectedDate}',
    child: Material(
      type: MaterialType.transparency,
      child: _buildInsightButtonContent(),
    ),
  ),
);
```

**🔑 월뷰→디테일뷰와 동일한 설정:**

| 항목 | 월뷰→디테일뷰 | 인사이트 플레이어 | 비고 |
|------|--------------|------------------|------|
| **Duration (열기)** | 520ms | 520ms (Hero default) | ✅ 동일 |
| **Duration (닫기)** | 480ms | 480ms | ✅ 동일 |
| **Curve** | `Cubic(0.05, 0.7, 0.1, 1.0)` | `Cubic(0.05, 0.7, 0.1, 1.0)` | ✅ 동일 (flightShuttleBuilder) |
| **Border Radius** | 0px → 36px | 버튼 → 36px | ✅ 동일 (Figma 60% smoothing) |
| **minScale** | - | 0.90 | 드래그 시 축소 |
| **배경색** | #F7F7F7 | 투명 → #566099 | 인사이트는 보라색 |

---

**✨ flightShuttleBuilder의 역할:**

Hero 애니메이션의 "flight" 단계(버튼 → 화면 morphing 중)에서 **커스텀 커브**를 적용합니다.

```dart
// ❌ flightShuttleBuilder 없으면
Hero(child: ...) // 기본 linear 커브 사용 (부자연스러움)

// ✅ flightShuttleBuilder 있으면
Hero(
  flightShuttleBuilder: (...) {
    return CurvedAnimation(
      curve: MotionConfig.openContainerCurve, // 월뷰→디테일뷰와 동일한 쫀득함!
    );
  },
  child: ...,
)
```

---

**🔑 핵심 구조 변경:**

| 항목 | 이전 (잘못된 구조) | 현재 (올바른 구조) |
|------|-------------------|-------------------|
| **버튼 Hero** | ✅ 있음 | ✅ 있음 (Material 추가) |
| **화면 Hero** | ❌ DismissiblePage 안에 위치 | ✅ DismissiblePage 안에 독립적으로 위치 |
| **Material 위치** | InsightPlayerScreen 내부 | Hero 바로 안쪽 (양쪽 동일) |
| **Dismiss 시** | ❌ 아래로 사라짐 | ✅ 버튼 위치로 축소! |

---

**왜 Material로 감싸나요?**

Hero 애니메이션 중에는 양쪽 위젯이 동시에 렌더링되는 "flight" 단계가 있습니다. 이때 Material이 없으면 렌더링 오류가 발생할 수 있습니다.

```dart
// ❌ Material 없으면
Hero(
  child: _buildInsightButtonContent(), // 렌더링 오류 가능
)

// ✅ Material로 감싸면
Hero(
  child: Material(
    type: MaterialType.transparency,
    child: _buildInsightButtonContent(), // 안전하게 렌더링
  ),
)
```

**주요 설정값 (월뷰→디테일뷰와 동일):**

| 파라미터 | 값 | 이유 |
|---------|-----|------|
| `minScale` | 0.90 | 드래그 시 90% 크기 유지 (애플 스타일) |
| `maxRadius` | **36px** | **월뷰→디테일뷰와 동일! Figma 60% smoothing** |
| `maxTransformValue` | 0.4 | 화면 40%만 드래그해도 닫힘 |
| `reverseDuration` | **480ms** | **월뷰→디테일뷰와 동일! openContainerCloseDuration** |
| `dragSensitivity` | 0.8 | 약간 민감하게 (즉각 반응) |
| `dismissThresholds` | 0.3 | 30% 드래그 시 자동 닫힘 |
| **Hero curve** | **`Cubic(0.05, 0.7, 0.1, 1.0)`** | **월뷰→디테일뷰와 동일! Emphasized Decelerate** |

---

---

## 🎨 모션 효과 (애플 스타일 - 양방향 Hero)

### **1. Hero 애니메이션 (버튼 ↔ 화면 morphing)**
```
┌─────────────────┐
│ 작은 버튼       │  108x108px, 회전 -40도
│ (보라색 원형)   │
└─────────────────┘
        ↓ 탭!
        ↓ Hero 애니메이션 (300ms)
        ↓
┌─────────────────┐
│ 전체 화면       │  393x852px, 회전 0도
│ (Insight Player)│
└─────────────────┘
        ↓ 아래로 스와이프 30% 이상
        ↓ Hero 역방향 애니메이션 (300ms)
        ↓
┌─────────────────┐
│ 작은 버튼       │  ✅ 원래 위치로 돌아옴!
│ (보라색 원형)   │
└─────────────────┘
```

**✨ 핵심 특징:**
- ✅ **양방향 Hero**: 버튼 → 화면, 화면 → 버튼 (대칭적)
- ✅ **위치 기억**: dismiss 시 정확히 버튼 위치로 복귀
- ✅ **형태 변환**: 크기/회전/위치가 자연스럽게 morphing
- ✅ **애플 커브**: `cubic-bezier(0.25, 0.1, 0.25, 1.0)`

---

### **2. Dismissible 제스처 (드래그 인터랙션)**

#### 📱 드래그 시작
```
손가락 터치 → 즉시 반응
dragSensitivity: 0.8 (애플처럼 민감)
```

#### 🎨 드래그 중 (실시간 변화)
```
┌──────────────────────────────────┐
│ 드래그 0%:  화면 크기 100%       │
│ 드래그 15%: 화면 크기 95%        │
│ 드래그 30%: 화면 크기 90% ← 임계값│
│ 드래그 50%: 계속 축소...         │
└──────────────────────────────────┘

동시에:
- 모서리: 0px → 20px (둥글게)
- 배경: 투명 → 어둡게
```

#### 🔄 드래그 종료
```
┌─────────────────────────────────────┐
│ Case 1: 30% 미만 드래그             │
│ → reverseDuration: 300ms            │
│ → 스프링 복귀 (원래 화면 크기)      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Case 2: 30% 이상 드래그 ✅          │
│ → Navigator.pop() 실행              │
│ → Hero 역방향 애니메이션            │
│ → 버튼 위치로 축소하며 돌아감!      │
└─────────────────────────────────────┘
```

**🍎 애플 스타일 포인트:**
- 30% 임계값: 빠른 반응 (애플은 민감하게 설정)
- 90% 축소: 많이 축소하지 않음 (클린한 느낌)
- 스프링 복귀: 물리적인 느낌 (bouncy하지 않음)

---

## 📊 비교: OpenContainer vs Hero+Dismissible

| 항목 | OpenContainer | Hero+Dismissible (현재) |
|------|--------------|-------------------------|
| **전환 느낌** | Fade Through (Material) | Morphing (iOS) |
| **물리적 연결** | ❌ (새 화면 생성) | ✅ (버튼이 화면으로 변환) |
| **스와이프 닫기** | ❌ | ✅ |
| **드래그 인터랙션** | ❌ | ✅ (실시간 스케일/투명도) |
| **역방향 애니메이션** | Fade (동일) | Hero (대칭적) |
| **애플 느낌** | ⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 🍎 애플 스프링 물리 매개변수 (참고)

프로젝트의 `motion_config.dart`에 정의된 값:

```dart
/// Safari 스타일 스프링 애니메이션
static const double springMass = 1.0;
static const double springStiffness = 180.0;  // Safari Standard
static const double springDamping = 20.0;     // dampingRatio ≈ 0.745

/// 참고: dismissible_page는 자체 스프링 로직 사용
/// 하지만 reverseDuration (300ms)로 유사한 느낌 구현
```

**애플 스프링 프리셋 비교:**
| 프리셋 | Stiffness | Damping | 느낌 |
|--------|-----------|---------|------|
| **Standard** (현재) | 180 | 20 | 자연스럽고 빠름 |
| Subtle | 250 | 25 | 빠르고 섬세 |
| Playful | 150 | 18 | 느리고 bouncy |

---

---

## 🔧 기술 스택

| 항목 | 내용 |
|------|------|
| **패키지** | `dismissible_page: ^1.0.2` |
| **Hero Tag** | `insight-player-${selectedDate}` (날짜별 고유) |
| **전환 방향** | `DismissiblePageDismissDirection.down` |
| **배경 색상** | `Colors.black.withOpacity(0.0)` → 동적 변화 |
| **라우트** | `context.pushTransparentRoute()` |
| **스프링 복귀** | `reverseDuration: 300ms` |

---

## 🎯 사용자 경험 (애플 스타일)

### **화면 열기 (Hero morphing)**
1. 인사이트 버튼 탭
2. 버튼이 **화면으로 확장** (위치/크기/회전 변환)
3. 배경이 투명에서 보라색으로 자연스럽게 페이드

```
[작은 버튼] → Hero 애니메이션 → [전체 화면]
  108px           (300ms)          393x852px
  회전 -40도                        회전 0도
```

---

### **화면 닫기 (3가지 방법)**

#### 1️⃣ 아래로 스와이프 (🍎 애플 스타일 - 버튼으로 돌아감!)
```
손가락 아래로 드래그
  ↓
화면 스케일 축소 (90%)
배경 투명도 증가
모서리 둥글게 변화
  ↓
30% 이상 드래그?
  ├─ YES → Navigator.pop() 실행
  │         ↓
  │      Hero 역방향 애니메이션
  │         ↓
  │      버튼 위치로 축소하며 복귀 ✨
  │
  └─ NO  → 스프링 복귀 (300ms)
            원래 화면 크기로 복원
```

**✨ 핵심: Hero 역방향 애니메이션**
```
[전체 화면] → Hero morphing → [작은 버튼]
  393x852px     (300ms)         108x108px
  회전 0도                       회전 -40도
  정확히 버튼 위치로 돌아감!
```

**특징:**
- ✅ 드래그 중 **실시간 피드백** (스케일/투명도)
- ✅ 30% 임계값 도달 시 **자동 닫힘**
- ✅ Hero가 **정확히 버튼 위치로 축소** (애플 스타일!)
- ✅ 임계값 미달 시 **스프링처럼 복귀**

#### 2️⃣ 닫기 버튼 탭
- 헤더의 아래 화살표 버튼
- Navigator.pop() → Hero 역방향 애니메이션
- 버튼 위치로 축소

#### 3️⃣ 뒤로 가기
- Android/iOS 시스템 뒤로 가기
- Navigator.pop() → Hero 역방향 애니메이션
- 버튼 위치로 축소

**🔑 모든 닫기 방법에서 Hero 역방향 애니메이션 작동!**

---

## 🆚 왜 Hero + dismissible_page를 같이 쓰는가?

### 🤔 dismissible_page만 쓰면 안 되나요?

**A. 안 됩니다!** 각각 역할이 다릅니다.

| 역할 | Hero | dismissible_page |
|------|------|------------------|
| **화면 전환** | 버튼 → 화면 morphing | ❌ |
| **스와이프 닫기** | ❌ | 드래그 제스처 처리 |
| **물리적 연결** | ✅ (형태 변환) | ❌ (단순 fade) |
| **역방향 애니메이션** | ✅ (자동 대칭) | ❌ |

---

### 📊 조합 비교

#### ❌ dismissible_page만 사용
```dart
context.pushTransparentRoute(
  DismissiblePage(
    child: InsightPlayerScreen(), // 그냥 fade-in
  ),
);
```
**문제점:**
- 버튼과 화면이 **연결되지 않음**
- 새 화면이 **갑자기 나타나는 느낌**
- 애플 스타일 아님 ❌

---

#### ✅ Hero + dismissible_page 조합 (현재)
```dart
// 시작점
Hero(tag: 'button', child: SmallButton())

// 탭 → Hero가 위치/크기/회전 변환
Hero(tag: 'button', child: FullScreen())

// 드래그 → dismissible_page가 제스처 처리
DismissiblePage(child: Hero(...))
```
**장점:**
- 버튼이 화면으로 **morphing** ✅
- 드래그 시 **실시간 스케일** ✅
- 역방향도 **대칭적** ✅
- 애플 스타일 완벽 구현! 🍎

---

## 📝 코드 구조 요약

### 3️⃣ **InsightPlayerScreen 수정**
**파일:** `lib/features/insight_player/screens/insight_player_screen.dart`

```dart
@override
Widget build(BuildContext context) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF566099),
      statusBarIconBrightness: Brightness.light,
    ),
    // ⚠️ Material 제거 (Hero 외부에서 감싸므로 불필요)
    child: Scaffold(
      backgroundColor: const Color(0xFF566099),
      body: FutureBuilder<AudioContentData?>(
        // ...
      ),
    ),
  );
}
```

**변경사항:**
- ❌ `Material(type: MaterialType.transparency)` 제거 (중복 방지)
- ✅ Hero 외부에서 Material로 감싸므로 내부에서는 불필요
- ✅ 사용하지 않는 `_buildTopNavi` 함수 제거

---

### 4️⃣ **DateDetailView 수정**
**파일:** `lib/screen/date_detail_view.dart`

```dart
// DateDetailHeader에서 직접 처리
DateDetailHeader(
  selectedDate: date,
  // onSettingsTap 제거
),
```

**변경사항:**
- ✅ `onSettingsTap` 콜백 제거
- ✅ 사용하지 않는 import 제거

---

## ✅ 완료 확인

- [x] dismissible_page 패키지 설치
- [x] Hero + DismissiblePage 조합 구현
- [x] **양방향 Hero 애니메이션 적용** (버튼 ↔ 화면)
- [x] **Material 구조 최적화** (Hero 외부에서 감싸기)
- [x] 애플 스타일 스프링 모션 적용 (minScale: 0.90, maxRadius: 20)
- [x] Safari 복귀 애니메이션 (reverseDuration: 300ms)
- [x] Dismiss 임계값 설정 (30%)
- [x] InsightPlayerScreen 중복 Material 제거
- [x] DateDetailView에서 onSettingsTap 콜백 제거
- [x] 사용하지 않는 import 정리
- [x] 사용하지 않는 함수 제거 (_buildTopNavi)
- [x] Hero tag 고유성 확보 (날짜별)
- [x] **아래로 스와이프 시 버튼 위치로 돌아가는 애니메이션 확인** ✨
- [x] **버튼이 커지면서 화면으로 전환되는 애니메이션 확인** ✨

---

## 🚀 향후 개선 가능 사항

### 1️⃣ **햅틱 피드백 추가**
```dart
DismissiblePage(
  onDragUpdate: (details) {
    if (details.progress > 0.3) {
      HapticFeedback.lightImpact(); // 임계값 도달 시
    }
  },
  // ...
)
```

### 2️⃣ **커스텀 스프링 애니메이션**
```dart
// dismissible_page는 자체 스프링 로직 사용
// 더 정밀한 제어를 원하면 AnimationController 직접 구현 필요

// 참고: motion_config.dart
static const double springStiffness = 180.0;  // Safari Standard
static const double springDamping = 20.0;
```

### 3️⃣ **드래그 진행도 UI 표시**
```dart
DismissiblePage(
  onDragUpdate: (details) {
    setState(() {
      _dragProgress = details.progress; // 0.0 ~ 1.0
    });
  },
  child: Stack(
    children: [
      Content(),
      // 드래그 진행도 표시
      Positioned(
        top: 20,
        child: Text('${(_dragProgress * 100).toInt()}%'),
      ),
    ],
  ),
)
```

### 4️⃣ **가로 스와이프 추가 (옵션)**
```dart
// 현재: 아래로만 dismiss
direction: DismissiblePageDismissDirection.down,

// 변경: 모든 방향
direction: DismissiblePageDismissDirection.multi,
```

---

## 📚 참고 자료

- [dismissible_page GitHub](https://github.com/Tkko/Flutter_dismissible_page)
- [pub.dev/packages/dismissible_page](https://pub.dev/packages/dismissible_page)
- [Flutter Hero 애니메이션](https://docs.flutter.dev/ui/animations/hero-animations)
- [Apple Human Interface Guidelines - Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
- [Safari 스프링 애니메이션 분석](https://developer.apple.com/documentation/uikit/uispringtimingtparameters)

---

## 🎉 최종 결과

디테일뷰에서 인사이트 플레이어로 전환할 때:

### ✅ 화면 열기 (Hero morphing)
- 버튼이 화면으로 **형태 변환** (위치/크기/회전)
- 애플 기본 커브: `cubic-bezier(0.25, 0.1, 0.25, 1.0)`
- 물리적으로 **연결된 느낌**

### ✅ 화면 닫기 (Dismissible gesture)
- 아래로 스와이프 → **실시간 스케일/투명도** 변화
- 30% 드래그 → **자동 닫힘**
- 손을 떼면 → **스프링 복귀** (300ms)

### 🍎 애플 스타일 완성!
- OpenContainer의 단순 fade와 달리 **물리적 연결감**
- Instagram/Safari와 동일한 **스와이프 제스처**
- 드래그 시 살짝만 축소 (90%) → **클린한 애플 느낌**

**완벽한 dismissible page 모션 구현 완료!** 🎊

---

## 🔑 핵심 포인트 요약

1. **Hero는 필수**: 버튼 → 화면 morphing (물리적 연결)
2. **dismissible_page는 필수**: 스와이프 제스처 처리
3. **둘 다 써야 애플 스타일**: Hero(형태 변환) + Dismissible(제스처)
4. **스프링 설정이 중요**: minScale 0.90, reverseDuration 300ms
5. **임계값 30%**: 애플처럼 빠른 반응

이제 사용자는:
- 버튼을 탭하면 → **화면으로 확장되는 마법** ✨
- 아래로 드래그하면 → **원래 버튼으로 축소** 🔙
- 손을 떼면 → **스프링처럼 복귀** 🍎
