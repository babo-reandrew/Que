/// ✅ TaskCard 위젯 - Figma 완전 동일 구현
///
/// Figma 디자인: Property 1=Task (4가지 변형)
/// - Basic: 56px (제목만)
/// - Deadline: 100px (제목 + 마감일)
/// - Option: 88px (제목 + 리마인드/반복)
/// - Deadline_Option: 132px (제목 + 마감일 + 리마인드/반복)
///
/// 이거를 설정하고 → 할일 카드를 동적 높이로 표시하고
/// 이거를 해서 → 체크박스 클릭으로 완료 처리한다
/// 이거는 이래서 → 마감일, 리마인드, 반복 정보를 조건부로 표시한다

import 'package:flutter/material.dart';
import '../Database/schedule_database.dart';
import '../design_system/wolt_typography.dart';
import '../design_system/typography.dart' as AppTypography;
import '../const/color.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final TaskData task;
  final VoidCallback? onToggle; // 체크박스 토글 콜백
  final VoidCallback? onTap; // 카드 탭 콜백

  const TaskCard({super.key, required this.task, this.onToggle, this.onTap});

  @override
  Widget build(BuildContext context) {
    // 이거를 설정하고 → 마감일, 리마인드, 반복 여부 체크
    final hasDueDate = task.dueDate != null;
    final hasReminder = task.reminder.isNotEmpty;
    final hasRepeat = task.repeatRule.isNotEmpty;

    // 이거를 해서 → 동적 높이 계산 (Figma 디자인)
    final cardHeight = _calculateHeight(hasDueDate, hasReminder, hasRepeat);

    // ✅ GestureDetector 제거 - SlidableTaskCard에서 처리
    return Container(
      width: 345,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF111111).withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBABABA).withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
        borderRadius: BorderRadius.circular(hasDueDate ? 24 : 19),
      ),
      child: Stack(
        children: [
          // ===============================================
          // 우측 상단 더보기 아이콘 (Frame 665)
          // ===============================================
          Positioned(
            right: 20,
            top: 16,
            child: Icon(
              Icons.more_horiz,
              size: 24,
              color: const Color(0xFFF0F0F0),
            ),
          ),

          // ===============================================
          // Frame 671: 메인 콘텐츠
          // ===============================================
          Positioned(
            left: 8,
            top: 8,
            right: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Frame 670: 체크박스 + 제목
                _buildTitleRow(),

                // Frame 674: 마감일 (조건부)
                if (hasDueDate) ...[
                  const SizedBox(height: 4),
                  _buildDeadlineRow(),
                ],

                // Frame 675: 리마인드 + 반복 (조건부)
                if (hasReminder || hasRepeat) ...[
                  const SizedBox(height: 6),
                  _buildOptionRow(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 동적 높이 계산 (Figma 디자인)
  /// Basic: 56px, Deadline: 100px, Option: 88px, Deadline_Option: 132px
  double _calculateHeight(bool hasDueDate, bool hasReminder, bool hasRepeat) {
    if (hasDueDate && (hasReminder || hasRepeat)) {
      return 132; // Deadline_Option
    } else if (hasDueDate) {
      return 100; // Deadline
    } else if (hasReminder || hasRepeat) {
      return 88; // Option
    } else {
      return 56; // Basic
    }
  }

  /// Frame 670: 체크박스 + 제목
  Widget _buildTitleRow() {
    return SizedBox(
      width: 289,
      height: 40,
      child: Row(
        children: [
          // Check: 체크박스 (40x40)
          _buildCheckbox(),

          const SizedBox(width: 4), // gap: 4px
          // タスク名: 제목
          Expanded(
            child: Text(
              task.title,
              style: task.completed
                  ? WoltTypography.cardTitleCompleted
                  : WoltTypography.cardTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Check: 체크박스 (40x40)
  /// 이거를 설정하고 → 카테고리 색상으로 테두리(border) 표시
  Widget _buildCheckbox() {
    // 이거를 해서 → 카테고리 색상 가져오기
    final categoryColor = categoryColorMap[task.colorId] ?? categoryGray;

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
            // 완료 시: 카테고리 색상 채우기, 미완료 시: 투명
            color: task.completed ? categoryColor : Colors.transparent,
            border: Border.all(
              // 미완료 시: 테두리 15% 투명도, 완료 시: 100% 불투명
              color: task.completed
                  ? categoryColor
                  : categoryColor.withOpacity(0.15),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: task.completed
              ? Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  /// Frame 674: 마감일 배지 (조건부)
  Widget _buildDeadlineRow() {
    if (task.dueDate == null) return const SizedBox.shrink();

    final deadlineText = _getDeadlineText(task.dueDate!);

    return Padding(
      padding: const EdgeInsets.only(left: 38), // padding: 4px 0px 4px 38px
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          deadlineText,
          style: AppTypography.Typography.bodyMediumBold.copyWith(
            color: const Color(0xFF444444),
          ),
        ),
      ),
    );
  }

  /// Frame 675: 리마인드 + 반복 (조건부)
  Widget _buildOptionRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 38), // padding: 6px 38px (좌우만)
      child: Row(
        children: [
          // Frame 661: 리마인드 (조건부)
          if (task.reminder.isNotEmpty) ...[
            _buildReminderTag(task.reminder),
            const SizedBox(width: 8), // gap: 8px
          ],

          // Ellipse 100: 구분점 (리마인드 + 반복 둘 다 있을 때)
          if (task.reminder.isNotEmpty && task.repeatRule.isNotEmpty) ...[
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8), // gap: 8px
          ],

          // Frame 662: 반복 (조건부)
          if (task.repeatRule.isNotEmpty) _buildRepeatTag(task.repeatRule),
        ],
      ),
    );
  }

  /// Frame 661: 리마인드 아이콘 + 시간
  Widget _buildReminderTag(String reminder) {
    return Row(
      children: [
        Icon(
          Icons.notifications_none,
          size: 16,
          color: const Color(0xFF505050),
        ),
        const SizedBox(width: 2), // gap: 2px
        Text(
          reminder,
          style: AppTypography.Typography.labelLargeMedium.copyWith(
            color: const Color(0xFF505050),
          ),
        ),
      ],
    );
  }

  /// Frame 662: 반복 아이콘 + 텍스트
  Widget _buildRepeatTag(String repeatRule) {
    return Row(
      children: [
        Icon(Icons.sync, size: 16, color: const Color(0xFF505050)),
        const SizedBox(width: 2), // gap: 2px
        Text(
          repeatRule,
          style: AppTypography.Typography.labelLargeMedium.copyWith(
            color: const Color(0xFF505050),
          ),
        ),
      ],
    );
  }

  /// 마감일 텍스트 변환 (오늘, 내일, D-3 등)
  String _getDeadlineText(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return '今日'; // 오늘
    } else if (difference == 1) {
      return '明日'; // 내일
    } else if (difference == -1) {
      return '昨日'; // 어제
    } else if (difference > 1 && difference <= 7) {
      return 'D-$difference';
    } else {
      return DateFormat('M/d').format(dueDate);
    }
  }
}
