import 'dart:convert';
import '../Database/schedule_database.dart';

/// 🎯 드래그&드롭 데이터 모델
/// super_drag_and_drop 패키지에서 사용할 직렬화 가능한 데이터
class DragTaskData {
  final int taskId;
  final String title;
  final DateTime? executionDate;
  final bool completed;

  DragTaskData({
    required this.taskId,
    required this.title,
    this.executionDate,
    this.completed = false,
  });

  /// TaskData에서 변환
  factory DragTaskData.fromTaskData(TaskData task) {
    return DragTaskData(
      taskId: task.id,
      title: task.title,
      executionDate: task.executionDate,
      completed: task.completed,
    );
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'title': title,
      'executionDate': executionDate?.toIso8601String(),
      'completed': completed,
    };
  }

  /// JSON에서 역직렬화
  factory DragTaskData.fromJson(Map<String, dynamic> json) {
    return DragTaskData(
      taskId: json['taskId'] as int,
      title: json['title'] as String,
      executionDate: json['executionDate'] != null
          ? DateTime.parse(json['executionDate'] as String)
          : null,
      completed: json['completed'] as bool? ?? false,
    );
  }

  /// 문자열로 인코딩 (super_drag_and_drop용)
  String encode() {
    return jsonEncode(toJson());
  }

  /// 문자열에서 디코딩
  static DragTaskData decode(String encoded) {
    return DragTaskData.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
  }
}
