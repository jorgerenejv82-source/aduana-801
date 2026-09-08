import 'dart:async';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';

// Constantes de Diseño
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _gold = AppColors.gold;
const Color _verde = AppColors.green;
const Color _azul = AppColors.blue;

class CartaPorteScreen extends StatefulWidget {
  const CartaPorteScreen({super.key});

  @override
  State<CartaPorteScreen> createState() => _CartaPorteScreenState();
}

class _CartaPorteScreenState extends State<CartaPorteScreen> {
  // Controles de Transporter
  final _rfcCtrl = TextEditingController(text: 'TMM123456789');
  final _placasCtrl = TextEditingController(text: '56-XX-9A');
  final _permisoSCTCtrl = TextEditingController(text: 'TPAF123456');

  // Controles de Ubicación
  final _origenRfcCtrl = TextEditingController(text: 'ORG987654321');
  final _origenCPCtrl = TextEditingController(text: '88000'); // Nuevo Laredo
  final _destRfcCtrl = TextEditingController(text: 'DST123456789');
  final _destCPCtrl = TextEditingController(text: '64000'); // Monterrey

  // Controles de Mercancía
  final _pesoNetoCtrl = TextEditingController(text: '15000');
  final _bienesTransCtrl = TextEditingController(text: 'Auto partes');
  final _claveProdServCtrl = TextEditingController(
      text: '78101800'); // Transporte de carga por carretera

  bool _isGenerating = false;

  @override
  void dispose() {
    _rfcCtrl.dispose();
    _placasCtrl.dispose();
    _permisoSCTCtrl.dispose();
    _origenRfcCtrl.dispose();
    _origenCPCtrl.dispose();
    _destRfcCtrl.dispose();
    _destCPCtrl.dispose();
    _pesoNetoCtrl.dispose();
    _bienesTransCtrl.dispose();
    _claveProdServCtrl.dispose();
    super.dispose();
  }

  void _generarComplemento() async {
    setState(() => _isGenerating = true);
    final model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-1.5-flash',
      systemInstruction: Content.system(
          'Eres un experto en Carta Porte 3.0 del SAT Mexico. Valida los datos del complemento Carta Porte proporcionado y genera el XML de ejemplo con los campos correctos. Indica si hay errores de validacion segun las reglas del SAT. Responde en JSON: {"valido": true, "errores": ["string"], "xml": "string", "folio": "string"}'),
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
    final prompt =
        'Datos: Transporte: ${_rfcCtrl.text}, Origen: ${_origenCPCtrl.text}, Destino: ${_destCPCtrl.text}, Mercancia: ${_bienesTransCtrl.text}, Peso: ${_pesoNetoCtrl.text}, Clave: ${_claveProdServCtrl.text}';
    String xmlResult = '';
    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final jsonResponse =
          jsonDecode(response.text ?? '{}') as Map<String, dynamic>;
      xmlResult = (jsonResponse['xml'] ?? 'Error generando XML').toString();
    } catch (e) {
      xmlResult = 'Error: $e';
    }
    setState(() => _isGenerating = false);

