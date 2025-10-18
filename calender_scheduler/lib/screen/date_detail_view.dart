import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ HapticFeedback
import 'package:flutter/physics.dart'; // ✅ SpringSimulation 사용
import 'package:animated_reorderable_list/animated_reorderable_list.dart'; // 🆕 드래그 재정렬
import '../component/schedule_card.dart';
import '../component/create_entry_bottom_sheet.dart';
import '../const/motion_config.dart'; // ✅ Safari 스프링 파라미터
import '../component/slidable_schedule_card.dart'; // ✅ Slidable 컴포넌트 추가
import '../component/modal/option_setting_wolt_modal.dart'; // ✅ OptionSetting Wolt 모달 (Detached)
import '../component/modal/schedule_detail_wolt_modal.dart'; // ✅ 일정 상세 Wolt 모달
import '../component/modal/task_detail_wolt_modal.dart'; // ✅ 할일 상세 Wolt 모달
import '../component/modal/habit_detail_wolt_modal.dart'; // ✅ 습관 상세 Wolt 모달
import '../widgets/bottom_navigation_bar.dart'; // ✅ 하단 네비게이션 바 추가
import '../widgets/temp_input_box.dart'; // ✅ 임시 입력 박스 추가
import '../widgets/date_detail_header.dart'; // ✅ 날짜 헤더 위젯 추가
import '../widgets/task_card.dart'; // ✅ TaskCard 추가
import '../widgets/habit_card.dart'; // ✅ HabitCard 추가
import '../widgets/slidable_task_card.dart'; // ✅ SlidableTaskCard 추가
import '../widgets/slidable_habit_card.dart'; // ✅ SlidableHabitCard 추가
import '../widgets/completed_section.dart'; // ✅ CompletedSection 추가
import '../widgets/dashed_divider.dart'; // ✅ DashedDivider 추가
import '../Database/schedule_database.dart';
import '../model/unified_list_item.dart'; // 🆕 통합 리스트 아이템 모델
import 'package:get_it/get_it.dart';

/// 선택된 날짜의 상세 스케줄을 리스트 형태로 표시하는 화면
/// ⭐️ DB 통합: StreamBuilder를 사용해서 해당 날짜의 일정을 실시간으로 관찰한다
/// 이거를 설정하고 → watchByDay()로 DB 스트림을 구독해서
/// 이거를 해서 → 일정이 추가/삭제될 때마다 자동으로 UI가 갱신된다
/// 이거는 이래서 → setState 없이도 실시간 반영이 가능하다
/// ✅ StatefulWidget 전환: 좌우 스와이프 및 Pull-to-dismiss 기능을 위해 상태 관리 필요
class DateDetailView extends StatefulWidget {
  final DateTime selectedDate; // 선택된 날짜를 저장하는 변수
  final VoidCallback? onClose; // 🚀 Pull-to-dismiss 완료 시 OpenContainer 닫기 콜백

  const DateDetailView({
    super.key,
    required this.selectedDate, // 선택된 날짜를 필수로 받는다
    this.onClose, // ✅ OpenContainer의 action()을 받아서 실제 닫기 처리
  });

  @override
  State<DateDetailView> createState() => _DateDetailViewState();
}

