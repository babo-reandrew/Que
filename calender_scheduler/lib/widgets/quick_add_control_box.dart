import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ✅ SVG 아이콘 사용
import 'package:figma_squircle/figma_squircle.dart'; // ✅ Figma 스무싱 적용
import 'package:provider/provider.dart'; // ✅ Provider 추가
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
import '../../providers/bottom_sheet_controller.dart'; // ✅ BottomSheetController
import '../../utils/temp_input_cache.dart';

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
  final VoidCallback? onAddButtonPressed; // 🔥 추가 버튼 클릭 콜백
  final VoidCallback? onInputFocused; // 🔥 입력 포커스 콜백 (키보드 락 해제)

  const QuickAddControlBox({
    Key? key,
    required this.selectedDate,
    this.onSave,
    this.externalSelectedType, // ✅ 외부 타입
    this.onInputFocused, // 🔥 입력 포커스 콜백
    this.onTypeChanged, // ✅ 타입 변경 알림
    this.onAddButtonPressed, // 🔥 추가 버튼 콜백
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
  final FocusNode _focusNode = FocusNode(); // 🔥 키보드 제어용 FocusNode
  String _selectedColorId = 'gray'; // 선택된 색상 ID
  DateTime? _startDateTime; // 시작 날짜/시간
  DateTime? _endDateTime; // 종료 날짜/시간
  bool _showDetailPopup = false; // ✅ QuickDetailPopup 표시 여부
  bool _isAddButtonActive = false; // ✅ 追加버튼 활성화 상태 (텍스트 입력 시 활성화)
  double _textFieldHeight = 20.0; // ✅ TextField 높이 추적 (개행 감지용)

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

    // ✅ 임시 캐시에서 색상 복원
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreCachedState();
    });

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
    _focusNode.dispose(); // 🔥 FocusNode 해제
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
    double baseHeight;
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

        baseHeight = QuickAddConfig.controlBoxScheduleHeight; // 148px
        print('📅 [Quick Add] 일정 모드로 확장: ${baseHeight}px');
        break;

      case QuickAddType.task:
        baseHeight = QuickAddConfig.controlBoxTaskHeight; // 148px
        print('✅ [Quick Add] 할일 모드로 확장: ${baseHeight}px');
        break;

      case QuickAddType.habit:
        // ✅ 습관은 위에서 이미 처리됨 (모달 표시)
        return;
    }

    // ✅✅✅ TextField 높이 증가분 추가 (개행된 상태 유지)
    final extraHeight = _textFieldHeight > 20 ? (_textFieldHeight - 20) : 0;
    final targetHeight = baseHeight + extraHeight;

    print(
      '📏 [Quick Add] 타입 선택 시 높이: 기본 ${baseHeight}px + TextField ${extraHeight}px = ${targetHeight}px',
    );

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
  // TextField 높이 변화에 따른 전체 높이 업데이트
  // ========================================
  void _updateHeightForTextField() {
    double baseHeight;

    if (_selectedType == null) {
      baseHeight = QuickAddConfig.controlBoxInitialHeight; // 134px
    } else if (_selectedType == QuickAddType.schedule) {
      baseHeight = QuickAddConfig.controlBoxScheduleHeight; // 148px
    } else {
      baseHeight = QuickAddConfig.controlBoxTaskHeight; // 148px
    }

    // ✅ TextField 높이 증가분 추가 (기본 20px 제외)
    final extraHeight = _textFieldHeight > 20 ? (_textFieldHeight - 20) : 0;
    final targetHeight = baseHeight + extraHeight;

    _heightAnimation =
        Tween<double>(begin: _heightAnimation.value, end: targetHeight).animate(
          CurvedAnimation(
            parent: _heightAnimationController,
            curve: QuickAddConfig.heightExpandCurve,
          ),
        );

    _heightAnimationController.forward(from: 0.0);

    print(
      '📏 [Quick Add] TextField 높이 변화: ${_textFieldHeight}px → 전체: ${targetHeight}px',
    );
  }

  // ========================================
  // 색상 ID → Color 변환 헬퍼
  // ========================================
  Color? _getColorFromId(String colorId) {
    switch (colorId) {
      case 'red':
        return const Color(0xFFD22D2D);
      case 'orange':
        return const Color(0xFFF57C00);
      case 'blue':
        return const Color(0xFF1976D2);
      case 'yellow':
        return const Color(0xFFF7BD11);
      case 'green':
        return const Color(0xFF54C8A1);
      case 'gray':
      default:
        return null; // gray는 선택 안 된 상태
    }
  }

  // ========================================
  // 색상 선택 모달 표시 (Figma 2372-26840)
  // ========================================
  void _showColorPicker() async {
    print('🎨 [Quick Add] 색상 선택 모달 열기');

    // 이거를 설정하고 → showModalBottomSheet로 하단에 모달 표시해서
    // 이거를 해서 → 키보드가 내려가고 Wolt ColorPicker가 표시된다
    // 이거는 이래서 → helper 함수로 간결하게 처리된다
    // ✅ await으로 모달이 완전히 닫힐 때까지 대기
    await showWoltColorPicker(context, initialColorId: _selectedColorId);

    // ✅ 모달이 닫힌 후 선택된 색상 가져오기
    // Provider를 통해 선택된 색상 확인
    if (mounted) {
      final controller = Provider.of<BottomSheetController>(
        context,
        listen: false,
      );
      final selectedColor = controller.selectedColor;

      if (selectedColor.isNotEmpty && selectedColor != _selectedColorId) {
        setState(() {
          _selectedColorId = selectedColor;
        });
        print('✅ [Quick Add] 색상 선택됨: $_selectedColorId');

        // ✅ 임시 캐시에 색상 저장
        await TempInputCache.saveTempColor(_selectedColorId);
        print('💾 [Quick Add] 임시 캐시에 색상 저장됨: $_selectedColorId');
      }
    }
  }

  Future<void> _restoreCachedState() async {
    final cachedColor = await TempInputCache.getTempColor();
    if (!mounted || cachedColor == null || cachedColor.isEmpty) {
      return;
    }

    if (cachedColor == _selectedColorId) {
      return;
    }

    setState(() {
      _selectedColorId = cachedColor;
    });

    try {
      context.read<BottomSheetController>().updateColor(cachedColor);
    } catch (e) {
      debugPrint('⚠️ [Quick Add] 임시 색상 복원 중 Provider 업데이트 실패: $e');
    }

    print('✅ [Quick Add] 임시 색상 복원 완료: $_selectedColorId');
  }

  // ========================================
  // 날짜/시간 표시 텍스트 생성
  // ========================================
  String _formatDateTimeRange() {
    if (_startDateTime == null || _endDateTime == null) {
      return QuickAddStrings.startEnd; // "開始-終了"
    }

    // 요일 변환
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final startWeekday = weekdays[_startDateTime!.weekday - 1];
    final endWeekday = weekdays[_endDateTime!.weekday - 1];

    // 포맷: "月.日.要日 時間:分 - 月.日.要日 時間:分"
    final startDate =
        '${_startDateTime!.month}.${_startDateTime!.day}.$startWeekday';
    final startTime =
        '${_startDateTime!.hour.toString().padLeft(2, '0')}:${_startDateTime!.minute.toString().padLeft(2, '0')}';
    final endDate = '${_endDateTime!.month}.${_endDateTime!.day}.$endWeekday';
    final endTime =
        '${_endDateTime!.hour.toString().padLeft(2, '0')}:${_endDateTime!.minute.toString().padLeft(2, '0')}';

    return '$startDate $startTime - $endDate $endTime';
  }

  // ========================================
  // 날짜/시간 선택 모달 표시
  // ========================================
  void _showDateTimePicker() async {
    print('📅 [Quick Add] 일정 선택 모달 열기');

    await showDateTimePickerModal(
      context,
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
                              // ✅ 상단: 텍스트 입력 영역 (Frame 700)
                              _buildTextInputArea(),

                              // ✅ 중단: QuickDetail 옵션 (일정/할일 선택 시만 표시)
                              if (_selectedType != null)
                                _buildQuickDetailOptions(),

                              // ✅✅✅ 남은 공간 채우기 → 追加 버튼을 하단으로 밀어냄
                              if (_selectedType == null) const Spacer(),

                              // ✅ 하단: 追加 버튼 (타입 미선택 시만 표시)
                              if (_selectedType == null) _buildAddButtonArea(),
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
      },
      onTaskSelected: () {
        print('📋 [QuickDetailPopup] 할일 선택 - 직접 저장');
        _saveDirectTask();
      },
      onHabitSelected: () {
        print('📋 [QuickDetailPopup] 습관 선택 - 직접 저장');
        _saveDirectHabit();
      },
    );
  }

  /// 텍스트 입력 영역 (Figma: Frame 700)
  /// 이거를 설정하고 → 텍스트 필드만 포함해서
  /// 이거를 해서 → 추가 버튼은 별도로 Positioned로 배치한다
  Widget _buildTextInputArea() {
    return Padding(
      padding: const EdgeInsets.only(top: 32), // ✅ 위 32px만, 하단 패딩은 외부에서 관리
      child: Padding(
        padding: QuickAddSpacing.textAreaPadding, // 좌우 26px
        child: LayoutBuilder(
          builder: (context, constraints) {
            return TextField(
              controller: _textController,
              focusNode: _focusNode, // 🔥 FocusNode 연결
              autofocus: true, // 🔥 자동 포커스 복원!
              keyboardType: TextInputType.multiline, // ✅ 개행 가능한 기본 키보드
              textInputAction: TextInputAction.newline, // ✅ 엔터 키 → 개행
              maxLines: 2, // ✅✅✅ 최대 2행까지만 입력 가능
              minLines: 1, // ✅ 최소 1행
              onTap: () {
                print('👆 [TextField] onTap 호출!');
                print('   → _showDetailPopup: $_showDetailPopup');

                // 🔥 팝업이 떠있으면 닫고, 키보드 고정 해제!
                if (_showDetailPopup) {
                  setState(() {
                    _showDetailPopup = false;
                  });
                  // 부모에게 "키보드 락 해제" 신호!
                  widget.onInputFocused?.call();
                  print('🔓 [TextField] 팝업 닫음 + 키보드 락 해제!');
                }
              },
              onChanged: (text) {
                print('⌨️ [TextField] onChanged 호출! text: "$text"');
                print('   → _focusNode.hasFocus: ${_focusNode.hasFocus}');

                // ✅✅✅ 2행 초과 입력 방지
                final textPainter = TextPainter(
                  text: TextSpan(
                    text: text,
                    style: QuickAddTextStyles.inputText,
                  ),
                  maxLines: null,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth);

                final lineCount = textPainter.computeLineMetrics().length;

                // 2행 초과 시 → 마지막 입력 취소
                if (lineCount > 2) {
                  final previousText = _textController.text;
                  _textController.text = previousText.substring(
                    0,
                    previousText.length - 1,
                  );
                  _textController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _textController.text.length),
                  );
                  print('⚠️ [Quick Add] 2행 초과 입력 차단!');
                  return;
                }

                setState(() {
                  _isAddButtonActive = text.isNotEmpty;

                  // ✅ TextField 높이 계산 (개행 감지)
                  final newHeight = textPainter.height;
                  if (newHeight != _textFieldHeight) {
                    _textFieldHeight = newHeight;
                    _updateHeightForTextField(); // ✅ 높이 업데이트
                  }
                });
                print(
                  '📝 [Quick Add] 텍스트 입력: "$text" (${lineCount}행) → 追加버튼: $_isAddButtonActive',
                );
              },
              style: QuickAddTextStyles.inputText,
              decoration: InputDecoration(
                hintText: _getPlaceholder(),
                hintStyle: QuickAddTextStyles.placeholder,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            );
          },
        ),
      ),
    );
  }

  /// QuickDetail 옵션 영역만 (피그마: Frame 711 좌측 부분)
  /// ✅ Figma: Frame 711 - 옵션들과 전송 버튼이 Y축 중앙 정렬
  Widget _buildQuickDetailOptions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        0,
      ), // ✅ 좌우 18px, 위 12px, 아래 0px
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 배치
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ Y축 중앙 정렬
        children: [
          // ✅ 좌측: Frame 709 - 세부 옵션 버튼들
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _selectedType == QuickAddType.schedule
                ? _buildScheduleDetails()
                : _buildTaskDetails(),
          ),

          // ✅ 우측: Frame 702 - 전송 버튼 (같은 레벨, Y축 정렬)
          _buildDirectAddButton(),
        ],
      ),
    );
  }

  /// 追加 버튼 영역 (우측 하단 고정)
  /// ✅ Figma: 항상 표시, 텍스트 입력 시 활성화
  Widget _buildAddButtonArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 18, 12), // ✅ 우측 18px, 하단 12px
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [_buildAddButton()],
      ),
    );
  }

  /// 일정 QuickDetail 옵션 (피그마: 색상, 시작-종료, 더보기)
  List<Widget> _buildScheduleDetails() {
    return [
      // 1️⃣ 색상 아이콘 (피그마: QuickDetail_color)
      QuickDetailButton(
        svgPath: 'asset/icon/color_icon.svg', // ✅ SVG 아이콘
        showIconOnly: true,
        selectedColor: _getColorFromId(_selectedColorId), // ✅ 선택된 색상 전달
        onTap: () {
          print('🎨 [Quick Add] 색상 버튼 클릭');
          _showColorPicker();
        },
      ),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 2️⃣ 시작-종료 (피그마: QuickDetail_date, "開始-終了")
      QuickDetailButton(
        svgPath: 'asset/icon/date_icon.svg', // ✅ SVG 아이콘
        text: QuickAddStrings.startEnd, // ✅ "開始-終了"
        onTap: () {
          print('⏰ [Quick Add] 시작-종료 버튼 클릭');
          _showDateTimePicker();
        },
      ),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 3️⃣ 더보기 아이콘 (피그마: QuickDetail_more)
      QuickDetailButton(
        svgPath: 'asset/icon/down_icon.svg',
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
        svgPath: 'asset/icon/color_icon.svg', // ✅ SVG 아이콘
        showIconOnly: true,
        selectedColor: _getColorFromId(_selectedColorId), // ✅ 선택된 색상 전달
        onTap: () {
          print('🎨 [Quick Add] 색상 버튼 클릭');
          _showColorPicker();
        },
      ),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 2️⃣ 마감일 (피그마: QuickDetail_deadline, "締め切り")
      QuickDetailButton(
        svgPath: 'asset/icon/deadline_icon.svg', // ✅ SVG 아이콘
        text: QuickAddStrings.deadline, // ✅ "締め切り"
        onTap: () {
          print('📆 [Quick Add] 마감일 버튼 클릭');
          _showDateTimePicker();
        },
      ),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 3️⃣ 더보기 아이콘 (피그마: QuickDetail_more)
      QuickDetailButton(
        svgPath: 'asset/icon/down_icon.svg',
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
      onTap: _handleDirectAdd, // 🔥 항상 활성화! 내부에서 검증
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
              ), // ✅ Figma 스펙
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

  /// 전송 버튼 (Frame 702 전용)
  /// ✅ Figma: QuickAdd_DirectAddButton (40×40px, radius 16px, smoothing 60%)
  Widget _buildDirectAddButton() {
    final hasText = _textController.text.trim().isNotEmpty;

    return GestureDetector(
      onTap: hasText ? _handleDirectAdd : null,
      child: Container(
        width: 40, // Figma: 40×40px 고정
        height: 40,
        decoration: ShapeDecoration(
          color: hasText
              ? const Color(0xFF111111) // Figma: #111111 (활성)
              : const Color(0xFFDDDDDD), // Figma: #DDDDDD (비활성)
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16, // Figma: radius 16px
              cornerSmoothing: 0.6, // 60% smoothing
            ),
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            'asset/icon/up_icon.svg',
            width: 24, // Figma: icon 24×24px
            height: 24,
            colorFilter: ColorFilter.mode(
              hasText
                  ? const Color(0xFFFAFAFA) // 활성: #FAFAFA
                  : const Color(0xFFAAAAAA), // 비활성: 회색
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  /// DirectAddButton 클릭 처리
  void _handleDirectAdd() {
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('➕ [Quick Add] 추가버튼 클릭!');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final text = _textController.text.trim();
    if (text.isEmpty) {
      print('❌ [Quick Add] 텍스트 없음 - 추가 중단');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return;
    }

    // 🔥 1단계: 즉시 키보드 내리기!
    _focusNode.unfocus();
    print('⌨️ [KEYBOARD] 키보드 즉시 내림!');

    // 🔥 2단계: 팝업 표시
    setState(() {
      _showDetailPopup = true;
    });
    print('✅ [POPUP] 타입 선택 팝업 표시 완료');

    // 🔥 3단계: 부모에게 "키보드 고정해!" 신호 보내기
    if (widget.onAddButtonPressed != null) {
      debugPrint('🔒 [QuickAdd] 키보드 고정 콜백 실행!');
      widget.onAddButtonPressed!();
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
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
