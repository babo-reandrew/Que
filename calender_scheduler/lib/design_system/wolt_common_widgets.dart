/// 🎨 Wolt 공통 위젯 라이브러리
///
/// 모든 바텀시트에서 재사용 가능한 컴포넌트들
library;

import 'package:flutter/material.dart';
import '../design_system/wolt_design_tokens.dart';
import '../design_system/wolt_typography.dart';

// ==================== TopNavi 헤더 ====================

/// Wolt 바텀시트 헤더 (TopNavi)
///
/// Figma: TopNavi 컴포넌트
/// - height: 60px
/// - padding: 9px 28px
/// - gap: 205px (space-between으로 구현)
class WoltModalHeader extends StatelessWidget {
  const WoltModalHeader({
    super.key,
    required this.title,
    this.showCompleteButton = true,
    this.onComplete,
  });

  final String title;
  final bool showCompleteButton;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: WoltDesignTokens.topNaviHeight,
      padding: WoltDesignTokens.topNaviPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 타이틀
          Text(title, style: WoltTypography.subTitle),

          // 완료 버튼
          if (showCompleteButton) _CompleteButton(onPressed: onComplete),
        ],
      ),
    );
  }
}

/// 완료 버튼
class _CompleteButton extends StatelessWidget {
  const _CompleteButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        constraints: BoxConstraints(
          minWidth: WoltDesignTokens.sizeCompleteButton.width,
          minHeight: WoltDesignTokens.sizeCompleteButton.height,
        ),
        decoration: WoltDesignTokens.decorationCompleteButton,
        child: Center(child: Text('完了', style: WoltTypography.completeButton)),
      ),
    );
  }
}

// ==================== DetailOption 버튼 ====================

/// Wolt DetailOption 버튼 (64×64px)
///
/// Figma: DetailOption 컴포넌트
/// - 색상, 반복, 리마인더 선택에 사용
class WoltDetailOption extends StatelessWidget {
  const WoltDetailOption({super.key, this.icon, this.text, this.onTap});

  final Widget? icon;
  final String? text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: WoltDesignTokens.sizeDetailOption.width,
        height: WoltDesignTokens.sizeDetailOption.height,
        padding: const EdgeInsets.all(20),
        decoration: WoltDesignTokens.decorationDetailOption,
        child: Center(
          child: text != null
              ? Text(
                  text!,
                  style: WoltTypography.optionText,
                  textAlign: TextAlign.center,
                )
              : icon,
        ),
      ),
    );
  }
}

/// DetailOption 박스 (3개 버튼 가로 배치)
class WoltDetailOptionBox extends StatelessWidget {
  const WoltDetailOptionBox({super.key, required this.options});

  final List<Widget> options;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < options.length; i++) ...[
            options[i],
            if (i < options.length - 1)
              const SizedBox(width: WoltDesignTokens.gap8),
          ],
        ],
      ),
    );
  }
}

// ==================== CTA 버튼 ====================

/// Wolt CTA 버튼 (이동/삭제)
///
/// Figma: CTA 컴포넌트
/// - Primary (Blue): 이동 버튼
/// - Danger (Red): 삭제 버튼
class WoltCTAButton extends StatelessWidget {
  const WoltCTAButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDanger = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: isDanger
            ? WoltDesignTokens.decorationCTADanger
            : WoltDesignTokens.decorationCTAPrimary,
        child: Center(child: Text(text, style: WoltTypography.ctaButton)),
      ),
    );
  }
}

// ==================== 삭제 버튼 (작은) ====================

/// Wolt 삭제 버튼 (작은, 100×52px)
///
/// Figma: Frame 774 (削除 버튼)
class WoltDeleteButton extends StatelessWidget {
  const WoltDeleteButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: WoltDesignTokens.sizeDeleteButton.width,
        height: WoltDesignTokens.sizeDeleteButton.height,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: WoltDesignTokens.decorationDeleteButton,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 삭제 아이콘
            Icon(
              Icons.delete_outline,
              size: WoltDesignTokens.iconSizeMedium,
              color: WoltDesignTokens.subRed,
            ),
            const SizedBox(width: WoltDesignTokens.gap6),
            // 삭제 텍스트
            Text('削除', style: WoltTypography.deleteButton),
          ],
        ),
      ),
    );
  }
}

// ==================== 닫기 버튼 ====================

/// Wolt 닫기 버튼 (원형, 36×36px)
///
/// Figma: Modal Control Buttons (닫기)
class WoltCloseButton extends StatelessWidget {
  const WoltCloseButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      child: Container(
        width: WoltDesignTokens.sizeCloseButton.width,
        height: WoltDesignTokens.sizeCloseButton.height,
        padding: const EdgeInsets.all(8),
        decoration: WoltDesignTokens.decorationCloseButton,
        child: Icon(
          Icons.close,
          size: WoltDesignTokens.iconSizeMedium,
          color: WoltDesignTokens.primaryBlack,
        ),
      ),
    );
  }
}

