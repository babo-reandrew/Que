import 'package:flutter/material.dart';

/// 🎨 바텀시트 공통 상태 관리 Provider
///
/// **관리 항목**:
/// - selectedColor: 색상 선택 (gray, blue, green 등)
/// - repeatRule: 반복 규칙 (JSON 문자열)
/// - reminder: 리마인더 설정 (JSON 문자열)
///
/// **사용처**:
/// - CreateEntryBottomSheet
/// - ScheduleDetailWoltModal (일정 상세 모달)
/// - TaskDetailWoltModal (할일 상세 모달)
/// - HabitDetailWoltModal (습관 상세 모달)
///
/// **목적**: 바텀시트들의 공통 상태를 하나로 통합
class BottomSheetController extends ChangeNotifier {
  String _selectedColor = 'gray';
  String _repeatRule = '';
  String _reminder = '';

  // Getters
  String get selectedColor => _selectedColor;
  String get repeatRule => _repeatRule;
  String get reminder => _reminder;

  bool get hasRepeat => _repeatRule.isNotEmpty;
  bool get hasReminder => _reminder.isNotEmpty;

  // 반복 표시 텍스트
  String get repeatDisplay {
    if (_repeatRule.isEmpty) return '';
    try {
      if (_repeatRule.contains('daily')) return '매일';
      if (_repeatRule.contains('weekly')) return '매주';
      if (_repeatRule.contains('monthly')) return '매월';
      final match = RegExp(r'"display":"([^"]+)"').firstMatch(_repeatRule);
      return match?.group(1) ?? '설정됨';
    } catch (e) {
      return '설정됨';
    }
  }

  // 리마인더 표시 텍스트
  String get reminderDisplay {
    if (_reminder.isEmpty) return '';
    try {
      final match = RegExp(r'"display":"([^"]+)"').firstMatch(_reminder);
      return match?.group(1) ?? '설정됨';
    } catch (e) {
      return '설정됨';
    }
  }

  // Setters
  void updateColor(String color) {
    if (_selectedColor == color) return;
    _selectedColor = color;
    notifyListeners();
  }

  void updateRepeatRule(String rule) {
    if (_repeatRule == rule) return;
    _repeatRule = rule;
    notifyListeners();
  }

  void updateReminder(String reminder) {
    if (_reminder == reminder) return;
    _reminder = reminder;
    notifyListeners();
  }

  void clearRepeatRule() {
    if (_repeatRule.isEmpty) return;
    _repeatRule = '';
    notifyListeners();
  }

  void clearReminder() {
    if (_reminder.isEmpty) return;
    _reminder = '';
    notifyListeners();
  }

  // 초기화
  void reset() {
    _selectedColor = 'gray';
    _repeatRule = '';
    _reminder = '';
    notifyListeners();
  }

  void resetWithColor(String color) {
    _selectedColor = color;
    _repeatRule = '';
    _reminder = '';
    notifyListeners();
  }
}
