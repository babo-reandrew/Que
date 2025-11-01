import 'package:flutter/material.dart';

/// ✅ 할일 입력 폼 상태 관리 Controller
///
/// **관리 항목**:
/// - titleController: 제목 입력
/// - dueDate: 마감일
/// - executionDate: 실행일 (DetailView에 표시할 날짜)
/// - completed: 완료 여부
///
/// **사용처**:
/// - FullTaskBottomSheet
/// - TaskDetailWoltModal
///
/// **목적**: 할일 입력 상태를 중앙에서 관리
class TaskFormController extends ChangeNotifier {
  final titleController = TextEditingController();

  DateTime? _dueDate;
  DateTime? _executionDate;
  bool _completed = false;

  // Getters
  DateTime? get dueDate => _dueDate;
  DateTime? get executionDate => _executionDate;
  bool get completed => _completed;
  String get title => titleController.text.trim();
  bool get hasTitle => titleController.text.trim().isNotEmpty;
  bool get hasDueDate => _dueDate != null;
  bool get hasExecutionDate => _executionDate != null;

  // Setters
  void setDueDate(DateTime? date) {
    if (_dueDate == date) return;
    _dueDate = date;
    notifyListeners();
  }

  void setExecutionDate(DateTime? date) {
    if (_executionDate == date) return;
    _executionDate = date;

    // ✅ 실행일이 설정되고 마감일이 있으면, 마감일을 항상 실행일 + 1일로 설정
    // (실행일은 반드시 마감일보다 앞에 있어야 함)
    if (date != null && _dueDate != null) {
      // 날짜만 비교 (시간 제외)
      final executionDateOnly = DateTime(date.year, date.month, date.day);
      final dueDateOnly = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
      );

      // 실행일이 마감일보다 뒤에 있거나 같으면 마감일을 실행일 + 1일로 조정
      if (!executionDateOnly.isBefore(dueDateOnly)) {
        _dueDate = DateTime(
          date.year,
          date.month,
          date.day + 1,
          _dueDate!.hour,
          _dueDate!.minute,
          _dueDate!.second,
        );
      }
    }

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

  void clearExecutionDate() {
    if (_executionDate == null) return;
    _executionDate = null;
    notifyListeners();
  }

  // 초기화
  void reset() {
    titleController.clear();
    _dueDate = null;
    _executionDate = null;
    _completed = false;
    notifyListeners();
  }

  void resetWithDate(DateTime selectedDate) {
    titleController.clear();
    _dueDate = selectedDate;
    _executionDate = null;
    _completed = false;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}
