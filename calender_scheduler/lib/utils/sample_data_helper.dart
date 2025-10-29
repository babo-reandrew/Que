/// 🧪 임시 데이터 생성 헬퍼
///
/// Schedule, Task, Habit 샘플 데이터를 생성하는 유틸리티
/// 이거를 설정하고 → 데이터베이스에 실제 데이터를 추가해서
/// 이거를 해서 → UI 개발 시 실제 데이터처럼 테스트할 수 있다
library;

import '../Database/schedule_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';

class SampleDataHelper {
  /// Schedule 샘플 데이터 생성 (5개)
  /// 이거를 설정하고 → 5개의 실제 일정을 생성해서
  /// 이거를 해서 → ScheduleCard UI를 테스트한다
  static Future<void> createSampleSchedules(AppDatabase db) async {
    // 샘플 1: Flutter 졸업 프로젝트 중간 발표
    await db.createSchedule(
      ScheduleCompanion.insert(
        start: DateTime(2025, 10, 18, 14, 0), // 2025-10-18 14:00
        end: DateTime(2025, 10, 18, 15, 30), // 15:30
        summary: 'Flutter 졸업 프로젝트 중간 발표',
        description: const drift.Value(''),
        location: const drift.Value(''),
        colorId: 'blue', // 학업
        repeatRule: '',
        alertSetting: 'PT1H', // 1시간 전
        status: 'confirmed',
        visibility: 'default',
      ),
    );

    // 샘플 2: 디자인 시스템 리뷰 미팅
    await db.createSchedule(
      ScheduleCompanion.insert(
        start: DateTime(2025, 10, 17, 10, 0), // 2025-10-17 10:00
        end: DateTime(2025, 10, 17, 11, 0), // 11:00
        summary: 'デザインシステムレビューミーティング',
        description: const drift.Value(''),
        location: const drift.Value(''),
        colorId: 'green', // 프로젝트
        repeatRule: '',
        alertSetting: 'PT30M', // 30분 전
        status: 'confirmed',
        visibility: 'default',
      ),
    );

    // 샘플 3: Xcode 빌드 에러 해결 세션
    await db.createSchedule(
      ScheduleCompanion.insert(
        start: DateTime(2025, 10, 16, 20, 0), // 2025-10-16 20:00
        end: DateTime(2025, 10, 16, 22, 0), // 22:00
        summary: 'Xcodeビルドエラー解決セッション',
        description: const drift.Value(''),
        location: const drift.Value(''),
        colorId: 'red', // 개발
        repeatRule: '',
        alertSetting: '',
        status: 'confirmed',
        visibility: 'default',
      ),
    );

    // 샘플 4: UX 리서치 인터뷰
    await db.createSchedule(
      ScheduleCompanion.insert(
        start: DateTime(2025, 10, 21, 15, 0), // 2025-10-21 15:00
        end: DateTime(2025, 10, 21, 16, 0), // 16:00
        summary: 'UXリサーチインタビュー',
        description: const drift.Value(''),
        location: const drift.Value(''),
        colorId: 'green', // 프로젝트
        repeatRule: '',
        alertSetting: 'PT1H', // 1시간 전
        status: 'confirmed',
        visibility: 'default',
      ),
    );

    // 샘플 5: 프로젝트 팀 주간 회의
    await db.createSchedule(
      ScheduleCompanion.insert(
        start: DateTime(2025, 10, 23, 13, 0), // 2025-10-23 13:00
        end: DateTime(2025, 10, 23, 14, 0), // 14:00
        summary: 'プロジェクトチーム週間ミーティング',
        description: const drift.Value(''),
        location: const drift.Value(''),
        colorId: 'blue', // 학업
        repeatRule: 'FREQ=WEEKLY;BYDAY=WE', // 매주 수요일
        alertSetting: 'PT15M', // 15분 전
        status: 'confirmed',
        visibility: 'default',
      ),
    );

    print('✅ [SampleData] Schedule 샘플 데이터 5개 생성 완료');
  }

