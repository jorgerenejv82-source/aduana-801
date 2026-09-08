import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/nom_requirement_model.dart';

class NomsPdfService {
  static Future<void> exportChecklist(NomRequirement req) async {
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
                    'Checklist de Regulaciones No Arancelarias (RRNA)',
                    style: const pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900)),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey600)),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                    color: PdfColors.teal50,
                    border: pw.Border.all(color: PdfColors.teal)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Producto: ${req.productName}',
                        style: const pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Fraccin Arancelaria: ${req.hsCode}',
                        style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('NOMs de Cumplimiento Obligatorio:',
                  style: const pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red900)),
              pw.SizedBox(height: 5),
              if (req.requiredNoms.isEmpty)
                pw.Text('No aplica NOMs especiales.',
                    style: const pw.TextStyle(color: PdfColors.grey700))
              else
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:
                      req.requiredNoms.map((n) => pw.Text(' [ ] $n')).toList(),
                ),
              pw.SizedBox(height: 20),
              pw.Text('Permisos Especiales:',
                  style: const pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red900)),
              pw.SizedBox(height: 5),
              if (req.requiredPermits.isEmpty)
                pw.Text('No requiere permisos adicionales.',
                    style: const pw.TextStyle(color: PdfColors.grey700))
              else
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: req.requiredPermits
                      .map((p) => pw.Text(' [ ] $p'))
                      .toList(),
                ),
              pw.SizedBox(height: 20),
              pw.Text('Recomendaciones del Agente Aduanal:',
                  style: const pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text(req.recommendations,
                  style: const pw.TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'RRNA_Checklist_${req.hsCode}.pdf',
    );
  }
}