class _DateDetailViewState extends State<DateDetailView>
    with TickerProviderStateMixin {
  late DateTime _currentDate; // 현재 표시 중인 날짜 (좌우 스와이프로 변경됨)
  late PageController _pageController; // 좌우 스와이프를 위한 PageController
  late ScrollController _scrollController; // ✅ 리스트 스크롤 제어용 (Pull-to-dismiss)
  late AnimationController _dismissController; // ✅ Pull-to-dismiss 애니메이션 컨트롤러
  late AnimationController _entryController; // ✅ 진입 헤딩 모션 컨트롤러
  late Animation<double> _entryScaleAnimation; // ✅ 진입 스케일 애니메이션
  double _dragOffset = 0.0; // Pull-to-dismiss를 위한 드래그 오프셋

  // 🚫 Divider 제약을 위한 변수
  bool _isReorderingScheduleBelowDivider = false; // 일정이 divider 아래로 이동 시도 중

  // 📄 페이지네이션 변수
  static const int _pageSize = 20; // 한 번에 로드할 아이템 수
  int _currentTaskOffset = 0; // 현재 Task 오프셋
  int _currentHabitOffset = 0; // 현재 Habit 오프셋

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

    // 📄 페이지네이션: 스크롤 리스너 추가 (하단 도달 시 다음 페이지 로드)
    _scrollController.addListener(_onScroll);

    // ✅ Pull-to-dismiss 스프링 애니메이션 컨트롤러 (unbounded)
    // Safari 스타일: 물리 기반 스프링 시뮬레이션 사용
    _dismissController = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() {
          // SpringSimulation 값이 dragOffset에 반영됨
        });
      });

    // ✅ 진입 헤딩 모션: 0.95 → 1.0 스케일로 부드럽게 확대
    // Apple 쫀득한 느낌: OpenContainer와 동일한 520ms + Emphasized curve
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520), // OpenContainer와 동기화
    );

    _entryScaleAnimation =
        Tween<double>(
          begin: 0.95, // 95% 크기로 시작
          end: 1.0, // 100% 크기로 확대
        ).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Cubic(
              0.05,
              0.7,
              0.1,
              1.0,
            ), // Material Design 3 Emphasized (쫀득한 느낌)
          ),
        );

    // 진입 애니메이션 시작
    _entryController.forward();

    print('📅 [DateDetailView] 초기화 완료 - 날짜: $_currentDate');
  }

  @override
  void dispose() {
    // 이거를 설정하고 → 메모리 누수 방지를 위해 컨트롤러 정리
    _pageController.dispose();
    _scrollController.dispose(); // ✅ ScrollController도 정리
    _dismissController.dispose(); // ✅ Pull-to-dismiss 컨트롤러 정리
    _entryController.dispose(); // ✅ 진입 애니메이션 컨트롤러 정리
    print('🗑️ [DateDetailView] 리소스 정리 완료');
    super.dispose();
  }

  // 이거를 설정하고 → 인덱스를 실제 날짜로 변환하는 함수
  // 이거를 해서 → 중앙 인덱스 기준으로 상대적 날짜를 계산한다
  DateTime _getDateForIndex(int index) {
    final daysDiff = index - _centerIndex;
    return widget.selectedDate.add(Duration(days: daysDiff));
  }

  /// 📄 스크롤 리스너: 하단 도달 시 다음 페이지 로드
  /// 이거를 설정하고 → 스크롤이 하단에 도달하면 감지해서
  /// 이거를 해서 → offset을 증가시켜 다음 페이지를 로드하고
  /// 이거는 이래서 → 무한 스크롤이 가능하다
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 하단 200px 이전에 다음 페이지 로드 시작
      print('📄 [Pagination] 하단 도달 → 다음 페이지 로드');
      setState(() {
        _currentTaskOffset += _pageSize;
        _currentHabitOffset += _pageSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dismissProgress = (_dragOffset / screenHeight).clamp(0.0, 1.0);
    final scale = 1.0 - (dismissProgress * 0.25); // 1.0 → 0.75
    final borderRadius = 36.0 - (dismissProgress * 24.0); // 36 → 12

    return AnimatedBuilder(
      animation: _entryScaleAnimation,
      builder: (context, child) {
        final combinedScale = _entryScaleAnimation.value * scale;

        return Stack(
          children: [
            Material(
              type: MaterialType.transparency,
              child: GestureDetector(
                onVerticalDragUpdate: _handleDragUpdate,
                onVerticalDragEnd: _handleDragEnd,
                child: Transform.translate(
                  offset: Offset(0, _dragOffset),
                  child: Transform.scale(
                    scale: combinedScale,
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: dismissProgress > 0.0
                            ? Border.all(
                                color: const Color(
                                  0xFF111111,
                                ).withOpacity(0.1), // 10%
                                width: 1,
                              )
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: Scaffold(
                          appBar: _buildAppBar(context),
                          backgroundColor: const Color(0xFFF7F7F7),
                          resizeToAvoidBottomInset: false,
                          body: Stack(
                            children: [
                              _buildPageView(),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 20,
                                child: TempInputBox(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      barrierColor: Colors.black.withOpacity(
                                        0.0,
                                      ),
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
                                  },
                                  onDismiss: () => setState(() {}),
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
                              print('➕ [하단 네비] 일정 추가 버튼 클릭 → 바텀시트 표시');
                            },
                            isStarSelected: false, // TODO: 상태 관리
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_scrollController.hasClients) {
      setState(() {
        _dragOffset += details.delta.dy;
        if (_dragOffset < 0) _dragOffset = 0;
      });
      return;
    }

    final isAtTop = _scrollController.offset <= 0;
    final isAtBottom =
        _scrollController.offset >= _scrollController.position.maxScrollExtent;

    if ((isAtTop && details.delta.dy > 0) ||
        (isAtBottom && details.delta.dy > 0)) {
      setState(() {
        _dragOffset += details.delta.dy;
        if (_dragOffset < 0) _dragOffset = 0;
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    final screenHeight = MediaQuery.of(context).size.height;
    final progress = _dragOffset / screenHeight;

    if (velocity > MotionConfig.dismissThresholdVelocity ||
        progress > MotionConfig.dismissThresholdProgress) {
      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      _runSpringAnimation(velocity, screenHeight);
    }
  }

  void _runSpringAnimation(double velocity, double screenHeight) {
    const spring = SpringDescription(
      mass: MotionConfig.springMass,
      stiffness: MotionConfig.springStiffness,
      damping: MotionConfig.springDamping,
    );

    final normalizedStart = _dragOffset / screenHeight;
    final normalizedVelocity = -velocity / screenHeight;
    final simulation = SpringSimulation(
      spring,
      normalizedStart,
      0.0,
      normalizedVelocity,
    );

    _dismissController.animateWith(simulation);

    void listener() {
      if (mounted) {
        setState(() {
          _dragOffset = _dismissController.value * screenHeight;
        });
      }
    }

    _dismissController.addListener(listener);

    _dismissController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dismissController.removeListener(listener);
        if (mounted) {
          setState(() {
            _dragOffset = 0.0;
          });
        }
      }
    });
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
        // ✅ OpenContainer와 동일한 배경색 적용
        return Material(
          color: const Color(0xFFF7F7F7), // ✅ #F7F7F7 배경색
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
      backgroundColor: const Color(0xFFF7F7F7), // ✅ #F7F7F7 배경색
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

  /// 🆕 통합 리스트를 구성하는 함수 (AnimatedReorderableListView)
  /// 이거를 설정하고 → 일정, 할일, 습관을 드래그앤드롭으로 재정렬 가능한 리스트로 표시해서
  /// 이거를 해서 → 사용자가 원하는 순서로 카드를 배치할 수 있고
  /// 이거는 이래서 → DailyCardOrder 테이블에 순서를 저장해 다음에도 유지된다
  Widget _buildUnifiedList(DateTime date) {
    print('🎨 [_buildUnifiedList] 렌더링 시작: ${date.toString().split(' ')[0]}');

    return StreamBuilder<List<ScheduleData>>(
      stream: GetIt.I<AppDatabase>().watchByDay(date),
      builder: (context, scheduleSnapshot) {
        // 📄 페이지네이션: Task와 Habit은 화면에 보이는 것만 로드
        return StreamBuilder<List<TaskData>>(
          stream: GetIt.I<AppDatabase>().watchTasksPaginated(
            limit: _pageSize,
            offset: _currentTaskOffset,
          ),
          builder: (context, taskSnapshot) {
            return StreamBuilder<List<HabitData>>(
              stream: GetIt.I<AppDatabase>().watchHabitsPaginated(
                limit: _pageSize,
                offset: _currentHabitOffset,
              ),
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
                final completedTasks = tasks.where((t) => t.completed).toList();

                print(
                  '✅ [UnifiedList] 일정:${schedules.length}, 할일:${tasks.length}, 습관:${habits.length}, 완료:${completedTasks.length}',
                );

                // 🆕 이거를 설정하고 → FutureBuilder로 UnifiedListItem 리스트를 생성해서
                // 이거를 해서 → DailyCardOrder 기반 또는 기본 순서로 표시한다
                return FutureBuilder<List<UnifiedListItem>>(
                  future: _buildUnifiedItemList(date, schedules, tasks, habits),
                  builder: (context, itemsSnapshot) {
                    if (!itemsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = itemsSnapshot.data!;
                    print('📋 [_buildUnifiedList] 아이템 로드 완료: ${items.length}개');

                    // 🚀 AnimatedReorderableListView 구현!
                    // 이거를 설정하고 → AnimatedReorderableListView로 교체해서
                    // 이거를 해서 → 드래그앤드롭 재정렬 + iOS 애니메이션을 적용하고
                    // 이거는 이래서 → 기존 카드 컴포넌트는 그대로 재사용한다
                    return AnimatedReorderableListView(
                      items: items,

                      // 🔧 itemBuilder: 각 아이템을 카드로 렌더링
                      // 이거를 설정하고 → 타입별로 분기 처리해서
                      // 이거를 해서 → 기존 카드 컴포넌트를 그대로 사용한다
                      itemBuilder: (context, index) {
                        final item = items[index];
                        print(
                          '  → [itemBuilder] index=$index, type=${item.type}, id=${item.actualId}',
                        );

                        // 타입별 카드 렌더링
                        return _buildCardByType(item, date, completedTasks);
                      },

                      // � onReorderStart: 드래그 시작 시 제약 확인
                      // 이거를 설정하고 → 일정이 divider 아래로 가려는지 확인해서
                      // 이거를 해서 → 무효한 시도면 상태를 표시한다
                      onReorderStart: (index) {
                        final item = items[index];
                        print(
                          '🎯 [onReorderStart] index=$index, type=${item.type}',
                        );
                      },

                      // ✅ onReorderEnd: 드래그 종료 시 상태 초기화
                      onReorderEnd: (index) {
                        print('🏁 [onReorderEnd] index=$index');
                        setState(() {
                          _isReorderingScheduleBelowDivider = false;
                        });
                      },

                      // �🔄 onReorder: 재정렬 핸들러
                      // 이거를 설정하고 → 드래그앤드롭 시 호출되어
                      // 이거를 해서 → sortOrder 재계산 및 DB 저장한다
                      onReorder: (oldIndex, newIndex) {
                        // 🚫 Divider 제약 확인
                        final item = items[oldIndex];
                        final dividerIndex = items.indexWhere(
                          (i) => i.type == UnifiedItemType.divider,
                        );

                        // 일정이 divider 아래로 이동하려는 경우 차단!
                        if (item.type == UnifiedItemType.schedule &&
                            dividerIndex != -1) {
                          final targetIndex = newIndex > oldIndex
                              ? newIndex - 1
                              : newIndex;

                          if (targetIndex > dividerIndex) {
                            print(
                              '🚫 [onReorder] 일정을 divider 아래로 이동 불가! oldIndex=$oldIndex, newIndex=$newIndex, dividerIndex=$dividerIndex',
                            );

                            // 거부 효과: 상태 업데이트 + Haptic
                            setState(() {
                              _isReorderingScheduleBelowDivider = true;
                            });

                            HapticFeedback.heavyImpact(); // 강한 햅틱

                            // 100ms 후 FutureBuilder 재실행으로 원래 순서 복구
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                if (mounted) {
                                  setState(() {
                                    _isReorderingScheduleBelowDivider = false;
                                    // 이 setState가 FutureBuilder를 다시 실행시켜서
                                    // DB에서 원래 순서를 다시 로드하게 만듦!
                                  });
                                }
                              },
                            );

                            return; // 재정렬 중단! (_handleReorder 호출하지 않음)
                          }
                        }

                        // 정상적인 재정렬
                        _handleReorder(items, oldIndex, newIndex);
                      },

                      // 🔑 isSameItem: 동일 아이템 비교
                      // 이거를 설정하고 → uniqueId로 비교해서
                      // 이거를 해서 → 애니메이션이 정확히 작동하도록 한다
                      isSameItem: (a, b) => a.uniqueId == b.uniqueId,

                      // 🎨 iOS 18 스타일 애니메이션 설정
                      // 이거를 설정하고 → 300ms duration으로 설정해서
                      // 이거를 해서 → 부드러운 애니메이션을 구현한다
                      insertDuration: const Duration(milliseconds: 300),
                      removeDuration: const Duration(milliseconds: 250),

                      // 🎯 드래그 시작 딜레이 (길게 누르기)
                      // 이거를 설정하고 → 500ms로 설정해서
                      // 이거를 해서 → Slidable 스와이프와 충돌하지 않도록 한다
                      dragStartDelay: const Duration(milliseconds: 500),

                      // 🎭 enterTransition: 아이템 추가 애니메이션
                      // 이거를 설정하고 → iOS 스타일 ScaleIn + FadeIn으로
                      // 이거를 해서 → 부드럽게 나타나도록 한다
                      enterTransition: [
                        ScaleIn(
                          duration: const Duration(milliseconds: 300),
                          curve: const Cubic(0.25, 0.1, 0.25, 1.0), // iOS 곡선
                          begin: 0.95,
                          end: 1.0,
                        ),
                        FadeIn(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        ),
                      ],

                      // 🎭 exitTransition: 아이템 제거 애니메이션
                      // 이거를 설정하고 → iOS 스타일 ScaleIn + FadeIn으로
                      // 이거를 해서 → 부드럽게 사라지도록 한다
                      exitTransition: [
                        ScaleIn(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeIn,
                          begin: 1.0,
                          end: 0.95,
                        ),
                        FadeIn(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                        ),
                      ],

                      // 🎨 proxyDecorator: 드래그 중 카드 스타일
                      // 이거를 설정하고 → 드래그 시 확대 + 회전 + 그림자 효과를 추가해서
                      // 이거를 해서 → iOS 스타일 드래그 애니메이션을 구현한다
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            // 1️⃣ 확대 효과 (3%)
                            final scale = 1.0 + (animation.value * 0.03);

                            // 2️⃣ 회전 효과 (3도)
                            final rotation = animation.value * 0.05; // 약 3도

                            return Transform.scale(
                              scale: scale,
                              child: Transform.rotate(
                                angle: rotation,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0x14111111,
                                        ), // #111111 8% opacity
                                        offset: const Offset(0, 4), // y: 4
                                        blurRadius: 20, // blur: 20
                                      ),
                                    ],
                                  ),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: child,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// 🎨 타입별 카드 렌더링 함수
  /// 이거를 설정하고 → UnifiedListItem 타입을 확인해서
  /// 이거를 해서 → 기존 카드 컴포넌트를 그대로 재사용하고
  /// 이거는 이래서 → 기존 디자인과 기능이 100% 유지된다
  Widget _buildCardByType(
    UnifiedListItem item,
    DateTime date,
    List<TaskData> completedTasks,
  ) {
    // 🔑 Key 설정 (AnimatedReorderableListView 필수!)
    // 이거를 설정하고 → ValueKey(uniqueId)로 설정해서
    // 이거를 해서 → 재정렬 시 올바른 아이템을 추적한다
    final key = ValueKey(item.uniqueId);

    // 타입별 분기 처리
    switch (item.type) {
      // ====================================================================
      // 📅 일정 카드 (Schedule)
      // ====================================================================
      case UnifiedItemType.schedule:
        final schedule = item.data as ScheduleData;

        // 🚫 Divider 제약 위반 시 흔들림 + 빨간색 효과
        final isInvalid = _isReorderingScheduleBelowDivider;

        return AnimatedContainer(
          key: key,
          duration: const Duration(milliseconds: 200),
          curve: Curves.elasticOut,
          // 좌우 흔들림 효과 (offset 대신 padding으로 구현)
          padding: EdgeInsets.only(
            bottom: 4,
            left: isInvalid ? 20 : 24,
            right: isInvalid ? 28 : 24,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              // 빨간색 테두리 효과
              border: isInvalid
                  ? Border.all(color: Colors.red.withOpacity(0.6), width: 2)
                  : null,
            ),
            child: GestureDetector(
              onTap: () => _openScheduleDetail(schedule),
              child: SlidableScheduleCard(
                groupTag: 'unified_list',
                scheduleId: schedule.id,
                onComplete: () async {
                  await GetIt.I<AppDatabase>().completeSchedule(schedule.id);
                  print('✅ [ScheduleCard] 완료: ${schedule.summary}');
                },
                onDelete: () async {
                  await GetIt.I<AppDatabase>().deleteSchedule(schedule.id);
                  // 🗑️ DailyCardOrder에서도 삭제
                  await GetIt.I<AppDatabase>().deleteCardFromAllOrders(
                    'schedule',
                    schedule.id,
                  );
                  print('🗑️ [ScheduleCard] 삭제: ${schedule.summary}');
                },
                child: ScheduleCard(
                  start: schedule.start,
                  end: schedule.end,
                  summary: schedule.summary,
                  colorId: schedule.colorId,
                ),
              ),
            ),
          ),
        );

      // ====================================================================
      // ✅ 할일 카드 (Task)
      // ====================================================================
      case UnifiedItemType.task:
        final task = item.data as TaskData;
        return Padding(
          key: key,
          padding: const EdgeInsets.only(bottom: 4, left: 24, right: 24),
          child: SlidableTaskCard(
            groupTag: 'unified_list',
            taskId: task.id,
            onTap: () => _openTaskDetail(task),
            onComplete: () async {
              await GetIt.I<AppDatabase>().completeTask(task.id);
              print('✅ [TaskCard] 완료 토글: ${task.title}');
            },
            onDelete: () async {
              await GetIt.I<AppDatabase>().deleteTask(task.id);
              // 🗑️ DailyCardOrder에서도 삭제
              await GetIt.I<AppDatabase>().deleteCardFromAllOrders(
                'task',
                task.id,
              );
              print('🗑️ [TaskCard] 삭제: ${task.title}');
            },
            child: TaskCard(
              task: task,
              onToggle: () async {
                await GetIt.I<AppDatabase>().completeTask(task.id);
                print('✅ [TaskCard] 체크박스 완료 토글: ${task.title}');
              },
            ),
          ),
        );

      // ====================================================================
      // 🔁 습관 카드 (Habit)
      // ====================================================================
      case UnifiedItemType.habit:
        final habit = item.data as HabitData;
        return Padding(
          key: key,
          padding: const EdgeInsets.only(bottom: 4, left: 24, right: 24),
          child: GestureDetector(
            onTap: () => _showHabitDetailModal(habit, date),
            child: SlidableHabitCard(
              groupTag: 'unified_list',
              habitId: habit.id,
              onComplete: () async {
                await GetIt.I<AppDatabase>().recordHabitCompletion(
                  habit.id,
                  date,
                );
                print('✅ [HabitCard] 완료 기록: ${habit.title}');
              },
              onDelete: () async {
                await GetIt.I<AppDatabase>().deleteHabit(habit.id);
                // 🗑️ DailyCardOrder에서도 삭제
                await GetIt.I<AppDatabase>().deleteCardFromAllOrders(
                  'habit',
                  habit.id,
                );
                print('🗑️ [HabitCard] 삭제: ${habit.title}');
              },
              child: HabitCard(
                habit: habit,
                isCompleted: false, // TODO: HabitCompletion 확인
                onToggle: () async {
                  await GetIt.I<AppDatabase>().recordHabitCompletion(
                    habit.id,
                    date,
                  );
                  print('✅ [HabitCard] 체크박스 완료 기록: ${habit.title}');
                },
                onTap: () {
                  print('🔁 [HabitCard] 탭: ${habit.title}');
                  _showHabitDetailModal(habit, date);
                },
              ),
            ),
          ),
        );

      // ====================================================================
      // --- 점선 구분선 (Divider)
      // ====================================================================
      case UnifiedItemType.divider:
        return Padding(
          key: key,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: const DashedDivider(),
        );

      // ====================================================================
      // 📦 완료 섹션 (Completed)
      // ====================================================================
      case UnifiedItemType.completed:
        return Padding(
          key: key,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: CompletedSection(
            completedCount: completedTasks.length,
            onTap: () {
              print('📦 [CompletedSection] 탭 → CompletedDetailScreen 이동');
              // TODO: 완료 화면 이동 로직
            },
            isExpanded: false,
          ),
        );
    }
  }

  // ============================================================================
  // 🗑️ 기존 CustomScrollView 코드 (백업용 - 나중에 삭제)
  // ============================================================================
  /*
  Widget _buildUnifiedList_OLD(DateTime date) {
    return StreamBuilder<List<ScheduleData>>(
      stream: GetIt.I<AppDatabase>().watchByDay(date),
      builder: (context, scheduleSnapshot) {
        return StreamBuilder<List<TaskData>>(
          stream: GetIt.I<AppDatabase>().watchTasks(),
          builder: (context, taskSnapshot) {
            return StreamBuilder<List<HabitData>>(
              stream: GetIt.I<AppDatabase>().watchHabits(),
              builder: (context, habitSnapshot) {
                if (!scheduleSnapshot.hasData ||
                    !taskSnapshot.hasData ||
                    !habitSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final schedules = scheduleSnapshot.data!;
                final tasks = taskSnapshot.data!;
                final habits = habitSnapshot.data!;

                final incompleteTasks = tasks
                    .where((t) => !t.completed)
                    .toList();
                final completedTasks = tasks.where((t) => t.completed).toList();

                return CustomScrollView(
                  controller: _scrollController,
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
  */

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

  // ============================================================================
  // 🆕 ANIMATED_REORDERABLE_LIST 마이그레이션 - 새로운 함수들
  // ============================================================================
  //
  // ⚠️ **중요: 기존 _buildUnifiedList() 함수는 건들지 않고 새로운 함수 추가!**
  // - 이 함수들은 AnimatedReorderableListView 방식을 구현
  // - DailyCardOrder 테이블을 사용해 날짜별 순서 관리
  // - 기존 카드 컴포넌트 (ScheduleCard, TaskCard, HabitCard)는 그대로 재사용
  // - Slidable 래퍼도 그대로 유지

  /// 통합 아이템 리스트 생성 (DailyCardOrder 우선, 없으면 기본 순서)
  /// 이거를 설정하고 → DailyCardOrder 테이블에서 커스텀 순서를 조회해서
  /// 이거를 해서 → 있으면 커스텀 순서로, 없으면 기본 순서(createdAt)로 표시하고
  /// 이거는 이래서 → 사용자가 재정렬한 순서를 복원하거나 초기 상태를 보여준다
  Future<List<UnifiedListItem>> _buildUnifiedItemList(
    DateTime date,
    List<ScheduleData> schedules,
    List<TaskData> tasks,
    List<HabitData> habits,
  ) async {
    print('🔄 [_buildUnifiedItemList] 시작: ${date.toString().split(' ')[0]}');

    // 이거를 설정하고 → DailyCardOrder 테이블 조회해서
    // 이거를 해서 → 사용자 커스텀 순서가 있는지 확인한다
    final cardOrders = await GetIt.I<AppDatabase>()
        .watchDailyCardOrder(date)
        .first;

    print('  → DailyCardOrder 레코드: ${cardOrders.length}개');

    List<UnifiedListItem> items = [];

    if (cardOrders.isEmpty) {
      // ========================================================================
      // 케이스 1: 커스텀 순서 없음 → 기본 순서 (일정 → 할일 → 습관)
      // ========================================================================
      print('  → [기본 순서] createdAt 기준으로 생성');

      int order = 0;

      // 1️⃣ 일정 추가 (시간순)
      for (final schedule in schedules) {
        items.add(UnifiedListItem.fromSchedule(schedule, sortOrder: order++));
      }

      // 2️⃣ 점선 구분선 (일정 섹션 종료)
      if (schedules.isNotEmpty) {
        items.add(UnifiedListItem.divider(sortOrder: order++));
      }

      // 3️⃣ 할일 추가 (미완료만, createdAt 순)
      final incompleteTasks = tasks.where((t) => !t.completed).toList();
      for (final task in incompleteTasks) {
        items.add(UnifiedListItem.fromTask(task, sortOrder: order++));
      }

      // 4️⃣ 습관 추가 (createdAt 순)
      for (final habit in habits) {
        items.add(UnifiedListItem.fromHabit(habit, sortOrder: order++));
      }

      // 5️⃣ 완료 섹션 (완료된 할일이 있을 경우)
      final completedTasks = tasks.where((t) => t.completed).toList();
      if (completedTasks.isNotEmpty) {
        items.add(UnifiedListItem.completed(sortOrder: order++));
      }

      print('  → 기본 순서 생성 완료: ${items.length}개 아이템');
    } else {
      // ========================================================================
      // 케이스 2: 커스텀 순서 있음 → DailyCardOrder 기준으로 복원
      // ========================================================================
      print('  → [커스텀 순서] DailyCardOrder 기준으로 복원');

      // 이거를 설정하고 → cardOrders를 순회하면서
      // 이거를 해서 → 실제 데이터와 JOIN해서 UnifiedListItem 생성한다
      for (final orderData in cardOrders) {
        if (orderData.cardType == 'schedule') {
          // Schedule 찾기
          final schedule = schedules.firstWhere(
            (s) => s.id == orderData.cardId,
            orElse: () =>
                throw Exception('Schedule not found: ${orderData.cardId}'),
          );
          items.add(
            UnifiedListItem.fromSchedule(
              schedule,
              sortOrder: orderData.sortOrder,
            ),
          );
        } else if (orderData.cardType == 'task') {
          // Task 찾기
          final task = tasks.firstWhere(
            (t) => t.id == orderData.cardId,
            orElse: () =>
                throw Exception('Task not found: ${orderData.cardId}'),
          );
          items.add(
            UnifiedListItem.fromTask(task, sortOrder: orderData.sortOrder),
          );
        } else if (orderData.cardType == 'habit') {
          // Habit 찾기
          final habit = habits.firstWhere(
            (h) => h.id == orderData.cardId,
            orElse: () =>
                throw Exception('Habit not found: ${orderData.cardId}'),
          );
          items.add(
            UnifiedListItem.fromHabit(habit, sortOrder: orderData.sortOrder),
          );
        }
      }

      // 이거를 설정하고 → sortOrder 기준으로 정렬해서
      // 이거를 해서 → DB에 저장된 순서대로 표시한다
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      // 이거를 설정하고 → 점선 구분선을 동적으로 삽입해서
      // 이거를 해서 → 일정 섹션과 나머지 섹션을 구분한다
      // 이거는 이래서 → 재정렬 후에도 점선 위치가 자동으로 조정된다
      final lastScheduleIndex = items.lastIndexWhere(
        (item) => item.type == UnifiedItemType.schedule,
      );

      if (lastScheduleIndex != -1) {
        // 일정이 있으면 마지막 일정 다음에 점선 삽입
        items.insert(
          lastScheduleIndex + 1,
          UnifiedListItem.divider(sortOrder: lastScheduleIndex + 1),
        );
      }

      // 완료 섹션 추가
      final completedTasks = tasks.where((t) => t.completed).toList();
      if (completedTasks.isNotEmpty) {
        items.add(UnifiedListItem.completed(sortOrder: items.length));
      }

      print('  → 커스텀 순서 복원 완료: ${items.length}개 아이템');
    }

    print('✅ [_buildUnifiedItemList] 완료: ${items.length}개 아이템 생성');
    return items;
  }

  /// 재정렬 핸들러
  /// 이거를 설정하고 → 드래그앤드롭으로 아이템 순서가 바뀔 때 호출되어
  /// 이거를 해서 → sortOrder를 재계산하고 DB에 저장하고
  /// 이거는 이래서 → 앱을 재시작해도 순서가 유지된다
  void _handleReorder(List<UnifiedListItem> items, int oldIndex, int newIndex) {
    print('🔄 [Reorder] 시작: $oldIndex → $newIndex');

    // 이거를 설정하고 → iOS 스타일 햅틱 피드백을 추가해서
    // 이거를 해서 → 드래그 시작 시 촉각 피드백을 준다
    HapticFeedback.mediumImpact();

    setState(() {
      // 이거를 설정하고 → newIndex 조정 로직을 적용해서
      // 이거를 해서 → AnimatedReorderableListView의 동작과 일치시킨다
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // 이거를 설정하고 → 아이템을 이동시켜서
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      print('  → 아이템 이동: ${item.uniqueId} (type: ${item.type})');

      // 이거를 설정하고 → 전체 리스트의 sortOrder를 재계산해서
      // 이거를 해서 → 모든 아이템이 올바른 순서를 가지도록 한다
      for (int i = 0; i < items.length; i++) {
        items[i] = items[i].copyWith(sortOrder: i);
      }
      print('  → sortOrder 재계산 완료');
    });

    // 이거를 설정하고 → DB에 순서를 저장해서
    // 이거를 해서 → 앱 재시작 시에도 순서가 유지된다
    _saveDailyCardOrder(items);

    // 이거를 설정하고 → 드롭 완료 시 가벼운 햅틱 피드백을 추가해서
    // 이거를 해서 → 사용자에게 재정렬 완료를 알린다
    Future.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.lightImpact();
    });

    print('✅ [Reorder] 완료');
  }

  /// DB에 순서 저장
  /// 이거를 설정하고 → UnifiedListItem 리스트를 DB 형식으로 변환해서
  /// 이거를 해서 → DailyCardOrder 테이블에 저장하고
  /// 이거는 이래서 → 다음에 화면을 열 때 같은 순서로 복원된다
  Future<void> _saveDailyCardOrder(List<UnifiedListItem> items) async {
    print('💾 [_saveDailyCardOrder] DB 저장 시작');

    // 이거를 설정하고 → divider와 completed는 제외하고
    // 이거를 해서 → 실제 카드 데이터만 DB에 저장한다
    final dataToSave = items
        .where(
          (item) =>
              item.type != UnifiedItemType.divider &&
              item.type != UnifiedItemType.completed,
        )
        .map((item) => item.toMap())
        .toList();

    print('  → 저장할 카드: ${dataToSave.length}개');

    try {
      await GetIt.I<AppDatabase>().saveDailyCardOrder(_currentDate, dataToSave);
      print('✅ [_saveDailyCardOrder] 저장 완료');
    } catch (e) {
      print('❌ [_saveDailyCardOrder] 저장 실패: $e');
    }
  }
} // _DateDetailViewState 끝
