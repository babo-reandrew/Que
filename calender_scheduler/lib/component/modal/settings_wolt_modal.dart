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
      // Settings Main Page (index 0)
      _buildSettingsPage(context),

      // Google Calendar Integration Page (index 1)
      _buildGoogleCalendarPage(context),

      // Language Page (index 2)
      _buildLanguagePage(context),

      // Profile Page (index 3)
      _buildProfilePage(context),

      // Color Management Page (index 4)
      _buildColorManagementPage(context),
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
// 공통 서브 페이지 빌더 (OptionSetting 스타일)
// ========================================

/// 공통 서브 페이지 빌더
///
/// **용도:** 설정 메인에서 각 항목을 눌렀을 때 나오는 서브 페이지
/// **특징:** 364x210px, 라운드 36px, 상단 타이틀 + X 버튼
SliverWoltModalSheetPage _buildSubPage({
  required BuildContext context,
  required String id,
  required String title,
  required Widget content,
  VoidCallback? onClose, // Custom close action
  double bottomPadding = 16, // Custom bottom padding, default 16px
  bool enableDrag = true, // 드래그 가능 여부, default true
  bool resizeToAvoidBottomInset = true, // 키보드에 따라 모달 크기 조정 여부, default true
}) {
  return SliverWoltModalSheetPage(
    id: id,
    backgroundColor: Colors.transparent,
    enableDrag: enableDrag, // 드래그 비활성화 옵션
    resizeToAvoidBottomInset: resizeToAvoidBottomInset, // 하단 고정 옵션
    mainContentSliversBuilder: (context) => [
      SliverToBoxAdapter(
        child: _SubPageContainer(
          title: title,
          content: content,
          onClose: onClose,
          bottomPadding: bottomPadding,
        ),
      ),
    ],
  );
}

// ========================================
// Google Calendar Page Builder
// ========================================

SliverWoltModalSheetPage _buildGoogleCalendarPage(BuildContext context) {
  return _buildSubPage(
    context: context,
    id: 'google_calendar_page',
    title: 'Googleカレンダー連携',
    content: const _GoogleCalendarContent(),
    bottomPadding: 48, // 구글 캘린더는 예외적으로 48px
  );
}

// ========================================
// Language Page Builder
// ========================================

SliverWoltModalSheetPage _buildLanguagePage(BuildContext context) {
  return _buildSubPage(
    context: context,
    id: 'language_page',
    title: '言語',
    content: const _LanguageContent(),
    onClose: () {
      // 언어 페이지에서 X 버튼 클릭 시 설정 메인(index 0)으로 이동
      WoltModalSheet.of(context).showAtIndex(0);
    },
  );
}

// ========================================
// Profile Page Builder
// ========================================

SliverWoltModalSheetPage _buildProfilePage(BuildContext context) {
  return _buildSubPage(
    context: context,
    id: 'profile_page',
    title: 'プロフィール',
    content: const _ProfileContent(),
    bottomPadding: 36, // Figma spec: 36px bottom padding
    onClose: () {
      // 프로필 페이지에서 X 버튼 클릭 시 설정 메인(index 0)으로 이동
      WoltModalSheet.of(context).showAtIndex(0);
    },
  );
}

// ========================================
// Color Management Page Builder
// ========================================

