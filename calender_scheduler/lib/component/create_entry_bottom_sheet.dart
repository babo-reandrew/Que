import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // ✅ ImageFilter for backdrop blur
import 'package:provider/provider.dart';
import '../const/color.dart';
import '../const/quick_add_config.dart';
import '../component/custom_fille_field.dart';
import '../utils/validators/event_validators.dart';
import '../utils/validators/entity_validators.dart'; // ✅ Task/Habit 검증 추가
import '../utils/color_utils.dart';
import '../utils/temp_input_cache.dart'; // ✅ 캐시 저장 추가
import '../utils/input_accessory_manager.dart'; // 🔥 QuickAddKeyboardTracker
import '../Database/schedule_database.dart';
import 'package:get_it/get_it.dart';
import 'quick_add/quick_add_control_box.dart';
import 'package:drift/drift.dart' hide Column;
import '../providers/bottom_sheet_controller.dart';
import '../design_system/wolt_typography.dart'; // ✅ WoltTypography 사용
import '../design_system/wolt_helpers.dart'; // ✅ Wolt helper functions

/// CreateEntryBottomSheet - Quick_Add 시스템 통합 버전
/// 이거를 설정하고 → 기존 기능을 모두 보존하면서 새 컴포넌트를 조합해서
/// 이거를 해서 → 피그마 디자인의 Quick_Add 플로우를 구현한다
/// 이거는 이래서 → 일정/할일/습관을 하나의 UI에서 입력할 수 있다
/// 이거라면 → 기존 검증, 저장 로직이 그대로 동작한다
class CreateEntryBottomSheet extends StatefulWidget {
  final DateTime selectedDate;

  const CreateEntryBottomSheet({super.key, required this.selectedDate});

  @override
  State<CreateEntryBottomSheet> createState() => _CreateEntryBottomSheetState();
}

