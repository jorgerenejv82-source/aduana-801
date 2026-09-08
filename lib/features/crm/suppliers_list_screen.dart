import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/supplier_model.dart';
import 'services/supplier_pdf_service.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/error_state_widget.dart';

class SuppliersListScreen extends StatelessWidget {
  const SuppliersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: InkWell(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: AppColors.gold),
        ),
        title: const Text(
          'Proveedores Internacionales',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('suppliers')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonListView();
          }
          if (snapshot.hasError) {
            return ErrorStateWidget(message: snapshot.error.toString());
          }

          final suppliers = snapshot.data?.docs
                  .map((d) =>
                      Supplier.fromMap(d.data() as Map<String, dynamic>, d.id))
                  .toList() ??
              [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${suppliers.length} Proveedores',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.go('/suppliers/nuevo'),
                          icon: const Icon(Icons.add,
                              color: Colors.white, size: 16),
                          label: const Text('Nuevo',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () =>
                              SupplierPdfService.exportSupplierDirectory(
                                  suppliers),
                          icon: const Icon(Icons.picture_as_pdf,
                              color: Colors.white, size: 16),
                          label: const Text('Exportar',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: suppliers.isEmpty
                        ? const Center(
                            child: Text('No hay proveedores registrados.',
                                style: TextStyle(color: AppColors.sub)))
                        : ListView.separated(
                            itemCount: suppliers.length,
                            separatorBuilder: (_, __) => const Divider(
                                color: AppColors.border, height: 1),
                            itemBuilder: (context, index) {
                              final s = suppliers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.blue.withValues(alpha: 0.2),
                                  child: Text(
                                      s.country.isNotEmpty
                                          ? s.country
                                              .substring(0, 2)
                                              .toUpperCase()
                                          : 'N/A',
                                      style: const TextStyle(
                                          color: AppColors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                                title: Text(s.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${s.taxId} • Moneda: ${s.currency} • Trminos: ${s.paymentTerms}',
                                    style: const TextStyle(
                                        color: AppColors.sub, fontSize: 12)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star,
                                        color: AppColors.gold, size: 16),
                                    const SizedBox(width: 4),
                                    Text(s.reliabilityScore.toStringAsFixed(1),
                                        style: const TextStyle(
                                            color: AppColors.gold,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                onTap: () =>
                                    context.go('/suppliers/${s.id}/edit'),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
