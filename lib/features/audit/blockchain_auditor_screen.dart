import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _bg = AppColors.bg;
const Color _text = AppColors.text;
const Color _gold = AppColors.gold;
const Color _border = AppColors.border;
const Color _sub = AppColors.sub;
const Color _green = AppColors.green;

class BlockchainAuditorScreen extends StatelessWidget {
  const BlockchainAuditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Blockchain Audit Trail',
            style: TextStyle(color: _text, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _border, height: 1)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blockchain_audit_log')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _gold));
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Error al cargar la cadena',
                    style: TextStyle(color: Colors.red)));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
                child: Text('No hay bloques registrados.',
                    style: TextStyle(color: _sub)));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final hash = data['hash'] ?? 'N/A';
              final op = data['operation'] ?? 'N/A';
              final user = (data['user'] ?? 'N/A') as String;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _green.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link, color: _green, size: 20),
                        const SizedBox(width: 8),
                        const Text('Bloque Verificado',
                            style: TextStyle(
                                color: _green, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(user,
                            style: const TextStyle(color: _gold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Operación: $op',
                        style: const TextStyle(color: _text, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Hash: $hash',
                        style: const TextStyle(
                            color: _sub,
                            fontFamily: 'monospace',
                            fontSize: 12)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
