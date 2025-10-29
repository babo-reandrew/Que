// ===================================================================
// ⭐️ Gemini Test Screen
// ===================================================================
// Gemini API 연결 테스트를 위한 간단한 화면입니다.
//
// 기능:
// - 이미지 선택 (갤러리/카메라)
// - Gemini API로 전송
// - 결과를 print로 콘솔에 출력
// ===================================================================

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiTestScreen extends StatefulWidget {
  const GeminiTestScreen({super.key});

  @override
  State<GeminiTestScreen> createState() => _GeminiTestScreenState();
}

class _GeminiTestScreenState extends State<GeminiTestScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _resultText;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini API 테스트'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                const Text(
                  'Gemini가 이미지를 분석하고 있습니다...',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ] else if (_errorMessage != null) ...[
                Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                const SizedBox(height: 24),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _resultText = null;
                    });
                  },
                  child: const Text('다시 시도'),
                ),
              ] else if (_resultText != null) ...[
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  '✅ Gemini 응답 성공!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _resultText!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _resultText = null;
                      _errorMessage = null;
                    });
                  },
                  child: const Text('다시 테스트'),
                ),
              ] else ...[
                const Icon(
                  Icons.add_photo_alternate,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Gemini API 연결 테스트',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  '이미지를 선택하면\nGemini가 분석하고 결과를 콘솔에 출력합니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _testGemini(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('갤러리'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _testGemini(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('카메라'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Gemini API 테스트 실행
  Future<void> _testGemini(ImageSource source) async {
    try {
      print('═══════════════════════════════════════');
      print('🧪 [GeminiTest] 테스트 시작');
      print('═══════════════════════════════════════');

      // 1. 이미지 선택
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image == null) {
        print('❌ [GeminiTest] 이미지 선택 취소됨');
        return;
      }

      print('✅ [GeminiTest] 이미지 선택됨: ${image.path}');

      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _resultText = null;
      });

      // 2. API 키 확인
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('.env 파일에 GEMINI_API_KEY가 설정되지 않았습니다');
      }

      print('✅ [GeminiTest] API 키 확인됨: ${apiKey.substring(0, 10)}...');

      // 3. 이미지 바이트 읽기
      final bytes = await image.readAsBytes();
      print('✅ [GeminiTest] 이미지 크기: ${bytes.length} bytes');

      // 4. Gemini 모델 초기화
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
        ),
      );

      print('✅ [GeminiTest] Gemini 모델 초기화 완료: gemini-1.5-flash');

      // 5. 간단한 프롬프트로 테스트
      const testPrompt = '''
이미지에서 다음 정보를 추출해주세요:

1. 이미지에 무엇이 보이나요?
2. 일정, 할 일, 또는 습관과 관련된 텍스트가 있나요?
3. 날짜나 시간 정보가 있나요?

간단히 설명해주세요.
''';

      print('📤 [GeminiTest] Gemini API 호출 시작...');
      print('📝 [GeminiTest] 프롬프트: ${testPrompt.substring(0, 50)}...');

      // 6. API 호출
      final content = [
        Content.multi([DataPart('image/jpeg', bytes), TextPart(testPrompt)]),
      ];

      final startTime = DateTime.now();
      final response = await model.generateContent(content);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      print('✅ [GeminiTest] API 응답 수신 완료 (소요 시간: ${duration.inSeconds}초)');

      // 7. 응답 출력
      final responseText = response.text ?? '(응답 없음)';
      print('═══════════════════════════════════════');
      print('📥 [GeminiTest] Gemini 응답:');
      print('═══════════════════════════════════════');
      print(responseText);
      print('═══════════════════════════════════════');

      // 8. UI 업데이트
      setState(() {
        _resultText = responseText;
        _isLoading = false;
      });

      print('✅ [GeminiTest] 테스트 완료!');
      print('═══════════════════════════════════════');

      // 성공 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Gemini 응답 성공! (${duration.inSeconds}초 소요)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════');
      print('❌ [GeminiTest] 오류 발생:');
      print('═══════════════════════════════════════');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('═══════════════════════════════════════');

      setState(() {
        _errorMessage = '오류 발생:\n$e';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 오류: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
