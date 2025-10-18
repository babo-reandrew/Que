# 헤딩 모션 + 배경 투명도 구현 완료

## 📋 개요

**날짜**: 2024-10-18
**목적**: 월뷰→디테일뷰 진입 시 헤딩 모션, Pull-to-dismiss 시 배경 투명도 적용
**결과**: ✅ 자연스러운 진입 애니메이션 + 뒤 화면 보이는 효과

---

## 🎯 구현 내용

### 1. 헤딩 모션 (Heading Motion)
**진입 시 0.95 → 1.0 스케일로 부드럽게 확대**

```dart
// lib/screen/date_detail_view.dart (lines 66-79)

_entryController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 400),
);

_entryScaleAnimation = Tween<double>(
  begin: 0.95, // 95% 크기로 시작
  end: 1.0,    // 100% 크기로 확대
).animate(CurvedAnimation(
  parent: _entryController,
  curve: Curves.easeOutCubic, // 부드러운 감속 커브
));

// 진입 애니메이션 시작
_entryController.forward();
```

**효과**:
- OpenContainer fadeThrough와 동시에 실행
- 95% → 100% 약간 확대되면서 진입
- 자연스럽고 생동감 있는 느낌 ✨

### 2. 배경 투명도 (Background Opacity)
**Pull-to-dismiss 시 배경이 점점 투명해져서 뒤 화면 보임**

```dart
// lib/screen/date_detail_view.dart (lines 127-130)

// 드래그에 따른 배경 투명도 계산 (1.0 → 0.0)
// 끌어내릴수록 투명해져서 뒤 화면이 보임
final backgroundOpacity = 1.0 - dismissProgress;
```

```dart
// Stack 구조로 배경 레이어 분리 (lines 132-147)

return Stack(
  children: [
    // ✅ 배경 레이어 (투명도 조절)
    Positioned.fill(
      child: Opacity(
        opacity: backgroundOpacity, // 1.0 → 0.0
        child: Container(
          color: const Color(0xFFF7F7F7),
        ),
      ),
    ),
    
    // ✅ 메인 콘텐츠 레이어
    Material(/* ... */),
  ],
);
```

**효과**:
- 드래그 0%: 배경 불투명도 100% (완전히 가림)
- 드래그 50%: 배경 불투명도 50% (반투명)
- 드래그 100%: 배경 불투명도 0% (완전히 투명, 뒤 화면 보임) ✨

### 3. 애니메이션 결합
**진입 스케일 + 드래그 스케일 결합**

```dart
// lib/screen/date_detail_view.dart (lines 135-139)

return AnimatedBuilder(
  animation: _entryScaleAnimation,
  builder: (context, child) {
    // 진입 애니메이션과 드래그 스케일 결합
    final combinedScale = _entryScaleAnimation.value * scale;
    
    return Transform.scale(
      scale: combinedScale, // 0.95 → 1.0 → 0.85
      alignment: Alignment.topCenter,
      child: /* ... */,
    );
  },
);
```

**스케일 변화 타임라인**:
```
진입 (0-400ms):
0.95 (start) ────▶ 1.0 (end)
OpenContainer fadeThrough 동시 실행

드래그 (사용자 제스처):
1.0 (정상) ────▶ 0.85 (끌어내림)
배경 투명도 1.0 → 0.0 동시 변화
```

---

## 🎨 사용자 경험

### 월뷰 → 디테일뷰 진입

1. **셀 탭**
   - OpenContainer fadeThrough 시작 (400ms)
   - 콘텐츠가 fade out → middle color → fade in

2. **동시에 헤딩 모션 실행**
   - 디테일뷰가 95% 크기로 나타남
   - 400ms 동안 100% 크기로 부드럽게 확대
   - `Curves.easeOutCubic`: 빠르게 시작 → 천천히 정지

3. **결과**
   - "살짝 커지면서 나타나는" 자연스러운 느낌 ✨
   - OpenContainer의 fadeThrough와 완벽한 조화
   - iOS 네이티브 앱과 유사한 진입 효과

### Pull-to-Dismiss 드래그 중

1. **드래그 시작 (0%)**
   ```
   배경 불투명도: 100%
   화면 스케일: 100%
   border radius: 36px
   뒤 화면: 안 보임
   ```

2. **드래그 중 (50%)**
   ```
   배경 불투명도: 50% ✨
   화면 스케일: 92.5%
   border radius: 24px
   뒤 화면: 반투명하게 보임 ✨
   ```

