// ===================================================================
// ⭐️ Temporary Extracted Items Table
// ===================================================================
// Gemini AI가 추출한 일정/할일/습관을 임시로 저장하는 테이블
// 사용자가 최종 확인 후 실제 DB로 이동
// ===================================================================

import 'package:drift/drift.dart';

/// 임시 추출 항목 타입
enum TempItemType {
  schedule, // 일정
  task, // 할일
  habit, // 습관
}

/// Gemini AI 추출 결과 임시 저장 테이블
@DataClassName('TempExtractedItemData')
class TempExtractedItems extends Table {
  /// ID (자동 증가)
  IntColumn get id => integer().autoIncrement()();

  /// 항목 타입 (schedule, task, habit)
  TextColumn get itemType => text()();

  /// 제목 또는 요약
  TextColumn get title => text()();

  /// 시작 날짜/시간 (일정용, nullable)
  DateTimeColumn get startDate => dateTime().nullable()();

  /// 종료 날짜/시간 (일정용, nullable)
  DateTimeColumn get endDate => dateTime().nullable()();

  /// 마감일 (할일용, nullable)
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// 실행일 (할일용, nullable)
  DateTimeColumn get executionDate => dateTime().nullable()();

  /// 설명
  TextColumn get description => text().withDefault(const Constant(''))();

  /// 장소
  TextColumn get location => text().withDefault(const Constant(''))();

  /// 색상 ID
  TextColumn get colorId => text().withDefault(const Constant('gray'))();

  /// 반복 규칙 (RRULE 형식)
  TextColumn get repeatRule => text().withDefault(const Constant(''))();

  /// 리스트 ID (할일용, 기본: inbox)
  TextColumn get listId => text().withDefault(const Constant('inbox'))();

  /// 생성 시간
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 사용자 확인 여부 (체크박스)
  BoolColumn get isConfirmed => boolean().withDefault(const Constant(true))();
}
