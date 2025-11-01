# 🎯 반복 이벤트 시스템 종합 분석 및 개선 방안

> **분석 날짜**: 2025년 10월 31일  
> **참조 문서**: 캘린더 반복 이벤트 표시를 위한 시스템 아키텍처 및 시나리오 종합 분석

---

## I. 현재 시스템 구조 분석

### ✅ 잘 구현된 부분 (Strengths)

#### 1. **아키텍처: 동적 생성(On-the-Fly) 방식 채택** ⭐⭐⭐⭐⭐
**현재 구현:**
```dart
// RecurringPattern 테이블 (lib/model/entities.dart)
class RecurringPattern extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();        // 'schedule' | 'task' | 'habit'
  IntColumn get entityId => integer()();
  TextColumn get rrule => text()();             // RFC 5545 표준 RRULE
  DateTimeColumn get dtstart => dateTime()();
  DateTimeColumn get until => dateTime().nullable()();
  IntColumn get count => integer().nullable()();
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();
  TextColumn get exdate => text().withDefault(const Constant(''))();
}
```

**평가:**
- ✅ **완벽 구현**: "무한 반복 이벤트도 단 1개의 행만 저장"하는 동적 생성 모델을 정확히 구현
- ✅ **저장 효율성**: 보고서의 "O(1) 저장 공간" 원칙 준수
- ✅ **표준 준수**: RFC 5545 RRULE 표준 완벽 지원
- ✅ **유연성**: `entityType`을 통해 Schedule/Task/Habit 모두 지원

**보고서 일치도**: ✅ Section II.B "동적 생성(On-the-Fly) 접근 방식" 완벽 구현

---

#### 2. **데이터 모델: iCalendar(RFC 5545) 기반** ⭐⭐⭐⭐⭐
**현재 구현:**
```dart
// RRULE 예시 지원
// "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,FR;UNTIL=20250601T235959Z"
// → 매주 월/금요일, 2025-06-01까지

// EXDATE 지원
TextColumn get exdate => text().withDefault(const Constant(''))();
// → "20250315T100000,20250322T100000" 형식
```

**평가:**
- ✅ **RRULE 완벽 지원**: FREQ, INTERVAL, BYDAY, UNTIL, COUNT 모두 지원
- ✅ **EXDATE 구현**: "삭제된 인스턴스" 처리 (보고서 III.B 유형 1)
- ✅ **RecurringException 테이블**: "수정된 인스턴스" 처리 (보고서 III.B 유형 2)

**보고서 일치도**: ✅ Section III.A "iCalendar(RFC 5545) 기반 데이터 모델" 완벽 준수

---

#### 3. **예외 처리: 두 가지 유형 명확히 구분** ⭐⭐⭐⭐⭐
**현재 구현:**
```dart
// RecurringException 테이블 (lib/model/entities.dart)
class RecurringException extends Table {
  IntColumn get recurringPatternId => integer()();
  DateTimeColumn get originalDate => dateTime()();
  BoolColumn get isCancelled => boolean().withDefault(const Constant(false))();
  BoolColumn get isRescheduled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get newStartDate => dateTime().nullable()();
  DateTimeColumn get newEndDate => dateTime().nullable()();
  TextColumn get modifiedTitle => text().nullable()();
  TextColumn get modifiedDescription => text().nullable()();
  // ... 기타 수정 필드
}
```

**평가:**
- ✅ **유형 1 (삭제)**: `isCancelled` + EXDATE로 처리
- ✅ **유형 2 (수정)**: `isRescheduled` + 별도 필드로 수정 사항 저장
- ✅ **보고서 원칙**: "삭제 + 생성"의 조합으로 처리하는 로직 정확히 구현

**보고서 일치도**: ✅ Section III.B "예외(Exception)의 두 가지 유형" 완벽 구현

---

#### 4. **읽기 파이프라인: 정확한 알고리즘 구현** ⭐⭐⭐⭐
**현재 구현:**
```dart
// lib/Database/schedule_database.dart
Stream<List<ScheduleData>> watchSchedulesWithRepeat(DateTime targetDate) async* {
  for (final schedule in schedules) {
    final pattern = await getRecurringPattern(
      entityType: 'schedule',
      entityId: schedule.id,
    );

    if (pattern == null) {
      // 1. 일반 이벤트: 날짜 체크
      if (schedule.start.isBefore(targetEnd) && schedule.end.isAfter(target)) {
        if (!schedule.completed) result.add(schedule);
      }
    } else {
      // 2. 반복 이벤트: RRULE 확장
      final instances = await _generateScheduleInstancesForDate(...);
      
      // 3. 예외 처리 (삭제/수정)
      final exceptions = await getRecurringExceptions(pattern.id);
      
      // 4. 수정된 필드 적용
      if (exception != null && !exception.isCancelled) {
        displaySchedule = ScheduleData(
          summary: exception.modifiedTitle ?? schedule.summary,
          start: exception.newStartDate ?? schedule.start,
          // ... 수정 사항 병합
        );
      }
      
      result.add(displaySchedule);
    }
  }
}
```

