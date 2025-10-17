/// ✅ Settings Wolt Modal (Detached Style)
///
/// **⚠️ Detached 바텀시트 공통 규칙 (DetachedBottomSheetType에서 자동 적용):**
/// - 좌우 패딩: 16pt (고정)
/// - 하단 위치: 화면 바텀에서 16pt (고정)
/// - 높이: 이 모달의 경우 461px (내부 콘텐츠에 따라 동적 변경 가능)
///
/// **Figma Design Spec:**
///
/// **Frame 864 Container:**
/// - Size: 369 x 461px
/// - Position: bottom: 22px → 16px (DetachedBottomSheetType에서 자동 적용)
/// - Background: #FFFFFF
/// - Box-shadow: 0px -4px 20px rgba(0, 0, 0, 0.05)
/// - Border-radius: 42px
/// - Padding: 36px 0px
/// - Gap: 28px
///
/// **TopNavi:**
/// - Size: 369 x 54px
/// - Padding: 9px 28px
/// - Title "設定": font-weight: 800, font-size: 26px
/// - Two buttons: User icon (36x36), Close button (36x36)
///
/// **Frame 862 (Google Calendar):**
/// - Google カレンダー 連携: font-weight: 700, font-size: 16px
/// - 言語: font-weight: 700, font-size: 16px
///
/// **Frame 863 (色の管理):**
/// - Title "色の管理": font-weight: 700, font-size: 18px
/// - Color items: 26x26 circle + label "目標" (font-size: 13px)
/// - "登録+" button: font-weight: 700, font-size: 13px, color: #999999

import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../design_system/detached_bottom_sheet_type.dart';
import '../../design_system/wolt_typography.dart';

/// Settings Wolt Modal 표시 (페이지 네비게이션 지원)
void showSettingsWoltModal(BuildContext context) {
  WoltModalSheet.show(
    context: context,
    modalTypeBuilder: (_) => DetachedBottomSheetType(),
    barrierDismissible: true,
    // ✅ 배경을 완전히 투명하게 설정
    modalBarrierColor: Colors.transparent,
    pageListBuilder: (context) => [
      // Settings Main Page
      _buildSettingsPage(context),

      // Google Calendar Integration Page
      _buildGoogleCalendarPage(context),
    ],
    onModalDismissedWithBarrierTap: () {
      debugPrint('✅ [SettingsWolt] Modal dismissed');
    },
  );
}

// ========================================
// Settings Page Builder
// ========================================

SliverWoltModalSheetPage _buildSettingsPage(BuildContext context) {
  return SliverWoltModalSheetPage(
    id: 'settings_main_page',
    backgroundColor: Colors.transparent, // 완전 투명 (Container에서 배경 처리)
    mainContentSliversBuilder: (context) => [
      SliverToBoxAdapter(child: _SettingsContent()),
    ],
  );
}

// ========================================
// Google Calendar Page Builder
// ========================================

SliverWoltModalSheetPage _buildGoogleCalendarPage(BuildContext context) {
  return SliverWoltModalSheetPage(
    id: 'google_calendar_page',
    backgroundColor: Colors.transparent,
    mainContentSliversBuilder: (context) => [
      SliverToBoxAdapter(
        child: Container(
          height: 210, // Figma: 210px (OptionSetting height)
          padding: const EdgeInsets.all(0),
          child: const _GoogleCalendarContent(),
        ),
      ),
    ],
  );
}

// ========================================
// Settings Content (Stateful)
// ========================================

