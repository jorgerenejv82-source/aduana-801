import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'models/po_model.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/error_state_widget.dart';

class PoListScreen extends StatelessWidget {
  const PoListScreen({super.key});

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
          'Órdenes de Compra (POs)',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('purchase_orders')
            .orderBy('issueDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonListView();
          }
          if (snapshot.hasError) {
            return ErrorStateWidget(message: snapshot.error.toString());
          }

          final pos = snapshot.data?.docs
                  .map((d) => PurchaseOrder.fromMap(
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
                    Text('${pos.length} Órdenes de Compra',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/supply_chain/po/nueva'),
                      icon:
                          const Icon(Icons.add, color: Colors.white, size: 16),
                      label: const Text('Nueva PO',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue),
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
                    child: pos.isEmpty
                        ? const Center(
                            child: Text('No hay POs registradas.',
                                style: TextStyle(color: AppColors.sub)))
                        : RefreshIndicator(
                            onRefresh: () async {
                              await Future<void>.delayed(
                                  const Duration(milliseconds: 800));
                            },
                            color: AppColors.gold,
                            backgroundColor: AppColors.card,
                            child: ListView.separated(
                              itemCount: pos.length,
                              separatorBuilder: (_, __) => const Divider(
                                  color: AppColors.border, height: 1),
                              itemBuilder: (context, index) {
                                final po = pos[index];

                                Color statusColor;
                                switch (po.status) {
                                  case 'SENT':
                                    statusColor = AppColors.blue;
                                    break;
                                  case 'RECEIVED':
                                    statusColor = AppColors.green;
                                    break;
                                  default:
                                    statusColor = AppColors.gold;
                                }

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        statusColor.withValues(alpha: 0.2),
                                    child: Icon(Icons.receipt_long,
                                        color: statusColor, size: 20),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                              '${po.poNumber} - ${po.supplierName}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      if (po.tieneCertOrigen)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: AppColors.gold,
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: const Text('TMEC',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                          'Incoterm: ${po.incoterm} • Entrega: ${DateFormat('dd/MMM/yyyy').format(po.expectedDeliveryDate)}',
                                          style: const TextStyle(
                                              color: AppColors.sub,
                                              fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (po.fraccionArancelaria.isNotEmpty)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              decoration: BoxDecoration(
                                                  color: AppColors.blue
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Text(
                                                  'HTS: ${po.fraccionArancelaria}',
                                                  style: const TextStyle(
                                                      color: AppColors.blue,
                                                      fontSize: 10)),
                                            ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: Text(
                                                '${po.leadTimeDias}d LT',
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(fmt.format(po.totalAmount),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      Text(po.currency,
                                          style: const TextStyle(
                                              color: AppColors.sub,
                                              fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Text(
                                          'TCO Est: ${fmt.format(po.precioUnitario * po.cantidadUnidades + po.costoFleteEstimado)}',
                                          style: const TextStyle(
                                              color: AppColors.gold,
                                              fontSize: 10)),
                                    ],
                                  ),
                                );
                              },
                            ),
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
