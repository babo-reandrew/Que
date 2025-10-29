#!/usr/bin/env python3
import sys
import re

file_path = sys.argv[1]

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Navigator.pop(context, true); 패턴을 찾아서 이중 pop으로 변경
i = 0
changes = 0
while i < len(lines):
    line = lines[i]
    
    # Navigator.pop(context, true);가 있고, 주석에 "변경" 또는 "変更"가 있는 경우
    if 'Navigator.pop(context, true);' in line and ('변경' in line or '変更' in line):
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
    else:
        i += 1

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print(f"✅ {changes}개의 Navigator.pop 수정 완료")
