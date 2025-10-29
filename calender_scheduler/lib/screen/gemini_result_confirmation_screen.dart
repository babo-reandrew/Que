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
enum GeminiItemType { schedule, task, habit, sectionHeader }

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

  /// 섹션 헤더
  factory GeminiItem.header(String title) {
    return GeminiItem(
      type: GeminiItemType.sectionHeader,
      id: 'header_$title',
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
            description: task.description,
            location: task.location,
            repeatRule: '',
          );
        } else if (type == GeminiItemType.habit) {
          final habit = data as ExtractedHabit;
          return ExtractedSchedule(
            summary: habit.title,
            start: defaultTime,
            end: defaultTime.add(const Duration(hours: 1)),
            colorId: habit.colorId,
            description: habit.description,
            location: '',
            repeatRule: habit.repeatRule,
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
            description: schedule.description,
            location: schedule.location,
            listId: 'inbox',
          );
        } else if (type == GeminiItemType.habit) {
          final habit = data as ExtractedHabit;
          return ExtractedTask(
            title: habit.title,
            dueDate: null,
            executionDate: defaultTime,
            colorId: habit.colorId,
            description: habit.description,
            location: '',
            listId: 'inbox',
          );
        }
        break;

      case GeminiItemType.habit:
        if (type == GeminiItemType.schedule) {
          final schedule = data as ExtractedSchedule;
          return ExtractedHabit(
            title: schedule.summary,
            colorId: schedule.colorId,
            description: schedule.description,
            repeatRule: schedule.repeatRule,
          );
        } else if (type == GeminiItemType.task) {
          final task = data as ExtractedTask;
          return ExtractedHabit(
            title: task.title,
            colorId: task.colorId,
            description: task.description,
            repeatRule: '',
          );
        }
        break;

      case GeminiItemType.sectionHeader:
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

    // 1. 스케줄 (값이 있으면)
    if (hasSchedules) {
      _items.add(GeminiItem.header('スケジュール'));
      for (int i = 0; i < widget.schedules.length; i++) {
        _items.add(GeminiItem.schedule(widget.schedules[i], i));
      }
    }

    // 2. 타스크 (값이 있으면)
    if (hasTasks) {
      _items.add(GeminiItem.header('タスク'));
      for (int i = 0; i < widget.tasks.length; i++) {
        _items.add(GeminiItem.task(widget.tasks[i], i));
      }
    }

    // 3. 습관 (값이 있으면)
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
                      // 확인 시 화면 나가기
                      Navigator.of(context).pop();
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
    // 섹션 헤더
    if (item.type == GeminiItemType.sectionHeader) {
      // 해당 섹션에 값이 있는지 확인
      final hasItems = _hasSectionItems(item.sectionTitle!);

      return Container(
        key: ValueKey(item.id),
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
          onDismissed: () {
            print('🗑️ [GeminiConfirmation] 아이템 ID=${item.id} 삭제 완료');
          },
        ),
        children: [
          // 삭제 버튼
          CustomSlidableAction(
            onPressed: (context) async {
              await HapticFeedback.mediumImpact();
              print('🗑️ [GeminiConfirmation] 삭제 버튼 클릭');
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
    print('🗑️ [GeminiConfirmation] 아이템 삭제됨: ${item.type} (${item.id})');
  }

  /// 재정렬 핸들러
  void _handleReorder(int oldIndex, int newIndex) {
    print('');
    print('🔄 ===== Reorder 시작 =====');
    print('   oldIndex: $oldIndex');
    print('   newIndex: $newIndex');
    print('   이동할 아이템: ${_items[oldIndex].type} (${_items[oldIndex].id})');

    // 섹션 헤더 정보 출력
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].type == GeminiItemType.sectionHeader) {
        print('   [섹션 헤더 위치] index=$i, title="${_items[i].sectionTitle}"');
      }
    }

    final targetIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    print('   계산된 targetIndex: $targetIndex');

    setState(() {
      final item = _items.removeAt(oldIndex);
      print('   ✓ 아이템 제거 완료');
      print('   제거 후 리스트 길이: ${_items.length}');

      _items.insert(targetIndex, item);
      print('   ✓ 아이템 삽입 완료 (index: $targetIndex)');
      print('   삽입 후 리스트 길이: ${_items.length}');

      // 삽입된 위치 주변 아이템 확인
      print('   === 주변 아이템 확인 ===');
      if (targetIndex > 0) {
        final prev = _items[targetIndex - 1];
        if (prev.type == GeminiItemType.sectionHeader) {
          print('   이전: [섹션] "${prev.sectionTitle}"');
        } else {
          print('   이전: [${prev.type}] ${prev.id}');
        }
      } else {
        print('   이전: (없음 - 첫 번째 아이템)');
      }

      print('   현재: [${item.type}] ${item.id} ← 이동한 아이템');

      if (targetIndex < _items.length - 1) {
        final next = _items[targetIndex + 1];
        if (next.type == GeminiItemType.sectionHeader) {
          print('   다음: [섹션] "${next.sectionTitle}"');
        } else {
          print('   다음: [${next.type}] ${next.id}');
        }
      } else {
        print('   다음: (없음 - 마지막 아이템)');
      }
      print('   =======================');

      // 섹션 경계를 넘어서 이동한 경우 타입 변환
      print('   타입 변환 체크 시작...');
      _checkAndConvertType(targetIndex);
      print('🔄 ===== Reorder 완료 =====');
      print('');
    });
  }

  /// 타입 변환 체크 (섹션 경계 넘을 때)
  void _checkAndConvertType(int index) {
    if (index >= _items.length) return;

    final item = _items[index];
    if (item.type == GeminiItemType.sectionHeader) {
      print('   ⏭️  섹션 헤더는 변환 안함');
      return;
    }

    print('   🔍 [섹션 감지 시작] index=$index, 현재 타입=${item.type}');

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
      print('   ✨ 다음이 섹션 헤더! → "$currentSection" (index=${index + 1})');
      print('   → 이 섹션에 속하는 것으로 판단!');
    }
    // 우선순위 2: 위쪽으로 올라가면서 섹션 헤더 찾기
    else {
      for (int i = index - 1; i >= 0; i--) {
        if (_items[i].type == GeminiItemType.sectionHeader) {
          currentSection = _items[i].sectionTitle;
          print('   ✓ 발견! 위쪽 섹션 헤더: "$currentSection" (index=$i)');
          break;
        }
      }

      // 우선순위 3: 위쪽에 섹션이 없으면 아래쪽 확인
      if (currentSection == null) {
        print('   ⚠️  위쪽에 섹션 없음! 아래쪽 확인...');
        for (int i = index + 1; i < _items.length; i++) {
          if (_items[i].type == GeminiItemType.sectionHeader) {
            print('   ⚠️  아래쪽 섹션 발견: "${_items[i].sectionTitle}"');
            print('   ⚠️  위쪽 섹션이 없으므로 첫 번째 섹션으로 간주');
            currentSection = _items[i].sectionTitle;
            break;
          }
        }
      }
    }

    // 섹션에 따라 타겟 타입 결정
    if (currentSection == 'スケジュール') {
      targetType = GeminiItemType.schedule;
      print('   → 섹션: "스케줄" → 타겟 타입: schedule');
    } else if (currentSection == 'タスク') {
      targetType = GeminiItemType.task;
      print('   → 섹션: "태스크" → 타겟 타입: task');
    } else if (currentSection == 'ルーティン') {
      targetType = GeminiItemType.habit;
      print('   → 섹션: "루틴" → 타겟 타입: habit');
    } else {
      print('   ❌ 섹션을 찾을 수 없음!');
    }

    // 타입이 다르면 변환
    if (targetType != null && item.type != targetType) {
      print('   🔄 [타입 변환] ${item.type} → $targetType');
      final converted = item.convertToType(targetType);
      _items[index] = GeminiItem(
        type: targetType,
        id: '${targetType.name}_${DateTime.now().millisecondsSinceEpoch}',
        data: converted,
      );
      print('   ✅ 변환 완료!');

      // 🎯 변환 후 올바른 섹션으로 재배치 + 섹션 재정렬
      print('   🎯 섹션 재정렬 시작...');
      _reorganizeSections();
      print('   ✅ 섹션 재정렬 완료!');
    } else if (targetType == null) {
      print('   ⚠️  targetType이 null → 변환 안함');
    } else {
      print('   ✓ 타입 동일 → 변환 불필요 (${item.type})');
    }
  }

  /// 섹션 재정렬: 내용이 있는 섹션을 위로, 순서는 스케줄 → 타스크 → 습관
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

    print(
      '   분류 결과: 스케줄=${schedules.length}, 태스크=${tasks.length}, 습관=${habits.length}',
    );

    // 2. 새로운 리스트 구성
    _items.clear();

    // 값이 있는 섹션들 (스케줄 → 타스크 → 습관 순서)
    if (schedules.isNotEmpty) {
      _items.add(GeminiItem.header('スケジュール'));
      _items.addAll(schedules);
    }
    if (tasks.isNotEmpty) {
      _items.add(GeminiItem.header('タスク'));
      _items.addAll(tasks);
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

    print('   재정렬 후 총 아이템 수: ${_items.length}');
  }

  /// Provider에서 변경사항을 가져와 특정 인덱스의 아이템만 업데이트 (메모리만 업데이트, DB 저장 X)
  void _updateItemAtIndex(int index) {
    print('');
    print('🔄 ===== Provider 업데이트 시작 =====');
    print('   업데이트할 인덱스: $index');

    if (index < 0 || index >= _items.length) {
      print('   ❌ 유효하지 않은 인덱스!');
      return;
    }

    final item = _items[index];
    if (item.type == GeminiItemType.sectionHeader) {
      print('   ⏭️  섹션 헤더는 업데이트 안함');
      return;
    }

    print('   아이템 ID: ${item.id}, 타입: ${item.type}');

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

    print('   Provider 색상: ${bottomSheetController.selectedColor}');
    print('   Provider 반복: ${bottomSheetController.repeatRule}');

    setState(() {
      switch (item.type) {
        case GeminiItemType.schedule:
          // Provider에서 업데이트된 스케줄 정보 가져오기
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
            description: (item.data as ExtractedSchedule).description,
            location: (item.data as ExtractedSchedule).location,
          );
          _items[index] = GeminiItem(
            type: GeminiItemType.schedule,
            id: item.id,
            data: updatedSchedule,
          );
          print('   ✅ 스케줄 업데이트 완료!');
          print('      제목: ${updatedSchedule.summary}');
          print('      색상: ${updatedSchedule.colorId}');
          print('      반복: ${updatedSchedule.repeatRule}');
          break;

        case GeminiItemType.task:
          // Provider에서 업데이트된 타스크 정보 가져오기
          final updatedTask = ExtractedTask(
            title: taskController.titleController.text,
            colorId: bottomSheetController.selectedColor,
            executionDate: taskController.executionDate,
            dueDate: taskController.dueDate,
            listId: (item.data as ExtractedTask).listId,
            description: (item.data as ExtractedTask).description,
            location: (item.data as ExtractedTask).location,
            repeatRule: bottomSheetController.repeatRule, // 반복 규칙 업데이트
            reminder: bottomSheetController.reminder, // 리마인더 업데이트
          );
          _items[index] = GeminiItem(
            type: GeminiItemType.task,
            id: item.id,
            data: updatedTask,
          );
          print('   ✅ 타스크 업데이트 완료!');
          print('      제목: ${updatedTask.title}');
          print('      색상: ${updatedTask.colorId}');
          print('      실행일: ${updatedTask.executionDate}');
          print('      마감일: ${updatedTask.dueDate}');
          print('      반복: ${updatedTask.repeatRule}');
          print('      리마인더: ${updatedTask.reminder}');
          break;

        case GeminiItemType.habit:
          // Provider에서 업데이트된 습관 정보 가져오기
          final updatedHabit = ExtractedHabit(
            title: habitController.titleController.text,
            colorId: bottomSheetController.selectedColor,
            repeatRule: bottomSheetController.repeatRule,
            description: (item.data as ExtractedHabit).description,
            reminder: bottomSheetController.reminder, // 리마인더 업데이트
          );
          _items[index] = GeminiItem(
            type: GeminiItemType.habit,
            id: item.id,
            data: updatedHabit,
          );
          print('   ✅ 습관 업데이트 완료!');
          print('      제목: ${updatedHabit.title}');
          print('      색상: ${updatedHabit.colorId}');
          print('      반복: ${updatedHabit.repeatRule}');
          print('      리마인더: ${updatedHabit.reminder}');
          break;

        case GeminiItemType.sectionHeader:
          break;
      }
    });

    print('🔄 ===== Provider 업데이트 완료 =====');
    print('');
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
      print('❌ 저장 오류: $e');
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
