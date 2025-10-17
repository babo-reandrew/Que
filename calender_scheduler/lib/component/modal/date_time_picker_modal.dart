import 'package:flutter/material.dart';
import '../../const/quick_add_config.dart';
import '../../widgets/apple_wheel_picker.dart';

/// 일정 선택 모달 위젯 (날짜/시간 선택)
/// 이거를 설정하고 → 피그마 OptionSetting (일정) 디자인을 재현해서
/// 이거를 해서 → 시작/종료 날짜와 시간을 선택하고
/// 이거는 이래서 → 일정 생성 시 정확한 DateTime을 DB에 저장한다
/// 이거라면 → 사용자가 직관적으로 일정 시간을 설정할 수 있다
class DateTimePickerModal extends StatefulWidget {
  final DateTime initialStartDateTime;
  final DateTime initialEndDateTime;
  final Function(DateTime start, DateTime end) onDateTimeSelected;

  const DateTimePickerModal({
    Key? key,
    required this.initialStartDateTime,
    required this.initialEndDateTime,
    required this.onDateTimeSelected,
  }) : super(key: key);

  @override
  State<DateTimePickerModal> createState() => _DateTimePickerModalState();
}

class _DateTimePickerModalState extends State<DateTimePickerModal> {
  late DateTime _startDateTime;
  late DateTime _endDateTime;
  bool _isEditingStart = true; // true: 시작 편집, false: 종료 편집

