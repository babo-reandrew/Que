/// ✅ OptionSetting Wolt Modal (Detached Style)
///
/// **⚠️ Detached 바텀시트 공통 규칙 (DetachedBottomSheetType에서 자동 적용):**
/// - 좌우 패딩: 16pt (고정)
/// - 하단 위치: 화면 바텀에서 16pt (고정)
/// - 높이: 이 모달의 경우 246px (내부 콘텐츠에 따라 동적 변경 가능)
///
/// **Figma Design Spec:**
///
/// **OptionSetting Container:**
/// - Size: 364 x 246px
/// - Position: bottom: 16px (DetachedBottomSheetType에서 자동 적용), centered horizontally
/// - Background: #FFFFFF
/// - Border radius: 36px
/// - Padding: 32px 0px 60px
/// - Gap: 40px
///
/// **TopNavi:**
/// - Size: 369 x 54px
/// - Padding: 9px 24px
/// - Gap: 205px (justify-content: space-between)
/// - Title "設定": font-weight: 800, font-size: 26px, line-height: 140%, color: #111111
/// - Close button: 36x36px, background: rgba(228, 228, 228, 0.9), border-radius: 100px
///
/// **Setting/ToggleInfo:**
/// - Size: 321 x 60px
/// - Gap: 24px
/// - Title: font-weight: 700, font-size: 16px, line-height: 140%, color: #111111
/// - Description: font-weight: 400, font-size: 11px, line-height: 140%, color: #AAAAAA
/// - Toggle: 40 x 24px, border-radius: 100px
library;

import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../design_system/detached_bottom_sheet_type.dart';
import '../../design_system/wolt_typography.dart';

/// OptionSetting Wolt Modal 표시
void showOptionSettingWoltModal(BuildContext context) {
  WoltModalSheet.show(
    context: context,
    modalTypeBuilder: (_) => DetachedBottomSheetType(),
    barrierDismissible: true,
    // ✅ 배경을 완전히 투명하게 설정
    modalBarrierColor: Colors.transparent,
    pageListBuilder: (context) => [_buildOptionSettingPage(context)],
    onModalDismissedWithBarrierTap: () {
      debugPrint('✅ [OptionSettingWolt] Modal dismissed');
    },
  );
}

// ========================================
// Option Setting Page Builder
// ========================================

SliverWoltModalSheetPage _buildOptionSettingPage(BuildContext context) {
  return SliverWoltModalSheetPage(
    backgroundColor: Colors.transparent, // 완전 투명 (Container에서 배경 처리)
    mainContentSliversBuilder: (context) => [
      SliverToBoxAdapter(child: _OptionSettingContent()),
    ],
  );
}

// ========================================
// Option Setting Content (Stateful)
// ========================================

class _OptionSettingContent extends StatefulWidget {
  @override
  State<_OptionSettingContent> createState() => _OptionSettingContentState();
}

class _OptionSettingContentState extends State<_OptionSettingContent> {
  bool _showTimeGuide = false; // 시간 가이드 표시 상태

  @override
  Widget build(BuildContext context) {
    return Container(
      // ===================================================================
      // ⚠️ 이 모달의 높이: 246px (고정)
      // 다른 Detached 모달을 만들 때는 콘텐츠에 맞춰 높이만 변경
      // 좌우 패딩 16pt, 하단 16pt는 DetachedBottomSheetType에서 자동 적용
      // ===================================================================
      // Figma: OptionSetting Container
      // Size: 364 x 246px
      // Padding: 32px 0px 60px
      // Gap: 40px
      // Background: #FFFFFF
      // Border-radius: 36px
      // ===================================================================
      width: 364,
      height: 246, // 💡 이 모달의 높이 (다른 모달은 콘텐츠에 따라 변경 가능)
      padding: const EdgeInsets.only(
        top: 32, // Figma CSS: padding-top: 32px
        bottom: 60, // Figma CSS: padding-bottom: 60px
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Figma: background: #FFFFFF
        borderRadius: BorderRadius.circular(42), // Corner radius: 42pt
      ),
      child: Column(
        children: [
          // ===================================================================
          // TopNavi: "設定" 타이틀 + 닫기 버튼
          // ===================================================================
          _buildTopNavi(context),

          const SizedBox(height: 40), // Figma: gap: 40px
          // ===================================================================
          // Frame 865: Setting/ToggleInfo
          // ===================================================================
          _buildSettingToggleInfo(),
        ],
      ),
    );
  }

