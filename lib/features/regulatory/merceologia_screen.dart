import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';
import 'package:aduana_801/features/widgets/beginner_tip_widget.dart';

// â”€â”€ Design Tokens â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _teal = AppColors.green;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// HUB SCREEN â€” Laboratorio Merceológico (Titan-Tier)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class MerceologiaScreen extends StatelessWidget {
  const MerceologiaScreen({super.key});

  @override
  

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: _ambar),
        ),
        title: const Text('Laboratorio Merceologico (Titan-Tier)',
            style: TextStyle(
                color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _bord, height: 1)),
      ),
      body: Column(children: [
        // Sub-modules
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(32),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Defensa Merceologica LIGIE',
                style: TextStyle(
                    color: _ambar, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Analisis pericial taxonomico, deteccion de cuotas compensatorias y calculo de Riesgo PAMA.',
                style: TextStyle(color: _sec, fontSize: 14, height: 1.6)),
            const SizedBox(height: 32),
            Expanded(
                child: Row(children: [
              // Deep-LIGIE Engine
              Expanded(
                  child: _SubModuleCard(
                titulo: 'Deep-LIGIE Engine',
                subtitulo:
                    'Motor forense de clasificacion basado en las Reglas Generales y Notas Explicativas de la OMA.',
                icon: Icons.account_tree,
                iconColor: _sec,
                active: false,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const DeepLigieScreen())),
              )),
              const SizedBox(width: 24),
              // Radar RRNAs
              Expanded(
                  child: _SubModuleCard(
                titulo: 'Radar RRNAs & Matriz PAMA',
                subtitulo:
                    'Radar de Cuotas Compensatorias, Regulaciones no Arancelarias y exposicion financiera a multas (130%).',
                icon: Icons.gps_fixed,
                iconColor: _rojo,
                active: true,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const RadarRrnaScreen())),
              )),
            ])),
          ]),
        )),
      ]),
    );
  }
}

class _SubModuleCard extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final IconData icon;
  final Color iconColor;
  final bool active;
  final VoidCallback onTap;

  const _SubModuleCard({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.iconColor,
    required this.active,
    required this.onTap,
  });

  @override
  State<_SubModuleCard> createState() => _SubModuleCardState();
}

class _SubModuleCardState extends State<_SubModuleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(32),
          transform: Matrix4.translationValues(0, _hovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _hovered
                    ? (widget.active ? _rojo : _ambar).withValues(alpha: 0.5)
                    : _bord,
                width: _hovered ? 1.5 : 1),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: (widget.active ? _rojo : _ambar)
                            .withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon
                Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                        color: widget.iconColor
                            .withValues(alpha: widget.active ? 0.15 : 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: widget.iconColor
                                .withValues(alpha: widget.active ? 0.3 : 0.1))),
                    child:
                        Icon(widget.icon, color: widget.iconColor, size: 32)),
                const Spacer(),
                // Title
                Text(widget.titulo,
                    style: TextStyle(
                        color: widget.active ? widget.iconColor : _texto,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(widget.subtitulo,
                    style: const TextStyle(
                        color: _sec, fontSize: 14, height: 1.6)),
                const SizedBox(height: 24),
                // Arrow
                Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_forward_ios,
                        color: widget.active ? widget.iconColor : _sec,
                        size: 20)),
              ]),
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// DEEP-LIGIE ENGINE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _LigieResult {
  final String fraccion;
  final String descripcion;
  final double igi;
  final String? nom;
  final String? cuota;
  final String confianza;
  final String fundamento;

  const _LigieResult({
    required this.fraccion,
    required this.descripcion,
    required this.igi,
    this.nom,
    this.cuota,
    required this.confianza,
    required this.fundamento,
  });
}

class DeepLigieScreen extends StatefulWidget {
  const DeepLigieScreen({super.key});
  @override
  State<DeepLigieScreen> createState() => _DeepLigieScreenState();
}

