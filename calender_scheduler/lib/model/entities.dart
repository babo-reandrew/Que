import 'package:drift/drift.dart';

/// Task (할일) 테이블
/// 이거를 설정하고 → 할일 데이터를 저장하는 테이블을 정의해서
/// 이거를 해서 → 제목, 완료 여부, 마감일, 색상 등을 관리하고
/// 이거는 이래서 → Quick Add 시스템에서 할일을 추가/관리할 수 있다
@DataClassName('TaskData')
class Task extends Table {
  // 이거를 설정하고 → 자동 증가하는 id를 primary key로 설정해서
  // 이거를 해서 → 각 할일을 고유하게 식별한다
  IntColumn get id => integer().autoIncrement()();

  // 이거를 설정하고 → 제목을 필수 텍스트로 설정해서
  // 이거를 해서 → 할일의 내용을 저장한다
  TextColumn get title => text()();

  // 이거를 설정하고 → 완료 여부를 boolean으로 설정해서
  // 이거를 해서 → 체크박스 상태를 관리한다
  // 이거는 이래서 → 기본값은 false (미완료)
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  // 이거를 설정하고 → 마감일을 nullable DateTime으로 설정해서
  // 이거를 해서 → 마감일이 없는 할일도 허용한다
  DateTimeColumn get dueDate => dateTime().nullable()();

  // 이거를 설정하고 → 목록 ID를 텍스트로 설정해서
  // 이거를 해서 → 여러 목록(Inbox, 프로젝트 등)으로 분류한다
  // 이거는 이래서 → 기본값은 'inbox'
  TextColumn get listId => text().withDefault(const Constant('inbox'))();

  // 이거를 설정하고 → 생성일을 DateTime으로 설정해서
  // 이거를 해서 → 언제 만들어졌는지 기록한다
  DateTimeColumn get createdAt => dateTime()();

  // 이거를 설정하고 → 완료일을 nullable DateTime으로 설정해서
  // 이거를 해서 → 완료된 날짜를 기록한다
  DateTimeColumn get completedAt => dateTime().nullable()();

  // 이거를 설정하고 → 색상 ID를 텍스트로 설정해서
  // 이거를 해서 → 카테고리별로 색상을 구분한다
  // 이거는 이래서 → 기본값은 'gray'
  TextColumn get colorId => text().withDefault(const Constant('gray'))();

  // ✅ 반복 규칙 추가 (JSON 형식)
  // 이거를 설정하고 → 반복 주기를 JSON 형식의 텍스트로 설정해서
  // 이거를 해서 → 매일/매월/간격 반복 설정을 저장한다
  TextColumn get repeatRule => text().withDefault(const Constant(''))();

  // ✅ 리마인더 설정 추가 (JSON 형식)
  // 이거를 설정하고 → 리마인더 설정을 JSON 형식의 텍스트로 설정해서
  // 이거를 해서 → 알림 시간을 저장한다
  TextColumn get reminder => text().withDefault(const Constant(''))();
}

/// Habit (습관) 테이블
/// 이거를 설정하고 → 습관 데이터를 저장하는 테이블을 정의해서
/// 이거를 해서 → 반복되는 루틴을 관리하고
/// 이거는 이래서 → 날짜별 완료 기록을 추적할 수 있다
@DataClassName('HabitData')
class Habit extends Table {
  // 이거를 설정하고 → 자동 증가하는 id를 primary key로 설정해서
  // 이거를 해서 → 각 습관을 고유하게 식별한다
  IntColumn get id => integer().autoIncrement()();

  // 이거를 설정하고 → 제목을 필수 텍스트로 설정해서
  // 이거를 해서 → 습관의 내용을 저장한다
  TextColumn get title => text()();

  // 이거를 설정하고 → 생성일을 DateTime으로 설정해서
  // 이거를 해서 → 언제 시작했는지 기록한다
  DateTimeColumn get createdAt => dateTime()();

  // 이거를 설정하고 → 색상 ID를 텍스트로 설정해서
  // 이거를 해서 → 카테고리별로 색상을 구분한다
  // 이거는 이래서 → 기본값은 'gray'
  TextColumn get colorId => text().withDefault(const Constant('gray'))();

