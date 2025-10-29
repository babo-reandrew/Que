import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

// 간단한 테이블 정의
class RecurringPatterns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scheduleId => integer()();
  TextColumn get rrule => text()();
}

@DriftDatabase(tables: [RecurringPatterns])
class TestDatabase extends _$TestDatabase {
  TestDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}

void main() async {
  // 데이터베이스 경로 찾기
  final home = Platform.environment['HOME'];
  final dbPath = path.join(
    home!,
    'Library',
    'Containers',
    'com.example.calenderScheduler',
    'Data',
    'Library',
    'Application Support',
    'database',
    'schedule.db'
  );
  
  print('🔍 데이터베이스 경로: $dbPath');
  
  if (!File(dbPath).existsSync()) {
    print('❌ 데이터베이스 파일 없음!');
    print('\n다른 경로 시도...');
    
    // iOS Simulator 경로 찾기
    final libraryPath = path.join(home, 'Library', 'Developer', 'CoreSimulator');
    print('Simulator 경로: $libraryPath');
    
    return;
  }
  
  final db = TestDatabase(NativeDatabase(File(dbPath)));
  
  try {
    final patterns = await db.select(db.recurringPatterns).get();
    
    print('\n📊 저장된 반복 패턴:');
    print('총 ${patterns.length}개\n');
    
    for (var pattern in patterns) {
      print('ID: ${pattern.id}');
      print('Schedule ID: ${pattern.scheduleId}');
      print('RRULE: ${pattern.rrule}');
      print('---');
    }
    
  } catch (e) {
    print('❌ 쿼리 실패: $e');
  } finally {
    await db.close();
  }
}
