import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/supplier_model.dart';

class SupplierPdfService {
  static Future<void> exportSupplierDirectory(List<Supplier> suppliers) async {
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
                child: pw.Text('Directorio de Proveedores Internacionales',
                    style: const pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900)),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Fecha de emisin: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey600)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Nombre',
                  'Tax ID',
                  'Pas',
                  'Moneda',
                  'Trminos',
                  'Rating'
                ],
                headerStyle: const pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.indigo800),
                cellAlignment: pw.Alignment.centerLeft,
                data: suppliers.map((s) {
                  return [
                    s.name,
                    s.taxId,
                    s.country,
                    s.currency,
                    s.paymentTerms,
                    '${s.reliabilityScore}/10',
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
      name: 'Supplier_Directory.pdf',
    );
  }
}
