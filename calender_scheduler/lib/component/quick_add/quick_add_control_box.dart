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
import '../modal/deadline_picker_modal.dart'; // ✅ 데드라인 피커 모달
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
  final VoidCallback? onShowTypePopup; // 🔥 팝업 표시 요청 콜백
  final bool showTypePopup; // 🔥 외부에서 팝업 표시 여부 제어
  final VoidCallback? onInputFocused; // 🔥 입력 포커스 콜백 (키보드 락 해제)

  const QuickAddControlBox({
    super.key,
    required this.selectedDate,
    this.onSave,
    this.externalSelectedType, // ✅ 외부 타입
    this.onInputFocused, // 🔥 입력 포커스 콜백
    this.onTypeChanged, // ✅ 타입 변경 알림
    this.onShowTypePopup,
    required this.showTypePopup,
  });

  @override
  State<QuickAddControlBox> createState() => _QuickAddControlBoxState();
}

class _QuickAddControlBoxState extends State<QuickAddControlBox>
    with SingleTickerProviderStateMixin {
  // ========================================
  // 상태 변수
  // ========================================
  QuickAddType? _selectedType; // 선택된 타입 (일정/할일/습관)
  bool _showTypePopup = false; // 🌊 타입 선택 팝업 표시 여부 (내부 상태)
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // 🔥 키보드 제어용 FocusNode
  String _selectedColorId = 'gray'; // 선택된 색상 ID
  DateTime? _startDateTime; // 시작 날짜/시간
  DateTime? _endDateTime; // 종료 날짜/시간
  bool _isAddButtonActive = false; // ✅ 追加버튼 활성화 상태 (텍스트 입력 시 활성화)
  double _textFieldHeight = 20.0; // ✅ TextField 높이 추적 (개행 감지용)

  // ✅ 반복/리마인더 설정은 BottomSheetController에서 가져옴
  // (final 제거 - 사용하지 않음)

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

    // ✅ 임시 캐시에서 색상 복원 + 초기 포커스 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreCachedState();

      // 🔥 초기 포커스를 수동으로 요청 (autofocus 대신)
      if (mounted) {
        _focusNode.requestFocus();
      }
    });

    // 이거를 설정하고 → AnimationController를 초기화해서
    // 이거를 해서 → 높이 확장 애니메이션을 제어한다
    _heightAnimationController = AnimationController(
      vsync: this,
      duration: Duration.zero, // 애니메이션 없이 즉시 전환
    );

    // 이거를 설정하고 → 초기 높이를 설정해서
    // 이거를 해서 → 기본 상태는 140px로 시작한다
    _heightAnimation =
        Tween<double>(
          begin: QuickAddConfig.controlBoxInitialHeight, // 140px
          end: QuickAddConfig.controlBoxInitialHeight,
        ).animate(
          CurvedAnimation(
            parent: _heightAnimationController,
            curve: QuickAddConfig.heightExpandCurve, // Spring curve
          ),
        );
  }

  @override
  void didUpdateWidget(QuickAddControlBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ 외부 타입이 변경되면 내부 상태도 업데이트
    if (widget.externalSelectedType != oldWidget.externalSelectedType) {
      setState(() {
        _selectedType = widget.externalSelectedType;
      });
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
  void _onTypeSelected(QuickAddType type) async {
    // 🎯 타입 전환 시 현재 데이터를 캐시에 저장
    if (_selectedType != null && _selectedType != type) {
      await _saveCacheForCurrentType();
    }

    // ✅ 습관 선택 시 → 바로 모달만 표시 (QuickAdd 상태 변경 없음)
    if (type == QuickAddType.habit) {
      setState(() {
        _showTypePopup = false; // 🌊 팝업 닫기
      });
      _showFullHabitBottomSheet();
      return;
    }

    // ✅ 같은 타입 다시 터치 시 → 기본 상태로 복귀
    if (_selectedType == type) {
      setState(() {
        _selectedType = null;
        _showTypePopup = false; // 🌊 팝업 닫기
      });
      widget.onTypeChanged?.call(null);

      // 높이 축소 애니메이션
      _heightAnimation =
          Tween<double>(
            begin: _heightAnimation.value,
            end: QuickAddConfig.controlBoxInitialHeight, // 140px
          ).animate(
            CurvedAnimation(
              parent: _heightAnimationController,
              curve: QuickAddConfig.heightExpandCurve,
            ),
          );
      _heightAnimationController.forward(from: 0.0);

      return;
    }

    setState(() {
      _selectedType = type;
      _showTypePopup = false; // 🌊 타입 선택 후 팝업 닫기
    });

    // 🎯 새 타입으로 전환 - 캐시에서 데이터 복원
    await _restoreCacheForType(type);

    // ✅ 외부에 타입 변경 알림
    widget.onTypeChanged?.call(type);

    // ✅ Figma 스펙: 타입 선택 시 높이가 확장됨 (하단 고정, 상단이 올라감)
    // 이거를 설정하고 → 선택된 타입에 따라 목표 높이를 설정해서
    // 이거를 해서 → 애니메이션으로 높이를 확장한다
    // 이거는 이래서 → 하단은 키보드 위에 고정되고 상단이 올라간다
    double baseHeight;
    switch (type) {
      case QuickAddType.schedule:
        // ✅ 일정 타입 선택 시 시간을 자동 설정하지 않음
        // 유저가 날짜 선택 바텀시트에서 "완료"를 눌러야만 시간이 설정됨
        // 이거를 해서 → 기본 상태에서는 "開始-終了" 버튼만 표시된다

        baseHeight = QuickAddConfig.controlBoxScheduleHeight; // 140px
        break;

      case QuickAddType.task:
        baseHeight = QuickAddConfig.controlBoxTaskHeight; // 140px
        break;

      case QuickAddType.habit:
        // ✅ 습관은 위에서 이미 처리됨 (모달 표시)
        return;
    }

    // ✅✅✅ TextField 높이 증가분 추가 (개행된 상태 유지)
    final extraHeight = _textFieldHeight > 20 ? (_textFieldHeight - 20) : 0;
    final targetHeight = baseHeight + extraHeight;

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
      baseHeight = QuickAddConfig.controlBoxInitialHeight; // 140px
    } else if (_selectedType == QuickAddType.schedule) {
      baseHeight = QuickAddConfig.controlBoxScheduleHeight; // 140px
    } else {
      baseHeight = QuickAddConfig.controlBoxTaskHeight; // 140px
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
  }

  // ========================================
  // 날짜/시간 표시 텍스트 생성
  // ========================================
  String? _formatDateTimeRange() {
    if (_startDateTime == null || _endDateTime == null) {
      return null;
    }

    // 일본어 요일 매핑
    const weekdayMap = ['月', '火', '水', '木', '金', '土', '日'];

    String formatDateTime(DateTime dt) {
      final weekday = weekdayMap[dt.weekday - 1];
      return '${dt.month}.${dt.day}.$weekday ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return '${formatDateTime(_startDateTime!)} - ${formatDateTime(_endDateTime!)}';
  }

  // ========================================
  // 데드라인 표시 텍스트 생성 (할일용)
  // ========================================
  String? _formatDeadline() {
    if (_startDateTime == null) {
      return null;
    }

    // 일본어 요일 매핑
    const weekdayMap = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdayMap[_startDateTime!.weekday - 1];

    return '${_startDateTime!.month}.${_startDateTime!.day}.$weekday';
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

        // ✅ 임시 캐시에 색상 저장
        await TempInputCache.saveTempColor(_selectedColorId);
      }
    }
  }

  Future<void> _restoreCachedState() async {
    final cachedColor = await TempInputCache.getTempColor();
    final cachedDateTime = await TempInputCache.getTempDateTime();

    if (mounted &&
        cachedColor != null &&
        cachedColor.isNotEmpty &&
        cachedColor != _selectedColorId) {
      setState(() {
        _selectedColorId = cachedColor;
      });

      try {
        context.read<BottomSheetController>().updateColor(cachedColor);
      } catch (e) {
        debugPrint('⚠️ [Quick Add] 임시 색상 복원 중 Provider 업데이트 실패: $e');
      }
    }

    if (mounted && cachedDateTime != null) {
      setState(() {
        _startDateTime = cachedDateTime['start'];
        _endDateTime = cachedDateTime['end'];
      });
    }
  }

  // ========================================
  // 🎯 통합 캐시 시스템: 현재 타입의 데이터 저장
  // ========================================
  Future<void> _saveCacheForCurrentType() async {
    if (_selectedType == null) return;

    final currentTitle = _textController.text.trim();
    final controller = context.read<BottomSheetController>();

    // 공통 데이터 저장
    await TempInputCache.saveCommonData(
      title: currentTitle.isNotEmpty ? currentTitle : null,
      colorId: _selectedColorId,
      reminder: controller.reminder.isNotEmpty ? controller.reminder : null,
      repeatRule: controller.repeatRule.isNotEmpty
          ? controller.repeatRule
          : null,
    );

    // 타입별 개별 데이터 저장
    if (_selectedType == QuickAddType.schedule) {
      if (_startDateTime != null && _endDateTime != null) {
        await TempInputCache.saveScheduleData(
          startDateTime: _startDateTime,
          endDateTime: _endDateTime,
          isAllDay: false, // Quick Add에서는 종일 없음
        );
      }
      await TempInputCache.saveCurrentType('schedule');
    } else if (_selectedType == QuickAddType.task) {
      if (_startDateTime != null) {
        await TempInputCache.saveTaskData(
          dueDate: _startDateTime,
          executionDate: null, // Quick Add에서는 실행일 없음
        );
      }
      await TempInputCache.saveCurrentType('task');
    }
  }

  // ========================================
  // 🎯 통합 캐시 시스템: 특정 타입의 데이터 복원
  // ========================================
  Future<void> _restoreCacheForType(QuickAddType type) async {
    // 공통 데이터 복원
    final commonData = await TempInputCache.getCommonData();

    if (mounted) {
      // 제목 복원
      if (commonData['title'] != null && commonData['title']!.isNotEmpty) {
        _textController.text = commonData['title']!;
        setState(() {
          _isAddButtonActive = true;
        });
      }

      // 색상 복원
      if (commonData['colorId'] != null && commonData['colorId']!.isNotEmpty) {
        setState(() {
          _selectedColorId = commonData['colorId']!;
        });
        try {
          context.read<BottomSheetController>().updateColor(
            commonData['colorId']!,
          );
        } catch (e) {
          debugPrint('⚠️ [UnifiedCache] 색상 복원 중 오류: $e');
        }
      }

      // 리마인더 복원
      if (commonData['reminder'] != null &&
          commonData['reminder']!.isNotEmpty) {
        try {
          context.read<BottomSheetController>().updateReminder(
            commonData['reminder']!,
          );
        } catch (e) {
          debugPrint('⚠️ [UnifiedCache] 리마인더 복원 중 오류: $e');
        }
      }

      // 반복규칙 복원
      if (commonData['repeatRule'] != null &&
          commonData['repeatRule']!.isNotEmpty) {
        try {
          context.read<BottomSheetController>().updateRepeatRule(
            commonData['repeatRule']!,
          );
        } catch (e) {
          debugPrint('⚠️ [UnifiedCache] 반복규칙 복원 중 오류: $e');
        }
      }

      // 타입별 개별 데이터 복원
      if (type == QuickAddType.schedule) {
        final scheduleData = await TempInputCache.getScheduleData();
        if (scheduleData != null) {
          setState(() {
            _startDateTime = scheduleData['startDateTime'] as DateTime?;
            _endDateTime = scheduleData['endDateTime'] as DateTime?;
          });
        }
      } else if (type == QuickAddType.task) {
        final taskData = await TempInputCache.getTaskData();
        if (taskData != null && taskData['dueDate'] != null) {
          setState(() {
            _startDateTime = taskData['dueDate'];
          });
        }
      }
    }
  }

  // ========================================
  // 날짜/시간 선택 모달 표시 (일정용)
  // ========================================
  void _showDateTimePicker() async {
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
      },
    );
  }

  // ========================================
  // 데드라인 선택 모달 표시 (할일용)
  // ========================================
  void _showDeadlinePicker() async {
    await showDeadlinePickerModal(
      context,
      initialDeadline: _startDateTime ?? widget.selectedDate,
      onDeadlineSelected: (deadline) {
        setState(() {
          _startDateTime = deadline;
        });
      },
    );
  }

  // ========================================
  // 전체 일정 Wolt 모달 표시
  // ========================================
  void _showFullScheduleBottomSheet() async {
    final currentTitle = _textController.text.trim();
    final controller = context.read<BottomSheetController>();

    // 🎯 통합 캐시에 공통 데이터 저장
    await TempInputCache.saveCommonData(
      title: currentTitle.isNotEmpty ? currentTitle : null,
      colorId: _selectedColorId,
      reminder: controller.reminder.isNotEmpty ? controller.reminder : null,
      repeatRule: controller.repeatRule.isNotEmpty
          ? controller.repeatRule
          : null,
    );

    // 🎯 통합 캐시에 일정 전용 데이터 저장
    if (_startDateTime != null && _endDateTime != null) {
      await TempInputCache.saveScheduleData(
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
        isAllDay: false,
      );
    }

    await TempInputCache.saveCurrentType('schedule');

    // 🔥 일정 모달을 먼저 열고, 그 다음에 QuickAdd 닫기 (검은 화면 방지!)
    if (!mounted) return;

    showScheduleDetailWoltModal(
      context,
      schedule: null, // 새 일정 생성
      selectedDate: widget.selectedDate,
    ).then((_) {
      // 일정 모달이 닫힌 후 QuickAdd도 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  // ========================================
  // 전체 할일 Wolt 모달 표시
  // ========================================
  void _showFullTaskBottomSheet() async {
    final currentTitle = _textController.text.trim();
    final controller = context.read<BottomSheetController>();

    // 🎯 통합 캐시에 공통 데이터 저장
    await TempInputCache.saveCommonData(
      title: currentTitle.isNotEmpty ? currentTitle : null,
      colorId: _selectedColorId,
      reminder: controller.reminder.isNotEmpty ? controller.reminder : null,
      repeatRule: controller.repeatRule.isNotEmpty
          ? controller.repeatRule
          : null,
    );

    // 🎯 통합 캐시에 할일 전용 데이터 저장
    if (_startDateTime != null) {
      await TempInputCache.saveTaskData(
        dueDate: _startDateTime,
        executionDate: null, // Quick Add에서는 실행일 없음
      );
    }

    await TempInputCache.saveCurrentType('task');

    // 🔥 할일 모달을 먼저 열고, 그 다음에 QuickAdd 닫기 (검은 화면 방지!)
    if (!mounted) return;

    showTaskDetailWoltModal(
      context,
      task: null,
      selectedDate: widget.selectedDate,
    ).then((_) {
      // 할일 모달이 닫힌 후 QuickAdd도 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  // ========================================
  // 전체 습관 Wolt 모달 표시
  // ========================================
  void _showFullHabitBottomSheet() async {
    final currentTitle = _textController.text.trim();
    final controller = context.read<BottomSheetController>();

    // 🎯 통합 캐시에 공통 데이터 저장
    await TempInputCache.saveCommonData(
      title: currentTitle.isNotEmpty ? currentTitle : null,
      colorId: _selectedColorId,
      reminder: controller.reminder.isNotEmpty ? controller.reminder : null,
      repeatRule: controller.repeatRule.isNotEmpty
          ? controller.repeatRule
          : null,
    );

    await TempInputCache.saveCurrentType('habit');

    // 🔥 습관 모달을 먼저 열고, 그 다음에 QuickAdd 닫기 (검은 화면 방지!)
    // 습관 모달이 열리면서 자연스럽게 화면 전환
    if (!mounted) return;

    // 습관 모달 열기 (await 사용하여 모달이 완전히 열릴 때까지 대기)
    showHabitDetailWoltModal(
      context,
      habit: null, // 새 습관
      selectedDate: widget.selectedDate,
    ).then((_) {
      // 습관 모달이 닫힌 후 QuickAdd도 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }
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
                    width: QuickAddDimensions.getFrameWidth(
                      context,
                    ), // 🔥 동적 너비 (화면너비 - 28px)
                    height: _heightAnimation
                        .value, // ✅ 동적 높이 (기본 132px, 일정 196px, 할일 192px)
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: QuickAddDimensions.getFrameWidth(
                            context,
                          ), // 🔥 동적 너비
                          height: _heightAnimation.value, // 동적 높이
                          decoration: QuickAddWidgets.frame701Decoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // ✅ 상단 24px 고정 여백
                              const SizedBox(height: 24),

                              // ✅ 상단: 텍스트 입력 영역 (Frame 700)
                              _buildTextInputArea(),

                              // ✅ 남은 공간을 채워서 하단 버튼을 아래로 밀어냄
                              const Spacer(),

                              // ✅ 중단: QuickDetail 옵션 (일정/할일 선택 시만 표시) - 부드러운 기본 애니메이션
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: _selectedType != null
                                    ? KeyedSubtree(
                                        key: const ValueKey(
                                          'quickDetailOptions',
                                        ),
                                        child: _buildQuickDetailOptions(),
                                      )
                                    : KeyedSubtree(
                                        key: const ValueKey('addButtonArea'),
                                        child: _buildAddButtonArea(),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8), // Figma: gap 8px
                // ✅ 2. 타입 선택기 또는 타입 선택 팝업 (Frame 704 ↔ Frame 705)
                // 🌊 유기적 모핑 애니메이션 - 하나의 Container가 형태 변화
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    // 🎯 팝업이 닫혀있고 타입이 선택되지 않았을 때만 팝업 열기
                    onTap: () {
                      if (!_showTypePopup && _selectedType == null) {
                        setState(() {
                          _showTypePopup = true;
                        });
                      }
                    },
                    child: AnimatedContainer(
                      // 🎯 핵심: 업계 최고 수준의 유기적 곡선 (Apple-style easing)
                      duration: const Duration(milliseconds: 550),
                      curve: Curves.easeInOutCubicEmphasized,

                      // 📏 크기 변화 (52px ↔ 172px)
                      width: 220, // 고정 너비
                      height: _showTypePopup && _selectedType == null
                          ? 172
                          : 52,

                      // 🎨 패딩 변화 (부드러운 내용물 전환)
                      padding: const EdgeInsets.symmetric(horizontal: 4),

                      // 🌈 데코레이션 변화 (그림자, 테두리, 배경)
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        border: Border.all(
                          color: const Color(0xFF111111).withOpacity(0.1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          _showTypePopup && _selectedType == null ? 24 : 34,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFBABABA).withOpacity(0.08),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),

                      // 🔄 내용물 전환 (매우 부드러운 Fade 애니메이션)
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        transitionBuilder: (child, animation) {
                          // 🌊 크로스페이드: 기존 컨텐츠 fade out + 새 컨텐츠 fade in
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: _showTypePopup && _selectedType == null
                            ? _buildTypePopupContent()
                            : _buildTypeSelectorContent(),
                      ),
                    ),
                  ),
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

  /// 🌊 타입 선택기 내용 (Container 내부용)
  Widget _buildTypeSelectorContent() {
    return Container(
      key: const ValueKey('typeSelector'),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: QuickAddTypeSelector(
        selectedType: _selectedType,
        onTypeSelected: _onTypeSelected,
      ),
    );
  }

  /// 🌊 타입 선택 팝업 내용 (Container 내부용)
  Widget _buildTypePopupContent() {
    return Container(
      key: const ValueKey('typePopup'),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: QuickDetailPopup(
        onScheduleSelected: () {
          _onTypeSelected(QuickAddType.schedule);
        },
        onTaskSelected: () {
          _onTypeSelected(QuickAddType.task);
        },
        onHabitSelected: () {
          _onTypeSelected(QuickAddType.habit);
        },
      ),
    );
  }

  /// 텍스트 입력 영역 (Figma: Frame 700)
  /// 이거를 설정하고 → 텍스트 필드만 포함해서
  /// 이거를 해서 → 추가 버튼은 별도로 Positioned로 배치한다
  Widget _buildTextInputArea() {
    return Padding(
      padding: QuickAddSpacing.textAreaPadding, // 좌우 26px
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TextField(
            key: const ValueKey('quick_add_text_field'), // 🔥 상태 보존용 key 추가!
            controller: _textController,
            focusNode: _focusNode, // 🔥 FocusNode 연결
            autofocus: false, // 🔥 autofocus 제거 (깜빡임 방지)
            keyboardType: TextInputType.multiline, // ✅ 개행 가능한 기본 키보드
            textInputAction: TextInputAction.newline, // ✅ 엔터 키 → 개행
            maxLines: 2, // ✅✅✅ 최대 2행까지만 입력 가능
            minLines: 1, // ✅ 최소 1행
            onTap: () {
              // 🔥 팝업이 떠있으면 닫고, 키보드 고정 해제!
              if (widget.showTypePopup) {
                // 부모에게 "키보드 락 해제" 신호!
                widget.onInputFocused?.call();
              }
            },
            onChanged: (text) {
              // ✅✅✅ 2행 초과 입력 방지
              final textPainter = TextPainter(
                text: TextSpan(text: text, style: QuickAddTextStyles.inputText),
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
    );
  }

  /// QuickDetail 옵션 영역만 (피그마: Frame 711 좌측 부분)
  /// ✅ Figma: Frame 711 - 옵션들과 전송 버튼이 Y축 중앙 정렬
  Widget _buildQuickDetailOptions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        20,
      ), // ✅ 좌우 18px, 위 0px, 아래 20px
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
      padding: const EdgeInsets.fromLTRB(0, 0, 18, 18), // ✅ 우측 18px, 하단 18px
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [_buildAddButton()],
      ),
    );
  }

  /// 날짜/시간 버튼 (선택 시 텍스트 표시, 미선택 시 아이콘+텍스트)
  Widget _buildDateTimeButton() {
    final dateTimeText = _formatDateTimeRange();

    if (dateTimeText != null) {
      // 날짜/시간이 선택된 경우: 텍스트만 표시 (자동 스크롤 + 그라데이션)
      return GestureDetector(
        onTap: () {
          _showDateTimePicker();
        },
        child: _DateTimeAutoScrollText(text: dateTimeText),
      );
    } else {
      // 날짜/시간이 선택되지 않은 경우: 기본 버튼 표시
      final isSchedule = _selectedType == QuickAddType.schedule;
      return QuickDetailButton(
        svgPath: isSchedule
            ? 'asset/icon/date_icon.svg'
            : 'asset/icon/deadline_icon.svg',
        text: isSchedule ? QuickAddStrings.startEnd : QuickAddStrings.deadline,
        onTap: () {
          _showDateTimePicker();
        },
      );
    }
  }

  /// 데드라인 버튼 (할일용 - 선택 시 날짜 표시)
  Widget _buildDeadlineButton() {
    final deadlineText = _formatDeadline();

    if (deadlineText != null) {
      // 데드라인이 선택된 경우: 날짜 텍스트 표시 (14px bold)
      return GestureDetector(
        onTap: () {
          _showDeadlinePicker();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'asset/icon/deadline_icon.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF7A7A7A),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                deadlineText,
                style: const TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontSize: 14, // ✅ 14px
                  fontWeight: FontWeight.w700, // ✅ Bold
                  height: 1.4,
                  letterSpacing: -0.005 * 14,
                  color: Color(0xFF7A7A7A),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // 데드라인이 선택되지 않은 경우: 기본 버튼 표시
      return QuickDetailButton(
        svgPath: 'asset/icon/deadline_icon.svg',
        text: QuickAddStrings.deadline,
        onTap: () {
          _showDeadlinePicker();
        },
      );
    }
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
          _showColorPicker();
        },
      ),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 2️⃣ 시작-종료 (피그마: QuickDetail_date, "開始-終了")
      _buildDateTimeButton(),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 3️⃣ 더보기 아이콘 (피그마: QuickDetail_more) - 위아래 반전
      Transform.flip(
        flipY: true, // ✅ 상하 반전
        child: QuickDetailButton(
          svgPath: 'asset/icon/down_icon.svg',
          showIconOnly: true,
          onTap: () {
            _showFullScheduleBottomSheet();
          },
        ),
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
          _showColorPicker();
        },
      ),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 2️⃣ 마감일 (피그마: QuickDetail_deadline, "締め切り")
      _buildDeadlineButton(),

      SizedBox(width: QuickAddSpacing.detailButtonsGap), // 6px
      // 3️⃣ 더보기 아이콘 (피그마: QuickDetail_more) - 위아래 반전
      Transform.flip(
        flipY: true, // ✅ 상하 반전
        child: QuickDetailButton(
          svgPath: 'asset/icon/down_icon.svg',
          showIconOnly: true,
          onTap: () {
            _showFullTaskBottomSheet();
          },
        ),
      ),
    ];
  }

  /// DirectAddButton (Figma: QuickAdd_AddButton_On)
  /// 이거를 설정하고 → 텍스트 + 아이콘 버튼으로 표시해서
  /// 이거를 해서 → Figma 디자인과 정확히 일치시킨다
  Widget _buildAddButton() {
    final hasText = _textController.text.trim().isNotEmpty;

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
        decoration: ShapeDecoration(
          color: hasText
              ? const Color(0xFF111111) // 텍스트 있으면 #111111
              : const Color(0xFFDDDDDD), // 텍스트 없으면 #DDDDDD
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16, // Figma: radius 16px
              cornerSmoothing: 0.6, // 60% smoothing
            ),
          ),
        ),
        child: isTypeSelected
            ? _buildDirectAddButtonContent() // 타입 선택 시: 화살표만
            : _buildAddButtonContent(hasText), // 기본: 追加 + 화살표
      ),
    );
  }

  /// 기본 추가 버튼 내용 (追加 + ↑)
  Widget _buildAddButtonContent(bool hasText) {
    final textColor = hasText
        ? const Color(0xFFFAFAFA) // 텍스트 있으면 #FAFAFA
        : const Color(0xFFAAAAAA); // 텍스트 없으면 #AAAAAA

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Figma: Frame 659 - 텍스트 "追加"
        Padding(
          padding: const EdgeInsets.only(left: 8), // 좌측 8px
          child: Text(
            QuickAddStrings.addButton, // ✅ Figma: "追加"
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 13, // Figma: 13px
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005 * 13,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(width: 4), // Figma: gap 4px
        // Figma: icon 24×24px (위 화살표)
        Icon(
          Icons.arrow_upward, // 위 화살표 아이콘
          size: 24, // Figma: 24px
          color: textColor,
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

  /// DirectAddButton 클릭 처리 (타입별 분기)
  void _handleDirectAdd() {
    final text = _textController.text.trim();

    // 🔥 "追加↑" 버튼의 핵심 동작:
    // 1. 팝업이 떠있는 상태에서 누르면: 키보드만 내리고 현재 UI를 고정한다.
    if (widget.showTypePopup) {
      _focusNode.unfocus(); // 키보드만 내린다.
      // onInputFocused를 호출하지 않음으로써, 부모의 isKeyboardLocked 상태를 true로 유지.
      // -> QuickAddKeyboardTracker가 UI 위치를 현재 상단 위치에 고정시킨다.
      return;
    }

    // 2. 텍스트가 없는 상태에서 누르면: 타입 선택 팝업을 띄운다.
    if (text.isEmpty) {
      if (_selectedType == null) {
        widget.onShowTypePopup?.call();
      }
      return;
    }

    // 3. 텍스트가 있는 상태에서 누르면:
    _focusNode.unfocus(); // 일단 키보드를 내린다.

    // 3a. 타입이 아직 선택되지 않았다면: 타입 선택 팝업을 띄운다.
    if (_selectedType == null) {
      widget.onShowTypePopup?.call();
      return;
    }

    // 3b. 타입이 선택되었다면: 해당 타입으로 데이터를 저장한다.
    switch (_selectedType!) {
      case QuickAddType.schedule:
        _saveDirectSchedule();
        break;
      case QuickAddType.task:
        _saveDirectTask();
        break;
      case QuickAddType.habit:
        // 습관은 이 경로로 저장되지 않음.
        break;
    }
  }

  // ========================================
  // 직접 일정 저장 (시간 자동 설정 or 사용자 선택)
  // ========================================
  void _saveDirectSchedule() async {
    final title = _textController.text.trim();
    final now = DateTime.now();

    DateTime startTime;
    DateTime endTime;

    // ✅ 사용자가 시간을 선택했으면 그대로 사용
    if (_startDateTime != null && _endDateTime != null) {
      startTime = _startDateTime!;
      endTime = _endDateTime!;
    } else {
      // ✅ 시간을 선택하지 않았으면 현재시간 반올림 (14:34 → 15:00)
      int roundedHour = now.hour;
      if (now.minute > 0) {
        roundedHour += 1; // 분이 있으면 다음 시간으로 반올림
      }

      startTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        roundedHour.clamp(0, 23), // 🔥 시간이 24를 넘지 않도록 보정
        0, // 분은 00으로
      );
      endTime = startTime.add(const Duration(hours: 1)); // +1시간
    }

    // 🔥 1단계: 키보드 즉시 내리기
    _focusNode.unfocus();

    // 🔥 BottomSheetController에서 반복/알림 가져오기
    final controller = context.read<BottomSheetController>();
    final repeatRule = controller.repeatRule;
    final reminder = controller.reminder;

    // 🔥 디버그 로그: 전달할 데이터 확인
    debugPrint('📤 [QuickAddControl] 일정 데이터 전달');
    debugPrint('   - 제목: $title');
    debugPrint('   - 색상: $_selectedColorId');
    debugPrint('   - 시작: $startTime');
    debugPrint('   - 종료: $endTime');
    debugPrint('   - 반복: ${repeatRule.isEmpty ? "(없음)" : repeatRule}');
    debugPrint('   - 알림: ${reminder.isEmpty ? "(없음)" : reminder}');

    // 🔥 2단계: 저장 콜백 호출 (부모가 바텀시트를 닫고 토스트 표시)
    widget.onSave?.call({
      'type': QuickAddType.schedule,
      'title': title,
      'colorId': _selectedColorId,
      'startDateTime': startTime,
      'endDateTime': endTime,
      'repeatRule': repeatRule,
      'reminder': reminder,
    });
  }

  // ========================================
  // 직접 할일 저장 (제목만, 마감기한 선택사항)
  // ========================================
  void _saveDirectTask() {
    final title = _textController.text.trim();

    // 🔥 1단계: 키보드 즉시 내리기
    _focusNode.unfocus();

    // 🔥 BottomSheetController에서 반복/알림 가져오기
    final controller = context.read<BottomSheetController>();
    final repeatRule = controller.repeatRule;
    final reminder = controller.reminder;

    // 🔥 디버그 로그: 전달할 데이터 확인
    debugPrint('📤 [QuickAddControl] 할일 데이터 전달');
    debugPrint('   - 제목: $title');
    debugPrint('   - 색상: $_selectedColorId');
    debugPrint('   - 마감일: ${_startDateTime ?? "(없음)"}');
    debugPrint('   - 반복: ${repeatRule.isEmpty ? "(없음)" : repeatRule}');
    debugPrint('   - 알림: ${reminder.isEmpty ? "(없음)" : reminder}');

    // 🔥 2단계: 저장 콜백 호출 (부모가 바텀시트를 닫고 토스트 표시)
    widget.onSave?.call({
      'type': QuickAddType.task,
      'title': title,
      'colorId': _selectedColorId,
      'dueDate': _startDateTime, // ✅ 사용자가 선택한 마감일 (없을 수도 있음)
      'repeatRule': repeatRule,
      'reminder': reminder,
    });
  }

  // ========================================
  // ✅ 습관은 타입 선택 시 즉시 모달 표시 (직접 저장 없음)
  // ========================================
  // _saveDirectHabit() 함수 제거됨
  // → _onTypeSelected(QuickAddType.habit)에서 _showFullHabitBottomSheet() 호출
}

/// 자동 스크롤되는 날짜/시간 텍스트 위젯
class _DateTimeAutoScrollText extends StatefulWidget {
  final String text;

  const _DateTimeAutoScrollText({required this.text});

  @override
  State<_DateTimeAutoScrollText> createState() =>
      _DateTimeAutoScrollTextState();
}

class _DateTimeAutoScrollTextState extends State<_DateTimeAutoScrollText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // 위젯이 빌드된 후 스크롤 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;

    // 텍스트가 너비를 초과하는 경우에만 스크롤
    if (maxScroll > 0 && !_isScrolling) {
      _isScrolling = true;

      while (mounted && _isScrolling) {
        // 오른쪽으로 스크롤 (5초)
        await _scrollController.animateTo(
          maxScroll,
          duration: const Duration(seconds: 5),
          curve: Curves.linear,
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted || !_isScrolling) break;

        // 왼쪽으로 스크롤 (5초)
        await _scrollController.animateTo(
          0,
          duration: const Duration(seconds: 5),
          curve: Curves.linear,
        );

        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      constraints: const BoxConstraints(maxWidth: 120), // 최대 너비 120px
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: const [0.0, 0.1, 0.9, 1.0], // 양끝 10% 그라데이션
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(), // 수동 스크롤 비활성화
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Center(
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
