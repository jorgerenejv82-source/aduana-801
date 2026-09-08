import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cashflow_transaction_model.dart';

class CashflowPdfService {
  static Future<void> exportCashflowReport({
    required List<CashflowTransaction> transactions,
    required double totalIn,
    required double totalOut,
    required double pendingIn,
    required double pendingOut,
  }) async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Reporte de Flujo de Caja (Cashflow)',
                    style: const pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900)),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Fecha de emisin: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey600)),
              pw.SizedBox(height: 20),

              // KPIs
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildKpiBox('Cobrado (IN)', formatter.format(totalIn),
                      PdfColors.green700),
                  _buildKpiBox('Pagado (OUT)', formatter.format(totalOut),
                      PdfColors.red700),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildKpiBox('Cuentas por Cobrar',
                      formatter.format(pendingIn), PdfColors.orange700),
                  _buildKpiBox('Cuentas por Pagar',
                      formatter.format(pendingOut), PdfColors.purple700),
                ],
              ),
              pw.SizedBox(height: 30),

              pw.Text('Detalle de Transacciones:',
                  style: const pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              pw.TableHelper.fromTextArray(
                headers: ['Fecha', 'Ref', 'Tipo', 'Descripcin', 'Monto'],
                headerStyle: const pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.teal800),
                cellAlignment: pw.Alignment.centerLeft,
                data: transactions.map((t) {
                  return [
                    DateFormat('dd/MM/yy').format(t.date),
                    t.reference,
                    t.type,
                    t.description,
                    formatter.format(t.amount),
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
      name: 'Cashflow_Report.pdf',
    );
  }

  static pw.Widget _buildKpiBox(String title, String value, PdfColor color) {
    return pw.Container(
      width: 220,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style:
                  const pw.TextStyle(fontSize: 12, color: PdfColors.grey800)),
          pw.SizedBox(height: 4),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
