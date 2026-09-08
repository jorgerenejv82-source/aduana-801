import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/firestore_collections.dart';

enum SearchResultType { route, expediente, cliente, po, action }

class SearchResult {
  final String title;
  final String subtitle;
  final String route;
  final SearchResultType type;
  final IconData icon;
  final Color color;
  final Map<String, dynamic>? routeExtra;

  const SearchResult({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.type,
    required this.icon,
    required this.color,
    this.routeExtra,
  });
}

class GlobalSearchScreen extends StatefulWidget {
  final String userPersona;
  const GlobalSearchScreen({super.key, required this.userPersona});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';
  List<SearchResult> _staticResults = [];
  List<SearchResult> _firestoreResults = [];
  bool _isSearchingFirestore = false;
  List<String> _recentSearches = [];
  Timer? _debounce;
  String _userPersona = 'importador';

  List<SearchResult> _getStaticRoutes(String persona) {
    final List<SearchResult> routes = [
      const SearchResult(
          title: 'Inicio',
          subtitle: 'Pantalla principal',
          route: '/home',
          type: SearchResultType.route,
          icon: Icons.home_outlined,
          color: AppColors.blue),
      const SearchResult(
          title: 'Mi Perfil',
          subtitle: 'Configuración de cuenta',
          route: '/profile',
          type: SearchResultType.route,
          icon: Icons.person_outline,
          color: AppColors.sub),
      const SearchResult(
          title: 'Precios y Planes',
          subtitle: 'Ver planes PRO y AGENTE',
          route: '/pricing',
          type: SearchResultType.route,
          icon: Icons.star_outline,
          color: AppColors.gold),
      const SearchResult(
          title: 'Notificaciones',
          subtitle: 'Centro de alertas',
          route: '/notifications',
          type: SearchResultType.route,
          icon: Icons.notifications_outlined,
          color: AppColors.gold),
      const SearchResult(
          title: 'Glosario',
          subtitle: 'Términos de comercio exterior',
          route: '/glosario',
          type: SearchResultType.route,
          icon: Icons.book_outlined,
          color: AppColors.blue),
      const SearchResult(
          title: 'FAQ',
          subtitle: 'Preguntas frecuentes',
          route: '/faq',
          type: SearchResultType.route,
          icon: Icons.help_outline,
          color: AppColors.blue),
      const SearchResult(
          title: 'Centro de Aprendizaje',
          subtitle: 'Guías y tutoriales',
          route: '/learning_center',
          type: SearchResultType.route,
          icon: Icons.school_outlined,
          color: Color(0xFF6366F1)),
    ];

    if (persona == 'novato') {
      routes.addAll([
        const SearchResult(
            title: 'Mi Primera Importación',
            subtitle: 'Guía paso a paso',
            route: '/mi_primer_despacho',
            type: SearchResultType.route,
            icon: Icons.flag_outlined,
            color: Color(0xFF6366F1)),
        const SearchResult(
            title: '¿Cuánto me cuesta importar?',
            subtitle: 'Estimador simple de costos',
            route: '/simple_estimator',
            type: SearchResultType.route,
            icon: Icons.calculate_outlined,
            color: Color(0xFF10B981)),
        const SearchResult(
            title: '¿Ganaré dinero?',
            subtitle: 'Calculadora de utilidad neta',
            route: '/utilidad_neta',
            type: SearchResultType.route,
            icon: Icons.trending_up_outlined,
            color: Color(0xFF10B981)),
      ]);
    }

    if (persona == 'importador' || persona == 'agente') {
      routes.addAll([
        const SearchResult(
            title: 'Landed Cost',
            subtitle: 'Calcula el costo total de importación',
            route: '/landed_cost',
            type: SearchResultType.route,
            icon: Icons.calculate,
            color: Color(0xFF10B981)),
        const SearchResult(
            title: 'Dashboard Importador',
            subtitle: 'Panel ejecutivo con KPIs',
            route: '/importer_dashboard',
            type: SearchResultType.route,
            icon: Icons.dashboard_outlined,
            color: Color(0xFF6366F1)),
        const SearchResult(
            title: 'Embarques',
            subtitle: 'Trazabilidad de contenedores',
            route: '/shipment_tracker',
            type: SearchResultType.route,
            icon: Icons.directions_boat_outlined,
            color: AppColors.blue),
        const SearchResult(
            title: 'Órdenes de Compra',
            subtitle: 'Gestión de POs',
            route: '/supply_chain/po',
            type: SearchResultType.route,
            icon: Icons.shopping_cart_outlined,
            color: AppColors.blue),
        const SearchResult(
            title: 'Proveedores',
            subtitle: 'CRM de proveedores',
            route: '/suppliers',
            type: SearchResultType.route,
            icon: Icons.factory_outlined,
            color: AppColors.sub),
        const SearchResult(
            title: 'Clientes',
            subtitle: 'CRM de clientes',
            route: '/clientes',
            type: SearchResultType.route,
            icon: Icons.people_outline,
            color: AppColors.sub),
        const SearchResult(
            title: 'Análisis TMEC/USMCA',
            subtitle: 'Preferencias arancelarias',
            route: '/tmec',
            type: SearchResultType.route,
            icon: Icons.flag_outlined,
            color: Color(0xFF10B981)),
        const SearchResult(
            title: 'Duty Drawback',
            subtitle: 'Recuperación de impuestos de importación',
            route: '/duty_drawback',
            type: SearchResultType.route,
            icon: Icons.savings_outlined,
            color: Color(0xFF10B981)),
        const SearchResult(
            title: 'TCO — Costo Total de Propiedad',
            subtitle: 'Compara proveedores por costo real',
            route: '/tco_comparator',
            type: SearchResultType.route,
            icon: Icons.compare_arrows_outlined,
            color: AppColors.blue),
        const SearchResult(
            title: 'ROI Calculator',
            subtitle: '¿Vale la pena esta operación?',
            route: '/roi_calculator',
            type: SearchResultType.route,
            icon: Icons.percent_outlined,
            color: Color(0xFF10B981)),
        const SearchResult(
            title: 'Cashflow',
            subtitle: 'Flujo de efectivo de operaciones',
            route: '/cashflow',
            type: SearchResultType.route,
            icon: Icons.waterfall_chart,
            color: AppColors.blue),
        const SearchResult(
            title: 'Cuotas Compensatorias',
            subtitle: 'Anti-dumping y cuotas compensatorias',
            route: '/cuotas_compensatorias',
            type: SearchResultType.route,
            icon: Icons.gavel,
            color: AppColors.red),
        const SearchResult(
            title: 'Simulador de Fracción',
            subtitle: 'Impacto fiscal de cambio de clasificación',
            route: '/fraccion_simulator',
            type: SearchResultType.route,
            icon: Icons.swap_horiz,
            color: AppColors.gold),
        const SearchResult(
            title: 'Comparador de Regímenes',
            subtitle: 'A1 vs IMMEX vs RFE',
            route: '/regimen_comparator',
            type: SearchResultType.route,
            icon: Icons.balance,
            color: AppColors.gold),
        const SearchResult(
            title: 'Permisos Previos',
            subtitle: 'COFEPRIS, SENASICA, SE',
            route: '/permisos_previos',
            type: SearchResultType.route,
            icon: Icons.verified_outlined,
            color: AppColors.red),
        const SearchResult(
            title: 'NOMs y Vigencias',
            subtitle: 'Normas Oficiales Mexicanas',
            route: '/nom_calendar',
            type: SearchResultType.route,
            icon: Icons.calendar_today_outlined,
            color: Color(0xFFF59E0B)),
        const SearchResult(
            title: 'Scorecard de Proveedores',
            subtitle: 'Desempeño y cumplimiento',
            route: '/supplier_scorecard',
            type: SearchResultType.route,
            icon: Icons.leaderboard_outlined,
            color: AppColors.blue),
      ]);
    }

    if (persona == 'agente') {
      routes.addAll([
        const SearchResult(
            title: 'Expedientes',
            subtitle: 'Gestión de operaciones aduanales',
            route: '/expedientes',
            type: SearchResultType.route,
            icon: Icons.folder_outlined,
            color: AppColors.gold),
        const SearchResult(
            title: 'Pre-Glosa IA',
            subtitle: 'Validación inteligente de pedimentos',
            route: '/pre_glosa',
            type: SearchResultType.route,
            icon: Icons.document_scanner_outlined,
            color: Color(0xFF6366F1)),
        const SearchResult(
            title: 'M3 Forensics',
            subtitle: 'Análisis forense de operaciones',
            route: '/m3_forensics',
            type: SearchResultType.route,
            icon: Icons.analytics_outlined,
            color: Color(0xFF6366F1)),
        const SearchResult(
            title: 'Semáforo Aduanal',
            subtitle: 'Control de reconocimientos',
            route: '/semaforo',
            type: SearchResultType.route,
            icon: Icons.traffic_outlined,
            color: AppColors.red),
        const SearchResult(
            title: 'Kanban de Despachos',
            subtitle: 'Tablero visual de operaciones',
            route: '/kanban',
            type: SearchResultType.route,
            icon: Icons.view_kanban_outlined,
            color: AppColors.blue),
        const SearchResult(
            title: 'Bóveda FIEL',
            subtitle: 'Gestión segura de e.firma',
            route: '/boveda_fiel',
            type: SearchResultType.route,
            icon: Icons.security_outlined,
            color: AppColors.gold),
        const SearchResult(
            title: 'VUCEM Sync',
            subtitle: 'Sincronización con VUCEM',
            route: '/vucem_sync',
            type: SearchResultType.route,
            icon: Icons.sync_outlined,
            color: AppColors.blue),
        const SearchResult(
            title: 'Torre de Tráfico',
            subtitle: 'Control de embarques activos',
            route: '/traffic_tower',
            type: SearchResultType.route,
            icon: Icons.control_camera_outlined,
            color: AppColors.blue),
        const SearchResult(
            title: 'Carta de Cupo',
            subtitle: 'Cupos arancelarios y preferencias',
            route: '/carta_de_cupo',
            type: SearchResultType.route,
            icon: Icons.card_membership_outlined,
            color: Color(0xFF10B981)),
      ]);
    }

    if (persona == 'exportador') {
      routes.addAll([
        const SearchResult(
            title: 'Certificado de Origen',
            subtitle: 'TMEC/USMCA, Form A, EUR1',
            route: '/tmec',
            type: SearchResultType.route,
            icon: Icons.verified_outlined,
            color: Color(0xFF10B981)),
        const SearchResult(
            title: 'Pedimento de Exportación',
            subtitle: 'Simula pedimentos A1/IN/RT',
            route: '/simulador_pedimento',
            type: SearchResultType.route,
            icon: Icons.receipt_long_outlined,
            color: Color(0xFF6366F1)),
        const SearchResult(
            title: 'Duty Drawback',
            subtitle: 'Recupera impuestos de importación usados en exportación',
            route: '/duty_drawback',
            type: SearchResultType.route,
            icon: Icons.savings_outlined,
            color: Color(0xFF10B981)),
        const SearchResult(
            title: 'IMMEX',
            subtitle: 'Importación temporal para exportar',
            route: '/immex',
            type: SearchResultType.route,
            icon: Icons.factory_outlined,
            color: AppColors.blue),
        const SearchResult(
            title: 'Reglas de Origen',
            subtitle: 'RVC, Cambio de Tarifa, Proceso Productivo',
            route: '/auditor_tmec_bom',
            type: SearchResultType.route,
            icon: Icons.rule_outlined,
            color: AppColors.gold),
        const SearchResult(
            title: 'OEA / CTPAT',
            subtitle: 'Operador Económico Autorizado',
            route: '/oea_seciit',
            type: SearchResultType.route,
            icon: Icons.security_outlined,
            color: AppColors.blue),
        const SearchResult(
            title: 'Permisos de Exportación',
            subtitle: 'SE, SEMARNAT, COFEPRIS para exportar',
            route: '/permisos_previos',
            type: SearchResultType.route,
            icon: Icons.gavel_outlined,
            color: AppColors.red),
        const SearchResult(
            title: 'Incoterms 2020',
            subtitle: 'FOB, CIF, EXW para exportaciones',
            route: '/incoterms',
            type: SearchResultType.route,
            icon: Icons.local_shipping_outlined,
            color: AppColors.blue),
        const SearchResult(
            title: 'Resumen Anual',
            subtitle: 'Tus exportaciones del año',
            route: '/annual_summary',
            type: SearchResultType.route,
            icon: Icons.calendar_month_outlined,
            color: Color(0xFF10B981)),
      ]);
    }

    // Quick Actions
    routes.addAll([
      const SearchResult(
          title: 'Nuevo Expediente',
          subtitle: 'Crear operación aduanal',
          route: '/expedientes',
          type: SearchResultType.action,
          icon: Icons.add_box_outlined,
          color: Color(0xFF10B981)),
      const SearchResult(
          title: 'Nueva Orden de Compra',
          subtitle: 'Agregar PO a supply chain',
          route: '/supply_chain/po/nueva',
          type: SearchResultType.action,
          icon: Icons.add_shopping_cart,
          color: Color(0xFF10B981)),
      const SearchResult(
          title: 'Calcular Landed Cost',
          subtitle: 'Abrir calculadora',
          route: '/landed_cost',
          type: SearchResultType.action,
          icon: Icons.calculate,
          color: Color(0xFF10B981)),
      const SearchResult(
          title: 'Rastrear Contenedor',
          subtitle: 'Buscar por número de contenedor',
          route: '/shipment_tracker',
          type: SearchResultType.action,
          icon: Icons.search,
          color: AppColors.blue),
    ]);

    return routes;
  }