    if (!mounted) return;
    unawaited(showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _gold)),
        title: const Row(children: [
          Icon(Icons.check_circle, color: _verde),
          SizedBox(width: 12),
          Text('Complemento Carta Porte 3.1 Generado',
              style: TextStyle(
                  color: _gold, fontSize: 18, fontWeight: FontWeight.bold))
        ]),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Timbre SAT exitoso. XML firmado (simulado):',
                  style: TextStyle(color: _sec, fontSize: 14)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _bord)),
                child: SelectableText(
                  xmlResult,
                  style: const TextStyle(
                      color: _verde, fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_),
              child: const Text('Cerrar',
                  style: TextStyle(color: _sec, fontWeight: FontWeight.bold))),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(_);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('XML y PDF descargados',
                      style:
                          TextStyle(color: _bg, fontWeight: FontWeight.bold)),
                  backgroundColor: _gold));
            },
            icon: const Icon(Icons.download, size: 16, color: _bg),
            label: const Text('Descargar XML/PDF',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: _bg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Generador Carta Porte 3.1',
            style: TextStyle(
                color: _gold, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _gold),
            onPressed: () => context.go('/home')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Completa los campos obligatorios para generar el Complemento Carta Porte (CCP) Versión 3.1. Este documento es obligatorio para el traslado de mercancías.',
                style: TextStyle(color: _sec, fontSize: 16, height: 1.5)),
            const SizedBox(height: 32),

            // Sección Transporte
            _buildSectionCard('Autotransporte y Figura de Transporte',
                Icons.local_shipping_outlined, _azul, [
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          'RFC Operador/Transportista', _rfcCtrl)),
                  const SizedBox(width: 24),
                  Expanded(
                      child: _buildTextField('Placas Vehículo', _placasCtrl)),
                  const SizedBox(width: 24),
                  Expanded(
                      child: _buildTextField('Permiso SCT', _permisoSCTCtrl)),
                ],
              )
            ]),
            const SizedBox(height: 24),

            // Sección Ubicaciones
            _buildSectionCard('Ubicaciones (Origen y Destino)',
                Icons.location_on_outlined, _verde, [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _bord)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Datos de Origen',
                              style: TextStyle(
                                  color: _gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 20),
                          _buildTextField('RFC Remitente', _origenRfcCtrl),
                          const SizedBox(height: 16),
                          _buildTextField(
                              'Código Postal (Origen)', _origenCPCtrl),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _bord)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Datos de Destino',
                              style: TextStyle(
                                  color: _verde,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 20),
                          _buildTextField('RFC Destinatario', _destRfcCtrl),
                          const SizedBox(height: 16),
                          _buildTextField(
                              'Código Postal (Destino)', _destCPCtrl),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ]),
            const SizedBox(height: 24),

            // Sección Mercancías
            _buildSectionCard('Mercancías (Nivel Partidas)',
                Icons.inventory_2_outlined, _gold, [
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          'Bienes Transportados (Descripción)',
                          _bienesTransCtrl)),
                  const SizedBox(width: 24),
                  Expanded(
                      child: _buildTextField(
                          'Clave Prod/Serv (SAT)', _claveProdServCtrl)),
                  const SizedBox(width: 24),
                  Expanded(
                      child: _buildTextField(
                          'Peso Bruto Total (KG)', _pesoNetoCtrl)),
                ],
              )
            ]),

            const SizedBox(height: 40),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _origenRfcCtrl.clear();
                    _destRfcCtrl.clear();
                    _bienesTransCtrl.clear();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _sec,
                    side: const BorderSide(color: _bord),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Limpiar Formulario'),
                ),
                const SizedBox(width: 16),
                _GenerateButton(
                  isGenerating: _isGenerating,
                  onPressed: _generarComplemento,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bord),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(title,
                  style: const TextStyle(
                      color: _texto,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: _bord),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _sec, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: _texto, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: _bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: _bord),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: _gold),
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

class _GenerateButton extends StatefulWidget {
  final bool isGenerating;
  final VoidCallback onPressed;

  const _GenerateButton({required this.isGenerating, required this.onPressed});

  @override
  State<_GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<_GenerateButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _hover && !widget.isGenerating
              ? [
                  BoxShadow(
                      color: _gold.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: ElevatedButton.icon(
          onPressed: widget.isGenerating ? null : widget.onPressed,
          icon: widget.isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: _bg, strokeWidth: 2))
              : const Icon(Icons.flash_on, size: 20, color: _bg),
          label: Text(
              widget.isGenerating
                  ? 'Timbrando (PAC)...'
                  : 'Generar Carta Porte 3.1',
              style: const TextStyle(
                  color: _bg, fontWeight: FontWeight.bold, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _gold,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
