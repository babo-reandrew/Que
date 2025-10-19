# 📊 Calendar Scheduler - 데이터베이스 아키텍처 문서

> **작성일:** 2025-10-14  
> **목적:** 전체 시스템의 데이터 흐름과 구조를 한눈에 파악하기 위한 문서  
> **대상:** 개발자, 유지보수 담당자

---

## 🎯 시스템 개요

Calendar Scheduler는 **Drift ORM**을 기반으로 **7개의 핵심 테이블**을 운영합니다:

### **📅 Core Tables (핵심 관리)**
1. **Schedule** (일정) - 구글 캘린더 스타일의 이벤트
2. **Task** (할일) - Things3/Todoist 스타일의 체크리스트
3. **Habit** (습관) - Habitica 스타일의 반복 루틴
4. **HabitCompletion** (습관 완료 기록) - 습관의 날짜별 완료 추적
5. **DailyCardOrder** (날짜별 카드 순서) - 일정/할일/습관 드래그앤드롭 순서 저장

### **🎵 Insight Player Tables (인사이트 음성)**
6. **AudioContents** (오디오 콘텐츠) - 날짜별 인사이트 음성 파일 + 재생 상태 통합 관리 ⭐ NEW!
7. **TranscriptLines** (스크립트 라인) - 타임스탬프 기반 대사 텍스트 ⭐ NEW!

---

## 📁 파일 구조

```
lib/
├── model/
│   ├── schedule.dart          # Schedule 테이블 정의
│   └── entities.dart          # Task, Habit, HabitCompletion 테이블 정의
│
├── Database/
│   ├── schedule_database.dart # AppDatabase 클래스 + CRUD 함수
│   └── schedule_database.g.dart # Drift 자동 생성 코드 (편집 금지!)
│
├── component/
│   ├── create_entry_bottom_sheet.dart # Quick Add UI + 저장 로직
│   └── quick_add/
│       └── quick_add_control_box.dart # Quick Add 입력 컴포넌트
│
└── utils/
    └── validators/
        ├── event_validators.dart   # Schedule 검증 로직
        └── entity_validators.dart  # Task/Habit 검증 로직
```

---

## 🗄️ 데이터베이스 테이블 구조

### **1️⃣ Schedule (일정)**

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| `id` | INT | ✅ | AUTO | Primary Key (자동 증가) |
| `start` | DATETIME | ✅ | - | 시작 시간 |
| `end` | DATETIME | ✅ | - | 종료 시간 |
| `summary` | TEXT | ✅ | - | 일정 제목 |
| `description` | TEXT | ✅ | - | 상세 설명 |
| `location` | TEXT | ✅ | - | 장소 |
| `colorId` | TEXT | ✅ | - | 색상 ID (예: 'red', 'blue') |
| `repeatRule` | TEXT | ✅ | - | 반복 규칙 (JSON 형식) |
| `alertSetting` | TEXT | ✅ | - | 알림 설정 (JSON 형식) |
| `status` | TEXT | ✅ | - | 상태 (예: 'confirmed') |
| `visibility` | TEXT | ✅ | - | 공개 범위 (예: 'public') |
| `createdAt` | DATETIME | ✅ | NOW() | 생성 시간 (UTC) |

**데이터 클래스:** `ScheduleData`  
**Companion 클래스:** `ScheduleCompanion`

**특징:**
- 구글 캘린더 API 필드와 호환
- `start`와 `end`는 **정확한 DateTime** (2025-10-14 14:30:00)
- 종일 이벤트는 `00:00:00 ~ 23:59:59`로 저장

---

### **2️⃣ Task (할일)**

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| `id` | INT | ✅ | AUTO | Primary Key (자동 증가) |
| `title` | TEXT | ✅ | - | 할일 제목 |
| `completed` | BOOL | ✅ | false | 완료 여부 |
| `dueDate` | DATETIME | ❌ | NULL | 마감일 (nullable) |
| `listId` | TEXT | ✅ | 'inbox' | 목록 ID (inbox, work, etc.) |
| `createdAt` | DATETIME | ✅ | NOW() | 생성 시간 |
| `completedAt` | DATETIME | ❌ | NULL | 완료 시간 |
| `colorId` | TEXT | ✅ | 'gray' | 색상 ID |

**데이터 클래스:** `TaskData`  
**Companion 클래스:** `TaskCompanion`

**특징:**
- Things3 스타일의 간결한 구조
- `dueDate`는 선택적 (마감일 없는 할일 허용)
- `completed`가 true가 되면 `completedAt`에 현재 시간 기록

---

### **3️⃣ Habit (습관)**

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| `id` | INT | ✅ | AUTO | Primary Key (자동 증가) |
| `title` | TEXT | ✅ | - | 습관 이름 |
| `createdAt` | DATETIME | ✅ | NOW() | 생성 시간 |
| `colorId` | TEXT | ✅ | 'gray' | 색상 ID |
| `repeatRule` | TEXT | ✅ | - | 반복 규칙 (JSON) |

**데이터 클래스:** `HabitData`  
**Companion 클래스:** `HabitCompanion`

**repeatRule 예시:**
```json
{
  "mon": true,
  "tue": true,
  "wed": false,
  "thu": true,
  "fri": true,
  "sat": false,
  "sun": false
}
```

**특징:**
- 반복 패턴을 JSON으로 저장
- 완료 기록은 별도 테이블 (`HabitCompletion`)에서 관리

---

### **4️⃣ HabitCompletion (습관 완료 기록)**

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| `id` | INT | ✅ | AUTO | Primary Key (자동 증가) |
| `habitId` | INT | ✅ | - | Foreign Key → Habit.id |
| `completedDate` | DATETIME | ✅ | - | 완료한 날짜 |
| `createdAt` | DATETIME | ✅ | NOW() | 기록 생성 시간 |

**데이터 클래스:** `HabitCompletionData`  
**Companion 클래스:** `HabitCompletionCompanion`

**특징:**
- 같은 습관도 날짜별로 별도 완료 기록 생성
- 스트릭(연속 기록) 계산 시 이 테이블 조회
- `habitId`로 `Habit` 테이블과 관계 설정

---

