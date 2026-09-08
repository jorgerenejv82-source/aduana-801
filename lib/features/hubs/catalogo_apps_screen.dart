import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─── Design Tokens ───────────────────────────────────────────────
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _teal = Color(0xFF4ECCA3);
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;

// ─── App Card Model ────────────────────────────────────────────────
class _App {
  final String name;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final String? route;
  final bool isNew;
  const _App({
    required this.name,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.route,
    this.isNew = false,
  });
}

class _Section {
  final String title;
  final IconData sectionIcon;
  final List<_App> apps;
  const _Section({
    required this.title,
    required this.sectionIcon,
    required this.apps,
  });
}

// ─── App Data ─────────────────────────────────────────────────────
final _accesosRapidos = [
  const _App(
      name: 'Kanban\nTrafico',
      subtitle: 'Gestiona pedimentos...',
      icon: Icons.view_kanban,
      iconColor: _azul,
      route: '/kanban'),
  const _App(
      name: 'Lab\nMerceologico',
      subtitle: 'Defensa Merceolog...',
      icon: Icons.biotech,
      iconColor: _ambar,
      route: '/merceologia'),
  const _App(
      name: 'Agenda de\nVencimientos',
      subtitle: 'Fechas criticas y pl...',
      icon: Icons.event,
      iconColor: _teal,
      route: '/vencimientos'),
  const _App(
      name: 'Tipo de\nCambio',
      subtitle: 'TC DOF y Banxico c...',
      icon: Icons.currency_exchange,
      iconColor: _verde,
      route: '/calculator'),
  const _App(
      name: 'Centro de\nAlertas',
      subtitle: 'Alertas y notificacio...',
      icon: Icons.notifications_active,
      iconColor: _rojo,
      route: '/alerts'),
  const _App(
      name: 'Cotizador\nServicios',
      subtitle: 'Genera cotizaciones...',
      icon: Icons.diamond_outlined,
      iconColor: _azul,
      route: '/cotizador_servicios'),
  const _App(
      name: 'Landed Cost',
      subtitle: 'Costo total importa...',
      icon: Icons.calculate,
      iconColor: _azul,
      route: '/landed_cost'),
  const _App(
      name: 'Emergencias\nAduaneras',
      subtitle: 'Asistente de crisis',
      icon: Icons.emergency,
      iconColor: _rojo,
      route: '/warroom_simulator'),
];

