import 'package:flutter/material.dart';
import '../component/schedule_card.dart';
import '../component/create_entry_bottom_sheet.dart';
import '../component/keyboard_attachable_input_view.dart'; // 🆕 KeyboardAttachable 추가
import '../component/slidable_schedule_card.dart'; // ✅ Slidable 컴포넌트 추가
import '../component/modal/task_detail_wolt_modal.dart'; // ✅ 할일 상세 Wolt 모달
import '../component/modal/habit_detail_wolt_modal.dart'; // ✅ 습관 상세 Wolt 모달
import '../component/modal/schedule_detail_wolt_modal.dart'; // ✅ 일정 상세 Wolt 모달
import '../component/modal/option_setting_wolt_modal.dart'; // ✅ OptionSetting Wolt 모달 (Detached)
import '../widgets/bottom_navigation_bar.dart'; // ✅ 하단 네비게이션 바 추가
import '../widgets/temp_input_box.dart'; // ✅ 임시 입력 박스 추가
import '../widgets/date_detail_header.dart'; // ✅ 날짜 헤더 위젯 추가
import '../widgets/task_card.dart'; // ✅ TaskCard 추가
import '../widgets/habit_card.dart'; // ✅ HabitCard 추가
import '../widgets/slidable_task_card.dart'; // ✅ SlidableTaskCard 추가
import '../widgets/slidable_habit_card.dart'; // ✅ SlidableHabitCard 추가
import '../widgets/completed_section.dart'; // ✅ CompletedSection 추가
import '../widgets/dashed_divider.dart'; // ✅ DashedDivider 추가
import '../screen/completed_detail_screen.dart'; // ✅ CompletedDetailScreen 추가
import '../const/color.dart';
import '../Database/schedule_database.dart';
import 'package:get_it/get_it.dart';

/// 선택된 날짜의 상세 스케줄을 리스트 형태로 표시하는 화면
/// ⭐️ DB 통합: StreamBuilder를 사용해서 해당 날짜의 일정을 실시간으로 관찰한다
/// 이거를 설정하고 → watchByDay()로 DB 스트림을 구독해서
/// 이거를 해서 → 일정이 추가/삭제될 때마다 자동으로 UI가 갱신된다
/// 이거는 이래서 → setState 없이도 실시간 반영이 가능하다
/// ✅ StatefulWidget 전환: 좌우 스와이프 및 Pull-to-dismiss 기능을 위해 상태 관리 필요
class DateDetailView extends StatefulWidget {
  final DateTime selectedDate; // 선택된 날짜를 저장하는 변수

  const DateDetailView({
    super.key,
    required this.selectedDate, // 선택된 날짜를 필수로 받는다
  });

  @override
  State<DateDetailView> createState() => _DateDetailViewState();
}

class _DateDetailViewState extends State<DateDetailView> {
  late DateTime _currentDate; // 현재 표시 중인 날짜 (좌우 스와이프로 변경됨)
  late PageController _pageController; // 좌우 스와이프를 위한 PageController
  late ScrollController _scrollController; // ✅ 리스트 스크롤 제어용 (Pull-to-dismiss)
  double _dragOffset = 0.0; // Pull-to-dismiss를 위한 드래그 오프셋

  // 무한 스크롤을 위한 중앙 인덱스 (충분히 큰 수)
  static const int _centerIndex = 1000000;

  @override
  void initState() {
    super.initState();
    // 이거를 설정하고 → 기존 selectedDate를 현재 날짜로 초기화해서
    _currentDate = widget.selectedDate;
    // 이거를 해서 → 무한 스크롤을 위한 PageController 생성한다 (중앙 인덱스부터 시작)
    _pageController = PageController(initialPage: _centerIndex);
    // ✅ 리스트 스크롤 컨트롤러 초기화 (리스트 최상단 감지용)
    _scrollController = ScrollController();
    print('📅 [DateDetailView] 초기화 완료 - 날짜: $_currentDate');
  }

  @override
  void dispose() {
    // 이거를 설정하고 → 메모리 누수 방지를 위해 컨트롤러 정리
    _pageController.dispose();
    _scrollController.dispose(); // ✅ ScrollController도 정리
    print('🗑️ [DateDetailView] 리소스 정리 완료');
    super.dispose();
  }

