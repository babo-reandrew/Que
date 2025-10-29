/// 📅 DateDetailView 날짜 헤더 위젯
///
/// Figma 디자인: Frame 830, Frame 893
/// 8月 金曜日 / 11 今日 형태의 날짜 표시 + 설정 버튼
///
/// 이거를 설정하고 → 선택된 날짜를 월/요일/날짜로 분리해서
/// 이거를 해서 → Figma 디자인대로 레이아웃을 구성한다
/// 이거는 이래서 → 사용자가 현재 보고 있는 날짜를 명확히 인식한다
library;

import 'dart:ui' show ImageFilter;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:animations/animations.dart'; // ✅ OpenContainer (월뷰→디테일뷰와 동일)
import '../design_system/wolt_design_tokens.dart';
import '../design_system/wolt_typography.dart';
import '../Database/schedule_database.dart';
import '../features/insight_player/screens/insight_player_screen.dart'; // 🎵 Insight Player
import '../screen/date_detail_view.dart'; // ✅ DateDetailView for background
import '../const/motion_config.dart'; // 🍎 애플 스타일 모션 설정

class DateDetailHeader extends StatefulWidget {
  final DateTime selectedDate; // 선택된 날짜
  final VoidCallback? onSettingsTap; // 설정 버튼 탭 콜백
  final Function(DateTime)? onDateChanged; // 날짜 변경 콜백

  const DateDetailHeader({
    super.key,
    required this.selectedDate,
    this.onSettingsTap,
    this.onDateChanged,
  });

  @override
  State<DateDetailHeader> createState() => _DateDetailHeaderState();
}

class _DateDetailHeaderState extends State<DateDetailHeader> {
  bool _hasInsightData = false;

  @override
  void initState() {
    super.initState();
    _checkInsightData();
  }

