# ✅ 색상 기본값 Gray 설정 완료

## 📋 개요

**기본 색상을 gray로 설정**하고, 사용자가 명시적으로 색상을 선택하지 않으면 항상 회색으로 표시되도록 구현 완료.

## 🎯 구현 내용

### 1. 색상 선택 UI에 Gray 추가 ⭐

**기존 문제:**
- 색상 선택 UI에 5개 색상만 표시됨 (red, orange, blue, yellow, green)
- Gray가 없어서 사용자가 기본 색상으로 돌아갈 방법이 없음

**해결:**
- Gray를 **첫 번째 색상**으로 추가 (기본 색상임을 강조)
- 5개 → 6개 색상으로 확장

**수정 파일:**
1. `lib/design_system/wolt_helpers.dart`
2. `lib/design_system/wolt_page_builders.dart`

```dart
// ✅ 6개 색상 (gray 기본 포함)
final colorOptions = [
  {'value': 'gray', 'color': const Color(0xFF989898), 'label': 'グレー'}, // ✅ 기본 색상
  {'value': 'red', 'color': const Color(0xFFD22D2D), 'label': '赤'},
  {'value': 'orange', 'color': const Color(0xFFF57C00), 'label': 'オレンジ'},
  {'value': 'blue', 'color': const Color(0xFF1976D2), 'label': '青'},
  {'value': 'yellow', 'color': const Color(0xFFF7BD11), 'label': '黄'},
  {'value': 'green', 'color': const Color(0xFF54C8A1), 'label': '緑'},
];
```

### 2. 색상 버튼 레이아웃 조정

**기존:**
- 5개 색상 버튼, 간격 16px

**변경:**
- 6개 색상 버튼, 간격 12px (화면에 맞게 조정)
- 좌우 균등 패딩 (32px)

```dart
// ✅ 6개 색상 버튼 (gray 포함)
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 32), // ✅ 좌우 균등
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (int i = 0; i < colorOptions.length; i++) ...[
        // 색상 버튼...
        if (i < colorOptions.length - 1)
          const SizedBox(width: 12), // ✅ 간격 줄임 (16px → 12px)
      ],
    ],
  ),
),
```

### 3. 기본 색상 로직 (이미 구현됨)

**Schedule/Task/Habit 저장 시:**

```dart
// ✅ Provider 우선, 비어있으면 기본값 'gray'
final finalColor = bottomSheetController.selectedColor.isNotEmpty
    ? bottomSheetController.selectedColor
    : (cachedColor ?? 'gray'); // ✅ 기본값 gray
```

**BottomSheetController 초기화:**

```dart
void reset() {
  _selectedColor = 'gray'; // ✅ 기본값 gray
  _repeatRule = '';
  _reminder = '';
  notifyListeners();
}
```

## 📊 데이터 흐름

```
[새 일정/할일/습관 생성]
       ↓
[BottomSheetController.reset()]
  _selectedColor = 'gray' // ✅ 기본값
       ↓
[사용자가 색상 선택 안 함]
       ↓
[저장 버튼 클릭]
  finalColor = 'gray' // ✅ 기본값 사용
       ↓
[데이터베이스 저장]
  colorId = 'gray'
       ↓
[UI 표시]
  회색으로 표시됨
```

## 🎨 UI 변경사항

### Before (기존)
- 색상 선택 UI: 5개 (red, orange, blue, yellow, green)
- Gray가 없어서 기본 색상으로 돌아갈 수 없음
- 사용자가 색상을 선택하지 않으면 어떤 색으로 저장되는지 불명확

### After (개선)
- 색상 선택 UI: 6개 (gray, red, orange, blue, yellow, green)
- **Gray가 첫 번째 위치** (기본 색상임을 명확히 표시)
- 사용자가 명시적으로 Gray를 선택할 수 있음
- 색상을 선택하지 않으면 자동으로 Gray로 저장됨

## 🔍 핵심 수정 파일

1. **`wolt_helpers.dart`** (line 134-141)
   - colorOptions에 gray 추가 (첫 번째 위치)
   - 색상 버튼 간격 조정 (16px → 12px)

2. **`wolt_page_builders.dart`** (line 40-48)
   - colorOptions에 gray 추가 (첫 번째 위치)
   - 색상 버튼 간격 조정 (16px → 12px)

## ✅ 테스트 체크리스트

### 색상 선택 UI

#### Gray 표시 확인
1. [ ] 일정/할일/습관 생성 모달 열기
2. [ ] 색상 선택 버튼 클릭
3. [ ] **검증:**
   - [ ] 6개 색상 버튼이 한 줄에 표시됨
   - [ ] Gray가 **첫 번째** 위치에 있음
   - [ ] Gray 색상이 올바르게 표시됨 (#989898)

#### Gray 선택 확인
1. [ ] Gray 색상 버튼 클릭
2. [ ] "完了" 버튼 클릭
3. [ ] **검증:**
   - [ ] 색상 버튼에 회색이 표시됨
   - [ ] 저장 시 colorId = 'gray'로 저장됨

### 기본 색상 Gray

#### 새 일정 생성 (색상 선택 안 함)
1. [ ] 새 일정 생성
2. [ ] 색상 선택하지 않음
3. [ ] 저장
4. [ ] **검증:**
   - [ ] 일정이 회색으로 표시됨
   - [ ] 데이터베이스 colorId = 'gray'

#### 새 할일 생성 (색상 선택 안 함)
1. [ ] 새 할일 생성
2. [ ] 색상 선택하지 않음
3. [ ] 저장
4. [ ] **검증:**
   - [ ] 할일이 회색으로 표시됨
   - [ ] 데이터베이스 colorId = 'gray'

#### 새 습관 생성 (색상 선택 안 함)
1. [ ] 새 습관 생성
2. [ ] 색상 선택하지 않음
3. [ ] 저장
4. [ ] **검증:**
   - [ ] 습관이 회색으로 표시됨
   - [ ] 데이터베이스 colorId = 'gray'

### 색상 변경

#### 다른 색상 → Gray
1. [ ] 파란색 일정 생성
2. [ ] 수정 → 색상을 Gray로 변경
3. [ ] 저장
4. [ ] **검증:**
   - [ ] 일정이 회색으로 변경됨
   - [ ] 데이터베이스 colorId = 'gray'

#### Gray → 다른 색상
1. [ ] Gray 일정 생성
2. [ ] 수정 → 색상을 Red로 변경
3. [ ] 저장
4. [ ] **검증:**
   - [ ] 일정이 빨간색으로 변경됨
   - [ ] 데이터베이스 colorId = 'red'

## 🎯 결론

✅ **사용자 경험 개선:**
- Gray가 색상 선택 UI에 명시적으로 표시됨
- 기본 색상임을 명확히 인식할 수 있음
- 언제든지 Gray로 돌아갈 수 있음

✅ **데이터 정합성:**
- 색상 선택하지 않으면 항상 gray로 저장됨
- categoryColorMap에 gray가 포함되어 있어 올바르게 표시됨

✅ **최소한의 코드 수정:**
- 색상 옵션 배열에 gray 추가 (2개 파일)
- 레이아웃 조정 (간격만 줄임)
- 기존 로직은 이미 gray를 기본값으로 처리하고 있음
