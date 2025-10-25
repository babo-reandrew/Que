import 'package:flutter/material.dart';
import 'result_screen.dart';
import '../component/modal/image_picker_smooth_sheet.dart'; // ✅ smooth_sheet의 PickedImage 사용

/// 로딩 화면 - Google Gemini API 호출 및 응답 대기
class LoadingScreen extends StatefulWidget {
  final List<PickedImage> selectedImages;

  const LoadingScreen({Key? key, required this.selectedImages})
    : super(key: key);

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
    // TODO: [1단계] 선택한 이미지 데이터 준비
    // - widget.selectedImages를 Gemini API가 받을 수 있는 형태로 변환
    // - 예: File 객체 → bytes, base64, 또는 multipart form data

    // TODO: [2단계] Google Gemini API 호출
    // - API 엔드포인트: https://generativelanguage.googleapis.com/v1/...
    // - 헤더: Authorization, Content-Type 등
    // - Body: 이미지 데이터 + 프롬프트
    // 예시 코드:
    // final response = await http.post(
    //   Uri.parse('GEMINI_API_ENDPOINT'),
    //   headers: {
    //     'Authorization': 'Bearer YOUR_API_KEY',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode({
    //     'images': preparedImageData,
    //     'prompt': 'your prompt here',
    //   }),
    // );

    // TODO: [3단계] 응답 처리
    // - response.statusCode 확인
    // - JSON 파싱: final result = jsonDecode(response.body);
    // - 에러 처리

    // ⏰ 임시: 5초 대기 (실제로는 위의 API 호출 시간이 로딩 시간)
    await Future.delayed(Duration(seconds: 5));

    // TODO: [4단계] 결과 화면으로 이동
    // - API 응답 데이터를 ResultScreen으로 전달
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            // TODO: Gemini API 응답 데이터를 여기에 전달
            // geminiResponse: result,
          ),
        ),
      );
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
