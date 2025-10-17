import 'package:shared_preferences/shared_preferences.dart';

/// TempInputCache - 임시 입력 캐시 관리
/// 이거를 설정하고 → SharedPreferences로 임시 입력을 저장/불러오기해서
/// 이거를 해서 → 사용자가 입력만 하고 닫아도 데이터를 보존한다
/// 이거는 이래서 → Figma 디자인(2447-60096)의 캐시 저장 기능을 구현한다
/// 이거라면 → 앱을 다시 열어도 임시 입력을 복원할 수 있다
class TempInputCache {
  static const String _keyTempInput = 'quick_add_temp_input';
  static const String _keyTempTimestamp = 'quick_add_temp_timestamp';

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

  /// 임시 입력 삭제
  /// 이거를 설정하고 → 저장된 임시 입력을 삭제해서
  /// 이거를 해서 → 사용자가 저장을 완료하거나 취소했음을 표시한다
  static Future<void> clearTempInput() async {
    // 이거를 설정하고 → SharedPreferences 인스턴스를 가져와서
    final prefs = await SharedPreferences.getInstance();

    // 이거를 해서 → 저장된 데이터를 모두 삭제한다
    await prefs.remove(_keyTempInput);
    await prefs.remove(_keyTempTimestamp);

    print('🗑️ [TempCache] 임시 입력 삭제 완료');
  }

  /// 임시 입력이 있는지 확인
  /// 이거를 설정하고 → 저장된 데이터가 있는지 빠르게 확인해서
  /// 이거를 해서 → UI에서 하단 박스 표시 여부를 결정한다
  static Future<bool> hasTempInput() async {
    // 이거를 설정하고 → SharedPreferences 인스턴스를 가져와서
    final prefs = await SharedPreferences.getInstance();

    // 이거를 해서 → 텍스트가 있고 비어있지 않으면 true 반환
    final text = prefs.getString(_keyTempInput);
    return text != null && text.isNotEmpty;
  }
}
