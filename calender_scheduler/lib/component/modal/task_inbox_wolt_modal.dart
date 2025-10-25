import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:get_it/get_it.dart';

import '../../Database/schedule_database.dart';
import '../../widgets/task_card.dart';
import '../../widgets/slidable_task_card.dart';
import '../modal/task_detail_wolt_modal.dart';

/// Task Inbox Wolt Modal Sheet
///
/// 이거를 설정하고 → Inbox 모드에서 タスク 버튼 클릭 시 표시되는 모달을 구현해서
/// 이거를 해서 → 모든 할일 목록을 필터링하여 볼 수 있고
/// 이거는 이래서 → 사용자가 할일을 효율적으로 관리할 수 있다
///
/// **Figma Design Spec:**
///
/// **Modal Container:**
/// - Size: 393 x 780px
/// - Background: rgba(255, 255, 255, 0.95)
/// - Backdrop-filter: blur(2px)
/// - Border radius: 36px 36px 0px 0px
///
/// **TopNavi (42px):**
/// - Padding: 28px 좌우
/// - Title: "スケジュール" - Bold 16px, #505050
/// - AI Toggle: 40x24px
///
/// **Task List (746px):**
/// - Scrollable area
/// - Reuse TaskCard from DateDetailView
/// - Horizontal padding: 24px
/// - Card gap: 4px
///
/// **Filter Bar (bottom fixed):**
/// - Container: 393x104px
/// - White bar: 345x64px, radius 100px
/// - Close button: 44x44px
/// - Filter buttons: 80x60px each, 16px gap
/// - Icons: 27x27px
/// - Text: 9px Bold
/// - Filters: すべて, 即実行する, 計画する, 先送る, 捨てる, 素早く終える, 集中する, 色分け

/// Task Inbox Wolt Modal 표시 함수
///
/// 이거를 설정하고 → Task Inbox 모달을 표시해서
/// 이거를 해서 → 모든 할일을 필터링하여 관리하고
/// 이거는 이래서 → 사용자가 할일을 효율적으로 처리한다
void showTaskInboxWoltModal(BuildContext context) {
  debugPrint('📋 [TaskInbox] Wolt Modal 열기 시작');

  WoltModalSheet.show(
    context: context,
    pageListBuilder: (context) => [_buildTaskInboxPage(context)],
    modalTypeBuilder: (context) => WoltModalType.bottomSheet(),
    onModalDismissedWithBarrierTap: () {
      debugPrint('✅ [TaskInbox] Modal dismissed with tap');
    },
    onModalDismissedWithDrag: () {
      debugPrint('✅ [TaskInbox] Modal dismissed with drag');
    },
    useSafeArea: false, // ✅ SafeArea 비활성화
    barrierDismissible: true,
    enableDrag: true,
  );

  debugPrint('✅ [TaskInbox] Wolt Modal 표시 완료');
}

// ========================================
// Task Inbox Page Builder
// ========================================

/// Task Inbox 페이지 빌더
///
/// 이거를 설정하고 → SliverWoltModalSheetPage를 생성해서
/// 이거를 해서 → TopNavi + Task List + Filter Bar를 구성하고
/// 이거는 이래서 → 스크롤 가능한 할일 목록을 제공한다
SliverWoltModalSheetPage _buildTaskInboxPage(BuildContext context) {
  return SliverWoltModalSheetPage(
    hasTopBarLayer: false, // ✅ 커스텀 TopNavi 사용

    mainContentSliversBuilder: (context) => [
      // ========================================
      // TopNavi (42px)
      // ========================================
      SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95), // ✅ rgba(255,255,255,0.95)
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(36),
              topRight: Radius.circular(36),
            ),
          ),
          child: _buildTopNavi(context),
        ),
      ),

      // ========================================
      // Task List (scrollable, 746px max)
      // ========================================
      _buildTaskList(context),

      // ========================================
      // Bottom padding for Filter Bar
      // ========================================
      const SliverToBoxAdapter(
        child: SizedBox(height: 104), // Filter Bar 높이만큼 여백
      ),
    ],

    // ✅ 배경색 투명 (Container가 배경색 처리)
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,

    // ✅ Footer: Filter Bar (bottom fixed)
    stickyActionBar: _buildFilterBar(context),
  );
}

