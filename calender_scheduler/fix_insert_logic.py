#!/usr/bin/env python3
"""
Fix the insert logic in date_detail_view.dart
"""

with open('lib/screen/date_detail_view.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find and replace lines 1841-1853
# Line numbers are 1-indexed, but list is 0-indexed
start_idx = 1840  # line 1841
end_idx = 1853    # line 1854

old_block = """      int adjustedInsertIndex = actualDataIndex;
      
      if (existingTaskIndex != -1) {
        print('   🔄 기존 Task 발견 (index: $existingTaskIndex)');
        
        // 기존 Task가 삽입 위치보다 앞에 있으면, 제거 후 인덱스가 -1 됨
        if (existingTaskIndex < actualDataIndex) {
          adjustedInsertIndex = actualDataIndex - 1;
          print('   📍 기존 Task가 앞에 있음 → 삽입 인덱스 조정: $actualDataIndex → $adjustedInsertIndex');
        }
        
        updatedItems.removeAt(existingTaskIndex);
        print('   🗑️ 기존 Task 제거 완료');
      }
"""

new_block = """      int adjustedInsertIndex = actualDataIndex;
      
      if (existingTaskIndex != -1) {
        print('   🔄 기존 Task 발견 (index: $existingTaskIndex)');
        
        // 🔥 핵심 수정: 먼저 제거하고, 그 다음에 인덱스 조정
        // 기존 Task가 삽입 위치보다 앞에 있으면, 제거 후 리스트가 한 칸 당겨지므로
        // 삽입 인덱스도 -1 해야 함
        updatedItems.removeAt(existingTaskIndex);
        print('   🗑️ 기존 Task 제거 완료');
        
        if (existingTaskIndex < actualDataIndex) {
          adjustedInsertIndex = actualDataIndex - 1;
          print('   📍 기존 Task가 앞에 있었음 → 삽입 인덱스 조정: $actualDataIndex → $adjustedInsertIndex');
        }
      }
"""

# Replace the block
lines_before = lines[:start_idx]
lines_after = lines[end_idx:]
new_lines = lines_before + [new_block] + lines_after

# Write back
with open('lib/screen/date_detail_view.dart', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("✅ Fixed the insert logic - removeAt is now before index adjustment")
