import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfInstructionService {
  /// Generates the "Carta de Instrucciones" legal document as a PDF.
  /// Uses strict types and real data layout as requested.
  static Future<void> generarYDescargarCarta({
    required String rfcImportador,
    required String nombreImportador,
    required String patenteAgente,
    required String tipoOperacion,
    required double valorMercancia,
    required List<Map<String, dynamic>> partidas,
  }) async {
    final pdf = pw.Document();
    final fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(48),
        build: (pw.Context context) {
          return [
            _buildHeader(fechaHoy),
            pw.SizedBox(height: 24),
            _buildBody(
              rfcImportador: rfcImportador,
              nombreImportador: nombreImportador,
              patenteAgente: patenteAgente,
              tipoOperacion: tipoOperacion,
              valorMercancia: valorMercancia,
            ),
            pw.SizedBox(height: 24),
            _buildPartidasTable(partidas),
            pw.SizedBox(height: 48),
            _buildFirmas(nombreImportador),
          ];
        },
      ),
    );

    // Usa Printing.shareOndevice o Printing.layoutPdf.
    // Para Flutter Web, esto lanzar automticamente la descarga/impresin del navegador.
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Carta_Instrucciones_${rfcImportador}_$fechaHoy.pdf',
    );
  }

  static pw.Widget _buildHeader(String fecha) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text('CARTA DE INSTRUCCIONES (ART. 59-A LA)',
            style: const pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 8),
        pw.Text('Fecha: $fecha', style: const pw.TextStyle(fontSize: 12)),
      ],
    );
  }

  static pw.Widget _buildBody({
    required String rfcImportador,
    required String nombreImportador,
    required String patenteAgente,
    required String tipoOperacion,
    required double valorMercancia,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Agente Aduanal: Patente $patenteAgente',
            style: const pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.SizedBox(height: 16),
        pw.Text(
          'Por medio de la presente, yo, en representacin de $nombreImportador con RFC $rfcImportador, '
          'otorgo instrucciones y encomiendo el despacho aduanero de mi mercanca al amparo del Artculo 59-A de la Ley Aduanera.',
          textAlign: pw.TextAlign.justify,
          style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
        ),
        pw.SizedBox(height: 12),
        pw.Text('Detalles de la Operacin:',
            style: const pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.Bullet(
            text: 'Tipo: $tipoOperacion',
            style: const pw.TextStyle(fontSize: 12)),
        pw.Bullet(
            text:
                'Valor Total Declarado: \$${valorMercancia.toStringAsFixed(2)} USD',
            style: const pw.TextStyle(fontSize: 12)),
      ],
    );
  }

  static pw.Widget _buildPartidasTable(List<Map<String, dynamic>> partidas) {
    if (partidas.isEmpty) {
      return pw.Text('No hay partidas registradas.',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey));
    }

    final headers = ['Fraccin', 'Descripcin', 'Cantidad', 'Valor Unit.'];
    final data = partidas.map((p) {
      return [
        p['fraccion']?.toString() ?? '',
        p['descripcion']?.toString() ?? '',
        p['cantidad']?.toString() ?? '0',
        '\$${p['valor']?.toString() ?? '0.00'}',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      headerStyle:
          const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellHeight: 20,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildFirmas(String nombreImportador) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            pw.Column(
              children: [
                pw.Container(width: 150, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 8),
                pw.Text('Firma del Importador',
                    style: const pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(nombreImportador,
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Column(
              children: [
                pw.Container(width: 150, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 8),
                pw.Text('Sello Digital (Acuse)',
                    style: const pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
