import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const Color _bg = Color(0xFF0F172A);
const Color _card = Color(0xFF1E293B);
const Color _card2 = Color(0xFF334155);
const Color _text = Color(0xFFF8FAFC);
const Color _sub = Color(0xFF94A3B8);
const Color _border = Color(0xFF475569);
const Color _gold = Color(0xFFF59E0B);
const Color _green = AppColors.green;
const Color _blue = Color(0xFF3B82F6);
const Color _red = AppColors.red;
const Color _purple = Color(0xFF8B5CF6);

class CrossMatchGlosaScreen extends StatefulWidget {
  const CrossMatchGlosaScreen({super.key});

  @override
  State<CrossMatchGlosaScreen> createState() => _CrossMatchGlosaScreenState();
}

class _CrossMatchGlosaScreenState extends State<CrossMatchGlosaScreen> {
  Uint8List? _facturaBytes;
  String? _facturaName;
  String? _facturaMime;

  Uint8List? _pedimentoBytes;
  String? _pedimentoMime;

  final TextEditingController _pedimentoTextController =
      TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _glosaResult;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _pickFactura() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _facturaBytes = result.files.single.bytes;
          _facturaName = result.files.single.name;
          _facturaMime = _getMimeType(result.files.single.extension ?? '');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar factura: $e')),
        );
      }
    }
  }

  Future<void> _pickPedimento() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _pedimentoBytes = result.files.single.bytes;
          _pedimentoMime = _getMimeType(result.files.single.extension ?? '');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar pedimento: $e')),
        );
      }
    }
  }

  String _getMimeType(String ext) {
    if (ext.toLowerCase() == 'png') return 'image/png';
    return 'image/jpeg';
  }

  Future<void> _compararConIA() async {
    if (_facturaBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecciona una factura comercial.')),
      );
      return;
    }

    if (_pedimentoBytes == null &&
        _pedimentoTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, proporciona el pedimento (imagen o texto).')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _glosaResult = null;
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      const prompt = '''
Eres un experto en pre-glosa aduanal de Mexico. Compara la factura comercial con el pedimento/pre-validación M3 e identifica TODAS las discrepancias. 
Responde en JSON con la siguiente estructura:
{
  "discrepancias": [
    {
      "campo": "string",
      "valorFactura": "string",
      "valorPedimento": "string",
      "severidad": "CRITICA" | "ALTA" | "MEDIA" | "BAJA",
      "accion": "string"
    }
  ],
  "resumen": "string",
  "aprobado": boolean
}
''';

      final content = <Content>[];
      final parts = <Part>[TextPart(prompt)];

      parts.add(InlineDataPart(_facturaMime ?? 'image/jpeg', _facturaBytes!));

      if (_pedimentoBytes != null) {
        parts.add(
            InlineDataPart(_pedimentoMime ?? 'image/jpeg', _pedimentoBytes!));
      }
      if (_pedimentoTextController.text.trim().isNotEmpty) {
        parts.add(TextPart(
            'Texto del Pedimento/Pre-validación M3:\n${_pedimentoTextController.text}'));
      }

      content.add(Content.multi(parts));

      final response = await model.generateContent(content);
      final jsonResponse = response.text;

      if (jsonResponse != null) {
        final data = jsonDecode(jsonResponse) as Map<String, dynamic>;
        setState(() {
          _glosaResult = data;
        });
        await _saveToFirestore(data);
      } else {
        throw Exception('Respuesta vacía de la IA.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al analizar con IA: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveToFirestore(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado.');

      await _firestore.collection('glosas').add({
        'fecha': FieldValue.serverTimestamp(),
        'discrepancias': data['discrepancias'],
        'aprobado': data['aprobado'],
        'resumen': data['resumen'],
        'uid': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar en Firestore: $e')),
        );
      }
    }
  }

  Future<void> _exportPdf() async {
    if (_glosaResult == null) return;

    final doc = pw.Document();
    final aprobado = _glosaResult!['aprobado'] == true;
    final discrepancias =
        _glosaResult!['discrepancias'] as List<dynamic>? ?? [];

    doc.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Header(level: 0, child: pw.Text('Reporte de Pre-Glosa Aduanal')),
          pw.Paragraph(
              text: 'Resultado: ${aprobado ? 'Aprobado' : 'Rechazado'}'),
          pw.Paragraph(text: 'Resumen: ${_glosaResult!['resumen']}'),
          pw.SizedBox(height: 20),
          pw.Text('Discrepancias',
              style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Campo', 'Factura', 'Pedimento', 'Severidad', 'Acción'],
            data: discrepancias.map((d) {
              final row = d as Map<String, dynamic>;
              return <String>[
                row['campo']?.toString() ?? '',
                row['valorFactura']?.toString() ?? '',
                row['valorPedimento']?.toString() ?? '',
                row['severidad']?.toString() ?? '',
                row['accion']?.toString() ?? '',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICA':
        return _red;
      case 'ALTA':
        return _gold;
      case 'MEDIA':
        return _purple;
      case 'BAJA':
        return _blue;
      default:
        return _sub;
    }
  }

  @override
  @override
  void dispose() {
    _pedimentoTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Cross Match / Pre-Glosa'),
        backgroundColor: _card,
        foregroundColor: _text,
      ),
      body: Row(
        children: [
          // Main content
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildFacturaZone()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPedimentoZone()),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _buildFacturaZone(),
                          const SizedBox(height: 16),
                          _buildPedimentoZone(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _compararConIA,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: _text,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: _text))
                          : const Icon(Icons.compare_arrows),
                      label: Text(_isLoading
                          ? 'Analizando con IA...'
                          : 'Comparar con IA'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_glosaResult != null) _buildResultSection(),
                ],
              ),
            ),
          ),
          // History Sidebar
          Container(
            width: 300,
            color: _card,
            child: _buildHistorySection(),
          ),
        ],
      ),
    );
  }

  Widget _buildFacturaZone() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Factura Comercial (Imagen)',
              style: TextStyle(
                  color: _text, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickFactura,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _bg,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: _facturaBytes != null
                    ? Image.memory(_facturaBytes!, fit: BoxFit.contain)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file, color: _sub, size: 40),
                          SizedBox(height: 8),
                          Text('Clic para subir PNG/JPG',
                              style: TextStyle(color: _sub)),
                        ],
                      ),
              ),
            ),
          ),
          if (_facturaName != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_facturaName!,
                  style: const TextStyle(color: _sub, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildPedimentoZone() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pedimento / Pre-validación M3',
              style: TextStyle(
                  color: _text, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickPedimento,
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _bg,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: _pedimentoBytes != null
                    ? const Text('Imagen cargada',
                        style: TextStyle(color: _green))
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, color: _sub, size: 24),
                          SizedBox(height: 4),
                          Text('Subir imagen (opcional)',
                              style: TextStyle(color: _sub)),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('O pega el texto / XML:',
              style: TextStyle(color: _sub, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: _pedimentoTextController,
            maxLines: 5,
            style: const TextStyle(color: _text),
            decoration: InputDecoration(
              filled: true,
              fillColor: _bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _border),
              ),
              hintText: 'Pega aquí el contenido...',
              hintStyle: const TextStyle(color: _sub),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    final bool aprobado = (_glosaResult!['aprobado'] as bool?) ?? false;
    final String resumen = (_glosaResult!['resumen'] as String?) ?? '';
    final List<dynamic> discrepancias =
        (_glosaResult!['discrepancias'] as List<dynamic>?) ?? <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Resultados del Análisis',
                style: TextStyle(
                    color: _text, fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _exportPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: _card2,
                foregroundColor: _text,
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar PDF'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: aprobado
                ? _green.withValues(alpha: 0.2)
                : _red.withValues(alpha: 0.2),
            border: Border.all(color: aprobado ? _green : _red),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    aprobado ? Icons.check_circle : Icons.warning,
                    color: aprobado ? _green : _red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    aprobado ? 'APROBADO' : 'SE ENCONTRARON DISCREPANCIAS',
                    style: TextStyle(
                        color: aprobado ? _green : _red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(resumen, style: const TextStyle(color: _text)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (discrepancias.isNotEmpty) ...[
          const Text('Discrepancias Detalladas',
              style: TextStyle(
                  color: _text, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...discrepancias
              .map((d) => _buildDiscrepanciaCard(d as Map<String, dynamic>)),
        ]
      ],
    );
  }

  Widget _buildDiscrepanciaCard(Map<String, dynamic> data) {
    final severityColor =
        _getSeverityColor(data['severidad']?.toString() ?? '');

    return Card(
      color: _card2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: severityColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Campo: ${data['campo']}',
                  style: const TextStyle(
                      color: _text, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: severityColor),
                  ),
                  child: Text(
                    (data['severidad'] as String?) ?? 'DESC',
                    style: TextStyle(color: severityColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('En Factura:',
                          style: TextStyle(color: _sub, fontSize: 12)),
                      Text(data['valorFactura']?.toString() ?? '-',
                          style: const TextStyle(color: _text)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('En Pedimento:',
                          style: TextStyle(color: _sub, fontSize: 12)),
                      Text(data['valorPedimento']?.toString() ?? '-',
                          style: const TextStyle(color: _text)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Acción Recomendada:',
                style: TextStyle(color: _sub, fontSize: 12)),
            Text(data['accion']?.toString() ?? '-',
                style: const TextStyle(color: _gold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Historial Reciente',
              style: TextStyle(
                  color: _text, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const Divider(color: _border, height: 1),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('glosas')
                .where('uid', isEqualTo: _auth.currentUser?.uid)
                .orderBy('created_at', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: _blue));
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: _red)));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('No hay historial',
                        style: TextStyle(color: _sub)));
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: _border, height: 1),
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final bool aprobado = (data['aprobado'] as bool?) ?? false;
                  final ts = data['created_at'] as Timestamp?;
                  final dateStr = ts != null
                      ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year} ${ts.toDate().hour}:${ts.toDate().minute}'
                      : '';

                  return ListTile(
                    leading: Icon(
                      aprobado ? Icons.check_circle : Icons.warning,
                      color: aprobado ? _green : _red,
                    ),
                    title: Text(aprobado ? 'Aprobado' : 'Rechazado',
                        style: const TextStyle(color: _text)),
                    subtitle: Text(dateStr,
                        style: const TextStyle(color: _sub, fontSize: 12)),
                    onTap: () {
                      // Optionally load this historical data into view
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
