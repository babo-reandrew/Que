import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 🗑️ 변경 내용 취소 확인 모달 - Figma Property 1=Cancel_Short
///
/// Figma 스펙:
/// - 크기: 370x303px
/// - 배경: #FCFCFC
/// - Border: 1px solid rgba(17, 17, 17, 0.1)
/// - Shadow: 0px 2px 20px rgba(165, 165, 165, 0.2)
/// - Border Radius: 40px
///
/// 사용법:
/// ```dart
/// final confirmed = await showDiscardChangesModal(context);
/// if (confirmed == true) {
///   // 변경 사항 취소하고 닫기
///   Navigator.pop(context);
/// }
/// ```

Future<bool?> showDiscardChangesModal(BuildContext context) async {
  return await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Discard Changes',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const DiscardChangesModal();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // 하단에서 위로 슬라이드 애니메이션
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

class DiscardChangesModal extends StatelessWidget {
  const DiscardChangesModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16), // 하단 여백 16px
        child: Container(
          width: 370, // Figma: 370px
          height: 303, // Figma: 303px
          decoration: ShapeDecoration(
            color: const Color(0xFFFCFCFC), // #FCFCFC
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 40, // 라운드 40
                cornerSmoothing: 0.6, // Figma smoothing 60%
              ),
              side: BorderSide(
                color: const Color(0xFF111111).withOpacity(0.1),
                width: 1,
              ),
            ),
            shadows: [
              BoxShadow(
                color: const Color(0xFFA5A5A5).withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 36, 0, 0), // ✅ 상단만 36px
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 행: 텍스트 + 닫기 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                  ), // ✅ 좌우 28px
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 텍스트 영역
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "変更した内容を 破棄ますか？" - 22px extrabold, 행간 130%, 자간 -0.5%
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'LINE Seed JP App_TTF',
                                  fontWeight: FontWeight.w800, // extrabold
                                  fontSize: 22,
                                  height: 1.3, // 130%
                                  letterSpacing: -0.005 * 22, // -0.5%
                                  decoration: TextDecoration.none,
                                ),
                                children: const [
                                  TextSpan(
                                    text: '変更した内容を\n',
                                    style: TextStyle(color: Color(0xFF262626)),
                                  ),
                                  TextSpan(
                                    text: '破棄',
                                    style: TextStyle(
                                      color: Color(0xFFF22121), // #F22121 빨간색
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'しますか？',
                                    style: TextStyle(color: Color(0xFF262626)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20), // 하단 20px 띄우기
                            // "一回削除したものは、 戻すことができません。" - 13px regular, 행간 140%, 자간 -0.5%
                            const Text(
                              '一回削除したものは、\n戻すことができません。',
                              style: TextStyle(
                                fontFamily: 'LINE Seed JP App_TTF',
                                fontWeight: FontWeight.w400, // regular
                                fontSize: 13,
                                height: 1.4, // 140%
                                letterSpacing: -0.005 * 13, // -0.5%
                                color: Color(0xFF656565),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Modal Control Button (닫기) - X_icon.svg, 색상 #111111
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          width: 36,
                          height: 36,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4E4E4).withOpacity(0.9),
                            border: Border.all(
                              color: const Color(0xFF111111).withOpacity(0.02),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                offset: const Offset(0, 4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            'asset/icon/X_icon.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF111111),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 72), // 텍스트와 버튼 사이 간격 72px
                // CTA 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ), // ✅ 좌우 18px
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5).withOpacity(0.9),
                        border: Border.all(
                          color: const Color(0xFFFF0000).withOpacity(0.02),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            offset: const Offset(0, 4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '破棄する',
                          style: TextStyle(
                            fontFamily: 'LINE Seed JP App_TTF',
                            fontWeight: FontWeight.w800, // extrabold
                            fontSize: 15,
                            height: 1.4, // 140%
                            letterSpacing: -0.005 * 15, // -0.5%
                            color: Color(0xFFF22121), // #F22121 빨간색
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // ✅ 버튼 하단 20px
              ],
            ),
          ),
        ),
      ),
    );
  }
}
