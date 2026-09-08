import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color _bg = AppColors.bg;
const Color _text = AppColors.text;
const Color _gold = AppColors.gold;
const Color _border = AppColors.border;
const Color _sub = AppColors.sub;

class AuditorScreen extends StatefulWidget {
  const AuditorScreen({super.key});
  @override
  State<AuditorScreen> createState() => _AuditorScreenState();
}

class _AuditorScreenState extends State<AuditorScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String _reporte = '';

  Future<void> _generarReporte() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres el Auditor Aduanal Interno de Aduanas 801. Analiza la operacion aduanal descrita e identifica irregularidades, riesgos de multa, y acciones correctivas. Responde con un reporte de auditoria estructurado.'),
      );
      final response =
          await model.generateContent([Content.text(_controller.text)]);
      final report = response.text ?? 'Sin respuesta';

      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('auditorias').add({
        'uid': user?.uid ?? 'anon',
        'descripcion': _controller.text,
        'reporte': report,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      setState(() {
        _reporte = report;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Asistente de Auditoría Aduanal',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Describa la operación a auditar:',
                style: TextStyle(color: _gold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 4,
              style: const TextStyle(color: _text),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                hintText:
                    'Ej. Importación de textiles de China con certificado T-MEC...',
                hintStyle: const TextStyle(color: _sub),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _generarReporte,
                style: ElevatedButton.styleFrom(
                    backgroundColor: _gold, padding: const EdgeInsets.all(16)),
                child: _loading
                    ? const CircularProgressIndicator(color: _bg)
                    : const Text('Analizar y Generar Reporte',
                        style:
                            TextStyle(color: _bg, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            if (_reporte.isNotEmpty)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border)),
                  child: SingleChildScrollView(
                    child: Text(_reporte,
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
