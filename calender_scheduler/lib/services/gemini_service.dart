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
    print('🤖 [GeminiService] 초기화 완료: gemini-2.0-flash-exp');
  }

  /// 이미지를 분석하여 일정/할일/습관 추출
  ///
  /// [imageBytes]: 분석할 이미지의 바이트 데이터
  /// 반환: Map<String, dynamic> - schedules, todos, habits 배열을 포함하는 JSON
  /// 예외: GeminiException - API 호출 실패 시
  Future<Map<String, dynamic>> analyzeImage({
    required Uint8List imageBytes,
  }) async {
    print('📤 [GeminiService] 이미지 분석 시작... (크기: ${imageBytes.length} bytes)');

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
        print('🔄 [GeminiService] Gemini API 호출 중...');
        final response = await _model.generateContent(content);

        // 3. 응답 확인
        if (response.text == null || response.text!.isEmpty) {
          throw GeminiException('Gemini API 응답이 비어있습니다');
        }

        print('✅ [GeminiService] API 응답 수신 성공');
        print('📄 [GeminiService] 응답 길이: ${response.text!.length} characters');

        // 4. JSON 파싱
        final jsonResponse = _parseJsonResponse(response.text!);
        print('✅ [GeminiService] JSON 파싱 완료');
        print('📊 [GeminiService] 추출 결과:');
        print('   - 일정: ${jsonResponse['schedules']?.length ?? 0}개');
        print('   - 할 일: ${jsonResponse['tasks']?.length ?? 0}개');
        print('   - 습관: ${jsonResponse['habits']?.length ?? 0}개');
        print(
          '   - 관련 없는 이미지: ${jsonResponse['irrelevant_image_count'] ?? 0}개',
        );

        return jsonResponse;
      } catch (e) {
        print('❌ [GeminiService] 오류 발생: $e');
        throw GeminiException('이미지 분석 실패: $e');
      }
    });
  }

  /// JSON 응답 파싱 (마크다운 코드 블록 제거)
  ///
  /// Gemini가 ```json ... ``` 형식으로 반환하는 경우 처리
  Map<String, dynamic> _parseJsonResponse(String responseText) {
    print('🔍 [GeminiService] JSON 파싱 시작...');
    print('📝 [GeminiService] 원본 응답 길이: ${responseText.length} characters');

    String jsonStr = responseText.trim();

    // 마크다운 코드 블록 제거
    if (jsonStr.startsWith('```json')) {
      print('🔧 [GeminiService] 마크다운 코드 블록(```json) 감지 - 제거 중...');
      jsonStr = jsonStr.substring(7); // ```json 제거
    } else if (jsonStr.startsWith('```')) {
      print('🔧 [GeminiService] 마크다운 코드 블록(```) 감지 - 제거 중...');
      jsonStr = jsonStr.substring(3); // ``` 제거
    }

    if (jsonStr.endsWith('```')) {
      print('🔧 [GeminiService] 마크다운 코드 블록 종료(```) 감지 - 제거 중...');
      jsonStr = jsonStr.substring(0, jsonStr.length - 3); // ``` 제거
    }

    jsonStr = jsonStr.trim();
    print('✂️ [GeminiService] 정제된 JSON 길이: ${jsonStr.length} characters');

    try {
      print('🔄 [GeminiService] JSON.decode() 실행 중...');
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;
      print('✅ [GeminiService] JSON 파싱 성공!');

      // 필수 키 확인
      print('🔍 [GeminiService] 필수 키 검증 중...');
      final hasSchedules = parsed.containsKey('schedules');
      final hasTasks = parsed.containsKey('tasks');
      final hasHabits = parsed.containsKey('habits');

      print('   - schedules 존재: $hasSchedules');
      print('   - tasks 존재: $hasTasks');
      print('   - habits 존재: $hasHabits');

      if (!hasSchedules || !hasTasks || !hasHabits) {
        throw GeminiException('응답에 필수 키가 없습니다: schedules, tasks, habits');
      }

      print('✅ [GeminiService] 필수 키 검증 완료');
      return parsed;
    } catch (e) {
      print('═══════════════════════════════════════');
      print('❌ [GeminiService] JSON 파싱 실패');
      print('오류: $e');
      print('정제된 JSON (첫 500자):');
      print(jsonStr.length > 500 ? '${jsonStr.substring(0, 500)}...' : jsonStr);
      print('═══════════════════════════════════════');
      throw GeminiException('JSON 파싱 실패: $e');
    }
  }

  /// 재시도 로직을 포함한 작업 실행
  ///
  /// Exponential Backoff with Jitter 전략 사용
  /// - 429 (Rate Limit), 503 (Overloaded) 등 일시적 오류만 재시도
  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    print('🔁 [GeminiService] 재시도 로직 시작 (최대 $maxRetries회)');

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        print('🎯 [GeminiService] 시도 ${attempt + 1}/$maxRetries');
        final result = await operation();
        print('✅ [GeminiService] 작업 성공! (시도 ${attempt + 1}회)');
        return result;
      } catch (e) {
        print('⚠️ [GeminiService] 시도 ${attempt + 1} 실패: $e');

        if (_isRetryable(e) && attempt < maxRetries - 1) {
          final delay = _calculateDelay(attempt);
          print('⏳ [GeminiService] ${delay.inMilliseconds}ms 후 재시도...');
          print('🔄 [GeminiService] 재시도 가능한 오류 감지');
          await Future.delayed(delay);
        } else {
          print('❌ [GeminiService] 재시도 불가능하거나 최대 재시도 횟수 도달');
          rethrow;
        }
      }
    }

    print('❌ [GeminiService] 모든 재시도 실패');
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
