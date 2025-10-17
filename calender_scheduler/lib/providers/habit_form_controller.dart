import 'package:flutter/material.dart';

/// 📝 습관(Habit) 폼 상태 관리 Provider
///
/// **관리 항목**:
/// - titleController: 습관 제목 입력 컨트롤러
/// - habitTime: 습관 시간 (nullable)
///
/// **사용처**:
/// - HabitDetailWoltModal (습관 Wolt 모달) ✅ NEW
/// - CreateEntryBottomSheet (습관 입력 모드)
///
/// **목적**: 습관 전용 상태를 중앙화하고 중복 제거
class HabitFormController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  DateTime? _habitTime;

  // Getters
  String get title => titleController.text;
  DateTime? get habitTime => _habitTime;

  bool get hasTitle => title.trim().isNotEmpty;

  // Setters
  void setHabitTime(DateTime? time) {
    _habitTime = time;
    notifyListeners();
  }

  void reset() {
    titleController.clear();
    _habitTime = null;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}
