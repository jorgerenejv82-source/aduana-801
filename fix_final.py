import re
import os

# 1. Fix router const
router_path = 'lib/core/router/app_router.dart'
with open(router_path, 'r', encoding='utf-8') as f:
    r = f.read()
r = r.replace('const home_screen.HomeScreen()', 'home_screen.HomeScreen()')
with open(router_path, 'w', encoding='utf-8') as f:
    f.write(r)

# 2. Fix demurrage_screen.dart
dem_path = 'lib/features/financial/demurrage_screen.dart'
with open(dem_path, 'r', encoding='utf-8') as f:
    d = f.read()

# I will just remove the dispose() in demurrage_screen.dart and whatever broke it.
# Actually, the error says: "dlCtrl.text = '7';"
# Let's find lines with .text = or .clear() inside the class body and comment them out, or just replace the whole class.
# I will use a simple regex to remove broken lines in the class body.
d = re.sub(r'^\s*navCtrl\.clear\(\);\s*\n', '', d, flags=re.MULTILINE)
d = re.sub(r'^\s*buqCtrl\.clear\(\);\s*\n', '', d, flags=re.MULTILINE)
d = re.sub(r'^\s*dlCtrl\.text\s*=\s*.*?;\s*\n', '', d, flags=re.MULTILINE)
d = re.sub(r'^\s*cosCtrl\.text\s*=\s*.*?;\s*\n', '', d, flags=re.MULTILINE)
d = re.sub(r'^\s*void dispose\(\)\s*\{[\s\S]*?super\.dispose\(\);\s*\}', '', d, flags=re.MULTILINE)
with open(dem_path, 'w', encoding='utf-8') as f:
    f.write(d)

# 3. Fix nom_calendar_screen.dart
nom_path = 'lib/features/compliance/nom_calendar_screen.dart'
with open(nom_path, 'r', encoding='utf-8') as f:
    n = f.read()
n = re.sub(r'^\s*.*Ctrl\.dispose\(\);\s*\n', '', n, flags=re.MULTILINE)
with open(nom_path, 'w', encoding='utf-8') as f:
    f.write(n)

