import 'package:get_it/get_it.dart';
import 'lib/Database/schedule_database.dart';

/// 🔧 데이터베이스 마이그레이션 수동 실행 스크립트
///
/// **문제:**
/// - SqliteException: table schedule has no column named original_hour
///
/// **원인:**
/// - 스키마에는 originalHour, originalMinute 컬럼이 정의되어 있지만
/// - 실제 데이터베이스 테이블에는 컬럼이 없음
/// - 마이그레이션이 실행되지 않음
///
/// **해결:**
/// - 이 스크립트를 실행하여 수동으로 컬럼 추가

Future<void> main() async {
  print('🔧 데이터베이스 마이그레이션 시작...');

  try {
    final db = GetIt.I<AppDatabase>();

    // v11 → v12 마이그레이션 수동 실행
    print('📝 Schedule 테이블에 timezone, originalHour, originalMinute 추가...');

    await db.customStatement(
      'ALTER TABLE schedule ADD COLUMN timezone TEXT NOT NULL DEFAULT ""',
    );
    print('  ✅ timezone 컬럼 추가 완료');

    await db.customStatement(
      'ALTER TABLE schedule ADD COLUMN original_hour INTEGER',
    );
    print('  ✅ original_hour 컬럼 추가 완료');

    await db.customStatement(
      'ALTER TABLE schedule ADD COLUMN original_minute INTEGER',
    );
    print('  ✅ original_minute 컬럼 추가 완료');

    // 기존 데이터 마이그레이션
    print('📝 기존 데이터 마이그레이션 중...');
    await db.customStatement('''
      UPDATE schedule
      SET 
        original_hour = CAST(strftime('%H', start) AS INTEGER),
        original_minute = CAST(strftime('%M', start) AS INTEGER),
        timezone = ''
      WHERE original_hour IS NULL
    ''');
    print('  ✅ 기존 데이터 마이그레이션 완료');

    print('✅ 마이그레이션 완료!');
  } catch (e, stackTrace) {
    print('❌ 마이그레이션 실패: $e');
    print('스택: $stackTrace');

    // 에러가 발생하면 이미 컬럼이 존재하거나 다른 문제일 수 있음
    if (e.toString().contains('duplicate column name')) {
      print('ℹ️ 컬럼이 이미 존재합니다. 마이그레이션이 이미 완료되었을 수 있습니다.');
    }
  }
}
