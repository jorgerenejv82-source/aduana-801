import 'dart:async';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;
const Color _naran = Color(0xFFF97316);
const Color _morado = Color(0xFF8B5CF6);

class _Factor {
  final String nombre;
  final double score;
  final Color color;
  final IconData icon;
  final String descripcion;
  final String accion;
  const _Factor(
      {required this.nombre,
      required this.score,
      required this.color,
      required this.icon,
      required this.descripcion,
      required this.accion});
}

final _pedimentos = [
  {
    'folio': '26-25-2026-0000123',
    'aduana': 'Nuevo Laredo',
    'fraccion': '8544.42.01',
    'valor': 125000.0,
    'riesgo': 'ALTO',
    'motivo': 'Fracción con alta frecuencia de revisión'
  },
  {
    'folio': '26-25-2026-0000089',
    'aduana': 'Cd. Juárez',
    'fraccion': '8536.90.99',
    'valor': 89200.0,
    'riesgo': 'MEDIO',
    'motivo': 'Valor declarado por debajo del promedio de mercado'
  },
  {
    'folio': '26-25-2026-0000054',
    'aduana': 'Tijuana',
    'fraccion': '8501.10.01',
    'valor': 38000.0,
    'riesgo': 'BAJO',
    'motivo': 'Proveedor OEA certificado, bajo perfil de riesgo'
  },
];

class MlAuditPredictorScreen extends StatefulWidget {
  const MlAuditPredictorScreen({super.key});
  @override
  State<MlAuditPredictorScreen> createState() => _MlAuditPredictorScreenState();
}

