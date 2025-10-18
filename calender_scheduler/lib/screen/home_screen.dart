import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:animations/animations.dart'; // ✅ OpenContainer import
import '../const/color.dart';
import '../const/calendar_config.dart';
import '../const/motion_config.dart';
import '../component/create_entry_bottom_sheet.dart';
import '../component/keyboard_attachable_input_view.dart'; // 🆕 KeyboardAttachable 추가
import '../component/modal/settings_wolt_modal.dart'; // ✅ Settings Modal 추가
import '../screen/date_detail_view.dart';
import '../Database/schedule_database.dart';
import '../widgets/bottom_navigation_bar.dart'; // ✅ 하단 네비게이션 바 추가
import '../widgets/temp_input_box.dart'; // ✅ 임시 입력 박스 추가
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

  @override
  void initState() {
    super.initState();
    // 🚀 키보드 프리로딩: 앱 시작 시 키보드를 미리 초기화해서
    // 사용자가 + 버튼을 눌렀을 때 바로 뜨도록 함 (첫 번째 딜레이 제거)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadKeyboard();
    });
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
    // 이거를 설정하고 → watchSchedules()로 전체 일정을 실시간 스트림으로 가져와서
    // 이거를 해서 → Map<DateTime, List<ScheduleData>>로 변환한 다음
    // 이거는 이래서 → TableCalendar가 해당 날짜별 일정 개수를 표시할 수 있다
    return StreamBuilder<List<ScheduleData>>(
      stream: GetIt.I<AppDatabase>().watchSchedules(),
      builder: (context, snapshot) {
        // 로딩 중이거나 에러 처리
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ [HomeScreen] StreamBuilder 로딩 중...');
        }

        if (snapshot.hasError) {
          print('❌ [HomeScreen] StreamBuilder 에러: ${snapshot.error}');
        }

        // 일정 리스트를 Map<DateTime, List<ScheduleData>>로 변환
        // 이거를 설정하고 → snapshot.data에서 일정 리스트를 가져와서
        // 이거를 해서 → 날짜별로 그룹화된 Map을 생성한다
        final schedules = <DateTime, List<ScheduleData>>{};
        if (snapshot.hasData) {
          print(
            '🔄 [HomeScreen] StreamBuilder 데이터 수신: ${snapshot.data!.length}개 일정',
          );
          for (final schedule in snapshot.data!) {
            // 날짜 키 생성 (시간 정보 제거, 날짜만 사용)
            final dateKey = DateTime(
              schedule.start.year,
              schedule.start.month,
              schedule.start.day,
            );
            schedules.putIfAbsent(dateKey, () => []).add(schedule);
          }
          print('📊 [HomeScreen] 날짜별 일정 그룹화 완료: ${schedules.length}개 날짜');
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F7), // ✅ 월뷰 배경색
          resizeToAvoidBottomInset: false, // ✅ KeyboardAttachable 필수 설정!
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
              // final targetDate = selectedDay ?? DateTime.now();
              // showModalBottomSheet(
              //   context: context,
              //   isScrollControlled: true,
              //   backgroundColor: Colors.transparent,
              //   barrierColor: Colors.transparent,
              //   elevation: 0,
              //   builder: (context) =>
              //       CreateEntryBottomSheet(selectedDate: targetDate),
              // );
              // print('➕ [하단 네비] 더하기 버튼 클릭 → 날짜: $targetDate');
            },
            isStarSelected: false, // TODO: 상태 관리
          ),
          body: Stack(
            children: [
              // 메인 컨텐츠
              SafeArea(
                child: Column(
                  // Column으로 감싸서 세로로 배치
                  children: [
                    // ⭐️ 커스텀 헤더 추가: 햄버거 메뉴 + 날짜 표시
                    _buildCustomHeader(),

                    // TableCalendar를 Expanded로 감싸서 전체 화면을 차지하도록 만든다
                    // 이렇게 하면 네이버 캘린더처럼 캘린더가 화면을 가득 채운다
                    Expanded(
                      child: TableCalendar(
                        // 1. 기본 설정: 언어를 한국어로 설정하고 날짜 범위를 지정한다
                        locale: 'ko_KR', // 한국어로 설정해서 월/요일이 한글로 표시되도록 한다
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
                        focusedDay: focusedDay, // 현재 화면에 보이는 달을 설정한다
                        // 2. 전체 화면 설정: shouldFillViewport를 true로 설정해서 뷰포트를 완전히 채운다
                        shouldFillViewport:
                            true, // 캘린더가 사용 가능한 모든 공간을 채우도록 설정한다
                        // 3. ⭐️ 헤더 숨김: TableCalendar의 기본 헤더를 숨기고 커스텀 헤더를 사용한다
                        headerVisible: false, // TableCalendar의 기본 헤더를 숨긴다
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
                            letterSpacing: -0.045, // -0.005em → -0.045px
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
                        // 6. 날짜 선택 처리: 사용자가 날짜를 클릭하면 선택된 날짜로 이동한다
                        onDaySelected:
                            _onDaySelected, // 날짜를 클릭하면 선택된 날짜로 이동하고 상태를 업데이트한다
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
                        ), // 각 날짜 셀의 모양을 설정해서 기본/선택/오늘/이전달 날짜를 다르게 표시한다
                      ),
                    ),
                    // 하단 ListView는 제거 - 스케줄 표시는 DateDetailView에서 처리한다
                    // 이제 날짜를 클릭하면 바로 DateDetailView로 이동해서 상세 정보를 볼 수 있다ㄱ
                    // 하단 40px 여백 추가 - 이미지 레이아웃과 동일하게 하단에 빈 공간을 만든다
                    SizedBox(
                      height: 40,
                    ), // 화면 최하단에 40픽셀의 여백을 추가해서 캘린더와 화면 끝 사이에 공간을 만든다
                  ],
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
                      isScrollControlled: true, // ✅ 키보드 높이에 따라 동적으로 조절
                      backgroundColor: Colors.transparent, // ✅ 투명 배경
                      barrierColor: Colors.transparent, // ✅ 배경 터치 차단 없음
                      elevation: 0, // ✅ 그림자 제거
                      builder: (context) =>
                          CreateEntryBottomSheet(selectedDate: targetDate),
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
        );
      },
    ); // StreamBuilder 닫기
  }

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
                  child: const Icon(
                    Icons.menu,
                    size: 32, // 피그마: 32×32px
                    color: Color(0xFFCCCCCC), // 피그마: border #CCCCCC
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // ✅ 날짜 표시 영역 (Frame 688)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
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

                  // "2025" (Bold 27px, #CFCFCF)
                  Text(
                    '${focusedDay.year}',
                    style: const TextStyle(
                      fontFamily: 'LINE Seed JP App_TTF',
                      fontSize: 27,
                      fontWeight: FontWeight.w700, // Bold
                      color: Color(0xFFCFCFCF),
                      letterSpacing: -0.135,
                      height: 1.4,
                    ),
                  ),
                ],
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
  // 36×36px, 검은 배경 (#111111), radius 12px, "11" 텍스트 (ExtraBold 12px, 흰색)
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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 36, // 피그마: Frame 123 크기 36×36px
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF111111), // 피그마: 배경색 #111111
              borderRadius: BorderRadius.circular(12), // 피그마: radius 12px
              border: Border.all(
                color: const Color(
                  0xFF000000,
                ).withOpacity(0.04), // 피그마: rgba(0,0,0,0.04)
                width: 1,
              ),
              boxShadow: [
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
        );
      },
      // 이전 달/다음 달 날짜 셀 (회색으로 표시하고 가운데 정렬)
      outsideBuilder: (context, day, focusedDay) {
        return _buildCalendarCell(
          day: day,
          backgroundColor: Colors.transparent, // 투명 배경
          textColor: const Color(0xFF999999), // ✅ Figma: #999999 (회색)
          daySchedules: schedules, // 일정 데이터 전달
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

    // 6. 계산 결과 로그 출력
    print(
      '📐 [높이 계산] 셀 높이: ${cellHeight.toStringAsFixed(1)}px → 사용가능: ${availableHeight.toStringAsFixed(1)}px → 몫: $maxCount → 최대 일정: $finalCount개',
    );

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
  }) {
    // ⭐️ OpenContainer 구조:
    // 1. OpenContainer가 전체를 감싸서 탭 시 자동으로 DateDetailView 열림
    // 2. closedBuilder: 작은 셀 UI (날짜 + 일정 미리보기)
    // 3. openBuilder: 전체 화면 DateDetailView
    // 4. 자동으로 위치/크기 측정, 보간, 배경 scrim 처리

    // 이거를 설정하고 → 해당 날짜의 일정 리스트를 조회해서
    final dateKey = DateTime(day.year, day.month, day.day);
    final schedulesForDay = daySchedules[dateKey] ?? [];

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
            _buildSchedulePreview(schedulesForDay),
          ],
        ),
      );
    }

    // ✅ OpenContainer로 감싸기
    return OpenContainer(
      // ========================================
      // 애니메이션 설정
      // ========================================
      transitionDuration: MotionConfig.openContainerDuration, // 550ms
      transitionType: ContainerTransitionType.fade, // ✅ fade: Stack 구조에 적합
      // ========================================
      // 닫힌 상태 (셀 UI) - #F7F7F7 배경
      // ========================================
      closedElevation: 0, // 그림자 없음
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // ✅ 라운드 0 (직각)
      ),
      closedColor: const Color(0xFFF7F7F7), // ✅ #F7F7F7 배경색
      middleColor: MotionConfig.openContainerMiddleColor, // ✅ fadeThrough 중간 색상
      closedBuilder: (context, action) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 날짜 숫자 (Hero처럼 동기화됨)
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
              // 일정 미리보기
              _buildSchedulePreview(schedulesForDay),
            ],
          ),
        );
      },

      // ========================================
      // 열린 상태 (DateDetailView 전체 화면) - #F7F7F7 배경
      // ========================================
      openElevation: 0, // 그림자 없음
      openShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36), // ✅ 라운드 36 (피그마 60% 스무싱)
      ),
      openColor: const Color(0xFFF7F7F7), // ✅ #F7F7F7 배경색
      openBuilder: (context, action) {
        // 🚀 혁신적 구조: Stack으로 월뷰를 배경에 깔고 디테일뷰를 위에 겹침
        // Pull-to-dismiss 시 디테일뷰가 작아지면서 아래 월뷰가 보이는 효과!
        return Stack(
          children: [
            // 1️⃣ 배경: 월뷰 전체 (고정)
            // OpenContainer가 열렸을 때 뒤에 깔리는 월뷰
            Positioned.fill(child: _buildMonthViewBackground()),

            // 2️⃣ 전면: 디테일뷰 (pull-to-dismiss 가능)
            // onClose 콜백으로 OpenContainer의 action() 연결
            DateDetailView(
              selectedDate: dateKey,
              onClose: action, // ✅ Pull-to-dismiss 완료 시 OpenContainer 닫기
            ),
          ],
        );
      },

      // ========================================
      // 기타 설정
      // ========================================
      useRootNavigator: false,
      clipBehavior: Clip.antiAlias,
    );
  }

  // ========================================
  // 일정 미리보기 위젯 (Expanded 영역)
  // ========================================
  Widget _buildSchedulePreview(List<ScheduleData> schedulesForDay) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellHeight = constraints.maxHeight + 26;
          final maxDisplayCount = _calculateMaxScheduleCount(cellHeight);

          if (schedulesForDay.isEmpty) {
            return const SizedBox.shrink();
          }

          final displaySchedules = schedulesForDay
              .take(maxDisplayCount)
              .toList();
          final remainingCount =
              schedulesForDay.length - displaySchedules.length;

          return Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...displaySchedules.map(
                  (schedule) => _buildScheduleBox(schedule),
                ),
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
    required Rect? begin, // 시작 위치와 크기
    required Rect? end, // 종료 위치와 크기
  }) : super(begin: begin, end: end);

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
  /// ```dart
  /// _showKeyboardAttachableQuickAdd();
  /// ```
  void _showKeyboardAttachableQuickAdd() {
    final targetDate = selectedDay ?? DateTime.now();

    InputAccessoryHelper.showQuickAdd(
      context,
      selectedDate: targetDate,
      onSaveComplete: () {
        print('✅ [KeyboardAttachable] 저장 완료 → StreamBuilder 자동 갱신');
        // StreamBuilder가 자동으로 UI 갱신하므로 추가 로직 불필요
      },
    );

    print('➕ [KeyboardAttachable] 더하기 버튼 클릭 → 날짜: $targetDate');
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
          bottomNavigationBar: CustomBottomNavigationBar(
            onInboxTap: () {},
            onStarTap: () {},
            onAddTap: () {},
            isStarSelected: false,
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildCustomHeader(),
                Expanded(
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
                const SizedBox(height: 40),
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
          _buildSchedulePreview(schedulesForDay),
        ],
      ),
    );
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
//   // final targetDate = selectedDay ?? DateTime.now();
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
