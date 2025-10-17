# 🌐 다국어 폰트 시스템 가이드

**작성일**: 2025-10-16  
**목적**: 한국어, 영어, 일본어 별도 폰트 패밀리 등록 및 사용

---

## 1. 폰트 패밀리 정의

### 현재 상황
```dart
// 현재: 일본어 폰트만 사용
static const String fontFamily = 'LINE Seed JP App_TTF';
```

### 개선안: 언어별 폰트 분리
```dart
/// 일본어 (기본)
static const String fontFamilyJapanese = 'LINE Seed JP App_TTF';

/// 한국어
static const String fontFamilyKorean = 'Pretendard';  // 또는 'Noto Sans KR'

/// 영어
static const String fontFamilyEnglish = 'SF Pro Display';  // 또는 'Inter'
```

---

## 2. 폰트 패밀리 후보

### 🇯🇵 일본어 (현재 사용 중)
```yaml
# pubspec.yaml
fonts:
  - family: LINE Seed JP App_TTF
    fonts:
      - asset: asset/font/LINESeedJP_A_TTF_Rg.ttf
        weight: 400
      - asset: asset/font/LINESeedJP_A_TTF_Bd.ttf
        weight: 700
      - asset: asset/font/LINESeedJP_A_TTF_Eb.ttf
        weight: 800
```

**특징**:
- LINE 공식 일본어 폰트
- 히라가나, 가타카나, 한자 지원
- iOS 네이티브 느낌

---

### 🇰🇷 한국어 (추천 폰트)

#### 옵션 1: Pretendard (추천 ⭐)
```yaml
# pubspec.yaml
fonts:
  - family: Pretendard
    fonts:
      - asset: asset/font/Pretendard-Regular.otf
        weight: 400
      - asset: asset/font/Pretendard-Bold.otf
        weight: 700
      - asset: asset/font/Pretendard-ExtraBold.otf
        weight: 800
```

**장점**:
- ✅ 한국어 가독성 최고
- ✅ Apple SD Gothic Neo 계열 (iOS 네이티브)
- ✅ Variable Font 지원
- ✅ 오픈소스 (무료)
- ✅ LINE Seed JP와 스타일 유사

**다운로드**: https://github.com/orioncactus/pretendard

---

#### 옵션 2: Noto Sans KR
```yaml
fonts:
  - family: Noto Sans KR
    fonts:
      - asset: asset/font/NotoSansKR-Regular.otf
        weight: 400
      - asset: asset/font/NotoSansKR-Bold.otf
        weight: 700
      - asset: asset/font/NotoSansKR-Black.otf
        weight: 900
```

**장점**:
- ✅ 구글 공식 폰트
- ✅ 다국어 지원 우수
- ✅ 안정성 높음

**단점**:
- ❌ LINE Seed JP보다 두꺼운 느낌
- ❌ iOS 네이티브 느낌 부족

**다운로드**: https://fonts.google.com/noto/specimen/Noto+Sans+KR

---

### 🇺🇸 영어 (추천 폰트)

#### 옵션 1: SF Pro Display (iOS 공식, 추천 ⭐)
```yaml
# ⚠️ 주의: Apple 라이선스 제약 있음
fonts:
  - family: SF Pro Display
    fonts:
      - asset: asset/font/SF-Pro-Display-Regular.otf
        weight: 400
      - asset: asset/font/SF-Pro-Display-Bold.otf
        weight: 700
      - asset: asset/font/SF-Pro-Display-Black.otf
        weight: 900
```

**장점**:
- ✅ iOS 네이티브 폰트
- ✅ LINE Seed JP와 완벽 조화
- ✅ Dynamic Type 지원

**단점**:
- ❌ 라이선스 제약 (Apple 앱에서만 사용 가능)
- ❌ Android 배포 시 문제 가능성

**다운로드**: https://developer.apple.com/fonts/

---

#### 옵션 2: Inter (오픈소스, 안전 ⭐)
```yaml
fonts:
  - family: Inter
    fonts:
      - asset: asset/font/Inter-Regular.ttf
        weight: 400
      - asset: asset/font/Inter-Bold.ttf
        weight: 700
      - asset: asset/font/Inter-ExtraBold.ttf
        weight: 800
```

