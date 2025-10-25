import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../design_system/quick_add_design_system.dart';

/// Frame 653 - 타입 선택 팝업 (追加 버튼 클릭 시)
///
/// Figma: https://www.figma.com/design/yIPyfmQsxbZYonWnxQoCB0?node-id=2318-7933
///
/// **Figma Design Spec:**
/// - Container: 212×172px
/// - Padding: 10px 12px 10px 10px
/// - Gap: 4px
/// - Background: #FFFFFF
/// - Border: 1px solid rgba(17, 17, 17, 0.1)
/// - Shadow: 0px 2px 8px rgba(186, 186, 186, 0.08)
/// - Border radius: 24px
///
/// **Item (Frame 650/651/652):**
/// - Size: 190×48px
/// - Padding: 12px 16px
/// - Gap: 12px
/// - Icon: 24×24px
/// - Text: Bold 14px, #262626
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
              width: 212, // Figma: Frame 653
              height: 172,
              padding: const EdgeInsets.fromLTRB(10, 10, 12, 10), // Figma 스펙
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF), // Figma: #FFFFFF
                border: Border.all(
                  color: const Color(
                    0xFF111111,
                  ).withOpacity(0.1), // Figma: rgba(17, 17, 17, 0.1)
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(24), // Figma: 24px
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(
                      186,
                      186,
                      186,
                      0.08,
                    ), // Figma: rgba(186, 186, 186, 0.08)
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Frame 650: 今日のスケジュール
                  _buildPopupItem(
                    svgPath: 'asset/icon/Schedule_icon.svg',
                    text: '今日のスケジュール', // Figma 텍스트
                    onTap: widget.onScheduleSelected,
                  ),
                  const SizedBox(height: 4), // Figma: gap 4px
                  // Frame 651: タスク
                  _buildPopupItem(
                    svgPath: 'asset/icon/Task_icon.svg',
                    text: 'タスク', // Figma 텍스트
                    onTap: widget.onTaskSelected,
                  ),
                  const SizedBox(height: 4), // Figma: gap 4px
                  // Frame 652: ルーティン
                  _buildPopupItem(
                    svgPath: 'asset/icon/routine_icon.svg',
                    text: 'ルーティン', // Figma 텍스트
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
    required String svgPath,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 190, // Figma: Frame 650/651/652
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Figma: 12px 16px
        child: Row(
          children: [
            // Figma: icon 24×24px
            SvgPicture.asset(
              svgPath,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF3B3B3B), // Figma: border 1.7px solid #3B3B3B
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12), // Figma: gap 12px
            // Figma: Bold 14px, #262626
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 14,
                fontWeight: FontWeight.w700, // Bold
                height: 1.4, // line-height: 140%
                letterSpacing: -0.005 * 14, // -0.005em
                color: Color(0xFF262626),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
