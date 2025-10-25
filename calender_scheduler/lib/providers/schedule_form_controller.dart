import 'package:flutter/material.dart';

/// 📅 스케줄 입력 폼 상태 관리 Controller
///
/// **관리 항목**:
/// - titleController: 제목 입력
/// - isAllDay: 종일 여부
/// - startDate/Time: 시작 날짜/시간
/// - endDate/Time: 종료 날짜/시간
///
/// **사용처**:
/// - ScheduleDetailWoltModal (일정 상세 모달)
///
/// **목적**: 스케줄 입력 상태를 중앙에서 관리
class ScheduleFormController extends ChangeNotifier {
  // TextEditingController
  final titleController = TextEditingController();

  // 날짜/시간 상태
  bool _isAllDay = false;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Getters
  bool get isAllDay => _isAllDay;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;

  String get title => titleController.text.trim();
  bool get hasTitle => titleController.text.trim().isNotEmpty;

  /// 시작 DateTime 빌드
  DateTime? get startDateTime {
    if (_startDate == null) return null;
    if (_isAllDay || _startTime == null) {
      return DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        0,
        0,
        0,
      );
    }
    return DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
      0,
    );
  }

  /// 종료 DateTime 빌드
  DateTime? get endDateTime {
    if (_endDate == null) return null;
    if (_isAllDay || _endTime == null) {
      return DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        23,
        59,
        59,
      );
    }
    return DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
      0,
    );
  }

  // Setters
  void toggleAllDay() {
    _isAllDay = !_isAllDay;
    // ✅ 終日 토글 시 시간 값은 유지 (null로 설정하지 않음)
    // 시간 값이 없으면 기본값 설정
    if (_isAllDay) {
      if (_startTime == null) {
        _startTime = const TimeOfDay(hour: 0, minute: 0);
      }
      if (_endTime == null) {
        _endTime = const TimeOfDay(hour: 23, minute: 59);
      }
    }
    notifyListeners();
    debugPrint(
      '🔄 [ScheduleForm] 終日 토글: $_isAllDay (시간 유지: start=$_startTime, end=$_endTime)',
    );
  }

  void setAllDay(bool value) {
    if (_isAllDay == value) return;
    _isAllDay = value;
    // ✅ 終日 설정 시 시간 값은 유지
    if (_isAllDay) {
      if (_startTime == null) {
        _startTime = const TimeOfDay(hour: 0, minute: 0);
      }
      if (_endTime == null) {
        _endTime = const TimeOfDay(hour: 23, minute: 59);
      }
    }
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    if (_endDate == null || _endDate!.isBefore(date)) {
      _endDate = date;
    }
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    _startTime = time;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    if (_startDate != null && _startDate!.isAfter(date)) {
      _startDate = date;
    }
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    _endTime = time;
    notifyListeners();
  }

  // 초기화
  void reset() {
    titleController.clear();
    _isAllDay = false;
    _startDate = null;
    _startTime = null;
    _endDate = null;
    _endTime = null;
    notifyListeners();
  }

  void resetWithDate(DateTime selectedDate) {
    titleController.clear();
    _isAllDay = false;
    _startDate = selectedDate;
    _endDate = selectedDate;
    final now = TimeOfDay.now();
    _startTime = now;
    _endTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute);
    notifyListeners();
  }

  void loadInitialTitle(String? title) {
    if (title != null && title.isNotEmpty) {
      titleController.text = title;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}
