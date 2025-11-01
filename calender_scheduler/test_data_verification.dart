import 'lib/Database/schedule_database.dart';

/// 데이터베이스 검증 스크립트
///
/// 실행 방법:
/// ```bash
/// dart test_data_verification.dart
/// ```
///
/// 검증 항목:
/// 1. 일정(Schedule)의 색상(colorId)과 리마인더(alertSetting)
/// 2. 할일(Task)의 색상(colorId)과 리마인더(reminder), 실행일(executionDate)
/// 3. 습관(Habit)의 색상(colorId)과 리마인더(reminder)

void main() async {
  print('🔍 데이터베이스 검증 시작...\n');

  final db = AppDatabase();

  try {
    // ========== 1. 일정(Schedule) 검증 ==========
    print('📅 [일정(Schedule) 검증]');
    final schedules = await db.getSchedules();

    if (schedules.isEmpty) {
      print('   ⚠️  저장된 일정이 없습니다.');
    } else {
      print('   총 ${schedules.length}개의 일정 발견\n');

      for (int i = 0; i < schedules.length && i < 5; i++) {
        final schedule = schedules[i];
        print('   일정 #${schedule.id}:');
        print('   - 제목: ${schedule.summary}');
        print('   - 색상: ${schedule.colorId}');
        print(
          '   - 리마인더: ${schedule.alertSetting.isEmpty ? "(없음)" : schedule.alertSetting}',
        );
        print(
          '   - 반복 규칙: ${schedule.repeatRule.isEmpty ? "(없음)" : schedule.repeatRule}',
        );
        print('   - 시작: ${schedule.start}');
        print('   - 종료: ${schedule.end}');
        print('');
      }

      if (schedules.length > 5) {
        print('   ... 외 ${schedules.length - 5}개\n');
      }
    }

    // ========== 2. 할일(Task) 검증 ==========
    print('✅ [할일(Task) 검증]');
    final tasks = await db.select(db.task).get();

    if (tasks.isEmpty) {
      print('   ⚠️  저장된 할일이 없습니다.');
    } else {
      print('   총 ${tasks.length}개의 할일 발견\n');

      for (int i = 0; i < tasks.length && i < 5; i++) {
        final task = tasks[i];
        print('   할일 #${task.id}:');
        print('   - 제목: ${task.title}');
        print('   - 색상: ${task.colorId}');
        print('   - 리마인더: ${task.reminder.isEmpty ? "(없음)" : task.reminder}');
        print('   - 실행일: ${task.executionDate ?? "(없음)"}');
        print('   - 마감일: ${task.dueDate ?? "(없음)"}');
        print(
          '   - 반복 규칙: ${task.repeatRule.isEmpty ? "(없음)" : task.repeatRule}',
        );
        print('   - 완료 여부: ${task.completed ? "완료됨" : "미완료"}');
        print('');
      }

      if (tasks.length > 5) {
        print('   ... 외 ${tasks.length - 5}개\n');
      }
    }

    // ========== 3. 습관(Habit) 검증 ==========
    print('🔄 [습관(Habit) 검증]');
    final habits = await db.select(db.habit).get();

    if (habits.isEmpty) {
      print('   ⚠️  저장된 습관이 없습니다.');
    } else {
      print('   총 ${habits.length}개의 습관 발견\n');

      for (int i = 0; i < habits.length && i < 5; i++) {
        final habit = habits[i];
        print('   습관 #${habit.id}:');
        print('   - 제목: ${habit.title}');
        print('   - 색상: ${habit.colorId}');
        print('   - 리마인더: ${habit.reminder.isEmpty ? "(없음)" : habit.reminder}');
        print(
          '   - 반복 규칙: ${habit.repeatRule.isEmpty ? "(없음)" : habit.repeatRule}',
        );
        print('   - 생성일: ${habit.createdAt}');
        print('');
      }

      if (habits.length > 5) {
        print('   ... 외 ${habits.length - 5}개\n');
      }
    }

    // ========== 4. 최근 데이터 요약 ==========
    print('📊 [데이터 요약]');
    print('   - 일정: ${schedules.length}개');
    print('   - 할일: ${tasks.length}개');
    print('   - 습관: ${habits.length}개');
    print('   - 총계: ${schedules.length + tasks.length + habits.length}개\n');

    // ========== 5. 색상 분포 확인 ==========
    print('🎨 [색상 분포]');
    final scheduleColors = _countColors(
      schedules.map((s) => s.colorId).toList(),
    );
    final taskColors = _countColors(tasks.map((t) => t.colorId).toList());
    final habitColors = _countColors(habits.map((h) => h.colorId).toList());

    print('   일정 색상: ${scheduleColors.isEmpty ? "(없음)" : scheduleColors}');
    print('   할일 색상: ${taskColors.isEmpty ? "(없음)" : taskColors}');
    print('   습관 색상: ${habitColors.isEmpty ? "(없음)" : habitColors}\n');

    // ========== 6. 리마인더 설정 확인 ==========
    print('🔔 [리마인더 설정]');
    final scheduleReminders = schedules
        .where((s) => s.alertSetting.isNotEmpty)
        .length;
    final taskReminders = tasks.where((t) => t.reminder.isNotEmpty).length;
    final habitReminders = habits.where((h) => h.reminder.isNotEmpty).length;

    print('   일정 리마인더 설정: ${scheduleReminders}/${schedules.length}개');
    print('   할일 리마인더 설정: ${taskReminders}/${tasks.length}개');
    print('   습관 리마인더 설정: ${habitReminders}/${habits.length}개\n');

    // ========== 7. 할일 실행일 검증 ==========
    if (tasks.isNotEmpty) {
      print('📆 [할일 실행일 검증]');
      final tasksWithExecutionDate = tasks
          .where((t) => t.executionDate != null)
          .length;
      final recurringTasks = tasks.where((t) => t.repeatRule.isNotEmpty).length;

      print('   실행일 설정: ${tasksWithExecutionDate}/${tasks.length}개');
      print('   반복 설정: ${recurringTasks}/${tasks.length}개');

      // 반복 할일 중 실행일이 있는 것들 표시
      final recurringWithExecution = tasks.where(
        (t) => t.repeatRule.isNotEmpty && t.executionDate != null,
      );

      if (recurringWithExecution.isNotEmpty) {
        print('   반복 할일 + 실행일: ${recurringWithExecution.length}개');
        for (final task in recurringWithExecution.take(3)) {
          print('     - "${task.title}": ${task.executionDate}');
        }
      }
      print('');
    }

    print('✅ 검증 완료!');
  } catch (e, stackTrace) {
    print('❌ 오류 발생: $e');
    print('Stack trace: $stackTrace');
  } finally {
    await db.close();
  }
}

/// 색상 분포 계산
Map<String, int> _countColors(List<String> colors) {
  final Map<String, int> distribution = {};
  for (final color in colors) {
    distribution[color] = (distribution[color] ?? 0) + 1;
  }
  return distribution;
}