  // 이거를 설정하고 → 인덱스를 실제 날짜로 변환하는 함수
  // 이거를 해서 → 중앙 인덱스 기준으로 상대적 날짜를 계산한다
  DateTime _getDateForIndex(int index) {
    final daysDiff = index - _centerIndex;
    return widget.selectedDate.add(Duration(days: daysDiff));
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 전체 화면 Hero: 월뷰 → 디테일뷰 전환 시 확대 효과
    return Hero(
      tag:
          'calendar-cell-${widget.selectedDate.year}-${widget.selectedDate.month}-${widget.selectedDate.day}',
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          // 이거를 해서 → 수직 드래그 업데이트를 실시간으로 감지한다
          onVerticalDragUpdate: _handleDragUpdate,
          // 이거는 이래서 → 드래그 종료 시 dismiss 여부를 판단한다
          onVerticalDragEnd: _handleDragEnd,
          child: Transform.translate(
            // 이거라면 → 드래그 오프셋만큼 화면을 이동시킨다
            offset: Offset(0, _dragOffset),
            child: Scaffold(
              // 앱바를 설정해서 뒤로가기 버튼과 제목을 표시한다
              appBar: _buildAppBar(context),
              // 배경색을 밝은 회색으로 설정해서 깔끔한 느낌을 만든다
              backgroundColor: gray050,
              resizeToAvoidBottomInset: false, // ✅ KeyboardAttachable 필수 설정!
              // ⭐️ PageView로 좌우 스와이프 날짜 변경 기능 추가 (기존 Hero 구조 유지)
              body: Stack(
                children: [
                  // 메인 컨텐츠
                  _buildPageView(),

                  // ✅ 하단 임시 입력 박스 (Figma 2447-60074, 2447-59689)
                  // 이거를 설정하고 → 하단에 고정 위치로 배치해서
                  // 이거를 해서 → 캐시된 임시 입력을 표시한다
                  // 이거는 이래서 → Figma 디자인대로 정확한 위치에 나타난다
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20, // 하단 네비게이션 바 위에 배치
                    child: TempInputBox(
                      onTap: () {
                        // 이거를 설정하고 → 임시 박스 클릭 시 QuickAdd를 다시 열어서
                        // 이거를 해서 → 사용자가 이어서 작업할 수 있다
                        showModalBottomSheet(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.0),
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.95),
                                  Colors.white,
                                ],
                                stops: [0.0, 0.3, 1.0],
                              ),
                            ),
                            child: CreateEntryBottomSheet(
                              selectedDate: _currentDate,
                            ),
                          ),
                        );
                        print('📦 [TempBox] 임시 박스 클릭 → QuickAdd 재열기');
                      },
                      onDismiss: () {
                        // 이거라면 → 삭제 시 상태를 새로고침한다
                        setState(() {});
                        print('🗑️ [TempBox] 임시 박스 삭제 완료');
                      },
                    ),
                  ),
                ],
              ),
              // ✅ FloatingActionButton 제거 → 하단 네비게이션 바로 대체
              // ✅ 하단 네비게이션 바 추가 (피그마: Frame 822)
              bottomNavigationBar: CustomBottomNavigationBar(
                onInboxTap: () {
                  print('📥 [하단 네비] Inbox 버튼 클릭');
                  // TODO: Inbox 화면으로 이동
                },
                onStarTap: () {
                  print('⭐ [하단 네비] 별 버튼 클릭');
                  // TODO: 즐겨찾기 화면으로 이동
                },
                onAddTap: () {
                  // 🆕 KeyboardAttachable 방식으로 변경!
                  _showKeyboardAttachableQuickAdd();

                  // ⚠️ 기존 방식 (테스트 완료 후 제거 예정)
                  // showModalBottomSheet(
                  //   context: context,
                  //   barrierColor: Colors.black.withOpacity(0.0),
                  //   backgroundColor: Colors.transparent,
                  //   builder: (context) => Container(
                  //     decoration: BoxDecoration(
                  //       gradient: LinearGradient(
                  //         begin: Alignment.topCenter,
                  //         end: Alignment.bottomCenter,
                  //         colors: [
                  //           Colors.white.withOpacity(0.0),
                  //           Colors.white.withOpacity(0.95),
                  //           Colors.white,
                  //         ],
                  //         stops: [0.0, 0.3, 1.0],
                  //       ),
                  //     ),
                  //     child: CreateEntryBottomSheet(selectedDate: _currentDate),
                  //   ),
                  // );
                  // print('➕ [하단 네비] 일정 추가 버튼 클릭 → 바텀시트 표시');
                },
                isStarSelected: false, // TODO: 상태 관리
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================================
  // ✅ Pull-to-Dismiss 제스처 핸들러
  // ========================================

  /// 이거를 설정하고 → 드래그 업데이트 이벤트를 처리해서
  /// 이거를 해서 → 드래그 오프셋을 실시간으로 업데이트한다
  /// ✅ 오버라이딩: 리스트 최상단/최하단일 때 동작하도록 개선
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_scrollController.hasClients) {
      setState(() {
        _dragOffset += details.delta.dy;
        if (_dragOffset < 0) _dragOffset = 0;
      });
      print('👆 [Pull-to-Dismiss] 드래그 중 (스크롤 없음): $_dragOffset');
      return;
    }

    // ✅ 리스트 최상단/최하단 확인
    final isAtTop = _scrollController.offset <= 0;
    final isAtBottom =
        _scrollController.offset >= _scrollController.position.maxScrollExtent;

    // 이거를 설정하고 → 최상단/최하단에서 아래로 드래그할 때만 동작
    if ((isAtTop && details.delta.dy > 0) ||
        (isAtBottom && details.delta.dy > 0)) {
      setState(() {
        // 이거를 설정하고 → 드래그 거리를 누적해서
        _dragOffset += details.delta.dy;
        // 이거를 해서 → 위로 드래그는 무시한다 (음수 방지)
        if (_dragOffset < 0) _dragOffset = 0;
      });
      print(
        '👆 [Pull-to-Dismiss] 드래그 중 (최상단=$isAtTop, 최하단=$isAtBottom): $_dragOffset',
      );
    }
  }

  /// 이거를 설정하고 → 드래그 종료 이벤트를 처리해서
  /// 이거를 해서 → dismiss 여부를 판단하고 실행한다
  /// ✅ 기존 로직 유지 (재사용)
  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    final progress = _dragOffset / MediaQuery.of(context).size.height;

    print(
      '✋ [Pull-to-Dismiss] 드래그 종료 - 속도: $velocity, 진행률: ${(progress * 100).toStringAsFixed(1)}%',
    );

    // 이거는 이래서 → 속도(500px/s 이상) 또는 진행률(30% 이상)이 임계값 초과하면
    if (velocity > 500 || progress > 0.3) {
      // 이거라면 → 기존 Navigator.pop() 방식 그대로 사용해서 HomeScreen으로 복귀
      print('✅ [Pull-to-Dismiss] Dismiss 실행 → HomeScreen 복귀');
      Navigator.of(context).pop();
    } else {
      // 이거를 설정하고 → 임계값 미만이면 원위치로 복귀시킨다
      print('↩️ [Pull-to-Dismiss] 원위치 복귀');
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  // ========================================
  // ✅ PageView 구현 (좌우 스와이프 날짜 변경)
  // ========================================

  /// 이거를 설정하고 → PageView를 구성해서 좌우 스와이프 날짜 변경 기능 제공
  /// 이거를 해서 → 기존 Hero 구조를 그대로 유지하면서 무한 스크롤 구현
  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          // 이거를 설정하고 → 인덱스를 날짜로 변환해서
          _currentDate = _getDateForIndex(index);
          print('📆 [PageView] 날짜 변경: $_currentDate');
        });
      },
      itemBuilder: (context, index) {
        final date = _getDateForIndex(index);
        // ✅ Hero 제거: 카드별 Hero와 충돌 방지
        // 이유: ConditionalHeroWrapper가 각 카드에 Hero를 적용하므로
        //       PageView 전체를 Hero로 감싸면 중첩 에러 발생
        return Material(
          color: gray050,
          // 이거는 이래서 → 기존 _buildBody 함수 재사용
          child: _buildBody(context, date),
        );
      },
    );
  }

  /// 앱바를 구성하는 함수 - 피그마 디자인: ⋯ 버튼 + 날짜 + v 버튼
  /// 이거를 설정하고 → 좌측에 설정(⋯), 중앙에 날짜, 우측에 닫기(v) 버튼을 배치해서
  /// 이거를 해서 → 피그마 디자인과 동일한 레이아웃을 만든다
  /// 이거는 이래서 → iOS 네이티브 앱과 유사한 UX를 제공한다
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: gray050, // 배경색을 화면과 동일하게 설정
      elevation: 0, // 그림자 제거
      automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
      // ✅ 좌측: 설정 버튼 (⋯ 세 점)
      leading: Container(
        margin: const EdgeInsets.only(left: 12),
        child: IconButton(
          padding: EdgeInsets.zero, // ✅ 기본 패딩 제거
          constraints: const BoxConstraints(), // ✅ 최소 크기 제약 제거
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E4E4).withOpacity(0.9),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: const Color(0xFF111111).withOpacity(0.02),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.more_horiz,
              color: Color(0xFF111111),
              size: 20,
            ),
          ),
          onPressed: () {
            debugPrint(
              '⋮ [UI] 앱바 좌측 메뉴 버튼 클릭 → OptionSetting Wolt Modal (Detached) 표시',
            );
            showOptionSettingWoltModal(context);
          },
        ),
      ),

      // ✅ 수정: 중앙 텍스트 제거 (Figma 디자인에 따라)
      title: null,
      centerTitle: true,

      // ✅ 우측: 닫기 버튼 (v 아래 화살표)
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: IconButton(
            padding: EdgeInsets.zero, // ✅ 기본 패딩 제거
            constraints: const BoxConstraints(), // ✅ 최소 크기 제약 제거
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E4E4).withOpacity(0.9),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: const Color(0xFF111111).withOpacity(0.02),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF111111),
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              print('⬇️ [UI] 닫기 버튼 클릭 → HomeScreen으로 복귀');
            },
          ),
        ),
      ],
    );
  }

  /// 일본어 요일 변환 함수 (삭제됨 - DateDetailHeader에서 직접 처리)

  /// 스케줄 리스트를 구성하는 함수 (삭제됨 - _buildUnifiedList 사용)  /// 메인 바디를 구성하는 함수 - 피그마 디자인: 날짜 헤더 + 스케줄 리스트
  /// 이거를 설정하고 → 상단에 DateDetailHeader를 추가하고
  /// 이거를 해서 → Figma 디자인과 동일한 레이아웃을 만든다
  /// 이거는 이래서 → 시각적으로 명확한 날짜 정보를 제공한다
  /// ✅ 날짜 매개변수 추가: PageView에서 각 페이지마다 다른 날짜 표시
  Widget _buildBody(BuildContext context, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================================================
        // ✅ 새로운 날짜 헤더 (Figma: Frame 830, Frame 893)
        // ===================================================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: DateDetailHeader(
            selectedDate: date,
            onSettingsTap: () {
              showOptionSettingWoltModal(context);
              debugPrint(
                '⚙️ [DateDetailView] 설정 버튼 클릭 → OptionSetting Wolt Modal (Detached) 표시',
              );
            },
          ),
        ),

        // ===================================================================
        // ✅ 통합 리스트 (일정 + 할일 + 습관 + 완료)
        // ===================================================================
        Expanded(child: _buildUnifiedList(date)),
      ],
    );
  }

  /// 날짜 헤더 위젯 - 피그마 디자인 기준 (삭제됨 - DateDetailHeader 위젯 사용)
  /// 이제 _buildDateHeader는 사용하지 않습니다

  /// 통합 리스트를 구성하는 함수
  /// 이거를 설정하고 → 일정, 할일, 습관, 완료 섹션을 하나의 스크롤 뷰에 통합해서
  /// 이거를 해서 → Figma 디자인대로 순서와 구분선을 표시한다
  /// 이거는 이래서 → 사용자가 모든 항목을 한 화면에서 확인할 수 있다
  Widget _buildUnifiedList(DateTime date) {
    return StreamBuilder<List<ScheduleData>>(
      stream: GetIt.I<AppDatabase>().watchByDay(date),
      builder: (context, scheduleSnapshot) {
        // 이거를 설정하고 → Task와 Habit도 동시에 스트림으로 가져온다
        return StreamBuilder<List<TaskData>>(
          stream: GetIt.I<AppDatabase>().watchTasks(),
          builder: (context, taskSnapshot) {
            return StreamBuilder<List<HabitData>>(
              stream: GetIt.I<AppDatabase>().watchHabits(),
              builder: (context, habitSnapshot) {
                // 로딩 체크
                if (!scheduleSnapshot.hasData ||
                    !taskSnapshot.hasData ||
                    !habitSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final schedules = scheduleSnapshot.data!;
                final tasks = taskSnapshot.data!;
                final habits = habitSnapshot.data!;

                // 이거를 해서 → 완료된 항목과 미완료 항목 분리
                final incompleteTasks = tasks
                    .where((t) => !t.completed)
                    .toList();
                final completedTasks = tasks.where((t) => t.completed).toList();

                print(
                  '✅ [UnifiedList] 일정:${schedules.length}, 할일:${incompleteTasks.length}, 습관:${habits.length}, 완료:${completedTasks.length}',
                );

                return CustomScrollView(
                  controller:
                      _scrollController, // ✅ ScrollController 연결 (리스트 최상단 감지)
                  slivers: [
                    // ===============================================
                    // 1. 일정 섹션 (시간순)
                    // ===============================================
                    if (schedules.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final schedule = schedules[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: GestureDetector(
                                onTap: () => _openScheduleDetail(schedule),
                                child: SlidableScheduleCard(
                                  groupTag: 'unified_list',
                                  scheduleId: schedule.id,
                                  onComplete: () async {
                                    await GetIt.I<AppDatabase>()
                                        .completeSchedule(schedule.id);
                                  },
                                  onDelete: () async {
                                    await GetIt.I<AppDatabase>().deleteSchedule(
                                      schedule.id,
                                    );
                                  },
                                  child: ScheduleCard(
                                    start: schedule.start,
                                    end: schedule.end,
                                    summary: schedule.summary,
                                    colorId: schedule.colorId,
                                  ),
                                ),
                              ),
                            );
                          }, childCount: schedules.length),
                        ),
                      ),

                    // ===============================================
                    // 2. 점선 구분선 (Figma: Vector 88)
                    // ===============================================
                    if (schedules.isNotEmpty &&
                        (incompleteTasks.isNotEmpty || habits.isNotEmpty))
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: const DashedDivider(),
                        ),
                      ),

                    // ===============================================
                    // 3. 할일 섹션 (추가순)
                    // ===============================================
                    if (incompleteTasks.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final task = incompleteTasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: SlidableTaskCard(
                                groupTag: 'unified_list',
                                taskId: task.id,
                                onTap: () =>
                                    _openTaskDetail(task), // ✅ onTap 추가!
                                onComplete: () async {
                                  // 이거를 설정하고 → 완료 토글
                                  await GetIt.I<AppDatabase>().completeTask(
                                    task.id,
                                  );
                                  print('✅ [TaskCard] 완료 토글: ${task.title}');
                                },
                                onDelete: () async {
                                  // 이거를 해서 → 할일 삭제 (나중에 Inbox로 이동 기능 추가 예정)
                                  await GetIt.I<AppDatabase>().deleteTask(
                                    task.id,
                                  );
                                  print('🗑️ [TaskCard] 삭제: ${task.title}');
                                },
                                child: TaskCard(
                                  task: task,
                                  onToggle: () async {
                                    // 이거를 설정하고 → 체크박스 클릭 시에도 완료 토글
                                    await GetIt.I<AppDatabase>().completeTask(
                                      task.id,
                                    );
                                    print(
                                      '✅ [TaskCard] 체크박스 완료 토글: ${task.title}',
                                    );
                                  },
                                ),
                              ),
                            );
                          }, childCount: incompleteTasks.length),
                        ),
                      ),

                    // ===============================================
                    // 4. 습관 섹션 (시간순 → 추가순)
                    // ===============================================
                    if (habits.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final habit = habits[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: GestureDetector(
                                onTap: () => _showHabitDetailModal(habit, date),
                                child: SlidableHabitCard(
                                  groupTag: 'unified_list',
                                  habitId: habit.id,
                                  onComplete: () async {
                                    // 이거를 해서 → 오늘 날짜로 완료 기록
                                    await GetIt.I<AppDatabase>()
                                        .recordHabitCompletion(habit.id, date);
                                    print(
                                      '✅ [HabitCard] 완료 기록: ${habit.title}',
                                    );
                                  },
                                  onDelete: () async {
                                    // 이거라면 → 습관 삭제
                                    await GetIt.I<AppDatabase>().deleteHabit(
                                      habit.id,
                                    );
                                    print('🗑️ [HabitCard] 삭제: ${habit.title}');
                                  },
                                  child: HabitCard(
                                    habit: habit,
                                    isCompleted:
                                        false, // TODO: HabitCompletion 확인
                                    onToggle: () async {
                                      // 이거를 설정하고 → 체크박스 클릭 시에도 완료 기록
                                      await GetIt.I<AppDatabase>()
                                          .recordHabitCompletion(
                                            habit.id,
                                            date,
                                          );
                                      print(
                                        '✅ [HabitCard] 체크박스 완료 기록: ${habit.title}',
                                      );
                                    },
                                    onTap: () {
                                      print('🔁 [HabitCard] 탭: ${habit.title}');
                                      // ✅ Wolt 습관 상세 모달 표시
                                      _showHabitDetailModal(habit, date);
                                    },
                                  ),
                                ),
                              ),
                            );
                          }, childCount: habits.length),
                        ),
                      ),

                    // ===============================================
                    // 5. 완료 섹션 (Figma: Complete_ActionData)
                    // ===============================================
                    if (completedTasks.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: CompletedSection(
                            completedCount: completedTasks.length,
                            onTap: () {
                              print(
                                '📦 [CompletedSection] 탭 → CompletedDetailScreen 이동',
                              );
                              // 완료된 항목 필터링
                              final completedSchedules = schedules
                                  .where((s) => s.status == 'completed')
                                  .toList();
                              final completedTaskList = tasks
                                  .where((t) => t.completed)
                                  .toList();
                              final completedHabitList = habits
                                  .where(
                                    (h) => false,
                                  ) // TODO: HabitCompletion 조회
                                  .toList();

                              // 전체 화면으로 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompletedDetailScreen(
                                    completedCount:
                                        completedTaskList.length +
                                        completedHabitList.length +
                                        completedSchedules.length,
                                    completedSchedules: completedSchedules,
                                    completedTasks: completedTaskList,
                                    completedHabits: completedHabitList,
                                    onUncompleteSchedule: (id) async {
                                      // TODO: 일정 완료 해제
                                      Navigator.pop(context);
                                    },
                                    onUncompleteTask: (id) async {
                                      await GetIt.I<AppDatabase>()
                                          .uncompleteTask(id);
                                      Navigator.pop(context);
                                    },
                                    onUncompleteHabit: (id) async {
                                      // TODO: 습관 완료 해제
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                            isExpanded: false,
                          ),
                        ),
                      ),

                    // 하단 여백
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ============================================================================
  // ⭐️ iOS 네이티브 스타일 상세 페이지 열기 함수들
  // ============================================================================

  /// 일정 상세 Wolt 모달 열기
  void _openScheduleDetail(ScheduleData schedule) {
    debugPrint('🎯 [DateDetailView] 일정 상세 열기: ${schedule.summary}');

    showScheduleDetailWoltModal(
      context,
      schedule: schedule,
      selectedDate: schedule.start,
    );
  }

  /// 할일 상세 - Wolt Modal로 변경
  void _openTaskDetail(TaskData task) {
    print('🎯 [DateDetailView] 할일 상세 열기: ${task.title}');

    showTaskDetailWoltModal(context, task: task, selectedDate: _currentDate);
  }

  /// ✅ Wolt 습관 상세 모달 표시
  /// Figma 스펙을 100% 구현한 WoltModalSheet 기반 습관 상세 화면
  void _showHabitDetailModal(HabitData habit, DateTime date) {
    print('🎯 [DateDetailView] Wolt 습관 상세 열기: ${habit.title}');

    showHabitDetailWoltModal(context, habit: habit, selectedDate: date);
  }

  /// 스케줄 리스트를 구성하는 함수 (삭제됨 - _buildUnifiedList 사용)
}

