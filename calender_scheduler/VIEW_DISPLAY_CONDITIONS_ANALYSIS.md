# 월뷰/디테일뷰 표시 조건 개선 분석

## I. 현재 구현 vs 이상적 구현 갭 분석

### 1. 🔴 심각한 누락 (즉시 수정 필요)

#### 1.1 RELATIVE_ON_COMPLETION (every!) 작업 표시 로직 누락
**문제점**:
- 현재: `watchTasksWithRepeat()`는 ABSOLUTE/RELATIVE 구분 없이 모든 반복 작업 표시
- 이상: RELATIVE_ON_COMPLETION 작업은 **완료 후에만** 다음 날짜로 이동해야 함

**현재 동작** (잘못됨):
```
Task: "3일에 한 번 운동" (every! 3 days, RELATIVE_ON_COMPLETION)
생성일: 2025-01-01
RRULE: FREQ=DAILY;INTERVAL=3

현재 표시:
- 1/1, 1/4, 1/7, 1/10... (캘린더에 미리 표시됨) ← 잘못됨!
```

**이상적 동작**:
```
Task: "3일에 한 번 운동" (every! 3 days, RELATIVE_ON_COMPLETION)
생성일: 2025-01-01

1월 1일: Task 표시 (executionDate = 1/1)
사용자가 1월 2일에 완료 → executionDate가 1/5로 자동 업데이트
1월 5일: Task 표시 (executionDate = 1/5)
사용자가 1월 8일에 완료 → executionDate가 1/11로 자동 업데이트
...
```

**파일**: `lib/Database/schedule_database.dart`
**함수**: `watchTasksWithRepeat()`, `watchHabitsWithRepeat()`

**수정 필요사항**:
```dart
// 현재 코드 (잘못됨):
if (pattern != null) {
  // ABSOLUTE/RELATIVE 구분 없이 RRULE 확장
  final dates = RRuleUtils.generateInstancesFromPattern(...);
}

// 수정 후:
if (pattern != null) {
  if (pattern.recurrenceMode == 'RELATIVE_ON_COMPLETION') {
    // every! 모드: 현재 executionDate만 표시
    // RRULE 확장 하지 않음
    if (task.executionDate == targetDate) {
      // 표시
    }
  } else {
    // every 모드: RRULE 확장
    final dates = RRuleUtils.generateInstancesFromPattern(...);
  }
}
```

---

#### 1.2 연체(Overdue) 작업 표시 로직 누락
**문제점**:
- 현재: 연체된 작업이 디테일뷰에서 사라짐
- 이상: Google Tasks처럼 "보류 중인 작업" 섹션에 표시

**파일**: `lib/screen/date_detail_view.dart`
**함수**: `_buildTaskSection()`

**수정 필요사항**:
```dart
// 추가할 섹션:
Widget _buildOverdueSection(DateTime targetDate) {
  return FutureBuilder<OverdueTaskStats>(
    future: getOverdueTaskStats(db, referenceDate: targetDate),
    builder: (context, snapshot) {
      if (snapshot.data?.count == 0) return SizedBox.shrink();

      return Column(
        children: [
          Text('보류 중인 작업 (${snapshot.data?.count}개)'),
          // 연체된 작업 목록
        ],
      );
    },
  );
}
```

---

### 2. ⚠️ 중요한 개선 (성능/정확성)

#### 2.1 시간 보존 (preserveTime) 누락
**문제점**:
- 반복 일정 인스턴스 생성 시 원본 시간이 손실될 수 있음
- `RRuleUtils.generateInstances(..., preserveTime: true)` 누락

**파일**: `lib/Database/schedule_database.dart`
**함수**: `watchSchedulesWithRepeat()`

**현재 상태** (이미 수정됨):
```dart
// ✅ 이미 preserveTime: true 추가됨 (system-reminder에서 확인)
final dates = RRuleUtils.generateInstances(
  rruleString: pattern.rrule,
  dtstart: pattern.dtstart,
  rangeStart: rangeStart,
  rangeEnd: rangeEnd,
  preserveTime: true, // ✅ 원본 시간 보존
);
```

