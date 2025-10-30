// ===================================================================
// ⭐️ Extracted Data Models
// ===================================================================
// Gemini API에서 추출한 일정/할일/습관 데이터를 표현하는 모델입니다.
//
// 역할:
// - Gemini JSON 응답을 Dart 객체로 변환
// - Drift Schedule/Task/Habit 테이블에 삽입하기 위한 Companion 객체 생성
// - 타입별(일정/할일/습관) 구분 및 처리
// ===================================================================

import 'package:drift/drift.dart';
import '../Database/schedule_database.dart';

/// 추출된 항목의 타입
enum ItemType {
  schedule, // 일정: 특정 날짜+시간이 있는 일회성 이벤트
  task, // 할 일: 시간 지정 없는 작업 (마감일만 있음)
  habit, // 습관: 반복되는 활동
}

// ===================================================================
// 📅 ExtractedSchedule (일정)
// ===================================================================
/// Gemini API에서 추출한 일정 데이터
class ExtractedSchedule {
  final String summary; // 제목 (필수)
  final DateTime start; // 시작 날짜/시간
  final DateTime end; // 종료 날짜/시간
  final String description; // 설명
  final String location; // 장소
  final String colorId; // 색상 ID
  final String repeatRule; // 반복 규칙 (RRULE 형식)

  ExtractedSchedule({
    required this.summary,
    required this.start,
    required this.end,
    this.description = '',
    this.location = '',
    this.colorId = 'gray',
    this.repeatRule = '',
  });

  /// Gemini JSON 응답에서 ExtractedSchedule 객체 생성
  factory ExtractedSchedule.fromJson(Map<String, dynamic> json) {
    return ExtractedSchedule(
      summary: json['summary'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      colorId: json['colorId'] as String? ?? 'gray',
      repeatRule: json['repeatRule'] as String? ?? '',
    );
  }

  /// Drift Schedule 테이블에 삽입하기 위한 Companion 객체 변환
  ScheduleCompanion toCompanion() {
    return ScheduleCompanion.insert(
      start: start,
      end: end,
      summary: summary,
      description: Value(description),
      location: Value(location),
      colorId: colorId,
      repeatRule: Value(repeatRule),
    );
  }

  @override
  String toString() {
    return 'ExtractedSchedule(summary: $summary, start: $start, end: $end, colorId: $colorId)';
  }
}

// ===================================================================
// ✅ ExtractedTask (할 일)
// ===================================================================
/// Gemini API에서 추출한 할 일 데이터
class ExtractedTask {
  final String title; // 제목 (필수)
  final DateTime? dueDate; // 마감 날짜 (nullable)
  final DateTime? executionDate; // 실행 날짜 (nullable)
  final String colorId; // 색상 ID
  final String listId; // 목록 ID
  final String repeatRule; // 반복 규칙 (RRULE 형식)
  final String reminder; // 리마인더 설정

  ExtractedTask({
    required this.title,
    this.dueDate,
    this.executionDate,
    this.colorId = 'gray',
    this.listId = 'inbox',
    this.repeatRule = '',
    this.reminder = '',
  });

  /// Gemini JSON 응답에서 ExtractedTask 객체 생성
  factory ExtractedTask.fromJson(Map<String, dynamic> json) {
    return ExtractedTask(
      title: json['title'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      executionDate: json['executionDate'] != null
          ? DateTime.parse(json['executionDate'] as String)
          : null,
      colorId: json['colorId'] as String? ?? 'gray',
      listId: json['listId'] as String? ?? 'inbox',
      repeatRule: json['repeatRule'] as String? ?? '',
      reminder: json['reminder'] as String? ?? '',
    );
  }

  /// Drift Task 테이블에 삽입하기 위한 Companion 객체 변환
  TaskCompanion toCompanion() {
    return TaskCompanion.insert(
      title: title,
      dueDate: Value(dueDate),
      executionDate: Value(executionDate),
      listId: Value(listId),
      colorId: Value(colorId),
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ExtractedTask(title: $title, dueDate: $dueDate, executionDate: $executionDate, colorId: $colorId)';
  }
}

// ===================================================================
// 🔁 ExtractedHabit (습관)
// ===================================================================
/// Gemini API에서 추출한 습관 데이터
class ExtractedHabit {
  final String title; // 제목 (필수)
  final String repeatRule; // 반복 규칙 (RRULE 형식, 필수)
  final String colorId; // 색상 ID
  final String reminder; // 리마인더 설정

  ExtractedHabit({
    required this.title,
    required this.repeatRule,
    this.colorId = 'gray',
    this.reminder = '',
  });

  /// Gemini JSON 응답에서 ExtractedHabit 객체 생성
  factory ExtractedHabit.fromJson(Map<String, dynamic> json) {
    return ExtractedHabit(
      title: json['title'] as String,
      repeatRule: json['repeatRule'] as String,
      colorId: json['colorId'] as String? ?? 'gray',
      reminder: json['reminder'] as String? ?? '',
    );
  }

  /// Drift Habit 테이블에 삽입하기 위한 Companion 객체 변환
  HabitCompanion toCompanion() {
    return HabitCompanion.insert(
      title: title,
      repeatRule: repeatRule,
      colorId: Value(colorId),
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ExtractedHabit(title: $title, repeatRule: $repeatRule, colorId: $colorId)';
  }
}

// ===================================================================
// 📦 GeminiResponse (전체 응답 래퍼)
// ===================================================================
/// Gemini API의 전체 응답을 파싱하는 래퍼 클래스
class GeminiResponse {
  final List<ExtractedSchedule> schedules;
  final List<ExtractedTask> tasks;
  final List<ExtractedHabit> habits;
  final int irrelevantImageCount;

  GeminiResponse({
    required this.schedules,
    required this.tasks,
    required this.habits,
    this.irrelevantImageCount = 0,
  });

  /// Gemini JSON 응답에서 GeminiResponse 객체 생성
  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    return GeminiResponse(
      schedules:
          (json['schedules'] as List<dynamic>?)
              ?.map(
                (e) => ExtractedSchedule.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((e) => ExtractedTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      habits:
          (json['habits'] as List<dynamic>?)
              ?.map((e) => ExtractedHabit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      irrelevantImageCount: json['irrelevant_image_count'] as int? ?? 0,
    );
  }

  /// 전체 항목 개수
  int get totalCount => schedules.length + tasks.length + habits.length;

  /// 빈 응답인지 확인
  bool get isEmpty => totalCount == 0;

  @override
  String toString() {
    return 'GeminiResponse(schedules: ${schedules.length}, tasks: ${tasks.length}, habits: ${habits.length}, irrelevant: $irrelevantImageCount)';
  }
}