class _CreateEntryBottomSheetState extends State<CreateEntryBottomSheet>
    with SingleTickerProviderStateMixin {
  // ========================================
  // ✅ 기존 상태 변수 (최소화 - description/location 제거)
  // ========================================
  final _formKey = GlobalKey<FormState>();
  String? _title;
  bool _isAllDay = false;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // ========================================
  // ✅ Quick_Add 상태 변수 (새로 추가)
  // ========================================
  final bool _useQuickAdd = true; // ✅ Quick Add 모드 활성화! (피그마 디자인 적용)
  final TextEditingController _quickAddController = TextEditingController();
  QuickAddType? _selectedQuickAddType; // ✅ 외부에서 관리하는 타입 상태
  bool _isKeyboardLocked = false; // 🔥 키보드 고정 상태

  // ========================================
  // ✅ 습관 입력 전용 상태 변수 (새로 추가)
  // ========================================
  final TextEditingController _habitTitleController =
      TextEditingController(); // 습관 제목 입력 컨트롤러

  @override
  void initState() {
    super.initState();

    // 🔥 키보드 락 초기화 (매번 바텀시트 열 때 false로 시작!)
    _isKeyboardLocked = false;

    // 🔥 타입 선택기 초기화 (매번 바텀시트 열 때 null로 시작!)
    _selectedQuickAddType = null;

    print('🎬 [CreateEntry] 바텀시트 초기화 완료');
  }

  @override
  void dispose() {
    // 이거를 설정하고 → 바텀시트가 닫힐 때 임시 입력을 캐시에 저장해서
    // 이거를 해서 → 사용자가 입력만 하고 닫아도 데이터를 보존한다
    // 이거는 이래서 → Figma 디자인(2447-60096)의 캐시 저장 기능을 구현한다
    final tempText = _quickAddController.text.trim();
    if (tempText.isNotEmpty) {
      // 이거라면 → 입력된 텍스트가 있으면 캐시에 저장한다
      TempInputCache.saveTempInput(tempText);
      print('💾 [CreateEntry] dispose 시 캐시 저장: "$tempText"');
    }

    if (_useQuickAdd) {
      try {
        final controller = context.read<BottomSheetController>();
        final selectedColorId = controller.selectedColor;
        if (selectedColorId.isNotEmpty) {
          TempInputCache.saveTempColor(selectedColorId);
          debugPrint('💾 [CreateEntry] dispose 시 색상 캐시 저장: "$selectedColorId"');
        }
      } catch (e) {
        debugPrint('⚠️ [CreateEntry] dispose 색상 캐시 저장 실패: $e');
      }
    }

    _quickAddController.dispose();
    _habitTitleController.dispose(); // ✅ 습관 컨트롤러 해제
    super.dispose();
  }

  // ========================================
  // ✅ Quick Add 저장 함수 (새로 추가)
  // ========================================

  /// Quick Add에서 빠른 저장 처리
  /// 이거를 설정하고 → Quick Add에서 입력된 데이터를 받아서
  /// 이거를 해서 → 간소화된 검증 후 DB에 저장한다
  void _saveQuickAdd(Map<String, dynamic> data) async {
    print('\n========================================');
    print('⚡ [Quick Add 저장] 빠른 저장 프로세스 시작');

    try {
      final type = data['type'] as QuickAddType;
      final title = data['title'] as String;
      final colorId = data['colorId'] as String;

      if (type == QuickAddType.schedule) {
        // 일정 저장
        final startDateTime = data['startDateTime'] as DateTime;
        final endDateTime = data['endDateTime'] as DateTime;
        final repeatRule = data['repeatRule'] as String? ?? '';
        final reminder = data['reminder'] as String? ?? '';

        final companion = ScheduleCompanion.insert(
          start: startDateTime,
          end: endDateTime,
          summary: title,
          // ✅ description, location 제거 (기본값 '' 자동 적용)
          colorId: colorId,
          repeatRule: repeatRule.isNotEmpty
              ? Value(repeatRule)
              : const Value.absent(), // ✅ 반복 규칙: 사용자가 설정한 경우에만 저장
          alertSetting: reminder.isNotEmpty
              ? Value(reminder)
              : const Value.absent(), // ✅ 리마인더: 사용자가 설정한 경우에만 저장
        );

        final database = GetIt.I<AppDatabase>();
        final id = await database.createSchedule(companion);

        print('✅ [Quick Add 저장] 일정 저장 완료! ID: $id');
        print('   → 제목: $title');
        print('   → 시작: $startDateTime');
        print('   → 종료: $endDateTime');
        print('   → 반복: ${repeatRule.isEmpty ? "(미설정)" : repeatRule}');
        print('   → 리마인더: ${reminder.isEmpty ? "(미설정)" : reminder}');
      } else if (type == QuickAddType.task) {
        // ========================================
        // 할일 저장
        // ========================================
        final dueDate = data['dueDate'] as DateTime?;
        final repeatRule = data['repeatRule'] as String? ?? '';
        final reminder = data['reminder'] as String? ?? '';

        // 1. 검증
        final validationResult = EntityValidators.validateCompleteTask(
          title: title,
          dueDate: dueDate,
          colorId: colorId,
        );

        EntityValidators.printValidationResult(validationResult, '할일');

        if (!validationResult['isValid']) {
          print('❌ [Quick Add 저장] 할일 검증 실패 - 저장 중단');
          print('========================================\n');
          return;
        }

        // 2. DB 저장
        final companion = TaskCompanion.insert(
          title: title,
          createdAt: DateTime.now(),
          colorId: Value(colorId),
          completed: const Value(false),
          dueDate: Value(dueDate),
          listId: const Value('inbox'),
          repeatRule: Value(repeatRule), // ✅ 반복 규칙 포함
          reminder: Value(reminder), // ✅ 리마인더 포함
        );

        final database = GetIt.I<AppDatabase>();
        final id = await database.createTask(companion);

        print('✅ [Quick Add 저장] 할일 저장 완료! ID: $id');
        print('   → 제목: $title');
        print('   → 마감일: ${dueDate ?? "(없음)"}');
        print('   → 색상: $colorId');
      } else if (type == QuickAddType.habit) {
        // ========================================
        // 습관 저장
        // ========================================
        final repeatRule =
            data['repeatRule'] as String? ?? ''; // ✅ 기본값 강제 설정 제거
        final reminder = data['reminder'] as String? ?? '';

        // 1. 검증
        final validationResult = EntityValidators.validateCompleteHabit(
          title: title,
          repeatRule: repeatRule,
          colorId: colorId,
        );

        EntityValidators.printValidationResult(validationResult, '습관');

        if (!validationResult['isValid']) {
          print('❌ [Quick Add 저장] 습관 검증 실패 - 저장 중단');
          print('========================================\n');
          return;
        }

        // 2. DB 저장
        final companion = HabitCompanion.insert(
          title: title,
          createdAt: DateTime.now(),
          repeatRule: repeatRule,
          colorId: Value(colorId),
          reminder: Value(reminder), // ✅ 리마인더 포함
        );

        final database = GetIt.I<AppDatabase>();
        final id = await database.createHabit(companion);

        print('✅ [Quick Add 저장] 습관 저장 완료! ID: $id');
        print('   → 제목: $title');
        print('   → 반복: $repeatRule');
        print('   → 색상: $colorId');
      }

      // 이거를 설정하고 → 저장이 성공했으므로 임시 캐시를 삭제해서
      // 이거를 해서 → 하단 박스가 사라지도록 한다
      // 이거는 이래서 → Figma 디자인대로 저장 후 임시 데이터를 정리한다
      await TempInputCache.clearTempInput();
      print('🗑️ [Quick Add 저장] 임시 캐시 삭제 완료');

      if (context.mounted) {
        Navigator.of(context).pop();
        print('🔙 [UI] 바텀시트 닫기 → StreamBuilder 자동 갱신');
      }

      print('========================================\n');
    } catch (e, stackTrace) {
      print('❌ [Quick Add 저장] 에러 발생: $e');
      print('스택 트레이스: $stackTrace');
      print('========================================\n');
    }
  }

  // ========================================
  // ✅ 기존 폼 저장 함수 (모두 보존)
  // ========================================

  /// 폼 검증과 스케줄 저장을 처리하는 함수
  /// 이거를 설정하고 → 폼을 검증해서 유효성을 확인하고
  /// 이거를 해서 → DB에 일정을 저장한 뒤
  /// 이거는 이래서 → 바텀시트를 닫으면 StreamBuilder가 자동으로 UI를 갱신한다
  void _saveSchedule(BuildContext context) async {
    final controller = Provider.of<BottomSheetController>(
      context,
      listen: false,
    );

    print('\n========================================');
    print('💾 [저장] 일정 저장 프로세스 시작');

    // 1. 먼저 기본 폼 검증을 수행한다 (각 필드의 validator 실행)
    if (!(_formKey.currentState?.validate() ?? false)) {
      // 기본 검증이 실패하면 여기서 중단한다
      print('❌ [검증] 기본 폼 검증 실패 - 저장 중단');
      print('========================================\n');
      return;
    }
    print('✅ [검증] 기본 폼 검증 통과');

    // 2. 폼이 유효하면 저장을 실행한다 (각 필드의 onSaved 실행)
    _formKey.currentState?.save();
    print('✅ [검증] 폼 데이터 저장 완료 (_title 등)');

    // 3. ⭐️ 종일/시간별에 따라 다른 DateTime 사용
    // 이거를 설정하고 → _isAllDay 플래그로 종일/시간별을 구분해서
    // 이거를 해서 → 종일이면 00:00:00 ~ 23:59:59, 시간별이면 정확한 DateTime 사용
    // 이거는 이래서 → DB에 올바른 형식으로 저장된다
    final DateTime startDateTime;
    final DateTime endDateTime;

    print('💾 [저장] 종일 여부: $_isAllDay');

    if (_isAllDay) {
      // 종일: 선택된 날짜의 00:00:00 ~ 23:59:59
      startDateTime =
          _selectedStartDate ??
          DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
          );
      endDateTime =
          _selectedEndDate ??
          DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
            23,
            59,
            59,
          );
      print('⏰ [종일] 시작: $startDateTime');
      print('⏰ [종일] 종료: $endDateTime');
    } else {
      // 시간별: 피커에서 선택한 정확한 DateTime
      startDateTime = _selectedStartDate ?? widget.selectedDate;
      endDateTime =
          _selectedEndDate ?? widget.selectedDate.add(Duration(hours: 1));
      print('⏰ [시간별] 시작: $startDateTime');
      print('⏰ [시간별] 종료: $endDateTime');
    }

    print('💾 [저장] 최종 시작: $startDateTime');
    print('💾 [저장] 최종 종료: $endDateTime');

    // 4. 종합 검증을 수행한다 - 모든 필드와 논리적 일관성을 종합적으로 검증한다
    final validationResult = EventValidators.validateCompleteEvent(
      title: _title,
      description: '', // ✅ description 제거됨 (빈 문자열)
      location: '', // ✅ location 제거됨 (빈 문자열)
      startTime: startDateTime,
      endTime: endDateTime,
      colorId: controller.selectedColor,
      existingEvents: [],
      importantEvents: [],
      allowPastEvents: true,
    );

    // 5. 검증 결과를 디버깅 출력한다
    EventValidators.printValidationResult(validationResult);

    // 6. 검증이 실패하면 에러를 표시하고 중단한다
    if (!validationResult.isValid) {
      if (context.mounted) {
        _showValidationErrors(context, validationResult.errors);
      }
      print('❌ [검증] 종합 검증 실패 - 저장 중단');
      print('========================================\n');
      return;
    }
    print('✅ [검증] 종합 검증 통과');

    // 7. 경고가 있으면 사용자에게 확인을 받는다
    if (validationResult.hasWarnings) {
      final shouldContinue = await _showWarningsDialog(
        context,
        validationResult.warnings,
      );
      if (shouldContinue != true) {
        print('⚠️ [검증] 사용자가 경고 확인 후 저장을 취소했습니다');
        print('========================================\n');
        return;
      }
      print('✅ [검증] 경고 확인 후 계속 진행');
    }

    // 8. ScheduleCompanion 객체를 생성한다
    // 이거를 설정하고 → 폼 데이터를 ScheduleCompanion.insert()로 변환해서
    // 이거를 해서 → Drift가 필요한 형식으로 준비한다
    try {
      final companion = ScheduleCompanion.insert(
        start: startDateTime,
        end: endDateTime,
        summary: _title ?? '제목 없음',
        // ✅ description, location 제거 (기본값 '' 자동 적용)
        colorId: controller.selectedColor,
        repeatRule: controller.repeatRule.isNotEmpty
            ? Value(controller.repeatRule)
            : const Value.absent(), // ✅ 반복 규칙: 사용자가 설정한 경우에만 저장
        alertSetting: controller.reminder.isNotEmpty
            ? Value(controller.reminder)
            : const Value.absent(), // ✅ 리마인더: 사용자가 설정한 경우에만 저장
      );

      print('📦 [데이터] ScheduleCompanion 생성 완료:');
      print('   → 제목: ${_title ?? "제목 없음"}');
      print('   → 시작: $startDateTime');
      print('   → 종료: $endDateTime');
      print('   → 색상: ${controller.selectedColor}');
      print('   → 종일: $_isAllDay');
      print(
        '   → 반복: ${controller.repeatRule.isEmpty ? "(미설정)" : controller.repeatRule}',
      );
      print(
        '   → 리마인더: ${controller.reminder.isEmpty ? "(미설정)" : controller.reminder}',
      );

      // 9. DB에 저장한다
      // 이거는 이래서 → createSchedule()이 완료되면 DB 스트림이 자동으로 갱신된다
      // 이거라면 → StreamBuilder가 감지해서 UI를 자동으로 업데이트한다
      final database = GetIt.I<AppDatabase>();
      final id = await database.createSchedule(companion);

      print('✅ [DB] 일정 저장 완료! 생성된 ID: $id');

      // 10. 바텀시트를 닫는다
      // 이거를 설정하고 → Navigator.pop()으로 바텀시트를 닫으면
      // 이거를 해서 → StreamBuilder가 자동으로 새로운 데이터를 감지한다
      if (context.mounted) {
        Navigator.of(context).pop();
        print('🔙 [UI] 바텀시트 닫기 → StreamBuilder 자동 갱신 대기 중');
      }

      print('========================================\n');
    } catch (e, stackTrace) {
      print('❌ [DB] 저장 중 에러 발생: $e');
      print('스택 트레이스: $stackTrace');
      print('========================================\n');

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')));
      }
    }
  }

  /// 검증 에러를 표시하는 함수 - 사용자에게 구체적인 에러 메시지를 다이얼로그로 표시한다
  void _showValidationErrors(BuildContext context, Map<String, String> errors) {
    // 1. 에러가 없으면 표시하지 않는다
    if (errors.isEmpty) return;

    // 2. 에러 메시지를 리스트 형태로 구성한다
    final errorMessages = errors.entries
        .map((entry) {
          // 필드명을 사용자 친화적으로 변환한다
          final fieldName = _getFieldDisplayName(entry.key);
          return '• $fieldName: ${entry.value}';
        })
        .join('\n');

    // 3. 에러 다이얼로그를 표시한다
    showDialog(
      context: context, // 현재 컨텍스트를 사용한다
      builder: (context) => AlertDialog(
        // 에러 다이얼로그를 구성한다
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red), // 에러 아이콘을 표시한다
            SizedBox(width: 8),
            Text('입력 오류', style: TextStyle(color: Colors.red)), // 제목을 표시한다
          ],
        ),
        content: SingleChildScrollView(
          // 스크롤 가능하게 만든다 (에러가 많을 경우 대비)
          child: Text(
            errorMessages, // 에러 메시지를 표시한다
            style: TextStyle(fontSize: 14, color: gray900),
          ),
        ),
        actions: [
          // 확인 버튼을 추가한다
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // 다이얼로그를 닫는다
            child: Text('확인', style: TextStyle(color: gray1000)),
          ),
        ],
      ),
    );
  }

  /// 검증 경고를 표시하는 함수 - 사용자에게 경고를 표시하고 계속 진행할지 확인한다
  Future<bool?> _showWarningsDialog(
    BuildContext context,
    List<String> warnings,
  ) async {
    // 1. 경고가 없으면 표시하지 않는다
    if (warnings.isEmpty) return true;

    // 2. 경고 메시지를 리스트 형태로 구성한다
    final warningMessages = warnings.map((warning) => '• $warning').join('\n');

    // 3. 경고 다이얼로그를 표시하고 사용자의 선택을 기다린다
    return await showDialog<bool>(
      context: context, // 현재 컨텍스트를 사용한다
      builder: (context) => AlertDialog(
        // 경고 다이얼로그를 구성한다
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange), // 경고 아이콘을 표시한다
            SizedBox(width: 8),
            Text('주의사항', style: TextStyle(color: Colors.orange)), // 제목을 표시한다
          ],
        ),
        content: SingleChildScrollView(
          // 스크롤 가능하게 만든다 (경고가 많을 경우 대비)
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞춘다
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                warningMessages, // 경고 메시지를 표시한다
                style: TextStyle(fontSize: 14, color: gray900),
              ),
              SizedBox(height: 16),
              Text(
                '그래도 계속 진행하시겠습니까?', // 확인 질문을 표시한다
                style: TextStyle(
                  fontSize: 13,
                  color: gray700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // 취소 버튼을 추가한다
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false), // false를 반환하고 다이얼로그를 닫는다
            child: Text('취소', style: TextStyle(color: gray600)),
          ),
          // 계속 버튼을 추가한다
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(true), // true를 반환하고 다이얼로그를 닫는다
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, // 경고 색상으로 설정한다
            ),
            child: Text('계속 진행', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 필드명을 사용자 친화적인 이름으로 변환하는 헬퍼 함수
  String _getFieldDisplayName(String fieldKey) {
    // 필드 키를 한글 이름으로 매핑한다
    const fieldNames = {
      'title': '제목',
      'startTime': '시작 시간',
      'endTime': '종료 시간',
      'description': '설명',
      'location': '위치',
      'timeOrder': '시간 순서',
      'duration': '일정 시간',
      'timezone': '타임존',
      'allDay': '종일 이벤트',
      'recurrence': '반복 설정',
      'priority': '우선순위',
      'colorId': '색상',
      'status': '상태',
      'visibility': '공개 설정',
      'pastTime': '시간 설정',
      'conflict': '일정 충돌',
    };

    return fieldNames[fieldKey] ?? fieldKey; // 매핑된 이름이 없으면 키를 그대로 반환한다
  }

  // ========================================
  // ✅ Quick Add용 간소화 저장 함수 (새로 추가)
  // ========================================

  /// Quick Add 모드에서 사용하는 저장 함수
  /// 이거를 설정하고 → Quick Add에서 받은 데이터를 바로 저장해서
  /// 이거를 해서 → 빠른 입력 UX를 제공한다
  void _handleQuickAddSave(Map<String, dynamic> data) {
    _saveQuickAdd(data);
  }

  @override
  Widget build(BuildContext context) {
    print('🎯 [CreateEntryBottomSheet] _useQuickAdd: $_useQuickAdd');
    print('🔒 [CreateEntryBottomSheet] _isKeyboardLocked: $_isKeyboardLocked');

    // ✅✅✅ ULTRATHINK: Quick Add 모드
    if (_useQuickAdd) {
      print('✅ [CreateEntryBottomSheet] Quick Add 모드');

      // 🔥 핵심: LayoutBuilder로 정확한 위치 계산하여 blur 영역 제한
      return Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

            // Input Accessory 예상 높이 (SafeArea bottom + padding + QuickAddControlBox 기본 높이)
            final safeAreaBottom = MediaQuery.of(context).padding.bottom;
            final inputAccessoryHeight = safeAreaBottom + 8.0 + 60.0; // 대략적인 높이

            // Input Accessory가 시작되는 Y 좌표 (위에서부터)
            final inputAccessoryTop = screenHeight - keyboardHeight - inputAccessoryHeight;

            print('📐 [Blur] screenHeight: $screenHeight');
            print('📐 [Blur] keyboardHeight: $keyboardHeight');
            print('📐 [Blur] inputAccessoryTop: $inputAccessoryTop');
            print('📐 [Blur] blur 영역: $inputAccessoryTop ~ $screenHeight');

            return Stack(
              children: [
                // 1️⃣ 커스텀 Barrier - 빈 공간 터치 시 닫기
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      if (!_isKeyboardLocked) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),

                // 2️⃣ Blur + Gradient - Input Accessory 상단부터 화면 하단까지만 (Positioned로 정확히 제한)
                Positioned(
                  left: 0,
                  right: 0,
                  top: inputAccessoryTop, // 🔥 Input Accessory 상단부터 시작
                  bottom: 0,              // 🔥 화면 하단까지
                  child: IgnorePointer(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 4.0, // Figma 스펙: 4px blur
                        sigmaY: 4.0,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x00FFFFFF), // 상단: 완전 투명
                              Color(0xF2F0F0F0), // 하단: 95% 불투명 (Figma 스펙)
                            ],
                            stops: [0.0, 0.5], // Figma: 0%, 50%
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3️⃣ Input Accessory 컨텐츠
                QuickAddKeyboardTracker(
                  isLocked: _isKeyboardLocked,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: QuickAddControlBox(
                          selectedDate: widget.selectedDate,
                          onSave: _handleQuickAddSave,
                          externalSelectedType: _selectedQuickAddType,
                          onTypeChanged: (type) {
                            setState(() {
                              _selectedQuickAddType = type;
                            });
                            print('📋 [타입 변경] $type');
                          },
                          onAddButtonPressed: () {
                            setState(() {
                              _isKeyboardLocked = true;
                            });
                            debugPrint(
                              '🔒 [CreateEntry] 키보드 고정! isLocked: $_isKeyboardLocked',
                            );
                          },
                          onInputFocused: () {
                            setState(() {
                              _isKeyboardLocked = false;
                            });
                            debugPrint(
                              '🔓 [CreateEntry] 키보드 락 해제! isLocked: $_isKeyboardLocked',
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // ✅ 레거시 폼 모드
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(height: 500, child: _buildLegacyFormMode()),
      ),
    );
  }

  /// ✅ 습관 입력 전용 UI (Figma 디자인 완전 재현)
  /// 이거를 설정하고 → Figma DetailPopup 디자인을 정확히 구현해서
  /// 이거를 해서 → 습관 입력에 특화된 UI를 제공한다
  /// 이거는 이래서 → 모든 색상, 여백, 폰트가 Figma와 완전히 동일하다
  Widget _buildHabitInputMode() {
    return Container(
      // ✅ Figma: DetailPopup 전체 컨테이너
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC), // 피그마: #fcfcfc (연한 회색 배경)
        border: Border.all(
          color: const Color(
            0xFF111111,
          ).withOpacity(0.1), // 피그마: rgba(17,17,17,0.1)
          width: 1,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36), // 피그마: 상단 좌측 36px
          topRight: Radius.circular(36), // 피그마: 상단 우측 36px
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ 상단 헤더 (TopNavi)
          _buildHabitHeader(),

          const SizedBox(height: 12), // 피그마: gap 12px
          // ✅ 메인 콘텐츠 영역
          Expanded(
            child: Column(
              children: [
                // ✅ 서브타이틀 영역
                _buildHabitSubtitle(),

                const SizedBox(height: 24), // 피그마: gap 24px
                // ✅ 3개 옵션 아이콘 영역
                _buildHabitOptions(),

                const SizedBox(height: 48), // 피그마: gap 48px
                // ✅ 삭제 버튼 영역
                _buildHabitDeleteSection(),

                // ✅ 하단 여백 (키보드 공간 확보)
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 습관 입력 헤더 (피그마: TopNavi)
  /// 좌측: "習慣" 제목, 우측: 완료 버튼
  Widget _buildHabitHeader() {
    return Container(
      // 피그마: TopNavi 패딩
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ 좌측: "習慣" 제목
          Text(
            '習慣', // 피그마: "習慣" 텍스트
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 16, // 피그마: 16px
              fontWeight: FontWeight.w700, // 피그마: Bold
              color: Color(0xFF505050), // 피그마: #505050 (중간 회색)
              letterSpacing: -0.08, // 피그마: -0.08px
              height: 1.4, // 피그마: leading 1.4
            ),
          ),

          // ✅ 우측: 완료 버튼 (바텀시트 닫기)
          GestureDetector(
            onTap: () {
              // X 버튼은 바텀시트를 닫는 역할
              Navigator.of(context).pop();
              print('❌ [습관 UI] X 버튼으로 바텀시트 닫기');
            },
            child: Container(
              padding: const EdgeInsets.all(8), // 피그마: p-[8px]
              decoration: BoxDecoration(
                color: const Color(
                  0xFFE4E4E4,
                ).withOpacity(0.9), // 피그마: rgba(228,228,228,0.9)
                border: Border.all(
                  color: const Color(
                    0xFF111111,
                  ).withOpacity(0.02), // 피그마: rgba(17,17,17,0.02)
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(
                  100,
                ), // 피그마: rounded-[100px] (완전 원형)
              ),
              child: const Icon(
                Icons.close, // X 아이콘
                size: 20, // 피그마: size-[20px]
                color: Color(0xFF111111), // 피그마: 검은색
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 습관 입력 필드 (피그마: DetailView_Title)
  /// 이거를 설정하고 → "新しいルーティンを記録" 부분을 실제 입력 필드로 구현해서
  /// 이거를 해서 → 사용자가 직접 습관 이름을 입력할 수 있도록 한다
  Widget _buildHabitSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ), // 피그마: px-0 py-[12px] + px-[24px]
      width: double.infinity,
      child: TextField(
        controller: _habitTitleController,
        decoration: InputDecoration(
          hintText: '新しいルーティンを記録', // 피그마: 플레이스홀더 텍스트
          hintStyle: WoltTypography.placeholder, // ✅ 디자인 시스템 적용
          border: InputBorder.none, // 테두리 없음 (Figma 디자인과 동일)
          contentPadding: EdgeInsets.zero, // 패딩 없음
        ),
        style: WoltTypography.mainTitle, // ✅ 디자인 시스템 적용
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _saveHabitFromInput(), // 엔터 키로 저장
      ),
    );
  }

  /// ✅ 습관 옵션 아이콘들 (피그마: DetailOption/Box)
  Widget _buildHabitOptions() {
    // ✅ 키보드 높이 감지
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final hasKeyboard = keyboardHeight > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24), // 피그마: px-[24px]
      child: Row(
        // ✅ 키보드 상태에 따른 정렬 조정
        mainAxisAlignment: hasKeyboard
            ? MainAxisAlignment
                  .center // 키보드 있음: 중앙 정렬
            : MainAxisAlignment.start, // 키보드 없음: 좌측 정렬
        children: [
          // ✅ 첫 번째 옵션 (반복 아이콘)
          _buildHabitOptionIcon(
            icon: Icons.refresh,
            onTap: _showRepeatOptionModal,
          ),

          const SizedBox(width: 8), // 피그마: gap-[8px]
          // ✅ 두 번째 옵션 (알림 아이콘)
          _buildHabitOptionIcon(
            icon: Icons.notifications_outlined,
            onTap: _showReminderOptionModal,
          ),

          const SizedBox(width: 8), // 피그마: gap-[8px]
          // ✅ 세 번째 옵션 (색상 아이콘)
          _buildHabitOptionIcon(
            icon: Icons.palette_outlined,
            onTap: _showColorOptionModal,
          ),
        ],
      ),
    );
  }

  /// ✅ 개별 옵션 아이콘 박스 (피그마: DetailOption)
  Widget _buildHabitOptionIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64, // 피그마: size-[64px]
        height: 64, // 피그마: size-[64px]
        padding: const EdgeInsets.all(20), // 피그마: p-[20px]
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7), // 피그마: #f7f7f7 (연한 회색 배경)
          border: Border.all(
            color: const Color(
              0xFF111111,
            ).withOpacity(0.08), // 피그마: rgba(17,17,17,0.08)
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24), // 피그마: rounded-[24px]
        ),
        child: Icon(
          icon,
          size: 24, // 피그마: size-[24px]
          color: const Color(0xFF111111), // 피그마: rgba(17,17,17,1) (검은색)
        ),
      ),
    );
  }

  /// ✅ 반복 설정 모달 표시
  void _showRepeatOptionModal() {
    final controller = Provider.of<BottomSheetController>(
      context,
      listen: false,
    );
    showWoltRepeatOption(context, initialRepeatRule: controller.repeatRule);
  }

  /// ✅ 리마인더 설정 모달 표시
  void _showReminderOptionModal() {
    final controller = Provider.of<BottomSheetController>(
      context,
      listen: false,
    );
    showWoltReminderOption(context, initialReminder: controller.reminder);
  }

  /// ✅ 색상 설정 모달 표시 (커스텀 색상 선택기)
  void _showColorOptionModal() {
    final controller = Provider.of<BottomSheetController>(
      context,
      listen: false,
    );
    showWoltColorPicker(context, initialColorId: controller.selectedColor);
  }

  /// ✅ 습관 삭제 섹션 (피그마: 하단 삭제 영역)
  Widget _buildHabitDeleteSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24), // 피그마: px-[24px]
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ), // 피그마: px-[24px] py-[16px]
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7), // 피그마: #f7f7f7 (연한 회색 배경)
          border: Border.all(
            color: const Color(
              0xFFBABABA,
            ).withOpacity(0.08), // 피그마: rgba(186,186,186,0.08)
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16), // 피그마: rounded-[16px]
        ),
        child: Row(
          children: [
            // ✅ 삭제 아이콘
            const Icon(
              Icons.delete_outline,
              size: 20, // 피그마: size-[20px]
              color: Color(0xFFF74A4A), // 피그마: #f74a4a (빨간색)
            ),

            const SizedBox(width: 6), // 피그마: gap-[6px]
            // ✅ 삭제 텍스트
            const Text(
              '削除', // 피그마: "削除" 텍스트
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 13, // 피그마: 13px
                fontWeight: FontWeight.w700, // 피그마: Bold
                color: Color(0xFFF74A4A), // 피그마: #f74a4a (빨간색)
                letterSpacing: -0.065, // 피그마: -0.065px
                height: 1.4, // 피그마: leading 1.4
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ 습관 저장 함수 (입력 필드에서 호출)
  /// 이거를 설정하고 → 텍스트 필드의 내용을 습관으로 저장해서
  /// 이거를 해서 → 기존 습관 저장 로직을 재사용한다
  void _saveHabitFromInput() {
    final controller = Provider.of<BottomSheetController>(
      context,
      listen: false,
    );
    final title = _habitTitleController.text.trim();

    if (title.isEmpty) {
      print('⚠️ [습관 저장] 제목이 비어있어서 저장하지 않음');
      return;
    }

    // ✅ 사용자가 설정한 값만 사용 (기본값 강제 설정 제거)
    final repeatRule = controller.repeatRule;

    // 기존 Quick Add 저장 로직 재사용
    final habitData = {
      'type': QuickAddType.habit,
      'title': title,
      'colorId': controller.selectedColor,
      'repeatRule': repeatRule, // ✅ 반복 규칙 포함
      'reminder': controller.reminder, // ✅ 리마인더 포함
    };

    print('💾 [습관 저장] 입력 필드에서 저장 시작: $title');
    print('   → 반복: ${repeatRule.isEmpty ? "(미설정)" : repeatRule}');
    print('   → 리마인더: ${controller.reminder}');
    _saveQuickAdd(habitData);
  }

  /// ✅ 기존 폼 모드 UI (완전 보존)
  /// 이거를 설정하고 → 기존 UI를 그대로 유지해서
  /// 이거를 해서 → 기존 기능이 정상 동작한다
  Widget _buildLegacyFormMode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomFillField(
              label: '제목',
              onSaved: (String? value) {
                _title = value;
                print('📝 제목 필드 onSaved 실행:');
                print('  - 입력값: ${value ?? "null"}');
                print('  - _title 변수에 저장됨: ${_title ?? "null"}');
                print('  - 저장 성공: ${_title != null ? "✅" : "❌"}');
              },
              validator: (String? value) {
                return EventValidators.validateTitle(value);
              },
            ),
            SizedBox(height: 8),

            // ⭐️ 종일 토글 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '종일',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: gray1000,
                  ),
                ),
                CupertinoSwitch(
                  value: _isAllDay,
                  onChanged: (value) {
                    setState(() {
                      _isAllDay = value;
                    });
                    print('🔄 [토글] 종일: $_isAllDay');
                  },
                ),
              ],
            ),
            SizedBox(height: 8),

            // 조건부 렌더링: 종일 vs 시간별
            if (_isAllDay)
              _AllDayDatePicker(
                selectedDate: widget.selectedDate,
                onStartDateSelected: (date) {
                  setState(() {
                    _selectedStartDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                    );
                  });
                  print('📅 [종일] 시작 날짜: $_selectedStartDate');
                },
                onEndDateSelected: (date) {
                  setState(() {
                    _selectedEndDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      23,
                      59,
                      59,
                    );
                  });
                  print('📅 [종일] 종료 날짜: $_selectedEndDate');
                },
              )
            else
              _TimeDatePicker(
                selectedDate: widget.selectedDate,
                onStartDateTimeSelected: (dateTime) {
                  setState(() {
                    _selectedStartDate = dateTime;
                  });
                  print('📅 [시간별] 시작: $_selectedStartDate');
                },
                onEndDateTimeSelected: (dateTime) {
                  setState(() {
                    _selectedEndDate = dateTime;
                  });
                  print('📅 [시간별] 종료: $_selectedEndDate');
                },
              ),

            SizedBox(height: 8),
            Consumer<BottomSheetController>(
              builder: (context, controller, child) => _Category(
                selectedColor: controller.selectedColor,
                onTap: (String color) {
                  print('🎨 색상 선택됨: $color');
                  controller.updateColor(color);
                  print('✅ 상태 업데이트 완료: selectedColor = $color');
                },
              ),
            ),
            SizedBox(height: 8),
            _Save(),
          ],
        ),
      ),
    );
  }
}

