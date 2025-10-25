/// 📅 DateDetailView 날짜 헤더 위젯
///
/// Figma 디자인: Frame 830, Frame 893
/// 8月 金曜日 / 11 今日 형태의 날짜 표시 + 설정 버튼
///
/// 이거를 설정하고 → 선택된 날짜를 월/요일/날짜로 분리해서
/// 이거를 해서 → Figma 디자인대로 레이아웃을 구성한다
/// 이거는 이래서 → 사용자가 현재 보고 있는 날짜를 명확히 인식한다

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

  const DateDetailHeader({
    super.key,
    required this.selectedDate,
    this.onSettingsTap,
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
    // 이거를 설정하고 → 오늘 날짜와 비교해서 "今日" 뱃지 표시 여부 결정
    final isToday = _isToday(widget.selectedDate);

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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 이거를 설정하고 → 큰 숫자(48px)로 날짜를 표시
                    // 📋 Hero 애니메이션으로 앱바로 이동
                    Hero(
                      tag: 'date_number_${widget.selectedDate.day}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          dayNumber,
                          style: WoltTypography.dateNumberLarge,
                        ),
                      ),
                    ),

                    const SizedBox(width: 4), // gap: 4px
                    // -----------------------------------------------
                    // Frame 827: "今日" 뱃지 + 아이콘 (세로 배치)
                    // -----------------------------------------------
                    // 이거를 해서 → 오늘 날짜일 때만 뱃지를 표시한다
                    if (isToday) ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // "今日" 텍스트
                          Text('今日', style: WoltTypography.todayBadge),

                          const SizedBox(height: 12), // gap: 12px
                          // 아이콘 (Frame 824)
                          _buildTodayIcon(),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
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

  /// 이거를 설정하고 → 오늘 날짜인지 확인하는 함수
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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

  /// "今日" 아이콘 빌더 (Figma: icon 16x16)
  Widget _buildTodayIcon() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        border: Border.all(
          color: WoltDesignTokens.primaryBlack, // #222222
          width: 1.5,
        ),
        shape: BoxShape.circle,
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