**장점**:
- ✅ 오픈소스 (무료)
- ✅ 가독성 우수
- ✅ Variable Font 지원
- ✅ LINE Seed JP와 스타일 유사

**추천 이유**:
- iOS/Android 모두 안전
- Figma 스타일 가이드에서도 사용 중

**다운로드**: https://rsms.me/inter/

---

## 3. 폰트 등록 방법

### Step 1: 폰트 파일 다운로드 및 배치
```bash
# 디렉토리 구조
asset/font/
├── LINESeedJP_A_TTF_Rg.ttf      # 일본어 (기존)
├── LINESeedJP_A_TTF_Bd.ttf
├── LINESeedJP_A_TTF_Eb.ttf
├── Pretendard-Regular.otf       # 한국어 (추가)
├── Pretendard-Bold.otf
├── Pretendard-ExtraBold.otf
├── Inter-Regular.ttf            # 영어 (추가)
├── Inter-Bold.ttf
└── Inter-ExtraBold.ttf
```

---

### Step 2: pubspec.yaml 수정
```yaml
flutter:
  fonts:
    # 일본어 (기존)
    - family: LINE Seed JP App_TTF
      fonts:
        - asset: asset/font/LINESeedJP_A_TTF_Rg.ttf
          weight: 400
        - asset: asset/font/LINESeedJP_A_TTF_Bd.ttf
          weight: 700
        - asset: asset/font/LINESeedJP_A_TTF_Eb.ttf
          weight: 800
    
    # 한국어 (추가)
    - family: Pretendard
      fonts:
        - asset: asset/font/Pretendard-Regular.otf
          weight: 400
        - asset: asset/font/Pretendard-Bold.otf
          weight: 700
        - asset: asset/font/Pretendard-ExtraBold.otf
          weight: 800
    
    # 영어 (추가)
    - family: Inter
      fonts:
        - asset: asset/font/Inter-Regular.ttf
          weight: 400
        - asset: asset/font/Inter-Bold.ttf
          weight: 700
        - asset: asset/font/Inter-ExtraBold.ttf
          weight: 800
```

---

### Step 3: AppleTypography 수정
```dart
/// lib/design_system/apple_typography.dart

class AppleTypography {
  AppleTypography._();

  /// 언어별 폰트 패밀리
  static const String fontFamilyJapanese = 'LINE Seed JP App_TTF';
  static const String fontFamilyKorean = 'Pretendard';
  static const String fontFamilyEnglish = 'Inter';

  /// 현재 언어에 따라 폰트 선택
  static String getFontFamily(Locale locale) {
    switch (locale.languageCode) {
      case 'ko':
        return fontFamilyKorean;
      case 'en':
        return fontFamilyEnglish;
      case 'ja':
      default:
        return fontFamilyJapanese;
    }
  }

  /// Letter Spacing (동일)
  static double letterSpacing(double fontSize) => fontSize * -0.005;

  // ==================== Display ====================

  /// Display Large / ExtraBold
  static TextStyle displayLargeExtraBold({required Locale locale}) => TextStyle(
    fontFamily: getFontFamily(locale),
    fontWeight: FontWeight.w800,
    fontSize: 33,
    height: 1.3,
    letterSpacing: letterSpacing(33),
    color: Colors.black,
  );

  // ... (다른 스타일도 동일하게 locale 파라미터 추가)
}
```

---

### Step 4: 사용 예시
```dart
// main.dart에서 언어 설정
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('ja'),  // 일본어 기본
      supportedLocales: [
        Locale('ja'),
        Locale('ko'),
        Locale('en'),
      ],
      // ...
    );
  }
}

// 화면에서 사용
class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    
    return Text(
      'スケジュール',  // 일본어
      style: AppleTypography.displayLargeExtraBold(locale: locale),
    );
  }
}
```

---

## 4. 간단한 방법 (Locale 없이)

