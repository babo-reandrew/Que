/// UnifiedListItem - 통합 리스트 아이템 모델
///
/// 이거를 설정하고 → 일정/할일/습관/구분선/완료섹션을 하나의 모델로 통합해서
/// 이거를 해서 → AnimatedReorderableListView에서 단일 리스트로 관리하고
/// 이거는 이래서 → 재정렬 시 타입 구분 없이 자유롭게 배치할 수 있다
///
/// **사용 예시:**
/// ```dart
/// // 일정 아이템
/// UnifiedListItem.fromSchedule(schedule, sortOrder: 0);
///
/// // 할일 아이템
/// UnifiedListItem.fromTask(task, sortOrder: 1);
///
/// // 점선 구분선
/// UnifiedListItem.divider(sortOrder: 2);
/// ```

import '../Database/schedule_database.dart';

/// 통합 리스트 아이템 타입
enum UnifiedItemType {
  schedule, // 일정
  task, // 할일
  habit, // 습관
  divider, // 점선 구분선
  completed, // 완료 섹션
}

/// 통합 리스트 아이템 클래스
class UnifiedListItem {
  // 🔑 고유 ID (타입_실제ID)
  // 이거를 설정하고 → 'schedule_1', 'task_5', 'habit_3' 형태로 생성해서
  // 이거를 해서 → AnimatedReorderableListView의 Key로 사용하고
  // 이거는 이래서 → 같은 타입에서 ID가 중복되어도 구분 가능하다
  final String uniqueId;

  // 🎯 아이템 타입
  final UnifiedItemType type;

  // 📦 실제 데이터 (nullable - divider의 경우 null)
  // 이거를 설정하고 → ScheduleData | TaskData | HabitData를 저장해서
  // 이거를 해서 → 실제 카드를 렌더링할 때 사용한다
  final dynamic data;

  // 📊 정렬 순서 (0부터 시작, 작을수록 위)
  // 이거를 설정하고 → 화면에 표시될 순서를 저장해서
  // 이거를 해서 → 재정렬 시 이 값을 기준으로 정렬한다
  final int sortOrder;

  // 🔒 드래그 가능 여부
  // 이거를 설정하고 → 재정렬 가능 여부를 플래그로 저장해서
  // 이거를 해서 → 점선이나 완료섹션은 고정시킨다
  final bool isDraggable;

  /// 생성자
  UnifiedListItem({
    required this.uniqueId,
    required this.type,
    this.data,
    required this.sortOrder,
    this.isDraggable = true,
  });

  // ============================================================================
  // 🏭 팩토리 메서드들
  // ============================================================================

  /// Schedule로부터 UnifiedListItem 생성
  /// 이거를 설정하고 → ScheduleData를 받아서 UnifiedListItem으로 변환해서
  /// 이거를 해서 → 일정 카드를 리스트에 추가할 수 있다
  factory UnifiedListItem.fromSchedule(
    ScheduleData schedule, {
    required int sortOrder,
  }) {
    return UnifiedListItem(
      uniqueId: 'schedule_${schedule.id}',
      type: UnifiedItemType.schedule,
      data: schedule,
      sortOrder: sortOrder,
      isDraggable: true,
    );
  }

  /// Task로부터 UnifiedListItem 생성
  /// 이거를 설정하고 → TaskData를 받아서 UnifiedListItem으로 변환해서
  /// 이거를 해서 → 할일 카드를 리스트에 추가할 수 있다
  factory UnifiedListItem.fromTask(TaskData task, {required int sortOrder}) {
    return UnifiedListItem(
      uniqueId: 'task_${task.id}',
      type: UnifiedItemType.task,
      data: task,
      sortOrder: sortOrder,
      isDraggable: true,
    );
  }

