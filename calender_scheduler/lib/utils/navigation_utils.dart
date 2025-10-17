import 'package:flutter/material.dart';
import '../screen/date_detail_view.dart';
import 'animation_utils.dart';

/// 네비게이션 관련 유틸리티 함수들을 모아놓은 클래스
/// 화면 전환과 라우팅을 중앙화해서 관리한다
class NavigationUtils {
  // DateDetailView로 전환하는 함수 - 선택된 날짜의 스케줄을 표시한다 (DB 스트림 기반)
  static Future<void> navigateToDateDetail({
    required BuildContext context, // 현재 컨텍스트를 받는다
    required DateTime selectedDate, // 선택된 날짜를 받는다
  }) async {
    // DateDetailView로 전환하고 결과를 받는다
    await Navigator.of(context).push(
      AnimationUtils.createPageRoute(
        // 애니메이션 효과를 적용한 페이지 라우트를 생성한다
        page: DateDetailView(
          selectedDate: selectedDate, // 선택된 날짜를 전달한다
        ),
        duration: const Duration(milliseconds: 300), // 애니메이션 지속시간을 300ms로 설정한다
        curve: Curves.easeInOut, // 부드러운 커브를 적용한다
      ),
    );
  }

  // 뒤로가기 함수 - 이전 화면으로 돌아간다
  static void goBack(BuildContext context) {
    Navigator.of(context).pop(); // 이전 화면으로 돌아간다
  }

  // 루트로 돌아가는 함수 - 메인 화면으로 돌아간다
  static void goToRoot(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/', // 루트 경로로 이동한다
      (route) => false, // 모든 이전 라우트를 제거한다
    );
  }

  // 모달 바텀시트를 표시하는 함수 - 하단에서 올라오는 시트를 표시한다
  static Future<T?> showCustomModalBottomSheet<T>({
    required BuildContext context, // 현재 컨텍스트를 받는다
    required Widget child, // 표시할 위젯을 받는다
    bool isDismissible = true, // 외부 탭으로 닫을 수 있는지 설정한다
    bool enableDrag = true, // 드래그로 닫을 수 있는지 설정한다
  }) {
    return showModalBottomSheet<T>(
      // 모달 바텀시트를 표시한다
      context: context, // 컨텍스트를 설정한다
      isDismissible: isDismissible, // 외부 탭으로 닫을 수 있는지 설정한다
      enableDrag: enableDrag, // 드래그로 닫을 수 있는지 설정한다
      backgroundColor: Colors.transparent, // 배경을 투명하게 설정한다
      builder: (context) => child, // 표시할 위젯을 설정한다
    );
  }

  // 다이얼로그를 표시하는 함수 - 확인/취소 다이얼로그를 표시한다
  static Future<bool?> showConfirmDialog({
    required BuildContext context, // 현재 컨텍스트를 받는다
    required String title, // 다이얼로그 제목을 받는다
    required String content, // 다이얼로그 내용을 받는다
    String confirmText = '확인', // 확인 버튼 텍스트를 받는다
    String cancelText = '취소', // 취소 버튼 텍스트를 받는다
  }) {
    return showDialog<bool>(
      // 다이얼로그를 표시한다
      context: context, // 컨텍스트를 설정한다
      builder: (context) => AlertDialog(
        // 알림 다이얼로그를 생성한다
        title: Text(title), // 제목을 설정한다
        content: Text(content), // 내용을 설정한다
        actions: [
          // 액션 버튼들을 설정한다
          TextButton(
            // 취소 버튼을 생성한다
            onPressed: () =>
                Navigator.of(context).pop(false), // false를 반환하고 닫는다
            child: Text(cancelText), // 취소 텍스트를 설정한다
          ),
          TextButton(
            // 확인 버튼을 생성한다
            onPressed: () => Navigator.of(context).pop(true), // true를 반환하고 닫는다
            child: Text(confirmText), // 확인 텍스트를 설정한다
          ),
        ],
      ),
    );
  }
}
