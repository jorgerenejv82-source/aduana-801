import re

with open(r'C:\Users\jorge\.gemini\antigravity\scratch\all_files.txt', 'r', encoding='utf-8') as f:
    content = f.read()

files = content.split('@@@ ')
for file_content in files:
    if not file_content.strip(): continue
    lines = file_content.split('\n')
    filepath = lines[0].strip()
    
    # Check for Expanded inside SingleChildScrollView
    code_lines = [l.split('|', 1)[1] if '|' in l else l for l in lines[1:]]
    code = '\n'.join(code_lines)
    
    issues = []
    
    # 1. Unbounded height/width
    if 'SingleChildScrollView(' in code and 'Expanded(' in code:
        issues.append('Possible Expanded inside SingleChildScrollView')
    if 'Column(' in code and 'ListView(' in code and 'shrinkWrap: true' not in code and 'shrinkWrap:true' not in code:
        issues.append('ListView without shrinkWrap inside possible Column')
    
    # 2. Instantiations in build
    build_idx = code.find('Widget build(')
    if build_idx != -1:
        build_code = code[build_idx:]
        if re.search(r'\b(TextEditingController|AnimationController|FocusNode|ScrollController)\s*\(', build_code):
            issues.append('Controller instantiated in build()')

    # 3. Memory leaks
    if re.search(r'\b(TextEditingController|AnimationController|FocusNode|ScrollController)\s*\(', code):
        if 'void dispose()' not in code:
            issues.append('Controller created but no dispose() method found')
        else:
            # Check if all controllers are disposed
            controllers = re.findall(r'\b([_a-zA-Z0-9]+)\s*=\s*(?:TextEditingController|AnimationController|FocusNode|ScrollController)\s*\(', code)
            for c in controllers:
                if f'{c}.dispose()' not in code and f'{c}?.dispose()' not in code:
                    issues.append(f'Controller {c} not disposed')

    # 4. Async contexts
    # simplistic check
    if 'await ' in code and 'context' in code:
        if 'if (!mounted) return;' not in code and 'if(!mounted)return;' not in code:
            issues.append('Missing if (!mounted) return; after await')

    if issues:
        print(f'--- {filepath} ---')
        for iss in set(issues):
            print(f'  - {iss}')