  /// Task 샘플 데이터 생성 (10개)
  /// 이거를 설정하고 → 10개의 실제 할일을 생성해서
  /// 이거를 해서 → TaskCard UI를 테스트한다
  static Future<void> createSampleTasks(AppDatabase db) async {
    final now = DateTime.now();

    // 샘플 1: table_calendar 패키지 성능 최적화
    await db.createTask(
      TaskCompanion.insert(
        title: 'table_calendarパッケージ性能最適化',
        completed: const drift.Value(false),
        dueDate: drift.Value(DateTime(2025, 10, 17)),
        createdAt: now,
        colorId: const drift.Value('red'), // 우선순위 높음
      ),
    );

    // 샘플 2: iOS 배포 인증서 갱신
    await db.createTask(
      TaskCompanion.insert(
        title: 'iOS配布証明書更新',
        completed: const drift.Value(false),
        dueDate: drift.Value(DateTime(2025, 10, 18)),
        createdAt: now,
        colorId: const drift.Value('red'), // 우선순위 높음
      ),
    );

    // 샘플 3: G마켓산스/Gilroy/LINE Seed 폰트 통합 테스트
    await db.createTask(
      TaskCompanion.insert(
        title: 'Gマーケットサンス/Gilroy/LINE Seedフォント統合テスト',
        completed: const drift.Value(false),
        dueDate: drift.Value(DateTime(2025, 10, 19)),
        createdAt: now,
        colorId: const drift.Value('blue'), // 우선순위 중간
      ),
    );

    // 샘플 4: MCP 서버 연결 설정 문서화
    await db.createTask(
      TaskCompanion.insert(
        title: 'MCPサーバー接続設定ドキュメント化',
        completed: const drift.Value(false),
        dueDate: drift.Value(DateTime(2025, 10, 20)),
        createdAt: now,
        colorId: const drift.Value('gray'), // 우선순위 낮음
      ),
    );

    // 샘플 5: Drift vs Isar 데이터베이스 성능 비교
    await db.createTask(
      TaskCompanion.insert(
        title: 'Drift vs Isarデータベース性能比較',
        completed: const drift.Value(false),
        dueDate: drift.Value(DateTime(2025, 10, 22)),
        createdAt: now,
        colorId: const drift.Value('red'), // 우선순위 높음
      ),
    );

    // 샘플 6: 사용자 페르소나 3개 작성
    await db.createTask(
      TaskCompanion.insert(
        title: 'ユーザーペルソナ3つ作成',
        completed: const drift.Value(false),
        dueDate: drift.Value(DateTime(2025, 10, 23)),
        createdAt: now,
        colorId: const drift.Value('blue'), // 우선순위 중간
      ),
    );

    // 샘플 7: Git 브랜치 병합 및 충돌 해결
    await db.createTask(
      TaskCompanion.insert(
        title: 'Gitブランチマージ及び衝突解決',
        completed: const drift.Value(false),
        dueDate: drift.Value(DateTime(2025, 10, 17)),
        createdAt: now,
        colorId: const drift.Value('red'), // 우선순위 높음
      ),
    );

    // 샘플 8: 컬러 시스템 Figma 컴포넌트화
    await db.createTask(
      TaskCompanion.insert(
        title: 'カラーシステムFigmaコンポーネント化',
        completed: const drift.Value(false),
        dueDate: drift.Value(DateTime(2025, 10, 24)),
        createdAt: now,
        colorId: const drift.Value('blue'), // 우선순위 중간
      ),
    );

    // 샘플 9: Gemini Nano 온디바이스 LLM 통합 조사
    await db.createTask(
      TaskCompanion.insert(
        title: 'Gemini NanoオンデバイスLLM統合調査',
        completed: const drift.Value(false),
        dueDate: drift.Value(DateTime(2025, 10, 25)),
        createdAt: now,
        colorId: const drift.Value('blue'), // 우선순위 중간
      ),
    );

    // 샘플 10: Cursor Ultra 구독 비용 검토
    await db.createTask(
      TaskCompanion.insert(
        title: 'Cursor Ultra購読費用検討',
        completed: const drift.Value(false),
        dueDate: drift.Value(DateTime(2025, 10, 19)),
        createdAt: now,
        colorId: const drift.Value('gray'), // 우선순위 낮음
      ),
    );

    print('✅ [SampleData] Task 샘플 데이터 10개 생성 완료');
  }