**상태**: ✅ 이미 수정 완료

---

#### 2.2 완료 확인 우선순위 불명확
**문제점**:
- 일반 작업 vs 반복 작업의 완료 확인 로직이 섞여 있음
- 우선순위가 명확하지 않음

**파일**: `lib/Database/schedule_database.dart`
**함수**: `watchTasksWithRepeat()`, `watchSchedulesWithRepeat()`

**수정 필요사항**:
```dart
// 명확한 우선순위 로직 추가
bool isTaskCompleted(TaskData task, DateTime targetDate) {
  // 1순위: 반복 작업 (repeatRule이 있음)
  if (task.repeatRule.isNotEmpty) {
    // TaskCompletion 테이블에서 확인
    return taskCompletions.any((c) =>
      c.taskId == task.id &&
      isSameDay(c.completedDate, targetDate)
    );
  }

  // 2순위: 일반 작업
  return task.completed;
}
```

---

#### 2.3 예외(Exception) 처리 시 날짜 이동 누락
**문제점**:
- `RecurringException`의 `newStartDate`가 다른 날짜로 이동한 경우 처리 누락
- FROM 날짜에서는 제거, TO 날짜에서는 추가해야 함

**파일**: `lib/Database/schedule_database.dart`
**함수**: `watchTasksWithRepeat()`

**현재 코드**:
```dart
// 예외 처리 (누락된 부분 있음)
if (exception != null && exception.isCancelled) {
  continue; // 취소된 인스턴스 제외
}

// ❌ 날짜 이동 처리 누락!
```

**수정 필요사항**:
```dart
// 1. FROM 날짜에서 제외
if (exception != null && exception.newStartDate != null) {
  final newDate = DateTime(
    exception.newStartDate!.year,
    exception.newStartDate!.month,
    exception.newStartDate!.day,
  );

  if (!isSameDay(newDate, date)) {
    // 다른 날짜로 이동 → 현재 날짜에서 제외
    continue;
  }
}

// 2. TO 날짜에서 추가 (별도 쿼리 필요)
final movedToThisDate = await _getMovedExceptionsToDate(targetDate);
```

---

### 3. 📝 명확성 개선 (코드 가독성)

#### 3.1 완료 섹션 쿼리 중복
**문제점**:
- `watchCompletedSchedulesByDay()`, `watchCompletedTasksByDay()`, `watchCompletedHabitsByDay()`가 유사한 로직 반복

**개선 방향**:
- 공통 로직 추출
- 제네릭 함수로 통합 가능

---

#### 3.2 날짜 정규화 로직 분산
**문제점**:
- 날짜를 00:00:00으로 정규화하는 로직이 여러 곳에 중복

**개선 방향**:
```dart
// 유틸리티 함수 추가
DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
```

---

## II. 수정 계획 우선순위

### 🔥 Phase 1: 즉시 수정 (기능 오류)
1. ✅ **RELATIVE_ON_COMPLETION 작업 표시 로직 수정**
   - 파일: `schedule_database.dart`
   - 함수: `watchTasksWithRepeat()`, `watchHabitsWithRepeat()`
   - 영향: Task, Habit

2. ✅ **연체 작업 표시 섹션 추가**
   - 파일: `date_detail_view.dart`
   - 함수: `_buildOverdueSection()` 추가
   - 영향: Task

3. ✅ **예외 날짜 이동 처리 추가**
   - 파일: `schedule_database.dart`
   - 함수: `watchTasksWithRepeat()`, `watchSchedulesWithRepeat()`
   - 영향: Schedule, Task

### 📊 Phase 2: 정확성 개선
4. ✅ **완료 확인 우선순위 명확화**
   - 파일: `schedule_database.dart`
   - 함수: 모든 watch 함수
   - 영향: Schedule, Task, Habit

