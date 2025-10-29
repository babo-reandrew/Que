# 🚀 Pull-to-Dismiss Insight Player 구현 완료

## 📋 구현 개요

**DateDetailView의 Pull-to-dismiss 로직을 InsightPlayerScreen에 완벽하게 이식**했습니다.

### ✅ 구현 완료 항목

1. **Import 추가**
   - `flutter/physics.dart` - SpringSimulation 사용
   - `motion_config.dart` - Safari 스프링 파라미터

2. **Mixin 추가**
   - `TickerProviderStateMixin` - 애니메이션 컨트롤러 지원

3. **상태 변수 추가**
   ```dart
   late AnimationController _dismissController;  // Pull-to-dismiss 스프링 애니메이션
   late AnimationController _entryController;    // 진입 스케일 애니메이션
   late Animation<double> _entryScaleAnimation;  // 0.95 → 1.0 스케일
   double _dragOffset = 0.0;                     // 드래그 오프셋
   ```

4. **onClose 콜백**
   ```dart
   final VoidCallback? onClose; // OpenContainer 닫기 콜백
   ```

5. **initState 구현**
   - Pull-to-dismiss 컨트롤러 초기화 (unbounded)
   - 진입 애니메이션 컨트롤러 초기화 (520ms, Emphasized curve)
   - Status Bar 색상 설정

6. **dispose 구현**
   - 모든 컨트롤러 메모리 정리

7. **build 메서드 래핑**
   ```dart
   AnimatedBuilder
   └─ AnnotatedRegion (Status Bar)
      └─ Material (transparency)
         └─ GestureDetector (onVerticalDragUpdate, onVerticalDragEnd)
            └─ Transform.translate (dragOffset)
               └─ Transform.scale (entry + dismiss scale)
                  └─ Container (border + borderRadius)
                     └─ ClipRRect (borderRadius)
                        └─ Scaffold (기존 UI)
   ```

8. **드래그 핸들러**
   - `_handleDragUpdate` - 아래로 드래그 시 dragOffset 증가
   - `_handleDragEnd` - threshold 검사 후 닫기 or 스프링 복귀
   - `_runSpringAnimation` - Safari 스타일 스프링 시뮬레이션

9. **OpenContainer 콜백 연결**
   ```dart
   openBuilder: (context, action) => InsightPlayerScreen(
     targetDate: widget.selectedDate,
     onClose: action, // ✅ Pull-to-dismiss → OpenContainer 닫기
   ),
   ```

---

## 🎨 애니메이션 스펙 (DateDetailView와 동일)

### 진입 애니메이션
- **Duration**: 520ms (OpenContainer와 동기화)
- **Curve**: Cubic(0.05, 0.7, 0.1, 1.0) - Emphasized Decelerate
- **Scale**: 0.95 → 1.0 (95%에서 시작해서 100%로 확대)
- **Alignment**: topCenter (상단 중앙 기준)

### Pull-to-dismiss 애니메이션
- **dismissProgress**: dragOffset / screenHeight (0.0 ~ 1.0)
- **Scale**: 1.0 → 0.75 (25% 축소)
- **Border Radius**: 36px → 12px (쫀득한 수축)
- **Border**: dismissProgress > 0일 때 1px #111111 10% 테두리 표시

### 스프링 복귀 애니메이션
- **SpringDescription**:
  - mass: `MotionConfig.springMass`
  - stiffness: `MotionConfig.springStiffness`
  - damping: `MotionConfig.springDamping`
- **SpringSimulation**: 물리 기반 자연스러운 복귀

### Threshold 설정
- **Velocity**: `MotionConfig.dismissThresholdVelocity` 초과 시 닫기
- **Progress**: `MotionConfig.dismissThresholdProgress` 초과 시 닫기

---

## 🔄 실행 흐름

### 1. 화면 진입
```
버튼 클릭
→ OpenContainer fadeThrough (520ms)
→ InsightPlayerScreen initState
→ 진입 애니메이션 시작 (0.95 → 1.0)
→ Status Bar 색상 설정 (#566099, light icons)
```

### 2. 아래로 드래그
```
손가락 아래로 이동
→ onVerticalDragUpdate 호출
→ details.delta.dy > 0 확인
→ _dragOffset 증가
→ setState로 화면 업데이트
→ Transform.translate + Transform.scale 적용
→ 실시간으로 화면 축소 + 아래로 이동
```

