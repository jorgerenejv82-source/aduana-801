import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LandedCostPdfService {
  static Future<void> exportLandedCost({
    required double fob,
    required double flete,
    required double seguro,
    required double agenteAduanal,
    required double almacenaje,
    required double maniobras,
    required double igi,
    required double dta,
    required double iva,
    required double impuestosTotal,
    required double totalLandedCost,
  }) async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final baseGravable = fob + flete + seguro;
    final logisticaExtra = agenteAduanal + almacenaje + maniobras;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Cálculo de Landed Cost (Costo en Destino)',
                    style: const pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepPurple900)),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Fecha de cálculo: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey600)),
              pw.SizedBox(height: 30),
              _buildSection('1. Valor en Aduana (Base Gravable)', [
                _buildRow('Valor FOB (Mercancía)', formatter.format(fob)),
                _buildRow('Flete Internacional', formatter.format(flete)),
                _buildRow('Seguro', formatter.format(seguro)),
                _buildDivider(),
                _buildRow('Base Gravable Total', formatter.format(baseGravable),
                    isBold: true),
              ]),
              pw.SizedBox(height: 20),
              _buildSection('2. Impuestos y Contribuciones (Aduana)', [
                _buildRow('IGI (Arancel)', formatter.format(igi)),
                _buildRow(
                    'DTA (Derecho Trámite Aduanero)', formatter.format(dta)),
                _buildRow(
                    'IVA (Impuesto al Valor Agregado)', formatter.format(iva)),
                _buildDivider(),
                _buildRow('Total Impuestos', formatter.format(impuestosTotal),
                    isBold: true),
              ]),
              pw.SizedBox(height: 20),
              _buildSection('3. Gastos Logísticos y Despacho', [
                _buildRow('Honorarios Agente Aduanal',
                    formatter.format(agenteAduanal)),
                _buildRow('Almacenaje (Puerto/Aeropuerto)',
                    formatter.format(almacenaje)),
                _buildRow('Maniobras / DUM', formatter.format(maniobras)),
                _buildDivider(),
                _buildRow(
                    'Total Gastos Extra', formatter.format(logisticaExtra),
                    isBold: true),
              ]),
              pw.SizedBox(height: 30),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.deepPurple50,
                  border:
                      pw.Border.all(color: PdfColors.deepPurple800, width: 2),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL LANDED COST:',
                        style: const pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.deepPurple900)),
                    pw.Text(formatter.format(totalLandedCost),
                        style: const pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.deepPurple900)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Landed_Cost_Calculator.pdf',
    );
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: const pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.deepPurple800)),
        pw.SizedBox(height: 10),
        ...children,
      ],
    );
  }

  static pw.Widget _buildRow(String label, String value,
      {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontWeight:
                      isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontWeight:
                      isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  static pw.Widget _buildDivider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: PdfColors.grey400,
    );
  }
}
