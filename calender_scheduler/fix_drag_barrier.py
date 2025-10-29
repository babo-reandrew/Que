#!/usr/bin/env python3
import sys
import re

file_path = sys.argv[1]

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. showModalBottomSheet 앞에 변수 추가
insert_position = content.find('await showModalBottomSheet(')
if insert_position != -1:
    # 들여쓰기 찾기
    line_start = content.rfind('\n', 0, insert_position) + 1
    indent = ' ' * (insert_position - line_start)
    
    variables = f'''{indent}// ✅ 드래그 방향 추적 변수
{indent}double? _previousExtent;
{indent}bool _isDismissing = false; // 팝업 중복 방지

{indent}'''
    
    content = content[:insert_position] + variables + content[insert_position:]

# 2. GestureDetector를 Stack으로 변경
content = re.sub(
    r'(child: GestureDetector\(\s+behavior: HitTestBehavior\.opaque,\s+onTap: \(\) async \{)',
    r'child: Stack(\n        children: [\n          // ✅ 배리어 영역 (전체 화면)\n          Positioned.fill(\n            child: GestureDetector(\n              behavior: HitTestBehavior.opaque,\n              onTap: () async {',
    content,
    count=1
)

# 3. 배리어 GestureDetector 닫기 및 바텀시트 시작
content = re.sub(
    r'(\}\s+\}\s+\},\s+child: NotificationListener)',
    r'}\n              },\n              child: Container(color: Colors.transparent),\n            ),\n          ),\n          // ✅ 바텀시트 (배리어 위에)\n          NotificationListener',
    content,
    count=1
)

# 4. NotificationListener의 드래그 방향 감지 로직 수정
old_drag_logic = r'if \(notification\.extent <= notification\.minExtent \+ 0\.05\) \{'
new_drag_logic = r'''// ✅ 드래그 방향 감지 (아래로만)
              final isMovingDown = _previousExtent != null && notification.extent < _previousExtent!;
              _previousExtent = notification.extent;
              
              // ✅ 바텀시트를 아래로 드래그하여 minChildSize 이하로 내릴 때만
              if (isMovingDown && 
                  notification.extent <= notification.minExtent + 0.05 &&
                  !_isDismissing) {'''

content = re.sub(old_drag_logic, new_drag_logic, content, count=1)

# 5. _isDismissing 플래그 추가
content = re.sub(
    r"(debugPrint\('🐛 \[.*?Wolt\] 드래그 닫기 감지'\);)",
    r"debugPrint('🐛 [TaskWolt] 아래로 드래그 닫기 감지');\n                \n                _isDismissing = true; // 중복 방지",
    content,
    count=1
)

# 6. _isDismissing 리셋 추가
content = re.sub(
    r'(if \(sheetContext\.mounted\) \{\s+final confirmed = await showDiscardChangesModal\(context\);\s+if \(confirmed == true && sheetContext\.mounted\) \{\s+Navigator\.of\(sheetContext\)\.pop\(\);\s+\}\s+\})',
    r'\1\n                      _isDismissing = false; // 리셋',
    content,
    count=1
)

content = re.sub(
    r'(Navigator\.of\(sheetContext, rootNavigator: false\)\.pop\(\);\s+\} catch \(e\) \{\s+debugPrint\(\'❌ 바텀시트 닫기 실패: \$e\'\);\s+\}\s+\})',
    r'\1\n                      _isDismissing = false; // 리셋',
    content,
    count=1
)

# 7. 내부 GestureDetector 수정 및 Stack children 닫기
content = re.sub(
    r'(child: GestureDetector\(\s+behavior: HitTestBehavior\.translucent,\s+onTap: \(\) \{\s+// ✅ 바텀시트 내부 터치는 무시 \(배리어만 감지\)\s+debugPrint\(\'🐛 \[.*?Wolt\] 바텀시트 내부 터치\'\);\s+\},\s+child: DraggableScrollableSheet\()',
    r'child: DraggableScrollableSheet(',
    content,
    count=1
)

content = re.sub(
    r'(builder: \(context, scrollController\) => Container\()',
    r'builder: (context, scrollController) => GestureDetector(\n                behavior: HitTestBehavior.opaque,\n                onTap: () {\n                  // ✅ 바텀시트 내부 터치는 아무것도 안함 (포커스 해제 등)\n                  debugPrint(\'🐛 [TaskWolt] 바텀시트 내부 터치\');\n                },\n                child: Container(',
    content,
    count=1
)

# 8. Container 닫기 전에 GestureDetector 닫기 추가
content = re.sub(
    r'(\),\s+\),\s+\),\s+\),\s+\),\s+\);\s+\})',
    r'),\n                ),\n              ),\n            ),\n          ),\n        ],\n      ),\n    ),\n  );\n}',
    content,
    count=1
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"✅ {file_path} 수정 완료")