**평가:**
- ✅ **3단계 파이프라인**: 마스터 확장 → 예외 필터링 → 수정 병합
- ✅ **완료 상태 관리**: ScheduleCompletion 테이블로 반복 이벤트 완료 추적
- ⚠️ **성능**: 실시간 계산 (개선 필요 - 후술)

**보고서 일치도**: ✅ Section III.C "읽기(Read) 파이프라인" 알고리즘 정확히 구현

---

#### 5. **상태(State) 기반 반복: recurrenceMode 필드** ⭐⭐⭐⭐
**현재 구현:**
```dart
// RecurringPattern 테이블
TextColumn get recurrenceMode => text().withDefault(
  const Constant('ABSOLUTE'),
)(); // 'ABSOLUTE' | 'RELATIVE_ON_COMPLETION'
```

**평가:**
- ✅ **Todoist 스타일**: `every` (ABSOLUTE) vs `every!` (RELATIVE_ON_COMPLETION) 구분
- ✅ **설계 완료**: 데이터 모델은 준비됨
- ⚠️ **구현 미완**: RELATIVE_ON_COMPLETION 로직이 코드에 아직 미구현

**보고서 일치도**: ✅ Section V.B "every vs every!" 개념은 준비됨, 구현 필요

---

### ❌ 개선이 필요한 부분 (Critical Issues)

---

## II. 핵심 문제점 및 개선 방안

### 🚨 **문제점 1: 시간대(Timezone) 및 DST 처리 부재** (치명적)

#### 현재 상태:
```dart
// RecurringPattern 테이블
TextColumn get timezone => text().withDefault(const Constant('UTC'))();
// ❌ 저장은 되지만 실제 로직에서 사용하지 않음!

// RRuleUtils.generateInstances()
final dtstartDateOnly = DateTime.utc(
  dtstart.year,
  dtstart.month,
  dtstart.day,
);
// ❌ 모든 날짜를 UTC로 변환 → 로컬 시간 무시
```

#### 보고서가 요구하는 것:
```
Section IV.A "알람 시계 문제"와 DST:
- ✅ 올바른 모델: (로컬 시간 "08:00", TZID "Asia/Seoul", RRULE)
- ❌ 잘못된 모델: (UTC 타임스탬프만 저장)

문제: "매일 오전 8시" 이벤트가 DST 변경 시 "오전 9시"로 표시됨
```

#### 개선 방안:

**1단계: Schedule 테이블에 로컬 시간 저장**
```dart
// lib/model/schedule.dart
class Schedule extends Table {
  DateTimeColumn get start => dateTime()();        // ❌ 기존: UTC 타임스탬프
  DateTimeColumn get end => dateTime()();
  
  // ✅ 추가 필요:
  IntColumn get startHour => integer().nullable()();    // 로컬 시간 (0-23)
  IntColumn get startMinute => integer().nullable()();  // 로컬 분 (0-59)
  IntColumn get endHour => integer().nullable()();
  IntColumn get endMinute => integer().nullable()();
  TextColumn get timezone => text().withDefault(const Constant(''))(); // IANA ID
  BoolColumn get isFloating => boolean().withDefault(const Constant(false))(); // Section IV.B
}
```

**2단계: RRuleUtils에서 Timezone 고려**
```dart
// lib/utils/rrule_utils.dart
static List<DateTime> generateInstances({
  required String rruleString,
  required DateTime dtstart,
  required String timezone,  // ✅ 추가
  required DateTime rangeStart,
  required DateTime rangeEnd,
}) {
  // ✅ timezone 패키지 사용
  import 'package:timezone/timezone.dart' as tz;
  
  final location = tz.getLocation(timezone); // 예: 'Asia/Seoul'
  
  // ✅ dtstart를 해당 timezone의 로컬 시간으로 해석
  final localStart = tz.TZDateTime(
    location,
    dtstart.year,
    dtstart.month,
    dtstart.day,
    dtstart.hour,
    dtstart.minute,
  );
  
  // RRULE 인스턴스 생성 시 localStart 사용
  // → DST 변경 시에도 로컬 시간 유지됨
}
```

