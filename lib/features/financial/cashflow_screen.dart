import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'models/cashflow_transaction_model.dart';
import 'services/cashflow_pdf_service.dart';

class CashflowScreen extends StatelessWidget {
  const CashflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
          'Flujo de Caja Real',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cashflow_transactions')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.blue));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.red)));
          }

          final transactions = snapshot.data?.docs
                  .map((d) => CashflowTransaction.fromMap(
                      d.data() as Map<String, dynamic>, d.id))
                  .toList() ??
              [];

          // Calcular KPIs reales (Anti-Mock)
          double totalIn = 0;
          double totalOut = 0;
          double pendingIn = 0;
          double pendingOut = 0;

          for (final t in transactions) {
            if (t.type == 'IN') {
              totalIn += t.amount;
            } else if (t.type == 'OUT') {
              totalOut += t.amount;
            } else if (t.type == 'PENDING_IN') {
              pendingIn += t.amount;
            } else if (t.type == 'PENDING_OUT') {
              pendingOut += t.amount;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Resumen Financiero',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () => CashflowPdfService.exportCashflowReport(
                        transactions: transactions,
                        totalIn: totalIn,
                        totalOut: totalOut,
                        pendingIn: pendingIn,
                        pendingOut: pendingOut,
                      ),
                      icon: const Icon(Icons.picture_as_pdf,
                          color: Colors.white, size: 16),
                      label: const Text('Exportar PDF',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _KpiCard(
                            title: 'Cobrado',
                            value: currencyFormatter.format(totalIn),
                            icon: Icons.download,
                            color: AppColors.green)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _KpiCard(
                            title: 'Pagado',
                            value: currencyFormatter.format(totalOut),
                            icon: Icons.upload,
                            color: AppColors.red)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _KpiCard(
                            title: 'CxC',
                            value: currencyFormatter.format(pendingIn),
                            icon: Icons.pending_actions,
                            color: AppColors.gold)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Últimas Transacciones',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: transactions.isEmpty
                        ? const Center(
                            child: Text('No hay transacciones registradas.',
                                style: TextStyle(color: AppColors.sub)))
                        : ListView.separated(
                            itemCount: transactions.length,
                            separatorBuilder: (_, __) => const Divider(
                                color: AppColors.border, height: 1),
                            itemBuilder: (context, index) {
                              final t = transactions[index];
                              Color iconColor = AppColors.sub;
                              IconData icon = Icons.circle;

                              if (t.type == 'IN') {
                                iconColor = AppColors.green;
                                icon = Icons.arrow_downward;
                              } else if (t.type == 'OUT') {
                                iconColor = AppColors.red;
                                icon = Icons.arrow_upward;
                              } else if (t.type == 'PENDING_IN') {
                                iconColor = AppColors.gold;
                                icon = Icons.hourglass_bottom;
                              } else if (t.type == 'PENDING_OUT') {
                                iconColor = Colors.purple;
                                icon = Icons.hourglass_top;
                              }

                              return ListTile(
                                leading: CircleAvatar(
                                    backgroundColor:
                                        iconColor.withValues(alpha: 0.2),
                                    child:
                                        Icon(icon, color: iconColor, size: 20)),
                                title: Text(t.description,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${t.reference} • ${DateFormat('dd/MMM/yy').format(t.date)}',
                                    style: const TextStyle(
                                        color: AppColors.sub, fontSize: 12)),
                                trailing: Text(
                                    currencyFormatter.format(t.amount),
                                    style: TextStyle(
                                        color: iconColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
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

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(color: AppColors.sub, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