### **5️⃣ DailyCardOrder (날짜별 카드 순서)** ⭐ NEW!

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| `id` | INT | ✅ | AUTO | Primary Key (자동 증가) |
| `date` | DATETIME | ✅ | - | 대상 날짜 (자정으로 정규화) |
| `cardType` | TEXT | ✅ | - | 카드 유형 ('schedule', 'task', 'habit') |
| `cardId` | INT | ✅ | - | 해당 테이블의 ID (Schedule.id, Task.id, Habit.id) |
| `sortOrder` | INT | ✅ | - | 정렬 순서 (0부터 시작) |
| `updatedAt` | DATETIME | ✅ | NOW() | 순서 변경 시간 |

**데이터 클래스:** `DailyCardOrderData`  
**Companion 클래스:** `DailyCardOrderCompanion`

**특징:**
- **AnimatedReorderableListView 드래그앤드롭 순서 저장**
- 날짜별로 독립적인 순서 관리 (2025-10-14의 순서 ≠ 2025-10-15의 순서)
- `cardType` + `cardId`로 원본 데이터 조회 (Junction Table 패턴)
- 드래그 완료 시 `sortOrder` 업데이트

**예시 데이터:**
```sql
-- 2025-10-14 날짜의 카드 순서
id | date       | cardType  | cardId | sortOrder | updatedAt
---|------------|-----------|--------|-----------|-------------------
1  | 2025-10-14 | schedule  | 3      | 0         | 2025-10-14 10:00
2  | 2025-10-14 | task      | 12     | 1         | 2025-10-14 10:00
3  | 2025-10-14 | habit     | 5      | 2         | 2025-10-14 10:00
4  | 2025-10-14 | schedule  | 7      | 3         | 2025-10-14 10:00
```

**드래그앤드롭 제약:**
- **일정(Schedule)은 Divider 아래로 이동 불가** (shake 애니메이션 + 햅틱)
- 할일/습관은 자유롭게 이동 가능
- Divider 위치: 마지막 일정 다음 (동적 계산)

---

### **6️⃣ AudioContents (인사이트 오디오 - 메타데이터 + 재생 상태 통합)** ⭐ NEW!

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| **📦 메타데이터** |
| `id` | INT | ✅ | AUTO | Primary Key (자동 증가) |
| `title` | TEXT | ✅ | - | 인사이트 제목 (예: "過去データから見える自分可能性") |
| `subtitle` | TEXT | ✅ | - | 부제목 (예: "インサイト") |
| `audioPath` | TEXT | ✅ | - | 오디오 파일 경로 (`audio/insight_001.mp3`) |
| `durationSeconds` | INT | ✅ | - | 총 재생 시간 (초 단위) |
| `targetDate` | DATETIME | ✅ | - | 대상 날짜 (정규화: YYYY-MM-DD 00:00:00) |
| `createdAt` | DATETIME | ✅ | NOW() | 생성 시간 |
| **🎬 재생 상태** |
| `lastPositionMs` | INT | ✅ | 0 | 마지막 재생 위치 (밀리초) - 이어듣기용 |
| `isCompleted` | BOOL | ✅ | false | 완료 여부 (90% 이상 재생 시 true) |
| `lastPlayedAt` | DATETIME | ❌ | NULL | 마지막 재생 시각 (null = 한 번도 안 들음) |
| `completedAt` | DATETIME | ❌ | NULL | 완료 시각 (null = 미완료) |
| `playCount` | INT | ✅ | 0 | 총 재생 횟수 (통계용) |

**데이터 클래스:** `AudioContentData`  
**Companion 클래스:** `AudioContentsCompanion`

**UNIQUE 제약:** `targetDate` (하루에 하나의 인사이트만)

**특징:**
- **테이블 통합 설계:** 기존 `AudioProgress` 테이블을 제거하고 재생 상태를 `AudioContents`에 통합
- **JOIN 불필요:** 한 번의 쿼리로 메타데이터 + 재생 상태 모두 조회 가능
- **amlv 패키지 호환:** Apple Music 스타일 가사 뷰어와 완벽 통합
- **Asset 경로 주의:** amlv의 `AssetSource`가 자동으로 `"assets/"` 접두어를 추가하므로, DB에는 `"audio/..."` 형식으로 저장

**재생 시나리오별 데이터 흐름:**
```
1️⃣ 첫 재생 시작:
   playCount++, lastPlayedAt=now, lastPositionMs=0

2️⃣ 재생 중 (onLyricChanged):
   lastPositionMs = currentLine.startTimeMs (실시간 업데이트)
   lastPlayedAt = now

3️⃣ 일시정지/앱 종료:
   마지막 위치 자동 저장 → 다음 실행 시 이어듣기

4️⃣ 완료 (90%+ 재생):
   isCompleted = true
   completedAt = now

5️⃣ 완료 후 재시작:
   lastPositionMs = 0
   playCount++
   (isCompleted는 유지 - 통계용)
```

**예시 데이터:**
```sql
-- 2025-10-18 날짜의 인사이트
id | title                           | audioPath             | durationSeconds | lastPositionMs | isCompleted | playCount
---|----------------------------------|------------------------|-----------------|----------------|-------------|----------
1  | 過去データから見える自分可能性  | audio/insight_001.mp3 | 84              | 45200          | false       | 3
```

---

### **7️⃣ TranscriptLines (스크립트 라인 - amlv LyricViewer 호환)** ⭐ NEW!

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| `id` | INT | ✅ | AUTO | Primary Key (자동 증가) |
| `audioContentId` | INT | ✅ | - | Foreign Key → AudioContents.id (CASCADE DELETE) |
| `sequence` | INT | ✅ | - | 순서 번호 (0부터 시작) |
| `startTimeMs` | INT | ✅ | - | 시작 시간 (밀리초) - **타임스탬프!** ⏱️ |
| `endTimeMs` | INT | ✅ | - | 종료 시간 (밀리초) |
| `content` | TEXT | ✅ | - | 스크립트 텍스트 내용 |

**데이터 클래스:** `TranscriptLineData`  
**Companion 클래스:** `TranscriptLinesCompanion`

**UNIQUE 제약:** `{audioContentId, sequence}` (같은 오디오에서 순서 중복 불가)