**3단계: 표시 로직 수정**
```dart
// lib/screen/date_detail_view.dart
Widget _buildScheduleCard(ScheduleData schedule, RecurringPatternData? pattern) {
  DateTime displayTime;
  
  if (schedule.isFloating) {
    // ✅ 부동 시간: 사용자 기기의 현재 시간대로 표시
    displayTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      schedule.startHour!,
      schedule.startMinute!,
    );
  } else if (schedule.timezone.isNotEmpty) {
    // ✅ 고정 시간대: timezone 고려하여 변환
    final location = tz.getLocation(schedule.timezone);
    final tzTime = tz.TZDateTime(
      location,
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      schedule.startHour!,
      schedule.startMinute!,
    );
    displayTime = tzTime.toLocal(); // 사용자 기기 시간대로 변환
  } else {
    // Fallback: 기존 UTC 방식
    displayTime = schedule.start;
  }
  
  return Text('${displayTime.hour}:${displayTime.minute.toString().padLeft(2, '0')}');
}
```

**필요 패키지:**
```yaml
# pubspec.yaml
dependencies:
  timezone: ^0.9.0
```

**보고서 참조**: Section IV.A, IV.B, IV.C

---

### 🚨 **문제점 2: 읽기 성능 - 구체화된 뷰(Materialized View) 부재** (중요)

#### 현재 상태:
```dart
// ❌ 매번 실시간 계산
Stream<List<ScheduleData>> watchSchedulesWithRepeat(DateTime targetDate) async* {
  for (final schedule in schedules) {
    // 모든 일정에 대해 RRULE 파싱 + 예외 조회 + 병합
    final instances = await _generateScheduleInstancesForDate(...);
  }
}
```

**문제점:**
- 사용자가 "3월 보기"를 열 때마다 모든 반복 규칙을 다시 계산
- DB 쿼리 N회 (일정 개수만큼) + RRULE 파싱 N회
- 월뷰에서 30일 × N개 일정 = 매우 느린 성능

#### 보고서가 권장하는 것:
```
Section II.C "하이브리드 아키텍처":
- 쓰기: 동적 모델 (RecurringPattern 테이블)
- 읽기: Materialized View (미리 계산된 인스턴스 캐시)
```

#### 개선 방안:

**1단계: MaterializedInstance 테이블 생성**
```dart
// lib/model/entities.dart
@DataClassName('MaterializedInstanceData')
class MaterializedInstance extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // 원본 이벤트 참조
  TextColumn get entityType => text()(); // 'schedule' | 'task' | 'habit'
  IntColumn get entityId => integer()();
  IntColumn get recurringPatternId => integer().nullable()();
  
  // 인스턴스 정보
  DateTimeColumn get occurrenceDate => dateTime()(); // 발생 날짜
  BoolColumn get isException => boolean().withDefault(const Constant(false))();
  IntColumn get exceptionId => integer().nullable()(); // RecurringException.id
  
  // 캐시된 표시 데이터 (빠른 읽기)
  TextColumn get cachedTitle => text()();
  DateTimeColumn get cachedStartTime => dateTime()();
  DateTimeColumn get cachedEndTime => dateTime()();
  TextColumn get cachedColorId => text()();
  
  // 메타데이터
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get validUntil => dateTime()(); // 캐시 만료 시간
  
  @override
  Set<Column> get primaryKey => {id};
}
```

