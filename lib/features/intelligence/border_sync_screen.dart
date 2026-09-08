import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _verde = AppColors.green;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;

class _Truck {
  final String id;
  final Color color;
  double x;
  double y;
  final String status;
  _Truck(this.id, this.color, this.x, this.y, this.status);
}

class BorderSyncScreen extends StatefulWidget {
  const BorderSyncScreen({super.key});
  @override
  State<BorderSyncScreen> createState() => _BorderSyncScreenState();
}

class _BorderSyncScreenState extends State<BorderSyncScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweepCtrl;
  _Truck? _selected;
  bool _btnHovered = false;

  final List<_Truck> _trucks = [
    _Truck('TRK-01A', _azul, -0.42, 0.28, 'EN TRANSITO'),
    _Truck('TRK-05B', _verde, 0.04, 0.02, 'EN ADUANA'),
    _Truck('TRK-09C', _rojo, 0.38, -0.06, 'RETENIDO'),
  ];

  @override
  void initState() {
    super.initState();
    _sweepCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _sweepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: _bg,
            child: Row(children: [
              InkWell(
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go('/home'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _bord)),
                      child: const Icon(Icons.chevron_left,
                          color: _ambar, size: 20))),
              const SizedBox(width: 14),
              const Text('Border-Sync Command Center',
                  style: TextStyle(
                      color: _ambar,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _verde.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _verde.withValues(alpha: 0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.circle, color: _verde, size: 8),
                    const SizedBox(width: 6),
                    Text('${_trucks.length} unidades activas',
                        style: const TextStyle(
                            color: _verde,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ])),
            ])),
        const Divider(height: 1, color: _bord),
        Expanded(
            child: Stack(children: [
          AnimatedBuilder(
              animation: _sweepCtrl,
              builder: (_, __) => CustomPaint(
                    painter: _RadarPainter(_sweepCtrl.value, _trucks),
                    child: Container(color: Colors.transparent),
                  )),
          LayoutBuilder(builder: (_, box) {
            return Stack(
                children: _trucks.map((t) {
              final px = box.maxWidth / 2 + t.x * box.maxWidth * 0.4;
              final py = box.maxHeight / 2 + t.y * box.maxHeight * 0.4;
              return Positioned(
                left: px - 20,
                top: py - 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _selected = _selected?.id == t.id ? null : t),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: t.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: t.color,
                              width: _selected?.id == t.id ? 3 : 2),
                          boxShadow: _selected?.id == t.id
                              ? [
                                  BoxShadow(
                                      color: t.color.withValues(alpha: 0.4),
                                      blurRadius: 8)
                                ]
                              : [],
                        ),
                        child: Icon(Icons.local_shipping,
                            color: t.color, size: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(t.id,
                          style: TextStyle(
                              color: t.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
              );
            }).toList());
          }),
          Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 60),
            Text('ADUANA\nNUEVO LAREDO',
                style: TextStyle(
                    color: _ambar.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
                textAlign: TextAlign.center),
          ])),
          if (_selected != null)
            Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _selected!.color.withValues(alpha: 0.5),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10)
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.local_shipping,
                              color: _selected!.color, size: 20),
                          const SizedBox(width: 8),
                          Text(_selected!.id,
                              style: TextStyle(
                                  color: _selected!.color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const Spacer(),
                          GestureDetector(
                              onTap: () => setState(() => _selected = null),
                              child: const Icon(Icons.close,
                                  color: _sec, size: 18)),
                        ]),
                        const SizedBox(height: 12),
                        _truckRow('Status', _selected!.status),
                        _truckRow('Pedimento',
                            '26 8301 ${_selected!.id.replaceAll('-', '')}'),
                        _truckRow('Origen', 'Monterrey, NL'),
                        _truckRow('Destino', 'Nuevo Laredo, Tam'),
                        _truckRow('ETA', 'Hoy 22:30h'),
                        const SizedBox(height: 12),
                        if (_selected!.status == 'RETENIDO')
                          MouseRegion(
                            onEnter: (_) => setState(() => _btnHovered = true),
                            onExit: (_) => setState(() => _btnHovered = false),
                            child: GestureDetector(
                              onTap: () => ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Alerta enviada al agente aduanal'))),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _btnHovered
                                      ? const Color(0xFFDC2626)
                                      : _rojo,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.warning_amber,
                                        size: 16, color: _texto),
                                    SizedBox(width: 8),
                                    Text('Alertar Agente',
                                        style: TextStyle(
                                            color: _texto,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          )
                      ]),
                )),
          Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _bord)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('LEYENDA',
                          style: TextStyle(
                              color: _ambar,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                      const SizedBox(height: 8),
                      _leyenda(_azul, 'En Transito'),
                      _leyenda(_verde, 'En Aduana'),
                      _leyenda(_rojo, 'Retenido'),
                    ]),
              )),
        ])),
      ]),
    );
  }

  Widget _truckRow(String l, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(
            width: 80,
            child: Text(l, style: const TextStyle(color: _sec, fontSize: 12))),
        Expanded(
            child: Text(v,
                style: const TextStyle(
                    color: _texto, fontSize: 12, fontWeight: FontWeight.bold))),
      ]));

  Widget _leyenda(Color c, String l) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 4)
                ])),
        const SizedBox(width: 8),
        Text(l, style: const TextStyle(color: _sec, fontSize: 11)),
      ]));
}

class _RadarPainter extends CustomPainter {
  final double sweep;
  final List<_Truck> trucks;
  _RadarPainter(this.sweep, this.trucks);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final gridP = Paint()
      ..color = _bord
      ..strokeWidth = 0.6;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridP);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }

    final ringP = Paint()
      ..color = _bord
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(
          Offset(cx, cy), i * math.min(size.width, size.height) / 8, ringP);
    }

    final sweepAngle = sweep * 2 * math.pi - math.pi / 2;
    final beamPaint = Paint()
      ..shader = RadialGradient(colors: [
        _ambar.withValues(alpha: 0.15),
        Colors.transparent
      ]).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: size.width * 0.5));
    final beamPath = Path()
      ..moveTo(cx, cy)
      ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: size.width * 0.5),
          sweepAngle - 0.6, 0.6, false)
      ..close();
    canvas.drawPath(beamPath, beamPaint);

    canvas.drawCircle(Offset(cx, cy), 8, Paint()..color = _verde);
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = _bg);
  }

  @override
  bool shouldRepaint(_RadarPainter o) => o.sweep != sweep;
}
