// ignore_for_file: prefer_const_constructors, unused_field
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfGeneratorService {
  static PdfGeneratorService? _instance;
  static PdfGeneratorService get instance =>
      _instance ??= PdfGeneratorService._();
  PdfGeneratorService._();

  // --- Colors ---
  static final _gold = PdfColor.fromHex('#F59E0B');
  static final _dark = PdfColor.fromHex('#0F172A');
  static final _sub = PdfColor.fromHex('#64748B');
  static final _red = PdfColor.fromHex('#EF4444');

  /// Download/print PDF in browser
  Future<void> downloadPdf(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  // ─────────────────────────────────────────────────────────────
  // ANEXO 24 REPORT
  // ─────────────────────────────────────────────────────────────
  Future<Uint8List> generateAnexo24Report({
    required List<Map<String, dynamic>> saldos,
    required String empresa,
  }) async {
    final pdf = pw.Document();
    final fmt = DateFormat('dd/MM/yyyy', 'es_MX');
    final now = DateTime.now();

    // Stats
    final total = saldos.length;
    final vencidos =
        saldos.where((s) => (s['diasRestantes'] as int? ?? 0) < 0).length;
    final riesgo = saldos.where((s) {
      final d = s['diasRestantes'] as int? ?? 0;
      return d >= 0 && d <= 30;
    }).length;
    final enRegla = total - vencidos - riesgo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _gold, width: 2))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('REPORTE ANEXO 24 — IMMEX',
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: _gold)),
                    pw.Text('Control de Temporalidad',
                        style: pw.TextStyle(fontSize: 11, color: _sub)),
                  ]),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(empresa,
                        style: const pw.TextStyle(
                            fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Generado: ${fmt.format(now)}',
                        style: pw.TextStyle(fontSize: 10, color: _sub)),
                  ]),
            ],
          ),
        ),
        build: (context) => [
          // KPI Summary
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(vertical: 16),
            child: pw.Row(
              children: [
                _kpiBox('Total Partidas', '$total', PdfColors.blue200),
                pw.SizedBox(width: 8),
                _kpiBox('En Regla', '$enRegla', PdfColors.green200),
                pw.SizedBox(width: 8),
                _kpiBox('En Riesgo', '$riesgo', PdfColors.amber200),
                pw.SizedBox(width: 8),
                _kpiBox('Vencidos', '$vencidos', PdfColors.red200),
              ],
            ),
          ),

          // Warning if vencidos > 0
          if (vencidos > 0)
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              margin: const pw.EdgeInsets.only(bottom: 12),
              decoration: pw.BoxDecoration(
                color: PdfColors.red50,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: _red),
              ),
              child: pw.Text(
                '⚠ ADVERTENCIA: $vencidos partida(s) vencida(s). Regularizar ante el SAT de inmediato.',
                style: pw.TextStyle(
                    color: _red, fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ),

          // Table
          pw.TableHelper.fromTextArray(
            headers: [
              'Pedimento IN',
              'Fracción',
              'Cant. Inicial',
              'Restante',
              'Entrada',
              'Vencimiento',
              'Días',
              'Estado'
            ],
            headerStyle: const pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
                color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: _dark),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 8),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
            data: saldos.map((s) {
              final dias = s['diasRestantes'] as int? ?? 0;
              final status = dias < 0
                  ? 'VENCIDO'
                  : dias <= 30
                      ? 'EN RIESGO'
                      : 'EN REGLA';
              return [
                s['pedimentoImportacion'] ?? '',
                s['fraccion'] ?? '',
                (s['cantidadInicial'] as num?)?.toStringAsFixed(0) ?? '0',
                (s['cantidadRestante'] as num?)?.toStringAsFixed(0) ?? '0',
                s['fechaEntrada'] != null
                    ? fmt.format(DateTime.parse(s['fechaEntrada'] as String))
                    : '',
                s['fechaVencimiento'] != null
                    ? fmt
                        .format(DateTime.parse(s['fechaVencimiento'] as String))
                    : '',
                '$dias',
                status,
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 24),
          pw.Text(
            'Este reporte es generado automáticamente por Aduanas 801. Para efectos oficiales ante el SAT, consulte al agente aduanal autorizado.',
            style: pw.TextStyle(fontSize: 8, color: _sub),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ─────────────────────────────────────────────────────────────
  // LANDED COST REPORT
  // ─────────────────────────────────────────────────────────────
  Future<Uint8List> generateLandedCostReport({
    required String producto,
    required double valorFactura,
    required double flete,
    required double seguro,
    required double valorAduana,
    required double arancel,
    required double iva,
    required double ieps,
    required double dta,
    required double totalImpuestos,
    required double costoTotal,
    required double tipoCambio,
  }) async {
    final pdf = pw.Document();
    final fmt = DateFormat('dd/MM/yyyy HH:mm', 'es_MX');
    final fmtNum = NumberFormat('#,##0.00', 'es_MX');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 12),
              decoration: pw.BoxDecoration(
                  border:
                      pw.Border(bottom: pw.BorderSide(color: _gold, width: 2))),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('LANDED COST',
                            style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: _gold)),
                        pw.Text('Costo Total de Importación',
                            style: pw.TextStyle(fontSize: 11, color: _sub)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(fmt.format(DateTime.now()),
                            style: pw.TextStyle(fontSize: 10, color: _sub)),
                        pw.Text('TC: \$${fmtNum.format(tipoCambio)} MXN/USD',
                            style: const pw.TextStyle(fontSize: 10)),
                      ]),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Product
            pw.Text('Producto: $producto',
                style: const pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),

            // Base values
            _sectionTitle('BASE DE CÁLCULO'),
            _row('Valor de Factura (USD)', '\$${fmtNum.format(valorFactura)}'),
            _row('Flete', '\$${fmtNum.format(flete)}'),
            _row('Seguro', '\$${fmtNum.format(seguro)}'),
            _rowBold(
                'Valor en Aduana (USD)', '\$${fmtNum.format(valorAduana)}'),
            pw.SizedBox(height: 12),

            // Taxes
            _sectionTitle('IMPUESTOS Y DERECHOS'),
            _row('Arancel', '\$${fmtNum.format(arancel)} MXN'),
            _row('IVA', '\$${fmtNum.format(iva)} MXN'),
            _row('IEPS', '\$${fmtNum.format(ieps)} MXN'),
            _row('DTA', '\$${fmtNum.format(dta)} MXN'),
            _rowBold(
                'Total Impuestos', '\$${fmtNum.format(totalImpuestos)} MXN'),
            pw.SizedBox(height: 12),

            // Total
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: _dark,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('COSTO TOTAL LANDED',
                      style: const pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                  pw.Text('\$${fmtNum.format(costoTotal)} MXN',
                      style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: _gold)),
                ],
              ),
            ),

            pw.Spacer(),
            pw.Text('Generado por Aduanas 801 · aduana-801.web.app',
                style: pw.TextStyle(fontSize: 8, color: _sub)),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  // ─── Helpers ───────────────────────────────────────────────

  pw.Widget _kpiBox(String label, String value, PdfColor color) => pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(value,
                  style: const pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        ),
      );

  pw.Widget _sectionTitle(String title) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(title,
            style: pw.TextStyle(
                fontSize: 10, fontWeight: pw.FontWeight.bold, color: _sub)),
      );

  pw.Widget _row(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      );

  pw.Widget _rowBold(String label, String value) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300))),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text(value,
                style: const pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );
}
