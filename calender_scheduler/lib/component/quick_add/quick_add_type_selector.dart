import 'package:flutter/material.dart';
import '../../const/quick_add_config.dart';

/// Quick_Add 하단 타입 선택 위젯 (일정/할일/습관)
/// 이거를 설정하고 → 3개의 아이콘 버튼을 가로로 배치해서
/// 이거를 해서 → 사용자가 일정/할일/습관 중 하나를 선택하고
/// 이거는 이래서 → 선택된 타입에 따라 Quick_Add_ControlBox가 확장된다
/// 이거라면 → 타입별 입력 UI가 동적으로 표시된다
class QuickAddTypeSelector extends StatelessWidget {
  final QuickAddType? selectedType;
  final Function(QuickAddType) onTypeSelected;

  const QuickAddTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 이거를 설정하고 → Frame 704 (Figma: 212×52px, radius 34px)
    // 이거를 해서 → 3개의 아이콘을 수평으로 배치한다
    // 이거는 이래서 → 사용자가 쉽게 타입을 선택할 수 있다
    return Container(
      width: 212, // Figma: Frame 704 width
      height: 52, // Figma: Frame 704 height
      decoration: BoxDecoration(
        color: QuickAddConfig.controlBoxBackground, // Figma: #FFFFFF
        border: Border.all(
          color: const Color(
            0xFF111111,
          ).withOpacity(0.1), // Figma: rgba(17,17,17,0.1)
          width: 1,
        ),
        borderRadius: BorderRadius.circular(34), // Figma: 34px
        // Figma: 0px 2px 8px rgba(186,186,186,0.08)
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBABABA).withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      // Figma: padding 2px 20px
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Figma: gap 8px
        children: [
          // 1️⃣ 일정 아이콘 (Frame 654)
          _TypeIconButton(
            icon: Icons.calendar_today_outlined,
            isSelected: selectedType == QuickAddType.schedule,
            onTap: () {
              print('📅 [타입 선택] 일정 선택됨');
              onTypeSelected(QuickAddType.schedule);
            },
          ),

          // 2️⃣ 할일 아이콘 (Frame 655)
          _TypeIconButton(
            icon: Icons.check_box_outline_blank,
            isSelected: selectedType == QuickAddType.task,
            onTap: () {
              print('✅ [타입 선택] 할일 선택됨');
              onTypeSelected(QuickAddType.task);
            },
          ),

          // 3️⃣ 습관 아이콘 (Frame 656)
          _TypeIconButton(
            icon: Icons.repeat,
            isSelected: selectedType == QuickAddType.habit,
            onTap: () {
              print('🔄 [타입 선택] 습관 선택됨');
              onTypeSelected(QuickAddType.habit);
            },
          ),
        ],
      ),
    );
  }
}

/// 개별 타입 아이콘 버튼 위젯
/// 이거를 설정하고 → 52×48px 크기의 아이콘 버튼을 만들어서
/// 이거를 해서 → 선택 상태에 따라 시각적 피드백을 제공한다
class _TypeIconButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeIconButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 이거를 설정하고 → 52×48px 터치 영역을 설정해서
    // 이거를 해서 → 아이콘을 중앙에 배치한다
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, // Figma: Frame 654/655/656 width
        height: 48, // Figma: Frame 654/655/656 height
        // Figma: padding 12px 14px
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 24, // Figma: icon 크기 24×24px
          // Figma: border 2px solid rgba(186,186,186,0.54)
          color: const Color(0xFFBABABA).withOpacity(0.54),
        ),
      ),
    );
  }
}
