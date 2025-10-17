import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../const/quick_add_config.dart';
import '../../design_system/quick_add_design_system.dart'; // ✅ Design System import
import 'quick_add_type_selector.dart';
import 'quick_detail_button.dart';
import 'quick_detail_popup.dart';
import '../modal/date_time_picker_modal.dart';
import '../modal/schedule_detail_wolt_modal.dart'; // ✅ 일정 Wolt 모달
import '../modal/task_detail_wolt_modal.dart'; // ✅ 할일 Wolt 모달
import '../modal/habit_detail_wolt_modal.dart'; // ✅ 습관 Wolt 모달
import '../../design_system/wolt_helpers.dart'; // ✅ Wolt helper functions

/// Quick_Add_ControlBox 메인 위젯
/// 이거를 설정하고 → 피그마 Quick_Add_ControlBox 디자인을 완벽 재현해서
/// 이거를 해서 → 일정/할일/습관 입력을 통합 관리하고
/// 이거는 이래서 → 동적으로 높이가 확장/축소되며 애니메이션된다
/// 이거라면 → 사용자가 하나의 UI에서 모든 타입을 입력할 수 있다
class QuickAddControlBox extends StatefulWidget {
  final DateTime selectedDate;
  final Function(Map<String, dynamic> data)? onSave; // 저장 콜백
  final QuickAddType? externalSelectedType; // ✅ 외부에서 전달받는 타입
  final Function(QuickAddType?)? onTypeChanged; // ✅ 타입 변경 콜백

  const QuickAddControlBox({
    Key? key,
    required this.selectedDate,
    this.onSave,
    this.externalSelectedType, // ✅ 외부 타입
    this.onTypeChanged, // ✅ 타입 변경 알림
  }) : super(key: key);

  @override
  State<QuickAddControlBox> createState() => _QuickAddControlBoxState();
}