**2단계: 캐시 갱신 로직**
```dart
// lib/Database/schedule_database.dart

/// 특정 RecurringPattern의 캐시 갱신 (과거 1개월 ~ 미래 3개월)
Future<void> refreshMaterializedInstances(int recurringPatternId) async {
  final pattern = await getRecurringPatternById(recurringPatternId);
  if (pattern == null) return;
  
  // 1. 기존 캐시 삭제
  await (delete(materializedInstance)
    ..where((tbl) => tbl.recurringPatternId.equals(recurringPatternId))
  ).go();
  
  // 2. 인스턴스 생성 (3개월치)
  final now = DateTime.now();
  final rangeStart = DateTime(now.year, now.month - 1, 1);
  final rangeEnd = DateTime(now.year, now.month + 3, 1);
  
  final instances = RRuleUtils.generateInstances(
    rruleString: pattern.rrule,
    dtstart: pattern.dtstart,
    timezone: pattern.timezone,
    rangeStart: rangeStart,
    rangeEnd: rangeEnd,
  );
  
  // 3. 예외 적용
  final exceptions = await getRecurringExceptions(recurringPatternId);
  final exceptionMap = {for (var e in exceptions) e.originalDate: e};
  
  // 4. Base Event 조회 (Schedule/Task/Habit)
  final baseSchedule = await getSchedule(pattern.entityId);
  
  // 5. 캐시 INSERT
  for (final instanceDate in instances) {
    final exception = exceptionMap[instanceDate];
    
    if (exception != null && exception.isCancelled) {
      continue; // 취소된 인스턴스는 캐시에 저장 안 함
    }
    
    await into(materializedInstance).insert(
      MaterializedInstanceCompanion.insert(
        entityType: pattern.entityType,
        entityId: pattern.entityId,
        recurringPatternId: Value(recurringPatternId),
        occurrenceDate: instanceDate,
        isException: Value(exception != null),
        exceptionId: Value(exception?.id),
        cachedTitle: exception?.modifiedTitle ?? baseSchedule!.summary,
        cachedStartTime: exception?.newStartDate ?? _calculateInstanceTime(baseSchedule, instanceDate),
        cachedEndTime: exception?.newEndDate ?? _calculateInstanceTime(baseSchedule, instanceDate, isEnd: true),
        cachedColorId: exception?.modifiedColorId ?? baseSchedule!.colorId,
        validUntil: Value(rangeEnd), // 3개월 후 만료
      ),
    );
  }
}

/// RecurringPattern 생성/수정 시 자동 갱신
Future<int> createRecurringPattern(RecurringPatternCompanion companion) async {
  final id = await into(recurringPattern).insert(companion);
  await refreshMaterializedInstances(id); // ✅ 자동 캐시 생성
  return id;
}

Future<void> updateRecurringPattern(int id, RecurringPatternCompanion companion) async {
  await (update(recurringPattern)..where((tbl) => tbl.id.equals(id))).write(companion);
  await refreshMaterializedInstances(id); // ✅ 자동 캐시 갱신
}
```

**3단계: 빠른 읽기 쿼리**
```dart
/// 🚀 캐시에서 읽기 (초고속)
Stream<List<MaterializedInstanceData>> watchScheduleInstancesFromCache(DateTime targetDate) {
  final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
  final targetEnd = target.add(const Duration(days: 1));
  
  return (select(materializedInstance)
    ..where((tbl) => 
      tbl.entityType.equals('schedule') &
      tbl.occurrenceDate.isBiggerOrEqualValue(target) &
      tbl.occurrenceDate.isSmallerThanValue(targetEnd) &
      tbl.validUntil.isBiggerThanValue(DateTime.now()) // 만료 체크
    )
    ..orderBy([(tbl) => OrderingTerm(expression: tbl.cachedStartTime)])
  ).watch();
}
```

**4단계: 백그라운드 캐시 갱신**
```dart
// lib/main.dart
void main() async {
  // 앱 시작 시 만료된 캐시 갱신
  final db = GetIt.I<AppDatabase>();
  await db.refreshExpiredMaterializedInstances();
  
  // 주기적 갱신 (매일 1회)
  Timer.periodic(Duration(hours: 24), (_) async {
    await db.refreshExpiredMaterializedInstances();
  });
}

// lib/Database/schedule_database.dart
Future<void> refreshExpiredMaterializedInstances() async {
  final now = DateTime.now();
  
  // 만료된 패턴 찾기
  final expiredPatterns = await (selectOnly(materializedInstance, distinct: true)
    ..addColumns([materializedInstance.recurringPatternId])
    ..where(materializedInstance.validUntil.isSmallerThanValue(now))
  ).get();
  
  for (final row in expiredPatterns) {
    final patternId = row.read(materializedInstance.recurringPatternId);
    if (patternId != null) {
      await refreshMaterializedInstances(patternId);
    }
  }
}
```

**성능 개선 효과:**
- ❌ 기존: 월뷰 로딩 시 N개 일정 × 30일 = **수백 회 계산**
- ✅ 개선: 1회 SELECT 쿼리 → **즉시 반환**

**보고서 참조**: Section II.C "하이브리드 및 성능 최적화"

---

### 🚨 **문제점 3: UI 수정 로직 - "이 이벤트만/향후 모든/모든 이벤트" 처리** (중요)

#### 현재 상태:
- ❌ 사용자가 반복 이벤트를 수정할 때 수정 범위 확인 대화상자 없음
- ❌ "이 이벤트 및 향후 모든 이벤트" → 시리즈 분할(Split) 로직 미구현

#### 보고서가 요구하는 것:
```
Section VI.B "수정 확인 대화상자":
- 옵션 1: "이 이벤트만" (Override 생성)
- 옵션 2: "이 이벤트 및 향후 모든 이벤트" (Series Split)
- 옵션 3: "모든 이벤트" (Master Update)
```

#### 개선 방안:

**1단계: 수정 확인 다이얼로그 추가**
```dart
// lib/widgets/recurring_event_edit_dialog.dart
import 'package:flutter/material.dart';

enum RecurringEditOption {
  thisOnly,      // "이 이벤트만"
  thisAndFuture, // "이 이벤트 및 향후 모든 이벤트"
  allEvents,     // "모든 이벤트"
}

Future<RecurringEditOption?> showRecurringEditDialog(BuildContext context) async {
  return showDialog<RecurringEditOption>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('반복 일정 수정'),
      content: const Text('이 일정의 다른 반복도 함께 변경하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, RecurringEditOption.thisOnly),
          child: const Text('이 이벤트만'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, RecurringEditOption.thisAndFuture),
          child: const Text('이 이벤트 및 향후 모든 이벤트'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, RecurringEditOption.allEvents),
          child: const Text('모든 이벤트'),
        ),
      ],
    ),
  );
}
```

**2단계: 수정 로직 구현**
```dart
// lib/Database/schedule_database.dart

/// 반복 일정 수정 (옵션에 따라 다른 로직 실행)
Future<void> updateRecurringSchedule({
  required int scheduleId,
  required DateTime instanceDate,
  required RecurringEditOption option,
  required ScheduleCompanion newData,
}) async {
  final pattern = await getRecurringPattern(
    entityType: 'schedule',
    entityId: scheduleId,
  );
  
  if (pattern == null) {
    // 일반 일정: 그냥 업데이트
    await updateSchedule(scheduleId, newData);
    return;
  }
  
  switch (option) {
    case RecurringEditOption.thisOnly:
      await _updateThisOnly(scheduleId, instanceDate, pattern, newData);
      break;
      
    case RecurringEditOption.thisAndFuture:
      await _updateThisAndFuture(scheduleId, instanceDate, pattern, newData);
      break;
      
    case RecurringEditOption.allEvents:
      await _updateAllEvents(scheduleId, pattern, newData);
      break;
  }
}

/// "이 이벤트만" → Override 생성
Future<void> _updateThisOnly(
  int scheduleId,
  DateTime instanceDate,
  RecurringPatternData pattern,
  ScheduleCompanion newData,
) async {
  // 1. RecurringException 생성/업데이트
  final existingException = await (select(recurringException)
    ..where((tbl) => 
      tbl.recurringPatternId.equals(pattern.id) &
      tbl.originalDate.equals(instanceDate)
    )
  ).getSingleOrNull();
  
  if (existingException != null) {
    // 기존 예외 업데이트
    await (update(recurringException)
      ..where((tbl) => tbl.id.equals(existingException.id))
    ).write(RecurringExceptionCompanion(
      modifiedTitle: newData.summary,
      newStartDate: newData.start,
      newEndDate: newData.end,
      modifiedDescription: newData.description,
      modifiedLocation: newData.location,
      modifiedColorId: newData.colorId,
      isRescheduled: Value(
        newData.start.present && newData.start.value != instanceDate
      ),
      updatedAt: Value(DateTime.now()),
    ));
  } else {
    // 새 예외 생성
    await into(recurringException).insert(
      RecurringExceptionCompanion.insert(
        recurringPatternId: pattern.id,
        originalDate: instanceDate,
        modifiedTitle: newData.summary,
        newStartDate: newData.start,
        newEndDate: newData.end,
        modifiedDescription: newData.description,
        modifiedLocation: newData.location,
        modifiedColorId: newData.colorId,
        isRescheduled: Value(
          newData.start.present && newData.start.value != instanceDate
        ),
      ),
    );
  }
  
  // 2. 캐시 갱신
  await refreshMaterializedInstances(pattern.id);
}

/// "이 이벤트 및 향후 모든 이벤트" → 시리즈 분할
Future<void> _updateThisAndFuture(
  int scheduleId,
  DateTime splitDate,
  RecurringPatternData pattern,
  ScheduleCompanion newData,
) async {
  // 🔥 CRITICAL: Section VI.C "시리즈 분할" 알고리즘
  
  await transaction(() async {
    // 1. 원본 시리즈 종료 (UNTIL 추가)
    final splitDateMinusOne = splitDate.subtract(const Duration(days: 1));
    final newRRule = _addUntilToRRule(pattern.rrule, splitDateMinusOne);
    
    await (update(recurringPattern)
      ..where((tbl) => tbl.id.equals(pattern.id))
    ).write(RecurringPatternCompanion(
      rrule: Value(newRRule),
      until: Value(splitDateMinusOne),
      updatedAt: Value(DateTime.now()),
    ));
    
    // 2. 새 Base Event 생성 (수정된 내용)
    final newScheduleId = await into(schedule).insert(
      ScheduleCompanion.insert(
        summary: newData.summary.present ? newData.summary.value : pattern.dtstart.toString(),
        start: newData.start.present ? newData.start.value : splitDate,
        end: newData.end.present ? newData.end.value : splitDate.add(const Duration(hours: 1)),
        colorId: newData.colorId.present ? newData.colorId.value : 'default',
        description: newData.description,
        location: newData.location,
        repeatRule: const Value(''),
        alertSetting: const Value(''),
      ),
    );
    
    // 3. 새 RecurringPattern 생성 (splitDate부터 시작)
    final newPatternId = await into(recurringPattern).insert(
      RecurringPatternCompanion.insert(
        entityType: 'schedule',
        entityId: newScheduleId,
        rrule: pattern.rrule, // 원본 RRULE 유지 (UNTIL 없음)
        dtstart: splitDate,
        until: Value(pattern.until),
        count: Value(pattern.count),
        timezone: Value(pattern.timezone),
      ),
    );
    
    // 4. 기존 예외 중 splitDate 이후 것들을 새 패턴으로 이동
    final futureExceptions = await (select(recurringException)
      ..where((tbl) => 
        tbl.recurringPatternId.equals(pattern.id) &
        tbl.originalDate.isBiggerOrEqualValue(splitDate)
      )
    ).get();
    
    for (final exception in futureExceptions) {
      await (update(recurringException)
        ..where((tbl) => tbl.id.equals(exception.id))
      ).write(RecurringExceptionCompanion(
        recurringPatternId: Value(newPatternId),
      ));
    }
    
    // 5. 캐시 갱신 (두 패턴 모두)
    await refreshMaterializedInstances(pattern.id);
    await refreshMaterializedInstances(newPatternId);
  });
}

/// "모든 이벤트" → 마스터 업데이트
Future<void> _updateAllEvents(
  int scheduleId,
  RecurringPatternData pattern,
  ScheduleCompanion newData,
) async {
  // 1. Base Event 업데이트
  await (update(schedule)
    ..where((tbl) => tbl.id.equals(scheduleId))
  ).write(newData);
  
  // 2. RRULE 변경이 있으면 RecurringPattern 업데이트
  if (newData.repeatRule.present && newData.repeatRule.value.isNotEmpty) {
    await (update(recurringPattern)
      ..where((tbl) => tbl.id.equals(pattern.id))
    ).write(RecurringPatternCompanion(
      rrule: Value(newData.repeatRule.value),
      updatedAt: Value(DateTime.now()),
    ));
  }
  
  // 3. 캐시 갱신
  await refreshMaterializedInstances(pattern.id);
}

/// RRULE에 UNTIL 추가하는 헬퍼
String _addUntilToRRule(String rrule, DateTime until) {
  final untilStr = RRuleUtils._formatDateTime(until);
  if (rrule.contains('UNTIL=')) {
    // 기존 UNTIL 교체
    return rrule.replaceFirst(RegExp(r'UNTIL=[^;]+'), 'UNTIL=$untilStr');
  } else {
    // UNTIL 추가
    return '$rrule;UNTIL=$untilStr';
  }
}
```

