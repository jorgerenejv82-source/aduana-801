import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'dart:math' as math;
import 'package:flutter/material.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _gold = AppColors.gold;
const Color _red = AppColors.red;
const Color _green = AppColors.green;
const Color _blue = AppColors.blue;

class Anexo30Screen extends StatefulWidget {
  const Anexo30Screen({super.key});
  @override
  State<Anexo30Screen> createState() => _Anexo30ScreenState();
}

class _Anexo30ScreenState extends State<Anexo30Screen> {
  // State
  double _saldoInicial = 0;
  double _cargos = 0;
  double _descargos = 0;
  bool _rfidOk = true;
  List<double> _tendencia = List.filled(6, 0);

  double get _saldoFinal => _saldoInicial + _cargos - _descargos;
  double get _burnRate =>
      _saldoInicial > 0 ? (_descargos / _saldoInicial * 100).clamp(0, 100) : 0;
  double get _riesgo => 100 - _burnRate;
  double get _discrepancia => 0.0;

  String _fmt(double v) {
    if (v == 0) return '\$0.00M';
    final m = v / 1000000;
    return '\$${m.toStringAsFixed(2)}M';
  }

  void _inyectarDemo() {
    Navigator.pop(context);
    setState(() {
      _saldoInicial = 4500000;
      _cargos = 1200000;
      _descargos = 3100000;
      _tendencia = [820000, 340000, 610000, 490000, 720000, 580000];
      _rfidOk = true;
    });
  }