  /// TopNavi 빌더
  ///
  /// **Figma Spec:**
  /// - Size: 369 x 54px
  /// - Padding: 9px 24px
  /// - Gap: 205px (justify-content: space-between)
  Widget _buildTopNavi(BuildContext context) {
    return Container(
      width: 369,
      height: 54,
      padding: const EdgeInsets.symmetric(
        horizontal: 24, // Figma: padding: 9px 24px
        vertical: 9,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Figma: gap: 205px
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
          // 닫기 버튼 (Modal Control Buttons)
          // ===================================================================
          _buildCloseButton(context),
        ],
      ),
    );
  }

  /// 닫기 버튼
  ///
  /// **Figma Spec:**
  /// - Size: 36 x 36px
  /// - Background: rgba(228, 228, 228, 0.9)
  /// - Border: 1px solid rgba(17, 17, 17, 0.02)
  /// - Shadow: 0px -2px 8px rgba(186, 186, 186, 0.08)
  /// - Border radius: 100px
  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
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
        child: const Icon(
          Icons.close,
          size: 20, // Figma: icon 20px
          color: Color(0xFF111111),
        ),
      ),
    );
  }

  /// Setting/ToggleInfo 빌더
  ///
  /// **Figma Spec:**
  /// - Size: 321 x 60px
  /// - Gap: 24px
  Widget _buildSettingToggleInfo() {
    return SizedBox(
      width: 321,
      height: 60,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Figma: align-items: flex-start
        children: [
          // ===================================================================
          // Frame 534: 텍스트 정보
          // ===================================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "時間ガイド表示" 제목
                // Figma: font-weight: 700, font-size: 16px, line-height: 140%
                Text(
                  '時間ガイド表示',
                  style: WoltTypography.settingsItemTitle, // Bold 16px, #111111
                ),

                const SizedBox(height: 8), // Figma: gap: 8px
                // 설명 텍스트
                // Figma: font-weight: 400, font-size: 11px, line-height: 140%
                Text(
                  'スケジュールが表示される時間領域に、\n具体的な時間ガイドラインが表示されます。',
                  style: WoltTypography
                      .settingsItemDescription, // Regular 11px, #AAAAAA
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),

          const SizedBox(width: 24), // Figma: gap: 24px
          // ===================================================================
          // Frame 721: 토글 스위치
          // ===================================================================
          _buildToggleSwitch(),
        ],
      ),
    );
  }

  /// 커스텀 토글 스위치
  ///
  /// **Figma Spec:**
  /// - Size: 40 x 24px
  /// - Background (OFF): #E4E4E4
  /// - Background (ON): #111111
  /// - Border: 1px solid #E4E4E4
  /// - Border radius: 100px
  /// - Toggle circle: 16 x 16px, left: 10% (OFF), 50% (ON)
  Widget _buildToggleSwitch() {
    return Container(
      width: 40,
      height: 26, // Figma: Frame 721 height: 26px (1px padding)
      padding: const EdgeInsets.symmetric(
        vertical: 1,
      ), // Figma: padding: 1px 0px
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showTimeGuide = !_showTimeGuide;
          });
          debugPrint('⚙️ [OptionSettingWolt] 시간 가이드 표시: $_showTimeGuide');
        },
        child: Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            // Figma: background: #E4E4E4 (OFF), #111111 (ON)
            color: _showTimeGuide
                ? const Color(0xFF111111) // ON: 검은색
                : const Color(0xFFE4E4E4), // OFF: 회색
            border: Border.all(
              color: const Color(
                0xFFE4E4E4,
              ), // Figma: border: 1px solid #E4E4E4
              width: 1,
            ),
            borderRadius: BorderRadius.circular(
              100,
            ), // Figma: border-radius: 100px (완전한 라운드)
          ),
          child: Stack(
            children: [
              // ===================================================================
              // Ellipse 149: 토글 원형 버튼
              // Figma: 16 x 16px, left: 10% (OFF), 50% (ON)
              // ===================================================================
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                // Figma: left: 10% (OFF) = 4px, right: 50% (ON) = 20px
                left: _showTimeGuide ? 20 : 4,
                top: 4, // Figma: top: 4px (중앙 정렬)
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA), // Figma: background: #FAFAFA
                    shape: BoxShape.circle, // 완전한 원형
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
