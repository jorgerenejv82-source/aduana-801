import sys
import re

file_path = r'C:\Users\jorge\.gemini\antigravity\scratch\aduana_801\lib\core\router\app_router.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

import_statement = "import 'package:aduana_801/features/home/widgets/recent_routes_tracker.dart';\n"
if import_statement not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_statement)

routes_to_update = {
    '/landed_cost': "'Landed Cost'",
    '/shipment_tracker': "'Torre de Tráfico'",
    '/expedientes': "'Expedientes'",
    '/supply_chain/po': "'Órdenes de Compra'",
    '/clientes': "'CRM Clientes'",
    '/importer_dashboard': "'Dashboard Importador'",
    '/tmec': "'Análisis TMEC'",
    '/tco_comparator': "'Comparador TCO'",
    '/nom_calendar': "'Calendario NOMs'",
    '/duty_drawback': "'Duty Drawback'",
}

for route, label in routes_to_update.items():
    pattern = r"(GoRoute\(\s*path:\s*'" + re.escape(route) + r"')(\s*,)\s*(builder:\s*.*?)\)\s*,?"
    
    def repl(m):
        return m.group(1) + ", redirect: (c, s) { RecentRoutesTracker.recordVisit('" + route + "', " + label + "); return null; }, " + m.group(3) + "),"

    content = re.sub(pattern, repl, content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
