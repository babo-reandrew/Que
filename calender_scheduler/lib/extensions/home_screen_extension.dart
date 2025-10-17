import 'package:flutter/material.dart';
import '../Database/schedule_database.dart'; // ⭐️ DB 통합: Drift의 ScheduleData 사용
import '../utils/home_screen_utils.dart';

/// HomeScreen 기능을 확장하는 확장 클래스
/// 기존 HomeScreen 코드를 건드리지 않고 새로운 기능을 추가한다
extension HomeScreenExtension on State {
  // 날짜 클릭 시 DateDetailView로 전환하는 확장 함수 - 기존 _onDaySelected 함수를 확장한다
  void handleDateSelection({
    required DateTime selectedDay, // 선택된 날짜를 받는다
    required DateTime focusedDay, // 포커스된 날짜를 받는다
    required Map<DateTime, List<ScheduleData>>
    schedules, // 전체 스케줄 맵을 받는다 (DB 통합)
    required Function(DateTime, DateTime)
    originalOnDaySelected, // 기존 날짜 선택 함수를 받는다
  }) {
    // 기존 날짜 선택 로직을 먼저 실행한다
    originalOnDaySelected(selectedDay, focusedDay);

    // DateDetailView로 전환하는 로직을 추가한다
    HomeScreenUtils.handleDateTap(
      context: context, // 현재 컨텍스트를 전달한다
      selectedDate: selectedDay, // 선택된 날짜를 전달한다
      schedules: schedules, // 전체 스케줄 맵을 전달한다
    );
  }

  // 스케줄이 있는 날짜에 시각적 표시를 추가하는 확장 함수 - 캘린더 셀에 스케줄 표시를 추가한다
  Widget buildEnhancedCalendarCell({
    required DateTime day, // 날짜를 받는다
    required Color backgroundColor, // 배경색을 받는다
    required Color textColor, // 텍스트 색상을 받는다
    required Map<DateTime, List<ScheduleData>>
    schedules, // 전체 스케줄 맵을 받는다 (DB 통합)
    required Widget originalCell, // 기존 셀 위젯을 받는다
    double size = 22, // 셀 크기를 받는다
    bool isCircular = false, // 원형인지 확인한다
  }) {
    // 해당 날짜에 스케줄이 있는지 확인한다
    final hasSchedules = HomeScreenUtils.hasSchedulesForDate(
      date: day, // 확인할 날짜를 전달한다
      schedules: schedules, // 전체 스케줄 맵을 전달한다
    );

    // 스케줄 개수를 가져온다
    final scheduleCount = HomeScreenUtils.getScheduleCountForDate(
      date: day, // 확인할 날짜를 전달한다
      schedules: schedules, // 전체 스케줄 맵을 전달한다
    );

    return Stack(
      // 스택을 사용해서 기존 셀 위에 스케줄 표시를 추가한다
      children: [
        originalCell, // 기존 셀을 배치한다
        if (hasSchedules) // 스케줄이 있는 경우에만 표시한다
          Positioned(
            // 위치를 설정한다
            bottom: 2, // 하단에서 2픽셀 위에 배치한다
            right: 2, // 우측에서 2픽셀 왼쪽에 배치한다
            child: Container(
              // 스케줄 표시 컨테이너를 생성한다
              width: 8, // 너비를 8픽셀로 설정한다
              height: 8, // 높이를 8픽셀로 설정한다
              decoration: BoxDecoration(
                color: Colors.red, // 빨간색으로 설정한다
                shape: BoxShape.circle, // 원형으로 설정한다
              ),
              child: Center(
                // 가운데 정렬한다
                child: Text(
                  '${scheduleCount}', // 스케줄 개수를 표시한다
                  style: TextStyle(
                    color: Colors.white, // 흰색으로 설정한다
                    fontSize: 6, // 작은 폰트로 설정한다
                    fontWeight: FontWeight.bold, // 굵게 설정한다
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 오늘 날짜에 특별한 표시를 추가하는 확장 함수 - 오늘 날짜를 강조한다
  Widget buildTodayIndicator({
    required DateTime day, // 날짜를 받는다
    required Widget originalCell, // 기존 셀 위젯을 받는다
  }) {
    // 오늘인지 확인한다
    final isToday = HomeScreenUtils.isToday(day);

    if (!isToday) {
      // 오늘이 아니면 기존 셀을 그대로 반환한다
      return originalCell;
    }

    return Container(
      // 오늘 날짜를 감싸는 컨테이너를 생성한다
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.red, // 빨간색 테두리를 설정한다
          width: 2, // 테두리 두께를 2픽셀로 설정한다
        ),
        borderRadius: BorderRadius.circular(4), // 둥근 모서리를 설정한다
      ),
      child: originalCell, // 기존 셀을 배치한다
    );
  }
}
