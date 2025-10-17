import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Database/schedule_database.dart';
import 'package:get_it/get_it.dart';
import '../providers/bottom_sheet_controller.dart';
import '../providers/schedule_form_controller.dart';
import '../design_system/wolt_common_widgets.dart'; // ✅ WoltDetailOption 사용
import '../design_system/wolt_typography.dart'; // ✅ WoltTypography 사용
import '../design_system/wolt_helpers.dart'; // ✅ Wolt helper functions
import '../design_system/typography.dart' as AppTypography; // ✅ Typography 시스템

/// FullScheduleBottomSheet - More 버튼으로 표시되는 전체 일정 입력 바텀시트
/// 이거를 설정하고 → 이미지 기반 Figma 디자인을 완전히 복제해서
/// 이거를 해서 → 모든 일정 옵션을 입력할 수 있는 UI를 제공하고
/// 이거는 이래서 → 사용자가 상세한 일정 정보를 설정할 수 있다
/// 이거라면 → DB에 완전한 일정 데이터가 저장된다
class FullScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate; // 선택된 날짜
  final String? initialTitle; // 간단 모드에서 입력한 제목 (있으면 자동 입력)

  const FullScheduleBottomSheet({
    super.key,
    required this.selectedDate,
    this.initialTitle,
  });

  @override
  State<FullScheduleBottomSheet> createState() =>
      _FullScheduleBottomSheetState();
}

