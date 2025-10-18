import 'package:drift/drift.dart';

/// Task (할일) 테이블
/// 이거를 설정하고 → 할일 데이터를 저장하는 테이블을 정의해서
/// 이거를 해서 → 제목, 완료 여부, 마감일, 색상 등을 관리하고
/// 이거는 이래서 → Quick Add 시스템에서 할일을 추가/관리할 수 있다
@DataClassName('TaskData')
class Task extends Table {
  // 이거를 설정하고 → 자동 증가하는 id를 primary key로 설정해서
  // 이거를 해서 → 각 할일을 고유하게 식별한다
  IntColumn get id => integer().autoIncrement()();

  // 이거를 설정하고 → 제목을 필수 텍스트로 설정해서
  // 이거를 해서 → 할일의 내용을 저장한다
  TextColumn get title => text()();

  // 이거를 설정하고 → 완료 여부를 boolean으로 설정해서
  // 이거를 해서 → 체크박스 상태를 관리한다
  // 이거는 이래서 → 기본값은 false (미완료)
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  // 이거를 설정하고 → 마감일을 nullable DateTime으로 설정해서
  // 이거를 해서 → 마감일이 없는 할일도 허용한다
  DateTimeColumn get dueDate => dateTime().nullable()();

  // 이거를 설정하고 → 목록 ID를 텍스트로 설정해서
  // 이거를 해서 → 여러 목록(Inbox, 프로젝트 등)으로 분류한다
  // 이거는 이래서 → 기본값은 'inbox'
  TextColumn get listId => text().withDefault(const Constant('inbox'))();

  // 이거를 설정하고 → 생성일을 DateTime으로 설정해서
  // 이거를 해서 → 언제 만들어졌는지 기록한다
  DateTimeColumn get createdAt => dateTime()();

  // 이거를 설정하고 → 완료일을 nullable DateTime으로 설정해서
  // 이거를 해서 → 완료된 날짜를 기록한다
  DateTimeColumn get completedAt => dateTime().nullable()();

  // 이거를 설정하고 → 색상 ID를 텍스트로 설정해서
  // 이거를 해서 → 카테고리별로 색상을 구분한다
  // 이거는 이래서 → 기본값은 'gray'
  TextColumn get colorId => text().withDefault(const Constant('gray'))();

  // ✅ 반복 규칙 추가 (JSON 형식)
  // 이거를 설정하고 → 반복 주기를 JSON 형식의 텍스트로 설정해서
  // 이거를 해서 → 매일/매월/간격 반복 설정을 저장한다
  TextColumn get repeatRule => text().withDefault(const Constant(''))();

  // ✅ 리마인더 설정 추가 (JSON 형식)
  // 이거를 설정하고 → 리마인더 설정을 JSON 형식의 텍스트로 설정해서
  // 이거를 해서 → 알림 시간을 저장한다
  TextColumn get reminder => text().withDefault(const Constant(''))();
}

/// Habit (습관) 테이블
/// 이거를 설정하고 → 습관 데이터를 저장하는 테이블을 정의해서
/// 이거를 해서 → 반복되는 루틴을 관리하고
/// 이거는 이래서 → 날짜별 완료 기록을 추적할 수 있다
@DataClassName('HabitData')
class Habit extends Table {
  // 이거를 설정하고 → 자동 증가하는 id를 primary key로 설정해서
  // 이거를 해서 → 각 습관을 고유하게 식별한다
  IntColumn get id => integer().autoIncrement()();

  // 이거를 설정하고 → 제목을 필수 텍스트로 설정해서
  // 이거를 해서 → 습관의 내용을 저장한다
  TextColumn get title => text()();

  // 이거를 설정하고 → 생성일을 DateTime으로 설정해서
  // 이거를 해서 → 언제 시작했는지 기록한다
  DateTimeColumn get createdAt => dateTime()();

  // 이거를 설정하고 → 색상 ID를 텍스트로 설정해서
  // 이거를 해서 → 카테고리별로 색상을 구분한다
  // 이거는 이래서 → 기본값은 'gray'
  TextColumn get colorId => text().withDefault(const Constant('gray'))();

  // 이거를 설정하고 → 반복 주기를 JSON 형식의 텍스트로 설정해서
  // 이거를 해서 → 요일별 반복 설정을 저장한다
  // 이거는 이래서 → 예: '{"mon":true,"tue":false,...}'
  TextColumn get repeatRule => text()();

  // ✅ 리마인더 설정 추가 (JSON 형식)
  // 이거를 설정하고 → 리마인더 설정을 JSON 형식의 텍스트로 설정해서
  // 이거를 해서 → 알림 시간을 저장한다
  TextColumn get reminder => text().withDefault(const Constant(''))();
}

