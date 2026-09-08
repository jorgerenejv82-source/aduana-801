// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/constants/firestore_collections.dart';

class SearchScreen extends StatefulWidget {
  final String? initialPersona;
  const SearchScreen({super.key, this.initialPersona});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';
  bool _isSearching = false;
  List<_ModuleResult> _moduleResults = [];
  List<Map<String, dynamic>> _immexResults = [];
  List<String> _recentSearches = [];

  // ── All modules for search ──
  static const _allModules = [
    _ModuleResult(
        title: 'Landed Cost Avanzado',
        subtitle: 'Calcula el costo total de importación',
        route: '/landed_cost',
        icon: Icons.calculate),
    _ModuleResult(
        title: '¿Cuánto cuesta importar?',
        subtitle: 'Calculadora básica de importación',
        route: '/how_much_to_import',
        icon: Icons.attach_money),
    _ModuleResult(
        title: 'Clasificador Arancelario',
        subtitle: 'Encuentra la fracción correcta con IA',
        route: '/classifier',
        icon: Icons.category),
    _ModuleResult(
        title: 'Control Temporalidad IMMEX',
        subtitle: 'Anexo 24 - inventario IMMEX',
        route: '/control_immex',
        icon: Icons.inventory),
    _ModuleResult(
        title: 'Copiloto Aduanero',
        subtitle: 'Asistente IA para comercio exterior',
        route: '/copiloto',
        icon: Icons.smart_toy),
    _ModuleResult(
        title: 'Pre-Glosa',
        subtitle: 'Verificación previa de pedimentos',
        route: '/pre_glosa',
        icon: Icons.fact_check),
    _ModuleResult(
        title: 'Permisos de Exportación',
        subtitle: 'Control de permisos y licencias',
        route: '/export_permits',
        icon: Icons.approval),
    _ModuleResult(
        title: 'TMEC / USMCA',
        subtitle: 'Certificados de origen',
        route: '/tmec',
        icon: Icons.flag),
    _ModuleResult(
        title: 'NOMs Aplicables',
        subtitle: 'Normas Oficiales Mexicanas',
        route: '/noms',
        icon: Icons.rule),
    _ModuleResult(
        title: 'Incoterms 2020',
        subtitle: 'Términos de comercio internacional',
        route: '/incoterms',
        icon: Icons.local_shipping),
    _ModuleResult(
        title: 'Glosario Aduanero',
        subtitle: 'Términos y definiciones',
        route: '/glossary',
        icon: Icons.book),
    _ModuleResult(
        title: 'ROI Calculator',
        subtitle: 'Calcula el retorno de inversión',
        route: '/roi_calculator',
        icon: Icons.trending_up),
    _ModuleResult(
        title: 'Flujo de Caja',
        subtitle: 'Proyección de cash flow',
        route: '/cashflow',
        icon: Icons.waterfall_chart),
    _ModuleResult(
        title: 'Dashboard Importador',
        subtitle: 'KPIs y métricas de importación',
        route: '/importer_dashboard',
        icon: Icons.dashboard),
    _ModuleResult(
        title: 'Mi Suscripción',
        subtitle: 'Ver y gestionar tu plan',
        route: '/subscription',
        icon: Icons.credit_card),
    _ModuleResult(
        title: 'Mi Perfil',
        subtitle: 'Editar datos y preferencias',
        route: '/profile',
        icon: Icons.person),
    _ModuleResult(
        title: 'Arancel Mexico',
        subtitle: 'Consulta la TIGIE',
        route: '/arancel_mexico',
        icon: Icons.table_chart),
    _ModuleResult(
        title: 'Duty Drawback',
        subtitle: 'Recupera impuestos pagados',
        route: '/duty_drawback',
        icon: Icons.currency_exchange),
    _ModuleResult(
        title: 'OEA - Operador Económico',
        subtitle: 'Proceso de certificación OEA',
        route: '/oea_certification',
        icon: Icons.verified),
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    // Auto-focus after frame
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recent_searches') ?? [];
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 10) searches.removeLast();
    await prefs.setStringList('recent_searches', searches);
    setState(() => _recentSearches = searches);
  }

  void _onQueryChanged(String q) {
    setState(() => _query = q);
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() {
        _moduleResults = [];
        _immexResults = [];
        _isSearching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(q));
  }

  Future<void> _search(String q) async {
    setState(() => _isSearching = true);
    final lower = q.toLowerCase();

    // Module search (local, instant)
    final modules = _allModules
        .where((m) =>
            m.title.toLowerCase().contains(lower) ||
            m.subtitle.toLowerCase().contains(lower))
        .toList();

    // IMMEX search (Firestore)
    List<Map<String, dynamic>> immex = [];
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final snap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.immexInventario)
            .where('uid', isEqualTo: uid)
            .limit(20)
            .get();
        immex = snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .where((d) =>
                (d['fraccion'] as String? ?? '')
                    .toLowerCase()
                    .contains(lower) ||
                (d['pedimentoImportacion'] as String? ?? '')
                    .toLowerCase()
                    .contains(lower))
            .toList();
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _moduleResults = modules;
      _immexResults = immex;
      _isSearching = false;
    });
    unawaited(_saveSearch(q));
  }

  void _navigateTo(String route) {
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _query.isEmpty
                  ? _buildHomepage()
                  : _isSearching
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: AppColors.gold))
                      : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.gold, size: 18),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              onChanged: _onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'Buscar módulos, fracciones, pedimentos...',
                hintStyle: TextStyle(color: AppColors.sub, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.sub, size: 18),
              onPressed: () {
                _ctrl.clear();
                _onQueryChanged('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHomepage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          const _SectionHeader('Búsquedas recientes'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches
                .take(6)
                .map((s) => ActionChip(
                      label: Text(s,
                          style: const TextStyle(
                              color: AppColors.sub, fontSize: 12)),
                      backgroundColor: AppColors.card,
                      side: const BorderSide(color: AppColors.border),
                      onPressed: () {
                        _ctrl.text = s;
                        _onQueryChanged(s);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
        const _SectionHeader('Accesos rápidos'),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: const [
            _QuickCard(title: '🧮 Landed Cost', route: '/landed_cost'),
            _QuickCard(title: '🤖 Copiloto', route: '/copiloto'),
            _QuickCard(title: '📦 IMMEX Anexo 24', route: '/control_immex'),
            _QuickCard(title: '📋 Clasificador', route: '/classifier'),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Todos los módulos'),
        const SizedBox(height: 8),
        ..._allModules.take(10).map(
            (m) => _ModuleTile(result: m, onTap: () => _navigateTo(m.route))),
      ],
    );
  }

  Widget _buildResults() {
    final hasResults = _moduleResults.isNotEmpty || _immexResults.isNotEmpty;
    if (!hasResults) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, color: AppColors.sub, size: 56),
            const SizedBox(height: 12),
            Text('Sin resultados para "$_query"',
                style: const TextStyle(color: AppColors.sub, fontSize: 15)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_moduleResults.isNotEmpty) ...[
          _SectionHeader('Módulos (${_moduleResults.length})'),
          const SizedBox(height: 8),
          ..._moduleResults.map(
              (m) => _ModuleTile(result: m, onTap: () => _navigateTo(m.route))),
          const SizedBox(height: 16),
        ],
        if (_immexResults.isNotEmpty) ...[
          _SectionHeader('IMMEX — Inventario (${_immexResults.length})'),
          const SizedBox(height: 8),
          ..._immexResults.map((d) => _ImmexTile(
                fraccion: d['fraccion'] as String? ?? '',
                pedimento: d['pedimentoImportacion'] as String? ?? '',
                restante: (d['cantidadRestante'] as num?)?.toDouble() ?? 0,
                onTap: () => _navigateTo('/control_immex'),
              )),
        ],
      ],
    );
  }
}

