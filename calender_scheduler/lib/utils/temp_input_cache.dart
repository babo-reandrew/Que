import 'package:shared_preferences/shared_preferences.dart';

/// TempInputCache - 임시 입력 캐시 관리
/// 이거를 설정하고 → SharedPreferences로 임시 입력을 저장/불러오기해서
/// 이거를 해서 → 사용자가 입력만 하고 닫아도 데이터를 보존한다
/// 이거는 이래서 → Figma 디자인(2447-60096)의 캐시 저장 기능을 구현한다
/// 이거라면 → 앱을 다시 열어도 임시 입력을 복원할 수 있다
class TempInputCache {
  static const String _keyTempInput = 'quick_add_temp_input';
  static const String _keyTempTimestamp = 'quick_add_temp_timestamp';
  static const String _keyTempColor = 'quick_add_temp_color';
  static const String _keyTempStartDateTime = 'quick_add_temp_start_datetime';
  static const String _keyTempEndDateTime = 'quick_add_temp_end_datetime';
  static const String _keyTempExecutionDate =
      'task_temp_execution_date'; // ✅ 実行日
  static const String _keyTempDueDate = 'task_temp_due_date'; // ✅ 締め切り
  static const String _keyTempTitle = 'temp_title'; // ✅ 제목
  static const String _keyTempRepeatRule = 'temp_repeat_rule'; // ✅ 반복 규칙

  /// 임시 입력 저장
  /// 이거를 설정하고 → 입력된 텍스트와 타임스탬프를 저장해서
  /// 이거를 해서 → 나중에 복원할 수 있도록 한다
  static Future<void> saveTempInput(String text) async {
    // 이거를 설정하고 → SharedPreferences 인스턴스를 가져와서
    final prefs = await SharedPreferences.getInstance();

    // 이거를 해서 → 텍스트와 현재 시간을 저장한다
    await prefs.setString(_keyTempInput, text);
    await prefs.setInt(
      _keyTempTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );

    print('💾 [TempCache] 임시 입력 저장: "$text"');
  }

