import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 햅틱 피드백용
import 'package:flutter_slidable/flutter_slidable.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // ✅ Key는 각 아이템을 고유하게 식별 (필수!)
      // 이유: Flutter의 위젯 트리 동기화를 위해 필요
      // 조건: taskId를 사용한 고유한 값
      // 결과: 삭제 후 잘못된 아이템이 열려있는 버그 방지
      key: ValueKey('task_$taskId'),

      // ✅ 그룹 태그 설정 (선택사항)
      // 이유: 같은 그룹에서 한 번에 하나의 Slidable만 열림
      // 조건: SlidableAutoCloseBehavior로 감싸져 있어야 함
      // 결과: iOS 네이티브처럼 하나만 열린 상태 유지
      groupTag: groupTag,

      // ✅ 스크롤 시 자동 닫힘 (iOS 네이티브 동작)
      // 이유: 사용자가 스크롤하면 자동으로 Slidable이 닫혀야 자연스럽다
      closeOnScroll: true,

      // ========================================
      // startActionPane: 왼쪽에서 오른쪽 스와이프 → 인박스 → 삭제
      // iOS Mail 정확한 동작: 0-30% 인박스만, 30-60% 삭제만
      // ========================================
      startActionPane: ActionPane(
        motion: const DrawerMotion(), // DrawerMotion: 서랍처럼 순차적으로 나타남
        extentRatio: onInbox != null
            ? 0.6
            : 0.144, // 초기 56px (0.144), 스와이프 시 확장
        // 끝까지 스와이프 시 삭제 실행
        dismissible: DismissiblePane(
          dismissThreshold: 0.6, // 60% 이상 스와이프하면 삭제
          closeOnCancel: true,
          confirmDismiss: () async {
            // 햅틱 피드백
            await HapticFeedback.mediumImpact();

            // 끝까지 스와이프 시 삭제 모달 표시
            if (showConfirmDialog) {
              bool confirmed = false;
              bool hasRepeat =
                  repeatRule != null &&
                  repeatRule!.isNotEmpty &&
                  repeatRule != '{}' &&
                  repeatRule != '[]';

              if (hasRepeat) {
                await showDeleteRepeatConfirmationModal(
                  context,
                  onDeleteThis: () async {
                    confirmed = true;
                    await onDelete();
                  },
                  onDeleteFuture: () async {
                    confirmed = true;
                    await onDelete();
                  },
                  onDeleteAll: () async {
                    confirmed = true;
                    await onDelete();
                  },
                );
              } else {
                await showDeleteConfirmationModal(
                  context,
                  onDelete: () async {
                    confirmed = true;
                    await onDelete();
                  },
                );
              }
              return confirmed;
            } else {
              await onDelete();
              return true;
            }
          },
          onDismissed: () {
          },
        ),

        children: [
          // 삭제 버튼 (0-30% 구간에서 먼저 보임)
          CustomSlidableAction(
            onPressed: (context) async {
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
            },
            backgroundColor: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.symmetric(vertical: 8),
            autoClose: true,
            child: Padding(
              padding: onInbox != null
                  ? const EdgeInsets.only(left: 8, right: 4)
                  : const EdgeInsets.only(left: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth, // 부모 크기에 맞춤
                    height: 56, // 높이만 56px 고정!!!
                    constraints: const BoxConstraints(
                      minWidth: 56, // 최소 56px
                      minHeight: 56,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'asset/icon/trash_icon.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 인박스 버튼 (30-60% 구간에서 보임)
          ...onInbox != null
              ? [
                  CustomSlidableAction(
                    onPressed: (context) async {
                      await HapticFeedback.lightImpact();

                      // 인박스로 이동 (executionDate만 제거)
                      await onInbox!();
                    },
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF566099),
                    borderRadius: BorderRadius.circular(100),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    autoClose: true,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, right: 8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            width: constraints.maxWidth, // 부모 크기에 맞춤
                            height: 56, // 높이만 56px 고정!!!
                            constraints: const BoxConstraints(
                              minWidth: 56, // 최소 56px
                              minHeight: 56,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0x33566099),
                                width: 1,
                              ),
                            ),
                            child: Center(
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
                        },
                      ),
                    ),
                  ),
                ]
              : [],
        ],
      ),

      // ========================================
      // endActionPane: 오른쪽에서 왼쪽 스와이프 → 완료 (쉽게 접근)
      // ========================================
      endActionPane: ActionPane(
        motion: const BehindMotion(), // BehindMotion으로 변경 (iOS 표준)
        extentRatio: 0.144, // 초기 56px (0.144), 스와이프 시 확장
        // ✅ DismissiblePane: 끝까지 스와이프 시 즉시 완료 처리
        // 이유: 사용자가 빠르게 완료할 수 있도록
        dismissible: DismissiblePane(
          dismissThreshold: 0.5,
          closeOnCancel: true,
          dismissalDuration: const Duration(milliseconds: 300),
          resizeDuration: const Duration(milliseconds: 300),

          onDismissed: () async {
            // 1. 햅틱 피드백 (iOS 네이티브 스타일)
            await HapticFeedback.mediumImpact();

            // 2. 완료 액션 실행
            await onComplete();
          },
        ),

        // ✅ 액션 버튼 정의
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              await HapticFeedback.lightImpact();
              await onComplete();
            },
            autoClose: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth, // 부모 크기에 맞춤
                    height: 56, // 높이만 56px 고정!!!
                    constraints: const BoxConstraints(
                      minWidth: 56, // 최소 56px
                      minHeight: 56,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0CF20C),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'asset/icon/Check_icon.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFFFFFFF),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // ✅ child: 실제 표시되는 위젯
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