  @override
  void initState() {
    super.initState();
    _userPersona = widget.userPersona;
    _staticResults = _getStaticRoutes(_userPersona);
    _loadRecentSearches();
    _focusNode.requestFocus();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('global_search_recent') ?? [];
    });
  }

  void _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('global_search_recent') ?? [];
    list.remove(query);
    list.insert(0, query);
    if (list.length > 8) list.removeLast();
    await prefs.setStringList('global_search_recent', list);
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() => _query = query);

    _debounce?.cancel();
    if (query.length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 400), () {
        _searchFirestore(query);
      });
    } else {
      setState(() {
        _firestoreResults = [];
        _isSearchingFirestore = false;
      });
    }
  }

  Future<void> _searchFirestore(String query) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isSearchingFirestore = true);

    try {
      final expQuery = await FirebaseFirestore.instance
          .collection(FirestoreCollections.expedientesCompletos)
          .where('uid', isEqualTo: uid)
          .where('numExpediente', isGreaterThanOrEqualTo: query.toUpperCase())
          .where('numExpediente',
              isLessThanOrEqualTo: '${query.toUpperCase()}\uf8ff')
          .limit(5)
          .get();

      final clienteQuery = await FirebaseFirestore.instance
          .collection(FirestoreCollections.clientesCrm)
          .where('uid', isEqualTo: uid)
          .where('nombre', isGreaterThanOrEqualTo: query)
          .where('nombre', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(5)
          .get();

      final poQuery = await FirebaseFirestore.instance
          .collection(FirestoreCollections.purchaseOrders)
          .where('uid', isEqualTo: uid)
          .where('poNumber', isGreaterThanOrEqualTo: query.toUpperCase())
          .where('poNumber',
              isLessThanOrEqualTo: '${query.toUpperCase()}\uf8ff')
          .limit(5)
          .get();

      final results = <SearchResult>[];

      for (final doc in expQuery.docs) {
        results.add(SearchResult(
          title: (doc['numExpediente'] ?? 'EXP-???').toString(),
          subtitle:
              '📁 Expediente · ${doc['clienteNombre'] ?? ''} · ${doc['estado'] ?? ''}',
          route: '/expedientes/${doc.id}',
          type: SearchResultType.expediente,
          icon: Icons.folder_outlined,
          color: AppColors.gold,
        ));
      }

      for (final doc in clienteQuery.docs) {
        results.add(SearchResult(
          title: (doc['nombre'] ?? 'Cliente').toString(),
          subtitle: '👤 Cliente · RFC: ${doc['rfc'] ?? ''}',
          route: '/clientes',
          type: SearchResultType.cliente,
          icon: Icons.person_outline,
          color: AppColors.blue,
        ));
      }

      for (final doc in poQuery.docs) {
        results.add(SearchResult(
          title: (doc['poNumber'] ?? 'PO-???').toString(),
          subtitle: '🛒 Orden de Compra · ${doc['supplierName'] ?? ''}',
          route: '/supply_chain/po',
          type: SearchResultType.po,
          icon: Icons.shopping_cart_outlined,
          color: AppColors.blue,
        ));
      }

      if (mounted) {
        setState(() {
          _firestoreResults = results;
          _isSearchingFirestore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearchingFirestore = false);
      }
    }
  }

  List<SearchResult> get _filteredStaticResults {
    if (_query.isEmpty) return [];
    return _staticResults
        .where((r) =>
            r.title.toLowerCase().contains(_query) ||
            r.subtitle.toLowerCase().contains(_query))
        .toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _navigate(SearchResult result) {
    _saveRecentSearch(_searchCtrl.text.trim());
    context.pop();
    context.push(result.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gold),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Buscar módulos, expedientes, clientes, POs...',
                hintStyle: const TextStyle(color: AppColors.sub, fontSize: 14),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: AppColors.sub),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.sub),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          const Text('ESC',
              style: TextStyle(color: AppColors.sub, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_query.isEmpty) ..._buildEmptyState(),
          if (_query.isNotEmpty) ..._buildSearchResults(),
        ],
      ),
    );
  }

  List<Widget> _buildEmptyState() {
    final actions =
        _staticResults.where((r) => r.type == SearchResultType.action).toList();
    final firstModules = _staticResults
        .where((r) => r.type == SearchResultType.route)
        .take(6)
        .toList();

    return [
      if (actions.isNotEmpty) ...[
        const Text('Acciones Rápidas',
            style: TextStyle(
                color: AppColors.sub,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: actions
                .map((a) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(a.title),
                        avatar: Icon(a.icon, size: 16, color: a.color),
                        backgroundColor: a.color.withValues(alpha: 0.1),
                        side: BorderSide(color: a.color.withValues(alpha: 0.3)),
                        onPressed: () => _navigate(a),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
      if (_recentSearches.isNotEmpty) ...[
        const Text('Búsquedas Recientes',
            style: TextStyle(
                color: AppColors.sub,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._recentSearches.map((s) => ListTile(
              leading: const Icon(Icons.history, color: AppColors.sub),
              title: Text(s, style: const TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: AppColors.sub, size: 16),
                onPressed: () {
                  setState(() => _recentSearches.remove(s));
                  SharedPreferences.getInstance().then((p) =>
                      p.setStringList('global_search_recent', _recentSearches));
                },
              ),
              onTap: () {
                _searchCtrl.text = s;
                _onSearchChanged();
              },
            )),
        const SizedBox(height: 24),
      ],
      const Text('Módulos disponibles',
          style: TextStyle(
              color: AppColors.sub, fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...firstModules.map((m) => _buildResultTile(m)),
    ];
  }

  List<Widget> _buildSearchResults() {
    return [
      if (_isSearchingFirestore)
        const Center(
            child: Padding(
          padding: EdgeInsets.all(16),
          child:
              CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
        )),
      if (_firestoreResults.isNotEmpty)
        ..._buildSection('Resultados de datos', _firestoreResults),
      if (_filteredStaticResults.isNotEmpty)
        ..._buildSection('Módulos y funciones', _filteredStaticResults),
      if (_filteredStaticResults.isEmpty &&
          _firestoreResults.isEmpty &&
          !_isSearchingFirestore)
        _buildNoResults(),
    ];
  }

  List<Widget> _buildSection(String title, List<SearchResult> results) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(title.toUpperCase(),
            style: const TextStyle(
                color: AppColors.sub,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ),
      ...results.map((r) => _buildResultTile(r)),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildResultTile(SearchResult result) {
    return InkWell(
      onTap: () => _navigate(result),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: result.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(result.icon, color: result.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(result.subtitle,
                      style:
                          const TextStyle(color: AppColors.sub, fontSize: 12)),
                ],
              ),
            ),
            if (result.type == SearchResultType.action)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: result.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4)),
                child: Text('Acción',
                    style: TextStyle(
                        color: result.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            if (result.type == SearchResultType.expediente)
              const Icon(Icons.folder, color: AppColors.gold, size: 16),
            if (result.type == SearchResultType.cliente)
              const Icon(Icons.person, color: AppColors.blue, size: 16),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.sub, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.search_off, color: AppColors.sub, size: 48),
          const SizedBox(height: 16),
          Text('Sin resultados para "$_query"',
              style: const TextStyle(color: AppColors.sub, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Prueba con: landed cost, expediente, MSCU, cliente...',
              style: TextStyle(color: AppColors.sub, fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
