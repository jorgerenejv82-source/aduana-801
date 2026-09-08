import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:aduana_801/features/widgets/beginner_tip_widget.dart';

class InvoiceVsPedimentoScreen extends StatefulWidget {
  const InvoiceVsPedimentoScreen({super.key});

  @override
  State<InvoiceVsPedimentoScreen> createState() =>
      _InvoiceVsPedimentoScreenState();
}

class _InvoiceVsPedimentoScreenState extends State<InvoiceVsPedimentoScreen> {
  final _pedimentoCtrl = TextEditingController();
  final _facturaCtrl = TextEditingController();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _discrepancies = [];

  @override
  void dispose() {
    _pedimentoCtrl.dispose();
    _facturaCtrl.dispose();
    super.dispose();
  }

  /// Busca ambos documentos en Firestore (colecciones `pedimentos` y `facturas`)
  /// y cruza campo por campo. Si alguno no existe en la base de datos, lanza
  /// un mensaje explícito al usuario — nunca simula datos.
  Future<void> _conciliar() async {
    final pedId = _pedimentoCtrl.text.trim();
    final facId = _facturaCtrl.text.trim();

    if (pedId.isEmpty || facId.isEmpty) {
      setState(() => _error = 'Ingresa el No. de Pedimento y la Factura.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _discrepancies = [];
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // Buscar en las colecciones reales de Firestore
      final pedSnap = await firestore
          .collection('pedimentos')
          .where('numero', isEqualTo: pedId)
          .limit(1)
          .get();

      final facSnap = await firestore
          .collection('facturas')
          .where('numero', isEqualTo: facId)
          .limit(1)
          .get();

      if (pedSnap.docs.isEmpty) {
        setState(() {
          _error =
              'Pedimento "$pedId" no encontrado en la base de datos. Verifica el número o regístralo primero.';
          _isLoading = false;
        });
        return;
      }

      if (facSnap.docs.isEmpty) {
        setState(() {
          _error =
              'Factura "$facId" no encontrada en la base de datos. Verifica el número o regístrala primero.';
          _isLoading = false;
        });
        return;
      }

      final ped = pedSnap.docs.first.data();
      final fac = facSnap.docs.first.data();

      // Cruce real campo por campo
      final results = <Map<String, dynamic>>[];

      void check(String campo, dynamic vFac, dynamic vPed) {
        final fStr = vFac?.toString() ?? '';
        final pStr = vPed?.toString() ?? '';

        bool match = false;
        String fDisplay = fStr;
        String pDisplay = pStr;

        final fNum = double.tryParse(fStr);
        final pNum = double.tryParse(pStr);

        if (fNum != null && pNum != null) {
          match = (fNum - pNum).abs() <= 0.001;
          fDisplay = fNum.toStringAsFixed(2);
          pDisplay = pNum.toStringAsFixed(2);
        } else {
          match = fStr.trim().toLowerCase() == pStr.trim().toLowerCase();
        }

        results.add({
          'campo': campo,
          'factura': fDisplay,
          'pedimento': pDisplay,
          'match': match
        });
      }

      check('Valor Total (USD)', fac['valorTotal'], ped['valorTotal']);
      check('Cantidad (Piezas)', fac['cantidad'], ped['cantidad']);
      check('Descripción de Mercancía', fac['descripcion'], ped['descripcion']);
      check('Peso Bruto (KG)', fac['pesoBruto'], ped['pesoBruto']);
      check('País de Origen', fac['paisOrigen'], ped['paisOrigen']);
      check('Incoterm', fac['incoterm'], ped['incoterm']);

      setState(() {
        _discrepancies = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al consultar Firestore: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _exportarPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Reporte de Conciliación: Factura vs Pedimento',
                  style: const pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo900),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Pedimento: ${_pedimentoCtrl.text}',
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Factura Comercial: ${_facturaCtrl.text}',
                  style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Campo Auditado',
                  'Dato en Factura',
                  'Dato en Pedimento',
                  'Estado'
                ],
                headerStyle: const pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.indigo800),
                cellAlignment: pw.Alignment.centerLeft,
                data: _discrepancies.map((d) {
                  return [
                    d['campo'].toString(),
                    d['factura'].toString(),
                    d['pedimento'].toString(),
                    d['match'] as bool ? 'COINCIDE' : 'DISCREPANCIA',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Conciliacion_${_pedimentoCtrl.text}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Row(children: [
          Text('Conciliación Automática',
              style: TextStyle(color: Colors.white)),
          BeginnerTipWidget(
              term: 'Conciliación',
              explanation:
                  'Comparar campo por campo la información del pedimento contra la factura comercial para detectar discrepancias y evitar multas.')
        ]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Auditoría Factura vs Pedimento',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa el número de Pedimento y la Factura para cruzar los datos declarados contra los facturados en Firestore.',
              style: TextStyle(color: AppColors.sub, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pedimentoCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'No. Pedimento (15 dígitos)',
                      labelStyle: TextStyle(color: AppColors.sub),
                      filled: true,
                      fillColor: AppColors.card,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _facturaCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'No. Factura Comercial',
                      labelStyle: TextStyle(color: AppColors.sub),
                      filled: true,
                      fillColor: AppColors.card,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _conciliar,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text('Auditar',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                ),
                child: Text(_error!,
                    style: const TextStyle(
                        color: AppColors.red, fontWeight: FontWeight.bold)),
              ),
            if (_isLoading)
              const Center(
                  child: CircularProgressIndicator(color: AppColors.blue)),
            if (!_isLoading && _discrepancies.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_discrepancies.where((d) => !(d['match'] as bool)).length} discrepancias encontradas',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _exportarPdf,
                          icon: const Icon(Icons.picture_as_pdf,
                              color: Colors.white, size: 16),
                          label: const Text('Exportar Reporte',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _discrepancies.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: AppColors.border, height: 1),
                          itemBuilder: (context, index) {
                            final d = _discrepancies[index];
                            final match = d['match'] as bool;
                            return ListTile(
                              leading: Icon(
                                match
                                    ? Icons.check_circle
                                    : Icons.warning_rounded,
                                color: match ? AppColors.green : AppColors.red,
                              ),
                              title: Text(d['campo'].toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                'Factura: ${d['factura']}\nPedimento: ${d['pedimento']}',
                                style: const TextStyle(
                                    color: AppColors.sub, height: 1.5),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      (match ? AppColors.green : AppColors.red)
                                          .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  match ? 'COINCIDE' : 'DISCREPANCIA',
                                  style: TextStyle(
                                    color:
                                        match ? AppColors.green : AppColors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
