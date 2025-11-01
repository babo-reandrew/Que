// ===================================================================
// ⭐️ Gemini Result Date Detail Screen
// ===================================================================
// 디테일뷰에서 이미지 추가 → AI 분석 결과 확인 화면
// 날짜별 그룹핑 → 섹션별 하위 구조 (월뷰와 반대)
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
            repeatRule: task.repeatRule,
            description: '',
            location: '',
          );
        } else if (type == GeminiItemType.habit) {
          final habit = data as ExtractedHabit;
          return ExtractedSchedule(
            summary: habit.title,
            start: defaultTime,
            end: defaultTime.add(const Duration(hours: 1)),
            colorId: habit.colorId,
            repeatRule: habit.repeatRule,
            description: '',
            location: '',
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
            repeatRule: schedule.repeatRule,
            reminder: '',
          );
        } else if (type == GeminiItemType.habit) {
          final habit = data as ExtractedHabit;
          return ExtractedTask(
            title: habit.title,
            dueDate: null,
            executionDate: defaultTime,
            colorId: habit.colorId,
            listId: 'inbox',
            repeatRule: habit.repeatRule,
            reminder: habit.reminder,
          );
        }
        break;

      case GeminiItemType.habit:
        if (type == GeminiItemType.schedule) {
          final schedule = data as ExtractedSchedule;
          return ExtractedHabit(
            title: schedule.summary,
            colorId: schedule.colorId,
            repeatRule: schedule.repeatRule,
            reminder: '',
          );
        } else if (type == GeminiItemType.task) {
          final task = data as ExtractedTask;
          return ExtractedHabit(
            title: task.title,
            colorId: task.colorId,
            repeatRule: task.repeatRule,
            reminder: task.reminder,
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

class GeminiResultDateDetailScreen extends StatefulWidget {
  final List<ExtractedSchedule> schedules;
  final List<ExtractedTask> tasks;
  final List<ExtractedHabit> habits;

  const GeminiResultDateDetailScreen({
    super.key,
    required this.schedules,
    required this.tasks,
    required this.habits,
  });

  @override
  State<GeminiResultDateDetailScreen> createState() =>
      _GeminiResultDateDetailScreenState();
}

class _GeminiResultDateDetailScreenState
    extends State<GeminiResultDateDetailScreen> {
  late List<GeminiItem> _items;
  bool _isSaving = false;
  final Map<String, bool> _sectionHasItems = {}; // 🎯 섹션별 아이템 유무 캐시

  @override
  void initState() {
    super.initState();
    _buildItemList();
    _updateSectionCache(); // 🎯 초기 캐시 생성
  }

  /// 통합 아이템 리스트 생성 (날짜 우선 → 섹션 하위)
  void _buildItemList() {
    _items = [];

    // 🎯 모든 아이템을 날짜별로 그룹핑
    final allItemsByDate = <DateTime?, List<GeminiItem>>{};

    // 스케줄 수집 (startDate 기준)
    for (int i = 0; i < widget.schedules.length; i++) {
      final schedule = widget.schedules[i];
      final dateKey = DateTime(
        schedule.start.year,
        schedule.start.month,
        schedule.start.day,
      );
      final item = GeminiItem.schedule(schedule, i);
      allItemsByDate.putIfAbsent(dateKey, () => []).add(item);
    }

    // 타스크 수집 (executionDate 기준, null이면 "未指定")
    for (int i = 0; i < widget.tasks.length; i++) {
      final task = widget.tasks[i];
      final dateKey = task.executionDate != null
          ? DateTime(
              task.executionDate!.year,
              task.executionDate!.month,
              task.executionDate!.day,
            )
          : null;
      final item = GeminiItem.task(task, i);
      allItemsByDate.putIfAbsent(dateKey, () => []).add(item);
    }

    // 습관 수집 (날짜 없음 → "未指定")
    for (int i = 0; i < widget.habits.length; i++) {
      final habit = widget.habits[i];
      final item = GeminiItem.habit(habit, i);
      allItemsByDate.putIfAbsent(null, () => []).add(item);
    }

    // 🎯 날짜순으로 정렬 (null은 맨 뒤)
    final sortedDates = allItemsByDate.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1; // null은 맨 뒤
        if (b == null) return -1;
        return a.compareTo(b);
      });

    // 🎯 날짜별로 순회하면서 섹션별 하위 구조 생성
    for (final date in sortedDates) {
      final items = allItemsByDate[date]!;

      // 날짜 헤더 추가
      final dateHeader = date != null ? _formatDateHeader(date) : '未指定';
      _items.add(GeminiItem.dateHeader(dateHeader));

      // 이 날짜의 아이템들을 타입별로 분류
      final schedules = items
          .where((i) => i.type == GeminiItemType.schedule)
          .toList();
      final tasks = items.where((i) => i.type == GeminiItemType.task).toList();
      final habits = items
          .where((i) => i.type == GeminiItemType.habit)
          .toList();

      // 섹션별로 추가 (항상 표시, 비어있어도)
      _items.add(GeminiItem.header('スケジュール'));
      if (schedules.isNotEmpty) {
        _items.addAll(schedules);
      }

      _items.add(GeminiItem.header('タスク'));
      if (tasks.isNotEmpty) {
        _items.addAll(tasks);
      }

      _items.add(GeminiItem.header('ルーティン'));
      if (habits.isNotEmpty) {
        _items.addAll(habits);
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
      return '${date.month}月${date.day}日';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Color(0xFFFAFAFA),
                const Color(0xFFFAFAFA).withOpacity(0),
              ],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 28),
                child: GestureDetector(
                  onTap: () async {
                    final confirmed = await showDiscardChangesModal(context);
                    if (confirmed == true && mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE6E6).withOpacity(0.9),
                      border: Border.all(
                        color: const Color(0xFF111111).withOpacity(0.02),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: SvgPicture.asset(
                      'asset/icon/X_icon.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFF0000),
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
              Expanded(
                child: AnimatedReorderableListView(
                  items: _items,
                  padding: EdgeInsets.only(
                    top: topPadding + kToolbarHeight + 32,
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
                  // 🎯 헤더는 드래그 불가능하게 설정
                  buildDefaultDragHandles: true,
                  onReorderStart: (index) {
                    final item = _items[index];
                    // 헤더는 드래그 시작 불가
                    if (item.type == GeminiItemType.dateHeader ||
                        item.type == GeminiItemType.sectionHeader) {
                      return;
                    }
                  },
                  proxyDecorator: (child, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: 4 * 3.14159 / 180,
                          child: Transform.scale(
                            scale: 1.05,
                            child: Opacity(opacity: 0.9, child: child),
                          ),
                        );
                      },
                      child: child,
                    );
                  },
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
              _buildBottomButton(),
            ],
          ),
        ],
      ),
    );
  }

  /// 섹션별 아이템 유무 캐시 업데이트
  void _updateSectionCache() {
    _sectionHasItems.clear();

    for (int i = 0; i < _items.length; i++) {
      if (_items[i].type == GeminiItemType.sectionHeader) {
        final sectionTitle = _items[i].sectionTitle!;

        // 다음 아이템이 카드인지 확인
        final hasItems =
            i + 1 < _items.length &&
            (_items[i + 1].type == GeminiItemType.schedule ||
                _items[i + 1].type == GeminiItemType.task ||
                _items[i + 1].type == GeminiItemType.habit);

        _sectionHasItems[sectionTitle] = hasItems;
      }
    }
  }

  /// 섹션에 아이템이 있는지 확인 (캐시 사용)
  bool _hasSectionItems(String sectionTitle) {
    return _sectionHasItems[sectionTitle] ?? false;
  }

  /// 아이템 빌더
  Widget _buildItem(GeminiItem item, int index) {
    // 날짜 헤더 (今日, 8月2日 등 또는 未指定 점선)
    if (item.type == GeminiItemType.dateHeader) {
      // 未指定인 경우 점선으로 표시
      if (item.sectionTitle == '未指定') {
        return Container(
          key: ValueKey(item.id),
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(0, 64, 0, 8), // 🎯 위 패딩 64px
          child: SizedBox(
            width: 342,
            child: CustomPaint(
              size: const Size(320, 1),
              painter: _DashedLinePainter(),
            ),
          ),
        );
      }

      // 일반 날짜 헤더 (今日, 明日, 8月2日 등)
      return Container(
        key: ValueKey(item.id),
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
        child: SizedBox(
          width: 342,
          child: Text(
            item.sectionTitle!,
            style: const TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF262626),
            ),
          ),
        ),
      );
    }

    // 섹션 헤더 (スケジュール, タスク, ルーティン) - 항상 고정 표시
    if (item.type == GeminiItemType.sectionHeader) {
      // 🎯 캐시에서 해당 섹션에 아이템이 있는지 확인
      final hasItems = _hasSectionItems(item.sectionTitle!);

      return Container(
        key: ValueKey(item.id),
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
        child: SizedBox(
          width: 342,
          child: Text(
            item.sectionTitle!,
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: hasItems
                  ? const Color(0xFF7A7A7A) // 아이템 있음
                  : const Color(0xFF909090), // 아이템 없음 (#909090)
            ),
          ),
        ),
      );
    }

    // 카드 아이템
    return Container(
      key: ValueKey(item.id),
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(width: 342, child: _buildCard(item)),
    );
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
        onTap = () async {
          final currentIndex = _items.indexWhere((i) => i.id == item.id);
          if (currentIndex == -1) return;

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
          repeatRule: task.repeatRule,
          reminder: task.reminder,
          inboxOrder: 0,
        );
        card = TaskCard(task: taskData);
        onTap = () async {
          final currentIndex = _items.indexWhere((i) => i.id == item.id);
          if (currentIndex == -1) return;

          await showTaskDetailWoltModal(
            context,
            task: taskData,
            selectedDate: task.executionDate ?? DateTime.now(),
          );
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
          reminder: habit.reminder,
        );
        card = HabitCard(habit: habitData);
        onTap = () async {
          final currentIndex = _items.indexWhere((i) => i.id == item.id);
          if (currentIndex == -1) return;

          await showHabitDetailWoltModal(
            context,
            habit: habitData,
            selectedDate: DateTime.now(),
          );
          _updateItemAtIndex(currentIndex);
        };
        break;

      default:
        return const SizedBox.shrink();
    }

    final slidableCard = Slidable(
      key: ValueKey(item.id),
      closeOnScroll: true,
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.144,
        dismissible: DismissiblePane(
          dismissThreshold: 0.6,
          closeOnCancel: true,
          confirmDismiss: () async {
            await HapticFeedback.mediumImpact();
            _deleteItem(item);
            return true;
          },
          onDismissed: () {},
        ),
        children: [
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
      child: GestureDetector(onTap: onTap, child: card),
    );

    return Align(alignment: Alignment.center, child: slidableCard);
  }

  /// 아이템 삭제
  void _deleteItem(GeminiItem item) {
    setState(() {
      _items.removeWhere((i) => i.id == item.id);
      _reorganizeSections();
      _updateSectionCache(); // 🎯 캐시 업데이트
    });
  }

  /// 재정렬 핸들러
  void _handleReorder(int oldIndex, int newIndex) {
    final targetIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;

    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(targetIndex, item);
      _checkAndConvertType(targetIndex);
      _updateSectionCache(); // 🎯 캐시 업데이트
    });
  }

  /// 타입 변환 체크
  void _checkAndConvertType(int index) {
    if (index >= _items.length) return;

    final item = _items[index];
    if (item.type == GeminiItemType.sectionHeader ||
        item.type == GeminiItemType.dateHeader) {
      return;
    }

    // 현재 섹션 찾기
    String? currentSection;
    GeminiItemType? targetType;

    // 우선순위 1: 다음 아이템이 섹션 헤더
    if (index < _items.length - 1 &&
        _items[index + 1].type == GeminiItemType.sectionHeader) {
      currentSection = _items[index + 1].sectionTitle;
    }
    // 우선순위 2: 위쪽 섹션 헤더
    else {
      for (int i = index - 1; i >= 0; i--) {
        if (_items[i].type == GeminiItemType.sectionHeader) {
          currentSection = _items[i].sectionTitle;
          break;
        }
      }

      // 우선순위 3: 아래쪽 섹션 헤더
      if (currentSection == null) {
        for (int i = index + 1; i < _items.length; i++) {
          if (_items[i].type == GeminiItemType.sectionHeader) {
            currentSection = _items[i].sectionTitle;
            break;
          }
        }
      }
    }

    // 섹션에 따라 타입 결정
    if (currentSection == 'スケジュール') {
      targetType = GeminiItemType.schedule;
    } else if (currentSection == 'タスク') {
      targetType = GeminiItemType.task;
    } else if (currentSection == 'ルーティン') {
      targetType = GeminiItemType.habit;
    }

    // 타입이 다르면 변환
    if (targetType != null && item.type != targetType) {
      final converted = item.convertToType(targetType);
      _items[index] = GeminiItem(
        type: targetType,
        id: '${targetType.name}_${DateTime.now().millisecondsSinceEpoch}',
        data: converted,
      );
      _reorganizeSections();
    }
  }

  /// 섹션 재정렬 (날짜 우선 → 섹션 하위)
  void _reorganizeSections() {
    // 모든 카드 아이템 수집
    final allItems = _items
        .where(
          (i) =>
              i.type == GeminiItemType.schedule ||
              i.type == GeminiItemType.task ||
              i.type == GeminiItemType.habit,
        )
        .toList();

    // 날짜별로 그룹핑
    final itemsByDate = <DateTime?, List<GeminiItem>>{};

    for (final item in allItems) {
      DateTime? dateKey;

      if (item.type == GeminiItemType.schedule) {
        final schedule = item.data as ExtractedSchedule;
        dateKey = DateTime(
          schedule.start.year,
          schedule.start.month,
          schedule.start.day,
        );
      } else if (item.type == GeminiItemType.task) {
        final task = item.data as ExtractedTask;
        if (task.executionDate != null) {
          dateKey = DateTime(
            task.executionDate!.year,
            task.executionDate!.month,
            task.executionDate!.day,
          );
        }
      }
      // habit은 null (未指定)

      itemsByDate.putIfAbsent(dateKey, () => []).add(item);
    }

    // 날짜순 정렬 (null은 맨 뒤)
    final sortedDates = itemsByDate.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        return a.compareTo(b);
      });

    // 새로운 리스트 구성
    _items.clear();

    for (final date in sortedDates) {
      final items = itemsByDate[date]!;

      // 날짜 헤더
      final dateHeader = date != null ? _formatDateHeader(date) : '未指定';
      _items.add(GeminiItem.dateHeader(dateHeader));

      // 타입별 분류
      final schedules = items
          .where((i) => i.type == GeminiItemType.schedule)
          .toList();
      final tasks = items.where((i) => i.type == GeminiItemType.task).toList();
      final habits = items
          .where((i) => i.type == GeminiItemType.habit)
          .toList();

      // 섹션별 추가 (항상 표시, 비어있어도)
      _items.add(GeminiItem.header('スケジュール'));
      if (schedules.isNotEmpty) {
        _items.addAll(schedules);
      }

      _items.add(GeminiItem.header('タスク'));
      if (tasks.isNotEmpty) {
        _items.addAll(tasks);
      }

      _items.add(GeminiItem.header('ルーティン'));
      if (habits.isNotEmpty) {
        _items.addAll(habits);
      }
    }
  }

  /// Provider에서 변경사항 업데이트
  void _updateItemAtIndex(int index) {
    if (index < 0 || index >= _items.length) return;

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

    // 🎯 먼저 데이터 생성 (setState 밖에서)
    switch (item.type) {
      case GeminiItemType.schedule:
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

        // 🎯 날짜가 변경된 경우에만 재정렬
        if (oldDate != newDate) {
          setState(() {
            _items[index] = GeminiItem(
              type: GeminiItemType.schedule,
              id: item.id,
              data: updatedSchedule,
            );
            _reorganizeSections();
            _updateSectionCache(); // 🎯 캐시 업데이트
          });
        } else {
          // 날짜 변경 없으면 데이터만 업데이트 (깜빡임 없음)
          setState(() {
            _items[index] = GeminiItem(
              type: GeminiItemType.schedule,
              id: item.id,
              data: updatedSchedule,
            );
            // 캐시 업데이트 불필요 (섹션 구조 변경 없음)
          });
        }
        break;

      case GeminiItemType.task:
        final oldTask = item.data as ExtractedTask;
        final updatedTask = ExtractedTask(
          title: taskController.titleController.text,
          colorId: bottomSheetController.selectedColor,
          executionDate: taskController.executionDate,
          dueDate: taskController.dueDate,
          listId: oldTask.listId,
          repeatRule: bottomSheetController.repeatRule,
          reminder: bottomSheetController.reminder,
        );

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

        // 🎯 날짜가 변경된 경우에만 재정렬
        if (oldDate != newDate) {
          setState(() {
            _items[index] = GeminiItem(
              type: GeminiItemType.task,
              id: item.id,
              data: updatedTask,
            );
            _reorganizeSections();
            _updateSectionCache(); // 🎯 캐시 업데이트
          });
        } else {
          // 날짜 변경 없으면 데이터만 업데이트
          setState(() {
            _items[index] = GeminiItem(
              type: GeminiItemType.task,
              id: item.id,
              data: updatedTask,
            );
            // 캐시 업데이트 불필요
          });
        }
        break;

      case GeminiItemType.habit:
        final updatedHabit = ExtractedHabit(
          title: habitController.titleController.text,
          colorId: bottomSheetController.selectedColor,
          repeatRule: bottomSheetController.repeatRule,
          reminder: bottomSheetController.reminder,
        );
        // 습관은 날짜가 없으므로 그냥 업데이트
        setState(() {
          _items[index] = GeminiItem(
            type: GeminiItemType.habit,
            id: item.id,
            data: updatedHabit,
          );
        });
        break;

      case GeminiItemType.sectionHeader:
      case GeminiItemType.dateHeader:
        break;
    }
  }

  /// 하단 버튼
  Widget _buildBottomButton() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFAFAFA).withOpacity(0),
                    const Color(0xFFFAFAFA),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            child: GestureDetector(
              onTap: _isSaving ? null : _onAddPressed,
              child: Container(
                width: 333,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF566099),
                  borderRadius: BorderRadius.circular(24),
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
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 1.4,
                            letterSpacing: -0.005 * 14,
                            color: Color(0xFFFFFFFF),
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
        if (item.type == GeminiItemType.sectionHeader ||
            item.type == GeminiItemType.dateHeader)
          continue;

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
                    timezone: Value('Asia/Seoul'),
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
                    repeatRule: Value(task.repeatRule),
                    reminder: Value(task.reminder),
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
                    reminder: Value(habit.reminder),
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

/// 점선 그리기 (未指定용)
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFE4E4E4) // #E4E4E4
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const dashWidth = 7.0;
    const dashSpace = 7.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