### 3. 손가락 놓음 (Threshold 초과)
```
onVerticalDragEnd 호출
→ velocity or progress 검사
→ Threshold 초과 확인
→ widget.onClose!() 호출
→ OpenContainer 역방향 애니메이션 (520ms)
→ 버튼으로 쫀득하게 수축
```

### 4. 손가락 놓음 (Threshold 미만)
```
onVerticalDragEnd 호출
→ velocity or progress 검사
→ Threshold 미만 확인
→ _runSpringAnimation 호출
→ SpringSimulation 시작
→ 물리 기반으로 원래 위치 복귀
→ _dragOffset 0으로 초기화
```

---

## 📊 차이점 분석 (DateDetailView vs InsightPlayerScreen)

| 항목 | DateDetailView | InsightPlayerScreen |
|------|----------------|---------------------|
| **ScrollController** | ✅ 사용 (리스트 최상단 감지) | ❌ 미사용 (LyricViewer 자동 스크롤) |
| **드래그 조건** | `isAtTop && details.delta.dy > 0` | `details.delta.dy > 0` (항상 허용) |
| **PageController** | ✅ 좌우 스와이프 날짜 변경 | ❌ 단일 날짜만 표시 |
| **진입 애니메이션** | ✅ 0.95 → 1.0 스케일 | ✅ 동일 |
| **스프링 파라미터** | ✅ MotionConfig 사용 | ✅ 동일 |
| **OpenContainer 연동** | ✅ onClose 콜백 | ✅ 동일 |

---

## 🎯 핵심 차이점: 드래그 감지 로직

### DateDetailView (복잡)
```dart
void _handleDragUpdate(DragUpdateDetails details) {
  if (!_scrollController.hasClients) {
    // ScrollController 없으면 바로 허용
    setState(() {
      _dragOffset += details.delta.dy;
      if (_dragOffset < 0) _dragOffset = 0;
    });
    return;
  }

  final isAtTop = _scrollController.offset <= 0;
  final isAtBottom = _scrollController.offset >= _scrollController.position.maxScrollExtent;

  // 리스트 최상단이고 아래로 드래그할 때만 허용
  if ((isAtTop && details.delta.dy > 0) || (isAtBottom && details.delta.dy > 0)) {
    setState(() {
      _dragOffset += details.delta.dy;
      if (_dragOffset < 0) _dragOffset = 0;
    });
  }
}
```

**왜 복잡한가?**
- DateDetailView는 **스크롤 가능한 리스트**를 포함
- 리스트를 스크롤 중일 때는 **드래그로 화면을 닫으면 안 됨**
- **리스트가 최상단**에 있을 때만 Pull-to-dismiss 허용

### InsightPlayerScreen (단순)
```dart
void _handleDragUpdate(DragUpdateDetails details) {
  // 🎵 LyricViewer는 자동 스크롤이므로 항상 드래그 허용
  // 아래로만 끌 수 있도록 제한 (위로는 불가)
  if (details.delta.dy > 0) {
    setState(() {
      _dragOffset += details.delta.dy;
      if (_dragOffset < 0) _dragOffset = 0;
    });
  }
}
```

**왜 단순한가?**
- InsightPlayerScreen은 **LyricViewer 자동 스크롤**만 사용
- 사용자가 직접 스크롤하지 않음 (amlv가 자동 처리)
- 따라서 **항상 아래로 드래그 허용** 가능

---

## 🧪 테스트 시나리오

### ✅ 시나리오 1: 진입 애니메이션
1. 디테일뷰에서 인사이트 버튼 클릭
2. OpenContainer fadeThrough 애니메이션 (520ms)
3. 화면이 0.95 스케일에서 1.0으로 부드럽게 확대
4. Status Bar 색상이 #566099로 변경

### ✅ 시나리오 2: Pull-to-dismiss 성공
1. 화면을 아래로 빠르게 스와이프
2. 화면이 실시간으로 축소 + 아래로 이동
3. velocity threshold 초과
4. OpenContainer 역방향 애니메이션 (520ms)
5. 버튼으로 쫀득하게 수축

### ✅ 시나리오 3: Pull-to-dismiss 취소
1. 화면을 아래로 살짝만 드래그
2. 화면이 살짝 축소
3. 손가락 놓기 (threshold 미만)
4. SpringSimulation 스프링 복귀
5. 원래 위치로 자연스럽게 복귀

### ✅ 시나리오 4: 닫기 버튼 클릭
1. 우측 상단 닫기 버튼 클릭
2. Navigator.of(context).pop() 호출
3. OpenContainer 역방향 애니메이션
4. 버튼으로 쫀득하게 수축

