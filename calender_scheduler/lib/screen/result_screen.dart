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
      print('⚠️ [ResultScreen] 응답 데이터가 없습니다');
      return;
    }

    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║          📊 GEMINI API 분석 결과 상세 보고서                ║');
    print('╚═══════════════════════════════════════════════════════════╝');
    print('');

    // 일정 (Schedules) 출력
    final schedules = geminiResponseJson?['schedules'] as List? ?? [];
    print('📅 ===== 일정 (SCHEDULES) =====');
    print('총 ${schedules.length}개의 일정이 추출되었습니다.');
    if (schedules.isNotEmpty) {
      for (int i = 0; i < schedules.length; i++) {
        final schedule = schedules[i];
        print('');
        print('  [일정 ${i + 1}]');
        print('    제목: ${schedule['summary'] ?? '(없음)'}');
        print('    시작: ${schedule['start'] ?? '(없음)'}');
        print('    종료: ${schedule['end'] ?? '(없음)'}');
        print(
          '    설명: ${schedule['description']?.isEmpty ?? true ? '(없음)' : schedule['description']}',
        );
        print(
          '    장소: ${schedule['location']?.isEmpty ?? true ? '(없음)' : schedule['location']}',
        );
        print('    색상: ${schedule['colorId'] ?? 'gray'}');
        print(
          '    반복: ${schedule['repeatRule']?.isEmpty ?? true ? '없음' : schedule['repeatRule']}',
        );
      }
    } else {
      print('  → 추출된 일정이 없습니다.');
    }
    print('');

    // 작업 (Tasks) 출력
    final tasks = geminiResponseJson?['tasks'] as List? ?? [];
    print('✅ ===== 작업 (TASKS) =====');
    print('총 ${tasks.length}개의 작업이 추출되었습니다.');
    if (tasks.isNotEmpty) {
      for (int i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        print('');
        print('  [작업 ${i + 1}]');
        print('    제목: ${task['title'] ?? '(없음)'}');
        print('    마감일: ${task['dueDate'] ?? '(없음)'}');
        print('    실행일: ${task['executionDate'] ?? '(없음)'}');
        print(
          '    설명: ${task['description']?.isEmpty ?? true ? '(없음)' : task['description']}',
        );
        print(
          '    장소: ${task['location']?.isEmpty ?? true ? '(없음)' : task['location']}',
        );
        print('    색상: ${task['colorId'] ?? 'gray'}');
        print('    목록: ${task['listId'] ?? 'inbox'}');
      }
    } else {
      print('  → 추출된 작업이 없습니다.');
    }
    print('');

    // 습관 (Habits) 출력
    final habits = geminiResponseJson?['habits'] as List? ?? [];
    print('🔁 ===== 습관 (HABITS) =====');
    print('총 ${habits.length}개의 습관이 추출되었습니다.');
    if (habits.isNotEmpty) {
      for (int i = 0; i < habits.length; i++) {
        final habit = habits[i];
        print('');
        print('  [습관 ${i + 1}]');
        print('    제목: ${habit['title'] ?? '(없음)'}');
        print('    반복 규칙: ${habit['repeatRule'] ?? '(없음)'}');
        print('    색상: ${habit['colorId'] ?? 'gray'}');
        print(
          '    설명: ${habit['description']?.isEmpty ?? true ? '(없음)' : habit['description']}',
        );
      }
    } else {
      print('  → 추출된 습관이 없습니다.');
    }
    print('');

    // 기타 정보
    final irrelevantCount = geminiResponseJson?['irrelevant_image_count'] ?? 0;
    print('🚫 ===== 기타 정보 =====');
    print('관련 없는 이미지 개수: $irrelevantCount');
    print('');

    // 요약
    print('📈 ===== 요약 =====');
    print('총 추출된 항목: ${schedules.length + tasks.length + habits.length}개');
    print('  - 일정: ${schedules.length}개');
    print('  - 작업: ${tasks.length}개');
    print('  - 습관: ${habits.length}개');
    print('');
    print('╔═══════════════════════════════════════════════════════════╗');
    print('║                  🎉 분석 완료!                             ║');
    print('╚═══════════════════════════════════════════════════════════╝');
    print('');
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