  @override
  void initState() {
    super.initState();
    _startDateTime = widget.initialStartDateTime;
    _endDateTime = widget.initialEndDateTime;
    print('📅 [일정 모달] 초기화: 시작=$_startDateTime, 종료=$_endDateTime');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: QuickAddConfig.modalWidth, // 피그마: 364px
      height: QuickAddConfig.dateTimePickerModalHeight, // 피그마: 508px
      decoration: BoxDecoration(
        color: QuickAddConfig.modalBackground, // 피그마: #fcfcfc
        border: Border.all(
          color: QuickAddConfig.modalBorder, // 피그마: #111111 opacity 10%
          width: 1,
        ),
        borderRadius: BorderRadius.circular(
          QuickAddConfig.modalRadius,
        ), // 피그마: 36px
      ),
      child: Column(
        children: [
          // ✅ TopNavi (피그마: TopNavi)
          _buildTopNavi(),

          const SizedBox(height: 12),

          // ✅ 시작/종료 시간 표시 (피그마: DetailView)
          _buildDateTimeDisplay(),

          const SizedBox(height: 24),

          // ✅ iOS Wheel Picker (피그마: WheelPicker)
          _buildWheelPicker(),

          const Spacer(),

          // ✅ CTA 버튼 (피그마: "完了")
          _buildCTAButton(),
        ],
      ),
    );
  }

  /// TopNavi 위젯 (피그마: TopNavi)
  Widget _buildTopNavi() {
    return Container(
      height: QuickAddConfig.topNaviHeight, // 피그마: 54px
      padding: EdgeInsets.symmetric(
        horizontal: QuickAddConfig.modalTopNaviLeftPadding,
      ), // 28px
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌측: 제목 "日付"
          Text(
            QuickAddConfig.modalTitleDateTime, // 피그마: "日付"
            style: QuickAddConfig.topNaviTitleStyle, // Bold 19px, #111111
          ),

          // 우측: 닫기 버튼
          GestureDetector(
            onTap: () {
              print('❌ [일정 모달] 닫기 버튼 클릭');
              Navigator.of(context).pop();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E4E4).withOpacity(0.9),
                border: Border.all(
                  color: const Color(0xFF111111).withOpacity(0.02),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(100),
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

  /// 시작/종료 시간 표시 위젯 (피그마: DetailView - Frame 758, Frame 759)
  /// 이거를 설정하고 → 시작/종료를 좌우로 배치해서
  /// 이거를 해서 → 사용자가 현재 선택된 시간을 확인하고
  /// 이거는 이래서 → 클릭하면 편집 모드를 전환한다
  Widget _buildDateTimeDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // 좌측: 시작 (피그마: Frame 758)
          Expanded(
            child: _DateTimeDisplayBox(
              label: '開始', // 피그마: "開始"
              dateTime: _startDateTime,
              isEditing: _isEditingStart,
              onTap: () {
                setState(() {
                  _isEditingStart = true;
                });
                print('📅 [일정 모달] 시작 시간 편집 모드');
              },
            ),
          ),

          // 중앙: 구분선 (피그마: DetailView_Object, 8×46px)
          Container(
            width: 8,
            height: 46,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: const Center(
              child: VerticalDivider(color: Color(0xFFE0E0E0), thickness: 2),
            ),
          ),

          // 우측: 종료 (피그마: Frame 759)
          Expanded(
            child: _DateTimeDisplayBox(
              label: '終了', // 피그마: "終了"
              dateTime: _endDateTime,
              isEditing: !_isEditingStart,
              onTap: () {
                setState(() {
                  _isEditingStart = false;
                });
                print('📅 [일정 모달] 종료 시간 편집 모드');
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Wheel Picker 위젯 (피그마: WheelPicker)
  Widget _buildWheelPicker() {
    return AppleDateTimeWheelPicker(
      initialDateTime: _isEditingStart ? _startDateTime : _endDateTime,
      onDateTimeChanged: (dateTime) {
        setState(() {
          if (_isEditingStart) {
            _startDateTime = dateTime;
            print('📅 [일정 모달] 시작 시간 변경: $_startDateTime');
          } else {
            _endDateTime = dateTime;
            print('📅 [일정 모달] 종료 시간 변경: $_endDateTime');
          }
        });
      },
    );
  }

  /// CTA 버튼 위젯 (피그마: CTA "完了")
  Widget _buildCTAButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: GestureDetector(
        onTap: () {
          print('✅ [일정 모달] 완료 버튼 클릭');
          print('   → 시작: $_startDateTime');
          print('   → 종료: $_endDateTime');
          widget.onDateTimeSelected(_startDateTime, _endDateTime);
          Navigator.of(context).pop();
        },
        child: Container(
          width: 333,
          height: QuickAddConfig.ctaButtonHeight, // 56px
          decoration: BoxDecoration(
            color: QuickAddConfig.buttonActive, // #111111
            border: Border.all(
              color: const Color(0xFF111111).withOpacity(0.01),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            QuickAddConfig.buttonComplete, // "完了"
            style: QuickAddConfig.ctaButtonStyle, // Bold 15px, #fafafa
          ),
        ),
      ),
    );
  }
}

/// 날짜/시간 표시 박스 위젯 (피그마: Frame 758, Frame 759)
/// 이거를 설정하고 → 날짜와 시간을 세로로 배치해서
/// 이거를 해서 → 선택/편집 상태를 시각적으로 표시한다
class _DateTimeDisplayBox extends StatelessWidget {
  final String label; // "開始" 또는 "終了"
  final DateTime dateTime;
  final bool isEditing;
  final VoidCallback onTap;

  const _DateTimeDisplayBox({
    required this.label,
    required this.dateTime,
    required this.isEditing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isEditing
              ? const Color(0xFFF0F0F0).withOpacity(0.5) // 편집 중 강조
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 라벨 (피그마: "開始" / "終了")
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7A7A7A), // 피그마: #7a7a7a
                letterSpacing: -0.08,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 4),

            // 중단: 날짜 (피그마: "25. 7. 30")
            Text(
              '${dateTime.year}. ${dateTime.month}. ${dateTime.day}',
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 19,
                fontWeight: FontWeight.w800, // ExtraBold
                color: Color(0xFF111111), // 피그마: #111111
                letterSpacing: -0.095,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 2),

            // 하단: 시간 (피그마: "15:30")
            Text(
              '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 33,
                fontWeight: FontWeight.w800, // ExtraBold
                color: Color(0xFF111111), // 피그마: #111111
                letterSpacing: -0.165,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
