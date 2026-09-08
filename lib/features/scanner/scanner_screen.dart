import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

const Color _bg = Color(0xFF0F172A);
const Color _card = Color(0xFF1E293B);
const Color _text = Color(0xFFF8FAFC);
const Color _sub = Color(0xFF94A3B8);
const Color _gold = Color(0xFFF59E0B);
const Color _green = AppColors.green;
const Color _blue = Color(0xFF3B82F6);
const Color _border = Color(0xFF475569);

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isLoading = false;
  String _analysisResult = '';
  String _fileName = '';

  Future<void> _scanDocument() async {
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    setState(() {
      _isLoading = true;
      _fileName = file.name;
      _analysisResult = '';
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
          model: 'gemini-1.5-flash',
          systemInstruction: Content.system(
              'Eres un experto en documentos de comercio exterior. Identifica qué tipo de documento aduanal es este (factura, packing list, BL, AWB, pedimento, permiso, certificado, etc.) y extrae TODOS los datos relevantes en formato estructurado.'));

      final mimeType = file.extension == 'pdf'
          ? 'application/pdf'
          : 'image/${file.extension}';

      final response = await model.generateContent([
        Content.multi([
          TextPart('Analiza el siguiente documento:'),
          InlineDataPart(mimeType, bytes)
        ])
      ]);

      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final textResult = response.text ?? 'Sin resultados';

      await FirebaseFirestore.instance.collection('document_analysis').add({
        'fileName': file.name,
        'analysis': textResult,
        'created_at': FieldValue.serverTimestamp(),
        'uid': uid,
      });

      if (mounted) {
        setState(() {
          _analysisResult = textResult;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Documento analizado y guardado'),
            backgroundColor: _green));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Scanner de Documentos IA',
            style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _text),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gold.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.document_scanner, size: 64, color: _gold),
                  const SizedBox(height: 16),
                  const Text(
                      'Sube un documento aduanal para extraer sus datos automáticamente.',
                      style: TextStyle(color: _sub)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _scanDocument,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: _bg, strokeWidth: 2))
                        : const Icon(Icons.upload_file, color: _bg),
                    label: Text(
                        _isLoading ? 'Analizando...' : 'Escanear Documento',
                        style: const TextStyle(
                            color: _bg, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_analysisResult.isNotEmpty) ...[
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resultados de $_fileName',
                          style: const TextStyle(
                              color: _text,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(_analysisResult,
                              style: const TextStyle(
                                  color: _text, fontFamily: 'monospace')),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/despacho_hub'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Usar en nuevo expediente',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
