import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class RfcVerificadorScreen extends StatefulWidget {
  final String? initialRfc;

  const RfcVerificadorScreen({super.key, this.initialRfc});

  @override
  State<RfcVerificadorScreen> createState() => _RfcVerificadorScreenState();
}

class _RfcVerificadorScreenState extends State<RfcVerificadorScreen> {
  final _rfcController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    if (widget.initialRfc != null) {
      _rfcController.text = widget.initialRfc!;
    }
  }

  @override
  void dispose() {
    _rfcController.dispose();
    super.dispose();
  }

  Future<void> _consultarIA() async {
    final rfc = _rfcController.text.trim();
    if (rfc.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system('''
Eres un asesor de cumplimiento fiscal y aduanal de México. Para el RFC proporcionado, indica: 
1) Si es probable que esté en el listado del Art. 69-B del CFF (EFOS - Empresas que Facturan Operaciones Simuladas) basándote en tu conocimiento actualizado, 
2) Qué verificaciones manuales debe hacer el agente aduanal (con URLs concretas del SAT), 
3) Qué riesgo implica operar con este RFC. 
IMPORTANTE: siempre indica que la verificación definitiva debe hacerse en sat.gob.mx. 
Responde en JSON con la siguiente estructura y sin formato adicional:
{"probable69b": true o false, "nivelRiesgo": "bajo|medio|alto", "accionesVerificacion": ["url o instruccion"], "advertencia": "texto"}
'''),
      );

      final response =
          await model.generateContent([Content.text('Analiza el RFC: $rfc')]);
      final text = response.text ?? '{}';

      final cleanedText =
          text.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = jsonDecode(cleanedText);

      setState(() {
        _result = data as Map<String, dynamic>?;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Error: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _registrarVerificacion() async {
    if (_result == null) return;

    final rfc = _rfcController.text.trim();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    try {
      await FirebaseFirestore.instance.collection('rfc_verificaciones').add({
        'rfc': rfc,
        'resultado': _result,
        'fecha': FieldValue.serverTimestamp(),
        'uid': uid,
        'notas': 'Verificado mediante IA Copilot',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Verificación guardada',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Error: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.red));
      }
    }
  }

  Future<void> _marcarEnCliente() async {
    final rfc = _rfcController.text.trim();
    if (rfc.isEmpty || _result == null) return;

    final esPeligroso =
        _result?['probable69b'] == true || _result?['nivelRiesgo'] == 'alto';

    try {
      final query = await FirebaseFirestore.instance
          .collection('clientes')
          .where('rfc', isEqualTo: rfc)
          .get();

      if (query.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Cliente no encontrado en la BD con este RFC',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.orange));
        }
        return;
      }

      for (final doc in query.docs) {
        await doc.reference.update({
          'rfcListaNegra': esPeligroso,
          'rfcListaNegraFecha': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Cliente actualizado exitosamente',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Error: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text('Verificador RFC / Art. 69-B',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Consultar Estatus 69-B',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _rfcController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'RFC',
                      labelStyle: const TextStyle(color: AppColors.sub),
                      filled: true,
                      fillColor: AppColors.bg,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading ? null : _consultarIA,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.auto_awesome, color: Colors.white),
                    label: Text(
                        _isLoading ? 'Consultando...' : 'Consultar con IA',
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResultCard(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.green),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _registrarVerificacion,
                      child: const Text('Registrar Verificación Manual',
                          style: TextStyle(color: AppColors.green)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _marcarEnCliente,
                      child: const Text('Marcar en Cliente',
                          style: TextStyle(color: AppColors.bg)),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final bool isProbable = _result!['probable69b'] == true;
    final String riesgo = _result!['nivelRiesgo']?.toString() ?? 'bajo';
    final List<dynamic> acciones =
        (_result!['accionesVerificacion'] as List<dynamic>?) ?? [];
    final String advertencia = _result!['advertencia']?.toString() ?? '';

    Color badgeColor = AppColors.green;
    String badgeText = '🟢 Bajo Riesgo';

    if (riesgo == 'medio') {
      badgeColor = Colors.orange;
      badgeText = '🟡 Riesgo Medio';
    } else if (riesgo == 'alto' || isProbable) {
      badgeColor = AppColors.red;
      badgeText = '🔴 Alto Riesgo';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Resultado del Análisis',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(badgeText,
                    style: TextStyle(
                        color: badgeColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
              isProbable
                  ? '⚠️ Es PROBABLE que el RFC esté relacionado con el listado del Art. 69-B (EFOS).'
                  : '✅ No se encontraron incidencias de alta probabilidad para Art. 69-B.',
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 24),
          const Text('Acciones de Verificación Sugeridas:',
              style:
                  TextStyle(color: AppColors.sub, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...acciones.map((accion) {
            final text = accion.toString();
            final isUrl = text.startsWith('http');
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right,
                      color: AppColors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: isUrl
                        ? InkWell(
                            onTap: () => launchUrl(Uri.parse(text)),
                            child: Text(text,
                                style: const TextStyle(
                                    color: AppColors.blue,
                                    decoration: TextDecoration.underline)),
                          )
                        : Text(text,
                            style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }),
          if (advertencia.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.1),
                  border:
                      Border.all(color: Colors.yellow.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.yellow),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(advertencia,
                          style: const TextStyle(color: Colors.yellow))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