// ========================================
// ✅ 기존 헬퍼 위젯들 (완전 보존)
// ========================================

/// 아무것도 반환하지 않는 함수인데, 파라미터에다가 우리가 선택한 색상을 넣을 것이다.
typedef OnColorSelected = void Function(String color);

class _Category extends StatelessWidget {
  final OnColorSelected
  onTap; //이거 원래 voidcallback인데, 이거를 해당 함수로 변환을 하였다. 타입데트형식의
  final String selectedColor;
  const _Category({required this.selectedColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: categoryColors.map((color) {
        // 1. Color 객체를 문자열로 변환한다 (예: categoryRed -> 'red')
        final colorName = ColorUtils.colorToString(color);

        // 2. 현재 색상이 선택된 색상인지 확인한다
        final isSelected = colorName == selectedColor;

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              // 3. 색상을 클릭하면 문자열로 변환된 색상 이름을 전달한다
              print('👆 색상 클릭: $colorName (원본: $color)'); // 디버깅: 클릭된 색상 정보 출력
              onTap(colorName); // 'red', 'blue' 같은 문자열을 전달한다
            },

            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color, // 실제 Color 객체로 색상을 표시한다
                shape: BoxShape.circle,
                border: Border.all(
                  // 4. 선택된 색상이면 테두리를 표시하고, 아니면 투명하게 한다
                  color: isSelected ? gray1000 : Colors.transparent,
                  width: 2,
                ),
              ),
              width: 24,
              height: 24,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ⭐️ 종일 날짜 피커 위젯
// 이거를 설정하고 → CupertinoDatePicker를 date 모드로 표시해서
// 이거를 해서 → 애플 스타일 스크롤 휠로 (연도)-월-일 선택하고
// 이거는 이래서 → 종일 일정은 00:00:00 ~ 23:59:59로 저장된다
class _AllDayDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onStartDateSelected;
  final Function(DateTime) onEndDateSelected;

  const _AllDayDatePicker({
    required this.selectedDate,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DatePickerField(
          label: '시작 날짜',
          selectedDate: selectedDate,
          onDateSelected: onStartDateSelected,
        ),
        SizedBox(height: 8),
        _DatePickerField(
          label: '종료 날짜',
          selectedDate: selectedDate,
          onDateSelected: onEndDateSelected,
        ),
      ],
    );
  }
}

// ⭐️ 시간별 날짜/시간 피커 위젯
// 이거를 설정하고 → CupertinoDatePicker를 dateAndTime 모드로 표시해서
// 이거를 해서 → (연-월-일)-시간-분을 15분 단위로 선택하고
// 이거는 이래서 → 정확한 DateTime 객체로 DB에 저장된다
class _TimeDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onStartDateTimeSelected;
  final Function(DateTime) onEndDateTimeSelected;

