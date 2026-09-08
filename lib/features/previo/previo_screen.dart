import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class PrevioImage {
  final Uint8List bytes;
  final String filename;
  String label;

  PrevioImage({
    required this.bytes,
    required this.filename,
    this.label = '',
  });
}

class PrevioScreen extends StatefulWidget {
  const PrevioScreen({super.key});

  @override
  State<PrevioScreen> createState() => _PrevioScreenState();
}

class _PrevioScreenState extends State<PrevioScreen> {
  final _formKey = GlobalKey<FormState>();

  // Theme Colors
  static const Color bgColor = Color(0xFF0F172A);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color card2Color = Color(0xFF334155);
  static const Color textColor = Color(0xFFF8FAFC);
  static const Color subTextColor = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFF475569);
  static const Color goldColor = Color(0xFFF59E0B);
  static const Color greenColor = AppColors.green;
  static const Color blueColor = Color(0xFF3B82F6);
  static const Color redColor = AppColors.red;
  static const Color purpleColor = Color(0xFF8B5CF6);

  // Header Fields
  final _pedimentoCtrl = TextEditingController();
  final _rfcCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  String _aduana = 'Nuevo Laredo';
  DateTime _fechaPrevio = DateTime.now();
  final _verificadorCtrl = TextEditingController();

  final List<String> _aduanas = [
    'Nuevo Laredo',
    'El Paso',
    'Tijuana',
    'Manzanillo',
    'Veracruz',
    'Aeropuerto CDMX',
    'Colombia',
    'Reynosa',
    'Matamoros',
    'Nogales',
  ];

  // Declared Fields
  final _descDeclCtrl = TextEditingController();
  final _cantDeclCtrl = TextEditingController();
  final _pesoDeclCtrl = TextEditingController();
  final _valorDeclCtrl = TextEditingController();
  final _fraccionCtrl = TextEditingController();

  // Found Fields
  final _descFoundCtrl = TextEditingController();
  final _cantFoundCtrl = TextEditingController();
  final _pesoFoundCtrl = TextEditingController();
  String _estadoMercancia = 'Bueno';
  final _observacionesCtrl = TextEditingController();

  final List<String> _estados = [
    'Bueno',
    'Con daÃƒÂ±os',
    'Parcialmente daÃƒÂ±ado'
  ];

  // Images
  final List<PrevioImage> _images = [];

  // AI
  String _aiAnalysis = '';
  bool _isAnalyzing = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _pedimentoCtrl.dispose();
    _rfcCtrl.dispose();
    _nombreCtrl.dispose();
    _verificadorCtrl.dispose();
    _descDeclCtrl.dispose();
    _cantDeclCtrl.dispose();
    _pesoDeclCtrl.dispose();
    _valorDeclCtrl.dispose();
    _fraccionCtrl.dispose();
    _descFoundCtrl.dispose();
    _cantFoundCtrl.dispose();
    _pesoFoundCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaPrevio,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _fechaPrevio = date;
      });
    }
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) {
      _showSnackBar('MÃƒ¡ximo 5 imÃƒ¡genes permitidas', redColor);
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          for (final file in result.files) {
            if (_images.length < 5 && file.bytes != null) {
              _images.add(PrevioImage(
                bytes: file.bytes!,
                filename: file.name,
              ));
            }
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error al seleccionar imÃƒ¡genes: $e', redColor);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  double _calculateVariance(String declaredStr, String foundStr) {
    final declared = double.tryParse(declaredStr) ?? 0.0;
    final found = double.tryParse(foundStr) ?? 0.0;
    return found - declared;
  }

  double _calculateVariancePercent(String declaredStr, String foundStr) {
    final declared = double.tryParse(declaredStr) ?? 0.0;
    final found = double.tryParse(foundStr) ?? 0.0;
    if (declared == 0.0) return 0.0;
    return ((found - declared) / declared) * 100;
  }

  Color _getVarianceColor(double variancePercent) {
    if (variancePercent == 0) return greenColor;
    if (variancePercent.abs() <= 5) return goldColor;
    return redColor;
  }

  String _getResultado() {
    final double cantVar =
        _calculateVariancePercent(_cantDeclCtrl.text, _cantFoundCtrl.text);
    final double pesoVar =
        _calculateVariancePercent(_pesoDeclCtrl.text, _pesoFoundCtrl.text);

    if (cantVar.abs() > 5 || pesoVar.abs() > 5 || _estadoMercancia != 'Bueno') {
      return 'CON DISCREPANCIAS GRAVES';
    } else if (cantVar != 0 ||
        pesoVar != 0 ||
        _observacionesCtrl.text.isNotEmpty) {
      return 'CON OBSERVACIONES';
    }
    return 'SIN INCIDENCIAS';
  }

  Future<void> _analyzeImagesWithAI() async {
    if (_images.isEmpty) {
      _showSnackBar('Agregue imÃƒ¡genes para analizar', goldColor);
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final model =
          FirebaseAI.vertexAI().generativeModel(model: 'gemini-1.5-flash');

      final prompt = TextPart('''
ActÃƒÂºas como un experto verificador de aduanas. 
Tengo estas imÃƒ¡genes de una mercancÃƒÂ­a inspeccionada.
DescripciÃƒÂ³n declarada: ${_descDeclCtrl.text}
Cantidad declarada: ${_cantDeclCtrl.text}
Por favor, analiza las imÃƒ¡genes y dime:
1. Ã‚¿La mercancÃƒÂ­a visible coincide with la descripciÃƒÂ³n declarada?
2. Ã‚¿QuÃƒÂ© observaciones o posibles problemas notas (daÃƒÂ±os, discrepancias)?
3. RecomendaciÃƒÂ³n final para el dictamen aduanero.
Responde de forma profesional, clara y concisa.
      ''');

      final imageParts = _images
          .map((img) => InlineDataPart('image/jpeg', img.bytes))
          .toList();

      final response = await model.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);

      setState(() {
        _aiAnalysis = response.text ?? 'Sin anÃƒ¡lisis disponible';
      });
      _showSnackBar('AnÃƒ¡lisis completado', greenColor);
    } catch (e) {
      _showSnackBar('Error en anÃƒ¡lisis de IA: $e', redColor);
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _saveToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('Usuario no autenticado');
      }

      // Convert images to base64 or upload to Storage.
      // For simplicity in this self-contained file without firebase_storage,
      // we'll avoid saving huge base64 strings if not strictly necessary,
      // but if we must save them, we can. We'll skip saving images to firestore directly
      // to avoid exceeding 1MB limit easily, just save the metadata.

      final data = {
        'pedimento': _pedimentoCtrl.text,
        'rfc_importador': _rfcCtrl.text,
        'nombre_importador': _nombreCtrl.text,
        'aduana': _aduana,
        'fecha_previo': Timestamp.fromDate(_fechaPrevio),
        'nombre_verificador': _verificadorCtrl.text,
        'descripcion_declarada': _descDeclCtrl.text,
        'cantidad_declarada': double.tryParse(_cantDeclCtrl.text) ?? 0,
        'peso_declarado': double.tryParse(_pesoDeclCtrl.text) ?? 0,
        'valor_declarado': double.tryParse(_valorDeclCtrl.text) ?? 0,
        'fraccion_arancelaria': _fraccionCtrl.text,
        'descripcion_encontrada': _descFoundCtrl.text,
        'cantidad_encontrada': double.tryParse(_cantFoundCtrl.text) ?? 0,
        'peso_encontrado': double.tryParse(_pesoFoundCtrl.text) ?? 0,
        'estado_mercancia': _estadoMercancia,
        'observaciones': _observacionesCtrl.text,
        'resultado': _getResultado(),
        'ai_analisis': _aiAnalysis,
        'uid': uid,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('previos').add(data);

      _showSnackBar('Previo guardado exitosamente', greenColor);
      if (mounted) context.pop();
    } catch (e) {
      _showSnackBar('Error al guardar: $e', redColor);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('REPORTE DE PREVIO ADUANAL',
                  style: const pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),

            // Header Info
            pw.Text('InformaciÃƒÂ³n General',
                style: const pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Pedimento: ${_pedimentoCtrl.text}'),
            pw.Text('Aduana: $_aduana'),
            pw.Text('Fecha: ${dateFormat.format(_fechaPrevio)}'),
            pw.Text('Verificador: ${_verificadorCtrl.text}'),
            pw.Text('Importador: ${_nombreCtrl.text} (RFC: ${_rfcCtrl.text})'),
            pw.SizedBox(height: 20),

            // Declared
            pw.Text('MercancÃƒÂ­a Declarada',
                style: const pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('DescripciÃƒÂ³n: ${_descDeclCtrl.text}'),
            pw.Text('FracciÃƒÂ³n Arancelaria: ${_fraccionCtrl.text}'),
            pw.Text(
                'Cantidad: ${_cantDeclCtrl.text} | Peso: ${_pesoDeclCtrl.text} kg | Valor: \$${_valorDeclCtrl.text} USD'),
            pw.SizedBox(height: 20),

            // Found
            pw.Text('MercancÃƒÂ­a Encontrada',
                style: const pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('DescripciÃƒÂ³n: ${_descFoundCtrl.text}'),
            pw.Text(
                'Cantidad: ${_cantFoundCtrl.text} (Dif: ${_calculateVariance(_cantDeclCtrl.text, _cantFoundCtrl.text)})'),
            pw.Text(
                'Peso: ${_pesoFoundCtrl.text} kg (Dif: ${_calculateVariance(_pesoDeclCtrl.text, _pesoFoundCtrl.text)} kg)'),
            pw.Text('Estado: $_estadoMercancia'),
            pw.Text('Observaciones: ${_observacionesCtrl.text}'),
            pw.SizedBox(height: 20),

            // Result
            pw.Text('Resultado: ${_getResultado()}',
                style: const pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),

            // AI Analysis
            if (_aiAnalysis.isNotEmpty) ...[
              pw.Text('AnÃƒ¡lisis de IA Asistente',
                  style: const pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(_aiAnalysis),
            ],
          ];
        },
      ),
    );

    // If there are images, add them in a new page
    if (_images.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          build: (context) {
            return [
              pw.Header(child: pw.Text('Evidencia FotogrÃƒ¡fica')),
              pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _images.map((img) {
                  return pw.Column(
                    children: [
                      pw.Image(pw.MemoryImage(img.bytes),
                          width: 200, height: 200),
                      if (img.label.isNotEmpty) pw.Text(img.label),
                    ],
                  );
                }).toList(),
              ),
            ];
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false, int maxLines = 1, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: textColor),
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: subTextColor),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: blueColor),
          ),
          fillColor: card2Color,
          filled: true,
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo requerido';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Nuevo Previo Aduanal',
            style: TextStyle(color: textColor)),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: redColor),
            tooltip: 'Exportar PDF',
            onPressed: _generatePdf,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: greenColor),
            tooltip: 'Guardar Previo',
            onPressed: _isSaving ? null : _saveToFirestore,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header fields
              _buildSectionTitle('InformaciÃƒÂ³n General'),
              Card(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: _buildTextField(
                                  _pedimentoCtrl, 'NÃƒÂºmero de Pedimento')),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildTextField(
                                  _rfcCtrl, 'RFC del Importador')),
                        ],
                      ),
                      _buildTextField(_nombreCtrl, 'Nombre del Importador'),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _aduana,
                              dropdownColor: card2Color,
                              style: const TextStyle(color: textColor),
                              decoration: const InputDecoration(
                                labelText: 'Aduana',
                                labelStyle: TextStyle(color: subTextColor),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: borderColor)),
                                fillColor: card2Color,
                                filled: true,
                              ),
                              items: _aduanas
                                  .map((a) => DropdownMenuItem(
                                      value: a, child: Text(a)))
                                  .toList(),
                              onChanged: (v) => setState(() => _aduana = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: _pickDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Fecha del Previo',
                                  labelStyle: TextStyle(color: subTextColor),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: borderColor)),
                                  fillColor: card2Color,
                                  filled: true,
                                ),
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(_fechaPrevio),
                                  style: const TextStyle(color: textColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                          _verificadorCtrl, 'Nombre del Verificador'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. MercancÃƒÂ­a Declarada
              _buildSectionTitle('MercancÃƒÂ­a Declarada'),
              Card(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(_descDeclCtrl, 'DescripciÃƒÂ³n Declarada',
                          maxLines: 2),
                      Row(
                        children: [
                          Expanded(
                              child: _buildTextField(
                                  _cantDeclCtrl, 'Cantidad Declarada',
                                  isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildTextField(
                                  _pesoDeclCtrl, 'Peso Declarado (kg)',
                                  isNumber: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: _buildTextField(
                                  _valorDeclCtrl, 'Valor Declarado (USD)',
                                  isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildTextField(
                                  _fraccionCtrl, 'FracciÃƒÂ³n Arancelaria')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. MercancÃƒÂ­a Encontrada
              _buildSectionTitle('MercancÃƒÂ­a Encontrada (FÃƒÂ­sico)'),
              Card(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                          _descFoundCtrl, 'DescripciÃƒÂ³n Encontrada',
                          maxLines: 2),

                      // Variances UI
                      AnimatedBuilder(
                          animation: Listenable.merge([
                            _cantDeclCtrl,
                            _cantFoundCtrl,
                            _pesoDeclCtrl,
                            _pesoFoundCtrl
                          ]),
                          builder: (context, _) {
                            final double cantDiff = _calculateVariance(
                                _cantDeclCtrl.text, _cantFoundCtrl.text);
                            final double cantVarPercent =
                                _calculateVariancePercent(
                                    _cantDeclCtrl.text, _cantFoundCtrl.text);
                            final Color cantColor =
                                _getVarianceColor(cantVarPercent);

                            final double pesoDiff = _calculateVariance(
                                _pesoDeclCtrl.text, _pesoFoundCtrl.text);
                            final double pesoVarPercent =
                                _calculateVariancePercent(
                                    _pesoDeclCtrl.text, _pesoFoundCtrl.text);
                            final Color pesoColor =
                                _getVarianceColor(pesoVarPercent);

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildTextField(_cantFoundCtrl,
                                            'Cantidad Encontrada',
                                            isNumber: true)),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: card2Color,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(color: cantColor),
                                        ),
                                        child: Text(
                                          'Dif: $cantDiff (${cantVarPercent.toStringAsFixed(1)}%)',
                                          style: TextStyle(
                                              color: cantColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildTextField(_pesoFoundCtrl,
                                            'Peso Encontrado (kg)',
                                            isNumber: true)),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: card2Color,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(color: pesoColor),
                                        ),
                                        child: Text(
                                          'Dif: $pesoDiff kg (${pesoVarPercent.toStringAsFixed(1)}%)',
                                          style: TextStyle(
                                              color: pesoColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),

                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _estadoMercancia,
                        dropdownColor: card2Color,
                        style: const TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          labelText: 'Estado de la MercancÃƒÂ­a',
                          labelStyle: TextStyle(color: subTextColor),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: borderColor)),
                          fillColor: card2Color,
                          filled: true,
                        ),
                        items: _estados
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _estadoMercancia = v!),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                          _observacionesCtrl, 'Observaciones del Verificador',
                          maxLines: 3, required: false),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4. Images
              _buildSectionTitle(
                  'Evidencia FotogrÃƒ¡fica (${_images.length}/5)'),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Agregar ImÃƒ¡genes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  foregroundColor: textColor,
                ),
              ),
              const SizedBox(height: 16),
              if (_images.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: cardColor,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.memory(
                              _images[index].bytes,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              style: const TextStyle(
                                  color: textColor, fontSize: 12),
                              decoration: const InputDecoration(
                                hintText: 'Etiqueta/Nota',
                                hintStyle: TextStyle(color: subTextColor),
                                isDense: true,
                              ),
                              onChanged: (val) => _images[index].label = val,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: redColor, size: 20),
                            onPressed: () {
                              setState(() {
                                _images.removeAt(index);
                              });
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // 5. AI Asistencia
              _buildSectionTitle('Asistencia de IA (Gemini)'),
              Card(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _analyzeImagesWithAI,
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: textColor))
                            : const Icon(Icons.auto_awesome),
                        label: const Text('Analizar con IA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purpleColor,
                          foregroundColor: textColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      if (_aiAnalysis.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: card2Color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: goldColor),
                          ),
                          child: Text(
                            _aiAnalysis,
                            style: const TextStyle(color: textColor),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 7. Resultado Final
              AnimatedBuilder(
                  animation: Listenable.merge([
                    _cantDeclCtrl,
                    _cantFoundCtrl,
                    _pesoDeclCtrl,
                    _pesoFoundCtrl,
                    _observacionesCtrl
                  ]),
                  builder: (context, _) {
                    final String resultado = _getResultado();
                    final Color resColor = resultado == 'SIN INCIDENCIAS'
                        ? greenColor
                        : resultado == 'CON OBSERVACIONES'
                            ? goldColor
                            : redColor;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: resColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: resColor, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text('DICTAMEN DEL PREVIO',
                              style:
                                  TextStyle(color: subTextColor, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                            resultado,
                            style: TextStyle(
                                color: resColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: goldColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
