# 🚨 Typography System - 필수 준수 규칙

**이 규칙들은 절대 어겨서는 안 됩니다!**

---

## 🔒 Rule #1: Import 규칙

### ✅ 올바른 방법
```dart
import '../design_system/typography.dart' as AppTypography;
```

### ❌ 절대 금지
```dart
import '../design_system/typography.dart';  // prefix 없음
```

**이유**: Flutter Material의 `Typography` 클래스와 이름 충돌

---

## 🔒 Rule #2: 사용 규칙

### ✅ 올바른 방법
```dart
AppTypography.Typography.bodyLargeBold
```

### ❌ 절대 금지
```dart
Typography.bodyLargeBold  // prefix 누락
```

---

## 🔒 Rule #3: TextStyle 직접 생성 금지

### ❌ 절대 금지
```dart
TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
  fontFamily: 'LINE Seed JP App_TTF',
  letterSpacing: -0.075,
  height: 1.67,
)
```

### ✅ 올바른 방법
```dart
AppTypography.Typography.bodyLargeBold
```

**예외**: 디자인 시스템에 없는 **특수한 경우만** 허용 (팀 승인 필요)

---

## 🔒 Rule #4: const + copyWith 금지

### ❌ 컴파일 에러 발생
```dart
const Text(
  '텍스트',
  style: AppTypography.Typography.bodyLargeBold.copyWith(
    color: const Color(0xFF111111),
  ),
)
```

### ✅ 올바른 방법
```dart
Text(  // const 제거!
  '텍스트',
  style: AppTypography.Typography.bodyLargeBold.copyWith(
    color: const Color(0xFF111111),
  ),
)
```

---

## 🔒 Rule #5: copyWith 사용 제한

### ✅ 허용되는 속성
```dart
.copyWith(
  color: const Color(0xFF111111),        // ✅
  shadows: const [...],                   // ✅
  decoration: TextDecoration.underline,   // ✅
)
```

### ❌ 절대 금지
```dart
.copyWith(
  fontSize: 20,           // ❌ 크기 변경 금지
  fontWeight: FontWeight.w800,  // ❌ 무게 변경 금지
  fontFamily: 'Roboto',   // ❌ 폰트 변경 금지
  letterSpacing: -0.1,    // ❌ 자간 변경 금지
  height: 1.5,            // ❌ 행간 변경 금지
)
```

**이유**: Typography 시스템의 일관성 유지

---

## 🔒 Rule #6: 새 스타일 추가 금지

### ❌ 절대 금지
```dart
// typography.dart에 새 스타일 추가
static const TextStyle myCustomStyle = TextStyle(...);
```

**현재 30개 스타일로 충분합니다.**

필요하다면:
1. 기존 30개 중 가장 가까운 것 사용
2. 정말 필요하면 팀 회의 후 추가

---

## 🔒 Rule #7: 언어 규칙

### UI 텍스트 (사용자 대면)
```dart
Text('エラー')          // ✅ 일본어
Text('削除')            // ✅ 일본어
hintText: 'タスク名',   // ✅ 일본어
```

### 코드 주석/로그 (개발자용)
```dart
/// 이거를 설정하고 → Figma 디자인 기반  // ✅ 한국어
print('🔄 [종일 토글] 상태: ...');        // ✅ 한국어
// 이거는 이래서 → 시간 데이터 유지        // ✅ 한국어
```

### 변수명/함수명
```dart
String userName = '';     // ✅ 영어
void saveData() {}        // ✅ 영어
```

---

## 🔒 Rule #8: 파일별 Import 위치

### ✅ 올바른 순서
```dart
// 1. Dart 기본 라이브러리
import 'dart:async';

// 2. Flutter 패키지
import 'package:flutter/material.dart';

// 3. 외부 패키지
import 'package:provider/provider.dart';

// 4. 프로젝트 내부 파일
import '../design_system/typography.dart' as AppTypography;  // ⚠️ 여기!
import '../model/schedule.dart';
```

---

## 🔒 Rule #9: 코드 리뷰 체크리스트

Pull Request 전 반드시 확인:

- [ ] `TextStyle(...)` 직접 생성한 곳 없음?
- [ ] `fontSize:`, `fontWeight:` 하드코딩 없음?
- [ ] `AppTypography` prefix 모두 포함?
- [ ] `const Text(...copyWith(...))` 패턴 없음?
- [ ] UI 텍스트 모두 일본어?
- [ ] 주석/로그 한국어 유지?

---

## 🔒 Rule #10: MCP 검증 (월 1회)

### 실행 명령
```bash
# Dart Analysis Server에서
mcp_dart_sdk_mcp__analyze_files
```

### 검증 항목
1. Typography violations: 0개
2. Compilation errors: 0개
3. `fontSize:` 패턴 검색 → Typography만 허용

---

## 💡 빠른 의사결정 플로우차트

```
새 텍스트 스타일 필요?
  ↓
30개 중에 있나요?
  ├─ YES → 그거 사용 ✅
  └─ NO → 가장 가까운 것 사용 ✅
              ↓
         색상만 다르면?
              ├─ YES → copyWith(color: ...) ✅
              └─ NO → 팀에 문의 ⚠️
```

---

## 🆘 긴급 상황

### "Typography 에러나는데 급해요!"

1. **Import 확인**
   ```dart
   import '../design_system/typography.dart' as AppTypography;
   ```

2. **Prefix 확인**
   ```dart
   AppTypography.Typography.bodyLargeBold  // ✅
   ```

3. **const 제거**
   ```dart
   Text('...', style: AppTypography.Typography.bodyLargeBold.copyWith(...))
   // Text에서 const 빼기!
   ```

4. **여전히 에러?**
   - `TYPOGRAPHY_QUICK_REFERENCE.md` 참고
   - 팀 채널에 질문

---

## 📞 Contact

**문제 발생 시 연락처**:
- Typography 담당: [팀장 이름]
- 긴급 상황: [채팅 채널]

**참고 문서**:
- 📖 `TYPOGRAPHY_MIGRATION_COMPLETE.md` - 전체 가이드
- ⚡ `TYPOGRAPHY_QUICK_REFERENCE.md` - 빠른 참조

---

## ✅ 마지막 체크

이 문서를 읽었다면:

- [ ] Rule #1-10 모두 이해함
- [ ] Import 방법 숙지 (`as AppTypography`)
- [ ] const + copyWith 금지 이해
- [ ] 30개 스타일 위치 알고 있음 (`TYPOGRAPHY_QUICK_REFERENCE.md`)
- [ ] 언어 규칙 이해 (UI=일본어, 주석=한국어)

**모두 체크했다면 개발 시작! 🚀**

---

**버전**: 1.0  
**최종 업데이트**: 2025-10-16  
**필수 읽기**: 모든 개발자
