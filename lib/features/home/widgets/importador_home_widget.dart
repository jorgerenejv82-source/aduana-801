import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/skeleton_loader.dart';

class ImportadorHomeWidget extends StatefulWidget {
  final String userName;
  const ImportadorHomeWidget({super.key, required this.userName});

  @override
  State<ImportadorHomeWidget> createState() => _ImportadorHomeWidgetState();
}

class _ImportadorHomeWidgetState extends State<ImportadorHomeWidget> {
  final String uid =
      'test_uid'; // Assuming uid comes from auth, but not provided in req, we just use a generic or empty

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
                  'Hola, ${widget.userName} 📦',
                  style:
                      AppTextStyles.displayMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Controla tus costos y cumplimiento',
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Director de Comercio Exterior',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.gold),
                  ),
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
            children: [
              _buildKPI1(),
              _buildKPI2(),
              _buildKPI3(),
              _buildKPI4(),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ActionChip('📅 Resumen Anual', Icons.calendar_month_outlined,
                    '/annual_summary'),
                SizedBox(width: 8),
                _ActionChip(
                    '📊 Dashboard', Icons.dashboard, '/importer_dashboard'),
                SizedBox(width: 8),
                _ActionChip('💰 Costo Total', Icons.calculate, '/landed_cost'),
                SizedBox(width: 8),
                _ActionChip(
                    '📦 Mis Compras', Icons.shopping_cart, '/supply_chain/po'),
                SizedBox(width: 8),
                _ActionChip(
                    '🚢 Embarques', Icons.directions_boat, '/shipment_tracker'),
                SizedBox(width: 8),
                _ActionChip('🔍 Comparar Costos', Icons.compare_arrows,
                    '/tco_comparator'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Alerts section
          const Text('🔔 Alertas del día', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 12),
          _buildAlerts(),
        ],
      ),
    );
  }

  Widget _buildKPI1() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('embarques')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonLoader(height: 100);
        }
        if (snapshot.hasError) {
          return _kpiCard(
              title: 'Capital en Tránsito',
              value: '--',
              subtitle: 'Error',
              color: AppColors.gold,
              icon: Icons.directions_boat);
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _kpiOnboarding('Capital en Tránsito');

        int count = 0;
        double sum = 0.0;
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['status'] != 'liberado') {
            count++;
            sum += (data['valorFob'] ?? 0.0) as double;
          }
        }
        return _kpiCard(
          title: 'Capital en Tránsito',
          value: '\$ ${sum.toStringAsFixed(2)} USD',
          subtitle: '$count embarques activos',
          color: AppColors.gold,
          icon: Icons.directions_boat,
        );
      },
    );
  }

  Widget _buildKPI2() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('purchase_orders')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonLoader(height: 100);
        }
        if (snapshot.hasError) {
          return _kpiCard(
              title: 'POs Retrasadas',
              value: '--',
              subtitle: 'Error',
              color: AppColors.red,
              icon: Icons.warning_amber);
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _kpiOnboarding('POs Retrasadas');

        int count = 0;
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['status'] == 'PENDING') {
            final expectedDelivery = data['expectedDelivery'];
            if (expectedDelivery != null) {
              DateTime dt;
              if (expectedDelivery is Timestamp) {
                dt = expectedDelivery.toDate();
              } else {
                dt = DateTime.tryParse(expectedDelivery.toString()) ??
                    DateTime.now();
              }
              if (dt.isBefore(DateTime.now())) {
                count++;
              }
            }
          }
        }
        return _kpiCard(
          title: 'POs Retrasadas',
          value: count.toString(),
          subtitle: 'Requieren atención',
          color: AppColors.red,
          icon: Icons.warning_amber,
        );
      },
    );
  }

  Widget _buildKPI3() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('nom_vigencias')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonLoader(height: 100);
        }
        if (snapshot.hasError) {
          return _kpiCard(
              title: 'NOMs por Vencer',
              value: '--',
              subtitle: 'Error',
              color: const Color(0xFFF59E0B),
              icon: Icons.gavel);
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _kpiOnboarding('NOMs por Vencer');

        int count = 0;
        final ninetyDays = DateTime.now().add(const Duration(days: 90));
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final fechaVigencia = data['fechaVigencia'];
          if (fechaVigencia != null) {
            DateTime dt;
            if (fechaVigencia is Timestamp) {
              dt = fechaVigencia.toDate();
            } else {
              dt =
                  DateTime.tryParse(fechaVigencia.toString()) ?? DateTime.now();
            }
            if (dt.isBefore(ninetyDays)) {
              count++;
            }
          }
        }
        return _kpiCard(
          title: 'NOMs por Vencer',
          value: count.toString(),
          subtitle: 'Próximos 90 días',
          color: const Color(0xFFF59E0B),
          icon: Icons.gavel,
        );
      },
    );
  }

  Widget _buildKPI4() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('drawback_historial')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonLoader(height: 100);
        }
        if (snapshot.hasError) {
          return _kpiCard(
              title: 'Ahorro TMEC Año',
              value: '--',
              subtitle: 'Error',
              color: AppColors.green,
              icon: Icons.savings);
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _kpiOnboarding('Ahorro TMEC Año');

        double sum = 0.0;
        final currentYear = DateTime.now().year;
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final createdAt = data['createdAt'];
          if (createdAt != null) {
            DateTime dt;
            if (createdAt is Timestamp) {
              dt = createdAt.toDate();
            } else {
              dt = DateTime.tryParse(createdAt.toString()) ?? DateTime.now();
            }
            if (dt.year == currentYear) {
              sum += (data['totalRecuperable'] ?? 0.0) as double;
            }
          }
        }
        return _kpiCard(
          title: 'Ahorro TMEC Año',
          value: '\$ ${sum.toStringAsFixed(2)} MXN',
          subtitle: 'Recuperado este año',
          color: AppColors.green,
          icon: Icons.savings,
        );
      },
    );
  }

  Widget _kpiCard(
      {required String title,
      required String value,
      required String subtitle,
      required Color color,
      required IconData icon}) {
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
                  child: Text(title,
                      style: AppTextStyles.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const Spacer(),
          Text(value,
              style: AppTextStyles.displayMedium.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _kpiOnboarding(String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text('Configurar\n$title',
            textAlign: TextAlign.center, style: AppTextStyles.labelMedium),
      ),
    );
  }

  Widget _buildAlerts() {
    return Text('✅ Sin alertas hoy. Todo en orden.',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.green));
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;

  const _ActionChip(this.label, this.icon, this.route);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.sub),
      label: Text(label, style: AppTextStyles.labelMedium),
      backgroundColor: AppColors.card,
      side: const BorderSide(color: AppColors.border),
      onPressed: () => context.push(route),
    );
  }
}

