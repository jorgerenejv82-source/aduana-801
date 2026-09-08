import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Theme Colors
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

class ConsultorTigieScreen extends StatefulWidget {
  const ConsultorTigieScreen({super.key});

  @override
  State<ConsultorTigieScreen> createState() => _ConsultorTigieScreenState();
}

class _ConsultorTigieScreenState extends State<ConsultorTigieScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _descriptionController = TextEditingController();
  PlatformFile? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _classificationResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          _selectedImage = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e',
                style: const TextStyle(color: _text)),
            backgroundColor: _red,
          ),
        );
      }
    }
  }

  Future<void> _classify() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa una descripción o sube una imagen',
              style: TextStyle(color: _text)),
          backgroundColor: _gold,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _classificationResult = null;
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
        systemInstruction: Content.system(
          'Eres el Director de Clasificacion Arancelaria de Mexico con 20 anios de experiencia en la TIGIE. El usuario te dara una descripcion de mercancia (y posiblemente una foto). Tu tarea es: 1) Determinar la fraccion arancelaria correcta de 8 digitos de la TIGIE 2) Explicar por que esa fraccion es correcta 3) Indicar el arancel ad-valorem aplicable (en %) 4) Mencionar si hay cuotas compensatorias para China u otros paises 5) Listar las NOMs (Normas Oficiales Mexicanas) aplicables 6) Indicar si requiere permiso previo de COFEPRIS, SADER u otra dependencia 7) Sugerir 2 fracciones alternativas con sus diferencias. Responde en JSON estricto: {"fraccionPrincipal": "...", "descripcionOficial": "...", "arancelAdValorem": "...", "cuotasCompensatorias": "...", "nomsAplicables": ["..."], "permisosPrevios": ["..."], "alternativas": [{"fraccion": "...", "descripcion": "...", "diferencia": "..."}], "razonamiento": "...", "advertencias": ["..."]}',
        ),
      );

      final parts = <Part>[];
      if (description.isNotEmpty) {
        parts.add(TextPart(description));
      }

      if (_selectedImage != null && _selectedImage!.path != null) {
        final bytes = File(_selectedImage!.path!).readAsBytesSync();
        final ext = _selectedImage!.extension?.toLowerCase() ?? '';
        final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
        parts.add(InlineDataPart(mimeType, bytes));
      }

      final response = await model.generateContent([Content.multi(parts)]);
      final text = response.text;

      if (text != null) {
        final jsonResult = jsonDecode(text) as Map<String, dynamic>;
        setState(() {
          _classificationResult = jsonResult;
        });

        await _saveToHistory(jsonResult);
      } else {
        throw Exception('Respuesta vacía de la IA');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: const TextStyle(color: _text)),
            backgroundColor: _red,
          ),
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

  Future<void> _saveToHistory(Map<String, dynamic> result) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = {
        'fraccion': result['fraccionPrincipal'] ?? 'N/A',
        'mercancia': _descriptionController.text.isEmpty
            ? 'Imagen subida'
            : _descriptionController.text,
        'fecha': FieldValue.serverTimestamp(),
        'uid': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('clasificaciones').add(doc);
    } catch (e) {
      debugPrint('Error guardando historial: $e');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Copiado al portapapeles', style: TextStyle(color: _text)),
        backgroundColor: _green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Consultor TIGIE', style: TextStyle(color: _text)),
        iconTheme: const IconThemeData(color: _text),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _blue,
          labelColor: _blue,
          unselectedLabelColor: _sub,
          tabs: const [
            Tab(text: 'Clasificar', icon: Icon(Icons.search)),
            Tab(text: 'Historial', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClassifyTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildClassifyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(color: _text),
                  decoration: const InputDecoration(
                    hintText: 'Describe la mercancia que deseas clasificar...',
                    hintStyle: TextStyle(color: _sub),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _border)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _blue)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image, color: _sub),
                        label: Text(
                          _selectedImage != null
                              ? 'Imagen Seleccionada'
                              : 'Adjuntar Imagen (Opcional)',
                          style: const TextStyle(color: _sub),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _border),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear, color: _red),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _classify,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _text))
                      : const Icon(Icons.auto_awesome, color: _text),
                  label: const Text('Clasificar con IA',
                      style: TextStyle(color: _text, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: _border,
                  ),
                ),
              ],
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: _red),
              ),
              child: Text(_error!, style: const TextStyle(color: _red)),
            ),
          ],

          if (_classificationResult != null) ...[
            const SizedBox(height: 24),
            _buildResultsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final res = _classificationResult!;
    final fraccion = (res['fraccionPrincipal'] ?? '').toString();
    final desc = (res['descripcionOficial'] ?? '').toString();
    final arancel = (res['arancelAdValorem'] ?? '').toString();
    final cuotas = (res['cuotasCompensatorias'] ?? '').toString();
    final razonamiento = (res['razonamiento'] ?? '').toString();
    final noms = List<String>.from(
        res['nomsAplicables'] as List<dynamic>? ?? <dynamic>[]);
    final permisos = List<String>.from(
        res['permisosPrevios'] as List<dynamic>? ?? <dynamic>[]);
    final advertencias =
        List<String>.from(res['advertencias'] as List<dynamic>? ?? <dynamic>[]);
    final alternativas = List<Map<String, dynamic>>.from(
        (res['alternativas'] as List<dynamic>? ?? <dynamic>[])
            .map((e) => e as Map<String, dynamic>));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Fraccion Card
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_card, _card2]),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: _blue, width: 2),
            boxShadow: [
              BoxShadow(
                  color: _blue.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('FRACCIÃ“N ARANCELARIA',
                      style: TextStyle(
                          color: _sub,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.copy, color: _blue, size: 20),
                    onPressed: () => _copyToClipboard(fraccion),
                    tooltip: 'Copiar fracción',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(fraccion,
                  style: const TextStyle(
                      color: _gold,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 8),
              Text(desc, style: const TextStyle(color: _text, fontSize: 16)),
              const Divider(color: _border, height: 32),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: _green, size: 20),
                  const SizedBox(width: 8),
                  Text('Arancel: $arancel',
                      style: const TextStyle(
                          color: _green,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Warning Cards
        if (cuotas.isNotEmpty &&
            cuotas.toLowerCase() != 'ninguna' &&
            cuotas.toLowerCase() != 'no aplica')
          _buildWarningCard(
              Icons.warning_amber, 'Cuotas Compensatorias', cuotas, _gold),

        if (noms.isNotEmpty)
          _buildWarningCard(
              Icons.verified_user, 'NOMs Aplicables', noms.join('\n'), _purple),

        if (permisos.isNotEmpty)
          _buildWarningCard(
              Icons.assignment, 'Permisos Previos', permisos.join('\n'), _red),

        if (advertencias.isNotEmpty)
          _buildWarningCard(Icons.info_outline, 'Advertencias',
              advertencias.join('\n'), _blue),

        const SizedBox(height: 16),

        // Reasoning Collapsible
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            collapsedBackgroundColor: _card,
            backgroundColor: _card2,
            iconColor: _text,
            collapsedIconColor: _sub,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: _border)),
            collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: _border)),
            title: const Text('Razonamiento de Clasificación',
                style: TextStyle(color: _text, fontWeight: FontWeight.w600)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(razonamiento,
                    style: const TextStyle(color: _text, height: 1.5)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Alternatives
        if (alternativas.isNotEmpty) ...[
          const Text('Fracciones Alternativas Consideradas',
              style: TextStyle(
                  color: _text, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alternativas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alt = alternativas[index];
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: _border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text((alt['fraccion'] ?? '').toString(),
                            style: const TextStyle(
                                color: _gold,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.copy, color: _sub, size: 20),
                          onPressed: () => _copyToClipboard(
                              (alt['fraccion'] ?? '').toString()),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text((alt['descripcion'] ?? '').toString(),
                        style: const TextStyle(color: _text, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: _card2,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.compare_arrows,
                              color: _sub, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text((alt['diferencia'] ?? '').toString(),
                                  style: const TextStyle(
                                      color: _sub, fontSize: 13))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildWarningCard(
      IconData icon, String title, String content, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(content,
                    style: const TextStyle(
                        color: _text, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
          child: Text('Debes iniciar sesión para ver el historial',
              style: TextStyle(color: _sub)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('clasificaciones')
          .where('uid', isEqualTo: user.uid)
          .orderBy('fecha', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _blue));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: _red)));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
              child: Text('No hay clasificaciones en el historial',
                  style: TextStyle(color: _sub)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final fraccion = (data['fraccion'] ?? 'N/A').toString();
            final mercancia = (data['mercancia'] ?? '').toString();
            final fecha = (data['fecha'] as Timestamp?)?.toDate();
            final dateStr = fecha != null
                ? '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'
                : '';

            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(fraccion,
                          style: const TextStyle(
                              color: _gold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(dateStr,
                              style:
                                  const TextStyle(color: _sub, fontSize: 12)),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy, color: _sub, size: 20),
                            onPressed: () => _copyToClipboard(fraccion),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(mercancia,
                      style: const TextStyle(color: _text, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