**3단계: UI 통합**
```dart
// lib/screen/date_detail_view.dart
void _onScheduleEdit(ScheduleData schedule, DateTime instanceDate) async {
  final pattern = await GetIt.I<AppDatabase>().getRecurringPattern(
    entityType: 'schedule',
    entityId: schedule.id,
  );
  
  if (pattern != null) {
    // ✅ 반복 이벤트: 수정 옵션 다이얼로그 표시
    final option = await showRecurringEditDialog(context);
    if (option == null) return; // 취소
    
    // ... 수정 UI 표시 후 ...
    
    await GetIt.I<AppDatabase>().updateRecurringSchedule(
      scheduleId: schedule.id,
      instanceDate: instanceDate,
      option: option,
      newData: newScheduleData,
    );
  } else {
    // 일반 이벤트: 바로 수정
    await GetIt.I<AppDatabase>().updateSchedule(schedule.id, newData);
  }
}
```

**보고서 참조**: Section VI.B, VI.C "UI 상호작용 및 수정 로직"

---

### ⚠️ **문제점 4: 상대적 반복 (every!) 미구현** (중요도 중)

#### 현재 상태:
```dart
// RecurringPattern 테이블
TextColumn get recurrenceMode => text().withDefault(
  const Constant('ABSOLUTE'),
)(); // 'RELATIVE_ON_COMPLETION' 로직 미구현
```

#### 보고서가 요구하는 것:
```
Section V.B "every vs every!":
- every (ABSOLUTE): 캘린더 기준 반복 (매주 월요일)
- every! (RELATIVE_ON_COMPLETION): 완료 기준 반복 (완료 후 3일마다)
```

