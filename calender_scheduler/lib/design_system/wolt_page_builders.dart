/// 🎨 Wolt Modal Sheet 페이지 빌더 함수들
///
/// 재사용 가능한 Wolt 모달 페이지 생성 함수들
/// - buildColorPickerPage: 색상 선택 페이지
/// - buildRepeatDailyPage: 반복 설정 (매일)
/// - buildRepeatMonthlyPage: 반복 설정 (매월)
/// - buildRepeatIntervalPage: 반복 설정 (간격)
/// - buildReminderOptionPage: 리마인더 설정 페이지
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import '../design_system/wolt_design_tokens.dart';
import '../design_system/wolt_typography.dart';
import '../design_system/wolt_common_widgets.dart';
import '../providers/bottom_sheet_controller.dart';

// ==================== 색상 선택 페이지 ====================

/// 🎨 색상 선택 Wolt 페이지 (Figma: OptionSetting - 色)
///
/// **피그마 디자인:**
/// - 크기: 364×414px
/// - TopNavi: "色" (19px bold)
/// - 중앙 미리보기: 100×100px 원형 + "デザイン" 텍스트
/// - 하단 5색: 32×32px 원형 버튼
/// - CTA: "完了" 버튼 (333×56px)
///
/// **사용법:**
/// ```dart
/// WoltModalSheet.show(
///   context: context,
///   pageListBuilder: (context) => [
///     buildColorPickerPage(context),
///   ],
/// );
/// ```
SliverWoltModalSheetPage buildColorPickerPage(BuildContext context) {
  final controller = Provider.of<BottomSheetController>(context, listen: false);

  // Figma: 6개 색상 (gray 기본 포함)
  final colorOptions = [
    {
      'value': 'gray',
      'color': const Color(0xFF989898),
      'label': 'グレー',
    }, // ✅ 기본 색상 (categoryGray)
    {'value': 'red', 'color': const Color(0xFFD22D2D), 'label': '赤'},
    {'value': 'orange', 'color': const Color(0xFFF57C00), 'label': 'オレンジ'},
    {'value': 'blue', 'color': const Color(0xFF1976D2), 'label': '青'},
    {'value': 'yellow', 'color': const Color(0xFFF7BD11), 'label': '黄'},
    {'value': 'green', 'color': const Color(0xFF54C8A1), 'label': '緑'},
  ];

  return SliverWoltModalSheetPage(
    // ==================== 헤더 (TopNavi) ====================
    // Figma: padding 9px 28px, gap 205px (space-between)
    topBarTitle: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // "色" 타이틀
          Text(
            '色',
            style: const TextStyle(
              fontFamily: 'LINE Seed JP',
              fontSize: 19, // Figma: font-size 19px
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005,
              color: Color(0xFF111111),
            ),
          ),

          // 닫기 버튼 (36×36px)
          WoltCloseButton(),
        ],
      ),
    ),

    // ==================== 메인 컨텐츠 ====================
    mainContentSliversBuilder: (context) => [
      SliverPadding(
        padding: const EdgeInsets.only(
          top: 32, // Figma: padding 32px 0px 16px
          bottom: 16,
        ),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              // ==================== Frame 783: 중앙 색상 미리보기 + 5색 버튼 ====================
              // Figma: gap 36px between preview and buttons
              Column(
                children: [
                  // 중앙 큰 색상 미리보기 (100×100px)
                  Consumer<BottomSheetController>(
                    builder: (context, ctrl, _) {
                      // 현재 선택된 색상 찾기
                      final selectedOption = colorOptions.firstWhere(
                        (opt) => opt['value'] == ctrl.selectedColor,
                        orElse: () => colorOptions[0],
                      );
                      final selectedColor = selectedOption['color'] as Color;
                      final selectedLabel = selectedOption['label'] as String;

                      return Container(
                        width: 100, // Figma: width 100px
                        height: 100, // Figma: height 100px
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            selectedLabel,
                            style: const TextStyle(
                              fontFamily: 'LINE Seed JP',
                              fontSize: 19, // Figma: font-size 19px
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              letterSpacing: -0.005,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 36), // Figma: gap 36px
                  // ==================== 하단 5개 색상 버튼 ====================
                  // ✅ 6개 색상 버튼 (gray 포함)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                    ), // ✅ 좌우 균등 패딩
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < colorOptions.length; i++) ...[
                          Consumer<BottomSheetController>(
                            builder: (context, ctrl, _) {
                              final option = colorOptions[i];
                              final colorValue = option['value'] as String;
                              final color = option['color'] as Color;
                              final isSelected =
                                  ctrl.selectedColor == colorValue;

                              return GestureDetector(
                                onTap: () {
                                  controller.updateColor(colorValue);
                                },
                                child: Container(
                                  width: 32, // Figma: width 32px
                                  height: 32, // Figma: height 32px
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: const Color(0xFF111111),
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (i < colorOptions.length - 1)
                            const SizedBox(width: 12), // ✅ 간격 줄임 (16px → 12px)
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 52), // Figma: gap 52px to CTA button
              // ==================== CTA 버튼 ("完了") ====================
              // Figma: width 333px, height 56px, padding 10px
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 333, // Figma: width 333px
                    height: 56, // Figma: height 56px
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111), // Figma: bg #111111
                      border: Border.all(
                        color: const Color(0xFF111111).withOpacity(0.01),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        24,
                      ), // Figma: border-radius 24px
                    ),
                    child: Center(
                      child: Text(
                        '完了',
                        style: const TextStyle(
                          fontFamily: 'LINE Seed JP',
                          fontSize: 15, // Figma: font-size 15px
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          letterSpacing: -0.005,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// ==================== 리마인더 설정 페이지 ====================

/// 리마인더 설정 Wolt 페이지
///
/// **Figma 디자인 반영:**
/// - 定時 (정시)
/// - 5分前, 10分前, 15分前, 30分前
/// - 1時間前, 2時間前
/// - 스크롤 가능한 리스트
///
/// **사용법:**
/// ```dart
/// WoltModalSheet.show(
///   context: context,
///   pageListBuilder: (context) => [
///     buildReminderOptionPage(context),
///   ],
/// );
/// ```
SliverWoltModalSheetPage buildReminderOptionPage(BuildContext context) {
  final controller = Provider.of<BottomSheetController>(context, listen: false);

  // 🎨 Figma 디자인 반영: 리마인더 옵션 목록
  final reminderOptions = [
    {'value': 'ontime', 'label': '定時', 'displayJa': '定時'},
    {'value': '5min', 'label': '5分前', 'displayJa': '5分前'},
    {'value': '10min', 'label': '10分前', 'displayJa': '10分前'},
    {'value': '15min', 'label': '15分前', 'displayJa': '15分前'},
    {'value': '30min', 'label': '30分前', 'displayJa': '30分前'},
    {'value': '1hour', 'label': '1時間前', 'displayJa': '1時間前'},
    {'value': '2hour', 'label': '2時間前', 'displayJa': '2時間前'},
  ];

  return SliverWoltModalSheetPage(
    // ==================== 헤더 ====================
    topBarTitle: Text('リマインダー', style: WoltTypography.subTitle),

    // ==================== 메인 컨텐츠 ====================
    mainContentSliversBuilder: (context) => [
      // 🎨 리마인더 옵션 리스트 (스크롤 가능)
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final option = reminderOptions[index];
          final value = option['value'] as String;
          final label = option['label'] as String;

          return Consumer<BottomSheetController>(
            builder: (context, ctrl, _) {
              final isSelected = ctrl.reminder == value;

              return InkWell(
                onTap: () {
                  // JSON 형식으로 저장
                  final reminderJson = '{"value":"$value","display":"$label"}';
                  controller.updateReminder(reminderJson);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28, // Figma: px-[28px]
                    vertical: 18, // Figma: py-[18px]
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: WoltDesignTokens.border08,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: WoltTypography.optionText.copyWith(
                          color: isSelected
                              ? WoltDesignTokens.primaryBlack
                              : WoltDesignTokens.primaryBlack,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: WoltDesignTokens.primaryBlack,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }, childCount: reminderOptions.length),
      ),
    ],
  );
}

// ==================== 반복 설정 페이지 (3개 토글 - Figma 정확한 높이) ====================

/// 🎨 반복 설정 Wolt 페이지 - 毎日 (매일) - Figma: 366px
///
/// **Figma 디자인 스펙:**
/// - 크기: 364×366px
/// - TopNavi: "繰り返し" (19px bold) + 닫기 버튼 (36×36px)
/// - Frame 788: gap 36px
///   - 3개 토글: 毎日 / 毎月 / 間隔 (256×48px, gap 4px)
///   - WeekPicker: 7개 요일 버튼 (40×40px, gap 4px)
/// - CTA: "完了" 버튼 (333×56px)
///
/// **사용법:**
/// ```dart
/// final pageIndexNotifier = ValueNotifier<int>(0);
/// WoltModalSheet.show(
///   context: context,
///   pageIndexNotifier: pageIndexNotifier,
///   pageListBuilder: (context) => [
///     buildRepeatDailyPage(context, pageIndexNotifier),
///     buildRepeatMonthlyPage(context, pageIndexNotifier),
///     buildRepeatIntervalPage(context, pageIndexNotifier),
///   ],
/// );
/// ```
SliverWoltModalSheetPage buildRepeatDailyPage(
  BuildContext context,
  ValueNotifier<int> pageIndexNotifier,
) {
  final controller = Provider.of<BottomSheetController>(context, listen: false);

  return SliverWoltModalSheetPage(
    // ==================== 헤더 (TopNavi) ====================
    // Figma: padding 9px 28px, gap 205px (space-between)
    topBarTitle: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // "繰り返し" 타이틀
          Text(
            '繰り返し',
            style: const TextStyle(
              fontFamily: 'LINE Seed JP',
              fontSize: 19, // Figma: font-size 19px
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005,
              color: Color(0xFF111111),
            ),
          ),

          // 닫기 버튼 (36×36px)
          WoltCloseButton(),
        ],
      ),
    ),

    // ==================== 메인 컨텐츠 ====================
    mainContentSliversBuilder: (context) => [
      SliverPadding(
        padding: const EdgeInsets.only(
          top: 32, // Figma: padding 32px 0px 16px
          bottom: 16,
        ),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              // ==================== Frame 788: 토글 + 요일 선택기 ====================
              // Figma: gap 36px between toggle and weekpicker
              Column(
                children: [
                  // ==================== 3개 토글 셀렉터 (毎日 / 毎月 / 間隔) ====================
                  // Figma: width 256px, height 48px, background #F0F0F2, border-radius 24px
                  Container(
                    width: 256,
                    height: 48,
                    padding: const EdgeInsets.all(4), // Figma: padding 4px
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F2), // Figma: bg #F0F0F2
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        // 毎日 버튼 (선택됨)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => pageIndexNotifier.value = 0,
                            child: Container(
                              height: 40, // Figma: height 40px
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFFFFF,
                                ), // Figma: selected bg #FFFFFF
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: const Color(
                                    0xFF111111,
                                  ).withOpacity(0.08),
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14BABABA),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '毎日',
                                  style: const TextStyle(
                                    fontFamily: 'LINE Seed JP',
                                    fontSize: 13, // Figma: font-size 13px
                                    fontWeight: FontWeight.w700,
                                    height: 1.4,
                                    letterSpacing: -0.005,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4), // Figma: gap 4px
                        // 毎月 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () => pageIndexNotifier.value = 1,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  '毎月',
                                  style: const TextStyle(
                                    fontFamily: 'LINE Seed JP',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    height: 1.4,
                                    letterSpacing: -0.005,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4), // Figma: gap 4px
                        // 間隔 버튼
                        Expanded(
                          child: GestureDetector(
                            onTap: () => pageIndexNotifier.value = 2,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  '間隔',
                                  style: const TextStyle(
                                    fontFamily: 'LINE Seed JP',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    height: 1.4,
                                    letterSpacing: -0.005,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36), // Figma: gap 36px
                  // ==================== WeekPicker (요일 선택기) ====================
                  // Figma: padding 0px 8px, gap 4px, 7개 버튼 (40×40px)
                  Consumer<BottomSheetController>(
                    builder: (context, ctrl, _) {
                      // 선택된 요일 파싱
                      final selectedWeekdays = <int>{};

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildWeekdayButton(
                              '月',
                              1,
                              selectedWeekdays,
                              controller,
                            ),
                            const SizedBox(width: 4),
                            _buildWeekdayButton(
                              '火',
                              2,
                              selectedWeekdays,
                              controller,
                            ),
                            const SizedBox(width: 4),
                            _buildWeekdayButton(
                              '水',
                              3,
                              selectedWeekdays,
                              controller,
                            ),
                            const SizedBox(width: 4),
                            _buildWeekdayButton(
                              '木',
                              4,
                              selectedWeekdays,
                              controller,
                            ),
                            const SizedBox(width: 4),
                            _buildWeekdayButton(
                              '金',
                              5,
                              selectedWeekdays,
                              controller,
                            ),
                            const SizedBox(width: 4),
                            _buildWeekdayButton(
                              '土',
                              6,
                              selectedWeekdays,
                              controller,
                            ),
                            const SizedBox(width: 4),
                            _buildWeekdayButton(
                              '日',
                              7,
                              selectedWeekdays,
                              controller,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 48), // Figma: gap 48px to CTA button
              // ==================== CTA 버튼 ("完了") ====================
              // Figma: width 333px, height 56px
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 333,
                    height: 56,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      border: Border.all(
                        color: const Color(0xFF111111).withOpacity(0.01),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        '完了',
                        style: const TextStyle(
                          fontFamily: 'LINE Seed JP',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          letterSpacing: -0.005,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// ==================== 요일 버튼 헬퍼 함수 ====================
Widget _buildWeekdayButton(
  String label,
  int weekdayNumber,
  Set<int> selectedWeekdays,
  BottomSheetController controller,
) {
  final isSelected = selectedWeekdays.contains(weekdayNumber);

  return GestureDetector(
    onTap: () {
      if (isSelected) {
        selectedWeekdays.remove(weekdayNumber);
      } else {
        selectedWeekdays.add(weekdayNumber);
      }
      controller.updateRepeatRule(
        '{"mode":"weekly","weekdays":${selectedWeekdays.toList()}}',
      );
    },
    child: Container(
      width: 40, // Figma: width 40px
      height: 40, // Figma: height 40px
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF262626) // Figma: selected bg #262626
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16), // Figma: border-radius 16px
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'LINE Seed JP',
            fontSize: 12, // Figma: font-size 12px
            fontWeight: FontWeight.w700,
            height: 1.4,
            letterSpacing: -0.005,
            color: isSelected
                ? const Color(0xFFFFFFFF) // Figma: selected color #FFFFFF
                : const Color(0xFF111111),
          ),
        ),
      ),
    ),
  );
}

// ==================== 날짜 그리드 헬퍼 함수 ====================

/// 날짜 그리드 행 빌더 (Figma: DatePicker 46×46px)
Widget _buildMonthDayRow(
  List<int> days,
  Set<int> selectedDays,
  BottomSheetController controller,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (int i = 0; i < 7; i++)
        i < days.length
            ? _buildMonthDayButton(days[i], selectedDays, controller)
            : const SizedBox(width: 46, height: 46), // 빈 공간
    ],
  );
}

/// 날짜 버튼 빌더 (Figma: 46×46px, border-radius 18px)
Widget _buildMonthDayButton(
  int day,
  Set<int> selectedDays,
  BottomSheetController controller,
) {
  final isSelected = selectedDays.contains(day);

  return GestureDetector(
    onTap: () {
      if (isSelected) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
      controller.updateRepeatRule(
        '{"mode":"monthly","days":${selectedDays.toList()}}',
      );
    },
    child: Container(
      width: 46, // Figma: width 46px
      height: 46, // Figma: height 46px
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF262626) // Figma: selected (검정 배경)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18), // Figma: border-radius 18px
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            fontFamily: 'LINE Seed JP',
            fontSize: 14, // Figma: font-size 14px
            fontWeight: FontWeight.w700,
            height: 1.4,
            letterSpacing: -0.005,
            color: isSelected
                ? const Color(0xFFFFFFFF) // Figma: 선택시 흰색
                : const Color(0xFF111111), // Figma: 기본 검정
          ),
        ),
      ),
    ),
  );
}

/// 🎨 반복 설정 Wolt 페이지 - 毎月 (매월) - Figma: 576px
///
/// **Figma 디자인 스펙:**
/// - 크기: 364×576px (366px + 210px 날짜 그리드)
/// - 3개 토글 + 날짜 선택 그리드 (1-31)
///
SliverWoltModalSheetPage buildRepeatMonthlyPage(
  BuildContext context,
  ValueNotifier<int> pageIndexNotifier,
) {
  final controller = Provider.of<BottomSheetController>(context, listen: false);

  return SliverWoltModalSheetPage(
    // ==================== 헤더 ====================
    topBarTitle: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '繰り返し',
            style: const TextStyle(
              fontFamily: 'LINE Seed JP',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005,
              color: Color(0xFF111111),
            ),
          ),
          WoltCloseButton(),
        ],
      ),
    ),

    // ==================== 메인 컨텐츠 ====================
    mainContentSliversBuilder: (context) => [
      SliverPadding(
        padding: const EdgeInsets.only(top: 32, bottom: 16),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              // ==================== 3개 토글 (毎月 선택됨) ====================
              Container(
                width: 256,
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    // 毎日 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pageIndexNotifier.value = 0,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              '毎日',
                              style: const TextStyle(
                                fontFamily: 'LINE Seed JP',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                letterSpacing: -0.005,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // 毎月 버튼 (선택됨)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pageIndexNotifier.value = 1,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFF111111).withOpacity(0.08),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14BABABA),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '毎月',
                              style: const TextStyle(
                                fontFamily: 'LINE Seed JP',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                letterSpacing: -0.005,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // 間隔 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pageIndexNotifier.value = 2,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              '間隔',
                              style: const TextStyle(
                                fontFamily: 'LINE Seed JP',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                letterSpacing: -0.005,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48), // Figma: gap 48px
              // ==================== 날짜 선택 그리드 (1-31) ====================
              // Figma: DatePicker_CalenderView_Basic
              // - width: 346px, height: 250px
              // - padding: 0px 12px
              // - 각 버튼: 46×46px, border-radius 18px
              // - 7개 × 5줄 = 35개 (1-31 + 빈칸)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Consumer<BottomSheetController>(
                  builder: (context, ctrl, _) {
                    // 선택된 날짜 파싱
                    final selectedDays = <int>{};

                    return SizedBox(
                      width: 346,
                      height: 250,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1-7
                          _buildMonthDayRow(
                            [1, 2, 3, 4, 5, 6, 7],
                            selectedDays,
                            controller,
                          ),
                          // 8-14
                          _buildMonthDayRow(
                            [8, 9, 10, 11, 12, 13, 14],
                            selectedDays,
                            controller,
                          ),
                          // 15-21
                          _buildMonthDayRow(
                            [15, 16, 17, 18, 19, 20, 21],
                            selectedDays,
                            controller,
                          ),
                          // 22-28
                          _buildMonthDayRow(
                            [22, 23, 24, 25, 26, 27, 28],
                            selectedDays,
                            controller,
                          ),
                          // 29-31
                          _buildMonthDayRow(
                            [29, 30, 31],
                            selectedDays,
                            controller,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 48),

              // ==================== CTA 버튼 ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 333,
                    height: 56,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      border: Border.all(
                        color: const Color(0xFF111111).withOpacity(0.01),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        '完了',
                        style: const TextStyle(
                          fontFamily: 'LINE Seed JP',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          letterSpacing: -0.005,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// 🎨 반복 설정 Wolt 페이지 - 間隔 (간격) - Figma: 662px
///
/// **Figma 디자인 스펙:**
/// - 크기: 364×662px (가장 큰 높이)
/// - 3개 토글 + 간격 입력 + 요일 선택
///
SliverWoltModalSheetPage buildRepeatIntervalPage(
  BuildContext context,
  ValueNotifier<int> pageIndexNotifier,
) {
  final controller = Provider.of<BottomSheetController>(context, listen: false);

  return SliverWoltModalSheetPage(
    // ==================== 헤더 ====================
    topBarTitle: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '繰り返し',
            style: const TextStyle(
              fontFamily: 'LINE Seed JP',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005,
              color: Color(0xFF111111),
            ),
          ),
          WoltCloseButton(),
        ],
      ),
    ),

    // ==================== 메인 컨텐츠 ====================
    mainContentSliversBuilder: (context) => [
      SliverPadding(
        padding: const EdgeInsets.only(top: 32, bottom: 16),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              // ==================== 3개 토글 (間隔 선택됨) ====================
              Container(
                width: 256,
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    // 毎日 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pageIndexNotifier.value = 0,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              '毎日',
                              style: const TextStyle(
                                fontFamily: 'LINE Seed JP',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                letterSpacing: -0.005,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // 毎月 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pageIndexNotifier.value = 1,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              '毎月',
                              style: const TextStyle(
                                fontFamily: 'LINE Seed JP',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                letterSpacing: -0.005,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // 間隔 버튼 (선택됨)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pageIndexNotifier.value = 2,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFF111111).withOpacity(0.08),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14BABABA),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '間隔',
                              style: const TextStyle(
                                fontFamily: 'LINE Seed JP',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                letterSpacing: -0.005,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ==================== 간격 옵션 리스트 (스크롤) ====================
              // Figma: DetailOption/RepeatScroll
              // - width: 345px, height: 336px
              // - padding: 0px 16px
              // - 각 아이템: padding 12px 16px, height 48px
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: 345,
                  height: 336, // Figma: height 336px
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF111111).withOpacity(0.08),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Consumer<BottomSheetController>(
                    builder: (context, ctrl, _) {
                      // 간격 옵션 목록 (Figma 스펙)
                      final intervalOptions = [
                        {'value': '2day', 'label': '2日毎'},
                        {'value': '3day', 'label': '3日毎'},
                        {'value': '4day', 'label': '4日毎'},
                        {'value': '5day', 'label': '5日毎'},
                        {'value': '6day', 'label': '6日毎'},
                        {'value': '7day', 'label': '7日毎'},
                        {'value': '8day', 'label': '8日毎'},
                      ];

                      return ListView.builder(
                        itemCount: intervalOptions.length,
                        itemBuilder: (context, index) {
                          final option = intervalOptions[index];
                          final value = option['value'] as String;
                          final label = option['label'] as String;
                          final isSelected = ctrl.repeatRule.contains(value);

                          return InkWell(
                            onTap: () {
                              controller.updateRepeatRule(
                                '{"mode":"interval","value":"$value","display":"$label"}',
                              );
                            },
                            child: Container(
                              height: 48, // Figma: height 48px
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, // Figma: padding 12px 16px
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: index < intervalOptions.length - 1
                                    ? const Border(
                                        bottom: BorderSide(
                                          color: Color(0x14111111),
                                          width: 1,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontFamily: 'LINE Seed JP',
                                      fontSize: 13, // Figma: font-size 13px
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      height: 1.4,
                                      letterSpacing: -0.005,
                                      color: isSelected
                                          ? const Color(0xFF111111)
                                          : const Color(0xFF555555),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check,
                                      color: Color(0xFF111111),
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ==================== CTA 버튼 ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 333,
                    height: 56,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      border: Border.all(
                        color: const Color(0xFF111111).withOpacity(0.01),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        '完了',
                        style: const TextStyle(
                          fontFamily: 'LINE Seed JP',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          letterSpacing: -0.005,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// ==================== 기존 반복 옵션 페이지 (간단한 버전) ====================

/// 반복 설정 Wolt 페이지 (레거시 - 간단한 리스트 버전)
///
/// **사용법:**
/// ```dart
/// WoltModalSheet.show(
///   context: context,
///   pageListBuilder: (context) => [
///     buildRepeatOptionPage(context),
///   ],
/// );
/// ```
SliverWoltModalSheetPage buildRepeatOptionPage(BuildContext context) {
  final controller = Provider.of<BottomSheetController>(context, listen: false);

  // 반복 옵션 목록
  final repeatOptions = [
    {'value': '', 'label': '없음'},
    {'value': 'daily', 'label': '매일'},
    {'value': 'weekly', 'label': '매주'},
    {'value': 'monthly', 'label': '매월'},
    {'value': 'custom', 'label': '사용자 지정'},
  ];

  return SliverWoltModalSheetPage(
    // ==================== 헤더 ====================
    topBarTitle: Text('반복 설정', style: WoltTypography.subTitle),

    // ==================== 메인 컨텐츠 ====================
    mainContentSliversBuilder: (context) => [
      // 반복 옵션 리스트
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final option = repeatOptions[index];
          final value = option['value'] as String;
          final label = option['label'] as String;

          return Consumer<BottomSheetController>(
            builder: (context, ctrl, _) {
              final isSelected = ctrl.repeatRule.contains(value);

              return InkWell(
                onTap: () {
                  if (value.isEmpty) {
                    controller.clearRepeatRule();
                  } else if (value == 'custom') {
                    // TODO: 사용자 지정 반복 설정 모달 열기
                    Navigator.pop(context);
                  } else {
                    // JSON 형식으로 저장
                    final repeatJson = '{"mode":"$value","display":"$label"}';
                    controller.updateRepeatRule(repeatJson);
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: WoltDesignTokens.border08,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: WoltTypography.optionText.copyWith(
                          color: isSelected
                              ? WoltDesignTokens.primaryBlue
                              : WoltDesignTokens.primaryBlack,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: WoltDesignTokens.primaryBlue,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }, childCount: repeatOptions.length),
      ),
    ],
  );
}
