import 'dart:async';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

class SemaforoScreen extends StatefulWidget {
  const SemaforoScreen({super.key});

  @override
  State<SemaforoScreen> createState() => _SemaforoScreenState();
}

class _SemaforoScreenState extends State<SemaforoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _numPedimento = '';
  String _cliente = '';
  String _aduana = '';

  String? _selectedColor;

  // Rojo form
  final _verificadorController = TextEditingController();
  final _observacionesController = TextEditingController();

  @override
  void dispose() {
    _verificadorController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _saveSemaforo() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un resultado del semáforo')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final data = {
        'uid': user.uid,
        'numPedimento': _numPedimento,
        'cliente': _cliente,
        'aduana': _aduana,
        'resultado': _selectedColor,
        'fecha': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (_selectedColor == 'rojo') {
        data['verificador'] = _verificadorController.text;
        data['observaciones'] = _observacionesController.text;
      }

      await FirebaseFirestore.instance.collection('semaforos').add(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro guardado exitosamente')),
        );
        setState(() {
          _selectedColor = null;
          _formKey.currentState?.reset();
          _verificadorController.clear();
          _observacionesController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Registro Rápido Semáforo',
            style: TextStyle(color: Color(0xFFF8FAFC))),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Datos del Despacho',
                        style: TextStyle(
                            color: Color(0xFFF8FAFC),
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: const TextStyle(color: Color(0xFFF8FAFC)),
                      decoration: InputDecoration(
                        labelText: 'Número de Pedimento',
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                      onSaved: (v) => _numPedimento = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: const TextStyle(color: Color(0xFFF8FAFC)),
                      decoration: InputDecoration(
                        labelText: 'Cliente',
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                      onSaved: (v) => _cliente = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: const TextStyle(color: Color(0xFFF8FAFC)),
                      decoration: InputDecoration(
                        labelText: 'Aduana',
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                      onSaved: (v) => _aduana = v ?? '',
                    ),
                    const SizedBox(height: 32),
                    const Text('Resultado M.S.A.',
                        style: TextStyle(
                            color: Color(0xFFF8FAFC),
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedColor = 'verde'),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(
                                    alpha:
                                        _selectedColor == 'verde' ? 1.0 : 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _selectedColor == 'verde'
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3),
                              ),
                              alignment: Alignment.center,
                              child: const Text('VERDE',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedColor = 'naranja'),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(
                                    alpha: _selectedColor == 'naranja'
                                        ? 1.0
                                        : 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _selectedColor == 'naranja'
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3),
                              ),
                              alignment: Alignment.center,
                              child: const Text('NARANJA',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedColor = 'rojo'),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.red.withValues(
                                    alpha:
                                        _selectedColor == 'rojo' ? 1.0 : 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _selectedColor == 'rojo'
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3),
                              ),
                              alignment: Alignment.center,
                              child: const Text('ROJO',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedColor == 'naranja') ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Revisión Documental Requerida',
                                style: TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(
                                'El plazo para presentar los documentos es de 10 días hábiles.',
                                style: TextStyle(color: Color(0xFFF8FAFC))),
                          ],
                        ),
                      )
                    ],
                    if (_selectedColor == 'rojo') ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Reconocimiento Aduanero',
                                style: TextStyle(
                                    color: AppColors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _verificadorController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Verificador',
                                labelStyle:
                                    const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF1E293B),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _observacionesController,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Observaciones / Incidencias',
                                labelStyle:
                                    const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF1E293B),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B5CF6)),
                              icon: const Icon(Icons.auto_awesome,
                                  color: Colors.white),
                              label: const Text('Análisis Rápido IA',
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () async {
                                if (_observacionesController.text.isEmpty) {
                                  return;
                                }
                                try {
                                  final model = FirebaseAI.vertexAI()
                                      .generativeModel(
                                          model: 'gemini-1.5-flash');
                                  final prompt =
                                      'Soy agente aduanal en México. Analiza esta incidencia en reconocimiento: ${_observacionesController.text}. ¿Qué fundamento legal aplica y qué procede?';
                                  final response = await model
                                      .generateContent([Content.text(prompt)]);
                                  if (!mounted) return;
                                  if (!context.mounted) return;
                                  unawaited(showDialog<void>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                            backgroundColor:
                                                const Color(0xFF1E293B),
                                            title: const Text('Sugerencia IA',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            content: SingleChildScrollView(
                                                child: Text(response.text ?? '',
                                                    style: const TextStyle(
                                                        color: Colors.white))),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(c),
                                                  child: const Text('Cerrar',
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xFF3B82F6))))
                                            ],
                                          )));
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')));
                                }
                              },
                            )
                          ],
                        ),
                      )
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _saveSemaforo,
                      child: const Text('GUARDAR REGISTRO',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
          ),

          // Panel derecho (Historial y Stats)
          Expanded(
            child: ColoredBox(
              color: const Color(0xFF1E293B),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Ãšltimos 10 Registros',
                        style: TextStyle(
                            color: Color(0xFFF8FAFC),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('semaforos')
                          .orderBy('created_at', descending: true)
                          .limit(10)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red)));
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return const Center(
                              child: Text('No hay registros',
                                  style: TextStyle(color: Color(0xFF94A3B8))));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final res = data['resultado'] ?? '';
                            Color iconColor = Colors.grey;
                            if (res == 'verde') iconColor = AppColors.green;
                            if (res == 'naranja') {
                              iconColor = const Color(0xFFF59E0B);
                            }
                            if (res == 'rojo') iconColor = AppColors.red;

                            return ListTile(
                              leading: Icon(Icons.circle, color: iconColor),
                              title: Text(
                                  (data['numPedimento'] ?? '').toString(),
                                  style: const TextStyle(
                                      color: Color(0xFFF8FAFC))),
                              subtitle: Text((data['cliente'] ?? '').toString(),
                                  style: const TextStyle(
                                      color: Color(0xFF94A3B8))),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
