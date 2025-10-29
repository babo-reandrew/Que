// ===================================================================
// ⭐️ Loading Overlay Widget
// ===================================================================
// 전체 화면을 덮는 로딩 오버레이 위젯입니다.
//
// 사용처:
// - 이미지 분석 중
// - API 호출 중
// - 데이터 저장 중
//
// 특징:
// - 반투명 배경으로 하위 UI 비활성화
// - 로딩 인디케이터 + 안내 메시지
// - 카드 형태의 깔끔한 디자인
// ===================================================================

import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  /// 로딩 상태 여부
  final bool isLoading;

  /// 하위 위젯 (로딩이 false일 때 보여줄 컨텐츠)
  final Widget child;

  /// 로딩 메시지 (기본값: 'AI가 이미지를 분석 중입니다...')
  final String? loadingMessage;

  /// 서브 메시지 (기본값: '잠시만 기다려주세요')
  final String? subMessage;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
    this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 하위 컨텐츠
        child,

        // 로딩 오버레이
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.6), // 반투명 배경
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 로딩 인디케이터
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 메인 메시지
                      Text(
                        loadingMessage ?? 'AI가 이미지를 분석 중입니다...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 서브 메시지
                      Text(
                        subMessage ?? '잠시만 기다려주세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 간단한 로딩 인디케이터 (오버레이 없이)
class SimpleLoadingIndicator extends StatelessWidget {
  final String? message;

  const SimpleLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}