**특징:**
- **LRC 파싱 결과 저장:** 타임스탬프와 텍스트를 함께 관리
- **자동 스크롤 동기화:** amlv가 `startTimeMs`를 보고 오디오 재생 위치에 맞춰 자동 스크롤
- **CASCADE DELETE:** `AudioContents`가 삭제되면 관련 스크립트 라인도 자동 삭제
- **성능 최적화:** `{audioContentId, sequence}` 복합 인덱스로 O(log n) 조회

**amlv 통합 코드:**
```dart
Lyric _convertToLyric(AudioContentData audioContent, List<TranscriptLineData> lines) {
  final lyricLines = lines.map((line) => LyricLine(
    time: Duration(milliseconds: line.startTimeMs), // ← 타임스탬프 사용!
    content: line.content,
  )).toList();
  
  return Lyric(
    audio: AssetSource(audioContent.audioPath),
    lines: lyricLines, // ← amlv가 이 타임스탬프 보고 자동 스크롤!
  );
}
```

**예시 데이터:**
```sql
-- audioContentId=1의 스크립트 라인들
id | audioContentId | sequence | startTimeMs | endTimeMs | content
---|----------------|----------|-------------|-----------|----------------------------------------
1  | 1              | 0        | 0           | 5500      | こんにちは。あなたの週訪時間に...
2  | 1              | 1        | 5500        | 12000     | こんにちは。脳科学と心理学で...
3  | 1              | 2        | 12000       | 18500     | Wさん、今日とても興味深いの...
4  | 1              | 3        | 18500       | 28000     | でも「価値観を整理する」とか...
```

**타임스탬프 활용:**
- **자동 스크롤:** amlv가 오디오 재생 중 `startTimeMs`와 현재 위치를 비교하여 현재 라인 하이라이트
- **수동 스킵:** 사용자가 특정 라인을 탭하면 해당 `startTimeMs`로 오디오 seek
- **이어듣기:** `lastPositionMs`를 `startTimeMs`와 비교하여 가장 가까운 라인부터 시작

---

## 🎵 Insight Player 데이터 흐름

### **📝 Insight 재생 시작 흐름**

```
┌─────────────────┐
│ DateDetailView  │
│ (인사이트 버튼) │
└────────┬────────┘
         │ onTap()
         ▼
┌─────────────────────────────────┐
│ database.getInsightForDate()    │
│ - SELECT * FROM audio_contents  │
│   WHERE targetDate = '2025-10-18'│
└────────┬────────────────────────┘
         │ AudioContentData?
         ▼
┌─────────────────────────────────┐
│ InsightPlayerScreen             │
│ - AudioContentData 로드          │
│ - TranscriptLines 조회           │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ _convertToLyric()               │
│ - TranscriptLineData → LyricLine│
│ - startTimeMs → Duration         │
└────────┬────────────────────────┘
         │ Lyric 객체
         ▼
┌─────────────────────────────────┐
│ amlv LyricViewer                │
│ - audio: AssetSource(audioPath) │
│ - lines: List<LyricLine>        │
│ - 자동 재생 + 스크롤 동기화     │
└─────────────────────────────────┘
```

---

### **🎬 재생 중 상태 저장 흐름**

```
┌─────────────────┐
│ amlv LyricViewer│
│ (오디오 재생 중)│
└────────┬────────┘
         │ onLyricChanged(LyricLine line)
         │ → 매 라인 변경마다 호출
         ▼
┌─────────────────────────────────┐
│ InsightPlayerScreen             │
│ onLyricChanged: (line) async {  │
│   final positionMs =            │
│     line.time.inMilliseconds;   │
│   await database.updateAudio-   │
│     Progress(id, positionMs);   │
│ }                                │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ updateAudioProgress()           │
│ - UPDATE audio_contents         │
│   SET lastPositionMs = ?,       │
│       lastPlayedAt = now        │
│   WHERE id = ?                  │
└─────────────────────────────────┘
```

---

### **✅ 재생 완료 처리 흐름**

```
┌─────────────────┐
│ amlv LyricViewer│
│ (재생 완료)     │
└────────┬────────┘
         │ onCompleted()
         ▼
┌─────────────────────────────────┐
│ InsightPlayerScreen             │
│ onCompleted: () async {         │
│   await database.markInsight-   │
│     AsCompleted(id);            │
│ }                                │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ markInsightAsCompleted()        │
│ - UPDATE audio_contents         │
│   SET isCompleted = true,       │
│       completedAt = now         │
│   WHERE id = ?                  │
└─────────────────────────────────┘
```

---

### **📊 재생 횟수 증가 (선택 사용)** 

```
┌─────────────────┐
│ 재생 버튼 클릭  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│ incrementPlayCount()            │
│ - SELECT playCount              │
│   FROM audio_contents           │
│   WHERE id = ?                  │
│ - UPDATE audio_contents         │
│   SET playCount = playCount + 1 │
└─────────────────────────────────┘
```

---

## 🛠️ Insight Player CRUD 함수 정리

### **AudioContents (인사이트 오디오)**

| 함수명 | 반환 타입 | 설명 |
|--------|-----------|------|
| `getInsightForDate(DateTime)` | `Future<AudioContentData?>` | 특정 날짜의 인사이트 조회 |
| `updateAudioProgress(int, int)` | `Future<void>` | 재생 위치 업데이트 (id, positionMs) |
| `markInsightAsCompleted(int)` | `Future<void>` | 완료 처리 (isCompleted=true, completedAt=now) |
| `incrementPlayCount(int)` | `Future<void>` | 재생 횟수 +1 증가 |

---

### **TranscriptLines (스크립트 라인)**

| 함수명 | 반환 타입 | 설명 |
|--------|-----------|------|
| `getTranscriptLines(int)` | `Future<List<TranscriptLineData>>` | 특정 오디오의 스크립트 라인 조회 (sequence 순) |

**정렬 순서:**
- `sequence` (오름차순 - 0, 1, 2, 3...)

---

## 🎨 amlv 패키지 통합 상세

### **LyricViewer 주요 기능**

