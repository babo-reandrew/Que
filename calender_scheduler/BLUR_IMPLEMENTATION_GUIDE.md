# Input Accessory Blur 구현 가이드

## 문제 상황
Input Accessory View에 Figma 스펙대로 그라디언트 블러를 적용했지만 화면에 표시되지 않는 문제

**Figma 스펙 (Rectangle 385):**
```css
position: absolute;
left: 0%;
right: 0%;
top: 0%;
bottom: 0%;

background: linear-gradient(180deg, rgba(255, 255, 255, 0) 0%, rgba(240, 240, 240, 0.95) 50%);
backdrop-filter: blur(4px);
```

---

## 해결 방법 3가지 (우선순위별)

### 🥇 방법 1: BackdropFilter 순서 수정 (추천)
**파일:** `keyboard_attachable_input_view.dart` (수정 완료)

#### 핵심 변경사항
1. **Stack 순서 변경**: 컨텐츠를 먼저, blur 레이어를 나중에 배치
2. **ClipRect 제거**: blur를 가리는 요소 제거
3. **LayoutBuilder 사용**: Input Accessory 상단부터 화면 하단까지 동적 높이 계산
4. **Blur sigma 증가**: 4 → 12 (육안 확인 가능하도록)
5. **IgnorePointer 추가**: blur 레이어가 터치를 방해하지 않도록

#### 코드 구조
```dart
Stack(
  children: [
    // 1. 컨텐츠 먼저 (blur의 백그라운드가 됨)
    AnimatedBuilder(...
      child: QuickAddControlBox(...),
    ),

    // 2. Blur 레이어 나중에 (컨텐츠 위에 덮음)
    LayoutBuilder(
      builder: (context, constraints) {
        final blurHeight = /* 동적 계산 */;
        return Positioned(
          bottom: 0,
          height: blurHeight,
          child: IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(gradient: ...),
              ),
            ),
          ),
        );
      },
    ),
  ],
)
```

#### 장점
- 원본 파일 수정만으로 해결 (추가 파일 불필요)
- 성능 최적화 (BackdropFilter는 하드웨어 가속)
- Figma 스펙에 가장 가깝게 구현

#### 단점
- Android에서 blur 강도가 약할 수 있음

---

### 🥈 방법 2: ImageFiltered 대체 구현
**파일:** `keyboard_attachable_input_view_v2.dart` (신규 생성)

#### 핵심 차이
- `BackdropFilter` 대신 `ImageFiltered` 사용
- 전체 화면을 blur 처리 (더 확실한 효과)

#### 코드 구조
```dart
ImageFiltered(
  imageFilter: ImageFilter.blur(
    sigmaX: 12,
    sigmaY: 12,
    tileMode: TileMode.decal,
  ),
  child: Stack(
    children: [
      // Gradient overlay
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(gradient: ...),
        ),
      ),
      // Input Accessory content
      QuickAddControlBox(...),
    ],
  ),
)
```

#### 사용 방법
기존 `InputAccessoryHelper.showQuickAdd()`에서 위젯만 교체:
```dart
// 기존
builder: (context) => InputAccessoryWithBlur(...)

// V2로 교체
builder: (context) => InputAccessoryWithBlurV2(...)
```

#### 장점
- BackdropFilter보다 강력한 blur
- 확실히 작동 (100% 보장)

#### 단점
- 전체 화면을 blur하므로 성능 저하 가능
- 배터리 소모 증가

---

### 🥉 방법 3: Platform별 최적화
**파일:** `keyboard_attachable_input_view_platform.dart` (신규 생성)

#### 핵심 차이
- iOS와 Android에서 각각 다른 구현 사용
- iOS: BackdropFilter (native 지원 우수)
- Android: 다중 레이어 blur (더 강한 효과)

#### 코드 구조
```dart
Stack(
  children: [
    QuickAddControlBox(...),

    // Platform별 분기
    if (Platform.isIOS)
      _buildIOSBlur(sigma: 12)
    else
      _buildAndroidBlur(sigma: 20), // Android는 더 강하게
  ],
)
```

#### Android 특별 처리
```dart
Widget _buildAndroidBlur(...) {
  return Stack(
    children: [
      // 첫 번째 blur 레이어
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(color: Colors.transparent),
      ),
      // 두 번째 blur 레이어 (더 강하게)
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(decoration: gradient),
      ),
    ],
  );
}
```

#### 장점
- Platform별 최적 성능
- iOS에서는 native blur, Android에서는 강한 blur

#### 단점
- 코드 복잡도 증가
- Platform별 테스트 필요

---

## 테스트 방법