// ============================================================================
// 🆕 KEYBOARD_ATTACHABLE 마이그레이션 - 기존 코드 건들지 않고 새 함수 추가!
// ============================================================================
//
// ⚠️ **중요: 기존 onAddTap() 로직은 그대로 유지!**
// - 이 함수들은 새로운 keyboard_attachable 방식을 테스트하기 위한 것
// - 기존 showModalBottomSheet 방식과 병행 사용 가능
// - 검증 완료 후에만 기존 코드 제거
//
// **새로운 방식의 장점:**
// 1. iOS inputAccessoryView 완벽 구현 (키보드에 정확히 붙음!)
// 2. 키보드와 함께 자연스러운 애니메이션
// 3. Figma 디자인 5가지 상태 완벽 지원
// 4. 백그라운드 블러 효과 (Rectangle 385)
// ============================================================================

extension KeyboardAttachableQuickAdd on _DateDetailViewState {
  /// 🆕 KeyboardAttachable 방식으로 QuickAdd 표시
  ///
  /// 기존 방식:
  /// ```dart
  /// showModalBottomSheet(
  ///   context: context,
  ///   builder: (context) => CreateEntryBottomSheet(selectedDate: _currentDate),
  /// );
  /// ```
  ///
  /// 신규 방식 (병행 테스트):
  /// ```dart
  /// _showKeyboardAttachableQuickAdd();
  /// ```
  void _showKeyboardAttachableQuickAdd() {
    InputAccessoryHelper.showQuickAdd(
      context,
      selectedDate: _currentDate,
      onSaveComplete: () {
        print('✅ [KeyboardAttachable] 저장 완료 → StreamBuilder 자동 갱신');
        // StreamBuilder가 자동으로 UI 갱신하므로 추가 로직 불필요
      },
    );

    print('➕ [KeyboardAttachable] 더하기 버튼 클릭 → 날짜: $_currentDate');
  }