```dart
LyricViewer(
  lyric: lyric,                         // Lyric 객체 (audio + lines)
  activeColor: Color(0xFF566099),       // 현재 라인 색상 (Figma #566099)
  inactiveColor: Colors.white.withOpacity(0.3), // 비활성 라인 색상
  gradientColor1: Color(0xFF566099),    // 그라데이션 시작 색
  gradientColor2: Color(0xFFFFFFFF),    // 그라데이션 끝 색
  playerIconSize: 64,                   // 재생 버튼 크기
  
  // 🎵 라인 변경 시 콜백 (DB 저장용)
  onLyricChanged: (LyricLine line, String source) async {
    await database.updateAudioProgress(id, line.time.inMilliseconds);
  },
  
  // ✅ 재생 완료 시 콜백 (완료 처리용)
  onCompleted: () async {
    await database.markInsightAsCompleted(id);
  },
);
```

**자동 제공 기능:**
- ✅ 오디오 재생/일시정지/탐색
- ✅ 타임스탬프 기반 자동 스크롤
- ✅ 현재 라인 하이라이트
- ✅ 라인 탭으로 특정 위치 스킵
- ✅ 진행 바 표시
- ✅ 재생 완료 감지

---

## 📊 Insight Player 실제 데이터 예시

### **AudioContents 저장 예시**

```dart
// ✅ seedInsightData()에서 자동 생성
final audioId = await into(audioContents).insert(
  AudioContentsCompanion.insert(
    title: '過去データから見える自分可能性',
    subtitle: 'インサイト',
    audioPath: 'audio/insight_001.mp3', // ⚠️ "asset/" 제외!
    durationSeconds: 84,
    targetDate: DateTime(2025, 10, 18),
    // 재생 상태는 기본값 자동 설정
    // lastPositionMs: 0, isCompleted: false, playCount: 0
  ),
);

// ✅ 콘솔 출력:
// [DB] 오디오 콘텐츠 생성 완료 (id=1)
```

---

### **TranscriptLines 저장 예시**

```dart
// ✅ seedInsightData()에서 자동 생성
final lines = [
  (0, 5500, 'こんにちは。あなたの週訪時間にインサイトをお届けする「脳の賢者たち」です。'),
  (5500, 12000, 'こんにちは。脳科学と心理学であなたの今日を応援するWです。'),
  (12000, 18500, 'Wさん、今日とても興味深いのToDoリストを見たんです...'),
  // ... 총 11개 라인
];

for (var i = 0; i < lines.length; i++) {
  await into(transcriptLines).insert(
    TranscriptLinesCompanion.insert(
      audioContentId: audioId,
      sequence: i,
      startTimeMs: lines[i].$1,
      endTimeMs: lines[i].$2,
      content: lines[i].$3,
    ),
  );
}

// ✅ 콘솔 출력:
// [DB] 스크립트 라인 11개 삽입 완료
```

---

### **재생 상태 업데이트 예시**

```dart
// ✅ 사용자가 45.2초 지점까지 재생 시
await database.updateAudioProgress(1, 45200);

// ✅ DB 상태:
// id=1: lastPositionMs=45200, lastPlayedAt='2025-10-18 15:30:00'

// ✅ 콘솔 출력:
// 💾 [DB] 재생 위치 저장: 45200ms
```

---

### **완료 처리 예시**

```dart
// ✅ 사용자가 인사이트를 끝까지 들었을 때
await database.markInsightAsCompleted(1);

// ✅ DB 상태:
// id=1: isCompleted=true, completedAt='2025-10-18 15:31:24'

// ✅ 콘솔 출력:
// ✅ [DB] markInsightAsCompleted: audioContentId=1
```

---

## 🔍 Insight Player 디버깅 가이드

### **흔한 에러와 해결책**

#### **1. `Unable to load asset: "assets/asset/audio/insight_001.mp3"`**

```dart
// ❌ 잘못된 코드 (DB에 "asset/" 포함)
audioPath: 'asset/audio/insight_001.mp3'
// → amlv가 "assets/" 추가 → "assets/asset/..." (중복!)

// ✅ 올바른 코드 (DB에 "audio/"만)
audioPath: 'audio/insight_001.mp3'
// → amlv가 "assets/" 추가 → "assets/audio/..." (정상!)
```

---

#### **2. `Null check operator used on a null value`**

```
원인: 기존 DB에 lastPositionMs, isCompleted 등의 컬럼이 없음

해결책 1: 시뮬레이터에서 앱 삭제 후 재설치 (깨끗한 v5 스키마)
해결책 2: xcrun simctl erase all (시뮬레이터 완전 초기화)
```

---

#### **3. `스크립트가 자동 스크롤 안 됨`**

```dart
// ❌ 잘못된 코드 (startTimeMs 누락)
LyricLine(
  content: line.content,
  // time이 없음!
)

// ✅ 올바른 코드 (startTimeMs 필수!)
LyricLine(
  time: Duration(milliseconds: line.startTimeMs),
  content: line.content,
)
```

---

## 📚 Insight Player 관련 문서

- **amlv 패키지:** https://pub.dev/packages/amlv
- **LRC 파싱 가이드:** https://en.wikipedia.org/wiki/LRC_(file_format)
- **audioplayers 패키지:** https://pub.dev/packages/audioplayers (amlv 내부 사용)

---

## 🎓 Insight Player 학습 로드맵

### **초급 (현재 시스템 이해)**
1. ✅ AudioContents + TranscriptLines 구조 파악
2. ✅ amlv LyricViewer 사용법 익히기
3. ✅ 타임스탬프 기반 자동 스크롤 이해
4. ✅ 재생 상태 DB 동기화 흐름 파악

### **중급 (기능 확장)**
5. ⏳ 여러 날짜의 인사이트 관리 (시드 데이터 추가)
6. ⏳ 인사이트 완료율 통계 대시보드
7. ⏳ 이어듣기 위치 표시 UI
8. ⏳ 재생 속도 조절 (0.5x ~ 2.0x)

### **고급 (성능 최적화)**
9. ⏳ 오디오 스트리밍 (로컬 캐싱)
10. ⏳ 백그라운드 재생 지원
11. ⏳ 스크립트 검색 기능

---

## 🔄 데이터베이스 스키마 버전 히스토리