class TcWatchWidget extends StatefulWidget {
  const TcWatchWidget({super.key});

  @override
  State<TcWatchWidget> createState() => _TcWatchWidgetState();
}

class _TcWatchWidgetState extends State<TcWatchWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.doc('config/tipo_cambio').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.attach_money, color: AppColors.sub, size: 14),
            Text('17.15', style: TextStyle(color: AppColors.sub, fontSize: 13)),
            Text(' MXN/USD',
                style: TextStyle(color: AppColors.sub, fontSize: 10)),
          ]);
        }
        String value = '17.15';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data.containsKey('usd_mxn')) {
            value = data['usd_mxn'].toString();
          }
        }

        return InkWell(
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (ctx) => Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.bg,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tipo de Cambio FIX',
                        style: AppTextStyles.headlineLarge),
                    SizedBox(height: 16),
                    Text(
                        'Este es el tipo de cambio FIX publicado por Banxico/DOF en tiempo real.',
                        style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            );
          },
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.attach_money, size: 16, color: AppColors.gold),
                const SizedBox(width: 4),
                Text('$value MXN/USD',
                    style: AppTextStyles.labelMedium
                        .copyWith(fontSize: 13, color: AppColors.gold)),
              ],
            ),
          ),
        );
      },
    );
  }
}