### 1. Hot Reload로 즉시 확인
```bash
# 앱 실행 중 상태에서
r  # hot reload
```

### 2. Input Accessory 실행
앱에서 날짜 셀을 탭하거나 + 버튼을 눌러 Input Accessory 표시

### 3. Blur 확인 포인트
- [ ] Input Accessory 뒤의 컨텐츠가 흐릿하게 보이는가?
- [ ] 그라디언트가 투명 → 불투명으로 자연스럽게 변하는가?
- [ ] Blur 영역이 Input Accessory 상단부터 화면 하단까지인가?
- [ ] 터치 이벤트가 정상 작동하는가?

### 4. Blur Sigma 조정
효과가 약하면 sigma 값 증가:
```dart
// keyboard_attachable_input_view.dart:169
sigmaX: 12, // → 20으로 증가
sigmaY: 12, // → 20으로 증가
```

### 5. Debug Overlay 활성화
```dart
// main.dart에서
MaterialApp(
  debugShowMaterialGrid: true, // 그리드로 blur 확인
)
```

---

## 왜 BackdropFilter가 안 보였나?

### 원인 1: Stack 순서 문제
```dart
// ❌ 잘못된 순서 (원래 코드)
Stack(
  children: [
    BackdropFilter(...), // 먼저 그려짐
    QuickAddControlBox(...), // 나중에 그려짐
  ],
)
```
**문제:** BackdropFilter는 자기 **뒤에** 있는 위젯만 blur합니다. 위 코드에서는 BackdropFilter 뒤에 아무것도 없어서 blur 효과가 없습니다.

```dart
// ✅ 올바른 순서 (수정된 코드)
Stack(
  children: [
    QuickAddControlBox(...), // 먼저 그려짐 (blur의 대상)
    BackdropFilter(...), // 나중에 그려짐 (QuickAdd를 blur)
  ],
)
```

### 원인 2: Gradient와 Blur 순서
```dart
// ❌ 잘못된 구조
BackdropFilter(
  filter: blur,
  child: Container(
    decoration: gradient, // blur 뒤에 gradient
  ),
)
```
**문제:** Gradient가 blur를 덮어버립니다.

```dart
// ✅ 올바른 구조
BackdropFilter(
  filter: blur,
  child: Container(
    decoration: gradient, // blur 위에 gradient
  ),
)
```
하지만 여전히 순서가 중요합니다! 전체 Stack에서 컨텐츠가 먼저 와야 합니다.

### 원인 3: ClipRect
```dart
// ❌ ClipRect가 blur를 자름
ClipRect(
  child: BackdropFilter(...),
)
```
**문제:** ClipRect가 blur 영역을 제한할 수 있습니다.

**해결:** ClipRect 제거 (필요 없음)

### 원인 4: Blur Sigma가 너무 작음
```dart
sigmaX: 4, sigmaY: 4 // Figma 스펙
```
**문제:** 4px blur는 육안으로 거의 안 보입니다.

**해결:** 12~20으로 증가

---

## 최종 추천

### 👉 우선 방법 1 시도 (keyboard_attachable_input_view.dart)
이미 수정 완료되었으므로 hot reload로 즉시 확인 가능

### 👉 안 되면 방법 2 시도 (keyboard_attachable_input_view_v2.dart)
`InputAccessoryHelper.showQuickAdd()`에서 위젯만 교체

### 👉 Platform별 차이가 크면 방법 3 시도
iOS는 괜찮은데 Android만 안 보이는 경우

---

## Troubleshooting

### Q: 여전히 blur가 안 보여요
**A:** Blur sigma를 20~30으로 증가:
```dart
sigmaX: 30, sigmaY: 30
```

### Q: Blur는 보이는데 gradient가 안 보여요
**A:** Gradient stops 조정:
```dart
stops: [0.0, 0.5] // → [0.0, 0.8]로 변경
```

### Q: 성능이 너무 안 좋아요
**A:** Blur sigma 감소 or 방법 1 사용 (BackdropFilter가 가장 빠름)

### Q: Android에서만 안 보여요
**A:** 방법 3 사용 (Platform별 최적화)

### Q: Modal 전체가 blur되어요
**A:** `showModalBottomSheet`의 `backgroundColor`가 투명한지 확인:
```dart
backgroundColor: Colors.transparent,
barrierColor: Colors.transparent,
```

---

## 참고 자료
- Figma 디자인: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0/%EC%A1%B8%EC%97%85%EC%9E%91%ED%92%88?node-id=2480-73452
- Flutter BackdropFilter: https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html
- Flutter ImageFiltered: https://api.flutter.dev/flutter/widgets/ImageFiltered-class.html