  /// Habit 샘플 데이터 생성 (3개)
  /// 이거를 설정하고 → 3개의 실제 습관을 생성해서
  /// 이거를 해서 → HabitCard UI를 테스트한다
  static Future<void> createSampleHabits(AppDatabase db) async {
    final now = DateTime.now();

    // 샘플 1: 운동 (매일, 07:00)
    await db.createHabit(
      HabitCompanion.insert(
        title: '運動',
        createdAt: now,
        repeatRule: '毎日', // 매일
        reminder: const drift.Value('07:00'), // 오전 7시
        colorId: const drift.Value('red'), // 핵심
      ),
    );

    // 샘플 2: 수면 (매일, 22:30)
    await db.createHabit(
      HabitCompanion.insert(
        title: '睡眠',
        createdAt: now,
        repeatRule: '毎日', // 매일
        reminder: const drift.Value('22:30'), // 오후 10시 30분
        colorId: const drift.Value('red'), // 핵심
      ),
    );

    // 샘플 3: 식단 관리 (매일, 12:00)
    await db.createHabit(
      HabitCompanion.insert(
        title: '食事管理',
        createdAt: now,
        repeatRule: '毎日', // 매일
        reminder: const drift.Value('12:00'), // 낮 12시
        colorId: const drift.Value('blue'), // 일상
      ),
    );

    print('✅ [SampleData] Habit 샘플 데이터 3개 생성 완료');
  }

  /// 모든 샘플 데이터 생성 (딱 한 번만)
  /// 이거를 설정하고 → SharedPreferences로 이미 추가했는지 체크해서
  /// 이거를 해서 → 앱 재실행 시 중복 추가를 방지한다
  /// 이거는 이래서 → 샘플 데이터가 한 번만 생성된다
  static Future<void> createAllSampleData(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    final hasCreatedSampleData =
        prefs.getBool('has_created_sample_data') ?? false;

    // 이미 샘플 데이터를 생성했다면 스킵
    if (hasCreatedSampleData) {
      print('ℹ️ [SampleData] 샘플 데이터가 이미 존재합니다. 스킵합니다.');
      return;
    }

    // 샘플 데이터 생성
    await createSampleSchedules(db);
    await createSampleTasks(db);
    await createSampleHabits(db);

    // 생성 완료 플래그 저장
    await prefs.setBool('has_created_sample_data', true);
    print('🎉 [SampleData] 모든 샘플 데이터 생성 완료 (일정 5개, 할일 10개, 습관 3개)');
  }

  /// 샘플 데이터 삭제 (초기화)
  /// 이거를 설정하고 → 모든 Schedule, Task, Habit를 삭제하고
  /// 이거를 해서 → SharedPreferences 플래그도 초기화한다
  /// 이거는 이래서 → 다시 샘플 데이터를 추가할 수 있다
  /// 🧪 오늘 날짜에 테스트용 일정 5개 추가
  /// 이거를 설정하고 → 오늘 날짜에 5개의 임시 일정을 생성해서
  /// 이거를 해서 → 동적 일정 개수 계산 기능을 테스트한다
  static Future<void> createTodayTestSchedules(AppDatabase db) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    print(
      '🧪 [TestData] 오늘 날짜(${todayDate.toString().split(' ')[0]})에 5개 일정 추가 시작...',
    );

