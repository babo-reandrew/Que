import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/navigation_utils.dart';
import '../const/color.dart';
import '../const/typography.dart';
import '../const/calendar_config.dart';

/// 향상된 캘린더 위젯 - 기존 TableCalendar를 확장해서 DateDetailView 전환 기능을 추가한다
/// 기존 HomeScreen의 캘린더 기능을 그대로 유지하면서 새로운 기능을 추가한다
/// ⭐️ DB 통합: 로컬 스케줄 맵 제거, DateDetailView가 자체적으로 DB에서 조회
class EnhancedCalendarWidget extends StatelessWidget {
  final DateTime focusedDay; // 현재 포커스된 날짜를 받는다
  final DateTime? selectedDay; // 선택된 날짜를 받는다
  final Function(DateTime, DateTime) onDaySelected; // 날짜 선택 콜백을 받는다
  final bool Function(DateTime) onDaySelectedPredicate; // 날짜 선택 조건을 받는다
  final Function(DateTime, DateTime, DateTime)
  onCalendarCellBuilder; // 캘린더 셀 빌더를 받는다

  const EnhancedCalendarWidget({
    super.key,
    required this.focusedDay, // 포커스된 날짜를 필수로 받는다
    required this.selectedDay, // 선택된 날짜를 필수로 받는다
    required this.onDaySelected, // 날짜 선택 콜백을 필수로 받는다
    required this.onDaySelectedPredicate, // 날짜 선택 조건을 필수로 받는다
    required this.onCalendarCellBuilder, // 캘린더 셀 빌더를 필수로 받는다
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      // 기본 캘린더 설정을 유지한다
      locale: 'ko_KR', // 한국어로 설정한다
      firstDay: DateTime.utc(1800, 1, 1), // 최초 날짜를 설정한다
      lastDay: DateTime.utc(3000, 12, 30), // 마지막 날짜를 설정한다
      focusedDay: focusedDay, // 포커스된 날짜를 설정한다
      // 헤더 스타일을 설정한다
      headerStyle: _buildHeaderStyle(),
      // 캘린더 스타일을 설정한다
      calendarStyle: _buildCalendarStyle(),
      // 날짜 선택 처리를 확장한다
      onDaySelected: (selectedDay, focusedDay) {
        // 기존 날짜 선택 로직을 실행한다
        onDaySelected(selectedDay, focusedDay);

        // DateDetailView로 전환하는 로직을 추가한다
        _handleDateTap(context, selectedDay);
      },
      // 선택된 날짜 조건을 설정한다
      selectedDayPredicate: onDaySelectedPredicate,
      // 캘린더 빌더를 확장한다
      calendarBuilders: _buildCalendarBuilders(context),
    );
  }

  /// 헤더 스타일을 구성하는 함수 - 기존 스타일을 유지한다
  HeaderStyle _buildHeaderStyle() {
    return HeaderStyle(
      formatButtonVisible: false, // 포맷 버튼을 숨긴다
      titleCentered: true, // 제목을 가운데 정렬한다
      titleTextStyle: CalendarTypography.headerText, // 헤더 텍스트 스타일을 설정한다
    );
  }

