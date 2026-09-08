import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FinancialDashboardScreen extends StatefulWidget {
  const FinancialDashboardScreen({super.key});

  @override
  State<FinancialDashboardScreen> createState() =>
      _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState extends State<FinancialDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _briefingGenerated = false;
  static const Color bg1 = AppColors.bg;
  static const Color card = AppColors.card;
  static const Color gold = AppColors.gold;
  static const Color text = AppColors.text;
  static const Color sub = AppColors.sub;
  static const Color border = AppColors.border;
  static const Color green = AppColors.green;
  static const Color blue = AppColors.blue;
  static const Color red = AppColors.red;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _generarBriefing() {
    setState(() {
      _briefingGenerated = true;
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat("EEEE, d 'de' MMMM • HH:mm", 'es').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg1,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildBriefingCard(),
                const SizedBox(height: 24),
                _buildKpiRow(),
                const SizedBox(height: 24),
                _buildControlTowerCard(context),
                const SizedBox(height: 16),
                _buildAutopilotCard(context),
                const SizedBox(height: 24),
                _buildTipoCambioCard(),
                const SizedBox(height: 32),
                _buildQuickActions(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aduanas 801',
              style: TextStyle(
                  color: gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5),
            ),
            SizedBox(height: 4),
            Text(
              'Dashboard Financiero',
              style: TextStyle(
                color: text,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const Spacer(),
        _buildHeaderIcon(Icons.search),
        const SizedBox(width: 12),
        _buildHeaderIcon(Icons.notifications_none),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: card,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: text, size: 20),
    );
  }

  Widget _buildBriefingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [card, bg1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.wb_sunny, color: gold, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Briefing Ejecutivo',
                    style: TextStyle(
                        color: text, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
              Text(
                _formatDate(DateTime.now()),
                style: const TextStyle(
                    color: sub, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: border, height: 1),
          const SizedBox(height: 20),
          if (!_briefingGenerated) ...[
            const Text(
              'Sintetiza la información clave del día impulsado por IA.',
              style: TextStyle(color: sub, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _generarBriefing,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Generar Inteligencia Diaria'),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: bg1,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ] else ...[
            _buildBriefingPoint(
                'Tipo de Cambio (DOF)',
                'Estable. \$17.15 MXN por USD. Buen momento para pagos.',
                Icons.currency_exchange),
            const SizedBox(height: 16),
            _buildBriefingPoint(
                'Alerta Operativa',
                'Revisar fracciones arancelarias de nuevos productos electrónicos antes del despacho.',
                Icons.warning_amber),
            const SizedBox(height: 16),
            _buildBriefingPoint(
                'Insight',
                '"El éxito en aduanas es 90% preparación y 10% ejecución."',
                Icons.lightbulb_outline),
          ],
        ],
      ),
    );
  }

  Widget _buildBriefingPoint(String title, String content, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: gold, size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: gold, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text(content,
                  style:
                      const TextStyle(color: text, fontSize: 14, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiRow() {
    return const Row(
      children: [
        Expanded(
          child: _KpiCard(
            title: 'Pedimentos Activos',
            value: '42',
            icon: Icons.inventory_2_outlined,
            trend: '+5%',
            isPositive: true,
            iconColor: blue,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            title: 'Despachos Hoy',
            value: '18',
            icon: Icons.check_circle_outline,
            trend: '+12%',
            isPositive: true,
            iconColor: green,
          ),
        ),
      ],
    );
  }

  Widget _buildControlTowerCard(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      route: '/immex',
      title: 'Control Tower (IMMEX)',
      subtitle: 'Orquestador Inbound/Outbound',
      icon: Icons.qr_code_scanner,
      gradientColors: [gold, const Color(0xFFA67A00)],
      textColor: bg1,
    );
  }

  Widget _buildAutopilotCard(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      route: '/ai_copilot',
      title: 'Autopilot AI Center',
      subtitle: 'Agentes Autónomos Monitoreando',
      icon: Icons.smart_toy,
      gradientColors: [card, const Color(0xFF162540)],
      textColor: text,
      borderColor: blue.withValues(alpha: 0.3),
      iconColor: blue,
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String route,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required Color textColor,
    Color? borderColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor ?? Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (textColor == bg1 ? Colors.black : Colors.white)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? textColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: textColor.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoCambioCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gold.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.currency_exchange, color: gold, size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tipo de Cambio DOF',
                  style: TextStyle(
                      color: sub,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(height: 4),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('config')
                    .doc('tipoCambio')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error',
                        style: TextStyle(color: AppColors.red));
                  }
                  String valor = '17.1500';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    if (data.containsKey('valor')) {
                      valor = data['valor'].toString();
                    }
                  }
                  return Text(
                    '\$$valor',
                    style: const TextStyle(
                        color: text, fontSize: 28, fontWeight: FontWeight.w900),
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh, color: blue),
            tooltip: 'Actualizar',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.view_kanban,
        'title': 'Kanban',
        'route': '/kanban',
        'color': blue
      },
      {
        'icon': Icons.event_busy,
        'title': 'Vencimientos',
        'route': '/history',
        'color': red
      },
      {
        'icon': Icons.radar,
        'title': 'Radar SAT',
        'route': '/sat_radar',
        'color': green
      },
      {
        'icon': Icons.calculate,
        'title': 'Calculadora',
        'route': '/calculator',
        'color': gold
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Herramientas Rápidas',
          style:
              TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            final color = action['color'] as Color;
            return InkWell(
              onTap: () => context.go(action['route'] as String),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 75,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: card,
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(action['icon'] as IconData, color: color, size: 28),
                    const SizedBox(height: 12),
                    Text(
                      action['title'] as String,
                      style: const TextStyle(
                          color: text,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String trend;
  final bool isPositive;
  final Color iconColor;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.trend,
    required this.isPositive,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.green : AppColors.red)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? AppColors.green : AppColors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: isPositive ? AppColors.green : AppColors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
                color: AppColors.sub,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