5. ✅ **날짜 정규화 유틸리티 추가**
   - 파일: 새 파일 `lib/utils/date_utils.dart`
   - 함수: `normalizeDate()`, `isSameDay()`
   - 영향: 전체

### 🎨 Phase 3: 리팩토링 (선택)
6. 완료 섹션 쿼리 통합
7. 코드 중복 제거

---

## III. 구체적 수정 내용

### 수정 1: RELATIVE_ON_COMPLETION 작업 표시 로직

**파일**: `lib/Database/schedule_database.dart`

**Before** (현재 코드):
```dart
Future<List<TaskWithCompletion>> watchTasksWithRepeat(DateTime targetDate) async {
  final tasks = await watchTasks().first;
  final result = <TaskWithCompletion>[];

  for (final task in tasks) {
    final pattern = await getRecurringPattern(...);

    if (pattern != null) {
      // ❌ ABSOLUTE/RELATIVE 구분 없음
      final dates = RRuleUtils.generateInstancesFromPattern(...);

      for (final date in dates) {
        // 모든 인스턴스 표시
      }
    }
  }
}
```

**After** (수정 후):
```dart
Future<List<TaskWithCompletion>> watchTasksWithRepeat(DateTime targetDate) async {
  final tasks = await watchTasks().first;
  final result = <TaskWithCompletion>[];

  for (final task in tasks) {
    final pattern = await getRecurringPattern(...);

    if (pattern != null) {
      // ✅ RELATIVE_ON_COMPLETION 구분
      if (pattern.recurrenceMode == 'RELATIVE_ON_COMPLETION') {
        // every! 모드: 현재 executionDate만 표시
        if (task.executionDate != null &&
            isSameDay(task.executionDate!, targetDate)) {
          // 완료 확인
          final isCompleted = await _isTaskCompletedOnDate(task.id, targetDate);
          if (!isCompleted) {
            result.add(TaskWithCompletion(task: task, isCompleted: false));
          }
        }
      } else {
        // ABSOLUTE 모드: RRULE 확장
        final dates = RRuleUtils.generateInstancesFromPattern(...);

        for (final date in dates) {
          // 기존 로직
        }
      }
    }
  }
}
```

---

### 수정 2: 연체 작업 표시 섹션 추가

**파일**: `lib/screen/date_detail_view.dart`

**추가할 위젯**:
```dart
Widget _buildOverdueSection(BuildContext context, DateTime targetDate) {
  return FutureBuilder<List<TaskData>>(
    future: getOverdueTasks(
      _database,
      referenceDate: targetDate,
      daysBack: 30, // 최근 30일간 연체
    ),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return SizedBox.shrink();
      }

      final overdueTasks = snapshot.data!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '보류 중인 작업 (${overdueTasks.length}개)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
          ...overdueTasks.map((task) {
            final daysOverdue = getDaysOverdue(task, referenceDate: targetDate);
            return TaskCard(
              task: task,
              badge: '$daysOverdue일 지연',
              badgeColor: Colors.red,
            );
          }),
        ],
      );
    },
  );
}
```

---

### 수정 3: 예외 날짜 이동 처리

**파일**: `lib/Database/schedule_database.dart`

**추가할 함수**:
```dart
/// 다른 날짜에서 이 날짜로 이동한 예외 인스턴스 조회
Future<List<RecurringExceptionData>> _getMovedExceptionsToDate(
  DateTime targetDate,
  String entityType,
) async {
  final targetNormalized = DateTime(
    targetDate.year,
    targetDate.month,
    targetDate.day,
  );

  final query = select(recurringException).join([
    innerJoin(
      recurringPattern,
      recurringPattern.id.equalsExp(recurringException.recurringPatternId),
    ),
  ])
    ..where(
      recurringPattern.entityType.equals(entityType) &
      recurringException.newStartDate.equals(targetNormalized) &
      recurringException.isRescheduled.equals(true)
    );

  final results = await query.get();
  return results.map((row) => row.readTable(recurringException)).toList();
}
```

