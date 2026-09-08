import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<Uint8List> generateCalculationReport(Map<String, dynamic> data) async {
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
                child: pw.Text('Aduanas 801 Enterprise'),
              ),
              pw.Text(
                  'Date: ${DateTime.now().toIso8601String().substring(0, 10)}'),
              pw.SizedBox(height: 20),
              pw.Text('Reporte de Calculo',
                  style: const pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  for (final key in data.keys)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(key,
                              style: const pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(data[key].toString()),
                        ),
                      ],
                    ),
                ],
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Text(
                  'Legal Disclaimer: This document is for informational purposes only.',
                  style:
                      const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generateSwarmReport(List<Map<String, String>> agentResults,
      String fraccion, String pais) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Aduanas 801 Enterprise'),
            ),
            pw.Text(
                'Date: ${DateTime.now().toIso8601String().substring(0, 10)}'),
            pw.SizedBox(height: 20),
            pw.Text('Reporte de Swarm AI',
                style: const pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Fraccion: $fraccion'),
            pw.Text('Origen: $pais'),
            pw.SizedBox(height: 20),
            for (final agent in agentResults)
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(agent['nombre'] ?? '',
                        style:
                            const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text(agent['resultado'] ?? ''),
                  ],
                ),
              ),
            pw.Divider(),
            pw.Text(
                'Legal Disclaimer: This document is for informational purposes only.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
