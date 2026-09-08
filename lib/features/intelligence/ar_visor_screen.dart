import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _bg = AppColors.bg;
const Color _text = AppColors.text;
const Color _gold = AppColors.gold;
const Color _border = AppColors.border;
const Color _sub = AppColors.sub;

class ArVisorScreen extends StatefulWidget {
  const ArVisorScreen({super.key});

  @override
  State<ArVisorScreen> createState() => _ArVisorScreenState();
}

class _ArVisorScreenState extends State<ArVisorScreen> {
  bool _loading = false;
  String _resultado = '';
  PlatformFile? _pickedFile;

  Future<void> _analizarDocumento() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    if (file.bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo leer la imagen')));
      }
      return;
    }

    setState(() {
      _pickedFile = file;
      _loading = true;
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un experto en documentos de comercio exterior. Identifica que tipo de documento es este y extrae todos los datos relevantes para una operacion aduanal.'),
      );

      final inlineData = InlineDataPart('image/${file.extension}', file.bytes!);
      final prompt = Content.multi(
          [TextPart('Analiza este documento aduanal.'), inlineData]);

      final response = await model.generateContent([prompt]);
      final analysis = response.text ?? 'Sin anÃƒ¡lisis';

      setState(() {
        _resultado = analysis;
        _loading = false;
      });

      // Opt: Log to blockchain/firestore if needed
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('document_analysis').add({
          'uid': user.uid,
          'analysis': analysis,
          'filename': file.name,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Vista Documental Avanzada',
            style: TextStyle(color: _text)),
        iconTheme: const IconThemeData(color: _gold),
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _border, height: 1)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _analizarDocumento,
                icon: _loading
                    ? const CircularProgressIndicator(color: _bg)
                    : const Icon(Icons.document_scanner, color: _bg),
                label: Text(
                    _loading ? 'Analizando...' : 'Subir Imagen y Analizar',
                    style: const TextStyle(
                        color: _bg, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _gold, padding: const EdgeInsets.all(20)),
              ),
            ),
            const SizedBox(height: 24),
            if (_pickedFile != null)
              Text('Archivo: ${_pickedFile!.name}',
                  style: const TextStyle(color: _sub)),
            const SizedBox(height: 16),
            if (_resultado.isNotEmpty)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border)),
                  child: SingleChildScrollView(
                    child: Text(_resultado,
                        style: const TextStyle(color: _text, height: 1.5)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
