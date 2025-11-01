import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // ✅ ImageFilter for backdrop blur
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // ✅ DateFormat 추가
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
import 'toast/save_toast.dart'; // 🔥 SaveToast import
import 'modal/schedule_detail_wolt_modal.dart'; // 🔥 상세 모달
import 'modal/task_detail_wolt_modal.dart'; // 🔥 상세 모달
import 'modal/habit_detail_wolt_modal.dart'; // 🔥 상세 모달

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
  bool _showQuickAddTypePopup = false; // 🔥 팝업 표시 상태

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

    // 🔥 팝업 상태 초기화
    _showQuickAddTypePopup = false;
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
    try {
      final type = data['type'] as QuickAddType;
      final title = data['title'] as String;
      final colorId = data['colorId'] as String;
      int? savedId; // 🔥 저장된 ID 추적

      if (type == QuickAddType.schedule) {
        // ========================================
        // 일정 저장
        // ========================================
        final startDateTime = data['startDateTime'] as DateTime;
        final endDateTime = data['endDateTime'] as DateTime;
        final repeatRule = data['repeatRule'] as String? ?? '';
        final reminder = data['reminder'] as String? ?? '';

        // ✅ 일정 리마인더 기본값: 10분 전
        final finalReminder = reminder.isEmpty
            ? '{"value":"10","display":"10分前"}'
            : reminder;

        // 🔥 디버그 로그: 저장 전 데이터 확인
        debugPrint('💾 [QuickAdd] 일정 저장 시작');
        debugPrint('   - 제목: $title');
        debugPrint('   - 시작: $startDateTime');
        debugPrint('   - 종료: $endDateTime');
        debugPrint('   - 색상: $colorId');
        debugPrint('   - 반복: ${repeatRule.isEmpty ? "(없음)" : repeatRule}');
        debugPrint('   - 알림: ${reminder.isEmpty ? "(기본값: 10분 전)" : reminder}');

        final companion = ScheduleCompanion.insert(
          start: startDateTime,
          end: endDateTime,
          summary: title,
          colorId: colorId,
          // ✅ description, location은 기본값 '' 자동 적용
          repeatRule: repeatRule.isNotEmpty
              ? Value(repeatRule)
              : const Value.absent(), // ✅ 빈 문자열이면 absent (기본값 '' 사용)
          alertSetting: Value(finalReminder), // ✅ 기본값 10분 전 적용
        );

        final database = GetIt.I<AppDatabase>();
        savedId = await database.createSchedule(companion);
        debugPrint('✅ [QuickAdd] 일정 저장 완료: ID=$savedId');
      } else if (type == QuickAddType.task) {
        // ========================================
        // 할일 저장
        // ========================================
        final dueDate = data['dueDate'] as DateTime?;
        final repeatRule = data['repeatRule'] as String? ?? '';
        final reminder = data['reminder'] as String? ?? '';

        // 🔥 디버그 로그: 저장 전 데이터 확인
        debugPrint('💾 [QuickAdd] 할일 저장 시작');
        debugPrint('   - 제목: $title');
        debugPrint('   - 색상: $colorId');
        debugPrint('   - 마감일: ${dueDate ?? "(없음)"}');
        debugPrint('   - 반복: ${repeatRule.isEmpty ? "(없음)" : repeatRule}');
        debugPrint('   - 알림: ${reminder.isEmpty ? "(없음)" : reminder}');

        // 1. 검증
        final validationResult = EntityValidators.validateCompleteTask(
          title: title,
          dueDate: dueDate,
          colorId: colorId,
        );

        EntityValidators.printValidationResult(validationResult, '할일');

        if (!validationResult['isValid']) {
          // 🔥 검증 실패 시 사용자 피드백
          debugPrint('⚠️ [QuickAdd] 할일 검증 실패');
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('タイトルを入力してください')));
          }
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
          repeatRule: repeatRule.isNotEmpty
              ? Value(repeatRule)
              : const Value.absent(), // ✅ 빈 문자열이면 absent (기본값 '' 사용)
          reminder: reminder.isNotEmpty
              ? Value(reminder)
              : const Value.absent(), // ✅ 빈 문자열이면 absent (기본값 '' 사용)
        );

        final database = GetIt.I<AppDatabase>();
        savedId = await database.createTask(companion);
        debugPrint('✅ [QuickAdd] 할일 저장 완료: ID=$savedId');
      } else if (type == QuickAddType.habit) {
        // ========================================
        // 습관 저장
        // ========================================
        final repeatRule = data['repeatRule'] as String? ?? '';
        final reminder = data['reminder'] as String? ?? '';

        // 🔥 디버그 로그: 저장 전 데이터 확인
        debugPrint('💾 [QuickAdd] 습관 저장 시작');
        debugPrint('   - 제목: $title');
        debugPrint('   - 색상: $colorId');
        debugPrint(
          '   - 반복: ${repeatRule.isEmpty ? "(없음 - 오류!)" : repeatRule}',
        );
        debugPrint('   - 알림: ${reminder.isEmpty ? "(없음)" : reminder}');

        // 🔥 핵심 검증: repeatRule이 비어있으면 저장 불가
        if (repeatRule.isEmpty) {
          debugPrint('⚠️ [QuickAdd] 습관 저장 실패: repeatRule이 비어있음');
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('繰り返し設定を選択してください')));
          }
          return;
        }

        // 1. 검증
        final validationResult = EntityValidators.validateCompleteHabit(
          title: title,
          repeatRule: repeatRule,
          colorId: colorId,
        );

        EntityValidators.printValidationResult(validationResult, '습관');

        if (!validationResult['isValid']) {
          // 🔥 검증 실패 시 사용자 피드백
          debugPrint('⚠️ [QuickAdd] 습관 검증 실패');
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('繰り返し設定を選択してください')));
          }
          return;
        }

        // 2. DB 저장
        final companion = HabitCompanion.insert(
          title: title,
          createdAt: DateTime.now(),
          repeatRule: repeatRule, // ✅ 필수 필드 (이미 검증됨)
          colorId: Value(colorId),
          reminder: reminder.isNotEmpty
              ? Value(reminder)
              : const Value.absent(), // ✅ 빈 문자열이면 absent (기본값 '' 사용)
        );

        final database = GetIt.I<AppDatabase>();
        savedId = await database.createHabit(companion);
        debugPrint('✅ [QuickAdd] 습관 저장 완료: ID=$savedId');
      }

      // 이거를 설정하고 → 저장이 성공했으므로 제목 포함 모든 캐시를 삭제해서
      // 이거를 해서 → 하단 박스가 사라지도록 한다
      // 이거는 이래서 → Figma 디자인대로 저장 후 임시 데이터를 정리한다
      await TempInputCache.clearAllIncludingTitle();

      // 🔥 저장 성공 후 바텀시트를 닫고 토스트 표시
      if (context.mounted && savedId != null) {
        // 먼저 바텀시트 닫기
        Navigator.of(context).pop();

        // 약간의 딜레이 후 토스트 표시 (바텀시트 애니메이션 완료 대기)
        await Future.delayed(const Duration(milliseconds: 150));

        if (context.mounted) {
          showSaveToast(
            context,
            toInbox: type != QuickAddType.schedule, // 일정은 캘린더, 할일/습관은 인박스
            onTap: () async {
              // 🔥 토스트 탭 시 상세 모달 열기 (저장된 데이터 로드)
              final database = GetIt.I<AppDatabase>();

              if (type == QuickAddType.schedule) {
                final schedule = await database.getScheduleById(savedId!);
                if (context.mounted && schedule != null) {
                  showScheduleDetailWoltModal(
                    context,
                    schedule: schedule,
                    selectedDate: widget.selectedDate,
                  );
                }
              } else if (type == QuickAddType.task) {
                final task = await database.getTaskById(savedId!);
                if (context.mounted && task != null) {
                  showTaskDetailWoltModal(
                    context,
                    task: task,
                    selectedDate: widget.selectedDate,
                  );
                }
              } else if (type == QuickAddType.habit) {
                final habit = await database.getHabitById(savedId!);
                if (context.mounted && habit != null) {
                  showHabitDetailWoltModal(
                    context,
                    habit: habit,
                    selectedDate: widget.selectedDate,
                  );
                }
              }
            },
          );
        }
      }
    } catch (e, stackTrace) {
      // 🔥 에러 발생 시 상세 로그와 사용자 피드백
      debugPrint('❌ [QuickAdd] 저장 중 에러 발생');
      debugPrint('   - 에러: $e');
      debugPrint('   - 스택: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
      }
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

    // 1. 먼저 기본 폼 검증을 수행한다 (각 필드의 validator 실행)
    if (!(_formKey.currentState?.validate() ?? false)) {
      // 기본 검증이 실패하면 여기서 중단한다
      return;
    }

    // 2. 폼이 유효하면 저장을 실행한다 (각 필드의 onSaved 실행)
    _formKey.currentState?.save();

    // 3. ⭐️ 종일/시간별에 따라 다른 DateTime 사용
    // 이거를 설정하고 → _isAllDay 플래그로 종일/시간별을 구분해서
    // 이거를 해서 → 종일이면 00:00:00 ~ 23:59:59, 시간별이면 정확한 DateTime 사용
    // 이거는 이래서 → DB에 올바른 형식으로 저장된다
    final DateTime startDateTime;
    final DateTime endDateTime;

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
    } else {
      // 시간별: 피커에서 선택한 정확한 DateTime
      startDateTime = _selectedStartDate ?? widget.selectedDate;
      endDateTime =
          _selectedEndDate ?? widget.selectedDate.add(Duration(hours: 1));
    }

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
      return;
    }

    // 7. 경고가 있으면 사용자에게 확인을 받는다
    if (validationResult.hasWarnings) {
      final shouldContinue = await _showWarningsDialog(
        context,
        validationResult.warnings,
      );
      if (shouldContinue != true) {
        return;
      }
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

      // 9. DB에 저장한다
      // 이거는 이래서 → createSchedule()이 완료되면 DB 스트림이 자동으로 갱신된다
      // 이거라면 → StreamBuilder가 감지해서 UI를 자동으로 업데이트한다
      final database = GetIt.I<AppDatabase>();
      final id = await database.createSchedule(companion);

      // 10. 바텀시트를 닫는다
      // 이거를 설정하고 → Navigator.pop()으로 바텀시트를 닫으면
      // 이거를 해서 → StreamBuilder가 자동으로 새로운 데이터를 감지한다
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
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
    // ✅✅✅ ULTRATHINK: Quick Add 모드
    if (_useQuickAdd) {
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
            final inputAccessoryTop =
                screenHeight - keyboardHeight - inputAccessoryHeight;

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
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // 2️⃣ 배경색 F0F0F0 - Input Accessory 상단부터 화면 하단까지
                Positioned(
                  left: 0,
                  right: 0,
                  top: inputAccessoryTop, // 🔥 Input Accessory 상단부터 시작
                  bottom: 0, // 🔥 화면 하단까지
                  child: IgnorePointer(
                    child: Container(
                      color: const Color(0xFFF0F0F0), // Blur 대신 단색 배경
                    ),
                  ),
                ),

                // 3️⃣ Blur + Gradient Overlay (배경색 위에 덧입힘)
                Positioned(
                  left: 0,
                  right: 0,
                  top: inputAccessoryTop,
                  bottom: 0,
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
                              Color(0x80F0F0F0), // 하단: 50% 불투명 F0F0F0
                            ],
                            stops: [0.0, 0.5], // Figma: 0%, 50%
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 4️⃣ Input Accessory 컨텐츠
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
                          showTypePopup: _showQuickAddTypePopup,
                          onShowTypePopup: () {
                            setState(() {
                              _showQuickAddTypePopup = true;
                              _isKeyboardLocked = true; // 즉시 하단 고정 모드 활성화
                            });
                            debugPrint(
                              '🔒 [CreateEntry] 타입 선택 팝업 표시! isLocked: $_isKeyboardLocked',
                            );
                          },
                          onTypeChanged: (type) {
                            setState(() {
                              _selectedQuickAddType = type;
                              _showQuickAddTypePopup = false;
                            });
                          },
                          onInputFocused: () {
                            setState(() {
                              _isKeyboardLocked = false;
                              _showQuickAddTypePopup = false;
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
                  },
                ),
              ],
            ),
            SizedBox(height: 8),

            // 조건부 렌더링: 종일 vs 시간별
            SizedBox(height: 8),
            if (_selectedStartDate != null)
              Text(
                '시작: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedStartDate!)}',
                style: TextStyle(color: Colors.white70),
              ),
            if (_selectedEndDate != null)
              Text(
                '종료: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedEndDate!)}',
                style: TextStyle(color: Colors.white70),
              ),
            SizedBox(height: 8),
            Consumer<BottomSheetController>(
              builder: (context, controller, child) => _Category(
                selectedColor: controller.selectedColor,
                onTap: (String color) {
                  controller.updateColor(color);
                },
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // TODO: 저장 로직 구현
                Navigator.pop(context);
              },
              child: Text('저장'),
            ),
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
              onTap(colorName);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
