// ===================================================================
// ⭐️ Gemini Service
// ===================================================================
// Google Gemini API를 사용하여 이미지에서 일정/할일/습관을 추출하는 서비스입니다.
//
// 주요 기능:
// - 이미지를 Gemini API로 전송
// - 구조화된 프롬프트로 JSON 응답 받기
// - 에러 처리 및 재시도 로직
// - API 호출 제한 대응 (Rate Limit)
// ===================================================================

import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../const/gemini_prompt.dart';

class GeminiService {
  late final GenerativeModel _model;
  final String apiKey;

  /// 최대 재시도 횟수
  static const int maxRetries = 3;

  /// 기본 재시도 대기 시간
  static const Duration baseDelay = Duration(seconds: 1);

  GeminiService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp', // 최신 실험 모델 (더 빠르고 정확함)
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2, // 낮은 값으로 일관성 있는 결과
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
      ),
    );
  }

  /// 이미지를 분석하여 일정/할일/습관 추출
  ///
  /// [imageBytes]: 분석할 이미지의 바이트 데이터
  /// 반환: Map<String, dynamic> - schedules, todos, habits 배열을 포함하는 JSON
  /// 예외: GeminiException - API 호출 실패 시
  Future<Map<String, dynamic>> analyzeImage({
    required Uint8List imageBytes,
  }) async {

    return await _executeWithRetry(() async {
      try {
        // 1. Content 구성 (이미지 + 프롬프트)
        final content = [
          Content.multi([
            DataPart('image/jpeg', imageBytes),
            TextPart(GEMINI_IMAGE_ANALYSIS_PROMPT),
          ]),
        ];

        // 2. Gemini API 호출
        final response = await _model.generateContent(content);

        // 3. 응답 확인
        if (response.text == null || response.text!.isEmpty) {
          throw GeminiException('Gemini API 응답이 비어있습니다');
        }


        // 4. JSON 파싱
        final jsonResponse = _parseJsonResponse(response.text!);

        return jsonResponse;
      } catch (e) {
        throw GeminiException('이미지 분석 실패: $e');
      }
    });
  }

  /// JSON 응답 파싱 (마크다운 코드 블록 제거)
  ///
  /// Gemini가 ```json ... ``` 형식으로 반환하는 경우 처리
  Map<String, dynamic> _parseJsonResponse(String responseText) {

    String jsonStr = responseText.trim();

    // 마크다운 코드 블록 제거
    if (jsonStr.startsWith('```json')) {
      jsonStr = jsonStr.substring(7); // ```json 제거
    } else if (jsonStr.startsWith('```')) {
      jsonStr = jsonStr.substring(3); // ``` 제거
    }

    if (jsonStr.endsWith('```')) {
      jsonStr = jsonStr.substring(0, jsonStr.length - 3); // ``` 제거
    }

    jsonStr = jsonStr.trim();

    try {
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;

      // 필수 키 확인
      final hasSchedules = parsed.containsKey('schedules');
      final hasTasks = parsed.containsKey('tasks');
      final hasHabits = parsed.containsKey('habits');


      if (!hasSchedules || !hasTasks || !hasHabits) {
        throw GeminiException('응답에 필수 키가 없습니다: schedules, tasks, habits');
      }

      return parsed;
    } catch (e) {
      throw GeminiException('JSON 파싱 실패: $e');
    }
  }

  /// 재시도 로직을 포함한 작업 실행
  ///
  /// Exponential Backoff with Jitter 전략 사용
  /// - 429 (Rate Limit), 503 (Overloaded) 등 일시적 오류만 재시도
  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final result = await operation();
        return result;
      } catch (e) {

        if (_isRetryable(e) && attempt < maxRetries - 1) {
          final delay = _calculateDelay(attempt);
          await Future.delayed(delay);
        } else {
          rethrow;
        }
      }
    }

    throw GeminiException('최대 재시도 횟수($maxRetries)를 초과했습니다');
  }

  /// 재시도 가능한 오류인지 확인
  ///
  /// - 429: Rate Limit (API 호출 제한)
  /// - 503: Service Unavailable (서버 과부하)
  /// - 500: Internal Server Error
  bool _isRetryable(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('429') ||
        errorStr.contains('503') ||
        errorStr.contains('500') ||
        errorStr.contains('rate limit') ||
        errorStr.contains('overloaded');
  }

  /// Exponential Backoff + Jitter 지연 시간 계산
  ///
  /// 공식: (baseDelay * 2^attempt) + random(0~1000ms)
  /// 예: 1초 → 2초 → 4초 (+ 랜덤)
  Duration _calculateDelay(int attempt) {
    final exponential = baseDelay * pow(2, attempt);
    final jitter = Duration(milliseconds: Random().nextInt(1000));
    return exponential + jitter;
  }
}

/// Gemini 서비스 전용 예외 클래스
class GeminiException implements Exception {
  final String message;

  GeminiException(this.message);

  @override
  String toString() => 'GeminiException: $message';
}
