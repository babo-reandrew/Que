// ===================================================================
// ⭐️ Gemini Result Confirmation Screen
// ===================================================================
// AnimatedReorderableListView로 드래그 앤 드롭 구현
// date_detail_view.dart와 동일한 방식 사용
// ===================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../Database/schedule_database.dart';
import '../model/extracted_schedule.dart';
import '../component/schedule_card.dart';
import '../widgets/task_card.dart';
import '../widgets/habit_card.dart';
import '../component/modal/schedule_detail_wolt_modal.dart';
import '../component/modal/task_detail_wolt_modal.dart';
import '../component/modal/habit_detail_wolt_modal.dart';
import '../component/modal/discard_changes_modal.dart';
import '../providers/schedule_form_controller.dart';
import '../providers/task_form_controller.dart';
import '../providers/habit_form_controller.dart';
import '../providers/bottom_sheet_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 통합 아이템 타입
enum GeminiItemType { schedule, task, habit, sectionHeader, dateHeader }

/// 통합 아이템 클래스
class GeminiItem {
  final GeminiItemType type;
  final String id;
  final dynamic data; // ExtractedSchedule, ExtractedTask, ExtractedHabit
  final String? sectionTitle; // 섹션 헤더용

  GeminiItem({
    required this.type,
    required this.id,
    this.data,
    this.sectionTitle,
  });

  /// 스케줄에서 생성
  factory GeminiItem.schedule(ExtractedSchedule schedule, int index) {
    return GeminiItem(
      type: GeminiItemType.schedule,
      id: 'schedule_$index',
      data: schedule,
    );
  }

  /// 타스크에서 생성
  factory GeminiItem.task(ExtractedTask task, int index) {
    return GeminiItem(type: GeminiItemType.task, id: 'task_$index', data: task);
  }

  /// 습관에서 생성
  factory GeminiItem.habit(ExtractedHabit habit, int index) {
    return GeminiItem(
      type: GeminiItemType.habit,
      id: 'habit_$index',
      data: habit,
    );
  }

  /// 섹션 헤더 (スケジュール, タスク, ルーティン)
  factory GeminiItem.header(String title) {
    return GeminiItem(
      type: GeminiItemType.sectionHeader,
      id: 'header_$title',
      sectionTitle: title,
    );
  }

  /// 날짜 헤더 (今日, 8月2日 등)
  factory GeminiItem.dateHeader(String title) {
    return GeminiItem(
      type: GeminiItemType.dateHeader,
      id: 'date_header_$title',
      sectionTitle: title,
    );
  }

  /// 타입 변환
  dynamic convertToType(GeminiItemType targetType) {
    if (type == targetType) return data;

    final now = DateTime.now();
    final defaultTime = DateTime(now.year, now.month, now.day, 15, 0);

    switch (targetType) {
      case GeminiItemType.schedule:
        if (type == GeminiItemType.task) {
          final task = data as ExtractedTask;
          return ExtractedSchedule(
            summary: task.title,
            start: task.executionDate ?? defaultTime,
            end: (task.executionDate ?? defaultTime).add(
              const Duration(hours: 1),
            ),
            colorId: task.colorId,
            repeatRule: task.repeatRule, // ✅ 반복 규칙 보존
            description: '', // ✅ description은 기본값
            location: '', // ✅ location은 기본값
          );
        } else if (type == GeminiItemType.habit) {
          final habit = data as ExtractedHabit;
          return ExtractedSchedule(
            summary: habit.title,
            start: defaultTime,
            end: defaultTime.add(const Duration(hours: 1)),
            colorId: habit.colorId,
            repeatRule: habit.repeatRule, // ✅ 반복 규칙 보존
            description: '', // ✅ description은 기본값
            location: '', // ✅ location은 기본값
          );
        }
        break;

      case GeminiItemType.task:
        if (type == GeminiItemType.schedule) {
          final schedule = data as ExtractedSchedule;
          return ExtractedTask(
            title: schedule.summary,
            dueDate: null,
            executionDate: schedule.start,
            colorId: schedule.colorId,
            listId: 'inbox',
            repeatRule: schedule.repeatRule, // ✅ 반복 규칙 보존
            reminder: '', // ✅ 리마인더는 기본값
          );
        } else if (type == GeminiItemType.habit) {
          final habit = data as ExtractedHabit;
          return ExtractedTask(
            title: habit.title,
            dueDate: null,
            executionDate: defaultTime,
            colorId: habit.colorId,
            listId: 'inbox',
            repeatRule: habit.repeatRule, // ✅ 반복 규칙 보존
            reminder: habit.reminder, // ✅ 리마인더 보존
          );
        }
        break;

      case GeminiItemType.habit:
        if (type == GeminiItemType.schedule) {
          final schedule = data as ExtractedSchedule;
          return ExtractedHabit(
            title: schedule.summary,
            colorId: schedule.colorId,
            repeatRule: schedule.repeatRule, // ✅ 반복 규칙 보존
            reminder: '', // ✅ reminder는 기본값
          );
        } else if (type == GeminiItemType.task) {
          final task = data as ExtractedTask;
          return ExtractedHabit(
            title: task.title,
            colorId: task.colorId,
            repeatRule: task.repeatRule, // ✅ 반복 규칙 보존
            reminder: task.reminder, // ✅ 리마인더 보존
          );
        }
        break;

      case GeminiItemType.sectionHeader:
      case GeminiItemType.dateHeader:
        return data;
    }
    return data;
  }
}