// ========================================
// TopNavi Component (42px)
// ========================================

/// TopNavi 컴포넌트
///
/// 이거를 설정하고 → 42px 높이의 상단 네비게이션을 만들어서
/// 이거를 해서 → "スケジュール" 타이틀과 AI 토글을 표시하고
/// 이거는 이래서 → 사용자가 현재 뷰를 인식할 수 있다
Widget _buildTopNavi(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 9),
    child: SizedBox(
      height: 24, // 42px - (9px * 2) = 24px
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title: "スケジュール"
          Text(
            'スケジュール',
            style: TextStyle(
              fontFamily: 'LINE Seed JP App_TTF',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.08,
              color: const Color(0xFF505050),
            ),
          ),

          // AI Toggle (40x24px)
          _buildAIToggle(),
        ],
      ),
    ),
  );
}

/// AI 토글 스위치 (40x24px)
///
/// 이거를 설정하고 → 40x24px AI 토글을 만들어서
/// 이거를 해서 → AI 기능 활성화 여부를 표시하고
/// 이거는 이래서 → 사용자가 AI 모드를 전환할 수 있다
Widget _buildAIToggle() {
  return Container(
    width: 40,
    height: 24,
    decoration: BoxDecoration(
      color: const Color(0xFF111111),
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: Text(
      'AI',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'LINE Seed JP App_TTF',
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    ),
  );
}

// ========================================
// Task List Component (scrollable)
// ========================================

/// Task List 컴포넌트
///
/// 이거를 설정하고 → DB에서 모든 할일을 조회해서
/// 이거를 해서 → TaskCard를 재사용하여 목록을 표시하고
/// 이거는 이래서 → 사용자가 할일을 확인하고 관리할 수 있다
Widget _buildTaskList(BuildContext context) {
  // ✅ DB에서 모든 할일을 실시간으로 관찰
  return StreamBuilder<List<TaskData>>(
    stream: GetIt.I<AppDatabase>().watchTasks(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      final tasks = snapshot.data!;
      print('📋 [TaskInbox] 전체 할일 수: ${tasks.length}');

      if (tasks.isEmpty) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Text(
                '할일이 없습니다',
                style: TextStyle(
                  fontFamily: 'LINE Seed JP App_TTF',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF7A7A7A),
                ),
              ),
            ),
          ),
        );
      }

      // ✅ Task 목록 표시 (DateDetailView와 동일한 방식)
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final task = tasks[index];
            print('  → [TaskInbox] Task ${index + 1}: ${task.title}');

            // ✅ SlidableTaskCard 재사용 (DateDetailView와 동일)
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SlidableTaskCard(
                groupTag: 'task_inbox',
                taskId: task.id,
                onTap: () {
                  print('📋 [TaskInbox] Task 탭: ${task.title}');
                  // ✅ Task Detail Modal 표시
                  showTaskDetailWoltModal(
                    context,
                    task: task,
                    selectedDate: DateTime.now(),
                  );
                },
                onComplete: () async {
                  print('✅ [TaskInbox] Task 완료 토글: ${task.title}');
                  await GetIt.I<AppDatabase>().completeTask(task.id);
                },
                onDelete: () async {
                  print('🗑️ [TaskInbox] Task 삭제: ${task.title}');
                  await GetIt.I<AppDatabase>().deleteTask(task.id);
                },
                child: TaskCard(
                  task: task,
                  onToggle: () async {
                    if (task.completed) {
                      print('🔄 [TaskInbox] 체크박스 완료 해제: ${task.title}');
                      await GetIt.I<AppDatabase>().uncompleteTask(task.id);
                    } else {
                      print('✅ [TaskInbox] 체크박스 완료 처리: ${task.title}');
                      await GetIt.I<AppDatabase>().completeTask(task.id);
                    }
                  },
                ),
              ),
            );
          }, childCount: tasks.length),
        ),
      );
    },
  );
}

