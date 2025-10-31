import 'package:flutter/material.dart';
import 'dart:convert';
import '../model/extracted_schedule.dart';
import 'gemini_result_confirmation_screen.dart';

/// 결과 화면 - Gemini API 응답 결과 표시
class ResultScreen extends StatelessWidget {
  final Map<String, dynamic>? geminiResponseJson;

  const ResultScreen({super.key, this.geminiResponseJson});

  @override
  Widget build(BuildContext context) {
    // 🔍 결과 화면 진입 시 상세 로그 출력
    _printDetailedResults();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xff111111)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '결과',
          style: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xff111111),
          ),
        ),
      ),
      body: geminiResponseJson == null
          ? Center(
              child: Text(
                '데이터가 없습니다',
                style: TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontSize: 16,
                  color: Color(0xff999999),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('📊 분석 결과'),
                  const SizedBox(height: 16),

                  // 통계
                  _buildStatistics(context),
                  const SizedBox(height: 24),

                  // 원본 JSON (디버깅용)
                  _buildSectionTitle('🔍 상세 정보 (JSON)'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      JsonEncoder.withIndent('  ').convert(geminiResponseJson),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xff111111),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// 상세 결과 로그 출력
  void _printDetailedResults() {
    if (geminiResponseJson == null) {
      return;
    }


    // 일정 (Schedules) 출력
    final schedules = geminiResponseJson?['schedules'] as List? ?? [];
    if (schedules.isNotEmpty) {
      for (int i = 0; i < schedules.length; i++) {
        final schedule = schedules[i];
      }
    } else {
    }

    // 작업 (Tasks) 출력
    final tasks = geminiResponseJson?['tasks'] as List? ?? [];
    if (tasks.isNotEmpty) {
      for (int i = 0; i < tasks.length; i++) {
        final task = tasks[i];
      }
    } else {
    }

    // 습관 (Habits) 출력
    final habits = geminiResponseJson?['habits'] as List? ?? [];
    if (habits.isNotEmpty) {
      for (int i = 0; i < habits.length; i++) {
        final habit = habits[i];
      }
    } else {
    }

    // 기타 정보
    final irrelevantCount = geminiResponseJson?['irrelevant_image_count'] ?? 0;

    // 요약
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'LINE Seed JP App_TTF',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xff111111),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final schedules = geminiResponseJson?['schedules'] as List? ?? [];
    final tasks = geminiResponseJson?['tasks'] as List? ?? [];
    final habits = geminiResponseJson?['habits'] as List? ?? [];
    final irrelevant = geminiResponseJson?['irrelevant_image_count'] ?? 0;

    return Column(
      children: [
        _buildStatRow(
          context,
          '📅 일정',
          schedules.length,
          onTap: () =>
              _openConfirmationScreen(context, schedules, tasks, habits),
        ),
        const SizedBox(height: 8),
        _buildStatRow(
          context,
          '✅ 작업',
          tasks.length,
          onTap: () =>
              _openConfirmationScreen(context, schedules, tasks, habits),
        ),
        const SizedBox(height: 8),
        _buildStatRow(
          context,
          '🔁 습관',
          habits.length,
          onTap: () =>
              _openConfirmationScreen(context, schedules, tasks, habits),
        ),
        const SizedBox(height: 8),
        _buildStatRow(context, '🚫 관련 없는 이미지', irrelevant),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    int count, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff111111),
              ),
            ),
            Row(
              children: [
                Text(
                  '$count개',
                  style: TextStyle(
                    fontFamily: 'LINE Seed JP App_TTF',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff566099),
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xff566099),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openConfirmationScreen(
    BuildContext context,
    List schedules,
    List tasks,
    List habits,
  ) {
    // JSON을 ExtractedSchedule 등 모델로 변환
    final extractedSchedules = schedules
        .map((json) => ExtractedSchedule.fromJson(json as Map<String, dynamic>))
        .toList();
    final extractedTasks = tasks
        .map((json) => ExtractedTask.fromJson(json as Map<String, dynamic>))
        .toList();
    final extractedHabits = habits
        .map((json) => ExtractedHabit.fromJson(json as Map<String, dynamic>))
        .toList();

    // 확인 화면으로 이동
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GeminiResultConfirmationScreen(
          schedules: extractedSchedules,
          tasks: extractedTasks,
          habits: extractedHabits,
        ),
      ),
    );
  }
}
