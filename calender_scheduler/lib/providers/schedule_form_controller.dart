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

  // ✅ 종일 토글 시 시간 정보 캐시 (종일 해제 시 복원용)
  TimeOfDay? _cachedStartTime;
  TimeOfDay? _cachedEndTime;

  // Getters
  bool get isAllDay => _isAllDay;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;

  String get title => titleController.text.trim();
  bool get hasTitle => titleController.text.trim().isNotEmpty;

  /// 시작 DateTime 빌드
  /// ✅ 종일일 때: 00:00:00으로 저장 (시간 정보는 캐시에 보존)
  /// ✅ 일반일 때: 실제 시간 사용
  DateTime? get startDateTime {
    if (_startDate == null) return null;
    if (_isAllDay) {
      // 종일: 무조건 00:00:00 (시간은 _cachedStartTime에 보존됨)
      return DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        0,
        0,
        0,
      );
    }
    // 일반: 실제 시간 사용
    if (_startTime == null) {
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
  /// ✅ 종일일 때: 23:59:59로 저장 (시간 정보는 캐시에 보존)
  /// ✅ 일반일 때: 실제 시간 사용
  DateTime? get endDateTime {
    if (_endDate == null) return null;
    if (_isAllDay) {
      // 종일: 무조건 23:59:59 (시간은 _cachedEndTime에 보존됨)
      return DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        23,
        59,
        59,
      );
    }
    // 일반: 실제 시간 사용
    if (_endTime == null) {
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

    if (_isAllDay) {
      // ✅ 종일 ON: 현재 시간을 캐시에 저장하고 00:00 ~ 23:59로 설정
      if (_startTime != null) {
        _cachedStartTime = _startTime;
      }
      if (_endTime != null) {
        _cachedEndTime = _endTime;
      }
      _startTime = const TimeOfDay(hour: 0, minute: 0);
      _endTime = const TimeOfDay(hour: 23, minute: 59);
      debugPrint(
        '🔄 [ScheduleForm] 終日 ON: 시간 캐시 저장 (start=${_cachedStartTime}, end=${_cachedEndTime}) → 00:00 ~ 23:59',
      );
    } else {
      // ✅ 종일 OFF: 캐시에서 시간 복원
      if (_cachedStartTime != null) {
        _startTime = _cachedStartTime;
      }
      if (_cachedEndTime != null) {
        _endTime = _cachedEndTime;
      }
      debugPrint(
        '🔄 [ScheduleForm] 終日 OFF: 시간 복원 (start=$_startTime, end=$_endTime)',
      );
    }

    notifyListeners();
  }

  void setAllDay(bool value) {
    if (_isAllDay == value) return;
    _isAllDay = value;

    if (_isAllDay) {
      // ✅ 종일 ON: 현재 시간을 캐시에 저장하고 00:00 ~ 23:59로 설정
      if (_startTime != null) {
        _cachedStartTime = _startTime;
      }
      if (_endTime != null) {
        _cachedEndTime = _endTime;
      }
      _startTime = const TimeOfDay(hour: 0, minute: 0);
      _endTime = const TimeOfDay(hour: 23, minute: 59);
    } else {
      // ✅ 종일 OFF: 캐시에서 시간 복원
      if (_cachedStartTime != null) {
        _startTime = _cachedStartTime;
      }
      if (_cachedEndTime != null) {
        _endTime = _cachedEndTime;
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
    _cachedStartTime = null; // ✅ 캐시 초기화
    _cachedEndTime = null; // ✅ 캐시 초기화
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
    _cachedStartTime = null; // ✅ 캐시 초기화
    _cachedEndTime = null; // ✅ 캐시 초기화
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
