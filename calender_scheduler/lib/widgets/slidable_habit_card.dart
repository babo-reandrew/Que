import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 햅틱 피드백용
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 아이콘용
import '../component/modal/delete_confirmation_modal.dart'; // 🗑️ 삭제 확인 모달 추가
import '../component/modal/delete_repeat_confirmation_modal.dart'; // 🔄 반복 삭제 확인 모달 추가

/// 애플 네이티브 스타일의 재사용 가능한 Slidable 습관 카드 컴포넌트
///
/// 이거를 설정하고 → iOS Reminders 앱처럼 자연스러운 스와이프 제스처를 구현한다
/// 이거를 해서 → 왼쪽 스와이프로 삭제, 오른쪽 스와이프로 완료 기능을 제공한다
/// 이거는 이래서 → 사용자에게 직관적인 UX를 제공하고 햅틱 피드백으로 피드백을 준다
/// 이거라면 → date_detail_view.dart에서 HabitCard를 Slidable로 감싸서 사용한다
///
/// 사용 예시:
/// ```dart
/// SlidableHabitCard(
///   habitId: habit.id,
///   onComplete: () async { /* 완료 로직 */ },
///   onDelete: () async { /* 삭제 로직 */ },
///   child: HabitCard(habit: habit),
/// )
/// ```
class SlidableHabitCard extends StatelessWidget {
  final Widget child; // 실제 습관 카드 위젯
  final int habitId; // 습관 ID
  final String? repeatRule; // 🔄 반복 규칙 (JSON 문자열) - 습관은 대부분 반복 있음
  final Future<void> Function() onComplete; // 완료 처리 콜백
  final Future<void> Function() onDelete; // 삭제 처리 콜백
  final VoidCallback? onTap; // 탭 이벤트 콜백 (선택사항)

  // 선택적 커스터마이징
  final Color? completeColor; // 완료 버튼 색상
  final Color? deleteColor; // 삭제 버튼 색상
  final String? completeLabel; // 완료 버튼 라벨
  final String? deleteLabel; // 삭제 버튼 라벨
  final bool showConfirmDialog; // 삭제 확인 다이얼로그 표시 여부
  final String? groupTag; // 그룹 태그 (한 번에 하나만 열기)
  final bool isCompletedItem; // 🎯 완료박스 아이템 여부 (완료 취소 기능)

  const SlidableHabitCard({
    super.key,
    required this.child,
    required this.habitId,
    this.repeatRule, // 🔄 반복 규칙 추가
    required this.onComplete,
    required this.onDelete,
    this.onTap,
    this.completeColor,
    this.deleteColor,
    this.completeLabel,
    this.deleteLabel,
    this.showConfirmDialog = true, // 기본값: 확인 다이얼로그 표시 (습관 삭제는 신중하게)
    this.groupTag,
    this.isCompletedItem = false, // 🎯 기본값: 일반 아이템 (완료 처리)
  });

  // 삭제 버튼 위젯 생성
  Widget _buildDeleteButton() {
    return Container(
      color: Colors.transparent, // 🎯 배경 완전 투명
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 16, right: 16), // 🎯 카드와 16px 간격
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFF0000),
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'asset/icon/trash_icon.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            Color(0xFFFFFFFF),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  // 완료 버튼 위젯 생성
  Widget _buildCompleteButton() {
    return Container(
      color: Colors.transparent, // 🎯 배경 완전 투명
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(left: 16, right: 16), // 🎯 카드와 16px 간격
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF0CF20C),
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          // 🎯 조건 분기: 완료박스에서는 CheckBack_Icon, 일반에서는 Check_icon
          isCompletedItem
              ? 'asset/icon/CheckBack_Icon.svg'
              : 'asset/icon/Check_icon.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            Color(0xFFFFFFFF),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: ValueKey('habit_$habitId'),

      // 🎯 풀 스와이프 설정 (끝까지 당기면 자동 실행)
      backgroundColor: Colors.transparent, // 배경 투명
      fullSwipeFactor: 0.5, // 50% 이상 스와이프 시 풀 스와이프로 간주
      openAnimationDuration: 250, // 250ms로 빠른 오픈 애니메이션
      closeAnimationDuration: 300, // 300ms로 부드러운 클로즈 애니메이션
      openAnimationCurve: Curves.easeOutCubic, // iOS 네이티브 스타일 곡선
      closeAnimationCurve: Curves.easeInOutCubic, // 부드러운 닫힘
      // 왼쪽에서 오른쪽 스와이프 → 삭제
      leadingActions: [
        SwipeAction(
          performsFirstActionWithFullSwipe: true, // ✅ 끝까지 슬라이드 시 자동 실행
          widthSpace: 84, // 🎯 52px 버튼 + 16px 양쪽 여백 = 84px
          forceAlignmentToBoundary: true,
          nestedAction: SwipeNestedAction(title: "삭제"), // 🎯 네이티브 스타일
          onTap: (handler) async {
            await HapticFeedback.mediumImpact();

            if (showConfirmDialog) {
              bool hasRepeat =
                  repeatRule != null &&
                  repeatRule!.isNotEmpty &&
                  repeatRule != '{}' &&
                  repeatRule != '[]';

              if (hasRepeat) {
                await showDeleteRepeatConfirmationModal(
                  context,
                  onDeleteThis: () async {
                    await onDelete();
                  },
                  onDeleteFuture: () async {
                    await onDelete();
                  },
                  onDeleteAll: () async {
                    await onDelete();
                  },
                );
              } else {
                await showDeleteConfirmationModal(
                  context,
                  onDelete: () async {
                    await onDelete();
                  },
                );
              }
            } else {
              await onDelete();
            }
            handler(false);
          },
          color: Colors.transparent,
          content: _buildDeleteButton(),
        ),
      ],

      // 오른쪽에서 왼쪽 스와이프 → 완료
      trailingActions: [
        SwipeAction(
          performsFirstActionWithFullSwipe: true, // ✅ 끝까지 슬라이드 시 자동 실행
          widthSpace: 84, // 🎯 52px 버튼 + 16px 양쪽 여백 = 84px
          forceAlignmentToBoundary: true,
          nestedAction: SwipeNestedAction(title: "완료"), // 🎯 네이티브 스타일
          onTap: (handler) async {
            await HapticFeedback.lightImpact();
            await onComplete();
            handler(false);
          },
          color: Colors.transparent,
          content: _buildCompleteButton(),
        ),
      ],

      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
