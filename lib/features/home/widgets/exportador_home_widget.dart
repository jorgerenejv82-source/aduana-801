import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/widgets/skeleton_loader.dart';

class ExportadorHomeWidget extends StatefulWidget {
  final String userName;
  const ExportadorHomeWidget({super.key, required this.userName});

  @override
  State<ExportadorHomeWidget> createState() => _ExportadorHomeWidgetState();
}

class _ExportadorHomeWidgetState extends State<ExportadorHomeWidget> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'test_uid';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF134E5E), Color(0xFF71B280)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, ${widget.userName}! 📤',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Exporta con confianza y conocimiento',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // KPI Row
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: const [
              _KpiCard(
                  label: 'Exportado YTD',
                  value: '\$0 USD',
                  icon: Icons.upload_outlined,
                  color: Color(0xFF10B981)),
              _KpiCard(
                  label: 'IVA Tasa 0',
                  value: '\$0 MXN',
                  icon: Icons.percent_outlined,
                  color: AppColors.gold),
              _KpiCard(
                  label: 'Certificados C.O.',
                  value: '0 activos',
                  icon: Icons.verified_outlined,
                  color: AppColors.blue),
              _KpiCard(
                  label: 'Pedimentos Exp.',
                  value: '0 este mes',
                  icon: Icons.receipt_long_outlined,
                  color: Color(0xFF6366F1)),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ActionChip('🇲🇽🇺🇸 Cert. Origen', '/tmec'),
                SizedBox(width: 8),
                _ActionChip('📜 Reglas de Origen', '/tmec'),
                SizedBox(width: 8),
                _ActionChip('📤 Pedimento Exp.', '/simulador_pedimento'),
                SizedBox(width: 8),
                _ActionChip('💰 Drawback', '/duty_drawback'),
                SizedBox(width: 8),
                _ActionChip('🏭 IMMEX', '/immex'),
                SizedBox(width: 8),
                _ActionChip('📊 Landed Cost', '/landed_cost'),
                SizedBox(width: 8),
                _ActionChip('🔐 OEA', '/oea_seciit'),
                SizedBox(width: 8),
                _ActionChip('💹 Finanzas', '/cashflow'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Modules
          const Text('🌎 Tus herramientas de exportación',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: const [
                _ModuleCard(
                    title: 'Certificado de Origen',
                    subtitle: 'TMEC/USMCA · Form A · EUR1',
                    icon: Icons.verified_outlined,
                    color: Color(0xFF10B981),
                    route: '/tmec'),
                _ModuleCard(
                    title: 'Pedimento Exportación',
                    subtitle: 'Simula pedimentos A1/IN/RT',
                    icon: Icons.receipt_long_outlined,
                    color: Color(0xFF6366F1),
                    route: '/simulador_pedimento'),
                _ModuleCard(
                    title: 'Reglas de Origen',
                    subtitle: 'Clasifica con criterio RVC/TARIFF',
                    icon: Icons.rule_outlined,
                    color: AppColors.gold,
                    route: '/auditor_tmec_bom'),
                _ModuleCard(
                    title: 'Duty Drawback',
                    subtitle: 'Recupera impuestos de importación',
                    icon: Icons.savings_outlined,
                    color: Color(0xFF10B981),
                    route: '/duty_drawback'),
                _ModuleCard(
                    title: 'IMMEX',
                    subtitle: 'Importación temporal para exportar',
                    icon: Icons.factory_outlined,
                    color: AppColors.blue,
                    route: '/immex'),
                _ModuleCard(
                    title: 'IVA Tasa 0',
                    subtitle: 'Exportaciones exentas de IVA',
                    icon: Icons.percent_outlined,
                    color: AppColors.gold,
                    route: '/cashflow'),
                _ModuleCard(
                    title: 'OEA / CTPAT',
                    subtitle: 'Operador Económico Autorizado',
                    icon: Icons.security_outlined,
                    color: AppColors.blue,
                    route: '/oea_seciit'),
                _ModuleCard(
                    title: 'Clasificación HTS',
                    subtitle: 'Código arancelario en destino',
                    icon: Icons.qr_code_outlined,
                    color: Color(0xFF6366F1),
                    route: '/clasificador_ia'),
                _ModuleCard(
                    title: 'Proveedores',
                    subtitle: 'CRM de clientes en el extranjero',
                    icon: Icons.public_outlined,
                    color: AppColors.sub,
                    route: '/suppliers'),
                _ModuleCard(
                    title: 'Permisos Previos',
                    subtitle: 'SE, SEMARNAT, COFEPRIS',
                    icon: Icons.gavel_outlined,
                    color: AppColors.red,
                    route: '/permisos_previos'),
                _ModuleCard(
                    title: 'Incoterms 2020',
                    subtitle: 'Define responsabilidades y costos',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.blue,
                    route: '/incoterms'),
                _ModuleCard(
                    title: 'Resumen Anual',
                    subtitle: 'Tu año en exportaciones',
                    icon: Icons.calendar_month_outlined,
                    color: Color(0xFF10B981),
                    route: '/annual_summary'),
              ]),
          const SizedBox(height: 24),

          // Alerts section
          const Text('🔔 Alertas del día',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildAlerts(),
        ],
      ),
    );
  }

  Widget _buildAlerts() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestoreCollections.notificaciones)
            .where('uid', isEqualTo: uid)
            .where('read', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SkeletonLoader(height: 50);
          final unread = snapshot.data!.docs.length;
          if (unread == 0) {
            return const Text('✅ Sin alertas hoy. Todo en orden.',
                style: TextStyle(color: AppColors.green, fontSize: 14));
          }
          return InkWell(
            onTap: () => context.push('/alerts'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withAlpha(102)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.gold),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text('Tienes $unread alertas pendientes',
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold))),
                  const Icon(Icons.chevron_right, color: AppColors.gold),
                ],
              ),
            ),
          );
        });
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Conecta tus operaciones',
              style: TextStyle(color: AppColors.sub, fontSize: 10)),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final String route;

  const _ActionChip(this.label, this.route);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: AppColors.sub, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