final _sections = [
  const _Section(
    title: 'Compliance & Auditoria',
    sectionIcon: Icons.shield_outlined,
    apps: [
      _App(
          name: 'Auditor DataStage\nvs ERP',
          icon: Icons.compare_arrows,
          iconColor: _ambar,
          route: '/conciliador_visor_b'),
      _App(
          name: 'Predictor Multas',
          icon: Icons.gavel,
          iconColor: _rojo,
          route: '/ml_audit_predictor'),
      _App(
          name: 'C-TPAT / OEA',
          icon: Icons.verified_user,
          iconColor: _sec,
          route: '/ctpat_hub'),
      _App(
          name: 'Tratados (T-MEC)',
          icon: Icons.handshake,
          iconColor: _teal,
          route: '/tmec'),
      _App(
          name: 'Virtual Ops (V1)',
          icon: Icons.grid_view,
          iconColor: _sec,
          route: '/virtual_ops'),
    ],
  ),
  const _Section(
    title: 'Operacion Agencia Aduanal & Defensa Patente',
    sectionIcon: Icons.account_balance,
    apps: [
      _App(
          name: 'Escritos Legales\n(RI)',
          icon: Icons.description,
          iconColor: _ambar,
          route: '/escritos_legales'),
      _App(
          name: 'Motor de\nProformas',
          icon: Icons.receipt_long,
          iconColor: _verde,
          route: '/motor_proformas'),
      _App(
          name: 'War Room\nSemaforo',
          icon: Icons.warning_amber,
          iconColor: _rojo,
          route: '/warroom_simulator',
          isNew: true),
      _App(
          name: 'Radar\nEFOS/EDOS',
          icon: Icons.radar,
          iconColor: _sec,
          route: '/sat_radar',
          isNew: true),
      _App(
          name: 'Kanban Trafico',
          icon: Icons.view_kanban,
          iconColor: _teal,
          route: '/kanban'),
      _App(
          name: 'Trafico y\nDespacho',
          icon: Icons.local_shipping,
          iconColor: _teal,
          route: '/trafico_despacho'),
      _App(
          name: 'Reloj de Demoras\n(Demurrage)',
          icon: Icons.timer,
          iconColor: _ambar,
          route: '/demurrage'),
      _App(
          name: 'Cross-Match\nGlosa',
          icon: Icons.checklist,
          iconColor: _teal,
          route: '/cross_match_glosa'),
      _App(
          name: 'Generador\nDODA / PITA',
          icon: Icons.qr_code_2,
          iconColor: _ambar,
          route: '/generador_doda_pita'),
      _App(
          name: 'Catalogo\nLIGIE / NICO',
          icon: Icons.search,
          iconColor: _sec,
          route: '/consultor_tigie'),
      _App(
          name: 'Monitor Encargos\nConferidos',
          icon: Icons.shield,
          iconColor: _ambar,
          route: '/monitor_encargos'),
      _App(
          name: 'Extractor COVE\n(OCR)',
          icon: Icons.document_scanner,
          iconColor: _rojo,
          route: '/scanner'),
      _App(
          name: 'Glosa\nColaborativa',
          icon: Icons.group_work,
          iconColor: _azul,
          route: '/glosa_colab',
          isNew: true),
      _App(
          name: 'Turnos de\nGarita',
          icon: Icons.local_shipping,
          iconColor: _verde,
          route: '/coming_soon',
          isNew: true),
      _App(
          name: 'Boveda VUCEM\n(e.firma)',
          icon: Icons.lock,
          iconColor: _sec,
          route: '/boveda_vucem',
          isNew: true),
    ],
  ),
  const _Section(
    title: 'Suite Directiva (C-Level & Global Trade)',
    sectionIcon: Icons.business_center,
    apps: [
      _App(
          name: 'Port AI\n& Rutas',
          icon: Icons.anchor,
          iconColor: _teal,
          route: '/border_sync'),
      _App(
          name: 'Auditor T-MEC\n(BOM)',
          icon: Icons.verified_user,
          iconColor: _sec,
          route: '/auditor_tmec_bom'),
      _App(
          name: 'Trade War\nSimulator',
          icon: Icons.gps_fixed,
          iconColor: _rojo,
          route: '/warroom_simulator'),
      _App(
          name: 'Control\nPresupuesto (Spend)',
          icon: Icons.bar_chart,
          iconColor: _ambar,
          route: '/financial_dashboard'),
    ],
  ),
  const _Section(
    title: 'Operaciones Logisticas de Alto Impacto',
    sectionIcon: Icons.local_shipping,
    apps: [
      _App(
          name: 'D&D Tracker',
          icon: Icons.av_timer,
          iconColor: _rojo,
          route: '/demurrage'),
      _App(
          name: 'Cotizador\nDoor-to-Door',
          icon: Icons.grid_on,
          iconColor: _ambar,
          route: '/cotizador_d2d'),
      _App(
          name: 'SLI / VGM\nGenerator',
          icon: Icons.diamond,
          iconColor: _sec,
          route: '/sli_vgm'),
      _App(
          name: 'Vendor\nCompliance',
          icon: Icons.fact_check,
          iconColor: _ambar,
          route: '/compliance'),
      _App(
          name: 'Calculadora\nSeguros',
          icon: Icons.health_and_safety,
          iconColor: _verde,
          route: '/calculadora_seguros'),
    ],
  ),
  const _Section(
    title: 'Logistica & Cadena de Suministro',
    sectionIcon: Icons.alt_route,
    apps: [
      _App(
          name: 'Torre de\nControl Global',
          icon: Icons.inventory_2,
          iconColor: _ambar,
          route: '/border_sync'),
      _App(
          name: 'Traffic Tower',
          icon: Icons.cell_tower,
          iconColor: _teal,
          route: '/traffic_tower'),
      _App(
          name: 'Rutas Globales',
          icon: Icons.public,
          iconColor: _sec,
          route: '/rutas_globales'),
      _App(
          name: 'Tracking\n(Blockchain)',
          icon: Icons.link,
          iconColor: _teal,
          route: '/blockchain_ledger'),
      _App(
          name: 'Incoterms (IA)',
          icon: Icons.layers,
          iconColor: _ambar,
          route: '/incoterms'),
      _App(
          name: 'ESG\nCalculator',
          icon: Icons.eco,
          iconColor: _verde,
          route: '/esg'),
    ],
  ),
  const _Section(
    title: 'Inteligencia & Estrategia',
    sectionIcon: Icons.psychology,
    apps: [
      _App(
          name: 'Defensa Legal\nLIGIE',
          icon: Icons.balance,
          iconColor: _azul,
          route: '/coming_soon'),
      _App(
          name: 'Simulador\n0 a 100',
          icon: Icons.rocket_launch,
          iconColor: _sec,
          route: '/warroom_simulator'),
      _App(
          name: 'API Gateway\nB2B',
          icon: Icons.hub,
          iconColor: _ambar,
          route: '/api_gateway'),
      _App(
          name: 'Traductor\nCorporativo',
          icon: Icons.translate,
          iconColor: _ambar,
          route: '/traductor_corp'),
      _App(
          name: 'Busqueda\nProveedores',
          icon: Icons.manage_search,
          iconColor: _verde,
          route: '/global_sourcing'),
      _App(
          name: 'Asesoria\nExpress',
          icon: Icons.support_agent,
          iconColor: _rojo,
          route: '/copiloto'),
      _App(
          name: 'Rescate\nEnterprise',
          icon: Icons.emergency,
          iconColor: _rojo,
          route: '/rescate'),
      _App(
          name: 'Data Integration\n(ETL)',
          icon: Icons.upload_file,
          iconColor: _ambar,
          route: '/data_integration'),
    ],
  ),
  const _Section(
    title: 'Cerebro Autonomo (Inteligencia Artificial)',
    sectionIcon: Icons.auto_awesome,
    apps: [
      _App(
          name: 'Vision AI (OCR)',
          icon: Icons.document_scanner,
          iconColor: _teal,
          route: '/ar_visor'),
      _App(
          name: 'RAG Legal Bot',
          icon: Icons.balance,
          iconColor: _ambar,
          route: '/copiloto'),
      _App(
          name: 'Predictive\nAnalytics',
          icon: Icons.trending_up,
          iconColor: _teal,
          route: '/ml_audit_predictor'),
      _App(
          name: 'Swarm AI\n(Enjambre)',
          icon: Icons.hub,
          iconColor: _sec,
          route: '/swarm_ai'),
    ],
  ),
  const _Section(
    title: 'Marco Legal & Herramientas Clave',
    sectionIcon: Icons.gavel,
    apps: [
      _App(
          name: 'Calculadora\nUMA & Multas',
          icon: Icons.attach_money,
          iconColor: _rojo,
          route: '/calculator'),
      _App(
          name: 'Cuotas\nCompensatorias',
          icon: Icons.balance,
          iconColor: _ambar,
          route: '/cuotas_compensatorias'),
      _App(
          name: 'Comando Fiscal\ny Log. Nacional',
          icon: Icons.local_shipping,
          iconColor: _teal,
          route: '/comando_fiscal'),
      _App(
          name: 'Agenda de\nVencimientos',
          icon: Icons.calendar_today,
          iconColor: _sec,
          route: '/agenda_venc'),
      _App(
          name: 'Tipo de Cambio\n(TC DOF)',
          icon: Icons.currency_exchange,
          iconColor: _azul,
          route: '/calculator'),
    ],
  ),
  const _Section(
    title: 'Fiscal y Gubernamental',
    sectionIcon: Icons.account_balance,
    apps: [
      _App(
          name: 'Validador\nSAAI M3',
          icon: Icons.monitor,
          iconColor: _teal,
          route: '/agace'),
    ],
  ),
  const _Section(
    title: 'Operacion Avanzada & Reportes',
    sectionIcon: Icons.rocket,
    apps: [
      _App(
          name: 'Centro de\nAlertas',
          icon: Icons.notifications_active,
          iconColor: _rojo,
          route: '/agace',
          isNew: true),
      _App(
          name: 'Cotizador de\nServicios AA',
          icon: Icons.receipt,
          iconColor: _ambar,
          route: '/cotizador_servicios',
          isNew: true),
      _App(
          name: 'Reporte\nMensual BI',
          icon: Icons.bar_chart,
          iconColor: _verde,
          route: '/financial_dashboard',
          isNew: true),
      _App(
          name: 'Chat Cliente /\nProveedor',
          icon: Icons.chat_bubble_outline,
          iconColor: _teal,
          route: '/copiloto',
          isNew: true),
    ],
  ),
];

