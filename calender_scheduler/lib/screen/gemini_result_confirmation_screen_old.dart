// ===================================================================
// ⭐️ Gemini Result Confirmation Screen
// ===================================================================
// Gemini AI가 추출한 일정/할일/습관을 최종 확인하는 화면 (Figma 디자인 기반)
// ===================================================================

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../Database/schedule_database.dart';
import '../model/extracted_schedule.dart';

class GeminiResultConfirmationScreen extends StatefulWidget {
  final List<ExtractedSchedule> schedules;
  final List<ExtractedTask> tasks;
  final List<ExtractedHabit> habits;

  const GeminiResultConfirmationScreen({
    super.key,
    required this.schedules,
    required this.tasks,
    required this.habits,
  });

  @override
  State<GeminiResultConfirmationScreen> createState() =>
      _GeminiResultConfirmationScreenState();
}

class _GeminiResultConfirmationScreenState
    extends State<GeminiResultConfirmationScreen> {
  late List<bool> scheduleChecks;
  late List<bool> taskChecks;
  late List<bool> habitChecks;
  final bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    scheduleChecks = List.filled(widget.schedules.length, true);
    taskChecks = List.filled(widget.tasks.length, true);
    habitChecks = List.filled(widget.habits.length, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // スケジュール 섹션
                  if (widget.schedules.isNotEmpty) _buildScheduleSection(),

                  // タスク 섹션
                  if (widget.tasks.isNotEmpty) _buildTaskSection(),

                  // ルーティン 섹션
                  if (widget.habits.isNotEmpty) _buildHabitSection(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // 하단 버튼
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onAddPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5FC1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text('追加する',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../Database/schedule_database.dart';
import '../model/extracted_schedule.dart';

class GeminiResultConfirmationScreen extends StatefulWidget {
  /// 추출된 일정 목록
  final List<ExtractedSchedule> schedules;

  /// 추출된 할일 목록
  final List<ExtractedTask> tasks;

  /// 추출된 습관 목록
  final List<ExtractedHabit> habits;

  const GeminiResultConfirmationScreen({
    Key? key,
    required this.schedules,
    required this.tasks,
    required this.habits,
  }) : super(key: key);

  @override
  State<GeminiResultConfirmationScreen> createState() =>
      _GeminiResultConfirmationScreenState();
}

class _GeminiResultConfirmationScreenState
    extends State<GeminiResultConfirmationScreen> {
  late List<bool> scheduleChecks;
  late List<bool> taskChecks;
  late List<bool> habitChecks;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 모든 항목 기본 체크
    scheduleChecks = List.filled(widget.schedules.length, true);
    taskChecks = List.filled(widget.tasks.length, true);
    habitChecks = List.filled(widget.habits.length, true);
  }

  @override
  Widget build(BuildContext context) {
    final totalCount =
        widget.schedules.length + widget.tasks.length + widget.habits.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF262626)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI 분석 결과',
          style: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: Color(0xFF262626),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 헤더: 전체 개수
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF111111).withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              '총 $totalCount개의 항목을 찾았습니다',
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF262626),
              ),
            ),
          ),

          // 스크롤 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // 버튼 영역 확보
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 스케줄 섹션
                  if (widget.schedules.isNotEmpty)
                    _buildSection(
                      title: 'スケジュール',
                      count: widget.schedules.length,
                      items: widget.schedules,
                      checks: scheduleChecks,
                      onCheckChanged: (index, value) {
                        setState(() => scheduleChecks[index] = value);
                      },
                      builder: (item, index) => _buildScheduleCard(
                        item as ExtractedSchedule,
                        scheduleChecks[index],
                        (value) => setState(() => scheduleChecks[index] = value),
                      ),
                    ),

                  // 타스크 섹션
                  if (widget.tasks.isNotEmpty)
                    _buildSection(
                      title: 'タスク',
                      count: widget.tasks.length,
                      items: widget.tasks,
                      checks: taskChecks,
                      onCheckChanged: (index, value) {
                        setState(() => taskChecks[index] = value);
                      },
                      builder: (item, index) => _buildTaskCard(
                        item as ExtractedTask,
                        taskChecks[index],
                        (value) => setState(() => taskChecks[index] = value),
                      ),
                    ),

                  // 루틴 섹션
                  if (widget.habits.isNotEmpty)
                    _buildSection(
                      title: 'ルーティン',
                      count: widget.habits.length,
                      items: widget.habits,
                      checks: habitChecks,
                      onCheckChanged: (index, value) {
                        setState(() => habitChecks[index] = value);
                      },
                      builder: (item, index) => _buildHabitCard(
                        item as ExtractedHabit,
                        habitChecks[index],
                        (value) => setState(() => habitChecks[index] = value),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 하단 고정 버튼
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onAddPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5FC1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '追加する',
                          style: TextStyle(
                            fontFamily: 'LINE Seed JP App_TTF',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 빌더
  Widget _buildSection({
    required String title,
    required int count,
    required List items,
    required List<bool> checks,
    required Function(int, bool) onCheckChanged,
    required Widget Function(dynamic, int) builder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF262626),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => builder(items[index], index),
        ),
      ],
    );
  }

  /// 스케줄 카드
  Widget _buildScheduleCard(
    ExtractedSchedule schedule,
    bool isChecked,
    ValueChanged<bool> onChanged,
  ) {
    return _buildBaseCard(
      isChecked: isChecked,
      onChanged: onChanged,
      color: const Color(0xFF0066FF),
      icon: Icons.event,
      label: 'スケジュール',
      title: schedule.summary,
      subtitle: _formatScheduleTime(schedule),
      details: [
        if (schedule.location.isNotEmpty)
          _buildDetailRow(Icons.location_on, schedule.location),
        if (schedule.repeatRule.isNotEmpty)
          _buildDetailRow(Icons.repeat, _parseRepeatRule(schedule.repeatRule)),
      ],
    );
  }

  /// 타스크 카드
  Widget _buildTaskCard(
    ExtractedTask task,
    bool isChecked,
    ValueChanged<bool> onChanged,
  ) {
    return _buildBaseCard(
      isChecked: isChecked,
      onChanged: onChanged,
      color: const Color(0xFF10B981),
      icon: Icons.check_circle_outline,
      label: 'タスク',
      title: task.title,
      subtitle: _formatTaskTime(task),
      details: [
        if (task.location.isNotEmpty)
          _buildDetailRow(Icons.location_on, task.location),
      ],
    );
  }

  /// 습관 카드
  Widget _buildHabitCard(
    ExtractedHabit habit,
    bool isChecked,
    ValueChanged<bool> onChanged,
  ) {
    return _buildBaseCard(
      isChecked: isChecked,
      onChanged: onChanged,
      color: const Color(0xFFF59E0B),
      icon: Icons.repeat,
      label: 'ルーティン',
      title: habit.title,
      subtitle: _parseRepeatRule(habit.repeatRule),
      details: [],
    );
  }

  /// 기본 카드 위젯
  Widget _buildBaseCard({
    required bool isChecked,
    required ValueChanged<bool> onChanged,
    required Color color,
    required IconData icon,
    required String label,
    required String title,
    required String subtitle,
    required List<Widget> details,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked
              ? color.withOpacity(0.3)
              : const Color(0xFF111111).withOpacity(0.1),
          width: isChecked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!isChecked),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 체크박스
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isChecked ? color : Colors.white,
                    border: Border.all(
                      color: isChecked ? color : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isChecked
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타입 칩
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 12, color: color),
                            const SizedBox(width: 4),
                            Text(
                              label,
                              style: TextStyle(
                                fontFamily: 'LINE Seed JP App_TTF',
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 제목
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'LINE Seed JP App_TTF',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF262626),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 서브타이틀
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'LINE Seed JP App_TTF',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: const Color(0xFF111111).withOpacity(0.6),
                        ),
                      ),

                      // 추가 정보
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...details,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 상세 정보 행
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF111111).withOpacity(0.4),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: const Color(0xFF111111).withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 스케줄 시간 포맷
  String _formatScheduleTime(ExtractedSchedule schedule) {
    final start = schedule.start;
    final end = schedule.end;

    final startStr =
        '${start.month}/${start.day} ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '$startStr - $endStr';
    }

    final endDateStr =
        '${end.month}/${end.day} ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endDateStr';
  }

  /// 타스크 시간 포맷
  String _formatTaskTime(ExtractedTask task) {
    if (task.dueDate != null) {
      final due = task.dueDate!;
      return '${due.month}/${due.day}まで';
    }
    if (task.executionDate != null) {
      final exec = task.executionDate!;
      return '${exec.month}/${exec.day}';
    }
    return '期限なし';
  }

  /// RRULE 파싱
  String _parseRepeatRule(String rrule) {
    if (rrule.isEmpty) return '';

    if (rrule.contains('FREQ=DAILY')) return '毎日';
    if (rrule.contains('FREQ=WEEKLY')) {
      if (rrule.contains('BYDAY=MO,TU,WE,TH,FR')) return '平日毎日';
      if (rrule.contains('BYDAY=SA,SU')) return '週末毎日';
      return '毎週';
    }
    if (rrule.contains('FREQ=MONTHLY')) return '毎月';
    if (rrule.contains('FREQ=YEARLY')) return '毎年';

    return '繰り返し';
  }

  /// 추가 버튼 처리
  Future<void> _onAddPressed() async {
    setState(() => _isSaving = true);

    try {
      final database = GetIt.instance<AppDatabase>();
      int addedCount = 0;

      // 스케줄 추가
      for (int i = 0; i < widget.schedules.length; i++) {
        if (scheduleChecks[i]) {
          await database.createSchedule(widget.schedules[i].toCompanion());
          addedCount++;
        }
      }

      // 타스크 추가
      for (int i = 0; i < widget.tasks.length; i++) {
        if (taskChecks[i]) {
          await database.createTask(widget.tasks[i].toCompanion());
          addedCount++;
        }
      }

      // 습관 추가
      for (int i = 0; i < widget.habits.length; i++) {
        if (habitChecks[i]) {
          await database.createHabit(widget.habits[i].toCompanion());
          addedCount++;
        }
      }

      if (!mounted) return;

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$addedCount個の項目を追加しました'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // 화면 닫기
      Navigator.of(context).pop(addedCount);
    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
