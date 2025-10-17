# 📊 Calendar Scheduler - 데이터베이스 아키텍처 문서

> **작성일:** 2025-10-14  
> **목적:** 전체 시스템의 데이터 흐름과 구조를 한눈에 파악하기 위한 문서  
> **대상:** 개발자, 유지보수 담당자

---

## 🎯 시스템 개요

Calendar Scheduler는 **Drift ORM**을 기반으로 **4개의 핵심 테이블**을 운영합니다:

1. **Schedule** (일정) - 구글 캘린더 스타일의 이벤트
2. **Task** (할일) - Things3/Todoist 스타일의 체크리스트
3. **Habit** (습관) - Habitica 스타일의 반복 루틴
4. **HabitCompletion** (습관 완료 기록) - 습관의 날짜별 완료 추적

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
1. ✅ 4개 테이블 구조 파악
2. ✅ CRUD 함수 사용법 익히기
3. ✅ StreamBuilder 동작 원리 이해

### **중급 (기능 확장)**
4. ⏳ `repeatRule` JSON 파싱 구현
5. ⏳ `alertSetting` 푸시 알림 구현
6. ⏳ Task `listId` 기반 폴더 시스템

### **고급 (성능 최적화)**
7. ⏳ 복합 인덱스 추가
8. ⏳ 쿼리 최적화 (EXPLAIN 분석)
9. ⏳ 백그라운드 동기화 (Isolate)

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

**마지막 업데이트:** 2025-10-14  
**작성자:** Cursor AI + Junsung  
**버전:** v2.0 (Task/Habit 추가)

---

🎉 **수고하셨습니다!** 이 문서가 도움이 되었다면 북마크해두세요!

