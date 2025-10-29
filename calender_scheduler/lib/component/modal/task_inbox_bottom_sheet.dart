import 'dart:ui'; // ✅ ImageFilter를 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ HapticFeedback 추가
import 'package:get_it/get_it.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../../Database/schedule_database.dart';
import '../../widgets/task_card.dart';
import '../../widgets/slidable_task_card.dart';
import '../modal/task_detail_wolt_modal.dart';

/// 📋 Task Inbox Bottom Sheet - smooth_sheets 구현
/// ⚠️ DEPRECATED: Navigator 사용 시 DragTarget이 작동하지 않음
/// 대신 HomeScreen의 Stack에서 직접 렌더링하세요:
/// ```dart
/// if (_showTaskInboxSheet)
///   Positioned.fill(
///     child: TaskInboxBottomSheet(onClose: () {...}),
///   )
/// ```
@Deprecated('Use Stack rendering instead of Navigator')
Future<void> showTaskInboxBottomSheet(BuildContext context) async {
  await Navigator.of(context).push(
    ModalSheetRoute(
      builder: (context) => const TaskInboxBottomSheet(),
      barrierColor: Colors.transparent,
      barrierDismissible: true,
    ),
  );
}

class TaskInboxBottomSheet extends StatefulWidget {
  final VoidCallback? onClose; // 📋 닫기 콜백 추가
  final VoidCallback? onDragStart; // 🎯 드래그 시작 콜백 추가
  final VoidCallback? onDragEnd; // 🎯 드래그 종료 콜백 추가
  final bool isDraggingFromParent; // 🎯 부모로부터 드래그 상태 받기

  const TaskInboxBottomSheet({
    super.key,
    this.onClose,
    this.onDragStart, // 🎯 드래그 시작 콜백
    this.onDragEnd, // 🎯 드래그 종료 콜백
    this.isDraggingFromParent = false, // 🎯 기본값 false
  });

  @override
  State<TaskInboxBottomSheet> createState() => _TaskInboxBottomSheetState();
}

