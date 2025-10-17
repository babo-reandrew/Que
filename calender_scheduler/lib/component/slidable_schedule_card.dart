import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 햅틱 피드백용
import 'package:flutter_slidable/flutter_slidable.dart';

/// 애플 네이티브 스타일의 재사용 가능한 Slidable 일정 카드 컴포넌트
///
/// 이거를 설정하고 → iOS Mail/Reminders 앱처럼 자연스러운 스와이프 제스처를 구현한다
/// 이거를 해서 → 오른쪽 스와이프로 삭제, 왼쪽 스와이프로 완료 기능을 제공한다
/// 이거는 이래서 → 사용자에게 직관적인 UX를 제공하고 햅틱 피드백으로 피드백을 준다
/// 이거라면 → date_detail_view.dart에서 일정 카드를 Slidable로 감싸서 사용한다
///
/// 사용 예시:
/// ```dart
/// SlidableScheduleCard(
///   scheduleId: schedule.id,
///   onComplete: () async { /* 완료 로직 */ },
///   onDelete: () async { /* 삭제 로직 */ },
///   child: ScheduleCard(schedule: schedule),
/// )
/// ```
class SlidableScheduleCard extends StatelessWidget {
  final Widget child; // 실제 일정 카드 위젯
  final int scheduleId; // 일정 ID
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

