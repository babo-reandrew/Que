import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';

/// 🍞 액션 토스트 (삭제/저장/변경)
///
/// Figma 스펙:
/// - 크기: 169x64px
/// - 배경: #FAFAFA
/// - Border: 이중 (안쪽 16%, 바깥 8%)
/// - Shadow: 0px -2px 8px rgba(186, 186, 186, 0.04)
/// - Border Radius: 18px (Smoothing 60%)
/// - 위치: SafeArea 8px 아래, 화면 중앙
/// - 애니메이션: 5초 후 위로 슬라이드 아웃
/// - 프로그레스: 상단 중앙에서 시계방향으로 5초간 채워짐
///
/// 사용법:
/// ```dart
/// showActionToast(context, type: ToastType.delete);
/// showActionToast(context, type: ToastType.save);
/// showActionToast(context, type: ToastType.change);
/// ```

enum ToastType {
  delete, // 削除されました (빨간색)
  save, // 保存されました (검은색)
  change, // 変更されました (파란색)
  inbox, // ヒキダシに保存されました (보라색)
}

class ActionToast extends StatefulWidget {
  final ToastType type;
  final VoidCallback? onDismiss;

  const ActionToast({super.key, required this.type, this.onDismiss});

  @override
  State<ActionToast> createState() => _ActionToastState();
}

class _ActionToastState extends State<ActionToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 2초 애니메이션
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 슬라이드 다운 애니메이션 (0 → 1)
    _slideAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.1, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // 2초 후 자동 제거
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _slideOut();
      }
    });
  }

  void _slideOut() async {
    // 위로 슬라이드 아웃
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget get _messageWidget {
    const baseStyle = TextStyle(
      fontFamily: 'LINE Seed JP App_TTF',
      fontWeight: FontWeight.w700, // bold
      fontSize: 13,
      height: 1.4, // 140%
      letterSpacing: -0.005 * 13, // -0.5%
      decoration: TextDecoration.none,
    );

    switch (widget.type) {
      case ToastType.delete:
        return RichText(
          maxLines: 2,
          softWrap: true,
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: '削除',
                style: baseStyle.copyWith(color: const Color(0xFFFF0000)),
              ),
              TextSpan(
                text: 'されました',
                style: baseStyle.copyWith(color: const Color(0xFF111111)),
              ),
            ],
          ),
        );
      case ToastType.save:
        return Text(
          '保存されました',
          style: baseStyle.copyWith(color: const Color(0xFF111111)),
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
        );
      case ToastType.change:
        return RichText(
          maxLines: 2,
          softWrap: true,
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: '変更',
                style: baseStyle.copyWith(color: const Color(0xFF0000FF)),
              ),
              TextSpan(
                text: 'されました',
                style: baseStyle.copyWith(color: const Color(0xFF111111)),
              ),
            ],
          ),
        );
      case ToastType.inbox:
        return RichText(
          maxLines: 2,
          softWrap: true,
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'ヒキダシに',
                style: baseStyle.copyWith(color: const Color(0xFF566099)),
              ),
              TextSpan(
                text: '\n保存されました',
                style: baseStyle.copyWith(color: const Color(0xFF111111)),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 8 + _slideAnimation.value,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 169,
              height: 64,
              decoration: ShapeDecoration(
                color: const Color(0xFFFAFAFA), // #FAFAFA
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 18,
                    cornerSmoothing: 0.6, // 60% smoothing
                  ),
                  side: BorderSide(
                    color: const Color(0xFF111111).withOpacity(0.08), // 8% 바깥쪽
                    width: 1,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: const Color(0xFFBABABA).withOpacity(0.04),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 안쪽 테두리 (6% - 고정)
                  Positioned.fill(
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 18,
                            cornerSmoothing: 0.6,
                          ),
                          side: BorderSide(
                            color: const Color(
                              0xFF111111,
                            ).withOpacity(0.06), // 6% 안쪽
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 텍스트
                  Center(
                    child: SizedBox(
                      width: 120, // 텍스트 영역만 좁혀 2줄 고정 개행
                      child: _messageWidget,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 토스트 표시 헬퍼 함수
void showActionToast(BuildContext context, {required ToastType type}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => ActionToast(
      type: type,
      onDismiss: () {
        overlayEntry.remove();
      },
    ),
  );

  overlay.insert(overlayEntry);
}
