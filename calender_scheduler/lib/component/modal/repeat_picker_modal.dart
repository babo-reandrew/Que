import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/bottom_sheet_controller.dart';
import '../../utils/temp_input_cache.dart';

/// 반복 선택 바텀시트 모달 표시
///
/// 색상 선택 바텀시트와 동일한 구조
Future<void> showRepeatPickerModal(
  BuildContext context, {
  String? initialRepeatRule,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _RepeatPickerSheet(
      controller: Provider.of<BottomSheetController>(context, listen: false),
    ),
  );
}

class _RepeatPickerSheet extends StatefulWidget {
  final BottomSheetController controller;

  const _RepeatPickerSheet({required this.controller});

  @override
  State<_RepeatPickerSheet> createState() => _RepeatPickerSheetState();
}

class _RepeatPickerSheetState extends State<_RepeatPickerSheet> {
  // ✅ 탭 선택 상태 (0: 毎日, 1: 毎月, 2: 間隔)
  int _selectedTab = 0;

  // ✅ 로컬 상태로 선택된 값 관리
  String? _selectedValue;

  // ✅ 毎日 탭: 요일 선택 (월~일)
  Set<String> _selectedWeekdays = {};

  // ✅ 毎月 탭: 날짜 선택 (1~31일) - 최대 2개까지만
  Set<int> _selectedMonthDays = {};

  // ✅ 間隔 탭: 선택된 간격
  String? _selectedInterval;
  String? _selectedIntervalLabel; // 표시용 라벨 (예: '2日毎')