  const SlidableScheduleCard({
    Key? key,
    required this.child,
    required this.scheduleId,
    required this.onComplete,
    required this.onDelete,
    this.onTap,
    this.completeColor,
    this.deleteColor,
    this.completeLabel,
    this.deleteLabel,
    this.showConfirmDialog = true, // 기본값: 확인 다이얼로그 표시
    this.groupTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // ✅ Key는 각 아이템을 고유하게 식별 (필수!)
      // 이유: Flutter의 위젯 트리 동기화를 위해 필요
      // 조건: scheduleId를 사용한 고유한 값
      // 결과: 삭제 후 잘못된 아이템이 열려있는 버그 방지
      key: ValueKey('schedule_$scheduleId'),

      // ✅ 그룹 태그 설정 (선택사항)
      // 이유: 같은 그룹에서 한 번에 하나의 Slidable만 열림
      // 조건: SlidableAutoCloseBehavior로 감싸져 있어야 함
      // 결과: iOS 네이티브처럼 하나만 열린 상태 유지
      groupTag: groupTag,

      // ✅ 스크롤 시 자동 닫힘 (iOS 네이티브 동작)
      // 이유: 사용자가 스크롤하면 자동으로 Slidable이 닫혀야 자연스럽다
      closeOnScroll: true,

      // ========================================
      // ✅ 수정: startActionPane: 오른쪽에서 왼쪽 스와이프 → 완료 (쉽게 접근)
      // ========================================
      startActionPane: ActionPane(
        // ✅ BehindMotion: iOS Mail 스타일 (가장 네이티브스러움)
        // 이유: 액션이 Slidable 뒤에 고정되어 나타남 (iOS 표준)
        // 조건: BehindMotion을 사용해야 iOS 느낌이 남
        // 대안: ScrollMotion (함께 움직임), DrawerMotion (서랍 스타일) - 비권장
        motion: const BehindMotion(),

        // ✅ extentRatio: 액션 패널이 차지하는 비율
        // 이유: iOS 네이티브는 보통 0.25~0.3 사용 (화면의 25~30%)
        // 조건: 0.0 ~ 1.0 사이 값
        // 결과: 너무 크지 않게 적절한 크기로 표시
        extentRatio: 0.25,

        // ✅ DismissiblePane: 끝까지 스와이프 시 즉시 완료 처리
        // 이유: 사용자가 빠르게 완료할 수 있도록
        // 조건: dismissThreshold 이상 스와이프 시 발동
        dismissible: DismissiblePane(
          // ✅ dismissThreshold: dismiss가 발동되는 임계값
          // 이유: 0.5 = 50% 이상 스와이프 시 dismiss 실행
          // 조건: 0.0 ~ 1.0 사이 값 (기본값: 0.4)
          // 결과: 충분히 스와이프했을 때만 완료 처리
          dismissThreshold: 0.5,

          // ✅ closeOnCancel: 취소 시 닫힘 여부
          // 이유: false로 설정하면 취소 시에도 열린 상태 유지
          // 조건: true로 설정해서 취소 시 자동 닫힘
          closeOnCancel: true,

          // ✅ 애니메이션 시간 (iOS 네이티브 스타일)
          // 이유: iOS 표준 애니메이션 타이밍은 200~300ms
          // 조건: 너무 빠르거나 느리지 않게 300ms로 설정
          dismissalDuration: const Duration(milliseconds: 300),
          resizeDuration: const Duration(milliseconds: 300),

          // ✅ onDismissed: 완전히 스와이프했을 때 실행
          // 이유: 사용자가 끝까지 스와이프했을 때의 완료 처리
          // 다음: 햅틱 피드백 → 완료 처리 → DB 업데이트 → 이벤트 로그
          onDismissed: () async {
            // 1. 햅틱 피드백 (iOS 네이티브 스타일)
            // 이유: 사용자에게 즉각적인 촉각 피드백 제공
            // 조건: mediumImpact는 완료 같은 중간 중요도 액션에 적합
            await HapticFeedback.mediumImpact();
            print(
              '✅ [Slidable] 일정 ID=$scheduleId 완료 스와이프 감지 - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
            );

            // 2. 완료 액션 실행
            // 이유: DB에서 일정을 완료 처리하고 UI 갱신
            // 조건: onComplete 콜백이 제공되어야 함
            await onComplete();
            print(
              '✅ [Slidable] 일정 ID=$scheduleId 완료 처리 완료 - DB 업데이트 및 이벤트 로그 기록됨',
            );
          },
        ),

        // ✅ 액션 버튼 정의
        // 이유: 스와이프하지 않고 버튼을 직접 탭할 수도 있음
        children: [
          SlidableAction(
            // ✅ onPressed: 버튼 클릭 시 콜백
            // 이유: 스와이프하지 않고 버튼을 직접 탭할 때 실행
            // 다음: 햅틱 피드백 → 완료 처리
            onPressed: (context) async {
              await HapticFeedback.lightImpact();
              print(
                '✅ [Slidable] 일정 ID=$scheduleId 완료 버튼 클릭 - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
              );
              await onComplete();
            },

            // ✅ 색상 설정 (iOS 네이티브 완료 색상)
            // 이유: iOS Green은 완료를 나타내는 표준 색상
            // 조건: completeColor가 제공되지 않으면 기본 iOS Green 사용
            backgroundColor:
                completeColor ?? const Color(0xFF34C759), // iOS Green
            foregroundColor: Colors.white,

            // ✅ 아이콘 및 레이블
            // 이유: 체크 아이콘은 완료를 직관적으로 표현
            icon: Icons.check_circle_outline,
            label: completeLabel ?? '완료',

            // ✅ autoClose: 탭 후 자동 닫힘
            // 이유: iOS 네이티브 동작은 액션 후 자동으로 닫힘
            autoClose: true,

            // ✅ borderRadius: 모서리 둥글게 (선택사항)
            // 이유: iOS 네이티브 스타일은 약간의 radius 사용
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),

      // ========================================
      // ✅ 수정: endActionPane: 왼쪽에서 오른쪽 스와이프 → 삭제
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
          // 이유: 사용자 실수 방지
          // 조건: showConfirmDialog가 true일 때만 표시
          // 반환: true → 삭제 진행, false/null → 취소
          confirmDismiss: showConfirmDialog
              ? () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('일정 삭제'),
                        content: const Text('이 일정을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                            child: const Text(
                              '삭제',
                              style: TextStyle(color: Color(0xFFFF3B30)),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  return result ?? false; // null인 경우 false 반환
                }
              : null,

          onDismissed: () async {
            // 1. 햅틱 피드백 (강한 진동 - 삭제는 중요한 액션)
            // 이유: 삭제는 되돌릴 수 없으므로 강한 피드백 제공
            // 조건: heavyImpact는 중요한 액션에 사용
            await HapticFeedback.heavyImpact();
            print(
              '🗑️ [Slidable] 일정 ID=$scheduleId 삭제 스와이프 감지 - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
            );

            // 2. 삭제 액션 실행
            // 이유: DB에서 일정을 삭제하고 UI 갱신
            // 조건: onDelete 콜백이 제공되어야 함
            await onDelete();
            print(
              '🗑️ [Slidable] 일정 ID=$scheduleId 삭제 처리 완료 - DB 업데이트 및 이벤트 로그 기록됨',
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
                      title: const Text('일정 삭제'),
                      content: const Text('이 일정을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text(
                            '삭제',
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
                    '🗑️ [Slidable] 일정 ID=$scheduleId 삭제 버튼 클릭 (확인됨) - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
                  );
                  await onDelete();
                } else {
                  print(
                    '❌ [Slidable] 일정 ID=$scheduleId 삭제 취소됨 - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
                  );
                }
              } else {
                await HapticFeedback.mediumImpact();
                print(
                  '🗑️ [Slidable] 일정 ID=$scheduleId 삭제 버튼 클릭 - 타임스탬프: ${DateTime.now().millisecondsSinceEpoch}',
                );
                await onDelete();
              }
            },

            // ✅ iOS 네이티브 삭제 색상
            // 이유: iOS Red는 삭제를 나타내는 표준 색상
            // 조건: deleteColor가 제공되지 않으면 기본 iOS Red 사용
            backgroundColor: deleteColor ?? const Color(0xFFFF3B30), // iOS Red
            foregroundColor: Colors.white,

            icon: Icons.delete_outline,
            label: deleteLabel ?? '삭제',
            autoClose: true,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),

      // ✅ child: 실제 표시되는 위젯
      // 이유: GestureDetector로 감싸서 탭 이벤트 처리
      // 조건: onTap이 제공된 경우에만 탭 가능
      child: GestureDetector(
        onTap: onTap,
        // ✅ iOS 네이티브 스타일: 탭 시 배경색 변경 피드백
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