// ==================== 종일 토글 ====================

/// 종일 토글 (DetailView_AllDay)
///
/// Figma: DetailView_AllDay 컴포넌트
class WoltAllDayToggle extends StatelessWidget {
  const WoltAllDayToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 종일 라벨
          Row(
            children: [
              Icon(
                Icons.check_box_outline_blank_rounded,
                size: WoltDesignTokens.iconSizeSmall,
                color: WoltDesignTokens.primaryBlack,
              ),
              const SizedBox(width: WoltDesignTokens.gap8),
              Text('終日', style: WoltTypography.optionText),
            ],
          ),

          // 토글 스위치
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: WoltDesignTokens.primaryBlue,
              inactiveThumbColor: WoltDesignTokens.gray100,
              inactiveTrackColor: WoltDesignTokens.gray300,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 마감일 라벨 ====================

/// 마감일 라벨 (DetailView/DeadlineLabel)
///
/// Figma: DetailView/DeadlineLabel 컴포넌트
class WoltDeadlineLabel extends StatelessWidget {
  const WoltDeadlineLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.flag_outlined,
            size: WoltDesignTokens.iconSizeSmall,
            color: WoltDesignTokens.primaryBlack,
          ),
          const SizedBox(width: WoltDesignTokens.gap8),
          Text('締め切り', style: WoltTypography.optionText),
        ],
      ),
    );
  }
}

// ==================== 타이틀 입력 필드 ====================

/// 타이틀 입력 필드 (DetailView_Title)
///
/// Figma: DetailView_Title 컴포넌트
class WoltTitleInput extends StatelessWidget {
  const WoltTitleInput({
    super.key,
    required this.controller,
    this.hintText = 'スケジュールを入力',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        controller: controller,
        style: WoltTypography.mainTitle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: WoltTypography.placeholder,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 28),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ==================== 날짜/시간 선택 버튼 ====================

/// 날짜/시간 선택 버튼 (32×32px 원형)
///
/// Figma: Modal Control Buttons (날짜/시간)
class WoltDateTimePickerButton extends StatelessWidget {
  const WoltDateTimePickerButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: WoltDesignTokens.sizeDateTimeButton.width,
        height: WoltDesignTokens.sizeDateTimeButton.height,
        padding: const EdgeInsets.all(4),
        decoration: WoltDesignTokens.decorationDateTimeButton,
        child: Icon(
          Icons.edit_calendar_outlined,
          size: WoltDesignTokens.iconSizeLarge,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ==================== 날짜/시간 표시 ====================

/// 날짜/시간 표시 컴포넌트
///
/// Figma: Frame 301 (날짜/시간 표시)
class WoltDateTimeDisplay extends StatelessWidget {
  const WoltDateTimeDisplay({
    super.key,
    required this.label,
    this.date,
    this.time,
    this.onEditTap,
    this.isInactive = false,
  });

  final String label; // "開始" or "終了"
  final String? date; // "25. 7. 30"
  final String? time; // "15:30"
  final VoidCallback? onEditTap;
  final bool isInactive;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = date == null || time == null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: isInactive ? 0.3 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 라벨 (開始/終了)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(label, style: WoltTypography.label),
              ),
              const SizedBox(height: WoltDesignTokens.gap10),

              // 날짜/시간 표시
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜
                  if (!isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Text(date!, style: WoltTypography.dateText),
                    ),
                    const SizedBox(height: WoltDesignTokens.gap2),
                    // 시간
                    Text(time!, style: WoltTypography.timeText),
                  ] else ...[
                    // 플레이스홀더
                    Text('10', style: WoltTypography.largePlaceholder),
                  ],
                ],
              ),
            ],
          ),
        ),

        // 수정 버튼 (중앙 하단)
        if (!isEmpty && onEditTap != null)
          Positioned(
            left: 16,
            bottom: 16,
            child: WoltDateTimePickerButton(onTap: onEditTap),
          ),
      ],
    );
  }
}

// ==================== 날짜/시간 선택 영역 ====================

/// 날짜/시간 선택 영역 (시작 ~ 종료)
///
/// Figma: DetailView 컴포넌트
class WoltDateTimeSelector extends StatelessWidget {
  const WoltDateTimeSelector({
    super.key,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.onStartEditTap,
    this.onEndEditTap,
  });

  final String? startDate;
  final String? startTime;
  final String? endDate;
  final String? endTime;
  final VoidCallback? onStartEditTap;
  final VoidCallback? onEndEditTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 시작 날짜/시간
          WoltDateTimeDisplay(
            label: '開始',
            date: startDate,
            time: startTime,
            onEditTap: onStartEditTap,
          ),