  @override
  void initState() {
    super.initState();
    // ✅ 초기값: 현재 controller에서 가져오기
    if (widget.controller.repeatRule.isNotEmpty) {
      try {
        final repeatData = widget.controller.repeatRule;
        if (repeatData.contains('"value":"')) {
          final startIndex = repeatData.indexOf('"value":"') + 9;
          final endIndex = repeatData.indexOf('"', startIndex);
          _selectedValue = repeatData.substring(startIndex, endIndex);

          // ✅ value에서 탭과 선택값 복원
          if (_selectedValue!.startsWith('daily:')) {
            _selectedTab = 0;
            final days = _selectedValue!
                .substring(6)
                .split(',')
                .map((d) => d.trim())
                .where((d) => d.isNotEmpty)
                .toList();
            _selectedWeekdays = days.toSet();
            debugPrint('🐛 [RepeatPicker] 초기화: daily days = $days');
            debugPrint(
              '🐛 [RepeatPicker] 초기화: _selectedWeekdays = $_selectedWeekdays',
            );
          } else if (_selectedValue!.startsWith('monthly:')) {
            _selectedTab = 1;
            final days = _selectedValue!.substring(8).split(',');
            _selectedMonthDays = days.map((d) => int.tryParse(d) ?? 0).toSet();
          } else {
            _selectedTab = 2;
            _selectedInterval = _selectedValue;

            // ✅ display 값도 복원
            if (repeatData.contains('"display":"')) {
              final displayStartIndex = repeatData.indexOf('"display":"') + 11;
              final displayEndIndex = repeatData.indexOf(
                '"',
                displayStartIndex,
              );
              _selectedIntervalLabel = repeatData.substring(
                displayStartIndex,
                displayEndIndex,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('반복 초기값 파싱 오류: $e');
      }
    }
  }

  // ✅ 선택된 값에서 표시 텍스트 생성
  String _generateDisplayText() {
    if (_selectedTab == 0) {
      // 毎日 탭: 요일 조합 확인
      if (_selectedWeekdays.isEmpty) return '';

      final weekdays = ['月', '火', '水', '木', '金', '土', '日'];
      final weekdaySet = _selectedWeekdays.toSet();

      // ✅ 주 7일 모두 선택 → "毎日"
      if (weekdaySet.length == 7) {
        return '毎日';
      }
      // ✅ 평일 (월~금)
      if (weekdaySet.containsAll(['月', '火', '水', '木', '金']) &&
          weekdaySet.length == 5) {
        return '平日';
      }
      // ✅ 주말 (토, 일)
      if (weekdaySet.containsAll(['土', '日']) && weekdaySet.length == 2) {
        return '週末';
      }
      // ✅ 그 외: 선택된 요일 그대로 표시 (최대 4글자)
      final sortedDays = weekdays
          .where((day) => weekdaySet.contains(day))
          .toList();
      final displayText = sortedDays.join('');
      return displayText.length > 4 ? displayText.substring(0, 4) : displayText;
    } else if (_selectedTab == 1) {
      // 毎月 탭: 날짜 표시 (4글자 초과 시 자동 개행)
      if (_selectedMonthDays.isEmpty) return '';

      final sortedDays = _selectedMonthDays.toList()..sort();
      String displayText;
      if (sortedDays.length == 1) {
        displayText = '毎月${sortedDays[0]}日';
      } else if (sortedDays.length == 2) {
        displayText = '毎月${sortedDays[0]}, ${sortedDays[1]}日';
      } else {
        return '';
      }

      // ✅ 4글자 초과 시 "毎月" 뒤에서 개행
      if (displayText.length > 4) {
        displayText = displayText.replaceFirst('毎月', '毎月\n');
      }

      return displayText;
    } else if (_selectedTab == 2) {
      // 間隔 탭: 선택한 라벨 그대로 표시
      return _selectedIntervalLabel ?? '';
    }

    return '';
  }

  // ✅ "完了" 버튼 클릭 시 최종 저장
  Future<void> _saveRepeat() async {
    final displayText = _generateDisplayText();

    if (displayText.isNotEmpty) {
      String value = '';

      if (_selectedTab == 0) {
        value = 'daily:${_selectedWeekdays.join(',')}';
        debugPrint('🐛 [RepeatPicker] 毎日 탭 저장');
        debugPrint('🐛 [RepeatPicker] _selectedWeekdays: $_selectedWeekdays');
        debugPrint('🐛 [RepeatPicker] value: $value');
      } else if (_selectedTab == 1) {
        value = 'monthly:${_selectedMonthDays.join(',')}';
      } else if (_selectedTab == 2) {
        value = _selectedInterval ?? '';
      }

      // JSON 형식으로 저장
      final repeatJson = '{"value":"$value","display":"$displayText"}';

      debugPrint('💾 [RepeatPicker] ========== 저장 시작 ==========');
      debugPrint('💾 [RepeatPicker] 반복 규칙: $repeatJson');
      debugPrint('💾 [RepeatPicker] 표시 텍스트: $displayText');
      debugPrint(
        '💾 [RepeatPicker] Provider 업데이트 전: ${widget.controller.repeatRule}',
      );

      widget.controller.updateRepeatRule(repeatJson);

      debugPrint(
        '💾 [RepeatPicker] Provider 업데이트 후: ${widget.controller.repeatRule}',
      );

      // ✅ 캐시에도 저장 (임시 저장)
      await TempInputCache.saveTempRepeatRule(repeatJson);

      debugPrint('💾 [RepeatPicker] ========== 저장 완료 ==========');
    } else {
      // ✅ 선택값이 없으면 반복 규칙 제거
      debugPrint('🗑️ [RepeatPicker] 모든 선택 해제 → 반복 규칙 제거');
      widget.controller.clearRepeatRule();
      await TempInputCache.saveTempRepeatRule('');
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // ✅✅✅ 핵심: Padding으로 전체 Container를 감싸서 바텀시트 자체가 위로 올라가도록!
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        decoration: ShapeDecoration(
          color: const Color(0xFFFCFCFC),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.only(
              topLeft: SmoothRadius(cornerRadius: 36, cornerSmoothing: 0.6),
              topRight: SmoothRadius(cornerRadius: 36, cornerSmoothing: 0.6),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32), // ✅ 상단 패딩 32px
            // 헤더 (TopNavi) - Figma 스펙: 좌우 28px 여백
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
              child: SizedBox(
                height: 54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // "繰り返し" 타이틀 - Figma: 19px, Bold, LINE Seed JP App_TTF
                    const Text(
                      '繰り返し',
                      style: TextStyle(
                        fontFamily: 'LINE Seed JP App_TTF',
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        height: 1.4, // line-height: 140%
                        letterSpacing: -0.005,
                        color: Color(0xFF111111),
                      ),
                    ),
                    // 닫기 버튼 (Modal Control Buttons) - Figma: 36×36px
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        padding: const EdgeInsets.all(8), // ✅ 8px 패딩
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE4E4E4,
                          ).withOpacity(0.9), // rgba(228, 228, 228, 0.9)
                          border: Border.all(
                            color: const Color(0xFF111111).withOpacity(0.02),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'asset/icon/X_icon.svg', // ✅ X_icon.svg 사용
                          width: 20, // ✅ 20×20px
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
            ),
            // 메인 컨텐츠
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 16),
              child: Column(
                children: [
                  // ✅ 탭 버튼 (毎日/毎月/間隔)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: 256,
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton('毎日', 0),
                          _buildTabButton('毎月', 1),
                          _buildTabButton('間隔', 2),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ✅ 탭별 컨텐츠
                  SizedBox(height: 280, child: _buildTabContent()),

                  const SizedBox(height: 20),

                  // CTA 버튼 ("完了")
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 20,
                    ),
                    child: GestureDetector(
                      onTap: _saveRepeat,
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
                        child: const Center(
                          child: Text(
                            '完了',
                            style: TextStyle(
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
          ],
        ),
      ),
    ); // ✅ Padding 닫기
  }

  // ✅ 탭 버튼 빌더
  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFFFF) : Colors.transparent,
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF111111).withOpacity(0.08),
                    width: 1,
                  )
                : null,
            borderRadius: BorderRadius.circular(100),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFBABABA).withOpacity(0.08),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: -0.065,
                color: Color(0xFF111111),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ 탭별 컨텐츠 빌더
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: // 毎日
        return _buildDailyContent();
      case 1: // 毎月
        return _buildMonthlyContent();
      case 2: // 間隔
        return _buildIntervalContent();
      default:
        return const SizedBox.shrink();
    }
  }

