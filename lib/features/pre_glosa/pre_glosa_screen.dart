import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Colors based on rules
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

class PreGlosaScreen extends StatefulWidget {
  const PreGlosaScreen({super.key});

  @override
  State<PreGlosaScreen> createState() => _PreGlosaScreenState();
}

class _PreGlosaScreenState extends State<PreGlosaScreen> {
  PlatformFile? _facturaFile;
  PlatformFile? _packingListFile;
  PlatformFile? _blAwbFile;
  final TextEditingController _pedimentoController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _results;

  Future<void> _pickFile(void Function(PlatformFile?) onPicked) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          onPicked(result.files.first);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al seleccionar archivo: $e',
                  style: const TextStyle(color: _text)),
              backgroundColor: _red),
        );
      }
    }
  }

  Future<void> _analyzeWithAI() async {
    if (_facturaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La Factura Comercial es obligatoria',
                style: TextStyle(color: _text)),
            backgroundColor: _red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _results = null;
    });

    try {
      // ignore: deprecated_member_use
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
          'Eres un experto verificador de pre-glosa aduanal de Mexico con 20 años de experiencia. '
          'Analiza TODOS los documentos proporcionados y realiza una pre-glosa completa. '
          'Verifica: 1) Datos del exportador/importador correctos y consistentes entre documentos '
          '2) Descripcion de mercancia coincide en todos los docs '
          '3) Valor correcto y mismo en todos (factura vs pedimento) '
          '4) Incoterm declarado consistente 5) Pesos y cantidades coinciden '
          '6) Fraccion arancelaria correcta para la mercancia descrita 7) Pais de origen correcto '
          '8) Datos del transporte (BL/AWB) consistentes. '
          'Responde estrictamente en JSON: {"aprobado": bool, "puntaje": número (0-100), "verificaciones": [{"area": string, "estado": "ok"|"advertencia"|"error", "detalle": string, "accion": string}], "fraccionSugerida": string, "observacionesGenerales": string}',
        ),
      );

      final List<Part> parts = [];

      // Add text input
      if (_pedimentoController.text.isNotEmpty) {
        parts.add(TextPart('Draft Pedimento:\n${_pedimentoController.text}'));
      }

      // Add files
      String getMimeType(String? extension) {
        if (extension == 'pdf') return 'application/pdf';
        return 'image/${extension ?? 'jpeg'}';
      }

      if (_facturaFile?.bytes != null) {
        parts.add(InlineDataPart(
            getMimeType(_facturaFile!.extension), _facturaFile!.bytes!));
      }
      if (_packingListFile?.bytes != null) {
        parts.add(InlineDataPart(getMimeType(_packingListFile!.extension),
            _packingListFile!.bytes!));
      }
      if (_blAwbFile?.bytes != null) {
        parts.add(InlineDataPart(
            getMimeType(_blAwbFile!.extension), _blAwbFile!.bytes!));
      }

      final response = await model.generateContent([Content.multi(parts)]);

      String responseText = response.text ?? '{}';

      // Clean up markdown if present
      if (responseText.contains('```json')) {
        responseText = responseText.split('```json')[1].split('```')[0].trim();
      } else if (responseText.contains('```')) {
        responseText = responseText.split('```')[1].split('```')[0].trim();
      }

      final data = jsonDecode(responseText) as Map<String, dynamic>;

      setState(() {
        _results = data;
      });

      await _saveToFirestore(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error en análisis IA: $e',
                  style: const TextStyle(color: _text)),
              backgroundColor: _red),
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      await FirebaseFirestore.instance.collection('pre_glosas').add({
        ...data,
        'uid': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar en historial: $e',
                  style: const TextStyle(color: _text)),
              backgroundColor: _red),
        );
      }
    }
  }

  Future<void> _exportPdf() async {
    if (_results == null) return;

    final doc = pw.Document();

    final aprobado = _results!['aprobado'] as bool? ?? false;
    final puntaje = _results!['puntaje'] as num? ?? 0;
    final verificaciones =
        (_results!['verificaciones'] as List<dynamic>?) ?? [];
    final fraccion = _results!['fraccionSugerida'] as String? ?? 'N/A';
    final observaciones =
        _results!['observacionesGenerales'] as String? ?? 'N/A';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'Reporte de Pre-Glosa Aduanal'),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Puntaje: $puntaje/100',
                      style: const pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    aprobado
                        ? 'APROBADO PARA DESPACHO'
                        : 'REQUIERE CORRECCIONES',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: aprobado ? PdfColors.green : PdfColors.red,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Fracción Sugerida: $fraccion',
                  style: const pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Observaciones Generales:',
                  style: const pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(observaciones),
              pw.SizedBox(height: 20),
              pw.Text('Verificaciones:',
                  style: const pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...verificaciones.map((v) {
                final vMap = v as Map<String, dynamic>;
                final area = vMap['area'] as String? ?? '';
                final estado = vMap['estado'] as String? ?? '';
                final detalle = vMap['detalle'] as String? ?? '';
                final accion = vMap['accion'] as String? ?? '';
                return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey)),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Área: $area ($estado)',
                            style: const pw.TextStyle(
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Detalle: $detalle'),
                        pw.Text('Acción: $accion'),
                      ],
                    ));
              }),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  Widget _buildFilePicker(
      String label, PlatformFile? file, void Function(PlatformFile?) onPicked,
      {bool isRequired = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label + (isRequired ? ' *' : ''),
                  style: TextStyle(
                      color: isRequired ? _gold : _text,
                      fontWeight: FontWeight.bold),
                ),
                if (file != null) ...[
                  const SizedBox(height: 4),
                  Text(file.name,
                      style: const TextStyle(color: _sub, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ] else ...[
                  const SizedBox(height: 4),
                  const Text('No se ha seleccionado archivo',
                      style: TextStyle(color: _sub, fontSize: 12)),
                ]
              ],
            ),
          ),
          IconButton(
            icon: Icon(file != null ? Icons.check_circle : Icons.upload_file,
                color: file != null ? _green : _blue),
            onPressed: () => _pickFile(onPicked),
          ),
          if (file != null)
            IconButton(
              icon: const Icon(Icons.close, color: _red),
              onPressed: () => setState(() => onPicked(null)),
            )
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_results == null) {
      return const Center(
          child: Text('No hay resultados aún.', style: TextStyle(color: _sub)));
    }

    final num puntaje = (_results!['puntaje'] as num?) ?? 0;
    final bool aprobado = (_results!['aprobado'] as bool?) ?? false;
    final String fraccion = (_results!['fraccionSugerida'] as String?) ?? '';
    final String obs = (_results!['observacionesGenerales'] as String?) ?? '';
    final List<dynamic> verificaciones =
        (_results!['verificaciones'] as List<dynamic>?) ?? <dynamic>[];

    Color scoreColor = _red;
    if (puntaje >= 85) {
      scoreColor = _green;
    } else if (puntaje >= 60) {
      scoreColor = _gold;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Resultados del Análisis',
                  style: TextStyle(
                      color: _text, fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: _red),
                  onPressed: _exportPdf,
                  tooltip: 'Exportar PDF'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: puntaje / 100,
                      strokeWidth: 10,
                      backgroundColor: _card2,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                    Center(
                        child: Text('$puntaje%',
                            style: TextStyle(
                                color: scoreColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: aprobado
                        ? _green.withValues(alpha: 0.2)
                        : _red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: aprobado ? _green : _red),
                  ),
                  child: Text(
                    aprobado
                        ? 'APROBADO PARA DESPACHO'
                        : 'REQUIERE CORRECCIONES',
                    style: TextStyle(
                        color: aprobado ? _green : _red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: _card2, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.category, color: _blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fracción Arancelaria Sugerida',
                          style: TextStyle(color: _sub, fontSize: 12)),
                      Text(fraccion,
                          style: const TextStyle(
                              color: _text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Observaciones Generales',
              style: TextStyle(color: _text, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(obs, style: const TextStyle(color: _sub)),
          const SizedBox(height: 24),
          const Text('Verificaciones (Checklist)',
              style: TextStyle(color: _text, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...verificaciones.map((v) {
            final vMap = v as Map<String, dynamic>;
            final estado = vMap['estado'] as String? ?? 'error';
            Color statusColor = _red;
            IconData statusIcon = Icons.error;
            if (estado == 'ok') {
              statusColor = _green;
              statusIcon = Icons.check_circle;
            } else if (estado == 'advertencia') {
              statusColor = _gold;
              statusIcon = Icons.warning;
            }

            return Card(
              color: _card2,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: _border)),
              child: ListTile(
                leading: Icon(statusIcon, color: statusColor),
                title: Text(vMap['area'] as String? ?? '',
                    style: const TextStyle(
                        color: _text, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vMap['detalle'] as String? ?? '',
                        style: const TextStyle(color: _sub)),
                    if (vMap['accion'] != null &&
                        (vMap['accion'] as String).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Acción: ${vMap['accion'] as String}',
                          style: const TextStyle(
                              color: _gold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ]
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Historial Reciente (Ãšltimas 5)',
            style: TextStyle(
                color: _text, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pre_glosas')
              .orderBy('created_at', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: _red));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: _blue));
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Text('No hay historial',
                  style: TextStyle(color: _sub));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final aprobado = data['aprobado'] as bool? ?? false;
                final puntaje = data['puntaje'] ?? 0;
                final date = (data['created_at'] as Timestamp?)?.toDate();
                final dateStr = date != null
                    ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}'
                    : '';

                return Card(
                  color: _card2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: aprobado
                          ? _green.withValues(alpha: 0.2)
                          : _red.withValues(alpha: 0.2),
                      child: Text('$puntaje',
                          style: TextStyle(
                              color: aprobado ? _green : _red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                        data['fraccionSugerida'] as String? ?? 'Desconocida',
                        style: const TextStyle(color: _text)),
                    subtitle: Text(dateStr,
                        style: const TextStyle(color: _sub, fontSize: 12)),
                    trailing: Icon(aprobado ? Icons.check : Icons.warning,
                        color: aprobado ? _green : _red),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pedimentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Pre-Glosa Aduanal (IA)',
            style: TextStyle(color: _text)),
        backgroundColor: _card,
        iconTheme: const IconThemeData(color: _text),
        elevation: 0,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Uploads & Input
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: _border)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Documentos Requeridos',
                        style: TextStyle(
                            color: _text,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    _buildFilePicker('Factura Comercial (PNG/JPG)',
                        _facturaFile, (f) => _facturaFile = f,
                        isRequired: true),
                    _buildFilePicker('Packing List (Opcional)',
                        _packingListFile, (f) => _packingListFile = f),
                    _buildFilePicker('B/L o AWB (Opcional)', _blAwbFile,
                        (f) => _blAwbFile = f),
                    const SizedBox(height: 16),
                    const Text('Draft Pedimento / Pre-validación M3',
                        style: TextStyle(
                            color: _text, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pedimentoController,
                      style: const TextStyle(color: _text),
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Pega el texto del draft o M3 aquí...',
                        hintStyle: const TextStyle(color: _sub),
                        filled: true,
                        fillColor: _card2,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _analyzeWithAI,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: _text, strokeWidth: 2))
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                            _isLoading
                                ? 'Analizando...'
                                : 'Iniciar Pre-Glosa con IA',
                            style: const TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor: _text,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Column: Results & History
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: _buildResults(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: SingleChildScrollView(child: _buildHistory()),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
