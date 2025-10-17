# ⚡ Typography Quick Reference

**빠른 참조용 치트시트**

---

## 🎯 30초 요약

```dart
// 1. Import (필수!)
import '../design_system/typography.dart' as AppTypography;

// 2. 사용
AppTypography.Typography.bodyLargeBold

// 3. 색상 변경
AppTypography.Typography.bodyLargeBold.copyWith(
  color: const Color(0xFF111111),
)
```

---

## 📏 스타일 선택 가이드

### 크기별 추천

| 원하는 크기 | 추천 스타일 | 실제 크기 (일본어) |
|------------|------------|-------------------|
| 9-10pt | labelSmall | 9pt |
| 11-12pt | labelLarge | 11pt |
| 13-14pt | bodyMedium | 13pt |
| 15-16pt | bodyLarge | 15pt |
| 17-18pt | titleLarge | 16pt |
| 19-20pt | headlineSmall | 19pt |
| 21-25pt | headlineMedium | 22pt |
| 26-30pt | headlineLarge | 27pt |
| 31-35pt | displayLarge | 33pt |

### 무게별 추천

| FontWeight | Typography 이름 |
|-----------|----------------|
| w300 | Regular |
| w400 | Regular |
| w500 | Medium |
| w600 | Medium |
| w700 | Bold |
| w800 | ExtraBold |
| w900 | ExtraBold |

---

## 🔍 일반적인 사용 사례

### 1. 헤더 타이틀
```dart
Text(
  'スケジュール',
  style: AppTypography.Typography.headlineSmallBold,
)
```

### 2. 본문 텍스트
```dart
Text(
  '詳細内容',
  style: AppTypography.Typography.bodyLargeMedium,
)
```

### 3. 버튼 텍스트
```dart
Text(
  '削除',
  style: AppTypography.Typography.bodyLargeBold.copyWith(
    color: const Color(0xFFF74A4A),
  ),
)
```

### 4. 작은 라벨
```dart
Text(
  'Inbox',
  style: AppTypography.Typography.labelLargeBold,
)
```

### 5. 큰 숫자 표시
```dart
Text(
  '10',
  style: AppTypography.Typography.displayLargeExtraBold.copyWith(
    color: const Color(0xFFEEEEEE),
  ),
)
```

---

## ❌ 하지 말아야 할 것

```dart
// ❌ 절대 금지: 직접 TextStyle 생성
const TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
)

// ❌ 금지: prefix 없이 사용
Typography.bodyLargeBold

// ❌ 금지: copyWith + const
const Text('텍스트', style: AppTypography.Typography.bodyLargeBold.copyWith(...))

// ❌ 금지: fontSize override
AppTypography.Typography.bodyLargeBold.copyWith(fontSize: 16)
```

---

## ✅ 올바른 패턴

```dart
// ✅ 기본 사용
Text(
  '텍스트',
  style: AppTypography.Typography.bodyLargeBold,
)

// ✅ 색상만 변경
Text(
  '텍스트',
  style: AppTypography.Typography.bodyLargeBold.copyWith(
    color: const Color(0xFF111111),
  ),
)

// ✅ 여러 속성 변경 (색상, shadows만!)
Text(
  '텍스트',
  style: AppTypography.Typography.headlineSmallBold.copyWith(
    color: const Color(0xFF505050),
    shadows: const [
      Shadow(
        color: Color(0x1A000000),
        blurRadius: 20,
        offset: Offset(0, 4),
      ),
    ],
  ),
)
```

---

## 🚨 자주 하는 실수

### 실수 1: Import 빠뜨림
```dart
// ❌ 에러 발생
Text('텍스트', style: AppTypography.Typography.bodyLargeBold)
// Error: Undefined name 'AppTypography'

// ✅ 해결
import '../design_system/typography.dart' as AppTypography;
```

### 실수 2: const와 copyWith 혼용
```dart
// ❌ 컴파일 에러
const Text(
  '텍스트',
  style: AppTypography.Typography.bodyLargeBold.copyWith(color: Colors.red),
)

// ✅ const 제거
Text(
  '텍스트',
  style: AppTypography.Typography.bodyLargeBold.copyWith(color: Colors.red),
)
```

### 실수 3: fontSize 직접 수정
```dart
// ❌ 시스템 우회
AppTypography.Typography.bodyLargeBold.copyWith(fontSize: 20)

// ✅ 다른 스타일 선택
AppTypography.Typography.headlineSmallBold
```

---

## 📊 전체 스타일 목록

### Display (3개)
- `displayLargeExtraBold` - 33pt w700
- `displayLargeBold` - 33pt w500
- `displayLargeRegular` - 33pt w300

