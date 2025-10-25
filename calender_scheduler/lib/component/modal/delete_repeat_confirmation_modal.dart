import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../toast/action_toast.dart';

/// 🗑️ 반복 일정/할일/습관 삭제 확인 모달 - Figma Property 1=Delete
///
/// Figma 스펙:
/// - 크기: 370x438px
/// - 배경: #FCFCFC
/// - Border: 1px solid rgba(17, 17, 17, 0.1)
/// - Shadow: 0px 2px 20px rgba(165, 165, 165, 0.2)
/// - Border Radius: 36px
///
/// 삭제 옵션:
/// 1. この回のみ (이 일정만): 현재 일정만 삭제
/// 2. この予定以降 (이 일정 이후): 미래 일정만 삭제 (과거 체크된 항목 유지)
/// 3. すべての回 (모든 일정): 전체 삭제
///
/// 사용법:
/// ```dart
/// showDeleteRepeatConfirmationModal(
///   context,
///   onDeleteThis: () async {
///     // 이 일정만 삭제
///   },
///   onDeleteFuture: () async {
///     // 이후 일정 삭제
///   },
///   onDeleteAll: () async {
///     // 전체 삭제
///   },
/// );
/// ```

enum DeleteOption {
  thisOnly, // この回のみ
  afterThis, // この予定以降
  all, // すべての回
}

Future<void> showDeleteRepeatConfirmationModal(
  BuildContext context, {
  required Future<void> Function() onDeleteThis,
  required Future<void> Function() onDeleteFuture,
  required Future<void> Function() onDeleteAll,
}) async {
  // ✅ 모달을 먼저 표시하고 결과를 기다림
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Delete Repeat Confirmation',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return DeleteRepeatConfirmationModal(
        onDeleteThis: onDeleteThis,
        onDeleteFuture: onDeleteFuture,
        onDeleteAll: onDeleteAll,
      );
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

  // ✅ 삭제가 완료되었으면 토스트 표시
  if (result == true && context.mounted) {
    showActionToast(context, type: ToastType.delete);
  }
}

class DeleteRepeatConfirmationModal extends StatefulWidget {
  final Future<void> Function() onDeleteThis;
  final Future<void> Function() onDeleteFuture;
  final Future<void> Function() onDeleteAll;

  const DeleteRepeatConfirmationModal({
    super.key,
    required this.onDeleteThis,
    required this.onDeleteFuture,
    required this.onDeleteAll,
  });

  @override
  State<DeleteRepeatConfirmationModal> createState() =>
      _DeleteRepeatConfirmationModalState();
}

class _DeleteRepeatConfirmationModalState
    extends State<DeleteRepeatConfirmationModal> {
  DeleteOption _selectedOption = DeleteOption.thisOnly; // 기본 선택: この回のみ

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16), // 하단 여백 16px
        child: Container(
          width: 370, // Figma: 370px
          height: 438, // Figma: 438px
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
                            // "内容を 削除ますか？" - 22px extrabold, 행간 130%, 자간 -0.5%
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
                const SizedBox(height: 28), // 텍스트와 옵션 사이 간격
                // Frame 841: 삭제 옵션 선택 (3개)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                  ), // ✅ 체크박스는 모달 좌측 끝에서부터 20px
                  child: Column(
                    children: [
                      // この回のみ
                      _buildOption(
                        option: DeleteOption.thisOnly,
                        label: 'この回のみ',
                      ),
                      const SizedBox(height: 2),
                      // この予定以降
                      _buildOption(
                        option: DeleteOption.afterThis,
                        label: 'この予定以降',
                      ),
                      const SizedBox(height: 2),
                      // すべての回
                      _buildOption(option: DeleteOption.all, label: 'すべての回'),
                    ],
                  ),
                ),
                const SizedBox(height: 48), // 마지막 옵션에서 삭제 버튼까지 48px
                // CTA 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ), // ✅ 좌우 18px (모달 내부 여백)
                  child: GestureDetector(
                    onTap: () async {
                      // 모달 먼저 닫기 (true 반환)
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }

                      // 선택된 옵션에 따라 삭제 실행
                      switch (_selectedOption) {
                        case DeleteOption.thisOnly:
                          await widget.onDeleteThis();
                          break;
                        case DeleteOption.afterThis:
                          await widget.onDeleteFuture();
                          break;
                        case DeleteOption.all:
                          await widget.onDeleteAll();
                          break;
                      }
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5).withOpacity(0.9),
                        border: Border.all(
                          color: const Color(0xFFFF0000).withOpacity(0.02),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '削除する',
                        style: TextStyle(
                          fontFamily: 'LINE Seed JP App_TTF',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.4, // 140%
                          letterSpacing: -0.005 * 15,
                          color: Color(0xFFFF0000),
                          decoration: TextDecoration.none,
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

  Widget _buildOption({required DeleteOption option, required String label}) {
    final isSelected = _selectedOption == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = option;
        });
      },
      child: Container(
        width: 346,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // 라디오 버튼
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF262626), width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF262626),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            // 라벨
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.4, // 140%
                letterSpacing: -0.005 * 15,
                color: Color(0xFF262626),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
