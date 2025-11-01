import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider; // ✅ prefix 추가
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod 추가
import 'package:flutter_persistent_keyboard_height/flutter_persistent_keyboard_height.dart'; // ✅ 키보드 높이 유지
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ 환경 변수
import 'package:super_drag_and_drop/super_drag_and_drop.dart'; // 🔥 드래그 앤 드롭 추가
import 'package:calender_scheduler/config/app_routes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:calender_scheduler/Database/schedule_database.dart';
import 'package:get_it/get_it.dart';
import 'package:calender_scheduler/providers/bottom_sheet_controller.dart';
import 'package:calender_scheduler/providers/schedule_form_controller.dart';
import 'package:calender_scheduler/providers/task_form_controller.dart';
import 'package:calender_scheduler/providers/habit_form_controller.dart';
import 'package:calender_scheduler/providers/image_analysis_provider.dart'; // ✅ 추가
import 'package:calender_scheduler/design_system/wolt_theme.dart';
import 'package:calender_scheduler/utils/temp_input_cache.dart'; // ✅ 임시 캐시 초기화
// import 'package:calender_scheduler/utils/sample_data_helper.dart'; // ✅ 샘플 데이터 헬퍼 - 비활성화

// ===================================================================
// ⭐️ Main Entry Point: 앱의 진입점
// ===================================================================
// 이거를 설정하고 → 앱 시작 전 필요한 초기화 작업을 수행하고
// 이거를 해서 → 데이터베이스, 날짜 포맷, 의존성 주입을 준비한다
// 이거는 이래서 → 앱이 안정적으로 실행되고 모든 기능이 정상 작동한다
// 이거라면 → 중앙화된 라우트 시스템으로 화면 전환을 관리한다

void main() async {
  // ===================================================================
  // 1. Flutter 프레임워크 초기화
  // ===================================================================
  WidgetsFlutterBinding.ensureInitialized();
  // 이거를 설정하고 → Flutter 프레임워크가 준비될 때까지 기다려서
  // 이거를 해서 → async 작업이 main 함수에서 안전하게 실행된다

  // ===================================================================
  // 2. 날짜 포맷 초기화 (다국어 지원)
  // ===================================================================
  await initializeDateFormatting();
  // 이거를 설정하고 → 한국어 날짜 포맷을 로드해서
  // 이거를 해서 → "10월", "월요일" 같은 한국어 표시가 가능하다

  // ===================================================================
  // 2.5 환경 변수 로드 (.env 파일)
  // ===================================================================
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {}

  // ===================================================================
  // 3. 데이터베이스 초기화 및 의존성 주입
  // ===================================================================
  final database = AppDatabase();
  GetIt.instance.registerSingleton<AppDatabase>(database);
  // 이거를 설정하고 → AppDatabase 인스턴스를 GetIt에 등록해서
  // 이거를 해서 → 어디서든 GetIt.I<AppDatabase>()로 접근 가능하다
  // 이거는 이래서 → 데이터베이스를 전역으로 공유하고 중복 생성을 방지한다

  // ===================================================================
  // 4. 🎵 Insight Player 샘플 데이터 초기화 (Phase 1)
  // ===================================================================
  // 이거를 설정하고 → 앱 시작 시 샘플 인사이트 데이터를 자동 삽입해서
  // 이거를 해서 → 2025-10-18 날짜에 테스트용 인사이트를 제공한다
  await database.seedInsightData();

  // ===================================================================
  // 5. 초기 데이터 로드 (앱 시작 시 오늘 일정 확인)
  // ===================================================================
  final resp = await database.getSchedulesByDate(DateTime.now());

  // ===================================================================
  // 6. ✅ 샘플 데이터 생성 (Task, Habit 테스트용) - 비활성화
  // ===================================================================
  // 이거를 설정하고 → 앱 첫 실행 시 샘플 데이터를 생성해서
  // 이거를 해서 → TaskCard와 HabitCard UI를 바로 테스트할 수 있다
  // TODO: 실제 배포 시에는 이 코드를 제거하거나 디버그 모드에서만 실행
  // try {
  //   await SampleDataHelper.createAllSampleData(database);
  // } catch (e) {
  //   print('⚠️ [main.dart] 샘플 데이터 생성 실패 (이미 존재할 수 있음): $e');
  // }

  // ===================================================================
  // 🧪 오늘 날짜 테스트 데이터 추가 (동적 일정 개수 테스트용) - 비활성화
  // ===================================================================
  // 이거를 설정하고 → 오늘 날짜에 5개의 테스트 일정을 추가해서
  // 이거를 해서 → 셀 높이 기반 동적 일정 개수 계산을 테스트한다
  // try {
  //   await SampleDataHelper.createTodayTestSchedules(database);
  //   print('✅ [main.dart] 오늘 날짜 테스트 일정 5개 추가 완료');
  // } catch (e) {
  //   print('⚠️ [main.dart] 오늘 날짜 테스트 일정 추가 실패: $e');
  // }

  // ===================================================================
  // 7. 앱 재실행 시 임시 캐시 초기화 (제목 제외)
  // ===================================================================
  // 이거를 설정하고 → 앱 시작 시 임시 입력 캐시를 삭제해서
  // 이거를 해서 → 색상, 날짜, 반복 규칙, 리마인더가 초기화된다
  // 이거는 이래서 → 사용자가 앱을 새로 열 때마다 깨끗한 상태로 시작한다
  await TempInputCache.clearTempInput();
  await TempInputCache.clearAllUnifiedCache(); // 통합 캐시도 초기화 (제목 제외)

  // ===================================================================
  // 8. 앱 실행
  // ===================================================================
  runApp(const CalendarSchedulerApp());
}

