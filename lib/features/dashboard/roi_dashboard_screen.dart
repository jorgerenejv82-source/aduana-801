import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RoiDashboardScreen extends StatefulWidget {
  const RoiDashboardScreen({super.key});

  @override
  State<RoiDashboardScreen> createState() => _RoiDashboardScreenState();
}

class _RoiDashboardScreenState extends State<RoiDashboardScreen> {
  final formatCurrency = NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de ROI (IA)'),
      ),
      body: uid == null
          ? const Center(child: Text('Usuario no autenticado'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ai_metrics')
                  .where('userId', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                double totalFinesSaved = 0.0;
                int highRiskCount = 0;

                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fines = (data['potentialFinesUSD'] as num?)?.toDouble() ?? 0.0;
                  totalFinesSaved += fines;
                  if (data['riskLevel'] == 'high') highRiskCount++;
                }

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Impacto Financiero de Inteligencia Artificial',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildStatCard(
                            context,
                            'Multas Prevenidas',
                            formatCurrency.format(totalFinesSaved),
                            Colors.greenAccent,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            context,
                            'Pedimentos Auditados',
                            docs.length.toString(),
                            Colors.blueAccent,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            context,
                            'Alertas Criticas (Riesgo Alto)',
                            highRiskCount.toString(),
                            Colors.redAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Text('Historial de Ahorros Recientes', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final fines = (data['potentialFinesUSD'] as num?)?.toDouble() ?? 0.0;
                            return ListTile(
                              leading: const Icon(Icons.analytics, color: Colors.blueAccent),
                              title: Text('Ahorro: ${formatCurrency.format(fines)}'),
                              subtitle: Text(data['summary']?.toString() ?? 'Sin resumen'),
                              trailing: Chip(
                                label: Text(data['riskLevel']?.toString().toUpperCase() ?? 'N/A'),
                                backgroundColor: data['riskLevel'] == 'high' 
                                  ? Colors.red.withValues(alpha: 0.2) 
                                  : Colors.orange.withValues(alpha: 0.2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