    // 테스트 1: 아침 미팅
    await db.createSchedule(
      ScheduleCompanion.insert(
        start: DateTime(todayDate.year, todayDate.month, todayDate.day, 9, 0),
        end: DateTime(todayDate.year, todayDate.month, todayDate.day, 10, 0),
        summary: '아침 스탠드업 미팅',
        description: const drift.Value('오늘의 업무 공유'),
        location: const drift.Value('회의실 A'),
        colorId: 'blue',
        repeatRule: '',
        alertSetting: 'PT15M',
        status: 'confirmed',
        visibility: 'default',
      ),
    );
    print('✅ [TestData] 1/5 추가됨: 아침 스탠드업 미팅 (09:00-10:00)');

    // 테스트 2: 코드 리뷰
    await db.createSchedule(
      ScheduleCompanion.insert(
        start: DateTime(todayDate.year, todayDate.month, todayDate.day, 11, 0),
        end: DateTime(todayDate.year, todayDate.month, todayDate.day, 12, 0),
        summary: 'Flutter 코드 리뷰',
        description: const drift.Value('월뷰 동적 일정 개수 기능 리뷰'),
        location: const drift.Value('온라인'),
        colorId: 'green',
        repeatRule: '',
        alertSetting: 'PT30M',
        status: 'confirmed',
        visibility: 'default',
      ),
    );
    print('✅ [TestData] 2/5 추가됨: Flutter 코드 리뷰 (11:00-12:00)');

    // 테스트 3: 점심 약속
    await db.createSchedule(
      ScheduleCompanion.insert(
        start: DateTime(todayDate.year, todayDate.month, todayDate.day, 12, 30),
        end: DateTime(todayDate.year, todayDate.month, todayDate.day, 13, 30),
        summary: '팀 점심 식사',
        description: const drift.Value('이탈리안 레스토랑'),
        location: const drift.Value('강남역 근처'),
        colorId: 'red',
        repeatRule: '',
        alertSetting: 'PT1H',
        status: 'confirmed',
        visibility: 'default',
      ),
    );
    print('✅ [TestData] 3/5 추가됨: 팀 점심 식사 (12:30-13:30)');

    // 테스트 4: 오후 개발
    await db.createSchedule(
      ScheduleCompanion.insert(
        start: DateTime(todayDate.year, todayDate.month, todayDate.day, 14, 0),
        end: DateTime(todayDate.year, todayDate.month, todayDate.day, 16, 0),
        summary: 'UI 개발 집중 시간',
        description: const drift.Value('방해 금지 모드'),
        location: const drift.Value('사무실'),
        colorId: 'purple',
        repeatRule: '',
        alertSetting: '',
        status: 'confirmed',
        visibility: 'default',
      ),
    );
    print('✅ [TestData] 4/5 추가됨: UI 개발 집중 시간 (14:00-16:00)');

    // 테스트 5: 저녁 운동
    await db.createSchedule(
      ScheduleCompanion.insert(
        start: DateTime(todayDate.year, todayDate.month, todayDate.day, 18, 30),
        end: DateTime(todayDate.year, todayDate.month, todayDate.day, 19, 30),
        summary: '헬스장 운동',
        description: const drift.Value('하체 운동'),
        location: const drift.Value('OO 피트니스'),
        colorId: 'orange',
        repeatRule: '',
        alertSetting: 'PT15M',
        status: 'confirmed',
        visibility: 'default',
      ),
    );
    print('✅ [TestData] 5/5 추가됨: 헬스장 운동 (18:30-19:30)');

    print('🎉 [TestData] 오늘 날짜에 5개 일정 추가 완료!');
  }

  static Future<void> clearAllSampleData(AppDatabase db) async {
    // Schedule 삭제
    final schedules = await db.select(db.schedule).get();
    for (final schedule in schedules) {
      await db.deleteSchedule(schedule.id);
    }

    // Task 삭제
    final tasks = await db.select(db.task).get();
    for (final task in tasks) {
      await db.deleteTask(task.id);
    }

    // Habit 삭제
    final habits = await db.select(db.habit).get();
    for (final habit in habits) {
      await db.deleteHabit(habit.id);
    }

    // SharedPreferences 플래그 초기화
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_created_sample_data');

    print('🗑️ [SampleData] 모든 샘플 데이터 삭제 완료');
  }
}
