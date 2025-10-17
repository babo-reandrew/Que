/// ✅ OptionSetting 바텀시트
///
/// Figma 디자인: OptionSetting
/// 앱바 좌측 메뉴(⋯) 또는 날짜 헤더 우측 설정 아이콘 클릭 시 표시
///
/// 이거를 설정하고 → "設定" 타이틀과 닫기 버튼을 표시하고
/// 이거를 해서 → "時間ガイド表示" 토글 스위치를 제공한다
/// 이거는 이래서 → 사용자가 시간 가이드 표시 여부를 제어할 수 있다

import 'package:flutter/material.dart';
import '../design_system/wolt_design_tokens.dart';
import '../design_system/wolt_typography.dart';

class OptionSettingBottomSheet extends StatefulWidget {
  const OptionSettingBottomSheet({super.key});

  @override
  State<OptionSettingBottomSheet> createState() =>
      _OptionSettingBottomSheetState();
}

class _OptionSettingBottomSheetState extends State<OptionSettingBottomSheet> {
  bool _showTimeGuide = false; // 시간 가이드 표시 상태

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 364,
      height: 246,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
      ),
      padding: const EdgeInsets.only(top: 32, bottom: 60),
      child: Column(
        children: [
          // ===================================================================
          // TopNavi: "設定" 타이틀 + 닫기 버튼
          // ===================================================================
          _buildTopNav(context),

          const SizedBox(height: 40),

          // ===================================================================
          // Setting/ToggleInfo: "時間ガイド表示" + 토글 스위치
          // ===================================================================
          _buildToggleInfo(),
        ],
      ),
    );
  }

  /// TopNavi: "設定" 타이틀 + 닫기 버튼
  /// Figma: TopNavi
  /// flex-direction: row, justify-content: space-between, padding: 9px 24px, gap: 205px
  Widget _buildTopNav(BuildContext context) {
    return Container(
      width: 369,
      height: 54,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 9, bottom: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // "設定" 타이틀
          Text('設定', style: WoltTypography.settingsTitle),

          // 닫기 버튼 (Modal Control Buttons)
          _buildCloseButton(context),
        ],
      ),
    );
  }

  /// 닫기 버튼
  /// Figma: Modal Control Buttons
  /// width: 36px, height: 36px, background: rgba(228, 228, 228, 0.9), border-radius: 100px
  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 36,
        height: 36,
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
        padding: const EdgeInsets.all(8),
        child: const Icon(Icons.close, size: 20, color: Color(0xFF111111)),
      ),
    );
  }

  /// Setting/ToggleInfo: "時間ガイド表示" + 토글 스위치
  /// Figma: Setting/ToggleInfo
  /// flex-direction: row, gap: 24px, width: 321px, height: 60px
  Widget _buildToggleInfo() {
    return Container(
      width: 321,
      height: 60,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 좌측: 텍스트 정보 (Frame 534)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "時間ガイド表示" 제목
                Text('時間ガイド表示', style: WoltTypography.settingsItemTitle),

                const SizedBox(height: 8),

                // 설명 텍스트
                Text(
                  'スケジュールが表示される時間領域に、\n具体的な時間ガイドラインが表示されます。',
                  style: WoltTypography.settingsItemDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // 우측: 토글 스위치 (Frame 721)
          _buildToggleSwitch(),
        ],
      ),
    );
  }

  /// 커스텀 토글 스위치
  /// Figma: Togle_Off
  /// width: 40px, height: 24px, background: #E4E4E4, border-radius: 100px
  Widget _buildToggleSwitch() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showTimeGuide = !_showTimeGuide;
        });
        print('⚙️ [OptionSetting] 시간 가이드 표시: $_showTimeGuide');
      },
      child: Container(
        width: 40,
        height: 24,
        decoration: BoxDecoration(
          color: _showTimeGuide
              ? WoltDesignTokens.primaryBlack
              : const Color(0xFFE4E4E4),
          border: Border.all(color: const Color(0xFFE4E4E4), width: 1),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          children: [
            // 토글 원형 버튼 (Ellipse 149)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: _showTimeGuide ? 20 : 4, // ON: 50%, OFF: 10%
              top: 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
