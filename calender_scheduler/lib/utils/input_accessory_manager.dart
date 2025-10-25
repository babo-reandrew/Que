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
    Key? key,
    required this.child,
    this.isLocked = false,
  }) : super(key: key);

  @override
  State<QuickAddKeyboardTracker> createState() =>
      _QuickAddKeyboardTrackerState();
}

class _QuickAddKeyboardTrackerState extends State<QuickAddKeyboardTracker> {
  final KeyboardHeightPlugin _keyboardPlugin = KeyboardHeightPlugin();
  double _currentKeyboardHeight = 0;
  double? _lockedTopPosition; // 🔥 고정된 상단 위치 (화면 상단부터 박스 상단까지)

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

    // 🔥 고정 상태로 전환되면 현재 박스 상단의 절대 위치를 저장!
    if (!oldWidget.isLocked && widget.isLocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && mounted) {
          final position = renderBox.localToGlobal(Offset.zero);
          setState(() {
            _lockedTopPosition = position.dy; // 화면 상단부터 박스 상단까지의 거리
          });
          debugPrint(
            '🔒 [KeyboardTracker] 박스 상단 위치 고정! top: $_lockedTopPosition',
          );
        }
      });
    }

    // 🔥 고정 해제 시 위치 초기화
    if (oldWidget.isLocked && !widget.isLocked) {
      setState(() {
        _lockedTopPosition = null;
      });
      debugPrint('🔓 [KeyboardTracker] 위치 고정 해제!');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 고정 상태일 때: 절대 top 위치로 배치
    if (widget.isLocked && _lockedTopPosition != null) {
      debugPrint('📍 [KeyboardTracker] 고정 모드 - top: $_lockedTopPosition');

      return Positioned(
        left: 0,
        right: 0,
        top: _lockedTopPosition, // 화면 상단에서 고정된 위치 유지
        child: widget.child,
      );
    }

    // 🔥 일반 상태: 키보드 위에 배치 (여백 없이 순수 키보드 높이만)
    final bottomDistance = _currentKeyboardHeight;
    debugPrint('📍 [KeyboardTracker] 일반 모드 - bottom: $bottomDistance');

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomDistance,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
