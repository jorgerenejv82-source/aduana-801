import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'models/freight_quote_model.dart';

class FreightQuotesScreen extends StatefulWidget {
  const FreightQuotesScreen({super.key});

  @override
  State<FreightQuotesScreen> createState() => _FreightQuotesScreenState();
}

class _FreightQuotesScreenState extends State<FreightQuotesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showNewQuoteDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    String forwarder = '';
    String originPort = '';
    String destPort = '';
    String mode = 'MARITIMO';
    double totalCost = 0.0;
    const String currency = 'USD';
    int transit = 0;

    showDialog<void>(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              title: const Text('Registrar Cotizacin de Flete',
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
                            _buildField(
                                'Forwarder (Agencia)', (v) => forwarder = v!),
                            _buildField('Puerto/Aeropuerto Origen',
                                (v) => originPort = v!),
                            _buildField('Puerto/Aeropuerto Destino',
                                (v) => destPort = v!),
                            DropdownButtonFormField<String>(
                              initialValue: mode,
                              dropdownColor: AppColors.bg,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                  labelText: 'Modalidad',
                                  labelStyle: TextStyle(color: AppColors.sub)),
                              items: ['MARITIMO', 'AEREO', 'TERRESTRE']
                                  .map((i) => DropdownMenuItem(
                                      value: i, child: Text(i)))
                                  .toList(),
                              onChanged: (v) => setState(() => mode = v!),
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                                'Costo Total',
                                (v) => totalCost =
                                    double.tryParse(v ?? '0') ?? 0.0,
                                isNum: true),
                            _buildField('Tiempo Trnsito (Das)',
                                (v) => transit = int.tryParse(v ?? '0') ?? 0,
                                isNum: true),
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

                    final quote = FreightQuote(
                      id: '',
                      forwarder: forwarder,
                      originPort: originPort,
                      destinationPort: destPort,
                      mode: mode,
                      totalCost: totalCost,
                      currency: currency,
                      transitTimeDays: transit,
                      isAwarded: false,
                      quoteDate: DateTime.now(),
                    );

                    await _firestore
                        .collection('freight_quotes')
                        .add(quote.toMap());
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

  Future<void> _adjudicar(String id) async {
    await _firestore
        .collection('freight_quotes')
        .doc(id)
        .update({'isAwarded': true});
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

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gold),
            onPressed: () => context.pop()),
        title: const Text('Comparador de Fletes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewQuoteDialog(context),
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('freight_quotes')
            .orderBy('quoteDate', descending: true)
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

          final quotes = snapshot.data?.docs
                  .map((d) => FreightQuote.fromMap(
                      d.data() as Map<String, dynamic>, d.id))
                  .toList() ??
              [];

          return quotes.isEmpty
              ? const Center(
                  child: Text('Agrega cotizaciones para comenzar a comparar.',
                      style: TextStyle(color: AppColors.sub)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: quotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final q = quotes[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: q.isAwarded
                            ? AppColors.green.withValues(alpha: 0.1)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: q.isAwarded
                                ? AppColors.green
                                : AppColors.border),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(q.forwarder,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              if (q.isAwarded)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: AppColors.green
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: const Text('ADJUDICADO',
                                      style: TextStyle(
                                          color: AppColors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                )
                              else
                                TextButton.icon(
                                  onPressed: () => _adjudicar(q.id),
                                  icon: const Icon(Icons.check_circle_outline,
                                      color: AppColors.blue, size: 16),
                                  label: const Text('Adjudicar',
                                      style: TextStyle(color: AppColors.blue)),
                                ),
                            ],
                          ),
                          const Divider(color: AppColors.border, height: 24),
                          Row(
                            children: [
                              Icon(
                                  q.mode == 'MARITIMO'
                                      ? Icons.directions_boat
                                      : q.mode == 'AEREO'
                                          ? Icons.flight
                                          : Icons.local_shipping,
                                  color: AppColors.gold,
                                  size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      '${q.originPort}  ${q.destinationPort}',
                                      style: const TextStyle(
                                          color: Colors.white))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Transit Time',
                                      style: TextStyle(
                                          color: AppColors.sub, fontSize: 12)),
                                  Text('${q.transitTimeDays} das',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Costo Total',
                                      style: TextStyle(
                                          color: AppColors.sub, fontSize: 12)),
                                  Text(
                                      '${fmt.format(q.totalCost)} ${q.currency}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
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
