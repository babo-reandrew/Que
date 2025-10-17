# 🚨 타이포그래피 가이드 위반 사항 종합 분석

## 📊 전체 요약

**분석 범위**: `lib/**/*.dart` 전체 파일  
**분석 기준**: 새로운 `Typography` 클래스 (한국어/영어/일본어 30개 스타일)  
**발견된 위반 패턴**: 총 **7가지 카테고리**

---

## 🔴 위반 카테고리 1: 하드코딩된 TextStyle (가장 심각)

### 파일: `lib/component/full_schedule_bottom_sheet.dart`

#### 위반 1: 라인 177-184
```dart
// ❌ 현재 (하드코딩)
const Text(
  'スケジュール',
  style: TextStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: Color(0xFF505050),
    letterSpacing: -0.095,
    height: 1.4,
  ),
),

// ✅ 수정안
const Text(
  'スケジュール',
  style: Typography.headlineSmallBold.copyWith(
    color: Color(0xFF505050),
  ),
),
```
**이유**: 19pt, w700 → `headlineSmallBold` (20pt, w500) 가장 근접

---

#### 위반 2: 라인 299-306 (버튼 텍스트)
```dart
// ❌ 현재
style: TextStyle(
  fontFamily: 'LINE Seed JP App_TTF',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.075,
  height: 1.4,
),

// ✅ 수정안
style: Typography.bodyLargeBold
```
**이유**: 15pt, w700 → `bodyLargeBold` (16pt, bold) 표준 버튼용

---

#### 위반 3: 라인 361-368 (옵션 텍스트)
```dart
// ❌ 현재
style: TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.065,
  height: 1.4,
),

// ✅ 수정안
style: Typography.bodyMediumBold
```
**이유**: 13pt, w700 → `bodyMediumBold` (14pt, bold) 보조 버튼용

---

#### 위반 4: 라인 492-499 (라벨 텍스트)
```dart
// ❌ 현재
style: const TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.08,
  height: 1.4,
),

// ✅ 수정안
style: Typography.bodyLargeBold
```

---

#### 위반 5-7: 라인 509-560 (숫자 표시 - 대형)
```dart
// ❌ 현재
fontSize: 50, fontWeight: w800  // 라인 509
fontSize: 19, fontWeight: w800  // 라인 535
fontSize: 33, fontWeight: w800  // 라인 554

// ✅ 수정안
Typography.displayLargeExtraBold  // 35pt → 50pt는 없음, 가장 큰 스타일
Typography.headlineSmallBold      // 20pt
Typography.displayLargeExtraBold  // 35pt
```
**참고**: 50pt는 가이드에 없음 → 예외 처리 필요 또는 가장 큰 스타일 사용

---

#### 위반 8: 라인 773-780 (CTA 버튼)
```dart
// ❌ 현재
style: TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.075,
  height: 1.4,
),

// ✅ 수정안
style: Typography.bodyLargeBold
```

---

### 파일: `lib/widgets/temp_input_box.dart`

#### 위반 9: 라인 111-118
```dart
// ❌ 현재
style: const TextStyle(
  fontFamily: 'LINE Seed JP App_TTF',
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: Color(0xFF333333),
  letterSpacing: -0.3,  // ← 과도한 자간!
  height: 1.4,
),

// ✅ 수정안
style: Typography.bodyLargeMedium.copyWith(
  color: Color(0xFF333333),
)
```
**이유**: 15pt, w600 → `bodyLargeMedium` (16pt, w500)  
**참고**: letterSpacing -0.3은 과도함 (가이드: -0.5% = -0.075)

---

### 파일: `lib/widgets/task_card.dart`

#### 위반 10: 라인 198-204 (마감 시간 텍스트)
```dart
// ❌ 현재
style: TextStyle(
  fontFamily: 'LINE Seed JP App_TTF',
  fontWeight: FontWeight.w700,
  fontSize: 14,
  height: 1.4,
  letterSpacing: -0.005 * 14,
  color: const Color(0xFF444444),
),

// ✅ 수정안
style: Typography.bodyMediumBold.copyWith(
  color: Color(0xFF444444),
)
```
**이유**: 14pt, w700 → `bodyMediumBold` (14pt, bold)

---

#### 위반 11-12: 라인 255-262, 276-283 (리마인드/반복 태그)
```dart
// ❌ 현재 (2곳 동일)
style: TextStyle(
  fontFamily: 'LINE Seed JP App_TTF',
  fontWeight: FontWeight.w400,
  fontSize: 11,
  height: 1.4,
  letterSpacing: -0.005 * 11,
  color: const Color(0xFF505050),
),

// ✅ 수정안
style: Typography.labelLargeMedium.copyWith(
  color: Color(0xFF505050),
)
```
**이유**: 11pt, w400 → `labelLargeMedium` (12pt, w500)  
**참고**: 가이드에서 labelSmall (9pt)은 피해야 함

---

### 파일: `lib/widgets/bottom_navigation_bar.dart`

