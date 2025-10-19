import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import '../model/schedule.dart';
import '../model/entities.dart'; // ✅ Task, Habit, HabitCompletion 추가
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';

//part '../const/color.dart'; //part파일은 완전히 다른 파일을 하나의 파일 처럼 관리를 할 수 있ㄱ 된다.
//즉, 데이터베이스 파일과 color.dart를 하나의 파일처럼 관리를 하라는 것이다.
//그래서 우리가 color.dart에 있는 값을 임포트 하지 않아도 쓸 수 있다.
part 'schedule_database.g.dart'; //g.을 붙이는 건 생성된 파일이라는 의미를 전달한다.
//g.를 붙여주면 즉, 자동으로 설치가 되거나 실행이 될 때 자동으로 설치도도록 한다.

// ✅ 7개 테이블: Schedule, Task, Habit, HabitCompletion, DailyCardOrder, AudioContents, TranscriptLines
// ⚠️ AudioProgress 제거됨 → AudioContents에 재생 상태 통합
@DriftDatabase(
  tables: [
    Schedule,
    Task,
    Habit,
    HabitCompletion,
    DailyCardOrder,
    AudioContents,
    TranscriptLines,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // ✅ 테스트용 생성자 추가
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  // ==================== 조회 함수 ====================

  /// 전체 일정을 조회하는 함수 (일회성 조회)
  /// 이거를 설정하고 → select(schedule)로 테이블 전체를 선택해서
  /// 이거를 해서 → get()으로 데이터를 가져온다
  Future<List<ScheduleData>> getSchedules() async {
    final result = await select(schedule).get();
    print('📊 [DB] getSchedules 실행 완료: ${result.length}개 일정 조회됨');
    return result;
  }

  /// 특정 날짜의 일정만 조회하는 함수 (메모리 효율적)
  /// 이거를 설정하고 → 선택한 날짜의 00:00부터 다음날 00:00 전까지의 범위를 계산해서
  /// 이거를 해서 → 해당 구간과 겹치는 일정만 DB에서 필터링한다
  /// 이거는 이래서 → 메모리 부담 없이 필요한 데이터만 가져온다
  /// 이거라면 → 월뷰나 디테일뷰에서 특정 날짜만 조회할 때 사용한다
  Future<List<ScheduleData>> getSchedulesByDate(DateTime selectedDate) async {
    final dayStart = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final dayEnd = dayStart.add(const Duration(days: 1));

    final result =
        await (select(schedule)
              ..where((tbl) => tbl.start.isBiggerThanValue(dayStart))
              ..where((tbl) => tbl.start.isSmallerThanValue(dayEnd)))
            .get();

    print(
      '📅 [DB] getSchedulesByDate 실행 완료: ${selectedDate.toString().split(' ')[0]} → ${result.length}개 일정',
    );
    return result;
  }

  /// 전체 일정을 실시간으로 관찰하는 함수 (Stream 반환)
  /// 이거는 이래서 → DB가 변경될 때마다 자동으로 새로운 데이터를 전달한다
  /// 이거라면 → UI에서 StreamBuilder로 받아서 자동 갱신이 가능하다
  /// 이거를 설정하고 → orderBy로 시작시간 오름차순, 같으면 제목 오름차순으로 정렬한다
  Stream<List<ScheduleData>> watchSchedules() {
    print('👀 [DB] watchSchedules 스트림 시작 - 실시간 관찰 중 (start↑ → summary↑ 정렬)');
    return (select(schedule)..orderBy([
          (tbl) => OrderingTerm(expression: tbl.start, mode: OrderingMode.asc),
          (tbl) =>
              OrderingTerm(expression: tbl.summary, mode: OrderingMode.asc),
        ]))
        .watch();
  }

  /// 특정 날짜의 일정만 조회하는 함수 (일회성 조회)
  /// 이거를 설정하고 → 선택한 날짜의 00:00부터 다음날 00:00 전까지의 범위를 계산해서
  /// 이거를 해서 → 해당 구간과 겹치는 일정만 필터링한다
  /// 이거는 이래서 → 구글 캘린더처럼 종일/다일 이벤트도 정확히 포함된다
  Future<List<ScheduleData>> getByDay(DateTime selected) async {
    final dayStart = DateTime(selected.year, selected.month, selected.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final result =
        await (select(schedule)..where(
              (tbl) =>
                  tbl.end.isBiggerThanValue(dayStart) &
                  tbl.start.isSmallerThanValue(dayEnd),
            ))
            .get();

    print(
      '📅 [DB] getByDay 실행 완료: ${selected.toString().split(' ')[0]} → ${result.length}개 일정',
    );
    return result;
  }

  /// 특정 날짜의 일정을 실시간으로 관찰하는 함수 (Stream 반환)
  /// 이거라면 → DateDetailView에서 사용해 해당 날짜 일정만 실시간 갱신한다
  /// 이거를 설정하고 → orderBy로 시작시간 오름차순, 같으면 제목 오름차순으로 정렬한다
  Stream<List<ScheduleData>> watchByDay(DateTime selected) {
    final dayStart = DateTime(selected.year, selected.month, selected.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    print(
      '👀 [DB] watchByDay 스트림 시작: ${selected.toString().split(' ')[0]} - 실시간 관찰 중 (start↑ → summary↑ 정렬)',
    );
    return (select(schedule)
          ..where(
            (tbl) =>
                tbl.end.isBiggerThanValue(dayStart) &
                tbl.start.isSmallerThanValue(dayEnd),
          )
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.start, mode: OrderingMode.asc),
            (tbl) =>
                OrderingTerm(expression: tbl.summary, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  // ==================== 생성 함수 ====================

  /// 새로운 일정을 생성하는 함수
  /// 이거를 설정하고 → ScheduleCompanion 데이터를 받아서
  /// 이거를 해서 → into(schedule)로 테이블에 삽입하고
  /// 이거는 이래서 → 삽입된 행의 id를 int로 반환한다 (자동 생성)
  Future<int> createSchedule(ScheduleCompanion data) async {
    final id = await into(schedule).insert(data);
    print('✅ [DB] createSchedule 실행 완료: ID=$id로 일정 생성됨');
    print('   → 제목: ${data.summary.value}');
    print('   → 시작: ${data.start.value}');
    print('   → 종료: ${data.end.value}');
    return id;
  }

  // ==================== 수정 함수 ====================

  /// 기존 일정을 수정하는 함수
  /// 이거를 설정하고 → ScheduleCompanion에 id와 변경할 필드를 담아서
  /// 이거를 해서 → update로 해당 id의 행을 업데이트한다
  /// 이거라면 → 성공 시 true를 반환한다
  Future<bool> updateSchedule(ScheduleCompanion data) async {
    final result = await update(schedule).replace(data);
    print('🔄 [DB] updateSchedule 실행 완료: ${result ? "성공" : "실패"}');
    if (result) {
      print('   → 수정된 ID: ${data.id.value}');
    }
    return result;
  }

  // ==================== 삭제 함수 ====================

  /// 특정 일정을 삭제하는 함수
  /// 이거를 설정하고 → 삭제할 일정의 id를 받아서
  /// 이거를 해서 → delete로 해당 id의 행을 삭제한다
  /// 이거는 이래서 → 삭제된 행의 개수를 반환한다 (보통 1 또는 0)
  Future<int> deleteSchedule(int id) async {
    final count = await (delete(
      schedule,
    )..where((tbl) => tbl.id.equals(id))).go();
    print('🗑️ [DB] deleteSchedule 실행 완료: ID=$id → ${count}개 행 삭제됨');
    return count;
  }

  // ==================== 완료 처리 함수 ====================

  /// 특정 일정을 완료 처리하는 함수 (현재는 삭제로 구현)
  /// 이거를 설정하고 → 완료할 일정의 id를 받아서
  /// 이거를 해서 → 일정을 삭제한다 (나중에 완료 상태 컬럼 추가 시 업데이트로 변경 가능)
  /// 이거는 이래서 → 완료된 일정이 목록에서 사라진다
  /// 이거라면 → Slidable에서 오른쪽 스와이프로 완료 처리할 때 사용한다
  Future<int> completeSchedule(int id) async {
    // TODO: 나중에 Schedule 테이블에 'isCompleted' 컬럼 추가 후 아래 코드로 변경
    // final count = await (update(schedule)
    //   ..where((tbl) => tbl.id.equals(id)))
    //   .write(ScheduleCompanion(isCompleted: Value(true)));

    // 현재는 완료 = 삭제로 구현
    final count = await deleteSchedule(id);
    print('✅ [DB] completeSchedule 실행 완료: ID=$id → 완료 처리됨 (삭제)');
    return count;
  }

  // ==================== Task (할일) 함수 ====================

  /// 할일 생성
  /// 이거를 설정하고 → TaskCompanion 데이터를 받아서
  /// 이거를 해서 → into(task).insert()로 DB에 저장한다
  Future<int> createTask(TaskCompanion data) async {
    final id = await into(task).insert(data);
    print('✅ [DB] createTask 실행 완료: ID=$id로 할일 생성됨');
    print('   → 제목: ${data.title.value}');
    return id;
  }

  /// 할일 목록 조회 (스트림)
  /// 이거를 설정하고 → task 테이블을 watch()로 구독해서
  /// 이거를 해서 → 실시간으로 할일 목록을 받는다
  Stream<List<TaskData>> watchTasks() {
    print('👀 [DB] watchTasks 스트림 시작 - 실시간 관찰 중');
    return (select(task)..orderBy([
          (tbl) => OrderingTerm(expression: tbl.completed), // 미완료 먼저
          (tbl) => OrderingTerm(expression: tbl.dueDate), // 마감일 순
          (tbl) => OrderingTerm(expression: tbl.title), // 제목 순
        ]))
        .watch();
  }

  /// 할일 완료 처리
  /// 이거를 설정하고 → completed를 true로 업데이트하고
  /// 이거를 해서 → completedAt에 현재 시간을 기록한다
  Future<int> completeTask(int id) async {
    final now = DateTime.now();
    final count = await (update(task)..where((tbl) => tbl.id.equals(id))).write(
      TaskCompanion(completed: const Value(true), completedAt: Value(now)),
    );
    print('✅ [DB] completeTask 실행 완료: ID=$id → 완료 처리됨');
    return count;
  }

  /// 할일 완료 해제
  /// 이거를 설정하고 → completed를 false로 업데이트하고
  /// 이거를 해서 → completedAt을 null로 초기화한다
  Future<int> uncompleteTask(int id) async {
    final count = await (update(task)..where((tbl) => tbl.id.equals(id))).write(
      const TaskCompanion(completed: Value(false), completedAt: Value(null)),
    );
    print('🔄 [DB] uncompleteTask 실행 완료: ID=$id → 완료 해제됨');
    return count;
  }

  /// 할일 삭제
  /// 이거를 설정하고 → 특정 id의 할일을 삭제해서
  /// 이거를 해서 → DB에서 영구 제거한다
  Future<int> deleteTask(int id) async {
    final count = await (delete(task)..where((tbl) => tbl.id.equals(id))).go();
    print('🗑️ [DB] deleteTask 실행 완료: ID=$id → ${count}개 행 삭제됨');
    return count;
  }

  // ==================== Habit (습관) 함수 ====================

  /// 습관 생성
  /// 이거를 설정하고 → HabitCompanion 데이터를 받아서
  /// 이거를 해서 → into(habit).insert()로 DB에 저장한다
  Future<int> createHabit(HabitCompanion data) async {
    final id = await into(habit).insert(data);
    print('✅ [DB] createHabit 실행 완료: ID=$id로 습관 생성됨');
    print('   → 제목: ${data.title.value}');
    return id;
  }

  /// 습관 목록 조회 (스트림)
  /// 이거를 설정하고 → habit 테이블을 watch()로 구독해서
  /// 이거를 해서 → 실시간으로 습관 목록을 받는다
  Stream<List<HabitData>> watchHabits() {
    print('👀 [DB] watchHabits 스트림 시작 - 실시간 관찰 중');
    return (select(habit)..orderBy([
          (tbl) =>
              OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  /// 습관 완료 기록 추가
  /// 이거를 설정하고 → 특정 날짜에 습관을 완료했다고 기록해서
  /// 이거를 해서 → HabitCompletion 테이블에 저장한다
  Future<int> recordHabitCompletion(int habitId, DateTime date) async {
    final companion = HabitCompletionCompanion.insert(
      habitId: habitId,
      completedDate: date,
      createdAt: DateTime.now(),
    );
    final id = await into(habitCompletion).insert(companion);
    print('✅ [DB] recordHabitCompletion 실행 완료: habitId=$habitId, date=$date');
    return id;
  }

  /// 특정 날짜의 습관 완료 기록 조회
  /// 이거를 설정하고 → 특정 날짜의 완료 기록을 조회해서
  /// 이거를 해서 → 오늘 완료한 습관 목록을 확인한다
  Future<List<HabitCompletionData>> getHabitCompletionsByDate(
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result =
        await (select(habitCompletion)..where(
              (tbl) =>
                  tbl.completedDate.isBiggerOrEqualValue(startOfDay) &
                  tbl.completedDate.isSmallerOrEqualValue(endOfDay),
            ))
            .get();

    print(
      '📊 [DB] getHabitCompletionsByDate 실행 완료: $date → ${result.length}개 기록',
    );
    return result;
  }

  /// 습관 삭제
  /// 이거를 설정하고 → 특정 id의 습관을 삭제해서
  /// 이거를 해서 → DB에서 영구 제거한다
  Future<int> deleteHabit(int id) async {
    // 1. 습관 완료 기록도 함께 삭제
    await (delete(
      habitCompletion,
    )..where((tbl) => tbl.habitId.equals(id))).go();

    // 2. 습관 삭제
    final count = await (delete(habit)..where((tbl) => tbl.id.equals(id))).go();
    print('🗑️ [DB] deleteHabit 실행 완료: ID=$id → ${count}개 행 삭제됨 (완료 기록 포함)');
    return count;
  }

  /// 습관 수정
  /// 이거를 설정하고 → HabitCompanion에 id와 변경할 필드를 담아서
  /// 이거를 해서 → update로 해당 id의 행을 업데이트한다
  /// 이거라면 → 성공 시 true를 반환한다
  Future<bool> updateHabit(HabitCompanion data) async {
    final result = await update(habit).replace(data);
    print('🔄 [DB] updateHabit 실행 완료: ${result ? "성공" : "실패"}');
    if (result) {
      print('   → 수정된 ID: ${data.id.value}');
    }
    return result;
  }

  // ==================== DailyCardOrder (날짜별 카드 순서) 함수 ====================

  /// 특정 날짜의 카드 순서 조회 (실시간 스트림)
  /// 이거를 설정하고 → date를 받아서 해당 날짜의 모든 카드 순서를 실시간으로 가져오고
  /// 이거를 해서 → sortOrder 기준으로 정렬된 DailyCardOrderData를 반환한다
  /// 이거는 이래서 → 사용자가 설정한 커스텀 순서를 복원할 수 있다
  Stream<List<DailyCardOrderData>> watchDailyCardOrder(DateTime date) {
    // 이거를 설정하고 → 날짜를 00:00:00으로 정규화해서
    // 이거를 해서 → 시간 상관없이 같은 날짜로 인식되도록 한다
    final normalizedDate = DateTime(date.year, date.month, date.day);
    print(
      '👀 [DB] watchDailyCardOrder 스트림 시작: ${normalizedDate.toString().split(' ')[0]}',
    );

    // 이거를 설정하고 → dailyCardOrder 테이블에서 해당 날짜 필터링해서
    // 이거를 해서 → sortOrder 오름차순으로 정렬하고
    // 이거는 이래서 → 실시간으로 순서 변경을 감지한다
    return (select(dailyCardOrder)
          ..where((tbl) => tbl.date.equals(normalizedDate))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.sortOrder, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  /// 날짜별 카드 순서 저장 (전체 교체)
  /// 이거를 설정하고 → 날짜와 UnifiedListItem 리스트를 받아서
  /// 이거를 해서 → 기존 순서를 삭제하고 새로운 순서로 저장한다
  /// 이거는 이래서 → 드래그앤드롭 재정렬 시 호출된다
  /// 이거라면 → 트랜잭션으로 원자성을 보장한다
  Future<void> saveDailyCardOrder(
    DateTime date,
    List<Map<String, dynamic>> items,
  ) async {
    // 이거를 설정하고 → 날짜를 00:00:00으로 정규화해서
    final normalizedDate = DateTime(date.year, date.month, date.day);
    print(
      '💾 [DB] saveDailyCardOrder 시작: ${normalizedDate.toString().split(' ')[0]}',
    );

    // 이거를 설정하고 → transaction()으로 묶어서
    // 이거를 해서 → 삭제와 삽입이 하나의 단위로 실행되고
    // 이거는 이래서 → 에러 발생 시 자동 롤백된다
    await transaction(() async {
      // 1️⃣ 기존 순서 삭제
      // 이거를 설정하고 → 해당 날짜의 모든 순서 데이터를 삭제해서
      // 이거를 해서 → 깨끗한 상태에서 새로 저장한다
      final deleteCount = await (delete(
        dailyCardOrder,
      )..where((tbl) => tbl.date.equals(normalizedDate))).go();
      print('  → [1/2] 기존 순서 삭제 완료: ${deleteCount}개 레코드');

      // 2️⃣ 새로운 순서 삽입
      // 이거를 설정하고 → items를 순회하면서
      // 이거를 해서 → 각 카드의 순서 정보를 DB에 저장한다
      int insertCount = 0;
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final type = item['type'] as String;
        final id = item['id'] as int?;

        // 이거를 설정하고 → divider, completed는 제외해서
        // 이거를 해서 → 실제 카드 데이터만 저장한다
        // 이거는 이래서 → 점선이나 완료 섹션은 동적으로 삽입되기 때문
        if (type == 'divider' || type == 'completed' || id == null) {
          continue;
        }

        // 이거를 설정하고 → DailyCardOrderCompanion을 생성해서
        // 이거를 해서 → 날짜, 타입, ID, 순서를 DB에 저장한다
        await into(dailyCardOrder).insert(
          DailyCardOrderCompanion(
            date: Value(normalizedDate),
            cardType: Value(type),
            cardId: Value(id),
            sortOrder: Value(i),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
        insertCount++;
      }

      print('  → [2/2] 새로운 순서 저장 완료: ${insertCount}개 카드');
      print('✅ [DB] saveDailyCardOrder 완료');
    });
  }

  /// 특정 카드의 순서만 업데이트 (단일 업데이트)
  /// 이거를 설정하고 → 하나의 카드만 순서를 변경할 때 사용해서
  /// 이거를 해서 → 전체 삭제/삽입 없이 효율적으로 업데이트한다
  /// 이거는 이래서 → 미세 조정 시 성능이 좋다
  Future<void> updateCardOrder(
    DateTime date,
    String cardType,
    int cardId,
    int newOrder,
  ) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    print(
      '🔄 [DB] updateCardOrder: $cardType-$cardId → order=$newOrder (날짜: ${normalizedDate.toString().split(' ')[0]})',
    );

    // 이거를 설정하고 → update로 특정 카드만 찾아서
    // 이거를 해서 → sortOrder와 updatedAt만 업데이트한다
    final count =
        await (update(dailyCardOrder)..where(
              (tbl) =>
                  tbl.date.equals(normalizedDate) &
                  tbl.cardType.equals(cardType) &
                  tbl.cardId.equals(cardId),
            ))
            .write(
              DailyCardOrderCompanion(
                sortOrder: Value(newOrder),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );

    print('✅ [DB] updateCardOrder 완료: ${count}개 행 업데이트됨');
  }

  /// 특정 날짜의 카드 순서 초기화 (삭제)
  /// 이거를 설정하고 → 날짜별 커스텀 순서를 리셋할 때 사용해서
  /// 이거를 해서 → 해당 날짜의 모든 순서 데이터를 삭제하고
  /// 이거는 이래서 → 기본 순서(createdAt)로 돌아간다
  Future<int> resetDailyCardOrder(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    print(
      '🔄 [DB] resetDailyCardOrder: ${normalizedDate.toString().split(' ')[0]}',
    );

    // 이거를 설정하고 → delete로 해당 날짜의 모든 순서를 삭제해서
    // 이거를 해서 → 커스텀 순서를 제거한다
    final count = await (delete(
      dailyCardOrder,
    )..where((tbl) => tbl.date.equals(normalizedDate))).go();

    print('✅ [DB] resetDailyCardOrder 완료: ${count}개 순서 리셋됨');
    return count;
  }

  /// 특정 카드 삭제 시 모든 날짜의 순서에서 제거
  /// 이거를 설정하고 → Schedule/Task/Habit 삭제 시 함께 호출해서
  /// 이거를 해서 → 모든 날짜의 DailyCardOrder에서 해당 카드를 제거하고
  /// 이거는 이래서 → 고아 레코드(orphan record)를 방지한다
  Future<int> deleteCardFromAllOrders(String cardType, int cardId) async {
    print('🗑️ [DB] deleteCardFromAllOrders: $cardType-$cardId (모든 날짜)');

    // 이거를 설정하고 → cardType과 cardId로 필터링해서
    // 이거를 해서 → 모든 날짜의 해당 카드 순서를 삭제한다
    final count =
        await (delete(dailyCardOrder)..where(
              (tbl) =>
                  tbl.cardType.equals(cardType) & tbl.cardId.equals(cardId),
            ))
            .go();

    print('✅ [DB] deleteCardFromAllOrders 완료: ${count}개 레코드 삭제됨');
    return count;
  }

  // ============================================================================
  // 📄 페이지네이션 - 화면에 보이는 데이터만 로드
  // ============================================================================

  /// 📄 할일 페이지네이션 (화면에 보이는 것만 로드)
  /// 이거를 설정하고 → limit과 offset으로 필요한 만큼만 가져와서
  /// 이거를 해서 → 성능을 최적화하고
  /// 이거는 이래서 → 대량의 할일이 있어도 빠르게 로드된다
  Stream<List<TaskData>> watchTasksPaginated({
    required int limit,
    required int offset,
  }) {
    print('📄 [DB] watchTasksPaginated: limit=$limit, offset=$offset');
    return (select(task)
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.completed), // 미완료 먼저
            (tbl) => OrderingTerm(expression: tbl.dueDate), // 마감일 순
            (tbl) => OrderingTerm(expression: tbl.title), // 제목 순
          ])
          ..limit(limit, offset: offset))
        .watch();
  }

  /// 📄 습관 페이지네이션 (화면에 보이는 것만 로드)
  /// 이거를 설정하고 → limit과 offset으로 필요한 만큼만 가져와서
  /// 이거를 해서 → 성능을 최적화하고
  /// 이거는 이래서 → 대량의 습관이 있어도 빠르게 로드된다
  Stream<List<HabitData>> watchHabitsPaginated({
    required int limit,
    required int offset,
  }) {
    print('📄 [DB] watchHabitsPaginated: limit=$limit, offset=$offset');
    return (select(habit)
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.createdAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit, offset: offset))
        .watch();
  }

  /// 📊 할일 총 개수 조회 (페이지네이션용)
  /// 이거를 설정하고 → 전체 할일 개수를 세어서
  /// 이거를 해서 → 페이지네이션 계산에 사용한다
  Future<int> getTasksCount() async {
    final query = selectOnly(task)..addColumns([task.id.count()]);
    final result = await query.getSingle();
    final count = result.read(task.id.count()) ?? 0;
    print('📊 [DB] getTasksCount: $count개');
    return count;
  }

  /// 📊 습관 총 개수 조회 (페이지네이션용)
  /// 이거를 설정하고 → 전체 습관 개수를 세어서
  /// 이거를 해서 → 페이지네이션 계산에 사용한다
  Future<int> getHabitsCount() async {
    final query = selectOnly(habit)..addColumns([habit.id.count()]);
    final result = await query.getSingle();
    final count = result.read(habit.id.count()) ?? 0;
    print('📊 [DB] getHabitsCount: $count개');
    return count;
  }

  // ==================== 🎵 Insight Player 함수 (Phase 1) ====================

  /// 특정 날짜의 인사이트 조회
  /// 이거를 설정하고 → targetDate로 정확한 날짜 매칭해서
  /// 이거를 해서 → 해당 날짜에 연결된 오디오 콘텐츠를 반환한다
  Future<AudioContentData?> getInsightForDate(DateTime date) async {
    // 날짜 정규화 (시간 부분 제거)
    final normalized = DateTime(date.year, date.month, date.day);

    print('🎵 [DB] getInsightForDate: ${normalized.toString().split(' ')[0]}');

    final result = await (select(
      audioContents,
    )..where((t) => t.targetDate.equals(normalized))).getSingleOrNull();

    if (result != null) {
      print('✅ [DB] 인사이트 발견: ${result.title}');
    } else {
      print('⚠️ [DB] 해당 날짜의 인사이트 없음');
    }

    return result;
  }

  /// 인사이트의 스크립트 라인 조회 (실시간 스트림)
  /// 이거를 설정하고 → audioContentId로 필터링해서
  /// 이거를 해서 → sequence 순서대로 정렬된 스크립트를 watch한다
  Stream<List<TranscriptLineData>> watchTranscriptLines(int audioContentId) {
    print('📜 [DB] watchTranscriptLines: audioContentId=$audioContentId');

    return (select(transcriptLines)
          ..where((t) => t.audioContentId.equals(audioContentId))
          ..orderBy([(t) => OrderingTerm(expression: t.sequence)]))
        .watch();
  }

  /// 현재 재생 위치에 해당하는 스크립트 라인 찾기 (성능 최적화)
  /// 이거를 설정하고 → startTimeMs <= positionMs 조건으로 필터링해서
  /// 이거를 해서 → 가장 최근 startTime을 가진 라인을 반환한다
  Future<TranscriptLineData?> getCurrentLine(
    int audioContentId,
    int positionMs,
  ) async {
    return await (select(transcriptLines)
          ..where(
            (t) =>
                t.audioContentId.equals(audioContentId) &
                t.startTimeMs.isSmallerOrEqualValue(positionMs),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.startTimeMs,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// 재생 진행 상태 업데이트
  /// 이거를 설정하고 → AudioContents의 lastPositionMs와 lastPlayedAt을 업데이트해서
  /// 이거를 해서 → 사용자가 어디까지 들었는지 기록한다
  Future<void> updateAudioProgress(int audioContentId, int positionMs) async {
    print('💾 [DB] updateAudioProgress: $positionMs ms');

    await (update(
      audioContents,
    )..where((t) => t.id.equals(audioContentId))).write(
      AudioContentsCompanion(
        lastPositionMs: Value(positionMs),
        lastPlayedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 인사이트 완료 처리
  /// 이거를 설정하고 → isCompleted를 true로 설정하고
  /// 이거를 해서 → completedAt 타임스탬프를 기록한다
  Future<void> markInsightAsCompleted(int audioContentId) async {
    print('✅ [DB] markInsightAsCompleted: audioContentId=$audioContentId');

    await (update(
      audioContents,
    )..where((t) => t.id.equals(audioContentId))).write(
      AudioContentsCompanion(
        isCompleted: const Value(true),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 재생 횟수 증가
  /// 이거를 설정하고 → playCount를 +1 증가시켜서
  /// 이거를 해서 → 몇 번 재생했는지 추적한다
  Future<void> incrementPlayCount(int audioContentId) async {
    print('📊 [DB] incrementPlayCount: audioContentId=$audioContentId');

    final current = await (select(
      audioContents,
    )..where((t) => t.id.equals(audioContentId))).getSingle();

    await (update(
      audioContents,
    )..where((t) => t.id.equals(audioContentId))).write(
      AudioContentsCompanion(playCount: Value((current.playCount ?? 0) + 1)),
    );
  }

  /// 샘플 인사이트 데이터 삽입 (초기화 시 자동 실행)
  /// 이거를 설정하고 → Figma 텍스트 기반 LRC 데이터를 생성해서
  /// 이거를 해서 → 2025-10-18 날짜에 샘플 인사이트를 추가한다
  Future<void> seedInsightData() async {
    print('🌱 [DB] seedInsightData 시작');

    // 이미 데이터가 있는지 확인
    final existing = await getInsightForDate(DateTime(2025, 10, 18));
    if (existing != null) {
      print('⚠️ [DB] 이미 샘플 데이터가 존재함. 스킵.');
      return;
    }

    // 1. 오디오 콘텐츠 생성
    final audioId = await into(audioContents).insert(
      AudioContentsCompanion.insert(
        title: '過去データから見える自分可能性',
        subtitle: 'インサイト',
        audioPath: 'asset/audio/insight_001.mp3', // Flutter asset 경로
        durationSeconds: 84, // 1분 24초
        targetDate: DateTime(2025, 10, 18),
        // 재생 상태는 기본값 사용 (lastPositionMs=0, isCompleted=false, playCount=0)
      ),
    );
    print('✅ [DB] 오디오 콘텐츠 생성 완료 (id=$audioId)');

    // 2. 스크립트 라인 삽입 (Figma 텍스트 기반)
    final lines = [
      (0, 5500, 'こんにちは。あなたの週訪時間にインサイトをお届けする「脳の賢者たち」です。'),
      (5500, 12000, 'こんにちは。脳科学と心理学であなたの今日を応援するWです。'),
      (
        12000,
        18500,
        'Wさん、今日とても興味深いのToDoリストを見たんです。旅行の準備、部屋の掃除、メモの整理みたいに、明確で小さな目標はさらんと終わらせていました。',
      ),
      (
        18500,
        28000,
        'でも「価値観を整理する」とか、大事な「業務テスト」みたいな大きくて抽象的なことは全然手をつけられていなかったんです。…これ、すごく見覚えがありませんか？',
      ),
      (
        28000,
        33500,
        'あー、ありますね。それは私たちの脳にとって、とても自然を特徴なんです。脳は課題をひとつずつ終わらせるために、「ドーハミン」という興奮ホルモンをくれるんですよ。',
      ),
      (
        33500,
        43500,
        'これが私たちが感じる達成感の正体です。小さくて具体的な作業は、このドーハミンを早く、簡単に得られるとても良い方法なんです。だから、ToDoリストにチェックを入れて快感を味わうのは、脳の正常な機能そのものなんですね。',
      ),
      (
        43500,
        50000,
        'そうですよね。心理学では「スモール・ウィンズ（小さな成功）」戦略の力が大く強調されますよね。でも問題は、終わっていない大きな課題が、心のどこかでずっと引っかかってしまうことです。',
      ),
      (
        50000,
        60000,
        'これを心理学ルーン効果といいまして、未完了の課題が脳のメモリーを占有し続けて、他のことに集中するのを邪魔したり、無意識のストレスを与えてしまうんです。',
      ),
      (
        60000,
        68000,
        'そんなときは、脳にちょっとしたトリックが必要です。「価値観を整理する」という大きな目標が重く感じるなら、「今日は大事だと思った価値を1つだけ書いてみる」といったらどうでできる小さな第一歩にかけるんですね。',
      ),
      (
        68000,
        76000,
        '「業務テスト」がハードル高く感じる場合も、「まずはテストの第一項目だけ決める」から始めるんですね。一度エンジンがかかれば、脳は慣性の法則によって、そのまま続けたくなる傾向があります から。',
      ),
      (
        76000,
        84000,
        '本当にいい方法ですね。大きな岩を小石に砕くしたですね。この方のリストを見たら、韓国旅行の準備、外国語の勉強、マラソンの申し込みまで計画していて、未来に向けずはらしい計画を立て、ちゃんと実行しているあなたたどうかがります。',
      ),
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
    print('✅ [DB] 스크립트 라인 ${lines.length}개 삽입 완료');

    // ⚠️ AudioProgress 제거: 재생 상태는 AudioContents에 통합됨
    // 기본값으로 lastPositionMs=0, isCompleted=false, playCount=0 자동 설정

    print('🎉 [DB] seedInsightData 완료!');
  }

  @override
  int get schemaVersion => 5; // ✅ 스키마 버전 5: Insight Player (AudioContents + TranscriptLines, 재생 상태 통합)

  // ✅ [마이그레이션 전략 추가]
  // 이거를 설정하고 → onCreate에서 테이블을 생성하고
  // 이거를 해서 → onUpgrade에서 스키마 변경 시 마이그레이션 로직을 실행한다
  // 이거는 이래서 → Drift가 데이터베이스 초기화 및 업그레이드를 안전하게 처리한다
  // 이거라면 → 앱 재실행 시 마이그레이션 오류가 발생하지 않는다
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      print('🏗️ [DB Migration] 데이터베이스 생성 시작');
      await m.createAll();
      print('✅ [DB Migration] 모든 테이블 생성 완료');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      print('🔄 [DB Migration] 스키마 업그레이드: v$from → v$to');

      // v2 → v3: Task와 Habit 테이블에 반복/리마인더 컬럼 추가
      if (from == 2 && to == 3) {
        print('📦 [DB Migration] v2→v3: Task/Habit에 반복/리마인더 컬럼 추가');
        await m.addColumn(task, task.repeatRule);
        await m.addColumn(task, task.reminder);
        await m.addColumn(habit, habit.reminder);
        print('✅ [DB Migration] v2→v3 완료');
      }

      // v3 → v4: DailyCardOrder 테이블 추가 (날짜별 카드 순서 관리)
      if (from == 3 && to == 4) {
        print('📦 [DB Migration] v3→v4: DailyCardOrder 테이블 생성');
        await m.createTable(dailyCardOrder);
        print('✅ [DB Migration] v3→v4 완료 - 날짜별 카드 순서 관리 기능 추가');
      }

      // v4 → v5: Insight Player 테이블 추가 (AudioContents만, 재생 상태 통합)
      if (from == 4 && to >= 5) {
        print('📦 [DB Migration] v4→v5+: Insight Player 테이블 생성');
        await m.createTable(audioContents);
        await m.createTable(transcriptLines);
        print('✅ [DB Migration] v4→v5+ 완료 - Insight Player 기능 추가 (재생 상태 통합)');
      }

      print('✅ [DB Migration] 업그레이드 완료');
    },
    beforeOpen: (details) async {
      print('🔓 [DB] 데이터베이스 연결 전 체크');
      // 외래키 제약조건 활성화 등
      await customStatement('PRAGMA foreign_keys = ON');
      print('✅ [DB] 연결 준비 완료 (schemaVersion: $schemaVersion)');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder =
        await getApplicationDocumentsDirectory(); //이거는 닥큐멘트 드렉토리를 가져옴. 앱에 지정된 문팡리이다.
    //p.join은 경로를 합쳐준다.
    //어떠한 결로를 합칠 건가?
    //dbFolder.path는 앱의 문서 폴더 경로이다. 시스템에서 자동으로 지정해주는 경로
    //'db.sqlite'는 데이터베이스 (예시)파일 이름이다.
    //합쳐서 /users/appuser/documents/db.sqlite 경로를 만든다.
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions(); // 'sqlite3' 포함
    }

    final cachedDatabase = await getTemporaryDirectory(); //이거는 임시 폴더를 가져오는 것이다.

    sqlite3.tempDirectory = cachedDatabase.path; //임시폴더를 써서 캐시를 저장할 곳이 필요하다.

    return NativeDatabase.createInBackground(file);
    //오픈커넥트 함수를 실행을 하면, 해당 파일경로 위치에 데이터베이스를 생성한다라는 뜻
  });
}
