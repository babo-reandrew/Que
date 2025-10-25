import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ HapticFeedback
import 'package:flutter/physics.dart'; // ✅ SpringSimulation 사용
import 'package:smooth_sheets/smooth_sheets.dart'; // ✅ smooth_sheets 추가
import 'package:animated_reorderable_list/animated_reorderable_list.dart'; // 🆕 드래그 재정렬
import '../component/toast/action_toast.dart'; // ✅ 토스트 추가
import '../component/schedule_card.dart';
import '../component/create_entry_bottom_sheet.dart';
import '../const/motion_config.dart'; // ✅ Safari 스프링 파라미터
import '../component/slidable_schedule_card.dart'; // ✅ Slidable 컴포넌트 추가
import '../component/modal/option_setting_wolt_modal.dart'; // ✅ OptionSetting Wolt 모달 (Detached)
import '../component/modal/schedule_detail_wolt_modal.dart'; // ✅ 일정 상세 Wolt 모달
import '../component/modal/task_detail_wolt_modal.dart'; // ✅ 할일 상세 Wolt 모달
import '../component/modal/habit_detail_wolt_modal.dart'; // ✅ 습관 상세 Wolt 모달
import '../component/modal/image_picker_smooth_sheet.dart'; // ✅ 이미지 선택 Smooth Sheet 모달
import '../component/modal/task_inbox_bottom_sheet.dart'; // 📋 Task Inbox 추가
import '../widgets/bottom_navigation_bar.dart'; // ✅ 하단 네비게이션 바 추가
import '../widgets/temp_input_box.dart'; // ✅ 임시 입력 박스 추가
import '../widgets/date_detail_header.dart'; // ✅ 날짜 헤더 위젯 추가
import '../widgets/task_inbox_top_bar.dart'; // 📋 Task Inbox TopBar 추가 (일간뷰용)
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
  final bool isInboxMode; // 📋 인박스 모드 여부

  const DateDetailView({
    super.key,
    required this.selectedDate, // 선택된 날짜를 필수로 받는다
    this.onClose, // ✅ OpenContainer의 action()을 받아서 실제 닫기 처리
    this.isInboxMode = false, // 기본값: false (일반 모드)
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

  // 📋 인박스 모드 상태 (내부에서 변경 가능)
  late bool _isInboxMode;
  bool _showInboxOverlay = false; // 📋 인박스 오버레이 표시 여부
  bool _isDraggingFromInbox = false; // 🎯 인박스에서 드래그 중인지 여부

  // 🚫 Divider 제약을 위한 변수
  bool _isReorderingScheduleBelowDivider = false; // 일정이 divider 아래로 이동 시도 중

  // 무한 스크롤을 위한 중앙 인덱스 (충분히 큰 수)
  static const int _centerIndex = 1000000;

  // 🎯 Future 캐시: FutureBuilder rebuild 시 중복 호출 방지
  final Map<String, Future<List<UnifiedListItem>>> _itemListCache = {};

  // 🎯 자동 스크롤을 위한 BuildContext 캐시
  BuildContext? _scrollableContext;

  @override
  void initState() {
    super.initState();
    // 이거를 설정하고 → 기존 selectedDate를 현재 날짜로 초기화해서
    _currentDate = widget.selectedDate;
    // 📋 인박스 모드 초기화
    _isInboxMode = widget.isInboxMode;
    // 이거를 해서 → 무한 스크롤을 위한 PageController 생성한다 (중앙 인덱스부터 시작)
    _pageController = PageController(initialPage: _centerIndex);
    // ✅ 리스트 스크롤 컨트롤러 초기화 (리스트 최상단 감지용)
    _scrollController = ScrollController();

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

  /// 🎯 드래그 시 자동 스크롤 (AnimatedReorderableListView 네이티브 동작)
  /// 이거를 설정하고 → 드래그 중인 카드의 Y 위치를 감지해서
  /// 이거를 해서 → 화면 상단/하단 경계 근처면 자동으로 스크롤하고
  /// 이거는 이래서 → 보이지 않는 영역으로도 드래그 가능하다
  void _handleAutoScroll(double globalY, BuildContext dragContext) {
    if (_scrollableContext == null) {
      // print('❌ [AutoScroll] _scrollableContext가 없음!');
      return;
    }

    // Scrollable 위젯의 ScrollPosition에 직접 접근
    final scrollableState = Scrollable.maybeOf(_scrollableContext!);
    if (scrollableState == null) {
      print('❌ [AutoScroll] Scrollable을 찾을 수 없음!');
      return;
    }

    final position = scrollableState.position;

    // 🚫 PageView의 무한 스크롤 감지 (maxScrollExtent가 비정상적으로 크면 무시)
    if (position.maxScrollExtent > 100000000) {
      // print('❌ [AutoScroll] PageView 스크롤 감지됨 - 무시');
      return;
    }

    // 화면 높이 가져오기
    final screenHeight = MediaQuery.of(dragContext).size.height;

    // 디버그용 로그 (너무 많아서 주석 처리 가능)
    // print('📊 [AutoScroll] globalY=$globalY, screenHeight=$screenHeight, offset=${position.pixels}, max=${position.maxScrollExtent}');

    const topScrollZone = 300.0; // 상단 300px (확대!)
    final bottomScrollZone = screenHeight - 300.0; // 하단에서 300px 위 (확대!)
    const scrollSpeed = 40.0; // 스크롤 속도

    // print('🎯 [AutoScroll] 임계값 체크: top=${globalY < topScrollZone}, bottom=${globalY > bottomScrollZone} (bottom기준=$bottomScrollZone)');

    // 🔼 상단 경계 근처: 위로 스크롤
    if (globalY < topScrollZone) {
      final intensity = (topScrollZone - globalY) / topScrollZone; // 0.0 ~ 1.0
      final offset = (position.pixels - (scrollSpeed * intensity)).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      // print('🔼 [AutoScroll] 상단 스크롤: intensity=$intensity, newOffset=$offset');
      position.jumpTo(offset);
    }
    // 🔽 하단 경계 근처: 아래로 스크롤
    else if (globalY > bottomScrollZone) {
      final intensity = ((globalY - bottomScrollZone) / 300.0).clamp(
        0.0,
        1.0,
      ); // 300px 범위
      final offset = (position.pixels + (scrollSpeed * intensity)).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      print(
        '🔽 [AutoScroll] 하단 스크롤: globalY=$globalY, bottom=$bottomScrollZone, intensity=$intensity, newOffset=$offset',
      );
      position.jumpTo(offset);
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
            // 🎯 메인 컨텐츠와 DragTarget들
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
                        clipBehavior: Clip.hardEdge, // 🎯 터치 이벤트 통과 보장
                        child: Stack(
                          children: [
                            // 메인 Scaffold
                            Scaffold(
                              appBar: _buildAppBar(context),
                              backgroundColor: const Color(0xFFF7F7F7),
                              resizeToAvoidBottomInset: false,
                              body: _buildPageView(), // 🎯 직접 렌더링
                              // ✅ FloatingActionButton 제거 → 하단 네비게이션 바로 대체
                              // ✅ 하단 네비게이션 바 추가 (피그마: Frame 822)
                              bottomNavigationBar: _isInboxMode
                                  ? null // 📋 인박스 모드에서는 하단 네비 숨김
                                  : CustomBottomNavigationBar(
                                      onInboxTap: () {
                                        print('📥 [하단 네비] Inbox 버튼 클릭');
                                        setState(() {
                                          _isInboxMode = true; // 📋 인박스 모드 활성화
                                          _showInboxOverlay =
                                              true; // 📋 오버레이 표시
                                        });
                                      },
                                      onImageAddTap: () {
                                        print(
                                          '🖼️ [하단 네비] 이미지 추가 버튼 클릭 → 이미지 선택 모달 오픈',
                                        );
                                        // 📸 이미지 선택 Smooth Sheet 표시
                                        Navigator.push(
                                          context,
                                          ModalSheetRoute(
                                            builder: (context) => ImagePickerSmoothSheet(
                                              onImagesSelected: (selectedImages) {
                                                print(
                                                  '✅ [DateDetailView] 선택된 이미지: ${selectedImages.length}개',
                                                );
                                                // TODO: AI 분석으로 전달 (추후 구현)
                                                for (final img
                                                    in selectedImages) {
                                                  print(
                                                    '   - 이미지 ID/path: ${img.idOrPath()}',
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      onAddTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true, // ✅ 전체화면
                                          backgroundColor:
                                              Colors.transparent, // ✅ 투명 배경
                                          barrierColor:
                                              Colors.transparent, // ✅ 배리어도 투명!
                                          elevation: 0, // ✅ 그림자 제거
                                          useSafeArea:
                                              false, // ✅ SafeArea 사용 안함
                                          builder: (context) =>
                                              CreateEntryBottomSheet(
                                                selectedDate: _currentDate,
                                              ),
                                        );
                                        print('➕ [디테일뷰 +버튼] QuickAdd 표시');
                                      },
                                    ),
                            ),
                            // 📋 인박스 모드 상단 TopBar
                            if (_isInboxMode)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: const Color(0xFFF7F7F7),
                                  child: SafeArea(
                                    bottom: false,
                                    child: Stack(
                                      children: [
                                        TaskInboxDayTopBar(
                                          date: _currentDate,
                                          onSwipeLeft: () {
                                            _pageController.nextPage(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                          onSwipeRight: () {
                                            _pageController.previousPage(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                        ),
                                        Positioned(
                                          right: 24,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: TaskInboxCheckButton(
                                              onClose: () {
                                                setState(() {
                                                  _isInboxMode = false;
                                                  _showInboxOverlay = false;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 🎯 TempInputBox를 Stack 최상위로 이동
            if (!_showInboxOverlay)
              Positioned(
                left: 0,
                right: 0,
                bottom:
                    20 +
                    MediaQuery.of(context).padding.bottom +
                    80, // bottomNavigationBar 높이 고려
                child: TempInputBox(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // ✅ 전체화면
                      backgroundColor: Colors.transparent, // ✅ 투명 배경
                      barrierColor: Colors.transparent, // ✅ 배리어도 투명!
                      elevation: 0, // ✅ 그림자 제거
                      useSafeArea: false, // ✅ SafeArea 사용 안함
                      builder: (context) =>
                          CreateEntryBottomSheet(selectedDate: _currentDate),
                    );
                  },
                  onDismiss: () => setState(() {}),
                ),
              ),
            // 📋 인박스 오버레이 (조건부 표시) - 최상위 레이어
            if (_showInboxOverlay)
              Positioned.fill(
                child: TaskInboxBottomSheet(
                  onClose: () {
                    setState(() {
                      _showInboxOverlay = false;
                      _isInboxMode = false;
                    });
                  },
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
        // ✅ 인박스 모드 애니메이션 추가 (홈스크린과 동일 - AnimatedContainer 사용)
        return AnimatedContainer(
          duration: const Duration(milliseconds: 900), // ✅ 홈스크린과 동일
          curve: const Cubic(0.4, 0.0, 0.2, 1.0), // ✅ Material Emphasized curve
          transform: _isInboxMode
              ? (Matrix4.identity()..scale(0.92, 0.92)) // ✅ 가로 92%, 세로 92%
              : Matrix4.identity(),
          transformAlignment: Alignment.topCenter,
          child: Material(
            color: const Color(0xFFF7F7F7), // ✅ #F7F7F7 배경색
            // 이거는 이래서 → 기존 _buildBody 함수 재사용
            child: _buildBody(context, date),
          ),
        );
      },
    );
  }

  /// 앱바를 구성하는 함수 - 피그마 디자인: ⋯ 버튼 + 날짜 + v 버튼
  /// 이거를 설정하고 → 좌측에 설정(⋯), 중앙에 날짜, 우측에 닫기(v) 버튼을 배치해서
  /// 이거를 해서 → 피그마 디자인과 동일한 레이아웃을 만든다
  /// 이거는 이래서 → iOS 네이티브 앱과 유사한 UX를 제공한다
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    print('🔍 [AppBar] isInboxMode: $_isInboxMode');

    // 인박스 모드일 때는 그라데이션 배경의 커스텀 앱바
    if (_isInboxMode) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Opacity(
          opacity: 0.96, // 전체 투명도 96%
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFAFAFA).withOpacity(1.0), // 상단 100% #FAFAFA
                  const Color(0xFFFAFAFA).withOpacity(0.0), // 하단 0% #FAFAFA
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x0A111111), // background 4% #111111 오버레이
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                // 중앙에 일과 요일 표시 (AnimatedSwitcher 적용)
                title: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        // 🎯 홈스크린과 완전히 동일한 애니메이션 값
                        final scaleAnimation = TweenSequence<double>([
                          TweenSequenceItem(
                            tween: Tween<double>(
                              begin: 0.92,
                              end: 1.05,
                            ).chain(CurveTween(curve: Curves.easeOutCubic)),
                            weight: 50,
                          ),
                          TweenSequenceItem(
                            tween: Tween<double>(
                              begin: 1.05,
                              end: 1.0,
                            ).chain(CurveTween(curve: Curves.easeInOut)),
                            weight: 30,
                          ),
                        ]).animate(animation);

                        final slideAnimation = TweenSequence<Offset>([
                          TweenSequenceItem(
                            tween: Tween<Offset>(
                              begin: const Offset(0, 0.4),
                              end: const Offset(0, 0.2),
                            ).chain(CurveTween(curve: Curves.easeOut)),
                            weight: 30,
                          ),
                          TweenSequenceItem(
                            tween: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: const Offset(0, -0.02),
                            ).chain(CurveTween(curve: Curves.easeOutCubic)),
                            weight: 40,
                          ),
                          TweenSequenceItem(
                            tween: Tween<Offset>(
                              begin: const Offset(0, -0.02),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeInOut)),
                            weight: 30,
                          ),
                        ]).animate(animation);

                        final fadeAnimation = TweenSequence<double>([
                          TweenSequenceItem(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: 0.3,
                            ).chain(CurveTween(curve: Curves.easeIn)),
                            weight: 20,
                          ),
                          TweenSequenceItem(
                            tween: Tween<double>(
                              begin: 0.3,
                              end: 1.0,
                            ).chain(CurveTween(curve: Curves.easeOut)),
                            weight: 80,
                          ),
                        ]).animate(animation);

                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: slideAnimation,
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: child,
                            ),
                          ),
                        );
                      },
                  child: TaskInboxDayTopBar(
                    key: ValueKey(
                      'inbox_day_bar_${_currentDate.day}_${_currentDate.weekday}',
                    ),
                    date: _currentDate,
                  ),
                ),
                centerTitle: true,
              ),
            ),
          ),
        ),
      );
    }

    // 일반 모드 앱바
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
    // 인박스 모드일 때는 헤더를 리스트 안에 포함시켜 스크롤 가능하게 함
    if (_isInboxMode) {
      return _buildUnifiedList(date); // 헤더가 리스트 안에 포함됨
    }

    // 일반 모드일 때는 헤더를 고정
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================================================
        // ✅ 새로운 날짜 헤더 (Figma: Frame 830, Frame 893)
        // 일반 디테일뷰: 상단 48px, 하단 32px, 좌우 20px
        // ===================================================================
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
          child: DateDetailHeader(
            selectedDate: date,
            // onSettingsTap은 제거 - DateDetailHeader에서 직접 처리
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

    // 🔁 반복 규칙을 고려한 데이터 조회
    return StreamBuilder<List<ScheduleData>>(
      stream: GetIt.I<AppDatabase>().watchSchedulesWithRepeat(date),
      builder: (context, scheduleSnapshot) {
        // 🎯 반복 규칙을 고려한 Task 조회
        return StreamBuilder<List<TaskData>>(
          stream: GetIt.I<AppDatabase>().watchTasksWithRepeat(date),
          builder: (context, taskSnapshot) {
            // 🔁 반복 규칙을 고려한 Habit 조회
            return StreamBuilder<List<HabitData>>(
              stream: GetIt.I<AppDatabase>().watchHabitsWithRepeat(date),
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

                debugPrint(
                  '🔁 [UnifiedList] ${date.toString().split(' ')[0]} - 일정:${schedules.length}, 할일:${tasks.length}, 습관:${habits.length}',
                );

                // 이거를 해서 → 완료된 항목과 미완료 항목 분리
                final completedTasksCount = tasks
                    .where((t) => t.completed)
                    .length;

                print(
                  '✅ [UnifiedList] 일정:${schedules.length}, 할일:${tasks.length}, 습관:${habits.length}, 완료:${completedTasksCount}',
                );

                // 🆕 이거를 설정하고 → FutureBuilder로 UnifiedListItem 리스트를 생성해서
                // 이거를 해서 → DailyCardOrder 기반 또는 기본 순서로 표시한다
                // 🎯 Future 캐시: 날짜 + 데이터 해시 기준으로 캐시하여 rebuild 시 중복 호출 방지
                // ✅ 수정된 내용도 반영하기 위해 각 아이템의 제목 해시를 포함
                final scheduleHash = schedules
                    .map(
                      (s) =>
                          '${s.id}_${s.summary}_${s.start}_${s.end}_${s.colorId}_${s.repeatRule}_${s.alertSetting}',
                    )
                    .join('|');
                final taskHash = tasks
                    .map(
                      (t) =>
                          '${t.id}_${t.title}_${t.completed}_${t.dueDate}_${t.executionDate}_${t.colorId}_${t.repeatRule}_${t.reminder}',
                    )
                    .join('|');
                final habitHash = habits
                    .map(
                      (h) =>
                          '${h.id}_${h.title}_${h.colorId}_${h.repeatRule}_${h.reminder}',
                    )
                    .join('|');
                final cacheKey =
                    '${date.toString().split(' ')[0]}_${scheduleHash.hashCode}_${taskHash.hashCode}_${habitHash.hashCode}_$completedTasksCount';
                // 데이터가 변경되면 (해시가 다르면) 캐시 초기화
                if (!_itemListCache.containsKey(cacheKey)) {
                  _itemListCache.clear(); // 기존 캐시 모두 삭제
                  _itemListCache[cacheKey] = _buildUnifiedItemList(
                    date,
                    schedules,
                    tasks,
                    habits,
                  );
                }

                return FutureBuilder<List<UnifiedListItem>>(
                  future: _itemListCache[cacheKey],
                  builder: (context, itemsSnapshot) {
                    if (!itemsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var items = itemsSnapshot.data!;

                    // ✅ 데이터가 없을 때 메시지 표시
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          '現在データがありません',
                          style: TextStyle(
                            fontFamily: 'LINE Seed JP App_TTF',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF999999),
                            letterSpacing: -0.075,
                          ),
                        ),
                      );
                    }

                    // 🎯 인박스 모드일 때 헤더를 리스트 맨 앞에 추가
                    if (_isInboxMode &&
                        (items.isEmpty ||
                            items.first.type != UnifiedItemType.inboxHeader)) {
                      items = [
                        UnifiedListItem.inboxHeader(
                          sortOrder: -1000,
                        ), // 맨 앞에 위치
                        ...items,
                      ];
                    }

                    // 🎯 드래그 호버 시 플레이스홀더 삽입 (candidateData 기반으로 직접 체크)
                    // NOTE: DragTarget builder에서 candidateData를 체크하므로 여기서는 불필요

                    print('📋 [_buildUnifiedList] 아이템 로드 완료: ${items.length}개');

                    // ========================================================================
                    // 🆕 2컬럼 레이아웃: 종일 일정 분리
                    // ========================================================================
                    final scheduleItems = _getScheduleItems(items);
                    final allDaySchedule = _findAllDaySchedule(scheduleItems);
                    final normalSchedules = _getNormalSchedules(scheduleItems, allDaySchedule);
                    final belowDividerItems = _getBelowDividerItems(items);

                    print('🎨 [2Column] 종일:${allDaySchedule != null ? 1 : 0}, 일반:${normalSchedules.length}, Divider아래:${belowDividerItems.length}');

                    // ========================================================================
                    // 🎯 2컬럼 레이아웃 구현: SingleChildScrollView + Column
                    // ========================================================================
                    return SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== 점선 위: 일정 영역 =====
                          if (scheduleItems.isNotEmpty)
                            _buildScheduleSection(allDaySchedule, normalSchedules, date, items),

                          // ===== 점선 구분선 =====
                          if (scheduleItems.isNotEmpty && belowDividerItems.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              child: DashedDivider(),
                            ),

                          // ===== 점선 아래: 할일/습관 영역 =====
                          if (belowDividerItems.isNotEmpty)
                            _buildBelowDividerSection(belowDividerItems, date, tasks.where((t) => t.completed).toList(), items),

                          // 하단 여백
                          const SizedBox(height: 100),
                        ],
                      ),
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

  // ============================================================================
  // 🆕 2컬럼 레이아웃 빌더 함수들
  // ============================================================================

  /// 일정 섹션 빌더 (종일 + 일반 일정)
  /// 이거를 설정하고 → 종일 일정이 있으면 Row로 2컬럼 배치해서
  /// 이거를 해서 → 좌측 40% 종일, 우측 60% 일반 일정을 표시하고
  /// 이거는 이래서 → Figma 디자인대로 2컬럼 레이아웃이 구현된다
  Widget _buildScheduleSection(
    UnifiedListItem? allDaySchedule,
    List<UnifiedListItem> normalSchedules,
    DateTime date,
    List<UnifiedListItem> allItems,
  ) {
    // 종일 일정이 있으면 Row로 2컬럼
    if (allDaySchedule != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 24, right: 0), // 우측 패딩은 카드에 있음
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== 좌측: 종일 일정 (40%) =====
            Expanded(
              flex: 4,
              child: _buildAllDayCard(allDaySchedule, normalSchedules.length, date),
            ),

            const SizedBox(width: 8), // 간격

            // ===== 우측: 일반 일정들 (60%) =====
            Expanded(
              flex: 6,
              child: _buildNormalScheduleList(normalSchedules, date, allItems),
            ),
          ],
        ),
      );
    }
    // 종일 일정이 없으면 일반 일정만 전체 너비로
    else {
      return _buildNormalScheduleList(normalSchedules, date, allItems);
    }
  }

  /// 종일 카드 빌더
  /// 이거를 설정하고 → 종일 일정 카드를 우측 일정 개수에 맞춰 높이 조절해서
  /// 이거를 해서 → 좌우 카드가 같은 높이를 유지하도록 한다
  Widget _buildAllDayCard(
    UnifiedListItem allDaySchedule,
    int normalScheduleCount,
    DateTime date,
  ) {
    final cardHeight = 64.0; // 일반 카드 1개 높이
    final spacing = 4.0; // 카드 간 간격
    final totalHeight = normalScheduleCount > 0
        ? (cardHeight * normalScheduleCount) + (spacing * (normalScheduleCount - 1))
        : cardHeight;

    return Container(
      height: totalHeight,
      child: _buildCardByType(
        allDaySchedule,
        date,
        [],
        0,
      ),
    );
  }

  /// 일반 일정 리스트 빌더 (AnimatedReorderableListView 사용)
  /// 이거를 설정하고 → shrinkWrap: true로 설정하여 Column 안에서 사용 가능하게 하고
  /// 이거를 해서 → 기존 드래그앤드롭 기능을 그대로 유지한다
  Widget _buildNormalScheduleList(
    List<UnifiedListItem> normalSchedules,
    DateTime date,
    List<UnifiedListItem> allItems,
  ) {
    if (normalSchedules.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedReorderableListView(
      items: normalSchedules,
      shrinkWrap: true, // ⚠️ 필수! Column 안에서 사용 시
      physics: const NeverScrollableScrollPhysics(), // 부모 스크롤에 위임

      itemBuilder: (context, index) {
        final item = normalSchedules[index];
        return _buildCardByType(item, date, [], index);
      },

      onReorderStart: (index) {
        print('🎯 [Schedule onReorderStart] index=$index');
      },

      onReorderEnd: (index) {
        print('🏁 [Schedule onReorderEnd] index=$index');
      },

      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = normalSchedules.removeAt(oldIndex);
          normalSchedules.insert(newIndex, item);

          // allItems에도 반영
          _updateAllItemsOrder(allItems, normalSchedules);
        });

        _saveDailyCardOrder(allItems);
        HapticFeedback.mediumImpact();
      },

      isSameItem: (a, b) => a.uniqueId == b.uniqueId,

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
          curve: Curves.easeIn,
          begin: 1.0,
          end: 0.95,
        ),
        FadeIn(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        ),
      ],

      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scale = 1.0 + (animation.value * 0.03);
            final rotation = animation.value * 0.05;

            return Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: rotation,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x14111111),
                        offset: const Offset(0, 4),
                        blurRadius: 20,
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
  }

  /// Divider 아래 섹션 빌더 (할일, 습관, 완료)
  /// 이거를 설정하고 → 점선 아래 모든 아이템을 AnimatedReorderableListView로 표시해서
  /// 이거를 해서 → 할일/습관/완료 섹션도 재정렬 가능하도록 한다
  Widget _buildBelowDividerSection(
    List<UnifiedListItem> belowDividerItems,
    DateTime date,
    List<TaskData> completedTasks,
    List<UnifiedListItem> allItems,
  ) {
    return AnimatedReorderableListView(
      items: belowDividerItems,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemBuilder: (context, index) {
        final item = belowDividerItems[index];
        return _buildCardByType(item, date, completedTasks, index);
      },

      onReorderStart: (index) {
        print('🎯 [BelowDivider onReorderStart] index=$index');
      },

      onReorderEnd: (index) {
        print('🏁 [BelowDivider onReorderEnd] index=$index');
      },

      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = belowDividerItems.removeAt(oldIndex);
          belowDividerItems.insert(newIndex, item);

          // allItems에도 반영
          _updateAllItemsOrder(allItems, belowDividerItems);
        });

        _saveDailyCardOrder(allItems);
        HapticFeedback.mediumImpact();
      },

      isSameItem: (a, b) => a.uniqueId == b.uniqueId,

      insertDuration: const Duration(milliseconds: 300),
      removeDuration: const Duration(milliseconds: 250),

      dragStartDelay: _isDraggingFromInbox
          ? const Duration(days: 365)
          : const Duration(milliseconds: 500),

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
          curve: Curves.easeIn,
          begin: 1.0,
          end: 0.95,
        ),
        FadeIn(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        ),
      ],

      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scale = 1.0 + (animation.value * 0.03);
            final rotation = animation.value * 0.05;

            return Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: rotation,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x14111111),
                        offset: const Offset(0, 4),
                        blurRadius: 20,
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
  }

  /// allItems 순서 업데이트 헬퍼
  /// 이거를 설정하고 → 재정렬된 섹션의 순서를 allItems에 반영해서
  /// 이거를 해서 → DB 저장 시 올바른 순서가 저장되도록 한다
  void _updateAllItemsOrder(List<UnifiedListItem> allItems, List<UnifiedListItem> sectionItems) {
    // sortOrder 재계산
    for (int i = 0; i < allItems.length; i++) {
      allItems[i] = allItems[i].copyWith(sortOrder: i);
    }
  }

  /// 🎨 타입별 카드 렌더링 함수
  /// 이거를 설정하고 → UnifiedListItem 타입을 확인해서
  /// 이거를 해서 → 기존 카드 컴포넌트를 그대로 재사용하고
  /// 이거는 이래서 → 기존 디자인과 기능이 100% 유지된다
  Widget _buildCardByType(
    UnifiedListItem item,
    DateTime date,
    List<TaskData> completedTasks,
    int index, // 🎯 플레이스홀더 위치 계산용 index
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

        return DragTarget<TaskData>(
          key: key,
          onWillAcceptWithDetails: (details) {
            // 🎯 인박스에서 드래그 시작됨
            if (!_isDraggingFromInbox) {
              setState(() {
                _isDraggingFromInbox = true;
              });
            }
            return true;
          },
          onMove: (details) {
            // 🎯 드래그 중 자동 스크롤 (context 전달)
            _handleAutoScroll(details.offset.dy, context);
          },
          onAcceptWithDetails: (details) async {
            final droppedTask = details.data;
            await GetIt.I<AppDatabase>().updateTaskDate(droppedTask.id, date);
            HapticFeedback.heavyImpact();
            // 🎯 드래그 완료 - 상태 초기화
            setState(() {
              _isDraggingFromInbox = false;
            });
          },
          builder: (context, candidateData, rejectedData) {
            // ✅ candidateData만으로 호버 상태 판단
            final isHovering = candidateData.isNotEmpty;

            return RepaintBoundary(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🎯 호버 시 빠르게 공간 생성
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    height: isHovering ? 64 : 0,
                  ),
                  // 실제 카드
                  AnimatedContainer(
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
                            ? Border.all(
                                color: Colors.red.withOpacity(0.6),
                                width: 2,
                              )
                            : null,
                      ),
                      child: GestureDetector(
                        onTap: () => _openScheduleDetail(schedule),
                        child: SlidableScheduleCard(
                          groupTag: 'unified_list',
                          scheduleId: schedule.id,
                          repeatRule: schedule.repeatRule, // 🔄 반복 규칙 전달
                          showConfirmDialog: true, // ✅ 삭제 확인 모달 표시
                          onComplete: () async {
                            await GetIt.I<AppDatabase>().completeSchedule(
                              schedule.id,
                            );
                            print('✅ [ScheduleCard] 완료: ${schedule.summary}');
                          },
                          onDelete: () async {
                            await GetIt.I<AppDatabase>().deleteSchedule(
                              schedule.id,
                            );
                            // 🗑️ DailyCardOrder에서도 삭제
                            await GetIt.I<AppDatabase>()
                                .deleteCardFromAllOrders(
                                  'schedule',
                                  schedule.id,
                                );
                            print('🗑️ [ScheduleCard] 삭제: ${schedule.summary}');
                            // ✅ 토스트 표시
                            if (context.mounted) {
                              showActionToast(context, type: ToastType.delete);
                            }
                          },
                          child: ScheduleCard(
                            start: schedule.start,
                            end: schedule.end,
                            summary: schedule.summary,
                            colorId: schedule.colorId,
                            repeatRule: schedule.repeatRule,
                            alertSetting: schedule.alertSetting,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      // ====================================================================
      // ✅ 할일 카드 (Task)
      // ====================================================================
      case UnifiedItemType.task:
        final task = item.data as TaskData;
        return DragTarget<TaskData>(
          key: key,
          onWillAcceptWithDetails: (details) {
            // 🎯 인박스에서 드래그 시작됨
            if (!_isDraggingFromInbox) {
              setState(() {
                _isDraggingFromInbox = true;
              });
            }
            return true;
          },
          onMove: (details) {
            // 🎯 드래그 중 자동 스크롤 (context 전달)
            _handleAutoScroll(details.offset.dy, context);
          },
          onAcceptWithDetails: (details) async {
            final droppedTask = details.data;
            await GetIt.I<AppDatabase>().updateTaskDate(droppedTask.id, date);
            HapticFeedback.heavyImpact();
            // 🎯 드래그 완료 - 상태 초기화
            setState(() {
              _isDraggingFromInbox = false;
            });
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;

            return RepaintBoundary(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🎯 호버 시 빠르게 공간 생성
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    height: isHovering ? 64 : 0,
                  ),
                  // 실제 카드
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4,
                      left: 24,
                      right: 24,
                    ),
                    child: SlidableTaskCard(
                      groupTag: 'unified_list',
                      taskId: task.id,
                      repeatRule: task.repeatRule, // 🔄 반복 규칙 전달
                      showConfirmDialog: true, // ✅ 삭제 확인 모달 표시
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
                        // ✅ 토스트 표시
                        if (context.mounted) {
                          showActionToast(context, type: ToastType.delete);
                        }
                      },
                      child: TaskCard(
                        task: task,
                        onToggle: () async {
                          if (task.completed) {
                            await GetIt.I<AppDatabase>().uncompleteTask(
                              task.id,
                            );
                            print('🔄 [TaskCard] 체크박스 완료 해제: ${task.title}');
                          } else {
                            await GetIt.I<AppDatabase>().completeTask(task.id);
                            print('✅ [TaskCard] 체크박스 완료 처리: ${task.title}');
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      // ====================================================================
      // 🔁 습관 카드 (Habit)
      // ====================================================================
      case UnifiedItemType.habit:
        final habit = item.data as HabitData;
        return DragTarget<TaskData>(
          key: key,
          onWillAcceptWithDetails: (details) {
            // 🎯 인박스에서 드래그 시작됨
            if (!_isDraggingFromInbox) {
              setState(() {
                _isDraggingFromInbox = true;
              });
            }
            return true;
          },
          onMove: (details) {
            // 🎯 드래그 중 자동 스크롤 (context 전달)
            _handleAutoScroll(details.offset.dy, context);
          },
          onAcceptWithDetails: (details) async {
            final droppedTask = details.data;
            await GetIt.I<AppDatabase>().updateTaskDate(droppedTask.id, date);
            HapticFeedback.heavyImpact();
            // 🎯 드래그 완료 - 상태 초기화
            setState(() {
              _isDraggingFromInbox = false;
            });
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;

            return RepaintBoundary(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🎯 호버 시 빠르게 공간 생성
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    height: isHovering ? 64 : 0,
                  ),
                  // 실제 카드
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4,
                      left: 24,
                      right: 24,
                    ),
                    child: GestureDetector(
                      onTap: () => _showHabitDetailModal(habit, date),
                      child: SlidableHabitCard(
                        groupTag: 'unified_list',
                        habitId: habit.id,
                        repeatRule: habit.repeatRule, // 🔄 반복 규칙 전달
                        showConfirmDialog: true, // ✅ 삭제 확인 모달 표시
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
                          // ✅ 토스트 표시
                          if (context.mounted) {
                            showActionToast(context, type: ToastType.delete);
                          }
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
                  ),
                ],
              ),
            );
          },
        );

      // ====================================================================
      // 📋 인박스 헤더 (Inbox Header)
      // 인박스 모드에서 리스트 맨 위에 표시되는 헤더
      // 상단 42px, 하단 32px, 좌우 32px 패딩 (좌우는 외부 24px + 내부 8px = 32px)
      // ====================================================================
      case UnifiedItemType.inboxHeader:
        return Container(
          key: key,
          padding: const EdgeInsets.fromLTRB(32, 42, 32, 32),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: 1.0,
            child: const Text(
              '1日の流れを\n表現しよ',
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontWeight: FontWeight.w700,
                fontSize: 19,
                height: 1.4,
                letterSpacing: -0.005 * 19,
                color: Color(0xFFCFCFCF),
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
      // 📋 인박스 모드에서는 숨김
      // ====================================================================
      case UnifiedItemType.completed:
        // 인박스 모드에서는 빈 컨테이너 반환
        if (_isInboxMode) {
          return SizedBox.shrink(key: key);
        }

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

      // ====================================================================
      // 🎯 드래그 플레이스홀더 (Placeholder)
      // ====================================================================
      case UnifiedItemType.placeholder:
        return SizedBox(
          key: key,
          height: 64, // 카드 높이만큼 투명한 공간
          width: double.infinity,
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
                            // ✅ RepaintBoundary + ValueKey로 성능 최적화
                            return RepaintBoundary(
                              key: ValueKey('schedule_${schedule.id}'),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: GestureDetector(
                                  onTap: () => _openScheduleDetail(schedule),
                                  child: SlidableScheduleCard(
                                    groupTag: 'unified_list',
                                    scheduleId: schedule.id,
                                    repeatRule: schedule.repeatRule, // 🔄 반복 규칙 전달
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
                                      repeatRule: schedule.repeatRule,
                                      alertSetting: schedule.alertSetting,
                                    ),
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
                    // 3. 할일 섹션 (추가순) + 🎯 DragTarget 추가
                    // ===============================================
                    // 🎯 빈 리스트일 때도 DragTarget 표시
                    if (incompleteTasks.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: DragTarget<TaskData>(
                            onAcceptWithDetails: (details) async {
                              final droppedTask = details.data;
                              print('✅ [DateDetail] 빈 리스트에 태스크 드롭: "${droppedTask.title}"');
                              
                              await GetIt.I<AppDatabase>().updateTaskDate(
                                droppedTask.id,
                                widget.selectedDate,
                              );
                              
                              HapticFeedback.heavyImpact();
                            },
                            onWillAcceptWithDetails: (details) {
                              print('🎯 [DateDetail] 빈 리스트 onWillAccept');
                              return true;
                            },
                            onMove: (details) {
                              print('👆 [DateDetail] 빈 리스트 onMove: ${details.offset}');
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isHovering = candidateData.isNotEmpty;
                              print('🔄 [DateDetail] 빈 리스트 builder: hovering=$isHovering');
                              
                              return Container(
                                height: 80,
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: isHovering 
                                    ? const Color(0xFF566099).withOpacity(0.1)
                                    : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isHovering
                                    ? Border.all(
                                        color: const Color(0xFF566099),
                                        width: 2,
                                      )
                                    : null,
                                ),
                                child: Center(
                                  child: isHovering
                                    ? const Icon(
                                        Icons.add,
                                        color: Color(0xFF566099),
                                        size: 32,
                                      )
                                    : const SizedBox.shrink(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    
                    if (incompleteTasks.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final task = incompleteTasks[index];
                            
                            // 🎯 각 Task 카드를 DragTarget으로 감싸기
                            return DragTarget<TaskData>(
                              onAcceptWithDetails: (details) async {
                                final droppedTask = details.data;
                                print('✅ [DateDetail] 태스크 드롭: "${droppedTask.title}" → ${widget.selectedDate}');
                                
                                // ✅ DB 업데이트
                                await GetIt.I<AppDatabase>().updateTaskDate(
                                  droppedTask.id,
                                  widget.selectedDate,
                                );
                                
                                HapticFeedback.heavyImpact();
                              },
                              onWillAcceptWithDetails: (details) {
                                print('🎯 [DateDetail] DragTarget onWillAccept: Task 리스트');
                                return true;
                              },
                              builder: (context, candidateData, rejectedData) {
                                final isHovering = candidateData.isNotEmpty;
                                
                                return Column(
                                  children: [
                                    // 🎯 호버링 중일 때 공간 표시 (자연스러운 삽입 위치)
                                    if (isHovering && index == 0)
                                      Container(
                                        height: 60,
                                        margin: const EdgeInsets.only(bottom: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF566099).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: const Color(0xFF566099),
                                            width: 2,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.add,
                                            color: Color(0xFF566099),
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                    
                                    // ✅ 기존 Task 카드
                                    RepaintBoundary(
                                      key: ValueKey('task_${task.id}'),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: SlidableTaskCard(
                                          groupTag: 'unified_list',
                                          taskId: task.id,
                                          repeatRule: task.repeatRule, // 🔄 반복 규칙 전달
                                          onTap: () => _openTaskDetail(task),
                                          onComplete: () async {
                                            await GetIt.I<AppDatabase>().completeTask(task.id);
                                            print('✅ [TaskCard] 완료 토글: ${task.title}');
                                          },
                                          onDelete: () async {
                                            await GetIt.I<AppDatabase>().deleteTask(task.id);
                                            print('🗑️ [TaskCard] 삭제: ${task.title}');
                                            // ✅ 토스트 표시
                                            if (context.mounted) {
                                              showActionToast(context, type: ToastType.delete);
                                            }
                                          },
                                          child: TaskCard(
                                            task: task,
                                            onToggle: () async {
                                              if (task.completed) {
                                                await GetIt.I<AppDatabase>().uncompleteTask(task.id);
                                                print('🔄 [TaskCard] 체크박스 완료 해제: ${task.title}');
                                              } else {
                                                await GetIt.I<AppDatabase>().completeTask(task.id);
                                                print('✅ [TaskCard] 체크박스 완료 처리: ${task.title}');
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
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
                            // ✅ RepaintBoundary + ValueKey로 성능 최적화
                            return DragTarget<TaskData>(
                              onWillAcceptWithDetails: (details) {
                                print('📌 습관 위로 Drag Hover: ${details.data.title} -> ${habit.title}');
                                return true;
                              },
                              onAcceptWithDetails: (details) async {
                                final droppedTask = details.data;
                                print('✅ 습관 위에 Drop: ${droppedTask.title} -> ${habit.title}');
                                await GetIt.I<AppDatabase>()
                                    .updateTaskDate(droppedTask.id, widget.selectedDate);
                                HapticFeedback.heavyImpact();
                              },
                              builder: (context, candidateData, rejectedData) {
                                final isHovering = candidateData.isNotEmpty;
                                return RepaintBoundary(
                                  key: ValueKey('habit_${habit.id}'),
                                  child: Column(
                                    children: [
                                      // 드래그 호버 시 공간 표시
                                      if (isHovering)
                                        Container(
                                          height: 60,
                                          margin: const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFF566099),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.add_circle_outline,
                                              color: Color(0xFF566099),
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: GestureDetector(
                                          onTap: () => _showHabitDetailModal(habit, date),
                                          child: SlidableHabitCard(
                                            groupTag: 'unified_list',
                                            habitId: habit.id,
                                            repeatRule: habit.repeatRule, // 🔄 반복 규칙 전달
                                            showConfirmDialog: true, // ✅ 삭제 확인 모달 표시
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
                                              // ✅ 토스트 표시
                                              if (context.mounted) {
                                                showActionToast(context, type: ToastType.delete);
                                              }
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
                                    ),
                                  ],
                                );
                              },
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

  // ============================================================================
  // 🆕 2컬럼 레이아웃 헬퍼 함수들 (파일 끝에 위치)
  // ============================================================================

  /// 종일 일정 확인
  /// 이거를 설정하고 → ScheduleData의 시간을 체크해서
  /// 이거를 해서 → 0:00~23:59인지 확인하고
  /// 이거는 이래서 → 종일 일정 여부를 반환한다
  bool _isAllDaySchedule(ScheduleData schedule) {
    final start = schedule.start;
    final end = schedule.end;
    
    // 0시 0분 ~ 23시 59분이면 종일
    return start.hour == 0 && 
           start.minute == 0 && 
           end.hour == 23 && 
           end.minute == 59;
  }

  /// 일정 아이템만 필터링
  /// 이거를 설정하고 → UnifiedListItem에서 일정만 추출해서
  /// 이거를 해서 → 일정 리스트만 반환한다
  List<UnifiedListItem> _getScheduleItems(List<UnifiedListItem> items) {
    return items
        .where((item) => item.type == UnifiedItemType.schedule)
        .toList();
  }

  /// 종일 일정 찾기
  /// 이거를 설정하고 → 일정 리스트에서 종일 일정을 찾아서
  /// 이거를 해서 → 첫 번째 종일 일정을 반환한다 (없으면 null)
  UnifiedListItem? _findAllDaySchedule(List<UnifiedListItem> scheduleItems) {
    for (var item in scheduleItems) {
      final schedule = item.data as ScheduleData;
      if (_isAllDaySchedule(schedule)) {
        return item;
      }
    }
    return null;
  }

  /// 일반 일정들 (종일 제외)
  /// 이거를 설정하고 → 종일 일정을 제외한 나머지 일정만 반환해서
  /// 이거를 해서 → 우측 컬럼에 표시할 일정 리스트를 만든다
  List<UnifiedListItem> _getNormalSchedules(
    List<UnifiedListItem> scheduleItems,
    UnifiedListItem? allDaySchedule,
  ) {
    if (allDaySchedule == null) return scheduleItems;
    
    return scheduleItems
        .where((item) => item.uniqueId != allDaySchedule.uniqueId)
        .toList();
  }

  /// Divider 이후 아이템들 (할일, 습관, 완료섹션)
  /// 이거를 설정하고 → Task, Habit, Completed 아이템만 반환해서
  /// 이거를 해서 → 점선 아래 영역을 구성한다
  List<UnifiedListItem> _getBelowDividerItems(List<UnifiedListItem> items) {
    // divider, inboxHeader는 제외하고 Task/Habit/Completed만 반환
    return items
        .where((item) => 
          item.type == UnifiedItemType.task ||
          item.type == UnifiedItemType.habit ||
          item.type == UnifiedItemType.completed
        )
        .toList();
  }
} // _DateDetailViewState 끝
