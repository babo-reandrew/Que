import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../toast/action_toast.dart';

/// ✏️ 반복 일정/할일/습관 수정 확인 모달 - Figma Property 1=Edit
///
/// Figma 스펙:
/// - 크기: 370x438px
/// - 배경: #FCFCFC
/// - Border: 1px solid rgba(17, 17, 17, 0.1)
/// - Shadow: 0px 2px 20px rgba(165, 165, 165, 0.2)
/// - Border Radius: 36px
///
/// 수정 옵션:
/// 1. この回のみ (이 일정만): 현재 일정만 수정 → RecurringException 생성
/// 2. この予定以降 (이 일정 이후): 이후 일정만 수정 → RRULE 분할
/// 3. すべての回 (모든 일정): 전체 수정 → Base Event + RRULE 업데이트
///
/// 사용법:
/// ```dart
/// showEditRepeatConfirmationModal(
///   context,
///   onEditThis: () async {
///     // 이 일정만 수정
///   },
///   onEditFuture: () async {
///     // 이후 일정 수정
///   },
///   onEditAll: () async {
///     // 전체 수정
///   },
/// );
/// ```

enum EditOption {
  thisOnly, // この回のみ
  afterThis, // この予定以降
  all, // すべての回
}

Future<void> showEditRepeatConfirmationModal(
  BuildContext context, {
  required Future<void> Function() onEditThis,
  required Future<void> Function() onEditFuture,
  required Future<void> Function() onEditAll,
}) async {
  // ✅ 모달을 먼저 표시하고 결과를 기다림
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Edit Repeat Confirmation',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return EditRepeatConfirmationModal(
        onEditThis: onEditThis,
        onEditFuture: onEditFuture,
        onEditAll: onEditAll,
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

  // ✅ 수정이 완료되었으면 토스트 표시
  if (result == true && context.mounted) {
    showActionToast(context, type: ToastType.change);
  }
}

class EditRepeatConfirmationModal extends StatefulWidget {
  final Future<void> Function() onEditThis;
  final Future<void> Function() onEditFuture;
  final Future<void> Function() onEditAll;

  const EditRepeatConfirmationModal({
    super.key,
    required this.onEditThis,
    required this.onEditFuture,
    required this.onEditAll,
  });

  @override
  State<EditRepeatConfirmationModal> createState() =>
      _EditRepeatConfirmationModalState();
}

class _EditRepeatConfirmationModalState
    extends State<EditRepeatConfirmationModal> {
  EditOption _selectedOption = EditOption.all; // 기본 선택: すべての回 (가장 일반적)

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
                            // "内容を 変更ますか？" - 22px extrabold, 행간 130%, 자간 -0.5%
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
                                    text: '変更',
                                    style: TextStyle(
                                      color: Color(0xFF0066FF), // #0066FF 파란색
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
                            // "変更範囲を選択してください。" - 13px regular, 행간 140%, 자간 -0.5%
                            const Text(
                              '変更範囲を選択してください。',
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
                // Frame 841: 수정 옵션 선택 (3개)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                  ), // ✅ 체크박스는 모달 좌측 끝에서부터 20px
                  child: Column(
                    children: [
                      // この回のみ
                      _buildOption(option: EditOption.thisOnly, label: 'この回のみ'),
                      const SizedBox(height: 2),
                      // この予定以降
                      _buildOption(
                        option: EditOption.afterThis,
                        label: 'この予定以降',
                      ),
                      const SizedBox(height: 2),
                      // すべての回
                      _buildOption(option: EditOption.all, label: 'すべての回'),
                    ],
                  ),
                ),
                const SizedBox(height: 48), // 마지막 옵션에서 변경 버튼까지 48px
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

                      // 선택된 옵션에 따라 수정 실행
                      switch (_selectedOption) {
                        case EditOption.thisOnly:
                          await widget.onEditThis();
                          break;
                        case EditOption.afterThis:
                          await widget.onEditFuture();
                          break;
                        case EditOption.all:
                          await widget.onEditAll();
                          break;
                      }
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F0FF).withOpacity(0.9),
                        border: Border.all(
                          color: const Color(0xFF0066FF).withOpacity(0.02),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '変更する',
                        style: TextStyle(
                          fontFamily: 'LINE Seed JP App_TTF',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.4, // 140%
                          letterSpacing: -0.005 * 15,
                          color: Color(0xFF0066FF),
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

  Widget _buildOption({required EditOption option, required String label}) {
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
