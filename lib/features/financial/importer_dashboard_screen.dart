import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class ImporterDashboardScreen extends StatefulWidget {
  const ImporterDashboardScreen({super.key});

  @override
  State<ImporterDashboardScreen> createState() =>
      _ImporterDashboardScreenState();
}

class _ImporterDashboardScreenState extends State<ImporterDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Dashboard Ejecutivo Importador'),
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Generación de PDF con IA en desarrollo...')));
            },
            tooltip: 'Exportar Reporte PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _buildKpiCard('Capital en Tránsito', '\$1,250,000',
                    '4 embarques activos', Colors.amber),
                _buildKpiCard('Órdenes Atrasadas', '3', 'Requieren atención',
                    Colors.redAccent),
                _buildKpiCard('Impuestos Pagados (Mes)', '\$450,000 MXN',
                    'vs. \$500,000 presupuesto', Colors.blueAccent),
                _buildKpiCard('NOMs por Vencer <90 días', '2',
                    'Requieren renovación', Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: const Color(0xFF1E1E1E),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ahorro TMEC Acumulado',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text('\$120,500',
                              style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)),
                          const Text('Este año',
                              style: TextStyle(color: Colors.white54)),
                          const SizedBox(height: 8),
                          FractionallySizedBox(
                            widthFactor: 0.65,
                            child:
                                Container(height: 8, color: Colors.greenAccent),
                          ),
                          const Text('65% del total vs sin preferencia',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: const Color(0xFF1E1E1E),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              'Capital de Trabajo en Operaciones Abiertas',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.blueAccent, width: 8),
                                ),
                                child: const Center(
                                    child: Text('Total',
                                        style: TextStyle(color: Colors.white))),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLegendItem(Colors.blue,
                                      'En tránsito marítimo (40%)'),
                                  _buildLegendItem(
                                      Colors.orange, 'En aduana (35%)'),
                                  _buildLegendItem(
                                      Colors.green, 'Liberado este mes (25%)'),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Top 5 Proveedores por TCO',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: const Color(0xFF1E1E1E),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSupplierRow('Proveedor A', 15.5, 30, true),
                    _buildSupplierRow('Proveedor B', 16.2, 45, false),
                    _buildSupplierRow('Proveedor C', 17.0, 20, true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Últimas 5 Operaciones',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Card(
                        color: const Color(0xFF1E1E1E),
                        child: Column(
                          children: [
                            _buildOperationRow('EXP-2026-001', 'Cliente Alpha',
                                'En Tránsito', '08/08/2026'),
                            _buildOperationRow('EXP-2026-002', 'Cliente Beta',
                                'Liberado', '07/08/2026'),
                            _buildOperationRow('EXP-2026-003', 'Cliente Gamma',
                                'Revisión', '05/08/2026'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alertas del Día',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Card(
                        color: Color(0xFF1E1E1E),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• Embarques con ETA vencida: 1',
                                  style: TextStyle(color: Colors.redAccent)),
                              SizedBox(height: 8),
                              Text('• POs con entrega atrasada: 3',
                                  style: TextStyle(color: Colors.orangeAccent)),
                              SizedBox(height: 8),
                              Text('• NOMs por vencer <30 días: 0',
                                  style: TextStyle(color: Colors.white70)),
                              SizedBox(height: 8),
                              Text(
                                  '• Clientes con IMMEX por vencer <30 días: 1',
                                  style: TextStyle(color: Colors.yellowAccent)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(
      String title, String value, String subtitle, Color color) {
    return Expanded(
      child: Card(
        color: const Color(0xFF1E1E1E),
        margin: const EdgeInsets.only(right: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      color: color, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSupplierRow(String name, double tco, int leadTime, bool tmec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(name, style: const TextStyle(color: Colors.white))),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (tco / 20).clamp(0.0, 1.0),
              child: Container(height: 12, color: Colors.blueAccent),
            ),
          ),
          const SizedBox(width: 16),
          Text('\$${tco.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4)),
            child: Text('$leadTime d',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          if (tmec)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(4)),
              child: const Text('TMEC',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildOperationRow(
      String id, String client, String status, String date) {
    return ListTile(
      title: Text(id, style: const TextStyle(color: Colors.white)),
      subtitle: Text(client, style: const TextStyle(color: Colors.white70)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:
                  status == 'Liberado' ? Colors.green[900] : Colors.orange[900],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status,
                style: TextStyle(
                    color: status == 'Liberado'
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    fontSize: 12)),
          ),
          const SizedBox(height: 4),
          Text(date,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
      onTap: () {},
    );
  }
}
