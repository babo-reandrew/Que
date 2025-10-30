# Blur 디버깅 가이드

## 현재 상태
`create_entry_bottom_sheet.dart` 608-626번째 줄에 blur 구현 완료

## 여전히 안 보인다면 시도할 것들

### 1단계: Blur Sigma 극대화 (즉시 테스트)
```dart
// create_entry_bottom_sheet.dart:610-611
sigmaX: 50.0,  // 20 → 50
sigmaY: 50.0,
```

### 2단계: Gradient 색상 진하게
```dart
// create_entry_bottom_sheet.dart:619-620
Color(0x00FFFFFF), // 상단: 투명 (그대로)
Color(0xFFE0E0E0), // 하단: 완전 불투명한 회색 (F2 → FF)
```

### 3단계: 테스트용 단색 배경
Gradient 대신 단색으로 테스트:
```dart
// create_entry_bottom_sheet.dart:614-624 전체를 이것으로 교체:
child: Container(
  color: Colors.red.withOpacity(0.5), // 빨간색 반투명 (테스트용)
),
```
→ 이렇게 했을 때 빨간색이 보이면 **gradient 문제**
→ 여전히 안 보이면 **위젯 구조 문제**

### 4단계: QuickAddKeyboardTracker 확인
QuickAddKeyboardTracker가 blur를 가리고 있을 가능성:
```dart
// create_entry_bottom_sheet.dart:601 확인
// QuickAddKeyboardTracker 내부에서 높이/위치가 제대로 계산되는지 확인 필요
```

### 5단계: ClipRRect 제거 테스트
```dart
// create_entry_bottom_sheet.dart:604-607 주석 처리
// child: ClipRRect(
//   borderRadius: const BorderRadius.vertical(
//     top: Radius.circular(24),
//   ),
  child: BackdropFilter(
    ...
```

### 6단계: IgnorePointer 제거 테스트
```dart
// create_entry_bottom_sheet.dart:603 제거
// child: IgnorePointer(
  child: ClipRRect(
    ...
```

### 7단계: 완전히 새로운 접근 - Overlay 사용
QuickAddKeyboardTracker를 사용하지 않고 직접 Positioned 사용:
```dart
// create_entry_bottom_sheet.dart:597-629를 이것으로 교체:
Positioned(
  left: 0,
  right: 0,
  bottom: 0,
  top: MediaQuery.of(context).size.height * 0.3, // 화면 하단 70%
  child: IgnorePointer(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x00FFFFFF),
              Color(0xF2F0F0F0),
            ],
            stops: [0.0, 0.5],
          ),
        ),
      ),
    ),
  ),
),
```

## 디버깅 출력 추가

blur가 렌더링되는지 확인:
```dart
// create_entry_bottom_sheet.dart:608 다음에 추가
child: BackdropFilter(
  filter: ImageFilter.blur(
    sigmaX: 20.0,
    sigmaY: 20.0,
  ),
  child: LayoutBuilder(
    builder: (context, constraints) {
      print('🎨 [BLUR] 렌더링됨! 크기: ${constraints.maxWidth} x ${constraints.maxHeight}');
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(...),
        ),
      );
    },
  ),
),
```

## 플랫폼별 확인

### iOS Simulator
- iOS는 BackdropFilter를 잘 지원합니다
- Metal rendering이 활성화되어 있는지 확인

### Android Emulator
- Android에서 blur가 약할 수 있습니다
- Sigma를 30~50으로 증가 필요

## 최후의 수단: Material 대신 ImageFiltered

BackdropFilter 대신 전체를 ImageFiltered로 감싸기:
```dart
// create_entry_bottom_sheet.dart:584-629 전체를 이것으로 교체:
Positioned.fill(
  child: ImageFiltered(
    imageFilter: ImageFilter.blur(
      sigmaX: 30,
      sigmaY: 30,
      tileMode: TileMode.decal,
    ),
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00FFFFFF),
            Color(0xF2F0F0F0),
          ],
          stops: [0.0, 0.5],
        ),
      ),
    ),
  ),
),
```
