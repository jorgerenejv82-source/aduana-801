import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'models/cliente_crm_model.dart';
import 'services/clientes_pdf_service.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/error_state_widget.dart';

class ClientesListScreen extends StatelessWidget {
  const ClientesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
          'Clientes CRM',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clientes_crm')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonListView();
          }
          if (snapshot.hasError) {
            return ErrorStateWidget(message: snapshot.error.toString());
          }

          final clientes = snapshot.data?.docs
                  .map((d) => ClienteCrm.fromMap(
                      d.data() as Map<String, dynamic>, d.id))
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
                    Text('${clientes.length} Clientes',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.go(
                              '/clientes/nuevo'), // Usa el cliente_form_screen existente
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
                              ClientesPdfService.exportDirectorioClientes(
                                  clientes),
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
                    child: clientes.isEmpty
                        ? const Center(
                            child: Text(
                                'No hay clientes registrados en el CRM.',
                                style: TextStyle(color: AppColors.sub)))
                        : ListView.separated(
                            itemCount: clientes.length,
                            separatorBuilder: (_, __) => const Divider(
                                color: AppColors.border, height: 1),
                            itemBuilder: (context, index) {
                              final c = clientes[index];
                              // Semforo bsico: rojo si debe ms del 80% de su crdito
                              final isRisk = c.creditLimit > 0 &&
                                  (c.currentBalance / c.creditLimit) > 0.8;

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.gold.withValues(alpha: 0.2),
                                  child: Text(
                                      c.country.isNotEmpty
                                          ? c.country
                                              .substring(0, 2)
                                              .toUpperCase()
                                          : 'N/A',
                                      style: const TextStyle(
                                          color: AppColors.gold,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                                title: Text(c.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${c.industry} • ${c.taxId} • Trminos: ${c.paymentTerms}',
                                    style: const TextStyle(
                                        color: AppColors.sub, fontSize: 12)),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        'Saldo: ${fmt.format(c.currentBalance)}',
                                        style: TextStyle(
                                            color: isRisk
                                                ? AppColors.red
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    Text('Lmite: ${fmt.format(c.creditLimit)}',
                                        style: const TextStyle(
                                            color: AppColors.sub,
                                            fontSize: 11)),
                                  ],
                                ),
                                onTap: () => context.go('/clientes/${c.id}'),
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