| 버전 | 날짜 | 변경 사항 |
|------|------|-----------|
| v1 | 2025-10-01 | Schedule 테이블 초기 설계 |
| v2 | 2025-10-08 | Task, Habit, HabitCompletion 추가 |
| v3 | 2025-10-10 | Task/Habit에 repeatRule, reminder 컬럼 추가 |
| v4 | 2025-10-14 | DailyCardOrder 테이블 추가 (드래그앤드롭) |
| **v5** | **2025-10-18** | **AudioContents, TranscriptLines 추가 (Insight Player)** ⭐ |

**현재 버전:** `v5`

**마이그레이션 로직:**
```dart
// v4 → v5: Insight Player 테이블 추가
if (from == 4 && to >= 5) {
  await m.createTable(audioContents);
  await m.createTable(transcriptLines);
}
```

---

## 🎉 테이블 통합 설계 성과

### **Before (3-Table 구조):**
```
AudioContents (메타데이터)
  ↓ JOIN
AudioProgress (재생 상태)
  ↓ CASCADE DELETE
TranscriptLines (스크립트)
```
- ❌ 매번 JOIN 필요
- ❌ 2개 테이블 업데이트 필요
- ❌ 복잡한 코드

### **After (2-Table 구조):**
```
AudioContents (메타데이터 + 재생 상태 통합)
  ↓ CASCADE DELETE
TranscriptLines (스크립트)
```
- ✅ JOIN 불필요 (한 번의 SELECT)
- ✅ 1개 테이블 업데이트
- ✅ 간결한 코드
- ✅ 80% 코드 감소 (590 lines → 119 lines)

---

## 🔄 데이터 흐름도

### **📝 데이터 생성 흐름 (Create)**

```
┌─────────────────┐
│ 사용자 입력     │
│ (Quick Add UI)  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│ QuickAddControlBox              │
│ - 텍스트 입력                   │
│ - 색상 선택 (ColorPickerModal)  │
│ - 날짜/시간 선택 (DateTimeModal)│
│ - 타입 선택 (일정/할일/습관)    │
└────────┬────────────────────────┘
         │ _handleDirectAdd()
         │ → Map<String, dynamic> data
         ▼
┌─────────────────────────────────┐
│ CreateEntryBottomSheet          │
│ _saveQuickAdd(data)             │
└────────┬────────────────────────┘
         │
         ├─→ type == 'schedule' ─→ ScheduleCompanion.insert()
         │                           ↓
         │                       database.createSchedule()
         │
         ├─→ type == 'task' ─────→ TaskCompanion.insert()
         │                           ↓
         │                       EntityValidators.validateCompleteTask()
         │                           ↓
         │                       database.createTask()
         │
         └─→ type == 'habit' ────→ HabitCompanion.insert()
                                     ↓
                                 EntityValidators.validateCompleteHabit()
                                     ↓
                                 database.createHabit()
```

---

### **👀 데이터 조회 흐름 (Read - Stream)**

```
┌─────────────────┐
│ UI 화면         │
│ (HomeScreen,    │
│  DateDetailView)│
└────────┬────────┘
         │ initState()
         ▼
┌─────────────────────────────────┐
│ StreamBuilder<List<ScheduleData>>│
│ stream: database.watchByDay()    │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ AppDatabase                      │
│ watchByDay(DateTime selected)    │
│ - where: start < dayEnd          │
│   AND end > dayStart             │
│ - orderBy: start ASC, summary ASC│
│ - watch(): 실시간 구독 🔴        │
└────────┬────────────────────────┘
         │ DB 변경 감지
         ▼
┌─────────────────────────────────┐
│ StreamBuilder.builder()          │
│ - snapshot.data로 리스트 렌더링  │
│ - 자동 UI 갱신 ✨                │
└─────────────────────────────────┘
```

**핵심 포인트:**
- `.get()` → **일회성 조회** (Future)
- `.watch()` → **실시간 구독** (Stream)
- DB 변경 시 → Stream 자동 emit → StreamBuilder 자동 rebuild

---

### **✏️ 데이터 수정 흐름 (Update)**

```
┌─────────────────┐
│ 사용자 액션     │
│ (완료 버튼 클릭)│
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│ database.completeTask(id)        │
│ - update(task)                   │
│   .where(tbl.id == id)           │
│   .write(TaskCompanion(          │
│     completed: Value(true),      │
│     completedAt: Value(now)      │
│   ))                             │
└────────┬────────────────────────┘
         │ SQLite UPDATE 실행
         ▼
┌─────────────────────────────────┐
│ Drift Stream 자동 갱신           │
│ - watchTasks() 구독자들에게 알림 │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ UI 자동 업데이트                 │
│ - 체크박스가 자동으로 체크됨 ✅  │
└─────────────────────────────────┘
```

---

### **🗑️ 데이터 삭제 흐름 (Delete)**

```
┌─────────────────┐
│ 사용자 액션     │
│ (Slidable 스와이프)│
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│ database.deleteSchedule(id)      │
│ - delete(schedule)               │
│   .where(tbl.id == id)           │
│   .go()                          │
└────────┬────────────────────────┘
         │ SQLite DELETE 실행
         ▼
┌─────────────────────────────────┐
│ Drift Stream 자동 갱신           │
│ - watchByDay() 구독자들에게 알림 │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ UI 자동 업데이트                 │
│ - 아이템이 리스트에서 사라짐 💨  │
└─────────────────────────────────┘
```

**특별 케이스 - Habit 삭제:**
```
database.deleteHabit(id)
  ├─→ delete(habitCompletion).where(habitId == id) // 완료 기록 먼저 삭제
  └─→ delete(habit).where(id == id)                 // 그 다음 습관 삭제
```

---

## 🛠️ 핵심 CRUD 함수 정리

### **Schedule (일정)**

