import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ✅ SVG 아이콘 사용
import '../../const/quick_add_config.dart';

/// QuickDetail 버튼 위젯 (날짜, 시간, 반복 등)
/// 이거를 설정하고 → 아이콘과 텍스트를 조합한 버튼을 만들어서
/// 이거를 해서 → 사용자가 세부 옵션을 클릭하면 모달을 열고
/// 이거는 이래서 → 일정/할일의 상세 정보를 입력할 수 있다
class QuickDetailButton extends StatelessWidget {
  final IconData? icon; // Material icon (deprecated, SVG 사용 권장)
  final String? svgPath; // ✅ SVG 아이콘 경로
  final String? text; // null이면 아이콘만 표시
  final VoidCallback? onTap;
  final bool showIconOnly; // true면 아이콘만 표시 (40×40px)
  final Color? selectedColor; // ✅ 선택된 색상 (색상 버튼 전용)

  const QuickDetailButton({
    super.key,
    this.icon,
    this.svgPath, // ✅ SVG 경로 추가
    this.text,
    this.onTap,
    this.showIconOnly = false,
    this.selectedColor, // ✅ 색상 선택 시 전달
  }) : assert(icon != null || svgPath != null, 'icon 또는 svgPath 중 하나는 필수입니다');

  @override
  Widget build(BuildContext context) {
    // 이거를 설정하고 → showIconOnly 플래그로 크기를 결정해서
    // 이거를 해서 → 아이콘만 또는 아이콘+텍스트를 표시한다
    if (showIconOnly) {
      // ✅ 아이콘만 표시 (피그마: QuickDetail 40×40px)
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: QuickAddConfig.quickDetailSize, // 40px
          height: QuickAddConfig.quickDetailSize, // 40px
          padding: const EdgeInsets.all(8), // ✅ Figma: padding 8px
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildIcon(),
        ),
      );
    }

    // ✅ 아이콘 + 텍스트 표시 (피그마: QuickDetail 가변 너비)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: QuickAddConfig.quickDetailSize, // 40px
        padding: const EdgeInsets.all(8), // ✅ Figma: padding 8px
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            if (text != null) ...[
              const SizedBox(width: 2), // ✅ Figma: gap 2px
              Text(
                text!,
                style: QuickAddConfig.quickDetailStyle, // Bold 14px, #7a7a7a
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 아이콘 빌드 (SVG 우선, Material icon 대체)
  Widget _buildIcon() {
    if (svgPath != null) {
      // ✅ 색상 선택 시: Color_Selected_icon.svg로 교체하고 22×22px (padding 1px 보상)
      final isColorSelected = selectedColor != null;
      final effectiveSvgPath = isColorSelected
          ? 'asset/icon/Color_Selected_icon.svg'
          : svgPath!;
      final iconSize = isColorSelected ? 22.0 : 24.0; // 선택 시 2px 축소

      Widget iconWidget = SvgPicture.asset(
        effectiveSvgPath,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(
          isColorSelected ? selectedColor! : QuickAddConfig.placeholderText,
          BlendMode.srcIn,
        ),
      );

      // ✅ 선택 시: 1px padding으로 24×24 크기 유지
      if (isColorSelected) {
        return Padding(padding: const EdgeInsets.all(1), child: iconWidget);
      }

      return iconWidget;
    }

    // Fallback: Material icon
    return Icon(
      icon!,
      size: 24, // 피그마: icon 24×24px
      color: QuickAddConfig.placeholderText, // #7a7a7a
    );
  }
}