3. **드래그 끝 (100%)**
   ```
   배경 불투명도: 0% ✨
   화면 스케일: 85%
   border radius: 12px
   뒤 화면: 완전히 보임 ✨
   ```

4. **효과**
   - "뒤로 밀려나는" 느낌
   - 뒤에 월뷰가 보이면서 맥락 유지
   - 사용자가 어디로 돌아가는지 명확함

---

## 🔧 기술 구현 세부사항

### TickerProviderStateMixin
```dart
class _DateDetailViewState extends State<DateDetailView>
    with TickerProviderStateMixin {
  // 두 개의 AnimationController 사용
  late AnimationController _dismissController;
  late AnimationController _entryController;
}
```

**변경 이유**:
- `SingleTickerProviderStateMixin` → `TickerProviderStateMixin`
- 여러 개의 AnimationController 사용 가능

### 진입 애니메이션 파라미터
```dart
duration: Duration(milliseconds: 400)
begin: 0.95  // 95% 크기
end: 1.0     // 100% 크기
curve: Curves.easeOutCubic
```

**선택 이유**:
- **400ms**: OpenContainer fadeThrough와 동일한 duration (동기화)
- **0.95 → 1.0**: 5% 확대로 미묘하고 자연스러움
- **easeOutCubic**: 빠른 시작 + 부드러운 정지 (heading 느낌)

### 배경 투명도 계산
```dart
final dismissProgress = (_dragOffset / screenHeight).clamp(0.0, 1.0);
final backgroundOpacity = 1.0 - dismissProgress;
```

**수식**:
- `dismissProgress = 0.0`: `backgroundOpacity = 1.0` (불투명)
- `dismissProgress = 0.5`: `backgroundOpacity = 0.5` (반투명)
- `dismissProgress = 1.0`: `backgroundOpacity = 0.0` (투명)

**선형 관계**: 드래그 거리에 정확히 비례

### Stack 레이어 구조
```
Stack
├─ Positioned.fill (배경 레이어)
│  └─ Opacity (투명도 조절)
│     └─ Container (색상 #F7F7F7)
│
└─ Material (메인 콘텐츠 레이어)
   └─ GestureDetector
      └─ Transform.translate (드래그 이동)
         └─ Transform.scale (스케일 축소)
            └─ ClipRRect (border radius)
               └─ Scaffold (실제 UI)
```

**장점**:
- 배경과 콘텐츠 레이어 분리
- 배경만 투명도 조절 가능
- 콘텐츠는 스케일/이동만 적용

---

## 📊 애니메이션 타임라인

### 진입 시 (0-400ms)
```
Time:       0ms           200ms          400ms
            │             │              │
OpenContainer fadeThrough:
            fade out ─────▶ middle ─────▶ fade in

Entry Scale:
            0.95 ─────────────────────────▶ 1.0

Border Radius:
            0px ──────────────────────────▶ 36px

Result:
            [셀] ─────────▶ [중간] ─────────▶ [디테일뷰]
                          살짝 작음        정상 크기
```

### Pull-to-Dismiss 시 (실시간)
```
Drag:       0%            50%            100%
            │             │              │
Scale:      1.0 ──────────▶ 0.925 ──────▶ 0.85

Opacity:    1.0 ──────────▶ 0.5 ────────▶ 0.0
            불투명         반투명         투명

Radius:     36px ─────────▶ 24px ───────▶ 12px

Visible:    [디테일뷰]     [디테일뷰]     [디테일뷰]
            뒤 안 보임     뒤 약간 보임   뒤 완전히 보임
```

---

## ✅ 구현 완료 체크리스트

### 헤딩 모션
- [x] AnimationController 추가 (_entryController)
- [x] Tween<double> 정의 (0.95 → 1.0)
- [x] CurvedAnimation 적용 (Curves.easeOutCubic)
- [x] AnimatedBuilder로 빌드 래핑
- [x] combinedScale 계산 (entry * drag)
- [x] dispose에서 리소스 정리

### 배경 투명도
- [x] dismissProgress 기반 opacity 계산
- [x] Stack 구조로 레이어 분리
- [x] Positioned.fill + Opacity 배경 레이어
- [x] Material 메인 콘텐츠 레이어
- [x] 실시간 투명도 업데이트 (setState)