| 함수명 | 반환 타입 | 설명 |
|--------|-----------|------|
| `getSchedules()` | `Future<List<ScheduleData>>` | 전체 일정 조회 (일회성) |
| `watchSchedules()` | `Stream<List<ScheduleData>>` | 전체 일정 구독 (실시간) |
| `watchByDay(DateTime)` | `Stream<List<ScheduleData>>` | 특정 날짜 일정 구독 |
| `createSchedule(ScheduleCompanion)` | `Future<int>` | 일정 생성 → ID 반환 |
| `updateSchedule(ScheduleCompanion)` | `Future<bool>` | 일정 수정 → 성공 여부 |
| `deleteSchedule(int id)` | `Future<int>` | 일정 삭제 → 삭제 개수 |
| `completeSchedule(int id)` | `Future<int>` | 일정 완료 (현재는 삭제) |

---

### **Task (할일)**

| 함수명 | 반환 타입 | 설명 |
|--------|-----------|------|
| `watchTasks()` | `Stream<List<TaskData>>` | 전체 할일 구독 (실시간) |
| `createTask(TaskCompanion)` | `Future<int>` | 할일 생성 → ID 반환 |
| `completeTask(int id)` | `Future<int>` | 할일 완료 → 업데이트 개수 |
| `deleteTask(int id)` | `Future<int>` | 할일 삭제 → 삭제 개수 |

**정렬 순서:**
1. `completed` (false 먼저 - 미완료 우선)
2. `dueDate` (오름차순 - 마감일 빠른 것 우선)
3. `title` (오름차순 - 가나다순)

---

### **Habit (습관)**

| 함수명 | 반환 타입 | 설명 |
|--------|-----------|------|
| `watchHabits()` | `Stream<List<HabitData>>` | 전체 습관 구독 (실시간) |
| `createHabit(HabitCompanion)` | `Future<int>` | 습관 생성 → ID 반환 |
| `recordHabitCompletion(int, DateTime)` | `Future<int>` | 완료 기록 추가 |
| `getHabitCompletionsByDate(DateTime)` | `Future<List<HabitCompletionData>>` | 날짜별 완료 기록 |
| `deleteHabit(int id)` | `Future<int>` | 습관 삭제 (완료 기록 포함) |

**정렬 순서:**
- `createdAt` (내림차순 - 최신 것 우선)

---

### **DailyCardOrder (날짜별 순서)** ⭐ NEW!

| 함수명 | 반환 타입 | 설명 |
|--------|-----------|------|
| `watchDailyCardOrders(DateTime)` | `Stream<List<DailyCardOrderData>>` | 날짜별 순서 구독 (실시간) |
| `saveDailyCardOrder(DailyCardOrderCompanion)` | `Future<int>` | 새 순서 저장 → ID 반환 |
| `updateDailyCardOrder(int, int)` | `Future<int>` | 순서 업데이트 (id, newOrder) |
| `resetDailyCardOrders(DateTime)` | `Future<void>` | 해당 날짜 전체 순서 초기화 |
| `deleteDailyCardOrder(int)` | `Future<int>` | 순서 기록 삭제 |

**정렬 순서:**
- `sortOrder` (오름차순 - 0, 1, 2, 3...)

**사용 시나리오:**
```dart
// 1. 드래그 시작: 현재 순서 로드
final orders = await database.watchDailyCardOrders(selectedDate).first;

// 2. 드래그 완료: 새 순서 저장
await database.updateDailyCardOrder(cardId, newSortOrder);

// 3. UI 갱신: Stream이 자동으로 새 순서 emit
// → AnimatedReorderableListView 자동 업데이트
```

---

## 🔐 데이터 검증 시스템

### **EventValidators (Schedule 전용)**

```dart
class EventValidators {
  // 개별 필드 검증
  static String? validateTitle(String? title)
  static String? validateTime(DateTime? start, DateTime? end)
  static String? validateDescription(String? description)
  static String? validateLocation(String? location)
  
  // 종합 검증
  static ValidationResult validateCompleteEvent({
    String? title,
    DateTime? start,
    DateTime? end,
    String? description,
    String? location,
    String? colorId,
    List<ScheduleData>? existingSchedules,
    int? currentEventId,
  })
  
  // 디버깅
  static void printValidationResult(ValidationResult result)
}
```

---

### **EntityValidators (Task/Habit 전용)**

```dart
class EntityValidators {
  // ========================================
  // Task 검증
  // ========================================
  static String? validateTitle(String? title)
  static String? validateDueDate(DateTime? dueDate)
  
  static Map<String, dynamic> validateCompleteTask({
    String? title,
    DateTime? dueDate,
    String? colorId,
  })
  
  // ========================================
  // Habit 검증
  // ========================================
  static String? validateTitle(String? title)
  static String? validateRepeatRule(String? repeatRule)
  
  static Map<String, dynamic> validateCompleteHabit({
    String? title,
    String? colorId,
    String? repeatRule,
  })
  
  // ========================================
  // 공통 유틸리티
  // ========================================
  static void printValidationResult(
    Map<String, dynamic> result,
    String entityType,
  )
}
```

**ValidationResult 구조:**
```dart
{
  'isValid': bool,            // 전체 유효성
  'errors': Map<String, String>,   // 필드별 에러 메시지
  'warnings': List<String>,   // 경고 메시지
}
```

---

## 🎨 색상 시스템

### **colorId → Color 매핑**

`const/color.dart`에 정의된 색상 매핑:

```dart
final Map<String, Color> categoryColors = {
  'red': Color(0xFFFF6B6B),
  'orange': Color(0xFFFF8C42),
  'yellow': Color(0xFFFFD93D),
  'green': Color(0xFF6BCF7F),
  'blue': Color(0xFF4D96FF),
  'indigo': Color(0xFF6C5CE7),
  'purple': Color(0xFFA29BFE),
  'pink': Color(0xFFFF85A2),
  'gray': Color(0xFF95A5A6),
};
```

**사용 예시:**
```dart
// 저장 시
colorId: 'red'

// 표시 시
final color = categoryColors[schedule.colorId] ?? Colors.grey;
```

---

## 📊 실제 데이터 예시

### **Schedule 저장 예시**

