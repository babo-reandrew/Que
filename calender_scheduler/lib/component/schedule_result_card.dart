// ===================================================================
// ⭐️ Schedule Result Card Widget
// ===================================================================
// Gemini AI가 추출한 일정/할일/습관을 카드 형태로 표시하는 위젯입니다.
//
// 주요 기능:
// - 타입별 구분 (일정/할일/습관)
// - 날짜/시간 정보 표시
// - 장소, 반복 규칙, 설명 표시
// - 수정/저장 버튼
// ===================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/extracted_schedule.dart';

class ScheduleResultCard extends StatelessWidget {
  /// 표시할 추출된 데이터 (ExtractedSchedule, ExtractedTask, ExtractedHabit 중 하나)
  final dynamic item;

  /// 수정 버튼 콜백
  final VoidCallback onEdit;

  /// 저장 버튼 콜백
  final VoidCallback onSave;

  /// 삭제 버튼 콜백 (선택)
  final VoidCallback? onDelete;

  const ScheduleResultCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onSave,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 타입 판별
    final ItemType itemType = _getItemType();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getTypeColor(itemType).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 타입 칩 + 제목
            Row(
              children: [
                _buildTypeChip(itemType),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 시간 정보
            _buildInfoRow(
              icon: Icons.access_time,
              label: _getTimeLabel(),
              color: Colors.blue,
            ),

            // 장소 (있는 경우만)
            if (_getLocation().isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.location_on,
                label: _getLocation(),
                color: Colors.red,
              ),
            ],

            // 반복 규칙 (있는 경우만)
            if (_getRepeatRule().isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.repeat,
                label: _parseRepeatRule(_getRepeatRule()),
                color: Colors.purple,
              ),
            ],

            // 설명 (있는 경우만)
            if (_getDescription().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getDescription(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 액션 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 삭제 버튼 (선택)
                if (onDelete != null) ...[
                  OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('삭제'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // 수정 버튼
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('수정'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _getTypeColor(itemType),
                  ),
                ),
                const SizedBox(width: 8),

                // 저장 버튼
                ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('저장'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getTypeColor(itemType),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 타입 판별 헬퍼
  ItemType _getItemType() {
    if (item is ExtractedSchedule) return ItemType.schedule;
    if (item is ExtractedTask) return ItemType.task;
    if (item is ExtractedHabit) return ItemType.habit;
    return ItemType.schedule; // fallback
  }

  /// 제목 가져오기
  String _getTitle() {
    if (item is ExtractedSchedule) return (item as ExtractedSchedule).summary;
    if (item is ExtractedTask) return (item as ExtractedTask).title;
    if (item is ExtractedHabit) return (item as ExtractedHabit).title;
    return '';
  }

  /// 설명 가져오기
  String _getDescription() {
    if (item is ExtractedSchedule) {
      return (item as ExtractedSchedule).description;
    }
    if (item is ExtractedTask) return (item as ExtractedTask).description;
    if (item is ExtractedHabit) return (item as ExtractedHabit).description;
    return '';
  }

  /// 장소 가져오기
  String _getLocation() {
    if (item is ExtractedSchedule) return (item as ExtractedSchedule).location;
    if (item is ExtractedTask) return (item as ExtractedTask).location;
    return '';
  }

  /// 반복 규칙 가져오기
  String _getRepeatRule() {
    if (item is ExtractedSchedule) {
      return (item as ExtractedSchedule).repeatRule;
    }
    if (item is ExtractedHabit) return (item as ExtractedHabit).repeatRule;
    return '';
  }

  /// 타입 칩 위젯
  Widget _buildTypeChip(ItemType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTypeColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTypeIcon(type), size: 16, color: _getTypeColor(type)),
          const SizedBox(width: 4),
          Text(
            _getTypeName(type),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getTypeColor(type),
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 행 위젯 (아이콘 + 텍스트)
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  /// 시간 레이블 생성
  String _getTimeLabel() {
    if (item is ExtractedSchedule) {
      final schedule = item as ExtractedSchedule;
      final dateFormat = DateFormat('M/d (E)', 'ko_KR');
      final timeFormat = DateFormat('HH:mm');

      final dateStr = dateFormat.format(schedule.start);
      final startTime = timeFormat.format(schedule.start);
      final endTime = timeFormat.format(schedule.end);

      // 같은 날짜인 경우
      if (DateUtils.isSameDay(schedule.start, schedule.end)) {
        return '$dateStr $startTime - $endTime';
      }

      // 다른 날짜인 경우
      final endDateStr = dateFormat.format(schedule.end);
      return '$dateStr $startTime - $endDateStr $endTime';
    }

    if (item is ExtractedTask) {
      final task = item as ExtractedTask;
      if (task.dueDate != null) {
        final dateFormat = DateFormat('M/d (E)', 'ko_KR');
        return '${dateFormat.format(task.dueDate!)}까지';
      }
      if (task.executionDate != null) {
        final dateFormat = DateFormat('M/d (E)', 'ko_KR');
        return dateFormat.format(task.executionDate!);
      }
      return '날짜 미지정';
    }

    if (item is ExtractedHabit) {
      return '반복 습관';
    }

    return '';
  }

  /// RRULE 파싱하여 한글 표시
  String _parseRepeatRule(String rrule) {
    if (rrule.isEmpty) return '';

    if (rrule.contains('FREQ=DAILY')) {
      return '매일 반복';
    }

    if (rrule.contains('FREQ=WEEKLY')) {
      if (rrule.contains('BYDAY')) {
        final days = _extractWeekdays(rrule);
        return days.isNotEmpty ? '매주 $days 반복' : '매주 반복';
      }
      return '매주 반복';
    }

    if (rrule.contains('FREQ=MONTHLY')) {
      return '매월 반복';
    }

    if (rrule.contains('FREQ=YEARLY')) {
      return '매년 반복';
    }

    return '반복 일정';
  }

  /// BYDAY에서 요일 추출
  String _extractWeekdays(String rrule) {
    final regex = RegExp(r'BYDAY=([A-Z,]+)');
    final match = regex.firstMatch(rrule);
    if (match == null) return '';

    final days = match.group(1)!.split(',');
    final dayNames = {
      'MO': '월',
      'TU': '화',
      'WE': '수',
      'TH': '목',
      'FR': '금',
      'SA': '토',
      'SU': '일',
    };

    return days.map((d) => dayNames[d] ?? d).join(', ');
  }

  /// 타입별 아이콘
  IconData _getTypeIcon(ItemType type) {
    switch (type) {
      case ItemType.schedule:
        return Icons.event;
      case ItemType.task:
        return Icons.check_circle_outline;
      case ItemType.habit:
        return Icons.repeat;
    }
  }

  /// 타입별 이름
  String _getTypeName(ItemType type) {
    switch (type) {
      case ItemType.schedule:
        return '일정';
      case ItemType.task:
        return '할 일';
      case ItemType.habit:
        return '습관';
    }
  }

  /// 타입별 색상
  Color _getTypeColor(ItemType type) {
    switch (type) {
      case ItemType.schedule:
        return Colors.blue;
      case ItemType.task:
        return Colors.green;
      case ItemType.habit:
        return Colors.orange;
    }
  }
}
