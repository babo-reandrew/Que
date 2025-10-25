import 'package:flutter/material.dart';

/// 결과 화면 - Gemini API 응답 결과 표시
class ResultScreen extends StatelessWidget {
  // TODO: Gemini API 응답 데이터를 받을 필드 추가
  // final GeminiResponse? geminiResponse;

  const ResultScreen({
    Key? key,
    // this.geminiResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xff111111)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '결과',
          style: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xff111111),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: 실제 Gemini API 응답 데이터 표시
            // - 분석 결과 텍스트
            // - 추출된 일정 정보
            // - 기타 메타데이터

            // 임시 화면
            Text(
              '임시화면',
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xff111111),
              ),
            ),
            SizedBox(height: 16),

            Text(
              'Gemini API 응답 결과가 여기에 표시됩니다',
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
