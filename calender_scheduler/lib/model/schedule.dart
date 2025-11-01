import 'package:drift/drift.dart';

class Schedule extends Table {
  // 구글 캘린더 API 필수 필드들
  DateTimeColumn get start => dateTime()(); // EventDateTime -> DateTime
  DateTimeColumn get end => dateTime()(); // EventDateTime -> DateTime

  // 구글 캘린더 API 권장/선택 필드들
  IntColumn get id => integer().autoIncrement()(); // String (선택)
  //()()를 두번 써야 하는 이유는 아마도 함수를 반환한 걸 한번 더 반환을 해주어야 하기 때문
  //autoIncrement는 우리가 어떠한 값이 들어오면, 자동으로 1을 올려서 다른 값인 걸 반환하고싶다. 그럴 때 자동으로 해준다.
  TextColumn get summary => text()(); // String (권장) - title 대신

  // ✅ [NULLABLE] UI 입력 없음 - 기본값 빈 문자열로 저장
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get location => text().withDefault(const Constant(''))();

  TextColumn get colorId => text()(); // String (선택) - category 대신

  // ✅ 반복 규칙과 알림 설정은 기본값 빈 문자열 (사용자가 선택하지 않으면 반복 없음)
  TextColumn get repeatRule =>
      text().withDefault(const Constant(''))(); // recurrence로 매핑 가능
  TextColumn get alertSetting =>
      text().withDefault(const Constant(''))(); // reminders로 매핑 가능

  // 로컬 앱용 추가 필드들 (구글 API 연동용으로 나중에 사용)

  DateTimeColumn get createdAt => dateTime().clientDefault(
    () => DateTime.now().toUtc(),
  )(); //생성된 날짜를 자동으로 넣어라.

  // ✅ status와 visibility는 기본값 설정 (사용자 입력 없음)
  TextColumn get status =>
      text().withDefault(const Constant('confirmed'))(); // String (선택)
  TextColumn get visibility => text().withDefault(
    const Constant('default'),
  )(); // String (선택) - publicRange 대신

  // 완료 기능
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  // 🌍 시간대 정보 (로컬 시간 보존을 위한 필드)
  // 이거를 설정하고 → 반복 일정의 원래 "로컬 시간"을 기억해서
  // 이거를 해서 → DST 변경 시에도 사용자가 원하는 시간을 유지하고
  // 이거는 이래서 → "매일 오전 8시"가 항상 8시에 표시된다
  TextColumn get timezone => text().withDefault(
    const Constant(''),
  )(); // IANA Timezone ID (예: 'Asia/Seoul', 빈 문자열이면 UTC)

  // 🕐 원본 로컬 시간 (반복 이벤트용)
  // start/end는 UTC로 저장되므로, 원래 사용자가 선택한 "로컬 시간"을 별도 저장
  IntColumn get originalHour => integer().nullable()(); // 0-23
  IntColumn get originalMinute => integer().nullable()(); // 0-59
}