class _DeepLigieScreenState extends State<DeepLigieScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  _LigieResult? _result;

  Future<void> _analizar() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un experto en merceologia aduanera de Mexico. Genera la descripcion merceologica completa y tecnica de la mercancia para declaracion en pedimento.'),
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt =
          '''Analiza la siguiente descripcion comercial o ficha tecnica: "${_ctrl.text}"
Devuelve un JSON con la siguiente estructura:
{
  "fraccion": "Fraccion sugerida de 8 digitos",
  "descripcion": "Descripcion merceologica completa y tecnica para pedimento",
  "igi": 15.0,
  "nom": "Aplica alguna NOM? (o null)",
  "cuota": "Aplica cuota compensatoria? (o null)",
  "confianza": "Porcentaje de confianza (ej. '95%')",
  "fundamento": "Regla General o Nota legal aplicable"
}''';

      final response = await model.generateContent([Content.text(prompt)]);
      final jsonResponse =
          jsonDecode(response.text ?? '{}') as Map<String, dynamic>;

      setState(() {
        _loading = false;
        _result = _LigieResult(
          fraccion: jsonResponse['fraccion']?.toString() ?? '9999.99.99.00',
          descripcion:
              jsonResponse['descripcion']?.toString() ?? 'Sin descripcion',
          igi: (jsonResponse['igi'] as num?)?.toDouble() ?? 0.0,
          nom: jsonResponse['nom']?.toString(),
          cuota: jsonResponse['cuota']?.toString(),
          confianza: jsonResponse['confianza']?.toString() ?? 'Desconocida',
          fundamento:
              jsonResponse['fundamento']?.toString() ?? 'Sin fundamento',
        );
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _result = const _LigieResult(
          fraccion: 'Error',
          descripcion: 'Ocurrio un error al analizar con Gemini.',
          igi: 0,
          confianza: '0%',
          fundamento: 'Error',
        );
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
          child: const Icon(Icons.arrow_back, color: _ambar),
        ),
        title: const Text('Deep-LIGIE Engine',
            style: TextStyle(
                color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _bord, height: 1)),
      ),
      body: Row(children: [
        // â”€â”€ Left panel â€” input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Clasificacion Arancelaria Estructural',
                        style: TextStyle(
                            color: _ambar,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                        'Analisis taxonomico basado en las Reglas Generales y Complementarias de la TIGIE 2024.',
                        style:
                            TextStyle(color: _sec, fontSize: 13, height: 1.6)),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _bord),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ficha Tecnica / Numero CAS',
                                style: TextStyle(
                                    color: _texto,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 16),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: _bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _bord),
                              ),
                              child: TextField(
                                controller: _ctrl,
                                maxLines: 6,
                                style: const TextStyle(
                                    color: _texto, fontSize: 14, height: 1.6),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Ej. Acero Inoxidable, Cromo 18%, Niquel 8% (Acero 304)...\nO describe el producto: Motor electrico DC 12V...',
                                  hintStyle:
                                      TextStyle(color: _sec, fontSize: 13),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _loading ? null : _analizar,
                                  icon: _loading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              color: _bg, strokeWidth: 2))
                                      : const Icon(Icons.search,
                                          size: 18, color: _bg),
                                  label: Text(
                                      _loading
                                          ? 'Analizando TIGIE 2024...'
                                          : 'Ejecutar Analisis LIGIE',
                                      style: const TextStyle(
                                          color: _bg,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: _ambar,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16)),
                                )),
                          ]),
                    ),
                    const SizedBox(height: 24),
                    // Quick examples
                    const Text('Ejemplos rapidos:',
                        style: TextStyle(
                            color: _sec,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          'Acero Inoxidable',
                          'Capacitor Tantalio',
                          'Motor DC 12V',
                          'Medicamento Capsulas',
                          'Tela Poliester',
                        ]
                            .map((e) => MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _ctrl.text = e),
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: _card,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(color: _bord)),
                                        child: Text(e,
                                            style: const TextStyle(
                                                color: _sec, fontSize: 12))),
                                  ),
                                ))
                            .toList()),
                  ]),
            )),
        // â”€â”€ Right panel â€” result â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: _bord))),
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.gavel_rounded,
                          color: Color(0xFFF59E0B), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AVISO LEGAL: Las fracciones arancelarias generadas por IA son orientativas. '
                          'Toda fracción debe validarse en el SIAVI del SAT (siavi4.economia.gob.mx) '
                          'antes de declararla en pedimento. El agente aduanal es el responsable de '
                          'la clasificación final (Art. 59-A Ley Aduanera).',
                          style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 11,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _result == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              CustomPaint(
                                  painter: _RadarRingPainter(),
                                  size: const Size(120, 120)),
                              const SizedBox(height: 32),
                              const Text('Esperando Ficha Tecnica...',
                                  style: TextStyle(
                                      color: _sec,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              const Text(
                                  'Ingresa la descripcion del producto y ejecuta el analisis.',
                                  style: TextStyle(color: _sec, fontSize: 14),
                                  textAlign: TextAlign.center),
                            ])
                      : _buildResult(_result!),
                ),
              ]),
            )),
      ]),
    );
  }

  Widget _buildResult(_LigieResult r) {
    final isUnknown = r.fraccion == '9999.99.99.00';
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Confidence header
      Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Resultado del Analisis',
              style: TextStyle(
                  color: _sec, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(r.fraccion,
              style: TextStyle(
                  color: isUnknown ? _rojo : _teal,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace')),
        ])),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
                color: _teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _teal.withValues(alpha: 0.5))),
            child: Column(children: [
              const Text('Confianza',
                  style: TextStyle(color: _sec, fontSize: 12)),
              const SizedBox(height: 4),
              Text(r.confianza,
                  style: const TextStyle(
                      color: _teal, fontSize: 24, fontWeight: FontWeight.bold)),
            ])),
      ]),
      const SizedBox(height: 24),
      // Description
      Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _bord),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]),
          child: Text(r.descripcion,
              style:
                  const TextStyle(color: _texto, fontSize: 14, height: 1.7))),
      const SizedBox(height: 24),
      // KPI row
      Row(children: [
        _kpiBox('IGI', '${r.igi}%', r.igi > 0 ? _ambar : _teal),
        const SizedBox(width: 16),
        _kpiBox('Cuota Comp.', r.cuota != null ? 'SI' : 'NO',
            r.cuota != null ? _rojo : _teal),
        const SizedBox(width: 16),
        _kpiBox(
            'NOM', r.nom != null ? 'SI' : 'NO', r.nom != null ? _ambar : _teal),
      ]),
      const SizedBox(height: 24),
      if (r.cuota != null)
        _alertCard('Cuota Compensatoria Detectada', r.cuota!, _rojo),
      if (r.nom != null)
        _alertCard('Regulacion No Arancelaria (NOM)', r.nom!, _ambar),
      if (r.cuota != null || r.nom != null) const SizedBox(height: 24),
      // Fundamento
      Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _bord)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Fundamento Legal',
                style: TextStyle(
                    color: _sec, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(r.fundamento,
                style: const TextStyle(color: _texto, fontSize: 14)),
          ])),
      const SizedBox(height: 32),
      // Actions
      Row(children: [
        Expanded(
            child: ElevatedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: r.fraccion));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Fraccion copiada', style: TextStyle(color: _bg)),
                backgroundColor: _ambar));
          },
          icon: const Icon(Icons.copy, size: 18, color: _bg),
          label: const Text('Copiar Fraccion',
              style: TextStyle(
                  color: _bg, fontWeight: FontWeight.bold, fontSize: 14)),
          style: ElevatedButton.styleFrom(
              backgroundColor: _ambar,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16)),
        )),
        const SizedBox(width: 16),
        Expanded(
            child: OutlinedButton.icon(
          onPressed: () => setState(() {
            _result = null;
            _ctrl.clear();
          }),
          icon: const Icon(Icons.refresh, size: 18, color: _sec),
          label: const Text('Nueva Consulta',
              style: TextStyle(
                  color: _sec, fontSize: 14, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _bord),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16)),
        )),
      ]),
    ]));
  }

  Widget _kpiBox(String l, String v, Color c) => Expanded(
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ]),
          child: Column(children: [
            Text(v,
                style: TextStyle(
                    color: c, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(l, style: const TextStyle(color: _sec, fontSize: 12)),
          ])));

  Widget _alertCard(String titulo, String contenido, Color c) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withValues(alpha: 0.5))),
      child: Row(children: [
        Icon(Icons.warning_amber, color: c, size: 24),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo,
              style: TextStyle(
                  color: c, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(contenido, style: const TextStyle(color: _texto, fontSize: 13)),
        ])),
      ]));
}