          const SizedBox(width: 32),

          // 구분선
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: 8,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black.withOpacity(0.05),
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(width: 32),

          // 종료 날짜/시간
          WoltDateTimeDisplay(
            label: '終了',
            date: endDate,
            time: endTime,
            onEditTap: onEndEditTap,
            isInactive: endDate == null,
          ),
        ],
      ),
    );
  }
}

// ==================== 토글 셀렉터 ====================

/// 🎨 3개 옵션 토글 셀렉터 (Figma: 繰り返し 모달)
///
/// **피그마 디자인:**
/// - 毎日 / 毎月 / 間隔
/// - 선택된 옵션: 흰색 배경
/// - 비선택 옵션: 투명 배경
class WoltToggleSelector extends StatelessWidget {
  const WoltToggleSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64, // Figma: h-[64px]
      padding: const EdgeInsets.all(8), // Figma: p-[8px]
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7), // Figma: #f7f7f7
        borderRadius: BorderRadius.circular(100), // Figma: rounded-full
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (index) {
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32, // Figma: px-[32px]
                vertical: 12, // Figma: py-[12px]
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors
                          .white // 선택됨: 흰색
                    : Colors.transparent, // 비선택: 투명
                borderRadius: BorderRadius.circular(100),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                options[index],
                style: WoltTypography.optionText.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: WoltDesignTokens.primaryBlack,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ==================== 요일 선택기 (圓形 버튼) ====================

/// 🎨 원형 요일 선택 버튼 (Figma: 繰り返し - 毎日 페이지)
///
/// **피그마 디자인:**
/// - 월화수목금토일 (月火水木金土日)
/// - 선택됨: 검은색 배경 + 흰색 텍스트
/// - 비선택: 투명 배경 + 검은색 텍스트
class WoltWeekdayButton extends StatelessWidget {
  const WoltWeekdayButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, // Figma: w-[40px] (Component 75)
        height: 40, // Figma: h-[40px]
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF262626) // Figma: #262626 (선택됨: 검은색)
              : Colors.transparent, // 비선택: 투명
          borderRadius: BorderRadius.circular(16), // Figma: border-radius 16px
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFF111111).withOpacity(0.1),
                  width: 1,
                ),
        ),
        child: Center(
          child: Text(
            label,
            style:
                const TextStyle(
                  fontFamily: 'LINE Seed JP',
                  fontSize: 12, // Figma: font-size 12px
                  fontWeight: FontWeight.w700,
                  height: 1.4, // line-height 140%
                  letterSpacing: -0.005,
                  color: Colors.white, // 선택됨: white, 비선택: black (조건부 처리됨)
                ).copyWith(
                  color: isSelected ? Colors.white : const Color(0xFF111111),
                ),
          ),
        ),
      ),
    );
  }
}

// ==================== 월간 날짜 그리드 ====================

/// 🎨 월간 날짜 선택 그리드 (Figma: 繰り返し - 毎月 페이지)
///
/// **피그마 디자인:**
/// - 1~31일 숫자 그리드 (7열 × 5행)
/// - 선택된 날짜: 검은색 텍스트
/// - 비선택 날짜: 회색 텍스트
class WoltMonthDayGrid extends StatelessWidget {
  const WoltMonthDayGrid({
    super.key,
    required this.selectedDays,
    required this.onDayTap,
  });

  final Set<int> selectedDays;
  final ValueChanged<int> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ), // Figma: padding 0px 12px
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 0, // Figma: no spacing between rows
          crossAxisSpacing: 0, // Figma: no spacing between columns
          childAspectRatio: 1, // 46x46px square cells
        ),
        itemCount: 35, // Figma: 7x5 grid = 35 cells (1-31 + 4 empty)
        itemBuilder: (context, index) {
          final day = index + 1;
          final isValid = day <= 31; // Only show 1-31
          final isSelected = isValid && selectedDays.contains(day);

          return GestureDetector(
            onTap: isValid ? () => onDayTap(day) : null,
            child: Container(
              width: 46, // Figma: DatePicker 46x46px
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  18,
                ), // Figma: border-radius 18px
              ),
              child: isValid
                  ? Text(
                      '$day',
                      style:
                          const TextStyle(
                            fontFamily: 'LINE Seed JP',
                            fontSize: 14, // Figma: font-size 14px
                            fontWeight:
                                FontWeight.w700, // All text is bold in Figma
                            height: 1.4,
                            letterSpacing: -0.005,
                          ).copyWith(
                            color: isSelected
                                ? const Color(0xFF111111) // Selected: black
                                : const Color(
                                    0xFF111111,
                                  ).withOpacity(0.3), // Unselected: 30% opacity
                          ),
                    )
                  : const SizedBox.shrink(), // Empty cells for grid alignment
            ),
          );
        },
      ),
    );
  }
}
