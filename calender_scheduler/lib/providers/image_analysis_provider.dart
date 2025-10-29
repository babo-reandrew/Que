// ===================================================================
// ⭐️ Image Analysis Provider
// ===================================================================
// 이미지 분석 상태를 관리하는 Provider입니다.
//
// 역할:
// - 이미지 분석 요청 및 결과 관리
// - 로딩 상태 관리
// - 에러 처리
// - UI에 결과 노출
// ===================================================================

import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/gemini_service.dart';
import '../model/extracted_schedule.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageAnalysisProvider extends ChangeNotifier {
  /// 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 추출된 항목들 (타입별로 분리)
  List<ExtractedSchedule> _schedules = [];
  List<ExtractedTask> _tasks = [];
  List<ExtractedHabit> _habits = [];

  List<ExtractedSchedule> get schedules => _schedules;
  List<ExtractedTask> get tasks => _tasks;
  List<ExtractedHabit> get habits => _habits;

  /// 전체 항목들을 하나의 리스트로 반환 (UI 호환성)
  List<dynamic> get extractedItems => [..._schedules, ..._tasks, ..._habits];

  /// 에러 메시지
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// 전체 항목 개수
  int get totalCount => _schedules.length + _tasks.length + _habits.length;

  /// 이미지 분석 시작
  ///
  /// [imageBytes]: 분석할 이미지의 바이트 데이터
  Future<void> analyzeImage(Uint8List imageBytes) async {
    print('🔍 [ImageAnalysisProvider] 이미지 분석 시작');

    _isLoading = true;
    _errorMessage = null;
    _schedules = [];
    _tasks = [];
    _habits = [];
    notifyListeners();

    try {
      // 1. Gemini API 호출
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API 키가 설정되지 않았습니다.');
      }

      final geminiService = GeminiService(apiKey: apiKey);
      final result = await geminiService.analyzeImage(imageBytes: imageBytes);

      // 2. 응답 파싱
      final response = GeminiResponse.fromJson(result);
      _schedules = response.schedules;
      _tasks = response.tasks;
      _habits = response.habits;

      // 3. 결과 확인
      if (totalCount == 0) {
        _errorMessage = '이미지에서 일정/할 일/습관을 찾을 수 없습니다.\n다른 이미지를 시도해보세요.';
        print('⚠️ [ImageAnalysisProvider] 추출된 항목 없음');
      } else {
        print('✅ [ImageAnalysisProvider] 분석 완료: $totalCount개 항목');
        print('   - 일정: ${_schedules.length}개');
        print('   - 작업: ${_tasks.length}개');
        print('   - 습관: ${_habits.length}개');
      }
    } on GeminiException catch (e) {
      _errorMessage = e.message;
      print('❌ [ImageAnalysisProvider] Gemini 오류: ${e.message}');
    } catch (e) {
      _errorMessage = '알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.';
      print('❌ [ImageAnalysisProvider] 예상치 못한 오류: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 특정 항목 제거
  ///
  /// [index]: 제거할 항목의 인덱스 (전체 리스트 기준)
  void removeItem(int index) {
    final allItems = extractedItems;
    if (index >= 0 && index < allItems.length) {
      final item = allItems[index];

      if (item is ExtractedSchedule) {
        _schedules.remove(item);
      } else if (item is ExtractedTask) {
        _tasks.remove(item);
      } else if (item is ExtractedHabit) {
        _habits.remove(item);
      }

      print('🗑️ [ImageAnalysisProvider] 항목 제거: 인덱스 $index');
      notifyListeners();
    }
  }

  /// 특정 항목 업데이트
  ///
  /// [index]: 업데이트할 항목의 인덱스
  /// [updatedItem]: 새로운 데이터
  void updateItem(int index, dynamic updatedItem) {
    final allItems = extractedItems;
    if (index >= 0 && index < allItems.length) {
      final item = allItems[index];

      if (item is ExtractedSchedule && updatedItem is ExtractedSchedule) {
        final itemIndex = _schedules.indexOf(item);
        if (itemIndex >= 0) _schedules[itemIndex] = updatedItem;
      } else if (item is ExtractedTask && updatedItem is ExtractedTask) {
        final itemIndex = _tasks.indexOf(item);
        if (itemIndex >= 0) _tasks[itemIndex] = updatedItem;
      } else if (item is ExtractedHabit && updatedItem is ExtractedHabit) {
        final itemIndex = _habits.indexOf(item);
        if (itemIndex >= 0) _habits[itemIndex] = updatedItem;
      }

      print('✏️ [ImageAnalysisProvider] 항목 업데이트: 인덱스 $index');
      notifyListeners();
    }
  }

  /// 결과 초기화
  void clearResults() {
    _schedules = [];
    _tasks = [];
    _habits = [];
    _errorMessage = null;
    _isLoading = false;
    print('🧹 [ImageAnalysisProvider] 결과 초기화');
    notifyListeners();
  }

  /// 에러 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    print('♻️ [ImageAnalysisProvider] dispose 호출');
    super.dispose();
  }
}