class _TaskInboxBottomSheetState extends State<TaskInboxBottomSheet>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'すべて';
  bool _isAIEnabled = true;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterOpacity;
  final SheetController _sheetController = SheetController(); // 🎯 Sheet 컨트롤러

  @override
  void initState() {
    super.initState();
    print('');
    print('╔═══════════════════════════════════════════════════════════════╗');
    print('║  🚀 [LIFECYCLE] TaskInboxBottomSheet.initState()             ║');
    print('╚═══════════════════════════════════════════════════════════════╝');
    print('📊 isDraggingFromParent: ${widget.isDraggingFromParent}');
    print('🎯 onClose callback: ${widget.onClose != null}');
    print('🎯 onDragStart callback: ${widget.onDragStart != null}');
    print('🎯 onDragEnd callback: ${widget.onDragEnd != null}');
    // ✅ 필터 버튼 fade-in 애니메이션
    _filterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _filterOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _filterAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    // Hero 애니메이션 완료 후 필터 버튼 표시
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        print('✅ [TaskInboxBottomSheet] 필터 애니메이션 시작 (300ms 후)');
        _filterAnimationController.forward();
      }
    });
    print('✅ [LIFECYCLE] TaskInboxBottomSheet.initState 완료');
    print('');
  }

  @override
  void didUpdateWidget(TaskInboxBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🔥 드래그 상태 변경 감지하여 즉시 반영
    if (oldWidget.isDraggingFromParent != widget.isDraggingFromParent) {
      print('');
      print('╔═══════════════════════════════════════════════════════════════╗');
      print('║  🔄 [LIFECYCLE] didUpdateWidget - isDragging 변경          ║');
      print('╚═══════════════════════════════════════════════════════════════╝');
      print('📊 이전: ${oldWidget.isDraggingFromParent}');
      print('📊 현재: ${widget.isDraggingFromParent}');
      print('');
      // setState 없이도 AnimatedOpacity가 자동으로 감지
    }
  }

  @override
  void dispose() {
    print('');
    print('╔═══════════════════════════════════════════════════════════════╗');
    print('║  🗑️ [LIFECYCLE] TaskInboxBottomSheet.dispose()              ║');
    print('╚═══════════════════════════════════════════════════════════════╝');
    _filterAnimationController.dispose();
    print('✅ [LIFECYCLE] TaskInboxBottomSheet.dispose 완료');
    print('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('');
    print('╔═══════════════════════════════════════════════════════════════╗');
    print('║  🏗️ [BUILD] TaskInboxBottomSheet.build()                    ║');
    print('╚═══════════════════════════════════════════════════════════════╝');
    print('📊 isDraggingFromParent: ${widget.isDraggingFromParent}');
    print('🎯 _selectedFilter: $_selectedFilter');
    print('🤖 _isAIEnabled: $_isAIEnabled');
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = (screenHeight - safeAreaTop - 8) / screenHeight;

    // 🎯 부모로부터 받은 드래그 상태 사용
    final isDragging = widget.isDraggingFromParent;

    // 🎯 드래그 중일 때는 전체 위젯이 터치를 통과시킴
    return IgnorePointer(
      ignoring: isDragging, // ✅ 드래그 중일 때 전체가 터치 무시
      child: Stack(
        children: [
          // ✅ 1. 바텀시트 (드래그 가능)
          // 🎯 드래그 중에는 바텀시트의 터치를 무시하고 투명하게 만들어 뒤의 캘린더가 보이도록 함
          AnimatedOpacity(
            opacity: isDragging ? 0.0 : 1.0, // ✅ 드래그 중일 때 완전히 투명
            duration: const Duration(milliseconds: 200), // ✅ 부드러운 페이드 아웃
            child: IgnorePointer(
              ignoring: isDragging, // ✅ 드래그 중일 때 터치 무시
              child: ScrollableSheet(
                controller: _sheetController, // 🎯 컨트롤러 연결
                initialExtent: const Extent.proportional(
                  0.16,
                ), // ✅ 초기 높이 16% (가장 낮은 높이)
                physics: BouncingSheetPhysics(
                  parent: SnappingSheetPhysics(
                    snappingBehavior: SnapToNearest(
                      snapTo: [
                        Extent.proportional(0.16), // ✅ 최소 16%
                        Extent.proportional(0.45), // ✅ 중간 45%
                        Extent.proportional(0.88),
                      ],
                    ),
                  ),
                ),
                minExtent: Extent.proportional(0.16), // ✅ 최소 16%
                maxExtent: Extent.proportional(maxHeight),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // ✅ 배경 블러 4
                    child: Material(
                      color: Colors.transparent,
                      clipBehavior: Clip.antiAlias,
                      shape: SmoothRectangleBorder(
                        side: const BorderSide(
                          color: Color(0x0A111111), // ✅ #111111 4%로 변경
                          width: 1,
                        ),
                        borderRadius: SmoothBorderRadius.vertical(
                          top: SmoothRadius(
                            cornerRadius: 36, // ✅ 상단 라운드 36
                            cornerSmoothing: 0.6, // ✅ 피그마 스무싱 60%
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: ShapeDecoration(
                          color: const Color(
                            0xF2FFFFFF,
                          ), // ✅ #FFFFFF 95% (5% 투명)
                          shape: SmoothRectangleBorder(
                            side: const BorderSide(
                              color: Color(0x0A111111), // ✅ #111111 4%로 변경
                              width: 1,
                            ),
                            borderRadius: SmoothBorderRadius.vertical(
                              top: SmoothRadius(
                                cornerRadius: 36,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x14BABABA), // ✅ #BABABA 8%
                              offset: Offset(0, 2), // ✅ y: 2
                              blurRadius: 8, // ✅ blur 8
                            ),
                          ],
                        ),
                        // ✅ Column with drag handle area
                        child: Column(
                          children: [
                            // 🎯 드래그 핸들 영역 - SheetDraggable로 감싸서 smooth_sheets와 연동
                            SheetDraggable(
                              child: Container(
                                color: Colors.transparent, // 터치 영역 확보
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ), // 상하 2px 패딩
                                height: 36, // 32 + 4 (패딩)
                                child: Center(
                                  child: Container(
                                    width: 36,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0x1A111111),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 🎯 TopNavi - 전체를 Stack으로 구성하여 드래그 가능한 영역과 AI 토글 분리
                            SizedBox(
                              height: 40,
                              child: Stack(
                                children: [
                                  // 배경 전체를 드래그 가능하게
                                  Positioned.fill(
                                    child: SheetDraggable(
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  // 실제 TopNavi 컨텐츠 (AI 토글은 터치 받음)
                                  Positioned.fill(child: _buildTopNavi()),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // ✅ 스크롤 가능한 드래그 앤 드롭 리스트
                            Expanded(child: _buildTaskList()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ), // ✅ ScrollableSheet 닫기
            ), // ✅ IgnorePointer 닫기
          ), // ✅ AnimatedOpacity 닫기
          // ✅ 3. 필터바 아래 터치 차단 영역 (그라데이션 블러)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 104, // ✅ 필터바 64px + 하단 40px
            child: Opacity(
              opacity: 0.96, // ✅ 96% 투명도
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 16,
                    sigmaY: 16,
                  ), // ✅ 레이어 블러 16
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0x00FAFAFA), // ✅ #FAFAFA 0%
                          const Color(0x1FFAFAFA), // ✅ #FAFAFA 12%
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // ✅ 2. 필터바 (화면 최하단 고정 - 독립적)
          Positioned(
            bottom: 40, // ✅ 화면 하단에서 40px 떨어짐
            left: 0,
            right: 0,
            child: _buildFilterBar(),
          ),
        ],
      ), // ✅ Stack 닫기
    ); // ✅ IgnorePointer 닫기
  }

  /// TopNavi (40px): タスク + AI Toggle
  Widget _buildTopNavi() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28), // ✅ 좌우만 28px
      child: SizedBox(
        height: 40, // ✅ 40px 높이로 변경
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center, // ✅ 세로 중앙 정렬
          children: [
            // 🎯 텍스트는 터치 무시 (배경의 SheetDraggable이 처리)
            IgnorePointer(
              child: const Text(
                'タスク', // ✅ 変更済み
                style: TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: -0.08,
                  color: Color(0xFF909090),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 🎯 AI Toggle은 터치 받음 (IgnorePointer 없음)
            _buildAIToggle(),
          ],
        ),
      ),
    );
  }

  /// Togle_AiOn (40x24px)
  Widget _buildAIToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isAIEnabled = !_isAIEnabled),
      child: SizedBox(
        width: 40,
        height: 24,
        child: Stack(
          children: [
            Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF566099),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _isAIEnabled ? 18 : 2,
              top: 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEAE7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Frame 805 + Frame 798: Task List (AnimatedReorderableListView)
  Widget _buildTaskList() {
    return StreamBuilder<List<TaskData>>(
      stream: GetIt.I<AppDatabase>()
          .watchInboxTasks(), // ✅ executionDate가 null인 것만
      builder: (context, snapshot) {
        // 🐛 디버그: 스트림 상태 확인
        debugPrint(
          '📥 [TaskInbox] StreamBuilder 상태: hasData=${snapshot.hasData}, connectionState=${snapshot.connectionState}',
        );

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // 🐛 디버그: 받은 데이터 확인
        var tasks = snapshot.data!;
        debugPrint('📥 [TaskInbox] 받은 Task 개수: ${tasks.length}');
        for (var task in tasks) {
          debugPrint(
            '   - Task: "${task.title}", executionDate=${task.executionDate}, dueDate=${task.dueDate}',
          );
        }

        // ✅ 필터 로직 적용
        final filteredTasks = _applyFilter(tasks);
        debugPrint('📥 [TaskInbox] 필터 후 Task 개수: ${filteredTasks.length}');

        if (filteredTasks.isEmpty) {
          return const Center(
            child: Text(
              'タスクがありません',
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF7A7A7A),
              ),
            ),
          );
        }

        // 🔥 전체 리스트를 Listener로 감싸서 포인터 업 감지 (백업용)
        return Listener(
          onPointerUp: (event) {
            // 🔥 손을 떼면 무조건 바텀시트 복구
            print('');
            print(
              '╔═══════════════════════════════════════════════════════════════╗',
            );
            print('║  🖐️ [BACKUP] 리스트 전체에서 포인터 업 감지 (백업)       ║');
            print(
              '╚═══════════════════════════════════════════════════════════════╝',
            );
            print('⏰ 시각: ${DateTime.now()}');
            print('🔄 바텀시트 복구 시작 (100ms 딜레이)...');
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                print('✅ onDragEnd 콜백 호출 (백업)');
                widget.onDragEnd?.call();
              }
            });
            print('');
          },
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 216, // ✅ 필터바 116px + 추가 100px = 216px
            ),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return Padding(
                key: ValueKey(task.id), // ✅ 고유 키 필수
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: SizedBox(
                    width: 345,
                    child: _buildDraggableTaskCard(task),
                  ),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              // ✅ 리스트 재정렬 로직
              print('🔄 [TaskInbox] 재정렬: $oldIndex → $newIndex');
              HapticFeedback.mediumImpact();
              // TODO: DB에 순서 저장
            },
          ), // ReorderableListView
        ); // Listener
      },
    );
  }

  /// 필터 로직
  List<TaskData> _applyFilter(List<TaskData> tasks) {
    // ✅ 일단 모든 필터에서 전체 태스크 반환 (나중에 필터 로직 추가 예정)
    switch (_selectedFilter) {
      case 'すべて':
        return tasks; // 전체

      case '即実行する':
        // TODO: 즉시 실행할 태스크 필터 (마감일이 오늘이거나 지난 것)
        return tasks;

      case '計画する':
        // TODO: 계획할 태스크 필터 (마감일이 미래인 것)
        return tasks;

      case '先送る':
        // TODO: 미룰 태스크 필터 (마감일이 없는 것)
        return tasks;

      case '捨てる':
        // TODO: 버릴 태스크 필터 (완료된 것)
        return tasks;

      case '素早く終える':
        // TODO: 빠르게 끝낼 태스크 필터 (제목이 짧은 것)
        return tasks;

      case '集中する':
        // TODO: 집중할 태스크 필터 (중요한 것)
        return tasks;

      case '色分け':
        // TODO: 색상별 태스크 필터 (색상이 지정된 것)
        return tasks;

      default:
        return tasks;
    }
  }

  /// 🚀 Draggable Task Card: Flutter 기본 LongPressDraggable 사용
  Widget _buildDraggableTaskCard(TaskData task) {
    final taskCard = _buildTaskCard(task);

    return LongPressDraggable<TaskData>(
      data: task, // ✅ TaskData 직접 전달
      feedback: Transform.rotate(
        angle: 0.07, // 🎯 4도 기울임 (약 0.07 라디안)
        child: Opacity(
          opacity: 0.95, // ✅ 드래그 중 95% 투명도
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 345, // ✅ 카드 너비 고정
              child: taskCard,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3, // ✅ 원래 위치 30% 투명도
        child: taskCard,
      ),
      onDragStarted: () {
        print('');
        print(
          '╔═══════════════════════════════════════════════════════════════╗',
        );
        print('║  🎯 [DRAG START] 드래그 시작                                ║');
        print(
          '╚═══════════════════════════════════════════════════════════════╝',
        );
        print('📋 Task: ${task.title} (id=${task.id})');
        print('⏰ 시각: ${DateTime.now()}');
        HapticFeedback.mediumImpact();

        // 🔥 부모에게 드래그 시작 알림
        widget.onDragStart?.call();
        print('✅ onDragStart 콜백 호출 완료');
        print('');
      },
      onDragEnd: (details) {
        print('');
        print(
          '╔═══════════════════════════════════════════════════════════════╗',
        );
        print('║  🎯 [DRAG END] 드래그 종료                                  ║');
        print(
          '╚═══════════════════════════════════════════════════════════════╝',
        );
        print('📋 Task: ${task.title}');
        print('✅ wasAccepted: ${details.wasAccepted}');
        
        // 🔥 부모에게 드래그 종료 알림
        widget.onDragEnd?.call();
        
        if (details.wasAccepted) {
          print('✅ [TaskInbox] 드롭 성공');
          HapticFeedback.heavyImpact(); // ✅ 강한 진동
        } else {
          print('❌ [TaskInbox] 드롭 실패');
          HapticFeedback.lightImpact(); // ✅ 약한 진동
        }
        print('');
      },
      child: taskCard,
    );
  }

  /// Task Card: 기존 SlidableTaskCard + TaskCard 재사용
  Widget _buildTaskCard(TaskData task) {
    return SlidableTaskCard(
      groupTag: 'inbox',
      taskId: task.id,
      repeatRule: task.repeatRule, // 🔄 반복 규칙 전달
      showConfirmDialog: true, // ✅ Inbox에서도 삭제 확인 모달 표시
      onTap: () {
        print('');
        print(
          '╔═══════════════════════════════════════════════════════════════╗',
        );
        print('║  📝 [TASK DETAIL] Task 카드 탭 - Wolt Modal 열기            ║');
        print(
          '╚═══════════════════════════════════════════════════════════════╝',
        );
        print('📋 Task ID: ${task.id}');
        print('📝 Task Title: ${task.title}');
        print('⏰ 현재 시각: ${DateTime.now()}');
        print('🔓 Modal 열기 시작...');
        showTaskDetailWoltModal(
          context,
          task: task,
          selectedDate: DateTime.now(),
        );
        print('✅ showTaskDetailWoltModal 호출 완료');
        print('');
      },
      onComplete: () async =>
          await GetIt.I<AppDatabase>().completeTask(task.id),
      onDelete: () async => await GetIt.I<AppDatabase>().deleteTask(task.id),
      child: TaskCard(
        task: task,
        onToggle: () async {
          if (task.completed) {
            await GetIt.I<AppDatabase>().uncompleteTask(task.id);
          } else {
            await GetIt.I<AppDatabase>().completeTask(task.id);
          }
        },
      ),
    );
  }

  /// Frame 676: Filter Bar (345x64px, bottom fixed) - Figma Perfect Match
  Widget _buildFilterBar() {
    return Container(
      height: 64, // ✅ 64px만 (padding 제거)
      padding: const EdgeInsets.symmetric(horizontal: 24), // ✅ 좌우 패딩 24px
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Stack(
        children: [
          // Rectangle 393: 배경 바 - Hero로 인박스 버튼과 연결
          Positioned.fill(
            child: Hero(
              tag: 'inbox-to-filter', // ✅ Hero 태그로 인박스 버튼과 연결
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEFDFD), // #FEFDFD
                    border: Border.all(
                      color: const Color(0x1A111111), // rgba(17,17,17,0.1)
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33A5A5A5), // rgba(165,165,165,0.2)
                        offset: Offset(0, -2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Frame 895: 필터 버튼들 (horizontal scroll) - Fade In 애니메이션
          Positioned(
            left: 10, // ✅ 좌측 여백 10px
            top: 2,
            right: 10, // ✅ 우측 여백 10px
            child: FadeTransition(
              opacity: _filterOpacity,
              child: SizedBox(height: 60, child: _buildFilterButtons()),
            ),
          ),
        ],
      ),
    );
  }

  /// Frame 895: Filter Buttons (horizontal scroll)
  Widget _buildFilterButtons() {
    final filters = [
      ('すべて', Icons.layers),
      ('即実行する', Icons.play_arrow_rounded),
      ('計画する', Icons.event_outlined),
      ('先送る', Icons.access_time),
      ('捨てる', Icons.delete_outline),
      ('素早く終える', Icons.flash_on),
      ('集中する', Icons.filter_center_focus),
      ('色分け', Icons.palette_outlined),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final isSelected = _selectedFilter == entry.value.$1;
          return Padding(
            padding: EdgeInsets.only(
              right: entry.key < filters.length - 1 ? 16 : 0,
            ),
            child: _buildFilterButton(
              entry.value.$1,
              entry.value.$2,
              isSelected,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Inbox_Button (80x60px) - Figma 완벽 매칭 + 토스 버튼 효과
  Widget _buildFilterButton(String label, IconData icon, bool isSelected) {
    return _TossButton(
      onTap: () {
        print('');
        print(
          '╔═══════════════════════════════════════════════════════════════╗',
        );
        print('║  🔘 [FILTER] 필터 버튼 클릭                                 ║');
        print(
          '╚═══════════════════════════════════════════════════════════════╝',
        );
        print('⏰ 클릭 전 필터: $_selectedFilter');
        print('🔘 클릭한 필터: $label');
        setState(() => _selectedFilter = label);
        print('⏰ setState 후 필터: $_selectedFilter');

        // 🎯 필터 버튼 클릭 시 바텀시트가 최소 높이(16%)면 중간 높이(45%)로 이동
        final currentExtent = _sheetController.value.maybePixels;
        final screenHeight = MediaQuery.of(context).size.height;
        final minHeight = screenHeight * 0.16;

        print('📊 현재 Sheet Extent: $currentExtent px');
        print('📊 최소 높이: $minHeight px (16%)');

        if (currentExtent != null && currentExtent <= minHeight + 10) {
          print('🔼 Sheet 확장 시작: 16% → 45%');
          _sheetController.animateTo(
            const Extent.proportional(0.45),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
        } else {
          print('ℹ️ Sheet 이미 확장되어 있음 - 애니메이션 스킵');
        }
        print('');
      },
      child: Container(
        width: 80,
        height: 60,
        padding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 8,
        ), // ✅ 패딩 제거!
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 27,
              color: isSelected
                  ? const Color(0xFF262626)
                  : const Color(0xFFBABABA),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: -0.005,
                color: isSelected
                    ? const Color(0xFF262626)
                    : const Color(0xFFA5A5A5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 토스 버튼 효과 (7% 축소 + 햅틱)
class _TossButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TossButton({required this.child, required this.onTap});

  @override
  State<_TossButton> createState() => _TossButtonState();
}

class _TossButtonState extends State<_TossButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.93, // ✅ 7% 축소
      upperBound: 1.0,
      duration: const Duration(milliseconds: 100), // ✅ 빠른 반응
    )..value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick(); // ✅ 중간 강도 진동
      },
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(), // ✅ 드래그 취소 시 복원
      child: ScaleTransition(scale: _controller, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
