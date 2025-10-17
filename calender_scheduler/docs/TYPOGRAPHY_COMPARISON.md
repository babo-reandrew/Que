# 📊 타이포그래피 시스템 비교 분석

**작성일**: 2025-10-16  
**목적**: 기존 Wolt 스타일과 새로운 Apple HIG 기반 타이포그래피 차이점 파악

---

## 1. 설계 철학 비교

### 🔷 기존 (WoltTypography)
```
- 모달/바텀시트 중심 디자인
- Wolt 앱 스타일 모방
- 용도별 네이밍 (mainTitle, modalTitle, subTitle, label, optionText 등)
- 총 7개 스타일 (용도 중심)
- Letter Spacing: -0.5% (-0.005em)
- Line Height: 140% 고정
```

### 🍎 새로운 (AppleTypography)
```
- iOS Human Interface Guidelines 기반
- 애플 네이티브 앱 스타일
- 계층별 네이밍 (Display, Headline, Title, Body, Label)
- 총 30개 스타일 (크기 × 무게 조합)
- Letter Spacing: -0.5% (동일)
- Line Height: 130% (헤더), 150% (본문/라벨) - 가독성 최적화
```

---

## 2. 폰트 크기 매핑표

| 기존 (Wolt) | 크기 | 무게 | Line Height | → | 새로운 (Apple) | 크기 | 무게 | Line Height |
|-------------|------|------|-------------|---|----------------|------|------|-------------|
| modalTitle | 22px | w800 | 140% | ≈ | headlineMediumExtraBold | 22pt | w800 | 130% |
| mainTitle | 19px | w800 | 140% | ≈ | headlineSmallExtraBold | 19pt | w800 | 130% |
| schedulePlaceholder | 24px | w700 | 140% | → | (없음) | - | - | - |
| placeholder | 19px | w700 | 140% | ≈ | headlineSmallBold | 19pt | w700 | 130% |
| subTitle | 16px | w700 | 140% | ≈ | titleLargeBold | 16pt | w700 | 130% |
| label | 16px | w700 | 140% | ≈ | titleLargeBold | 16pt | w700 | 130% |
| optionText | 13px | w700 | 140% | ≈ | bodyMediumBold | 13pt | w700 | 150% |
| description | 13px | w400 | 140% | ≈ | bodyMediumRegular | 13pt | w400 | 150% |

---

## 3. 새로운 타입 스타일 계층 구조

### 📱 Display (가장 큰 제목)
```dart
displayLargeExtraBold  33pt  w800  130%  // 앱의 가장 중요한 대형 제목
displayLargeBold       33pt  w700  130%  
displayLargeRegular    33pt  w400  130%  
```

### 📰 Headline (주요 제목)
```dart
// Large (27pt)
headlineLargeExtraBold  27pt  w800  130%  // 섹션의 주요 제목
headlineLargeBold       27pt  w700  130%  
headlineLargeRegular    27pt  w400  130%  

// Medium (22pt) ← modalTitle와 동일
headlineMediumExtraBold 22pt  w800  130%  // 중간 크기 섹션 제목
headlineMediumBold      22pt  w700  130%  
headlineMediumRegular   22pt  w400  130%  

// Small (19pt) ← mainTitle와 동일
headlineSmallExtraBold  19pt  w800  130%  // 작은 섹션 제목
headlineSmallBold       19pt  w700  130%  
headlineSmallRegular    19pt  w400  130%  
```

### 🏷️ Title (부제목)
```dart
// Large (16pt) ← subTitle, label과 동일
titleLargeExtraBold     16pt  w800  130%  // 카드/리스트 아이템 제목
titleLargeBold          16pt  w700  130%  
titleLargeRegular       16pt  w400  130%  
```

### 📄 Body (본문)
```dart
// Large (15pt)
bodyLargeBold           15pt  w700  150%  // 강조된 본문 텍스트
bodyLargeMedium         15pt  w400  150%  
bodyLargeRegular        15pt  w400  150%  

// Medium (13pt) ← optionText, description과 동일
bodyMediumBold          13pt  w700  150%  // 중간 크기 본문 (강조)
bodyMediumMedium        13pt  w400  150%  
bodyMediumRegular       13pt  w400  150%  

// Small (12pt)
bodySmallBold           12pt  w700  150%  // 작은 본문 (강조)
bodySmallMedium         12pt  w400  150%  
bodySmallRegular        12pt  w400  150%  
```

### 🔖 Label (라벨/캡션)
```dart
// Large (11pt)
labelLargeBold          11pt  w700  150%  // 큰 라벨 (강조)
labelLargeMedium        11pt  w400  150%  
labelLargeRegular       11pt  w400  150%  

// Medium (9pt)
labelMediumBold         9pt   w700  200%  // 작은 라벨 (강조)
labelMediumMedium       9pt   w400  200%  
labelMediumRegular      9pt   w400  200%  
```

---

## 4. 주요 차이점

### 🔴 삭제된 것 (기존에 있었으나 새 시스템에 없음)
```dart
schedulePlaceholder  24px  w700  140%  // → displayLargeBold (33pt)로 대체 가능
placeholder          19px  w700  140%  // → headlineSmallBold (19pt)로 대체
```

### 🟢 추가된 것 (새 시스템에만 있음)
```dart
// Display 계층 (33pt) - 가장 큰 제목
displayLargeExtraBold  displayLargeBold  displayLargeRegular

// Headline Large (27pt) - 기존에 없던 크기
headlineLargeExtraBold  headlineLargeBold  headlineLargeRegular

// Body Small (12pt) - 기존에 없던 작은 본문
bodySmallBold  bodySmallMedium  bodySmallRegular

// Label (11pt, 9pt) - 기존에 없던 매우 작은 라벨
labelLargeBold  labelLargeMedium  labelLargeRegular
labelMediumBold  labelMediumMedium  labelMediumRegular
```

