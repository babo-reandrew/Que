import 'package:flutter/material.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';

/// 🔥 ULTRATHINK: 전체 박스의 상단 절대 위치 고정!
/// 이거를 설정하고 → 추가 버튼 누르면 전체 입력박스의 상단 위치(top)를 고정해서
/// 이거를 해서 → 키보드가 내려가도 박스 상단은 화면 상단에서 그 거리를 유지하고
/// 이거는 이래서 → 타입선택기 등이 그 고정된 박스 아래에 뜬다!
class QuickAddKeyboardTracker extends StatefulWidget {
  final Widget child;
  final bool isLocked; // 🔥 외부에서 제어하는 고정 상태

  const QuickAddKeyboardTracker({
    super.key,
    required this.child,
    this.isLocked = false,
  });

  @override
  State<QuickAddKeyboardTracker> createState() =>
      _QuickAddKeyboardTrackerState();
}

class _QuickAddKeyboardTrackerState extends State<QuickAddKeyboardTracker> {
  final KeyboardHeightPlugin _keyboardPlugin = KeyboardHeightPlugin();
  double _currentKeyboardHeight = 0;

  @override
  void initState() {
    super.initState();

    // 🔥 키보드 높이 실시간 감지
    _keyboardPlugin.onKeyboardHeightChanged((double height) {
      if (mounted && !widget.isLocked) {
        setState(() {
          _currentKeyboardHeight = height;
        });
        debugPrint('🎹 [KeyboardTracker] 키보드 높이: $height');
      }
    });
  }

  @override
  void didUpdateWidget(QuickAddKeyboardTracker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 고정/해제 상태 변경 로그
    if (!oldWidget.isLocked && widget.isLocked) {
      debugPrint('🔒 [KeyboardTracker] 위치 고정 모드 활성화');
    }

    if (oldWidget.isLocked && !widget.isLocked) {
      debugPrint('🔓 [KeyboardTracker] 위치 고정 모드 해제');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 항상 하단 기준으로 배치
    // 일반 모드: 키보드 높이만큼 위로 올림
    // 고정 모드: 키보드 높이 - 184px (타입 선택기 높이)
    final bottomDistance = widget.isLocked
        ? (_currentKeyboardHeight - 184.0).clamp(0.0, double.infinity)
        : _currentKeyboardHeight;

    debugPrint(
      '📍 [KeyboardTracker] ${widget.isLocked ? "고정" : "일반"} 모드 - bottom: $bottomDistance',
    );

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomDistance,
      child: AnimatedContainer(
        // 고정 모드로 전환될 때는 애니메이션 없이 즉시 이동
        duration: widget.isLocked
            ? Duration.zero
            : const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
