import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS 시뮬레이터에서 햅틱 에러를 방지하는 헬퍼
class HapticHelper {
  // 시뮬레이터 감지 (실제 기기에서는 햅틱 실행)
  static bool get _shouldRunHaptic {
    // Web/Desktop은 햅틱 지원 안 함
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      return false;
    }
    
    // iOS 실제 기기에서만 실행 (시뮬레이터에서는 에러 방지)
    // 실제로는 시뮬레이터/기기 구분이 어려우므로, 
    // 에러를 방지하려면 try-catch로 처리
    return true;
  }

  static Future<void> lightImpact() async {
    if (!_shouldRunHaptic) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // 시뮬레이터 에러 무시
      debugPrint('🔇 [Haptic] Light impact 스킵 (시뮬레이터)');
    }
  }

  static Future<void> mediumImpact() async {
    if (!_shouldRunHaptic) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('🔇 [Haptic] Medium impact 스킵 (시뮬레이터)');
    }
  }

  static Future<void> heavyImpact() async {
    if (!_shouldRunHaptic) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('🔇 [Haptic] Heavy impact 스킵 (시뮬레이터)');
    }
  }

  static Future<void> selectionClick() async {
    if (!_shouldRunHaptic) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('🔇 [Haptic] Selection click 스킵 (시뮬레이터)');
    }
  }
}
