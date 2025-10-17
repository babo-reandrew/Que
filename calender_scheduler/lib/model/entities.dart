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