  void _mostrarInyector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Centro de Inyección Anexo 30',
                style: TextStyle(
                    color: _gold, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Carga Layouts (CSV) para poblar Saldos y Descargos. Las gráficas reaccionarán al instante.',
                style: TextStyle(color: _sec, fontSize: 14, height: 1.5)),
            const Divider(color: _bord, height: 32),
            _inyectorItem(
                Icons.inventory_2,
                _green,
                'Inyectar Saldos Iniciales',
                'Layout CSV: pedimento, unitPrice, initialQuantity',
                () {}),
            const SizedBox(height: 16),
            _inyectorItem(Icons.outbox, _gold, 'Inyectar Descargos (Salidas)',
                'Layout CSV: pedimento, qtyDescargada', () {}),
            const Divider(color: _bord, height: 32),
            _inyectorItem(Icons.auto_awesome, _blue, 'Cargar Dataset Demo',
                'Inyecta datos falsos para ver el efecto magia.', _inyectarDemo,
                labelColor: _blue),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _inyectorItem(IconData icon, Color iconColor, String title, String sub,
      VoidCallback onTap,
      {Color? labelColor}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.transparent), // for hover effect spacing
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: iconColor.withValues(alpha: 0.3))),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: labelColor ?? _texto,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(sub,
                        style: const TextStyle(color: _sec, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: FloatingActionButton.extended(
          onPressed: _mostrarInyector,
          backgroundColor: _gold,
          icon: const Icon(Icons.upload_file, color: _bg, size: 20),
          label: const Text('Inyector A30',
              style: TextStyle(color: _bg, fontWeight: FontWeight.bold)),
        ),
      ),
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: _gold),
        ),
        title: const Text('Administrador Anexo 30 (Saldos IVA/IEPS)',
            style: TextStyle(
                color: _gold, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Digital Twin 3D — próximamente'))),
            icon: const Icon(Icons.view_in_ar, size: 16),
            label: const Text('Digital Twin 3D',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _sec,
              side: const BorderSide(color: _bord),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: _card,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: _red.withValues(alpha: 0.5))),
                title: const Text('BOTÓN DE PÁNICO — Auditoría',
                    style: TextStyle(
                        color: _red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                content: const Text(
                    'Esta acción genera un Bloqueo de Saldo Temporal y notifica a tu agente aduanal. Solo usar en caso de auditoría sorpresa del SAT.\n\n¿Confirmas?',
                    style: TextStyle(color: _texto, fontSize: 15, height: 1.6)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar',
                          style: TextStyle(
                              color: _sec, fontWeight: FontWeight.bold))),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              '⚠️ MODO PÁNICO ACTIVADO — Bloqueo temporal iniciado'),
                          backgroundColor: _red));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text('ACTIVAR',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            icon:
                const Icon(Icons.warning_amber, color: Colors.white, size: 16),
            label: const Text('BOTÓN DE PÁNICO (Auditoría)',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Control Financiero de Créditos Fiscales',
                      style: TextStyle(
                          color: _gold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'Monitoreo del crédito otorgado por el SAT (Certificación IVA/IEPS) y los descargos por exportaciones comprobadas.',
                      style: TextStyle(color: _sec, fontSize: 15, height: 1.5)),
                  const SizedBox(height: 32),

                  // ── Auditoria Drone-Sync ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _bord)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: (_rfidOk ? _green : _red)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle),
                          child: Icon(Icons.airplanemode_active,
                              color: _rfidOk ? _green : _red, size: 32),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Auditoría Drone-Sync (RFID)',
                                  style: TextStyle(
                                      color: _texto,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                _rfidOk
                                    ? 'Sin discrepancias detectadas. Inventario físico concuerda con saldo teórico.'
                                    : 'ALERTA: Discrepancia física detectada. Revisar inmediatamente.',
                                style: TextStyle(
                                    color: _rfidOk ? _green : _red,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text('Pedimento A3 generado'),
                                  backgroundColor: _card)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Regularizar (Pedimento A3)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── AI Burn-Rate Forecast ──
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _blue.withValues(alpha: 0.5), width: 2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.trending_down, color: _blue, size: 24),
                            SizedBox(width: 12),
                            Text('AI Burn-Rate Forecast',
                                style: TextStyle(
                                    color: _blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'A tu ritmo actual de manufactura, descargarás el ${_burnRate.toStringAsFixed(1)}% de este saldo de forma natural antes de la caducidad. El ${_riesgo.toStringAsFixed(1)}% presenta riesgo remanente.',
                          style: const TextStyle(
                              color: _texto, fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _burnRate / 100,
                            minHeight: 12,
                            backgroundColor: _bord,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_burnRate > 70
                                    ? _green
                                    : _burnRate > 40
                                        ? _gold
                                        : _red),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                            'Proyección: ${_burnRate.toStringAsFixed(1)}% consumo natural | ${_riesgo.toStringAsFixed(1)}% riesgo remanente',
                            style: const TextStyle(
                                color: _sec,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Termometro Certificacion OEA ──
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _bord)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined,
                                color: _blue, size: 24),
                            const SizedBox(width: 12),
                            const Text('Termómetro Certificación OEA/IVA',
                                style: TextStyle(
                                    color: _texto,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: _green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _green.withValues(alpha: 0.3))),
                              child: const Text('ESTATUS SEGURO',
                                  style: TextStyle(
                                      color: _green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _discrepancia > 0 ? 0.6 : 0.1,
                            minHeight: 12,
                            backgroundColor: _bord,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _discrepancia > 0 ? _red : _green),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              'Discrepancia detectada: \$${_discrepancia.toStringAsFixed(2)} MXN',
                              style: const TextStyle(
                                  color: _sec,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── 4 KPI cards ──
                  Row(
                    children: [
                      _kpiCard(Icons.account_balance_wallet_outlined,
                          'Saldo Inicial (Mes)', _saldoInicial, _sec),
                      const SizedBox(width: 16),
                      _kpiCard(Icons.arrow_downward, 'Nuevos Cargos (IN)',
                          _cargos, _blue),
                      const SizedBox(width: 16),
                      _kpiCard(Icons.arrow_upward, 'Descargos (OUT)',
                          _descargos, _green),
                      const SizedBox(width: 16),
                      _kpiCard(Icons.attach_money, 'Saldo Final Pendiente',
                          _saldoFinal, _gold),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Bottom row: chart + riesgo ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _bord)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tendencia de Descargos (Retornos)',
                                  style: TextStyle(
                                      color: _texto,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 200,
                                child: CustomPaint(
                                  painter: _TendenciaPainter(_tendencia),
                                  size: const Size(double.infinity, 200),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Riesgo de Vencimiento
                      SizedBox(
                        width: 360,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _bord)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.timer_off_outlined,
                                      color: _red, size: 24),
                                  SizedBox(width: 12),
                                  Text('Riesgo de Vencimiento',
                                      style: TextStyle(
                                          color: _red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                  'Pedimentos próximos a vencer su plazo de retorno (18 meses).',
                                  style: TextStyle(
                                      color: _sec, fontSize: 14, height: 1.5)),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: _green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: _green, size: 16),
                                    SizedBox(width: 8),
                                    Text('No hay riesgos inminentes.',
                                        style: TextStyle(
                                            color: _green,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                              '📄 Estado de Cuenta SAT descargado'),
                                          backgroundColor: _card)),
                                  icon: const Icon(Icons.download, size: 16),
                                  label: const Text(
                                      'Descargar Estado de Cuenta SAT',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _gold,
                                    side: const BorderSide(
                                        color: _gold, width: 2),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(IconData icon, String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bord)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(label,
                        style: const TextStyle(
                            color: _sec,
                            fontSize: 12,
                            fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(_fmt(value),
                    style: TextStyle(
                        color: color,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Text('MXN',
                    style: TextStyle(
                        color: _sec,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gráfica de Tendencia (CustomPainter) ──
class _TendenciaPainter extends CustomPainter {
  final List<double> data;
  _TendenciaPainter(this.data);

  static const List<String> _months = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun'
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double maxVal = data.isEmpty ? 1 : data.reduce(math.max);
    const double padL = 20;
    const double padR = 20;
    const double padT = 20;
    const double padB = 40;
    final double w = size.width - padL - padR;
    final double h = size.height - padT - padB;

    final dashedPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Grid horizontal lines (4 lines)
    for (int r = 0; r <= 3; r++) {
      final y = padT + h - (r / 3) * h;
      _drawDashed(canvas, Offset(padL, y), Offset(padL + w, y), dashedPaint);
    }

    // Month labels and vertical lines
    const textStyle = TextStyle(
        color: AppColors.sub, fontSize: 12, fontWeight: FontWeight.bold);
    for (int i = 0; i < _months.length; i++) {
      final x = padL + (i / (_months.length - 1)) * w;
      // Vertical dashed line
      _drawDashed(canvas, Offset(x, padT), Offset(x, padT + h), dashedPaint);
      // Label
      final tp = TextPainter(
          text: TextSpan(text: _months[i], style: textStyle),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, padT + h + 16));
    }

    if (maxVal <= 0) return;

    // Gradient fill
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padL + (i / (data.length - 1)) * w;
      final y = padT + h - (data[i] / maxVal) * h;
      points.add(Offset(x, y));
    }

    if (points.length >= 2) {
      // Fill
      final fillPath = Path()..moveTo(points.first.dx, padT + h);
      for (final p in points) {
        fillPath.lineTo(p.dx, p.dy);
      }
      fillPath.lineTo(points.last.dx, padT + h);
      fillPath.close();

      final grad = LinearGradient(colors: [
        AppColors.gold.withValues(alpha: 0.3),
        AppColors.gold.withValues(alpha: 0.0)
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      canvas.drawPath(
          fillPath,
          Paint()
            ..shader =
                grad.createShader(Rect.fromLTWH(0, padT, size.width, h)));

      // Line
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(
          linePath,
          Paint()
            ..color = AppColors.gold
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);

      // Dots
      for (final p in points) {
        canvas.drawCircle(p, 6, Paint()..color = AppColors.gold);
        canvas.drawCircle(p, 3, Paint()..color = AppColors.card);
      }
    }
  }

  void _drawDashed(Canvas c, Offset p1, Offset p2, Paint paint) {
    const double dashLen = 6;
    const double gapLen = 6;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    final unitX = dx / len;
    final unitY = dy / len;
    double pos = 0;
    bool draw = true;
    while (pos < len) {
      final seg = draw ? dashLen : gapLen;
      final end = math.min(pos + seg, len);
      if (draw) {
        c.drawLine(Offset(p1.dx + unitX * pos, p1.dy + unitY * pos),
            Offset(p1.dx + unitX * end, p1.dy + unitY * end), paint);
      }
      pos = end;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(_TendenciaPainter old) => old.data != data;
}