class _SettingsContent extends StatefulWidget {
  @override
  State<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<_SettingsContent> {
  // 색상 목록 (Figma 기준)
  final List<ColorItem> _colorItems = [
    ColorItem(color: const Color(0xFF1976D2), label: '目標'),
    ColorItem(color: const Color(0xFFF57C00), label: '目標'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // ===================================================================
      // ⚠️ 이 모달의 높이: 461px (고정)
      // 다른 Detached 모달을 만들 때는 콘텐츠에 맞춰 높이만 변경
      // 좌우 패딩 16pt, 하단 16pt는 DetachedBottomSheetType에서 자동 적용
      // ===================================================================
      // Figma: Frame 864 Container
      // Size: 369 x 461px
      // Padding: 36px 0px
      // Gap: 28px
      // Background: #FFFFFF
      // Border-radius: 42px
      // ===================================================================
      width: 369,
      height: 461, // 💡 이 모달의 높이
      padding: const EdgeInsets.symmetric(
        vertical: 36,
      ), // Figma: padding: 36px 0px
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Figma: background: #FFFFFF
        borderRadius: BorderRadius.circular(42), // Corner radius: 42pt
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Figma: rgba(0, 0, 0, 0.05)
            offset: const Offset(0, -4), // Figma: 0px -4px
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          // ===================================================================
          // TopNavi: "設定" 타이틀 + User icon + 닫기 버튼
          // ===================================================================
          _buildTopNavi(context),

          const SizedBox(height: 28), // Figma: gap: 28px
          // ===================================================================
          // Frame 862: Google Calendar 연동 + 언어 설정
          // ===================================================================
          _buildGoogleCalendarSection(),

          const SizedBox(height: 28), // Figma: gap: 28px
          // ===================================================================
          // Frame 863: 색의 관리
          // ===================================================================
          _buildColorManagementSection(),
        ],
      ),
    );
  }

  /// TopNavi 빌더
  ///
  /// **Figma Spec:**
  /// - Size: 369 x 54px
  /// - Padding: 9px 28px
  /// - Title "設定": font-weight: 800, font-size: 26px
  Widget _buildTopNavi(BuildContext context) {
    return Container(
      width: 369,
      height: 54,
      padding: const EdgeInsets.symmetric(
        horizontal: 28, // Figma: padding: 9px 28px
        vertical: 9,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            CrossAxisAlignment.end, // Figma: align-items: flex-end
        children: [
          // ===================================================================
          // "設定" 타이틀
          // Figma: font-weight: 800, font-size: 26px, line-height: 140%
          // ===================================================================
          Text(
            '設定',
            style: WoltTypography.settingsTitle, // ExtraBold 26px, #111111
          ),

          // ===================================================================
          // Frame 858: User icon + Close button
          // ===================================================================
          Row(
            children: [
              _buildIconButton(
                context,
                Icons.person_outline,
                onTap: () {
                  debugPrint('⚙️ [SettingsWolt] User icon tapped');
                },
              ),
              const SizedBox(width: 12), // Figma: gap: 12px
              _buildIconButton(
                context,
                Icons.close,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Icon 버튼 (User, Close)
  ///
  /// **Figma Spec:**
  /// - Size: 36 x 36px
  /// - Background: rgba(228, 228, 228, 0.9)
  /// - Border: 1px solid rgba(17, 17, 17, 0.02)
  /// - Shadow: 0px -2px 8px rgba(186, 186, 186, 0.08)
  /// - Border radius: 100px
  Widget _buildIconButton(
    BuildContext context,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        padding: const EdgeInsets.all(8), // Figma: padding: 8px
        decoration: BoxDecoration(
          color: const Color(
            0xFFE4E4E4,
          ).withOpacity(0.9), // Figma: rgba(228, 228, 228, 0.9)
          border: Border.all(
            color: const Color(
              0xFF111111,
            ).withOpacity(0.02), // Figma: rgba(17, 17, 17, 0.02)
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFBABABA,
              ).withOpacity(0.08), // Figma: rgba(186, 186, 186, 0.08)
              offset: const Offset(0, -2), // Figma: 0px -2px
              blurRadius: 8,
            ),
          ],
          borderRadius: BorderRadius.circular(
            100,
          ), // Figma: border-radius: 100px
        ),
        child: Icon(
          icon,
          size: 20, // Figma: icon 20px
          color: const Color(0xFF111111),
        ),
      ),
    );
  }

  /// Google Calendar 연동 섹션
  ///
  /// **Figma Spec:**
  /// - Frame 862: gap: 2px
  /// - Frame 859/860: padding: 8px 28px
  Widget _buildGoogleCalendarSection() {
    return SizedBox(
      width: 369,
      height: 78,
      child: Column(
        children: [
          _buildMenuItem(
            title: 'Googleカレンダー 連携',
            icon: Icons.chevron_right,
            onTap: () {
              debugPrint('⚙️ [SettingsWolt] Google Calendar tapped');
              // Wolt Modal 페이지 전환
              WoltModalSheet.of(context).showNext();
            },
          ),
          const SizedBox(height: 2), // Figma: gap: 2px
          _buildMenuItem(
            title: '言語',
            icon: Icons.chevron_right,
            onTap: () {
              debugPrint('⚙️ [SettingsWolt] Language tapped');
            },
          ),
        ],
      ),
    );
  }

  /// 메뉴 아이템
  ///
  /// **Figma Spec:**
  /// - Size: 369 x 38px
  /// - Padding: 8px 28px
  /// - Title: font-weight: 700, font-size: 16px
  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 369,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: WoltTypography.settingsItemTitle, // Bold 16px, #111111
            ),
            Icon(
              icon,
              size: 20, // Figma: icon 20px
              color: const Color(0xFF111111),
            ),
          ],
        ),
      ),
    );
  }

  /// 색의 관리 섹션
  ///
  /// **Figma Spec:**
  /// - Frame 863: gap: 32px
  /// - Frame 861: gap: 8px
  /// - Title "色の管理": font-weight: 700, font-size: 18px
  Widget _buildColorManagementSection() {
    return SizedBox(
      width: 369,
      height: 201,
      child: Column(
        children: [
          // ===================================================================
          // Frame 861: Title + Color list
          // ===================================================================
          SizedBox(
            width: 369,
            height: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title "色の管理"
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 8,
                  ),
                  child: Text(
                    '色の管理',
                    style: const TextStyle(
                      fontFamily: 'LINE Seed JP App_TTF',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      height: 1.4,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                const SizedBox(height: 8), // Figma: gap: 8px
                // Color list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      for (var colorItem in _colorItems)
                        _buildColorItem(colorItem),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32), // Figma: gap: 32px
          // ===================================================================
          // "登録+" 버튼
          // ===================================================================
          _buildAddColorButton(),
        ],
      ),
    );
  }

  /// 색상 아이템
  ///
  /// **Figma Spec:**
  /// - Size: 313 x 42px
  /// - Circle: 26 x 26px
  /// - Label: font-weight: 700, font-size: 13px
  Widget _buildColorItem(ColorItem colorItem) {
    return Container(
      width: 313,
      height: 42,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 색상 원
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: colorItem.color,
              shape: BoxShape.circle,
            ),
          ),

          // 구분선
          Container(
            width: 219,
            height: 0,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(
                    0xFFE3F2FD,
                  ).withOpacity(0.7), // Figma: rgba(227, 242, 253, 0.7)
                  width: 1,
                ),
              ),
            ),
          ),

          // 라벨 + 화살표
          Row(
            children: [
              Text(
                colorItem.label,
                style: const TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.4,
                  letterSpacing: -0.065,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: const Color(
                  0xFF111111,
                ).withOpacity(0.1), // Figma: rgba(17, 17, 17, 0.1)
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "登録+" 버튼
  ///
  /// **Figma Spec:**
  /// - Size: 109 x 34px
  /// - Padding: 8px 16px
  /// - Color circles: 16x16, overlapped
  /// - Text: font-weight: 700, font-size: 13px, color: #999999
  Widget _buildAddColorButton() {
    return GestureDetector(
      onTap: () {
        debugPrint('⚙️ [SettingsWolt] Add color tapped');
      },
      child: Container(
        width: 109,
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 색상 원 3개 겹쳐진 모습
            SizedBox(
              width: 32,
              height: 16,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF57C00),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1976D2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB284FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '登録+',
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.4,
                letterSpacing: -0.065,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Google Calendar Content (Stateful)
// ========================================

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
      // Figma: OptionSetting
      // Size: 364 x 210px
      // Position: bottom 22px (DetachedBottomSheetType에서 처리)
      // Padding: 24px 0px 48px
      // Gap: 20px
      width: 364,
      height: 210,
      padding: const EdgeInsets.only(
        top: 24,
        bottom: 48,
      ), // Figma: padding: 24px 0px 48px
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Figma: background: #FFFFFF
        borderRadius: BorderRadius.circular(36), // Figma: border-radius: 36px
      ),
      child: Column(
        children: [
          // ===================================================================
          // Frame 784 (TopNavi wrapper)
          // Gap: 40px
          // ===================================================================
          _buildTopNavi(context),

          const SizedBox(height: 20), // Figma: gap: 20px (OptionSetting의 gap)
          // ===================================================================
          // Google Login Button
          // ===================================================================
          _buildGoogleLoginButton(),
        ],
      ),
    );
  }

  /// TopNavi
  ///
  /// **Figma Spec:**
  /// - Size: 364 x 54px
  /// - Padding: 9px 28px
  /// - Gap: 205px
  /// - Title "Googleカレンダー連携": font-weight: 700, font-size: 16px, color: #505050
  /// - Close button: 36x36px, icon 20px
  Widget _buildTopNavi(BuildContext context) {
    return Container(
      width: 364,
      height: 54,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 9,
      ), // Figma: padding: 9px 28px
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title "Googleカレンダー連携" (left aligned)
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft, // 좌측 정렬
              child: Text(
                'Googleカレンダー連携',
                style: const TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontWeight: FontWeight.w700, // Bold
                  fontSize: 16, // Figma: 16px
                  height: 1.4, // line-height: 140%
                  letterSpacing: -0.08, // 16px * -0.005em
                  color: Color(0xFF505050), // Figma: #505050
                ),
              ),
            ),
          ),

          // Close button
          _buildIconButton(
            context,
            Icons.close,
            onTap: () {
              debugPrint('⚙️ [GoogleCalendarWolt] Close button tapped');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// Icon Button (Close)
  ///
  /// **Figma Spec (Modal Control Buttons):**
  /// - Size: 36 x 36px
  /// - Padding: 8px
  /// - Icon: 20px, color: #111111
  /// - Background: rgba(228, 228, 228, 0.9)
  /// - Border: 1px solid rgba(17, 17, 17, 0.02)
  /// - border-radius: 100px
  Widget _buildIconButton(
    BuildContext context,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        padding: const EdgeInsets.all(8), // Figma: padding: 8px
        decoration: BoxDecoration(
          color: const Color(
            0xFFE4E4E4,
          ).withOpacity(0.9), // Figma: rgba(228, 228, 228, 0.9)
          border: Border.all(
            color: const Color(
              0xFF111111,
            ).withOpacity(0.02), // Figma: rgba(17, 17, 17, 0.02)
            width: 1,
          ),
          borderRadius: BorderRadius.circular(
            100,
          ), // Figma: border-radius: 100px
        ),
        child: Icon(
          icon,
          size: 20, // Figma: icon 20px
          color: const Color(0xFF111111),
        ),
      ),
    );
  }

  /// Google Login Button
  ///
  /// **Figma Spec (비활성화 상태):**
  /// - Size: 320 x 64px
  /// - Padding: 22px 98px
  /// - Background: #111111
  /// - Border: 1px solid rgba(17, 17, 17, 0.01)
  /// - Box-shadow: 0px 4px 20px rgba(0, 0, 0, 0.05)
  /// - border-radius: 24px
  /// - Text "Google ログイン": font-weight: 700, font-size: 14px, color: #FAFAFA
  ///
  /// **Figma Spec (활성화 상태):**
  /// - Size: 320 x 64px
  /// - Padding: 22px 108px
  /// - Background: #FFFFFF
  /// - Border: 2px radial gradient from center
  ///   - Colors: #EA4235(0%) → #F27F1D → #FABC05 → #34A853 → #4385F5(100%)
  /// - border-radius: 24px
  /// - Text "Google 連携中": font-weight: 700, font-size: 14px, color: #111111
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
        width: 320,
        height: 64,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          children: [
            // Gradient Border (활성화 상태만) - Angular Gradient from center
            if (_isConnecting)
              Container(
                width: 320,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const SweepGradient(
                    center: Alignment.center,
                    startAngle: 0.0,
                    endAngle: 2 * 3.14159, // 360도 회전
                    colors: [
                      Color(0xFFEA4235), // Red (0%)
                      Color(0xFFF27F1D), // Orange
                      Color(0xFFFABC05), // Yellow
                      Color(0xFF34A853), // Green
                      Color(0xFF4385F5), // Blue (100%)
                      Color(0xFFEA4235), // Red (다시 0%로 돌아옴)
                    ],
                    stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                  ),
                ),
              ),

            // Inner Container (버튼 본체)
            Container(
              width: 320,
              height: 64,
              margin: _isConnecting
                  ? const EdgeInsets.all(2) // 활성화: 2px border
                  : EdgeInsets.zero, // 비활성화: border 없음
              padding: EdgeInsets.symmetric(
                horizontal: _isConnecting ? 108 : 98,
                vertical: 22,
              ),
              decoration: BoxDecoration(
                color: _isConnecting
                    ? const Color(0xFFFFFFFF) // 활성화: 흰색 배경
                    : const Color(0xFF111111), // 비활성화: 검은색 배경
                border: _isConnecting
                    ? null
                    : Border.all(
                        color: const Color(0xFF111111).withOpacity(0.01),
                        width: 1,
                      ),
                boxShadow: _isConnecting
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 20,
                        ),
                      ],
                borderRadius: BorderRadius.circular(
                  _isConnecting ? 22 : 24,
                ), // 활성화: 22px (24-2), 비활성화: 24px
              ),
              child: Center(
                child: Text(
                  _isConnecting ? 'Google 連携中' : 'Google ログイン',
                  style: TextStyle(
                    fontFamily: 'LINE Seed JP App_TTF',
                    fontWeight: FontWeight.w700, // Bold (both states)
                    fontSize: 14, // 14px (both states)
                    height: 1.4,
                    letterSpacing: -0.07, // 14px * -0.005em
                    color: _isConnecting
                        ? const Color(0xFF111111) // 활성화: 검은색
                        : const Color(0xFFFAFAFA), // 비활성화: 흰색
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Data Model
// ========================================

class ColorItem {
  final Color color;
  final String label;

  ColorItem({required this.color, required this.label});
}
