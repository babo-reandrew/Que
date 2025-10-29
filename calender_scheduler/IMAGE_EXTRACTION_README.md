# 📸 이미지 기반 일정 추출 기능

Gemini AI를 사용하여 이미지에서 일정, 할 일, 습관을 자동으로 추출하는 기능입니다.

## ✨ 주요 기능

- 📷 **이미지 선택**: 갤러리 또는 카메라에서 이미지 선택
- 🤖 **AI 분석**: Google Gemini API로 이미지 텍스트 분석
- 📋 **자동 분류**: 일정(Schedule), 할 일(Todo), 습관(Habit) 자동 구분
- 🎨 **결과 카드**: 추출된 항목을 카드 형태로 시각적 표시
- 💾 **일괄 저장**: 개별 저장 또는 모두 저장 기능

## 🚀 설정 방법

### 1. Gemini API 키 발급

1. [Google AI Studio](https://ai.google.dev/) 방문
2. 무료 API 키 발급
3. API 키 복사

### 2. 환경 변수 설정

`.env` 파일을 생성하고 API 키를 입력하세요:

```bash
GEMINI_API_KEY=your_actual_api_key_here
```

⚠️ **중요**: `.env` 파일은 `.gitignore`에 포함되어 있으므로 Git에 커밋되지 않습니다.

### 3. 앱 실행

```bash
flutter pub get
flutter run
```

## 📱 사용 방법

### 화면 접근

```dart
// 라우트를 통한 접근
Navigator.pushNamed(context, AppRoutes.imageExtraction);

// 또는 직접 위젯 사용
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ImageExtractionScreen(),
  ),
);
```

### 사용 흐름

1. **이미지 선택**
   - "갤러리" 버튼: 기기의 사진 앨범에서 선택
   - "카메라" 버튼: 카메라로 즉시 촬영

2. **AI 분석**
   - 로딩 화면 표시 (약 3-10초 소요)
   - Gemini API가 이미지 텍스트 분석

3. **결과 확인**
   - 추출된 항목이 카드 형태로 표시
   - 타입별 색상 구분:
     - 🔵 **일정**: 파란색 (날짜 + 시간 지정)
     - 🟢 **할 일**: 초록색 (마감일만 있음)
     - 🟠 **습관**: 주황색 (반복 규칙 있음)

4. **저장**
   - **개별 저장**: 각 카드의 "저장" 버튼
   - **모두 저장**: 하단의 "모두 저장" 버튼

## 🏗️ 아키텍처

### 파일 구조

```
lib/
├── const/
│   └── gemini_prompt.dart          # Gemini API 프롬프트
├── model/
│   └── extracted_schedule.dart     # 추출된 데이터 모델
├── services/
│   └── gemini_service.dart         # Gemini API 통신
├── providers/
│   └── image_analysis_provider.dart # 상태 관리
├── component/
│   ├── loading_overlay.dart        # 로딩 화면
│   └── schedule_result_card.dart   # 결과 카드
└── screen/
    └── image_extraction_screen.dart # 메인 화면
```

### 데이터 흐름

```
이미지 선택 (ImagePicker)
    ↓
Provider (ImageAnalysisProvider)
    ↓
Gemini Service (이미지 → JSON)
    ↓
ExtractedSchedule 모델 변환
    ↓
UI 업데이트 (카드 표시)
    ↓
Drift Database 저장
```

## 🎯 Gemini 프롬프트 구조

이미지 분석을 위한 프롬프트는 다음과 같이 구성되어 있습니다:

### 입력 형식
- **이미지**: JPEG 형식 (최대 2048x2048)
- **프롬프트**: 구조화된 JSON 스키마 포함

### 출력 형식 (JSON)

```json
{
  "schedules": [
    {
      "summary": "치과 예약",
      "start": "2025-10-26T15:00:00",
      "end": "2025-10-26T16:00:00",
      "description": "",
      "location": "○○치과",
      "repeatRule": ""
    }
  ],
  "todos": [
    {
      "summary": "보고서 작성",
      "start": "2025-10-30T23:59:59",
      "end": "2025-10-30T23:59:59",
      "description": "분기별 실적 보고서",
      "location": ""
    }
  ],
  "habits": [
    {
      "summary": "아침 7시 기상",
      "start": "2025-10-26T07:00:00",
      "end": "2025-10-26T08:00:00",
      "repeatRule": "RRULE:FREQ=DAILY",
      "description": ""
    }
  ]
}
```

### 분류 기준

| 타입 | 특징 | 예시 |
|------|------|------|
| **일정** | 날짜 + 시간 모두 있음 | "10/26 오후 3시 회의" |
| **할 일** | 날짜만 있고 시간 없음 | "주말까지 청소하기" |
| **습관** | 반복 키워드 포함 | "매일 운동", "매주 월요일" |

## 🔧 주요 클래스

### 1. GeminiService

```dart
class GeminiService {
  // 이미지 분석
  Future<Map<String, dynamic>> analyzeImage({
    required Uint8List imageBytes,
  });
  
  // 재시도 로직 (Exponential Backoff)
  // Rate Limit 대응
}
```

### 2. ImageAnalysisProvider

```dart
class ImageAnalysisProvider extends ChangeNotifier {
  // 로딩 상태
  bool get isLoading;
  
  // 추출된 항목
  List<ExtractedSchedule> get extractedItems;
  
  // 타입별 필터링
  List<ExtractedSchedule> get schedules;
  List<ExtractedSchedule> get todos;
  List<ExtractedSchedule> get habits;
  
  // 분석 시작
  Future<void> analyzeImage(Uint8List imageBytes);
}
```

### 3. ExtractedSchedule

```dart
class ExtractedSchedule {
  final String summary;
  final DateTime start;
  final DateTime end;
  final String description;
  final String location;
  final String repeatRule;
  final ItemType type;
  
  // Drift Companion 변환
  ScheduleCompanion toCompanion();
}
```

## 📊 성능 최적화

### 이미지 최적화
- 최대 해상도: 2048x2048
- JPEG 압축: 85% 품질
- 메모리 효율적 처리

### 에러 처리
- ✅ 네트워크 에러 재시도 (최대 3회)
- ✅ Rate Limit 대응 (Exponential Backoff)
- ✅ JSON 파싱 오류 처리
- ✅ 사용자 친화적 오류 메시지

### API 호출 제한
- Gemini 1.5 Flash: 분당 15 요청 (무료)
- 재시도 간격: 1초 → 2초 → 4초 (+ 랜덤)

## 🐛 문제 해결

### API 키 오류
```
⚠️ [main.dart] GEMINI_API_KEY가 설정되지 않았습니다
```
**해결**: `.env` 파일에 올바른 API 키 입력

### Rate Limit 오류
```
❌ 429: Rate Limit Exceeded
```
**해결**: 자동 재시도 (최대 3회) 또는 1분 대기 후 재시도

### JSON 파싱 오류
```
❌ JSON 파싱 실패
```
**해결**: 프롬프트가 올바른지 확인, Gemini 모델 버전 확인

## 🎨 커스터마이징

### 프롬프트 수정

`lib/const/gemini_prompt.dart`에서 프롬프트를 수정할 수 있습니다:

```dart
const String GEMINI_IMAGE_ANALYSIS_PROMPT = '''
{
  "persona": "당신은...",
  "category_definitions": {
    // 분류 기준 커스터마이즈
  }
}
''';
```

### UI 스타일 변경

`lib/component/schedule_result_card.dart`에서 카드 디자인 변경:

```dart
Color _getTypeColor(ItemType type) {
  // 타입별 색상 변경
}
```

## 📝 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

## 🤝 기여

버그 리포트나 기능 제안은 이슈로 등록해주세요!
