import 'package:flutter/material.dart';
import '../../../services/normativa_service.dart';
import 'package:aduana_801/features/home/widgets/breadcrumb_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class TcoComparatorScreen extends StatefulWidget {
  const TcoComparatorScreen({super.key});

  @override
  State<TcoComparatorScreen> createState() => _TcoComparatorScreenState();
}

class _SupplierEntry {
  final nameCtrl = TextEditingController();
  final paisCtrl = TextEditingController();
  final precioFobCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController(text: '1000');
  final fleteCtrl = TextEditingController();
  final seguroCtrl = TextEditingController();
  final arancelPctCtrl = TextEditingController(text: '5.0');
  bool tieneTmec = false;
  final leadTimeCtrl = TextEditingController(text: '30');
  final inspeccionCtrl = TextEditingController(text: '0');
  final almacenamientoCtrl = TextEditingController(text: '0');
  final rechazoPctCtrl = TextEditingController(text: '2.0');

  void dispose() {
    nameCtrl.dispose();
    paisCtrl.dispose();
    precioFobCtrl.dispose();
    cantidadCtrl.dispose();
    fleteCtrl.dispose();
    seguroCtrl.dispose();
    arancelPctCtrl.dispose();
    leadTimeCtrl.dispose();
    inspeccionCtrl.dispose();
    almacenamientoCtrl.dispose();
    rechazoPctCtrl.dispose();
  }
}

class _TcoComparatorScreenState extends State<TcoComparatorScreen> {
  final List<_SupplierEntry> _suppliers = [];
  bool _showResults = false;

  @override
  void dispose() {
    for (final s in _suppliers) {
      s.dispose();
    }
    super.dispose();
  }

  void _addSupplier() {
    if (_suppliers.length < 3) {
      setState(() {
        _suppliers.add(_SupplierEntry());
      });
    }
  }

  void _removeSupplier(int index) {
    setState(() {
      _suppliers[index].dispose();
      _suppliers.removeAt(index);
      if (_suppliers.isEmpty) _showResults = false;
    });
  }

  double calcularTCO(_SupplierEntry s) {
    final qty = double.tryParse(s.cantidadCtrl.text) ?? 0;
    final fob = (double.tryParse(s.precioFobCtrl.text) ?? 0) * qty;
    final flete = double.tryParse(s.fleteCtrl.text) ?? 0;
    final seguro = double.tryParse(s.seguroCtrl.text) ?? 0;
    final valorAduana = fob + flete + seguro;
    final igi = s.tieneTmec
        ? 0.0
        : valorAduana * (double.tryParse(s.arancelPctCtrl.text) ?? 0) / 100;
    final dta = NormativaService()
        .calcularDTA(valorAduana, s.tieneTmec ? 'IMMEX' : 'Importacion');
    final inspeccion = double.tryParse(s.inspeccionCtrl.text) ?? 0;
    final merma = fob * (double.tryParse(s.rechazoPctCtrl.text) ?? 0) / 100;
    final leadTime = int.tryParse(s.leadTimeCtrl.text) ?? 30;
    final almacenamiento = double.tryParse(s.almacenamientoCtrl.text) ?? 0;
    final capitalCost = valorAduana * 0.01 * (leadTime / 30);

    return fob +
        flete +
        seguro +
        igi +
        dta +
        inspeccion +
        merma +
        almacenamiento +
        capitalCost;
  }

  double calcularTCOUnitario(_SupplierEntry s) {
    final qty = double.tryParse(s.cantidadCtrl.text) ?? 1;
    return calcularTCO(s) / (qty > 0 ? qty : 1);
  }

