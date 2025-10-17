/// 📅 DateDetailView 날짜 헤더 위젯
///
/// Figma 디자인: Frame 830, Frame 893
/// 8月 金曜日 / 11 今日 형태의 날짜 표시 + 설정 버튼
///
/// 이거를 설정하고 → 선택된 날짜를 월/요일/날짜로 분리해서
/// 이거를 해서 → Figma 디자인대로 레이아웃을 구성한다
/// 이거는 이래서 → 사용자가 현재 보고 있는 날짜를 명확히 인식한다

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../design_system/wolt_design_tokens.dart';
import '../design_system/wolt_typography.dart';

class DateDetailHeader extends StatelessWidget {
  final DateTime selectedDate; // 선택된 날짜
  final VoidCallback onSettingsTap; // 설정 버튼 콜백

  const DateDetailHeader({
    super.key,
    required this.selectedDate,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    // 이거를 설정하고 → 오늘 날짜와 비교해서 "今日" 뱃지 표시 여부 결정
    final isToday = _isToday(selectedDate);

    // 이거를 해서 → 월, 요일, 날짜를 일본어로 포맷팅한다
    final monthText = _formatMonth(selectedDate); // "8月"
    final dayOfWeekText = _formatDayOfWeek(selectedDate); // "金曜日"
    final dayNumber = selectedDate.day.toString(); // "11"

    return Container(
      // 이거를 설정하고 → Figma Frame 893의 크기를 그대로 적용
      width: 353,
      height: 80,
      padding: const EdgeInsets.only(left: 12), // 왼쪽 12px
      child: Stack(
        children: [
          // ===================================================================
          // 왼쪽 영역: Frame 830 (월/요일 + 날짜/뱃지)
          // ===================================================================
          Positioned(
            left: 0,
            top: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -----------------------------------------------
                // Frame 823: 월 + 요일 (가로 배치)
                // -----------------------------------------------
                Row(
                  children: [
                    // 이거를 설정하고 → 월 표시를 빨강(#FF4444)으로 강조
                    Text(monthText, style: WoltTypography.monthText),
                    const SizedBox(width: 6), // gap: 6px
                    // 이거를 해서 → 요일 표시를 회색(#999999)으로 구분
                    Text(dayOfWeekText, style: WoltTypography.dayOfWeekText),
                  ],
                ),

                const SizedBox(height: 4), // Frame 830 내부 gap
                // -----------------------------------------------
                // Frame 829: 날짜 숫자 + 뱃지 (가로 배치)
                // -----------------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 이거를 설정하고 → 큰 숫자(48px)로 날짜를 표시
                    Text(dayNumber, style: WoltTypography.dateNumberLarge),

                    const SizedBox(width: 4), // gap: 4px
                    // -----------------------------------------------
                    // Frame 827: "今日" 뱃지 + 아이콘 (세로 배치)
                    // -----------------------------------------------
                    // 이거를 해서 → 오늘 날짜일 때만 뱃지를 표시한다
                    if (isToday) ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // "今日" 텍스트
                          Text('今日', style: WoltTypography.todayBadge),

                          const SizedBox(height: 12), // gap: 12px
                          // 아이콘 (Frame 824)
                          _buildTodayIcon(),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ===================================================================
          // 오른쪽 영역: Frame 892 (설정 버튼)
          // ===================================================================
          Positioned(
            right: 5, // 282px left → 오른쪽 기준 계산
            top: 18,
            child: _buildSettingsButton(),
          ),
        ],
      ),
    );
  }

  // ========================================
  // 헬퍼 함수들
  // ========================================

  /// 이거를 설정하고 → 오늘 날짜인지 확인하는 함수
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 이거를 해서 → 월을 일본어로 포맷팅 (8月)
  String _formatMonth(DateTime date) {
    return '${date.month}月';
  }

  /// 이거를 해서 → 요일을 일본어로 포맷팅 (金曜日)
  String _formatDayOfWeek(DateTime date) {
    final formatter = DateFormat('EEEE', 'ja_JP'); // 일본어 요일
    return formatter.format(date);
  }

  /// "今日" 아이콘 빌더 (Figma: icon 16x16)
  Widget _buildTodayIcon() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        border: Border.all(
          color: WoltDesignTokens.primaryBlack, // #222222
          width: 1.5,
        ),
        shape: BoxShape.circle,
      ),
    );
  }

  /// 설정 버튼 빌더 (Figma: Frame 892, Frame 671)
  /// 이거를 설정하고 → 원형 배경에 톱니바퀴 아이콘을 배치
  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: onSettingsTap,
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(12), // 아이콘 중앙 정렬용
        decoration: WoltDesignTokens.decorationSettingsButton,
        child: Icon(
          Icons.settings,
          size: 26, // 32px 아이콘 크기
          color: WoltDesignTokens.gray300, // #E0E0E0
        ),
      ),
    );
  }
}
