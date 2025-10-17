/// ✅ CompletedSection 위젯
///
/// Figma 디자인: Complete_ActionData
/// 완료된 항목들을 모아두는 접기/펴기 가능한 섹션
///
/// 이거를 설정하고 → "完了" 텍스트와 드롭다운 아이콘을 표시하고
/// 이거를 해서 → 탭하면 완료된 항목 리스트를 보여준다
/// 이거는 이래서 → Hero 애니메이션으로 전체 화면 확장이 가능하다

import 'package:flutter/material.dart';
import '../design_system/wolt_design_tokens.dart';
import '../design_system/wolt_typography.dart';

class CompletedSection extends StatelessWidget {
  final int completedCount; // 완료된 항목 개수
  final VoidCallback? onTap; // 탭 콜백 (확장/축소)
  final bool isExpanded; // 확장 상태

  const CompletedSection({
    super.key,
    required this.completedCount,
    this.onTap,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // 이거를 설정하고 → Container로 완료 섹션 UI 구성 (Hero는 상위에서 관리)
      child: Container(
        width: 345,
        height: 56,
        decoration: WoltDesignTokens.decorationCompletedSection,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // ===================================================================
            // "完了" 텍스트
            // ===================================================================
            Text('完了', style: WoltTypography.completedSectionText),

            // 이거를 해서 → 개수를 표시 (예: "完了 (3)")
            if (completedCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '($completedCount)',
                style: WoltTypography.completedSectionText.copyWith(
                  color: WoltDesignTokens.gray800,
                ),
              ),
            ],

            const Spacer(),

            // ===================================================================
            // 드롭다운 아이콘
            // ===================================================================
            Icon(
              // 이거를 설정하고 → 확장 상태에 따라 아이콘 회전
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 24,
              color: WoltDesignTokens.primaryBlack, // #111111
            ),
          ],
        ),
      ),
    );
  }
}
