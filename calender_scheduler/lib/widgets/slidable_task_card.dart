import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 햅틱 피드백용
import 'package:flutter_slidable/flutter_slidable.dart';

/// 애플 네이티브 스타일의 재사용 가능한 Slidable 할일 카드 컴포넌트
///
/// 이거를 설정하고 → iOS Reminders 앱처럼 자연스러운 스와이프 제스처를 구현한다
/// 이거를 해서 → 오른쪽 스와이프로 완료, 왼쪽 스와이프로 삭제 기능을 제공한다
/// 이거는 이래서 → 사용자에게 직관적인 UX를 제공하고 햅틱 피드백으로 피드백을 준다
/// 이거라면 → date_detail_view.dart에서 TaskCard를 Slidable로 감싸서 사용한다
///
/// 사용 예시:
/// ```dart
/// SlidableTaskCard(
///   taskId: task.id,
///   onComplete: () async { /* 완료 로직 */ },
///   onDelete: () async { /* 삭제 로직 */ },
///   child: TaskCard(task: task),
/// )
/// ```
class SlidableTaskCard extends StatelessWidget {
  final Widget child; // 실제 할일 카드 위젯
  final int taskId; // 할일 ID
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

  const SlidableTaskCard({
    Key? key,
    required this.child,
    required this.taskId,
    required this.onComplete,
    required this.onDelete,
    this.onTap,
    this.completeColor,
    this.deleteColor,
    this.completeLabel,
    this.deleteLabel,
    this.showConfirmDialog = false, // 기본값: 확인 다이얼로그 미표시 (빠른 삭제)
    this.groupTag,
  }) : super(key: key);

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
      // startActionPane: 오른쪽에서 왼쪽 스와이프 → 완료 (쉽게 접근)
      // ========================================
      startActionPane: ActionPane(
        // ✅ BehindMotion: iOS Reminders 스타일 (가장 네이티브스러움)
        // 이유: 액션이 Slidable 뒤에 고정되어 나타남 (iOS 표준)
        motion: const BehindMotion(),

        // ✅ extentRatio: 액션 패널이 차지하는 비율
        // 이유: iOS 네이티브는 보통 0.25~0.3 사용 (화면의 25~30%)
        extentRatio: 0.25,

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
            print(
              '✅ [SlidableTask] 할일 ID=$taskId 완료 스와이프 감지 - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
            );

            // 2. 완료 액션 실행
            await onComplete();
            print(
              '✅ [SlidableTask] 할일 ID=$taskId 완료 처리 완료 - DB 업데이트 및 이벤트 로그 기록됨',
            );
          },
        ),

        // ✅ 액션 버튼 정의
        children: [
          SlidableAction(
            onPressed: (context) async {
              await HapticFeedback.lightImpact();
              print(
                '✅ [SlidableTask] 할일 ID=$taskId 완료 버튼 클릭 - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
              );
              await onComplete();
            },

            // ✅ 색상 설정 (iOS 네이티브 완료 색상)
            backgroundColor:
                completeColor ?? const Color(0xFF34C759), // iOS Green
            foregroundColor: Colors.white,

            icon: Icons.check_circle_outline,
            label: completeLabel ?? '完了',
            autoClose: true,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),

      // ========================================
      // endActionPane: 왼쪽에서 오른쪽 스와이프 → 삭제 (나중에 Inbox 추가 예정)
      // ========================================
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,

        dismissible: DismissiblePane(
          dismissThreshold: 0.5,
          closeOnCancel: true,
          dismissalDuration: const Duration(milliseconds: 300),
          resizeDuration: const Duration(milliseconds: 300),

          // ✅ confirmDismiss: 삭제 확인 다이얼로그 (선택사항)
          // 이유: 할일은 빠른 삭제를 위해 기본적으로 비활성화
          confirmDismiss: showConfirmDialog
              ? () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('タスク削除'),
                        content: const Text('このタスクを削除しますか？'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                            child: const Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                            child: const Text(
                              '削除',
                              style: TextStyle(color: Color(0xFFFF3B30)),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  return result ?? false;
                }
              : null,

          onDismissed: () async {
            // 1. 햅틱 피드백 (강한 진동 - 삭제는 중요한 액션)
            await HapticFeedback.heavyImpact();
            print(
              '🗑️ [SlidableTask] 할일 ID=$taskId 삭제 스와이프 감지 - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
            );

            // 2. 삭제 액션 실행
            await onDelete();
            print(
              '🗑️ [SlidableTask] 할일 ID=$taskId 삭제 처리 완료 - DB 업데이트 및 이벤트 로그 기록됨',
            );
          },
        ),

        children: [
          SlidableAction(
            onPressed: (context) async {
              // 삭제 버튼 클릭 시 confirmDismiss 확인
              if (showConfirmDialog) {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('タスク削除'),
                      content: const Text('このタスクを削除しますか？'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text(
                            '削除',
                            style: TextStyle(color: Color(0xFFFF3B30)),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed == true) {
                  await HapticFeedback.mediumImpact();
                  print(
                    '🗑️ [SlidableTask] 할일 ID=$taskId 삭제 버튼 클릭 (확인됨) - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
                  );
                  await onDelete();
                } else {
                  print(
                    '❌ [SlidableTask] 할일 ID=$taskId 삭제 취소됨 - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
                  );
                }
              } else {
                await HapticFeedback.mediumImpact();
                print(
                  '🗑️ [SlidableTask] 할일 ID=$taskId 삭제 버튼 클릭 - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
                );
                await onDelete();
              }
            },

            // ✅ iOS 네이티브 삭제 색상
            backgroundColor: deleteColor ?? const Color(0xFFFF3B30), // iOS Red
            foregroundColor: Colors.white,

            icon: Icons.delete_outline,
            label: deleteLabel ?? '削除',
            autoClose: true,
            borderRadius: BorderRadius.circular(8),
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
