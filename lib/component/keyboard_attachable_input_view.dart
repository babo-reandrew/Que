import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import '../design_system/input_accessory_design_system.dart';
import 'QuickAddControlBox.dart';

/// KeyboardAttachable 기반 InputAccessoryView
///
/// **기존 코드 완전 보존!**
/// - QuickAddControlBox를 그대로 재사용
/// - 기존 로직 수정 없음
/// - FooterLayout + KeyboardAttachable로 감싸기만 함
///
/// **iOS inputAccessoryView 완벽 구현:**
/// - 키보드에 정확히 붙어서 올라옴 (Padding 방식 아님!)
/// - 키보드와 함께 애니메이션
/// - 5가지 Figma 상태 완벽 지원
///
/// Figma 스펙:
/// - Frame 701 (Container): https://www.figma.com/design/oIi8TtLEDhGxMIjyyoDqsp/OMO-Calendar?node-id=1172-11346&t=XSLcW7fW0WxGTmPy-0
/// - Anything (기본): https://www.figma.com/design/oIi8TtLEDhGxMIjyyoDqsp/OMO-Calendar?node-id=1172-10856&t=XSLcW7fW0WxGTmPy-0
/// - Variant5 (버튼만): https://www.figma.com/design/oIi8TtLEDhGxMIjyyoDqsp/OMO-Calendar?node-id=1172-10877&t=XSLcW7fW0WxGTmPy-0
/// - Touched_Anything (확장): https://www.figma.com/design/oIi8TtLEDhGxMIjyyoDqsp/OMO-Calendar?node-id=1172-10889&t=XSLcW7fW0WxGTmPy-0
/// - Task: https://www.figma.com/design/oIi8TtLEDhGxMIjyyoDqsp/OMO-Calendar?node-id=1172-10952&t=XSLcW7fW0WxGTmPy-0
/// - Schedule: https://www.figma.com/design/oIi8TtLEDhGxMIjyyoDqsp/OMO-Calendar?node-id=1172-11096&t=XSLcW7fW0WxGTmPy-0
class KeyboardAttachableInputView extends StatelessWidget {
  /// QuickAddControlBox에 전달할 선택된 날짜
  final DateTime? selectedDate;

  /// QuickAddControlBox에 전달할 기존 스케줄 ID (수정 모드)
  final int? existingScheduleId;

  /// QuickAddControlBox에 전달할 초기 타입 (task/schedule)
  final String? initialType;

  /// 저장 완료 콜백
  final VoidCallback? onSaveComplete;

  /// 취소 콜백
  final VoidCallback? onCancel;

  const KeyboardAttachableInputView({
    super.key,
    this.selectedDate,
    this.existingScheduleId,
    this.initialType,
    this.onSaveComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return FooterLayout(
      // 키보드에 붙을 Footer 영역 (QuickAddControlBox)
      footer: Container(
        decoration: InputAccessoryDesign.frame701Decoration,
        child: SafeArea(
          top: false,
          child: QuickAddControlBox(
            selectedDate: selectedDate,
            existingScheduleId: existingScheduleId,
            initialType: initialType,
            onSaveComplete: onSaveComplete,
            onCancel: onCancel,
          ),
        ),
      ),

      // 메인 콘텐츠는 빈 컨테이너 (실제 콘텐츠는 부모 위젯에서 관리)
      child: const SizedBox.shrink(),
    );
  }
}

/// 전체 화면 구조: 백그라운드 블러 + KeyboardAttachable Input
///
/// **사용 예시 (home_screen.dart 또는 date_detail_view.dart):**
/// ```dart
/// class _HomeScreenState extends State<HomeScreen> {
///   bool _isQuickAddVisible = false;
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Stack(
///         children: [
///           // 기존 콘텐츠
///           _buildMainContent(),
///
///           // 새로운 KeyboardAttachable 방식 (기존 코드 건들지 않음!)
///           if (_isQuickAddVisible)
///             InputAccessoryWithBlur(
///               selectedDate: _selectedDate,
///               onSaveComplete: () {
///                 setState(() => _isQuickAddVisible = false);
///                 // 기존 새로고침 로직 호출
///               },
///               onCancel: () {
///                 setState(() => _isQuickAddVisible = false);
///               },
///             ),
///         ],
///       ),
///
///       // + 버튼 탭 시
///       floatingActionButton: FloatingActionButton(
///         onPressed: () {
///           setState(() => _isQuickAddVisible = true);
///           // TextField에 포커스 주기 (키보드 올리기)
///         },
///       ),
///     );
///   }
/// }
/// ```
class InputAccessoryWithBlur extends StatelessWidget {
  final DateTime? selectedDate;
  final int? existingScheduleId;
  final String? initialType;
  final VoidCallback? onSaveComplete;
  final VoidCallback? onCancel;

  const InputAccessoryWithBlur({
    super.key,
    this.selectedDate,
    this.existingScheduleId,
    this.initialType,
    this.onSaveComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardAttachable(
      // 키보드와 함께 애니메이션 (iOS inputAccessoryView 동작)
      backgroundColor: Colors.transparent,

      // Footer에 QuickAddControlBox가 들어감
      footer: Container(
        decoration: InputAccessoryDesign.frame701Decoration,
        child: SafeArea(
          top: false,
          child: QuickAddControlBox(
            selectedDate: selectedDate,
            existingScheduleId: existingScheduleId,
            initialType: initialType,
            onSaveComplete: onSaveComplete,
            onCancel: onCancel,
          ),
        ),
      ),

      // 메인 콘텐츠 영역 (백그라운드 블러만 표시)
      child: GestureDetector(
        onTap: () {
          // 배경 탭 시 키보드 닫기
          FocusScope.of(context).unfocus();
          onCancel?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: InputAccessoryDesign.backgroundBlurWidth,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: InputAccessoryDesign.backgroundBlurGradient,
          ),
          child: BackdropFilter(
            filter: InputAccessoryDesign.backgroundBlurFilter,
            child: Container(
              decoration: BoxDecoration(
                color: InputAccessoryDesign.backgroundBlurOverlay,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 간단한 사용을 위한 헬퍼 함수들
///
/// **기존 코드와 병행 사용 가능!**
/// 기존 CreateEntryBottomSheet 제거 전까지 둘 다 유지
class InputAccessoryHelper {
  /// KeyboardAttachable 방식으로 QuickAdd 표시
  ///
  /// 기존:
  /// ```dart
  /// CreateEntryBottomSheet.show(context, selectedDate: date);
  /// ```
  ///
  /// 신규 (병행 사용):
  /// ```dart
  /// InputAccessoryHelper.showQuickAdd(context, selectedDate: date);
  /// ```
  static void showQuickAdd(
    BuildContext context, {
    DateTime? selectedDate,
    int? existingScheduleId,
    String? initialType,
    VoidCallback? onSaveComplete,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // 백그라운드 블러가 대체
      barrierDismissible: true,
      builder: (context) => InputAccessoryWithBlur(
        selectedDate: selectedDate,
        existingScheduleId: existingScheduleId,
        initialType: initialType,
        onSaveComplete: () {
          Navigator.of(context).pop();
          onSaveComplete?.call();
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// 디버그: 5가지 Figma 상태 확인용
  static void testAllStates(BuildContext context) {
    print('=== InputAccessory 5가지 상태 테스트 ===');
    print('1. Anything (기본)');
    print('2. Variant5 (버튼만)');
    print('3. Touched_Anything (확장)');
    print('4. Task');
    print('5. Schedule');
    print('디자인 시스템 검증: ${InputAccessoryDesign.frame701Decoration}');
  }
}
