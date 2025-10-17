import 'package:flutter/material.dart';

/// ✅ 할일 입력 폼 상태 관리 Controller
///
/// **관리 항목**:
/// - titleController: 제목 입력
/// - dueDate: 마감일
/// - completed: 완료 여부
///
/// **사용처**:
/// - FullTaskBottomSheet
///
/// **목적**: 할일 입력 상태를 중앙에서 관리
class TaskFormController extends ChangeNotifier {
  final titleController = TextEditingController();

  DateTime? _dueDate;
  bool _completed = false;

  // Getters
  DateTime? get dueDate => _dueDate;
  bool get completed => _completed;
  String get title => titleController.text.trim();
  bool get hasTitle => titleController.text.trim().isNotEmpty;
  bool get hasDueDate => _dueDate != null;

  // Setters
  void setDueDate(DateTime? date) {
    if (_dueDate == date) return;
    _dueDate = date;
    notifyListeners();
  }

  void toggleCompleted() {
    _completed = !_completed;
    notifyListeners();
  }

  void setCompleted(bool value) {
    if (_completed == value) return;
    _completed = value;
    notifyListeners();
  }

  void clearDueDate() {
    if (_dueDate == null) return;
    _dueDate = null;
    notifyListeners();
  }

  // 초기화
  void reset() {
    titleController.clear();
    _dueDate = null;
    _completed = false;
    notifyListeners();
  }

  void resetWithDate(DateTime selectedDate) {
    titleController.clear();
    _dueDate = selectedDate;
    _completed = false;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}