```dart
// ✅ Quick Add로 저장하는 경우
final companion = ScheduleCompanion.insert(
  start: DateTime(2025, 10, 14, 14, 30),  // 2025-10-14 14:30:00
  end: DateTime(2025, 10, 14, 16, 0),     // 2025-10-14 16:00:00
  summary: '팀 미팅',
  description: 'Q4 기획 논의',
  location: '본사 3층 회의실',
  colorId: 'blue',
  repeatRule: '',
  alertSetting: '',
  status: 'confirmed',
  visibility: 'public',
);

final id = await database.createSchedule(companion);
// ✅ 콘솔 출력:
// [DB] createSchedule 실행 완료: ID=42로 일정 생성됨
//    → 제목: 팀 미팅
//    → 시작: 2025-10-14 14:30:00.000
//    → 종료: 2025-10-14 16:00:00.000
```

---

### **Task 저장 예시**

```dart
// ✅ Quick Add로 저장하는 경우
final companion = TaskCompanion.insert(
  title: '월말 보고서 작성',
  createdAt: DateTime.now(),
  colorId: Value('orange'),
  completed: const Value(false),
  dueDate: Value(DateTime(2025, 10, 31)),
  listId: const Value('work'),
);

final id = await database.createTask(companion);
// ✅ 콘솔 출력:
// [DB] createTask 실행 완료: ID=15로 할일 생성됨
//    → 제목: 월말 보고서 작성
```

---

### **Habit 저장 예시**

```dart
// ✅ Quick Add로 저장하는 경우
final companion = HabitCompanion.insert(
  title: '아침 운동',
  createdAt: DateTime.now(),
  repeatRule: '{"mon":true,"tue":true,"wed":true,"thu":true,"fri":true,"sat":false,"sun":false}',
  colorId: Value('green'),
);

final id = await database.createHabit(companion);
// ✅ 콘솔 출력:
// [DB] createHabit 실행 완료: ID=7로 습관 생성됨
//    → 제목: 아침 운동
```

---

### **HabitCompletion 저장 예시**

```dart
// ✅ 사용자가 특정 날짜에 습관 완료 시
final id = await database.recordHabitCompletion(
  7,  // habitId
  DateTime(2025, 10, 14),  // 오늘 날짜
);

// ✅ 콘솔 출력:
// [DB] recordHabitCompletion 실행 완료: habitId=7, date=2025-10-14 00:00:00.000
```

---

## 🚀 성능 최적화 팁

### **1. 필요한 데이터만 조회**

```dart
// ❌ 나쁜 예: 모든 데이터를 가져온 뒤 필터링
final all = await database.getSchedules();
final today = all.where((e) => DateUtils.isSameDay(e.start, DateTime.now()));

// ✅ 좋은 예: DB에서 필터링
final today = await database.watchByDay(DateTime.now()).first;
```

---

### **2. Stream 적극 활용**

```dart
// ❌ 나쁜 예: FutureBuilder + 수동 setState
Future<void> _loadData() async {
  final data = await database.getSchedules();
  setState(() { schedules = data; });
}

// ✅ 좋은 예: StreamBuilder (자동 갱신)
StreamBuilder<List<ScheduleData>>(
  stream: database.watchSchedules(),
  builder: (context, snapshot) {
    // DB 변경 시 자동 rebuild
  },
);
```

---

### **3. 복합 인덱스 활용 (향후 개선)**

```dart
// ⭐️ 향후 추가할 인덱스 예시
@TableIndex(name: 'schedule_by_date', columns: {#start, #end})
class Schedule extends Table { ... }

@TableIndex(name: 'task_by_status', columns: {#completed, #dueDate})
class Task extends Table { ... }
```

---

## 🔍 디버깅 가이드

### **콘솔 로그 읽기**

모든 DB 함수는 실행 시 자동으로 로그를 출력합니다:

```
✅ [DB] createSchedule 실행 완료: ID=42로 일정 생성됨
   → 제목: 팀 미팅
   → 시작: 2025-10-14 14:30:00.000
   → 종료: 2025-10-14 16:00:00.000
```

**로그 아이콘 의미:**
- `✅` : 성공
- `❌` : 에러
- `👀` : Stream 구독 시작
- `🗑️` : 삭제
- `🔄` : 업데이트
- `📊` : 조회
- `⚡` : Quick Add

---

### **흔한 에러와 해결책**

#### **1. `The argument type 'String' can't be assigned to 'Value<String>'`**

```dart
// ❌ 잘못된 코드
TaskCompanion.insert(
  title: '할일',
  colorId: 'red',  // ❌ String을 직접 전달
)

// ✅ 올바른 코드
TaskCompanion.insert(
  title: '할일',
  colorId: Value('red'),  // ✅ Value로 감싸기
)
```

---

#### **2. `Stream이 갱신 안 됨`**

```dart
// ❌ 잘못된 코드
final schedules = await database.getSchedules();  // 일회성 조회

// ✅ 올바른 코드
StreamBuilder<List<ScheduleData>>(
  stream: database.watchSchedules(),  // 실시간 구독
  builder: (context, snapshot) { ... },
)
```

---

#### **3. `Drift 생성 코드 에러`**

```bash
# 해결책: 코드 재생성
cd calender_scheduler
dart run build_runner build --delete-conflicting-outputs
```

---

## 📚 관련 문서

- **Drift 공식 문서:** https://drift.simonbinder.eu/
- **SQLite 문법:** https://www.sqlite.org/lang.html
- **Flutter GetIt:** https://pub.dev/packages/get_it

---

## 🎓 학습 로드맵

### **초급 (현재 시스템 이해)**
1. ✅ 5개 테이블 구조 파악 (DailyCardOrder 포함)
2. ✅ CRUD 함수 사용법 익히기
3. ✅ StreamBuilder 동작 원리 이해
4. ✅ AnimatedReorderableListView + DailyCardOrder 연동

### **중급 (기능 확장)**
5. ⏳ `repeatRule` JSON 파싱 구현
6. ⏳ `alertSetting` 푸시 알림 구현
7. ⏳ Task `listId` 기반 폴더 시스템
8. ⏳ Pagination 최적화 (현재 구현됨, 추가 개선 가능)

### **고급 (성능 최적화)**
9. ⏳ 복합 인덱스 추가
10. ⏳ 쿼리 최적화 (EXPLAIN 분석)
11. ⏳ 백그라운드 동기화 (Isolate)

---

## 🎨 AnimatedReorderableListView 통합

