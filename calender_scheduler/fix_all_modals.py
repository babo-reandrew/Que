#!/usr/bin/env python3
import sys

file_path = sys.argv[1]

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

i = 0
changes = 0
inside_delete_or_edit_handler = False
handler_name = ""

while i < len(lines):
    line = lines[i]
    
    # 삭제/수정 핸들러 시작 감지
    if 'onDeleteThis:' in line or 'onDeleteFuture:' in line or 'onDeleteAll:' in line or \
       'onEditThis:' in line or 'onEditFuture:' in line or 'onEditAll:' in line:
        inside_delete_or_edit_handler = True
        if 'onDeleteThis:' in line:
            handler_name = "onDeleteThis"
        elif 'onDeleteFuture:' in line:
            handler_name = "onDeleteFuture"
        elif 'onDeleteAll:' in line:
            handler_name = "onDeleteAll"
        elif 'onEditThis:' in line:
            handler_name = "onEditThis"
        elif 'onEditFuture:' in line:
            handler_name = "onEditFuture"
        elif 'onEditAll:' in line:
            handler_name = "onEditAll"
    
    # 핸들러 종료 감지
    if inside_delete_or_edit_handler and (line.strip() == '},') and i > 0 and 'ScaffoldMessenger' in ''.join(lines[max(0,i-10):i]):
        inside_delete_or_edit_handler = False
        handler_name = ""
    
    # 핸들러 내부에서 Navigator.pop(context, true); 발견
    if inside_delete_or_edit_handler and 'Navigator.pop(context, true);' in line and 'if (context.mounted)' in ''.join(lines[max(0,i-5):i]):
        # 현재 들여쓰기 추출
        indent = len(line) - len(line.lstrip())
        indent_str = ' ' * indent
        
        # 4줄로 교체
        new_lines = [
            f'{indent_str}// ✅ 1. 확인 모달 닫기\n',
            f'{indent_str}Navigator.pop(context);\n',
            f'{indent_str}// ✅ 2. Detail modal 닫기 (변경 신호 전달)\n',
            f'{indent_str}Navigator.pop(context, true);\n',
        ]
        
        # 현재 라인 교체
        lines[i:i+1] = new_lines
        i += 4  # 새로 추가된 라인들 건너뛰기
        changes += 1
        print(f"  ✅ {handler_name} 수정")
    else:
        i += 1

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print(f"\n✅ 총 {changes}개의 Navigator.pop 수정 완료")
