import os
import re

target_dirs = ['home', 'auth', 'profile', 'kanban', 'expediente', 'despacho', 'pre_glosa']
base_path = r'C:\Users\jorge\.gemini\antigravity\scratch\aduana_801\lib\features'

files_to_check = []
for root, dirs, files in os.walk(base_path):
    for dir in target_dirs:
        if f'\\{dir}' in root or root.endswith(f'\\{dir}'):
            for f in files:
                if f.endswith('.dart'):
                    files_to_check.append(os.path.join(root, f))
            break # Avoid double counting if paths overlap

print(f"Found {len(files_to_check)} dart files.")

# Rule 2: Unbounded Height (SingleChildScrollView > Column > (ListView|GridView|Expanded))
# Actually just Expanded inside SingleChildScrollView > Column is a classic crash.
# Or ListView/GridView without shrinkWrap: true inside Column inside SingleChildScrollView.
# Let's just find files with SingleChildScrollView, Column, and Expanded/ListView/GridView.

# Rule 3: Memory Leaks
# Check if controller is created, then check if it's disposed.

# Rule 4: Async Contexts
# `await ` followed by `context` without `if (!mounted) return;` in between.

# Rule 5: Controllers in build()
# `Widget build` containing `TextEditingController(`, `FocusNode(`, etc.

issues = []

for filepath in set(files_to_check):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    filename = os.path.basename(filepath)

    # Rule 5
    build_methods = re.finditer(r'Widget\s+build\s*\([^)]*\)\s*\{', content)
    for match in build_methods:
        start_idx = match.end()
        # simplified check: look for controllers in the rest of the file after build
        # actually, better to match brackets, but a regex like `TextEditingController\(` after build might just be anywhere.
        pass # Too complex for simple regex without bracket matching, let's use a simpler heuristic
    
    lines = content.split('\n')
    
    inside_build = False
    brace_count = 0
    for i, line in enumerate(lines):
        if re.search(r'Widget\s+build\s*\(', line):
            inside_build = True
            brace_count += line.count('{') - line.count('}')
            continue
        
        if inside_build:
            brace_count += line.count('{') - line.count('}')
            if re.search(r'(TextEditingController|FocusNode|AnimationController|ScrollController)\(', line):
                issues.append(f"{filename}:{i+1} Rule 5 - Controller in build()")
            if brace_count <= 0:
                inside_build = False

    # Rule 4: Async Context
    # Look for await, then context usage.
    # We will search block by block
    blocks = re.split(r'\}', content)
    for i, line in enumerate(lines):
        if 'await ' in line:
            # check the next few lines for 'context'
            for j in range(1, 10):
                if i + j < len(lines):
                    next_line = lines[i+j]
                    if 'if (!mounted)' in next_line:
                        break # protected
                    if re.search(r'\bcontext\b', next_line) and not 'Theme.of(context)' in next_line and not 'MediaQuery.of(context)' in next_line:
                        issues.append(f"{filename}:{i+j+1} Rule 4 - Context used after await without mounted check")
                        break
                    if '}' in next_line:
                        break

    # Rule 3: Memory leaks
    # find state variables
    controllers = re.findall(r'(?:final|late)\s+(?:TextEditingController|AnimationController|FocusNode|ScrollController)\s+([_a-zA-Z0-9]+)', content)
    controllers += re.findall(r'([_a-zA-Z0-9]+)\s*=\s*(?:TextEditingController|AnimationController|FocusNode|ScrollController)\(', content)
    
    controllers = list(set(controllers))
    if controllers:
        dispose_match = re.search(r'void\s+dispose\s*\(\)\s*\{([^}]+)\}', content)
        if dispose_match:
            dispose_body = dispose_match.group(1)
            for c in controllers:
                if c not in dispose_body:
                    issues.append(f"{filename} Rule 3 - Controller {c} not disposed")
        else:
            if 'extends State<' in content:
                for c in controllers:
                    issues.append(f"{filename} Rule 3 - No dispose() method, {c} leaking")

    # Rule 2: Unbounded Height
    # Just check if file has SingleChildScrollView, Column, and Expanded
    # We'll just flag it to manually check.
    if 'SingleChildScrollView' in content and 'Column' in content:
        if 'Expanded(' in content or 'ListView(' in content or 'ListView.builder(' in content or 'GridView' in content:
            issues.append(f"{filename} Rule 2 - Potential Unbounded Height (SingleChildScrollView + Column + Expanded/ListView/GridView)")


with open(r'C:\Users\jorge\.gemini\antigravity\scratch\aduana_801\issues.txt', 'w', encoding='utf-8') as f:
    for issue in issues:
        f.write(issue + '\n')
print(f"Found {len(issues)} potential issues.")
