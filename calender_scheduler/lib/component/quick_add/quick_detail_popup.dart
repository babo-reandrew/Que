import 'package:flutter/material.dart';
import '../../design_system/quick_add_design_system.dart';

/// Frame 705 - 타입 선택 팝업 (追加 버튼 클릭 시)
///
/// Figma: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0
///
/// Frame 704 (타입 선택기)가 자연스러운 애니메이션으로 Frame 705로 변환됨
/// - 같은 위치, 크기만 변경: 220×52px → 220×172px
/// - 애플스러운 easing 적용 (easeInOutCubic, 350ms)
class QuickDetailPopup extends StatefulWidget {
  final VoidCallback onScheduleSelected;
  final VoidCallback onTaskSelected;
  final VoidCallback onHabitSelected;

  const QuickDetailPopup({
    Key? key,
    required this.onScheduleSelected,
    required this.onTaskSelected,
    required this.onHabitSelected,
  }) : super(key: key);

  @override
  State<QuickDetailPopup> createState() => _QuickDetailPopupState();
}

class _QuickDetailPopupState extends State<QuickDetailPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Figma 애니메이션: 350ms, easeInOutCubic
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // 높이 애니메이션: 52px → 172px (Frame 704 → Frame 705)
    _heightAnimation = Tween<double>(begin: 52.0, end: 172.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    // 투명도 애니메이션
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // 애니메이션 시작
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 220,
          height: _heightAnimation.value,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 212,
              height: 172,
              padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
              decoration: QuickAddWidgets.typePopupDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPopupItem(
                    icon: Icons.calendar_today,
                    text: QuickAddStrings.typeSchedule,
                    onTap: widget.onScheduleSelected,
                  ),
                  const SizedBox(height: 4),
                  _buildPopupItem(
                    icon: Icons.check_box_outline_blank,
                    text: QuickAddStrings.typeTask,
                    onTap: widget.onTaskSelected,
                  ),
                  const SizedBox(height: 4),
                  _buildPopupItem(
                    icon: Icons.repeat,
                    text: QuickAddStrings.typeHabit,
                    onTap: widget.onHabitSelected,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 190,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF3B3B3B)),
            const SizedBox(width: 12),
            Text(text, style: QuickAddTextStyles.popupItem),
          ],
        ),
      ),
    );
  }
}
