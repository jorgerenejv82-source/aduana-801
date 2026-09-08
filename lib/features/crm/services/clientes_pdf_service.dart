import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cliente_crm_model.dart';

class ClientesPdfService {
  static Future<void> exportDirectorioClientes(
      List<ClienteCrm> clientes) async {
    final pdf = pw.Document();
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Directorio de Clientes CRM (Exportador)',
                    style: const pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepPurple900)),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Fecha de emisin: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey600)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Cliente',
                  'Tax ID',
                  'Pas',
                  'Trminos',
                  'Lmite Crdito',
                  'Saldo Actual'
                ],
                headerStyle: const pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.deepPurple800),
                cellAlignment: pw.Alignment.centerLeft,
                data: clientes.map((c) {
                  return [
                    c.name,
                    c.taxId,
                    c.country,
                    c.paymentTerms,
                    fmt.format(c.creditLimit),
                    fmt.format(c.currentBalance),
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
      name: 'Directorio_Clientes_CRM.pdf',
    );
  }
}
