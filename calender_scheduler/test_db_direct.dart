import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// SQLite3 직접 사용 데이터베이스 검증 스크립트
///
/// 실행 방법:
/// ```bash
/// flutter run test_db_direct.dart
/// ```

void main() async {
  print('🔍 데이터베이스 직접 검증 시작...\n');

  try {
    // 앱 문서 디렉토리 경로 가져오기
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = '${documentsDirectory.path}/db.sqlite';

    print('📁 데이터베이스 경로: $dbPath');

    // 데이터베이스 파일 존재 확인
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      print('❌ 데이터베이스 파일이 존재하지 않습니다.');
      return;
    }

    print('✅ 데이터베이스 파일 존재 확인\n');

    // SQLite3로 데이터베이스 열기
    final db = sqlite3.open(dbPath);

    // ========== 1. 테이블 존재 확인 ==========
    print('📊 [테이블 확인]');
    final tables = db.select(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    );

    print('   발견된 테이블:');
    for (final table in tables) {
      print('   - ${table['name']}');
    }
    print('');

    // ========== 2. Schedule 테이블 검증 ==========
    print('📅 [Schedule 테이블 검증]');

    final scheduleCount =
        db.select('SELECT COUNT(*) as count FROM schedule')[0]['count'] as int;
    print('   총 개수: $scheduleCount개\n');

    if (scheduleCount > 0) {
      final schedules = db.select(
        'SELECT id, summary, color_id, alert_setting, repeat_rule, start, end FROM schedule LIMIT 5',
      );

      for (final row in schedules) {
        print('   일정 #${row['id']}:');
        print('   - 제목: ${row['summary']}');
        print('   - 색상: ${row['color_id']}');
        print('   - 리마인더: ${row['alert_setting'] ?? "(없음)"}');
        print('   - 반복: ${row['repeat_rule'] ?? "(없음)"}');
        print('   - 시작: ${row['start']}');
        print('   - 종료: ${row['end']}');
        print('');
      }

      if (scheduleCount > 5) {
        print('   ... 외 ${scheduleCount - 5}개\n');
      }
    }

    // ========== 3. Task 테이블 검증 ==========
    print('✅ [Task 테이블 검증]');

    final taskCount =
        db.select('SELECT COUNT(*) as count FROM task')[0]['count'] as int;
    print('   총 개수: $taskCount개\n');

    if (taskCount > 0) {
      final tasks = db.select(
        'SELECT id, title, color_id, reminder, execution_date, due_date, repeat_rule, completed FROM task LIMIT 5',
      );

      for (final row in tasks) {
        print('   할일 #${row['id']}:');
        print('   - 제목: ${row['title']}');
        print('   - 색상: ${row['color_id']}');
        print('   - 리마인더: ${row['reminder'] ?? "(없음)"}');
        print('   - 실행일: ${row['execution_date'] ?? "(없음)"}');
        print('   - 마감일: ${row['due_date'] ?? "(없음)"}');
        print('   - 반복: ${row['repeat_rule'] ?? "(없음)"}');
        print('   - 완료: ${row['completed'] == 1 ? "완료" : "미완료"}');
        print('');
      }

      if (taskCount > 5) {
        print('   ... 외 ${taskCount - 5}개\n');
      }
    }

    // ========== 4. Habit 테이블 검증 ==========
    print('🔄 [Habit 테이블 검증]');

    final habitCount =
        db.select('SELECT COUNT(*) as count FROM habit')[0]['count'] as int;
    print('   총 개수: $habitCount개\n');

    if (habitCount > 0) {
      final habits = db.select(
        'SELECT id, title, color_id, reminder, repeat_rule, created_at FROM habit LIMIT 5',
      );

      for (final row in habits) {
        print('   습관 #${row['id']}:');
        print('   - 제목: ${row['title']}');
        print('   - 색상: ${row['color_id']}');
        print('   - 리마인더: ${row['reminder'] ?? "(없음)"}');
        print('   - 반복: ${row['repeat_rule'] ?? "(없음)"}');
        print('   - 생성일: ${row['created_at']}');
        print('');
      }

      if (habitCount > 5) {
        print('   ... 외 ${habitCount - 5}개\n');
      }
    }

    // ========== 5. 색상 분포 ==========
    print('🎨 [색상 분포]');

    if (scheduleCount > 0) {
      final scheduleColors = db.select(
        'SELECT color_id, COUNT(*) as count FROM schedule GROUP BY color_id',
      );
      print('   일정 색상:');
      for (final row in scheduleColors) {
        print('     - ${row['color_id']}: ${row['count']}개');
      }
    }

    if (taskCount > 0) {
      final taskColors = db.select(
        'SELECT color_id, COUNT(*) as count FROM task GROUP BY color_id',
      );
      print('   할일 색상:');
      for (final row in taskColors) {
        print('     - ${row['color_id']}: ${row['count']}개');
      }
    }

    if (habitCount > 0) {
      final habitColors = db.select(
        'SELECT color_id, COUNT(*) as count FROM habit GROUP BY color_id',
      );
      print('   습관 색상:');
      for (final row in habitColors) {
        print('     - ${row['color_id']}: ${row['count']}개');
      }
    }
    print('');

    // ========== 6. 리마인더 설정 통계 ==========
    print('🔔 [리마인더 설정 통계]');

    if (scheduleCount > 0) {
      final scheduleReminders =
          db.select(
                "SELECT COUNT(*) as count FROM schedule WHERE alert_setting != '' AND alert_setting IS NOT NULL",
              )[0]['count']
              as int;
      print('   일정 리마인더: $scheduleReminders/$scheduleCount개');
    }

    if (taskCount > 0) {
      final taskReminders =
          db.select(
                "SELECT COUNT(*) as count FROM task WHERE reminder != '' AND reminder IS NOT NULL",
              )[0]['count']
              as int;
      print('   할일 리마인더: $taskReminders/$taskCount개');
    }

    if (habitCount > 0) {
      final habitReminders =
          db.select(
                "SELECT COUNT(*) as count FROM habit WHERE reminder != '' AND reminder IS NOT NULL",
              )[0]['count']
              as int;
      print('   습관 리마인더: $habitReminders/$habitCount개');
    }
    print('');

    // ========== 7. 할일 실행일 통계 ==========
    if (taskCount > 0) {
      print('📆 [할일 실행일 통계]');

      final tasksWithExecutionDate =
          db.select(
                'SELECT COUNT(*) as count FROM task WHERE execution_date IS NOT NULL',
              )[0]['count']
              as int;

      final tasksWithRepeat =
          db.select(
                "SELECT COUNT(*) as count FROM task WHERE repeat_rule != '' AND repeat_rule IS NOT NULL",
              )[0]['count']
              as int;

      print('   실행일 설정: $tasksWithExecutionDate/$taskCount개');
      print('   반복 설정: $tasksWithRepeat/$taskCount개');

      // 반복 + 실행일이 모두 있는 할일
      final recurringWithExecution = db.select(
        "SELECT id, title, execution_date FROM task WHERE repeat_rule != '' AND repeat_rule IS NOT NULL AND execution_date IS NOT NULL LIMIT 3",
      );

      if (recurringWithExecution.isNotEmpty) {
        print('   반복 + 실행일:');
        for (final row in recurringWithExecution) {
          print('     - "${row['title']}": ${row['execution_date']}');
        }
      }
      print('');
    }

    // ========== 8. 요약 ==========
    print('📊 [전체 요약]');
    print('   - 일정: $scheduleCount개');
    print('   - 할일: $taskCount개');
    print('   - 습관: $habitCount개');
    print('   - 총계: ${scheduleCount + taskCount + habitCount}개\n');

    print('✅ 검증 완료!');

    db.dispose();
  } catch (e, stackTrace) {
    print('❌ 오류 발생: $e');
    print('Stack trace: $stackTrace');
  }
}