### 🔵 변경된 것
```dart
// Line Height 조정
기존: 모든 스타일 140% 고정
새로운: Headline/Title 130%, Body/Label 150-200% (가독성 강화)

// 네이밍 방식
기존: 용도 기반 (mainTitle, modalTitle, subTitle)
새로운: 계층 기반 (Display, Headline, Title, Body, Label)

// 무게 변형
기존: 주로 w800, w700, w400만 사용
새로운: ExtraBold(w800), Bold(w700), Regular(w400), Medium(w400) 체계적 조합
```

---

## 5. 마이그레이션 가이드

### 📌 기존 코드 → 새 스타일 매핑

```dart
// ✅ 1:1 매핑 (크기와 무게가 정확히 일치)
WoltTypography.modalTitle     → AppleTypography.headlineMediumExtraBold
WoltTypography.mainTitle      → AppleTypography.headlineSmallExtraBold
WoltTypography.placeholder    → AppleTypography.headlineSmallBold
WoltTypography.subTitle       → AppleTypography.titleLargeBold
WoltTypography.label          → AppleTypography.titleLargeBold
WoltTypography.optionText     → AppleTypography.bodyMediumBold
WoltTypography.description    → AppleTypography.bodyMediumRegular

// ⚠️ 크기 조정 필요 (더 큰 스타일로 대체)
WoltTypography.schedulePlaceholder (24px w700)
  → AppleTypography.displayLargeBold (33pt w700)  // 9pt 증가
  → AppleTypography.headlineLargeBold (27pt w700)  // 3pt 증가 (추천)
```

### 📝 사용 예시

```dart
// 기존 (Wolt)
Text(
  'スケジュール',
  style: WoltTypography.mainTitle,  // 19px w800 140%
)

// 새로운 (Apple)
Text(
  'スケジュール',
  style: AppleTypography.headlineSmallExtraBold,  // 19pt w800 130%
)
```

```dart
// 기존 (Wolt)
Text(
  '２日毎',
  style: WoltTypography.optionText,  // 13px w700 140%
)

// 새로운 (Apple)
Text(
  '２日毎',
  style: AppleTypography.bodyMediumBold,  // 13pt w700 150%
)
```

---

## 6. 장단점 비교

### 기존 (WoltTypography)
**장점**:
- ✅ 용도가 명확 (mainTitle, modalTitle 등 직관적)
- ✅ 스타일 수가 적어 선택이 간단 (7개)
- ✅ 기존 프로젝트에 이미 적용됨

**단점**:
- ❌ 확장성 부족 (새로운 크기 추가 시 일관성 깨짐)
- ❌ Dynamic Type 미지원
- ❌ 폰트 무게 변형 부족 (w800, w700, w400만)
- ❌ Line Height 고정 (140%)으로 가독성 최적화 어려움

### 새로운 (AppleTypography)
**장점**:
- ✅ iOS HIG 기반으로 네이티브 느낌
- ✅ 계층적 네이밍으로 확장성 우수
- ✅ 다양한 폰트 무게 조합 (ExtraBold, Bold, Regular)
- ✅ Line Height 최적화 (헤더 130%, 본문 150%)
- ✅ Dynamic Type 지원 준비됨

**단점**:
- ❌ 스타일 수가 많아 초기 선택이 어려울 수 있음 (30개)
- ❌ 기존 코드 전체 수정 필요
- ❌ 용도 파악이 덜 직관적 (headline vs title 차이 이해 필요)

---

## 7. 권장 사항

### 🎯 새로운 프로젝트라면
→ **AppleTypography 사용 권장**
- iOS 중심 앱에 최적화
- 장기적 확장성과 유지보수 우수

### 🔄 기존 프로젝트 마이그레이션
→ **단계적 전환 권장**
1. **Phase 1**: 새로운 화면부터 AppleTypography 적용
2. **Phase 2**: 핵심 화면(일정, 할일, 습관) 순차 전환
3. **Phase 3**: WoltTypography 완전 제거

### 🤝 혼용 전략 (단기)
```dart
// 기존 화면은 WoltTypography 유지
import 'package:calender_scheduler/design_system/wolt_typography.dart';

// 새로운 화면은 AppleTypography 사용
import 'package:calender_scheduler/design_system/apple_typography.dart';
```

---

## 8. 결론

**새로운 AppleTypography는**:
- ✅ iOS Human Interface Guidelines 기반
- ✅ 명확한 계층 구조 (Display → Headline → Title → Body → Label)
- ✅ 가독성 최적화 (Line Height 차별화)
- ✅ 확장 가능한 네이밍 시스템

**이를 중심으로 디자인 시스템을 구축하면**:
1. **일관성**: 모든 화면에서 통일된 타이포그래피
2. **확장성**: 새로운 크기/무게 추가가 쉬움
3. **유지보수**: 계층별로 한 번에 수정 가능
4. **iOS 네이티브 느낌**: 사용자 친화적

---

**다음 단계**:
1. 새로운 AppleTypography 검토 및 승인
2. 핵심 화면 1개 선택하여 시범 적용
3. 팀 피드백 수렴
4. 전체 마이그레이션 계획 수립

---

*작성자: GitHub Copilot*  
*버전: 1.0.0*  
*참고: [Apple Human Interface Guidelines - Typography](https://developer.apple.com/design/human-interface-guidelines/typography)*
