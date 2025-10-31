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
  
  
  if (!File(dbPath).existsSync()) {
    
    // iOS Simulator 경로 찾기
    final libraryPath = path.join(home, 'Library', 'Developer', 'CoreSimulator');
    
    return;
  }
  
  final db = TestDatabase(NativeDatabase(File(dbPath)));
  
  try {
    final patterns = await db.select(db.recurringPatterns).get();
    
    
    for (var pattern in patterns) {
    }
    
  } catch (e) {
  } finally {
    await db.close();
  }
}