  @override
  void didUpdateWidget(DateDetailHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _checkInsightData();
    }
  }

  /// 해당 날짜에 Insight 데이터가 있는지 확인
  Future<void> _checkInsightData() async {
    final insight = await GetIt.I<AppDatabase>().getInsightForDate(
      widget.selectedDate,
    );
    if (mounted) {
      setState(() {
        _hasInsightData = insight != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이거를 설정하고 → 오늘 날짜와 비교해서 상대 날짜 텍스트 결정
    final relativeDateText = _getRelativeDateText(widget.selectedDate);

    // 이거를 해서 → 월, 요일, 날짜를 일본어로 포맷팅한다
    final monthText = _formatMonth(widget.selectedDate); // "8月"
    final dayOfWeekText = _formatDayOfWeek(widget.selectedDate); // "金曜日"
    final dayNumber = widget.selectedDate.day.toString(); // "11"

    return Container(
      // 이거를 설정하고 → Figma Frame 893의 크기를 그대로 적용
      width: 393, // ✅ Full width (iPhone 16)
      height: 80,
      padding: const EdgeInsets.only(left: 12), // 왼쪽 12px
      clipBehavior: Clip.none, // ✅ 패딩 영역 밖으로 나가도 안 잘림 (그림자/회색원 보이게)
      child: Stack(
        clipBehavior: Clip.none, // ✅ Stack도 클립 해제 (그림자 완전히 보이게)
        children: [
          // ===================================================================
          // 왼쪽 영역: Frame 830 (월/요일 + 날짜/뱃지)
          // ===================================================================
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => _showDatePicker(context),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------
                  // Frame 823: 월 + 요일 (가로 배치)
                  // -----------------------------------------------
                  Row(
                    children: [
                      // 이거를 설정하고 → 월 표시를 빨강(#FF4444)으로 강조
                      Text(monthText, style: WoltTypography.monthText),
                      const SizedBox(width: 6), // gap: 6px
                      // 이거를 해서 → 요일 표시를 회색(#999999)으로 구분
                      Text(dayOfWeekText, style: WoltTypography.dayOfWeekText),
                    ],
                  ),

                  const SizedBox(height: 4), // Frame 830 내부 gap
                  // -----------------------------------------------
                  // Frame 829: 날짜 숫자 + 뱃지 (가로 배치)
                  // -----------------------------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이거를 설정하고 → 큰 숫자(48px)로 날짜를 표시
                      // 📋 Hero 애니메이션으로 월 뷰 셀과 연동
                      Hero(
                        tag:
                            'date-cell-hero-${widget.selectedDate.year}-${widget.selectedDate.month}-${widget.selectedDate.day}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            dayNumber,
                            style: WoltTypography.dateNumberLarge,
                          ),
                        ),
                      ),

                      const SizedBox(width: 4), // gap: 4px (좌측 큰 글씨로부터)
                      // -----------------------------------------------
                      // Frame 827: 상대 날짜 텍스트 + 아이콘 (세로 배치)
                      // -----------------------------------------------
                      Padding(
                        padding: const EdgeInsets.only(top: 6), // 상단으로부터 6px
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 상대 날짜 텍스트 (今日, 明日, あと5日 등)
                            Text(
                              relativeDateText,
                              style: const TextStyle(
                                fontFamily: 'LINE Seed JP App_TTF',
                                fontSize: 12, // 12px
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                letterSpacing: -0.005 * 12,
                                color: Color(0xFF222222), // #222222
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ), // gap: 10px (아이콘 하단으로부터)
                            // 아이콘 (Frame 824) - down_icon.svg
                            _buildDownIcon(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ===================================================================
          // 오른쪽 영역: Frame 892 (인사이트 버튼)
          // ===================================================================
          Positioned(
            right: 8, // ✅ 좌측으로 12px 이동 (-4 + 12 = 8)
            top: 19.5, // ✅ 날짜 숫자와 수직 중앙선 일치 (70px 버튼 기준: 54.5 - 35)
            child: _buildSettingsButton(),
          ),
        ],
      ),
    );
  }

  // ========================================
  // 헬퍼 함수들
  // ========================================

  /// 날짜 피커 모달 표시 (상단 드롭다운)
  void _showDatePicker(BuildContext context) {
    if (widget.onDateChanged == null) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent, // 투명 배경
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _DatePickerModal(
            initialDate: widget.selectedDate,
            onDateChanged: (date) {
              widget.onDateChanged!(date);
            },
          );
        },
        transitionDuration: const Duration(milliseconds: 500), // Apple 스타일
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Apple spring 애니메이션
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1), // 위에서 내려옴
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  /// 상대 날짜 텍스트를 반환하는 함수
  /// - 오늘: 今日
  /// - 내일: 明日
  /// - 어제: 昨日
  /// - 5일 후: あと5日
  /// - 5일 전: 5日前
  String _getRelativeDateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return '今日'; // 오늘
    } else if (difference == 1) {
      return '明日'; // 내일
    } else if (difference == -1) {
      return '昨日'; // 어제
    } else if (difference > 1) {
      return 'あと$difference日'; // 5일 후 등
    } else {
      return '${difference.abs()}日前'; // 5일 전 등
    }
  }

  /// 이거를 해서 → 월을 일본어로 포맷팅 (8月)
  String _formatMonth(DateTime date) {
    return '${date.month}月';
  }

  /// 이거를 해서 → 요일을 일본어로 포맷팅 (金曜日)
  String _formatDayOfWeek(DateTime date) {
    final formatter = DateFormat('EEEE', 'ja_JP'); // 일본어 요일
    return formatter.format(date);
  }

  /// "down_icon.svg" 아이콘 빌더 (Figma: icon 16x16)
  Widget _buildDownIcon() {
    return SvgPicture.asset(
      'asset/icon/down_icon.svg',
      width: 16,
      height: 16,
      colorFilter: const ColorFilter.mode(
        Color(0xFF222222), // #222222
        BlendMode.srcIn,
      ),
    );
  }

  /// 설정 버튼 빌더 (Figma: Frame 892, Frame 671)
  /// 🎵 Insight 데이터가 있을 때는 -40도 회전된 특별한 아이콘 표시
  /// ✅ OpenContainer로 fade-through 전환 효과 적용
  Widget _buildSettingsButton() {
    // Insight 데이터가 없으면 기본 설정 버튼 (비활성화 - 아무 반응 없음)
    // onSettingsTap 콜백이 있어도 인사이트가 없으면 아무 반응 없음
    if (!_hasInsightData) {
      return Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(12),
        decoration: WoltDesignTokens.decorationSettingsButton,
        child: SvgPicture.asset(
          'asset/icon/none_Insight.svg',
          width: 26,
          height: 26,
          colorFilter: const ColorFilter.mode(
            Color(0xFFE0E0E0),
            BlendMode.srcIn,
          ),
        ),
      );
    }

    // onSettingsTap 콜백이 제공된 경우, 단순 버튼으로 처리
    if (widget.onSettingsTap != null) {
      // Insight 데이터가 있을 때의 버튼 (콜백 버전)
      return GestureDetector(
        onTap: widget.onSettingsTap,
        child: _buildInsightButtonContent(),
      );
    }

    // 🎵 Insight 데이터가 있을 때: OpenContainer로 전환
    // 🍎 월뷰→디테일뷰와 완전히 동일한 애니메이션! (animations 패키지만 사용)
    return OpenContainer(
      // ========== 닫힌 상태 (버튼) ==========
      closedColor: Colors.transparent, // 투명 배경
      closedElevation: MotionConfig.openContainerClosedElevation, // 0.0
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // 버튼의 원래 shape 유지
      ),
      closedBuilder: (context, action) => _buildInsightButtonContent(),

      // ========== 열린 상태 (전체 화면) ==========
      openColor: Colors.transparent, // ✅ 투명! (InsightPlayerScreen이 직접 배경색 관리)
      openElevation: MotionConfig.openContainerOpenElevation, // 0.0
      openShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(36),
        ), // Figma 60% smoothing
      ),
      openBuilder: (context, action) => Stack(
        children: [
          // 1️⃣ 배경: 디테일뷰 전체 (고정) - 월뷰→디테일뷰와 동일한 패턴!
          // Pull-to-dismiss 시 InsightPlayerScreen이 투명해지면서 보이는 배경
          Positioned.fill(
            child: IgnorePointer(
              child: DateDetailView(
                selectedDate: widget.selectedDate,
                // onClose는 제공하지 않음 (배경이므로 interaction 없음)
                onClose: null,
              ),
            ),
          ),

          // 2️⃣ 전면: InsightPlayerScreen (pull-to-dismiss 가능)
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent, // ✅ Material 기본 배경 투명
              scaffoldBackgroundColor:
                  Colors.transparent, // ✅ Scaffold 기본 배경 투명
            ),
            child: InsightPlayerScreen(
              targetDate: widget.selectedDate,
              onClose: action, // ✅ Pull-to-dismiss 완료 시 OpenContainer 닫기
            ),
          ),
        ],
      ),

      // ========== 애니메이션 설정 (월뷰→디테일뷰와 동일!) ==========
      transitionDuration: MotionConfig.openContainerDuration, // 520ms
      transitionType:
          ContainerTransitionType.fade, // ✅ fade: 월→디테일뷰와 동일 (더 부드러움)
      // ✅ middleColor는 fade 타입에서는 사용 안 됨 (fadeThrough만 사용)
      // middleColor: const Color(0xFFF7F7F7),

      // 🎨 OpenContainer는 자체 커브 사용
      // MotionConfig.openContainerCurve: Cubic(0.05, 0.7, 0.1, 1.0)
      // OpenContainer 내부에서 자동 적용됨
    );
  }

  /// Insight 버튼 컨텐츠 추출 (재사용을 위해)
  /// ✅ 70px × 70px (54px + 8px padding * 2), -4도 회전, 회색 원(아래) + 버튼(위) 스택 구조
  Widget _buildInsightButtonContent() {
    return Container(
      width: 70, // ✅ 54px + 16px (padding 8px * 2)
      height: 70, // ✅ 54px + 16px (padding 8px * 2)
      padding: const EdgeInsets.all(8), // ✅ 상하좌우 8px 패딩 (4px 증가)
      clipBehavior: Clip.none, // ✅ Container도 클립 해제 (그림자 안 잘리게)
      child: Stack(
        clipBehavior: Clip.none, // ✅ 회색 원이 밖으로 나갈 수 있도록
        children: [
          // 🔘 회색 원 (하단 레이어) - 좌측 4px, 아래 4px 오프셋
          Positioned(
            left: 4, // ✅ 버튼 대비 좌측으로 4px
            top: 4, // ✅ 버튼 대비 아래로 4px
            child: Transform.rotate(
              angle: -4 * math.pi / 180, // ✅ -4도 회전
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🎵 인사이트 버튼 (상단 레이어)
          Positioned(
            left: 0,
            top: 0,
            child: Transform.rotate(
              angle: -4 * math.pi / 180, // ✅ -4도 회전 (상단 우 → 하단 좌)
              child: Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF566099), // Insight 보라색
                  border: Border.all(
                    color: const Color(0x1A111111), // rgba(17, 17, 17, 0.1)
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF566099).withOpacity(0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: 4 * math.pi / 180, // ✅ 아이콘은 다시 0도로 (4도 상쇄)
                  child: SvgPicture.asset(
                    'asset/icon/none_Insight.svg',
                    width: 30, // ✅ 54 - 12*2 = 30px
                    height: 30,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFFAF8F7),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// 날짜 피커 모달 위젯
// ========================================

class _DatePickerModal extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateChanged;

  const _DatePickerModal({
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<_DatePickerModal> createState() => _DatePickerModalState();
}

class _DatePickerModalState extends State<_DatePickerModal> {
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;

    // 1900년부터 2100년까지
    final yearIndex = _selectedYear - 1900;

    // 현재 월의 일수를 확인하고 day가 범위를 벗어나면 조정
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    if (_selectedDay > daysInMonth) {
      _selectedDay = daysInMonth;
    }

    _yearController = FixedExtentScrollController(initialItem: yearIndex);
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _updateDate() {
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    if (_selectedDay > daysInMonth) {
      _selectedDay = daysInMonth;
      _dayController.jumpToItem(_selectedDay - 1);
    }

    final newDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    widget.onDateChanged(newDate);
  }

  String _formatDateHeader() {
    final date = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    final month = date.month;
    final day = date.day;
    final weekday = ['월', '화', '수', '목', '금', '토', '일'][date.weekday % 7];
    return '$month. $day. $weekday';
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top; // 상태바 높이

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 상단 드롭다운 피커
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: statusBarHeight,
                ), // 상태바 높이만큼 padding
                height: 280 + statusBarHeight, // 전체 높이 = 피커 높이 + 상태바
                decoration: const BoxDecoration(
                  color: Color(0xFF3B3B3B), // 단색 #3B3B3B
                  // 라운드 제거
                ),
                child: Column(
                  children: [
                    // 상단 날짜 헤더 (월. 일. 요일)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 52, // 52px로 변경
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag:
                                  'date-picker-header-${widget.initialDate.year}-${widget.initialDate.month}-${widget.initialDate.day}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  _formatDateHeader(),
                                  style: const TextStyle(
                                    fontFamily: 'LINE Seed JP App_TTF',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.41,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Transform.rotate(
                              angle: 3.14159, // 180도 회전 (up 아이콘)
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
                    ),

                    // 피커
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                        ), // 좌우 여백 80px
                        child: Row(
                          children: [
                            // 년
                            Expanded(
                              flex: 3, // 연도 더 넓게
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

                            const SizedBox(width: 8), // 연-월 간격 좁게
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
                                        '$month월',
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

                            const SizedBox(width: 20), // 월-일 간격
                            // 일
                            Expanded(
                              flex: 2,
                              child: ListWheelScrollView.useDelegate(
                                controller: _dayController,
                                itemExtent: 24,
                                physics: const FixedExtentScrollPhysics(),
                                diameterRatio: 1.1,
                                perspective: 0.004,
                                squeeze: 1.0,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    final daysInMonth = DateTime(
                                      _selectedYear,
                                      _selectedMonth + 1,
                                      0,
                                    ).day;
                                    _selectedDay = (index + 1).clamp(
                                      1,
                                      daysInMonth,
                                    );
                                    _updateDate();
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    final day = index + 1;

                                    final isSelected = day == _selectedDay;
                                    return Center(
                                      child: Text(
                                        '$day일',
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
                                  childCount: DateTime(
                                    _selectedYear,
                                    _selectedMonth + 1,
                                    0,
                                  ).day,
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
            ),
          ],
        ),
      ),
    );
  }
}
