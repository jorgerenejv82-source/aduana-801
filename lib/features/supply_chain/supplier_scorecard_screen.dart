import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class SupplierScorecardScreen extends StatefulWidget {
  const SupplierScorecardScreen({super.key});

  @override
  State<SupplierScorecardScreen> createState() =>
      _SupplierScorecardScreenState();
}

class _SupplierScorecardScreenState extends State<SupplierScorecardScreen> {
  String _filter = 'Todos';

  String _getCountryFlag(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'USA':
        return '🇺🇸';
      case 'MEX':
        return '🇲🇽';
      case 'CHN':
        return '🇨🇳';
      case 'CAN':
        return '🇨🇦';
      case 'DEU':
        return '🇩🇪';
      default:
        return '🌐';
    }
  }

  void _showSupplierDetails(
      BuildContext context, Map<String, dynamic> supplierData, String id) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(supplierData['nombre']?.toString() ?? 'Sin nombre',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    const Text('Órdenes de Compra',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('purchase_orders')
                            .where('proveedorId', isEqualTo: id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.data!.docs.isEmpty) {
                            return const Text('Sin órdenes.');
                          }
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final po = snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                                return ListTile(
                                  title: Text('PO: ${po['folio'] ?? 'S/N'}'),
                                  subtitle:
                                      Text('Total: \$${po['total'] ?? '0.00'}'),
                                );
                              });
                        }),
                    const SizedBox(height: 16),
                    const Text('Historial de Embarques',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('embarques')
                            .where('proveedorId', isEqualTo: id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.data!.docs.isEmpty) {
                            return const Text('Sin embarques.');
                          }
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final embarque = snapshot.data!.docs[index]
                                    .data() as Map<String, dynamic>;
                                return ListTile(
                                  title: Text(
                                      'Embarque: ${embarque['guia'] ?? 'S/N'}'),
                                  subtitle: Text(
                                      'Status: ${embarque['status'] ?? 'N/A'}'),
                                );
                              });
                        }),
                    const SizedBox(height: 16),
                    const Text('Contacto',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(supplierData['contacto']?.toString() ?? 'N/A'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/suppliers/$id');
                          },
                          child: const Text('Ver en CRM'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context
                                .push('/supply_chain/po/nueva?supplierId=$id');
                          },
                          child: const Text('Crear PO'),
                        ),
                      ],
                    ),
                  ],
                );
              });
        });
  }

  void _showCompareDialog(BuildContext context) {
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Comparar 2 Proveedores'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Seleccione proveedores:'),
                const SizedBox(height: 8),
                // Dummy dropdowns for illustration
                DropdownButtonFormField<String>(
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('Proveedor A'))
                  ],
                  onChanged: (v) {},
                  decoration: const InputDecoration(labelText: 'Proveedor A'),
                ),
                DropdownButtonFormField<String>(
                  items: const [
                    DropdownMenuItem(value: '2', child: Text('Proveedor B'))
                  ],
                  onChanged: (v) {},
                  decoration: const InputDecoration(labelText: 'Proveedor B'),
                ),
                const SizedBox(height: 16),
                const Text('Análisis IA (Gemini):'),
                const Text(
                    'Basado en costo, riesgo, TMEC y tiempo de respuesta... (Simulado)',
                    style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'test_uid';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Scorecard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: Card(
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(children: [
                              Text('Total Activos'),
                              Text('24',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))
                            ])))),
                Expanded(
                    child: Card(
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(children: [
                              Text('Cumplimiento %'),
                              Text('89%',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))
                            ])))),
                Expanded(
                    child: Card(
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(children: [
                              Text('Con C.O. TMEC'),
                              Text('15',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))
                            ])))),
                Expanded(
                    child: Card(
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(children: [
                              Text('Alertas'),
                              Text('3',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red))
                            ])))),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todos', 'Con TMEC', 'Mejor TCO', 'Con Alertas']
                  .map((f) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FilterChip(
                          label: Text(f),
                          selected: _filter == f,
                          onSelected: (val) => setState(() => _filter = f),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('suppliers')
                      .where('uid', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error al cargar datos',
                              style: TextStyle(color: AppColors.sub)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('Sin datos disponibles',
                              style: TextStyle(color: AppColors.sub)));
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final id = docs[index].id;
                          final onTimePct =
                              (data['onTimePct'] as num?)?.toDouble() ?? 85.0;
                          final Color pctColor = onTimePct > 90
                              ? Colors.green
                              : (onTimePct > 70 ? Colors.orange : Colors.red);
                          final rating =
                              (data['rating'] as num?)?.toDouble() ?? 4.0;

                          if (_filter == 'Con TMEC' &&
                              data['tieneCertOrigen'] != true) {
                            return const SizedBox.shrink();
                          }
                          if (_filter == 'Con Alertas' && onTimePct >= 70) {
                            return const SizedBox.shrink();
                          }

                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: InkWell(
                              onTap: () =>
                                  _showSupplierDetails(context, data, id),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            '${data['nombre'] ?? 'Sin nombre'} ${_getCountryFlag(data['pais']?.toString() ?? '')}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        if (data['tieneCertOrigen'] == true)
                                          const Chip(
                                              label: Text('TMEC',
                                                  style:
                                                      TextStyle(fontSize: 10)),
                                              padding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 16),
                                        Text(rating.toStringAsFixed(1)),
                                      ],
                                    ),
                                    Text(
                                        'Lead Time promedio: ${data['leadTimeDias'] ?? 'N/A'} días'),
                                    Text(
                                        'Última operación: ${data['ultimaOperacion'] ?? 'N/A'}'),
                                    Row(
                                      children: [
                                        const Text('Cumplimiento: '),
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              value: onTimePct / 100,
                                              color: pctColor,
                                              strokeWidth: 3),
                                        ),
                                        Text(
                                            ' ${onTimePct.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                                color: pctColor,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const Text('Tendencia: ➡️ Estable'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  })),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCompareDialog(context),
        label: const Text('Comparar 2 Proveedores'),
        icon: const Icon(Icons.compare_arrows),
      ),
    );
  }
}