// ── Static data model ──
class _ModuleResult {
  final String title, subtitle, route;
  final IconData icon;
  const _ModuleResult(
      {required this.title,
      required this.subtitle,
      required this.route,
      required this.icon});
}

// ── Sub-widgets ──
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5));
}

class _QuickCard extends StatelessWidget {
  final String title, route;
  const _QuickCard({required this.title, required this.route});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.go(route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      );
}

class _ModuleTile extends StatelessWidget {
  final _ModuleResult result;
  final VoidCallback onTap;
  const _ModuleTile({required this.result, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(result.icon, color: AppColors.gold, size: 18),
        ),
        title: Text(result.title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        subtitle: Text(result.subtitle,
            style: const TextStyle(color: AppColors.sub, fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: AppColors.border, size: 12),
        onTap: onTap,
      );
}

class _ImmexTile extends StatelessWidget {
  final String fraccion, pedimento;
  final double restante;
  final VoidCallback onTap;
  const _ImmexTile(
      {required this.fraccion,
      required this.pedimento,
      required this.restante,
      required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.inventory_2_outlined,
              color: AppColors.blue, size: 18),
        ),
        title: Text(fraccion,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        subtitle: Text(
            'Pedimento: $pedimento · ${restante.toStringAsFixed(0)} u restantes',
            style: const TextStyle(color: AppColors.sub, fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: AppColors.border, size: 12),
        onTap: onTap,
      );
}