  // 이거를 설정하고 → 반복 주기를 JSON 형식의 텍스트로 설정해서
  // 이거를 해서 → 요일별 반복 설정을 저장한다
  // 이거는 이래서 → 예: '{"mon":true,"tue":false,...}'
  TextColumn get repeatRule => text()();

  // ✅ 리마인더 설정 추가 (JSON 형식)
  // 이거를 설정하고 → 리마인더 설정을 JSON 형식의 텍스트로 설정해서
  // 이거를 해서 → 알림 시간을 저장한다
  TextColumn get reminder => text().withDefault(const Constant(''))();
}

/// HabitCompletion (습관 완료 기록) 테이블
/// 이거를 설정하고 → 날짜별 습관 완료 기록을 저장하는 테이블을 정의해서
/// 이거를 해서 → 어떤 날짜에 어떤 습관을 완료했는지 추적하고
/// 이거는 이래서 → 통계와 스트릭(연속 기록)을 계산할 수 있다
@DataClassName('HabitCompletionData')
class HabitCompletion extends Table {
  // 이거를 설정하고 → 자동 증가하는 id를 primary key로 설정해서
  // 이거를 해서 → 각 완료 기록을 고유하게 식별한다
  IntColumn get id => integer().autoIncrement()();

  // 이거를 설정하고 → habitId를 foreign key로 설정해서
  // 이거를 해서 → Habit 테이블과 연결한다
  // 이거는 이래서 → 어느 습관의 기록인지 알 수 있다
  IntColumn get habitId => integer()();

  // 이거를 설정하고 → 완료한 날짜를 DateTime으로 설정해서
  // 이거를 해서 → 언제 완료했는지 기록한다
  DateTimeColumn get completedDate => dateTime()();

  // 이거를 설정하고 → 기록 생성일을 DateTime으로 설정해서
  // 이거를 해서 → 언제 체크했는지 기록한다
  DateTimeColumn get createdAt => dateTime()();
}

/// DailyCardOrder (날짜별 카드 순서 관리) 테이블
///
/// 이거를 설정하고 → 특정 날짜에 표시되는 모든 카드의 순서를 관리하는 테이블을 정의해서
/// 이거를 해서 → 날짜마다 사용자가 설정한 카드 배치 순서를 저장하고
/// 이거는 이래서 → 일정/할일/습관이 섞인 상태에서도 정확한 순서를 복원할 수 있다
///
/// **핵심 개념:**
/// - 날짜(date)를 기준으로 각 카드의 순서(sortOrder)를 저장
/// - cardType + cardId로 실제 카드 데이터와 JOIN
/// - 기존 Schedule/Task/Habit 테이블은 건드리지 않음
///
/// **사용 예시:**
/// ```
/// 2025-10-18 날짜:
///   - sortOrder: 0 → schedule (id: 5)
///   - sortOrder: 1 → task (id: 12)
///   - sortOrder: 2 → schedule (id: 8)
///   - sortOrder: 3 → habit (id: 3)
/// ```
@DataClassName('DailyCardOrderData')
class DailyCardOrder extends Table {
  // 🔑 Primary Key: 자동 증가 ID
  // 이거를 설정하고 → 자동 증가하는 id를 primary key로 설정해서
  // 이거를 해서 → 각 순서 레코드를 고유하게 식별한다
  IntColumn get id => integer().autoIncrement()();

  // 📅 날짜 (기준 날짜 - 시간 제거된 00:00:00)
  // 이거를 설정하고 → 어느 날짜의 순서인지 저장해서
  // 이거를 해서 → 날짜별로 다른 순서를 관리한다
  // 이거는 이래서 → date_detail_view에서 날짜별로 쿼리할 수 있다
  DateTimeColumn get date => dateTime()();

  // 🎯 카드 타입 ('schedule' | 'task' | 'habit')
  // 이거를 설정하고 → 어떤 종류의 카드인지 구분해서
  // 이거를 해서 → JOIN 시 올바른 테이블을 참조한다
  // 이거는 이래서 → 'schedule'이면 Schedule 테이블과 JOIN
  TextColumn get cardType => text()();

