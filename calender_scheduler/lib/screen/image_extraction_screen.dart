// ===================================================================
// ⭐️ Image Extraction Screen
// ===================================================================
// 이미지에서 일정/할일/습관을 추출하는 메인 화면입니다.
//
// 주요 흐름:
// 1. 이미지 선택 (갤러리 or 카메라)
// 2. Gemini API로 분석 (로딩 화면 표시)
// 3. 결과를 카드 형태로 표시
// 4. 개별 저장 or 모두 저장
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/image_analysis_provider.dart';
import '../component/loading_overlay.dart';
import 'gemini_result_confirmation_screen.dart';

class ImageExtractionScreen extends StatefulWidget {
  const ImageExtractionScreen({super.key});

  @override
  State<ImageExtractionScreen> createState() => _ImageExtractionScreenState();
}

class _ImageExtractionScreenState extends State<ImageExtractionScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지에서 일정 추출'),
        centerTitle: true,
        actions: [
          // 결과 초기화 버튼
          Consumer<ImageAnalysisProvider>(
            builder: (context, provider, child) {
              if (provider.extractedItems.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: '다시 시작',
                  onPressed: () {
                    provider.clearResults();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ImageAnalysisProvider>(
        builder: (context, provider, child) {
          return LoadingOverlay(
            isLoading: provider.isLoading,
            loadingMessage: 'AI가 이미지를 분석 중입니다...',
            subMessage: '일정, 할 일, 습관을 찾고 있어요',
            child: _buildBody(context, provider),
          );
        },
      ),
    );
  }

  /// 메인 바디 위젯
  Widget _buildBody(BuildContext context, ImageAnalysisProvider provider) {
    // 1. 에러가 있는 경우
    if (provider.errorMessage != null) {
      return _buildErrorState(context, provider);
    }

    // 2. 추출된 결과가 있는 경우 → 확인 화면으로 이동
    if (provider.extractedItems.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToConfirmation(context, provider);
      });
      return const SizedBox.shrink();
    }

    // 3. 초기 상태 (이미지 선택 대기)
    return _buildEmptyState(context);
  }

  /// 확인 화면으로 이동
  void _navigateToConfirmation(
    BuildContext context,
    ImageAnalysisProvider provider,
  ) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => GeminiResultConfirmationScreen(
              schedules: provider.schedules,
              tasks: provider.tasks,
              habits: provider.habits,
            ),
          ),
        )
        .then((addedCount) {
          // 확인 화면에서 돌아왔을 때
          if (addedCount != null && addedCount > 0) {
            // 결과 초기화
            provider.clearResults();
            // 홈 화면으로 이동
            Navigator.of(context).pop();
          }
        });
  }

  /// 초기 상태: 이미지 선택 안내
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              '이미지를 선택하면\nAI가 일정을 추출해드려요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '캘린더, 메모, 다이어리 등의\n이미지를 업로드해주세요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 40),

            // 이미지 선택 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 갤러리에서 선택
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
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

                // 카메라로 촬영
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
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
        ),
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState(
    BuildContext context,
    ImageAnalysisProvider provider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 24),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 32),

            // 재시도 버튼
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 선택 및 분석
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048, // 이미지 크기 제한 (Gemini API 최적화)
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }


      // 이미지 바이트 읽기
      final bytes = await image.readAsBytes();

      // Provider를 통해 분석 시작
      if (!mounted) return;
      final provider = context.read<ImageAnalysisProvider>();
      await provider.analyzeImage(bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
