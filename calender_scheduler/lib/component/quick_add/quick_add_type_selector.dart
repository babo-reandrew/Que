import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ✅ SVG 아이콘 사용
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
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 🌊 단순화된 구조 - 외부 Container에서 모든 스타일 관리
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1️⃣ 일정 아이콘 (Frame 654)
          _TypeIconButton(
            svgPath: 'asset/icon/Schedule_icon.svg',
            isSelected: selectedType == QuickAddType.schedule,
            onTap: () {
              if (selectedType == QuickAddType.schedule) {
                onTypeSelected(QuickAddType.schedule);
              } else {
                onTypeSelected(QuickAddType.schedule);
              }
            },
          ),

          // 2️⃣ 할일 아이콘 (Frame 655)
          _TypeIconButton(
            svgPath: 'asset/icon/Task_icon.svg',
            isSelected: selectedType == QuickAddType.task,
            onTap: () {
              if (selectedType == QuickAddType.task) {
                onTypeSelected(QuickAddType.task);
              } else {
                onTypeSelected(QuickAddType.task);
              }
            },
          ),

          // 3️⃣ 습관 아이콘 (Frame 656)
          _TypeIconButton(
            svgPath: 'asset/icon/routine_icon.svg',
            isSelected: selectedType == QuickAddType.habit,
            onTap: () {
              if (selectedType == QuickAddType.habit) {
                onTypeSelected(QuickAddType.habit);
              } else {
                onTypeSelected(QuickAddType.habit);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// 개별 타입 아이콘 버튼 위젯
/// ✅ Figma: Frame 654/655/656 (52×48px, padding 12px 14px)
class _TypeIconButton extends StatelessWidget {
  final String svgPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeIconButton({
    required this.svgPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Figma: 52×48px 터치 영역, padding 12px 14px
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, // Figma: Frame 654/655/656 width
        height: 48, // Figma: Frame 654/655/656 height
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SvgPicture.asset(
          svgPath,
          width: 24, // Figma: icon 크기 24×24px
          height: 24,
          // ✅ SVG 색상 변경: 선택 시 검은색, 미선택 시 회색
          colorFilter: ColorFilter.mode(
            isSelected
                ? const Color(0xFF262626) // 선택: #262626 (SVG 원본 색상과 동일)
                : const Color(
                    0xFFBABABA,
                  ).withOpacity(0.54), // 미선택: rgba(186,186,186,0.54)
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