#### 위반 13: 라인 102-109
```dart
// ❌ 현재
style: TextStyle(
  fontFamily: 'LINE Seed JP App_TTF',
  fontWeight: FontWeight.w800,
  fontSize: 11,
  color: Color(0xFF222222),
  letterSpacing: -0.055,
  height: 15.4 / 11,
),

// ✅ 수정안
style: Typography.labelLargeBold.copyWith(
  color: Color(0xFF222222),
)
```
**이유**: 11pt, w800 → `labelLargeBold` (12pt, bold)

---

### 파일: `lib/extensions/home_screen_extension.dart`

#### 위반 14: 라인 72-76 (뱃지 숫자 - 예외 허용)
```dart
// ❌ 현재
style: TextStyle(
  color: Colors.white,
  fontSize: 6,  // ← 가이드에 없는 극소 크기
  fontWeight: FontWeight.bold,
),

// ⚠️ 예외
// 이유: 6pt는 가이드 최소(9pt)보다 작음
// 제안: labelSmall (9pt) 사용 또는 예외 처리
```
**참고**: 뱃지는 극소 크기가 필요하므로 예외 허용 가능

---

## 🟡 위반 카테고리 2: WoltTypography 의존성 (레거시)

### 현재 사용 중인 파일들

1. **`lib/component/full_schedule_bottom_sheet.dart`** (라인 8)
   ```dart
   import '../design_system/wolt_typography.dart';
   ```
   - 라인 326: `WoltTypography.schedulePlaceholder`
   - 라인 330: `WoltTypography.scheduleTitle`

2. **`lib/widgets/habit_card.dart`**
   - 라인 57: `WoltTypography.cardTitleCompleted`
   - 라인 58: `WoltTypography.cardTitle`
   - 라인 181: `WoltTypography.cardMeta`

3. **`lib/widgets/option_setting_bottom_sheet.dart`**
   - 라인 66: `WoltTypography.settingsTitle`

**마이그레이션 계획**:
```dart
// WoltTypography → Typography 매핑
WoltTypography.schedulePlaceholder → Typography.headlineMediumBold
WoltTypography.scheduleTitle       → Typography.headlineMediumBold
WoltTypography.cardTitle           → Typography.bodyLargeBold
WoltTypography.cardTitleCompleted  → Typography.bodyLargeBold + lineThrough
WoltTypography.cardMeta            → Typography.labelLargeRegular
WoltTypography.settingsTitle       → Typography.headlineLargeExtraBold
```

---

## 🟢 위반 카테고리 3: 폰트 크기 불일치 (가이드 범위 밖)

### 가이드에 없는 크기들

| 파일 | 라인 | 현재 크기 | 가장 가까운 Typography | 차이 |
|------|------|-----------|------------------------|------|
| `full_schedule_bottom_sheet.dart` | 511 | 50pt | `displayLargeExtraBold` (35pt) | +15pt |
| `extensions/home_screen_extension.dart` | 74 | 6pt | `labelSmall` (9pt) | -3pt |
| `const/typography.dart` | 50 | 24pt | `headlineMediumExtraBold` (23pt) | +1pt |

**제안**:
- **50pt**: 타이포그래피 가이드 확장 필요 (displayExtraLarge 추가)
- **6pt**: 뱃지 전용 예외 허용
- **24pt**: headlineMediumExtraBold로 대체 가능

---

## 🔵 위반 카테고리 4: letterSpacing 값 오류

### 과도한 자간

| 파일 | 라인 | 현재 값 | 가이드 값 | 비고 |
|------|------|---------|-----------|------|
| `temp_input_box.dart` | 116 | -0.3 | -0.075 (15pt × -0.5%) | **4배 과도** |
| `full_schedule_bottom_sheet.dart` | 182 | -0.095 | -0.1 (20pt × -0.5%) | 근접 |
| `task_card.dart` | 203 | -0.07 | -0.07 (14pt × -0.5%) | ✅ 정확 |

**수정 필요**: `temp_input_box.dart` → `-0.3` → `-0.075`

---

## 🟣 위반 카테고리 5: Line Height 불일치

### 가이드와 다른 행간

| 역할 | 가이드 (한국어) | 가이드 (일본어) | 발견된 값 | 파일 |
|------|----------------|----------------|----------|------|
| headline | 1.2x | 1.37x | 1.4 | `full_schedule_bottom_sheet.dart` |
| body | 1.5x | 1.67~1.77x | 1.4 | 여러 파일 |
| label | 1.5x | 1.82x | 15.4/11=1.4 | `bottom_navigation_bar.dart` |

**패턴**: 대부분 `1.4` (140%) 고정 → 가이드는 역할별 차등  
**수정**: Typography 클래스 사용 시 자동 해결

---

## 🟠 위반 카테고리 6: 폰트 무게(FontWeight) 불일치

### 가이드에 없는 무게

| 현재 무게 | 사용 위치 | 가이드 무게 | 수정안 |
|-----------|-----------|-------------|--------|
| w600 | `temp_input_box.dart` (라인 114) | w500 (Medium) | Medium |
| w900 | `const/typography.dart` (라인 42, 51) | bold (w700) | Bold |

**참고**: 가이드는 Light (w300), Medium (w500), Bold (w700/bold)만 지원

---

