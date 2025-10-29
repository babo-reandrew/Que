/// ✅ TaskCard 위젯 - Figma 완전 동일 구현
///
/// Figma 디자인: Property 1=Task (동적 높이)
/// - 기본: 제목만
/// - Deadline: 제목 + 마감일
/// - Option: 제목 + 리마인드/반복
/// - Deadline_Option: 제목 + 마감일 + 리마인드/반복
///
/// 높이는 컨텐츠에 따라 동적으로 조정됨
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'dart:convert';
import '../Database/schedule_database.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final TaskData task;
  final VoidCallback? onToggle; // 체크박스 토글 콜백
  final VoidCallback? onTap; // 카드 탭 콜백

  const TaskCard({super.key, required this.task, this.onToggle, this.onTap});

  // 리마인더 텍스트 파싱: JSON → "15:30" 형식
  String? _parseReminderText() {
    if (task.reminder.isEmpty) return null;
    try {
      final data = jsonDecode(task.reminder);
      if (data is Map && data.containsKey('display')) {
        return data['display'];
      }
      if (data is Map && data.containsKey('value')) {
        return data['value'];
      }
    } catch (e) {
      // JSON 파싱 실패 시 null 반환
    }
    return null;
  }

  // 반복 텍스트 파싱: JSON → "月か水木" 형식
  String? _parseRepeatText() {
    if (task.repeatRule.isEmpty) return null;
    try {
      final data = jsonDecode(task.repeatRule);
      if (data is Map && data.containsKey('display')) {
        return data['display'];
      }
      if (data is Map && data.containsKey('value')) {
        return data['value'];
      }
    } catch (e) {
      // JSON 파싱 실패 시 null 반환
    }
    return null;
  }

  // 마감일 텍스트 변환 (오늘, 내일, 明日 등)
  String? _getDeadlineText() {
    if (task.dueDate == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );
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
      return DateFormat('M/d').format(task.dueDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderText = _parseReminderText();
    final repeatText = _parseRepeatText();
    final deadlineText = _getDeadlineText();

    return Container(
      width: 345, // Figma: 고정 너비
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 24,
            cornerSmoothing: 0.7, // Figma smoothing 70%
          ),
          side: BorderSide(
            color: const Color(0xFF111111).withOpacity(0.08),
            width: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0xFFBABABA).withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 메인 컨텐츠
          Padding(
            padding: const EdgeInsets.fromLTRB(
              8,
              8,
              48,
              8,
            ), // Figma: padding 8px 48px 8px 8px
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Frame 670: 체크박스 + 제목
                SizedBox(
                  width: 289,
                  height: 40,
                  child: Row(
                    children: [
                      // 체크박스
                      _buildCheckbox(),
                      const SizedBox(width: 4),
                      // 제목
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            color: task.completed
                                ? const Color(0xFF111111).withOpacity(0.3)
                                : const Color(0xFF111111),
                            fontWeight: FontWeight.w800, // extrabold
                            fontFamily: 'LINE Seed JP App_TTF', // 정확한 폰트 패밀리명
                            letterSpacing: -0.005 * 16,
                            height: 1.4, // 행간 140%
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Frame 945: 마감일 + 옵션
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Frame 674: 마감일 배지 (조건부)
                    if (deadlineText != null) ...[
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 42,
                          top: 2,
                          bottom: 4,
                        ),
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFEEEEEE),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            deadlineText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF444444),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'LINESeedJP',
                              letterSpacing: -0.07,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Frame 675: 리마인드 + 반복 (조건부)
                    if (reminderText != null || repeatText != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 42,
                          right: 42,
                          top: 8,
                          bottom: 14,
                        ), // 위 8px, 아래 14px
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Frame 661: 리마인드
                            if (reminderText != null) ...[
                              SvgPicture.asset(
                                'asset/icon/remind_icon.svg',
                                width: 16,
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF505050),
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                reminderText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF505050),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'LINESeedJP',
                                  letterSpacing: -0.055,
                                ),
                              ),
                            ],

                            // Ellipse 100: 구분점
                            if (reminderText != null && repeatText != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF0F0F0),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],

                            // Frame 662: 반복
                            if (repeatText != null) ...[
                              SvgPicture.asset(
                                'asset/icon/repeat_icon.svg',
                                width: 16,
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF505050),
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                repeatText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF505050),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'LINESeedJP',
                                  letterSpacing: -0.055,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 우측 중앙 드래그 아이콘 - 카드의 수직 중앙에 위치
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: SvgPicture.asset(
                  'asset/icon/drag_menu_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFF0F0F0),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 체크박스 (40x40 영역)
  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(4),
        alignment: Alignment.center,
        child: task.completed
            ? Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9FDE9), // #E9FDE9 연한 초록
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'asset/icon/check_box_checked.svg',
                  width: 24,
                  height: 24,
                ),
              )
            : SvgPicture.asset(
                'asset/icon/check_box_icon.svg',
                width: 24,
                height: 24,
              ),
      ),
    );
  }
}
