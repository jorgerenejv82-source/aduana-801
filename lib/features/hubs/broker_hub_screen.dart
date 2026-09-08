import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BrokerHubScreen extends StatelessWidget {
  const BrokerHubScreen({super.key});

  static const bg1 = AppColors.bg;
  static const card = AppColors.card;
  static const gold = AppColors.gold;
  static const text = AppColors.text;
  static const sub = AppColors.sub;
  static const border = AppColors.border;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg1,
      appBar: AppBar(
        backgroundColor: bg1,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: gold),
        ),
        title: const Text('Broker Hub',
            style: TextStyle(color: text, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: border, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panel de Control del Agente Aduanal',
              style: TextStyle(
                  color: text, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gestión centralizada de autorizaciones, firmas y expedientes de clientes.',
              style: TextStyle(color: sub, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  _HubActionCard(
                      title: 'Firma Electrónica',
                      icon: Icons.draw,
                      color: AppColors.blue,
                      route: '/'),
                  _HubActionCard(
                      title: 'Autorización Pedimentos',
                      icon: Icons.check_circle,
                      color: AppColors.green,
                      route: '/'),
                  _HubActionCard(
                      title: 'Gestión de Clientes',
                      icon: Icons.people,
                      color: AppColors.gold,
                      route: '/'),
                  _HubActionCard(
                      title: 'Tarifas y Cotizaciones',
                      icon: Icons.request_quote,
                      color: AppColors.blue,
                      route: '/'),
                  _HubActionCard(
                      title: 'Reportes SAT',
                      icon: Icons.account_balance,
                      color: AppColors.red,
                      route: '/'),
                  _HubActionCard(
                      title: 'Configuración Patente',
                      icon: Icons.settings,
                      color: sub,
                      route: '/'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _HubActionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  const _HubActionCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.route});

  @override
  State<_HubActionCard> createState() => _HubActionCardState();
}

class _HubActionCardState extends State<_HubActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: BrokerHubScreen.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _isHovered ? widget.color : BrokerHubScreen.border),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                    color: widget.color.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 1)
              else
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: widget.color.withValues(alpha: 0.3)),
                ),
                child: Icon(widget.icon, size: 28, color: widget.color),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: BrokerHubScreen.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
