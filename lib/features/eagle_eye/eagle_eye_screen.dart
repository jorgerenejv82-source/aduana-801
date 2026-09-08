import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

const Color _bg = Color(0xFF0F172A);
const Color _card = Color(0xFF1E293B);
const Color _text = Color(0xFFF8FAFC);
const Color _sub = Color(0xFF94A3B8);
const Color _gold = Color(0xFFF59E0B);
const Color _green = AppColors.green;
const Color _blue = Color(0xFF3B82F6);
const Color _red = AppColors.red;
const Color _border = Color(0xFF475569);

class EagleEyeScreen extends StatefulWidget {
  const EagleEyeScreen({super.key});
  @override
  State<EagleEyeScreen> createState() => _EagleEyeScreenState();
}

class _EagleEyeScreenState extends State<EagleEyeScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Eagle Eye - Monitoreo Global',
            style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _text),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Semáforo del Sistema',
                style: TextStyle(
                    color: _text, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSystemHealth(),
            const SizedBox(height: 32),
            const Text('Métricas en Tiempo Real',
                style: TextStyle(
                    color: _text, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildMetricCard('operaciones',
                        'Operaciones Activas', Icons.local_shipping, _blue)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildMetricCard('encargos', 'Encargos Pendientes',
                        Icons.assignment, _gold)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildMetricCard('pre_glosas',
                        'Alertas de Pre-Glosa', Icons.warning, _red)),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Feed de Eventos Recientes',
                style: TextStyle(
                    color: _text, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(child: _buildLiveFeed()),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealth() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _healthIndicator('VUCEM', true),
          _healthIndicator('Validador M3', true),
          _healthIndicator('Conexión SAP', false),
          _healthIndicator('SaaM', true),
        ],
      ),
    );
  }

  Widget _healthIndicator(String name, bool isOk) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
              color: isOk ? _green : _red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: (isOk ? _green : _red).withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2)
              ]),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(color: _sub, fontSize: 14)),
      ],
    );
  }

  Widget _buildMetricCard(
      String collection, String title, IconData icon, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        final int count = snapshot.data?.docs.length ?? 0;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const Spacer(),
                  Text(count.toString(),
                      style: TextStyle(
                          color: color,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(color: _text, fontSize: 16)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveFeed() {
    // We combine recent events from the three collections by fetching them individually and merging
    // In a real app we might use a dedicated 'events' collection or Cloud Functions.
    // For this UI, we will just show a merged list from a single stream if we can, or just mock the feed for now if complex.
    // Let's just subscribe to 'operaciones' as a proxy for the feed to keep it simple, or build a custom stream.

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('operaciones')
          .where('uid', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
              child: Text('No hay eventos recientes',
                  style: TextStyle(color: _sub)));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final date =
                (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
            final title =
                data['pedimento'] ?? data['referencia'] ?? 'Nueva Operación';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: _blue, size: 12),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Actualización: $title',
                            style: const TextStyle(
                                color: _text, fontWeight: FontWeight.bold)),
                        const Text('Operación modificada en el sistema',
                            style: TextStyle(color: _sub, fontSize: 13)),
                      ],
                    ),
                  ),
                  Text(DateFormat('HH:mm - dd/MM').format(date),
                      style: const TextStyle(color: _sub, fontSize: 12)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