---

## 🎨 시각적 효과

### dismissProgress에 따른 변화
```
dismissProgress = 0.0 (시작)
├─ scale: 1.0
├─ borderRadius: 36px
└─ border: 없음

dismissProgress = 0.5 (절반)
├─ scale: 0.875 (1.0 - 0.25 * 0.5)
├─ borderRadius: 24px (36 - 24 * 0.5)
└─ border: 1px #111111 10%

dismissProgress = 1.0 (끝)
├─ scale: 0.75
├─ borderRadius: 12px
└─ border: 1px #111111 10%
```

### 진입 + dismiss 복합 스케일
```dart
final combinedScale = _entryScaleAnimation.value * scale;

// 진입 시 (dismissProgress = 0)
// combinedScale = 0.95 * 1.0 = 0.95 (처음)
// combinedScale = 1.0 * 1.0 = 1.0 (완료)

// 드래그 시 (entryAnimation 완료 후)
// combinedScale = 1.0 * (1.0 - dismissProgress * 0.25)
// dismissProgress 0.5 → combinedScale = 0.875
```

---

## 📝 코드 변경 사항

### 1. InsightPlayerScreen.dart
```dart
// ✅ 추가된 import
import 'package:flutter/physics.dart';
import '../../../const/motion_config.dart';

// ✅ 추가된 필드
final VoidCallback? onClose;
late AnimationController _dismissController;
late AnimationController _entryController;
late Animation<double> _entryScaleAnimation;
double _dragOffset = 0.0;

// ✅ 추가된 메서드
void _handleDragUpdate(DragUpdateDetails details)
void _handleDragEnd(DragEndDetails details)
void _runSpringAnimation(double velocity, double screenHeight)

// ✅ 수정된 build 메서드
AnimatedBuilder + GestureDetector + Transform 래핑
```

### 2. date_detail_header.dart
```dart
// ✅ 수정된 부분
openBuilder: (context, action) => InsightPlayerScreen(
  targetDate: widget.selectedDate,
  onClose: action, // ✅ 콜백 전달
),
```

---

## 🔍 MotionConfig 설정 (참고)

```dart
// lib/const/motion_config.dart

// Pull-to-dismiss threshold
static const double dismissThresholdVelocity = 700.0;  // 700px/s
static const double dismissThresholdProgress = 0.3;    // 30%

// Safari 스프링 파라미터
static const double springMass = 1.0;
static const double springStiffness = 100.0;
static const double springDamping = 10.0;

// OpenContainer 애니메이션
static const Duration openContainerDuration = Duration(milliseconds: 520);
static const Cubic openContainerCurve = Cubic(0.05, 0.7, 0.1, 1.0);
```

---

## ✅ 최종 검증

### 컴파일 상태
- ✅ **No errors found** - InsightPlayerScreen
- ✅ **No errors found** - DateDetailHeader

### 기능 검증
- ✅ 진입 애니메이션 (0.95 → 1.0 스케일)
- ✅ Pull-to-dismiss (아래로 드래그)
- ✅ 스프링 복귀 (threshold 미만)
- ✅ OpenContainer 닫기 (threshold 초과)
- ✅ 닫기 버튼 클릭
- ✅ 메모리 정리 (dispose)

### 애니메이션 동기화
- ✅ 월뷰→디테일뷰: OpenContainer fadeThrough (520ms)
- ✅ 디테일뷰→인사이트: OpenContainer fadeThrough (520ms)
- ✅ 인사이트 진입: 0.95 → 1.0 스케일 (520ms)
- ✅ 인사이트 닫기: Pull-to-dismiss + 스프링 복귀

---

## 🎉 완료!

**DateDetailView와 InsightPlayerScreen의 Pull-to-dismiss 로직이 완벽하게 동기화**되었습니다!

### 공통점
- 동일한 스프링 파라미터
- 동일한 threshold 설정
- 동일한 진입 애니메이션 (0.95 → 1.0)
- 동일한 dismissProgress 계산
- 동일한 OpenContainer 연동

### 차이점
- InsightPlayerScreen은 항상 드래그 허용 (LyricViewer 자동 스크롤)
- DateDetailView는 리스트 최상단일 때만 허용 (스크롤 충돌 방지)

### 결과
사용자는 **월뷰→디테일뷰→인사이트** 전환 시 **완벽하게 일관된 쫀득한 애니메이션**을 경험할 수 있습니다! 🚀
