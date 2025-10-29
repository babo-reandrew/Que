import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ HapticFeedback 추가
import 'package:flutter_svg/flutter_svg.dart'; // ✅ SVG 아이콘 사용
import 'package:figma_squircle/figma_squircle.dart'; // ✅ Figma 스무싱 적용
import 'package:table_calendar/table_calendar.dart';
import 'package:smooth_sheets/smooth_sheets.dart'; // 📱 smooth_sheets 애니메이션
import 'package:dismissible_page/dismissible_page.dart'; // 🎯 Pull-to-dismiss 추가
import '../const/color.dart';
import '../const/calendar_config.dart';
import '../const/motion_config.dart';
import '../component/create_entry_bottom_sheet.dart';
import '../component/modal/settings_wolt_modal.dart'; // ✅ Settings Modal 추가
import '../component/modal/image_picker_smooth_sheet.dart'; // 📸 이미지 선택 Smooth Sheet + PickedImage
import '../component/modal/task_inbox_bottom_sheet.dart'; // 📋 Task Inbox 3-Stage Bottom Sheet 추가
import '../screen/date_detail_view.dart';
import '../Database/schedule_database.dart';
import '../utils/rrule_utils.dart'; // 🔥 RRULE 유틸리티 추가
import '../widgets/bottom_navigation_bar.dart'; // ✅ 하단 네비게이션 바 추가
import '../widgets/temp_input_box.dart'; // ✅ 임시 입력 박스 추가
import '../widgets/task_inbox_top_bar.dart'; // 🆕 Task Inbox 탑바 추가
import '../widgets/drawer_icons_overlay.dart'; // 🆕 서랍 아이콘 오버레이 추가
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime focusedDay = DateTime.now(); //
  DateTime? selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ); //현재 선택된 날짜이다. 중요!! 절대 지우거나 하면 안됨.

  // ⭐️ 로컬 schedules Map 제거됨
  // 이거는 이래서 → 이제 모든 일정은 DB에서 관리하고
  // 이거라면 → StreamBuilder로 실시간으로 가져온다

  // 🆕 Inbox 모드 상태 관리
  // 이거를 설정하고 → Inbox 모드 여부를 추적해서
  // 이거를 해서 → UI를 조건부로 렌더링하고
  // 이거는 이래서 → seamless한 전환을 만든다
  bool _isInboxMode = false;

  // 🎯 바텀시트 표시 상태 (Stack에서 직접 렌더링하기 위함)
  bool _showTaskInboxSheet = false;

  // 📋 DateDetailView의 인박스 모드 상태 추적 (DismissiblePage 제어용)
  bool _isDateDetailInboxMode = false;

  //  서랍 아이콘 표시 여부
  // 이거를 설정하고 → 아이콘 표시 타이밍을 제어해서
  // 이거를 해서 → 네비게이션 바 전환 후 아이콘을 표시하고
  // 이거는 이래서 → 순차적인 애니메이션을 만든다
  final bool _showDrawerIcons = false;

  @override
  void initState() {
    super.initState();

    // 🔧 dtstart 정규화 마이그레이션 (1회 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runMigration();
      _preloadKeyboard();
    });
  }

  /// 🔧 데이터베이스 마이그레이션 실행
  Future<void> _runMigration() async {
    try {
      final db = GetIt.I<AppDatabase>();
      await db.normalizeDtstartDates();
      print('✅ [HomeScreen] 마이그레이션 완료');
    } catch (e) {
      print('⚠️ [HomeScreen] 마이그레이션 실패: $e');
    }
  }

  /// 키보드 프리로딩: 보이지 않는 TextField를 만들어서 키보드 초기화
  void _preloadKeyboard() {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        top: 0,
        child: Opacity(
          opacity: 0.0, // 완전히 투명
          child: SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              autofocus: true, // 자동으로 포커스해서 키보드 초기화
            ),
          ),
        ),
      ),
    );

    // 1프레임만 표시하고 바로 제거
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 100), () {
      overlayEntry.remove();
      print('⌨️ [키보드] 프리로딩 완료');
    });
  }

  @override
  Widget build(BuildContext context) {
    // 📅 캘린더에 보이는 날짜 범위 계산 (현재 달 + 이전/다음 달 일부)
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    // 캘린더는 이전 달 마지막 주 ~ 다음 달 첫 주까지 보여주므로 여유있게 ±7일
    final rangeStart = firstDayOfMonth.subtract(const Duration(days: 7));
    final rangeEnd = lastDayOfMonth.add(
      const Duration(days: 8),
    ); // +1일 (23:59:59까지)

    // 🔥 이중 StreamBuilder: 일정과 할 일을 모두 가져오기
    // 외부: watchTasks() - 전체 할 일 목록
    // 내부: watchSchedulesInRange() - 범위 내 일정 목록
    return StreamBuilder<List<TaskData>>(
      stream: GetIt.I<AppDatabase>().watchTasks(),
      builder: (context, taskSnapshot) {
        // 이거를 설정하고 → watchSchedulesInRange()로 보이는 범위의 일정만 실시간 스트림으로 가져와서
        // 이거를 해서 → Map<DateTime, List<ScheduleData>>로 변환한 다음
        // 이거는 이래서 → TableCalendar가 해당 날짜별 일정 개수를 표시할 수 있다
        return StreamBuilder<List<ScheduleData>>(
          stream: GetIt.I<AppDatabase>().watchSchedulesInRange(
            rangeStart,
            rangeEnd,
          ),
          builder: (context, snapshot) {
            // 로딩 중이거나 에러 처리
            if (snapshot.connectionState == ConnectionState.waiting ||
                taskSnapshot.connectionState == ConnectionState.waiting) {
              print('⏳ [HomeScreen] StreamBuilder 로딩 중...');
            }

            // 일정 리스트를 Map<DateTime, List<ScheduleData>>로 변환
            // 🔥 CRITICAL: 반복 일정은 RRULE 인스턴스 날짜별로 추가해야 함!

            if (snapshot.hasError) {
              print('❌ [HomeScreen] StreamBuilder 에러: ${snapshot.error}');
            }

            // 🔥 FutureBuilder로 비동기 처리
            if (!snapshot.hasData || !taskSnapshot.hasData) {
              return const Scaffold(
                backgroundColor: Color(0xFFF7F7F7),
                body: Center(child: CircularProgressIndicator()),
              );
            }

            print(
              '🔄 [HomeScreen] StreamBuilder 데이터 수신: ${snapshot.data!.length}개 일정, ${taskSnapshot.data!.length}개 할 일',
            );

            // 🔥 CRITICAL: 일정과 할 일 모두 처리
            return FutureBuilder<
              (Map<DateTime, List<ScheduleData>>, Map<DateTime, List<TaskData>>)
            >(
              future:
                  Future.wait<dynamic>([
                    _processSchedulesForCalendarAsync(
                      snapshot.data!,
                      rangeStart,
                      rangeEnd,
                    ),
                    _processTasksForCalendarAsync(
                      taskSnapshot.data!,
                      rangeStart,
                      rangeEnd,
                    ),
                  ]).then(
                    (results) => (
                      results[0] as Map<DateTime, List<ScheduleData>>,
                      results[1] as Map<DateTime, List<TaskData>>,
                    ),
                  ),
              builder: (context, futureSnapshot) {
                final schedules =
                    futureSnapshot.data?.$1 ?? <DateTime, List<ScheduleData>>{};
                final tasks =
                    futureSnapshot.data?.$2 ?? <DateTime, List<TaskData>>{};
                final hasNoData =
                    snapshot.data!.isEmpty && taskSnapshot.data!.isEmpty;

                return Scaffold(
                  backgroundColor: const Color(0xFFF7F7F7), // ✅ 월뷰 배경색
                  resizeToAvoidBottomInset:
                      false, // ✅ KeyboardAttachable 필수 설정!
                  extendBody: true, // ✅ body가 하단까지 확장
                  body: Stack(
                    children: [
                      // ✅ 데이터 없음 메시지 (배경)
                      if (hasNoData)
                        Center(
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
                        ),
                      // 🆕 메인 뷰 (탑바는 고정, 캘린더만 축소)
                      Positioned.fill(
                        child: Column(
                          children: [
                            // ✅ 상단 여백 52px (4px 위로 올림)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOutQuart, // ✅ 부드럽게 가속/감속
                              height: 52,
                            ),

                            // ✅ 탑바 컨테이너 - "변신!" 외치는 순간
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOutQuart,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Stack(
                                children: [
                                  // 월 텍스트만 애니메이션 적용
                                  AnimatedSwitcher(
                                    duration: const Duration(
                                      milliseconds: 850,
                                    ), // ✅ 더 긴 지속시간
                                    switchInCurve: const Interval(
                                      0.0,
                                      1.0,
                                      curve: Curves.easeInOutCubicEmphasized,
                                    ),
                                    switchOutCurve: const Interval(
                                      0.0,
                                      0.6, // ✅ 빠르게 사라짐
                                      curve: Curves.easeInCubic,
                                    ),
                                    transitionBuilder: (child, animation) {
                                      // Scene 1: 웅크린 상태로 시작
                                      final scaleAnimation =
                                          TweenSequence<double>([
                                            TweenSequenceItem(
                                              tween:
                                                  Tween<double>(
                                                        begin: 0.8,
                                                        end: 0.85,
                                                      ) // ✅ 살짝 준비
                                                      .chain(
                                                        CurveTween(
                                                          curve: Curves.easeIn,
                                                        ),
                                                      ),
                                              weight: 20,
                                            ),
                                            TweenSequenceItem(
                                              tween:
                                                  Tween<double>(
                                                        begin: 0.85,
                                                        end: 1.05,
                                                      ) // ✅ 빠르게 커짐
                                                      .chain(
                                                        CurveTween(
                                                          curve: Curves
                                                              .easeOutCubic,
                                                        ),
                                                      ),
                                              weight: 50,
                                            ),
                                            TweenSequenceItem(
                                              tween:
                                                  Tween<double>(
                                                        begin: 1.05,
                                                        end: 1.0,
                                                      ) // ✅ 살짝 되돌림
                                                      .chain(
                                                        CurveTween(
                                                          curve:
                                                              Curves.easeInOut,
                                                        ),
                                                      ),
                                              weight: 30,
                                            ),
                                          ]).animate(animation);

                                      final slideAnimation =
                                          TweenSequence<Offset>([
                                            TweenSequenceItem(
                                              tween:
                                                  Tween<Offset>(
                                                    begin: const Offset(
                                                      0,
                                                      0.4,
                                                    ), // ✅ 아래에 웅크림
                                                    end: const Offset(0, 0.2),
                                                  ).chain(
                                                    CurveTween(
                                                      curve: Curves.easeOut,
                                                    ),
                                                  ),
                                              weight: 30,
                                            ),
                                            TweenSequenceItem(
                                              tween:
                                                  Tween<Offset>(
                                                    begin: const Offset(0, 0.2),
                                                    end: const Offset(
                                                      0,
                                                      -0.02,
                                                    ), // ✅ 살짝 위로 튕김
                                                  ).chain(
                                                    CurveTween(
                                                      curve:
                                                          Curves.easeOutCubic,
                                                    ),
                                                  ),
                                              weight: 40,
                                            ),
                                            TweenSequenceItem(
                                              tween:
                                                  Tween<Offset>(
                                                    begin: const Offset(
                                                      0,
                                                      -0.02,
                                                    ),
                                                    end: Offset
                                                        .zero, // ✅ 정확한 위치에 안착
                                                  ).chain(
                                                    CurveTween(
                                                      curve: Curves.easeInOut,
                                                    ),
                                                  ),
                                              weight: 30,
                                            ),
                                          ]).animate(animation);

                                      final fadeAnimation =
                                          TweenSequence<double>([
                                            TweenSequenceItem(
                                              tween:
                                                  Tween<double>(
                                                        begin: 0.0,
                                                        end: 0.3,
                                                      ) // ✅ 천천히 나타남
                                                      .chain(
                                                        CurveTween(
                                                          curve: Curves.easeIn,
                                                        ),
                                                      ),
                                              weight: 20,
                                            ),
                                            TweenSequenceItem(
                                              tween:
                                                  Tween<double>(
                                                        begin: 0.3,
                                                        end: 1.0,
                                                      ) // ✅ 빠르게 선명
                                                      .chain(
                                                        CurveTween(
                                                          curve: Curves.easeOut,
                                                        ),
                                                      ),
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
                                    child: _isInboxMode
                                        ? TaskInboxTopBar(
                                            key: ValueKey(
                                              'inbox_top_bar_${focusedDay.month}',
                                            ),
                                            title: '${focusedDay.month}月',
                                            onSwipeLeft: () {
                                              setState(() {
                                                focusedDay = DateTime(
                                                  focusedDay.year,
                                                  focusedDay.month + 1,
                                                );
                                              });
                                            },
                                            onSwipeRight: () {
                                              setState(() {
                                                focusedDay = DateTime(
                                                  focusedDay.year,
                                                  focusedDay.month - 1,
                                                );
                                              });
                                            },
                                          )
                                        : _buildCustomHeader(),
                                  ),
                                  // 체크 버튼은 애니메이션 없이 고정
                                  if (_isInboxMode)
                                    Positioned(
                                      right: 24,
                                      top: 0,
                                      bottom: 0,
                                      child: Center(
                                        child: TaskInboxCheckButton(
                                          onClose: () {
                                            setState(() {
                                              _isInboxMode = false;
                                              _showTaskInboxSheet = false;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // ✅ 캘린더 - 천천히 공간을 양보하며 축소 (숨 쉬는 느낌)
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 900,
                                ), // ✅ 가장 긴 지속시간
                                curve: const Cubic(
                                  0.4,
                                  0.0,
                                  0.2,
                                  1.0,
                                ), // ✅ Material Emphasized curve
                                transform: _isInboxMode
                                    ? (Matrix4.identity()
                                        ..scale(0.84, 0.84)) // ✅ 가로 84%, 세로 84%
                                    : Matrix4.identity(),
                                transformAlignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 2, // 좌측 2px
                                    right: 2, // 우측 2px
                                    bottom: 74, // 고정 74px 패딩
                                  ),
                                  child: TableCalendar(
                                    // 1. 기본 설정: 언어를 한국어로 설정하고 날짜 범위를 지정한다
                                    locale:
                                        'ko_KR', // 한국어로 설정해서 월/요일이 한글로 표시되도록 한다
                                    firstDay: DateTime.utc(
                                      1800,
                                      1,
                                      1,
                                    ), // 캘린더의 최초 시작 날짜를 설정한다
                                    lastDay: DateTime.utc(
                                      3000,
                                      12,
                                      30,
                                    ), // 캘린더의 마지막 선택 가능 날짜를 설정한다
                                    focusedDay:
                                        focusedDay, // 현재 화면에 보이는 달을 설정한다
                                    // 2. 전체 화면 설정: shouldFillViewport를 true로 설정해서 뷰포트를 완전히 채운다
                                    shouldFillViewport:
                                        true, // 캘린더가 사용 가능한 모든 공간을 채우도록 설정한다
                                    // 3. ⭐️ 헤더 숨김: TableCalendar의 기본 헤더를 숨기고 커스텀 헤더를 사용한다
                                    headerVisible:
                                        false, // TableCalendar의 기본 헤더를 숨긴다
                                    // 4. ✅ 피그마 디자인: 요일 헤더 스타일 (CalenderViewWeek)
                                    // 일요일: #FF0000 (빨강), 토요일: #0000FF (파랑), 평일: #454545 (회색)
                                    // Regular 9px, 90% lineHeight, -0.005em letterSpacing
                                    daysOfWeekStyle: DaysOfWeekStyle(
                                      dowTextFormatter: (date, locale) {
                                        // 요일을 일본어로 표시 (月, 火, 水, 木, 金, 土, 日)
                                        const weekdays = [
                                          '月',
                                          '火',
                                          '水',
                                          '木',
                                          '金',
                                          '土',
                                          '日',
                                        ];
                                        return weekdays[date.weekday - 1];
                                      },
                                      weekdayStyle: const TextStyle(
                                        fontFamily: 'LINE Seed JP App_TTF',
                                        fontSize: 9, // Regular 9px
                                        fontWeight: FontWeight.w400, // Regular
                                        color: Color(0xFF454545), // 평일: #454545
                                        letterSpacing:
                                            -0.045, // -0.005em → -0.045px
                                        height: 0.9, // 90% lineHeight
                                      ),
                                      weekendStyle: const TextStyle(
                                        fontFamily: 'LINE Seed JP App_TTF',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w400,
                                        color: Color(
                                          0xFF454545,
                                        ), // 기본값 (아래 builder에서 개별 설정)
                                        letterSpacing: -0.045,
                                        height: 0.9,
                                      ),
                                    ),

                                    // 5. 캘린더 스타일: 날짜들의 모양과 색상을 설정한다
                                    calendarStyle:
                                        _buildCalendarStyle(), // 캘린더 전체 스타일을 적용해서 날짜들의 모양을 설정한다
                                    // 6. 날짜 선택 처리: ⚠️ 비활성화 (GestureDetector가 직접 처리)
                                    onDaySelected:
                                        null, // TableCalendar의 기본 onTap 비활성화
                                    // 7. ⭐️ 페이지(월) 변경 처리: 사용자가 좌우로 스와이프하여 월을 변경하면 헤더 업데이트
                                    onPageChanged: (focusedDay) {
                                      // focusedDay를 업데이트해서 헤더의 월 표시를 동적으로 변경한다
                                      // setState를 호출해서 UI를 다시 그리고 "오늘로 돌아가기" 버튼도 조건부로 표시한다
                                      setState(() {
                                        this.focusedDay =
                                            focusedDay; // 포커스된 날짜를 새로운 월의 날짜로 업데이트
                                      });
                                    },
                                    // 8. 선택된 날짜 판단: 어떤 날짜가 선택된 상태인지 확인한다
                                    selectedDayPredicate:
                                        _selectedDayPredicate, // 선택된 날짜인지 확인해서 선택된 날짜만 강조 표시한다
                                    // 9. 날짜 셀 빌더: 각 날짜 셀의 모양을 커스터마이징한다
                                    calendarBuilders: _buildCalendarBuilders(
                                      schedules,
                                      tasks, // 🆕 할 일 맵 전달
                                    ), // 각 날짜 셀의 모양을 설정해서 기본/선택/오늘/이전달 날짜를 다르게 표시한다
                                    // 10. ✅ 파란색 점(marker) 제거
                                    eventLoader: (day) =>
                                        [], // 이벤트 로더를 빈 리스트로 설정해서 marker 표시 안 함
                                  ),
                                ), // Padding 닫기
                              ), // AnimatedContainer 닫기
                            ), // Expanded 닫기
                          ],
                        ), // Column 닫기
                      ), // Positioned.fill 닫기
                      // 🆕 서랍 아이콘 오버레이 (Inbox 모드 + showDrawerIcons일 때만)
                      // 이거를 설정하고 → 하단 네비게이션 바가 있던 위치에 배치해서
                      // 이거를 해서 → 기존 하단 네비를 자연스럽게 대체하고
                      // 이거는 이래서 → seamless한 전환을 만든다
                      if (_showDrawerIcons)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0, // SafeArea.bottom을 포함한 하단 고정
                          child: SafeArea(
                            top: false, // 상단 SafeArea 무시
                            child: DrawerIconsOverlay(
                              onScheduleTap: () {
                                print('📅 [서랍] 스케줄 탭');
                                // TODO: 스케줄 화면으로 이동
                              },
                              onTaskTap: () {
                                print(
                                  '✅ [서랍] 태스크 탭 - Task Inbox Bottom Sheet 표시',
                                );
                                // 🎯 Stack에서 바텀시트 직접 표시
                                setState(() {
                                  _showTaskInboxSheet = true;
                                });
                              },
                              onRoutineTap: () {
                                print('🔄 [서랍] 루틴 탭');
                                // TODO: 루틴 화면으로 이동
                              },
                              onAddTap: () {
                                print('➕ [서랍] 추가 버튼 탭');
                                _showKeyboardAttachableQuickAdd();
                              },
                            ),
                          ),
                        ),

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
                            final targetDate = selectedDay ?? DateTime.now();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true, // ✅ 전체화면
                              backgroundColor: Colors.transparent, // ✅ 투명 배경
                              barrierColor: Colors.black.withOpacity(
                                0.4,
                              ), // ✅ 배경 dim
                              elevation: 0, // ✅ 그림자 제거
                              useSafeArea: false, // ✅ SafeArea 사용 안함
                              builder: (context) => CreateEntryBottomSheet(
                                selectedDate: targetDate,
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

                      // 🎯 Task Inbox 바텀시트 (Stack에 직접 렌더링 - Navigator 사용 안 함!)
                      if (_showTaskInboxSheet)
                        Positioned.fill(
                          child: TaskInboxBottomSheet(
                            onClose: () {
                              setState(() {
                                _showTaskInboxSheet = false;
                                _isInboxMode = false;
                              });
                            },
                          ),
                        ),

                      // 🆕 하단 네비게이션 바 (Stack 최상단 - 인박스 모드에서는 숨김)
                      if (!_isInboxMode)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: CustomBottomNavigationBar(
                            onInboxTap: () {
                              print('📥 [하단 네비] Inbox 버튼 클릭');
                              // 🎯 Stack에서 바텀시트 직접 표시
                              setState(() {
                                _isInboxMode = true;
                                _showTaskInboxSheet = true;
                              });
                            },
                            onImageAddTap: () {
                              print('🖼️ [하단 네비] 이미지 추가 버튼 클릭 → 이미지 선택 시트 오픈');
                              // 🎯 smooth_sheets 애니메이션과 함께 시트 표시
                              Navigator.of(context).push(
                                ModalSheetRoute(
                                  builder: (context) => ImagePickerSmoothSheet(
                                    onClose: () {
                                      Navigator.of(context).pop();
                                    },
                                    onImagesSelected:
                                        (List<PickedImage> selectedImages) {
                                          print(
                                            '✅ [HomeScreen] 선택된 이미지: ${selectedImages.length}개',
                                          );
                                          for (final img in selectedImages) {
                                            print(
                                              '   - 이미지 ID/path: ${img.idOrPath()}',
                                            );
                                          }
                                          Navigator.of(context).pop();
                                        },
                                  ),
                                ),
                              );
                            },
                            onAddTap: () {
                              // 🆕 KeyboardAttachable 방식으로 변경!
                              _showKeyboardAttachableQuickAdd();
                            },
                          ),
                        ),
                    ],
                  ),
                ); // Scaffold 닫기
              }, // FutureBuilder builder 닫기
            ); // FutureBuilder 닫기
          }, // 내부 StreamBuilder (schedules) 닫기
        ); // 내부 StreamBuilder 닫기
      }, // 외부 StreamBuilder (tasks) 닫기
    ); // 외부 StreamBuilder 닫기
  }

  /// 🎯 동적 캘린더 하단 패딩 계산
  /// - 주가 많을수록 패딩을 늘려서 마지막 주를 더 잘 보이게 함
  /// - 4주: 패딩 적음 (캘린더가 작아서 이미 잘 보임)
  /// - 5주: 패딩 중간
  /// 위젯 영역 ------------------------------------------------------------------------------------------------
  // ⭐️ 피그마 디자인: TopNavi (54px 높이)
  // 좌측: 아이콘 버튼 (44×44px) + 중앙: "7月 2025" (ExtraBold 27px) + 우측: 날짜 배지 "11" (검은 배경, 36×36px)
  Widget _buildCustomHeader() {
    final today = DateTime.now();
    final isNotCurrentMonth =
        focusedDay.month != today.month || focusedDay.year != today.year;

    return Container(
      height: 54, // 피그마: TopNavi 높이 54px
      padding: const EdgeInsets.fromLTRB(
        12,
        5,
        18,
        5,
      ), // 피그마: 5px 18px 5px 12px
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F7), // 피그마: 배경색 #F7F7F7
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ 좌측: 아이콘 버튼 영역 (Frame 685)
          Row(
            children: [
              // 아이콘 버튼 (Frame 684: 44×44px, padding 6px)
              GestureDetector(
                onTap: () {
                  debugPrint('📱 [HomeScreen] 메뉴 버튼 클릭 → Settings Modal 표시');
                  showSettingsWoltModal(context);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(6), // 피그마: 6px 패딩
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    'asset/icon/menu_icon.svg',
                    width: 32, // 피그마: 32×32px
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // ✅ 날짜 표시 영역 (Frame 688) - 탭 가능
              GestureDetector(
                onTap: () {
                  _showMonthYearPicker();
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // "7月" (ExtraBold 27px, #111111)
                    Text(
                      '${focusedDay.month}月',
                      style: const TextStyle(
                        fontFamily: 'LINE Seed JP App_TTF',
                        fontSize: 27,
                        fontWeight: FontWeight.w800, // ExtraBold
                        color: Color(0xFF111111),
                        letterSpacing: -0.135,
                        height: 1.4, // lineHeight 37.8 / fontSize 27
                      ),
                    ),

                    const SizedBox(width: 4),

                    // "2025" (Bold 28px, #CFCFCF)
                    Text(
                      '${focusedDay.year}',
                      style: const TextStyle(
                        fontFamily: 'LINE Seed JP App_TTF',
                        fontSize: 28,
                        fontWeight: FontWeight.w700, // Bold
                        color: Color(0xFFCFCFCF),
                        letterSpacing: -0.135,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(width: 6),

                    // down_icon.svg (16px, #CFCFCF)
                    SvgPicture.asset(
                      'asset/icon/down_icon.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFCFCFCF),
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ✅ 우측: 날짜 배지 (Frame 686) - 오늘이 아닌 월일 때만 표시
          // 피그마: 44×44px Container with 4px padding
          if (isNotCurrentMonth)
            Container(
              width: 44, // 피그마: Frame 686 크기
              height: 44,
              padding: const EdgeInsets.all(4), // 피그마: 4px 패딩
              child: _buildTodayButton(today),
            ),
        ],
      ),
    );
  }

  // ✅ 피그마 디자인: Frame 686 (오늘 날짜 배지)
  // 36×36px, 검은 배경 (#111111), radius 12px (smoothing 60%), "11" 텍스트 (ExtraBold 12px, 흰색)
  Widget _buildTodayButton(DateTime today) {
    return Hero(
      tag: 'today-button-${today.toString()}',
      createRectTween: (begin, end) {
        return AppleStyleRectTween(begin: begin, end: end);
      },
      flightShuttleBuilder: appleStyleHeroFlightShuttleBuilder,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              focusedDay = today;
              selectedDay = DateTime.utc(today.year, today.month, today.day);
            });
          },
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 12,
              cornerSmoothing: 0.6, // 60% smoothing
            ),
          ),
          child: Container(
            width: 36, // 피그마: Frame 123 크기 36×36px
            height: 36,
            decoration: ShapeDecoration(
              color: const Color(0xFF111111), // 피그마: 배경색 #111111
              shape: SmoothRectangleBorder(
                side: BorderSide(
                  color: const Color(
                    0xFF000000,
                  ).withOpacity(0.04), // 피그마: rgba(0,0,0,0.04)
                  width: 1,
                ),
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 12, // 피그마: radius 12px
                  cornerSmoothing: 0.6, // 60% smoothing
                ),
              ),
              shadows: [
                // 피그마: 0px 4px 20px rgba(0,0,0,0.12)
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.12),
                  offset: const Offset(0, 4),
                  blurRadius: 20,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '${today.day}', // 피그마: "11" 텍스트
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 12, // 피그마: ExtraBold 12px
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFFFFF), // 피그마: 흰색
                letterSpacing: -0.06,
                height: 1.4, // lineHeight 16.8 / fontSize 12
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ 피그마 디자인: 캘린더 스타일 (CalenderViewWeek + CalenderView_Date)
  CalendarStyle _buildCalendarStyle() {
    return CalendarStyle(
      // ✅ 배경색: #F7F7F7 (Caldender_Basic_View)
      cellMargin: const EdgeInsets.all(0), // 셀 간격 제거
      cellPadding: const EdgeInsets.all(3), // 셀 패딩 3px (피그마)
      // ✅ 평일 날짜 스타일
      defaultDecoration: BoxDecoration(
        color: const Color(0xFFF7F7F7), // 배경색 #F7F7F7
        borderRadius: BorderRadius.circular(0), // 피그마에 보더 없음
      ),
      defaultTextStyle: const TextStyle(
        fontFamily: 'LINE Seed JP App_TTF',
        fontSize: 9,
        fontWeight: FontWeight.w700, // Bold
        color: Color(0xFF111111), // #111111
        letterSpacing: -0.045,
        height: 0.9,
      ),

      // ✅ 주말 날짜 스타일 (토요일, 일요일은 커스텀 빌더에서 처리)
      weekendDecoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(0),
      ),
      weekendTextStyle: const TextStyle(
        fontFamily: 'LINE Seed JP App_TTF',
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111111),
        letterSpacing: -0.045,
        height: 0.9,
      ),

      // ✅ 선택된 날짜 스타일 (20일: 검은 배경 + 흰 텍스트)
      selectedDecoration: BoxDecoration(
        color: const Color(0xFF111111), // 피그마: #111111
        borderRadius: BorderRadius.circular(9), // 피그마: radius 9px
      ),
      selectedTextStyle: const TextStyle(
        fontFamily: 'LINE Seed JP App_TTF',
        fontSize: 10, // ExtraBold 10px
        fontWeight: FontWeight.w800, // ExtraBold
        color: Color(0xFFF7F7F7), // 흰색
        letterSpacing: -0.05,
        height: 0.9,
      ),

      // ✅ 오늘 날짜 스타일 (선택과 동일하게)
      isTodayHighlighted: false, // 커스텀 빌더에서 처리
      todayDecoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(0),
      ),
      todayTextStyle: const TextStyle(
        fontFamily: 'LINE Seed JP App_TTF',
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111111),
        letterSpacing: -0.045,
        height: 0.9,
      ),

      // ✅ 이전달/다음달 날짜 스타일 (#999999)
      outsideDaysVisible: true,
      outsideDecoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(0),
      ),
      outsideTextStyle: const TextStyle(
        fontFamily: 'LINE Seed JP App_TTF',
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: Color(0xFF999999), // #999999
        letterSpacing: -0.045,
        height: 0.9,
      ),
    );
  }

  // 캘린더 빌더 설정 위젯
  // 이거를 설정하고 → schedules 맵을 받아서 각 셀에 일정 데이터를 전달한다
  CalendarBuilders _buildCalendarBuilders(
    Map<DateTime, List<ScheduleData>> schedules,
    Map<DateTime, List<TaskData>> tasks, // 🆕 할 일 맵 추가
  ) {
    return CalendarBuilders(
      // ✅ Figma: 요일 헤더 빌더 추가 (일요일 빨강, 토요일 파랑)
      dowBuilder: (context, day) {
        // 요일에 따라 색상 결정
        Color textColor;
        if (day.weekday == DateTime.sunday) {
          textColor = const Color(0xFFFF0000); // 일요일: 빨강
        } else if (day.weekday == DateTime.saturday) {
          textColor = const Color(0xFF0000FF); // 토요일: 파랑
        } else {
          textColor = const Color(0xFF454545); // 평일: 회색
        }

        // 요일 텍스트 가져오기 (일본어)
        const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
        final weekdayText = weekdays[day.weekday - 1];

        return Center(
          child: Text(
            weekdayText,
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: textColor,
              letterSpacing: -0.045,
              height: 0.9,
            ),
          ),
        );
      },
      // 평일(기본) 셀
      defaultBuilder: (context, day, focusedDay) {
        // ✅ Figma: 평일 #111111, 일요일 #FF0000
        final textColor = day.weekday == 7
            ? const Color(0xFFFF0000) // 일요일: 빨강
            : const Color(0xFF111111); // 평일: 검정

        return _buildCalendarCell(
          day: day,
          backgroundColor: Colors.transparent,
          textColor: textColor,
          daySchedules: schedules, // 일정 데이터 전달
          dayTasks: tasks, // 🆕 할 일 데이터 전달
        );
      },
      // 선택된 날짜 셀 - 색상 제거 (기본 스타일과 동일하게)
      selectedBuilder: (context, day, focusedDay) {
        // ✅ Figma: 평일 #111111, 일요일 #FF0000, 토요일 #1D00FB
        final textColor = day.weekday == 7
            ? const Color(0xFFFF0000) // 일요일: 빨강
            : day.weekday == 6
            ? const Color(0xFF1D00FB) // 토요일: 파랑
            : const Color(0xFF111111); // 평일: 검정

        return _buildCalendarCell(
          day: day,
          backgroundColor: Colors.transparent, // ⭐️ 선택된 날짜 색상 제거
          textColor: textColor, // ⭐️ 요일별 텍스트 색상 사용
          daySchedules: schedules, // 일정 데이터 전달
          dayTasks: tasks, // 🆕 할 일 데이터 전달
        );
      },
      // 오늘 날짜 셀 (검은 배경 + 흰 텍스트)
      todayBuilder: (context, day, focusedDay) {
        return _buildCalendarCell(
          day: day,
          backgroundColor: calendarTodayBg, // #111111 (검정)
          textColor: calendarTodayText, // #F7F7F7 (흰색)
          isCircular: false, // 기본 스타일과 동일하게 (둥근 모서리)
          daySchedules: schedules, // 일정 데이터 전달
          dayTasks: tasks, // 🆕 할 일 데이터 전달
        );
      },
      // 이전 달/다음 달 날짜 셀 (회색으로 표시하고 가운데 정렬)
      outsideBuilder: (context, day, focusedDay) {
        return _buildCalendarCell(
          day: day,
          backgroundColor: Colors.transparent, // 투명 배경
          textColor: const Color(0xFF999999), // ✅ Figma: #999999 (회색)
          daySchedules: schedules, // 일정 데이터 전달
          dayTasks: tasks, // 🆕 할 일 데이터 전달
        );
      },
    );
  }

  /// 핵심 함수 영역 ------------------------------------------------------------------------------------------------
  /// 날짜 선택 처리 함수: 사용자가 날짜를 클릭하면 DateDetailView로 이동한다
  /// 이거를 설정하고 → 선택된 날짜를 저장하고
  /// 이거를 해서 → DateDetailView로 화면 전환한다
  /// 이거는 이래서 → DB 기반이므로 별도 데이터 전달 불필요
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print('\n========================================');
    print('📅 [홈] 날짜 선택 이벤트 발생');
    print('   → 선택된 날짜: $selectedDay');
    print('   → 포커스된 날짜: $focusedDay');

    // ✅ OpenContainer가 자동으로 DateDetailView를 열므로
    // Navigator.push 불필요! 상태 업데이트만 수행
    setState(() {
      this.focusedDay = selectedDay;
      this.selectedDay = selectedDay;
    });
    print('✅ [홈] 상태 업데이트 완료');
    print('✅ [홈] OpenContainer가 자동으로 DateDetailView 전환 처리');
    print('========================================\n');
  }

  // 선택된 날짜 판단 함수: 선택된 날짜인지 확인해서 선택된 날짜만 강조 표시한다
  bool _selectedDayPredicate(DateTime date) {
    // 선택된 날짜인지 확인해서 선택된 날짜만 강조 표시한다
    if (selectedDay == null) return false; // 선택된 날짜가 없으면 false를 반환한다
    return isSameDay(date, selectedDay!); // 날짜가 같으면 true를 반환해서 선택된 날짜로 표시한다
  }

  /// 스케줄 관련 유틸 함수 영역 ------------------------------------------------------------------------------------------------

  // ⭐️ 셀 높이 기반 동적 일정 개수 계산 함수
  // 공식: ((셀의 높이 - 24) / 18 = 몫) - 2 = 실제 셀에 최대 들어갈 수 있는 일정 수
  // - 24 = 상단 영역 (4px padding + 22px 날짜 박스 + 2px gap 등)
  // - 18 = 일정 박스 하나의 높이 (18px) + 여백 포함
  // - -2 = "+숫자" 표시 및 overflow 방지를 위한 여유 공간 확보
  int _calculateMaxScheduleCount(double cellHeight) {
    // 1. 입력값 유효성 검사
    if (cellHeight <= 0) {
      print('⚠️ [높이 계산] 유효하지 않은 셀 높이: $cellHeight → 기본값 1개 반환');
      return 1;
    }

    // 2. 사용 가능한 높이 계산: 셀 높이에서 상단 고정 영역(24px) 제외
    final availableHeight = cellHeight - 24;

    // 3. 높이가 너무 작은 경우 처리
    if (availableHeight < 18) {
      print(
        '⚠️ [높이 계산] 셀 높이가 너무 작음: ${cellHeight.toStringAsFixed(1)}px → 최소값 1개 반환',
      );
      return 1;
    }

    // 4. 일정 박스가 들어갈 수 있는 개수 계산 (정수 나눗셈)
    final maxCount = (availableHeight / 18).floor();

    // 5. "+숫자" 표시 공간 및 overflow 방지를 위해 -2
    final finalCount = (maxCount - 2).clamp(1, 10); // 최소 1개, 최대 10개

    return finalCount;
  }

  // ✅ 피그마 디자인: Canleder_Month_View_Action (월뷰 일정 박스)
  // 배경: #EEEEEE (회색) 또는 #666666 (일본문화론), radius 6px, shadow, 좌측 1.5px 컬러바
  Widget _buildScheduleBox(ScheduleData schedule) {
    // 1. Schedule의 colorId를 실제 Color로 변환
    final baseColor = categoryColorMap[schedule.colorId] ?? categoryGray;

    // 2. ✅ 피그마 디자인: 배경색 결정
    // - 기본: #EEEEEE (Frame 795)
    // - 특정 카테고리(일본문화론 등): #666666 (흰색 텍스트)
    final bgColor = const Color(0xFFEEEEEE); // 피그마: 회색 배경
    final textColor = const Color(0xFF111111); // 피그마: 검은 텍스트

    // 3. ✅ 피그마: 18px 고정 높이 + radius 6px + shadow + 좌측 1.5px 컬러바
    return Container(
      width: double.infinity,
      height: 18, // 피그마: 고정 높이 18px
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor, // 피그마: #EEEEEE
        borderRadius: BorderRadius.circular(6), // 피그마: radius 6px
        border: Border.all(
          color: const Color(
            0xFF111111,
          ).withOpacity(0.04), // rgba(17,17,17,0.04)
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.04,
            ), // 0px 4px 20px rgba(0,0,0,0.04)
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ 좌측 컬러바 (1.5px, 8.5px 높이, Vector 56)
          Container(
            width: 0,
            height: 8.5,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: baseColor, // 원본 색상 사용
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(width: 3), // gap 3px
          // ✅ 텍스트 (좌측 정렬, Regular 9px)
          Expanded(
            child: Text(
              schedule.summary,
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 9, // 피그마: Regular 9px
                fontWeight: FontWeight.w400, // Regular
                color: textColor,
                letterSpacing: -0.045, // -0.005em → -0.045px
                height: 0.9, // lineHeight 90%
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left, // 좌측 정렬
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 피그마 디자인: 월뷰 할 일 박스 (일정과 다른 스타일)
  // 배경: 선택한 colorId 색상 (#666666 등), radius 6px, shadow, 좌측 선 없음, 흰색 텍스트
  Widget _buildTaskBox(TaskData task) {
    // 1. Task의 colorId를 실제 Color로 변환 → 배경색으로 사용
    final bgColor = categoryColorMap[task.colorId] ?? categoryGray;

    // 2. ✅ 피그마: 18px 고정 높이 + radius 6px + shadow + 배경색 전체 적용
    return Container(
      width: double.infinity,
      height: 18, // 피그마: 고정 높이 18px
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 3,
      ), // 피그마: 3px 4px
      decoration: BoxDecoration(
        color: bgColor, // 🆕 선택한 색상이 배경 전체
        borderRadius: BorderRadius.circular(6), // 피그마: radius 6px
        border: Border.all(
          color: const Color(0xFF111111).withOpacity(0.04),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          // 🆕 좌측 컬러바 없음 (일정과의 차이점)
          // ✅ 텍스트 (좌측 정렬, Regular 9px, 흰색)
          Expanded(
            child: Text(
              task.title,
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 9, // 피그마: Regular 9px
                fontWeight: FontWeight.w400, // Regular
                color: Color(0xFFFFFFFF), // 🆕 흰색 텍스트 (배경이 어두우므로)
                letterSpacing: -0.045, // -0.005em → -0.045px
                height: 0.9, // lineHeight 90%
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left, // 좌측 정렬
            ),
          ),
        ],
      ),
    );
  }

  /// 공통 함수 영역 ------------------------------------------------------------------------------------------------
  // 공통 캘린더 셀 위젯 함수
  // 수정된 부분: 이중 Container 구조로 터치 영역은 확장하되 디자인은 유지한다
  // 외부 Container: 터치 영역 확장 (double.infinity)
  // 내부 Container: 디자인 유지 (22px 고정)
  Widget _buildCalendarCell({
    required DateTime day, // 날짜를 받아서
    required Color backgroundColor, // 배경색을 받고
    required Color textColor, // 텍스트 색상도 받아서
    double size = CalendarConfig.cellSize, // 크기는 기본 22로 설정하고 (내부 Container용)
    bool isCircular = false, // 원형인지 확인해서
    required Map<DateTime, List<ScheduleData>> daySchedules, // 일정 맵을 받아서
    required Map<DateTime, List<TaskData>> dayTasks, // 🆕 할 일 맵을 받아서
  }) {
    // ⭐️ OpenContainer 구조:
    // 1. OpenContainer가 전체를 감싸서 탭 시 자동으로 DateDetailView 열림
    // 2. closedBuilder: 작은 셀 UI (날짜 + 일정 미리보기)
    // 3. openBuilder: 전체 화면 DateDetailView
    // 4. 자동으로 위치/크기 측정, 보간, 배경 scrim 처리

    // 이거를 설정하고 → 해당 날짜의 일정 및 할 일 리스트를 조회해서
    final dateKey = DateTime(day.year, day.month, day.day);
    final schedulesForDay = daySchedules[dateKey] ?? [];
    final tasksForDay = dayTasks[dateKey] ?? []; // 🆕 할 일 가져오기

    // ⭐️ 오늘 날짜인지 확인 (오늘 버튼 Hero는 별도 처리)
    final today = DateTime.now();
    final isToday =
        day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;

    final isNotCurrentMonth =
        focusedDay.month != today.month || focusedDay.year != today.year;

    // ✅ 오늘 날짜 + 다른 월 = Hero 유지 (OpenContainer 사용 안 함)
    if (isToday && isNotCurrentMonth) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'today-button-${today.year}-${today.month}-${today.day}',
                createRectTween: (begin, end) {
                  return AppleStyleRectTween(begin: begin, end: end);
                },
                flightShuttleBuilder: appleStyleHeroFlightShuttleBuilder,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontFamily: 'LINE Seed JP App_TTF',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.05,
                        height: 0.9,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildSchedulePreview(schedulesForDay, tasksForDay), // 🆕 할 일도 전달
          ],
        ),
      );
    }

    // 🆕 Inbox 모드에서는 OpenContainer 비활성화
    // 이거를 설정하고 → Inbox 모드일 때는 클릭해도 디테일뷰로 이동하지 않게 해서
    // 이거를 해서 → DragTarget으로 감싸서 드롭 가능하게 하고
    // 이거는 이래서 → 사용자가 Inbox 모드에서 태스크를 드래그하여 날짜에 배치할 수 있다
    // 🔒 하지만 디테일뷰에서 인박스 바텀시트가 열렸을 때는 월뷰로 드래그 불가
    if (_isInboxMode && !_isDateDetailInboxMode) {
      return DragTarget<TaskData>(
        onAcceptWithDetails: (details) async {
          final task = details.data;
          final targetDate = DateTime(day.year, day.month, day.day);
          print(
            '✅ [HomeScreen] 태스크 드롭: "${task.title}" → ${targetDate.toString().split(' ')[0]}',
          );

          // ✅ DB 업데이트
          await GetIt.I<AppDatabase>().updateTaskDate(task.id, targetDate);

          if (mounted) {
            HapticFeedback.heavyImpact();
          }
        },
        onWillAcceptWithDetails: (details) {
          // ✅ 드래그 중일 때 true 반환 → 하이라이트 표시
          return true;
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty; // ✅ 드래그 중인지 확인

          return Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.only(top: 4),
            decoration: isHovering
                ? BoxDecoration(
                    color: const Color(0xFF566099).withOpacity(0.1), // ✅ 하이라이트
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF566099),
                      width: 2,
                    ),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜 숫자
                Center(
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: isHovering
                          ? const Color(0xFF566099)
                          : backgroundColor, // ✅ 호버 시 색상 변경
                      borderRadius: BorderRadius.circular(isToday ? 9 : 8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontFamily: 'LINE Seed JP App_TTF',
                        fontSize: 10,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
                        color: isHovering
                            ? Colors.white
                            : textColor, // ✅ 호버 시 흰색
                        letterSpacing: -0.05,
                        height: 0.9,
                      ),
                    ),
                  ),
                ),
                _buildSchedulePreview(
                  schedulesForDay,
                  tasksForDay,
                ), // 🆕 할 일도 전달
              ],
            ),
          );
        },
      );
    }

    // ✅ 일반 모드: Hero + GestureDetector + PageRouteBuilder 사용
    // 🎯 Safari 스타일 Card Expansion을 위한 구조

    final cellHeroTag = 'date-cell-${day.year}-${day.month}-${day.day}';

    return Hero(
      tag: cellHeroTag,
      createRectTween: (begin, end) =>
          MaterialRectCenterArcTween(begin: begin, end: end),
      child: Material(
        color: const Color(0xFFF7F7F7),
        child: DragTarget<TaskData>(
          onAcceptWithDetails: (details) async {
            final task = details.data;
            final targetDate = DateTime(day.year, day.month, day.day);
            print(
              '✅ [HomeScreen] 태스크 드롭 성공: "${task.title}" → ${targetDate.toString().split(' ')[0]}',
            );

            // ✅ DB 업데이트
            await GetIt.I<AppDatabase>().updateTaskDate(task.id, targetDate);

            if (mounted) {
              HapticFeedback.heavyImpact();
            }
          },
          onWillAcceptWithDetails: (details) {
            print(
              '🎯 [HomeScreen] DragTarget onWillAccept: ${day.day}일 - ${details.data.title}',
            );
            return true;
          },
          onMove: (details) {
            print('🔍 [HomeScreen] onMove: ${day.day}일');
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;

            if (isHovering) {
              print('💜 [HomeScreen] 호버링 중: ${day.day}일');
            }

            // 🎯 GestureDetector로 탭 처리 (Hero는 DismissiblePage가 처리)
            return GestureDetector(
              behavior: HitTestBehavior.opaque, // 🎯 셀 전체 영역 클릭 가능!
              onTap: () {
                print('━━━━━━━━━━━━━━━━━━━━━━━━━━');
                print('📅 날짜 셀 탭 이벤트');
                print('  - 클릭한 날짜: ${day.toString().split(' ')[0]}');

                // 1️⃣ 상태 업데이트
                setState(() {
                  selectedDay = dateKey;
                  focusedDay = dateKey;
                });

                // 🎯 DismissiblePage로 Pull-to-dismiss + Hero 구현
                print(
                  '🎯 [DismissiblePage] 생성 - 현재 인박스 모드: $_isDateDetailInboxMode',
                );
                
                // 🔄 인박스 모드 변경을 감지하기 위한 ValueNotifier
                final inboxModeNotifier = ValueNotifier<bool>(_isDateDetailInboxMode);
                
                context.pushTransparentRoute(
                  ValueListenableBuilder<bool>(
                    valueListenable: inboxModeNotifier,
                    builder: (context, isInboxMode, _) {
                      return DismissiblePage(
                        key: ValueKey(isInboxMode), // 🔑 인박스 모드 변경 시 재생성
                        onDismissed: () {
                          print('🚪 [DismissiblePage] onDismissed 호출됨!');
                          setState(() {
                            _isDateDetailInboxMode = false; // 🔥 닫힐 때만 리셋
                          });
                          Navigator.of(context).pop();
                        },
                        // 🎯 일반 모드: down (위→아래로만) / 인박스 모드: none (완전 차단)
                        direction: isInboxMode
                            ? DismissiblePageDismissDirection.none
                            : DismissiblePageDismissDirection.down,
                        backgroundColor: Colors.black,
                        startingOpacity: 0.5, // 시작 배경 투명도
                        minRadius: 36, // Border radius (작아질 때)
                        minScale: 0.85, // 최소 스케일 (1.0 → 0.85)
                        maxTransformValue: 0.3, // 30% 드래그 시 dismiss (일반 모드만)
                        reverseDuration: const Duration(milliseconds: 300),
                        child: DateDetailView(
                          selectedDate: dateKey,
                          onClose: (lastDate) {
                            // 🎯 날짜 변경 반영
                            setState(() {
                              selectedDay = lastDate;
                              focusedDay = lastDate;
                            });
                          },
                          onInboxModeChanged: (newInboxMode) {
                            // 📋 DateDetailView의 인박스 모드 상태 변경 추적
                            setState(() {
                              _isDateDetailInboxMode = newInboxMode;
                            });
                            inboxModeNotifier.value = newInboxMode; // 🔄 ValueNotifier 업데이트
                            print(
                              '🎯 [HomeScreen] DateDetailView 인박스 모드 변경: $newInboxMode',
                            );
                          },
                        ),
                      );
                    },
                  ),
                );

                print('✅ [셀 탭] DateDetailView로 전환 완료 (DismissiblePage)');
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent, // 🎯 투명하지만 터치 이벤트 받음!
                padding: const EdgeInsets.only(top: 4),
                decoration: isHovering
                    ? BoxDecoration(
                        color: const Color(0xFF566099).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF566099),
                          width: 2,
                        ),
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ 날짜 숫자
                    Center(
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: isHovering
                              ? const Color(0xFF566099)
                              : backgroundColor,
                          borderRadius: BorderRadius.circular(isToday ? 9 : 8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontFamily: 'LINE Seed JP App_TTF',
                            fontSize: 10,
                            fontWeight: isToday
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: isHovering ? Colors.white : textColor,
                            letterSpacing: -0.05,
                            height: 0.9,
                          ),
                        ),
                      ),
                    ),
                    // 일정+할 일 미리보기
                    _buildSchedulePreview(schedulesForDay, tasksForDay),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ========================================
  // 일정+할 일 미리보기 위젯 (Expanded 영역)
  // ========================================
  Widget _buildSchedulePreview(
    List<ScheduleData> schedulesForDay,
    List<TaskData> tasksForDay, // 🆕 할 일 리스트 추가
  ) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellHeight = constraints.maxHeight + 26;
          final maxDisplayCount = _calculateMaxScheduleCount(cellHeight);

          // 🆕 일정과 할 일이 모두 없으면 빈 위젯 반환
          if (schedulesForDay.isEmpty && tasksForDay.isEmpty) {
            return const SizedBox.shrink();
          }

          // 🆕 우선순위: 일정 먼저, 그 다음 할 일
          // 전체 표시 개수는 maxDisplayCount로 제한
          final List<Widget> displayItems = [];

          // 1️⃣ 일정 추가 (우선순위 높음)
          for (
            int i = 0;
            i < schedulesForDay.length && displayItems.length < maxDisplayCount;
            i++
          ) {
            displayItems.add(_buildScheduleBox(schedulesForDay[i]));
          }

          // 2️⃣ 할 일 추가 (일정 다음에 표시)
          for (
            int i = 0;
            i < tasksForDay.length && displayItems.length < maxDisplayCount;
            i++
          ) {
            displayItems.add(_buildTaskBox(tasksForDay[i]));
          }

          // 3️⃣ 남은 개수 계산 (일정 + 할 일 전체에서 표시된 것 제외)
          final totalCount = schedulesForDay.length + tasksForDay.length;
          final remainingCount = totalCount - displayItems.length;

          return Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...displayItems,
                if (remainingCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 2),
                    child: Text(
                      '+$remainingCount',
                      style: const TextStyle(
                        fontFamily: 'LINE Seed JP App_TTF',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF999999),
                        letterSpacing: 0,
                        height: 1.1,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// ⭐️ 애플 스타일 Hero 애니메이션을 위한 커스텀 RectTween
// ─────────────────────────────────────────────────────────────────────────

/// 애플 네이티브 스타일의 부드러운 Hero 애니메이션을 구현하는 커스텀 RectTween
///
/// 작동 원리:
/// 1. begin (시작 위치/크기)과 end (종료 위치/크기)를 받는다
/// 2. lerp() 메서드가 t (0.0 ~ 1.0) 값을 받아서 중간 위치/크기를 계산한다
/// 3. MotionConfig.todayButtonHeroCurve를 적용해서 애플 스타일 가속도를 구현한다
///
/// 사용 예시:
/// - t = 0.0: begin 위치/크기 (오늘 날짜 셀, 22×22px)
/// - t = 0.5: 중간 위치/크기 (애니메이션 진행 중)
/// - t = 1.0: end 위치/크기 (앱바 버튼, 36×36px)
class AppleStyleRectTween extends RectTween {
  AppleStyleRectTween({
    required super.begin, // 시작 위치와 크기
    required super.end, // 종료 위치와 크기
  });

  @override
  Rect lerp(double t) {
    // 1. 애플 스타일 커브를 적용한다
    // - 원본 t 값 (0.0 ~ 1.0)을 애플 커브에 통과시켜서 자연스러운 가속도를 만든다
    // - cubic-bezier(0.25, 0.1, 0.25, 1.0): 부드러운 가속 + 정확한 안착
    final curvedT = MotionConfig.todayButtonHeroCurve.transform(t);

    // 2. 커브가 적용된 t 값으로 위치와 크기를 보간(interpolate)한다
    // - begin과 end 사이의 중간값을 계산한다
    // - curvedT가 0.0이면 begin, 1.0이면 end, 0.5면 중간값을 반환한다
    // - Rect.lerp()는 Flutter의 기본 보간 메서드로 x, y, width, height를 모두 계산한다
    return Rect.lerp(begin, end, curvedT)!;
  }
}

/// Hero 애니메이션 중 비행하는 위젯을 커스터마이징하는 빌더 함수
///
/// 파라미터 설명:
/// - flightContext: 애니메이션 중인 오버레이의 BuildContext
/// - animation: 0.0 (시작) → 1.0 (종료)로 진행되는 애니메이션 객체
/// - flightDirection: HeroFlightDirection.push (나타남) 또는 .pop (사라짐)
/// - fromHeroContext: 시작 위치의 Hero 위젯 컨텍스트 (캘린더 셀)
/// - toHeroContext: 종료 위치의 Hero 위젯 컨텍스트 (앱바 버튼)
///
/// 반환값: 애니메이션 중 표시할 위젯
Widget appleStyleHeroFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  // 1. 애니메이션 방향에 따라 올바른 Hero 위젯을 선택한다
  // - push (다른 월로 이동): fromHeroContext 사용 (캘린더 셀에서 시작)
  // - pop (오늘 월로 복귀): toHeroContext 사용 (앱바 버튼에서 시작)
  final Hero toHero = toHeroContext.widget as Hero;

  // 2. 애니메이션 중 표시할 위젯을 반환한다
  // - toHero.child를 그대로 사용해서 목적지 위젯의 스타일을 유지한다
  // - Flutter의 Hero 시스템이 자동으로 위치와 크기를 애니메이션한다
  return toHero.child;
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

extension KeyboardAttachableQuickAdd on _HomeScreenState {
  /// 🆕 KeyboardAttachable 방식으로 QuickAdd 표시
  ///
  /// 기존 방식:
  /// ```dart
  /// showModalBottomSheet(
  ///   context: context,
  ///   builder: (context) => CreateEntryBottomSheet(selectedDate: targetDate),
  /// );
  /// ```
  ///
  /// 신규 방식 (병행 테스트):
  /// 🔥 월뷰에서 + 버튼 클릭 → QuickAdd 표시
  void _showKeyboardAttachableQuickAdd() {
    final targetDate = selectedDay ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ 전체화면
      backgroundColor: Colors.transparent, // ✅ 투명 배경
      barrierColor: Colors.transparent, // ✅ 배리어도 투명! (뒤에 배경 안보이게)
      elevation: 0, // ✅ 그림자 제거
      useSafeArea: false, // ✅ SafeArea 사용 안함
      builder: (context) => CreateEntryBottomSheet(selectedDate: targetDate),
    );

    print('➕ [월뷰 +버튼] QuickAdd 표시 → 날짜: $targetDate');
  }

  // ========================================
  // 🚀 혁신적 구조: OpenContainer openBuilder 배경용 월뷰
  // ========================================
  /// Pull-to-dismiss 시 뒤에 보일 월뷰 전체를 반환한다
  /// OpenContainer의 openBuilder에서 Stack 배경으로 사용
  Widget _buildMonthViewBackground() {
    return StreamBuilder<List<ScheduleData>>(
      stream: GetIt.I<AppDatabase>().watchSchedules(),
      builder: (context, snapshot) {
        final schedules = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          extendBody: true, // ✅ body가 bottomNavigationBar 아래까지 확장
          bottomNavigationBar: CustomBottomNavigationBar(
            onInboxTap: () {},
            onImageAddTap: () {},
            onAddTap: () {},
          ),
          body: SafeArea(
            bottom: false, // ✅ 하단 SafeArea 무시 → 캘린더가 네비 바 아래까지 확장
            child: Column(
              children: [
                _buildCustomHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24), // ✅ 하단 24px 패딩
                    child: TableCalendar(
                      locale: 'ko_KR',
                      firstDay: DateTime.utc(1800, 1, 1),
                      lastDay: DateTime.utc(3000, 12, 30),
                      focusedDay: focusedDay,
                      shouldFillViewport: true,
                      headerVisible: false,
                      daysOfWeekStyle: DaysOfWeekStyle(
                        dowTextFormatter: (date, locale) {
                          const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
                          return weekdays[date.weekday - 1];
                        },
                        weekdayStyle: const TextStyle(
                          fontFamily: 'LINE Seed JP App_TTF',
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF454545),
                          letterSpacing: -0.045,
                          height: 0.9,
                        ),
                        weekendStyle: const TextStyle(
                          fontFamily: 'LINE Seed JP App_TTF',
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF454545),
                          letterSpacing: -0.045,
                          height: 0.9,
                        ),
                      ),
                      calendarStyle: _buildCalendarStyle(),
                      onDaySelected: (_, __) {}, // 배경이므로 상호작용 없음
                      onPageChanged: (_) {}, // 배경이므로 상호작용 없음
                      selectedDayPredicate: _selectedDayPredicate,
                      calendarBuilders: CalendarBuilders(
                        // 배경 월뷰는 OpenContainer 없이 단순 표시만
                        defaultBuilder: (context, day, focusedDay) {
                          return _buildSimpleDayCell(day, schedules);
                        },
                        todayBuilder: (context, day, focusedDay) {
                          return _buildSimpleDayCell(
                            day,
                            schedules,
                            isToday: true,
                          );
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          return _buildSimpleDayCell(
                            day,
                            schedules,
                            isSelected: true,
                          );
                        },
                        outsideBuilder: (context, day, focusedDay) {
                          return _buildSimpleDayCell(
                            day,
                            schedules,
                            isOutside: true,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 배경 월뷰용 단순 날짜 셀 (OpenContainer 없음)
  Widget _buildSimpleDayCell(
    DateTime day,
    List<ScheduleData> allSchedules, {
    bool isToday = false,
    bool isSelected = false,
    bool isOutside = false,
  }) {
    // ScheduleData의 start (DateTime)를 사용하여 해당 날짜의 일정 필터링
    final schedulesForDay = allSchedules.where((s) {
      final scheduleDate = s.start;
      return scheduleDate.year == day.year &&
          scheduleDate.month == day.month &&
          scheduleDate.day == day.day;
    }).toList();

    // 배경색 결정
    Color backgroundColor;
    Color textColor;
    double size = 16;

    if (isToday) {
      backgroundColor = const Color(0xFF000000);
      textColor = const Color(0xFFF7F7F7);
      size = 18;
    } else if (isSelected) {
      backgroundColor = const Color(0xFFE0E0E0);
      textColor = const Color(0xFF000000);
    } else {
      backgroundColor = Colors.transparent;
      textColor = isOutside ? const Color(0xFFB0B0B0) : const Color(0xFF000000);
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(isToday ? 9 : 8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontSize: 10,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.05,
                  height: 0.9,
                ),
              ),
            ),
          ),
          _buildSchedulePreview(schedulesForDay, []), // 배경 월뷰는 할 일 표시 안 함
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 🆕 Inbox 모드 전환 핸들러
  // ════════════════════════════════════════════════════════════════════════════

  /// Inbox 모드 진입 핸들러
  /// 이거를 설정하고 → Inbox 모드로 전환해서
  /// 이거를 해서 → UI를 업데이트하고 애니메이션을 시작하고
  /// 이거는 이래서 → 사용자에게 seamless한 경험을 제공한다

  // ════════════════════════════════════════════════════════════════════════════
  // 🔥 반복 일정 처리 (RRULE 인스턴스 생성)
  // ════════════════════════════════════════════════════════════════════════════

  /// 일정 리스트를 캘린더용 Map으로 변환 (반복 일정 인스턴스 생성)
  /// 🔥 디테일뷰와 동일한 로직 사용!
  Future<Map<DateTime, List<ScheduleData>>> _processSchedulesForCalendarAsync(
    List<ScheduleData> scheduleList,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) async {
    final schedules = <DateTime, List<ScheduleData>>{};
    final db = GetIt.I<AppDatabase>();

    // 🔥 범위 내 모든 날짜 순회
    DateTime currentDate = DateTime(
      rangeStart.year,
      rangeStart.month,
      rangeStart.day,
    );
    final endDate = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final targetDate = currentDate;

      print('📅 [월뷰] 날짜 처리 중: ${targetDate.toString().split(' ')[0]}');

      // 이 날짜에 표시될 일정 찾기
      for (final schedule in scheduleList) {
        // 🚫 완료된 일정은 월뷰에 표시하지 않음
        if (schedule.completed) {
          continue;
        }

        // 1. 반복 패턴 조회
        final pattern = await db.getRecurringPattern(
          entityType: 'schedule',
          entityId: schedule.id,
        );

        if (pattern == null) {
          // 일반 일정: 날짜만 비교 (시간 제거)
          final scheduleStartDate = DateTime(
            schedule.start.year,
            schedule.start.month,
            schedule.start.day,
          );
          final scheduleEndDate = DateTime(
            schedule.end.year,
            schedule.end.month,
            schedule.end.day,
          );

          // 일정의 날짜 범위에 targetDate가 포함되는지 체크
          if (!scheduleEndDate.isBefore(targetDate) &&
              !scheduleStartDate.isAfter(targetDate)) {
            final dateKey = DateTime(
              targetDate.year,
              targetDate.month,
              targetDate.day,
            );
            schedules.putIfAbsent(dateKey, () => []).add(schedule);
            print(
              '  ✅ [일반] "${schedule.summary}" → ${dateKey.toString().split(' ')[0]}',
            );
          }
        } else {
          // 반복 일정: RRULE로 인스턴스 생성 (디테일뷰와 동일)
          try {
            final instances = await _generateScheduleInstancesForDate(
              db: db,
              schedule: schedule,
              pattern: pattern,
              targetDate: targetDate,
            );

            if (instances.isNotEmpty) {
              final dateKey = DateTime(
                targetDate.year,
                targetDate.month,
                targetDate.day,
              );
              schedules.putIfAbsent(dateKey, () => []).add(schedule);
              print(
                '  ✅ [반복] "${schedule.summary}" → ${dateKey.toString().split(' ')[0]}',
              );
            }
          } catch (e) {
            print('  ⚠️ [반복] "${schedule.summary}" - RRULE 파싱 실패: $e');
            // 실패 시 원본 날짜 기준으로 폴백 (날짜만 비교)
            final scheduleStartDate = DateTime(
              schedule.start.year,
              schedule.start.month,
              schedule.start.day,
            );
            final scheduleEndDate = DateTime(
              schedule.end.year,
              schedule.end.month,
              schedule.end.day,
            );

            if (!scheduleEndDate.isBefore(targetDate) &&
                !scheduleStartDate.isAfter(targetDate)) {
              final dateKey = DateTime(
                targetDate.year,
                targetDate.month,
                targetDate.day,
              );
              schedules.putIfAbsent(dateKey, () => []).add(schedule);
            }
          }
        }
      }

      // 다음 날짜로
      currentDate = currentDate.add(const Duration(days: 1));
    }

    print('📊 [HomeScreen] 날짜별 일정 그룹화 완료: ${schedules.length}개 날짜');
    return schedules;
  }

  /// RRULE 인스턴스 생성 헬퍼 (디테일뷰 로직 복사)
  Future<List<DateTime>> _generateScheduleInstancesForDate({
    required AppDatabase db,
    required ScheduleData schedule,
    required RecurringPatternData pattern,
    required DateTime targetDate,
  }) async {
    print(
      '🔍 [인스턴스 체크] "${schedule.summary}" for ${targetDate.toString().split(' ')[0]}',
    );
    print('   RRULE: ${pattern.rrule}');
    print('   DTSTART: ${pattern.dtstart}');

    // RRULE 인스턴스 생성 (targetDate 당일만 - 시작과 끝을 같은 날로)
    final dayStart = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    final dayEnd = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      23,
      59,
      59,
    );

    final instances = RRuleUtils.generateInstances(
      rruleString: pattern.rrule,
      dtstart: pattern.dtstart,
      rangeStart: dayStart,
      rangeEnd: dayEnd,
    );

    print('   생성된 인스턴스: ${instances.length}개');

    // 🔥 CRITICAL: targetDate와 정확히 같은 날짜만 필터링
    final filteredInstances = instances.where((inst) {
      final instDate = DateTime(inst.year, inst.month, inst.day);
      final targetDateOnly = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );
      return instDate.isAtSameMomentAs(targetDateOnly);
    }).toList();

    print('   필터링 후: ${filteredInstances.length}개');
    for (final inst in filteredInstances) {
      print('     ✓ ${inst.toString().split(' ')[0]}');
    }

    // 예외 처리 (취소된 인스턴스 제외)
    final exceptions = await db.getRecurringExceptions(pattern.id);
    final cancelledDates = exceptions
        .where((e) => e.isCancelled)
        .map(
          (e) => DateTime(
            e.originalDate.year,
            e.originalDate.month,
            e.originalDate.day,
          ),
        )
        .toSet();

    final finalFiltered = filteredInstances.where((date) {
      final normalized = DateTime(date.year, date.month, date.day);
      return !cancelledDates.contains(normalized);
    }).toList();

    print('   예외 제외 후: ${finalFiltered.length}개');
    return finalFiltered;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 🔥 할 일 처리 (RRULE 인스턴스 생성)
  // ════════════════════════════════════════════════════════════════════════════

  /// 할 일 리스트를 캘린더용 Map으로 변환 (반복 할 일 인스턴스 생성)
  /// 일정 처리와 동일한 로직 사용!
  Future<Map<DateTime, List<TaskData>>> _processTasksForCalendarAsync(
    List<TaskData> taskList,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) async {
    final tasks = <DateTime, List<TaskData>>{};
    final db = GetIt.I<AppDatabase>();

    // 🔥 범위 내 모든 날짜 순회
    DateTime currentDate = DateTime(
      rangeStart.year,
      rangeStart.month,
      rangeStart.day,
    );
    final endDate = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final targetDate = currentDate;

      // 이 날짜에 표시될 할 일 찾기
      for (final task in taskList) {
        // executionDate가 null이면 Inbox 전용으로 월뷰에 표시 안 함
        if (task.executionDate == null) {
          continue;
        }

        // 🚫 완료된 할일은 월뷰에 표시하지 않음
        if (task.completed) {
          continue;
        }

        // 1. 반복 패턴 조회
        final pattern = await db.getRecurringPattern(
          entityType: 'task',
          entityId: task.id,
        );

        if (pattern == null) {
          // 일반 할 일: executionDate 기준
          final taskDate = DateTime(
            task.executionDate!.year,
            task.executionDate!.month,
            task.executionDate!.day,
          );

          if (taskDate.isAtSameMomentAs(targetDate)) {
            final dateKey = DateTime(
              targetDate.year,
              targetDate.month,
              targetDate.day,
            );
            tasks.putIfAbsent(dateKey, () => []).add(task);
          }
        } else {
          // 반복 할 일: RRULE로 인스턴스 생성
          try {
            final instances = await _generateTaskInstancesForDate(
              db: db,
              task: task,
              pattern: pattern,
              targetDate: targetDate,
            );

            if (instances.isNotEmpty) {
              final dateKey = DateTime(
                targetDate.year,
                targetDate.month,
                targetDate.day,
              );
              tasks.putIfAbsent(dateKey, () => []).add(task);
            }
          } catch (e) {
            // 실패 시 원본 executionDate 기준으로 폴백
            final taskDate = DateTime(
              task.executionDate!.year,
              task.executionDate!.month,
              task.executionDate!.day,
            );

            if (taskDate.isAtSameMomentAs(targetDate)) {
              final dateKey = DateTime(
                targetDate.year,
                targetDate.month,
                targetDate.day,
              );
              tasks.putIfAbsent(dateKey, () => []).add(task);
            }
          }
        }
      }

      // 다음 날짜로
      currentDate = currentDate.add(const Duration(days: 1));
    }

    print('📊 [HomeScreen] 날짜별 할 일 그룹화 완료: ${tasks.length}개 날짜');
    return tasks;
  }

  /// RRULE 인스턴스 생성 헬퍼 (할 일용)
  Future<List<DateTime>> _generateTaskInstancesForDate({
    required AppDatabase db,
    required TaskData task,
    required RecurringPatternData pattern,
    required DateTime targetDate,
  }) async {
    // RRULE 인스턴스 생성
    final dayStart = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    final dayEnd = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      23,
      59,
      59,
    );

    final instances = RRuleUtils.generateInstances(
      rruleString: pattern.rrule,
      dtstart: pattern.dtstart,
      rangeStart: dayStart,
      rangeEnd: dayEnd,
    );

    // 🔥 CRITICAL: targetDate와 정확히 같은 날짜만 필터링
    final filteredInstances = instances.where((inst) {
      final instDate = DateTime(inst.year, inst.month, inst.day);
      final targetDateOnly = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );
      return instDate.isAtSameMomentAs(targetDateOnly);
    }).toList();

    // 예외 처리 (취소된 인스턴스 제외)
    final exceptions = await db.getRecurringExceptions(pattern.id);
    final cancelledDates = exceptions
        .where((e) => e.isCancelled)
        .map(
          (e) => DateTime(
            e.originalDate.year,
            e.originalDate.month,
            e.originalDate.day,
          ),
        )
        .toSet();

    final finalFiltered = filteredInstances.where((date) {
      final normalized = DateTime(date.year, date.month, date.day);
      return !cancelledDates.contains(normalized);
    }).toList();

    return finalFiltered;
  }

  // 월-연도 피커 표시
  void _showMonthYearPicker() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _MonthYearPickerModal(
            initialDate: focusedDay,
            onDateChanged: (newDate) {
              setState(() {
                focusedDay = newDate;
              });
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final offsetAnimation = tween.animate(curvedAnimation);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

// 월-연도 피커 모달 (연도-월만 선택)
class _MonthYearPickerModal extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateChanged;

  const _MonthYearPickerModal({
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<_MonthYearPickerModal> createState() => _MonthYearPickerModalState();
}

class _MonthYearPickerModalState extends State<_MonthYearPickerModal> {
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;

  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;

    // 1900년부터 2100년까지
    final yearIndex = _selectedYear - 1900;

    _yearController = FixedExtentScrollController(initialItem: yearIndex);
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  void _updateDate() {
    final newDate = DateTime(_selectedYear, _selectedMonth, 1);
    widget.onDateChanged(newDate);
  }

  String _formatDateHeader() {
    return '$_selectedMonth月 $_selectedYear';
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              Container(
                color: const Color(0xFF3B3B3B),
                padding: EdgeInsets.only(top: statusBarHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 헤더
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDateHeader(),
                            style: const TextStyle(
                              fontFamily: 'LINE Seed JP App_TTF',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.41,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Transform.rotate(
                            angle: 3.14159,
                            child: SvgPicture.asset(
                              'asset/icon/down_icon.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 피커
                    SizedBox(
                      height: 200,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 80),
                        child: Row(
                          children: [
                            // 연도
                            Expanded(
                              flex: 3,
                              child: ListWheelScrollView.useDelegate(
                                controller: _yearController,
                                itemExtent: 24,
                                physics: const FixedExtentScrollPhysics(),
                                diameterRatio: 1.1,
                                perspective: 0.004,
                                squeeze: 1.0,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    _selectedYear = 1900 + index;
                                    _updateDate();
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    final year = 1900 + index;
                                    final isSelected = year == _selectedYear;
                                    return Center(
                                      child: Text(
                                        '$year年',
                                        style: TextStyle(
                                          fontFamily: 'LINE Seed JP App_TTF',
                                          fontSize: 18,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          letterSpacing: -0.41,
                                          decoration: TextDecoration.none,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: 201,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // 월
                            Expanded(
                              flex: 2,
                              child: ListWheelScrollView.useDelegate(
                                controller: _monthController,
                                itemExtent: 24,
                                physics: const FixedExtentScrollPhysics(),
                                diameterRatio: 1.1,
                                perspective: 0.004,
                                squeeze: 1.0,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    _selectedMonth = index + 1;
                                    _updateDate();
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    final month = index + 1;
                                    final isSelected = month == _selectedMonth;
                                    return Center(
                                      child: Text(
                                        '$month月',
                                        style: TextStyle(
                                          fontFamily: 'LINE Seed JP App_TTF',
                                          fontSize: 18,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          letterSpacing: -0.41,
                                          decoration: TextDecoration.none,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
