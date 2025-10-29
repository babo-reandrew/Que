// 🎯 DateDetailView 리팩토링 버전
//
// 핵심 변경사항:
// 1. DragTarget에서 insertTaskAtPosition 제거 → 단순히 updateTaskDate만 호출 (월뷰 방식)
// 2. _buildUnifiedItemList에서 자동으로 DailyCardOrder 동기화
// 3. 새로 추가된 Task는 드롭된 위치(targetOrder)에 자동 삽입

/// 🔥 핵심 개념:
///
/// 월뷰가 작동하는 이유:
/// - updateTaskDate(taskId, date) 호출
/// - Stream이 자동으로 새 Task를 포함한 리스트 emit
/// - UI 자동 업데이트
///
/// DateDetailView에서 같은 방식이 안 되는 이유:
/// - DailyCardOrder가 없으면 기본 순서(createdAt)로 맨 끝에 추가됨
/// - 드롭한 위치를 기억할 방법이 없음
///
/// 해결책:
/// - DragTarget에서 드롭 위치를 _pendingInsertions에 임시 저장
/// - _buildUnifiedItemList에서 새로 추가된 항목 감지
/// - 감지된 항목을 _pendingInsertions의 위치에 삽입
/// - DailyCardOrder에 전체 순서 저장
library;


import 'package:flutter/material.dart';

/// 🎯 임시 삽입 정보 저장
class PendingInsertion {
  final int taskId;
  final DateTime date;
  final int targetOrder; // 드롭된 위치의 sortOrder
  final DateTime timestamp;

  PendingInsertion({
    required this.taskId,
    required this.date,
    required this.targetOrder,
    required this.timestamp,
  });
}

/// 🎯 리팩토링된 DateDetailView의 핵심 로직
///
/// 사용법:
/// 1. DateDetailView의 State에 추가:
///    ```dart
///    final List<PendingInsertion> _pendingInsertions = [];
///    ```
///
/// 2. DragTarget의 onAcceptWithDetails 수정:
///    ```dart
///    onAcceptWithDetails: (details) async {
///      final droppedTask = details.data;
///
///      // 1️⃣ 드롭 위치를 임시 저장
///      _pendingInsertions.add(PendingInsertion(
///        taskId: droppedTask.id,
///        date: date,
///        targetOrder: item.sortOrder,
///        timestamp: DateTime.now(),
///      ));
///
///      // 2️⃣ 단순히 executionDate만 업데이트 (월뷰 방식!)
///      await GetIt.I<AppDatabase>().updateTaskDate(droppedTask.id, date);
///
///      HapticFeedback.heavyImpact();
///      setState(() { _isDraggingFromInbox = false; });
///    },
///    ```
///
/// 3. _buildUnifiedItemList 수정:
///    - 누락된 Task를 기본 순서 대신 _pendingInsertions의 targetOrder에 삽입
///    - 전체 리스트를 DailyCardOrder에 저장
///    - _pendingInsertions 클리어

