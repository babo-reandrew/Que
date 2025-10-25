import 'package:flutter/material.dart';

/// Task Inbox 전용 상단 네비게이션 바 (월 텍스트만, 체크 버튼 제외)
/// Figma: TopNavi (393x54px, 좌측 월 표시)
class TaskInboxTopBar extends StatelessWidget {
  final String title; // 기본값: "6月"
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  const TaskInboxTopBar({
    super.key,
    this.title = '6月',
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54, // Figma: 54px
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 9,
      ), // Figma: padding 9px 24px
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F7), // 기존 헤더와 동일
      ),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0 && onSwipeRight != null) {
              onSwipeRight!(); // 우로 스와이프 → 이전 달
            } else if (details.primaryVelocity! < 0 && onSwipeLeft != null) {
              onSwipeLeft!(); // 좌로 스와이프 → 다음 달
            }
          }
        },
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontWeight: FontWeight.w800,
              fontSize: 22, // Figma: 22px
              height: 1.4, // Figma: 140%
              letterSpacing: -0.005 * 22, // Figma: -0.005em
              color: Color(0xFF111111),
            ),
          ),
        ),
      ),
    );
  }
}

/// Task Inbox 체크 버튼 (애니메이션 없이 고정)
class TaskInboxCheckButton extends StatelessWidget {
  final VoidCallback onClose;

  const TaskInboxCheckButton({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        width: 36,
        height: 36,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xE6111111), // rgba(17, 17, 17, 0.9)
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14BABABA), // rgba(186, 186, 186, 0.08)
              offset: Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(Icons.check, size: 20, color: Colors.white),
      ),
    );
  }
}

/// Task Inbox 일간뷰 상단 네비게이션 바 (일 + 요일 표시)
/// 좌측에 일과 요일, 우측은 체크 버튼으로 분리
class TaskInboxDayTopBar extends StatelessWidget {
  final DateTime date; // 표시할 날짜
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  const TaskInboxDayTopBar({
    super.key,
    required this.date,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  String _getWeekdayName(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final weekday = _getWeekdayName(date.weekday);

    return Container(
      height: 54, // Figma: 54px
      padding: const EdgeInsets.only(
        left: 28, // 좌측 28px
        right: 28, // 우측 28px
        top: 9,
        bottom: 9,
      ),
      decoration: const BoxDecoration(color: Color(0xFFF7F7F7)),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0 && onSwipeRight != null) {
              onSwipeRight!(); // 우로 스와이프 → 이전 날
            } else if (details.primaryVelocity! < 0 && onSwipeLeft != null) {
              onSwipeLeft!(); // 좌로 스와이프 → 다음 날
            }
          }
        },
        child: Align(
          alignment: Alignment.centerLeft, // 좌측 정렬
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // 일 (큰 폰트) - Hero 애니메이션
              Hero(
                tag: 'date_number_${date.day}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontFamily: 'LINE Seed JP App_TTF',
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      height: 1.4,
                      letterSpacing: -0.005 * 22,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 요일 (작은 폰트)
              Text(
                weekday,
                style: const TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.4,
                  letterSpacing: -0.005 * 16,
                  color: Color(0xFF909090),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