class _FullScheduleBottomSheetState extends State<FullScheduleBottomSheet>
    with SingleTickerProviderStateMixin {
  // ========================================
  // ✅ 상태 변수
  // ========================================

  late AnimationController _headerAnimationController; // 헤더 X → 完了 애니메이션

  @override
  void initState() {
    super.initState();

    // Provider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scheduleForm = Provider.of<ScheduleFormController>(
        context,
        listen: false,
      );
      scheduleForm.loadInitialTitle(widget.initialTitle);

      // 초기 제목이 있으면 완료 버튼 상태로 시작
      if (scheduleForm.hasTitle) {
        _headerAnimationController.value = 1.0;
      }

      // 제목 변경 감지
      scheduleForm.titleController.addListener(_onTitleChanged);
    });

    // 이거를 설정하고 → 헤더 애니메이션 컨트롤러 초기화해서
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // 이거를 해서 → X 버튼과 完了 버튼 사이를 부드럽게 전환한다

    print(
      '📅 [FullScheduleBottomSheet] 초기화 완료 - 날짜: ${widget.selectedDate}, 제목: ${widget.initialTitle}',
    );
  }

  @override
  void dispose() {
    final scheduleForm = Provider.of<ScheduleFormController>(
      context,
      listen: false,
    );
    scheduleForm.titleController.removeListener(_onTitleChanged);
    _headerAnimationController.dispose();
    print('🗑️ [FullScheduleBottomSheet] 리소스 정리 완료');
    super.dispose();
  }

  // ========================================
  // ✅ 제목 변경 감지 (X ↔ 完了 애니메이션)
  // ========================================

  /// 이거를 설정하고 → 제목 입력 상태를 감지해서
  /// 이거를 해서 → 텍스트가 있으면 完了 버튼으로 전환하고
  /// 이거는 이래서 → 비어있으면 X 버튼으로 전환한다
  void _onTitleChanged() {
    final scheduleForm = Provider.of<ScheduleFormController>(
      context,
      listen: false,
    );
    if (scheduleForm.hasTitle) {
      // 이거라면 → 텍스트가 있으면 完了 버튼으로 애니메이션
      _headerAnimationController.forward();
    } else {
      // 이거를 설정하고 → 텍스트가 없으면 X 버튼으로 되돌림
      _headerAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이거를 설정하고 → 전체 화면 크기의 바텀시트를 구성해서
    return Container(
      height: MediaQuery.of(context).size.height * 0.9, // 화면의 90% 높이
      decoration: BoxDecoration(
        // 이거를 해서 → 이미지 기반 디자인: 흰색 배경 + 상단 둥근 모서리
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36), // 이미지: 상단 좌측 36px
          topRight: Radius.circular(36), // 이미지: 상단 우측 36px
        ),
      ),
      child: Column(
        children: [
          // ✅ 헤더 (스케쥴 + X/完了 버튼)
          _buildHeader(),

          // ✅ 스크롤 가능한 콘텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ 제목 입력
                  _buildTitleSection(),

                  const SizedBox(height: 32),

                  // ✅ 종일 섹션 (아이콘 + 레이블)
                  _buildAllDaySection(),

                  const SizedBox(height: 24),

                  // ✅ 날짜/시간 선택
                  _buildDateTimeSection(),

                  const SizedBox(height: 32),

                  // ✅ 하단 3개 옵션 (반복/알림/색상)
                  _buildOptionsSection(),

                  const SizedBox(height: 48),

                  // ✅ 삭제 버튼
                  _buildDeleteButton(),

                  const SizedBox(height: 32), // 하단 여백
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // ✅ UI 컴포넌트들
  // ========================================

  /// 헤더 구성 - "スケジュール" + X/完了 버튼 (애니메이션)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 이거를 설정하고 → 좌측에 "スケジュール" 텍스트 배치
          Text(
            'スケジュール',
            style: AppTypography.Typography.headlineSmallBold.copyWith(
              color: const Color(0xFF505050), // 이미지: 회색 텍스트
            ),
          ),

          // 이거를 해서 → 우측에 X ↔ 完了 애니메이션 버튼 배치
          _buildAnimatedHeaderButton(),
        ],
      ),
    );
  }

  /// X ↔ 完了 애니메이션 버튼
  Widget _buildAnimatedHeaderButton() {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        // 이거는 이래서 → 애니메이션 진행률에 따라 버튼 스타일 변경
        final progress = _headerAnimationController.value;

        // 이거라면 → X 버튼 (progress = 0) ↔ 完了 버튼 (progress = 1)
        final isComplete = progress > 0.5;

        return GestureDetector(
          onTap: () async {
            if (isComplete) {
              // 이거를 설정하고 → 完了 버튼이면 저장 처리
              final scheduleForm = Provider.of<ScheduleFormController>(
                context,
                listen: false,
              );
              final bottomSheet = Provider.of<BottomSheetController>(
                context,
                listen: false,
              );

              // 데이터 검증
              if (scheduleForm.title.isEmpty) {
                print('⚠️ [저장 실패] 제목이 비어있음');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
                return;
              }

              try {
                // 시작/종료 DateTime
                final startDateTime = scheduleForm.startDateTime;
                final endDateTime = scheduleForm.endDateTime;

                if (startDateTime == null || endDateTime == null) {
                  print('⚠️ [저장 실패] 날짜/시간이 비어있음');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('날짜와 시간을 설정해주세요')),
                  );
                  return;
                }

                // ScheduleCompanion 객체 생성
                final companion = ScheduleCompanion.insert(
                  start: scheduleForm.startDateTime!,
                  end: scheduleForm.endDateTime!,
                  summary: scheduleForm.title,
                  // ✅ description, location 제거 (기본값 '' 자동 적용)
                  colorId: bottomSheet.selectedColor,
                  repeatRule: bottomSheet.repeatRule,
                  alertSetting: bottomSheet.reminder,
                  status: 'confirmed',
                  visibility: 'public',
                );

                // DB에 저장
                await GetIt.I<AppDatabase>().createSchedule(companion);
                print(
                  '💾 [저장 성공] 제목: ${scheduleForm.title}, 날짜: $startDateTime ~ $endDateTime',
                );

                // 저장 후 바텀시트 닫기
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('일정이 저장되었습니다')));
                }
              } catch (e) {
                print('❌ [저장 에러] $e');
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
                }
              }
            } else {
              // 이거를 해서 → X 버튼이면 바텀시트 닫기
              Navigator.of(context).pop();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              // 이거는 이래서 → 完了일 때는 검은 배경, X일 때는 투명
              color: Color.lerp(
                Colors.transparent,
                const Color(0xFF111111), // 이미지: 검은색
                progress,
              ),
              borderRadius: BorderRadius.circular(100), // 이미지: 완전한 둥근 모서리
              border: Border.all(
                color: const Color(0xFFE4E4E4), // 이미지: 연한 회색 테두리
                width: 1,
              ),
            ),
            child: isComplete
                ? Text(
                    '完了',
                    style: AppTypography.Typography.bodyLargeBold.copyWith(
                      color: const Color(0xFFFAFAFA), // 이미지: 흰색 텍스트
                    ),
                  )
                : const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF111111), // 이미지: 검은색 X
                  ),
          ),
        );
      },
    );
  }

  /// 제목 입력 섹션
  Widget _buildTitleSection() {
    return Consumer<ScheduleFormController>(
      builder: (context, scheduleForm, child) => TextField(
        controller: scheduleForm.titleController,
        decoration: InputDecoration(
          hintText: '予定を追加', // Figma: 플레이스홀더
          hintStyle: WoltTypography.schedulePlaceholder, // ✅ 디자인 시스템 적용
          border: InputBorder.none, // 테두리 없음
          contentPadding: EdgeInsets.zero,
        ),
        style: WoltTypography.scheduleTitle, // ✅ 디자인 시스템 적용
        textInputAction: TextInputAction.done,
      ),
    );
  }

  /// 종일 섹션 (Figma: DetailView_AllDay)
  /// 이거를 설정하고 → 종일 아이콘 + 레이블 + 토글 버튼을 배치해서
  /// 이거를 해서 → 사용자가 종일 여부를 선택할 수 있다
  /// 이거는 이래서 → 토글 ON 시 시간 입력이 숨겨진다
  Widget _buildAllDaySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ), // Figma: padding 0px 24px
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ 좌측: 아이콘 + 終日 레이블 (Figma: Frame 715)
          Row(
            children: [
              // 이거를 설정하고 → 종일 아이콘 표시
              Icon(
                Icons.access_time, // Figma: icon 19×19px
                size: 19,
                color: const Color(0xFF111111),
              ),
              const SizedBox(width: 8), // Figma: gap 8px
              // 이거를 해서 → "終日" 레이블 표시
              Text('終日', style: AppTypography.Typography.bodyMediumBold),
            ],
          ),

          // ✅ 우측: 토글 버튼 (Figma: Togle_Off / Togle_On)
          Consumer<ScheduleFormController>(
            builder: (context, scheduleForm, child) => GestureDetector(
              onTap: () {
                scheduleForm.toggleAllDay();
                print('🔄 [종일 토글] 상태: ${scheduleForm.isAllDay} (시간 데이터 유지)');
              },
              child: Container(
                width: 48, // Figma: Frame 749 width
                height: 32, // Figma: Frame 749 height
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                decoration: BoxDecoration(
                  color: scheduleForm.isAllDay
                      ? const Color(0xFF21DC6D) // ON: 초록색
                      : const Color(0xFFF1F1F1), // OFF: 회색
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Align(
                  alignment: scheduleForm.isAllDay
                      ? Alignment
                            .centerRight // ON: 오른쪽
                      : Alignment.centerLeft, // OFF: 왼쪽
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜/시간 선택 섹션
  /// 날짜/시간 섹션 (Figma 2326-11044, 2326-11047, 2372-28903)
  /// 이거를 설정하고 → Figma DetailView 디자인을 완벽히 재현해서
  /// 이거를 해서 → 종일 OFF/ON 상태에 따라 다르게 표시하고
  /// 이거는 이래서 → 사용자가 날짜/시간을 직관적으로 선택할 수 있다
  Widget _buildDateTimeSection() {
    return Consumer<ScheduleFormController>(
      builder: (context, scheduleForm, child) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
        ), // Figma: padding 48px
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ✅ 시작 (開始)
            _buildDateTimeObject(
              label: '開始',
              date: scheduleForm.startDate,
              time: scheduleForm.startTime,
              isStart: true,
              isAllDay: scheduleForm.isAllDay,
            ),

            // ✅ 중앙 구분선 (Figma: Vector 87)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: 8,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF000000).withOpacity(0.05),
                    width: 2,
                  ),
                ),
              ),
            ),

            // ✅ 종료 (終了)
            _buildDateTimeObject(
              label: '終了',
              date: scheduleForm.endDate,
              time: scheduleForm.endTime,
              isStart: false,
              isAllDay: scheduleForm.isAllDay,
              isEndOpacity: scheduleForm.startDate == null, // 시작 미선택 시 종료는 흐리게
            ),
          ],
        ),
      ),
    );
  }

  /// 날짜/시간 객체 (Figma: DetailView_Object)
  /// 이거를 설정하고 → Figma 디자인대로 날짜/시간을 표시해서
  /// 이거를 해서 → 미선택 시 큰 숫자 + 중앙 버튼, 선택 시 날짜/시간 표시
  /// 이거는 이래서 → 종일 ON/OFF에 따라 다르게 렌더링된다
  Widget _buildDateTimeObject({
    required String label,
    DateTime? date,
    TimeOfDay? time,
    required bool isStart,
    required bool isAllDay,
    bool isEndOpacity = false,
  }) {
    return Opacity(
      opacity: isEndOpacity ? 0.3 : 1.0, // Figma: 종료는 시작 미선택 시 opacity 0.3
      child: SizedBox(
        width: 64, // Figma: 64px width
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 레이블 (開始/終了) - Figma: Frame 752
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Text(
                    label,
                    style: AppTypography.Typography.bodyLargeBold.copyWith(
                      color: const Color(0xFFBBBBBB), // Figma: #BBBBBB
                    ),
                  ),
                ),

                const SizedBox(height: 12), // Figma: gap 12px
                // ✅ 날짜/시간 또는 큰 숫자 "10"
                if (date == null)
                  // 미선택 상態: 큰 숫자 "10" (Figma: #EEEEEE)
                  Text(
                    '10',
                    style: AppTypography.Typography.displayLargeExtraBold
                        .copyWith(
                          color: const Color(0xFFEEEEEE), // Figma: #EEEEEE
                          shadows: const [],
                        ),
                  )
                else
                  // 선택 완료 상태: 날짜 + 시간
                  // 이거를 설정하고 → 종일 여부에 따라 표시만 다르게 하고
                  // 이거를 해서 → 시간 데이터는 항상 유지한다
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜 (Figma: Frame 751)
                      if (isAllDay)
                        // 종일 ON: 연도(빨강) + 월.일만 표시
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 1),
                              child: Text(
                                '${date.year}', // Figma: "2025" (빨강)
                                style: AppTypography
                                    .Typography
                                    .headlineSmallExtraBold
                                    .copyWith(
                                      color: const Color(
                                        0xFFE75858,
                                      ), // Figma: #E75858
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x1A000000),
                                          blurRadius: 20,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                              ),
                            ),
                            Text(
                              '${date.month}.${date.day}', // Figma: "8.30"
                              style: AppTypography
                                  .Typography
                                  .headlineLargeExtraBold
                                  .copyWith(
                                    color: const Color(
                                      0xFF111111,
                                    ), // Figma: #111111
                                    shadows: const [
                                      Shadow(
                                        color: Color(0x1A000000),
                                        blurRadius: 20,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                            ),
                          ],
                        )
                      else
                        // 종일 OFF: 년.월.일 + 시:분 표시 (시간 데이터는 항상 유지)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 1),
                              child: Text(
                                '${date.year % 100}. ${date.month}. ${date.day}', // Figma: "25. 7. 30"
                                style: AppTypography
                                    .Typography
                                    .headlineSmallExtraBold
                                    .copyWith(
                                      color: const Color(
                                        0xFF111111,
                                      ), // Figma: #111111
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x1A000000),
                                          blurRadius: 20,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                              ),
                            ),
                            const SizedBox(height: 2), // Figma: gap 2px
                            // 이거는 이래서 → 시간이 있으면 항상 표시 (종일 OFF일 때만)
                            if (time != null)
                              Text(
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}', // Figma: "15:30"
                                style: AppTypography
                                    .Typography
                                    .headlineLargeExtraBold
                                    .copyWith(
                                      color: const Color(
                                        0xFF111111,
                                      ), // Figma: #111111
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x1A000000),
                                          blurRadius: 20,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                              ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),

            // ✅ 중앙 + 버튼 (Figma: Modal Control Buttons)
            if (date == null)
              Positioned(
                left: 16, // calc(50% - 32px/2)
                top: 48, // calc(50% - 32px/2 + 16px)
                child: GestureDetector(
                  onTap: () => _showDatePicker(isStart: isStart),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626), // Figma: #262626
                      border: Border.all(
                        color: const Color(0xFF111111).withOpacity(0.06),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBABABA).withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 24,
                      color: Color(0xFFFFFFFF), // Figma: #FFFFFF
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 하단 3개 옵션 (반복/알림/색상) - 피그마 디자인
  Widget _buildOptionsSection() {
    final bottomSheet = Provider.of<BottomSheetController>(
      context,
      listen: false,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ 반복 아이콘 (피그마: DetailOption 64×64px)
          WoltDetailOption(
            icon: const Icon(Icons.refresh, size: 24, color: Color(0xFF111111)),
            onTap: () {
              showWoltRepeatOption(
                context,
                initialRepeatRule: bottomSheet.repeatRule,
              );
            },
          ),

          const SizedBox(width: 8), // 피그마: gap 8px
          // ✅ 리마인더 아이콘 (피그마: DetailOption 64×64px)
          WoltDetailOption(
            icon: const Icon(
              Icons.notifications_outlined,
              size: 24,
              color: Color(0xFF111111),
            ),
            onTap: () {
              showWoltReminderOption(
                context,
                initialReminder: bottomSheet.reminder,
              );
            },
          ),

          const SizedBox(width: 8), // 피그마: gap 8px
          // ✅ 색상 아이콘 (피그마: DetailOption 64×64px)
          WoltDetailOption(
            icon: const Icon(
              Icons.palette_outlined,
              size: 24,
              color: Color(0xFF111111),
            ),
            onTap: () async {
              print('🎨 [Full Schedule] 색상 선택 모달 열기');
              showWoltColorPicker(
                context,
                initialColorId: bottomSheet.selectedColor,
              );
            },
          ),
        ],
      ),
    );
  }

  /// 삭제 버튼
  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () async {
        // 삭제 확인 다이얼로그 표시
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('일정 삭제'),
            content: const Text('이 일정을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF74A4A),
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
        );

        if (confirm == true && mounted) {
          // TODO: 실제 삭제 로직 구현 (scheduleId 필요)
          print('🗑️ [삭제] 일정 삭제');
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('일정이 삭제되었습니다')));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_outline,
              size: 20,
              color: Color(0xFFF74A4A), // 이미지: 빨간색
            ),
            const SizedBox(width: 8),
            Text(
              '削除',
              style: AppTypography.Typography.bodyLargeBold.copyWith(
                color: const Color(0xFFF74A4A), // 이미지: 빨간색
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // ✅ 모달 표시 함수들
  // ========================================

  /// 날짜 선택 모달
  void _showDatePicker({required bool isStart}) async {
    final scheduleForm = Provider.of<ScheduleFormController>(
      context,
      listen: false,
    );

    // 이거를 설정하고 → iOS 스타일 날짜 picker를 표시해서
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (scheduleForm.startDate ?? widget.selectedDate)
          : (scheduleForm.endDate ?? widget.selectedDate),
      firstDate: DateTime(2020), // 이거를 해서 → 2020년부터 선택 가능
      lastDate: DateTime(2030), // 이거는 이래서 → 2030년까지 선택 가능
      builder: (context, child) {
        // 이거라면 → 다크 모드 대응 및 스타일 커스터마이징
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF111111), // 이미지: 검은색 테마
              onPrimary: Color(0xFFFAFAFA), // 흰색 텍스트
              surface: Colors.white,
              onSurface: Color(0xFF111111),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        // 이거를 설정하고 → 시작 날짜 업데이트
        scheduleForm.setStartDate(picked);
        print('📅 [날짜 선택] 시작 날짜: ${picked.toString()}');
      } else {
        // 이거를 해서 → 종료 날짜 업데이트
        scheduleForm.setEndDate(picked);
        print('📅 [날짜 선택] 종료 날짜: ${picked.toString()}');
      }

      // 이거를 설정하고 → 종일이 아닐 때만 시간 picker 자동 표시
      // 이거를 해서 → 날짜 선택 후 바로 시간을 선택할 수 있다
      if (!scheduleForm.isAllDay) {
        _showTimePicker(isStart: isStart);
      }
    }
  }

  /// 시간 선택 picker
  void _showTimePicker({required bool isStart}) async {
    final scheduleForm = Provider.of<ScheduleFormController>(
      context,
      listen: false,
    );

    // 이거를 설정하고 → iOS 스타일 시간 picker를 표시해서
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (scheduleForm.startTime ?? TimeOfDay.now())
          : (scheduleForm.endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        // 이거를 해서 → 24시간 형식 및 스타일 커스터마이징
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF111111), // 이미지: 검은색 테마
              onPrimary: Color(0xFFFAFAFA), // 흰색 텍스트
              surface: Colors.white,
              onSurface: Color(0xFF111111),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: true, // 이거는 이래서 → 24시간 형식 사용
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        // 이거라면 → 시작 시간 업데이트
        scheduleForm.setStartTime(picked);
        print('⏰ [시간 선택] 시작 시간: ${picked.format(context)}');
      } else {
        // 이거를 설정하고 → 종료 시간 업데이트
        scheduleForm.setEndTime(picked);
        print('⏰ [시간 선택] 종료 시간: ${picked.format(context)}');
      }
    }
  }

  // ========================================
  // ✅ Provider 사용으로 인한 함수 정리 완료
  // ========================================
}