class _RadarRingPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 1; i <= 3; i++) {
      p.color = AppColors.border.withValues(alpha: (4 - i) * 0.25);
      c.drawCircle(Offset(s.width / 2, s.height / 2), i * s.width / 7, p);
    }
    final cp = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;
    c.drawCircle(Offset(s.width / 2, s.height / 2), 6, cp);
  }

  @override
  bool shouldRepaint(_RadarRingPainter _) => false;
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// RADAR RRNAs & MATRIZ PAMA
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _PamaData {
  final double igi;
  final double cuota;
  final String rrna;
  final bool esRiesgo;
  final String descripcion;

  const _PamaData(
      {required this.igi,
      required this.cuota,
      required this.rrna,
      required this.esRiesgo,
      required this.descripcion});
}

const _pamaKb = <String, Map<String, _PamaData>>{
  '7219.21.01.00': {
    'China': _PamaData(
        igi: 15,
        cuota: 60,
        rrna: 'Aviso Siderurgico DOF',
        esRiesgo: true,
        descripcion:
            'Acero de China sujeto a Cuota Compensatoria definitiva por practicas desleales (Dumping). PAMA con embargo precautorio.'),
    'Mexico': _PamaData(
        igi: 0,
        cuota: 0,
        rrna: 'Ninguna',
        esRiesgo: false,
        descripcion: 'Producto nacional. Sin restricciones arancelarias.'),
    'EUA': _PamaData(
        igi: 0,
        cuota: 0,
        rrna: 'Certificado Origen T-MEC',
        esRiesgo: false,
        descripcion:
            'Preferencia arancelaria T-MEC. Requiere Certificado de Origen.'),
    'India': _PamaData(
        igi: 15,
        cuota: 25,
        rrna: 'Aviso Siderurgico DOF',
        esRiesgo: true,
        descripcion:
            'Cuota compensatoria por dumping de acero de India. Riesgo medio.'),
  },
  '8471.30.01.00': {
    'China': _PamaData(
        igi: 10,
        cuota: 0,
        rrna: 'Section 301 USA (referencial)',
        esRiesgo: false,
        descripcion:
            'Computadoras portatiles. Sin cuota compensatoria en Mexico. Monitoreo aranceles USA.'),
    'Mexico': _PamaData(
        igi: 0,
        cuota: 0,
        rrna: 'Ninguna',
        esRiesgo: false,
        descripcion: 'Producto nacional o T-MEC. Libre de arancel.'),
    'EUA': _PamaData(
        igi: 0,
        cuota: 0,
        rrna: 'Certificado Origen T-MEC',
        esRiesgo: false,
        descripcion: 'Preferencia T-MEC aplicable.'),
    'India': _PamaData(
        igi: 10,
        cuota: 0,
        rrna: 'Ninguna',
        esRiesgo: false,
        descripcion: 'Sin cuota compensatoria. Arancel general aplica.'),
  },
};

