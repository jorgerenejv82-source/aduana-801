import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/tracking_event_model.dart';

class ShippingTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TrackingEvent>> getContainerEvents(String containerNumber) {
    return _firestore
        .collection('tracking_events')
        .where('containerNumber', isEqualTo: containerNumber)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrackingEvent.fromMap(doc.data(), doc.id))
            .toList());
  }

  static Future<void> exportTrackingReportPdf({
    required String containerNumber,
    required List<TrackingEvent> events,
  }) async {
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
                child: pw.Text('Reporte de Trazabilidad Logstica',
                    style: const pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900)),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Contenedor / B/L: $containerNumber',
                  style: const pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Fecha de emisin: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey600)),
              pw.SizedBox(height: 20),
              if (events.isEmpty)
                pw.Text('No hay eventos registrados para este contenedor.')
              else
                pw.ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final e = events[index];
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 10),
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(5)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(e.status,
                                  style: const pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.blue800)),
                              pw.Text(
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(e.timestamp),
                                  style: const pw.TextStyle(
                                      fontSize: 12, color: PdfColors.grey700)),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text('Ubicacin: ${e.location}',
                              style: const pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 2),
                          pw.Text(e.description,
                              style: const pw.TextStyle(
                                  fontSize: 11, color: PdfColors.grey800)),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Tracking_Report_$containerNumber.pdf',
    );
  }
}