  // 🆔 실제 카드 ID (Schedule.id | Task.id | Habit.id)
  // 이거를 설정하고 → 실제 데이터의 ID를 저장해서
  // 이거를 해서 → Schedule/Task/Habit 테이블과 JOIN 연결한다
  // 이거는 이래서 → WHERE cardId = Schedule.id 조건으로 실제 데이터 가져옴
  IntColumn get cardId => integer()();

  // 📊 정렬 순서 (0부터 시작, 작을수록 위)
  // 이거를 설정하고 → 화면에 표시될 순서를 숫자로 저장해서
  // 이거를 해서 → ORDER BY sortOrder로 정렬한다
  // 이거는 이래서 → 드래그앤드롭으로 순서가 바뀌면 이 값만 업데이트
  IntColumn get sortOrder => integer()();

  // ⏰ 수정 시간 (순서가 변경된 최종 시간)
  // 이거를 설정하고 → 언제 순서가 변경되었는지 기록해서
  // 이거를 해서 → 디버깅 및 동기화 시 참고한다
  // 이거는 이래서 → 기존 카드 테이블의 createdAt은 그대로 두고 수정 시간만 관리
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
}

// ============================================================================
// 🎵 Insight Player 관련 테이블 (Phase 1)
// ============================================================================

/// AudioContents (인사이트 오디오 - 메타데이터 + 재생 상태 통합)
/// 이거를 설정하고 → 오디오 정보와 재생 상태를 하나의 테이블에서 관리해서
/// 이거를 해서 → JOIN 없이 한 번의 쿼리로 모든 정보를 가져온다
/// 이거는 이래서 → amlv LyricViewer 재생 중 모든 상태를 완벽하게 추적할 수 있다
///
/// **재생 시나리오별 데이터 흐름:**
/// 1. 첫 재생: playCount++, lastPlayedAt=now, lastPositionMs=0
/// 2. 재생 중: onLyricChanged → lastPositionMs 업데이트
/// 3. 일시정지/종료: 마지막 위치 자동 저장 → 이어듣기 가능
/// 4. 완료(90%+): isCompleted=true, completedAt=now
/// 5. 재시작: lastPositionMs=0, playCount++
@DataClassName('AudioContentData')
class AudioContents extends Table {
  // ========== � 메타데이터 (불변 정보) ==========

  // �🔑 고유 ID
  IntColumn get id => integer().autoIncrement()();

  // 📝 제목 (예: "過去データから見える自分可能性")
  TextColumn get title => text()();

  // 📝 부제목 (예: "インサイト")
  TextColumn get subtitle => text()();

  // 🎵 오디오 파일 경로 (audio/insight_001.mp3)
  // ⚠️ 주의: amlv의 AssetSource가 "assets/" 자동 추가하므로
  //    "audio/..."로 저장 (O), "asset/audio/..."로 저장 (X)
  TextColumn get audioPath => text()();

  // ⏱️ 총 재생 시간 (초 단위)
  IntColumn get durationSeconds => integer()();

  // 📅 대상 날짜 (정규화: YYYY-MM-DD 00:00:00)
  // 이거를 설정하고 → 날짜를 정규화해서 저장해서
  // 이거를 해서 → WHERE targetDate = DATE('2025-10-18') 로 조회한다
  DateTimeColumn get targetDate => dateTime()();

  // ⏰ 생성 시간
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // ========== 🎬 재생 상태 (가변 정보) ==========

  // 🎯 마지막 재생 위치 (밀리초)
  // 이거를 설정하고 → amlv onLyricChanged에서 실시간 업데이트해서
  // 이거를 해서 → 앱 재시작 시 이어듣기를 지원한다
  // 이거는 이래서 → 완료 후 재시작하면 0으로 리셋된다
  IntColumn get lastPositionMs => integer().withDefault(const Constant(0))();

  // ✅ 완료 여부 (90% 이상 재생 시 true)
  // 이거를 설정하고 → amlv onCompleted 콜백에서 true로 설정해서
  // 이거를 해서 → 완료된 인사이트를 구분한다
  // 이거는 이래서 → 재시작해도 유지됨 (통계용)
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  // ⏰ 마지막 재생 시각 (null = 한 번도 안 들음)
  // 이거를 설정하고 → 재생 시작할 때마다 DateTime.now()로 업데이트해서
  // 이거를 해서 → "최근 들은 인사이트" 목록을 만들 수 있다
  // 이거는 이래서 → nullable이므로 미재생 상태도 표현 가능
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();

