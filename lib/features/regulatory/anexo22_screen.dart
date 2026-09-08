import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Anexo22Screen extends StatelessWidget {
  const Anexo22Screen({super.key});

  static const _seccion1 = [
    _A22Module(title: 'Pre-Validador M3 (Zero-Ping-Pong)', desc: 'Escanea el borrador del pedimento contra 1,500 reglas locales antes de enviarlo a la agencia aduanal.', icon: Icons.rule_folder, color: AppColors.green, route: '/pre_validador_m3'),
    _A22Module(title: 'Apéndice 8 AI Matrix', desc: 'Matriz de nodos para cruzar identificadores. Previene combinaciones ilegales (Ej. usar TL sin TMEC).', icon: Icons.hub, color: AppColors.blue, route: '/apendice8_matrix'),
    _A22Module(title: 'M3 Forensics Decryptor', desc: 'Pega la cadena M3 en bruto y la inteligencia forense reconstruirá visualmente el pedimento, marcando bytes corruptos.', icon: Icons.bug_report, color: AppColors.red, route: '/m3_forensics'),
    _A22Module(title: 'Draft-Pedimento Auto-Gen', desc: 'Arrastra tu Factura Comercial y el motor ensamblará el borrador M3 perfecto usando inferencia RGCE.', icon: Icons.auto_fix_high, color: AppColors.gold, route: '/draft_pedimento'),
  ];

  static const _seccion2 = [
    _A22Module(title: 'Clasificador IA', desc: 'Clasifica productos en la TIGIE con IA Gemini. Obtén 3 fracciones candidatas con justificación arancelaria.', icon: Icons.auto_awesome, color: AppColors.gold, route: '/clasificador_ia'),
    _A22Module(title: 'Simulador de Pedimento', desc: 'Simula el llenado de un pedimento paso a paso: contribuciones, semáforo de riesgo e identificadores A8.', icon: Icons.assignment, color: AppColors.blue, route: '/simulador_pedimento'),
    _A22Module(title: 'Comparador de Incoterms', desc: 'Compara el impacto fiscal de todos los Incoterms: IGI, DTA, IVA y total en MXN.', icon: Icons.compare_arrows, color: AppColors.green, route: '/comparador_incoterms'),
    _A22Module(title: 'Historial M3', desc: 'Revisa todas las transmisiones M3 al SAAI con su status, texto raw y compliance badge.', icon: Icons.history, color: AppColors.blue, route: '/historial_m3'),
    _A22Module(title: 'Consultor TIGIE', desc: 'Busca fracciones arancelarias de la TIGIE 2024. Validación IA + link al SNICE oficial.', icon: Icons.menu_book, color: AppColors.green, route: '/consultor_tigie'),
    _A22Module(title: 'OEA / SECIIT Expedito', desc: 'Módulo de operaciones expeditas: certificación, checklist 60 criterios, DTA al 0.4%.', icon: Icons.verified, color: AppColors.gold, route: '/oea_seciit'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.gold),
              onPressed: () => context.go('/home'),
            ),
            title: const Text(
              'Anexo 22 Titan-Tier: El Arquitecto',
              style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _LegacyCard(),
            ),
          ),
          const SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Instructivo Llenado Pedimento (Anexo 22)',
              subtitle: 'Motores de inferencia y validación sintáctica M3 para la erradicación del error humano.',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _ModuleCard(module: _seccion1[i]),
                childCount: _seccion1.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Herramientas IA & Análisis',
              subtitle: 'Clasificación arancelaria, simulación y análisis de transmisiones.',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _ModuleCard(module: _seccion2[i]),
                childCount: _seccion2.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: _ColaTransmisionCard(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegacyCard extends StatefulWidget {
  @override
  State<_LegacyCard> createState() => _LegacyCardState();
}

class _LegacyCardState extends State<_LegacyCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go('/motor_a22'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFF14243D) : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hover ? AppColors.gold : AppColors.border),
            boxShadow: [
              if (_hover) BoxShadow(color: AppColors.gold.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.cloud, color: AppColors.gold, size: 28),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Anexo 22 Engine (Legacy)', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Motor completo de inferencia y validación sintáctica del Anexo 22 con simulación de pedimentos.', style: TextStyle(color: AppColors.sub, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: _hover ? AppColors.gold : AppColors.sub, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColaTransmisionCard extends StatefulWidget {
  @override
  State<_ColaTransmisionCard> createState() => _ColaTransmisionCardState();
}

class _ColaTransmisionCardState extends State<_ColaTransmisionCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go('/saai'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFF14243D) : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hover ? AppColors.blue : AppColors.border),
            boxShadow: [
              if (_hover) BoxShadow(color: AppColors.blue.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: AppColors.blue.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.cloud_upload, color: AppColors.blue, size: 28),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cola de Transmisión SAAI', style: TextStyle(color: AppColors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Gestiona los pedimentos listos para VUCEM. Descarga M3 + instrucciones paso a paso.', style: TextStyle(color: AppColors.sub, fontSize: 13), maxLines: 2),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: _hover ? AppColors.blue : AppColors.sub, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 24, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(subtitle, style: const TextStyle(color: AppColors.sub, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _A22Module {
  final String title, desc, route;
  final IconData icon;
  final Color color;
  const _A22Module({required this.title, required this.desc, required this.icon, required this.color, required this.route});
}

class _ModuleCard extends StatefulWidget {
  final _A22Module module;
  const _ModuleCard({required this.module});
  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(m.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFF14243D) : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hover ? m.color : AppColors.border, width: _hover ? 2 : 1),
            boxShadow: _hover ? [BoxShadow(color: m.color.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4))] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: m.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: m.color.withValues(alpha: 0.2)),
                    ),
                    child: Icon(m.icon, color: m.color, size: 24),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: _hover ? m.color : AppColors.sub.withValues(alpha: 0.5), size: 20),
                ],
              ),
              const Spacer(),
              Text(m.title, style: TextStyle(color: _hover ? m.color : AppColors.text, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(m.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.sub, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}

