import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _bg = AppColors.bg;
const Color _text = AppColors.text;
const Color _gold = AppColors.gold;
const Color _border = AppColors.border;
const Color _sub = AppColors.sub;

class VirtualOpsScreen extends StatelessWidget {
  const VirtualOpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Dashboard de Operaciones Virtuales',
            style: TextStyle(color: _text, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Conteo en Tiempo Real',
                style: TextStyle(
                    color: _gold, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                      child: _buildCountCard('Operaciones', 'operaciones')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCountCard('Encargos', 'encargos')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildCountCard('Expedientes', 'expedientes')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard(String title, String collectionName) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: StreamBuilder<AggregateQuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collectionName)
            .count()
            .get()
            .asStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _gold));
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Error', style: TextStyle(color: Colors.red)));
          }
          final count = snapshot.data?.count ?? 0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: _sub, fontSize: 16)),
              const SizedBox(height: 8),
              Text('$count',
                  style: const TextStyle(
                      color: _text, fontSize: 48, fontWeight: FontWeight.bold)),
            ],
          );
        },
      ),
    );
  }
}
