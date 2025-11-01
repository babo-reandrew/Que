// ✅ 날짜 유틸리티 함수
//
// **목적:**
// 날짜 정규화 및 비교 로직을 중앙화하여
// 코드 중복을 제거하고 일관성을 보장한다.

/// 날짜를 00:00:00으로 정규화
/// - 시간, 분, 초, 밀리초를 모두 제거
/// - 날짜만 남김 (년, 월, 일)
DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// 두 날짜가 같은 날인지 확인
/// - 년, 월, 일만 비교
/// - 시간은 무시
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 날짜 범위 생성 (start ~ end, 양끝 포함)
/// - start부터 end까지의 모든 날짜 리스트 반환
/// - 예: dateRange(1/1, 1/3) → [1/1, 1/2, 1/3]
List<DateTime> dateRange(DateTime start, DateTime end) {
  final days = <DateTime>[];
  var current = normalizeDate(start);
  final endNormalized = normalizeDate(end);

  while (current.isBefore(endNormalized) ||
      current.isAtSameMomentAs(endNormalized)) {
    days.add(current);
    current = current.add(const Duration(days: 1));
  }

  return days;
}

/// 두 날짜 사이의 일수 차이 계산
/// - 음수 가능 (a가 b보다 이전이면 음수)
/// - 예: daysBetween(1/1, 1/5) → 4
int daysBetween(DateTime a, DateTime b) {
  final aNormalized = normalizeDate(a);
  final bNormalized = normalizeDate(b);
  return bNormalized.difference(aNormalized).inDays;
}

/// 날짜가 특정 범위 내에 있는지 확인
/// - start와 end 포함 (inclusive)
bool isDateInRange(DateTime date, DateTime start, DateTime end) {
  final dateNormalized = normalizeDate(date);
  final startNormalized = normalizeDate(start);
  final endNormalized = normalizeDate(end);

  return (dateNormalized.isAfter(startNormalized) ||
          dateNormalized.isAtSameMomentAs(startNormalized)) &&
      (dateNormalized.isBefore(endNormalized) ||
          dateNormalized.isAtSameMomentAs(endNormalized));
}

/// 오늘인지 확인
bool isToday(DateTime date) {
  final now = DateTime.now();
  return isSameDay(date, now);
}

/// 과거 날짜인지 확인 (오늘 제외)
bool isPast(DateTime date) {
  final now = DateTime.now();
  final dateNormalized = normalizeDate(date);
  final todayNormalized = normalizeDate(now);

  return dateNormalized.isBefore(todayNormalized);
}

/// 미래 날짜인지 확인 (오늘 제외)
bool isFuture(DateTime date) {
  final now = DateTime.now();
  final dateNormalized = normalizeDate(date);
  final todayNormalized = normalizeDate(now);

  return dateNormalized.isAfter(todayNormalized);
}
