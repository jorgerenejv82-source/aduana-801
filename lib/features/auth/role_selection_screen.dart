import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});
  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const bg1 = AppColors.bg;
  static const gold = AppColors.gold;
  static const text = AppColors.text;
  static const sub = AppColors.sub;

  @override
  void initState() {
    super.initState();
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 14))
          ..repeat();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _showOnboardingModal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => const _OnboardingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 860;

    return Scaffold(
      backgroundColor: bg1,
      body: Stack(children: [
        AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
                painter: _RoleBgPainter(_bgCtrl.value),
                child: const SizedBox.expand())),
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(children: [
                  // --- Header ---
                  _buildHeader(),
                  const SizedBox(height: 48),

                  // --- Role Cards ---
                  isWide
                      ? IntrinsicHeight(
                          child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Expanded(
                                child: _RoleCard(
                              icon: Icons.gavel_rounded,
                              color: gold,
                              title: 'Agente Aduanal',
                              description:
                                  'Despacho completo, pedimentos, cumplimiento y más.',
                              features: [
                                'Pedimentos A1, A4, IMD',
                                'Validador XML & M3',
                                'Módulos EFOS y EDOS'
                              ],
                              route: '/home',
                              badge: 'COMPLETO',
                            )),
                            const SizedBox(width: 20),
                            Expanded(
                                child: _RoleCard(
                              icon: Icons.local_shipping_rounded,
                              color: AppColors.blue,
                              title: 'Importador / Exportador',
                              description:
                                  'Operaciones, costos, aranceles y logística global.',
                              features: const [
                                'Calculadora Landed Cost',
                                'Incoterms 2020',
                                'Rastreo de operaciones'
                              ],
                              onTap: () => _showOnboardingModal(context),
                              badge: 'RECOMENDADO',
                            )),
                            const SizedBox(width: 20),
                            const Expanded(
                                child: _RoleCard(
                              icon: Icons.factory_outlined,
                              color: AppColors.green,
                              title: 'Empresa IMMEX',
                              description:
                                  'Control Anexo 24, FIFO, saldos y vencimientos.',
                              features: [
                                'Motor FIFO Automático',
                                'Descargos en la nube',
                                'Alertas de vencimiento'
                              ],
                              route: '/immex',
                            )),
                          ],
                        ))
                      : Column(children: [
                          const _RoleCard(
                            icon: Icons.gavel_rounded,
                            color: gold,
                            title: 'Agente Aduanal',
                            description:
                                'Despacho completo, pedimentos, cumplimiento y más.',
                            features: [
                              'Pedimentos A1, A4, IMD',
                              'Validador XML & M3',
                              'Módulos EFOS y EDOS'
                            ],
                            route: '/home',
                            badge: 'COMPLETO',
                          ),
                          const SizedBox(height: 16),
                          _RoleCard(
                            icon: Icons.local_shipping_rounded,
                            color: AppColors.blue,
                            title: 'Importador / Exportador',
                            description:
                                'Operaciones, costos, aranceles y logística global.',
                            features: const [
                              'Calculadora Landed Cost',
                              'Incoterms 2020',
                              'Rastreo de operaciones'
                            ],
                            onTap: () => _showOnboardingModal(context),
                            badge: 'RECOMENDADO',
                          ),
                          const SizedBox(height: 16),
                          const _RoleCard(
                            icon: Icons.factory_outlined,
                            color: AppColors.green,
                            title: 'Empresa IMMEX',
                            description:
                                'Control Anexo 24, FIFO, saldos y vencimientos.',
                            features: [
                              'Motor FIFO Automático',
                              'Descargos en la nube',
                              'Alertas de vencimiento'
                            ],
                            route: '/immex',
                          ),
                        ]),

                  const SizedBox(height: 40),
                  Text(
                      'Puedes cambiar de rol en cualquier momento desde el menú',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: sub.withValues(alpha: 0.6), fontSize: 12)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    return Column(children: [
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.gold, Color(0xFFF5C842)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: gold.withValues(alpha: 0.45),
                blurRadius: 28,
                spreadRadius: 2)
          ],
        ),
        child: const Icon(Icons.shield_rounded, color: bg1, size: 36),
      ),
      const SizedBox(height: 20),
      ShaderMask(
        shaderCallback: (r) =>
            const LinearGradient(colors: [AppColors.gold, Color(0xFFFFE08A)])
                .createShader(r),
        child: const Text('Aduanas 801',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5)),
      ),
      const SizedBox(height: 10),
      const Text('¿Cómo quieres trabajar hoy?',
          style: TextStyle(
              color: text, fontSize: 16, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      const Text('Selecciona tu perfil para acceder a tus herramientas',
          style: TextStyle(color: sub, fontSize: 13)),
    ]);
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final List<String> features;
  final String? route;
  final String? badge;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.features,
    this.route,
    this.badge,
    this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovered = false;

  static const cardBg = AppColors.card;
  static const border = AppColors.border;
  static const sub = AppColors.sub;
  static const text = AppColors.text;
  static const bg1 = AppColors.bg;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          } else if (widget.route != null) {
            context.go(widget.route!);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withValues(alpha: 0.08) : cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered ? widget.color.withValues(alpha: 0.7) : border,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: widget.color.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 2),
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20),
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12),
                  ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // Icon container with gradient
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      widget.color.withValues(alpha: 0.25),
                      widget.color.withValues(alpha: 0.08)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border:
                      Border.all(color: widget.color.withValues(alpha: 0.3)),
                ),
                child: Icon(widget.icon, color: widget.color, size: 26),
              ),
              // Badge
              if (widget.badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: widget.color.withValues(alpha: 0.4)),
                  ),
                  child: Text(widget.badge!,
                      style: TextStyle(
                          color: widget.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                ),
            ]),
            const SizedBox(height: 20),
            Text(widget.title,
                style: const TextStyle(
                    color: text, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(widget.description,
                style: const TextStyle(color: sub, fontSize: 13, height: 1.5)),
            const SizedBox(height: 20),

            // Feature bullets
            ...widget.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Icon(Icons.check_circle_rounded,
                        color: widget.color, size: 14),
                    const SizedBox(width: 8),
                    Text(f,
                        style: const TextStyle(color: text, fontSize: 12.5)),
                  ]),
                )),
            const SizedBox(height: 20),

            // CTA Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: _hovered
                    ? widget.color
                    : widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: widget.color.withValues(alpha: 0.6)),
              ),
              child: Center(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Entrar como ${widget.title.split(' ').first}',
                    style: TextStyle(
                        color: _hovered ? bg1 : widget.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded,
                    color: _hovered ? bg1 : widget.color, size: 16),
              ])),
            ),
          ]),
        ),
      ),
    );
  }
}