  /// 캘린더 스타일을 구성하는 함수 - 기존 스타일을 유지한다
  CalendarStyle _buildCalendarStyle() {
    return CalendarStyle(
      isTodayHighlighted: true, // 오늘을 강조한다
      todayDecoration: BoxDecoration(
        color: Colors.red, // 오늘 배경색을 빨간색으로 설정한다
        shape: BoxShape.circle, // 원형으로 설정한다
      ),
      defaultDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0), // 둥근 모서리를 설정한다
        color: Colors.red, // 기본 배경색을 빨간색으로 설정한다
        border: Border.all(width: 1.0, color: gray100), // 테두리를 설정한다
      ),
      weekendDecoration: BoxDecoration(
        color: Colors.blue, // 주말 배경색을 파란색으로 설정한다
        border: Border.all(width: 1.0, color: gray100), // 테두리를 설정한다
      ),
      defaultTextStyle: CalendarTypography.calendarText.copyWith(
        color: gray1000, // 기본 텍스트 색상을 설정한다
      ),
      selectedDecoration: BoxDecoration(
        color: calendarSelectedBg, // 선택된 날짜 배경색을 설정한다
        borderRadius: BorderRadius.circular(
          CalendarConfig.borderRadius,
        ), // 둥근 모서리를 설정한다
      ),
      selectedTextStyle: CalendarTypography.calendarText.copyWith(
        color: calendarSelectedText, // 선택된 날짜 텍스트 색상을 설정한다
      ),
      outsideDaysVisible: true, // 이전/다음 달 날짜를 표시한다
      outsideTextStyle: CalendarTypography.calendarText.copyWith(
        color: calendarOutsideText, // 이전/다음 달 텍스트 색상을 설정한다
      ),
      outsideDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          CalendarConfig.borderRadius,
        ), // 둥근 모서리를 설정한다
      ),
    );
  }

  /// 캘린더 빌더를 구성하는 함수 - 기존 빌더를 확장한다
  CalendarBuilders _buildCalendarBuilders(BuildContext context) {
    return CalendarBuilders(
      // 평일 셀 빌더를 확장한다
      defaultBuilder: (context, day, focusedDay) {
        return _buildEnhancedCell(
          context: context, // 컨텍스트를 전달한다
          day: day, // 날짜를 전달한다
          backgroundColor: Colors.transparent, // 투명 배경을 설정한다
          textColor: gray1000, // 텍스트 색상을 설정한다
        );
      },
      // 선택된 날짜 셀 빌더를 확장한다
      selectedBuilder: (context, day, focusedDay) {
        return _buildEnhancedCell(
          context: context, // 컨텍스트를 전달한다
          day: day, // 날짜를 전달한다
          backgroundColor: calendarSelectedBg, // 선택된 날짜 배경색을 설정한다
          textColor: calendarSelectedText, // 선택된 날짜 텍스트 색상을 설정한다
        );
      },
      // 오늘 날짜 셀 빌더를 확장한다
      todayBuilder: (context, day, focusedDay) {
        return _buildEnhancedCell(
          context: context, // 컨텍스트를 전달한다
          day: day, // 날짜를 전달한다
          backgroundColor: calendarTodayBg, // 오늘 배경색을 설정한다
          textColor: calendarTodayText, // 오늘 텍스트 색상을 설정한다
        );
      },
      // 이전/다음 달 날짜 셀 빌더를 확장한다
      outsideBuilder: (context, day, focusedDay) {
        return _buildEnhancedCell(
          context: context, // 컨텍스트를 전달한다
          day: day, // 날짜를 전달한다
          backgroundColor: Colors.transparent, // 투명 배경을 설정한다
          textColor: calendarOutsideText, // 이전/다음 달 텍스트 색상을 설정한다
        );
      },
    );
  }

  /// 향상된 캘린더 셀을 구성하는 함수 - 스케줄 표시와 클릭 기능을 추가한다
  Widget _buildEnhancedCell({
    required BuildContext context, // 컨텍스트를 받는다
    required DateTime day, // 날짜를 받는다
    required Color backgroundColor, // 배경색을 받는다
    required Color textColor, // 텍스트 색상을 받는다
  }) {
    // ⭐️ DB 통합: 스케줄 표시 기능 제거됨
    // 이거는 이래서 → 이제 캘린더 셀에 스케줄 개수를 표시하지 않으므로 불필요하다
    // 이거라면 → 심플한 캘린더 UI 유지, 디테일은 DateDetailView에서 확인

    return GestureDetector(
      // 탭 제스처를 감지한다
      onTap: () => _handleDateTap(context, day), // 날짜 탭을 처리한다
      child: Container(
        // 셀 컨테이너를 생성한다
        width: CalendarConfig.cellSize, // 셀 크기를 설정한다
        height: CalendarConfig.cellSize, // 셀 높이를 설정한다
        decoration: BoxDecoration(
          color: backgroundColor, // 배경색을 설정한다
          borderRadius: BorderRadius.circular(
            CalendarConfig.borderRadius,
          ), // 둥근 모서리를 설정한다
        ),
        alignment: Alignment.center, // 가운데 정렬한다
        child: Stack(
          // 스택을 사용해서 텍스트와 스케줄 표시를 겹친다
          children: [
            // 날짜 텍스트를 표시한다
            Text(
              '${day.day}', // 날짜를 표시한다
              style: CalendarTypography.calendarText.copyWith(
                color: textColor, // 텍스트 색상을 설정한다
              ),
            ),
            // ⭐️ DB 통합: 스케줄 표시 기능 제거됨
            // 이거는 이래서 → 캘린더 셀에 스케줄 개수 표시를 하지 않는다
            // 이거라면 → 심플한 캘린더 UI 유지
          ],
        ),
      ),
    );
  }

  /// 날짜 탭을 처리하는 함수 - DateDetailView로 전환한다
  /// ⭐️ DB 통합: 이제 schedules 파라미터 없이 날짜만 전달한다
  /// 이거를 설정하고 → DateDetailView가 selectedDate를 받아서
  /// 이거를 해서 → 자체적으로 watchByDay()로 DB를 조회해서
  /// 이거는 이래서 → 실시간으로 해당 날짜의 일정을 표시한다
  void _handleDateTap(BuildContext context, DateTime selectedDate) {

    // DateDetailView로 전환한다
    NavigationUtils.navigateToDateDetail(
      context: context, // 컨텍스트를 전달한다
      selectedDate: selectedDate, // 선택된 날짜만 전달한다 (DB에서 조회할 것임)
    );
  }
}
