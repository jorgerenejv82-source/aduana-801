import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

const bg = AppColors.bg;
const card = AppColors.card;
const gold = AppColors.gold;
const text = AppColors.text;
const sub = AppColors.sub;
const border = AppColors.border;

class SidebarRoute {
  final String title;
  final String route;
  final IconData icon;
  final bool isNew;
  SidebarRoute(this.title, this.route, this.icon, {this.isNew = false});
}

class SidebarCategory {
  final String title;
  final IconData icon;
  final List<SidebarRoute> items;
  final List<String> visibleTo;
  SidebarCategory(this.title, this.icon, this.items, this.visibleTo);
}

class SmartSidebar extends StatefulWidget {
  final bool isCollapsed;
  final String? currentRoute;
  final VoidCallback onToggle;
  final String userRole;

  const SmartSidebar({
    super.key,
    required this.isCollapsed,
    this.currentRoute,
    required this.onToggle,
    required this.userRole,
  });

  @override
  State<SmartSidebar> createState() => _SmartSidebarState();
}

class _SmartSidebarState extends State<SmartSidebar> {
  String _selectedRole = 'importador';
  List<String> _recentRoutes = [];
  SharedPreferences? _prefs;

  String? _expandedCategoryTitle;

  late List<SidebarCategory> _allCategories;

  @override
  void initState() {
    super.initState();
    _initCategories();
    _updateExpandedCategory();
    _loadPrefs();
  }

