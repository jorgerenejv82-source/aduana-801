import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class ControlTowerScreen extends StatefulWidget {
  const ControlTowerScreen({super.key});

  @override
  State<ControlTowerScreen> createState() => _ControlTowerScreenState();
}

class _ControlTowerScreenState extends State<ControlTowerScreen> {
  final Color _bg = AppColors.bg;
  final Color _card = AppColors.card;
  final Color _sub = AppColors.sub;
  final Color _border = AppColors.border;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),

            // Fila Superior: Tracker y Alertas
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildShipmentTracker()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildRedAlerts()),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildShipmentTracker(),
                    const SizedBox(height: 24),
                    _buildRedAlerts(),
                  ],
                );
              }
            }),

            const SizedBox(height: 32),
            // Fila Inferior: Gastos
            _buildExpensesChart(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Control Tower",
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Visión 360° de tus operaciones internacionales",
                style: TextStyle(color: _sub, fontSize: 14)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/despacho_hub'),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Nuevo Embarque",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        )
      ],
    );
  }

  Widget _buildShipmentTracker() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_boat,
                  color: AppColors.blue, size: 20),
              const SizedBox(width: 8),
              const Text("Embarques Activos",
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                  onPressed: () {},
                  child: const Text("Ver todos",
                      style: TextStyle(color: AppColors.gold))),
            ],
          ),
          const SizedBox(height: 24),
          _buildTimeline(
            title: "Contenedor MSCU1234567 - Tenis Nike",
            status: 3, // 0 to 4
            statusText: "En Previo Aduanal",
            origin: "Shanghai, CHN",
            destination: "Manzanillo, MX",
            eta: "Hoy, 14:00 hrs",
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 24),
          _buildTimeline(
            title: "Guía Aérea 132-456789 - Electrónicos",
            status: 4,
            statusText: "Despachado (Semáforo Verde)",
            origin: "Shenzhen, CHN",
            destination: "AICM, MX",
            eta: "Entregado ayer",
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline({
    required String title,
    required int status,
    required String statusText,
    required String origin,
    required String destination,
    required String eta,
  }) {
    final steps = [
      {"icon": Icons.factory, "label": "Origen"},
      {"icon": Icons.sailing, "label": "Tránsito"},
      {"icon": Icons.anchor, "label": "Arribo"},
      {"icon": Icons.search, "label": "Aduana"},
      {"icon": Icons.local_shipping, "label": "Entrega"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: status == 4
                    ? AppColors.green.withAlpha(30)
                    : AppColors.blue.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: status == 4 ? AppColors.green : AppColors.blue),
              ),
              child: Text(statusText,
                  style: TextStyle(
                      color: status == 4 ? AppColors.green : AppColors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.flight_takeoff, color: _sub, size: 14),
            const SizedBox(width: 4),
            Text(origin, style: TextStyle(color: _sub, fontSize: 12)),
            const SizedBox(width: 16),
            Icon(Icons.flight_land, color: _sub, size: 14),
            const SizedBox(width: 4),
            Text(destination, style: TextStyle(color: _sub, fontSize: 12)),
            const SizedBox(width: 16),
            Icon(Icons.access_time, color: _sub, size: 14),
            const SizedBox(width: 4),
            Text(eta, style: TextStyle(color: _sub, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: List.generate(steps.length, (index) {
            final isActive = index <= status;
            final isCurrent = index == status;
            return Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              height: 2,
                              color: index == 0
                                  ? Colors.transparent
                                  : (isActive ? AppColors.gold : _border))),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.gold : _card,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isActive ? AppColors.gold : _border,
                              width: 2),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                      color: AppColors.gold.withAlpha(100),
                                      blurRadius: 8,
                                      spreadRadius: 2)
                                ]
                              : null,
                        ),
                        child: Icon(steps[index]["icon"] as IconData,
                            size: 14, color: isActive ? Colors.black : _sub),
                      ),
                      Expanded(
                          child: Container(
                              height: 2,
                              color: index == steps.length - 1
                                  ? Colors.transparent
                                  : (isActive && index < status
                                      ? AppColors.gold
                                      : _border))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(steps[index]["label"] as String,
                      style: TextStyle(
                          color: isActive ? AppColors.text : _sub,
                          fontSize: 11,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRedAlerts() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.red.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 20),
              SizedBox(width: 8),
              Text("Alertas de Cumplimiento",
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _buildAlertTile(
            title: "Falta Certificado NOM-001",
            desc: "Embarque MSCU1234567 requiere NOM de seguridad eléctrica.",
            isCritical: true,
          ),
          const SizedBox(height: 12),
          _buildAlertTile(
            title: "Carta Porte Pendiente",
            desc:
                "El transportista no ha emitido el CFDI de Traslado (Viaje a CDMX).",
            isCritical: true,
          ),
          const SizedBox(height: 12),
          _buildAlertTile(
            title: "Padrón Sectorial Textil",
            desc: "Tu padrón vence en 15 días. Inicia renovación.",
            isCritical: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(
      {required String title, required String desc, required bool isCritical}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCritical
            ? AppColors.red.withAlpha(20)
            : AppColors.gold.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isCritical
                ? AppColors.red.withAlpha(50)
                : AppColors.gold.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isCritical ? Icons.error_outline : Icons.info_outline,
              color: isCritical ? AppColors.red : AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: isCritical ? AppColors.red : AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(desc,
                    style:
                        const TextStyle(color: AppColors.text, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildExpensesChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gastos y Contribuciones (Últimos 7 días)",
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Impuestos (IGI, IVA, DTA) y Logística",
              style: TextStyle(color: AppColors.sub, fontSize: 13)),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                            color: AppColors.sub,
                            fontWeight: FontWeight.bold,
                            fontSize: 12);
                        String text = '';
                        switch (value.toInt()) {
                          case 0:
                            text = 'Lun';
                            break;
                          case 1:
                            text = 'Mar';
                            break;
                          case 2:
                            text = 'Mié';
                            break;
                          case 3:
                            text = 'Jue';
                            break;
                          case 4:
                            text = 'Vie';
                            break;
                          case 5:
                            text = 'Sáb';
                            break;
                          case 6:
                            text = 'Dom';
                            break;
                        }
                        return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return const Text('\${value.toInt()}k',
                            style:
                                TextStyle(color: AppColors.sub, fontSize: 11));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: _border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 45, 20),
                  _makeGroupData(1, 30, 10),
                  _makeGroupData(2, 60, 40),
                  _makeGroupData(3, 80, 25),
                  _makeGroupData(4, 25, 15),
                  _makeGroupData(5, 10, 5),
                  _makeGroupData(6, 5, 5),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 12, height: 12, color: AppColors.gold),
              const SizedBox(width: 8),
              const Text("Impuestos (MXN)",
                  style: TextStyle(color: AppColors.sub, fontSize: 12)),
              const SizedBox(width: 24),
              Container(width: 12, height: 12, color: AppColors.blue),
              const SizedBox(width: 8),
              const Text("Flete Terrestre",
                  style: TextStyle(color: AppColors.sub, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: AppColors.gold,
          width: 16,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        BarChartRodData(
          toY: y2,
          color: AppColors.blue,
          width: 16,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ],
    );
  }
}