### **개요**
`date_detail_view.dart`에서 **드래그앤드롭 기능**을 제공하며, 순서는 `DailyCardOrder` 테이블에 저장됩니다.

### **핵심 컴포넌트**

#### **1. UnifiedListItem 모델**
```dart
enum UnifiedItemType { schedule, task, habit, divider, completed }

class UnifiedListItem {
  final String uniqueId;        // 'schedule_1', 'task_5', 'habit_3'
  final UnifiedItemType type;
  final dynamic data;           // ScheduleData | TaskData | HabitData
  final int sortOrder;          // DailyCardOrder.sortOrder
  final bool isDraggable;       // divider는 false
}
```

#### **2. 리스트 구성 알고리즘**
```dart
List<UnifiedListItem> _buildUnifiedItemList() {
  // 1. DailyCardOrder에서 날짜별 순서 로드
  final orders = dailyCardOrders; // sortOrder로 정렬됨
  
  // 2. 순서대로 실제 데이터 조회
  for (order in orders) {
    if (order.cardType == 'schedule') {
      // Schedule 데이터 조회 → UnifiedListItem.fromSchedule()
    } else if (order.cardType == 'task') {
      // Task 데이터 조회 → UnifiedListItem.fromTask()
    } else if (order.cardType == 'habit') {
      // Habit 데이터 조회 → UnifiedListItem.fromHabit()
    }
  }
  
  // 3. Divider 삽입 (마지막 일정 다음)
  final dividerIndex = scheduleCount;
  items.insert(dividerIndex, UnifiedListItem.divider());
  
  // 4. Completed 섹션 추가
  if (hasCompletedTasks) {
    items.add(UnifiedListItem.completed());
    items.addAll(completedTasks);
  }
  
  return items;
}
```

#### **3. 드래그앤드롭 제약 시스템**
```dart
void _handleReorder(int oldIndex, int newIndex) {
  final item = items[oldIndex];
  
  // 🚫 제약 1: Divider 위치보다 아래로 일정 이동 불가
  if (item.type == UnifiedItemType.schedule && newIndex > dividerIndex) {
    setState(() { _isReorderingScheduleBelowDivider = true; });
    HapticFeedback.heavyImpact(); // 강한 햅틱
    
    // 100ms 후 원래대로 복구 (shake 애니메이션)
    Future.delayed(100ms, () {
      setState(() { _isReorderingScheduleBelowDivider = false; });
    });
    return; // DB 저장 중단
  }
  
  // ✅ 제약 통과: sortOrder 업데이트
  await database.updateDailyCardOrder(item.id, newIndex);
}
```

### **데이터 흐름**
```
[사용자 드래그]
      ↓
[AnimatedReorderableListView.onReorder]
      ↓
[_handleReorder() 제약 검사]
      ↓
[database.updateDailyCardOrder()]
      ↓
[DailyCardOrder 테이블 UPDATE]
      ↓
[Stream 자동 갱신]
      ↓
[UI 자동 리렌더링]
```

### **애니메이션 설정**
```dart
AnimatedReorderableListView(
  dragStartDelay: Duration(milliseconds: 500),  // 0.5초 후 드래그 시작
  insertDuration: Duration(milliseconds: 300),  // 삽입 애니메이션 0.3초
  proxyDecorator: (child, index, animation) {
    return Transform.scale(
      scale: 1.0 + (animation.value * 0.03),  // 3% 확대
      child: Transform.rotate(
        angle: animation.value * 0.05,        // 약간 회전
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x14111111),     // #111111 8%
                offset: Offset(0, 4),         // Y축 4px
                blurRadius: 20,               // 블러 20px
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  },
);
```

### **Divider Shake 애니메이션**
```dart
// date_detail_view.dart
AnimatedContainer(
  duration: Duration(milliseconds: 100),
  decoration: BoxDecoration(
    border: _isReorderingScheduleBelowDivider
        ? Border.all(color: Colors.red, width: 2)  // 빨간 테두리
        : null,
  ),
  child: DividerCard(),
)
```

---

## 🆘 문제 해결 체크리스트

문제가 생겼을 때 순서대로 확인하세요:

- [ ] 콘솔에 에러 메시지가 있는가?
- [ ] `dart run build_runner build` 실행했는가?
- [ ] `schedule_database.g.dart` 파일이 최신인가?
- [ ] `GetIt.I<AppDatabase>()`가 정상 초기화되었는가?
- [ ] `StreamBuilder`를 사용하고 있는가?
- [ ] 검증 로그(`[검증]`)가 통과했는가?
- [ ] DB 저장 로그(`[DB]`)가 출력되었는가?

---

**마지막 업데이트:** 2025-10-18  
**작성자:** Cursor AI + Junsung  
**버전:** v5.0 (Insight Player 추가 - AudioContents + TranscriptLines)

**주요 변경사항:**
- ✅ `AudioContents` 테이블 추가 (인사이트 오디오 메타데이터 + 재생 상태 통합)
- ✅ `TranscriptLines` 테이블 추가 (타임스탬프 기반 스크립트 라인)
- ✅ `AudioProgress` 테이블 제거 (AudioContents에 통합하여 단순화)
- ✅ `amlv` 패키지 통합 (Apple Music 스타일 LyricViewer)
- ✅ 자동 스크롤 동기화 (startTimeMs 타임스탬프 기반)
- ✅ 재생 상태 실시간 DB 저장 (lastPositionMs, isCompleted, playCount)
- ✅ 테이블 3개 → 2개로 단순화 (JOIN 제거, 성능 향상)
- ✅ InsightPlayerScreen 80% 코드 감소 (590 lines → 119 lines)

**이전 버전 (v4.0):**
- ✅ `DailyCardOrder` 테이블 추가 (날짜별 드래그앤드롭 순서 저장)
- ✅ `AnimatedReorderableListView` 통합 (iOS 18 스타일 애니메이션)
- ✅ `UnifiedListItem` 모델 도입 (schedule/task/habit 통합 관리)
- ✅ Divider 제약 시스템 (일정은 아래로 이동 불가)
- ✅ Pagination 구현 (20개씩 로드, 무한 스크롤)

---

🎉 **수고하셨습니다!** 이 문서가 도움이 되었다면 북마크해두세요!