  // 🎉 완료 시각 (null = 미완료)
  // 이거를 설정하고 → isCompleted=true 될 때 DateTime.now()로 설정해서
  // 이거를 해서 → 언제 완료했는지 기록한다
  // 이거는 이래서 → 완료 후 재시작해도 기록은 유지됨
  DateTimeColumn get completedAt => dateTime().nullable()();

  // 📊 총 재생 횟수 (통계용)
  // 이거를 설정하고 → 재생 시작할 때마다 +1 증가시켜서
  // 이거를 해서 → 몇 번 들었는지 추적한다
  // 이거는 이래서 → 인기 인사이트 분석에 사용 가능
  IntColumn get playCount => integer().withDefault(const Constant(0))();

  // � 성능 최적화: targetDate UNIQUE 제약
  // → 하루에 하나의 인사이트만 (중복 방지)
  // → WHERE targetDate = '2025-10-18' 쿼리 최적화 (인덱스 스캔)
  @override
  List<Set<Column>> get uniqueKeys => [
    {targetDate}, // 하나의 날짜에는 하나의 인사이트만
  ];
}

/// TranscriptLines (스크립트 라인 - amlv LyricViewer 호환)
/// 이거를 설정하고 → LRC 파싱 결과를 타임스탬프와 함께 저장해서
/// 이거를 해서 → amlv가 오디오 재생 중 자동으로 스크롤하며 표시한다
/// 이거는 이래서 → startTimeMs 기반으로 현재 라인을 O(log n)에 찾을 수 있다
///
/// **amlv 통합 방식:**
/// ```dart
/// final lyricLines = transcriptLines.map((line) => LyricLine(
///   time: Duration(milliseconds: line.startTimeMs),
///   content: line.content,
/// )).toList();
/// ```
@DataClassName('TranscriptLineData')
class TranscriptLines extends Table {
  // 🔑 고유 ID
  IntColumn get id => integer().autoIncrement()();

  // 🔗 오디오 콘텐츠 참조 (CASCADE DELETE)
  // 이거를 설정하고 → AudioContents가 삭제되면 자동 삭제되도록 해서
  // 이거를 해서 → 고아 레코드(orphan record)를 방지한다
  IntColumn get audioContentId =>
      integer().references(AudioContents, #id, onDelete: KeyAction.cascade)();

  // 📊 순서 번호 (0부터 시작)
  // 이거를 설정하고 → 스크립트의 순서를 명시적으로 저장해서
  // 이거를 해서 → ORDER BY sequence로 정렬한다
  // 이거는 이래서 → "3번째 라인" 같은 위치 기반 쿼리 가능
  IntColumn get sequence => integer()();

  // ⏱️ 시작 시간 (밀리초)
  // 이거를 설정하고 → 이 라인이 표시될 타임스탬프를 저장해서
  // 이거를 해서 → amlv가 오디오 위치와 비교하여 현재 라인을 결정한다
  IntColumn get startTimeMs => integer()();

  // ⏱️ 종료 시간 (밀리초)
  // 이거를 설정하고 → 다음 라인으로 넘어갈 타임스탬프를 저장해서
  // 이거를 해서 → 라인 지속 시간을 계산할 수 있다
  // 이거는 이래서 → duration = endTimeMs - startTimeMs
  IntColumn get endTimeMs => integer()();

  // 📝 스크립트 텍스트 내용
  // 이거를 설정하고 → 실제 표시될 텍스트를 저장해서
  // 이거를 해서 → amlv LyricViewer에 렌더링한다
  TextColumn get content => text()();

  // � 성능 최적화: {audioContentId, sequence} 복합 UNIQUE 제약
  // → 같은 오디오에서 순서 중복 방지 (데이터 무결성)
  // → WHERE audioContentId=X AND sequence=Y 쿼리 최적화 (복합 인덱스)
  @override
  List<Set<Column>> get uniqueKeys => [
    {audioContentId, sequence}, // 같은 오디오에서 순서는 중복 불가
  ];
}
