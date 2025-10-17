/// ⚙️ SettingsBottomSheet 위젯
///
/// Figma 디자인: OptionSetting
/// 시간 가이드 표시 토글 등 앱 설정 화면
///
/// 이거를 설정하고 → 바텀시트 형태로 설정 옵션을 표시하고
/// 이거를 해서 → 사용자가 앱 동작을 커스터마이징할 수 있다

import 'package:flutter/material.dart';
import '../design_system/wolt_design_tokens.dart';
import '../design_system/wolt_typography.dart';

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({super.key});

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  // 이거를 설정하고 → 시간 가이드 표시 상태를 관리
  bool _showTimeGuide = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      // 이거를 설정하고 → Figma 디자인대로 크기와 위치 설정
      width: 364,
      height: 246,
      margin: const EdgeInsets.only(bottom: 21), // 하단 21px 여백
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(WoltDesignTokens.radiusBottomSheet),
      ),
      child: Column(
        children: [
          // ===================================================================
          // TopNavi: "設定" 제목 + 닫기 버튼
          // ===================================================================
          _buildTopNavi(context),

          const SizedBox(height: 40), // gap: 40px
          // ===================================================================
          // 설정 항목 리스트 (Frame 865)
          // ===================================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSettingItem(
              title: '時間ガイド表示',
              description: 'スケジュールが表示される時間領域に、\n具体的な時間ガイドラインが表示されます。',
              value: _showTimeGuide,
              onChanged: (value) {
                setState(() {
                  _showTimeGuide = value;
                });
                // TODO: 설정 저장 로직 추가
                print('⚙️ [Settings] 시간 가이드 표시: $value');
              },
            ),
          ),

          const SizedBox(height: 60), // 하단 패딩
        ],
      ),
    );
  }

  /// TopNavi 빌더
  /// 이거를 설정하고 → "設定" 제목을 중앙에 배치하고 닫기 버튼 추가
  Widget _buildTopNavi(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽 빈 공간 (대칭을 위해)
          const SizedBox(width: 36),

          // 중앙 제목
          Text('設定', style: WoltTypography.settingsTitle),

          // 오른쪽 닫기 버튼
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: WoltDesignTokens.modalClose, // rgba(228, 228, 228, 0.9)
                border: Border.all(color: WoltDesignTokens.border02, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBABABA).withOpacity(0.08),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.close,
                size: 20,
                color: WoltDesignTokens.primaryBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 설정 항목 빌더 (Setting/ToggleInfo)
  /// 이거를 설정하고 → 제목 + 설명 + 토글 스위치를 배치
  Widget _buildSettingItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================================================
        // 왼쪽: 제목 + 설명 (Frame 534)
        // ===================================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: WoltTypography.settingsItemTitle),
              const SizedBox(height: 8), // gap: 8px
              Text(
                description,
                style: WoltTypography.settingsItemDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: 24), // gap: 24px
        // ===================================================================
        // 오른쪽: 토글 스위치 (Frame 721)
        // ===================================================================
        _buildToggleSwitch(value: value, onChanged: onChanged),
      ],
    );
  }

  /// 토글 스위치 빌더 (Togle_Off / Togle_On)
  /// 이거를 설정하고 → Figma 디자인대로 커스텀 토글 스위치 생성
  Widget _buildToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 40,
        height: 24,
        decoration: BoxDecoration(
          color: value
              ? WoltDesignTokens
                    .primaryBlack // ON: 검정
              : WoltDesignTokens.gray300, // OFF: 회색
          border: Border.all(
            color: value
                ? WoltDesignTokens.primaryBlack
                : WoltDesignTokens.gray300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedAlign(
          // 이거를 해서 → 토글 상태에 따라 Thumb 위치 애니메이션
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: WoltDesignTokens.gray100, // #FAFAFA
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