class RadarRrnaScreen extends StatefulWidget {
  const RadarRrnaScreen({super.key});
  @override
  State<RadarRrnaScreen> createState() => _RadarRrnaScreenState();
}

class _RadarRrnaScreenState extends State<RadarRrnaScreen> {
  final _fracCtrl = TextEditingController(text: '7219.21.01.00');
  final _valorCtrl = TextEditingController(text: '1500000');
  String _pais = 'China';
  bool _analizado = false;
  _PamaData? _data;

  static const _paises = [
    'China',
    'EUA',
    'Mexico',
    'India',
    'Alemania',
    'Japon',
    'Korea',
    'Brasil',
    'Espana'
  ];

  void _actualizar() {
    setState(() {
      _analizado = true;
      final frac = _fracCtrl.text.trim();
      final mapa = _pamaKb[frac];
      _data = mapa?[_pais] ??
          const _PamaData(
              igi: 15,
              cuota: 0,
              rrna: 'Consultar DOF',
              esRiesgo: false,
              descripcion:
                  'Fraccion no registrada en la base local. Se recomienda consulta directa con SECOFI/SE.');
    });
  }

  double get _valor =>
      double.tryParse(_valorCtrl.text.replaceAll(',', '')) ?? 0;
  double get _montoIgi => _valor * ((_data?.igi ?? 0) / 100);
  double get _montoCuota => _valor * ((_data?.cuota ?? 0) / 100);
  double get _multa => _montoCuota * 1.30;
  double get _exposicion => _montoIgi + _montoCuota + _multa;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: _ambar),
        ),
        title: const Text('Radar RRNAs & Matriz PAMA',
            style: TextStyle(
                color: _rojo, fontSize: 16, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _bord, height: 1)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Analisis de Exposicion Financiera y Regulatoria',
              style: TextStyle(
                  color: _ambar, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Evaluacion en tiempo real de Cuotas Compensatorias, permisos gubernamentales y riesgo de PAMA.',
              style: TextStyle(color: _sec, fontSize: 14, height: 1.5)),
          const SizedBox(height: 32),
          Expanded(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // â”€â”€ Left: Form â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SizedBox(
                width: 380,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _formField(
                          _fracCtrl, 'Fraccion (NICO)', 'Ej. 7219.21.01.00',
                          tip: const BeginnerTipWidget(
                              term: 'Fracción Arancelaria',
                              explanation:
                                  'Código numérico internacional usado para clasificar las mercancías y determinar impuestos y permisos.')),
                      const SizedBox(height: 20),
                      // Pais dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pais de Origen',
                              style: TextStyle(
                                  color: _sec,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _bord)),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              value: _pais,
                              isExpanded: true,
                              dropdownColor: _card,
                              style: const TextStyle(
                                  color: _texto,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                              items: _paises
                                  .map((p) => DropdownMenuItem(
                                      value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (v) => setState(() => _pais = v!),
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _formField(_valorCtrl, 'Valor en Aduana Estimado (MXN)',
                          '\$ 0.00',
                          isNumber: true),
                      const SizedBox(height: 32),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _actualizar,
                            icon: const Icon(Icons.radar,
                                size: 18, color: Colors.white),
                            label: const Text('Actualizar Radar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _rojo,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20)),
                          )),
                      if (_analizado && _data != null) ...[
                        const SizedBox(height: 32),
                        // Quick examples
                        const Text('Fracciones de prueba:',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: ['7219.21.01.00', '8471.30.01.00']
                                .map((f) => MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => _fracCtrl.text = f);
                                          _actualizar();
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                                color: _card,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border:
                                                    Border.all(color: _bord)),
                                            child: Text(f,
                                                style: const TextStyle(
                                                    color: _sec,
                                                    fontSize: 12,
                                                    fontFamily: 'monospace'))),
                                      ),
                                    ))
                                .toList()),
                      ],
                    ])),
            const SizedBox(width: 32),
            // â”€â”€ Right: Results â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (_analizado && _data != null)
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                // 3 KPI cards
                Row(children: [
                  _kpiCard('Arancel (IGI)', '${_data!.igi.toStringAsFixed(0)}%',
                      _ambar, Icons.percent),
                  const SizedBox(width: 16),
                  _kpiCard(
                      'Cuota Compensatoria',
                      '${_data!.cuota.toStringAsFixed(0)}%',
                      _rojo,
                      Icons.money_off),
                  const SizedBox(width: 16),
                  _kpiCard(
                      'RRNAs (Permisos)', _data!.rrna, _azul, Icons.assignment),
                ]),
                const SizedBox(height: 24),
                // PAMA Alert or Clean
                if (_data!.esRiesgo) _pamaAlerta() else _pamaClean(),
              ]))),
            if (!_analizado)
              Expanded(
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                    CustomPaint(
                        painter: _RadarSweepPainter(),
                        size: const Size(160, 160)),
                    const SizedBox(height: 32),
                    const Text(
                        'Configure los parametros y presione\n"Actualizar Radar"',
                        style: TextStyle(color: _sec, fontSize: 16),
                        textAlign: TextAlign.center),
                  ]))),
          ])),
        ]),
      ),
    );
  }

  Widget _pamaAlerta() => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: _rojo.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _rojo.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: _rojo.withValues(alpha: 0.1), blurRadius: 20)
            ]),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('ALERTA DE RIESGO CRITICO\n(PAMA)',
                    style: TextStyle(
                        color: _rojo,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3)),
                const SizedBox(height: 16),
                Text(_data!.descripcion,
                    style: const TextStyle(
                        color: _texto, fontSize: 14, height: 1.6)),
                const SizedBox(height: 16),
                Text(
                    'Cuota detectada: ${_data!.cuota.toStringAsFixed(0)}% â€” Acero',
                    style: const TextStyle(
                        color: _rojo,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold)),
              ])),
          const SizedBox(width: 32),
          // Financial breakdown
          Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _rojo.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Exposicion Financiera Estimada',
                  style: TextStyle(
                      color: _sec, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Text('\$${_exposicion.toStringAsFixed(2)} MXN',
                  style: const TextStyle(
                      color: _rojo, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Incluye Cuota Omitida + Multa 130%',
                  style: TextStyle(color: _sec, fontSize: 11)),
              const SizedBox(height: 20),
              const Divider(color: _bord, height: 1),
              const SizedBox(height: 16),
              _breakevenRow('Cuota Compensatoria', _montoCuota),
              _breakevenRow('Arancel IGI', _montoIgi),
              _breakevenRow('Multa PAMA (130%)', _multa, isTotal: true),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Alerta Compliance generada',
                                style: TextStyle(color: Colors.white)),
                            backgroundColor: _rojo)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _rojo,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Generar Alerta Compliance',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  )),
            ]),
          ),
        ]),
      );

  Widget _pamaClean() => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: _teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _teal.withValues(alpha: 0.5))),
        child: Row(children: [
          const Icon(Icons.check_circle, color: _teal, size: 48),
          const SizedBox(width: 24),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('SIN RIESGO DE PAMA',
                    style: TextStyle(
                        color: _teal,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_data!.descripcion,
                    style: const TextStyle(
                        color: _texto, fontSize: 14, height: 1.6)),
                const SizedBox(height: 12),
                Text(
                    'Exposicion fiscal estimada: \$${_montoIgi.toStringAsFixed(2)} MXN (solo IGI)',
                    style: const TextStyle(color: _sec, fontSize: 13)),
              ])),
        ]),
      );

  Widget _breakevenRow(String l, double v, {bool isTotal = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Expanded(
              child: Text(l,
                  style:
                      TextStyle(color: isTotal ? _rojo : _sec, fontSize: 12))),
          Text('\$${v.toStringAsFixed(0)} MXN',
              style: TextStyle(
                  color: isTotal ? _rojo : _texto,
                  fontSize: 12,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ]),
      );

  Widget _kpiCard(String l, String v, Color c, IconData ico) => Expanded(
          child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(ico, color: c, size: 18),
            const SizedBox(width: 8),
            Text(l,
                style: const TextStyle(
                    color: _sec, fontSize: 12, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 12),
          Text(v,
              style: TextStyle(
                  color: c, fontSize: 28, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ]),
      ));

  Widget _formField(TextEditingController c, String label, String hint,
          {bool isNumber = false, Widget? tip}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label,
              style: const TextStyle(
                  color: _sec, fontSize: 12, fontWeight: FontWeight.w500)),
          if (tip != null) tip
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: c,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(
              color: _texto, fontSize: 16, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _sec),
              filled: true,
              fillColor: _card,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _bord)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _bord))),
        ),
      ]);
}

class _RadarSweepPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 1; i <= 3; i++) {
      p.color = AppColors.border.withValues(alpha: 0.3 + (i * 0.2));
      c.drawCircle(Offset(cx, cy), i * s.width / 7, p);
    }
    // Cross hairs
    final cp = Paint()
      ..color = AppColors.red.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    c.drawLine(Offset(cx, 0), Offset(cx, s.height), cp);
    c.drawLine(Offset(0, cy), Offset(s.width, cy), cp);
    // Center dot
    c.drawCircle(Offset(cx, cy), 6, Paint()..color = AppColors.red);
    // Radar arrow
    const angle = -math.pi / 4;
    c.drawLine(
        Offset(cx, cy),
        Offset(cx + math.cos(angle) * s.width * 0.42,
            cy + math.sin(angle) * s.height * 0.42),
        Paint()
          ..color = AppColors.red.withValues(alpha: 0.8)
          ..strokeWidth = 2.0);
  }

  @override
  bool shouldRepaint(_) => false;
}