### 통합 테스트
- [ ] 진입 시 95% → 100% 확대 확인
- [ ] fadeThrough와 동시 실행 확인
- [ ] 드래그 시 배경 투명도 변화 확인
- [ ] 뒤 월뷰 화면 보이는지 확인
- [ ] 스케일 결합 (entry + drag) 정상 동작 확인

---

## 🎓 핵심 포인트

### 1. 헤딩 모션의 효과
- **미묘한 확대** (95% → 100%): 너무 크지 않아 자연스러움
- **빠른 시작** (easeOutCubic): 즉각적인 반응감
- **부드러운 정지**: 안정적으로 안착

### 2. 배경 투명도의 효과
- **맥락 유지**: 어디로 돌아가는지 명확
- **시각적 피드백**: 드래그 진행 상태 직관적
- **공간 인식**: 디테일뷰가 "위에 떠있는" 느낌

### 3. 애니메이션 동기화
- **진입**: OpenContainer (400ms) + Entry Scale (400ms)
- **드래그**: Scale + Opacity + Radius 동시 변화
- **일관성**: 모든 애니메이션이 조화롭게 작동

---

## 🧪 테스트 가이드

### 1. 진입 애니메이션 테스트
```
1. 월뷰에서 셀 탭
2. 확인: 디테일뷰가 살짝 작게 나타나는가?
3. 확인: 400ms 동안 정상 크기로 확대되는가?
4. 확인: fadeThrough와 동시에 실행되는가?
5. 느낌: 자연스럽고 생동감 있는가? ✨
```

### 2. 배경 투명도 테스트
```
1. 디테일뷰 진입
2. 천천히 아래로 드래그
3. 확인: 배경이 점점 투명해지는가?
4. 확인: 뒤 월뷰 화면이 보이는가? ✨
5. 확인: 드래그 거리에 비례하는가?
```

### 3. 통합 테스트
```
1. 월뷰 → 디테일뷰: 헤딩 모션 확인
2. Pull-to-dismiss: 배경 투명도 + 스케일 확인
3. 원위치 복귀: SpringSimulation 확인
4. Dismiss 완료: fadeThrough 복귀 확인
```

---

## 📝 요약

### Before
```
진입: fadeThrough만 (콘텐츠 fade)
배경: 항상 불투명 (뒤 안 보임)
```

### After
```
진입: fadeThrough + 헤딩 모션 (0.95 → 1.0) ✨
배경: 드래그에 따라 투명해짐 (뒤 화면 보임) ✨
```

### 핵심 개선사항
1. ✅ **헤딩 모션**: 살짝 확대되면서 진입 (95% → 100%)
2. ✅ **배경 투명도**: 끌어내릴수록 뒤 화면 보임 (opacity 1.0 → 0.0)
3. ✅ **애니메이션 동기화**: fadeThrough + entry scale 완벽 조화
4. ✅ **맥락 유지**: 사용자가 어디로 가는지/돌아가는지 명확

### 사용자가 느끼는 효과
> "디테일뷰가 살짝 커지면서 나타나고,  
> 끌어내리면 뒤에 월뷰가 보이면서 부드럽게 닫힌다.  
> iOS 앱처럼 자연스럽고 직관적이다!" ✨

---

## 🚀 다음 단계

### 즉시 테스트
```bash
flutter run
```

### 확인 포인트
1. 월뷰 → 디테일뷰: 헤딩 모션 (95% → 100%)
2. Pull-to-dismiss: 배경 투명도 (뒤 화면 보임)
3. 스케일 결합: entry + drag 자연스러움
4. 전체 플로우: 진입 → 드래그 → 복귀/dismiss

### Git Commit
```bash
git add .
git commit -m "feat: 헤딩 모션 + 배경 투명도 구현

- 진입 시 헤딩 모션 (scale: 0.95 → 1.0, 400ms)
- Curves.easeOutCubic으로 자연스러운 확대
- Pull-to-dismiss 시 배경 투명도 (1.0 → 0.0)
- Stack 레이어로 배경/콘텐츠 분리
- 뒤 월뷰 화면 보이면서 맥락 유지
- AnimatedBuilder로 entry + drag scale 결합
- TickerProviderStateMixin으로 다중 애니메이션"
```

---

**작성일**: 2024-10-18
**상태**: ✅ 완료 및 테스트 대기
**핵심**: Heading Motion (0.95 → 1.0) + Background Fade (1.0 → 0.0) ✨