## 🟤 위반 카테고리 7: 색상 하드코딩 (부수적 문제)

### 반복되는 색상 값

| 색상 코드 | 사용 빈도 | 의미 | 제안 토큰 |
|-----------|-----------|------|-----------|
| `Color(0xFF505050)` | 5회 | 회색 텍스트 | `WoltDesignTokens.gray800` |
| `Color(0xFF444444)` | 2회 | 진한 회색 | `WoltDesignTokens.gray900` |
| `Color(0xFF333333)` | 1회 | 거의 검정 | `WoltDesignTokens.primaryBlack` |
| `Color(0xFF222222)` | 1회 | 검정 | `WoltDesignTokens.primaryBlack` |

**제안**: 색상도 디자인 토큰으로 관리

---

## 📈 통계 요약

### 파일별 위반 건수

| 파일 | 하드코딩 TextStyle | WoltTypography | 총합 |
|------|-------------------|----------------|------|
| `full_schedule_bottom_sheet.dart` | 8건 | 2건 | 10건 |
| `task_card.dart` | 3건 | - | 3건 |
| `temp_input_box.dart` | 1건 | - | 1건 |
| `bottom_navigation_bar.dart` | 1건 | - | 1건 |
| `habit_card.dart` | - | 3건 | 3건 |
| `extensions/home_screen_extension.dart` | 1건 (예외) | - | 1건 |
| `option_setting_bottom_sheet.dart` | - | 1건 | 1건 |
| **총합** | **14건** | **6건** | **20건** |

### 우선순위 점수

| 순위 | 파일 | 점수 | 우선순위 |
|------|------|------|----------|
| 1 | `full_schedule_bottom_sheet.dart` | 10 | 🔴 매우 높음 |
| 2 | `task_card.dart` | 3 | 🟠 높음 |
| 2 | `habit_card.dart` | 3 | 🟠 높음 |
| 3 | `temp_input_box.dart` | 1 | 🟡 중간 |
| 3 | `bottom_navigation_bar.dart` | 1 | 🟡 중간 |
| 3 | `option_setting_bottom_sheet.dart` | 1 | 🟡 중간 |

---

## ✅ 수정 로드맵

### Phase 1: 핵심 파일 (1-2일)
1. ✅ `full_schedule_bottom_sheet.dart` - 8개 하드코딩 → Typography
2. ✅ `task_card.dart` - 3개 하드코딩 → Typography

### Phase 2: WoltTypography 마이그레이션 (1일)
3. ✅ `habit_card.dart` - WoltTypography → Typography
4. ✅ `option_setting_bottom_sheet.dart` - WoltTypography → Typography

### Phase 3: 나머지 파일 (0.5일)
5. ✅ `temp_input_box.dart` - letterSpacing 수정
6. ✅ `bottom_navigation_bar.dart` - Typography 적용

### Phase 4: 예외 처리 (0.5일)
7. ⚠️ `extensions/home_screen_extension.dart` - 6pt 뱃지 (예외 허용 or Typography.labelSmall 사용)
8. ⚠️ 50pt 대형 숫자 - 가이드 확장 or 예외 허용

---

## 🎯 주요 발견사항

### 1. **letterSpacing 계산 오류**
- ❌ `temp_input_box.dart`: `-0.3` (4배 과도)
- ❌ 여러 파일: `-0.095`, `-0.065` (근사값)
- ✅ 정확한 값: `fontSize * -0.005` (Typography 클래스에서 자동 계산)

### 2. **FontWeight 일관성 부족**
- ❌ w600, w900 사용 (가이드 없음)
- ✅ 가이드: w300 (Light), w500 (Medium), bold (Heavy)

### 3. **Line Height 고정 문제**
- ❌ 대부분 `1.4` (140%) 고정
- ✅ 가이드: 역할별 차등 (1.2x ~ 1.9x)

### 4. **가이드 범위 밖 크기**
- 50pt (너무 큼)
- 6pt (너무 작음)
- → 가이드 확장 또는 예외 처리 필요

---

## 📝 권장사항

### 즉시 조치
1. **`full_schedule_bottom_sheet.dart` 우선 수정** (영향도 최대)
2. **letterSpacing 수식 통일** (`fontSize * -0.005`)
3. **WoltTypography import 제거 시작**

### 중기 조치
1. **Typography 클래스 폰트 파일 등록** (Gilroy, Gmarket Sans)
2. **언어별 동적 폰트 변경 구현**
3. **디자인 토큰 색상 확장** (현재 하드코딩된 색상 포함)

### 장기 조치
1. **타이포그래피 가이드 확장** (50pt displayExtraLarge 추가)
2. **린트 규칙 추가** (하드코딩 TextStyle 금지)
3. **자동화 테스트** (Typography 사용 여부 검증)

---

## 🔗 관련 문서

- [Typography 클래스](../lib/design_system/typography.dart)
- [WoltTypography (레거시)](../lib/design_system/wolt_typography.dart)
- [타이포그래피 비교 분석](./TYPOGRAPHY_COMPARISON.md)
- [다국어 폰트 가이드](./MULTILINGUAL_FONT_GUIDE.md)