SliverWoltModalSheetPage _buildColorManagementPage(BuildContext context) {
  return _buildSubPage(
    context: context,
    id: 'color_management_page',
    title: '色の管理',
    content: const _ColorRegistrationContent(),
    bottomPadding: 16, // Figma spec: 16px bottom padding
    enableDrag: false, // 드래그 비활성화
    resizeToAvoidBottomInset: true, // ✅ 키보드 높이 감지 활성화
    onClose: () {
      // 색 관리 페이지에서 X 버튼 클릭 시 설정 메인(index 0)으로 이동
      WoltModalSheet.of(context).showAtIndex(0);
    },
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
                  WoltModalSheet.of(context).showAtIndex(3); // 프로필 페이지로 이동
                },
              ),
              const SizedBox(width: 12), // Figma: gap: 12px
              _buildIconButton(
                context,
                Icons.keyboard_arrow_down, // ✅ 아래 화살표 아이콘
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
              // ✅ Wolt Modal 페이지 전환 (2번째 인덱스)
              WoltModalSheet.of(context).showAtIndex(2);
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
      behavior: HitTestBehavior.opaque, // ✅ 전체 영역 터치 가능
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
        WoltModalSheet.of(context).showAtIndex(4); // 색 등록 페이지로 이동
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
    // _SubPageContainer가 이미 Container와 TopNavi를 제공하므로
    // 여기서는 실제 콘텐츠(Google Login Button)만 반환
    return _buildGoogleLoginButton();
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
// 공통 서브 페이지 컨테이너
// ========================================

class _SubPageContainer extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback? onClose; // Custom close action
  final double bottomPadding; // Custom bottom padding

  const _SubPageContainer({
    required this.title,
    required this.content,
    this.onClose,
    this.bottomPadding = 16, // Default: 16px (언어 페이지 등)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Figma: OptionSetting
      // Size: 364px width, height varies by content
      width: 364,
      padding: EdgeInsets.only(
        top: 24,
        bottom: bottomPadding,
      ), // Figma: 24px top, custom bottom
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Auto-size based on content
        children: [
          // TopNavi (타이틀 + 닫기 버튼)
          _buildTopNavi(context),
          const SizedBox(height: 20),
          // 실제 콘텐츠
          content,
        ],
      ),
    );
  }

  Widget _buildTopNavi(BuildContext context) {
    return Container(
      width: 364,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.08,
                  color: Color(0xFF505050),
                ),
              ),
            ),
          ),
          _buildIconButton(
            context,
            Icons.close,
            onTap:
                onClose ??
                () {
                  // Default: go back to previous page
                  WoltModalSheet.of(context).showPrevious();
                },
          ),
        ],
      ),
    );
  }

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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE4E4E4).withOpacity(0.9),
          border: Border.all(
            color: const Color(0xFF111111).withOpacity(0.02),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBABABA).withOpacity(0.08),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF111111)),
      ),
    );
  }
}

// ========================================
// 언어 콘텐츠
// ========================================

class _LanguageContent extends StatefulWidget {
  const _LanguageContent();

  @override
  State<_LanguageContent> createState() => _LanguageContentState();
}

class _LanguageContentState extends State<_LanguageContent> {
  final String _initialLanguage = '日本語'; // 초기 언어 (현재 사용중)
  String _selectedLanguage = '日本語'; // 선택된 언어

