import 'package:flutter/material.dart';
import '../../const/quick_add_config.dart';

/// QuickDetail 버튼 위젯 (날짜, 시간, 반복 등)
/// 이거를 설정하고 → 아이콘과 텍스트를 조합한 버튼을 만들어서
/// 이거를 해서 → 사용자가 세부 옵션을 클릭하면 모달을 열고
/// 이거는 이래서 → 일정/할일의 상세 정보를 입력할 수 있다
class QuickDetailButton extends StatelessWidget {
  final IconData icon;
  final String? text; // null이면 아이콘만 표시
  final VoidCallback? onTap;
  final bool showIconOnly; // true면 아이콘만 표시 (40×40px)

  const QuickDetailButton({
    Key? key,
    required this.icon,
    this.text,
    this.onTap,
    this.showIconOnly = false,
  }) : super(key: key);

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
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24, // 피그마: icon 24×24px
            color: QuickAddConfig.placeholderText, // #7a7a7a
          ),
        ),
      );
    }

    // ✅ 아이콘 + 텍스트 표시 (피그마: QuickDetail 가변 너비)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: QuickAddConfig.quickDetailSize, // 40px
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24, // 피그마: icon 24×24px
              color: QuickAddConfig.placeholderText, // #7a7a7a
            ),
            if (text != null) ...[
              const SizedBox(width: 4),
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
}
