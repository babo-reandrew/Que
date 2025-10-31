// ===================================================================
// 🧪 Gemini API 테스트 전용 앱
// ===================================================================
// 이 파일은 Gemini API를 테스트하기 위한 독립 실행 앱입니다.
//
// 실행 방법:
// flutter run -t lib/gemini_test_main.dart
// ===================================================================

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screen/gemini_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
  }

  runApp(const GeminiTestApp());
}

class GeminiTestApp extends StatelessWidget {
  const GeminiTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini API 테스트',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Gmarket Sans'),
      home: const GeminiTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
