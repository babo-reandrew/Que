import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../toast/action_toast.dart';

/// 🗑️ 삭제 확인 모달 - Figma Property 1=Cancel_Short
///
/// Figma 스펙:
/// - 크기: 370x303px
/// - 배경: #FCFCFC
/// - Border: 1px solid rgba(17, 17, 17, 0.1)
/// - Shadow: 0px 2px 20px rgba(165, 165, 165, 0.2)
/// - Border Radius: 36px
/// - 하단 여백: 16px (카드 베이스와 동일)
///
/// 사용법:
/// ```dart
/// showDeleteConfirmationModal(
///   context,
///   onDelete: () async {
///     await database.deleteSchedule(id);
///   },
/// );
/// ```
Future<void> showDeleteConfirmationModal(
  BuildContext context, {
  required Future<void> Function() onDelete,
}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Delete Confirmation',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return DeleteConfirmationModal(onDelete: onDelete);
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

class DeleteConfirmationModal extends StatelessWidget {
  final Future<void> Function() onDelete;

  const DeleteConfirmationModal({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16), // 하단 여백 16px
        child: Container(
          width: 370, // Figma: 370px
          // 동적 높이: 상단 37px + 제목(~62px) + 20px + 설명(~36px) + 72px + 버튼(56px) + 20px ≈ 303px
          constraints: const BoxConstraints(minHeight: 260, maxHeight: 320),
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
            padding: const EdgeInsets.fromLTRB(
              0,
              36,
              0,
              0,
            ), // ✅ 상단만 36px (좌우는 각 섹션에서 개별 적용)
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 행: 텍스트 + 닫기 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                  ), // ✅ 좌우 28px (모달 좌측 끝에서부터)
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 텍스트 영역
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "内容を 削除ますか？" - 22px extrabold, 행간 140%, 자간 -0.5%
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily:
                                      'LINE Seed JP App_TTF', // 정확한 폰트 패밀리명
                                  fontWeight: FontWeight
                                      .w800, // extrabold (LINESeedJP의 가장 두꺼운 폰트)
                                  fontSize: 22,
                                  height: 1.4, // 140%
                                  letterSpacing: -0.005 * 22, // -0.5%
                                  decoration: TextDecoration.none, // 하이라이트 제거
                                ),
                                children: const [
                                  TextSpan(
                                    text: '内容を\n',
                                    style: TextStyle(color: Color(0xFF262626)),
                                  ),
                                  TextSpan(
                                    text: '削除',
                                    style: TextStyle(
                                      color: Color(0xFFF22121), // #F22121 빨간색
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'ますか？',
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
                                fontFamily: 'LINESeedJP',
                                fontWeight: FontWeight.w400, // regular
                                fontSize: 13,
                                height: 1.4, // 140%
                                letterSpacing: -0.005 * 13, // -0.5%
                                color: Color(0xFF656565),
                                decoration: TextDecoration.none, // 하이라이트 제거
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Modal Control Button (닫기) - X_icon.svg, 색상 #111111
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
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
                            'asset/icon/X_icon.svg', // X_icon.svg로 변경
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF111111), // #111111 색상
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 72), // 텍스트 아래 72px 띄우기
                // CTA 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ), // ✅ 좌우 18px (버튼 여백)
                  child: GestureDetector(
                    onTap: () async {
                      // 모달 먼저 닫기
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                      // 삭제 실행
                      await onDelete();

                      // ✅ 토스트 표시
                      if (context.mounted) {
                        showActionToast(context, type: ToastType.delete);
                      }
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5).withOpacity(0.9),
                        border: Border.all(
                          color: const Color(0xFFFF0000).withOpacity(0.01),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '削除する',
                        style: TextStyle(
                          fontFamily: 'LINESeedJP',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.4, // 140%
                          letterSpacing: -0.005 * 15,
                          color: Color(0xFFFF0000),
                          decoration: TextDecoration.none, // 하이라이트 제거
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