  // 언어가 변경되었는지 확인
  bool get _hasLanguageChanged => _selectedLanguage != _initialLanguage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
      ), // 위 20px만 적용 (아래는 Container에서 관리)
      child: Column(
        children: [
          // Language options list (Frame 841)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 321,
              height: 192, // 64px × 3 = 192px
              child: Column(
                children: [
                  _buildLanguageOption(
                    language: '日本語',
                    fontFamily: 'LINE Seed JP App_TTF',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    lineHeight: 1.4, // 140%
                    textWidth: 45,
                    textHeight: 21,
                    iconTop: 20,
                    isFirst: true,
                  ),
                  _buildLanguageOption(
                    language: '한국어',
                    fontFamily: 'Gmarket Sans',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    lineHeight: 1.35, // 135%
                    textWidth: 44,
                    textHeight: 20,
                    iconTop: 20,
                  ),
                  _buildLanguageOption(
                    language: 'English',
                    fontFamily: 'Gilroy-Heavy',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    lineHeight: 1.4, // 140%
                    textWidth: 54,
                    textHeight: 22,
                    iconTop: 20,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 44), // Gap: 44px
          // 完了 button (CTA) - 언어 변경 시 활성화
          GestureDetector(
            onTap: _hasLanguageChanged
                ? () {
                    debugPrint(
                      '⚙️ [SettingsWolt] Language confirmed: $_selectedLanguage',
                    );
                    // TODO: Save language preference
                    WoltModalSheet.of(context).showAtIndex(0);
                  }
                : null, // 비활성화 시 null
            child: Container(
              width: 333,
              height: 56,
              decoration: BoxDecoration(
                color: _hasLanguageChanged
                    ? const Color(0xFF111111) // 활성화: 검은색
                    : const Color(0xFFCCCCCC), // 비활성화: 회색
                border: Border.all(
                  color: const Color(0xFF111111).withOpacity(0.01),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: const Text(
                '完了',
                style: TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.4,
                  letterSpacing: -0.075,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String language,
    required String fontFamily,
    required FontWeight fontWeight,
    required double fontSize,
    required double lineHeight,
    required double textWidth,
    required double textHeight,
    required double iconTop,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = _selectedLanguage == language;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        debugPrint('⚙️ [SettingsWolt] Selected language: $language');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 321,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(
                    color: const Color(0xFF111111).withOpacity(0.1),
                    width: 1,
                  ),
          ),
        ),
        child: Stack(
          children: [
            // Language text (centered) - Figma 스펙 정확히 맞춤
            Positioned(
              left: (321 - textWidth) / 2, // calc(50% - textWidth/2)
              top: (64 - textHeight) / 2, // Vertically centered
              child: SizedBox(
                width: textWidth,
                height: textHeight,
                child: Text(
                  language,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: fontWeight,
                    fontSize: fontSize,
                    height: lineHeight,
                    letterSpacing: -0.005 * fontSize, // -0.005em
                    color: const Color(0xFF111111),
                  ),
                ),
              ),
            ),

            // Radio button - 16×16px, left: 281px (중앙 정렬 보정)
            Positioned(
              left: 281, // 277 + (24-16)/2 = 281 (24px 영역 중앙에 16px 배치)
              top: iconTop + 4, // 20 + (24-16)/2 = 24 (세로 중앙 정렬)
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF111111)
                      : const Color(0xFFFFFFFF),
                  border: Border.all(color: const Color(0xFF111111), width: 2),
                  shape: BoxShape.circle,
                ),
                // Selected 상태일 때 내부 원 표시
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 6, // Inner circle size (16px 기준)
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// プロフィール コンテンツ
// ========================================

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32), // Figma: gap 32px from TopNavi
      child: Column(
        children: [
          // Frame 865: Login info + Sign out button
          Column(
            children: [
              // Login Box (사용자 정보)
              _buildLoginBox(),

              const SizedBox(height: 24), // Figma: gap 24px
              // Sign out Button
              _buildSignOutButton(context),
            ],
          ),
        ],
      ),
    );
  }

  /// Login Box (사용자 정보 표시)
  ///
  /// **Figma Spec:**
  /// - Size: 321 x 72px
  /// - Padding: 8px 12px
  /// - Background: #FFFFFF
  /// - Border: 1px solid rgba(17, 17, 17, 0.1)
  /// - Border radius: 24px
  Widget _buildLoginBox() {
    return Container(
      width: 321,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(
          color: const Color(0xFF111111).withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Profile Image (Rectangle 344)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9), // Figma: #D9D9D9
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          const SizedBox(width: 12), // Figma: gap 12px
          // Email Text
          const Text(
            'user_mail@gmail.com',
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1.4, // 140%
              letterSpacing: -0.065, // 13px * -0.005em
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }

  /// Sign out Button
  ///
  /// **Figma Spec:**
  /// - Size: 98 x 50px (auto width)
  /// - Padding: 16px 20px
  /// - Text "Sign out": font-weight: 700, font-size: 13px, color: #FF0000
  Widget _buildSignOutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('⚙️ [ProfileWolt] Sign out tapped');
        // TODO: Implement sign out logic
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: const Text(
          'Sign out',
          style: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            height: 1.4, // 140%
            letterSpacing: -0.065, // 13px * -0.005em
            color: Color(0xFFFF0000), // Figma: #FF0000 (Red)
          ),
        ),
      ),
    );
  }
}

// ========================================
// 色登録 コンテンツ
// ========================================

class _ColorRegistrationContent extends StatefulWidget {
  const _ColorRegistrationContent();

  @override
  State<_ColorRegistrationContent> createState() =>
      _ColorRegistrationContentState();
}

class _ColorRegistrationContentState extends State<_ColorRegistrationContent> {
  // 선택 가능한 색상들
  final List<Color> _availableColors = const [
    Color(0xFFD22D2D), // Red
    Color(0xFFF57C00), // Orange
    Color(0xFF1976D2), // Blue
    Color(0xFFF7BD11), // Yellow
    Color(0xFF54C8A1), // Green
  ];

  Color _selectedColor = const Color(0xFFD22D2D); // Default: Red
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // TODO: 키보드 자동 활성화 - 나중에 구현
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _focusNode.requestFocus();
    // });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 키보드 높이 감지
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        // 메인 콘텐츠
        Column(
          children: [
            const SizedBox(
              height: 54,
            ), // Figma: gap 54px from TopNavi to content
            // Frame 783: 큰 원 + 작은 원들 (height: 162px)
            Column(
              children: [
                // 큰 색상 원 (90px) + 텍스트
                _buildLargeColorCircle(),

                const SizedBox(height: 40), // Figma: gap 40px
                // 작은 색상 선택 원들 (32px)
                _buildColorPalette(),
              ],
            ),

            const SizedBox(height: 80), // 버튼까지의 공간
            // Hidden TextField for keyboard input (나중에 구현)
            Opacity(
              opacity: 0,
              child: SizedBox(
                width: 1,
                height: 1,
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  autofocus: false, // TODO: 나중에 true로 변경
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    setState(() {}); // 텍스트 변경 시 UI 업데이트
                  },
                  onSubmitted: (value) {
                    _saveColor();
                  },
                ),
              ),
            ),
          ],
        ),

        // 追加する 버튼 - 키보드 위에 고정
        Positioned(
          left: (MediaQuery.of(context).size.width - 333) / 2, // 중앙 정렬
          bottom: keyboardHeight + 16, // 키보드 위 16px
          child: _buildAddButton(context),
        ),
      ],
    );
  }

  void _saveColor() {
    if (_textController.text.isEmpty) return;
    debugPrint(
      '⚙️ [ColorRegistration] Saving color: ${_textController.text} / $_selectedColor',
    );
    // TODO: Save color to database
    WoltModalSheet.of(context).showAtIndex(0); // 설정 메인으로 복귀
  }

  /// 큰 색상 원 (90px) + 입력된 텍스트
  ///
  /// **Figma Spec:**
  /// - Size: 90 x 90px
  /// - Border: 2px solid (선택된 색상)
  /// - Background: 선택된 색상의 밝은 버전
  /// - Text: 19px, weight 700, 중앙 정렬
  Widget _buildLargeColorCircle() {
    return GestureDetector(
      onTap: () {
        debugPrint('⚙️ [ColorRegistration] Large circle tapped');
        // TODO: 별도 색상 선택 모달 표시
      },
      child: SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          children: [
            // 배경 원
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: _selectedColor.withOpacity(0.1), // 밝은 배경
                border: Border.all(color: _selectedColor, width: 2),
                shape: BoxShape.circle,
              ),
            ),
            // 텍스트
            Center(
              child: Text(
                _textController.text.isEmpty ? 'デザイン' : _textController.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                  height: 1.4, // 140%
                  letterSpacing: -0.095, // 19px * -0.005em
                  color: _selectedColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 색상 선택 팔레트 (32px × 5개)
  ///
  /// **Figma Spec:**
  /// - Container: 364 x 32px
  /// - Padding: 0px 0px 0px 157px (중앙 정렬 효과)
  /// - Gap: 16px
  /// - Circle size: 32 x 32px
  Widget _buildColorPalette() {
    return Container(
      width: 364,
      height: 32,
      padding: const EdgeInsets.only(left: 157), // Figma spec
      child: Row(
        children: [
          for (int i = 0; i < _availableColors.length; i++) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = _availableColors[i];
                });
                debugPrint(
                  '⚙️ [ColorRegistration] Color selected: ${_availableColors[i]}',
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _availableColors[i],
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (i < _availableColors.length - 1) const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }

  /// 追加する 버튼 (CTA)
  ///
  /// **Figma Spec:**
  /// - Size: 333 x 56px
  /// - Padding: 10px
  /// - Background: #111111 (항상 활성)
  /// - Border: 1px solid rgba(17, 17, 17, 0.01)
  /// - Border radius: 24px
  /// - Text: "追加する", 15px, weight 700, color #FFFFFF
  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: _saveColor,
      child: Container(
        width: 333,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF111111), // 항상 활성 상태
          border: Border.all(
            color: const Color(0xFF111111).withOpacity(0.01),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: const Text(
          '追加する',
          style: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            height: 1.4, // 140%
            letterSpacing: -0.075, // 15px * -0.005em
            color: Color(0xFFFFFFFF),
          ),
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
