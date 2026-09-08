import sys
import re

def rewrite():
    file_path = r"C:\Users\jorge\.gemini\antigravity\scratch\aduana_801\lib\features\home\home_screen.dart"
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # 1. Add imports
    content = content.replace("import 'package:aduana_801/core/theme/app_colors.dart';",
                              "import 'package:aduana_801/core/theme/app_colors.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\nimport 'package:aduana_801/features/home/widgets/empty_state_widget.dart';")
    
    # 2. Update build method for bottom navigation bar and width constraint
    content = content.replace(
        "final isWide = MediaQuery.of(context).size.width > 850;",
        "final isWide = MediaQuery.of(context).size.width >= 600;"
    )
    
    scaffold_replacement = """      child: Scaffold(
      backgroundColor: AppColors.bg,
      drawer: isWide ? null : _buildDrawer(context),
      body: Column(
        children: [
          _buildTopBar(context, isWide),
          Expanded(
            child: Row(
              children: [
                if (isWide) _buildSidebar(context),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWide ? _buildBottomNavBar(context) : null,
    ));"""
    content = re.sub(r"      child: Scaffold\([\s\S]*?\)\);", scaffold_replacement, content)
    
    # 3. Add Search button
    search_button = """          // Search Button
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.sub),
            onPressed: () => _showGlobalSearch(context),
          ),
          const SizedBox(width: 8),
          
          // Selector de Rol"""
    content = content.replace("// Selector de Rol", search_button)
    
    # 4. Replace _buildContent
    build_content_start = content.find("  // ─── MAIN CONTENT")
    build_content_end = content.find("  Stream<List<Map<String, dynamic>>> _getPedimentosStream()")
    
    if build_content_start != -1 and build_content_end != -1:
        new_build_content = """  // ─── MAIN CONTENT ─────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildZoneA(context),
              const SizedBox(height: 32),
              _buildZoneB(context),
              const SizedBox(height: 32),
              _buildZoneC(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneA(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alertas y KPIs', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _getPedimentosStream(),
            builder: (context, snap) {
              int embarquesActivos = 0;
              int expedientesPendientes = 0;
              int alertasDia = 3; // Mock value
              
              if (snap.hasData) {
                final docs = snap.data!;
                embarquesActivos = docs.where((data) => (data['status']?.toString().toLowerCase() ?? '') != 'liberado').length;
                expedientesPendientes = docs.length;
              }

              final isMobile = MediaQuery.of(context).size.width < 768;
              final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'usuario@aduana.com';
              final sessionAbbrev = userEmail.split('@').first;
              
              return GridView.count(
                crossAxisCount: isMobile ? 1 : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 3 : 2,
                children: [
                  _KpiCardPremium(
                    icon: Icons.local_shipping_outlined,
                    value: '$embarquesActivos',
                    label: 'Embarques Activos',
                    accentColor: AppColors.blue,
                    trend: '', trendUp: true,
                  ),
                  _KpiCardPremium(
                    icon: Icons.folder_open_outlined,
                    value: '$expedientesPendientes',
                    label: 'Expedientes Pendientes',
                    accentColor: AppColors.gold,
                    trend: '', trendUp: true,
                  ),
                  _KpiCardPremium(
                    icon: Icons.warning_amber_rounded,
                    value: '$alertasDia',
                    label: 'Alertas del Día',
                    accentColor: AppColors.red,
                    trend: '', trendUp: false,
                  ),
                  _KpiCardPremium(
                    icon: Icons.person_outline,
                    value: sessionAbbrev,
                    label: 'Sesión',
                    accentColor: AppColors.green,
                    trend: '', trendUp: true,
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildZoneB(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Acceso Rápido', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Tus módulos más usados', style: TextStyle(color: AppColors.sub, fontSize: 14)),
        const SizedBox(height: 20),
        
        FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            
            final prefs = snapshot.data!;
            List<String> recents = prefs.getStringList('recent_routes') ?? [];
            List<String> pinned = prefs.getStringList('pinned_modules') ?? [];
            
            final defaultRecents = ['🏠 Dashboard', '📦 Embarques', '💰 Landed Cost', '📋 Expedientes', '🔍 Clasificar'];
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Para empezar / Recientes:', style: TextStyle(color: AppColors.sub, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: (recents.isEmpty ? defaultRecents : recents).take(5).map((r) => _buildChip(r)).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Favoritos pinned:', style: TextStyle(color: AppColors.sub, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...pinned.map((p) => _buildChip(p, isPinned: true)),
                      ActionChip(
                        label: const Text('Personalizar'),
                        avatar: const Icon(Icons.add, size: 16),
                        onPressed: () => _showFavoritesBottomSheet(context),
                        backgroundColor: AppColors.card,
                        labelStyle: const TextStyle(color: Colors.white),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ],
    );
  }

  Widget _buildChip(String label, {bool isPinned = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        avatar: isPinned ? const Icon(Icons.star, color: AppColors.gold, size: 16) : null,
        backgroundColor: AppColors.card,
        labelStyle: const TextStyle(color: Colors.white),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }

  Widget _buildZoneC(BuildContext context) {
    final sections = [
      {'title': '🏫 Aprender', 'key': 'novato', 'modules': [
        const _ModuleCardPremium(icon: Icons.menu_book_outlined, title: 'Glosario ComEx', desc: 'Términos', route: '/glosario', color: Color(0xFF6366F1)),
        const _ModuleCardPremium(icon: Icons.help_outline_outlined, title: 'FAQ', desc: 'Dudas', route: '/faq', color: Color(0xFF0891B2)),
      ]},
      {'title': '📦 Operaciones', 'key': 'agente', 'modules': [
        const _ModuleCardPremium(icon: Icons.directions_boat_outlined, title: 'Shipment Tracker', desc: 'Rastrea', route: '/shipment_tracker', color: Color(0xFF0EA5E9)),
        const _ModuleCardPremium(icon: Icons.folder_open_outlined, title: 'Expedientes', desc: 'Archivo', route: '/expedientes', color: Color(0xFF8B5CF6)),
      ]},
      {'title': '💰 Finanzas', 'key': 'all', 'modules': [
        const _ModuleCardPremium(icon: Icons.calculate_outlined, title: 'Landed Cost', desc: 'Costos', route: '/landed_cost', color: AppColors.green),
      ]},
      {'title': '⚖️ Cumplimiento', 'key': 'all', 'modules': [
        const _ModuleCardPremium(icon: Icons.gavel_outlined, title: 'Compliance OEA', desc: 'Auditorías', route: '/compliance', color: AppColors.gold),
      ]},
      {'title': '🔬 IA & Análisis', 'key': 'agente', 'modules': [
        const _ModuleCardPremium(icon: Icons.psychology_outlined, title: 'AI Copilot', desc: 'Asistencia', route: '/ai_copilot', color: AppColors.gold),
      ]},
      {'title': '🛠️ Herramientas', 'key': 'all', 'modules': [
        const _ModuleCardPremium(icon: Icons.category_outlined, title: 'Clasificador HS', desc: 'Búsqueda', route: '/classifier', color: AppColors.blue),
      ]},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Módulos por Categoría', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...sections.map((sec) {
          final title = sec['title'] as String;
          final key = sec['key'] as String;
          final modules = sec['modules'] as List<Widget>;
          
          if (title.contains('IA & Análisis') && _userRole != 'Agente Aduanal') return const SizedBox.shrink();
          
          bool expanded = false;
          if (title.contains('Aprender') && _userRole == 'novato') expanded = true; // Assume there's a novato role logic or similar
          if (title.contains('Operaciones') && (_userRole == 'Importador/Exportador' || _userRole == 'Agente Aduanal')) expanded = true;

          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: expanded,
              title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              iconColor: AppColors.gold,
              collapsedIconColor: AppColors.sub,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 1200 ? 3 : constraints.maxWidth > 800 ? 2 : 1;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3,
                        children: modules,
                      );
                    }
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.bg2,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.sub,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          // scroll to top logic could be implemented with a ScrollController
        } else if (index == 1) {
          _showGlobalSearch(context);
        } else if (index == 2) {
          context.go('/shipment_tracker');
        } else if (index == 3) {
          context.go('/importer_dashboard');
        } else if (index == 4) {
          Scaffold.of(context).openDrawer();
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Ops'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Finanzas'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Más'),
      ],
    );
  }

  void _showGlobalSearch(BuildContext context) {
    showSearch(context: context, delegate: _GlobalSearchDelegate());
  }

  void _showFavoritesBottomSheet(BuildContext context) {
    // Implement bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg,
      builder: (context) => const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('Personalizar Favoritos', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

"""
        
        content = content[:build_content_start] + new_build_content + content[build_content_end:]
        
        # Add SearchDelegate class at the end
        search_delegate_class = """
class _GlobalSearchDelegate extends SearchDelegate<String> {
  final List<String> allModules = [
    'Dashboard', 'Embarques', 'Landed Cost', 'Expedientes', 'Clasificar',
    'Shipment Tracker', 'AI Copilot', 'Compliance OEA', 'Glosario ComEx'
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.bg2),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    final results = allModules.where((m) => m.toLowerCase().contains(query.toLowerCase())).toList();

    if (results.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No se encontró "$query"',
        subtitle: '¿Pregunta al Copiloto IA?',
        actionLabel: 'Ir a Copiloto',
        onAction: () {
          // Handle navigation
        },
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.extension, color: AppColors.gold),
          title: Text(results[index], style: const TextStyle(color: Colors.white)),
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            List<String> recents = prefs.getStringList('recent_routes') ?? [];
            if (!recents.contains(results[index])) {
              recents.insert(0, results[index]);
              if (recents.length > 5) recents.removeLast();
              await prefs.setStringList('recent_routes', recents);
            }
            close(context, results[index]);
          },
        );
      },
    );
  }
}
"""
        content += search_delegate_class
        
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
            
rewrite()
