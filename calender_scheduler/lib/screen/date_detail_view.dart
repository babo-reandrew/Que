import 'dart:async'; // ✅ Timer 추가
import 'dart:ui' show ImageFilter; // ✅ Backdrop Blur
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // ✅ GestureRecognizer 추가
import 'package:flutter/services.dart'; // ✅ HapticFeedback
import 'package:intl/intl.dart'; // ✅ DateFormat for 요일
import 'package:smooth_sheets/smooth_sheets.dart'; // ✅ smooth_sheets 추가
import 'package:animated_reorderable_list/animated_reorderable_list.dart'; // 🆕 드래그 재정렬
import 'package:flutter_svg/flutter_svg.dart'; // ✅ SVG 아이콘 추가
import 'package:flutter_slidable/flutter_slidable.dart'; // ✅ Slidable 추가
import 'package:figma_squircle/figma_squircle.dart'; // ✅ Figma 스무싱 적용
import '../component/toast/action_toast.dart'; // ✅ 토스트 추가
import '../component/schedule_card.dart';
import '../component/create_entry_bottom_sheet.dart';
import '../component/slidable_schedule_card.dart'; // ✅ Slidable 컴포넌트 추가
import '../component/modal/option_setting_wolt_modal.dart'; // ✅ OptionSetting Wolt 모달 (Detached)
import '../component/modal/schedule_detail_wolt_modal.dart'; // ✅ 일정 상세 Wolt 모달
import '../component/modal/task_detail_wolt_modal.dart'; // ✅ 할일 상세 Wolt 모달
import '../component/modal/habit_detail_wolt_modal.dart'; // ✅ 습관 상세 Wolt 모달
import '../component/modal/image_picker_smooth_sheet.dart'; // ✅ 이미지 선택 Smooth Sheet 모달
import '../component/modal/task_inbox_bottom_sheet.dart'; // 📋 Task Inbox 바텀시트 추가
import '../widgets/bottom_navigation_bar.dart'; // ✅ 하단 네비게이션 바 추가
import '../widgets/date_detail_header.dart'; // ✅ 날짜 헤더 위젯 추가
import '../widgets/task_inbox_top_bar.dart'; // 📋 Task Inbox TopBar 추가 (일간뷰용)
import '../widgets/task_card.dart'; // ✅ TaskCard 추가
import '../widgets/habit_card.dart'; // ✅ HabitCard 추가
import '../widgets/slidable_task_card.dart'; // ✅ SlidableTaskCard 추가
import '../widgets/slidable_habit_card.dart'; // ✅ SlidableHabitCard 추가
import '../widgets/dashed_divider.dart'; // ✅ DashedDivider 추가
import '../Database/schedule_database.dart';
import '../model/unified_list_item.dart'; // 🆕 통합 리스트 아이템 모델
import 'package:get_it/get_it.dart';

/// 선택된 날짜의 상세 스케줄을 리스트 형태로 표시하는 화면
/// ⭐️ DB 통합: StreamBuilder를 사용해서 해당 날짜의 일정을 실시간으로 관찰한다
/// 이거를 설정하고 → watchByDay()로 DB 스트림을 구독해서
/// 이거를 해서 → 일정이 추가/삭제될 때마다 자동으로 UI가 갱신된다
/// 이거는 이래서 → setState 없이도 실시간 반영이 가능하다
/// ✅ StatefulWidget 전환: 좌우 스와이프 및 Pull-to-dismiss 기능을 위해 상태 관리 필요
class DateDetailView extends StatefulWidget {
  final DateTime selectedDate; // 선택된 날짜를 저장하는 변수
  final Function(DateTime)? onClose; // 🚀 Pull-to-dismiss 완료 시 날짜 전달 콜백
  final bool isInboxMode; // 📋 인박스 모드 여부
  final Function(bool)? onInboxModeChanged; // 📋 인박스 모드 변경 콜백
  final Function(bool)? onPickerStateChanged; // 🗓️ 날짜 피커 상태 변경 콜백

  const DateDetailView({
    super.key,
    required this.selectedDate, // 선택된 날짜를 필수로 받는다
    this.onClose, // ✅ 상태 업데이트용 콜백
    this.isInboxMode = false, // 기본값: false (일반 모드)
    this.onInboxModeChanged, // 📋 인박스 모드 변경 콜백
    this.onPickerStateChanged, // 🗓️ 날짜 피커 상태 변경 콜백
  });

  @override
  State<DateDetailView> createState() => _DateDetailViewState();
}