  /// 임시 색상 저장
  /// 이거를 설정하고 → 사용자가 선택한 색상 ID를 저장해서
  /// 이거를 해서 → QuickAdd를 다시 열었을 때 색상 상태를 복원한다
  static Future<void> saveTempColor(String colorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTempColor, colorId);
    print('💾 [TempCache] 임시 색상 저장: "$colorId"');
  }

  /// 임시 날짜/시간 저장
  static Future<void> saveTempDateTime(
    DateTime startDateTime,
    DateTime endDateTime,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyTempStartDateTime,
      startDateTime.toIso8601String(),
    );
    await prefs.setString(_keyTempEndDateTime, endDateTime.toIso8601String());
    print('💾 [TempCache] 임시 날짜/시간 저장: $startDateTime ~ $endDateTime');
  }

  /// 임시 실행일 저장
  static Future<void> saveTempExecutionDate(DateTime executionDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyTempExecutionDate,
      executionDate.toIso8601String(),
    );
    print('💾 [TempCache] 임시 실행일 저장: $executionDate');
  }

  /// 임시 마감일 저장
  static Future<void> saveTempDueDate(DateTime dueDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTempDueDate, dueDate.toIso8601String());
    print('💾 [TempCache] 임시 마감일 저장: $dueDate');
  }

  /// 임시 반복 규칙 저장
  static Future<void> saveTempRepeatRule(String repeatRule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTempRepeatRule, repeatRule);
    print('💾 [TempCache] 임시 반복 규칙 저장: $repeatRule');
  }

  /// 임시 입력 불러오기
  /// 이거를 설정하고 → 저장된 임시 입력을 불러와서
  /// 이거를 해서 → 사용자가 이어서 작업할 수 있다
  /// 이거는 이래서 → null이면 저장된 데이터가 없는 것
  static Future<String?> getTempInput() async {
    // 이거를 설정하고 → SharedPreferences 인스턴스를 가져와서
    final prefs = await SharedPreferences.getInstance();

    // 이거를 해서 → 저장된 텍스트를 반환한다
    final text = prefs.getString(_keyTempInput);

    if (text != null && text.isNotEmpty) {
      print('📦 [TempCache] 임시 입력 복원: "$text"');
      return text;
    }

    return null;
  }

  /// 임시 색상 불러오기
  static Future<String?> getTempColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorId = prefs.getString(_keyTempColor);

    if (colorId != null && colorId.isNotEmpty) {
      print('📦 [TempCache] 임시 색상 복원: "$colorId"');
      return colorId;
    }

    return null;
  }

  /// 임시 날짜/시간 불러오기
  static Future<Map<String, DateTime>?> getTempDateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final startStr = prefs.getString(_keyTempStartDateTime);
    final endStr = prefs.getString(_keyTempEndDateTime);

    if (startStr != null && endStr != null) {
      final startDateTime = DateTime.parse(startStr);
      final endDateTime = DateTime.parse(endStr);
      print('📦 [TempCache] 임시 날짜/시간 복원: $startDateTime ~ $endDateTime');
      return {'start': startDateTime, 'end': endDateTime};
    }

    return null;
  }

  /// 임시 실행일 불러오기
  static Future<DateTime?> getTempExecutionDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyTempExecutionDate);

    if (dateStr != null) {
      final executionDate = DateTime.parse(dateStr);
      print('📦 [TempCache] 임시 실행일 복원: $executionDate');
      return executionDate;
    }

    return null;
  }

  /// 임시 마감일 불러오기
  static Future<DateTime?> getTempDueDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyTempDueDate);

    if (dateStr != null) {
      final dueDate = DateTime.parse(dateStr);
      print('📦 [TempCache] 임시 마감일 복원: $dueDate');
      return dueDate;
    }

    return null;
  }

  /// 임시 반복 규칙 불러오기
  static Future<String?> getTempRepeatRule() async {
    final prefs = await SharedPreferences.getInstance();
    final repeatRule = prefs.getString(_keyTempRepeatRule);

    if (repeatRule != null && repeatRule.isNotEmpty) {
      print('📦 [TempCache] 임시 반복 규칙 복원: $repeatRule');
      return repeatRule;
    }

    return null;
  }

  /// 임시 제목 저장
  static Future<void> saveTempTitle(String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTempTitle, title);
    print('💾 [TempCache] 임시 제목 저장: "$title"');
  }

  /// 임시 제목 불러오기
  static Future<String?> getTempTitle() async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString(_keyTempTitle);

    if (title != null && title.isNotEmpty) {
      print('📦 [TempCache] 임시 제목 복원: "$title"');
      return title;
    }

    return null;
  }

  /// 임시 리마인더 저장
  static Future<void> saveTempReminder(String reminder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_reminder', reminder);
    print('💾 [TempCache] 임시 리마인더 저장: "$reminder"');
  }

  /// 임시 리마인더 불러오기
  static Future<String?> getTempReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final reminder = prefs.getString('temp_reminder');

    if (reminder != null && reminder.isNotEmpty) {
      print('📦 [TempCache] 임시 리마인더 복원: "$reminder"');
      return reminder;
    }

    return null;
  }

  /// 임시 입력 삭제
  /// 이거를 설정하고 → 저장된 임시 입력을 삭제해서
  /// 이거를 해서 → 사용자가 저장을 완료하거나 취소했음을 표시한다
  static Future<void> clearTempInput() async {
    // 이거를 설정하고 → SharedPreferences 인스턴스를 가져와서
    final prefs = await SharedPreferences.getInstance();

    // 이거를 해서 → 저장된 데이터를 모두 삭제한다
    await prefs.remove(_keyTempInput);
    await prefs.remove(_keyTempTimestamp);
    await prefs.remove(_keyTempColor);
    await prefs.remove(_keyTempStartDateTime);
    await prefs.remove(_keyTempEndDateTime);
    await prefs.remove(_keyTempExecutionDate);
    await prefs.remove(_keyTempDueDate);
    await prefs.remove(_keyTempTitle);
    await prefs.remove('temp_reminder');
    await prefs.remove(_keyTempRepeatRule); // ✅ 반복 규칙도 삭제

    print('🗑️ [TempCache] 임시 입력 삭제 완료');

    // ✅ 리마인더 기본값(10분전) 설정
    await setDefaultReminder();
  }

  /// 리마인더 기본값(10분전) 설정
  static Future<void> setDefaultReminder() async {
    final defaultReminder = '{"minutes":10,"display":"10分前"}';
    await saveTempReminder(defaultReminder);
    print('✅ [TempCache] 리마인더 기본값(10분전) 설정 완료');
  }

  /// 임시 입력이 있는지 확인
  /// 이거를 설정하고 → 저장된 데이터가 있는지 빠르게 확인해서
  /// 이거를 해서 → UI에서 하단 박스 표시 여부를 결정한다
  static Future<bool> hasTempInput() async {
    // 이거를 설정하고 → SharedPreferences 인스턴스를 가져와서
    final prefs = await SharedPreferences.getInstance();

    // 이거를 해서 → 텍스트가 있고 비어있지 않으면 true 반환
    final text = prefs.getString(_keyTempInput);
    final color = prefs.getString(_keyTempColor);
    return (text != null && text.isNotEmpty) ||
        (color != null && color.isNotEmpty);
  }
}