class _MlAuditPredictorScreenState extends State<MlAuditPredictorScreen>
    with SingleTickerProviderStateMixin {
  bool _analyzing = false;
  bool _done = false;
  double _score = 0;
  late final AnimationController _gaugeCtrl;
  late final Animation<double> _gaugeAnim;
  double _targetScore = 67;
  bool _btnHovered = false;
  String _rawJson = '';

  final _factores = const [
    _Factor(
        nombre: 'Clasificación Arancelaria',
        score: 72,
        color: _naran,
        icon: Icons.category_outlined,
        descripcion:
            'Fracciones de alto perfil de riesgo (8544, 8536, 9031) con historial de controversia en clasificación.',
        accion:
            'Solicitar dictamen de clasificación previo a las próximas importaciones.'),
    _Factor(
        nombre: 'Valor en Aduana',
        score: 58,
        color: _ambar,
        icon: Icons.attach_money,
        descripcion:
            'Valor declarado en 2 pedimentos por debajo del VT histórico. Posible subvaluación detectada.',
        accion:
            'Preparar estudio de precios de transferencia para proveedores relacionados.'),
    _Factor(
        nombre: 'Origen de la Mercancía',
        score: 85,
        color: _rojo,
        icon: Icons.public,
        descripcion:
            'Mercancía de origen China en fracción con cuota compensatoria activa (Resolución DOF 2024).',
        accion:
            'Verificar que el Certificado de Origen esté validado y vigente antes de presentar pedimento.'),
    _Factor(
        nombre: 'Frecuencia de Reconocimiento',
        score: 45,
        color: _verde,
        icon: Icons.search,
        descripcion:
            'Solo el 20% de los pedimentos históricos tuvieron reconocimiento físico. Perfil controlado.',
        accion:
            'Mantener documentación completa para facilitar reconocimientos eventuales.'),
  ];

  @override
  void initState() {
    super.initState();
    _gaugeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    _gaugeAnim = Tween<double>(begin: 0, end: _targetScore / 100).animate(
        CurvedAnimation(parent: _gaugeCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _gaugeCtrl.dispose();
    super.dispose();
  }

  Future<void> _analizar() async {
    setState(() {
      _analyzing = true;
      _done = false;
      _score = 0;
    });
    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un modelo de machine learning entrenado con datos de auditorias del SAT Mexico. Dado el perfil de la empresa y sus operaciones aduanales, predice: probabilidad de auditoria (0-100%), factores de riesgo principales, meses de mayor riesgo, y recomendaciones preventivas. Responde en JSON: {"probabilidadAuditoria": 0, "nivelRiesgo": "", "factoresRiesgo": [{"factor": "", "peso": 0}], "mesesRiesgo": [""], "recomendaciones": [""]}'),
      );
      final response = await model.generateContent([
        Content.text(
            'Analiza empresa con 10 importaciones recientes de China y 2 subvaluaciones detectadas.')
      ]);
      String text = response.text ?? '{}';

      if (text.contains('```json')) {
        text = text.split('```json')[1].split('```')[0].trim();
      } else if (text.contains('```')) {
        text = text.split('```')[1].split('```')[0].trim();
      }

      final data = jsonDecode(text) as Map<String, dynamic>;

      setState(() {
        _analyzing = false;
        _done = true;
        _targetScore =
            (data['probabilidadAuditoria'] as num?)?.toDouble() ?? 67.0;
        _score = _targetScore;
        _rawJson = const JsonEncoder.withIndent('  ').convert(data);
      });
      unawaited(_gaugeCtrl.forward(from: 0));
    } catch (e) {
      setState(() {
        _analyzing = false;
        _done = true;
        _targetScore = 50.0;
        _score = _targetScore;
        _rawJson = 'Error: $e';
      });
      unawaited(_gaugeCtrl.forward(from: 0));
    }
  }

  Color get _scoreColor => _score >= 70
      ? _rojo
      : _score >= 45
          ? _naran
          : _verde;
  String get _scoreLabel => _score >= 70
      ? 'RIESGO ALTO'
      : _score >= 45
          ? 'RIESGO MEDIO'
          : 'RIESGO BAJO';
  IconData get _scoreIcon => _score >= 70
      ? Icons.warning_rounded
      : _score >= 45
          ? Icons.warning_amber_rounded
          : Icons.check_circle_outline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _ambar),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: _ambar.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _ambar.withValues(alpha: 0.3))),
                child: const Icon(Icons.pin_drop, color: _ambar, size: 18)),
            const SizedBox(width: 12),
            const Text('Análisis de Riesgo Predictivo con IA',
                style: TextStyle(
                    color: _ambar, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _ambar.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _ambar.withValues(alpha: 0.3))),
          child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: _ambar, size: 20),
                SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Análisis basado en tus pedimentos + IA',
                          style: TextStyle(
                              color: _ambar,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(
                          'Lee pedimentos históricos simulados y consulta a la IA para estimar el riesgo de auditoría y el impacto financiero potencial.',
                          style: TextStyle(
                              color: _sec, fontSize: 12, height: 1.5)),
                    ])),
              ]),
        ),
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  if (!_done && !_analyzing) _buildLanding(),
                  if (_analyzing) _buildAnalyzing(),
                  if (_done) ...[
                    _buildScoreCard(),
                    const SizedBox(height: 24),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildFactores()),
                          const SizedBox(width: 24),
                          Expanded(
                              flex: 2,
                              child: Column(children: [
                                _buildPedimentosRiesgo(),
                                const SizedBox(height: 24),
                                _buildRecomendaciones(),
                              ])),
                        ]),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                          child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.picture_as_pdf_outlined,
                                  size: 18, color: _rojo),
                              label: const Text('Exportar PDF',
                                  style: TextStyle(color: _rojo, fontSize: 14)),
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: _rojo),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12))))),
                      const SizedBox(width: 16),
                      Expanded(
                          child: ElevatedButton.icon(
                              onPressed: _analizar,
                              icon: const Icon(Icons.refresh,
                                  size: 18, color: _bg),
                              label: const Text('Nuevo Análisis',
                                  style: TextStyle(
                                      color: _bg,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _ambar,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12))))),
                    ]),
                  ],
                ]))),
      ]),
    );
  }

  Widget _buildLanding() => Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _bord)),
        child: Column(children: [
          Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _azul.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _azul.withValues(alpha: 0.3))),
              child: const Icon(Icons.bar_chart, color: _azul, size: 40)),
          const SizedBox(height: 24),
          const Text('Análisis de Riesgo Predictivo',
              style: TextStyle(
                  color: _texto, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
              'Lee tus pedimentos históricos y consulta a la IA para estimar el riesgo de auditoría.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _sec, fontSize: 14, height: 1.6)),
          const SizedBox(height: 32),
          MouseRegion(
            onEnter: (_) => setState(() => _btnHovered = true),
            onExit: (_) => setState(() => _btnHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _analizar,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  color: _btnHovered ? const Color(0xFFDC2626) : _rojo,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: _btnHovered
                      ? [
                          BoxShadow(
                              color: _rojo.withValues(alpha: 0.4),
                              blurRadius: 12)
                        ]
                      : [],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: _texto, size: 20),
                    SizedBox(width: 12),
                    Text('Analizar Riesgo con IA',
                        style: TextStyle(
                            color: _texto,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ]),
      );

  Widget _buildAnalyzing() => Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _bord)),
        child: const Column(children: [
          CircularProgressIndicator(color: _azul, strokeWidth: 3),
          SizedBox(height: 24),
          Text('Analizando pedimentos con IA...',
              style: TextStyle(
                  color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(
              'Evaluando clasificación arancelaria, valor, origen, y registros históricos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _sec, fontSize: 13, height: 1.5)),
        ]),
      );

  Widget _buildScoreCard() => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [_scoreColor.withValues(alpha: 0.15), _bg],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _scoreColor.withValues(alpha: 0.5))),
        child: Row(children: [
          SizedBox(
              width: 160,
              height: 160,
              child: AnimatedBuilder(
                  animation: _gaugeAnim,
                  builder: (_, __) => CustomPaint(
                      painter: _GaugePainter(_gaugeAnim.value, _scoreColor)))),
          const SizedBox(width: 32),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Icon(_scoreIcon, color: _scoreColor, size: 24),
                  const SizedBox(width: 12),
                  Text(_scoreLabel,
                      style: TextStyle(
                          color: _scoreColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1))
                ]),
                const SizedBox(height: 12),
                Text('Score de riesgo: ${_score.toStringAsFixed(0)}/100',
                    style: TextStyle(
                        color: _scoreColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace')),
                const SizedBox(height: 8),
                const Text(
                    'Basado en factores de riesgo analizados con IA. Actualizado al día de hoy.',
                    style: TextStyle(color: _sec, fontSize: 13, height: 1.5)),
                const SizedBox(height: 20),
                Row(children: [
                  _qstat('Pedimentos', '5', _azul),
                  _qstat('Alto riesgo', '2', _rojo),
                  _qstat('Impacto est.', '\$420K', _naran)
                ]),
              ])),
        ]),
      );

  Widget _qstat(String l, String v, Color c) => Expanded(
      child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: c.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.withValues(alpha: 0.3))),
          child: Column(children: [
            Text(v,
                style: TextStyle(
                    color: c,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1)),
            const SizedBox(height: 4),
            Text(l,
                style: const TextStyle(color: _sec, fontSize: 11, height: 1.3))
          ])));

  Widget _buildFactores() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _bord)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.analytics_outlined, color: _azul, size: 20),
            SizedBox(width: 12),
            Text('Factores de Riesgo',
                style: TextStyle(
                    color: _texto, fontSize: 16, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 20),
          ..._factores.map((f) => _factorRow(f)),
        ]),
      );

  Widget _factorRow(_Factor f) => Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 16),
          title:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: f.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: f.color.withValues(alpha: 0.3))),
                  child: Icon(f.icon, color: f.color, size: 16)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(f.nombre,
                      style: const TextStyle(
                          color: _texto,
                          fontSize: 14,
                          fontWeight: FontWeight.bold))),
              Text(f.score.toStringAsFixed(0),
                  style: TextStyle(
                      color: f.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace')),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                    value: f.score / 100,
                    backgroundColor: _bg,
                    color: f.color,
                    minHeight: 6)),
          ]),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _bord)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.descripcion,
                        style: const TextStyle(
                            color: _sec, fontSize: 13, height: 1.5)),
                    const SizedBox(height: 12),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right,
                              color: _verde, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(f.accion,
                                  style: const TextStyle(
                                      color: _verde,
                                      fontSize: 13,
                                      height: 1.5)))
                        ]),
                  ]),
            ),
          ],
        ),
      );

  Widget _buildPedimentosRiesgo() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _bord)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.receipt_long, color: _ambar, size: 20),
            SizedBox(width: 12),
            Text('Pedimentos (Top Riesgo)',
                style: TextStyle(
                    color: _texto, fontSize: 16, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 16),
          ..._pedimentos.map((p) {
            final nivel = p['riesgo'] as String;
            final c = nivel == 'ALTO'
                ? _rojo
                : nivel == 'MEDIO'
                    ? _naran
                    : _verde;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.withValues(alpha: 0.3))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(p['folio'] as String,
                              style: const TextStyle(
                                  color: _texto,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace'))),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: c.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(nivel,
                              style: TextStyle(
                                  color: c,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)))
                    ]),
                    const SizedBox(height: 8),
                    Text('${p['aduana']} â€” Fracción: ${p['fraccion']}',
                        style: const TextStyle(color: _sec, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(p['motivo'] as String,
                        style: TextStyle(color: c, fontSize: 12, height: 1.4)),
                  ]),
            );
          }),
        ]),
      );

  Widget _buildRecomendaciones() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _morado.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: _morado.withValues(alpha: 0.1), blurRadius: 10)
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.auto_awesome, color: _morado, size: 20),
            SizedBox(width: 12),
            Text('Recomendaciones IA',
                style: TextStyle(
                    color: _texto, fontSize: 16, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 20),
          if (_rawJson.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _bord)),
              child: Text(_rawJson,
                  style: const TextStyle(
                      color: _verde, fontFamily: 'monospace', fontSize: 12)),
            )
          else ...[
            _rec(
                '1',
                'Regularizar merma IMMEX â€” Presentar pedimento A3 antes de la próxima visita de verificación.',
                _rojo),
            _rec(
                '2',
                'Obtener Certificado de Origen válido para mercancía china con cuota compensatoria.',
                _naran),
            _rec(
                '3',
                'Preparar estudio de precios de transferencia para 2 proveedores con valor atípico.',
                _ambar),
          ]
        ]),
      );

  Widget _rec(String n, String t, Color c) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                color: c.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: c.withValues(alpha: 0.3))),
            child: Center(
                child: Text(n,
                    style: TextStyle(
                        color: c, fontSize: 12, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 12),
        Expanded(
            child: Text(t,
                style: const TextStyle(color: _sec, fontSize: 13, height: 1.5)))
      ]));
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  const _GaugePainter(this.value, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 12;
    const startAngle = math.pi * 0.75;
    const sweepTotal = math.pi * 1.5;
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        startAngle,
        sweepTotal,
        false,
        Paint()
          ..color = AppColors.border
          ..strokeWidth = 16
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    if (value > 0) {
      canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          startAngle,
          sweepTotal * value,
          false,
          Paint()
            ..color = color
            ..strokeWidth = 16
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
    }
    final score = (value * 100).round().toString();
    final tp = TextPainter(
        text: TextSpan(children: [
          TextSpan(
              text: score,
              style: TextStyle(
                  color: color,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace')),
          const TextSpan(
              text: '\n/100',
              style: TextStyle(color: AppColors.sub, fontSize: 14))
        ]),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.color != color;
}
