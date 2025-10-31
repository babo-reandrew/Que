import 'package:flutter/material.dart';
import '../screen/home_screen.dart';
import '../screen/date_detail_view.dart';
import '../screen/image_extraction_screen.dart'; // ✅ 추가
import '../screen/gemini_test_screen.dart'; // ✅ 테스트 화면
// ✅ OpenContainer 마이그레이션으로 AppleExpansionRoute 제거

// ===================================================================
// ⭐️ App Routes: 중앙화된 라우트 관리
// ===================================================================
// 이거를 설정하고 → 모든 라우트를 한 곳에서 정의하고 관리해서
// 이거를 해서 → 어디서든 일관된 방식으로 화면 전환을 할 수 있다
// 이거는 이래서 → 라우트 경로를 수정할 때 한 곳만 바꾸면 된다
// 이거라면 → 코드 유지보수가 쉽고 버그가 줄어든다

class AppRoutes {
  // ===================================================================
  // 라우트 경로 상수
  // ===================================================================
  // 이거를 설정하고 → 모든 라우트 경로를 상수로 정의해서
  // 이거를 해서 → 오타나 경로 변경 시 발생하는 오류를 방지한다

  static const String home = '/';
  static const String dateDetail = '/date-detail';
  static const String imageExtraction = '/image-extraction'; // ✅ 추가
  static const String geminiTest = '/gemini-test'; // ✅ 테스트 화면

  // ===================================================================
  // 라우트 생성 함수
  // ===================================================================

  /// 라우트 이름과 인자를 받아서 적절한 화면을 반환한다
  /// 이거를 설정하고 → RouteSettings에서 이름과 인자를 추출해서
  /// 이거를 해서 → 해당하는 화면과 애니메이션을 적용한 Route를 반환한다
  /// 이거는 이래서 → Navigator.pushNamed()로 간단하게 화면 전환이 가능하다
  /// 이거라면 → 모든 화면 전환이 일관된 애니메이션으로 동작한다
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {

    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case dateDetail:
        // ✅ OpenContainer 마이그레이션으로 이 라우트는 더 이상 사용되지 않음
        // OpenContainer가 HomeScreen 셀에서 직접 DateDetailView를 열기 때문에
        // Navigator.pushNamed가 아닌 OpenContainer의 내부 라우팅 사용
        final args = settings.arguments;

        if (args is DateTime) {
          // ⚠️ 이 코드는 레거시 호환성을 위해 남겨둠 (직접 호출 시)
          return MaterialPageRoute(
            builder: (_) => DateDetailView(selectedDate: args),
            settings: settings,
          );
        } else {
          return _errorRoute('날짜 정보가 올바르지 않습니다.');
        }

      case imageExtraction:
        return MaterialPageRoute(
          builder: (_) => const ImageExtractionScreen(),
          settings: settings,
        );

      case geminiTest:
        return MaterialPageRoute(
          builder: (_) => const GeminiTestScreen(),
          settings: settings,
        );

      default:
        return _errorRoute('존재하지 않는 화면입니다.');
    }
  }

  /// 에러 화면을 표시하는 라우트를 생성한다
  /// 이거를 설정하고 → 잘못된 라우트 요청 시 에러 메시지를 표시해서
  /// 이거를 해서 → 사용자에게 무엇이 잘못되었는지 알려준다
  /// 이거는 이래서 → 앱이 크래시되지 않고 안정적으로 동작한다
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('エラー')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('戻る'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================================================================
  // 편의 함수: 네비게이션 헬퍼
  // ===================================================================

  /// HomeScreen으로 이동한다
  static Future<void> toHome(BuildContext context, {bool clearStack = false}) {

    if (clearStack) {
      // 이거를 설정하고 → 네비게이션 스택을 전부 지우고
      // 이거를 해서 → 뒤로가기를 눌러도 이전 화면으로 돌아가지 않는다
      return Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(home, (route) => false);
    } else {
      return Navigator.of(context).pushNamed(home);
    }
  }

  /// DateDetailView로 이동한다
  static Future<void> toDateDetail(
    BuildContext context,
    DateTime selectedDate,
  ) {

    return Navigator.of(context).pushNamed(dateDetail, arguments: selectedDate);
  }

  /// 이전 화면으로 돌아간다
  static void goBack(BuildContext context, {dynamic result}) {
    Navigator.of(context).pop(result);
  }

  /// 현재 화면이 특정 라우트인지 확인한다
  static bool isCurrentRoute(BuildContext context, String routeName) {
    final currentRoute = ModalRoute.of(context);
    return currentRoute?.settings.name == routeName;
  }
}

// ===================================================================
// ⭐️ Route Names Extension: BuildContext에서 직접 라우트 이름 접근
// ===================================================================
// 이거를 설정하고 → BuildContext에 extension을 추가해서
// 이거를 해서 → context.routeName으로 현재 라우트를 확인할 수 있다
// 이거는 이래서 → 코드가 간결해지고 가독성이 높아진다

extension RouteExtension on BuildContext {
  /// 현재 라우트 이름을 반환한다
  String? get routeName => ModalRoute.of(this)?.settings.name;

  /// 현재 라우트가 HomeScreen인지 확인한다
  bool get isHome => routeName == AppRoutes.home;

  /// 현재 라우트가 DateDetailView인지 확인한다
  bool get isDateDetail => routeName == AppRoutes.dateDetail;
}