  /// 🆕 디버그: 5가지 Figma 상태 테스트
  void _testKeyboardAttachableStates() {
    // TODO: 임포트 추가 필요
    // import '../component/keyboard_attachable_input_view.dart';

    // InputAccessoryHelper.testAllStates(context);

    print('🧪 [KeyboardAttachable] 5가지 상태 테스트 실행');
    print('  1. Anything (기본)');
    print('  2. Variant5 (버튼만)');
    print('  3. Touched_Anything (확장)');
    print('  4. Task');
    print('  5. Schedule');
  }
}

// ============================================================================
// 📝 사용 가이드
// ============================================================================
// 
// **Step 1: 임포트 추가 (파일 상단)**
// ```dart
// import '../component/keyboard_attachable_input_view.dart';
// ```
// 
// **Step 2: onAddTap()에서 호출 (기존 코드와 병행)**
// ```dart
// onAddTap: () {
//   // ⭐️ 방법 A: 기존 방식 (현재 사용 중)
//   // showModalBottomSheet(...);
//   
//   // ⭐️ 방법 B: 새로운 keyboard_attachable 방식 (테스트)
//   _showKeyboardAttachableQuickAdd();
// },
// ```
// 
// **Step 3: 검증 후 기존 코드 제거**
// - 5가지 Figma 상태 모두 정상 동작 확인
// - DB 저장/불러오기 정상 동작 확인
// - 키보드 애니메이션 자연스러운지 확인
// - 문제 없으면 showModalBottomSheet 방식 제거
// 
// ============================================================================