### 방법 1: 기본 폰트 3개 버전 제공
```dart
class AppleTypography {
  // 일본어 (기본)
  static TextStyle get displayLargeExtraBold => _buildStyle(
    fontFamily: 'LINE Seed JP App_TTF',
    fontSize: 33,
    fontWeight: FontWeight.w800,
  );

  // 한국어
  static TextStyle get displayLargeExtraBoldKo => _buildStyle(
    fontFamily: 'Pretendard',
    fontSize: 33,
    fontWeight: FontWeight.w800,
  );

  // 영어
  static TextStyle get displayLargeExtraBoldEn => _buildStyle(
    fontFamily: 'Inter',
    fontSize: 33,
    fontWeight: FontWeight.w800,
  );

  static TextStyle _buildStyle({
    required String fontFamily,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.3,
      letterSpacing: fontSize * -0.005,
      color: Colors.black,
    );
  }
}
```

**사용 예시**:
```dart
// 일본어
Text('スケジュール', style: AppleTypography.displayLargeExtraBold);

// 한국어
Text('일정', style: AppleTypography.displayLargeExtraBoldKo);

// 영어
Text('Schedule', style: AppleTypography.displayLargeExtraBoldEn);
```

---

### 방법 2: Flutter의 fontFamilyFallback 사용 (가장 간단 ⭐)
```dart
class AppleTypography {
  static const String fontFamily = 'LINE Seed JP App_TTF';
  
  /// Fallback 폰트 리스트
  static const List<String> fontFamilyFallback = [
    'Pretendard',  // 한국어 우선
    'Inter',       // 영어 대체
    'LINE Seed JP App_TTF',  // 일본어 기본
  ];

  static TextStyle get displayLargeExtraBold => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,  // ⭐ 핵심
    fontWeight: FontWeight.w800,
    fontSize: 33,
    height: 1.3,
    letterSpacing: letterSpacing(33),
    color: Colors.black,
  );
}
```

**동작 원리**:
1. 텍스트가 '일정'이면 → Pretendard 사용 (한글)
2. 텍스트가 'Schedule'이면 → Inter 사용 (영문)
3. 텍스트가 'スケジュール'이면 → LINE Seed JP 사용 (일본어)

**장점**:
- ✅ 코드 수정 불필요
- ✅ 자동으로 언어 감지
- ✅ 가장 간단

---

## 5. 추천 방법 정리

### 🥇 **방법 2 (fontFamilyFallback) 추천**
```dart
// apple_typography.dart
static TextStyle get displayLargeExtraBold => TextStyle(
  fontFamily: 'LINE Seed JP App_TTF',
  fontFamilyFallback: ['Pretendard', 'Inter'],
  fontWeight: FontWeight.w800,
  fontSize: 33,
  height: 1.3,
  letterSpacing: letterSpacing(33),
);
```

**이유**:
- ✅ 가장 간단 (코드 수정 최소)
- ✅ 자동 언어 감지
- ✅ Flutter 네이티브 기능
- ✅ 유지보수 쉬움

---

## 6. 폰트 라이선스 확인

### ✅ 오픈소스 (상업 사용 가능)
- LINE Seed JP: ✅ SIL Open Font License
- Pretendard: ✅ SIL Open Font License
- Inter: ✅ SIL Open Font License
- Noto Sans KR: ✅ SIL Open Font License

### ⚠️ 제한적 라이선스
- SF Pro Display: ⚠️ Apple 앱에서만 사용 가능 (Android 배포 제약)

---

## 7. 다음 단계

1. **폰트 다운로드**: Pretendard, Inter
2. **pubspec.yaml 수정**: 폰트 등록
3. **AppleTypography 수정**: fontFamilyFallback 추가
4. **테스트**: 한/영/일 텍스트 모두 확인
5. **기존 화면 적용**: 순차적으로 전환

---

**권장 폰트 조합**:
```yaml
일본어: LINE Seed JP App_TTF (기존)
한국어: Pretendard (추가)
영어: Inter (추가)
```

**이유**:
- ✅ 모두 오픈소스
- ✅ 스타일 유사 (조화로움)
- ✅ iOS 네이티브 느낌
- ✅ 가독성 우수

---

*작성자: GitHub Copilot*  
*버전: 1.0.0*  
*참고: [Flutter Font Documentation](https://docs.flutter.dev/cookbook/design/fonts)*
