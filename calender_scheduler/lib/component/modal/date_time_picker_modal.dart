import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/apple_wheel_picker.dart';
import '../../utils/temp_input_cache.dart';

Future<void> showDateTimePickerModal(
  BuildContext context, {
  required DateTime initialStartDateTime,
  required DateTime initialEndDateTime,
  required Function(DateTime start, DateTime end) onDateTimeSelected,
  bool isAllDay = false, // ✅ 終日 모드 파라미터 추가
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DateTimePickerSheet(
      initialStartDateTime: initialStartDateTime,
      initialEndDateTime: initialEndDateTime,
      onDateTimeSelected: onDateTimeSelected,
      isAllDay: isAllDay, // ✅ 終日 모드 전달
    ),
  );
}

class DateTimePickerSheet extends StatefulWidget {
  final DateTime initialStartDateTime;
  final DateTime initialEndDateTime;
  final Function(DateTime start, DateTime end) onDateTimeSelected;
  final bool isAllDay; // ✅ 終日 모드

  const DateTimePickerSheet({
    super.key,
    required this.initialStartDateTime,
    required this.initialEndDateTime,
    required this.onDateTimeSelected,
    this.isAllDay = false, // ✅ 기본값 false
  });

  @override
  State<DateTimePickerSheet> createState() => _DateTimePickerSheetState();
}

class _DateTimePickerSheetState extends State<DateTimePickerSheet> {
  late DateTime _startDateTime;
  late DateTime _endDateTime;
  bool _isEditingStart = true;
  Duration? _timeDifference; // 시작-종료 시간 차이 저장

  @override
  void initState() {
    super.initState();
    _startDateTime = widget.initialStartDateTime;
    _endDateTime = widget.initialEndDateTime;

    // 초기 시간 차이 계산
    _timeDifference = _endDateTime.difference(_startDateTime);
    print('⏰ [DateTimePicker] 초기 시간 차이: ${_timeDifference?.inMinutes}분');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(height: 32),
          _buildTopNavi(),
          const SizedBox(height: 42),
          _buildDetailView(),
          const SizedBox(height: 16),
          _buildCTAButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTopNavi() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '日付',
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005,
              color: Color(0xFF111111),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.04),
                    offset: Offset(0, 4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 20,
                color: Color(0xFF111111),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    return Column(
      children: [
        _buildStartEndDisplay(),
        const SizedBox(height: 16),
        _buildWheelPickerSection(),
      ],
    );
  }

  Widget _buildStartEndDisplay() {
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 48),
      child: Stack(
        children: [
          // 좌측: 開始 (좌측 48px에 고정)
          Align(
            alignment: Alignment.centerLeft,
            child: Opacity(
              opacity: _isEditingStart ? 1.0 : 0.3,
              child: _buildTimeDisplay(
                label: '開始',
                dateTime: _startDateTime,
                onTap: () => setState(() => _isEditingStart = true),
              ),
            ),
          ),
          // 중앙: 화살표
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SvgPicture.asset(
                'asset/icon/Date_Picker_arrow.svg',
                width: 8,
                height: 46,
              ),
            ),
          ),
          // 우측: 終了 (우측 정렬)
          Align(
            alignment: Alignment.centerRight,
            child: Opacity(
              opacity: _isEditingStart ? 0.3 : 1.0,
              child: _buildTimeDisplay(
                label: '終了',
                dateTime: _endDateTime,
                onTap: () => setState(() => _isEditingStart = false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay({
    required String label,
    required DateTime dateTime,
    required VoidCallback onTap,
  }) {
    final dateText =
        '${dateTime.year.toString().substring(2)}. ${dateTime.month}. ${dateTime.day}';
    final timeText =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005,
              color: Color(0xFF7A7A7A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dateText,
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.005,
              color: Color(0xFF111111),
              shadows: [
                Shadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  offset: Offset(0, 4),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeText,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 33,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.005,
              color: Color(0xFF111111),
              shadows: [
                Shadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  offset: Offset(0, 4),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelPickerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 153,
        child: AppleDateTimeWheelPicker(
          initialDateTime: _isEditingStart ? _startDateTime : _endDateTime,
          isAllDay: widget.isAllDay, // ✅ 終日 모드 전달
          onDateTimeChanged: (dateTime) {
            setState(() {
              if (_isEditingStart) {
                // 시작 시간 변경
                final oldStart = _startDateTime;
                _startDateTime = dateTime;

                // 종료 시간도 같이 이동 (시간 차이 유지)
                if (_timeDifference != null) {
                  _endDateTime = _startDateTime.add(_timeDifference!);
                  print('⏰ [DateTimePicker] 시작 변경 → 종료도 자동 조정');
                  print('   시작: $oldStart → $_startDateTime');
                  print(
                    '   종료: $_endDateTime (차이: ${_timeDifference?.inMinutes}분 유지)',
                  );
                }
              } else {
                // 종료 시간 변경
                _endDateTime = dateTime;

                // 새로운 시간 차이 계산 및 저장
                _timeDifference = _endDateTime.difference(_startDateTime);
                print(
                  '⏰ [DateTimePicker] 종료 변경 → 새 시간 차이 저장: ${_timeDifference?.inMinutes}분',
                );
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    return GestureDetector(
      onTap: () async {
        // 임시 캐시에 저장
        await TempInputCache.saveTempDateTime(_startDateTime, _endDateTime);
        widget.onDateTimeSelected(_startDateTime, _endDateTime);
        Navigator.pop(context);
      },
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
        alignment: Alignment.center,
        child: const Text(
          '追加する',
          style: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.4,
            letterSpacing: -0.005,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