// ========================================
// Filter Bar Component (bottom fixed)
// ========================================

/// Filter Bar 컴포넌트
///
/// 이거를 설정하고 → 하단 고정 필터 바를 만들어서
/// 이거를 해서 → 8개의 필터 버튼과 닫기 버튼을 표시하고
/// 이거는 이래서 → 사용자가 할일을 카테고리별로 필터링할 수 있다
Widget _buildFilterBar(BuildContext context) {
  return Container(
    width: 393,
    height: 104,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: const Offset(0, -4),
          blurRadius: 20,
        ),
      ],
    ),
    child: Row(
      children: [
        // ========================================
        // Close Button (44x44px)
        // ========================================
        _buildCloseButton(context),

        const SizedBox(width: 12), // gap
        // ========================================
        // Filter Buttons (horizontal scroll)
        // ========================================
        Expanded(child: _buildFilterButtons()),
      ],
    ),
  );
}

/// Close Button (44x44px)
///
/// 이거를 설정하고 → 44x44px 닫기 버튼을 만들어서
/// 이거를 해서 → 모달을 닫을 수 있고
/// 이거는 이래서 → 사용자가 쉽게 모달을 종료할 수 있다
Widget _buildCloseButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      print('❌ [TaskInbox] 닫기 버튼 클릭');
      Navigator.of(context).pop();
    },
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF111111).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Icon(Icons.close, size: 24, color: const Color(0xFF111111)),
    ),
  );
}

/// Filter Buttons (horizontal scroll)
///
/// 이거를 설정하고 → 8개의 필터 버튼을 가로 스크롤로 배치해서
/// 이거를 해서 → 각 필터를 선택할 수 있고
/// 이거는 이래서 → 사용자가 원하는 카테고리의 할일만 볼 수 있다
Widget _buildFilterButtons() {
  final filters = [
    {'label': 'すべて', 'icon': Icons.list},
    {'label': '即実行する', 'icon': Icons.bolt},
    {'label': '計画する', 'icon': Icons.calendar_today},
    {'label': '先送る', 'icon': Icons.schedule},
    {'label': '捨てる', 'icon': Icons.delete_outline},
    {'label': '素早く終える', 'icon': Icons.flash_on},
    {'label': '集中する', 'icon': Icons.center_focus_strong},
    {'label': '色分け', 'icon': Icons.palette},
  ];

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: filters.asMap().entries.map((entry) {
        final index = entry.key;
        final filter = entry.value;
        final isFirst = index == 0; // "すべて" is default selected

        return Padding(
          padding: EdgeInsets.only(right: index < filters.length - 1 ? 16 : 0),
          child: _buildFilterButton(
            label: filter['label'] as String,
            icon: filter['icon'] as IconData,
            isSelected: isFirst, // ✅ 첫 번째 필터(すべて)가 기본 선택
          ),
        );
      }).toList(),
    ),
  );
}

/// Filter Button (80x60px)
///
/// 이거를 설정하고 → 80x60px 필터 버튼을 만들어서
/// 이거를 해서 → 아이콘과 라벨을 표시하고
/// 이거는 이래서 → 사용자가 직관적으로 필터를 선택할 수 있다
Widget _buildFilterButton({
  required String label,
  required IconData icon,
  required bool isSelected,
}) {
  return Container(
    width: 80,
    height: 60,
    decoration: BoxDecoration(
      color: isSelected ? const Color(0xFF111111) : Colors.white,
      borderRadius: BorderRadius.circular(100),
      border: Border.all(
        color: const Color(0xFF111111).withOpacity(0.1),
        width: 1,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon (27x27px)
        Icon(
          icon,
          size: 27,
          color: isSelected ? Colors.white : const Color(0xFFF0F0F0),
        ),
        const SizedBox(height: 4),
        // Label (9px Bold)
        Text(
          label,
          style: TextStyle(
            fontFamily: 'LINE Seed JP App_TTF',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFFF0F0F0),
          ),
        ),
      ],
    ),
  );
}
