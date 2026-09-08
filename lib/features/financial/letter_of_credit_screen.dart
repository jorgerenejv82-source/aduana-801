import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'models/lc_model.dart';

class LetterOfCreditScreen extends StatefulWidget {
  const LetterOfCreditScreen({super.key});

  @override
  State<LetterOfCreditScreen> createState() => _LetterOfCreditScreenState();
}

class _LetterOfCreditScreenState extends State<LetterOfCreditScreen> {
  void _showNewLcDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final firestore = FirebaseFirestore.instance;
    bool isLoading = false;

    String lcNumber = '';
    String issuingBank = '';
    String beneficiary = '';
    double amount = 0.0;
    const String currency = 'USD';
    String reqDocs = '';
    final DateTime expiryDate = DateTime.now().add(const Duration(days: 90));

    showDialog<void>(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              title: const Text('Registrar Carta de Crdito',
                  style: TextStyle(color: Colors.white)),
              content: isLoading
                  ? const SizedBox(
                      height: 200,
                      child: Center(
                          child:
                              CircularProgressIndicator(color: AppColors.blue)))
                  : SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildField('No. L/C', (v) => lcNumber = v!),
                            _buildField(
                                'Banco Emisor', (v) => issuingBank = v!),
                            _buildField(
                                'Beneficiario', (v) => beneficiary = v!),
                            _buildField(
                                'Monto',
                                (v) =>
                                    amount = double.tryParse(v ?? '0') ?? 0.0,
                                isNum: true),
                            _buildField(
                                'Documentos Requeridos (BL, Factura...)',
                                (v) => reqDocs = v!),
                          ],
                        ),
                      ),
                    ),
              actions: [
                TextButton(
                    onPressed: () => ctx.pop(),
                    child: const Text('Cancelar',
                        style: TextStyle(color: AppColors.sub))),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    formKey.currentState!.save();
                    setState(() => isLoading = true);

                    final lc = LetterOfCredit(
                      id: '',
                      lcNumber: lcNumber,
                      issuingBank: issuingBank,
                      beneficiary: beneficiary,
                      amount: amount,
                      currency: currency,
                      expiryDate: expiryDate,
                      requiredDocuments: reqDocs,
                    );

                    await firestore
                        .collection('letters_of_credit')
                        .add(lc.toMap());
                    if (ctx.mounted) ctx.pop();
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                  child: const Text('Guardar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          });
        });
  }

  Widget _buildField(String label, void Function(String?) onSaved,
      {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        keyboardType: isNum
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.sub, fontSize: 13),
          filled: true,
          fillColor: AppColors.bg,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
        ),
        validator: (v) => v!.isEmpty ? 'Requerido' : null,
        onSaved: onSaved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gold),
            onPressed: () => context.pop()),
        title: const Text('Cartas de Crdito (L/C)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewLcDialog(context),
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('letters_of_credit')
            .orderBy('expiryDate')
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

          final lcs = snapshot.data?.docs
                  .map((d) => LetterOfCredit.fromMap(
                      d.data() as Map<String, dynamic>, d.id))
                  .toList() ??
              [];

          return lcs.isEmpty
              ? const Center(
                  child: Text('No hay Cartas de Crdito activas.',
                      style: TextStyle(color: AppColors.sub)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lcs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final lc = lcs[index];
                    final daysLeft = lc.expiryDate.difference(now).inDays;

                    Color statusColor = AppColors.green;
                    if (daysLeft < 0) {
                      statusColor = AppColors.red;
                    } // Vencida
                    else if (daysLeft <= 15) {
                      statusColor = AppColors.gold;
                    } // Por vencer

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.5)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('L/C: ${lc.lcNumber}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  daysLeft < 0
                                      ? 'VENCIDA'
                                      : 'Faltan $daysLeft das',
                                  style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.border, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Beneficiario',
                                      style: TextStyle(
                                          color: AppColors.sub, fontSize: 12)),
                                  Text(lc.beneficiary,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Banco Emisor',
                                      style: TextStyle(
                                          color: AppColors.sub, fontSize: 12)),
                                  Text(lc.issuingBank,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(fmt.format(lc.amount),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(lc.currency,
                                  style: const TextStyle(
                                      color: AppColors.blue,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
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
