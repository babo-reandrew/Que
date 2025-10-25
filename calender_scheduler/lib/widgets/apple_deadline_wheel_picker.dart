import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../const/quick_add_config.dart';

/// 締切(마감일) 전용 Wheel Picker
/// 연도-월-일만 선택 가능
class AppleDeadlineWheelPicker extends StatefulWidget {
  final DateTime initialDateTime;
  final Function(DateTime) onDateTimeChanged;

  const AppleDeadlineWheelPicker({
    Key? key,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  }) : super(key: key);

  @override
  State<AppleDeadlineWheelPicker> createState() =>
      _AppleDeadlineWheelPickerState();
}

class _AppleDeadlineWheelPickerState extends State<AppleDeadlineWheelPicker> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  // 연도 리스트 생성 (현재 연도 ±10년)
  List<String> _generateYearList() {
    final currentYear = DateTime.now().year;
    final List<String> years = [];
    for (int i = currentYear - 10; i <= currentYear + 10; i++) {
      years.add(i.toString());
    }
    return years;
  }

  // 월 리스트 생성 (01-12)
  List<String> _generateMonthList() {
    return List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  }

  // 일 리스트 생성 (선택된 연월에 따라 동적 생성)
  List<String> _generateDayList() {
    final daysInMonth = DateTime(
      _selectedDateTime.year,
      _selectedDateTime.month + 1,
      0,
    ).day;
    return List.generate(
      daysInMonth,
      (index) => (index + 1).toString().padLeft(2, '0'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final yearList = _generateYearList();
    final monthList = _generateMonthList();
    final dayList = _generateDayList();

    final initialYearIndex =
        _selectedDateTime.year - (DateTime.now().year - 10);
    final initialMonthIndex = _selectedDateTime.month - 1;
    final initialDayIndex = _selectedDateTime.day - 1;

    return SizedBox(
      width: QuickAddConfig.wheelPickerWidth,
      height: QuickAddConfig.wheelPickerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 하이라이트 박스
          Positioned(
            child: Container(
              height: QuickAddConfig.wheelPickerRowHeight,
              decoration: BoxDecoration(
                color: const Color(0xFFCFCFCF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(
                  QuickAddConfig.wheelPickerRowRadius,
                ),
              ),
            ),
          ),
          // 피커들
          Row(
            children: [
              // 연도 Picker
              Expanded(
                flex: 2,
                child: _buildWheelPicker(
                  items: yearList,
                  initialIndex: initialYearIndex,
                  onSelectedItemChanged: (index) {
                    final newYear = DateTime.now().year - 10 + index;
                    setState(() {
                      _selectedDateTime = DateTime(
                        newYear,
                        _selectedDateTime.month,
                        _selectedDateTime.day,
                      );
                    });
                    widget.onDateTimeChanged(_selectedDateTime);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // 월 Picker
              Expanded(
                flex: 1,
                child: _buildWheelPicker(
                  items: monthList,
                  initialIndex: initialMonthIndex,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        _selectedDateTime.year,
                        index + 1,
                        _selectedDateTime.day,
                      );
                    });
                    widget.onDateTimeChanged(_selectedDateTime);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // 일 Picker
              Expanded(
                flex: 1,
                child: _buildWheelPicker(
                  items: dayList,
                  initialIndex: initialDayIndex,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        _selectedDateTime.year,
                        _selectedDateTime.month,
                        index + 1,
                      );
                    });
                    widget.onDateTimeChanged(_selectedDateTime);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWheelPicker({
    required List<String> items,
    required int initialIndex,
    required Function(int) onSelectedItemChanged,
  }) {
    final controller = FixedExtentScrollController(initialItem: initialIndex);

    return CupertinoPicker(
      scrollController: controller,
      itemExtent: 31.0,
      diameterRatio: 1.5,
      useMagnifier: false,
      magnification: 1.0,
      squeeze: 1.0,
      backgroundColor: Colors.transparent,
      selectionOverlay: Container(),
      onSelectedItemChanged: onSelectedItemChanged,
      children: items.map((item) {
        return Center(
          child: Text(
            item,
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005 * 19,
              color: Color(0xFF111111),
            ),
          ),
        );
      }).toList(),
    );
  }
}
