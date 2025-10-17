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
  TextColumn get repeatRule => text()(); // recurrence로 매핑 가능
  TextColumn get alertSetting => text()(); // reminders로 매핑 가능

  // 로컬 앱용 추가 필드들 (구글 API 연동용으로 나중에 사용)

  DateTimeColumn get createdAt => dateTime().clientDefault(
    () => DateTime.now().toUtc(),
  )(); //생성된 날짜를 자동으로 넣어라.
  TextColumn get status => text()(); // String (선택)
  TextColumn get visibility => text()(); // String (선택) - publicRange 대신
}