// ─── Main Screen ──────────────────────────────────────────────────
class CatalogoAppsScreen extends StatefulWidget {
  const CatalogoAppsScreen({super.key});
  @override
  State<CatalogoAppsScreen> createState() => _CatalogoAppsScreenState();
}

class _CatalogoAppsScreenState extends State<CatalogoAppsScreen> {
  String _query = '';

  List<_App> _filtered(List<_App> apps) {
    if (_query.isEmpty) return apps;
    return apps
        .where((a) => a.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  void _openApp(BuildContext ctx, _App app) {
    if (app.route != null) {
      ctx.push(app.route!);
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text('${app.name.replaceAll('\n', ' ')} — Próximamente'),
        backgroundColor: _card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: _ambar),
        ),
        title: const Text('Catálogo de Apps',
            style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _bord)),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(color: _texto, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Buscar app...',
                  hintStyle: TextStyle(color: _sec, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: _sec, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/copiloto'),
        backgroundColor: _ambar,
        icon: const Icon(Icons.support_agent, color: Colors.black, size: 20),
        label: const Text('Ayuda',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Accesos Rapidos ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _ambar.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                      color: _ambar.withValues(alpha: 0.05), blurRadius: 10)
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.star, color: _ambar, size: 20),
                  SizedBox(width: 8),
                  Text('Accesos Rápidos',
                      style: TextStyle(
                          color: _ambar,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('Los más usados',
                      style: TextStyle(color: _sec, fontSize: 12)),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _filtered(_accesosRapidos)
                        .map((app) => _HoverAppCard(
                              app: app,
                              compact: true,
                              onTap: () => _openApp(context, app),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Sections ─────────────────────────────────────────
          ..._sections.map((sec) {
            final filtered = _filtered(sec.apps);
            if (filtered.isEmpty) return const SizedBox.shrink();
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 4),
                    child: Row(children: [
                      Icon(sec.sectionIcon, color: _ambar, size: 18),
                      const SizedBox(width: 8),
                      Text(sec.title,
                          style: const TextStyle(
                              color: _texto,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  // Apps wrap
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: filtered
                        .map((app) => _HoverAppCard(
                              app: app,
                              onTap: () => _openApp(context, app),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                ]);
          }),
        ]),
      ),
    );
  }
}

class _HoverAppCard extends StatefulWidget {
  final _App app;
  final bool compact;
  final VoidCallback onTap;

  const _HoverAppCard(
      {required this.app, this.compact = false, required this.onTap});

  @override
  State<_HoverAppCard> createState() => _HoverAppCardState();
}

class _HoverAppCardState extends State<_HoverAppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double w = widget.compact ? 90 : 100;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: w,
          margin: widget.compact ? const EdgeInsets.only(right: 12) : null,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _isHovered
                    ? widget.app.iconColor.withValues(alpha: 0.5)
                    : _bord),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                    color: widget.app.iconColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1)
            ],
          ),
          child: Stack(alignment: Alignment.topRight, children: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.app.iconColor
                      .withValues(alpha: _isHovered ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: widget.app.iconColor.withValues(alpha: 0.3)),
                ),
                child: Icon(widget.app.icon,
                    color: widget.app.iconColor, size: 24),
              ),
              const SizedBox(height: 12),
              // App name
              Text(
                widget.app.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: _texto,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.2),
              ),
              if (widget.app.subtitle != null && !widget.compact) ...[
                const SizedBox(height: 4),
                Text(
                  widget.app.subtitle!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _sec, fontSize: 9),
                ),
              ],
            ]),
            // NUEVO badge
            if (widget.app.isNew)
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                        color: _verde, borderRadius: BorderRadius.circular(4)),
                    child: const Text('NUEVO',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold)),
                  )),
          ]),
        ),
      ),
    );
  }
}
