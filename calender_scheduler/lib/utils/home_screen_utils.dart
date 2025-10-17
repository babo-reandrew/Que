import 'package:flutter/material.dart';
import 'navigation_utils.dart';

/// HomeScreen 관련 유틸리티 함수들을 모아놓은 클래스
/// HomeScreen의 기능을 확장하기 위해 사용한다
class HomeScreenUtils {
  // 날짜 클릭 시 DateDetailView로 전환하는 함수
  // ⭐️ DB 통합: schedules 파라미터는 호환성 유지용 (미사용)
  // 이거를 설정하고 → selectedDate만 전달해서
  // 이거를 해서 → DateDetailView가 자체적으로 DB에서 조회하도록 한다
  static void handleDateTap({
    required BuildContext context, // 현재 컨텍스트를 받는다
    required DateTime selectedDate, // 선택된 날짜를 받는다
    required Map<DateTime, List<dynamic>>
    schedules, // 전체 스케줄 맵 (이제 미사용, 호환성 유지)
  }) {
    print(
      '🗓️ [Utils] handleDateTap 호출: ${selectedDate.toString().split(' ')[0]}',
    );

    // DateDetailView로 전환한다
    NavigationUtils.navigateToDateDetail(
      context: context, // 컨텍스트를 전달한다
      selectedDate: selectedDate, // 선택된 날짜를 전달한다
    );
  }

  // 스케줄이 있는 날짜인지 확인하는 함수 - 스케줄이 있는 날짜에 시각적 표시를 위해 사용한다
  static bool hasSchedulesForDate({
    required DateTime date, // 확인할 날짜를 받는다
    required Map<DateTime, List<dynamic>> schedules, // 전체 스케줄 맵 (이제 미사용)
  }) {
    final dateKey = DateTime.utc(date.year, date.month, date.day); // 날짜 키를 생성한다
    final daySchedules = schedules[dateKey]; // 해당 날짜의 스케줄을 가져온다
    return daySchedules != null &&
        daySchedules.isNotEmpty; // 스케줄이 있고 비어있지 않으면 true를 반환한다
  }

  // 특정 날짜의 스케줄 개수를 반환하는 함수 - 날짜에 표시할 스케줄 개수를 계산한다
  static int getScheduleCountForDate({
    required DateTime date, // 확인할 날짜를 받는다
    required Map<DateTime, List<dynamic>> schedules, // 전체 스케줄 맵 (이제 미사용)
  }) {
    final dateKey = DateTime.utc(date.year, date.month, date.day); // 날짜 키를 생성한다
    final daySchedules = schedules[dateKey]; // 해당 날짜의 스케줄을 가져온다
    return daySchedules?.length ?? 0; // 스케줄 개수를 반환한다 (없으면 0)
  }

  // 오늘인지 확인하는 함수 - 오늘 날짜에 특별한 표시를 위해 사용한다
  static bool isToday(DateTime date) {
    final now = DateTime.now(); // 현재 시간을 가져온다
    return date.year == now.year && // 연도가 같고
        date.month == now.month && // 월이 같고
        date.day == now.day; // 일이 같으면 오늘이다
  }

  // 날짜 포맷을 문자열로 변환하는 함수 - 날짜를 사용자에게 표시하기 위해 사용한다
  static String formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일'; // 년월일 형식으로 변환한다
  }

  // 요일을 한글로 변환하는 함수 - 숫자 요일을 한글 요일로 변환한다
  static String getWeekdayName(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일']; // 요일 배열을 정의한다
    return weekdays[weekday - 1]; // 1부터 시작하는 요일을 0부터 시작하는 배열 인덱스로 변환한다
  }
}
