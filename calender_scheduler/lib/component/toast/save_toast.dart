import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';

/// 🍞 저장 토스트 (생성 후 표시)
///
/// Figma 스펙:
///
/// **일반 저장 (캘린더에 표시):**
/// - 크기: 169x61px
/// - 메인 텍스트: "保存されました" (13px, Bold, #111111)
/// - 서브 텍스트: "タップして詳細を見る" (11px, Bold, #656565)
/// - Shadow: 0px -2px 8px rgba(186, 186, 186, 0.08)
///
/// **인박스 저장:**
/// - 크기: 162x60px
/// - 텍스트: "ヒキダシに\n保存されました" (13px, Bold, #111111, 2줄)
/// - Shadow: 0px -2px 8px rgba(186, 186, 186, 0.04)
///
/// **공통:**
/// - 배경: #FAFAFA
/// - Border: 1px solid rgba(17, 17, 17, 0.08)
/// - Border Radius: 18px (Smoothing 60%)
/// - 위치: SafeArea 8px 아래, 화면 중앙
/// - 애니메이션: 2초 후 위로 슬라이드 아웃
/// - 탭 가능: 탭하면 상세 바텀시트 열림
///
/// 사용법:
/// ```dart
/// showSaveToast(
///   context,
///   toInbox: false,
///   onTap: () => openDetailBottomSheet(id),
/// );
/// ```

class SaveToast extends StatefulWidget {
  final bool toInbox; // true: 인박스 저장, false: 캘린더 저장
  final VoidCallback? onTap; // 탭 시 실행할 콜백
  final VoidCallback? onDismiss;

  const SaveToast({
    super.key,
    required this.toInbox,
    this.onTap,
    this.onDismiss,
  });

  @override
  State<SaveToast> createState() => _SaveToastState();
}

class _SaveToastState extends State<SaveToast>
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
            child: GestureDetector(
              onTap: () {
                // 탭하면 콜백 실행하고 즉시 슬라이드 아웃
                widget.onTap?.call();
                _slideOut();
              },
              child: Container(
                width: widget.toInbox ? 162 : 169,
                height: widget.toInbox ? 60 : 61,
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 12,
                ),
                decoration: ShapeDecoration(
                  color: const Color(0xFFFAFAFA), // #FAFAFA
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 18,
                      cornerSmoothing: 0.6, // 60% smoothing
                    ),
                    side: BorderSide(
                      color: const Color(
                        0xFF111111,
                      ).withOpacity(0.08), // 8% 바깥쪽
                      width: 1,
                    ),
                  ),
                  shadows: [
                    BoxShadow(
                      color: const Color(
                        0xFFBABABA,
                      ).withOpacity(widget.toInbox ? 0.04 : 0.08),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 메인 텍스트
                    Text(
                      widget.toInbox ? 'ヒキダシに\n保存されました' : '保存されました',
                      style: const TextStyle(
                        fontFamily: 'LINE Seed JP App_TTF',
                        fontWeight: FontWeight.w700, // bold
                        fontSize: 13,
                        height: 1.4, // 140%
                        letterSpacing: -0.005 * 13, // -0.5%
                        color: Color(0xFF111111),
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // 서브 텍스트 (캘린더 저장일 때만)
                    if (!widget.toInbox) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'タップして詳細を見る',
                        style: TextStyle(
                          fontFamily: 'LINE Seed JP App_TTF',
                          fontWeight: FontWeight.w700, // bold
                          fontSize: 11,
                          height: 1.4, // 140%
                          letterSpacing: -0.005 * 11, // -0.5%
                          color: Color(0xFF656565),
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 저장 토스트 표시 헬퍼 함수
void showSaveToast(
  BuildContext context, {
  required bool toInbox,
  VoidCallback? onTap,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => SaveToast(
      toInbox: toInbox,
      onTap: onTap,
      onDismiss: () {
        overlayEntry.remove();
      },
    ),
  );

  overlay.insert(overlayEntry);
}
