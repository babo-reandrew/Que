/// ✅ Google Calendar Integration Wolt Modal (Detached Style)
///
/// **⚠️ Detached 바텀시트 공통 규칙 (DetachedBottomSheetType에서 자동 적용):**
/// - 좌우 패딩: 16pt (고정)
/// - 하단 위치: 화면 바텀에서 16pt (고정)
/// - 높이: 이 모달의 경우 284px (내부 콘텐츠에 따라 동적 변경 가능)
///
/// **Figma Design Spec:**
///
/// **Frame 873 Container:**
/// - Size: 369 x 284px
/// - border-radius: 42px
/// - background: #FFFFFF
///
/// **Layout Structure:**
/// 1. TopNavi (Frame 872): 56px height
///    - Title: "Googleカレンダー連携" (Bold 20px, #111111)
///    - Close button (우측 상단, 56x56px)
///
/// 2. Google Login Button (Frame 874):
///    - Size: 313 x 58px
///    - border-radius: 100px
///    - background: #111111 (비활성화 상태)
///    - border: 4px gradient (활성화 진행 중 상태)
///    - Text: "Google ログイン" / "Google 連携中"
///    - font-weight: 700, font-size: 18px, color: #FFFFFF
library;

import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../../design_system/detached_bottom_sheet_type.dart';
import '../../design_system/wolt_typography.dart';

/// Google Calendar Integration Modal 표시 함수
void showGoogleCalendarWoltModal(BuildContext context) {
  WoltModalSheet.show(
    context: context,
    modalTypeBuilder: (_) => DetachedBottomSheetType(),
    pageListBuilder: (context) => [
      // Google Calendar Integration Page
      SliverWoltModalSheetPage(
        id: 'google_calendar_page',
        mainContentSliversBuilder: (context) => [
          SliverToBoxAdapter(
            child: Container(
              height: 284, // Figma: 284px
              padding: const EdgeInsets.all(0),
              child: const _GoogleCalendarContent(),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Google Calendar Integration Content
class _GoogleCalendarContent extends StatefulWidget {
  const _GoogleCalendarContent();

  @override
  State<_GoogleCalendarContent> createState() => _GoogleCalendarContentState();
}

class _GoogleCalendarContentState extends State<_GoogleCalendarContent> {
  bool _isConnecting = false; // 연동 진행 중 상태

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 369,
      height: 284,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        children: [
          // ===================================================================
          // TopNavi: Title + Close Button
          // ===================================================================
          _buildTopNavi(context),

          const SizedBox(height: 170), // Figma: gap between TopNavi and Button
          // ===================================================================
          // Google Login Button
          // ===================================================================
          _buildGoogleLoginButton(),
        ],
      ),
    );
  }

  /// TopNavi (Frame 872)
  ///
  /// **Figma Spec:**
  /// - Frame 872: 56px height
  /// - Title: "Googleカレンダー連携" (Bold 20px, #111111)
  /// - Close button: 56x56px, icon 28px
  Widget _buildTopNavi(BuildContext context) {
    return SizedBox(
      width: 369,
      height: 56,
      child: Stack(
        children: [
          // Title: Center aligned
          Center(
            child: Text(
              'Googleカレンダー連携',
              style: WoltTypography.settingsTitle, // Bold 20px, #111111
            ),
          ),

          // Close button: Right aligned
          Positioned(
            right: 0,
            top: 0,
            child: _buildIconButton(
              context,
              Icons.close,
              onTap: () {
                debugPrint('⚙️ [GoogleCalendarWolt] Close button tapped');
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Icon Button (User/Close)
  ///
  /// **Figma Spec:**
  /// - Size: 56 x 56px
  /// - Icon: 28px, color: #111111
  /// - border-radius: 100px
  Widget _buildIconButton(
    BuildContext context,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Icon(
          icon,
          size: 28, // Figma: icon 28px
          color: const Color(0xFF111111),
        ),
      ),
    );
  }

  /// Google Login Button (Frame 874)
  ///
  /// **Figma Spec:**
  /// - Size: 313 x 58px
  /// - border-radius: 100px
  /// - background: #111111 (비활성화 상태)
  /// - border: 4px gradient (활성화 진행 중 상태)
  ///   - Gradient: [#9EE730, #00D1CD, #6B73FF, #FF5A79, #F8B959]
  /// - Text: "Google ログイン" / "Google 連携中"
  /// - font-weight: 700, font-size: 18px, color: #FFFFFF
  Widget _buildGoogleLoginButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isConnecting = !_isConnecting;
        });
        debugPrint(
          '⚙️ [GoogleCalendarWolt] Google Login button tapped: $_isConnecting',
        );
      },
      child: Container(
        width: 313,
        height: 58,
        decoration: _isConnecting
            ? ShapeDecoration(
                color: Colors.white,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 100,
                    cornerSmoothing: 0.6, // Figma Squircle: 60%
                  ),
                  side: const BorderSide(
                    width: 4,
                    color: Colors.transparent, // Gradient will be applied
                  ),
                ),
              )
            : ShapeDecoration(
                color: const Color(0xFF111111), // 비활성화 상태: 검은색 배경
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 100,
                    cornerSmoothing: 0.6, // Figma Squircle: 60%
                  ),
                ),
              ),
        child: Stack(
          children: [
            // Gradient Border (활성화 진행 중 상태만)
            if (_isConnecting)
              Positioned.fill(
                child: Container(
                  decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 100,
                        cornerSmoothing: 0.6,
                      ),
                      side: const BorderSide(
                        width: 4,
                        color: Colors.transparent,
                      ),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF9EE730), // Green
                        Color(0xFF00D1CD), // Cyan
                        Color(0xFF6B73FF), // Blue
                        Color(0xFFFF5A79), // Pink
                        Color(0xFFF8B959), // Orange
                      ],
                      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                  ),
                ),
              ),

            // Inner White Background (활성화 진행 중 상태만)
            if (_isConnecting)
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(4), // Border width
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 96, // 100 - 4 (border width)
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),

            // Text
            Center(
              child: Text(
                _isConnecting ? 'Google 連携中' : 'Google ログイン',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700, // Bold
                  fontSize: 18,
                  color: _isConnecting
                      ? const Color(0xFF111111) // 활성화 진행 중: 검은색 텍스트
                      : Colors.white, // 비활성화: 흰색 텍스트
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
