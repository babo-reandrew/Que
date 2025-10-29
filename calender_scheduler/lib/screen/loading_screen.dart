import 'package:flutter/material.dart';
import 'gemini_result_confirmation_screen.dart';
import '../component/modal/image_picker_smooth_sheet.dart'; // ✅ smooth_sheet의 PickedImage 사용
import '../services/gemini_service.dart';
import '../model/extracted_schedule.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 로딩 화면 - Google Gemini API 호출 및 응답 대기
class LoadingScreen extends StatefulWidget {
  final List<PickedImage> selectedImages;

  const LoadingScreen({super.key, required this.selectedImages});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _processImages();
  }

  /// 이미지 처리 및 Gemini API 호출
  Future<void> _processImages() async {
    print('═══════════════════════════════════════');
    print('🧪 [LoadingScreen] Gemini 분석 시작');
    print('📸 [LoadingScreen] 선택된 이미지: ${widget.selectedImages.length}개');
    print('═══════════════════════════════════════');

    try {
      // [1단계] 첫 번째 이미지 데이터 준비 (현재는 단일 이미지만 처리)
      final firstImage = widget.selectedImages.first;
      Uint8List? imageBytes;

      if (firstImage.isAsset && firstImage.asset != null) {
        // AssetEntity → bytes
        imageBytes = await firstImage.asset!.originBytes;
        print(
          '✅ [LoadingScreen] Asset 이미지 변환 완료: ${imageBytes?.length ?? 0} bytes',
        );
      } else if (firstImage.isFile && firstImage.file != null) {
        // XFile → bytes
        imageBytes = await firstImage.file!.readAsBytes();
        print('✅ [LoadingScreen] File 이미지 변환 완료: ${imageBytes.length} bytes');
      }

      if (imageBytes == null) {
        throw Exception('이미지 데이터를 읽을 수 없습니다');
      }

      // [2단계] Gemini API 호출
      print('📤 [LoadingScreen] Gemini API 호출 중...');
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API 키가 설정되지 않았습니다. .env 파일을 확인해주세요.');
      }

      final geminiService = GeminiService(apiKey: apiKey);
      final response = await geminiService.analyzeImage(imageBytes: imageBytes);

      print('📥 [LoadingScreen] Gemini 응답 받음');
      print('  - 일정: ${response['schedules']?.length ?? 0}개');
      print('  - 작업: ${response['tasks']?.length ?? 0}개');
      print('  - 습관: ${response['habits']?.length ?? 0}개');
      print('  - 관련 없는 이미지: ${response['irrelevant_image_count'] ?? 0}개');

      // [3단계] JSON을 모델로 변환
      final schedules = (response['schedules'] as List? ?? [])
          .map(
            (json) => ExtractedSchedule.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      final tasks = (response['tasks'] as List? ?? [])
          .map((json) => ExtractedTask.fromJson(json as Map<String, dynamic>))
          .toList();
      final habits = (response['habits'] as List? ?? [])
          .map((json) => ExtractedHabit.fromJson(json as Map<String, dynamic>))
          .toList();

      // [4단계] 확인 화면으로 이동
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GeminiResultConfirmationScreen(
              schedules: schedules,
              tasks: tasks,
              habits: habits,
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════');
      print('❌ [LoadingScreen] 오류 발생:');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('═══════════════════════════════════════');

      // 에러 다이얼로그 표시
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('분석 실패'),
            content: Text('이미지 분석 중 오류가 발생했습니다:\n\n$e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(); // LoadingScreen 닫기
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로딩 인디케이터
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff566099)),
              strokeWidth: 3,
            ),
            SizedBox(height: 32),

            // 로딩 텍스트
            Text(
              '이미지 분석 중...',
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xff111111),
              ),
            ),
            SizedBox(height: 12),

            // 선택된 이미지 개수
            Text(
              '${widget.selectedImages.length}개의 이미지',
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