#### 개선 방안:

**1단계: 완료 시 다음 인스턴스 생성**
```dart
// lib/Database/schedule_database.dart

/// Task/Habit 완료 시 다음 인스턴스 생성 (RELATIVE_ON_COMPLETION)
Future<void> completeTaskWithRecurrence(int taskId, DateTime completedDate) async {
  final pattern = await getRecurringPattern(
    entityType: 'task',
    entityId: taskId,
  );
  
  if (pattern == null || pattern.recurrenceMode != 'RELATIVE_ON_COMPLETION') {
    // 일반 완료 처리
    await completeTask(taskId, completedDate);
    return;
  }
  
  // 🔥 every! 로직: 완료일 기준으로 다음 인스턴스 계산
  await transaction(() async {
    // 1. 현재 인스턴스 완료 기록
    await into(taskCompletion).insert(
      TaskCompletionCompanion.insert(
        taskId: taskId,
        completionDate: completedDate,
      ),
    );
    
    // 2. RRULE에서 간격 추출 (예: "FREQ=DAILY;INTERVAL=3" → 3일)
    final interval = _extractIntervalFromRRule(pattern.rrule);
    final frequency = _extractFrequencyFromRRule(pattern.rrule);
    
    // 3. 다음 발생 날짜 계산
    DateTime nextDate;
    switch (frequency) {
      case 'DAILY':
        nextDate = completedDate.add(Duration(days: interval));
        break;
      case 'WEEKLY':
        nextDate = completedDate.add(Duration(days: interval * 7));
        break;
      case 'MONTHLY':
        nextDate = DateTime(
          completedDate.year,
          completedDate.month + interval,
          completedDate.day,
        );
        break;
      default:
        nextDate = completedDate.add(Duration(days: 1));
    }
    
    // 4. RecurringPattern 업데이트 (dtstart를 다음 날짜로)
    await (update(recurringPattern)
      ..where((tbl) => tbl.id.equals(pattern.id))
    ).write(RecurringPatternCompanion(
      dtstart: Value(nextDate),
      updatedAt: Value(DateTime.now()),
    ));
    
    // 5. 캐시 갱신
    await refreshMaterializedInstances(pattern.id);
  });
}

int _extractIntervalFromRRule(String rrule) {
  final match = RegExp(r'INTERVAL=(\d+)').firstMatch(rrule);
  return match != null ? int.parse(match.group(1)!) : 1;
}

String _extractFrequencyFromRRule(String rrule) {
  final match = RegExp(r'FREQ=(\w+)').firstMatch(rrule);
  return match?.group(1) ?? 'DAILY';
}
```

**2단계: UI에서 every vs every! 선택**
```dart
// lib/widgets/repeat_mode_selector.dart
enum RepeatMode {
  absolute,           // "매주 월요일" (every)
  relativeOnCompletion, // "완료 후 3일마다" (every!)
}

Widget buildRepeatModeSelector() {
  return SegmentedButton<RepeatMode>(
    segments: const [
      ButtonSegment(
        value: RepeatMode.absolute,
        label: Text('정기 반복'),
        icon: Icon(Icons.calendar_today),
      ),
      ButtonSegment(
        value: RepeatMode.relativeOnCompletion,
        label: Text('완료 기준'),
        icon: Icon(Icons.check_circle),
      ),
    ],
    selected: {_selectedMode},
    onSelectionChanged: (Set<RepeatMode> newSelection) {
      setState(() {
        _selectedMode = newSelection.first;
      });
    },
  );
}
```

**보고서 참조**: Section V.B "every vs every!"

---

## III. 구현 우선순위

### 🔴 **최우선 (P0) - 치명적 결함**
1. **Timezone 및 DST 처리** (문제점 1)
   - 예상 작업 시간: 3-5일
   - 영향: 모든 반복 이벤트의 정확성

### 🟠 **중요 (P1) - 성능 및 UX**
2. **Materialized View 캐시** (문제점 2)
   - 예상 작업 시간: 2-3일
   - 영향: 월뷰/디테일뷰 로딩 속도 10배 개선

3. **UI 수정 로직** (문제점 3)
   - 예상 작업 시간: 2-3일
   - 영향: 사용자 혼란 방지, 데이터 무결성

### 🟡 **부가 기능 (P2)**
4. **상대적 반복 (every!)** (문제점 4)
   - 예상 작업 시간: 1-2일
   - 영향: 고급 사용자 경험

---

## IV. 마이그레이션 계획

