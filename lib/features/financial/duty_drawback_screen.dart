import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:aduana_801/features/home/widgets/breadcrumb_nav.dart';

class DutyDrawbackScreen extends StatefulWidget {
  const DutyDrawbackScreen({super.key});

  @override
  State<DutyDrawbackScreen> createState() => _DutyDrawbackScreenState();
}

class _DutyDrawbackScreenState extends State<DutyDrawbackScreen> {
  final _descCtrl = TextEditingController();
  final _fracImportCtrl = TextEditingController();
  final _fobCtrl = TextEditingController();
  final _igiCtrl = TextEditingController();
  final _ivaCtrl = TextEditingController();
  final _pctCtrl = TextEditingController();
  final _fracExportCtrl = TextEditingController();
  DateTime _fechaImportacion = DateTime.now();

  bool _calculated = false;
  bool _enPlazo = false;
  double _igiRecuperable = 0;
  double _ivaRecuperable = 0;
  double _totalRecuperable = 0;

  void _calcular() {
    final _ = double.tryParse(_fobCtrl.text) ??
        0; // Not used directly in logic here, just stored
    final igi = double.tryParse(_igiCtrl.text) ?? 0;
    final iva = double.tryParse(_ivaCtrl.text) ?? 0;
    final pct = double.tryParse(_pctCtrl.text) ?? 0;

    final mesesTranscurridos =
        DateTime.now().difference(_fechaImportacion).inDays / 30;
    _enPlazo = mesesTranscurridos <= 12;

    final pctIncorporacion = pct / 100;
    _igiRecuperable = igi * pctIncorporacion;
    _ivaRecuperable = iva * pctIncorporacion;
    _totalRecuperable = _igiRecuperable + _ivaRecuperable;

    setState(() {
      _calculated = true;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaImportacion,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaImportacion = picked;
      });
    }
  }

  Future<void> _guardarHistorial() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'test_uid';
    await FirebaseFirestore.instance.collection('drawback_historial').add({
      'uid': uid,
      'descripcion': _descCtrl.text,
      'fraccionImportacion': _fracImportCtrl.text,
      'fob': double.tryParse(_fobCtrl.text) ?? 0,
      'igi': double.tryParse(_igiCtrl.text) ?? 0,
      'iva': double.tryParse(_ivaCtrl.text) ?? 0,
      'porcentajeIncorporacion': double.tryParse(_pctCtrl.text) ?? 0,
      'fraccionExportacion': _fracExportCtrl.text,
      'fechaImportacion': Timestamp.fromDate(_fechaImportacion),
      'totalRecuperable': _totalRecuperable,
      'timestamp': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Guardado en historial')));
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _fracImportCtrl.dispose();
    _fobCtrl.dispose();
    _igiCtrl.dispose();
    _ivaCtrl.dispose();
    _pctCtrl.dispose();
    _fracExportCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'test_uid';
    final formatoMoneda = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Duty Drawback Calculator'),
        bottom: BreadcrumbNav(items: [
          BreadcrumbItem(label: 'Inicio', route: '/'),
          BreadcrumbItem(label: 'Finanzas'),
          BreadcrumbItem(label: 'Duty Drawback'),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              color: Colors.blueAccent,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'El Duty Drawback permite recuperar hasta el 100% de los impuestos (IGI + IVA pagado en importación) de insumos que se incorporaron a productos exportados. Art. 121 Ley Aduanera / Art. 303 TMEC.',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Descripción del insumo importado')),
                    TextField(
                        controller: _fracImportCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Fracción arancelaria de importación')),
                    TextField(
                        controller: _fobCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Valor FOB de importación (USD)'),
                        keyboardType: TextInputType.number),
                    TextField(
                        controller: _igiCtrl,
                        decoration: const InputDecoration(
                            labelText: 'IGI pagado (MXN)'),
                        keyboardType: TextInputType.number),
                    TextField(
                        controller: _ivaCtrl,
                        decoration: const InputDecoration(
                            labelText: 'IVA pagado en importación (MXN)'),
                        keyboardType: TextInputType.number),
                    TextField(
                        controller: _pctCtrl,
                        decoration: const InputDecoration(
                            labelText:
                                'Porcentaje de incorporación al producto exportado (%)',
                            hintText: 'ej. 85'),
                        keyboardType: TextInputType.number),
                    TextField(
                        controller: _fracExportCtrl,
                        decoration: const InputDecoration(
                            labelText:
                                'Fracción arancelaria del producto exportado')),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                            'Fecha de importación: ${formatoFecha.format(_fechaImportacion)}'),
                        const Spacer(),
                        ElevatedButton(
                            onPressed: () => _selectDate(context),
                            child: const Text('Seleccionar')),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16)),
                        onPressed: _calcular,
                        child: const Text('CALCULAR DRAWBACK',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_calculated) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_enPlazo ? Icons.check_circle : Icons.cancel,
                              color: _enPlazo ? Colors.green : Colors.red,
                              size: 28),
                          const SizedBox(width: 8),
                          Text(_enPlazo ? 'EN PLAZO' : 'FUERA DE PLAZO',
                              style: TextStyle(
                                  color: _enPlazo ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          const Text(' (12 meses desde importación)'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                          'IGI Recuperable: ${formatoMoneda.format(_igiRecuperable)} MXN',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(
                          'IVA Recuperable: ${formatoMoneda.format(_ivaRecuperable)} MXN',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                          'TOTAL RECUPERABLE: ${formatoMoneda.format(_totalRecuperable)} MXN',
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 24)),
                      const SizedBox(height: 8),
                      Text(
                          'Plazo válido hasta: ${formatoFecha.format(_fechaImportacion.add(const Duration(days: 365)))}'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.amber.shade100,
                        child: const Text(
                            'El trámite de Drawback debe realizarse ante el SAT mediante pedimento de exportación con clave A9. Se recomienda contar con el pedimento de importación original y la factura de exportación.',
                            style: TextStyle(color: Colors.brown)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                              onPressed: _guardarHistorial,
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar en Historial')),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Generando reporte con IA...')));
                            },
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Generar Reporte'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Historial (Últimos 10)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('drawback_historial')
                    .where('uid', isEqualTo: uid)
                    .orderBy('timestamp', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error al cargar historial: ${snapshot.error}',
                            style: const TextStyle(
                                color: AppColors.sub, fontSize: 12)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Text('Sin historial');
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        return ListTile(
                          title:
                              Text((data['descripcion'] as String?) ?? 'S/D'),
                          subtitle:
                              Text('Fracción: ${data['fraccionImportacion']}'),
                          trailing: Text(
                              formatoMoneda
                                  .format(data['totalRecuperable'] ?? 0),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}
