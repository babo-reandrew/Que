import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 🗑️ 데이터베이스 삭제 스크립트
///
/// **사용법:**
/// ```bash
/// dart run calender_scheduler/delete_database.dart
/// ```
///
/// **주의:**
/// - 모든 데이터가 삭제됩니다!
/// - 앱을 재시작하면 마이그레이션이 자동 실행됩니다

void main() async {
  try {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    if (await file.exists()) {
      await file.delete();
      print('✅ 데이터베이스 삭제 완료: ${file.path}');
      print('🔄 앱을 재시작하면 스키마 v12로 재생성됩니다.');
    } else {
      print('ℹ️ 데이터베이스 파일이 존재하지 않습니다: ${file.path}');
    }
  } catch (e) {
    print('❌ 오류 발생: $e');
  }
}