**기존 로직 수정**:
```dart
// watchTasksWithRepeat() 내부
for (final date in dates) {
  final exception = exceptionMap[date];

  // ✅ 날짜 이동 처리 추가
  if (exception != null && exception.newStartDate != null) {
    final newDate = DateTime(
      exception.newStartDate!.year,
      exception.newStartDate!.month,
      exception.newStartDate!.day,
    );

    if (!isSameDay(newDate, date)) {
      // 다른 날짜로 이동 → 현재 날짜에서 제외
      continue;
    }
  }

  // 기존 로직...
}

// ✅ 이 날짜로 이동한 인스턴스 추가
final movedHere = await _getMovedExceptionsToDate(targetDate, 'task');
for (final exception in movedHere) {
  // 원본 작업 조회 후 추가
}
```

---

### 수정 4: 날짜 정규화 유틸리티

**새 파일**: `lib/utils/date_utils.dart`

```dart
/// 날짜를 00:00:00으로 정규화
DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// 두 날짜가 같은 날인지 확인
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 날짜 범위 생성 (start ~ end)
List<DateTime> dateRange(DateTime start, DateTime end) {
  final days = <DateTime>[];
  var current = normalizeDate(start);
  final endNormalized = normalizeDate(end);

  while (current.isBefore(endNormalized) || current.isAtSameMomentAs(endNormalized)) {
    days.add(current);
    current = current.add(Duration(days: 1));
  }

  return days;
}
```

---

## IV. 테스트 시나리오

### 시나리오 1: RELATIVE_ON_COMPLETION 작업 표시
```
Given: "3일에 한 번 운동" Task (every! 3 days, executionDate = 1/1)
When: 디테일뷰에서 1/4 확인
Then: Task가 표시되지 않음 (executionDate = 1/1이므로)

When: 1/1에 완료 처리
Then: executionDate가 1/4로 업데이트

When: 디테일뷰에서 1/4 확인
Then: Task가 표시됨
```

### 시나리오 2: 연체 작업 표시
```
Given: "보고서 제출" Task (executionDate = 12/20)
When: 12/25 디테일뷰 확인
Then: "보류 중인 작업" 섹션에 "5일 지연" 배지와 함께 표시
```

### 시나리오 3: 예외 날짜 이동
```
Given: "매주 월요일 회의" Schedule (RRULE: WEEKLY, BYDAY=MO)
When: 1/6(월) 인스턴스를 1/7(화)로 이동 (RecurringException 생성)
Then: 1/6 디테일뷰에서 회의 표시 안 됨
And: 1/7 디테일뷰에서 회의 표시됨
```

---

## V. 영향 분석

### 영향받는 파일
1. `lib/Database/schedule_database.dart` - 주요 로직 수정
2. `lib/screen/date_detail_view.dart` - UI 추가
3. `lib/utils/date_utils.dart` - 새 파일
4. `lib/utils/overdue_task_helper.dart` - 이미 생성됨

### 영향받는 기능
- ✅ Task 디테일뷰 표시
- ✅ Habit 디테일뷰 표시
- ⚠️ 월뷰 (최소 영향)
- ✅ 완료 섹션

### 호환성
- ✅ 기존 ABSOLUTE 작업/습관: 영향 없음
- ✅ 기존 일반 작업/습관: 영향 없음
- ✅ 신규 RELATIVE 작업/습관: 정상 작동

---

## VI. 다음 단계

1. **사용자 확인**: 위 수정 계획 승인
2. **Phase 1 구현**: RELATIVE 로직 + 연체 섹션 + 예외 이동
3. **테스트**: 시나리오 1-3 검증
4. **Phase 2 구현**: 완료 우선순위 + 날짜 유틸리티
5. **통합 테스트**: 전체 시나리오 검증
6. **빌드 및 배포**
