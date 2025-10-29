# 반복 일정 시스템 아키텍처 (Recurring Events Architecture)

## 📋 목차
1. [개요](#개요)
2. [아키텍처 설계](#아키텍처-설계)
3. [데이터베이스 스키마](#데이터베이스-스키마)
4. [사용 예제](#사용-예제)
5. [Edge Case 처리](#edge-case-처리)
6. [성능 최적화](#성능-최적화)

---

## 개요

### Expert Way: Google Calendar 방식 채택

이 프로젝트는 **구글 캘린더**와 동일한 **"1개 Base Event + RRULE"** 방식을 사용합니다.

#### ❌ Naive Way (비추천)
```
매일 반복 10회 → 10개 행 생성
매주 반복 1년 → 52개 행 생성
무한 반복 → ∞개 행 생성 (불가능)
```

#### ✅ Expert Way (채택)
```
Base Event: 1개 행
RRULE: 1개 행
Exception: N개 행 (수정/삭제된 인스턴스만)

총 저장 공간: O(1 + exceptions)
```

### 핵심 원리

| 구성 요소 | 역할 | 예시 |
|---------|------|------|
| **Base Event** | 원본 일정/할일/습관 | Schedule.id=5 "팀 회의" |
| **RRULE** | 반복 규칙 (RFC 5545) | "FREQ=WEEKLY;BYDAY=MO,WE" |
| **EXDATE** | 제외할 날짜 | "20250315T100000,20250322T100000" |
| **Exception** | 수정/삭제된 인스턴스 | 3/15 회의 → 3/16으로 변경 |

---

## 아키텍처 설계

### 시스템 구성도

```
┌──────────────────────────────────────────────────────────┐
│                     UI Layer                              │
│  (HomeScreen, DateDetailView, TaskInbox)                  │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│              RecurringEventService                        │
│  - getScheduleInstances()                                 │
│  - getTaskInstances()                                     │
│  - cancelSingleInstance()                                 │
│  - rescheduleSingleInstance()                             │
└────────────────────┬─────────────────────────────────────┘
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
┌─────────────────┐   ┌─────────────────┐
│  RRuleUtils     │   │  AppDatabase    │
│  (rrule.dart)   │   │  (Drift)        │
└─────────────────┘   └─────────────────┘
          │                     │
          └──────────┬──────────┘
                     ▼
          ┌─────────────────────────┐
          │  SQLite (db.sqlite)     │
          │  - schedule             │
          │  - task                 │
          │  - habit                │
          │  - recurring_pattern    │
          │  - recurring_exception  │
          └─────────────────────────┘
```

---

## 데이터베이스 스키마

### 1. RecurringPattern (반복 규칙)

```sql
CREATE TABLE recurring_pattern (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_type TEXT NOT NULL,          -- 'schedule' | 'task' | 'habit'
  entity_id INTEGER NOT NULL,         -- Schedule.id | Task.id | Habit.id
  rrule TEXT NOT NULL,                -- RRULE 문자열
  dtstart DATETIME NOT NULL,          -- 반복 시작일
  until DATETIME,                     -- 종료일 (nullable)
  count INTEGER,                      -- 최대 횟수 (nullable)
  timezone TEXT DEFAULT 'UTC',        -- 시간대
  exdate TEXT DEFAULT '',             -- 제외 날짜 (쉼표 구분)
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(entity_type, entity_id)      -- 하나의 엔티티에는 하나의 규칙
);
```

### 2. RecurringException (예외 인스턴스)

```sql
CREATE TABLE recurring_exception (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  recurring_pattern_id INTEGER NOT NULL,
  original_date DATETIME NOT NULL,    -- 원래 발생 날짜
  is_cancelled BOOLEAN DEFAULT 0,     -- 취소 여부
  is_rescheduled BOOLEAN DEFAULT 0,   -- 시간 변경 여부
  new_start_date DATETIME,            -- 새 시작 시간
  new_end_date DATETIME,              -- 새 종료 시간
  modified_title TEXT,                -- 수정된 제목
  modified_description TEXT,          -- 수정된 설명
  modified_location TEXT,             -- 수정된 장소
  modified_color_id TEXT,             -- 수정된 색상
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(recurring_pattern_id, original_date),
  FOREIGN KEY(recurring_pattern_id) REFERENCES recurring_pattern(id) ON DELETE CASCADE
);
```

### 3. RRULE 표준 (RFC 5545)

| 파라미터 | 설명 | 예시 |
|---------|------|------|
| **FREQ** | 반복 주기 | DAILY, WEEKLY, MONTHLY, YEARLY |
| **INTERVAL** | 간격 | 2 (격주), 3 (3개월마다) |
| **BYDAY** | 요일 | MO,WE,FR (월/수/금) |
| **BYMONTHDAY** | 월의 날짜 | 15 (매월 15일), -1 (월말) |
| **UNTIL** | 종료 날짜 | 20251231T235959Z |
| **COUNT** | 발생 횟수 | 10 (10회만) |

#### RRULE 예시

```
1. 매일 10회
   FREQ=DAILY;COUNT=10

2. 매주 월/수/금 (무한)
   FREQ=WEEKLY;BYDAY=MO,WE,FR

3. 격주 화요일 (1년)
   FREQ=WEEKLY;INTERVAL=2;BYDAY=TU;UNTIL=20251231T235959Z

4. 매월 마지막 날
   FREQ=MONTHLY;BYMONTHDAY=-1

5. 매년 2월 29일 (윤년만)
   FREQ=YEARLY;BYMONTH=2;BYMONTHDAY=29
```

---

## 사용 예제

### 1. 반복 일정 생성

```dart
final service = RecurringEventService(database);

// 매주 월요일 10:00 팀 회의 (6개월)
await service.createRecurringSchedule(
  scheduleData: ScheduleCompanion.insert(
    summary: '팀 회의',
    start: DateTime(2025, 1, 6, 10, 0),  // 첫 월요일
    end: DateTime(2025, 1, 6, 11, 0),
    colorId: 'blue',
  ),
  rrule: 'FREQ=WEEKLY;BYDAY=MO',
  until: DateTime(2025, 7, 1),
);
```

### 2. 반복 할일 생성

```dart
// 매일 아침 7시 "아침 운동" (30회)
await service.createRecurringTask(
  taskData: TaskCompanion.insert(
    title: '아침 운동',
    executionDate: DateTime(2025, 10, 26, 7, 0),
    colorId: 'green',
    createdAt: DateTime.now(),
  ),
  rrule: 'FREQ=DAILY',
  count: 30,
);
```

### 3. 반복 습관 생성

```dart
// 평일 저녁 독서 (무한)
await service.createRecurringHabit(
  habitData: HabitCompanion.insert(
    title: '독서 30분',
    createdAt: DateTime.now(),
    colorId: 'purple',
    repeatRule: '',  // RRULE로 대체됨
  ),
  rrule: 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
);
```

### 4. 특정 날짜 범위의 인스턴스 조회

```dart
// 이번 주 일정 가져오기
final startOfWeek = DateTime(2025, 10, 20);
final endOfWeek = DateTime(2025, 10, 27);

final instances = await service.getScheduleInstances(
  rangeStart: startOfWeek,
  rangeEnd: endOfWeek,
);

for (final instance in instances) {
  print('${instance.occurrenceDate}: ${instance.displayTitle}');
}
```

### 5. 단일 인스턴스 수정/삭제

```dart
// 10월 25일 회의만 취소
await service.cancelSingleInstance(
  entityType: 'schedule',
  entityId: 5,
  originalDate: DateTime(2025, 10, 25, 10, 0),
);

// 10월 30일 회의만 시간 변경 (10:00 → 14:00)
await service.rescheduleSingleInstance(
  entityType: 'schedule',
  entityId: 5,
  originalDate: DateTime(2025, 10, 30, 10, 0),
  newStartDate: DateTime(2025, 10, 30, 14, 0),
  newEndDate: DateTime(2025, 10, 30, 15, 0),
);

// 11월 6일 회의만 제목 변경
await service.modifySingleInstance(
  entityType: 'schedule',
  entityId: 5,
  originalDate: DateTime(2025, 11, 6, 10, 0),
  modifiedTitle: '긴급 팀 회의 (변경)',
);
```

### 6. RRuleUtils 사용 예제

```dart
// RRULE 빌드
final rrule = RRuleUtils.buildRRule(
  frequency: Frequency.weekly,
  byWeekDays: [
    ByWeekDayEntry.monday,
    ByWeekDayEntry.wednesday,
  ],
  until: DateTime(2025, 12, 31),
);
// 결과: "FREQ=WEEKLY;BYDAY=MO,WE;UNTIL=20251231T235959Z"

// 한국어 설명 생성
final description = RRuleUtils.getDescription(rrule);
// 결과: "매주 월, 수요일 (2025-12-31까지)"

// 다음 발생 날짜 조회
final nextDate = RRuleUtils.getNextOccurrence(
  rruleString: rrule,
  dtstart: DateTime(2025, 10, 27),  // 월요일
);
// 결과: 2025-10-29 (다음 수요일)
```

---

## Edge Case 처리

### 1. 윤년 처리

```dart
// 2월 29일 반복 → 평년에는 2월 28일 또는 3월 1일 생성
final rrule = 'FREQ=YEARLY;BYMONTH=2;BYMONTHDAY=29';
final instances = RRuleUtils.generateInstances(
  rruleString: rrule,
  dtstart: DateTime(2024, 2, 29),  // 윤년
  rangeStart: DateTime(2024, 1, 1),
  rangeEnd: DateTime(2027, 12, 31),
);
// 결과: [2024-02-29, 2028-02-29] (2025, 2026, 2027 스킵)
```

### 2. 일광절약시간 (DST)

```dart
// 시간대 정보 포함 저장
await service.createRecurringSchedule(
  scheduleData: ...,
  rrule: 'FREQ=WEEKLY;BYDAY=SU',
  timezone: 'America/New_York',  // DST 자동 처리
);
```

### 3. 월말 처리

```dart
// 매월 마지막 날 반복
final rrule = 'FREQ=MONTHLY;BYMONTHDAY=-1';
// 1월: 31일, 2월: 28일(평년)/29일(윤년), 4월: 30일
```

### 4. 무한 반복 성능 최적화

```dart
// 무한 반복은 1년치만 생성
final instances = await service.getScheduleInstances(
  rangeStart: DateTime.now(),
  rangeEnd: DateTime.now().add(const Duration(days: 365)),
);
// 필요시 추가 범위 요청 (Lazy Loading)
```

### 5. EXDATE vs Exception 선택

| 상황 | 사용 방법 | 이유 |
|------|----------|------|
| 단순 삭제 | EXDATE 또는 Exception (isCancelled) | 둘 다 가능 |
| 시간 변경 | Exception (isRescheduled) | 새 시간 저장 필요 |
| 내용 변경 | Exception (modifiedTitle 등) | 수정 필드 저장 |

---

## 성능 최적화

### 1. Memoization (캐싱)

```dart
class RecurringEventService {
  final _cache = <String, List<DateTime>>{};

  Future<List<ScheduleInstance>> getScheduleInstances(...) async {
    final cacheKey = 'schedule_${rangeStart}_${rangeEnd}';
    
    if (_cache.containsKey(cacheKey)) {
      // 캐시 적중
      return _buildInstancesFromCache(_cache[cacheKey]!);
    }

    // 캐시 미스 → 생성
    final instances = await _generateInstances(...);
    _cache[cacheKey] = instances.map((e) => e.occurrenceDate).toList();
    return instances;
  }
}
```

### 2. On-Demand Generation (필요 시 생성)

```dart
// 조회 시점에만 필요한 날짜 범위 생성
final thisWeek = await service.getScheduleInstances(
  rangeStart: startOfWeek,
  rangeEnd: endOfWeek,
);

// 다음 주가 필요할 때만 추가 생성
final nextWeek = await service.getScheduleInstances(
  rangeStart: endOfWeek,
  rangeEnd: endOfWeek.add(const Duration(days: 7)),
);
```

### 3. 복합 인덱스 최적화

```sql
-- recurring_pattern 테이블
CREATE UNIQUE INDEX idx_entity ON recurring_pattern(entity_type, entity_id);

-- recurring_exception 테이블
CREATE UNIQUE INDEX idx_exception ON recurring_exception(recurring_pattern_id, original_date);
```

### 4. Stream vs Future 선택

```dart
// 실시간 갱신 필요: Stream
Stream<List<ScheduleInstance>> watchScheduleInstances(...) {
  return _db.watchSchedules().asyncMap((schedules) async {
    return await _generateInstances(schedules, ...);
  });
}

// 일회성 조회: Future
Future<List<ScheduleInstance>> getScheduleInstances(...) async {
  final schedules = await _db.getSchedules();
  return await _generateInstances(schedules, ...);
}
```

---

## 데이터 흐름 다이어그램

### 반복 일정 조회 플로우

```
1. UI에서 날짜 범위 요청
   ↓
2. RecurringEventService.getScheduleInstances()
   ↓
3. [DB] Base Schedule 조회 (일반 + 반복 모두)
   ↓
4. 각 일정에 대해:
   - 반복 규칙 조회 (RecurringPattern)
   - RRULE 파싱 → RRuleUtils.generateInstances()
   - 예외 조회 (RecurringException)
   ↓
5. 예외 적용:
   - isCancelled=true → 스킵
   - isRescheduled=true → 새 시간 사용
   - modifiedXXX → 수정된 내용 사용
   ↓
6. 정렬 및 반환
   ↓
7. UI에 표시
```

### 단일 인스턴스 수정 플로우

```
1. 사용자가 특정 발생 수정 (예: 3/15 회의 시간 변경)
   ↓
2. RecurringEventService.rescheduleSingleInstance()
   ↓
3. [DB] RecurringException 생성
   - recurringPatternId: 5
   - originalDate: 2025-03-15T10:00:00
   - isRescheduled: true
   - newStartDate: 2025-03-15T14:00:00
   ↓
4. 이후 조회 시:
   - 3/15 10:00 → 예외 감지 → 3/15 14:00로 표시
   - 3/22 10:00 → 정상 발생
   - 3/29 10:00 → 정상 발생
```

---

## 참고 자료

- [RFC 5545 - iCalendar](https://datatracker.ietf.org/doc/html/rfc5545)
- [rrule.dart Package](https://pub.dev/packages/rrule)
- [Google Calendar API - Recurring Events](https://developers.google.com/workspace/calendar/api/v3/reference/events)
- [Managing Recurring Events (Vertabelo)](https://vertabelo.com/blog/again-and-again-managing-recurring-events-in-a-data-model/)

---

## 마이그레이션 가이드

### 기존 데이터 → 반복 일정 전환

```dart
// 기존: Task.repeatRule JSON
final oldTask = await db.getTaskById(1);
final oldRepeat = jsonDecode(oldTask.repeatRule);

// 새로운: RecurringPattern RRULE
if (oldRepeat['enabled'] == true) {
  final rrule = _convertJsonToRRule(oldRepeat);
  await service.createRecurringTask(
    taskData: TaskCompanion(
      id: Value(oldTask.id),
      title: Value(oldTask.title),
      ...
    ),
    rrule: rrule,
  );
}

String _convertJsonToRRule(Map<String, dynamic> json) {
  if (json['type'] == 'daily') {
    return 'FREQ=DAILY';
  } else if (json['type'] == 'weekly') {
    final days = (json['days'] as List).map((d) => _dayToRRule(d)).join(',');
    return 'FREQ=WEEKLY;BYDAY=$days';
  }
  // ... 추가 변환 로직
}
```

---

## 테스트 시나리오

```dart
void main() {
  test('매주 월/수/금 회의 생성', () async {
    final service = RecurringEventService(db);
    
    await service.createRecurringSchedule(
      scheduleData: ScheduleCompanion.insert(
        summary: '회의',
        start: DateTime(2025, 10, 27, 10, 0),  // 월요일
        end: DateTime(2025, 10, 27, 11, 0),
        colorId: 'blue',
      ),
      rrule: 'FREQ=WEEKLY;BYDAY=MO,WE,FR;COUNT=12',
    );

    final instances = await service.getScheduleInstances(
      rangeStart: DateTime(2025, 10, 27),
      rangeEnd: DateTime(2025, 11, 17),
    );

    expect(instances.length, 12);  // 4주 × 3일 = 12회
  });

  test('윤년 2월 29일 처리', () async {
    final rrule = 'FREQ=YEARLY;BYMONTH=2;BYMONTHDAY=29';
    final instances = RRuleUtils.generateInstances(
      rruleString: rrule,
      dtstart: DateTime(2024, 2, 29),
      rangeStart: DateTime(2024, 1, 1),
      rangeEnd: DateTime(2029, 12, 31),
    );

    expect(instances.length, 2);  // 2024, 2028만
    expect(instances[0].year, 2024);
    expect(instances[1].year, 2028);
  });
}
```

---

**작성일:** 2025-10-25  
**버전:** 1.0.0  
**작성자:** Calendar Scheduler Team