  // ✅ 毎日 탭 컨텐츠 (요일 선택)
  Widget _buildDailyContent() {
    final weekdays = ['月', '火', '水', '木', '金', '土', '日'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: weekdays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isSelected = _selectedWeekdays.contains(day);

          return Padding(
            padding: EdgeInsets.only(left: index > 0 ? 4 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    debugPrint('🐛 [RepeatPicker] 요일 제거: $day');
                    _selectedWeekdays.remove(day);
                  } else {
                    debugPrint('🐛 [RepeatPicker] 요일 추가: $day');
                    _selectedWeekdays.add(day);
                    // ✅ 다른 탭 선택 초기화
                    _selectedMonthDays.clear();
                    _selectedInterval = null;
                  }
                  debugPrint('🐛 [RepeatPicker] 현재 선택된 요일: $_selectedWeekdays');
                });
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF111111)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontFamily: 'LINE Seed JP App_TTF',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF111111),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ✅ 毎月 탭 컨텐츠 (날짜 선택)
  Widget _buildMonthlyContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // 1~7일
          _buildDateRow([1, 2, 3, 4, 5, 6, 7]),
          const SizedBox(height: 4),

          // 8~14일
          _buildDateRow([8, 9, 10, 11, 12, 13, 14]),
          const SizedBox(height: 4),

          // 15~21일
          _buildDateRow([15, 16, 17, 18, 19, 20, 21]),
          const SizedBox(height: 4),

          // 22~28일
          _buildDateRow([22, 23, 24, 25, 26, 27, 28]),
          const SizedBox(height: 4),

          // 29~31일 + 다음 달 1~4일 (회색)
          _buildDateRow([29, 30, 31, -1, -2, -3, -4]), // -값은 다음 달 (회색)
        ],
      ),
    );
  }

  // ✅ 날짜 행 빌더 (7개씩)
  Widget _buildDateRow(List<int> days) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: days.map((day) {
        // 다음 달 날짜 (회색 표시용)
        if (day < 0) {
          final nextMonthDay = day.abs();
          return _buildDateCell(nextMonthDay, isNextMonth: true);
        }
        return _buildDateCell(day);
      }).toList(),
    );
  }

  // ✅ 날짜 셀 빌더
  Widget _buildDateCell(int day, {bool isNextMonth = false}) {
    final isSelected = !isNextMonth && _selectedMonthDays.contains(day);

    return GestureDetector(
      onTap: isNextMonth
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  _selectedMonthDays.remove(day);
                } else {
                  // ✅ 최대 2개까지만 선택 가능
                  if (_selectedMonthDays.length < 2) {
                    _selectedMonthDays.add(day);
                    // ✅ 다른 탭 선택 초기화
                    _selectedWeekdays.clear();
                    _selectedInterval = null;
                  }
                }
              });
            },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF111111) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.07,
              color: isNextMonth
                  ? const Color(0xFF999999)
                  : isSelected
                  ? Colors.white
                  : const Color(0xFF111111),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ 間隔 탭 컨텐츠 (간격 설정)
  Widget _buildIntervalContent() {
    final intervalOptions = [
      {'value': '2days', 'label': '2日毎'},
      {'value': '3days', 'label': '3日毎'},
      {'value': '4days', 'label': '4日毎'},
      {'value': '5days', 'label': '5日毎'},
      {'value': '6days', 'label': '6日毎'},
      {'value': '1week', 'label': '1週毎'},
      {'value': '10days', 'label': '10日毎'},
      {'value': '2weeks', 'label': '2週毎'},
      {'value': '15days', 'label': '15日毎'},
      {'value': '20days', 'label': '20日毎'},
      {'value': '3weeks', 'label': '3週毎'},
      {'value': '25days', 'label': '25日毎'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: intervalOptions.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final option = intervalOptions[index];
          final value = option['value'] as String;
          final label = option['label'] as String;
          final isSelected = _selectedInterval == value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedInterval = value;
                    _selectedIntervalLabel = label; // ✅ 라벨도 함께 저장
                    // ✅ 다른 탭 선택 초기화
                    _selectedWeekdays.clear();
                    _selectedMonthDays.clear();
                  });
                  debugPrint('🔘 [RepeatPicker/間隔] 선택: $label');
                },
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF5F5F5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    width: 313,
                    height: 48,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Label Text
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'LINE Seed JP App_TTF',
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            height: 1.4,
                            letterSpacing: -0.065,
                            color: isSelected
                                ? const Color(0xFF111111)
                                : const Color(0xFF555555),
                          ),
                        ),

                        // Check Icon (visible when selected)
                        if (isSelected)
                          SvgPicture.asset(
                            'asset/icon/Check_icon.svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF111111),
                              BlendMode.srcIn,
                            ),
                          )
                        else
                          const SizedBox(width: 24, height: 24), // Placeholder
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
