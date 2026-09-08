import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Constantes de Diseño
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _gold = AppColors.gold;
const Color _text = AppColors.text;
const Color _sub = AppColors.sub;
const Color _border = AppColors.border;

/// Catálogo de Apps — Módulos disponibles en Aduanas 801
class ToolsHubScreen extends StatelessWidget {
  const ToolsHubScreen({super.key});

  static const _modules = [
    _AppModule(icon: Icons.view_kanban, label: 'Kanban Tráfico', route: '/kanban', color: AppColors.blue),
    _AppModule(icon: Icons.description, label: 'Previo Aduanal', route: '/previo', color: AppColors.green),
    _AppModule(icon: Icons.calculate, label: 'Pre-Glosa', route: '/pre_glosa', color: AppColors.gold),
    _AppModule(icon: Icons.monetization_on, label: 'Calculadora', route: '/calculator', color: AppColors.red),
    _AppModule(icon: Icons.category, label: 'Clasificador HS', route: '/classifier', color: AppColors.blue),
    _AppModule(icon: Icons.send, label: 'Despacho SAAI', route: '/saai', color: AppColors.green),
    _AppModule(icon: Icons.account_balance_wallet, label: 'Landed Cost', route: '/landed_cost', color: AppColors.gold),
    _AppModule(icon: Icons.account_balance, label: 'Dashboard Fin.', route: '/financial_dashboard', color: AppColors.green),
    _AppModule(icon: Icons.smart_toy, label: 'AI Copilot', route: '/ai_copilot', color: AppColors.blue),
    _AppModule(icon: Icons.radar, label: 'SAT Radar', route: '/sat_radar', color: AppColors.red),
    _AppModule(icon: Icons.factory, label: 'IMMEX', route: '/immex', color: AppColors.blue),
    _AppModule(icon: Icons.verified_user, label: 'T-MEC', route: '/tmec', color: AppColors.green),
    _AppModule(icon: Icons.security, label: 'Compliance', route: '/compliance', color: AppColors.gold),
    _AppModule(icon: Icons.hub, label: 'Blockchain Ledger', route: '/blockchain_ledger', color: AppColors.green),
    _AppModule(icon: Icons.local_shipping, label: 'Carta Porte', route: '/carta_porte', color: AppColors.blue),
    _AppModule(icon: Icons.visibility, label: 'Eagle Eye', route: '/eagle_eye', color: AppColors.gold),
    _AppModule(icon: Icons.bar_chart, label: 'ML Predictor', route: '/ml_audit_predictor', color: AppColors.blue),
    _AppModule(icon: Icons.search, label: 'AML Scanner', route: '/aml_scanner', color: AppColors.red),
    _AppModule(icon: Icons.person, label: 'Perfil', route: '/profile', color: AppColors.blue),
    _AppModule(icon: Icons.settings, label: 'Configuración', route: '/configuracion', color: AppColors.sub),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Catálogo de Apps', style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _gold),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Todos los módulos de Aduanas 801 Enterprise',
                style: TextStyle(color: _sub, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: _border, height: 1),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 160,
                mainAxisExtent: 130,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _modules.length,
              itemBuilder: (ctx, i) {
                final mod = _modules[i];
                return _AppCard(module: mod);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppModule {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _AppModule({required this.icon, required this.label, required this.route, required this.color});
}

class _AppCard extends StatefulWidget {
  final _AppModule module;
  const _AppCard({required this.module});

  @override
  State<_AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<_AppCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(widget.module.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hover ? widget.module.color : _border,
              width: _hover ? 1.5 : 1.0,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: widget.module.color.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.module.color.withValues(alpha: _hover ? 0.2 : 0.1),
                ),
                child: Icon(widget.module.icon, color: widget.module.color, size: 24),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.module.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _hover ? _text : _sub,
                    fontSize: 13,
                    fontWeight: _hover ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