class GeminiResultConfirmationScreen extends StatefulWidget {
  final List<ExtractedSchedule> schedules;
  final List<ExtractedTask> tasks;
  final List<ExtractedHabit> habits;

  const GeminiResultConfirmationScreen({
    super.key,
    required this.schedules,
    required this.tasks,
    required this.habits,
  });

  @override
  State<GeminiResultConfirmationScreen> createState() =>
      _GeminiResultConfirmationScreenState();
}

class _GeminiResultConfirmationScreenState
    extends State<GeminiResultConfirmationScreen> {
  late List<GeminiItem> _items;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _buildItemList();
  }

  /// 통합 아이템 리스트 생성
  void _buildItemList() {
    _items = [];

    // 값이 있는 섹션들 (일정 → 할일 → 습관 순서)
    final hasSchedules = widget.schedules.isNotEmpty;
    final hasTasks = widget.tasks.isNotEmpty;
    final hasHabits = widget.habits.isNotEmpty;

    // 1. 스케줄 (값이 있으면) - 날짜별 그룹핑
    if (hasSchedules) {
      _items.add(GeminiItem.header('スケジュール'));
      _addSchedulesGroupedByDate();
    }

    // 2. 타스크 (값이 있으면) - 실행일별 그룹핑
    if (hasTasks) {
      _items.add(GeminiItem.header('タスク'));
      _addTasksGroupedByDate();
    }

    // 3. 습관 (값이 있으면) - 날짜 그룹핑 없음
    if (hasHabits) {
      _items.add(GeminiItem.header('ルーティン'));
      for (int i = 0; i < widget.habits.length; i++) {
        _items.add(GeminiItem.habit(widget.habits[i], i));
      }
    }

    // 값이 없는 섹션들 (일정 → 할일 → 습관 순서)
    if (!hasSchedules) {
      _items.add(GeminiItem.header('スケジュール'));
    }
    if (!hasTasks) {
      _items.add(GeminiItem.header('タスク'));
    }
    if (!hasHabits) {
      _items.add(GeminiItem.header('ルーティン'));
    }
  }

  /// 스케줄을 날짜별로 그룹핑하여 추가
  void _addSchedulesGroupedByDate() {
    // 날짜별로 그룹핑
    final groupedSchedules = <DateTime, List<ExtractedSchedule>>{};

    for (final schedule in widget.schedules) {
      final dateKey = DateTime(
        schedule.start.year,
        schedule.start.month,
        schedule.start.day,
      );
      groupedSchedules.putIfAbsent(dateKey, () => []).add(schedule);
    }

    // 날짜순으로 정렬
    final sortedDates = groupedSchedules.keys.toList()..sort();

    // 각 날짜별로 헤더와 아이템 추가
    for (final date in sortedDates) {
      final schedules = groupedSchedules[date]!;

      // 날짜 헤더 추가
      final dateHeader = _formatDateHeader(date);
      _items.add(GeminiItem.dateHeader(dateHeader));

      // 해당 날짜의 스케줄들 추가
      for (int i = 0; i < schedules.length; i++) {
        _items.add(GeminiItem.schedule(schedules[i], i));
      }
    }
  }

  /// 타스크를 실행일별로 그룹핑하여 추가
  void _addTasksGroupedByDate() {
    // 실행일별로 그룹핑
    final groupedTasks = <DateTime?, List<ExtractedTask>>{};

    for (final task in widget.tasks) {
      final dateKey = task.executionDate != null
          ? DateTime(
              task.executionDate!.year,
              task.executionDate!.month,
              task.executionDate!.day,
            )
          : null;
      groupedTasks.putIfAbsent(dateKey, () => []).add(task);
    }

    // 날짜순으로 정렬 (null은 맨 뒤)
    final sortedDates = groupedTasks.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        return a.compareTo(b);
      });

    // 각 날짜별로 헤더와 아이템 추가
    for (final date in sortedDates) {
      final tasks = groupedTasks[date]!;

      // 날짜 헤더 추가
      final dateHeader = date != null ? _formatDateHeader(date) : '実行日なし';
      _items.add(GeminiItem.dateHeader(dateHeader));

      // 해당 날짜의 타스크들 추가
      for (int i = 0; i < tasks.length; i++) {
        _items.add(GeminiItem.task(tasks[i], i));
      }
    }
  }

  /// 날짜 헤더 포맷 (今日, 8月2日 등)
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) {
      return '今日';
    } else if (date == tomorrow) {
      return '明日';
    } else {
      // 8月2日 형식
      return '${date.month}月${date.day}日';
    }
  }

  @override
  Widget build(BuildContext context) {
    // SafeArea 높이 계산
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(topPadding + kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFAFAFA), // 상단 100% (불투명)
                const Color(0xFFFAFAFA).withOpacity(0), // 하단 0% (완전 투명)
              ],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent, // Material 3 색상 오버라이드 제거
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            actions: [
              // 삭제 버튼 - Figma 스펙
              Padding(
                padding: const EdgeInsets.only(right: 28), // 우측 28px 여백
                child: GestureDetector(
                  onTap: () async {
                    // 파기 확인 모달 표시
                    final confirmed = await showDiscardChangesModal(context);
                    if (confirmed == true && mounted) {
                      // 확인 시 화면 나가기 - 원래 화면(월뷰/디테일뷰)으로 돌아가기
                      // ImagePickerSmoothSheet는 이미 onClose로 닫혔으므로 한 번만 pop
                      Navigator.of(
                        context,
                      ).pop(); // GeminiResultConfirmationScreen 닫기
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFFFE6E6,
                      ).withOpacity(0.9), // rgba(255, 230, 230, 0.9)
                      border: Border.all(
                        color: const Color(
                          0xFF111111,
                        ).withOpacity(0.02), // rgba(17, 17, 17, 0.02)
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: SvgPicture.asset(
                      'asset/icon/X_icon.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFF0000), // #FF0000 빨간색, border 2px
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 리스트
              Expanded(
                child: AnimatedReorderableListView(
                  items: _items,
                  padding: EdgeInsets.only(
                    top:
                        topPadding +
                        kToolbarHeight +
                        32, // SafeArea + AppBar + 32px
                    bottom: 100,
                  ),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _buildItem(item, index);
                  },
                  onReorder: (oldIndex, newIndex) {
                    _handleReorder(oldIndex, newIndex);
                  },
                  isSameItem: (a, b) => a.id == b.id,

                  // 🎨 드래그 중 피드백: 4도 기울이기 + 스케일 + 투명도
                  proxyDecorator: (child, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: 4 * 3.14159 / 180, // 4도를 라디안으로 변환
                          child: Transform.scale(
                            scale: 1.05, // 살짝 확대
                            child: Opacity(opacity: 0.9, child: child),
                          ),
                        );
                      },
                      child: child,
                    );
                  },

                  // 애니메이션 설정 (date_detail_view와 동일)
                  insertDuration: const Duration(milliseconds: 300),
                  removeDuration: const Duration(milliseconds: 250),
                  dragStartDelay: const Duration(milliseconds: 500),

                  enterTransition: [
                    ScaleIn(
                      duration: const Duration(milliseconds: 300),
                      curve: const Cubic(0.25, 0.1, 0.25, 1.0),
                      begin: 0.95,
                      end: 1.0,
                    ),
                    FadeIn(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
                  ],

                  exitTransition: [
                    ScaleIn(
                      duration: const Duration(milliseconds: 250),
                      curve: const Cubic(0.42, 0.0, 0.58, 1.0),
                      begin: 1.0,
                      end: 0.9,
                    ),
                    FadeIn(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                      begin: 1.0,
                      end: 0.0,
                    ),
                  ],
                ),
              ),

              // 하단 버튼
              _buildBottomButton(),
            ],
          ),
        ],
      ),
    );
  }

  /// 아이템 빌더
  Widget _buildItem(GeminiItem item, int index) {
    // 섹션 헤더 (スケジュール, タスク, ルーティン) - 드래그 불가
    if (item.type == GeminiItemType.sectionHeader) {
      // 해당 섹션에 값이 있는지 확인
      final hasItems = _hasSectionItems(item.sectionTitle!);

      return IgnorePointer(
        key: ValueKey(item.id),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
          child: SizedBox(
            width: 342, // 카드와 동일한 너비
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 19,
                fontWeight: FontWeight.w800, // ExtraBold
                color: hasItems
                    ? const Color(0xFF262626) // 값이 있을 때: #262626
                    : const Color(0xFF7A7A7A), // 값이 없을 때: #7A7A7A (비활성화)
              ),
              child: Text(item.sectionTitle!),
            ),
          ),
        ),
      );
    }

    // 날짜 헤더 (今日, 8月2日 등) - 드래그 불가
    if (item.type == GeminiItemType.dateHeader) {
      return IgnorePointer(
        key: ValueKey(item.id),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: SizedBox(
            width: 342, // 카드와 동일한 너비
            child: Text(
              item.sectionTitle!,
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 15,
                fontWeight: FontWeight.w700, // Bold
                color: Color(0xFF7A7A7A), // 회색
              ),
            ),
          ),
        ),
      );
    }

    // 카드 아이템 - 중앙 정렬 + 342px (좌우 24px 여백)
    return Container(
      key: ValueKey(item.id),
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: 342, // 390 - 24*2 = 342
        child: _buildCard(item),
      ),
    );
  }

  /// 섹션에 아이템이 있는지 확인
  bool _hasSectionItems(String sectionTitle) {
    // 섹션 헤더 다음에 카드가 있는지 확인
    final sectionIndex = _items.indexWhere(
      (item) =>
          item.type == GeminiItemType.sectionHeader &&
          item.sectionTitle == sectionTitle,
    );

    if (sectionIndex == -1 || sectionIndex >= _items.length - 1) {
      return false;
    }

    // 다음 아이템이 섹션 헤더가 아니면 카드가 있는 것
    final nextItem = _items[sectionIndex + 1];
    return nextItem.type != GeminiItemType.sectionHeader;
  }

  /// 카드 빌더
  Widget _buildCard(GeminiItem item) {
    Widget card;
    VoidCallback? onTap;

    switch (item.type) {
      case GeminiItemType.schedule:
        final schedule = item.data as ExtractedSchedule;
        card = ScheduleCard(
          start: schedule.start,
          end: schedule.end,
          summary: schedule.summary,
          colorId: schedule.colorId,
          repeatRule: schedule.repeatRule.isEmpty ? null : schedule.repeatRule,
        );
        // 스케줄 상세 모달 열기
        onTap = () async {
          // 🎯 현재 아이템의 인덱스를 찾아서 저장
          final currentIndex = _items.indexWhere((i) => i.id == item.id);
          if (currentIndex == -1) return;

          // ExtractedSchedule → ScheduleData 변환 (임시 id: -1)
          final scheduleData = ScheduleData(
            id: -1,
            start: schedule.start,
            end: schedule.end,
            summary: schedule.summary,
            colorId: schedule.colorId,
            repeatRule: schedule.repeatRule,
            alertSetting: '',
            createdAt: DateTime.now(),
            description: schedule.description,
            location: schedule.location,
            status: 'confirmed',
            visibility: 'default',
            completed: false,
            completedAt: null,
            timezone: 'Asia/Seoul',
            originalHour: schedule.start.hour,
            originalMinute: schedule.start.minute,
          );
          await showScheduleDetailWoltModal(
            context,
            schedule: scheduleData,
            selectedDate: schedule.start,
          );

          // 모달이 닫힌 후 해당 인덱스의 아이템만 업데이트
          _updateItemAtIndex(currentIndex);
        };
        break;

      case GeminiItemType.task:
        final task = item.data as ExtractedTask;
        final taskData = TaskData(
          id: -1,
          title: task.title,
          completed: false,
          dueDate: task.dueDate,
          executionDate: task.executionDate,
          listId: task.listId,
          createdAt: DateTime.now(),
          colorId: task.colorId,
          repeatRule: task.repeatRule, // 반복 규칙 추가
          reminder: task.reminder, // 리마인더 추가
          inboxOrder: 0, // 기본값 또는 적절한 값
        );
        card = TaskCard(task: taskData);
        // 타스크 상세 모달 열기
        onTap = () async {
          // 🎯 현재 아이템의 인덱스를 찾아서 저장
          final currentIndex = _items.indexWhere((i) => i.id == item.id);
          if (currentIndex == -1) return;

          await showTaskDetailWoltModal(
            context,
            task: taskData,
            selectedDate: task.executionDate ?? DateTime.now(),
          );

          // 모달이 닫힌 후 해당 인덱스의 아이템만 업데이트
          _updateItemAtIndex(currentIndex);
        };
        break;

      case GeminiItemType.habit:
        final habit = item.data as ExtractedHabit;
        final habitData = HabitData(
          id: -1,
          title: habit.title,
          colorId: habit.colorId,
          repeatRule: habit.repeatRule,
          createdAt: DateTime.now(),
          reminder: habit.reminder, // 리마인더 추가
        );
        card = HabitCard(habit: habitData);
        // 습관 상세 모달 열기
        onTap = () async {
          // 🎯 현재 아이템의 인덱스를 찾아서 저장
          final currentIndex = _items.indexWhere((i) => i.id == item.id);
          if (currentIndex == -1) return;

          await showHabitDetailWoltModal(
            context,
            habit: habitData,
            selectedDate: DateTime.now(),
          );

          // 모달이 닫힌 후 해당 인덱스의 아이템만 업데이트
          _updateItemAtIndex(currentIndex);
        };
        break;

      default:
        return const SizedBox.shrink();
    }

    // 카드를 Slidable로 감싸서 삭제 기능 추가
    final slidableCard = Slidable(
      key: ValueKey(item.id),
      closeOnScroll: true,

      // 왼쪽에서 오른쪽 스와이프 → 삭제
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.144, // 초기 56px
        dismissible: DismissiblePane(
          dismissThreshold: 0.6,
          closeOnCancel: true,
          confirmDismiss: () async {
            await HapticFeedback.mediumImpact();
            // 삭제 확인 없이 바로 삭제
            _deleteItem(item);
            return true;
          },
          onDismissed: () {},
        ),
        children: [
          // 삭제 버튼
          CustomSlidableAction(
            onPressed: (context) async {
              await HapticFeedback.mediumImpact();
              _deleteItem(item);
            },
            backgroundColor: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.symmetric(vertical: 8),
            autoClose: true,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth,
                    height: 56,
                    constraints: const BoxConstraints(
                      minWidth: 56,
                      minHeight: 56,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'asset/icon/trash_icon.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // 카드를 GestureDetector로 감싸기
      child: GestureDetector(onTap: onTap, child: card),
    );

    // Slidable 카드를 중앙 정렬된 컨테이너에 배치
    return Align(alignment: Alignment.center, child: slidableCard);
  }

  /// 아이템 삭제
  void _deleteItem(GeminiItem item) {
    setState(() {
      _items.removeWhere((i) => i.id == item.id);
      // 섹션 재정렬
      _reorganizeSections();
    });
  }

  /// 재정렬 핸들러
  void _handleReorder(int oldIndex, int newIndex) {
    // 섹션 헤더 정보 출력
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].type == GeminiItemType.sectionHeader) {}
    }

    final targetIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;

    setState(() {
      final item = _items.removeAt(oldIndex);

      _items.insert(targetIndex, item);

      // 삽입된 위치 주변 아이템 확인
      if (targetIndex > 0) {
        final prev = _items[targetIndex - 1];
        if (prev.type == GeminiItemType.sectionHeader) {
        } else {}
      } else {}

      if (targetIndex < _items.length - 1) {
        final next = _items[targetIndex + 1];
        if (next.type == GeminiItemType.sectionHeader) {
        } else {}
      } else {}

      // 섹션 경계를 넘어서 이동한 경우 타입 변환
      _checkAndConvertType(targetIndex);
    });
  }

  /// 타입 변환 체크 (섹션 경계 넘을 때)
  void _checkAndConvertType(int index) {
    if (index >= _items.length) return;

    final item = _items[index];
    if (item.type == GeminiItemType.sectionHeader ||
        item.type == GeminiItemType.dateHeader) {
      return;
    }

    // ==========================================
    // 핵심: 이 아이템이 속한 섹션 찾기
    // ==========================================
    // 우선순위:
    // 1. 다음 아이템이 섹션 헤더 → 그 섹션에 속함 (섹션 헤더 바로 위)
    // 2. 위쪽 섹션 헤더 → 그 섹션에 속함
    // 3. 아래쪽 섹션 헤더 → 첫 번째 섹션으로 간주
    // ==========================================

    String? currentSection;
    GeminiItemType? targetType;

    // ✨ 우선순위 1: 다음 아이템이 섹션 헤더인지 확인 (섹션 헤더 바로 위에 드롭)
    if (index < _items.length - 1 &&
        _items[index + 1].type == GeminiItemType.sectionHeader) {
      currentSection = _items[index + 1].sectionTitle;
    }
    // 우선순위 2: 위쪽으로 올라가면서 섹션 헤더 찾기
    else {
      for (int i = index - 1; i >= 0; i--) {
        if (_items[i].type == GeminiItemType.sectionHeader) {
          currentSection = _items[i].sectionTitle;
          break;
        }
      }

      // 우선순위 3: 위쪽에 섹션이 없으면 아래쪽 확인
      if (currentSection == null) {
        for (int i = index + 1; i < _items.length; i++) {
          if (_items[i].type == GeminiItemType.sectionHeader) {
            currentSection = _items[i].sectionTitle;
            break;
          }
        }
      }
    }

    // 섹션에 따라 타겟 타입 결정
    if (currentSection == 'スケジュール') {
      targetType = GeminiItemType.schedule;
    } else if (currentSection == 'タスク') {
      targetType = GeminiItemType.task;
    } else if (currentSection == 'ルーティン') {
      targetType = GeminiItemType.habit;
    } else {}

    // 타입이 다르면 변환
    if (targetType != null && item.type != targetType) {
      final converted = item.convertToType(targetType);
      _items[index] = GeminiItem(
        type: targetType,
        id: '${targetType.name}_${DateTime.now().millisecondsSinceEpoch}',
        data: converted,
      );

      // 🎯 변환 후 올바른 섹션으로 재배치 + 섹션 재정렬
      _reorganizeSections();
    } else if (targetType == null) {
    } else {}
  }

  /// 섹션 재정렬: 내용이 있는 섹션을 위로, 순서는 스케줄 → 타스크 → 습관, 날짜별 그룹핑 유지
  void _reorganizeSections() {
    // 1. 모든 아이템을 타입별로 분류
    final schedules = <GeminiItem>[];
    final tasks = <GeminiItem>[];
    final habits = <GeminiItem>[];

    for (final item in _items) {
      if (item.type == GeminiItemType.schedule) {
        schedules.add(item);
      } else if (item.type == GeminiItemType.task) {
        tasks.add(item);
      } else if (item.type == GeminiItemType.habit) {
        habits.add(item);
      }
    }

    // 2. 새로운 리스트 구성
    _items.clear();

    // 값이 있는 섹션들 (스케줄 → 타스크 → 습관 순서)
    if (schedules.isNotEmpty) {
      _items.add(GeminiItem.header('スケジュール'));
      // 스케줄을 날짜별로 그룹핑
      _addScheduleItemsGroupedByDate(schedules);
    }
    if (tasks.isNotEmpty) {
      _items.add(GeminiItem.header('タスク'));
      // 타스크를 실행일별로 그룹핑
      _addTaskItemsGroupedByDate(tasks);
    }
    if (habits.isNotEmpty) {
      _items.add(GeminiItem.header('ルーティン'));
      _items.addAll(habits);
    }

    // 값이 없는 섹션들 (스케줄 → 타스크 → 습관 순서)
    if (schedules.isEmpty) {
      _items.add(GeminiItem.header('スケジュール'));
    }
    if (tasks.isEmpty) {
      _items.add(GeminiItem.header('タスク'));
    }
    if (habits.isEmpty) {
      _items.add(GeminiItem.header('ルーティン'));
    }
  }

  /// 스케줄 아이템들을 날짜별로 그룹핑하여 추가
  void _addScheduleItemsGroupedByDate(List<GeminiItem> scheduleItems) {
    // 날짜별로 그룹핑
    final groupedSchedules = <DateTime, List<GeminiItem>>{};

    for (final item in scheduleItems) {
      final schedule = item.data as ExtractedSchedule;
      final dateKey = DateTime(
        schedule.start.year,
        schedule.start.month,
        schedule.start.day,
      );
      groupedSchedules.putIfAbsent(dateKey, () => []).add(item);
    }

    // 날짜순으로 정렬
    final sortedDates = groupedSchedules.keys.toList()..sort();

    // 각 날짜별로 헤더와 아이템 추가
    for (final date in sortedDates) {
      final items = groupedSchedules[date]!;

      // 날짜 헤더 추가
      final dateHeader = _formatDateHeader(date);
      _items.add(GeminiItem.dateHeader(dateHeader));

      // 해당 날짜의 스케줄들 추가
      _items.addAll(items);
    }
  }

  /// 타스크 아이템들을 실행일별로 그룹핑하여 추가
  void _addTaskItemsGroupedByDate(List<GeminiItem> taskItems) {
    // 실행일별로 그룹핑
    final groupedTasks = <DateTime?, List<GeminiItem>>{};

    for (final item in taskItems) {
      final task = item.data as ExtractedTask;
      final dateKey = task.executionDate != null
          ? DateTime(
              task.executionDate!.year,
              task.executionDate!.month,
              task.executionDate!.day,
            )
          : null;
      groupedTasks.putIfAbsent(dateKey, () => []).add(item);
    }

    // 날짜순으로 정렬 (null은 맨 뒤)
    final sortedDates = groupedTasks.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        return a.compareTo(b);
      });

    // 각 날짜별로 헤더와 아이템 추가
    for (final date in sortedDates) {
      final items = groupedTasks[date]!;

      // 날짜 헤더 추가
      final dateHeader = date != null ? _formatDateHeader(date) : '実行日なし';
      _items.add(GeminiItem.dateHeader(dateHeader));

      // 해당 날짜의 타스크들 추가
      _items.addAll(items);
    }
  }

  /// Provider에서 변경사항을 가져와 특정 인덱스의 아이템만 업데이트 (메모리만 업데이트, DB 저장 X)
  void _updateItemAtIndex(int index) {
    if (index < 0 || index >= _items.length) {
      return;
    }

    final item = _items[index];
    if (item.type == GeminiItemType.sectionHeader ||
        item.type == GeminiItemType.dateHeader) {
      return;
    }

    final scheduleController = Provider.of<ScheduleFormController>(
      context,
      listen: false,
    );
    final taskController = Provider.of<TaskFormController>(
      context,
      listen: false,
    );
    final habitController = Provider.of<HabitFormController>(
      context,
      listen: false,
    );
    final bottomSheetController = Provider.of<BottomSheetController>(
      context,
      listen: false,
    );

    setState(() {
      switch (item.type) {
        case GeminiItemType.schedule:
          // Provider에서 업데이트된 스케줄 정보 가져오기
          final oldSchedule = item.data as ExtractedSchedule;
          final updatedSchedule = ExtractedSchedule(
            summary: scheduleController.titleController.text,
            start: DateTime(
              scheduleController.startDate!.year,
              scheduleController.startDate!.month,
              scheduleController.startDate!.day,
              scheduleController.startTime!.hour,
              scheduleController.startTime!.minute,
            ),
            end: DateTime(
              scheduleController.endDate!.year,
              scheduleController.endDate!.month,
              scheduleController.endDate!.day,
              scheduleController.endTime!.hour,
              scheduleController.endTime!.minute,
            ),
            colorId: bottomSheetController.selectedColor,
            repeatRule: bottomSheetController.repeatRule,
          );

          // 🎯 날짜가 바뀌었는지 확인
          final oldDate = DateTime(
            oldSchedule.start.year,
            oldSchedule.start.month,
            oldSchedule.start.day,
          );
          final newDate = DateTime(
            updatedSchedule.start.year,
            updatedSchedule.start.month,
            updatedSchedule.start.day,
          );

          _items[index] = GeminiItem(
            type: GeminiItemType.schedule,
            id: item.id,
            data: updatedSchedule,
          );

          // 🎯 날짜가 바뀌었으면 섹션 재정렬 (날짜 그룹 이동)
          if (oldDate != newDate) {
            _reorganizeSections();
          }
          break;

        case GeminiItemType.task:
          // Provider에서 업데이트된 타스크 정보 가져오기
          final oldTask = item.data as ExtractedTask;
          final updatedTask = ExtractedTask(
            title: taskController.titleController.text,
            colorId: bottomSheetController.selectedColor,
            executionDate: taskController.executionDate,
            dueDate: taskController.dueDate,
            listId: oldTask.listId,
            repeatRule: bottomSheetController.repeatRule, // 반복 규칙 업데이트
            reminder: bottomSheetController.reminder, // 리마인더 업데이트
          );

          // 🎯 실행일이 바뀌었는지 확인
          final oldDate = oldTask.executionDate != null
              ? DateTime(
                  oldTask.executionDate!.year,
                  oldTask.executionDate!.month,
                  oldTask.executionDate!.day,
                )
              : null;
          final newDate = updatedTask.executionDate != null
              ? DateTime(
                  updatedTask.executionDate!.year,
                  updatedTask.executionDate!.month,
                  updatedTask.executionDate!.day,
                )
              : null;

          _items[index] = GeminiItem(
            type: GeminiItemType.task,
            id: item.id,
            data: updatedTask,
          );

          // 🎯 실행일이 바뀌었으면 섹션 재정렬 (날짜 그룹 이동)
          if (oldDate != newDate) {
            _reorganizeSections();
          }
          break;

        case GeminiItemType.habit:
          // Provider에서 업데이트된 습관 정보 가져오기
          final updatedHabit = ExtractedHabit(
            title: habitController.titleController.text,
            colorId: bottomSheetController.selectedColor,
            repeatRule: bottomSheetController.repeatRule,
            reminder: bottomSheetController.reminder, // 리마인더 업데이트
          );
          _items[index] = GeminiItem(
            type: GeminiItemType.habit,
            id: item.id,
            data: updatedHabit,
          );
          // 습관은 날짜 그룹핑이 없으므로 재정렬 불필요
          break;

        case GeminiItemType.sectionHeader:
        case GeminiItemType.dateHeader:
          break;
      }
    });
  }

  /// 하단 버튼
  Widget _buildBottomButton() {
    return Stack(
      children: [
        // 그라데이션 배경
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 150, // 그라데이션 높이
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFAFAFA).withOpacity(0), // 상단 0% (완전 투명)
                    const Color(0xFFFAFAFA), // 하단 100% (불투명)
                  ],
                ),
              ),
            ),
          ),
        ),

        // 버튼
        Container(
          padding: const EdgeInsets.fromLTRB(30, 16, 30, 16), // 좌우 30px
          color: Colors.transparent, // 배경 투명
          child: SafeArea(
            top: false,
            child: GestureDetector(
              onTap: _isSaving ? null : _onAddPressed,
              child: Container(
                width: 333, // Figma: 333px
                height: 56, // Figma: 56px
                decoration: BoxDecoration(
                  color: const Color(0xFF566099), // #566099
                  borderRadius: BorderRadius.circular(24), // Figma: 24px
                ),
                child: Center(
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          '追加する',
                          style: TextStyle(
                            fontFamily: 'LINE Seed JP App_TTF',
                            fontWeight: FontWeight.w700, // 700
                            fontSize: 14, // Figma: 14px
                            height: 1.4, // 140%
                            letterSpacing: -0.005 * 14, // -0.5%
                            color: Color(0xFFFFFFFF), // #FFFFFF
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 추가 버튼
  Future<void> _onAddPressed() async {
    setState(() => _isSaving = true);

    try {
      final database = GetIt.instance<AppDatabase>();
      int savedCount = 0;

      for (var item in _items) {
        if (item.type == GeminiItemType.sectionHeader) continue;

        switch (item.type) {
          case GeminiItemType.schedule:
            final schedule = item.data as ExtractedSchedule;
            await database
                .into(database.schedule)
                .insert(
                  ScheduleCompanion.insert(
                    summary: schedule.summary,
                    start: schedule.start,
                    end: schedule.end,
                    colorId: schedule.colorId,
                    description: Value(schedule.description),
                    location: Value(schedule.location),
                    repeatRule: Value(schedule.repeatRule),
                    timezone: Value(
                      'Asia/Seoul',
                    ), // Default timezone for Gemini-extracted events
                    originalHour: Value(schedule.start.hour),
                    originalMinute: Value(schedule.start.minute),
                  ),
                );
            savedCount++;
            break;

          case GeminiItemType.task:
            final task = item.data as ExtractedTask;
            await database
                .into(database.task)
                .insert(
                  TaskCompanion.insert(
                    title: task.title,
                    colorId: Value(task.colorId),
                    createdAt: DateTime.now(),
                    listId: Value(task.listId),
                    dueDate: Value(task.dueDate),
                    executionDate: Value(task.executionDate),
                    repeatRule: Value(task.repeatRule), // ✅ 반복 규칙 저장
                    reminder: Value(task.reminder), // ✅ 리마인더 저장
                  ),
                );
            savedCount++;
            break;

          case GeminiItemType.habit:
            final habit = item.data as ExtractedHabit;
            await database
                .into(database.habit)
                .insert(
                  HabitCompanion.insert(
                    title: habit.title,
                    repeatRule: habit.repeatRule,
                    colorId: Value(habit.colorId),
                    createdAt: DateTime.now(),
                    reminder: Value(habit.reminder), // ✅ 리마인더 저장
                  ),
                );
            savedCount++;
            break;

          default:
            break;
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$savedCount個の項目を追加しました'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
