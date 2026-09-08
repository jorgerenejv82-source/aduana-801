
import os

folders = ['copiloto', 'ai_copilot', 'alerts', 'financial', 'pricing', 'calculator', 'eagle_eye']
base_dir = r'C:\Users\jorge\.gemini\antigravity\scratch\aduana_801\lib\features'
output_file = r'C:\Users\jorge\.gemini\antigravity\scratch\all_files.txt'

with open(output_file, 'w', encoding='utf-8') as outfile:
    for folder in folders:
        folder_path = os.path.join(base_dir, folder)
        for root, _, files in os.walk(folder_path):
            for file in files:
                if file.endswith('.dart'):
                    file_path = os.path.join(root, file)
                    outfile.write(f'@@@ {file_path}\n')
                    try:
                        with open(file_path, 'r', encoding='utf-8') as infile:
                            lines = infile.readlines()
                            for i, line in enumerate(lines):
                                outfile.write(f'{i+1:4d} | {line}')
                    except Exception as e:
                        outfile.write(f'ERROR reading {file_path}: {e}\n')
                    outfile.write('\n')
print(f'Wrote to {output_file}')