class DateDetailViewRefactorHelper {
  /// 🎯 Step 1: 누락된 Task를 targetOrder 위치에 삽입
  ///
  /// 기존 코드:
  /// ```dart
  /// final missingTasks = taskIds.difference(orderTaskIds);
  /// if (missingTasks.isNotEmpty) {
  ///   // 기본 순서로 맨 끝에 추가 ❌
  /// }
  /// ```
  ///
  /// 새 코드:
  /// ```dart
  /// final missingTasks = taskIds.difference(orderTaskIds);
  /// if (missingTasks.isNotEmpty) {
  ///   for (final taskId in missingTasks) {
  ///     // _pendingInsertions에서 targetOrder 찾기
  ///     final pending = _pendingInsertions.firstWhere(
  ///       (p) => p.taskId == taskId && p.date.isAtSameMomentAs(date),
  ///       orElse: () => null,
  ///     );
  ///
  ///     if (pending != null) {
  ///       // 드롭된 위치에 삽입 ✅
  ///       _insertTaskAtPosition(items, taskId, pending.targetOrder, tasks);
  ///     } else {
  ///       // 기본 순서로 맨 끝에 추가
  ///       items.add(UnifiedListItem.fromTask(task, sortOrder: items.length));
  ///     }
  ///   }
  /// }
  /// ```
  static void insertMissingTaskAtTargetPosition(
    List<dynamic> items, // UnifiedListItem
    int taskId,
    int targetOrder,
    List<dynamic> tasks, // TaskData
  ) {
    final task = tasks.firstWhere((t) => t.id == taskId);

    // targetOrder 위치에 삽입
    // 기존 items의 sortOrder를 조정
    for (int i = 0; i < items.length; i++) {
      if (items[i].sortOrder >= targetOrder) {
        items[i] = items[i].copyWith(sortOrder: items[i].sortOrder + 1);
      }
    }

    // 새 Task를 targetOrder에 추가
    items.add(
      // UnifiedListItem.fromTask(task, sortOrder: targetOrder)
      task, // 실제 구현에서는 UnifiedListItem.fromTask 사용
    );

    // sortOrder로 다시 정렬
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// 🎯 Step 2: 전체 리스트를 DailyCardOrder에 저장
  ///
  /// 기존 코드는 이미 존재함 (_handleReorder에서 saveDailyCardOrder 호출)
  ///
  /// 새로 추가할 부분:
  /// ```dart
  /// // _buildUnifiedItemList 마지막에 추가
  /// if (_pendingInsertions.isNotEmpty) {
  ///   // DailyCardOrder 저장
  ///   final itemsToSave = items
  ///       .where((i) => i.type != UnifiedItemType.divider && i.type != UnifiedItemType.dateHeader)
  ///       .map((i) => {'type': i.cardTypeString, 'id': i.actualId})
  ///       .toList();
  ///
  ///   await GetIt.I<AppDatabase>().saveDailyCardOrder(date, itemsToSave);
  ///
  ///   // 완료된 삽입 정보 제거
  ///   _pendingInsertions.removeWhere((p) => p.date.isAtSameMomentAs(date));
  /// }
  /// ```
}

/// 🎯 전체 구현 가이드
/// 
/// ============================================================================
/// 1. DateDetailView State에 추가
/// ============================================================================
/// ```dart
/// class _DateDetailViewState extends State<DateDetailView> {
///   // ... 기존 변수들 ...
///   
///   // 🔥 새로 추가
///   final List<PendingInsertion> _pendingInsertions = [];
/// ```
/// 
/// ============================================================================
/// 2. Schedule/Task/Habit DragTarget 수정
/// ============================================================================
/// ```dart
/// case UnifiedItemType.schedule:
///   return DragTarget<TaskData>(
///     onAcceptWithDetails: (details) async {
///       final droppedTask = details.data;
///       print('✅ [DragTarget-Schedule] 드롭: ${droppedTask.title}');
///       print('   └─ 위치: sortOrder=${item.sortOrder}');
///       
///       // 1️⃣ 드롭 위치 임시 저장
///       _pendingInsertions.add(PendingInsertion(
///         taskId: droppedTask.id,
///         date: date,
///         targetOrder: item.sortOrder,
///         timestamp: DateTime.now(),
///       ));
///       
///       // 2️⃣ 월뷰 방식: 단순히 executionDate만 업데이트
///       await GetIt.I<AppDatabase>().updateTaskDate(droppedTask.id, date);
///       
///       HapticFeedback.heavyImpact();
///       setState(() { _isDraggingFromInbox = false; });
///     },
///     // ... 나머지 동일 ...
///   );
/// ```
/// 
/// ============================================================================
/// 3. _buildUnifiedItemList 수정
/// ============================================================================
/// ```dart
/// Future<List<UnifiedListItem>> _buildUnifiedItemList(...) async {
///   // ... 기존 코드 ...
///   
///   if (cardOrders.isEmpty) {
///     // 기본 순서 생성
///     // ... 기존 코드 ...
///   } else {
///     // 커스텀 순서 복원
///     // ... 기존 코드 ...
///     
///     // 🔥 누락된 Task 처리
///     final missingTasks = taskIds.difference(orderTaskIds);
///     if (missingTasks.isNotEmpty) {
///       print('  ⚠️ 누락된 Task 발견: $missingTasks');
///       
///       for (final taskId in missingTasks) {
///         // _pendingInsertions에서 targetOrder 찾기
///         final pendingIndex = _pendingInsertions.indexWhere(
///           (p) => p.taskId == taskId && _isSameDay(p.date, date),
///         );
///         
///         if (pendingIndex != -1) {
///           final pending = _pendingInsertions[pendingIndex];
///           print('    🎯 드롭 위치로 삽입: Task $taskId → sortOrder=${pending.targetOrder}');
///           
///           // Task 데이터 찾기
///           final task = tasks.firstWhere((t) => t.id == taskId);
///           
///           // 기존 items의 sortOrder 증가 (targetOrder 이상만)
///           for (int i = 0; i < items.length; i++) {
///             if (items[i].sortOrder >= pending.targetOrder) {
///               final newOrder = items[i].sortOrder + 1;
///               items[i] = items[i].copyWith(sortOrder: newOrder);
///             }
///           }
///           
///           // 새 Task 삽입
///           items.add(UnifiedListItem.fromTask(task, sortOrder: pending.targetOrder));
///           
///           // 완료된 삽입 정보 제거
///           _pendingInsertions.removeAt(pendingIndex);
///         } else {
///           print('    ➕ 기본 위치에 추가: Task $taskId');
///           // 기본 순서로 맨 끝에 추가
///           final task = tasks.firstWhere((t) => t.id == taskId);
///           items.add(UnifiedListItem.fromTask(task, sortOrder: items.length));
///         }
///       }
///       
///       // sortOrder로 재정렬
///       items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
///       
///       // 🔥 DailyCardOrder에 전체 저장
///       final itemsToSave = items
///           .where((i) => i.type != UnifiedItemType.divider && 
///                        i.type != UnifiedItemType.dateHeader)
///           .map((i) => {'type': i.cardTypeString, 'id': i.actualId})
///           .toList();
///       
///       await GetIt.I<AppDatabase>().saveDailyCardOrder(date, itemsToSave);
///       print('  💾 DailyCardOrder 저장 완료: ${itemsToSave.length}개');
///     }
///   }
///   
///   return items;
/// }
/// 
/// bool _isSameDay(DateTime a, DateTime b) {
///   return a.year == b.year && a.month == b.month && a.day == b.day;
/// }
/// ```
/// 
/// ============================================================================
/// 4. 빈 리스트 DragTarget 수정
/// ============================================================================
/// ```dart
/// DragTarget<TaskData>(
///   onAcceptWithDetails: (details) async {
///     final droppedTask = details.data;
///     print('✅ [빈 리스트] 드롭: ${droppedTask.title}');
///     
///     // 1️⃣ 드롭 위치 임시 저장 (빈 리스트 = sortOrder 0)
///     _pendingInsertions.add(PendingInsertion(
///       taskId: droppedTask.id,
///       date: widget.selectedDate,
///       targetOrder: 0,
///       timestamp: DateTime.now(),
///     ));
///     
///     // 2️⃣ 월뷰 방식
///     await GetIt.I<AppDatabase>().updateTaskDate(
///       droppedTask.id,
///       widget.selectedDate,
///     );
///     
///     HapticFeedback.heavyImpact();
///   },
///   // ... 나머지 동일 ...
/// );
/// ```
/// 
/// ============================================================================
/// 5. insertTaskAtPosition 메서드 삭제
/// ============================================================================
/// `/lib/Database/schedule_database.dart`에서 방금 추가한 `insertTaskAtPosition` 메서드 삭제
/// 
/// 이유: 더 이상 필요 없음. updateTaskDate + 자동 동기화로 해결!