// ===================================================================
// ⭐️ Calendar Scheduler App: 앱의 루트 위젯
// ===================================================================
// 이거를 설정하고 → MaterialApp에 중앙화된 라우트 시스템을 적용해서
// 이거를 해서 → 모든 화면 전환을 일관되게 관리한다
// 이거는 이래서 → 코드 유지보수가 쉽고 라우트 추가/변경이 간단하다

class CalendarSchedulerApp extends StatelessWidget {
  const CalendarSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Riverpod ProviderScope로 전체 앱 감싸기
    return ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
            create: (_) => BottomSheetController(),
          ),
          provider.ChangeNotifierProvider(
            create: (_) => ScheduleFormController(),
          ),
          provider.ChangeNotifierProvider(create: (_) => TaskFormController()),
          provider.ChangeNotifierProvider(create: (_) => HabitFormController()),
          // ✅ ImageAnalysisProvider 추가
          provider.ChangeNotifierProvider(
            create: (_) => ImageAnalysisProvider(),
          ),
        ],
        child: MaterialApp(
          // ===================================================================
          // 앱 기본 설정
          // ===================================================================
          title: 'Calendar Scheduler',
          theme: ThemeData(
            fontFamily: 'Gmarket Sans',
            // ===================================================================
            // ⭐️ Wolt Modal Sheet 테마 적용
            // ===================================================================
            extensions: [WoltAppTheme.theme],
            // 이거를 설정하고 → WoltModalSheetThemeData를 ThemeData extension에 추가해서
            // 이거를 해서 → 모든 WoltModalSheet가 일관된 디자인 스타일을 사용한다
            // 이거는 이래서 → Figma 디자인 토큰이 전역적으로 적용된다
            // 이거라면 → 바텀시트 스타일 변경 시 wolt_theme.dart만 수정하면 된다
          ),

          // ===================================================================
          // ⭐️ 키보드 높이 유지 + 드래그 앤 드롭 활성화
          // ===================================================================
          builder: (context, child) => DropRegion(
            formats: Formats.standardFormats,
            onDropOver: (event) => DropOperation.none, // 최상위에서는 반응 안 함
            onPerformDrop: (event) async {
              // 최상위에서는 드롭을 처리하지 않음 (하위 DropRegion이 처리)
            },
            child: PersistentKeyboardHeightProvider(child: child!),
          ),
          // 이거를 설정하고 → DropRegion으로 전체 앱을 감싸서
          // 이거를 해서 → 모든 화면에서 드래그 앤 드롭이 작동한다
          // 이거는 이래서 → 인박스 바텀시트에서 디테일뷰로 드래그가 가능하다
          // 이거를 설정하고 → 키보드 높이를 자동으로 측정하고 저장해서
          // 이거를 해서 → 키보드가 내려가도 그 높이를 유지한다
          // 이거는 이래서 → 追加 버튼 클릭 시 입력창이 고정된 위치에 유지된다

          // ===================================================================
          // ⭐️ 라우트 중앙화: 모든 화면 전환을 한 곳에서 관리
          // ===================================================================
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          // 이거를 설정하고 → AppRoutes의 onGenerateRoute를 사용해서
          // 이거를 해서 → 라우트 이름으로 화면을 생성하고 애니메이션을 적용한다
          // 이거는 이래서 → Navigator.pushNamed()만으로 모든 화면 전환이 가능하다
          // 이거라면 → 라우트 경로를 수정할 때 app_routes.dart만 변경하면 된다

          // ===================================================================
          // 디버그 배너 제거 (릴리즈 빌드 시)
          // ===================================================================
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
