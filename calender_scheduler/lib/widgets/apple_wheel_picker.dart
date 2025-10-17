import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../const/quick_add_config.dart';

/// iOS 스타일 Wheel Picker 위젯
/// 이거를 설정하고 → CupertinoPicker를 커스터마이징해서
/// 이거를 해서 → 피그마 디자인과 동일한 스타일을 적용하고
/// 이거는 이래서 → 애플 네이티브한 UX를 제공한다
/// 이거라면 → 사용자가 자연스럽게 날짜/시간을 선택할 수 있다
class AppleWheelPicker extends StatelessWidget {
  final List<String> items; // 표시할 아이템 리스트
  final int initialIndex; // 초기 선택 인덱스
  final Function(int) onSelectedItemChanged; // 선택 변경 콜백
  final double itemExtent; // 아이템 높이 (피그마: 31px)
  final bool useMagnification; // 확대 효과 사용 여부

  const AppleWheelPicker({
    Key? key,
    required this.items,
    this.initialIndex = 0,
    required this.onSelectedItemChanged,
    this.itemExtent = 31.0, // 피그마: WheelPicker_Object 높이 31px
    this.useMagnification = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 이거를 설정하고 → FixedExtentScrollController로 초기 위치를 설정해서
    // 이거를 해서 → 피커가 초기값에서 시작한다
    final controller = FixedExtentScrollController(initialItem: initialIndex);

    return Container(
      height: QuickAddConfig.wheelPickerHeight, // 피그마: 105px
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ✅ 선택 영역 하이라이트 (피그마: Rectangle 399)
          Positioned(
            child: Container(
              height: QuickAddConfig.wheelPickerRowHeight, // 피그마: 36px
              decoration: BoxDecoration(
                color:
                    QuickAddConfig.wheelPickerSelected, // #cfcfcf opacity 30%
                borderRadius: BorderRadius.circular(
                  QuickAddConfig.wheelPickerRowRadius,
                ), // 8px
              ),
            ),
          ),

          // ✅ CupertinoPicker (iOS 네이티브 스타일)
          CupertinoPicker(
            scrollController: controller,
            itemExtent: itemExtent, // 피그마: 31px
            diameterRatio: 1.5, // 곡률 조정 (값이 작을수록 평평함)
            useMagnifier: useMagnification, // 확대 효과
            magnification: 1.0, // 확대 배율
            squeeze: 1.0, // 압축 효과
            onSelectedItemChanged: (index) {
              print(
                '🎡 [Wheel Picker] 선택 변경: index $index → "${items[index]}"',
              );
              onSelectedItemChanged(index);
            },
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              // ✅ 중앙 선택 여부 확인
              // 이거를 설정하고 → 현재 인덱스가 중앙인지 확인해서
              // 이거를 해서 → 선택/비선택 스타일을 적용한다
              final isCenter = index == initialIndex;

              return Center(
                child: Text(
                  item,
                  style: isCenter
                      ? QuickAddConfig
                            .wheelPickerSelectedStyle // Bold, #111111
                      : QuickAddConfig
                            .wheelPickerUnselectedStyle, // Regular, #000000 30%
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// iOS 스타일 날짜/시간 Wheel Picker (조합형)
/// 이거를 설정하고 → 날짜, 시간, 분 3개의 Wheel Picker를 조합해서
/// 이거를 해서 → 피그마 디자인의 WheelPicker를 완벽 재현한다
class AppleDateTimeWheelPicker extends StatefulWidget {
  final DateTime initialDateTime;
  final Function(DateTime) onDateTimeChanged;

  const AppleDateTimeWheelPicker({
    Key? key,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  }) : super(key: key);

  @override
  State<AppleDateTimeWheelPicker> createState() =>
      _AppleDateTimeWheelPickerState();
}

class _AppleDateTimeWheelPickerState extends State<AppleDateTimeWheelPicker> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  // 이거를 설정하고 → 날짜 리스트를 생성해서 (예: "8月30日 火")
  // 이거를 해서 → Wheel Picker에 표시한다
  List<String> _generateDateList() {
    final List<String> dates = [];
    final now = DateTime.now();

    // 이거를 설정하고 → 현재 날짜 기준 ±30일 범위를 생성해서
    // 이거를 해서 → 충분한 선택지를 제공한다
    for (int i = -30; i <= 30; i++) {
      final date = now.add(Duration(days: i));
      final weekday = _getJapaneseWeekday(date.weekday);
      dates.add('${date.month}月${date.day}日 $weekday');
    }

    return dates;
  }

  // 이거를 설정하고 → 시간 리스트를 생성해서 (0~23)
  // 이거를 해서 → Wheel Picker에 표시한다
  List<String> _generateHourList() {
    return List.generate(24, (index) => index.toString().padLeft(2, '0'));
  }

  // 이거를 설정하고 → 분 리스트를 생성해서 (0, 15, 30, 45)
  // 이거를 해서 → 15분 단위로 선택할 수 있다
  List<String> _generateMinuteList() {
    return ['00', '15', '30', '45'];
  }

  // 요일을 일본어로 변환
  String _getJapaneseWeekday(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final dateList = _generateDateList();
    final hourList = _generateHourList();
    final minuteList = _generateMinuteList();

    // 이거를 설정하고 → 초기 인덱스를 계산해서
    // 이거를 해서 → Wheel Picker의 시작 위치를 설정한다
    final initialDateIndex = 30; // 오늘 날짜 (리스트 중앙)
    final initialHourIndex = _selectedDateTime.hour;
    final initialMinuteIndex = (_selectedDateTime.minute / 15).floor();

    return Container(
      width: QuickAddConfig.wheelPickerWidth, // 피그마: 253px
      height: QuickAddConfig.wheelPickerHeight, // 피그마: 105px
      child: Row(
        children: [
          // ✅ 좌측: 날짜 Picker (피그마: Frame 764)
          Expanded(
            flex: 4,
            child: AppleWheelPicker(
              items: dateList,
              initialIndex: initialDateIndex,
              onSelectedItemChanged: (index) {
                // 날짜 변경 로직
                final newDate = DateTime.now().add(Duration(days: index - 30));
                setState(() {
                  _selectedDateTime = DateTime(
                    newDate.year,
                    newDate.month,
                    newDate.day,
                    _selectedDateTime.hour,
                    _selectedDateTime.minute,
                  );
                });
                widget.onDateTimeChanged(_selectedDateTime);
              },
            ),
          ),

          const SizedBox(width: 8),

          // ✅ 중앙: 시간 Picker (피그마: Frame 765)
          Expanded(
            flex: 1,
            child: AppleWheelPicker(
              items: hourList,
              initialIndex: initialHourIndex,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedDateTime = DateTime(
                    _selectedDateTime.year,
                    _selectedDateTime.month,
                    _selectedDateTime.day,
                    index,
                    _selectedDateTime.minute,
                  );
                });
                widget.onDateTimeChanged(_selectedDateTime);
              },
            ),
          ),

          const SizedBox(width: 8),

          // ✅ 우측: 분 Picker (피그마: Frame 766)
          Expanded(
            flex: 1,
            child: AppleWheelPicker(
              items: minuteList,
              initialIndex: initialMinuteIndex,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedDateTime = DateTime(
                    _selectedDateTime.year,
                    _selectedDateTime.month,
                    _selectedDateTime.day,
                    _selectedDateTime.hour,
                    index * 15, // 15분 단위
                  );
                });
                widget.onDateTimeChanged(_selectedDateTime);
              },
            ),
          ),
        ],
      ),
    );
  }
}
