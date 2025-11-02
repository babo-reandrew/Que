import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 햅틱 피드백용
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 아이콘용
import '../component/modal/delete_confirmation_modal.dart'; // 🗑️ 삭제 확인 모달 추가
import '../component/modal/delete_repeat_confirmation_modal.dart'; // 🔄 반복 삭제 확인 모달 추가

/// 애플 네이티브 스타일의 재사용 가능한 Slidable 할일 카드 컴포넌트
///
/// 이거를 설정하고 → iOS Reminders 앱처럼 자연스러운 스와이프 제스처를 구현한다
/// 이거를 해서 → 왼쪽 스와이프로 삭제+인박스, 오른쪽 스와이프로 완료 기능을 제공한다
/// 이거는 이래서 → 사용자에게 직관적인 UX를 제공하고 햅틱 피드백으로 피드백을 준다
/// 이거라면 → date_detail_view.dart에서 TaskCard를 Slidable로 감싸서 사용한다
///
/// 사용 예시:
/// ```dart
/// SlidableTaskCard(
///   taskId: task.id,
///   onComplete: () async { /* 완료 로직 */ },
///   onDelete: () async { /* 삭제 로직 */ },
///   onInbox: () async { /* 인박스 이동 로직 */ },
///   child: TaskCard(task: task),
/// )
/// ```
class SlidableTaskCard extends StatelessWidget {
  final Widget child; // 실제 할일 카드 위젯
  final int taskId; // 할일 ID
  final String? repeatRule; // 🔄 반복 규칙 (JSON 문자열)
  final Future<void> Function() onComplete; // 완료 처리 콜백
  final Future<void> Function() onDelete; // 삭제 처리 콜백
  final Future<void> Function()? onInbox; // 📥 인박스 이동 콜백 (실행일 제거)
  final VoidCallback? onTap; // 탭 이벤트 콜백 (선택사항)

  // 선택적 커스터마이징
  final Color? completeColor; // 완료 버튼 색상
  final Color? deleteColor; // 삭제 버튼 색상
  final Color? inboxColor; // 인박스 버튼 색상
  final String? completeLabel; // 완료 버튼 라벨
  final String? deleteLabel; // 삭제 버튼 라벨
  final String? inboxLabel; // 인박스 버튼 라벨
  final bool showConfirmDialog; // 삭제 확인 다이얼로그 표시 여부
  final String? groupTag; // 그룹 태그 (한 번에 하나만 열기)
  final bool isCompletedItem; // 🎯 완료박스 아이템 여부 (완료 취소 기능)

  const SlidableTaskCard({
    super.key,
    required this.child,
    required this.taskId,
    this.repeatRule, // 🔄 반복 규칙 추가
    required this.onComplete,
    required this.onDelete,
    this.onInbox, // 📥 인박스 이동 콜백 추가
    this.onTap,
    this.completeColor,
    this.deleteColor,
    this.inboxColor,
    this.completeLabel,
    this.deleteLabel,
    this.inboxLabel,
    this.showConfirmDialog = false, // 기본값: 확인 다이얼로그 미표시 (빠른 삭제)
    this.groupTag,
    this.isCompletedItem = false, // 🎯 기본값: 일반 아이템 (완료 처리)
  });

  // 삭제 버튼 위젯 생성
  Widget _buildDeleteButton() {
    return Container(
      color: Colors.transparent, // 🎯 배경 완전 투명
      alignment: Alignment.centerLeft,
      padding: onInbox != null
          ? const EdgeInsets.only(
              left: 16,
              right: 6,
            ) // 🎯 인박스 있을 때: 왼쪽 16px, 오른쪽 6px (총 12px 간격)
          : const EdgeInsets.only(
              left: 16,
              right: 16,
            ), // 🎯 인박스 없을 때: 카드와 16px 간격
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
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  // 인박스 버튼 위젯 생성
  Widget _buildInboxButton() {
    return Container(
      color: Colors.transparent, // 🎯 배경 완전 투명
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(
        left: 6,
        right: 16,
      ), // 🎯 삭제와 6px, 카드와 16px 간격
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0x33566099), width: 1),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'asset/icon/Inbox.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            Color(0xFF566099),
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
    // 왼쪽 스와이프 액션 리스트 생성
    final List<SwipeAction> leadingActions = [
      // 삭제 버튼
      SwipeAction(
        performsFirstActionWithFullSwipe: true, // ✅ 끝까지 슬라이드 시 자동 실행
        widthSpace: onInbox != null ? 74 : 84, // 🎯 인박스 있을 때 74px, 없을 때 84px
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
    ];

    // 인박스 버튼이 있는 경우 추가
    if (onInbox != null) {
      leadingActions.add(
        SwipeAction(
          performsFirstActionWithFullSwipe: false, // ❌ 인박스는 풀 스와이프 비활성화
          widthSpace: 74, // 🎯 52px 버튼 + 6px 왼쪽 + 16px 오른쪽 = 74px
          forceAlignmentToBoundary: true,
          nestedAction: SwipeNestedAction(title: "인박스"), // 🎯 네이티브 스타일
          onTap: (handler) async {
            await HapticFeedback.lightImpact();
            await onInbox!();
            handler(false);
          },
          color: Colors.transparent,
          content: _buildInboxButton(),
        ),
      );
    }

    return SwipeActionCell(
      key: ValueKey('task_$taskId'),

      // 🎯 풀 스와이프 설정 (끝까지 당기면 자동 실행)
      backgroundColor: Colors.transparent, // 배경 투명
      fullSwipeFactor: 0.5, // 50% 이상 스와이프 시 풀 스와이프로 간주
      openAnimationDuration: 250, // 250ms로 빠른 오픈 애니메이션
      closeAnimationDuration: 300, // 300ms로 부드러운 클로즈 애니메이션
      openAnimationCurve: Curves.easeOutCubic, // iOS 네이티브 스타일 곡선
      closeAnimationCurve: Curves.easeInOutCubic, // 부드러운 닫힘
      // 왼쪽에서 오른쪽 스와이프 → 삭제 (+ 인박스)
      leadingActions: leadingActions,

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
