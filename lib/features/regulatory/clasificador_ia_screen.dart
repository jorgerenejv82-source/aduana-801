import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';

const Color _red = AppColors.red;

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _gold = AppColors.gold;
const Color _verde = AppColors.green;
const Color _azul = AppColors.blue;

class ClasificadorIaScreen extends StatefulWidget {
  const ClasificadorIaScreen({super.key});

  @override
  State<ClasificadorIaScreen> createState() => _ClasificadorIaScreenState();
}

class _ClasificadorIaScreenState extends State<ClasificadorIaScreen> {
  final _descController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];

  final List<String> _ejemplos = [
    'Cable USB',
    'Conector automotriz',
    'Chasis aluminio',
    'Tela algodón',
    'Motor eléctrico',
    'Transformador'
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _clasificar() async {
    setState(() {
      _isLoading = true;
      _results = [];
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres el clasificador arancelario oficial de Mexico. Clasifica la mercancia descrita en la TIGIE y devuelve la fraccion de 8 digitos con justificacion.'),
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt =
          '''Clasifica la siguiente mercancia: "${_descController.text}"
Devuelve un JSON con un array de resultados llamado "resultados" con la siguiente estructura:
{
  "resultados": [
    {
      "codigo": "Fraccion de 8 digitos (ej. 8544.42.01)",
      "desc": "Descripcion legal de la fraccion",
      "igi": Numero (porcentaje de IGI, ej. 10),
      "iva": Numero (porcentaje de IVA, ej. 16),
      "confianza": "Alta", "Media", o "Baja",
      "just": "Breve justificacion de la clasificacion"
    }
  ]
}''';

      final response = await model.generateContent([Content.text(prompt)]);
      final jsonResponse =
          jsonDecode(response.text ?? '{}') as Map<String, dynamic>;

      setState(() {
        _isLoading = false;
        if (jsonResponse['resultados'] != null) {
          _results = List<Map<String, dynamic>>.from(
              jsonResponse['resultados'] as Iterable<dynamic>);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error: \$e', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red));
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
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: _gold),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _gold.withValues(alpha: 0.3))),
              child: const Icon(Icons.auto_awesome, color: _gold, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Clasificador IA Gemini',
                style: TextStyle(
                    color: _gold, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Asistente de Clasificación Arancelaria',
                      style: TextStyle(
                          color: _texto,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                      'Describe la mercancía con el mayor detalle posible. La IA analizará la descripción y sugerirá fracciones arancelarias basadas en la LIGIE.',
                      style: TextStyle(color: _sec, fontSize: 14, height: 1.5)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _descController,
                    maxLines: 6,
                    style: const TextStyle(color: _texto, fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Descripción de mercancía',
                      labelStyle: const TextStyle(color: _sec, fontSize: 16),
                      filled: true,
                      fillColor: _card,
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: _bord),
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: _gold),
                          borderRadius: BorderRadius.circular(12)),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Ejemplos rápidos:',
                      style: TextStyle(
                          color: _sec,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _ejemplos
                        .map((e) => _EjemploChip(
                              label: e,
                              onTap: () {
                                _descController.text = e;
                              },
                            ))
                        .toList(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: _clasificar,
                      icon: const Icon(Icons.psychology, color: _bg, size: 24),
                      label: const Text('Clasificar con IA Gemini',
                          style: TextStyle(
                              color: _bg,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: _card,
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.list_alt, color: _gold),
                      SizedBox(width: 12),
                      Text('Resultados de Clasificación',
                          style: TextStyle(
                              color: _texto,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: _bord),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: _gold),
                                SizedBox(height: 16),
                                Text('Analizando con IA...',
                                    style:
                                        TextStyle(color: _sec, fontSize: 16)),
                              ],
                            ),
                          )
                        : _results.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.search_off,
                                        color: _sec.withValues(alpha: 0.5),
                                        size: 64),
                                    const SizedBox(height: 16),
                                    const Text(
                                        'No hay resultados.\nIngresa una descripción para comenzar.',
                                        style: TextStyle(
                                            color: _sec, fontSize: 16),
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    _results.length > 3 ? 3 : _results.length,
                                itemBuilder: (context, index) {
                                  final r = _results[index];
                                  return _FraccionCard(data: r);
                                },
                              ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _EjemploChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _EjemploChip({required this.label, required this.onTap});

  @override
  State<_EjemploChip> createState() => _EjemploChipState();
}

class _EjemploChipState extends State<_EjemploChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? _gold.withValues(alpha: 0.2) : _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _hover ? _gold : _bord),
          ),
          child: Text(widget.label,
              style: TextStyle(color: _hover ? _gold : _texto, fontSize: 14)),
        ),
      ),
    );
  }
}

class _FraccionCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _FraccionCard({required this.data});

  @override
  State<_FraccionCard> createState() => _FraccionCardState();
}

class _FraccionCardState extends State<_FraccionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final confColor = widget.data['confianza'] == 'Alta'
        ? _verde
        : widget.data['confianza'] == 'Media'
            ? _gold
            : _red;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hover ? _gold : _bord),
          boxShadow: [
            if (_hover)
              BoxShadow(
                  color: _gold.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.data['codigo'].toString(),
                    style: const TextStyle(
                        color: _gold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: confColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: confColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.analytics, color: confColor, size: 14),
                      const SizedBox(width: 6),
                      Text('Confianza: ${widget.data['confianza']}',
                          style: TextStyle(
                              color: confColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(widget.data['desc'].toString(),
                style: const TextStyle(
                    color: _texto, fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _card, borderRadius: BorderRadius.circular(8)),
                  child: Text('IGI: ${widget.data['igi']}%',
                      style: const TextStyle(
                          color: _sec,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _card, borderRadius: BorderRadius.circular(8)),
                  child: Text('IVA: ${widget.data['iva']}%',
                      style: const TextStyle(
                          color: _sec,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _azul.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _azul.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: _azul, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text('Justificación: ${widget.data['just']}',
                          style: const TextStyle(color: _azul, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _card,
                  foregroundColor: _gold,
                  side: const BorderSide(color: _bord),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: widget.data['codigo'].toString()));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Fracción copiada al portapapeles'),
                      backgroundColor: _gold));
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Usar esta fracción',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
