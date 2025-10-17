import 'package:flutter/material.dart';
import '../design_system/typography.dart' as AppTypography; // ✅ Typography 시스템

/// 하단 네비게이션 바 (피그마: Frame 822)
/// 이거를 설정하고 → 피그마 디자인을 정확히 구현해서
/// 이거를 해서 → Inbox, 별, 더하기 버튼을 표시하고
/// 이거는 이래서 → 사용자가 빠르게 액션을 실행할 수 있다
/// 이거라면 → 모든 화면에서 일관된 네비게이션을 제공한다
class CustomBottomNavigationBar extends StatelessWidget {
  final VoidCallback onInboxTap;
  final VoidCallback onStarTap;
  final VoidCallback onAddTap;
  final bool isStarSelected; // 별 버튼 선택 상태

  const CustomBottomNavigationBar({
    Key? key,
    required this.onInboxTap,
    required this.onStarTap,
    required this.onAddTap,
    this.isStarSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 393, // 피그마: Frame 822 width
      height: 104, // 피그마: Frame 834 height (그라데이션 포함)
      decoration: BoxDecoration(
        // ✅ 피그마: 그라데이션 배경
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00FAFAFA), // #fafafa00
            Color(0x1FBABABA), // #bababa1f
          ],
        ),
        border: const Border(
          top: BorderSide(
            color: Color(0x14BABABA), // #bababa opacity 8%
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 0,
          bottom: 48, // Home Indicator 공간 확보
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1️⃣ Inbox 버튼 (피그마: Bottom_Navigation, 112×56px)
            _buildInboxButton(),

            // 간격
            const Spacer(),

            // 2️⃣ 별 버튼 (피그마: Bottom_Navigation, 56×56px)
            _buildStarButton(),

            const SizedBox(width: 8),

            // 3️⃣ 더하기 버튼 (피그마: Bottom_Navigation, 56×56px)
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  /// Inbox 버튼 (피그마: 112×56px, #fefdfd)
  Widget _buildInboxButton() {
    return GestureDetector(
      onTap: onInboxTap,
      child: Container(
        width: 112, // 피그마: width
        height: 56, // 피그마: height
        decoration: BoxDecoration(
          color: const Color(0xFFFEFDFD), // 피그마: #fefdfd
          border: Border.all(
            color: const Color(0xFF111111).withOpacity(0.08), // opacity 8%
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24), // 피그마: cornerRadius 24px
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Feather 아이콘 (24×24px)
            const Icon(
              Icons.inbox_outlined, // feather 스타일 아이콘
              size: 24,
              color: Color(0xFF222222),
            ),
            const SizedBox(width: 8),
            // ✅ "Inbox" 텍스트
            Text(
              'Inbox',
              style: AppTypography.Typography.labelLargeBold.copyWith(
                color: const Color(0xFF222222), // #222222
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 별 버튼 (피그마: 56×56px, 선택 시 테두리 #a6a9c3)
  Widget _buildStarButton() {
    return GestureDetector(
      onTap: onStarTap,
      child: Container(
        width: 56, // 피그마: width
        height: 56, // 피그마: height
        decoration: BoxDecoration(
          color: const Color(0xFFFEFDFD), // 피그마: #fefdfd
          border: Border.all(
            // ✅ 선택 시: #a6a9c3, 비선택 시: transparent
            color: isStarSelected
                ? const Color(0xFFA6A9C3)
                : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24), // 피그마: cornerRadius 24px
        ),
        child: Center(
          // ✅ 별 아이콘 (SVG 대신 Flutter 아이콘 사용)
          child: Icon(
            isStarSelected ? Icons.star : Icons.star_border,
            size: 24,
            color: isStarSelected
                ? const Color(0xFFA6A9C3)
                : const Color(0xFF222222),
          ),
        ),
      ),
    );
  }

  /// 더하기 버튼 (피그마: 56×56px, #222222)
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAddTap,
      child: Container(
        width: 56, // 피그마: width
        height: 56, // 피그마: height
        decoration: BoxDecoration(
          color: const Color(0xFF222222), // 피그마: #222222 (활성 상태)
          border: Border.all(
            color: const Color(0xFF111111).withOpacity(0.08), // opacity 8%
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24), // 피그마: cornerRadius 24px
        ),
        child: const Center(
          // ✅ 더하기 아이콘 (24×24px, 흰색)
          child: Icon(
            Icons.add,
            size: 24,
            color: Color(0xFFFFFFFF), // 흰색
          ),
        ),
      ),
    );
  }
}