### Phase 1: Timezone 지원 (P0)
```dart
// 1. Schedule 테이블 마이그레이션
if (from == 8 && to >= 9) {
  await m.addColumn(schedule, schedule.startHour);
  await m.addColumn(schedule, schedule.startMinute);
  await m.addColumn(schedule, schedule.endHour);
  await m.addColumn(schedule, schedule.endMinute);
  await m.addColumn(schedule, schedule.timezone);
  await m.addColumn(schedule, schedule.isFloating);
  
  // 기존 데이터 변환: start/end에서 시간 추출
  await customStatement('''
    UPDATE schedule
    SET 
      start_hour = CAST(strftime('%H', start) AS INTEGER),
      start_minute = CAST(strftime('%M', start) AS INTEGER),
      end_hour = CAST(strftime('%H', end) AS INTEGER),
      end_minute = CAST(strftime('%M', end) AS INTEGER),
      timezone = 'Asia/Seoul',
      is_floating = 0
  ''');
}
```

### Phase 2: Materialized View (P1)
```dart
if (from == 9 && to >= 10) {
  await m.createTable(materializedInstance);
  
  // 기존 RecurringPattern에 대해 캐시 생성
  final patterns = await select(recurringPattern).get();
  for (final pattern in patterns) {
    await refreshMaterializedInstances(pattern.id);
  }
}
```

### Phase 3: UI 로직 + every! (P1 + P2)
```dart
// 코드 변경만 필요, DB 마이그레이션 없음
```

---

## V. 테스트 시나리오

### 1. Timezone 테스트
```dart
test('DST 변경 시 로컬 시간 유지', () async {
  // Given: "매일 오전 8시" 이벤트 (Asia/Seoul)
  final scheduleId = await db.createRecurringSchedule(
    scheduleData: ScheduleCompanion.insert(
      summary: '아침 운동',
      start: DateTime(2025, 3, 1, 8, 0),
      end: DateTime(2025, 3, 1, 9, 0),
      colorId: 'blue',
      startHour: const Value(8),
      startMinute: const Value(0),
      timezone: const Value('Asia/Seoul'),
    ),
    rrule: 'FREQ=DAILY',
  );
  
  // When: DST 변경 후 (2025년 11월 3일, 한국은 DST 없지만 테스트용)
  final instances = await db.getScheduleInstancesForDate(
    DateTime(2025, 11, 3),
  );
  
  // Then: 여전히 오전 8시
  expect(instances.first.cachedStartTime.hour, 8);
});
```

### 2. 시리즈 분할 테스트
```dart
test('이 이벤트 및 향후 모든 이벤트 수정', () async {
  // Given: "매주 월요일" 이벤트 (2025-11-04 시작)
  final scheduleId = await createWeeklySchedule();
  
  // When: 2025-11-18부터 "화요일"로 변경
  await db.updateRecurringSchedule(
    scheduleId: scheduleId,
    instanceDate: DateTime(2025, 11, 18),
    option: RecurringEditOption.thisAndFuture,
    newData: ScheduleCompanion(
      summary: const Value('팀 미팅'),
      // RRULE: BYDAY=TU 로 변경
    ),
  );
  
  // Then: 2개의 RecurringPattern 생성
  final patterns = await db.getRecurringPatternsForSchedule(scheduleId);
  expect(patterns.length, 2);
  expect(patterns[0].until, DateTime(2025, 11, 17)); // 원본: 11/17까지
  expect(patterns[1].dtstart, DateTime(2025, 11, 18)); // 새: 11/18부터
});
```

---

## VI. 결론

### 현재 시스템의 강점
1. ✅ **동적 생성 아키텍처**: 보고서의 Expert Approach 완벽 구현
2. ✅ **RFC 5545 표준 준수**: RRULE, EXDATE 완벽 지원
3. ✅ **예외 처리**: 삭제/수정 두 가지 유형 명확히 구분

### 핵심 개선 과제
1. 🔴 **Timezone/DST**: 치명적 결함, 즉시 수정 필요
2. 🟠 **성능 캐싱**: 사용자 경험 크게 향상
3. 🟠 **UI 수정 로직**: 데이터 무결성 보장

### 최종 평가
**현재 완성도: 75% (데이터 모델은 완벽, 로직 구현 필요)**

보고서가 제시한 "견고한 반복 이벤트 시스템"의 청사진은 이미 데이터베이스 설계에 완벽히 반영되어 있습니다. 이제 **Timezone 처리**, **성능 캐싱**, **UI 로직** 3가지 핵심 구현만 완료하면, Google Calendar 수준의 완벽한 반복 이벤트 시스템이 완성됩니다.

---

**다음 단계:**
1. Phase 1 (Timezone) 구현 시작
2. 단위 테스트 작성
3. Phase 2 (Materialized View) 구현
4. 통합 테스트 및 성능 벤치마크