class _RoleBgPainter extends CustomPainter {
  final double t;
  _RoleBgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.bg, Color(0xFF0A1628), AppColors.bg],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final orbs = [
      (0.5, 0.1, 350.0, AppColors.gold, 0.0),
      (0.1, 0.7, 250.0, AppColors.blue, 0.3),
      (0.9, 0.8, 200.0, AppColors.green, 0.6),
    ];
    for (final o in orbs) {
      final phase = (t + o.$5) % 1.0;
      final cx = size.width * o.$1 + math.sin(phase * math.pi * 2) * 20;
      final cy = size.height * o.$2 + math.cos(phase * math.pi * 2) * 15;
      paint.shader = RadialGradient(
        colors: [o.$4.withValues(alpha: 0.1), o.$4.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: o.$3));
      canvas.drawCircle(Offset(cx, cy), o.$3, paint);
    }
    final lp = Paint()
      ..color = AppColors.border.withValues(alpha: 0.18)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lp);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lp);
    }
  }

  @override
  bool shouldRepaint(_RoleBgPainter old) => old.t != t;
}

class _OnboardingDialog extends StatefulWidget {
  const _OnboardingDialog();

  @override
  State<_OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<_OnboardingDialog> {
  String? q1;
  String? q2;
  String? q3;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.rocket_launch_rounded,
                color: Color(0xFFF59E0B), size: 48),
            const SizedBox(height: 16),
            const Text(
              '¡Bienvenido!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para darte la mejor experiencia, cuéntanos un poco sobre ti.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. ¿Qué quieres hacer?',
              value: q1,
              options: const ['Importar', 'Exportar', 'Apenas aprendiendo'],
              onChanged: (val) => setState(() => q1 = val),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '2. ¿Tienes empresa?',
              value: q2,
              options: const ['Sí, somos empresa', 'No, soy persona física'],
              onChanged: (val) => setState(() => q2 = val),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '3. ¿Nivel de experiencia?',
              value: q3,
              options: const [
                'Primera vez',
                'Tengo algo de experiencia',
                'Experto'
              ],
              onChanged: (val) => setState(() => q3 = val),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: (q1 != null && q2 != null && q3 != null)
                  ? () {
                      Navigator.of(context).pop();
                      if (q3 == 'Experto') {
                        context.go('/home');
                      } else {
                        context.go('/importer_hub');
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                disabledBackgroundColor: const Color(0xFF334155),
                disabledForegroundColor: const Color(0xFF94A3B8),
              ),
              child: const Text('Comenzar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = value == opt;
            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (sel) {
                if (sel) onChanged(opt);
              },
              backgroundColor: const Color(0xFF0F172A),
              selectedColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF475569),
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}
