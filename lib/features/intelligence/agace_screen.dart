import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _teal = AppColors.green;
const Color _rojo = AppColors.red;

class AgaceScreen extends StatefulWidget {
  const AgaceScreen({super.key});
  @override
  State<AgaceScreen> createState() => _AgaceScreenState();
}

class _AgaceScreenState extends State<AgaceScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotCtrl;
  late final AnimationController _pulseCtrl;
  bool _loading = false;
  bool _ejecutado = false;
  List<Map<String, dynamic>> _hallazgos = [];

  @override
  void initState() {
    super.initState();
    _rotCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _simularVisita() async {
    setState(() {
      _loading = true;
      _ejecutado = false;
      _hallazgos.clear();
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
          model: 'gemini-1.5-flash',
          generationConfig:
              GenerationConfig(responseMimeType: 'application/json'),
          systemInstruction: Content.system(
              'Eres el Auditor Supremo de AGACE del SAT de México. Analiza una empresa IMMEX y devuelve un JSON array con hallazgos.'
              'El JSON debe ser estrictamente un arreglo de objetos con las llaves: "desc" (string, descripción de la irregularidad), "accion" (string, acción a tomar), "nivel" ("ALTO", "MEDIO", "BAJO").'
              'Genera exactamente 4 hallazgos inventados pero muy realistas basados en regulaciones actuales (Anexo 30, mermas, activo fijo, etc).'));

      const prompt =
          'Inicia auditoría de escritorio preventiva a RFC: ADU8010101XYZ, programa IMMEX 1234-2006. Empresa automotriz con  USD en saldo Anexo 30 vencido.';
      final res = await model.generateContent([Content.text(prompt)]);

      final jsonText = res.text ?? "[]";
      final List<dynamic> decoded = jsonDecode(jsonText) as List<dynamic>;
      final List<Map<String, dynamic>> finalHallazgos = decoded
          .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _hallazgos = finalHallazgos;
          _ejecutado = true;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('AGACE error: $e');
      if (mounted) {
        setState(() {
          _hallazgos = [
            {
              'desc': 'Error conectando a AGACE AI: $e',
              'accion': 'N/A',
              'nivel': 'ALTO'
            }
          ];
          _ejecutado = true;
          _loading = false;
        });
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
        title: const Text('Auditoria Autonoma (AGACE)',
            style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _bord, height: 1),
        ),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            const Text('Zero-Click Compliance (Simulador AGACE)',
                style: TextStyle(
                    color: _ambar, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Detecta y neutraliza discrepancias fiscales antes de que el SAT emita una Carta Invitacion.',
                style: TextStyle(color: _sec, fontSize: 14, height: 1.6),
                textAlign: TextAlign.center),
            const SizedBox(height: 48),
            if (!_ejecutado) ...[
              Center(
                  child: SizedBox(
                      height: 300,
                      width: 300,
                      child: AnimatedBuilder(
                          animation: _rotCtrl,
                          builder: (_, __) => CustomPaint(
                              painter: _ShieldPainter(
                                  _rotCtrl.value, _pulseCtrl.value),
                              child: Center(
                                  child: ScaleTransition(
                                      scale: Tween(begin: 0.92, end: 1.08)
                                          .animate(_pulseCtrl),
                                      child: const Icon(Icons.security,
                                          color: _ambar, size: 84))))))),
              const SizedBox(height: 48),
              Center(
                  child: ElevatedButton.icon(
                onPressed: _loading ? null : _simularVisita,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: _bg, strokeWidth: 2))
                    : const Icon(Icons.manage_search, size: 20, color: _bg),
                label: Text(
                    _loading
                        ? 'Simulando auditoria SAT...'
                        : 'Simular Visita Domiciliaria',
                    style: const TextStyle(
                        color: _bg, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _ambar,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
              )),
            ] else
              _buildResultados(),
          ])),
    );
  }

  Widget _buildResultados() {
    final altos = _hallazgos.where((h) => h['nivel'] == 'ALTO').length;
    final medios = _hallazgos.where((h) => h['nivel'] == 'MEDIO').length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _HoverCard(
          padding: const EdgeInsets.all(24),
          borderColor: altos > 0 ? _rojo : _teal,
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: (altos > 0 ? _rojo : _teal).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                          (altos > 0 ? _rojo : _teal).withValues(alpha: 0.3))),
              child: Icon(altos > 0 ? Icons.gpp_bad : Icons.gpp_good,
                  color: altos > 0 ? _rojo : _teal, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      altos > 0
                          ? 'RIESGO DE AUDITORIA DETECTADO'
                          : 'PERFIL FISCAL LIMPIO',
                      style: TextStyle(
                          color: altos > 0 ? _rojo : _teal,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$altos riesgos altos · $medios alertas',
                      style: const TextStyle(color: _sec, fontSize: 14)),
                ])),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _ejecutado = false;
                _hallazgos = [];
              }),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reiniciar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                  foregroundColor: _sec,
                  side: const BorderSide(color: _bord),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          ])),
      const SizedBox(height: 24),
      ...List.generate(_hallazgos.length, (i) {
        final h = _hallazgos[i];
        final Color col = h['nivel'] == 'ALTO'
            ? _rojo
            : h['nivel'] == 'MEDIO'
                ? _ambar
                : _teal;
        final IconData ico = h['nivel'] == 'ALTO'
            ? Icons.gpp_bad
            : h['nivel'] == 'MEDIO'
                ? Icons.warning_amber
                : Icons.check_circle;
        return _HoverCard(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: col.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: col.withValues(alpha: 0.3))),
                child: Icon(ico, color: col, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(h['desc'] as String,
                        style: const TextStyle(
                            color: _texto,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Accion: ${h['accion']}',
                        style: const TextStyle(
                            color: _sec, fontSize: 13, height: 1.5)),
                  ])),
              const SizedBox(width: 16),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: col.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: col.withValues(alpha: 0.3))),
                  child: Text(h['nivel'] as String,
                      style: TextStyle(
                          color: col,
                          fontSize: 11,
                          fontWeight: FontWeight.bold))),
            ]));
      }),
      const SizedBox(height: 24),
      SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Reporte AGACE exportado'),
                    backgroundColor: _card)),
            icon: const Icon(Icons.download, size: 16, color: _bg),
            label: const Text('Exportar Reporte AGACE (PDF)',
                style: TextStyle(
                    color: _bg, fontWeight: FontWeight.bold, fontSize: 14)),
            style: ElevatedButton.styleFrom(
                backgroundColor: _ambar,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
          )),
    ]);
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;

  const _HoverCard(
      {required this.child,
      required this.padding,
      this.margin,
      this.borderColor});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: widget.padding,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: widget.borderColor ??
                  (_isHovered ? _ambar.withValues(alpha: 0.5) : _bord)),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final double rot;
  final double pulse;
  _ShieldPainter(this.rot, this.pulse);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 0; i < 3; i++) {
      final angle = rot * 2 * math.pi + i * math.pi / 3;
      final r = 90.0 + i * 28;
      paint.color = AppColors.gold.withValues(alpha: 0.15 + (i * 0.1));
      final path = Path()
        ..moveTo(cx + r * math.cos(angle), cy + r * math.sin(angle))
        ..lineTo(cx + r * math.cos(angle + math.pi / 2),
            cy + r * math.sin(angle + math.pi / 2))
        ..lineTo(cx + r * math.cos(angle + math.pi),
            cy + r * math.sin(angle + math.pi))
        ..lineTo(cx + r * math.cos(angle + 3 * math.pi / 2),
            cy + r * math.sin(angle + 3 * math.pi / 2))
        ..close();
      canvas.drawPath(path, paint);
    }
    final linePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(_ShieldPainter o) => o.rot != rot;
}