/// HabitCompletion (습관 완료 기록) 테이블
/// 이거를 설정하고 → 날짜별 습관 완료 기록을 저장하는 테이블을 정의해서
/// 이거를 해서 → 어떤 날짜에 어떤 습관을 완료했는지 추적하고
/// 이거는 이래서 → 통계와 스트릭(연속 기록)을 계산할 수 있다
@DataClassName('HabitCompletionData')
class HabitCompletion extends Table {
  // 이거를 설정하고 → 자동 증가하는 id를 primary key로 설정해서
  // 이거를 해서 → 각 완료 기록을 고유하게 식별한다
  IntColumn get id => integer().autoIncrement()();

  // 이거를 설정하고 → habitId를 foreign key로 설정해서
  // 이거를 해서 → Habit 테이블과 연결한다
  // 이거는 이래서 → 어느 습관의 기록인지 알 수 있다
  IntColumn get habitId => integer()();

  // 이거를 설정하고 → 완료한 날짜를 DateTime으로 설정해서
  // 이거를 해서 → 언제 완료했는지 기록한다
  DateTimeColumn get completedDate => dateTime()();

  // 이거를 설정하고 → 기록 생성일을 DateTime으로 설정해서
  // 이거를 해서 → 언제 체크했는지 기록한다
  DateTimeColumn get createdAt => dateTime()();
}

/// DailyCardOrder (날짜별 카드 순서 관리) 테이블
///
/// 이거를 설정하고 → 특정 날짜에 표시되는 모든 카드의 순서를 관리하는 테이블을 정의해서
/// 이거를 해서 → 날짜마다 사용자가 설정한 카드 배치 순서를 저장하고
/// 이거는 이래서 → 일정/할일/습관이 섞인 상태에서도 정확한 순서를 복원할 수 있다
///
/// **핵심 개념:**
/// - 날짜(date)를 기준으로 각 카드의 순서(sortOrder)를 저장
/// - cardType + cardId로 실제 카드 데이터와 JOIN
/// - 기존 Schedule/Task/Habit 테이블은 건드리지 않음
///
/// **사용 예시:**
/// ```
/// 2025-10-18 날짜:
///   - sortOrder: 0 → schedule (id: 5)
///   - sortOrder: 1 → task (id: 12)
///   - sortOrder: 2 → schedule (id: 8)
///   - sortOrder: 3 → habit (id: 3)
/// ```
@DataClassName('DailyCardOrderData')
class DailyCardOrder extends Table {
  // 🔑 Primary Key: 자동 증가 ID
  // 이거를 설정하고 → 자동 증가하는 id를 primary key로 설정해서
  // 이거를 해서 → 각 순서 레코드를 고유하게 식별한다
  IntColumn get id => integer().autoIncrement()();

  // 📅 날짜 (기준 날짜 - 시간 제거된 00:00:00)
  // 이거를 설정하고 → 어느 날짜의 순서인지 저장해서
  // 이거를 해서 → 날짜별로 다른 순서를 관리한다
  // 이거는 이래서 → date_detail_view에서 날짜별로 쿼리할 수 있다
  DateTimeColumn get date => dateTime()();

  // 🎯 카드 타입 ('schedule' | 'task' | 'habit')
  // 이거를 설정하고 → 어떤 종류의 카드인지 구분해서
  // 이거를 해서 → JOIN 시 올바른 테이블을 참조한다
  // 이거는 이래서 → 'schedule'이면 Schedule 테이블과 JOIN
  TextColumn get cardType => text()();

  // 🆔 실제 카드 ID (Schedule.id | Task.id | Habit.id)
  // 이거를 설정하고 → 실제 데이터의 ID를 저장해서
  // 이거를 해서 → Schedule/Task/Habit 테이블과 JOIN 연결한다
  // 이거는 이래서 → WHERE cardId = Schedule.id 조건으로 실제 데이터 가져옴
  IntColumn get cardId => integer()();

  // 📊 정렬 순서 (0부터 시작, 작을수록 위)
  // 이거를 설정하고 → 화면에 표시될 순서를 숫자로 저장해서
  // 이거를 해서 → ORDER BY sortOrder로 정렬한다
  // 이거는 이래서 → 드래그앤드롭으로 순서가 바뀌면 이 값만 업데이트
  IntColumn get sortOrder => integer()();

  // ⏰ 수정 시간 (순서가 변경된 최종 시간)
  // 이거를 설정하고 → 언제 순서가 변경되었는지 기록해서
  // 이거를 해서 → 디버깅 및 동기화 시 참고한다
  // 이거는 이래서 → 기존 카드 테이블의 createdAt은 그대로 두고 수정 시간만 관리
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
}