class _QuickAddControlBoxState extends State<QuickAddControlBox>
    with SingleTickerProviderStateMixin {
  // ========================================
  // 상태 변수
  // ========================================
  QuickAddType? _selectedType; // 선택된 타입 (일정/할일/습관)
  final TextEditingController _textController = TextEditingController();
  String _selectedColorId = 'gray'; // 선택된 색상 ID
  DateTime? _startDateTime; // 시작 날짜/시간
  DateTime? _endDateTime; // 종료 날짜/시간
  bool _showDetailPopup = false; // ✅ QuickDetailPopup 표시 여부
  bool _isAddButtonActive = false; // ✅ 追加버튼 활성화 상태 (텍스트 입력 시 활성화)

  // ✅ 반복/리마인더 설정 상태 변수
  String _repeatRule = ''; // 반복 규칙 (JSON 문자열)
  String _reminder = ''; // 리마인더 설정 (JSON 문자열)

  // ========================================
  // 애니메이션 컨트롤러
  // ========================================
  late AnimationController _heightAnimationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ 외부에서 전달받은 타입이 있으면 초기화
    _selectedType = widget.externalSelectedType;

    // 이거를 설정하고 → AnimationController를 초기화해서
    // 이거를 해서 → 높이 확장 애니메이션을 제어한다
    _heightAnimationController = AnimationController(
      vsync: this,
      duration: QuickAddConfig.heightExpandDuration, // 350ms
    );

    // 이거를 설정하고 → 초기 높이를 설정해서
    // 이거를 해서 → 기본 상태는 132px로 시작한다
    _heightAnimation =
        Tween<double>(
          begin: QuickAddConfig.controlBoxInitialHeight, // 132px
          end: QuickAddConfig.controlBoxInitialHeight,
        ).animate(
          CurvedAnimation(
            parent: _heightAnimationController,
            curve: QuickAddConfig.heightExpandCurve, // easeInOutCubic
          ),
        );

    print('🎬 [Quick Add] 컨트롤 박스 초기화 완료 (외부 타입: $_selectedType)');
  }

  @override
  void didUpdateWidget(QuickAddControlBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ 외부 타입이 변경되면 내부 상태도 업데이트
    if (widget.externalSelectedType != oldWidget.externalSelectedType) {
      setState(() {
        _selectedType = widget.externalSelectedType;
      });
      print('🔄 [Quick Add] 외부 타입 변경 감지: $_selectedType');
    }
  }

  @override
  void dispose() {
    _heightAnimationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // ========================================
  // 타입 선택 시 높이 변경
  // ========================================
  void _onTypeSelected(QuickAddType type) {
    // ✅ 습관 선택 시 → 바로 모달만 표시 (QuickAdd 상태 변경 없음)
    if (type == QuickAddType.habit) {
      print('🔄 [Quick Add] 습관 선택 → 모달만 표시');
      _showFullHabitBottomSheet();
      return;
    }

    // ✅ 같은 타입 다시 터치 시 → 기본 상태로 복귀
    if (_selectedType == type) {
      setState(() {
        _selectedType = null;
        _showDetailPopup = false;
      });
      widget.onTypeChanged?.call(null);

      // 높이 축소 애니메이션
      _heightAnimation =
          Tween<double>(
            begin: _heightAnimation.value,
            end: QuickAddConfig.controlBoxInitialHeight, // 132px
          ).animate(
            CurvedAnimation(
              parent: _heightAnimationController,
              curve: QuickAddConfig.heightExpandCurve,
            ),
          );
      _heightAnimationController.forward(from: 0.0);

      print('🔄 [Quick Add] 타입 해제 → 기본 상태 복귀 (132px)');
      return;
    }

    setState(() {
      _selectedType = type;
      _showDetailPopup = false; // ✅ 타입 선택 시 팝업 숨김
    });

    // ✅ 외부에 타입 변경 알림
    widget.onTypeChanged?.call(type);

    // ✅ Figma 스펙: 타입 선택 시 높이가 확장됨 (하단 고정, 상단이 올라감)
    // 이거를 설정하고 → 선택된 타입에 따라 목표 높이를 설정해서
    // 이거를 해서 → 애니메이션으로 높이를 확장한다
    // 이거는 이래서 → 하단은 키보드 위에 고정되고 상단이 올라간다
    double targetHeight;
    switch (type) {
      case QuickAddType.schedule:
        // 이거를 설정하고 → "今日のスケジュール" 선택 시 자동으로 시간을 설정해서
        // 이거를 해서 → 현재 시간 + 1시간을 시작/종료 시간으로 지정한다
        final now = DateTime.now();
        final startTime = DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
          now.hour,
          now.minute,
        );
        final endTime = startTime.add(
          const Duration(hours: 1),
        ); // 이거라면 → 1시간 후로 종료 시간 설정

        setState(() {
          _startDateTime = startTime;
          _endDateTime = endTime;
        });

        print('⏰ [Quick Add] 자동 시간 설정 완료');
        print('   → 시작: $startTime');
        print('   → 종료: $endTime');

        targetHeight = QuickAddConfig.controlBoxScheduleHeight; // 196px
        print('📅 [Quick Add] 일정 모드로 확장: ${targetHeight}px');
        break;

      case QuickAddType.task:
        targetHeight = QuickAddConfig.controlBoxTaskHeight; // 192px
        print('✅ [Quick Add] 할일 모드로 확장: ${targetHeight}px');
        break;

      case QuickAddType.habit:
        // ✅ 습관은 위에서 이미 처리됨 (모달 표시)
        return;
    }

    // 이거를 설정하고 → 애니메이션 범위를 업데이트해서
    // 이거를 해서 → 부드럽게 높이가 변경된다 (하단 고정, 상단이 올라감)
    _heightAnimation =
        Tween<double>(begin: _heightAnimation.value, end: targetHeight).animate(
          CurvedAnimation(
            parent: _heightAnimationController,
            curve: QuickAddConfig.heightExpandCurve,
          ),
        );

    _heightAnimationController.forward(from: 0.0);

    // 햅틱 피드백 제거 (사용자 요청)
    // HapticFeedback.lightImpact();
  }

  // ========================================
  // 색상 선택 모달 표시 (Figma 2372-26840)
  // ========================================
  void _showColorPicker() async {
    print('🎨 [Quick Add] 색상 선택 모달 열기');

    // 이거를 설정하고 → showModalBottomSheet로 하단에 모달 표시해서
    // 이거를 해서 → 키보드가 내려가고 Wolt ColorPicker가 표시된다
    // 이거는 이래서 → helper 함수로 간결하게 처리된다
    showWoltColorPicker(context, initialColorId: _selectedColorId);
  }

  // ========================================
  // 날짜/시간 선택 모달 표시
  // ========================================
  void _showDateTimePicker() async {
    print('📅 [Quick Add] 일정 선택 모달 열기');

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Center(
        child: DateTimePickerModal(
          initialStartDateTime: _startDateTime ?? widget.selectedDate,
          initialEndDateTime:
              _endDateTime ?? widget.selectedDate.add(Duration(hours: 1)),
          onDateTimeSelected: (start, end) {
            setState(() {
              _startDateTime = start;
              _endDateTime = end;
            });
            print('📅 [Quick Add] 일정 선택됨: 시작=$start, 종료=$end');
          },
        ),
      ),
    );
  }

  // ========================================
  // 전체 일정 Wolt 모달 표시
  // ========================================
  void _showFullScheduleBottomSheet() {
    print('📋 [Quick Add] 일정 Wolt 모달 열기');

    // ✅ 먼저 현재 bottom sheet 닫기 (검은 화면 방지!)
    Navigator.of(context).pop();

    // 약간의 딜레이 후 Wolt 모달 열기 (애니메이션 충돌 방지)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      showScheduleDetailWoltModal(
        context,
        schedule: null, // 새 일정 생성
        selectedDate: widget.selectedDate,
      );
    });
  }

  // ========================================
  // 전체 할일 Wolt 모달 표시
  // ========================================
  void _showFullTaskBottomSheet() {
    print('📋 [Quick Add] 할일 Wolt 모달 열기');

    // ✅ 먼저 현재 bottom sheet 닫기 (검은 화면 방지!)
    Navigator.of(context).pop();

    // 약간의 딜레이 후 Wolt 모달 열기 (애니메이션 충돌 방지)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      showTaskDetailWoltModal(
        context,
        task: null,
        selectedDate: widget.selectedDate,
      );
    });
  }

  // ========================================
  // 전체 습관 Wolt 모달 표시
  // ========================================
  void _showFullHabitBottomSheet() {
    print('📋 [Quick Add] 습관 Wolt 모달 열기');

    // ✅ 먼저 현재 bottom sheet 닫기 (검은 화면 방지!)
    Navigator.of(context).pop();

    // 약간의 딜레이 후 Wolt 모달 열기 (애니메이션 충돌 방지)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      showHabitDetailWoltModal(
        context,
        habit: null, // 새 습관
        selectedDate: widget.selectedDate,
      );
    });
  }

  // ========================================
  // 플레이스홀더 텍스트 반환
  // ========================================
  String _getPlaceholder() {
    // 이거를 설정하고 → 선택된 타입에 따라 플레이스홀더를 반환해서
    // 이거를 해서 → 사용자에게 적절한 안내를 제공한다
    switch (_selectedType) {
      case QuickAddType.schedule:
        return QuickAddConfig.placeholderSchedule; // "予定を追加"
      case QuickAddType.task:
        return QuickAddConfig.placeholderTask; // "やることをパッと入力"
      case QuickAddType.habit:
        return QuickAddConfig.placeholderHabit; // "新しいルーティンを記録"
      default:
        return QuickAddConfig.placeholderDefault; // "まずは一つ、入力してみて"
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔧 [QuickAddControlBox] build() 호출됨!');
    print('🔧 [QuickAddControlBox] _selectedType: $_selectedType');
    print('🔧 [QuickAddControlBox] height: ${_heightAnimation.value}');

    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none, // ✅ 팝업이 박스 밖으로 나갈 수 있도록
          children: [
            // ✅ Figma: Quick_Add_ControlBox (393×192px)
            // Column으로 수직 배치: 입력 박스 → gap 8px → 타입 선택기
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, // ✅ 좌측 정렬 (타입 선택기)
              children: [
                // ✅ 1. 입력 박스 (Figma: Frame 701) - 중앙 배치
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: QuickAddDimensions.frameWidth, // 365px
                    height: _heightAnimation
                        .value, // ✅ 동적 높이 (기본 132px, 일정 196px, 할일 192px)
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: QuickAddDimensions.frameWidth, // 365px
                          height: _heightAnimation.value, // 동적 높이
                          decoration: QuickAddWidgets.frame701Decoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // ✅ 상단: 텍스트 입력만 (Frame 700)
                              _buildTextInputArea(),

                              // ✅ 중단: QuickDetail 옵션 + 버튼 (일정/할일 선택 시 표시)
                              if (_selectedType != null) _buildQuickDetails(),

                              const Spacer(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8), // Figma: gap 8px
                // ✅ 2. 타입 선택기 또는 타입 선택 팝업 (Frame 704 ↔ Frame 705)
                // 追加 버튼 클릭 시 같은 위치에서 Frame 704 → Frame 705로 자연스럽게 전환
                Align(
                  alignment: Alignment.centerRight, // 📍 둘 다 우측 정렬
                  child: _showDetailPopup && _selectedType == null
                      ? _buildTypePopup() // Frame 705: 타입 선택 팝업
                      : _buildTypeSelector(), // Frame 704: 타입 선택기
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// 타입 선택기를 외부로 제공하는 getter
  /// 이거를 설정하고 → 외부(CreateEntryBottomSheet)에서 접근 가능하도록 해서
  /// 이거를 해서 → 같은 레벨에 배치할 수 있다
  Widget getTypeSelector() {
    return QuickAddTypeSelector(
      selectedType: _selectedType,
      onTypeSelected: _onTypeSelected,
    );
  }

  /// ✅ 타입 선택기 (Figma: Frame 704 - 입력 박스 아래에 별도 배치)
  /// 이거를 설정하고 → Frame 701 아래에 gap 8px로 배치해서
  /// 이거를 해서 → Figma 디자인처럼 수직으로 정렬한다
  /// ✅ Figma: Frame 704는 항상 표시됨
  Widget _buildTypeSelector() {
    // Figma: Frame 704 (220×52px)
    // Column 내부에서 중앙 정렬
    return Container(
      width: 220, // Figma: Frame 704 width
      height: 52, // Figma: Frame 704 height
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ), // Figma: padding 0px 4px
      child: QuickAddTypeSelector(
        selectedType: _selectedType,
        onTypeSelected: _onTypeSelected,
      ),
    );
  }

  /// ✅ 타입 선택 팝업 (Figma: Frame 705 - Frame 704와 같은 위치에서 확장)
  /// 이거를 설정하고 → 追加 버튼 클릭 시 Frame 704가 Frame 705로 전환되어
  /// 이거를 해서 → 같은 위치에서 자연스럽게 52px → 172px로 확장된다
  Widget _buildTypePopup() {
    // Figma: Frame 705 (220×172px)
    // Frame 704와 같은 위치, 높이만 확장
    return QuickDetailPopup(
      onScheduleSelected: () {
        print('📋 [QuickDetailPopup] 일정 선택 - 직접 저장');
        _saveDirectSchedule();
        setState(() {
          _showDetailPopup = false; // 팝업 닫기
        });
      },
      onTaskSelected: () {
        print('📋 [QuickDetailPopup] 할일 선택 - 직접 저장');
        _saveDirectTask();
        setState(() {
          _showDetailPopup = false; // 팝업 닫기
        });
      },
      onHabitSelected: () {
        print('📋 [QuickDetailPopup] 습관 선택 - 직접 저장');
        _saveDirectHabit();
        setState(() {
          _showDetailPopup = false; // 팝업 닫기
        });
      },
    );
  }

  /// 텍스트 입력 영역 (Figma: Frame 700)
  /// 이거를 설정하고 → 텍스트 필드만 포함해서
  /// 이거를 해서 → 추가 버튼은 별도로 Positioned로 배치한다
  Widget _buildTextInputArea() {
    return Container(
      width: QuickAddDimensions.frameWidth, // 365px
      height: 52, // Figma: Frame 700 height
      padding: const EdgeInsets.only(top: 30), // Figma: padding 30px 0px 0px
      child: Padding(
        padding: QuickAddSpacing.textAreaPadding, // 좌우 26px
        child: TextField(
          controller: _textController,
          autofocus: true, // 처음에만 키보드 표시
          onTap: () {
            // ✅ 입력박스 탭 시 팝업 닫고 키보드 올림
            if (_showDetailPopup) {
              setState(() {
                _showDetailPopup = false;
              });
            }
          },
          onChanged: (text) {
            setState(() {
              _isAddButtonActive = text.isNotEmpty;
            });
            print('📝 [Quick Add] 텍스트 입력: "$text" → 追加버튼: $_isAddButtonActive');
          },
          style: QuickAddTextStyles.inputText,
          decoration: InputDecoration(
            hintText: _getPlaceholder(),
            hintStyle: QuickAddTextStyles.placeholder,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  /// QuickDetail 옵션 영역 (피그마: Frame 711)
  /// ✅ Figma: 옵션 + 버튼을 같은 Row에 배치
  Widget _buildQuickDetails() {
    return Container(
      width: QuickAddDimensions.frameWidth, // 365px
      height: 80, // Figma: Frame 711 height
      padding: const EdgeInsets.symmetric(horizontal: 18), // 좌우 18px
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ 좌측: 세부 옵션 버튼들
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _selectedType == QuickAddType.schedule
                ? _buildScheduleDetails()
                : _buildTaskDetails(),
          ),

          // ✅ 우측: 추가 버튼
          _buildAddButton(),
        ],
      ),
    );
  }

  /// 일정 QuickDetail 옵션 (피그마: 색상, 시작-종료, 더보기)
  List<Widget> _buildScheduleDetails() {
    return [
      // 1️⃣ 색상 아이콘 (피그마: QuickDetail_color)
      QuickDetailButton(
        icon: Icons.circle,
        showIconOnly: true,
        onTap: () {
          print('🎨 [Quick Add] 색상 버튼 클릭');
          _showColorPicker();
        },
      ),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 2️⃣ 시작-종료 (피그마: QuickDetail_date, "開始-終了")
      QuickDetailButton(
        icon: Icons.access_time,
        text: QuickAddStrings.startEnd, // ✅ "開始-終了"
        onTap: () {
          print('⏰ [Quick Add] 시작-종료 버튼 클릭');
          _showDateTimePicker();
        },
      ),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 3️⃣ 더보기 아이콘 (피그마: QuickDetail_more)
      QuickDetailButton(
        icon: Icons.more_horiz,
        showIconOnly: true,
        onTap: () {
          print('📋 [Quick Add] 더보기 버튼 클릭 → 전체 일정 바텀시트 표시');
          _showFullScheduleBottomSheet();
        },
      ),
    ];
  }

  /// 할일 QuickDetail 옵션 (피그마: 색상, 마감일, 더보기)
  List<Widget> _buildTaskDetails() {
    return [
      // 1️⃣ 색상 아이콘 (피그마: QuickDetail_color)
      QuickDetailButton(
        icon: Icons.circle,
        showIconOnly: true,
        onTap: () {
          print('🎨 [Quick Add] 색상 버튼 클릭');
          _showColorPicker();
        },
      ),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 2️⃣ 마감일 (피그마: QuickDetail_deadline, "締め切り")
      QuickDetailButton(
        icon: Icons.event_outlined,
        text: QuickAddStrings.deadline, // ✅ "締め切り"
        onTap: () {
          print('📆 [Quick Add] 마감일 버튼 클릭');
          _showDateTimePicker();
        },
      ),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 3️⃣ 더보기 아이콘 (피그마: QuickDetail_more)
      QuickDetailButton(
        icon: Icons.more_horiz,
        showIconOnly: true,
        onTap: () {
          print('📋 [Quick Add] 할일 더보기 버튼 클릭 → 전체 할일 바텀시트 표시');
          _showFullTaskBottomSheet();
        },
      ),
    ];
  }

  /// DirectAddButton (Figma: QuickAdd_AddButton_On)
  /// 이거를 설정하고 → 텍스트 + 아이콘 버튼으로 표시해서
  /// 이거를 해서 → Figma 디자인과 정확히 일치시킨다
  Widget _buildAddButton() {
    final hasText = _textController.text.trim().isNotEmpty;
    print('🔘 [_buildAddButton] hasText: $hasText');

    // ✅ Figma 스펙: 타입 선택 시 56×56px, 기본은 86×44px
    final isTypeSelected = _selectedType != null;

    return GestureDetector(
      onTap: hasText ? _handleDirectAdd : null,
      child: Container(
        // ✅ Figma: 타입 선택 후 DirectAddButton 크기 변경
        width: isTypeSelected
            ? QuickAddDimensions.directAddButtonSize
            : QuickAddDimensions.addButtonWidth, // 56px or 86px
        height: isTypeSelected
            ? QuickAddDimensions.directAddButtonSize
            : QuickAddDimensions.addButtonHeight, // 56px or 44px
        padding: isTypeSelected
            ? QuickAddSpacing
                  .directAddButtonPadding // 8px
            : const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ), // 10px 12px
        decoration: BoxDecoration(
          color: hasText
              ? QuickAddColors
                    .addButtonActiveBackground // ✅ Figma: #111111
              : QuickAddColors.addButtonInactiveBackground, // ✅ Figma: #DDDDDD
          borderRadius: BorderRadius.circular(
            QuickAddBorderRadius.addButtonRadius,
          ), // 16px
        ),
        child: isTypeSelected
            ? _buildDirectAddButtonContent() // 타입 선택 시: 화살표만
            : _buildAddButtonContent(hasText), // 기본: 追加 + 화살표
      ),
    );
  }

  /// 기본 추가 버튼 내용 (追加 + ↑)
  Widget _buildAddButtonContent(bool hasText) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Figma: Frame 659 - 텍스트 "追加"
        Padding(
          padding: QuickAddSpacing.addButtonTextPadding, // 좌측 8px
          child: Text(
            QuickAddStrings.addButton, // ✅ Figma: "追加"
            style: QuickAddTextStyles.addButton.copyWith(
              color: hasText
                  ? QuickAddColors
                        .addButtonText // #FAFAFA
                  : const Color(0xFFAAAAAA), // 비활성: 회색
            ),
          ),
        ),
        SizedBox(width: QuickAddSpacing.addButtonGap), // Figma: gap 4px
        // Figma: icon 24×24px (위 화살표)
        Icon(
          Icons.arrow_upward, // 위 화살표 아이콘
          size: QuickAddDimensions.iconSize, // 24px
          color: hasText
              ? QuickAddColors
                    .iconAddButton // #FAFAFA
              : const Color(0xFFAAAAAA), // 비활성: 회색
        ),
      ],
    );
  }

  /// DirectAddButton 내용 (타입 선택 후: ↑만)
  /// Figma: QuickAdd_DirectAddButton (56×56px → 내부 40×40px)
  Widget _buildDirectAddButtonContent() {
    return Container(
      width: QuickAddDimensions.directAddButtonInnerSize, // 40px
      height: QuickAddDimensions.directAddButtonInnerSize, // 40px
      decoration: QuickAddWidgets.directAddButtonDecoration,
      child: Icon(
        Icons.arrow_upward,
        size: QuickAddDimensions.iconSize, // 24px
        color: QuickAddColors.iconAddButton, // #FAFAFA
      ),
    );
  }

  /// DirectAddButton 클릭 처리
  /// 이거를 설정하고 → 追加버튼 클릭 시 직접 저장 처리해서
  /// 이거를 해서 → 타입에 따라 자동으로 데이터를 설정하고 바로 저장한다
  /// 이거는 이래서 → Figma 플로우대로 빠른 입력이 가능하다
  void _handleDirectAdd() async {
    print('\n========================================');
    print('➕ [Quick Add] 追加버튼 클릭');

    final text = _textController.text.trim();
    if (text.isEmpty) {
      print('❌ [Quick Add] 텍스트 없음 - 추가 중단');
      return;
    }

    // ✅ 키보드만 내리기 (팝업/입력박스는 그 자리 고정)
    FocusScope.of(context).unfocus();

    // ✅ Figma: 追加 버튼 클릭 시 타입 선택 팝업 표시
    // Frame 704 (타입 선택기) 위치에 Frame 705 (타입 선택 팝업) 표시
    setState(() {
      _showDetailPopup = true; // 팝업 표시
    });

    print('✅ [Quick Add] 타입 선택 팝업 표시 (키보드만 내림)');
    print('========================================\n');
  }

  // ========================================
  // 직접 일정 저장 (현재시간 반올림 + 1시간)
  // ========================================
  void _saveDirectSchedule() async {
    final title = _textController.text.trim();
    final now = DateTime.now();

    // ✅ Figma 스펙: 현재시간 반올림 (14:34 → 15:00)
    int roundedHour = now.hour;
    if (now.minute > 0) {
      roundedHour += 1; // 분이 있으면 다음 시간으로 반올림
    }

    final startTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      roundedHour,
      0, // 분은 00으로
    );
    final endTime = startTime.add(const Duration(hours: 1)); // +1시간

    widget.onSave?.call({
      'type': QuickAddType.schedule,
      'title': title,
      'colorId': _selectedColorId,
      'startDateTime': startTime,
      'endDateTime': endTime,
      'repeatRule': _repeatRule,
      'reminder': _reminder,
    });

    print('✅ [DirectAdd] 일정 직접 저장: $title');
    print('   → 시작: $startTime (현재시간 반올림)');
    print('   → 종료: $endTime (+1시간)');
  }

  // ========================================
  // 직접 할일 저장 (제목만, 마감기한 없음)
  // ========================================
  void _saveDirectTask() {
    final title = _textController.text.trim();

    widget.onSave?.call({
      'type': QuickAddType.task,
      'title': title,
      'colorId': _selectedColorId,
      'dueDate': null, // ✅ Figma: 마감기한 없이 저장
      'repeatRule': _repeatRule,
      'reminder': _reminder,
    });

    print('✅ [DirectAdd] 할일 직접 저장: $title (마감기한 없음)');
  }

  // ========================================
  // 직접 습관 저장
  // ========================================
  void _saveDirectHabit() {
    final title = _textController.text.trim();

    // ✅ 반복 규칙이 없으면 기본값 설정 (매일)
    final repeatRule = _repeatRule.isEmpty
        ? '{"type":"daily","display":"매일"}'
        : _repeatRule;

    widget.onSave?.call({
      'type': QuickAddType.habit,
      'title': title,
      'colorId': _selectedColorId,
      'repeatRule': repeatRule,
      'reminder': _reminder,
    });

    print('✅ [DirectAdd] 습관 직접 저장: $title');
  }
}
