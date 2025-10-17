/// 🔁 HabitCard 위젯
///
/// Figma 디자인: Frame 671 (Block - Habit)
/// 체크박스 + 제목 + 시간 + 반복요일, 동적 높이(기본 88px), radius 24px
///
/// 이거를 설정하고 → HabitData를 받아서 카드 UI로 변환하고
/// 이거를 해서 → 알림 시간과 반복 요일을 표시한다
/// 이거는 이래서 → 사용자가 습관의 스케줄을 한눈에 파악할 수 있다

import 'package:flutter/material.dart';
import '../Database/schedule_database.dart';
import '../design_system/wolt_design_tokens.dart';
import '../design_system/typography.dart' as AppTypography;

class HabitCard extends StatelessWidget {
  final HabitData habit; // 습관 데이터
  final bool isCompleted; // 오늘 완료 여부 (HabitCompletion 테이블 확인 필요)
  final VoidCallback? onToggle; // 체크박스 토글 콜백
  final VoidCallback? onTap; // 카드 탭 콜백

  const HabitCard({
    super.key,
    required this.habit,
    this.isCompleted = false,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 345,
        // 이거를 설정하고 → 메타 정보가 있으면 88px, 없으면 56px로 동적 조정
        constraints: const BoxConstraints(minHeight: 56),
        decoration: WoltDesignTokens.decorationHabitCard,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===================================================================
            // 첫 번째 줄: 체크박스 + 제목 + 더보기 (Frame 670)
            // ===================================================================
            Row(
              children: [
                // 체크박스
                _buildCheckbox(),

                const SizedBox(width: 4), // gap: 4px
                // 제목 (ルーティン名)
                // 📝 Typography: AppTypography.bodyLargeBold (15pt w700, 일본어 100% 매치)
                Expanded(
                  child: Text(
                    habit.title,
                    // 이거를 해서 → 완료 상태면 취소선 표시
                    style: isCompleted
                        ? AppTypography.Typography.bodyLargeBold.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: WoltDesignTokens.gray400,
                          )
                        : AppTypography.Typography.bodyLargeBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 더보기 아이콘
                _buildMoreIcon(),
              ],
            ),

            // ===================================================================
            // 두 번째 줄: 시간 + 반복요일 (Frame 675)
            // ===================================================================
            // 이거를 설정하고 → reminder나 repeatRule이 있을 때만 표시
            if (_hasMetaInfo()) ...[
              const SizedBox(height: 6), // 위쪽 간격

              Padding(
                padding: const EdgeInsets.only(left: 38), // 체크박스 너비만큼 들여쓰기
                child: Row(
                  children: [
                    // 알림 시간 (Frame 661: 15:30)
                    // 이거를 해서 → reminder JSON을 파싱해서 시간을 표시
                    if (_getReminderTime() != null) ...[
                      _buildMetaItem(
                        icon: Icons.access_time,
                        text: _getReminderTime()!,
                      ),

                      const SizedBox(width: 8), // Ellipse 100 간격
                      _buildDotSeparator(),
                      const SizedBox(width: 8),
                    ],

                    // 반복 요일 (Frame 662: 月か水木)
                    // 이거를 해서 → repeatRule JSON을 파싱해서 요일을 표시
                    if (_getRepeatDaysText() != null)
                      _buildMetaItem(
                        icon: Icons.repeat,
                        text: _getRepeatDaysText()!,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 6), // 하단 패딩
            ],
          ],
        ),
      ),
    );
  }

  /// 체크박스 빌더 (습관용 - 반복 체크 아이콘)
  /// 이거를 설정하고 → 완료 상태면 체크 표시
  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(
              color: WoltDesignTokens.dividerGray, // #E6E6E6
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          // 이거를 해서 → 완료 상태면 체크 + 반복 아이콘 표시
          child: isCompleted
              ? Stack(
                  children: [
                    // 체크 표시 (Vector)
                    const Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(Icons.check, size: 12, color: Colors.black),
                    ),
                    // 반복 표시 (Vector)
                    const Positioned(
                      left: 0,
                      bottom: 0,
                      child: Icon(Icons.repeat, size: 10, color: Colors.black),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  /// 더보기 아이콘 빌더
  Widget _buildMoreIcon() {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      child: Icon(
        Icons.more_horiz,
        size: 20,
        color: WoltDesignTokens.gray300, // #F0F0F0
      ),
    );
  }

  /// 메타 정보 아이템 빌더 (아이콘 + 텍스트)
  /// 이거를 설정하고 → 알림/반복 정보를 아이콘과 함께 표시
  /// 📝 Typography: AppTypography.labelLargeMedium (11pt w400, 일본어 100% 매치!)
  Widget _buildMetaItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: WoltDesignTokens.gray800, // #505050
        ),
        const SizedBox(width: 2), // gap: 2px
        Text(
          text,
          style: AppTypography.Typography.labelLargeMedium.copyWith(
            color: WoltDesignTokens.gray800, // #505050
          ),
        ),
      ],
    );
  }

  /// 점 구분자 (Ellipse 100)
  Widget _buildDotSeparator() {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: WoltDesignTokens.gray300, // #F0F0F0
        shape: BoxShape.circle,
      ),
    );
  }

  /// 메타 정보가 있는지 확인
  /// 이거를 설정하고 → reminder나 repeatRule이 비어있지 않으면 true
  bool _hasMetaInfo() {
    return habit.reminder.isNotEmpty || habit.repeatRule.isNotEmpty;
  }

  /// reminder JSON에서 시간 추출
  /// 이거를 해서 → "15:30" 형태로 반환 (임시로 간단한 파싱)
  String? _getReminderTime() {
    if (habit.reminder.isEmpty) return null;
    // TODO: JSON 파싱 후 시간 추출 (현재는 임시 데이터 대응)
    try {
      // 간단한 예시: reminder가 "15:30" 같은 문자열이라고 가정
      return habit.reminder.isNotEmpty ? '15:30' : null;
    } catch (e) {
      return null;
    }
  }

  /// repeatRule JSON에서 요일 텍스트 추출
  /// 이거를 해서 → "月か水木" 형태로 반환 (임시로 간단한 파싱)
  String? _getRepeatDaysText() {
    if (habit.repeatRule.isEmpty) return null;
    // TODO: JSON 파싱 후 요일 조합 (현재는 임시 데이터 대응)
    try {
      // 간단한 예시: repeatRule이 "月か水木" 같은 문자열이라고 가정
      return habit.repeatRule.isNotEmpty ? '月か水木' : null;
    } catch (e) {
      return null;
    }
  }
}