  const _TimeDatePicker({
    required this.selectedDate,
    required this.onStartDateTimeSelected,
    required this.onEndDateTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DateTimePickerField(
          label: '시작',
          selectedDateTime: selectedDate,
          onDateTimeSelected: onStartDateTimeSelected,
        ),
        SizedBox(height: 8),
        _DateTimePickerField(
          label: '종료',
          selectedDateTime: selectedDate.add(Duration(hours: 1)),
          onDateTimeSelected: onEndDateTimeSelected,
        ),
      ],
    );
  }
}

// 날짜 선택 필드 (종일용)
class _DatePickerField extends StatefulWidget {
  final String label;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<_DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<_DatePickerField> {
  late DateTime _tempDate;

  @override
  void initState() {
    super.initState();
    _tempDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: gray050,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: gray300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(fontSize: 12, color: gray600),
                ),
                SizedBox(height: 4),
                Text(
                  '${_tempDate.year}년 ${_tempDate.month}월 ${_tempDate.day}일',
                  style: TextStyle(fontSize: 16, color: gray1000),
                ),
              ],
            ),
            Icon(Icons.calendar_today, color: gray600),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    DateTime tempSelectedDate = _tempDate;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            // 헤더
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: gray100,
                border: Border(bottom: BorderSide(color: gray300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      print('❌ [피커] 날짜 선택 취소');
                      Navigator.pop(context);
                    },
                    child: Text('취소', style: TextStyle(color: Colors.blue)),
                  ),
                  Text(
                    widget.label,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        _tempDate = tempSelectedDate;
                      });
                      widget.onDateSelected(tempSelectedDate);
                      print('📅 [피커] 날짜 선택 완료: $tempSelectedDate');
                      Navigator.pop(context);
                    },
                    child: Text(
                      '완료',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 피커
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _tempDate,
                onDateTimeChanged: (date) {
                  tempSelectedDate = date;
                  print('📅 [피커] 날짜 변경: $date');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 날짜+시간 선택 필드 (시간별용)
class _DateTimePickerField extends StatefulWidget {
  final String label;
  final DateTime selectedDateTime;
  final Function(DateTime) onDateTimeSelected;

  const _DateTimePickerField({
    required this.label,
    required this.selectedDateTime,
    required this.onDateTimeSelected,
  });

  @override
  State<_DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<_DateTimePickerField> {
  late DateTime _tempDateTime;

  @override
  void initState() {
    super.initState();
    _tempDateTime = widget.selectedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDateTimePicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: gray050,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: gray300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(fontSize: 12, color: gray600),
                ),
                SizedBox(height: 4),
                Text(
                  '${_tempDateTime.year}년 ${_tempDateTime.month}월 ${_tempDateTime.day}일 ${_tempDateTime.hour.toString().padLeft(2, '0')}:${_tempDateTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 16, color: gray1000),
                ),
              ],
            ),
            Icon(Icons.access_time, color: gray600),
          ],
        ),
      ),
    );
  }

  void _showDateTimePicker(BuildContext context) {
    DateTime tempSelectedDateTime = _tempDateTime;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            // 헤더
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: gray100,
                border: Border(bottom: BorderSide(color: gray300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      print('❌ [피커] 날짜/시간 선택 취소');
                      Navigator.pop(context);
                    },
                    child: Text('취소', style: TextStyle(color: Colors.blue)),
                  ),
                  Text(
                    widget.label,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        _tempDateTime = tempSelectedDateTime;
                      });
                      widget.onDateTimeSelected(tempSelectedDateTime);
                      print('📅 [피커] 날짜/시간 선택 완료: $tempSelectedDateTime');
                      Navigator.pop(context);
                    },
                    child: Text(
                      '완료',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 피커 (15분 단위)
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: _tempDateTime,
                minuteInterval: 15, // ⭐️ 15분 단위
                onDateTimeChanged: (dateTime) {
                  tempSelectedDateTime = dateTime;
                  print('📅 [피커] 날짜+시간 변경: $dateTime');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Save extends StatelessWidget {
  const _Save();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // 부모 위젯의 상태에 접근해서 폼 검증과 저장을 실행한다
              final parentState = context
                  .findAncestorStateOfType<_CreateEntryBottomSheetState>();
              if (parentState != null) {
                parentState._saveSchedule(context); // 폼 검증과 스케줄 저장을 실행한다
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: gray1000),
            child: Text('저장하기', style: TextStyle(color: gray050)),
          ),
        ),
      ],
    );
  }
}