  @override
  void didUpdateWidget(SmartSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRoute != oldWidget.currentRoute) {
      _updateExpandedCategory();
    }
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedRole = _prefs?.getString('user_role') ?? 'importador';
      _recentRoutes = _prefs?.getStringList('recent_routes') ?? [];
    });
    _updateExpandedCategory();
  }

  Future<void> _setRole(String role) async {
    setState(() {
      _selectedRole = role;
    });
    await _prefs?.setString('user_role', role);
    _updateExpandedCategory();
  }

  Future<void> _addRecentRoute(String route) async {
    if (route.isEmpty || route == '/') return;

    final recents = List<String>.from(_recentRoutes);
    recents.remove(route);
    recents.insert(0, route);
    if (recents.length > 5) {
      recents.removeLast();
    }

    setState(() {
      _recentRoutes = recents;
    });
    await _prefs?.setStringList('recent_routes', recents);
  }

  void _updateExpandedCategory() {
    if (widget.currentRoute == null) return;
    for (final cat in _allCategories) {
      if (cat.visibleTo.contains(_selectedRole)) {
        for (final item in cat.items) {
          if (item.route == widget.currentRoute) {
            setState(() {
              _expandedCategoryTitle = cat.title;
            });
            return;
          }
        }
      }
    }
  }

  void _initCategories() {
    _allCategories = [
      SidebarCategory('🏫 Aprender', Icons.school, [
        SidebarRoute(
            'Centro de Aprendizaje', '/learning_center', Icons.menu_book),
        SidebarRoute('Glosario ComEx', '/glosario', Icons.book),
        SidebarRoute('Preguntas Frecuentes', '/faq', Icons.question_answer),
        SidebarRoute(
            'Primer Despacho', '/mi_primer_despacho', Icons.flight_land),
        SidebarRoute('Incoterms', '/incoterms', Icons.handshake),
      ], [
        'novato',
        'importador',
        'agente'
      ]),
      SidebarCategory('📦 Operaciones', Icons.local_shipping, [
        SidebarRoute('Torre de Tráfico', '/shipment_tracker', Icons.radar),
        SidebarRoute(
            'Nuevo Embarque', '/shipment_tracker/nuevo', Icons.add_box),
        SidebarRoute('Órdenes de Compra', '/supply_chain/po', Icons.receipt),
        SidebarRoute('Expedientes', '/expedientes', Icons.folder),
        SidebarRoute('Despacho Hub', '/despacho_hub', Icons.hub),
        SidebarRoute('Kanban Operativo', '/kanban', Icons.view_kanban),
        SidebarRoute('Vencimientos', '/vencimientos', Icons.timer),
      ], [
        'importador',
        'agente'
      ]),
      SidebarCategory('💰 Finanzas', Icons.attach_money, [
        SidebarRoute(
            'Dashboard Importador', '/importer_dashboard', Icons.dashboard,
            isNew: true),
        SidebarRoute(
            '¿Cuánto cuesta importar?', '/simple_estimator', Icons.calculate),
        SidebarRoute('Landed Cost Avanzado', '/landed_cost', Icons.functions),
        SidebarRoute(
            'Cotizador Servicios', '/cotizador_servicios', Icons.request_quote),
        SidebarRoute('Cartas de Crédito', '/financial/lc', Icons.credit_card),
        SidebarRoute('Duty Drawback', '/duty_drawback', Icons.money_off),
        SidebarRoute('ROI Calculator', '/roi_calculator', Icons.trending_up),
        SidebarRoute(
            'Flujo de Caja', '/cashflow', Icons.account_balance_wallet),
      ], [
        'importador',
        'agente'
      ]),
      SidebarCategory('⚖️ Cumplimiento', Icons.gavel, [
        SidebarRoute('CRM Clientes', '/clientes', Icons.people),
        SidebarRoute('Evaluar Proveedor', '/supplier_scorecard', Icons.score),
        SidebarRoute('Normas de Producto (NOMs)', '/regulatory/noms_advisor',
            Icons.assignment_turned_in),
        SidebarRoute('Calendario NOMs', '/nom_calendar', Icons.calendar_today),
        SidebarRoute(
            'Permisos Previos', '/permisos_previos', Icons.verified_user),
        SidebarRoute('Carta de Cupo', '/carta_de_cupo', Icons.description),
        SidebarRoute(
            'Verifica un RFC', '/rfc_verificador', Icons.domain_verification),
        SidebarRoute('Blacklist SAT', '/lista_negra_sat', Icons.warning),
        SidebarRoute('Análisis TMEC', '/tmec', Icons.public),
        SidebarRoute('Cuotas Compensatorias', '/cuotas_compensatorias',
            Icons.price_change),
      ], [
        'importador',
        'agente'
      ]),
      SidebarCategory('🔬 IA & Análisis', Icons.science, [
        SidebarRoute('Clasificador IA', '/clasificador_ia', Icons.smart_toy),
        SidebarRoute(
            'Simulador Pedimento', '/simulador_pedimento', Icons.science),
        SidebarRoute('Pre-Glosa', '/pre_glosa', Icons.find_in_page),
        SidebarRoute('M3 Forense', '/m3_forensics', Icons.policy),
        SidebarRoute(
            'Conciliador', '/audit/invoice_match', Icons.compare_arrows),
        SidebarRoute('Swarm AI', '/swarm_ai', Icons.group_work),
        SidebarRoute('ESG Calculator', '/esg', Icons.eco),
      ], [
        'agente'
      ]),
      SidebarCategory('🔴 📋 Regulaciones Avanzadas', Icons.account_balance, [
        SidebarRoute(
            'Anexo 22 (Apéndice 8)', '/apendice8_matrix', Icons.grid_on),
        SidebarRoute('Anexo 24 (IMMEX)', '/immex', Icons.inventory),
        SidebarRoute('Anexo 30', '/anexo30', Icons.description),
        SidebarRoute(
            'Pre-Validador M3', '/pre_validador_m3', Icons.check_circle),
        SidebarRoute('Historial M3', '/historial_m3', Icons.history),
      ], [
        'novato',
        'importador',
        'exportador',
        'agente'
      ]),
      SidebarCategory('📤 Exportación', Icons.upload, [
        SidebarRoute('Cert. de Origen TMEC', '/tmec', Icons.verified),
        SidebarRoute('Pedimento Exportación', '/simulador_pedimento',
            Icons.receipt_long),
        SidebarRoute('Duty Drawback', '/duty_drawback', Icons.savings),
        SidebarRoute('IMMEX', '/immex', Icons.factory),
        SidebarRoute('OEA / CTPAT', '/oea_seciit', Icons.security),
        SidebarRoute('Reglas de Origen', '/auditor_tmec_bom', Icons.rule),
        SidebarRoute('Incoterms 2020', '/incoterms', Icons.handshake),
        SidebarRoute('Permisos Exportación', '/permisos_previos', Icons.gavel),
        SidebarRoute('Resumen Anual', '/annual_summary', Icons.calendar_month),
      ], [
        'exportador'
      ]),
      SidebarCategory('⚙️ Sistema', Icons.settings, [
        SidebarRoute('Mi Suscripción', '/subscription', Icons.credit_card),
        SidebarRoute('Catálogo de Apps', '/tools_hub', Icons.apps),
        SidebarRoute('Perfil', '/profile', Icons.person),
        SidebarRoute('VUCEM (Ventanilla SAT)', '/vucem_sync', Icons.sync),
        SidebarRoute('Mi e.Firma / FIEL', '/boveda_fiel', Icons.security),
        SidebarRoute('Configuración', '/configuracion', Icons.settings),
      ], [
        'novato',
        'importador',
        'exportador',
        'agente'
      ]),
    ];
  }

  Map<String, String> get _routeTitleMap {
    final map = <String, String>{};
    for (final cat in _allCategories) {
      for (final item in cat.items) {
        map[item.route] = item.title;
      }
    }
    return map;
  }

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = widget.isCollapsed ? 72.0 : 260.0;

    final visibleCategories = _allCategories
        .where((cat) => cat.visibleTo.contains(_selectedRole))
        .toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width,
      color: bg,
      child: Column(
        children: [
          _buildHeader(),
          if (!widget.isCollapsed) ...[
            _buildImmexAlert(),
            _buildRoleSwitcher(),
            _buildRecents(),
          ],
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(sub.withAlpha(128)),
                  thickness: WidgetStateProperty.all(4.0),
                ),
              ),
              child: Scrollbar(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: visibleCategories.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: gold, height: 1, thickness: 0.5),
                  itemBuilder: (context, index) =>
                      _buildCategory(visibleCategories[index]),
                ),
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: widget.isCollapsed ? 0 : 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        mainAxisAlignment: widget.isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          if (!widget.isCollapsed) ...[
            const Icon(Icons.shield, color: gold, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'ADUANAS 801',
                style: TextStyle(
                    color: text, fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          IconButton(
            icon: Icon(widget.isCollapsed ? Icons.menu : Icons.menu_open,
                color: sub),
            onPressed: widget.onToggle,
            tooltip: widget.isCollapsed ? 'Expandir' : 'Colapsar',
          )
        ],
      ),
    );
  }

  Widget _buildImmexAlert() {
    return StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('clientes_crm').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          int expiringCount = 0;
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data.containsKey('immexVigencia')) {
              final dynamic vigencia = data['immexVigencia'];
              if (vigencia is Timestamp) {
                final daysLeft =
                    vigencia.toDate().difference(DateTime.now()).inDays;
                if (daysLeft < 60) expiringCount++;
              } else if (vigencia is int) {
                if (vigencia < 60) expiringCount++;
              }
            }
          }

          if (expiringCount == 0) return const SizedBox();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                _addRecentRoute('/clientes');
                context.go('/clientes');
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.15),
                  border: Border.all(color: gold),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: gold, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ $expiringCount clientes con IMMEX por vencer →',
                        style: const TextStyle(
                            color: gold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildRoleSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: ToggleButtons(
        isSelected: [
          _selectedRole == 'novato',
          _selectedRole == 'importador',
          _selectedRole == 'exportador',
          _selectedRole == 'agente',
        ],
        onPressed: (int index) {
          if (index == 0) {
            _setRole('novato');
          } else if (index == 1) {
            _setRole('importador');
          } else if (index == 2) {
            _setRole('exportador');
          } else {
            _setRole('agente');
          }
        },
        color: sub,
        selectedColor: gold,
        fillColor: card,
        borderColor: border,
        selectedBorderColor: gold,
        borderRadius: BorderRadius.circular(8),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        constraints: const BoxConstraints(minHeight: 32, minWidth: 60),
        children: const [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('🌱 Empezando')),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('📦 Import.')),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('🌎 Export.')),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('⚖️ Pro')),
        ],
      ),
    );
  }

  Widget _buildRecents() {
    if (_recentRoutes.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recientes:', style: TextStyle(color: sub, fontSize: 11)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _recentRoutes.map((route) {
              final title = _routeTitleMap[route] ?? route;
              return ActionChip(
                label: Text(title,
                    style: const TextStyle(fontSize: 10, color: text)),
                backgroundColor: card,
                side: const BorderSide(color: border),
                padding: EdgeInsets.zero,
                onPressed: () {
                  _addRecentRoute(route);
                  if (Navigator.canPop(context)) Navigator.pop(context);
                  context.go(route);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(SidebarCategory category) {
    if (widget.isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Tooltip(
          message: category.title,
          preferBelow: false,
          child: InkWell(
            onTap: () {
              widget.onToggle();
              setState(() {
                _expandedCategoryTitle = category.title;
              });
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, color: sub, size: 20),
            ),
          ),
        ),
      );
    }

    final isExpanded = _expandedCategoryTitle == category.title;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: ValueKey('${category.title}_$_selectedRole'),
        initiallyExpanded: isExpanded,
        backgroundColor: bg,
        collapsedBackgroundColor: card,
        leading: Icon(category.icon, color: gold, size: 20),
        title: Text(
          category.title,
          style: const TextStyle(
              color: gold, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        iconColor: gold,
        collapsedIconColor: gold,
        children: category.items.map((item) => _buildRouteItem(item)).toList(),
      ),
    );
  }

  Widget _buildRouteItem(SidebarRoute item) {
    final bool isActive = widget.currentRoute == item.route;

    if (widget.isCollapsed) {
      return const SizedBox();
    }

    return _RouteItemWidget(
      item: item,
      isActive: isActive,
      onTap: () {
        _addRecentRoute(item.route);
        // Close drawer on mobile before navigating
        if (Navigator.canPop(context)) Navigator.pop(context);
        context.go(item.route);
      },
    );
  }

  Widget _buildFooter() {
    if (widget.isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: card,
              child: Icon(Icons.person, color: sub, size: 18),
            ),
            const SizedBox(height: 16),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: _handleLogout,
              tooltip: 'Cerrar Sesión',
            )
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: border)),
      ),
      child: InkWell(
        onTap: () => context.go('/profile'),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: card,
              child: Icon(Icons.person, color: sub, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usuario Activo',
                    style: TextStyle(
                        color: text, fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _selectedRole.toUpperCase(),
                    style: const TextStyle(color: sub, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
              onPressed: _handleLogout,
              tooltip: 'Cerrar Sesión',
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteItemWidget extends StatefulWidget {
  final SidebarRoute item;
  final bool isActive;
  final VoidCallback onTap;

  const _RouteItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_RouteItemWidget> createState() => _RouteItemWidgetState();
}

class _RouteItemWidgetState extends State<_RouteItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.only(left: 12, right: 16),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF1E293B) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: widget.isActive ? gold : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 36),
              Icon(widget.item.icon,
                  size: 18, color: widget.isActive ? gold : Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.title,
                  style: TextStyle(
                    color: widget.isActive ? gold : Colors.white,
                    fontSize: 13,
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (widget.item.isNew)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NUEVO',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
