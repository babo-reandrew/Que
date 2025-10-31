import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 햅틱 피드백용
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 아이콘용
import 'modal/delete_confirmation_modal.dart'; // 🗑️ 삭제 확인 모달 추가
import 'modal/delete_repeat_confirmation_modal.dart'; // 🔄 반복 삭제 확인 모달 추가

/// 애플 네이티브 스타일의 재사용 가능한 Slidable 일정 카드 컴포넌트
///
/// 이거를 설정하고 → iOS Mail/Reminders 앱처럼 자연스러운 스와이프 제스처를 구현한다
/// 이거를 해서 → 왼쪽 스와이프로 삭제, 오른쪽 스와이프로 완료 기능을 제공한다
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
  final String? repeatRule; // 🔄 반복 규칙 (JSON 문자열)
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
    super.key,
    required this.child,
    required this.scheduleId,
    this.repeatRule, // 🔄 반복 규칙 추가
    required this.onComplete,
    required this.onDelete,
    this.onTap,
    this.completeColor,
    this.deleteColor,
    this.completeLabel,
    this.deleteLabel,
    this.showConfirmDialog = true, // 기본값: 확인 다이얼로그 표시
    this.groupTag,
  });

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
      // startActionPane: 왼쪽에서 오른쪽 스와이프 → 삭제
      // ========================================
      startActionPane: ActionPane(
        motion: const BehindMotion(), // BehindMotion으로 변경 (iOS 표준)
        extentRatio: 0.144, // 초기 56px (0.144), 스와이프 시 확장
        // 🎯 iOS Mail 완벽 재현: 일정 거리 이상 스와이프 시 자동 삭제
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
          onDismissed: () {},
        ),

        // 슬라이드 정도에 따라 버튼 선택 가능하도록
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              if (showConfirmDialog) {
                if (repeatRule != null) {
                  await showDeleteRepeatConfirmationModal(
                    context,
                    onDeleteThis: () async {
                      await HapticFeedback.mediumImpact();
                      await onDelete();
                    },
                    onDeleteFuture: () async {
                      await HapticFeedback.mediumImpact();
                      // TODO: DB에 이후 삭제 함수 추가 필요
                      await onDelete();
                    },
                    onDeleteAll: () async {
                      await HapticFeedback.mediumImpact();
                      await onDelete();
                    },
                  );
                } else {
                  await showDeleteConfirmationModal(
                    context,
                    onDelete: () async {
                      await HapticFeedback.mediumImpact();
                      await onDelete();
                    },
                  );
                }
              } else {
                await HapticFeedback.mediumImpact();
                await onDelete();
              }
            },
            backgroundColor: Colors.transparent, // 배경을 투명하게
            foregroundColor: Colors.white,
            autoClose: true,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth, // 부모 크기에 맞춤
                    height: 56, // 높이만 56px 고정!!!
                    constraints: const BoxConstraints(
                      minWidth: 56,
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

      // ========================================
      // endActionPane: 오른쪽에서 왼쪽 스와이프 → 완료 (쉽게 접근)
      // ========================================
      endActionPane: ActionPane(
        motion: const BehindMotion(), // BehindMotion으로 변경 (iOS 표준)
        extentRatio: 0.144, // 초기 56px (0.144), 스와이프 시 확장
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

            // 2. 완료 액션 실행
            // 이유: DB에서 일정을 완료 처리하고 UI 갱신
            // 조건: onComplete 콜백이 제공되어야 함
            await onComplete();
          },
        ),

        // ✅ 액션 버튼 정의
        // 이유: 스와이프하지 않고 버튼을 직접 탭할 수도 있음
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              await HapticFeedback.lightImpact();
              await onComplete();
            },
            backgroundColor: Colors.transparent, // 배경을 투명하게
            foregroundColor: Colors.white,
            autoClose: true,
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
                      minWidth: 56,
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