  /// Habit로부터 UnifiedListItem 생성
  /// 이거를 설정하고 → HabitData를 받아서 UnifiedListItem으로 변환해서
  /// 이거를 해서 → 습관 카드를 리스트에 추가할 수 있다
  factory UnifiedListItem.fromHabit(HabitData habit, {required int sortOrder}) {
    return UnifiedListItem(
      uniqueId: 'habit_${habit.id}',
      type: UnifiedItemType.habit,
      data: habit,
      sortOrder: sortOrder,
      isDraggable: true,
    );
  }

  /// 점선 구분선 생성
  /// 이거를 설정하고 → 점선 구분선 아이템을 생성해서
  /// 이거를 해서 → 일정 섹션과 할일/습관 섹션을 시각적으로 구분하고
  /// 이거는 이래서 → isDraggable = false로 고정된다
  factory UnifiedListItem.divider({required int sortOrder}) {
    return UnifiedListItem(
      uniqueId: 'divider_schedule',
      type: UnifiedItemType.divider,
      data: null,
      sortOrder: sortOrder,
      isDraggable: false, // 점선은 드래그 불가
    );
  }

  /// 완료 섹션 생성
  /// 이거를 설정하고 → 완료 섹션 아이템을 생성해서
  /// 이거를 해서 → 완료된 항목들을 별도로 표시하고
  /// 이거는 이래서 → isDraggable = false로 고정된다
  factory UnifiedListItem.completed({required int sortOrder}) {
    return UnifiedListItem(
      uniqueId: 'completed_section',
      type: UnifiedItemType.completed,
      data: null,
      sortOrder: sortOrder,
      isDraggable: false, // 완료 섹션은 드래그 불가
    );
  }

  // ============================================================================
  // 🔧 유틸리티 메서드들
  // ============================================================================

  /// 실제 DB ID 가져오기
  /// 이거를 설정하고 → data의 타입을 확인해서
  /// 이거를 해서 → 실제 Schedule/Task/Habit의 ID를 반환하고
  /// 이거는 이래서 → DB 업데이트 시 사용한다
  int? get actualId {
    if (data is ScheduleData) return (data as ScheduleData).id;
    if (data is TaskData) return (data as TaskData).id;
    if (data is HabitData) return (data as HabitData).id;
    return null;
  }

  /// 카드 타입 문자열 (DB 저장용)
  /// 이거를 설정하고 → UnifiedItemType을 'schedule', 'task', 'habit'로 변환해서
  /// 이거를 해서 → DailyCardOrder 테이블의 cardType 컬럼에 저장한다
  String get cardTypeString {
    return type.toString().split('.').last;
  }

  /// copyWith 메서드 (불변 업데이트)
  /// 이거를 설정하고 → 특정 필드만 변경한 새로운 인스턴스를 생성해서
  /// 이거를 해서 → 재정렬 시 sortOrder만 업데이트할 수 있고
  /// 이거는 이래서 → 기존 데이터는 그대로 유지된다
  UnifiedListItem copyWith({
    String? uniqueId,
    UnifiedItemType? type,
    dynamic data,
    int? sortOrder,
    bool? isDraggable,
  }) {
    return UnifiedListItem(
      uniqueId: uniqueId ?? this.uniqueId,
      type: type ?? this.type,
      data: data ?? this.data,
      sortOrder: sortOrder ?? this.sortOrder,
      isDraggable: isDraggable ?? this.isDraggable,
    );
  }

  /// DB 저장용 Map 변환
  /// 이거를 설정하고 → UnifiedListItem을 Map으로 변환해서
  /// 이거를 해서 → saveDailyCardOrder() 함수에 전달할 수 있다
  Map<String, dynamic> toMap() {
    return {'type': cardTypeString, 'id': actualId, 'sortOrder': sortOrder};
  }

  @override
  String toString() {
    return 'UnifiedListItem('
        'uniqueId: $uniqueId, '
        'type: $type, '
        'actualId: $actualId, '
        'sortOrder: $sortOrder, '
        'isDraggable: $isDraggable'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UnifiedListItem &&
        other.uniqueId == uniqueId &&
        other.type == type &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return uniqueId.hashCode ^ type.hashCode ^ sortOrder.hashCode;
  }
}
