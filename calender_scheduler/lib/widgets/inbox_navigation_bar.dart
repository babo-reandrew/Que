import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 🆕 SVG 아이콘을 위한 import

/// Inbox 모드 전용 네비게이션 바 위젯
/// 이거를 설정하고 → 피그마 TopNavi 디자인을 정확히 구현해서
/// 이거를 해서 → 36px 검은 원형 뒤로가기 버튼과 타이틀을 표시하고
/// 이거는 이래서 → 사용자가 Inbox 모드임을 인지하고 쉽게 돌아갈 수 있다
///
/// 피그마 스펙:
/// - 높이: 54px
/// - padding: 9px 24px
/// - 타이틀: 22px ExtraBold, #111111
/// - 뒤로가기 버튼: 36×36px 검은 원형, #111111 90% opacity
class InboxNavigationBar extends StatelessWidget {
  /// 뒤로가기 버튼 클릭 시 실행될 콜백
  final VoidCallback onClose;

  /// Inbox 타이틀 텍스트 (기본값: "6月")
  final String title;

  const InboxNavigationBar({
    super.key,
    required this.onClose,
    this.title = '6月',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54, // 피그마: TopNavi 높이
      padding: const EdgeInsets.symmetric(
        horizontal: 24, // 좌우 24px 여백
        vertical: 9,
      ), // 피그마: padding 9px 24px
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 끝에 배치
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 좌측: 타이틀 (24px 여백에서 시작)
          _buildTitle(),

          // 우측: 뒤로가기 버튼 (24px 여백에서 끝)
          _buildCloseButton(),
        ],
      ),
    );
  }

  /// 타이틀 텍스트 위젯
  /// 피그마: 22px ExtraBold, #111111
  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'LINE Seed JP App_TTF',
        fontSize: 22, // 피그마: 22px
        fontWeight: FontWeight.w800, // ExtraBold
        color: Color(0xFF111111), // 피그마: #111111
        letterSpacing: -0.11, // -0.005em → -0.11px
        height: 1.4, // lineHeight 140%
      ),
    );
  }

  /// 뒤로가기 버튼 (36px 검은 원형)
  /// 피그마: Modal Control Buttons
  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        print('⬅️ [Inbox 네비] 뒤로가기 버튼 클릭');
        onClose();
        print('✅ [Inbox 네비] onClose 콜백 실행 완료');
      },
      child: Container(
        width: 36, // 피그마: 36×36px
        height: 36,
        padding: const EdgeInsets.all(8), // 피그마: padding 8px
        decoration: BoxDecoration(
          color: const Color(
            0xFF111111,
          ).withOpacity(0.9), // 피그마: rgba(17,17,17,0.9)
          borderRadius: BorderRadius.circular(100), // 원형
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBABABA).withOpacity(0.08),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: SvgPicture.asset(
          'asset/icon/exit_icon.svg', // 🆕 exit_icon.svg 사용
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Color(0xFFFFFFFF), // 흰색
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
