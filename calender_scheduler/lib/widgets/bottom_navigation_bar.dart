import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:dotted_border/dotted_border.dart';

/// 하단 네비게이션 바 (피그마: Frame 822)
/// 이거를 설정하고 → 피그마 디자인을 정확히 구현해서
/// 이거를 해서 → Inbox, 별, 더하기 버튼을 표시하고
/// 이거는 이래서 → 사용자가 빠르게 액션을 실행할 수 있다
/// 이거라면 → 모든 화면에서 일관된 네비게이션을 제공한다
class CustomBottomNavigationBar extends StatelessWidget {
  final VoidCallback onInboxTap;
  final VoidCallback onAddTap;
  final VoidCallback onImageAddTap; // 이미지 추가 버튼

  const CustomBottomNavigationBar({
    super.key,
    required this.onInboxTap,
    required this.onAddTap,
    required this.onImageAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🎨 배경 레이어: 그라데이션
        Positioned.fill(
          child: Container(
            width: 393,
            height: 104,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00FAFAFA), // 상단 0% #FAFAFA (투명)
                  Color(0xFFBABABA), // 하단 100% #BABABA (불투명)
                ],
              ),
            ),
          ),
        ),
        // 📱 버튼 컨테이너 (Frame 822)
        SizedBox(
          width: 393,
          height: 104,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 40, // 하단에서 40px
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1️⃣ Inbox 버튼 (피그마: Bottom_Navigation, 112×56px)
                  _buildInboxButton(),

                  // 간격
                  const Spacer(),

                  // 2️⃣ 이미지 추가 버튼 (피그마: Bottom_Navigation, 56×56px, 점선 테두리)
                  _buildImageAddButton(),

                  const SizedBox(width: 6),

                  // 3️⃣ 더하기 버튼 (피그마: Bottom_Navigation, 56×56px)
                  _buildAddButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    ); // Stack 닫기
  }

  /// Inbox 버튼 (피그마: 116×56px, #fefdfd, 라운드 스무싱 60%)
  Widget _buildInboxButton() {
    return GestureDetector(
      onTap: onInboxTap,
      child: Hero(
        tag: 'inbox-to-filter', // ✅ Hero 태그로 필터바와 연결
        child: Container(
          width: 116, // 피그마: width
          height: 56, // 피그마: height
          decoration: ShapeDecoration(
            color: const Color(0xFFFEFDFD), // 피그마: #fefdfd
            shape: SmoothRectangleBorder(
              side: BorderSide(
                color: const Color(
                  0xFF111111,
                ).withOpacity(0.08), // rgba(17, 17, 17, 0.08)
                width: 1,
              ),
              borderRadius: SmoothBorderRadius(
                cornerRadius: 24, // 피그마: cornerRadius 24px
                cornerSmoothing: 0.6, // ✅ 라운드 스무싱 60%
              ),
            ),
            shadows: [
              BoxShadow(
                color: const Color(
                  0xFFBABABA,
                ).withOpacity(0.08), // rgba(186, 186, 186, 0.08)
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(
                  0xFF111111,
                ).withOpacity(0.02), // rgba(17, 17, 17, 0.02) = 2%
                offset: const Offset(0, 4),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ SVG 아이콘 (24×24px)
                SvgPicture.asset(
                  'asset/icon/Inbox.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF222222),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                // ✅ "ヒキダシ" 텍스트 (LINE Seed JP App)
                const Text(
                  'ヒキダシ',
                  style: TextStyle(
                    fontFamily: 'LINE Seed JP App_TTF',
                    fontWeight: FontWeight.w800, // 800 = ExtraBold
                    fontSize: 11,
                    height: 1.4, // line-height: 140%
                    letterSpacing: -0.005 * 11, // -0.005em
                    color: Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ), // Center 닫기
        ), // Hero 닫기
      ), // Container 닫기
    ); // GestureDetector 닫기
  }

  /// 이미지 추가 버튼 (피그마: 56×56px, 점선 테두리 #a6a9c3, 라운드 스무싱 60%)
  Widget _buildImageAddButton() {
    return GestureDetector(
      onTap: onImageAddTap,
      child: SizedBox(
        width: 56, // ✅ 전체 크기 고정
        height: 56,
        child: DottedBorder(
          color: const Color(0xFFA6A9C3), // 피그마: 점선 색상 #a6a9c3
          strokeWidth: 1.5, // 피그마: 1.5px center
          dashPattern: const [0.1, 4], // 피그마: dash 0.1, gap 4
          strokeCap: StrokeCap.round, // 피그마: dash cap round
          borderType: BorderType.RRect,
          radius: const Radius.circular(24), // 피그마: cornerRadius 24px
          padding: EdgeInsets.zero, // ✅ 패딩 제거
          child: Container(
            decoration: ShapeDecoration(
              color: const Color(0xFFFEFDFD), // 피그마: #fefdfd
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 24, // 피그마: cornerRadius 24px
                  cornerSmoothing: 0.6, // ✅ 라운드 스무싱 60%
                ),
              ),
              shadows: [
                BoxShadow(
                  color: const Color(
                    0xFFBABABA,
                  ).withOpacity(0.08), // rgba(186, 186, 186, 0.08)
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              // ✅ 이미지 추가 SVG 아이콘 (24×24px)
              child: SvgPicture.asset(
                'asset/icon/Image_Add.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF3B4582), // Vector 색상
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 더하기 버튼 (피그마: 56×56px, #222222, 라운드 스무싱 60%)
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAddTap,
      child: Container(
        width: 56, // 피그마: width
        height: 56, // 피그마: height
        decoration: ShapeDecoration(
          color: const Color(0xFF222222), // 피그마: #222222 (Black_Add)
          shape: SmoothRectangleBorder(
            side: BorderSide(
              color: const Color(
                0xFF111111,
              ).withOpacity(0.08), // rgba(17, 17, 17, 0.08)
              width: 1,
            ),
            borderRadius: SmoothBorderRadius(
              cornerRadius: 24, // 피그마: cornerRadius 24px
              cornerSmoothing: 0.6, // ✅ 라운드 스무싱 60%
            ),
          ),
          shadows: [
            BoxShadow(
              color: const Color(
                0xFFBABABA,
              ).withOpacity(0.08), // rgba(186, 186, 186, 0.08)
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          // ✅ SVG 더하기 아이콘 (24×24px, #EEEEEE)
          child: SvgPicture.asset(
            'asset/icon/Add_Icon.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFFEEEEEE), // 피그마: #EEEEEE
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