class _DateDetailViewState extends State<DateDetailView>
    with TickerProviderStateMixin {
  late DateTime _currentDate; // 현재 표시 중인 날짜 (좌우 스와이프로 변경됨)
  late PageController _pageController; // 좌우 스와이프를 위한 PageController
  late ScrollController _scrollController; // ✅ 리스트 스크롤 제어용
  // ⚠️ 모든 애니메이션 컨트롤러 제거
  // late AnimationController _dismissController;
  // late AnimationController _entryController;
  // late Animation<double> _entryScaleAnimation;
  double _dragOffset = 0.0; // Pull-to-dismiss를 위한 드래그 오프셋

  // 📋 인박스 모드 상태 (내부에서 변경 가능)
  late bool _isInboxMode;
  bool _showInboxOverlay = false; // 📋 인박스 오버레이 표시 여부
  bool _isDraggingFromInbox = false; // 🎯 인박스에서 드래그 중인지 여부
  int? _hoveredCardIndex; // 🎯 현재 호버 중인 카드의 인덱스 (드롭존 표시용)

  // 🚫 Divider 제약을 위한 변수
  bool _isReorderingScheduleBelowDivider = false; // 일정이 divider 아래로 이동 시도 중

  // 🎯 바텀시트 열림 추적 (DateDetailView 드래그 제스처 비활성화용)
  bool _isBottomSheetOpen = false;

  // ⏱️ DB 저장 디바운스를 위한 타이머
  Timer? _saveOrderDebounceTimer;

  // 📄 페이지네이션 변수 (향후 구현용 - 현재 미사용)
  // static const int _pageSize = 20;
  // int _currentTaskOffset = 0;
  // int _currentHabitOffset = 0;

  // 무한 스크롤을 위한 중앙 인덱스 (충분히 큰 수)
  static const int _centerIndex = 1000000;

  // 🎯 Future 캐시: FutureBuilder rebuild 시 중복 호출 방지
  final Map<String, Future<List<UnifiedListItem>>> _itemListCache = {};

  // 🎯 자동 스크롤을 위한 BuildContext 캐시
  BuildContext? _scrollableContext;

  // 🔔 onClose 콜백 호출 여부 플래그 (중복 호출 방지)
  bool _onCloseCalled = false;

  // 🎯 오버스크롤 최대값 기록 (pull-to-dismiss용)
  double _maxOverscrollOffset = 0;

  // 🎯 임계값 초과 플래그 (bounce-back 방지용)
  bool _shouldDismissOnScrollEnd = false;

  // 🎯 Elevation Overlay: 스크롤 오프셋 추적 (iOS Settings 스타일)
  double _scrollOffset = 0.0;

  // 🗓️ 날짜 피커 표시 상태
  bool _showDatePicker = false;
  late AnimationController _datePickerAnimationController;

  // 🖼️ 이미지 피커 표시 상태 (DismissiblePage 비활성화용)
  bool _showImagePicker = false;

  // ✅ 완료 섹션 상태 관리
  bool _isCompletedExpanded = false; // 완료 섹션 확장 여부
  late AnimationController _completedExpandController; // 완료 섹션 애니메이션 컨트롤러
  late Animation<double> _completedExpandAnimation; // 완료 섹션 확장 애니메이션

  @override
  void initState() {
    super.initState();
    print('');
    print('╔═══════════════════════════════════════════════════════════════╗');
    print('║  🚀 [LIFECYCLE] DateDetailView.initState()                   ║');
    print('╚═══════════════════════════════════════════════════════════════╝');
    // 이거를 설정하고 → 기존 selectedDate를 현재 날짜로 초기화해서
    _currentDate = widget.selectedDate;
    print('� 초기 날짜: $_currentDate');
    // 📋 인박스 모드 초기화
    _isInboxMode = widget.isInboxMode;
    print('📋 인박스 모드: $_isInboxMode');
    print('📊 _showInboxOverlay: $_showInboxOverlay');
    print('🎯 _isDraggingFromInbox: $_isDraggingFromInbox');
    // 이거를 해서 → 무한 스크롤을 위한 PageController 생성한다 (중앙 인덱스부터 시작)
    _pageController = PageController(initialPage: _centerIndex);
    // ✅ 리스트 스크롤 컨트롤러 초기화 (리스트 최상단 감지용)
    _scrollController = ScrollController();

    // 📄 페이지네이션: 스크롤 리스너 추가 (하단 도달 시 다음 페이지 로드)
    _scrollController.addListener(_onScroll);

    // ⚠️ 모든 애니메이션 컨트롤러 제거 - Hero만 사용
    // _dismissController = AnimationController.unbounded(vsync: this)
    //   ..addListener(() {
    //     setState(() {
    //       // SpringSimulation 값이 dragOffset에 반영됨
    //     });
    //   });

    // _entryController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 520),
    // );

    // _entryScaleAnimation =
    //     Tween<double>(
    //       begin: 0.95,
    //       end: 1.0,
    //     ).animate(
    //       CurvedAnimation(
    //         parent: _entryController,
    //         curve: const Cubic(
    //           0.05,
    //           0.7,
    //           0.1,
    //           1.0,
    //         ),
    //       ),
    //     );

    // 진입 애니메이션 시작
    // _entryController.forward();

    // ✅ 완료 섹션 애니메이션 컨트롤러 초기화 (iOS 스타일 강조 애니메이션)
    _completedExpandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // 더 부드러운 애니메이션
    );

    _completedExpandAnimation = CurvedAnimation(
      parent: _completedExpandController,
      curve: Curves.easeInOutCubicEmphasized, // iOS 스타일 강조 곡선
    );

    // 🗓️ 날짜 피커 애니메이션 컨트롤러 초기화
    // 월뷰(200px)와 체감 속도를 맞추기 위해 높이에 비례하여 duration 조정
    _datePickerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // 280px + statusBar ≈ 1.7배 높이
    );

    print('✅ [LIFECYCLE] initState 완료');
    print('');
  }

  @override
  void dispose() {
    print('');
    print('╔═══════════════════════════════════════════════════════════════╗');
    print('║  �️ [LIFECYCLE] DateDetailView.dispose()                     ║');
    print('╚═══════════════════════════════════════════════════════════════╝');
    // 이거를 설정하고 → 메모리 누수 방지를 위해 컨트롤러 정리
    print('� 마지막 날짜: $_currentDate');
    print('📅 초기 날짜: ${widget.selectedDate}');
    print('🔄 날짜 변경됨: ${_currentDate != widget.selectedDate}');
    print('🔔 onClose 이미 호출됨: $_onCloseCalled');
    print('📋 _isInboxMode: $_isInboxMode');
    print('📊 _showInboxOverlay: $_showInboxOverlay');
    print('🎯 _isDraggingFromInbox: $_isDraggingFromInbox');

    // ✅ dispose 시에도 onClose 콜백 호출 (배경 탭으로 닫힐 때를 위해)
    // 단, 이미 호출되지 않았고, 날짜가 변경된 경우에만 호출
    if (widget.onClose != null &&
        !_onCloseCalled &&
        _currentDate != widget.selectedDate) {
      print('🔔 onClose 콜백 호출 - 마지막 날짜: $_currentDate');
      widget.onClose!(_currentDate);
    } else if (_onCloseCalled) {
      print('ℹ️ onClose 이미 호출됨 - 중복 호출 방지');
    } else if (_currentDate == widget.selectedDate) {
      print('ℹ️ 날짜 변경 없음 - onClose 호출 안 함');
    }

    print('✅ [LIFECYCLE] dispose 완료');
    print('');

    _pageController.dispose();
    _scrollController.dispose(); // ✅ ScrollController도 정리
    // _dismissController.dispose(); // ⚠️ 제거됨
    // _entryController.dispose(); // ⚠️ 제거됨
    _completedExpandController.dispose(); // ✅ 완료 섹션 애니메이션 컨트롤러 정리
    _datePickerAnimationController.dispose(); // 🗓️ 날짜 피커 애니메이션 컨트롤러 정리
    _saveOrderDebounceTimer?.cancel(); // ⏱️ 디바운스 타이머 정리
    print('🗑️ [DateDetailView] 리소스 정리 완료');
    super.dispose();
  }

  // 이거를 설정하고 → 인덱스를 실제 날짜로 변환하는 함수
  // 이거를 해서 → 중앙 인덱스 기준으로 상대적 날짜를 계산한다
  DateTime _getDateForIndex(int index) {
    final daysDiff = index - _centerIndex;
    return widget.selectedDate.add(Duration(days: daysDiff));
  }

  /// 📄 스크롤 리스너: 하단 도달 시 다음 페이지 로드
  /// 이거를 설정하고 → 스크롤이 하단에 도달하면 감지해서
  /// 이거를 해서 → offset을 증가시켜 다음 페이지를 로드하고
  /// 이거는 이래서 → 무한 스크롤이 가능하다
  /// ⚠️ 현재 미사용 - 페이지네이션 구현 시 활성화
  void _onScroll() {
    // 📄 페이지네이션 미구현 - 필요시 활성화
    /*
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 하단 200px 이전에 다음 페이지 로드 시작
      print('📄 [Pagination] 하단 도달 → 다음 페이지 로드');
      setState(() {
        _currentTaskOffset += _pageSize;
        _currentHabitOffset += _pageSize;
      });
    }
    */

    // 🎯 Pull-to-dismiss: 오버스크롤 감지
    if (!_scrollController.hasClients) return;

    // 📋 인박스 모드에서는 pull-to-dismiss 차단
    if (_isInboxMode) return;

    final pixels = _scrollController.position.pixels;

    // 🎯 최상단에서 오버스크롤 중 (pixels < 0)
    if (pixels < 0) {
      const sensitivity = 3.0; // 민감도 증폭
      final amplifiedOffset = pixels.abs() * sensitivity;

      // 🎯 최대값 기록 (가장 많이 당긴 거리)
      if (amplifiedOffset > _maxOverscrollOffset) {
        _maxOverscrollOffset = amplifiedOffset;
      }

      debugPrint(
        '🎯 [_onScroll] 오버스크롤 감지! pixels=$pixels → dragOffset=$amplifiedOffset (max=$_maxOverscrollOffset)',
      );

      setState(() {
        _dragOffset = amplifiedOffset;
      });
    }
    // ⚠️ pixels >= 0일 때는 _onScroll에서 처리하지 않음!
    // ScrollEndNotification에서 처리됨
  }

  /// 🎯 드래그 시 자동 스크롤은 super_drag_and_drop에서 자동 처리됨
  // void _handleAutoScroll(double globalY, BuildContext dragContext) { ... }

  @override
  Widget build(BuildContext context) {
    print('');
    print('╔═══════════════════════════════════════════════════════════════╗');
    print('║  🏗️ [BUILD] DateDetailView.build()                          ║');
    print('╚═══════════════════════════════════════════════════════════════╝');
    print('📋 _isInboxMode: $_isInboxMode');
    print('📊 _showInboxOverlay: $_showInboxOverlay');
    print('🎯 _isDraggingFromInbox: $_isDraggingFromInbox');
    print('🔒 _isBottomSheetOpen: $_isBottomSheetOpen');
    // ⚠️ DismissiblePage가 자체적으로 Hero를 처리하므로 여기서는 Hero 제거
    // ✅ Material로만 감싸서 반환

    return Material(
      type: MaterialType.transparency,
      color: Colors.transparent,
      child: Stack(
        children: [
          // 🎯 메인 Scaffold
          Scaffold(
            appBar: _buildAppBar(context),
            backgroundColor: const Color(0xFFF7F7F7),
            resizeToAvoidBottomInset: false,
            body: _buildPageView(),
            // ✅ 하단 네비게이션 바 추가 (피그마: Frame 822)
            bottomNavigationBar: _isInboxMode
                ? null // 📋 인박스 모드에서는 하단 네비 숨김
                : CustomBottomNavigationBar(
                    onInboxTap: () {
                      print('');
                      print(
                        '╔═══════════════════════════════════════════════════════════════╗',
                      );
                      print(
                        '║  📥 [INBOX TAP] 하단 네비 Inbox 버튼 클릭                  ║',
                      );
                      print(
                        '╚═══════════════════════════════════════════════════════════════╝',
                      );
                      print('⏰ 클릭 전 상태:');
                      print('   📋 _isInboxMode: $_isInboxMode');
                      print('   📊 _showInboxOverlay: $_showInboxOverlay');
                      print(
                        '   🎯 _isDraggingFromInbox: $_isDraggingFromInbox',
                      );
                      // 🎯 즉시 인박스 모드 활성화 + 오버레이 표시
                      setState(() {
                        _isInboxMode = true;
                        _showInboxOverlay = true;
                      });
                      widget.onInboxModeChanged?.call(true); // 📋 인박스 모드 활성화 알림
                      print('⏰ setState 후 상태:');
                      print('   📋 _isInboxMode: $_isInboxMode');
                      print('   📊 _showInboxOverlay: $_showInboxOverlay');
                      print('✅ 인박스 모드 활성화 완료 - Stack 렌더링 시작');
                      print('');
                    },
                    onImageAddTap: () {
                      print('🖼️ [하단 네비] 이미지 추가 버튼 클릭 → 이미지 선택 모달 오픈');
                      
                      // 🎯 이미지 피커 열기 전: DismissiblePage 비활성화
                      setState(() {
                        _showImagePicker = true;
                      });
                      widget.onPickerStateChanged?.call(true);
                      
                      Navigator.push(
                        context,
                        ModalSheetRoute(
                          barrierColor: const Color(0xFF656565).withOpacity(0.5), // 회색 배경
                          transitionDuration: const Duration(milliseconds: 200), // 빠른 닫힘
                          builder: (context) => ImagePickerSmoothSheet(
                            onClose: () {
                              Navigator.of(context).pop();
                            },
                            onImagesSelected: (selectedImages) {
                              print(
                                '✅ [DateDetailView] 선택된 이미지: ${selectedImages.length}개',
                              );
                              for (final img in selectedImages) {
                                print('   - 이미지 ID/path: ${img.idOrPath()}');
                              }
                            },
                          ),
                        ),
                      ).then((_) {
                        // 🎯 이미지 피커 닫힌 후: DismissiblePage 재활성화
                        if (mounted) {
                          setState(() {
                            _showImagePicker = false;
                          });
                          widget.onPickerStateChanged?.call(false);
                        }
                      });
                    },
                    onAddTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.transparent,
                        elevation: 0,
                        useSafeArea: false,
                        builder: (context) =>
                            CreateEntryBottomSheet(selectedDate: _currentDate),
                      );
                      print('➕ [디테일뷰 +버튼] QuickAdd 표시');
                    },
                  ),
          ), // Scaffold
          // �📋 인박스 모드 상단 TopBar
          if (_isInboxMode)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFFF7F7F7),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      TaskInboxDayTopBar(
                        date: _currentDate,
                        // 🎯 PageView의 네이티브 스와이프를 사용하므로 콜백 제거
                      ),
                      Positioned(
                        right: 24,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: TaskInboxCheckButton(
                            onClose: () {
                              setState(() {
                                _isInboxMode = false;
                                _showInboxOverlay = false;
                              });
                              widget.onInboxModeChanged?.call(
                                false,
                              ); // 📋 인박스 모드 비활성화 알림
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


          // 🗓️ 날짜 피커 오버레이 (AppBar 위로 렌더링)
          if (_showDatePicker)
            _buildDatePickerOverlay(),

          // 📋 인박스 오버레이 (바텀시트) - 조건부 표시
          if (_showInboxOverlay)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0, // 🎯 전체 화면을 덮도록 설정 (드래그 영역 확보)
              child: Builder(
                builder: (context) {
                  print('');
                  print(
                    '╔═══════════════════════════════════════════════════════════════╗',
                  );
                  print(
                    '║  📋 [BOTTOM SHEET] TaskInboxBottomSheet 렌더링 시작         ║',
                  );
                  print(
                    '╚═══════════════════════════════════════════════════════════════╝',
                  );
                  print('📊 _showInboxOverlay: $_showInboxOverlay');
                  print('🎯 _isDraggingFromInbox: $_isDraggingFromInbox');
                  print('📋 ValueKey: inbox_bottom_sheet');
                  return TaskInboxBottomSheet(
                    key: const ValueKey(
                      'inbox_bottom_sheet',
                    ), // 🔑 위젯 재사용을 위한 고유 키
                    isDraggingFromParent: _isDraggingFromInbox, // 🎯 드래그 상태 전달
                    isInboxMode: _isInboxMode, // 🎯 인박스 모드 전달 (월뷰로 드래그 비활성화)
                    onClose: () {
                      print('');
                      print(
                        '╔═══════════════════════════════════════════════════════════════╗',
                      );
                      print(
                        '║  ❌ [CLOSE CALLBACK] TaskInboxBottomSheet.onClose()        ║',
                      );
                      print(
                        '╚═══════════════════════════════════════════════════════════════╝',
                      );
                      print('⏰ 닫기 전 상태:');
                      print('   📋 _isInboxMode: $_isInboxMode');
                      print('   📊 _showInboxOverlay: $_showInboxOverlay');
                      setState(() {
                        _showInboxOverlay = false;
                        _isInboxMode = false;
                      });
                      widget.onInboxModeChanged?.call(
                        false,
                      ); // 📋 인박스 모드 비활성화 알림
                      print('⏰ setState 후 상태:');
                      print('   📋 _isInboxMode: $_isInboxMode');
                      print('   📊 _showInboxOverlay: $_showInboxOverlay');
                      print('✅ 바텀시트 닫기 완료');
                      print('');
                    },
                    onDragStart: () {
                      print('');
                      print(
                        '╔═══════════════════════════════════════════════════════════════╗',
                      );
                      print(
                        '║  🎯 [DRAG START] 드래그 시작 콜백                          ║',
                      );
                      print(
                        '╚═══════════════════════════════════════════════════════════════╝',
                      );
                      print('⏰ 드래그 시작 전 상태:');
                      print(
                        '   🎯 _isDraggingFromInbox: $_isDraggingFromInbox',
                      );
                      setState(() {
                        _isDraggingFromInbox = true;
                      });
                      print('⏰ setState 후 상태:');
                      print(
                        '   🎯 _isDraggingFromInbox: $_isDraggingFromInbox',
                      );
                      print('✅ 드래그 상태 활성화 완료');
                      print('');
                    },
                    onDragEnd: () {
                      print('');
                      print(
                        '╔═══════════════════════════════════════════════════════════════╗',
                      );
                      print(
                        '║  🎯 [DRAG END] 드래그 종료 콜백                            ║',
                      );
                      print(
                        '╚═══════════════════════════════════════════════════════════════╝',
                      );
                      print('⏰ 드래그 종료 전 상태:');
                      print(
                        '   🎯 _isDraggingFromInbox: $_isDraggingFromInbox',
                      );
                      // 🔥 드래그 종료 시 상태만 초기화 (바텀시트는 이미 표시 중)
                      setState(() {
                        _isDraggingFromInbox = false;
                      });
                      print('⏰ setState 후 상태:');
                      print(
                        '   🎯 _isDraggingFromInbox: $_isDraggingFromInbox',
                      );
                      print('✅ 드래그 상태 비활성화 완료 - 바텀시트 투명도 복구');
                      print('');
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ⚠️ Pull-to-dismiss 기능은 DismissiblePage가 처리
  // void _handleDragUpdate(...) → 삭제
  // void _handleDragEnd(...) → 삭제
  // void _runSpringAnimation(...) → 삭제

  // 날짜 피커 닫기 헬퍼 메서드
  void _closeDatePicker() {
    _datePickerAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showDatePicker = false;
        });
        // 🗓️ 부모에게 피커 닫힘 알림 (DismissiblePage 활성화)
        if (widget.onPickerStateChanged != null) {
          widget.onPickerStateChanged!(false);
        }
      }
    });
  }

  // 날짜 피커 오버레이 빌드
  Widget _buildDatePickerOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Stack(
        children: [
          // 배경 - 터치 시 피커 닫기
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDatePicker,
            ),
          ),
          // 피커 - 슬라이드 애니메이션
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _datePickerAnimationController,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              )),
              child: DatePickerModal(
                key: ValueKey('${_currentDate.year}-${_currentDate.month}-${_currentDate.day}'),
                initialDate: _currentDate,
                onDateChanged: (newDate) {
                  final daysDiff = newDate.difference(widget.selectedDate).inDays;
                  final targetIndex = _centerIndex + daysDiff;

                  _pageController.animateToPage(
                    targetIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                onClose: _closeDatePicker,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // ✅ PageView 구현 (좌우 스와이프 날짜 변경)
  // ========================================

  /// 이거를 설정하고 → PageView를 구성해서 좌우 스와이프 날짜 변경 기능 제공
  /// 이거를 해서 → 기존 Hero 구조를 그대로 유지하면서 무한 스크롤 구현
  /// 📋 인박스 모드에서 카드 드래그 중일 때만 PageView 스와이프 차단
  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      physics: _isDraggingFromInbox
          ? const NeverScrollableScrollPhysics() // 📋 카드 드래그 중: 스와이프 차단
          : const ClampingScrollPhysics(), // 그 외: 스와이프 허용 (인박스 모드 포함)
      onPageChanged: (index) {
        setState(() {
          // 이거를 설정하고 → 인덱스를 날짜로 변환해서
          final oldDate = _currentDate;
          _currentDate = _getDateForIndex(index);
          print('📆 [PageView] 날짜 변경: $oldDate → $_currentDate');
          print('   📅 초기 날짜: ${widget.selectedDate}');
          print(
            '   🔄 날짜 차이: ${_currentDate.difference(widget.selectedDate).inDays}일',
          );
        });
      },
      itemBuilder: (context, index) {
        final date = _getDateForIndex(index);
        // 🎯 매번 새로운 위젯 생성하도록 고유 key 추가 (Hero 충돌 방지!)
        final pageKey = ValueKey('page-${date.year}-${date.month}-${date.day}');

        // ✅ 인박스 모드 애니메이션 추가 (홈스크린과 동일 - AnimatedContainer 사용)
        return AnimatedContainer(
          key: pageKey, // 🎯 고유 key로 Hero 충돌 완전 방지!
          duration: const Duration(milliseconds: 900), // ✅ 홈스크린과 동일
          curve: const Cubic(0.4, 0.0, 0.2, 1.0), // ✅ Material Emphasized curve
          transform: _isInboxMode
              ? (Matrix4.identity()
                  ..scale(0.84, 0.84)) // ✅ 가로 84%, 세로 84% (월뷰와 동일)
              : Matrix4.identity(),
          transformAlignment: Alignment.topCenter,
          child: Material(
            color: const Color(0xFFF7F7F7), // ✅ #F7F7F7 배경색
            // 이거는 이래서 → 기존 _buildBody 함수 재사용
            child: _buildBody(context, date),
          ),
        );
      },
    );
  }

  /// 앱바를 구성하는 함수 - 피그마 디자인: ⋯ 버튼 + 날짜 + v 버튼
  /// 이거를 설정하고 → 좌측에 설정(⋯), 중앙에 날짜, 우측에 닫기(v) 버튼을 배치해서
  /// 이거를 해서 → 피그마 디자인과 동일한 레이아웃을 만든다
  /// 이거는 이래서 → iOS 네이티브 앱과 유사한 UX를 제공한다
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    print('🔍 [AppBar] isInboxMode: $_isInboxMode');

    // 인박스 모드일 때는 그라데이션 배경의 커스텀 앱바
    if (_isInboxMode) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Opacity(
          opacity: 0.96, // 전체 투명도 96%
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFAFAFA).withOpacity(1.0), // 상단 100% #FAFAFA
                  const Color(0xFFFAFAFA).withOpacity(0.0), // 하단 0% #FAFAFA
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x0A111111), // background 4% #111111 오버레이
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                // 중앙에 일과 요일 표시 (AnimatedSwitcher 적용)
                title: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        // 🎯 홈스크린과 완전히 동일한 애니메이션 값
                        final scaleAnimation = TweenSequence<double>([
                          TweenSequenceItem(
                            tween: Tween<double>(
                              begin: 0.92,
                              end: 1.05,
                            ).chain(CurveTween(curve: Curves.easeOutCubic)),
                            weight: 50,
                          ),
                          TweenSequenceItem(
                            tween: Tween<double>(
                              begin: 1.05,
                              end: 1.0,
                            ).chain(CurveTween(curve: Curves.easeInOut)),
                            weight: 30,
                          ),
                        ]).animate(animation);

                        final slideAnimation = TweenSequence<Offset>([
                          TweenSequenceItem(
                            tween: Tween<Offset>(
                              begin: const Offset(0, 0.4),
                              end: const Offset(0, 0.2),
                            ).chain(CurveTween(curve: Curves.easeOut)),
                            weight: 30,
                          ),
                          TweenSequenceItem(
                            tween: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: const Offset(0, -0.02),
                            ).chain(CurveTween(curve: Curves.easeOutCubic)),
                            weight: 40,
                          ),
                          TweenSequenceItem(
                            tween: Tween<Offset>(
                              begin: const Offset(0, -0.02),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeInOut)),
                            weight: 30,
                          ),
                        ]).animate(animation);

                        final fadeAnimation = TweenSequence<double>([
                          TweenSequenceItem(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: 0.3,
                            ).chain(CurveTween(curve: Curves.easeIn)),
                            weight: 20,
                          ),
                          TweenSequenceItem(
                            tween: Tween<double>(
                              begin: 0.3,
                              end: 1.0,
                            ).chain(CurveTween(curve: Curves.easeOut)),
                            weight: 80,
                          ),
                        ]).animate(animation);

                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: slideAnimation,
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: child,
                            ),
                          ),
                        );
                      },
                  child: TaskInboxDayTopBar(
                    key: ValueKey(
                      'inbox_day_bar_${_currentDate.day}_${_currentDate.weekday}',
                    ),
                    date: _currentDate,
                  ),
                ),
                centerTitle: true,
              ),
            ),
          ),
        ),
      );
    }

    // 일반 모드 앱바 - iOS Settings/Notes 스타일 Elevation Overlay
    // 🎯 70px 스크롤 기준으로 블러 + 그라데이션 활성화
    final threshold = 70.0;
    final overlayProgress = (_scrollOffset / threshold).clamp(0.0, 1.0);
    final blurAmount = overlayProgress * 20.0; // 최대 20px 블러

    // 🎯 날짜 정보 포맷팅 (AppBar 중앙 표시용)
    final dayOfWeekText = _formatDayOfWeek(_currentDate); // "金曜日"

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Stack(
        children: [
          // 배경 레이어 (블러 없는 고정 배경)
          Positioned.fill(child: Container(color: const Color(0xFFF7F7F7))),

          // 블러 레이어 (스크롤 시 활성화) - 인박스 모드에서는 블러 제거
          if (overlayProgress > 0 && !_isInboxMode)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurAmount,
                    sigmaY: blurAmount,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFAFAFA).withOpacity(overlayProgress),
                          const Color(0xFFFAFAFA).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // AppBar 컨텐츠
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent, // ✅ Material 3 선 제거
            shadowColor: Colors.transparent, // ✅ 그림자 제거
            automaticallyImplyLeading: false,

            // 좌측: 닫기 버튼 (down_icon.svg) - Figma 디자인
            leading: Container(
              margin: const EdgeInsets.only(left: 28), // 좌측 여백 28px
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Container(
                  width: 36, // Figma: 36px
                  height: 36, // Figma: 36px
                  padding: const EdgeInsets.all(8), // Figma: padding 8px
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFE4E4E4,
                    ).withOpacity(0.9), // Figma: rgba(228, 228, 228, 0.9)
                    borderRadius: BorderRadius.circular(
                      100,
                    ), // Figma: border-radius 100px
                    border: Border.all(
                      color: const Color(
                        0xFF111111,
                      ).withOpacity(0.02), // Figma: rgba(17, 17, 17, 0.02)
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFFBABABA,
                        ).withOpacity(0.08), // Figma: rgba(186, 186, 186, 0.08)
                        offset: const Offset(0, -2), // Figma: 0px -2px
                        blurRadius: 8, // Figma: 8px
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'asset/icon/down_icon.svg',
                    width: 20, // Figma: icon 20px
                    height: 20, // Figma: icon 20px
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF111111), // Figma: #111111
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                onPressed: () {
                  print('❌ [UI] 닫기 버튼 클릭 → Pull-to-dismiss 애니메이션으로 복귀');
                  print('   📅 현재 날짜: $_currentDate');
                  print('   📅 초기 날짜: ${widget.selectedDate}');
                  print('   🔄 날짜 변경됨: ${_currentDate != widget.selectedDate}');

                  // onClose 콜백이 있으면 호출 (날짜 상태 업데이트)
                  if (widget.onClose != null && !_onCloseCalled) {
                    print('   ✅ onClose 콜백 호출 시작!');
                    _onCloseCalled = true; // 🔔 플래그 설정 (중복 호출 방지)
                    widget.onClose!(_currentDate); // ✅ 마지막 날짜 전달!
                    print('   ✅ onClose 콜백 호출 완료!');
                  }

                  // DismissiblePage의 pull-to-dismiss 애니메이션으로 나가기
                  Navigator.of(context).pop();
                },
              ),
            ),

            // 중앙: 날짜 정보 (스크롤 시 fade in) - 한 줄 형식: "10.3. 金曜日"
            title: AnimatedOpacity(
              opacity: overlayProgress,
              duration: const Duration(milliseconds: 200),
              curve: const Cubic(0.05, 0.7, 0.1, 1.0), // Apple Emphasized
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 월.일. 요일 (한 줄)
                  Text(
                    '${_currentDate.month}.${_currentDate.day}. $dayOfWeekText',
                    style: const TextStyle(
                      fontFamily: 'LINE Seed JP App_TTF',
                      fontSize: 14, // 14px
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      letterSpacing: -0.07,
                      color: Color(0xFF222222),
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: true,

            // 우측: 오늘로 이동 버튼 (오늘이 아닐 때만 표시)
            actions: _isToday(_currentDate)
                ? null
                : [
                    Container(
                      width: 44, // 피그마: Frame 686 크기
                      height: 44,
                      padding: const EdgeInsets.all(4), // 피그마: 4px 패딩
                      margin: const EdgeInsets.only(right: 18), // ✅ 월뷰와 동일하게 18px
                      child: _buildTodayButton(DateTime.now()),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  /// 일본어 요일 변환 함수 (삭제됨 - DateDetailHeader에서 직접 처리)

  /// 스케줄 리스트를 구성하는 함수 (삭제됨 - _buildUnifiedList 사용)  /// 메인 바디를 구성하는 함수 - 피그마 디자인: 날짜 헤더 + 스케줄 리스트
  /// 이거를 설정하고 → 상단에 DateDetailHeader를 추가하고
  /// 이거를 해서 → Figma 디자인과 동일한 레이아웃을 만든다
  /// 이거는 이래서 → 시각적으로 명확한 날짜 정보를 제공한다
  /// ✅ 날짜 매개변수 추가: PageView에서 각 페이지마다 다른 날짜 표시
  Widget _buildBody(BuildContext context, DateTime date) {
    // 🚫 DropRegion 제거: 각 카드에 개별 DropRegion이 있으므로 불필요
    // 인박스 모드든 일반 모드든 _buildUnifiedList만 반환
    return _buildUnifiedList(date);
  }

  /// 날짜 헤더 위젯 - 피그마 디자인 기준 (삭제됨 - DateDetailHeader 위젯 사용)
  /// 이제 _buildDateHeader는 사용하지 않습니다

  /// 🆕 통합 리스트를 구성하는 함수 (AnimatedReorderableListView)
  /// 이거를 설정하고 → 일정, 할일, 습관을 드래그앤드롭으로 재정렬 가능한 리스트로 표시해서
  /// 이거를 해서 → 사용자가 원하는 순서로 카드를 배치할 수 있고
  /// 이거는 이래서 → DailyCardOrder 테이블에 순서를 저장해 다음에도 유지된다
  Widget _buildUnifiedList(DateTime date) {
    print('🎨 [_buildUnifiedList] 렌더링 시작: ${date.toString().split(' ')[0]}');

    // 🔁 반복 규칙을 고려한 데이터 조회
    return StreamBuilder<List<ScheduleData>>(
      stream: GetIt.I<AppDatabase>().watchSchedulesWithRepeat(date),
      builder: (context, scheduleSnapshot) {
        // 🎯 반복 규칙을 고려한 Task 조회
        return StreamBuilder<List<TaskData>>(
          stream: GetIt.I<AppDatabase>().watchTasksWithRepeat(date),
          builder: (context, taskSnapshot) {
            // 🔁 반복 규칙을 고려한 Habit 조회
            return StreamBuilder<List<HabitData>>(
              stream: GetIt.I<AppDatabase>().watchHabitsWithRepeat(date),
              builder: (context, habitSnapshot) {
                // 로딩 체크
                if (!scheduleSnapshot.hasData ||
                    !taskSnapshot.hasData ||
                    !habitSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final schedules = scheduleSnapshot.data!;
                final tasks = taskSnapshot.data!;
                final habits = habitSnapshot.data!;
                debugPrint(
                  '🔁 [UnifiedList] ${date.toString().split(' ')[0]} - 일정:${schedules.length}, 할일:${tasks.length}, 습관:${habits.length}',
                );

                // 이거를 해서 → 완료된 항목과 미완료 항목 분리
                final completedTasksCount = tasks
                    .where((t) => t.completed)
                    .length;

                print(
                  '✅ [UnifiedList] 일정:${schedules.length}, 할일:${tasks.length}, 습관:${habits.length}, 완료:${completedTasksCount}',
                );

                // 🆕 이거를 설정하고 → FutureBuilder로 UnifiedListItem 리스트를 생성해서
                // 이거를 해서 → DailyCardOrder 기반 또는 기본 순서로 표시한다
                // 🎯 Future 캐시: 날짜만으로 캐시 (간단하게 수정)
                final cacheKey = '${date.year}-${date.month}-${date.day}';

                // ✅ 데이터가 변경되면 항상 캐시 초기화 (Stream이 새로 들어오면 = 데이터 변경)
                _itemListCache.clear();
                _itemListCache[cacheKey] = _buildUnifiedItemList(
                  date,
                  schedules,
                  tasks,
                  habits,
                );

                return FutureBuilder<List<UnifiedListItem>>(
                  future: _itemListCache[cacheKey],
                  builder: (context, itemsSnapshot) {
                    if (!itemsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var items = itemsSnapshot.data!;

                    // ✅ 데이터가 없을 때 메시지 표시 + DragTarget으로 전체 영역 드롭 가능
                    if (items.isEmpty) {
                      // 🎯 SafeArea를 제외한 전체 화면 높이 계산
                      final mediaQuery = MediaQuery.of(context);
                      final safeAreaTop = mediaQuery.padding.top;
                      final safeAreaBottom = mediaQuery.padding.bottom;
                      final totalHeight = mediaQuery.size.height;
                      final availableHeight =
                          totalHeight - safeAreaTop - safeAreaBottom;

                      return DragTarget<TaskData>(
                        hitTestBehavior: HitTestBehavior
                            .translucent, // 🎯 더 민감한 터치 감지 (Empty Area)
                        onWillAcceptWithDetails: (details) => true,
                        onMove: (details) {
                          if (mounted && !_isDraggingFromInbox) {
                            setState(() {
                              _isDraggingFromInbox = true;
                            });
                          }
                        },
                        onLeave: (data) {
                          print('👋 [Empty Area] 드롭 영역 이탈');
                          if (mounted) {
                            setState(() {
                              _isDraggingFromInbox = false;
                            });
                          }
                        },
                        onAcceptWithDetails: (details) async {
                          final task = details.data;
                          print('✅ [Empty Area] 빈 화면에 드롭 완료');
                          print(
                            '💾 [Empty Area] Task 드롭: ${task.title} → $date',
                          );

                          // 🎯 즉시 햅틱
                          HapticFeedback.heavyImpact();

                          // 🎯 DB 업데이트: 날짜 + sortOrder (빈 화면은 맨 위)
                          await GetIt.I<AppDatabase>().updateTaskDate(
                            task.id,
                            date,
                          );
                          await GetIt.I<AppDatabase>().updateCardOrder(
                            date,
                            'task',
                            task.id,
                            0,
                          );

                          print('✅ [Empty Area] DB 업데이트 완료 (sortOrder=0, 맨 위)');

                          // 🔥 인박스 바텀시트 투명도 복구 (위젯 재생성 안함)
                          if (mounted) {
                            setState(() {
                              _isDraggingFromInbox = false;
                            });
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHovered =
                              candidateData.isNotEmpty || _isDraggingFromInbox;

                          return Container(
                            // 🎯 SafeArea 제외한 전체 화면 높이로 설정
                            height: availableHeight,
                            width: double.infinity,
                            decoration: isHovered
                                ? BoxDecoration(
                                    color: Colors.transparent, // 🎯 투명하게 변경
                                    border: Border.all(
                                      color: Colors.transparent, // 🎯 투명하게 변경
                                      width: 2,
                                    ),
                                  )
                                : null,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 🎯 드래그 중이면 드롭 메시지 표시
                                  if (isHovered)
                                    Column(
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline,
                                          color:
                                              Colors.transparent, // 🎯 투명하게 변경
                                          size: 48,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'ここにドロップ',
                                          style: TextStyle(
                                            fontFamily: 'LINE Seed JP App_TTF',
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Colors
                                                .transparent, // 🎯 투명하게 변경
                                          ),
                                        ),
                                      ],
                                    ),
                                  // 기본 메시지
                                  if (!isHovered)
                                    Text(
                                      '現在データがありません',
                                      style: TextStyle(
                                        fontFamily: 'LINE Seed JP App_TTF',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF999999),
                                        letterSpacing: -0.075,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    // 🎯 인박스 모드일 때 헤더를 리스트 맨 앞에 추가
                    if (_isInboxMode &&
                        (items.isEmpty ||
                            items.first.type != UnifiedItemType.inboxHeader)) {
                      items = [
                        UnifiedListItem.inboxHeader(
                          sortOrder: -1000,
                        ), // 맨 앞에 위치
                        ...items,
                      ];
                    }

                    // 🎯 드래그 호버 시 플레이스홀더 삽입 (candidateData 기반으로 직접 체크)
                    // NOTE: DragTarget builder에서 candidateData를 체크하므로 여기서는 불필요

                    print('📋 [_buildUnifiedList] 아이템 로드 완료: ${items.length}개');

                    // 🎯 화면 높이를 미리 계산 (NotificationListener 내부에서 MediaQuery 문제 방지)
                    final screenHeight = MediaQuery.of(context).size.height;
                    debugPrint('� [_buildUnifiedList] 화면 높이: $screenHeight');

                    // �🚀 AnimatedReorderableListView + 완료 섹션을 SingleChildScrollView로 감싸기!
                    // 🎯 NotificationListener로 감싸서 오버스크롤 시 pull-to-dismiss 활성화
                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        // 📋 인박스 모드에서는 pull-to-dismiss 완전 차단
                        if (_isInboxMode) return false;

                        if (notification is ScrollUpdateNotification) {
                          final pixels = notification.metrics.pixels;

                          // 🎯 Elevation Overlay: 스크롤 오프셋 업데이트 (일반 모드만)
                          if (!_isInboxMode && pixels >= 0) {
                            setState(() {
                              _scrollOffset = pixels;
                            });
                          }

                          // 🎯 핵심! pixels가 음수면 = 오버스크롤 중!
                          if (pixels < 0) {
                            // 🚀 민감도 증폭: pixels의 절댓값 × 3.0배!
                            const sensitivity = 3.0;
                            final amplifiedOffset = pixels.abs() * sensitivity;

                            // 🎯 최대값 기록
                            if (amplifiedOffset > _maxOverscrollOffset) {
                              _maxOverscrollOffset = amplifiedOffset;
                            }

                            // 🎯 임계값 체크: 15% 넘으면 플래그만 설정!
                            const loweredThreshold = 0.15;
                            final progress =
                                _maxOverscrollOffset / screenHeight;

                            if (progress >= loweredThreshold &&
                                !_shouldDismissOnScrollEnd) {
                              debugPrint('🎯 임계값 초과! 플래그 설정!');
                              _shouldDismissOnScrollEnd = true;
                            }

                            setState(() {
                              _dragOffset = amplifiedOffset;
                            });

                            return false;
                          } else if (_shouldDismissOnScrollEnd && pixels >= 0) {
                            // 🔥 임계값 초과 후 손가락을 뗐을 때 (pixels가 0으로 돌아올 때)
                            debugPrint(
                              '✅✅✅ 손가락 뗌 감지 (pixels=$pixels) → 즉시 닫기!',
                            );

                            // state 리셋
                            _dragOffset = 0;
                            _maxOverscrollOffset = 0;
                            _shouldDismissOnScrollEnd = false;

                            // 🎯 헤더 드래그와 동일한 방식으로 닫기!
                            // 1. onClose 콜백으로 상태 업데이트
                            if (widget.onClose != null && !_onCloseCalled) {
                              _onCloseCalled = true;
                              widget.onClose!(_currentDate);
                            }

                            // 2. Navigator.pop()으로 Hero 복귀 애니메이션
                            Navigator.of(context).pop();

                            return true; // 이벤트 소비
                          }
                        } else if (notification is ScrollEndNotification) {
                          // ⚠️ 스프링 복귀 제거 - 즉시 리셋
                          // 임계값 미달 → 즉시 0으로 리셋
                          // _runSpringAnimation(0, screenHeight);

                          // 리셋
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _dragOffset = 0;
                                _maxOverscrollOffset = 0;
                                _shouldDismissOnScrollEnd = false;
                              });
                            }
                          });
                        }

                        return false; // false = 이벤트를 부모로 전파
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        child: Column(
                          children: [
                            // 🎯 최상단 드롭존 (리스트 맨 위에 드롭 가능)
                            if (items.isNotEmpty) _buildTopDropZone(date),

                            // 🎯 리스트 영역 (shrinkWrap으로 높이 제한)
                            AnimatedReorderableListView(
                              items: items,

                              // 🚀 SingleChildScrollView 안에서 사용하기 위한 설정
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              buildDefaultDragHandles: false,

                              // 🔧 itemBuilder: 각 아이템을 카드로 렌더링
                              itemBuilder: (context, index) {
                                // 🎯 첫 번째 아이템에서 Scrollable context 캡처
                                if (index == 0 && _scrollableContext == null) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    try {
                                      final scrollableState =
                                          Scrollable.maybeOf(context);
                                      if (scrollableState != null &&
                                          scrollableState
                                                  .position
                                                  .maxScrollExtent !=
                                              double.infinity &&
                                          scrollableState
                                                  .position
                                                  .maxScrollExtent <
                                              100000000) {
                                        _scrollableContext = context;
                                        print(
                                          '✅ [ScrollContext] 저장 완료: max=${scrollableState.position.maxScrollExtent}',
                                        );
                                      } else {
                                        print(
                                          '❌ [ScrollContext] 부적절한 Scrollable: max=${scrollableState?.position.maxScrollExtent}',
                                        );
                                      }
                                    } catch (e) {
                                      print('❌ [ScrollContext] 저장 실패: $e');
                                    }
                                  });
                                }

                                final item = items[index];
                                print(
                                  '  → [itemBuilder] index=$index, type=${item.type}, id=${item.actualId}',
                                );

                                // 타입별 카드 렌더링 (index와 총 개수, items 배열 전달)
                                return _buildCardByType(
                                  item,
                                  date,
                                  tasks.where((t) => t.completed).toList(),
                                  index,
                                  items, // 🎯 items 배열 전달
                                );
                              },

                              onReorderStart: (index) {
                                final item = items[index];
                                print(
                                  '🎯 [onReorderStart] index=$index, type=${item.type}',
                                );
                              },

                              // ✅ onReorderEnd: 드래그 종료 시 상태 초기화
                              onReorderEnd: (index) {
                                print('🏁 [onReorderEnd] index=$index');
                                setState(() {
                                  _isReorderingScheduleBelowDivider = false;
                                });
                              },

                              // �🔄 onReorder: 재정렬 핸들러
                              // 이거를 설정하고 → 드래그앤드롭 시 호출되어
                              // 이거를 해서 → sortOrder 재계산 및 DB 저장한다
                              onReorder: (oldIndex, newIndex) {
                                print(
                                  '🎯 [onReorder] 콜백 호출됨! oldIndex=$oldIndex, newIndex=$newIndex',
                                );
                                print('   📋 인박스 모드: $_isInboxMode');
                                print('   📊 아이템 개수: ${items.length}');

                                // 🚫 Divider 제약 확인 → ✅ 제약 제거! 모든 아이템이 자유롭게 이동 가능
                                final item = items[oldIndex];
                                print(
                                  '   🎯 이동할 아이템: ${item.type} - ${item.uniqueId}',
                                );

                                final dividerIndex = items.indexWhere(
                                  (i) => i.type == UnifiedItemType.divider,
                                );
                                print('   📏 divider 위치: $dividerIndex');

                                // targetIndex 계산 (AnimatedReorderableListView 규칙)
                                final targetIndex = newIndex > oldIndex
                                    ? newIndex - 1
                                    : newIndex;

                                print(
                                  '🎯 [onReorder] 이동: index $oldIndex → $targetIndex (divider: $dividerIndex, type: ${item.type})',
                                );

                                // ✅ 제약 제거! 일정, 할일, 습관 모두 자유롭게 재정렬 가능
                                print('   ✅ 제약 없음 → 자유롭게 재정렬');
                                _handleReorder(items, oldIndex, newIndex);
                              },

                              // 🔑 isSameItem: 동일 아이템 비교
                              // 이거를 설정하고 → uniqueId로 비교해서
                              // 이거를 해서 → 애니메이션이 정확히 작동하도록 한다
                              isSameItem: (a, b) => a.uniqueId == b.uniqueId,

                              // 🎨 iOS 18 스타일 애니메이션 설정
                              // 이거를 설정하고 → 300ms duration으로 설정해서
                              // 이거를 해서 → 부드러운 애니메이션을 구현한다
                              insertDuration: const Duration(milliseconds: 300),
                              removeDuration: const Duration(milliseconds: 250),

                              // 🎯 드래그 시작 딜레이 (길게 누르기)
                              // 🎯 인박스에서 드래그 중일 때만 재정렬 비활성화
                              // 리스트 아이템 직접 드래그는 항상 가능
                              dragStartDelay: _isDraggingFromInbox
                                  ? const Duration(days: 365) // 인박스 드래그 중: 비활성화
                                  : const Duration(
                                      milliseconds: 500,
                                    ), // 일반: 500ms 딜레이
                              // 🎭 enterTransition: 아이템 추가 애니메이션
                              // 이거를 설정하고 → iOS 스타일 ScaleIn + FadeIn으로
                              // 이거를 해서 → 부드럽게 나타나도록 한다
                              enterTransition: [
                                ScaleIn(
                                  duration: const Duration(milliseconds: 300),
                                  curve: const Cubic(
                                    0.25,
                                    0.1,
                                    0.25,
                                    1.0,
                                  ), // iOS 곡선
                                  begin: 0.95,
                                  end: 1.0,
                                ),
                                FadeIn(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                ),
                              ],

                              // 🎭 exitTransition: 아이템 제거 애니메이션
                              // 이거를 설정하고 → iOS 스타일 ScaleIn + FadeIn으로
                              // 이거를 해서 → 부드럽게 사라지도록 한다
                              exitTransition: [
                                ScaleIn(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeIn,
                                  begin: 1.0,
                                  end: 0.95,
                                ),
                                FadeIn(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeIn,
                                ),
                              ],

                              // 🎨 proxyDecorator: 드래그 중 카드 스타일
                              // 이거를 설정하고 → 드래그 시 확대 + 회전 + 그림자 효과를 추가해서
                              // 이거를 해서 → iOS 스타일 드래그 애니메이션을 구현한다
                              proxyDecorator: (child, index, animation) {
                                return AnimatedBuilder(
                                  animation: animation,
                                  builder: (context, child) {
                                    // 1️⃣ 확대 효과 (3%)
                                    final scale =
                                        1.0 + (animation.value * 0.03);

                                    // 2️⃣ 회전 효과 (3도)
                                    final rotation =
                                        animation.value * 0.05; // 약 3도

                                    return Transform.scale(
                                      scale: scale,
                                      child: Transform.rotate(
                                        angle: rotation,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0x14111111,
                                                ), // #111111 8% opacity
                                                offset: const Offset(
                                                  0,
                                                  4,
                                                ), // y: 4
                                                blurRadius: 20, // blur: 20
                                              ),
                                            ],
                                          ),
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: child,
                                );
                              },
                            ), // AnimatedReorderableListView 끝
                            // ✅ 완료 섹션 - 리스트 바로 아래에 배치
                            StreamBuilder<List<ScheduleData>>(
                              stream: GetIt.I<AppDatabase>()
                                  .watchCompletedSchedulesByDay(date),
                              builder: (context, scheduleSnapshot) {
                                return StreamBuilder<List<TaskData>>(
                                  stream: GetIt.I<AppDatabase>()
                                      .watchCompletedTasksByDay(date),
                                  builder: (context, taskSnapshot) {
                                    return StreamBuilder<List<HabitData>>(
                                      stream: GetIt.I<AppDatabase>()
                                          .watchCompletedHabitsByDay(date),
                                      builder: (context, habitSnapshot) {
                                        if (!scheduleSnapshot.hasData ||
                                            !taskSnapshot.hasData ||
                                            !habitSnapshot.hasData) {
                                          return const SizedBox.shrink();
                                        }

                                        final completedSchedules =
                                            scheduleSnapshot.data ?? [];
                                        final completedTasks =
                                            taskSnapshot.data ?? [];
                                        final completedHabits =
                                            habitSnapshot.data ?? [];
                                        final completedCount =
                                            completedSchedules.length +
                                            completedTasks.length +
                                            completedHabits.length;

                                        // 🎯 인박스 모드이거나 완료 카드가 없으면 숨김
                                        if (_isInboxMode ||
                                            completedCount == 0) {
                                          return const SizedBox.shrink();
                                        }

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            left: _isCompletedExpanded
                                                ? 16
                                                : 24, // 열렸을 때: 361px(345+16), 닫혔을 때: 345px(345+24-24)
                                            right: _isCompletedExpanded
                                                ? 16
                                                : 24,
                                            top: 16,
                                            bottom: 16,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 600,
                                            ), // 더 부드러운 애니메이션
                                            curve: Curves
                                                .easeInOutCubicEmphasized, // iOS 스타일 강조 곡선
                                            width: _isCompletedExpanded
                                                ? 361
                                                : 345, // 열렸을 때: 361px, 닫혔을 때: 345px
                                            decoration: BoxDecoration(
                                              color: _isCompletedExpanded
                                                  ? const Color(
                                                      0xFFF7F7F7,
                                                    ) // 열렸을 때 #F7F7F7
                                                  : const Color(
                                                      0xFFE4E4E4,
                                                    ), // 닫혔을 때 #E4E4E4
                                              border: Border.all(
                                                color: const Color(
                                                  0x14111111,
                                                ), // rgba(17, 17, 17, 0.08)
                                                width: 1,
                                              ),
                                              // 🎨 Figma Smoothing 60% 적용 (반지름 × 1.6)
                                              borderRadius: _isCompletedExpanded
                                                  ? BorderRadius.circular(
                                                      24 * 1.6,
                                                    ) // 38.4px (열렸을 때)
                                                  : BorderRadius.circular(
                                                      16 * 1.6,
                                                    ), // 25.6px (닫혔을 때)
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(
                                                    0x14BABABA,
                                                  ), // rgba(186, 186, 186, 0.08)
                                                  offset: Offset(0, -2),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // 헤더 영역 (완료 텍스트 + 아이콘)
                                                Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius:
                                                        _isCompletedExpanded
                                                        ? BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  24 * 1.6,
                                                                ),
                                                          ) // 38.4px
                                                        : BorderRadius.circular(
                                                            16 * 1.6,
                                                          ), // 25.6px
                                                    onTap: () {
                                                      print(
                                                        '🟡 [CompletedSection] 완료 박스 탭!',
                                                      );
                                                      // 🎯 햅틱 피드백 추가
                                                      HapticFeedback.lightImpact();
                                                      setState(() {
                                                        _isCompletedExpanded =
                                                            !_isCompletedExpanded;
                                                        if (_isCompletedExpanded) {
                                                          _completedExpandController
                                                              .forward();
                                                        } else {
                                                          _completedExpandController
                                                              .reverse();
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      height:
                                                          _isCompletedExpanded
                                                          ? 64
                                                          : 56, // 열렸을 때: 64px, 닫혔을 때: 56px
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                          ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          // 完了 텍스트
                                                          Text(
                                                            '完了',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'LINE Seed JP App_TTF',
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  _isCompletedExpanded
                                                                  ? FontWeight
                                                                        .w700 // 열렸을 때 700
                                                                  : FontWeight
                                                                        .w800, // 닫혔을 때 800
                                                              height:
                                                                  1.4, // line-height: 140%
                                                              letterSpacing:
                                                                  _isCompletedExpanded
                                                                  ? 0.01 *
                                                                        13 // 열렸을 때 0.01em
                                                                  : -0.005 *
                                                                        13, // 닫혔을 때 -0.005em
                                                              color:
                                                                  const Color(
                                                                    0xFF111111,
                                                                  ),
                                                            ),
                                                          ),
                                                          // 아이콘
                                                          SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child: AnimatedRotation(
                                                              turns:
                                                                  _isCompletedExpanded
                                                                  ? 0.5
                                                                  : 0, // 180도 회전
                                                              duration:
                                                                  const Duration(
                                                                    milliseconds:
                                                                        600,
                                                                  ), // AnimatedContainer와 동기화
                                                              curve: Curves
                                                                  .easeInOutCubicEmphasized, // iOS 스타일 강조 곡선
                                                              child: const Icon(
                                                                Icons
                                                                    .keyboard_arrow_down,
                                                                size: 24,
                                                                color: Color(
                                                                  0xFF111111,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // 확장된 완료 아이템들
                                                SizeTransition(
                                                  sizeFactor:
                                                      _completedExpandAnimation,
                                                  axisAlignment: -1,
                                                  child: _buildCompletedItems(
                                                    completedSchedules,
                                                    completedTasks,
                                                    completedHabits,
                                                    date,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),

                            // 🎯 최하단 드롭존 (리스트 맨 아래에 드롭 가능)
                            if (items.isNotEmpty) _buildBottomDropZone(date),
                          ], // Column children 끝
                        ), // Column 끝
                      ), // SingleChildScrollView 끝
                    ); // NotificationListener 끝
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// 🎨 타입별 카드 렌더링 함수
  /// 이거를 설정하고 → UnifiedListItem 타입을 확인해서
  /// 이거를 해서 → 기존 카드 컴포넌트를 그대로 재사용하고
  /// 이거는 이래서 → 기존 디자인과 기능이 100% 유지된다
  Widget _buildCardByType(
    UnifiedListItem item,
    DateTime date,
    List<TaskData> completedTasks,
    int index, // 🎯 통합 리스트에서의 위치
    List<UnifiedListItem> allItems, // 🎯 전체 아이템 배열 (sortOrder 계산용)
  ) {
    // 🔑 Key 설정 (AnimatedReorderableListView 필수!)
    // 이거를 설정하고 → ValueKey(uniqueId)로 설정해서
    // 이거를 해서 → 재정렬 시 올바른 아이템을 추적한다
    final key = ValueKey(item.uniqueId);

    // 🔥 인박스에서 드롭 시 전체 리스트 재정렬 헬퍼 함수
    Future<void> _handleInboxDrop(
      int dropIndex,
      TaskData task,
      DateTime date,
    ) async {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔥 [인박스 드롭 처리 시작]');
      print('   • Task ID: ${task.id}');
      print('   • Task 제목: ${task.title}');
      print('   • UI 드롭 위치 (index): $dropIndex');
      print('   • 대상 날짜: ${date.toString().split(' ')[0]}');
      print('');

      // 🔥 [핵심 수정] UI 인덱스를 실제 데이터 인덱스로 정확하게 변환
      print('🔍 [인덱스 변환 시작]');
      print('   • 전체 allItems 길이: ${allItems.length}');
      print('   • 드롭된 UI 인덱스: $dropIndex');

      // allItems 구조 로깅
      for (int i = 0; i < allItems.length && i < 20; i++) {
        final item = allItems[i];
        String itemDesc = '';
        if (item.type == UnifiedItemType.schedule) {
          itemDesc = 'Schedule: ${(item.data as ScheduleData).summary}';
        } else if (item.type == UnifiedItemType.task) {
          itemDesc = 'Task: ${(item.data as TaskData).title}';
        } else if (item.type == UnifiedItemType.habit) {
          itemDesc = 'Habit: ${(item.data as HabitData).title}';
        } else {
          itemDesc = item.type.toString();
        }
        print('   [$i] $itemDesc');
      }

      // dropIndex보다 앞에 있는 non-data 아이템 개수 세기
      int nonDataCountBeforeDrop = 0;
      for (int i = 0; i < dropIndex && i < allItems.length; i++) {
        final item = allItems[i];
        if (item.type == UnifiedItemType.dateHeader ||
            item.type == UnifiedItemType.divider ||
            item.type == UnifiedItemType.completed ||
            item.type == UnifiedItemType.inboxHeader) {
          nonDataCountBeforeDrop++;
          print('   🔸 인덱스 $i: ${item.type} (non-data)');
        }
      }

      print('   • dropIndex 앞의 non-data 아이템: $nonDataCountBeforeDrop개');

      // 🔥 핵심 수정: 실제 데이터 인덱스 계산
      // dropIndex는 드롭 대상 아이템의 위치를 가리킴
      // 우리는 그 아이템의 "앞"에 삽입해야 하므로 -1 필요
      // 실제 데이터 인덱스 = (UI 인덱스 - non-data 아이템 수) 에서 드롭 대상 아이템 앞에 넣기 위해 추가 조정 불필요
      // 하지만 사용자가 "위에 드롭"했을 때 실제로는 그 아이템이 아니라 바로 앞 간격에 드롭하므로
      // dropIndex 자체가 이미 "그 아이템 뒤"를 가리키고 있음
      int actualDataIndex = dropIndex - nonDataCountBeforeDrop - 1;

      // 현재 화면에 표시된 실제 데이터 아이템 수 (검증용)
      final actualDataItems = allItems
          .where(
            (item) =>
                item.type != UnifiedItemType.divider &&
                item.type != UnifiedItemType.completed &&
                item.type != UnifiedItemType.inboxHeader &&
                item.type != UnifiedItemType.dateHeader &&
                !(item.type == UnifiedItemType.task &&
                    (item.data as TaskData).id == task.id), // 드롭된 Task 제외
          )
          .toList();

      print('   • 실제 데이터 아이템 수: ${actualDataItems.length}');
      print('   • 계산된 데이터 인덱스: $actualDataIndex');

      // 범위 검증
      if (actualDataIndex < 0) {
        actualDataIndex = 0;
        print('   ⚠️ 인덱스가 0보다 작음 → 0으로 조정');
      } else if (actualDataIndex > actualDataItems.length) {
        actualDataIndex = actualDataItems.length;
        print('   ⚠️ 인덱스가 범위 초과 → 맨 끝으로 조정');
      }

      print('   🎯 최종 삽입 위치: $actualDataIndex');
      print('');

      // [1단계] Task 날짜 변경
      print('💾 [1단계] Task 날짜 변경');
      await GetIt.I<AppDatabase>().updateTaskDate(task.id, date);
      print('   ✅ Task #${task.id} 날짜 변경 완료');
      print('');

      // [2단계] DB에서 현재 날짜의 모든 데이터 다시 로드 (최신 상태 반영)
      print('💾 [2단계] DB에서 최신 데이터 로드');
      final db = GetIt.I<AppDatabase>();

      // 해당 날짜의 일정, 할일, 습관 로드
      final schedules = await db.watchByDay(date).first;
      final tasks = await db.watchTasksByExecutionDate(date).first;
      final habits = await db.watchHabits().first;

      // 완료된 습관 제외
      final completedHabits = await db.watchCompletedHabitsByDay(date).first;
      final completedHabitIds = completedHabits.map((h) => h.id).toSet();
      final incompleteHabits = habits
          .where((h) => !completedHabitIds.contains(h.id))
          .toList();

      print(
        '   📊 로드된 데이터: 일정=${schedules.length}, 할일=${tasks.length}, 습관=${incompleteHabits.length}',
      );

      // [3단계] 기존 DailyCardOrder 로드
      print('🔍 [3단계] 기존 순서 조회');
      final existingOrders = await db.watchDailyCardOrder(date).first;
      print('   📊 기존 순서: ${existingOrders.length}개');

      // [4단계] 전체 아이템 리스트 구성 (기존 순서 + 새로운 Task)
      print('🔨 [4단계] 전체 아이템 리스트 구성');

      List<UnifiedListItem> updatedItems = [];

      if (existingOrders.isEmpty) {
        // 기존 순서가 없으면 기본 순서로 생성
        print('   ⚠️ 기존 순서 없음 → 기본 순서로 생성');
        int order = 0;

        // 일정 추가 (미완료만)
        for (final s in schedules.where((s) => !s.completed)) {
          updatedItems.add(UnifiedListItem.fromSchedule(s, sortOrder: order++));
        }

        // 할일 추가 (미완료만)
        for (final t in tasks.where((t) => !t.completed)) {
          updatedItems.add(UnifiedListItem.fromTask(t, sortOrder: order++));
        }

        // 습관 추가 (미완료만)
        for (final h in incompleteHabits) {
          updatedItems.add(UnifiedListItem.fromHabit(h, sortOrder: order++));
        }
      } else {
        // 기존 순서가 있으면 그 순서대로 복원
        print('   ✅ 기존 순서 복원');

        for (final orderData in existingOrders) {
          try {
            if (orderData.cardType == 'schedule') {
              final schedule = schedules.firstWhere(
                (s) => s.id == orderData.cardId,
              );
              if (!schedule.completed) {
                updatedItems.add(
                  UnifiedListItem.fromSchedule(
                    schedule,
                    sortOrder: orderData.sortOrder,
                  ),
                );
              }
            } else if (orderData.cardType == 'task') {
              final task = tasks.firstWhere((t) => t.id == orderData.cardId);
              if (!task.completed) {
                updatedItems.add(
                  UnifiedListItem.fromTask(
                    task,
                    sortOrder: orderData.sortOrder,
                  ),
                );
              }
            } else if (orderData.cardType == 'habit') {
              final habit = incompleteHabits.firstWhere(
                (h) => h.id == orderData.cardId,
              );
              updatedItems.add(
                UnifiedListItem.fromHabit(
                  habit,
                  sortOrder: orderData.sortOrder,
                ),
              );
            }
          } catch (e) {
            print('   ⚠️ 아이템 찾기 실패: ${orderData.cardType}-${orderData.cardId}');
          }
        }

        // sortOrder로 정렬
        updatedItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }

      print('   📊 현재 리스트 길이: ${updatedItems.length}');
      print('   📍 드롭 위치: $actualDataIndex');

      // [5단계] 새로운 Task 삽입
      print('➕ [5단계] 새로운 Task 삽입');

      // 드롭된 Task가 이미 리스트에 있는지 확인 (중복 방지)
      final existingTaskIndex = updatedItems.indexWhere(
        (item) =>
            item.type == UnifiedItemType.task &&
            (item.data as TaskData).id == task.id,
      );

      int adjustedInsertIndex = actualDataIndex;

      if (existingTaskIndex != -1) {
        print('   🔄 기존 Task 발견 (index: $existingTaskIndex)');

        // 🔥 핵심 수정: 먼저 제거하고, 그 다음에 인덱스 조정
        // 기존 Task가 삽입 위치보다 앞에 있으면, 제거 후 리스트가 한 칸 당겨지므로
        // 삽입 인덱스도 -1 해야 함
        updatedItems.removeAt(existingTaskIndex);
        print('   🗑️ 기존 Task 제거 완료');

        if (existingTaskIndex < actualDataIndex) {
          adjustedInsertIndex = actualDataIndex - 1;
          print(
            '   📍 기존 Task가 앞에 있었음 → 삽입 인덱스 조정: $actualDataIndex → $adjustedInsertIndex',
          );
        }
      }

      // DB에서 실제 Task 데이터 다시 로드
      final taskFromDb = await db.getTaskById(task.id);
      if (taskFromDb == null) {
        print('   ❌ Task를 DB에서 찾을 수 없음');
        return;
      }

      // 새 Task 아이템 생성
      final newTaskItem = UnifiedListItem.fromTask(
        taskFromDb,
        sortOrder: adjustedInsertIndex,
      );

      // 원하는 위치에 삽입
      if (adjustedInsertIndex >= updatedItems.length) {
        updatedItems.add(newTaskItem);
        print('   ➕ 맨 끝에 추가 (index: ${updatedItems.length - 1})');
      } else {
        updatedItems.insert(adjustedInsertIndex, newTaskItem);
        print('   ➕ index $adjustedInsertIndex에 삽입');
      }

      print('   📊 삽입 후 길이: ${updatedItems.length}');
      print('');

      // [6단계] sortOrder를 0부터 순차적으로 재계산
      print('🔢 [6단계] sortOrder 재계산 (0부터 순차)');
      for (int i = 0; i < updatedItems.length; i++) {
        updatedItems[i] = updatedItems[i].copyWith(sortOrder: i);
      }

      // 재계산된 리스트 출력
      print('📋 [재계산된 전체 순서]:');
      for (int i = 0; i < updatedItems.length; i++) {
        final marker = updatedItems[i].uniqueId.contains('task_${task.id}')
            ? '🔥 [방금 추가!]'
            : '';
        final typeEmoji = updatedItems[i].type == UnifiedItemType.schedule
            ? '📅'
            : updatedItems[i].type == UnifiedItemType.task
            ? '✅'
            : updatedItems[i].type == UnifiedItemType.habit
            ? '🔁'
            : '❓';
        print(
          '  [$i] $typeEmoji sortOrder=$i | ${updatedItems[i].uniqueId} $marker',
        );
      }
      print('');

      // [7단계] DB에 전체 순서 저장
      print('💾 [7단계] DB에 전체 순서 저장');
      await _saveDailyCardOrder(updatedItems);

      print('✅ [인박스 드롭 처리 완료!]');
      print('   • Task ID: ${task.id}');
      print('   • 최종 위치: $actualDataIndex');
      print('   • 날짜: ${date.toString().split(' ')[0]}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    // 타입별 분기 처리
    switch (item.type) {
      // ====================================================================
      // 📅 날짜 헤더 (DateDetailHeader - 스크롤 가능)
      // ====================================================================
      case UnifiedItemType.dateHeader:
        final headerDate = item.data as DateTime;
        return Container(
          key: key,
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
          child: DateDetailHeader(
            selectedDate: headerDate,
            onDateChanged: (newDate) {
              // 날짜 피커에서 선택한 날짜로 이동 (앱바의 오늘 버튼과 동일한 애니메이션)
              final daysDiff = newDate.difference(widget.selectedDate).inDays;
              final targetIndex = _centerIndex + daysDiff;
              
              _pageController.animateToPage(
                targetIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            onPickerTap: () {
              if (_showDatePicker) {
                // 피커 닫기
                _datePickerAnimationController.reverse().then((_) {
                  if (mounted) {
                    setState(() {
                      _showDatePicker = false;
                    });
                    // 🗓️ 부모에게 피커 닫힘 알림 (DismissiblePage 활성화)
                    if (widget.onPickerStateChanged != null) {
                      widget.onPickerStateChanged!(false);
                    }
                  }
                });
              } else {
                // 피커 열기
                _datePickerAnimationController.reset();
                setState(() {
                  _showDatePicker = true;
                });
                // 🗓️ 부모에게 피커 열림 알림 (DismissiblePage 비활성화)
                if (widget.onPickerStateChanged != null) {
                  widget.onPickerStateChanged!(true);
                }
                _datePickerAnimationController.forward();
              }
            },
          ),
        );

      // ====================================================================
      // 📅 일정 카드 (Schedule)
      // ====================================================================
      case UnifiedItemType.schedule:
        final schedule = item.data as ScheduleData;

        // 🚫 Divider 제약 위반 시 흔들림 + 빨간색 효과
        final isInvalid = _isReorderingScheduleBelowDivider;

        // 🎯 카드 위(사이)에 호버 중인지 확인 (-(index+1000)으로 표시)
        final isBetweenHovered = _hoveredCardIndex == -(index + 1000);

        // 🔥 Column으로 감싸서 between-card 드롭존 + 카드
        return Column(
          key: key,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎯 카드 사이 드롭존 (카드 위쪽)
            _buildBetweenCardDropZone(index, date, isBetweenHovered),

            // 🔥 실제 카드 (DragTarget으로 감싸기)
            DragTarget<TaskData>(
              hitTestBehavior:
                  HitTestBehavior.translucent, // 🎯 더 민감한 터치 감지 (Schedule)
              onWillAcceptWithDetails: (details) => true,
              onMove: (details) {
                if (mounted && _hoveredCardIndex != index) {
                  setState(() {
                    _isDraggingFromInbox = true;
                    _hoveredCardIndex = index;
                  });
                }
              },
              onLeave: (data) {
                print('👋 [Schedule #$index] 드롭 영역 이탈 - 파란색 박스 숨김');
                if (mounted) {
                  setState(() {
                    _hoveredCardIndex = null;
                  });
                }
              },
              onAcceptWithDetails: (details) async {
                final task = details.data;
                print(
                  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
                );
                print('✅ [Schedule #$index] 🔥 드롭 완료!');
                print('   🔵 파란색 박스가 표시된 위치: index=$index');
                print('   📅 대상 날짜: ${date.toString().split(' ')[0]}');
                print('');

                // 🎯 즉시 햅틱
                HapticFeedback.heavyImpact();

                // 🔥 새로운 드롭 처리 함수 호출
                await _handleInboxDrop(index, task, date);

                // 🔥 인박스 바텀시트 투명도 복구 (위젯 재생성 안함)
                if (mounted) {
                  setState(() {
                    _isDraggingFromInbox = false;
                    _hoveredCardIndex = null;
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                return RepaintBoundary(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.elasticOut,
                    // 좌우 흔들림 효과 (offset 대신 padding으로 구현)
                    padding: EdgeInsets.only(
                      bottom: 0,
                      left: isInvalid ? 20 : 24,
                      right: isInvalid ? 28 : 24,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        // 빨간색 테두리 효과
                        border: isInvalid
                            ? Border.all(
                                color: Colors.red.withOpacity(0.6),
                                width: 2,
                              )
                            : null,
                      ),
                      child: GestureDetector(
                        onTap: () => _openScheduleDetail(schedule),
                        child: SlidableScheduleCard(
                          groupTag: 'unified_list',
                          scheduleId: schedule.id,
                          repeatRule: schedule.repeatRule, // 🔄 반복 규칙 전달
                          showConfirmDialog: true, // ✅ 삭제 확인 모달 표시
                          onComplete: () async {
                            // 🔥 반복 일정은 ScheduleCompletion 테이블로 날짜별 완료 처리
                            await GetIt.I<AppDatabase>()
                                .recordScheduleCompletion(
                                  schedule.id,
                                  date, // 현재 날짜
                                );
                            print(
                              '✅ [ScheduleCard] 완료: ${schedule.summary} (날짜: $date)',
                            );
                            HapticFeedback.lightImpact();
                          },
                          onDelete: () async {
                            await GetIt.I<AppDatabase>().deleteSchedule(
                              schedule.id,
                            );
                            // 🗑️ DailyCardOrder에서도 삭제
                            await GetIt.I<AppDatabase>()
                                .deleteCardFromAllOrders(
                                  'schedule',
                                  schedule.id,
                                );
                            print('🗑️ [ScheduleCard] 삭제: ${schedule.summary}');
                            // ✅ 토스트 표시
                            if (context.mounted) {
                              showActionToast(context, type: ToastType.delete);
                            }
                          },
                          child: ScheduleCard(
                            start: schedule.start,
                            end: schedule.end,
                            summary: schedule.summary,
                            colorId: schedule.colorId,
                            repeatRule: schedule.repeatRule,
                            alertSetting: schedule.alertSetting,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ), // DragTarget 닫기
          ], // Column children 닫기
        ); // Column 닫기

      // ====================================================================
      // ✅ 할일 카드 (Task)
      // ====================================================================
      case UnifiedItemType.task:
        final task = item.data as TaskData;

        // 🎯 카드 위(사이)에 호버 중인지 확인 (-(index+1000)으로 표시)
        final isBetweenHovered = _hoveredCardIndex == -(index + 1000);

        // 🔥 Column으로 감싸서 between-card 드롭존 + 카드
        return Column(
          key: key,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎯 카드 사이 드롭존 (카드 위쪽)
            _buildBetweenCardDropZone(index, date, isBetweenHovered),

            // 🔥 실제 카드 (DragTarget으로 감싸기)
            DragTarget<TaskData>(
              hitTestBehavior:
                  HitTestBehavior.translucent, // 🎯 더 민감한 터치 감지 (Task)
              onWillAcceptWithDetails: (details) => true,
              onMove: (details) {
                if (mounted && _hoveredCardIndex != index) {
                  setState(() {
                    _isDraggingFromInbox = true;
                    _hoveredCardIndex = index;
                  });
                }
              },
              onLeave: (data) {
                print('👋 [Task #$index] 드롭 영역 이탈 - 파란색 박스 숨김');
                if (mounted) {
                  setState(() {
                    _hoveredCardIndex = null;
                  });
                }
              },
              onAcceptWithDetails: (details) async {
                final droppedTask = details.data;
                print(
                  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
                );
                print('✅ [Task #$index] 🔥 드롭 완료!');
                print('   🔵 파란색 박스가 표시된 위치: index=$index');
                print('   📅 대상 날짜: ${date.toString().split(' ')[0]}');
                print('');

                // 🎯 즉시 햅틱
                HapticFeedback.heavyImpact();

                // 🔥 새로운 드롭 처리 함수 호출
                await _handleInboxDrop(index, droppedTask, date);

                // 🔥 인박스 바텀시트 투명도 복구 (위젯 재생성 안함)
                if (mounted) {
                  setState(() {
                    _isDraggingFromInbox = false;
                    _hoveredCardIndex = null;
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                return RepaintBoundary(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 0,
                      left: 24,
                      right: 24,
                    ),
                    child: SlidableTaskCard(
                      groupTag: 'unified_list',
                      taskId: task.id,
                      repeatRule: task.repeatRule, // 🔄 반복 규칙 전달
                      showConfirmDialog: true, // ✅ 삭제 확인 모달 표시
                      onTap: () => _openTaskDetail(task),
                      onComplete: () async {
                        // 🎯 햅틱 피드백 추가
                        HapticFeedback.lightImpact();
                        // 🔥 반복 할일은 TaskCompletion 테이블로 날짜별 완료 처리
                        await GetIt.I<AppDatabase>().recordTaskCompletion(
                          task.id,
                          date,
                        );
                        print('✅ [TaskCard] 완료 토글: ${task.title} (날짜: $date)');
                      },
                      onDelete: () async {
                        await GetIt.I<AppDatabase>().deleteTask(task.id);
                        // 🗑️ DailyCardOrder에서도 삭제
                        await GetIt.I<AppDatabase>().deleteCardFromAllOrders(
                          'task',
                          task.id,
                        );
                        print('🗑️ [TaskCard] 삭제: ${task.title}');
                        // ✅ 토스트 표시
                        if (context.mounted) {
                          showActionToast(context, type: ToastType.delete);
                        }
                      },
                      onInbox: () async {
                        // 📥 인박스로 이동 (executionDate 제거)
                        await GetIt.I<AppDatabase>().moveTaskToInbox(task.id);
                        // 🗑️ DailyCardOrder에서도 삭제
                        await GetIt.I<AppDatabase>().deleteCardFromAllOrders(
                          'task',
                          task.id,
                        );
                        print('📥 [TaskCard] 인박스로 이동: ${task.title}');

                        // 📥 인박스 토스트 표시
                        if (context.mounted) {
                          showActionToast(context, type: ToastType.inbox);
                        }
                      },
                      child: TaskCard(
                        task: task,
                        onToggle: () async {
                          // 🎯 햅틱 피드백 추가
                          HapticFeedback.lightImpact();

                          // 🔥 반복 할일인지 확인
                          final pattern = await GetIt.I<AppDatabase>()
                              .getRecurringPattern(
                                entityType: 'task',
                                entityId: task.id,
                              );

                          if (pattern != null) {
                            // 🔥 반복 할일: TaskCompletion 테이블로 날짜별 완료 처리
                            final completions = await GetIt.I<AppDatabase>()
                                .getTaskCompletionsByDate(date);
                            final isCompleted = completions.any(
                              (c) => c.taskId == task.id,
                            );

                            if (isCompleted) {
                              await GetIt.I<AppDatabase>().deleteTaskCompletion(
                                task.id,
                                date,
                              );
                              print(
                                '🔄 [TaskCard] 체크박스 완료 해제: ${task.title} (날짜: $date)',
                              );
                            } else {
                              await GetIt.I<AppDatabase>().recordTaskCompletion(
                                task.id,
                                date,
                              );
                              print(
                                '✅ [TaskCard] 체크박스 완료 처리: ${task.title} (날짜: $date)',
                              );
                            }
                          } else {
                            // 🔥 일반 할일: 기존 completed 필드 사용
                            if (task.completed) {
                              await GetIt.I<AppDatabase>().uncompleteTask(
                                task.id,
                              );
                              print('🔄 [TaskCard] 체크박스 완료 해제: ${task.title}');
                            } else {
                              await GetIt.I<AppDatabase>().completeTask(
                                task.id,
                              );
                              print('✅ [TaskCard] 체크박스 완료 처리: ${task.title}');
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ), // DragTarget 닫기
          ], // Column children 닫기
        ); // Column 닫기

      // ====================================================================
      // 🔁 습관 카드 (Habit)
      // ====================================================================
      case UnifiedItemType.habit:
        final habit = item.data as HabitData;

        // 🎯 카드 위(사이)에 호버 중인지 확인 (-(index+1000)으로 표시)
        final isBetweenHovered = _hoveredCardIndex == -(index + 1000);

        // 🔥 Column으로 감싸서 between-card 드롭존 + 카드
        return Column(
          key: key,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎯 카드 사이 드롭존 (카드 위쪽)
            _buildBetweenCardDropZone(index, date, isBetweenHovered),

            // 🔥 실제 카드 (DragTarget으로 감싸기)
            DragTarget<TaskData>(
              hitTestBehavior:
                  HitTestBehavior.translucent, // 🎯 더 민감한 터치 감지 (Habit)
              onWillAcceptWithDetails: (details) => true,
              onMove: (details) {
                if (mounted && _hoveredCardIndex != index) {
                  setState(() {
                    _isDraggingFromInbox = true;
                    _hoveredCardIndex = index;
                  });
                }
              },
              onLeave: (data) {
                print('👋 [Habit #$index] 드롭 영역 이탈 - 파란색 박스 숨김');
                if (mounted) {
                  setState(() {
                    _hoveredCardIndex = null;
                  });
                }
              },
              onAcceptWithDetails: (details) async {
                final droppedTask = details.data;
                print(
                  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
                );
                print('✅ [Habit #$index] 🔥 드롭 완료!');
                print('   🔵 파란색 박스가 표시된 위치: index=$index');
                print('   📅 대상 날짜: ${date.toString().split(' ')[0]}');
                print('💾 [드롭된 Task 정보]');
                print('   • Task ID: ${droppedTask.id}');
                print('   • Task 제목: ${droppedTask.title}');
                print('   • 드롭된 날짜: ${date.toString().split(' ')[0]}');
                print('   • 드롭된 위치 (index): $index');
                print('');

                // 🎯 즉시 햅틱
                HapticFeedback.heavyImpact();

                // 🔥 새로운 드롭 처리 함수 호출
                await _handleInboxDrop(index, droppedTask, date);

                print(
                  '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
                );

                // 🔥 인박스 바텀시트 투명도 복구 (위젯 재생성 안함)
                if (mounted) {
                  setState(() {
                    _isDraggingFromInbox = false;
                    _hoveredCardIndex = null;
                  });
                }
              },
              builder: (context, candidateData, rejectedData) {
                return RepaintBoundary(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 0,
                      left: 24,
                      right: 24,
                    ),
                    child: GestureDetector(
                      onTap: () => _showHabitDetailModal(habit, date),
                      child: SlidableHabitCard(
                        groupTag: 'unified_list',
                        habitId: habit.id,
                        repeatRule: habit.repeatRule, // 🔄 반복 규칙 전달
                        showConfirmDialog: true, // ✅ 삭제 확인 모달 표시
                        onComplete: () async {
                          // 🎯 햅틱 피드백 추가
                          HapticFeedback.lightImpact();

                          // 애니메이션: 카드 축소 효과
                          setState(() {}); // 리빌드 트리거

                          await GetIt.I<AppDatabase>().recordHabitCompletion(
                            habit.id,
                            date,
                          );
                          print('✅ [HabitCard] 완료 기록: ${habit.title}');
                        },
                        onDelete: () async {
                          await GetIt.I<AppDatabase>().deleteHabit(habit.id);
                          // 🗑️ DailyCardOrder에서도 삭제
                          await GetIt.I<AppDatabase>().deleteCardFromAllOrders(
                            'habit',
                            habit.id,
                          );
                          print('🗑️ [HabitCard] 삭제: ${habit.title}');
                          // ✅ 토스트 표시
                          if (context.mounted) {
                            showActionToast(context, type: ToastType.delete);
                          }
                        },
                        child: HabitCard(
                          habit: habit,
                          isCompleted: false, // TODO: HabitCompletion 확인
                          onToggle: () async {
                            // 🎯 햅틱 피드백 추가
                            HapticFeedback.lightImpact();
                            await GetIt.I<AppDatabase>().recordHabitCompletion(
                              habit.id,
                              date,
                            );
                            print('✅ [HabitCard] 체크박스 완료 기록: ${habit.title}');
                          },
                          onTap: () {
                            print('🔁 [HabitCard] 탭: ${habit.title}');
                            _showHabitDetailModal(habit, date);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ), // DragTarget 닫기
          ], // Column children 닫기
        ); // Column 닫기

      // ====================================================================
      // 📋 인박스 헤더 (Inbox Header)
      // 인박스 모드에서 리스트 맨 위에 표시되는 헤더
      // 상단 42px, 하단 32px, 좌우 32px 패딩 (좌우는 외부 24px + 내부 8px = 32px)
      // ====================================================================
      case UnifiedItemType.inboxHeader:
        return Container(
          key: key,
          padding: const EdgeInsets.fromLTRB(32, 42, 32, 32),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: 1.0,
            child: const Text(
              '1日の流れを\n表現しよ',
              style: TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontWeight: FontWeight.w700,
                fontSize: 19,
                height: 1.4,
                letterSpacing: -0.005 * 19,
                color: Color(0xFFCFCFCF),
              ),
            ),
          ),
        );

      // ====================================================================
      // --- 점선 구분선 (Divider)
      // ====================================================================
      case UnifiedItemType.divider:
        return Padding(
          key: key,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: const DashedDivider(),
        );

      // ====================================================================
      // 🎯 드래그 플레이스홀더 (Placeholder)
      // ====================================================================
      case UnifiedItemType.placeholder:
        return SizedBox(
          key: key,
          height: 64, // 카드 높이만큼 투명한 공간
          width: double.infinity,
        );

      // ====================================================================
      // 📦 완료 섹션 (Completed) - 완료 박스 + 펼치기/접기
      // ====================================================================
      // � 완료 섹션 (Completed) - 리스트 밖에서 렌더링되므로 여기서는 제거
      // ====================================================================
      case UnifiedItemType.completed:
        // 완료 섹션은 AnimatedReorderableListView 밖에서 별도 렌더링
        return SizedBox.shrink(key: key);
    }
  }

  // ============================================================================
  // ⭐️ iOS 네이티브 스타일 상세 페이지 열기 함수들
  // ============================================================================

  /// 일정 상세 Wolt 모달 열기
  void _openScheduleDetail(ScheduleData schedule) {
    debugPrint('🎯 [DateDetailView] 일정 상세 열기: ${schedule.summary}');

    // 🎯 바텀시트 열림 표시 + 드래그 오프셋 리셋
    setState(() {
      _isBottomSheetOpen = true;
      _dragOffset = 0.0; // 🚫 드래그 오프셋 강제 리셋
    });
    debugPrint('✅ [MODAL OPEN] _isBottomSheetOpen = true, _dragOffset = 0.0');

    showScheduleDetailWoltModal(
      context,
      schedule: schedule,
      selectedDate: _currentDate, // ✅ 수정: 사용자가 보고 있는 날짜 전달
    ).whenComplete(() {
      debugPrint('🔥 [MODAL CLOSE] whenComplete 콜백 시작');
      // 🎯 바텀시트 닫힘 표시
      // 🔥 약간의 지연 추가: 바텀시트 애니메이션 완료 후 드래그 활성화
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          debugPrint('🔥 [MODAL CLOSE] 300ms 지연 후 콜백 실행');
          if (mounted) {
            setState(() {
              _isBottomSheetOpen = false;
            });
            debugPrint('✅ [MODAL CLOSE] _isBottomSheetOpen = false (지연 후)');
          }
        });
      }
    });
  }

  /// 할일 상세 - Wolt Modal로 변경
  void _openTaskDetail(TaskData task) {
    print('🎯 [DateDetailView] 할일 상세 열기: ${task.title}');

    // 🎯 바텀시트 열림 표시 + 드래그 오프셋 리셋
    setState(() {
      _isBottomSheetOpen = true;
      _dragOffset = 0.0; // 🚫 드래그 오프셋 강제 리셋
    });

    showTaskDetailWoltModal(
      context,
      task: task,
      selectedDate: _currentDate, // ✅ 이미 올바름
    ).whenComplete(() {
      // 🎯 바텀시트 닫힘 표시
      // 🔥 약간의 지연 추가: 바텀시트 애니메이션 완료 후 드래그 활성화
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _isBottomSheetOpen = false;
            });
          }
        });
      }
    });
  }

  /// ✅ Wolt 습관 상세 모달 표시
  /// Figma 스펙을 100% 구현한 WoltModalSheet 기반 습관 상세 화면
  void _showHabitDetailModal(HabitData habit, DateTime date) {
    print('🎯 [DateDetailView] Wolt 습관 상세 열기: ${habit.title}');

    // 🎯 바텀시트 열림 표시 + 드래그 오프셋 리셋
    setState(() {
      _isBottomSheetOpen = true;
      _dragOffset = 0.0; // 🚫 드래그 오프셋 강제 리셋
    });

    showHabitDetailWoltModal(
      context,
      habit: habit,
      selectedDate: date,
    ).whenComplete(() {
      // 🎯 바텀시트 닫힘 표시
      // 🔥 약간의 지연 추가: 바텀시트 애니메이션 완료 후 드래그 활성화
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _isBottomSheetOpen = false;
            });
          }
        });
      }
    });
  }

  /// 스케줄 리스트를 구성하는 함수 (삭제됨 - _buildUnifiedList 사용)

  // ============================================================================
  //  ANIMATED_REORDERABLE_LIST 마이그레이션 - 새로운 함수들
  // ============================================================================
  //
  // ⚠️ **중요: 기존 _buildUnifiedList() 함수는 건들지 않고 새로운 함수 추가!**
  // - 이 함수들은 AnimatedReorderableListView 방식을 구현
  // - DailyCardOrder 테이블을 사용해 날짜별 순서 관리
  // - 기존 카드 컴포넌트 (ScheduleCard, TaskCard, HabitCard)는 그대로 재사용
  // - Slidable 래퍼도 그대로 유지

  /// 요일을 일본어로 포맷팅 (金曜日)
  String _formatDayOfWeek(DateTime date) {
    final formatter = DateFormat('EEEE', 'ja_JP'); // 일본어 요일
    return formatter.format(date);
  }

  /// 날짜가 오늘인지 확인
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 통합 아이템 리스트 생성 (DailyCardOrder 우선, 없으면 기본 순서)
  /// 이거를 설정하고 → DailyCardOrder 테이블에서 커스텀 순서를 조회해서
  /// 이거를 해서 → 있으면 커스텀 순서로, 없으면 기본 순서(createdAt)로 표시하고
  /// 이거는 이래서 → 사용자가 재정렬한 순서를 복원하거나 초기 상태를 보여준다
  Future<List<UnifiedListItem>> _buildUnifiedItemList(
    DateTime date,
    List<ScheduleData> schedules,
    List<TaskData> tasks,
    List<HabitData> habits,
  ) async {
    print('🔄 [_buildUnifiedItemList] 시작: ${date.toString().split(' ')[0]}');
    print(
      '  📊 입력 데이터: 일정=${schedules.length}, 할일=${tasks.length}, 습관=${habits.length}',
    );

    // 🎯 완료된 습관 ID 조회 (HabitCompletion 테이블)
    final completedHabits = await GetIt.I<AppDatabase>()
        .watchCompletedHabitsByDay(date)
        .first;
    final completedHabitIds = completedHabits.map((h) => h.id).toSet();
    print('  📊 완료된 습관: ${completedHabitIds.length}개');

    // 미완료 습관만 필터링
    final incompleteHabits = habits
        .where((h) => !completedHabitIds.contains(h.id))
        .toList();
    print('  📊 미완료 습관: ${incompleteHabits.length}개');

    // 이거를 설정하고 → DailyCardOrder 테이블 조회해서
    // 이거를 해서 → 사용자 커스텀 순서가 있는지 확인한다
    final cardOrders = await GetIt.I<AppDatabase>()
        .watchDailyCardOrder(date)
        .first;

    print('  → DailyCardOrder 레코드: ${cardOrders.length}개');

    List<UnifiedListItem> items = [];

    // 🎯 일반 모드에서는 맨 처음에 DateDetailHeader 추가
    if (!_isInboxMode) {
      print('  → 📅 날짜 헤더 추가 (일반 모드)');
      items.add(
        UnifiedListItem.dateHeader(
          date: date,
          sortOrder: -1000, // 맨 앞에 위치
        ),
      );
    }

    if (cardOrders.isEmpty) {
      // ========================================================================
      // 케이스 1: 커스텀 순서 없음 → 기본 순서 (일정 → 할일 → 습관)
      // ========================================================================
      print('  → [기본 순서] createdAt 기준으로 생성');

      int order = 0;

      // 1️⃣ 일정 추가 (시간순, 미완료만)
      final incompleteSchedules = schedules.where((s) => !s.completed).toList();
      print('  → 일정 추가 중... (미완료: ${incompleteSchedules.length}개)');
      for (final schedule in incompleteSchedules) {
        print('    ✅ 일정 추가: "${schedule.summary}" (order=$order)');
        items.add(UnifiedListItem.fromSchedule(schedule, sortOrder: order++));
      }

      // 2️⃣ 점선 구분선 (일정 섹션 종료)
      if (incompleteSchedules.isNotEmpty) {
        print('    ➖ 구분선 추가 (order=$order)');
        items.add(UnifiedListItem.divider(sortOrder: order++));
      }

      // 3️⃣ 할일 추가 (미완료만, createdAt 순)
      final incompleteTasks = tasks.where((t) => !t.completed).toList();
      print('  → 할일 추가 중... (미완료: ${incompleteTasks.length}개)');
      for (final task in incompleteTasks) {
        print('    ✅ 할일 추가: "${task.title}" (order=$order)');
        items.add(UnifiedListItem.fromTask(task, sortOrder: order++));
      }

      // 4️⃣ 습관 추가 (미완료만, createdAt 순)
      // 🎯 완료된 습관은 완료 박스에만 표시되므로 여기서는 제외
      print('  → 습관 추가 중... (미완료: ${incompleteHabits.length}개)');
      for (final habit in incompleteHabits) {
        print('    ✅ 습관 추가: "${habit.title}" (order=$order)');
        items.add(UnifiedListItem.fromHabit(habit, sortOrder: order++));
      }

      // 🚫 완료된 할일/습관은 리스트에서 제거! 완료 박스에만 표시됨
      print('  → ✅ 완료된 항목은 완료 섹션에만 표시 (리스트에서 제외)');

      print('  → 기본 순서 생성 완료: ${items.length}개 아이템');
    } else {
      // ========================================================================
      // 케이스 2: 커스텀 순서 있음 → DailyCardOrder 기준으로 복원
      // ========================================================================
      print('  → [커스텀 순서] DailyCardOrder 기준으로 복원');

      // 🔍 검증: DB에 있는 항목이 DailyCardOrder에 모두 있는지 확인
      final scheduleIds = schedules.map((s) => s.id).toSet();
      final taskIds = tasks.map((t) => t.id).toSet();
      final habitIds = habits.map((h) => h.id).toSet();

      final orderScheduleIds = cardOrders
          .where((o) => o.cardType == 'schedule')
          .map((o) => o.cardId)
          .toSet();
      final orderTaskIds = cardOrders
          .where((o) => o.cardType == 'task')
          .map((o) => o.cardId)
          .toSet();
      final orderHabitIds = cardOrders
          .where((o) => o.cardType == 'habit')
          .map((o) => o.cardId)
          .toSet();

      // 누락된 항목 체크
      final missingSchedules = scheduleIds.difference(orderScheduleIds);
      final missingTasks = taskIds.difference(orderTaskIds);
      final missingHabits = habitIds.difference(orderHabitIds);

      if (missingSchedules.isNotEmpty ||
          missingTasks.isNotEmpty ||
          missingHabits.isNotEmpty) {
        print('  ⚠️ DailyCardOrder에 누락된 항목 발견!');
        print('     누락 일정: $missingSchedules');
        print('     누락 할일: $missingTasks');
        print('     누락 습관: $missingHabits');
        print('  🔄 DailyCardOrder 초기화 → 기본 순서로 복원');

        // DailyCardOrder 삭제 (비동기 처리)
        GetIt.I<AppDatabase>().resetDailyCardOrder(date);

        // 기본 순서로 폴백
        int order = 0;
        final incompleteSchedules = schedules
            .where((s) => !s.completed)
            .toList();
        for (final schedule in incompleteSchedules) {
          print('    ✅ 일정 추가: "${schedule.summary}" (order=$order)');
          items.add(UnifiedListItem.fromSchedule(schedule, sortOrder: order++));
        }
        if (incompleteSchedules.isNotEmpty) {
          print('    ➖ 구분선 추가 (order=$order)');
          items.add(UnifiedListItem.divider(sortOrder: order++));
        }
        final incompleteTasks = tasks.where((t) => !t.completed).toList();
        for (final task in incompleteTasks) {
          print('    ✅ 할일 추가: "${task.title}" (order=$order)');
          items.add(UnifiedListItem.fromTask(task, sortOrder: order++));
        }
        for (final habit in incompleteHabits) {
          print('    ✅ 습관 추가: "${habit.title}" (order=$order)');
          items.add(UnifiedListItem.fromHabit(habit, sortOrder: order++));
        }
        // 🚫 완료된 할일/습관은 리스트에서 제거! 완료 박스에만 표시됨
        print('  → ✅ 완료된 항목은 완료 섹션에만 표시 (리스트에서 제외)');
        print('  → 기본 순서로 복원 완료: ${items.length}개 아이템');
        return items;
      }

      // 이거를 설정하고 → cardOrders를 순회하면서
      // 이거를 해서 → 실제 데이터와 JOIN해서 UnifiedListItem 생성한다
      for (final orderData in cardOrders) {
        print(
          '    🔍 처리 중: ${orderData.cardType} (id=${orderData.cardId}, order=${orderData.sortOrder})',
        );

        if (orderData.cardType == 'schedule') {
          // Schedule 찾기 (🎯 완료된 Schedule는 제외)
          try {
            final schedule = schedules.firstWhere(
              (s) => s.id == orderData.cardId,
            );
            if (!schedule.completed) {
              // 미완료만 추가
              print('      ✅ Schedule 추가: "${schedule.summary}"');
              items.add(
                UnifiedListItem.fromSchedule(
                  schedule,
                  sortOrder: orderData.sortOrder,
                ),
              );
            } else {
              print('      🚫 완료된 Schedule 제외: "${schedule.summary}"');
            }
          } catch (e) {
            print('      ⚠️ Schedule not found: ${orderData.cardId}');
          }
        } else if (orderData.cardType == 'task') {
          // Task 찾기 (🎯 완료된 Task는 제외)
          try {
            final task = tasks.firstWhere((t) => t.id == orderData.cardId);
            if (!task.completed) {
              // 미완료만 추가
              print('      ✅ Task 추가: "${task.title}"');
              items.add(
                UnifiedListItem.fromTask(task, sortOrder: orderData.sortOrder),
              );
            } else {
              print('      🚫 완료된 Task 제외: "${task.title}"');
            }
          } catch (e) {
            print('      ⚠️ Task not found: ${orderData.cardId}');
          }
        } else if (orderData.cardType == 'habit') {
          // Habit 찾기 (완료된 습관 제외)
          try {
            final habit = incompleteHabits.firstWhere(
              (h) => h.id == orderData.cardId,
            );
            print('      ✅ Habit 추가: "${habit.title}"');
            items.add(
              UnifiedListItem.fromHabit(habit, sortOrder: orderData.sortOrder),
            );
          } catch (e) {
            print('      ⚠️ Habit not found or completed: ${orderData.cardId}');
          }
        }
      }

      // 이거를 설정하고 → sortOrder 기준으로 정렬해서
      // 이거를 해서 → DB에 저장된 순서대로 표시한다
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      // 이거를 설정하고 → 점선 구분선을 동적으로 삽입해서
      // 이거를 해서 → 일정 섹션과 나머지 섹션을 구분한다
      // 이거는 이래서 → 재정렬 후에도 점선 위치가 자동으로 조정된다
      final lastScheduleIndex = items.lastIndexWhere(
        (item) => item.type == UnifiedItemType.schedule,
      );

      if (lastScheduleIndex != -1) {
        // 일정이 있으면 마지막 일정 다음에 점선 삽입
        print('    ➖ 구분선 삽입: index=${lastScheduleIndex + 1}');
        items.insert(
          lastScheduleIndex + 1,
          UnifiedListItem.divider(sortOrder: lastScheduleIndex + 1),
        );
      }

      // 완료된 할일을 하단에 추가 (완료 섹션 박스 없이)
      final completedTasks = tasks.where((t) => t.completed).toList();
      if (completedTasks.isNotEmpty) {
        print('  → 완료된 할일 추가 중... (${completedTasks.length}개)');
        for (final task in completedTasks) {
          print('    ✅ 완료된 할일 추가: "${task.title}"');
          items.add(UnifiedListItem.fromTask(task, sortOrder: items.length));
        }
      }

      print('  → 커스텀 순서 복원 완료: ${items.length}개 아이템');
    }

    // ========================================================================
    // ✅ 완료 섹션은 리스트 밖에서 별도로 렌더링 (AnimatedReorderableListView 외부)
    // ========================================================================

    print('✅ [_buildUnifiedItemList] 완료: ${items.length}개 아이템 생성');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 [최종 생성된 리스트]');
    for (int i = 0; i < items.length; i++) {
      final typeEmoji = items[i].type == UnifiedItemType.schedule
          ? '📅'
          : items[i].type == UnifiedItemType.task
          ? '✅'
          : items[i].type == UnifiedItemType.habit
          ? '🔁'
          : items[i].type == UnifiedItemType.divider
          ? '━'
          : items[i].type == UnifiedItemType.dateHeader
          ? '📆'
          : '❓';

      final title = items[i].type == UnifiedItemType.schedule
          ? (items[i].data as ScheduleData).summary
          : items[i].type == UnifiedItemType.task
          ? (items[i].data as TaskData).title
          : items[i].type == UnifiedItemType.habit
          ? (items[i].data as HabitData).title
          : items[i].type == UnifiedItemType.divider
          ? '━━━━ 구분선 ━━━━'
          : items[i].type == UnifiedItemType.dateHeader
          ? '날짜 헤더'
          : '알 수 없음';

      print(
        '  [$i] $typeEmoji ${items[i].type.toString().padRight(30)} | sortOrder=${items[i].sortOrder.toString().padLeft(6)} | "$title"',
      );
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return items;
  }

  /// 재정렬 핸들러
  /// 이거를 설정하고 → 드래그앤드롭으로 아이템 순서가 바뀔 때 호출되어
  /// 이거를 해서 → sortOrder를 재계산하고 DB에 저장하고
  /// 이거는 이래서 → 앱을 재시작해도 순서가 유지된다
  void _handleReorder(List<UnifiedListItem> items, int oldIndex, int newIndex) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔄 [REORDER START] $oldIndex → $newIndex');
    print('   📋 인박스 모드: $_isInboxMode');
    print('   📅 현재 날짜: ${_currentDate.toString().split(' ')[0]}');
    print('   📊 아이템 개수: ${items.length}');
    print('');

    // 🔍 디바이더 위치 찾기
    final dividerIndex = items.indexWhere(
      (i) => i.type == UnifiedItemType.divider,
    );
    print('📍 디바이더 인덱스: $dividerIndex');
    print('');

    // 🔍 이동 전 전체 리스트 출력
    print('📋 [이동 전] 전체 리스트:');
    for (int i = 0; i < items.length; i++) {
      final marker = i == oldIndex
          ? '👉 [이동할 아이템]'
          : i == dividerIndex
          ? '━━━━ [디바이더] ━━━━'
          : '';
      final typeEmoji = items[i].type == UnifiedItemType.schedule
          ? '📅'
          : items[i].type == UnifiedItemType.task
          ? '✅'
          : items[i].type == UnifiedItemType.habit
          ? '🔁'
          : items[i].type == UnifiedItemType.divider
          ? '━'
          : '❓';
      print(
        '  [$i] $typeEmoji ${items[i].type.toString().padRight(25)} | ${items[i].uniqueId} $marker',
      );
    }
    print('');

    // 이거를 설정하고 → iOS 스타일 햅틱 피드백을 추가해서
    // 이거를 해서 → 드래그 시작 시 촉각 피드백을 준다
    HapticFeedback.mediumImpact();

    // ✅ setState 최적화: AnimatedReorderableListView가 자체적으로 UI를 업데이트하므로
    // 여기서는 데이터만 변경하고 setState는 호출하지 않음
    // 이거를 설정하고 → newIndex 조정 로직을 적용해서
    // 이거를 해서 → AnimatedReorderableListView의 동작과 일치시킨다
    final originalNewIndex = newIndex;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    print('🎯 조정된 newIndex: $originalNewIndex → $newIndex');
    print('');

    // 🔍 디바이더 경계 체크
    final movedItem = items[oldIndex];
    final crossingDivider =
        dividerIndex != -1 &&
        ((oldIndex < dividerIndex && newIndex >= dividerIndex) ||
            (oldIndex > dividerIndex && newIndex <= dividerIndex));

    print('🔍 [경계 분석]');
    print('  • 이동 아이템: ${movedItem.type} (${movedItem.uniqueId})');
    print('  • oldIndex < 디바이더: ${oldIndex < dividerIndex}');
    print('  • newIndex < 디바이더: ${newIndex < dividerIndex}');
    print('  • 디바이더 넘어감: ${crossingDivider ? "⚠️ YES" : "✅ NO"}');

    if (dividerIndex != -1) {
      if (oldIndex == dividerIndex - 1) {
        print('  • ⚠️ 디바이더 바로 위에서 이동');
      }
      if (oldIndex == dividerIndex + 1) {
        print('  • ⚠️ 디바이더 바로 아래서 이동');
      }
      if (newIndex == dividerIndex - 1) {
        print('  • ⚠️ 디바이더 바로 위로 이동');
      }
      if (newIndex == dividerIndex + 1) {
        print('  • ⚠️ 디바이더 바로 아래로 이동');
      }
    }
    print('');

    // 이거를 설정하고 → 아이템을 이동시켜서
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // � 디바이더 위치 재조정
    // 이거를 설정하고 → 이동 후 기존 디바이더를 제거하고
    // 이거를 해서 → 마지막 일정 다음에 다시 삽입한다
    // 이거는 이래서 → 일정과 할일/습관이 항상 분리된 상태를 유지한다
    final oldDividerIndex = items.indexWhere(
      (i) => i.type == UnifiedItemType.divider,
    );
    if (oldDividerIndex != -1) {
      items.removeAt(oldDividerIndex);
      print('  🗑️ 기존 디바이더 제거 (index: $oldDividerIndex)');
    }

    final lastScheduleIndex = items.lastIndexWhere(
      (item) => item.type == UnifiedItemType.schedule,
    );

    if (lastScheduleIndex != -1) {
      items.insert(
        lastScheduleIndex + 1,
        UnifiedListItem.divider(sortOrder: lastScheduleIndex + 1),
      );
      print('  ➕ 새 디바이더 삽입 (index: ${lastScheduleIndex + 1})');
    }

    // �🔍 이동 후 디바이더 위치 재확인
    final newDividerIndex = items.indexWhere(
      (i) => i.type == UnifiedItemType.divider,
    );

    print('📋 [이동 후] 전체 리스트:');
    for (int i = 0; i < items.length; i++) {
      final marker = i == newIndex
          ? '👈 [이동 완료]'
          : i == newDividerIndex
          ? '━━━━ [디바이더] ━━━━'
          : '';
      final typeEmoji = items[i].type == UnifiedItemType.schedule
          ? '📅'
          : items[i].type == UnifiedItemType.task
          ? '✅'
          : items[i].type == UnifiedItemType.habit
          ? '🔁'
          : items[i].type == UnifiedItemType.divider
          ? '━'
          : '❓';
      print(
        '  [$i] $typeEmoji ${items[i].type.toString().padRight(25)} | ${items[i].uniqueId} $marker',
      );
    }
    print('');

    if (dividerIndex != newDividerIndex) {
      print('✅ 디바이더 위치 조정됨: $dividerIndex → $newDividerIndex');
      print('');
    }

    // 이거를 설정하고 → 전체 리스트의 sortOrder를 재계산해서
    // 이거를 해서 → 모든 아이템이 올바른 순서를 가지도록 한다
    for (int i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(sortOrder: i);
    }
    print('  → sortOrder 재계산 완료 (0~${items.length - 1})');

    // ⏱️ 디바운스를 사용해 DB 저장 (300ms 후 저장)
    // 이거를 해서 → 여러 번 드래그할 때 DB 저장을 모아서 한 번만 실행
    _saveOrderDebounceTimer?.cancel();
    _saveOrderDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      print('⏰ [Reorder] 디바운스 타이머 실행 → DB 저장 시작');
      _saveDailyCardOrder(items);
    });
    print('  → 디바운스 타이머 설정됨 (300ms)');

    // 이거를 설정하고 → 드롭 완료 시 가벼운 햅틱 피드백을 추가해서
    // 이거를 해서 → 사용자에게 재정렬 완료를 알린다
    Future.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.lightImpact();
    });

    print('✅ [Reorder] 완료 (DB 저장은 디바운스 후)');
  }

  /// 🔥 인박스에서 드롭 시 특정 위치에 삽입 (클래스 메서드)
  /// dropIndex: UI에서의 인덱스 (allItems 기준)
  /// task: 드롭된 Task 데이터
  /// date: 대상 날짜
  Future<void> _handleInboxDropToPosition(
    int dropIndex,
    TaskData task,
    DateTime date,
  ) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔥 [카드 사이 드롭 처리 시작]');
    print('   • Task ID: ${task.id}');
    print('   • Task 제목: ${task.title}');
    print('   • UI 드롭 위치 (index): $dropIndex');
    print('   • 대상 날짜: ${date.toString().split(' ')[0]}');
    print('');

    // [1단계] 먼저 현재 날짜의 데이터를 sortOrder와 함께 로드 (날짜 변경 전!)
    print('💾 [1단계] 현재 날짜의 일정/할일/습관 로드 (sortOrder 포함) - 날짜 변경 전!');
    final db = GetIt.I<AppDatabase>();

    final schedules = await db.watchSchedulesWithRepeat(date).first;
    final tasks = await db.watchTasksWithRepeat(date).first;
    final habits = await db.watchHabitsWithRepeat(date).first;

    print('   • 일정: ${schedules.length}개');
    print('   • 할일: ${tasks.length}개 (드롭될 Task 아직 포함 안됨)');
    print('   • 습관: ${habits.length}개');

    // [2단계] 현재 순서대로 UnifiedListItem 생성 (sortOrder 기반)
    print('💾 [2단계] sortOrder 기반으로 현재 리스트 구성');
    var currentItems = await _buildUnifiedItemList(
      date,
      schedules,
      tasks,
      habits,
    );

    // 🔥 [중요] 인박스 모드일 때 inboxHeader 추가 (UI와 동일하게 맞추기)
    // UI에서는 line 1073-1078에서 inboxHeader가 prepend되므로, 여기서도 동일하게 처리
    if (_isInboxMode &&
        (currentItems.isEmpty ||
            currentItems.first.type != UnifiedItemType.inboxHeader)) {
      print('   🎯 [인박스 모드] inboxHeader 추가 (UI와 일치시키기)');
      currentItems = [
        UnifiedListItem.inboxHeader(sortOrder: -1000),
        ...currentItems,
      ];
    }

    print('   • 전체 currentItems 길이: ${currentItems.length}');

    // dateHeader, divider, completed, inboxHeader 제외한 실제 데이터만
    // 🔥 드롭될 Task는 아직 날짜가 변경되지 않았으므로 currentItems에 포함되지 않음
    final actualDataItems = currentItems
        .where(
          (item) =>
              item.type != UnifiedItemType.dateHeader &&
              item.type != UnifiedItemType.divider &&
              item.type != UnifiedItemType.completed &&
              item.type != UnifiedItemType.inboxHeader,
        )
        .toList();

    print('   • 실제 데이터 아이템 수 (헤더/구분선/드롭Task 제외): ${actualDataItems.length}');
    print('   • 받은 dropIndex (currentItems 기준): $dropIndex');

    // 🔥 [핵심] dropIndex를 actualDataItems 기준으로 변환
    // 🎯 명확한 계산: dropIndex 이전의 실제 데이터 아이템 개수를 센다
    int actualDropIndex = 0;

    if (dropIndex < currentItems.length) {
      final targetItem = currentItems[dropIndex];
      print(
        '   • dropIndex가 가리키는 아이템: ${targetItem.type} / ${targetItem.uniqueId}',
      );

      // 🎯 상세 계산 로그: dropIndex 이전의 모든 아이템 출력
      print('   🔍 [계산 과정] dropIndex($dropIndex) 이전의 아이템들:');
      int dataItemCountBefore = 0;
      for (int i = 0; i < dropIndex; i++) {
        final item = currentItems[i];
        final isDataItem =
            item.type != UnifiedItemType.dateHeader &&
            item.type != UnifiedItemType.divider &&
            item.type != UnifiedItemType.completed &&
            item.type != UnifiedItemType.inboxHeader;

        if (isDataItem) {
          print('      [$i] ${item.type} ✅ → count=${dataItemCountBefore + 1}');
          dataItemCountBefore++;
        } else {
          print('      [$i] ${item.type} ⏭️ (제외)');
        }
      }

      actualDropIndex = dataItemCountBefore;
      print('');
      print('   🎯 최종 계산 결과:');
      print('      • dropIndex (UI 리스트): $dropIndex');
      print('      • actualDropIndex (데이터 리스트): $actualDropIndex');
      print('      • 의미: actualDataItems[$actualDropIndex] 위치에 삽입');

      // 🔥 추가 검증: 범위 체크 (안전장치)
      if (actualDropIndex > actualDataItems.length) {
        print(
          '   ⚠️ actualDropIndex($actualDropIndex) > 실제 데이터 개수(${actualDataItems.length}) → 맨 끝으로 조정',
        );
        actualDropIndex = actualDataItems.length;
      }

      // 🎯 삽입 예상 위치 미리보기
      print('');
      print('   📋 [삽입 위치 미리보기]:');
      for (int i = 0; i < actualDataItems.length; i++) {
        if (i == actualDropIndex) {
          print('      [$i] ➡️ [여기에 새 Task 삽입!] ⬅️');
        }
        final typeEmoji = actualDataItems[i].type == UnifiedItemType.schedule
            ? '📅'
            : actualDataItems[i].type == UnifiedItemType.task
            ? '✅'
            : '🔁';
        print('      [$i] $typeEmoji ${actualDataItems[i].uniqueId}');
      }
      if (actualDropIndex >= actualDataItems.length) {
        print('      [$actualDropIndex] ➡️ [여기에 새 Task 삽입!] (맨 끝) ⬅️');
      }
    } else {
      // 범위 밖이면 맨 끝
      actualDropIndex = actualDataItems.length;
      print('   ⚠️ 범위 밖 → 맨 끝으로 설정');
    }

    // 🔥 수정: actualDropIndex는 이미 올바른 삽입 위치를 가리킴
    // _buildBetweenCardDropZone은 "카드 위쪽"에 드롭하는 것이고,
    // List.insert(index, element)는 해당 index에 삽입하여 기존 요소를 뒤로 미룸
    // 예: [A, B, C].insert(1, X) → [A, X, B, C] (B 앞에 삽입)
    // 따라서 actualDropIndex를 그대로 사용하면 정확한 위치에 삽입됨
    // 이전의 -1 로직은 3개 이하일 때 잘못된 위치에 삽입되는 원인이었음

    print('   🎯 최종 삽입 위치 (actualDataItems 기준): $actualDropIndex');
    print('');

    // [3단계] Task 날짜 변경
    print('💾 [3단계] Task 날짜 변경 (인덱스 계산 후)');
    await GetIt.I<AppDatabase>().updateTaskDate(task.id, date);
    print('   ✅ Task #${task.id} 날짜 변경 완료');
    print('');

    // [4단계] 전체 리스트에 새 Task 추가
    print('💾 [4단계] 정확한 위치에 새 Task 추가');
    final updatedItems = List<UnifiedListItem>.from(actualDataItems);

    // 🔥 DB에서 실제 Task 데이터 다시 로드 (날짜 변경 후)
    final taskFromDb = await GetIt.I<AppDatabase>().getTaskById(task.id);
    if (taskFromDb == null) {
      print('   ❌ Task를 DB에서 찾을 수 없음');
      return;
    }

    // 새 Task 아이템 생성
    final newTaskItem = UnifiedListItem.fromTask(
      taskFromDb,
      sortOrder: actualDropIndex,
    );

    print('   📊 현재 리스트 길이: ${updatedItems.length}');
    print('   📍 삽입 위치 (actualDataItems 기준): $actualDropIndex');

    // 원하는 위치에 삽입
    if (actualDropIndex >= updatedItems.length) {
      updatedItems.add(newTaskItem);
      print('   ➕ 맨 끝에 추가 (index ${updatedItems.length - 1})');
    } else {
      updatedItems.insert(actualDropIndex, newTaskItem);
      print('   ➕ index $actualDropIndex에 삽입');
    }

    print('   📊 삽입 후 길이: ${updatedItems.length}');
    print('');

    // [5단계] sortOrder를 0부터 순차적으로 재계산
    print('🔢 [5단계] sortOrder 재계산 (0부터 순차)');
    for (int i = 0; i < updatedItems.length; i++) {
      updatedItems[i] = updatedItems[i].copyWith(sortOrder: i);
    }

    // 재계산된 리스트 출력
    print('📋 [재계산된 전체 순서]:');
    for (int i = 0; i < updatedItems.length; i++) {
      final marker = updatedItems[i].uniqueId.contains('task_${task.id}')
          ? '🔥 [방금 추가!]'
          : '';
      final typeEmoji = updatedItems[i].type == UnifiedItemType.schedule
          ? '📅'
          : updatedItems[i].type == UnifiedItemType.task
          ? '✅'
          : updatedItems[i].type == UnifiedItemType.habit
          ? '🔁'
          : '❓';
      print(
        '  [$i] $typeEmoji sortOrder=$i | ${updatedItems[i].uniqueId} $marker',
      );
    }
    print('');

    // [6단계] DB에 전체 순서 저장
    print('💾 [6단계] DB에 전체 순서 저장');
    await _saveDailyCardOrder(updatedItems);

    print('✅ [카드 사이 드롭 처리 완료!]');
    print('   • Task ID: ${task.id}');
    print('   • 받은 dropIndex: $dropIndex');
    print('   • 최종 삽입 위치: $actualDropIndex');
    print('   • 날짜: ${date.toString().split(' ')[0]}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// DB에 순서 저장
  /// 이거를 설정하고 → UnifiedListItem 리스트를 DB 형식으로 변환해서
  /// 이거를 해서 → DailyCardOrder 테이블에 저장하고
  /// 이거는 이래서 → 다음에 화면을 열 때 같은 순서로 복원된다
  Future<void> _saveDailyCardOrder(List<UnifiedListItem> items) async {
    print('💾 [_saveDailyCardOrder] DB 저장 시작');
    print('   📋 인박스 모드: $_isInboxMode');
    print('   📅 저장할 날짜: ${_currentDate.toString().split(' ')[0]}');
    print('   📊 전체 아이템: ${items.length}개');

    // 이거를 설정하고 → divider와 completed는 제외하고
    // 이거를 해서 → 실제 카드 데이터만 DB에 저장한다
    final dataToSave = items
        .where(
          (item) =>
              item.type != UnifiedItemType.divider &&
              item.type != UnifiedItemType.completed,
        )
        .map((item) => item.toMap())
        .toList();

    print('  → 저장할 카드: ${dataToSave.length}개');

    // 저장될 데이터 미리보기
    for (int i = 0; i < dataToSave.length && i < 5; i++) {
      final card = dataToSave[i];
      print(
        '     [$i] type=${card['type']}, id=${card['id']}, sortOrder=${card['sortOrder']}',
      );
    }
    if (dataToSave.length > 5) print('     ... (${dataToSave.length - 5}개 더)');

    try {
      await GetIt.I<AppDatabase>().saveDailyCardOrder(_currentDate, dataToSave);
      print('✅ [_saveDailyCardOrder] 저장 완료');
    } catch (e) {
      print('❌ [_saveDailyCardOrder] 저장 실패: $e');
      print('   스택 트레이스: ${StackTrace.current}');
    }
  }

  // ============================================================================
  // ✅ 완료 섹션 UI 빌더
  // ============================================================================

  /// 완료된 항목 리스트 빌드 (타입별로 구분)
  /// Figma: Frame 681 (gap: 26px between sections)
  Widget _buildCompletedItems(
    List<ScheduleData> completedSchedules,
    List<TaskData> completedTasks,
    List<HabitData> completedHabits,
    DateTime date,
  ) {
    // 모든 완료된 항목을 하나의 리스트로 통합
    final List<Widget> allCompletedItems = [];

    // ===================================================================
    // スケジュール (일정)
    // ===================================================================
    if (completedSchedules.isNotEmpty) {
      allCompletedItems.add(
        const SizedBox(key: ValueKey('schedule_spacer_top'), height: 16),
      );
      allCompletedItems.add(
        Container(
          key: const ValueKey('schedule_header'),
          width: 345,
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text(
            'スケジュール',
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005 * 16,
              color: Color(0xFF262626),
            ),
          ),
        ),
      );
      allCompletedItems.add(
        const SizedBox(key: ValueKey('schedule_spacer'), height: 10),
      );
      for (final schedule in completedSchedules) {
        allCompletedItems.add(
          Padding(
            key: ValueKey('schedule_${schedule.id}'),
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildSwipeableCompletedSchedule(schedule, date),
          ),
        );
      }
    }

    // ===================================================================
    // タスク (할일)
    // ===================================================================
    if (completedTasks.isNotEmpty) {
      allCompletedItems.add(
        const SizedBox(key: ValueKey('task_spacer_top'), height: 16),
      );
      allCompletedItems.add(
        Container(
          key: const ValueKey('task_header'),
          width: 345,
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text(
            'タスク',
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005 * 16,
              color: Color(0xFF262626),
            ),
          ),
        ),
      );
      allCompletedItems.add(
        const SizedBox(key: ValueKey('task_spacer'), height: 10),
      );
      for (final task in completedTasks) {
        allCompletedItems.add(
          Padding(
            key: ValueKey('task_${task.id}'),
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildSwipeableCompletedTask(task, date),
          ),
        );
      }
    }

    // ===================================================================
    // 習慣 (습관)
    // ===================================================================
    if (completedHabits.isNotEmpty) {
      allCompletedItems.add(
        SizedBox(
          key: const ValueKey('habit_spacer_top'),
          height: completedTasks.isNotEmpty ? 26 : 16,
        ),
      );
      allCompletedItems.add(
        Container(
          key: const ValueKey('habit_header'),
          width: 345,
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text(
            '習慣',
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.005 * 16,
              color: Color(0xFF262626),
            ),
          ),
        ),
      );
      allCompletedItems.add(
        const SizedBox(key: ValueKey('habit_spacer'), height: 10),
      );
      for (final habit in completedHabits) {
        allCompletedItems.add(
          Padding(
            key: ValueKey('habit_${habit.id}'),
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildSwipeableCompletedHabit(habit, date),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
      child: AnimatedReorderableListView(
        items: allCompletedItems,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        isSameItem: (a, b) => a.key == b.key,
        onReorder: (oldIndex, newIndex) {
          // 드래그 재정렬 비활성화 (아무 동작도 하지 않음)
        },
        enterTransition: [
          ScaleIn(
            duration: const Duration(milliseconds: 300),
            curve: const Cubic(0.25, 0.1, 0.25, 1.0),
            begin: 0.95,
            end: 1.0,
          ),
          FadeIn(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ),
        ],
        exitTransition: [
          ScaleIn(
            duration: const Duration(milliseconds: 300),
            curve: const Cubic(0.4, 0.0, 1.0, 1.0),
            begin: 1.0,
            end: 0.95,
          ),
          FadeIn(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
            begin: 1.0,
            end: 0.0,
          ),
        ],
        insertDuration: const Duration(milliseconds: 300),
        removeDuration: const Duration(milliseconds: 300),
        itemBuilder: (context, index) {
          return allCompletedItems[index];
        },
      ),
    );
  }

  /// 스와이프 가능한 완료된 Schedule 카드
  Widget _buildSwipeableCompletedSchedule(
    ScheduleData schedule,
    DateTime date,
  ) {
    return Slidable(
      key: ValueKey('slidable_schedule_${schedule.id}'),
      closeOnScroll: true,
      // 좌→우: 삭제
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.144,
        dismissible: DismissiblePane(
          onDismissed: () async {
            await HapticFeedback.mediumImpact();
            await GetIt.I<AppDatabase>().deleteSchedule(schedule.id);
            setState(() {});
          },
        ),
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              await HapticFeedback.mediumImpact();
              await GetIt.I<AppDatabase>().deleteSchedule(schedule.id);
              setState(() {});
            },
            backgroundColor: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.symmetric(vertical: 8),
            autoClose: true,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: SvgPicture.asset(
                  'asset/icon/trash_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // 우→좌: 완료 해제
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.144,
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              await HapticFeedback.lightImpact();
              await GetIt.I<AppDatabase>().uncompleteSchedule(schedule.id);
              // setState() 제거 - StreamBuilder가 자동으로 반응
            },
            backgroundColor: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.symmetric(vertical: 8),
            autoClose: true,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0CF20C),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(Icons.undo, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
      child: _buildCompletedScheduleCard(schedule, date),
    );
  }

  /// 스와이프 가능한 완료된 Task 카드
  Widget _buildSwipeableCompletedTask(TaskData task, DateTime date) {
    return Slidable(
      key: ValueKey('slidable_task_${task.id}'),
      closeOnScroll: true,
      // 좌→우: 삭제
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.144,
        dismissible: DismissiblePane(
          onDismissed: () async {
            await HapticFeedback.mediumImpact();
            await GetIt.I<AppDatabase>().deleteTask(task.id);
            setState(() {});
          },
        ),
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              await HapticFeedback.mediumImpact();
              await GetIt.I<AppDatabase>().deleteTask(task.id);
              setState(() {});
            },
            backgroundColor: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.symmetric(vertical: 8),
            autoClose: true,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: SvgPicture.asset(
                  'asset/icon/trash_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // 우→좌: 완료 해제
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.144,
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              await HapticFeedback.lightImpact();
              await GetIt.I<AppDatabase>().uncompleteTask(task.id);
              // setState() 제거 - StreamBuilder가 자동으로 반응
            },
            backgroundColor: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.symmetric(vertical: 8),
            autoClose: true,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0CF20C),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(Icons.undo, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
      child: _buildCompletedTaskCard(task, date),
    );
  }

  /// 스와이프 가능한 완료된 Habit 카드
  Widget _buildSwipeableCompletedHabit(HabitData habit, DateTime date) {
    return Slidable(
      key: ValueKey('slidable_habit_${habit.id}'),
      closeOnScroll: true,
      // 좌→우: 삭제
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.144,
        dismissible: DismissiblePane(
          onDismissed: () async {
            await HapticFeedback.mediumImpact();
            await GetIt.I<AppDatabase>().deleteHabit(habit.id);
            setState(() {});
          },
        ),
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              await HapticFeedback.mediumImpact();
              await GetIt.I<AppDatabase>().deleteHabit(habit.id);
              setState(() {});
            },
            backgroundColor: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.symmetric(vertical: 8),
            autoClose: true,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: SvgPicture.asset(
                  'asset/icon/trash_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // 우→좌: 완료 해제
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.144,
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              await HapticFeedback.lightImpact();
              await GetIt.I<AppDatabase>().deleteHabitCompletion(
                habit.id,
                date,
              );
              // setState() 제거 - StreamBuilder가 자동으로 반응
            },
            backgroundColor: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            padding: const EdgeInsets.symmetric(vertical: 8),
            autoClose: true,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0CF20C),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(Icons.undo, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
      child: _buildCompletedHabitCard(habit, date),
    );
  }

  /// 완료된 Schedule 카드 (체크박스 없음, 반투명만)
  Widget _buildCompletedScheduleCard(ScheduleData schedule, DateTime date) {
    // ScheduleCard를 Opacity + GestureDetector로 감싸서 완료 상태 표시
    return GestureDetector(
      onTap: () {
        _openScheduleDetail(schedule);
      },
      child: Opacity(
        opacity: 0.5, // 완료된 항목은 반투명
        child: ScheduleCard(
          start: schedule.start,
          end: schedule.end,
          summary: schedule.summary,
          colorId: schedule.colorId,
          repeatRule: schedule.repeatRule,
          alertSetting: schedule.alertSetting,
        ),
      ),
    );
  }

  /// 완료된 Task 카드 (취소선 + 녹색 체크박스)
  Widget _buildCompletedTaskCard(TaskData task, DateTime date) {
    return TaskCard(
      task: task,
      onToggle: () async {
        // 🔥 반복 할일인지 확인
        final pattern = await GetIt.I<AppDatabase>().getRecurringPattern(
          entityType: 'task',
          entityId: task.id,
        );

        if (pattern != null) {
          // 🔥 반복 할일: TaskCompletion 삭제
          await GetIt.I<AppDatabase>().deleteTaskCompletion(task.id, date);
          print('🔄 [CompletedTask] 완료 해제: ${task.title} (날짜: $date)');
        } else {
          // 🔥 일반 할일: completed 필드 업데이트
          await GetIt.I<AppDatabase>().uncompleteTask(task.id);
          print('🔄 [CompletedTask] 완료 해제: ${task.title}');
        }
        HapticFeedback.lightImpact();
        // setState() 제거 - StreamBuilder가 자동으로 반응
      },
      onTap: () {
        // 상세 모달 열기
        _openTaskDetail(task);
      },
    );
  }

  /// 완료된 Habit 카드 (취소선 + 녹색 체크박스)
  Widget _buildCompletedHabitCard(HabitData habit, DateTime date) {
    return HabitCard(
      habit: habit,
      isCompleted: true, // 완료된 상태
      onToggle: () async {
        // 완료 해제 (HabitCompletion 삭제)
        await GetIt.I<AppDatabase>().deleteHabitCompletion(habit.id, date);
        print('🔄 [CompletedHabit] 완료 해제: ${habit.title}');
        HapticFeedback.lightImpact();
        // setState() 제거 - StreamBuilder가 자동으로 반응
      },
      onTap: () {
        // 상세 모달 열기
        _showHabitDetailModal(habit, date);
      },
    );
  }

  /// 🎯 최상단 드롭존 (리스트 맨 위에 드롭)
  Widget _buildTopDropZone(DateTime date) {
    return DragTarget<TaskData>(
      onWillAcceptWithDetails: (details) => true,
      onMove: (details) {
        if (mounted && _hoveredCardIndex != -1) {
          setState(() {
            _isDraggingFromInbox = true;
            _hoveredCardIndex = -1;
          });
        }
      },
      onLeave: (data) {
        print('👋 [TopDropZone] 드롭 영역 이탈');
        if (mounted) {
          setState(() => _hoveredCardIndex = null);
        }
      },
      onAcceptWithDetails: (details) async {
        final task = details.data;
        print('✅ [TopDropZone] 최상단 드롭 완료');
        print('💾 [TopDropZone] Task 드롭: ${task.title} → $date (최상단)');

        HapticFeedback.heavyImpact();
        await GetIt.I<AppDatabase>().updateTaskDate(task.id, date);
        await GetIt.I<AppDatabase>().updateCardOrder(date, 'task', task.id, 0);

        print('✅ [TopDropZone] DB 업데이트 완료 (sortOrder=0, 최상단)');

        // 🔥 드래그 종료 - 기존 바텀시트로 복귀 (중복 방지)
        if (mounted) {
          setState(() {
            _isDraggingFromInbox = false;
            _hoveredCardIndex = null;
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isHovered ? 80 : 0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent, // 🎯 투명하게 변경
            border: isHovered
                ? Border.all(color: Colors.transparent, width: 2) // 🎯 투명하게 변경
                : null,
          ),
          child: isHovered
              ? Center(
                  child: Icon(
                    Icons.add_circle_outline,
                    color: Colors.transparent, // 🎯 투명하게 변경
                    size: 32,
                  ),
                )
              : null,
        );
      },
    );
  }

  /// 🎯 카드 사이 드롭존 (카드와 카드 사이에 끼워넣기)
  Widget _buildBetweenCardDropZone(int index, DateTime date, bool isHovered) {
    // 🎯 between-card는 -(index+1000)로 표시 (예: index 5의 위쪽 = -1005)
    final betweenId = -(index + 1000);

    return DragTarget<TaskData>(
      hitTestBehavior: HitTestBehavior.translucent, // 🎯 더 민감한 터치 감지
      onWillAcceptWithDetails: (details) => true,
      onMove: (details) {
        if (mounted && _hoveredCardIndex != betweenId) {
          setState(() {
            _isDraggingFromInbox = true;
            _hoveredCardIndex = betweenId;
          });
        }
      },
      onLeave: (data) {
        print('👋 [BetweenCardDropZone] 카드 사이 이탈');
        if (mounted) {
          setState(() => _hoveredCardIndex = null);
        }
      },
      onAcceptWithDetails: (details) async {
        final task = details.data;
        print('✅ [BetweenCardDropZone] 카드 #$index 위쪽에 드롭 완료');
        print(
          '💾 [BetweenCardDropZone] Task 드롭: ${task.title} → $date (index $index 위쪽)',
        );

        HapticFeedback.heavyImpact();

        // 🔥 Task 날짜 변경 및 순서 재계산
        await _handleInboxDropToPosition(index, task, date);

        // 🔥 드래그 종료 및 UI 갱신
        if (mounted) {
          setState(() {
            _isDraggingFromInbox = false;
            _hoveredCardIndex = null;
          });

          // 🎯 추가: 명시적 상태 새로고침으로 카드 사라짐 방지
          print('🔄 [BetweenCardDropZone] 상태 새로고침 트리거');
          await Future.delayed(const Duration(milliseconds: 50));
          if (mounted) {
            setState(() {
              // 명시적 리빌드 트리거
            });
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: isHovered ? 80 : 0, // 🎯 기본 16px로 더 넓은 감지 영역
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          decoration: isHovered
              ? BoxDecoration(
                  color: Colors.transparent, // 🎯 투명하게 변경
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.transparent, // 🎯 투명하게 변경
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                )
              : null,
          child: isHovered
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: Colors.transparent, // 🎯 투명하게 변경
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ここにドロップ',
                      style: TextStyle(
                        fontFamily: 'LINE Seed JP App_TTF',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.transparent, // 🎯 투명하게 변경
                      ),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  /// 🎯 최하단 드롭존 (리스트 맨 아래에 드롭)
  Widget _buildBottomDropZone(DateTime date) {
    return DragTarget<TaskData>(
      hitTestBehavior: HitTestBehavior.translucent, // 🎯 더 민감한 터치 감지
      onWillAcceptWithDetails: (details) => true,
      onMove: (details) {
        if (mounted && _hoveredCardIndex != 999999) {
          setState(() {
            _isDraggingFromInbox = true;
            _hoveredCardIndex = 999999;
          });
        }
      },
      onLeave: (data) {
        print('👋 [BottomDropZone] 드롭 영역 이탈');
        if (mounted) {
          setState(() => _hoveredCardIndex = null);
        }
      },
      onAcceptWithDetails: (details) async {
        final task = details.data;
        print('✅ [BottomDropZone] 최하단 드롭 완료');
        print('💾 [BottomDropZone] Task 드롭: ${task.title} → $date (최하단)');

        HapticFeedback.heavyImpact();
        await GetIt.I<AppDatabase>().updateTaskDate(task.id, date);
        await GetIt.I<AppDatabase>().updateCardOrder(
          date,
          'task',
          task.id,
          999999000,
        );

        print('✅ [BottomDropZone] DB 업데이트 완료 (sortOrder=999999000, 최하단)');

        // 🔥 드래그 종료 - 기존 바텀시트로 복귀 (중복 방지)
        if (mounted) {
          setState(() {
            _isDraggingFromInbox = false;
            _hoveredCardIndex = null;
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isHovered ? 100 : 60, // 🎯 기본 60px로 더 넓은 감지 영역 확보
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent, // 🎯 투명하게 변경
            border: isHovered
                ? Border.all(color: Colors.transparent, width: 2) // 🎯 투명하게 변경
                : null,
          ),
          child: isHovered
              ? Center(
                  child: Icon(
                    Icons.add_circle_outline,
                    color: Colors.transparent, // 🎯 투명하게 변경
                    size: 32,
                  ),
                )
              : null,
        );
      },
    );
  }

  /// ✅ 피그마 디자인: Frame 686 (오늘 날짜 배지)
  /// 36×36px, 검은 배경 (#111111), radius 12px (smoothing 60%), 날짜 텍스트 (ExtraBold 12px, 흰색)
  /// 월뷰의 오늘 버튼과 동일한 디자인
  Widget _buildTodayButton(DateTime today) {
    return Hero(
      tag: 'today-button-${today.toString()}',
      createRectTween: (begin, end) {
        return _AppleStyleRectTween(begin: begin, end: end);
      },
      flightShuttleBuilder: _appleStyleHeroFlightShuttleBuilder,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('📅 [UI] 오늘로 이동 버튼 클릭');
            // 오늘 날짜를 정규화 (시간 제거)
            final todayDate = DateTime(today.year, today.month, today.day);
            // widget.selectedDate(초기 날짜)를 기준으로 오늘까지의 날짜 차이 계산
            final daysDiff = todayDate.difference(widget.selectedDate).inDays;
            final targetIndex = _centerIndex + daysDiff;

            print('   📅 초기 날짜: ${widget.selectedDate}');
            print('   📅 오늘 날짜: $todayDate');
            print('   📊 날짜 차이: $daysDiff일');
            print('   🎯 목표 인덱스: $targetIndex');

            _pageController.animateToPage(
              targetIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 12,
              cornerSmoothing: 0.6, // 60% smoothing
            ),
          ),
          child: Container(
            width: 36, // 피그마: Frame 123 크기 36×36px
            height: 36,
            decoration: ShapeDecoration(
              color: const Color(0xFF111111), // 피그마: 배경색 #111111
              shape: SmoothRectangleBorder(
                side: BorderSide(
                  color: const Color(0xFF000000).withOpacity(0.04),
                  width: 1,
                ),
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 12, // 피그마: radius 12px
                  cornerSmoothing: 0.6, // 60% smoothing
                ),
              ),
              shadows: [
                // 피그마: 0px 4px 20px rgba(0,0,0,0.12)
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.12),
                  offset: const Offset(0, 4),
                  blurRadius: 20,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '${today.day}', // 오늘 날짜 숫자
              style: const TextStyle(
                fontFamily: 'LINE Seed JP App_TTF',
                fontSize: 12, // 피그마: ExtraBold 12px
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFFFFF), // 피그마: 흰색
                letterSpacing: -0.06,
                height: 1.4, // lineHeight 16.8 / fontSize 12
              ),
            ),
          ),
        ),
      ),
    );
  }
} // _DateDetailViewState 끝

/// Apple 스타일 Hero 애니메이션을 위한 커스텀 RectTween
class _AppleStyleRectTween extends RectTween {
  _AppleStyleRectTween({required super.begin, required super.end});

  @override
  Rect lerp(double t) {
    // 애플 스타일 커브를 적용 (cubic-bezier 0.25, 0.1, 0.25, 1.0)
    final curvedT = Curves.easeInOut.transform(t);
    return Rect.lerp(begin, end, curvedT)!;
  }
}

/// Hero 애니메이션 중 비행하는 위젯을 커스터마이징하는 빌더 함수
Widget _appleStyleHeroFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Hero toHero = toHeroContext.widget as Hero;
  return toHero.child;
}
