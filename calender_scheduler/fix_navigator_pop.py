#!/usr/bin/env python3
import sys
import re

file_path = sys.argv[1]

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# onEditThis, onEditFuture, onEditAll, onDeleteFuture, onDeleteAll 패턴 찾아서 수정
# 패턴: Navigator.pop(context, true); // ✅ 변경 신호 전달
# 또는: Navigator.pop(context, true); // ✅ 変更 신호 전달

replacements = [
    # onEditThis
    (r'(onEditThis:.*?debugPrint.*?この回のみ.*?完了.*?\n.*?if \(context\.mounted\) \{\n)(\s*Navigator\.pop\(context, true\);.*?\n)',
     r'\1          // ✅ 1. 확인 모달 닫기\n          Navigator.pop(context);\n          // ✅ 2. Detail modal 닫기 (변경 신호 전달)\n          Navigator.pop(context, true);\n'),
    
    # onEditFuture
    (r'(onEditFuture:.*?debugPrint.*?この予定以降.*?完了.*?\n.*?if \(context\.mounted\) \{\n)(\s*Navigator\.pop\(context, true\);.*?\n)',
     r'\1          // ✅ 1. 확인 모달 닫기\n          Navigator.pop(context);\n          // ✅ 2. Detail modal 닫기 (변경 신호 전달)\n          Navigator.pop(context, true);\n'),
    
    # onEditAll (더 복잡함 - 여러 줄 이후)
    (r'(onEditAll:.*?debugPrint.*?すべての回.*?完了.*?\n.*?\n.*?if \(safeRepeatRule.*?\n.*?\n.*?if \(context\.mounted\) \{\n)(\s*Navigator\.pop\(context, true\);.*?\n)',
     r'\1            // ✅ 1. 확인 모달 닫기\n            Navigator.pop(context);\n            // ✅ 2. Detail modal 닫기 (변경 신호 전달)\n            Navigator.pop(context, true);\n'),
]

for pattern, replacement in replacements:
    content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Schedule 모든 Edit/Delete 핸들러 수정 완료")
