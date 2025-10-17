/// ✅ CompletedDetailScreen - 완료된 항목 전체 화면
///
/// Figma 디자인: Complete_ActionData 확장 뷰
/// 완료 섹션을 탭하면 전체 화면으로 확장되어 완료된 항목들을 표시
///
/// 이거를 설정하고 → Hero 애니메이션으로 부드럽게 확장하고
/// 이거를 해서 → 완료된 일정, 할일, 습관을 모두 보여준다
/// 이거는 이래서 → 완료 상태를 해제하거나 삭제할 수 있다

import 'package:flutter/material.dart';
import '../design_system/wolt_design_tokens.dart';
import '../design_system/wolt_typography.dart';
import '../Database/schedule_database.dart';
import '../widgets/task_card.dart';
import '../widgets/habit_card.dart';
import '../component/schedule_card.dart';
import '../const/color.dart';

class CompletedDetailScreen extends StatelessWidget {
  final int completedCount;
  final List<ScheduleData> completedSchedules;
  final List<TaskData> completedTasks;
  final List<HabitData> completedHabits;
  final Function(String) onUncompleteSchedule; // 일정 완료 해제
  final Function(int) onUncompleteTask; // 할일 완료 해제
  final Function(int) onUncompleteHabit; // 습관 완료 해제

  const CompletedDetailScreen({
    super.key,
    required this.completedCount,
    required this.completedSchedules,
    required this.completedTasks,
    required this.completedHabits,
    required this.onUncompleteSchedule,
    required this.onUncompleteTask,
    required this.onUncompleteHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gray050,
      body: SafeArea(
        child: Column(
          children: [
            // ===================================================================
            // 헤더: "完了" + 닫기 버튼
            // ===================================================================
            _buildHeader(context),

            // ===================================================================
            // 완료된 항목 리스트
            // ===================================================================
            Expanded(child: _buildCompletedList()),
          ],
        ),
      ),
    );
  }

  /// 헤더 구성 (Hero 애니메이션 대상)
  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: WoltDesignTokens.decorationCompletedSection,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // "完了" 텍스트
            Text('完了', style: WoltTypography.completedSectionText),

            // 개수 표시
            if (completedCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '($completedCount)',
                style: WoltTypography.completedSectionText.copyWith(
                  color: WoltDesignTokens.gray800,
                ),
              ),
            ],

            const Spacer(),

            // 닫기 아이콘
            Icon(
              Icons.keyboard_arrow_down,
              size: 24,
              color: WoltDesignTokens.primaryBlack,
            ),
          ],
        ),
      ),
    );
  }

  /// 완료된 항목 리스트 (일정, 할일, 습관)
  Widget _buildCompletedList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        // ===================================================================
        // 완료된 일정
        // ===================================================================
        if (completedSchedules.isNotEmpty) ...[
          _buildSectionTitle('完了した予定'),
          ...completedSchedules.map(
            (schedule) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ScheduleCard(
                start: schedule.start,
                end: schedule.end,
                summary: schedule.summary,
                colorId: schedule.colorId,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ===================================================================
        // 완료된 할일
        // ===================================================================
        if (completedTasks.isNotEmpty) ...[
          _buildSectionTitle('完了したタスク'),
          ...completedTasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCard(
                task: task,
                onToggle: () => onUncompleteTask(task.id),
                onTap: () {
                  // TODO: 할일 수정 화면
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ===================================================================
        // 완료된 습관
        // ===================================================================
        if (completedHabits.isNotEmpty) ...[
          _buildSectionTitle('完了したルーティン'),
          ...completedHabits.map(
            (habit) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HabitCard(
                habit: habit,
                isCompleted: true,
                onToggle: () => onUncompleteHabit(habit.id),
              ),
            ),
          ),
        ],

        // 하단 여백
        const SizedBox(height: 40),
      ],
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: WoltTypography.cardTitle.copyWith(
          color: WoltDesignTokens.gray800,
        ),
      ),
    );
  }
}