  int _getBestSupplierIndex() {
    int bestIndex = -1;
    double minTCO = double.infinity;
    for (int i = 0; i < _suppliers.length; i++) {
      final tco = calcularTCO(_suppliers[i]);
      if (tco < minTCO) {
        minTCO = tco;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de Costo Total de Propiedad (TCO)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        bottom: BreadcrumbNav(items: [
          BreadcrumbItem(label: 'Inicio', route: '/'),
          BreadcrumbItem(label: 'Proveedores'),
          BreadcrumbItem(label: 'Comparador TCO'),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '¿Qué proveedor te sale más barato puesto en planta? Compara hasta 3 proveedores con todos los costos reales.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (_suppliers.length < 3)
              ElevatedButton.icon(
                onPressed: _addSupplier,
                icon: const Icon(Icons.add),
                label: const Text('Añadir Proveedor'),
              ),
            const SizedBox(height: 20),
            ..._suppliers.asMap().entries.map((entry) {
              final int index = entry.key;
              final _SupplierEntry supplier = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Proveedor ${index + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeSupplier(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          TextField(
                              controller: supplier.nameCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Nombre del proveedor')),
                          TextField(
                              controller: supplier.paisCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'País de origen')),
                          TextField(
                              controller: supplier.precioFobCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Precio unitario FOB (USD)')),
                          TextField(
                              controller: supplier.cantidadCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Cantidad de unidades')),
                          TextField(
                              controller: supplier.fleteCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Flete total estimado (USD)')),
                          TextField(
                              controller: supplier.seguroCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Seguro (USD)')),
                          TextField(
                              controller: supplier.arancelPctCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Arancel IGI (%)')),
                          SwitchListTile(
                            title: const Text('Tiene C.O. TMEC'),
                            value: supplier.tieneTmec,
                            onChanged: (val) {
                              setState(() {
                                supplier.tieneTmec = val;
                                if (val) supplier.arancelPctCtrl.text = '0';
                              });
                            },
                          ),
                          TextField(
                              controller: supplier.leadTimeCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Lead time (días)')),
                          TextField(
                              controller: supplier.inspeccionCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Costo inspección (USD)')),
                          TextField(
                              controller: supplier.almacenamientoCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Almacenamiento (USD/mes)')),
                          TextField(
                              controller: supplier.rechazoPctCtrl,
                              decoration: const InputDecoration(
                                  labelText: '% Merma estimado')),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (_suppliers.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showResults = true;
                  });
                },
                child: const Text('CALCULAR TCO'),
              ),
            if (_showResults && _suppliers.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text('Resultados',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildResultsTable(),
              const SizedBox(height: 16),
              _buildBarChart(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Análisis con Gemini próximamente...')));
                },
                icon: const Icon(Icons.analytics),
                label: const Text('Análisis de IA (Gemini)'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Guardado en la nube en desarrollo...')));
                },
                icon: const Icon(Icons.save),
                label: const Text('Guardar Análisis'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.green),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTable() {
    final int bestIndex = _getBestSupplierIndex();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Concepto')),
          ..._suppliers.asMap().entries.map((e) {
            final String suffix = e.key == bestIndex ? ' 🏆 MEJOR TCO' : '';
            return DataColumn(
                label: Text(
                    '${e.value.nameCtrl.text.isEmpty ? 'Prov ${e.key + 1}' : e.value.nameCtrl.text}$suffix'));
          }),
        ],
        rows: [
          DataRow(
            cells: [
              const DataCell(Text('Costo FOB total')),
              ..._suppliers.map((s) {
                final qty = double.tryParse(s.cantidadCtrl.text) ?? 0;
                final fob = (double.tryParse(s.precioFobCtrl.text) ?? 0) * qty;
                return DataCell(Text('\$${fob.toStringAsFixed(2)}'));
              }),
            ],
          ),
          DataRow(
            cells: [
              const DataCell(Text('Flete + Seguro')),
              ..._suppliers.map((s) {
                final flete = double.tryParse(s.fleteCtrl.text) ?? 0;
                final seguro = double.tryParse(s.seguroCtrl.text) ?? 0;
                return DataCell(
                    Text('\$${(flete + seguro).toStringAsFixed(2)}'));
              }),
            ],
          ),
          DataRow(
            cells: [
              const DataCell(Text('IGI + DTA')),
              ..._suppliers.map((s) {
                final qty = double.tryParse(s.cantidadCtrl.text) ?? 0;
                final fob = (double.tryParse(s.precioFobCtrl.text) ?? 0) * qty;
                final flete = double.tryParse(s.fleteCtrl.text) ?? 0;
                final seguro = double.tryParse(s.seguroCtrl.text) ?? 0;
                final valorAduana = fob + flete + seguro;
                final igi = s.tieneTmec
                    ? 0.0
                    : valorAduana *
                        (double.tryParse(s.arancelPctCtrl.text) ?? 0) /
                        100;
                final dta = NormativaService().calcularDTA(
                    valorAduana, s.tieneTmec ? 'IMMEX' : 'Importacion');
                return DataCell(Text('\$${(igi + dta).toStringAsFixed(2)}'));
              }),
            ],
          ),
          DataRow(
            cells: [
              const DataCell(Text('Costo calidad/merma')),
              ..._suppliers.map((s) {
                final qty = double.tryParse(s.cantidadCtrl.text) ?? 0;
                final fob = (double.tryParse(s.precioFobCtrl.text) ?? 0) * qty;
                final merma =
                    fob * (double.tryParse(s.rechazoPctCtrl.text) ?? 0) / 100;
                return DataCell(Text('\$${merma.toStringAsFixed(2)}'));
              }),
            ],
          ),
          DataRow(
            cells: [
              const DataCell(Text('Costo capital (lead time)')),
              ..._suppliers.map((s) {
                final qty = double.tryParse(s.cantidadCtrl.text) ?? 0;
                final fob = (double.tryParse(s.precioFobCtrl.text) ?? 0) * qty;
                final flete = double.tryParse(s.fleteCtrl.text) ?? 0;
                final seguro = double.tryParse(s.seguroCtrl.text) ?? 0;
                final valorAduana = fob + flete + seguro;
                final leadTime = int.tryParse(s.leadTimeCtrl.text) ?? 30;
                final capitalCost = valorAduana * 0.01 * (leadTime / 30);
                return DataCell(Text('\$${capitalCost.toStringAsFixed(2)}'));
              }),
            ],
          ),
          DataRow(
            cells: [
              const DataCell(Text('TCO TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              ..._suppliers.map((s) => DataCell(Text(
                  '\$${calcularTCO(s).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
          DataRow(
            cells: [
              const DataCell(Text('TCO por unidad',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              ..._suppliers.map((s) => DataCell(Text(
                  '\$${calcularTCOUnitario(s).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
          DataRow(
            cells: [
              const DataCell(Text('Lead time')),
              ..._suppliers
                  .map((s) => DataCell(Text('${s.leadTimeCtrl.text} días'))),
            ],
          ),
          DataRow(
            cells: [
              const DataCell(Text('TMEC')),
              ..._suppliers
                  .map((s) => DataCell(Text(s.tieneTmec ? 'Sí' : 'No'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    double maxTco = 0;
    for (final s in _suppliers) {
      final tco = calcularTCO(s);
      if (tco > maxTco) maxTco = tco;
    }
    if (maxTco == 0) maxTco = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _suppliers.asMap().entries.map((e) {
        final tco = calcularTCO(e.value);
        final widthFactor = tco / maxTco;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                    e.value.nameCtrl.text.isEmpty
                        ? 'Prov ${e.key + 1}'
                        : e.value.nameCtrl.text,
                    overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widthFactor.clamp(0.0, 1.0),
                  child: Container(
                    height: 20,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('\$${tco.toStringAsFixed(0)}'),
            ],
          ),
        );
      }).toList(),
    );
  }
}