### Headline (9개)
- `headlineLargeExtraBold` - 27pt w700
- `headlineLargeBold` - 27pt w500
- `headlineLargeRegular` - 27pt w300
- `headlineMediumExtraBold` - 22pt w700
- `headlineMediumBold` - 22pt w500
- `headlineMediumRegular` - 22pt w300
- `headlineSmallExtraBold` - 19pt w700
- `headlineSmallBold` - 19pt w500
- `headlineSmallRegular` - 19pt w300

### Title (3개)
- `titleLargeExtraBold` - 16pt w700
- `titleLargeBold` - 16pt w500
- `titleLargeRegular` - 16pt w300

### Body (9개)
- `bodyLargeBold` - 15pt w700
- `bodyLargeMedium` - 15pt w500
- `bodyLargeRegular` - 15pt w300
- `bodyMediumBold` - 13pt w700
- `bodyMediumMedium` - 13pt w500
- `bodyMediumRegular` - 13pt w300
- `bodySmallBold` - 12pt w700
- `bodySmallMedium` - 12pt w500
- `bodySmallRegular` - 12pt w300

### Label (6개)
- `labelLargeBold` - 11pt w700
- `labelLargeMedium` - 11pt w500
- `labelLargeRegular` - 11pt w300
- `labelMediumBold` - 9pt w700
- `labelMediumMedium` - 9pt w500
- `labelMediumRegular` - 9pt w300

---

## 🔧 VSCode Snippets (추천)

`settings.json`에 추가:

```json
{
  "dart.snippets": {
    "AppTypography Import": {
      "prefix": "imptypo",
      "body": [
        "import '../design_system/typography.dart' as AppTypography;"
      ]
    },
    "Typography Style": {
      "prefix": "typo",
      "body": [
        "AppTypography.Typography.${1:bodyLargeBold}"
      ]
    },
    "Typography with Color": {
      "prefix": "typoc",
      "body": [
        "AppTypography.Typography.${1:bodyLargeBold}.copyWith(",
        "  color: const Color(${2:0xFF111111}),",
        ")"
      ]
    }
  }
}
```

---

## 🎨 색상 조합 추천

### Primary Text
```dart
AppTypography.Typography.bodyLargeBold.copyWith(
  color: const Color(0xFF111111), // 거의 검정
)
```

### Secondary Text
```dart
AppTypography.Typography.bodyMediumMedium.copyWith(
  color: const Color(0xFF505050), // 회색
)
```

### Error Text
```dart
AppTypography.Typography.bodyLargeBold.copyWith(
  color: const Color(0xFFF74A4A), // 빨강
)
```

### Success Text
```dart
AppTypography.Typography.bodyLargeBold.copyWith(
  color: const Color(0xFF21DC6D), // 초록
)
```

### Disabled Text
```dart
AppTypography.Typography.bodyMediumMedium.copyWith(
  color: const Color(0xFFEEEEEE), // 밝은 회색
)
```

---

## 🔍 디버깅 체크리스트

문제가 생기면 이 순서로 확인:

1. ✅ Import 확인
   ```dart
   import '../design_system/typography.dart' as AppTypography;
   ```

2. ✅ Prefix 확인
   ```dart
   AppTypography.Typography.스타일명  // ✅
   Typography.스타일명  // ❌
   ```

3. ✅ const 확인
   ```dart
   // copyWith 사용 시
   Text('텍스트', style: AppTypography.Typography.bodyLargeBold.copyWith(...))  // ✅
   const Text('텍스트', style: AppTypography.Typography.bodyLargeBold.copyWith(...))  // ❌
   ```

4. ✅ override 확인
   ```dart
   // color, shadows만 가능
   .copyWith(color: Colors.red)  // ✅
   .copyWith(fontSize: 20)  // ❌
   ```

---

## 📱 실전 예시

### 1. 홈 화면 타이틀
```dart
Text(
  'ホーム',
  style: AppTypography.Typography.headlineLargeBold,
)
```

### 2. 카드 제목
```dart
Text(
  'タスク名',
  style: AppTypography.Typography.bodyLargeBold.copyWith(
    color: const Color(0xFF111111),
  ),
)
```

### 3. 카드 설명
```dart
Text(
  '詳細説明',
  style: AppTypography.Typography.bodyMediumMedium.copyWith(
    color: const Color(0xFF505050),
  ),
)
```

### 4. 버튼 텍스트
```dart
ElevatedButton(
  child: Text(
    '保存',
    style: AppTypography.Typography.bodyLargeBold,
  ),
)
```

### 5. 시간 표시 (큰 글씨)
```dart
Text(
  '15:30',
  style: AppTypography.Typography.headlineLargeExtraBold.copyWith(
    color: const Color(0xFF111111),
  ),
)
```

---

**팁**: 이 문서를 북마크해두고 새 UI 작업 시 참고하세요!
