import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../../widgets/apple_deadline_wheel_picker.dart';

/// 締切(마감일) 선택 모달
/// 연도-월-일만 선택 가능한 단순 날짜 피커
Future<void> showDeadlinePickerModal(
  BuildContext context, {
  required DateTime initialDeadline,
  required Function(DateTime) onDeadlineSelected,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DeadlinePickerSheet(
      initialDeadline: initialDeadline,
      onDeadlineSelected: onDeadlineSelected,
    ),
  );
}

class DeadlinePickerSheet extends StatefulWidget {
  final DateTime initialDeadline;
  final Function(DateTime) onDeadlineSelected;

  const DeadlinePickerSheet({
    super.key,
    required this.initialDeadline,
    required this.onDeadlineSelected,
  });

  @override
  State<DeadlinePickerSheet> createState() => _DeadlinePickerSheetState();
}

class _DeadlinePickerSheetState extends State<DeadlinePickerSheet> {
  late DateTime _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _selectedDeadline = widget.initialDeadline;
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
          _buildDateDisplay(),
          const SizedBox(height: 42),
          _buildWheelPickerSection(),
          const SizedBox(height: 42), // ✅ 피커와 완료 버튼 사이 42px
          _buildCTAButton(),
          const SizedBox(height: 20), // ✅ 버튼 하단 20px
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
            '締め切り',
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005 * 19,
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

  Widget _buildDateDisplay() {
    return Padding(
      padding: const EdgeInsets.only(left: 28), // ✅ 좌측 28px 여백
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedDeadline.month.toString().padLeft(2, '0')}.${_selectedDeadline.day.toString().padLeft(2, '0')}.',
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 36, // ✅ 월.일 36px
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.005 * 36,
              color: Color(0xFF111111),
            ),
          ),
          Text(
            _selectedDeadline.year.toString(),
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 18, // ✅ 연도 18px
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.005 * 18,
              color: Color(0xFFFF5555),
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
        height: 140, // ✅ 피커 높이 140px
        child: AppleDeadlineWheelPicker(
          initialDateTime: _selectedDeadline,
          onDateTimeChanged: (dateTime) {
            setState(() {
              _selectedDeadline = dateTime;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    return GestureDetector(
      onTap: () {
        widget.onDeadlineSelected(_selectedDeadline);
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
          '完了',
          style: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.4,
            letterSpacing: -0.005 * 15,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
