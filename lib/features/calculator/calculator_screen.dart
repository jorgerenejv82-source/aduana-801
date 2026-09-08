import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/tc_live_badge.dart';
import '../../core/services/tc_service.dart';
import 'package:firebase_ai/firebase_ai.dart';

// â”€â”€ Design Tokens â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _card2 = Color(0xFF13233E);
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold; // gold
const Color _rojo = AppColors.red;
const Color _verde = AppColors.green;

// â”€â”€ Historical data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const _historico = [
  {'fecha': '2026-06-03', 'valor': 17.3456, 'hoy': true},
  {'fecha': '2026-06-02', 'valor': 17.2891, 'hoy': false},
  {'fecha': '2026-05-30', 'valor': 17.3120, 'hoy': false},
  {'fecha': '2026-05-29', 'valor': 17.4087, 'hoy': false},
  {'fecha': '2026-05-28', 'valor': 17.3899, 'hoy': false},
  {'fecha': '2026-05-27', 'valor': 17.3512, 'hoy': false},
  {'fecha': '2026-05-26', 'valor': 17.2764, 'hoy': false},
  {'fecha': '2026-05-23', 'valor': 17.1953, 'hoy': false},
  {'fecha': '2026-05-22', 'valor': 17.2435, 'hoy': false},
  {'fecha': '2026-05-21', 'valor': 17.3081, 'hoy': false},
];

// â”€â”€ Multi-currency rates to MXN â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
List<Map<String, dynamic>> _getDivisas() {
  final r = TcService().crossRates;
  return [
    {
      'code': 'USD',
      'nombre': 'Dólar Americano',
      'simbolo': '\$',
      'tc': r['USD'] ?? 17.3456
    },
    {
      'code': 'EUR',
      'nombre': 'Euro',
      'simbolo': 'â‚¬',
      'tc': r['EUR'] ?? 19.1283
    },
    {
      'code': 'GBP',
      'nombre': 'Libra Esterlina',
      'simbolo': 'Â£',
      'tc': r['GBP'] ?? 22.4878
    },
    {
      'code': 'JPY',
      'nombre': 'Yen Japonés',
      'simbolo': 'Â¥',
      'tc': r['JPY'] ?? 0.1154
    },
    {
      'code': 'CNY',
      'nombre': 'Yuan Chino',
      'simbolo': 'Â¥',
      'tc': r['CNY'] ?? 2.3981
    },
    {
      'code': 'CAD',
      'nombre': 'Dólar Canadiense',
      'simbolo': 'C\$',
      'tc': r['CAD'] ?? 12.8745
    },
  ];
}

// â”€â”€ Main Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class TipoCambioScreen extends StatefulWidget {
  const TipoCambioScreen({super.key});
  @override
  State<TipoCambioScreen> createState() => _TipoCambioScreenState();
}

class _TipoCambioScreenState extends State<TipoCambioScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _showAI = false;
  late final Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = TcService().fetchTc();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: FutureBuilder(
          future: _fetchFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: _ambar));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: _rojo)));
            }
            return Column(children: [
              // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              DecoratedBox(
                decoration: const BoxDecoration(
                    color: _bg,
                    border: Border(bottom: BorderSide(color: _bord))),
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(children: [
                        InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: _card,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _bord)),
                                child: const Icon(Icons.chevron_left,
                                    color: _texto, size: 24))),
                        const SizedBox(width: 16),
                        Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: _ambar.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _ambar.withValues(alpha: 0.3))),
                            child: const Icon(Icons.currency_exchange,
                                color: _ambar, size: 20)),
                        const SizedBox(width: 12),
                        const Text('Tipo de Cambio',
                            style: TextStyle(
                                color: _texto,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: _verde.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _verde.withValues(alpha: 0.4))),
                            child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, color: _verde, size: 8),
                                  SizedBox(width: 6),
                                  Text('DOF',
                                      style: TextStyle(
                                          color: _verde,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ])),
                      ])),
                  TabBar(
                    controller: _tabs,
                    indicatorColor: _ambar,
                    indicatorWeight: 3,
                    labelColor: _ambar,
                    unselectedLabelColor: _sec,
                    labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                    unselectedLabelStyle:
                        const TextStyle(fontSize: 12, letterSpacing: 0.5),
                    tabs: const [
                      Tab(
                          icon: Icon(Icons.trending_up, size: 18),
                          text: 'TC ADUANAL'),
                      Tab(
                          icon: Icon(Icons.history, size: 18),
                          text: 'HISTÃ“RICO'),
                      Tab(
                          icon: Icon(Icons.swap_horiz, size: 18),
                          text: 'CONVERSOR'),
                    ],
                  ),
                ]),
              ),
              Expanded(
                  child: TabBarView(controller: _tabs, children: [
                _TabAduanal(onAI: () => setState(() => _showAI = !_showAI)),
                const _TabHistorico(),
                const _TabConversor(),
              ])),
            ]);
          }),
      bottomSheet: _showAI
          ? _AiSheet(onClose: () => setState(() => _showAI = false))
          : null,
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// TAB 1 â€” TC ADUANAL
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _TabAduanal extends StatelessWidget {
  final VoidCallback onAI;
  const _TabAduanal({required this.onAI});

  @override
  Widget build(BuildContext context) {
    final rates = TcService().crossRates;
    final usdMxn = rates['USD'] ?? 17.3456;
    final eurMxn = rates['EUR'] ?? 19.1283;
    final usdEur = usdMxn / eurMxn;
    final cadMxn = rates['CAD'] ?? 12.8745;
    final jpyMxn = rates['JPY'] ?? 0.1154;
    final isLive = TcService().isLive;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // FIX Card
          Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_card2, _bg],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
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
                    const Row(children: [
                      Text('Tipo de Cambio FIX â€” DOF',
                          style: TextStyle(
                              color: _sec,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Spacer(),
                      TcLiveBadge(),
                    ]),
                    const SizedBox(height: 12),
                    const Text('USD / MXN',
                        style: TextStyle(color: _sec, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('\$${usdMxn.toStringAsFixed(4)} MXN',
                        style: const TextStyle(
                            color: _ambar,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace')),
                    const SizedBox(height: 4),
                    const Text('MXN por cada dólar americano',
                        style: TextStyle(color: _sec, fontSize: 13)),
                    const SizedBox(height: 20),
                    Row(children: [
                      const Icon(Icons.calendar_today, color: _sec, size: 14),
                      const SizedBox(width: 8),
                      const Text('Fecha: 03/Jun/2026',
                          style: TextStyle(color: _sec, fontSize: 13)),
                      const Spacer(),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: isLive
                                  ? _verde.withValues(alpha: 0.15)
                                  : _rojo.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: isLive
                                      ? _verde.withValues(alpha: 0.4)
                                      : _rojo.withValues(alpha: 0.4))),
                          child: Text(isLive ? 'Live API' : 'Fallback',
                              style: TextStyle(
                                  color: isLive ? _verde : _rojo,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold))),
                    ]),
                  ])),
          const SizedBox(height: 24),
          // Tipos de referencia
          const Row(children: [
            Icon(Icons.show_chart, color: _ambar, size: 18),
            SizedBox(width: 8),
            Text('Tipos de Cambio de Referencia',
                style: TextStyle(
                    color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
            Spacer(),
            Text('03/06/2026', style: TextStyle(color: _sec, fontSize: 13))
          ]),
          const SizedBox(height: 16),
          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _bord)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      _flag('US'),
                      const SizedBox(width: 10),
                      const Text('USD / MXN',
                          style: TextStyle(color: _sec, fontSize: 14)),
                      const Spacer(),
                      _badge(0.0565)
                    ]),
                    const SizedBox(height: 12),
                    Text(usdMxn.toStringAsFixed(4),
                        style: const TextStyle(
                            color: _texto,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace')),
                    const SizedBox(height: 4),
                    const Text('MXN por cada dólar americano',
                        style: TextStyle(color: _sec, fontSize: 12)),
                  ])),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _smCard('EUR / MXN', eurMxn, 0.06, 'EU', 'MX')),
            const SizedBox(width: 12),
            Expanded(child: _smCard('USD / EUR', usdEur, -0.02, 'US', 'EU')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _smCard('CAD / MXN', cadMxn, -0.08, 'CA', 'MX')),
            const SizedBox(width: 12),
            Expanded(child: _smCard('JPY / MXN', jpyMxn, 0.12, 'JP', 'MX')),
          ]),
          const SizedBox(height: 24),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                  color: _ambar.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _ambar.withValues(alpha: 0.3))),
              child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: _ambar, size: 18),
                    SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            'Para efectos aduanales, usar el tipo de cambio publicado en el DOF del día hábil anterior a la presentación del pedimento.',
                            style: TextStyle(
                                color: _ambar, fontSize: 13, height: 1.5)))
                  ])),
          const SizedBox(height: 24),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                    onPressed: onAI,
                    icon: const Icon(Icons.auto_awesome, size: 18, color: _bg),
                    label: const Text('Consultar con Gemini AI',
                        style: TextStyle(
                            color: _bg,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _ambar,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0))),
          ),
          const SizedBox(height: 16),
          const Center(
              child: Text('Fuente: Banco de México â€“ DOF. Sólo referencial.',
                  style: TextStyle(color: _sec, fontSize: 11))),
        ]));
  }

  static Widget _smCard(String par, double v, double c, String f1, String f2) =>
      Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _bord)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _flag(f1),
              const SizedBox(width: 8),
              Text(par,
                  style: const TextStyle(
                      color: _sec, fontSize: 12, fontWeight: FontWeight.w500)),
              const Spacer(),
              _badge(c)
            ]),
            const SizedBox(height: 12),
            Text(v.toStringAsFixed(4),
                style: const TextStyle(
                    color: _texto,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace'))
          ]));
  static Widget _flag(String code) {
    final m = {
      'US': const Color(0xFF1D3461),
      'EU': const Color(0xFF003087),
      'MX': const Color(0xFF006847),
      'CA': const Color(0xFFD80621),
      'JP': const Color(0xFFD80621)
    };
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: (m[code] ?? _card).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4)),
        child: Text(code,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold)));
  }

  static Widget _badge(double v) {
    final pos = v >= 0;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: (pos ? _verde : _rojo).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(pos ? Icons.trending_up : Icons.trending_down,
              color: pos ? _verde : _rojo, size: 12),
          const SizedBox(width: 4),
          Text('${pos ? '+' : ''}${v.toStringAsFixed(4)}',
              style: TextStyle(
                  color: pos ? _verde : _rojo,
                  fontSize: 11,
                  fontWeight: FontWeight.bold))
        ]));
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// TAB 2 â€” HISTÃ“RICO
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _TabHistorico extends StatelessWidget {
  const _TabHistorico();

  @override
  Widget build(BuildContext context) {
    final vals = _historico.map((e) => e['valor'] as double).toList();
    final minV = vals.reduce(math.min);
    final maxV = vals.reduce(math.max);
    final avgV = vals.reduce((a, b) => a + b) / vals.length;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // â”€â”€ 3 KPI cards â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Row(children: [
            Expanded(child: _kpi('Mínimo 10D', minV, _verde)),
            const SizedBox(width: 12),
            Expanded(child: _kpi('Promedio 10D', avgV, _ambar)),
            const SizedBox(width: 12),
            Expanded(child: _kpi('Máximo 10D', maxV, _rojo)),
          ]),
          const SizedBox(height: 24),
          // â”€â”€ Chart card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _bord)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.area_chart, color: _ambar, size: 18),
                SizedBox(width: 10),
                Text('Evolución TC DOF (10 días hábiles)',
                    style: TextStyle(
                        color: _texto,
                        fontSize: 16,
                        fontWeight: FontWeight.bold))
              ]),
              const SizedBox(height: 24),
              SizedBox(
                  height: 180,
                  child: CustomPaint(
                      painter: _AmbarChartPainter(vals), size: Size.infinite)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_historico.last['fecha'] as String,
                    style: const TextStyle(
                        color: _sec, fontSize: 11, fontFamily: 'monospace')),
                Text(_historico.first['fecha'] as String,
                    style: const TextStyle(
                        color: _sec, fontSize: 11, fontFamily: 'monospace')),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          // â”€â”€ Tabla Histórica DOF â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          DecoratedBox(
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _bord)),
            child: Column(children: [
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(children: [
                    Icon(Icons.table_rows, color: _ambar, size: 18),
                    SizedBox(width: 10),
                    Text('Tabla Histórica DOF',
                        style: TextStyle(
                            color: _texto,
                            fontSize: 15,
                            fontWeight: FontWeight.bold))
                  ])),
              const Divider(color: _bord, height: 1),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(children: [
                    Text('Fecha',
                        style: TextStyle(
                            color: _sec,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Spacer(),
                    Text('TC DOF (MXN/USD)',
                        style: TextStyle(
                            color: _sec,
                            fontSize: 13,
                            fontWeight: FontWeight.w600))
                  ])),
              const Divider(color: _bord, height: 1),
              ...List.generate(_historico.length, (i) {
                final e = _historico[i];
                final val = e['valor'] as double;
                final hoy = e['hoy'] as bool;
                final prev = i < _historico.length - 1
                    ? _historico[i + 1]['valor'] as double
                    : val;
                final diff = val - prev;
                final pos = diff >= 0;
                return Container(
                  decoration: BoxDecoration(
                      color: hoy
                          ? _ambar.withValues(alpha: 0.1)
                          : Colors.transparent,
                      border: i < _historico.length - 1
                          ? const Border(bottom: BorderSide(color: _bord))
                          : null),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(children: [
                    if (hoy)
                      Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                              color: _ambar,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text('HOY',
                              style: TextStyle(
                                  color: _bg,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold))),
                    Text(e['fecha'] as String,
                        style: TextStyle(
                            color: hoy ? _ambar : _texto,
                            fontSize: 14,
                            fontWeight:
                                hoy ? FontWeight.bold : FontWeight.normal,
                            fontFamily: 'monospace')),
                    const Spacer(),
                    Text(val.toStringAsFixed(4),
                        style: TextStyle(
                            color: hoy ? _ambar : _texto,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace')),
                    const SizedBox(width: 20),
                    SizedBox(
                        width: 80,
                        child: Text(
                            i == _historico.length - 1
                                ? 'â€”'
                                : '${pos ? '+' : ''}${diff.toStringAsFixed(4)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: i == _historico.length - 1
                                    ? _sec
                                    : pos
                                        ? _verde
                                        : _rojo,
                                fontSize: 12,
                                fontFamily: 'monospace'))),
                  ]),
                );
              }),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _bord)),
              child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.flag_outlined, color: _sec, size: 16),
                    SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            'Fuente: Banco de México â€“ DOF. Sólo referencial. Verifique el tipo de cambio oficial del día de presentación del pedimento en el Diario Oficial de la Federación (DOF) o en el portal de Banxico.',
                            style: TextStyle(
                                color: _sec, fontSize: 12, height: 1.5)))
                  ])),
        ]));
  }

  Widget _kpi(String l, double v, Color c) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _bord)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l,
            style: const TextStyle(
                color: _sec, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(v.toStringAsFixed(4),
            style: TextStyle(
                color: c,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace'))
      ]));
}

// â”€â”€ Amber chart painter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _AmbarChartPainter extends CustomPainter {
  final List<double> values;
  const _AmbarChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final reversed = values.reversed.toList();
    final minV = reversed.reduce(math.min) - 0.02;
    final maxV = reversed.reduce(math.max) + 0.02;
    final range = maxV - minV;
    const pad = EdgeInsets.fromLTRB(48, 8, 16, 24);
    final w = size.width - pad.left - pad.right;
    final h = size.height - pad.top - pad.bottom;

    Offset pt(int i) {
      final x = pad.left + (i / (reversed.length - 1)) * w;
      final y = pad.top + (1 - (reversed[i] - minV) / range) * h;
      return Offset(x, y);
    }

    // Grid lines + labels
    final gridP = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    const labelStyle =
        TextStyle(color: AppColors.sub, fontSize: 11, fontFamily: 'monospace');
    for (int i = 0; i <= 4; i++) {
      final y = pad.top + i * h / 4;
      canvas.drawLine(
          Offset(pad.left, y), Offset(size.width - pad.right, y), gridP);
      final val = maxV - i * range / 4;
      final tp = TextPainter(
          text: TextSpan(text: val.toStringAsFixed(2), style: labelStyle),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Fill gradient
    final fillPath = Path()..moveTo(pt(0).dx, size.height - pad.bottom);
    for (int i = 0; i < reversed.length; i++) {
      fillPath.lineTo(pt(i).dx, pt(i).dy);
    }
    fillPath
      ..lineTo(pt(reversed.length - 1).dx, size.height - pad.bottom)
      ..close();
    canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(colors: [
            AppColors.gold.withValues(alpha: 0.3),
            AppColors.gold.withValues(alpha: 0)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
              .createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Line
    final linePath = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (int i = 1; i < reversed.length; i++) {
      linePath.lineTo(pt(i).dx, pt(i).dy);
    }
    canvas.drawPath(
        linePath,
        Paint()
          ..color = AppColors.gold
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke);

    // Dots on last + first
    canvas.drawCircle(pt(0), 6, Paint()..color = AppColors.gold);
    canvas.drawCircle(
        pt(reversed.length - 1), 6, Paint()..color = AppColors.gold);

    // Value labels on endpoints
    const valStyle = TextStyle(
        color: AppColors.gold,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace');
    void labelAt(int i, {bool rightAlign = false}) {
      final p = pt(i);
      final txt = TextPainter(
          text: TextSpan(text: reversed[i].toStringAsFixed(4), style: valStyle),
          textDirection: TextDirection.ltr)
        ..layout();
      txt.paint(
          canvas,
          Offset(rightAlign ? p.dx - txt.width - 6 : p.dx + 6,
              p.dy - txt.height - 4));
    }

    labelAt(0);
    labelAt(reversed.length - 1, rightAlign: true);
  }

  @override
  bool shouldRepaint(_AmbarChartPainter old) => old.values != values;
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// TAB 3 â€” CONVERSOR MULTI-DIVISA
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _TabConversor extends StatefulWidget {
  const _TabConversor();
  @override
  State<_TabConversor> createState() => _TabConversorState();
}

class _TabConversorState extends State<_TabConversor> {
  final _ctrl = TextEditingController(text: '');
  int _selIdx = 0;

  double get _monto => double.tryParse(_ctrl.text.replaceAll(',', '')) ?? 0;
  double get _tcSel => _getDivisas()[_selIdx]['tc'] as double;

  @override
  Widget build(BuildContext context) {
    final divisas = _getDivisas();
    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // â”€â”€ Conversor Multi-Divisa â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _bord)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.swap_horiz, color: _ambar, size: 20),
                      SizedBox(width: 10),
                      Text('Conversor Multi-Divisa',
                          style: TextStyle(
                              color: _texto,
                              fontSize: 16,
                              fontWeight: FontWeight.bold))
                    ]),
                    const SizedBox(height: 24),
                    // Input monto
                    const Text('Monto a convertir',
                        style: TextStyle(
                            color: _sec,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ctrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                          color: _texto,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace'),
                      decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: const TextStyle(color: _sec, fontSize: 18),
                          filled: true,
                          fillColor: _bg,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _bord)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _bord)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _ambar))),
                    ),
                    const SizedBox(height: 20),
                    // Currency selector
                    const Text('Divisa origen',
                        style: TextStyle(
                            color: _sec,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(divisas.length, (i) {
                          final d = divisas[i];
                          final active = _selIdx == i;
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => setState(() => _selIdx = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                    color: active
                                        ? _ambar.withValues(alpha: 0.15)
                                        : _bg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: active ? _ambar : _bord,
                                        width: active ? 2 : 1)),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(d['code'] as String,
                                          style: TextStyle(
                                              color: active ? _ambar : _texto,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(d['simbolo'] as String,
                                          style: TextStyle(
                                              color: active
                                                  ? _ambar.withValues(
                                                      alpha: 0.8)
                                                  : _sec,
                                              fontSize: 12)),
                                    ]),
                              ),
                            ),
                          );
                        })),
                    // Result
                    if (_monto > 0) ...[
                      const SizedBox(height: 24),
                      const Divider(color: _bord, height: 1),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  '${_monto.toStringAsFixed(2)} ${divisas[_selIdx]['code']}',
                                  style: const TextStyle(
                                      color: _sec, fontSize: 15)),
                              const SizedBox(height: 4),
                              const Text('=',
                                  style: TextStyle(color: _sec, fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(
                                  '\$ ${(_monto * _tcSel).toStringAsFixed(2)} MXN',
                                  style: const TextStyle(
                                      color: _ambar,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace')),
                            ])),
                        Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: _ambar.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _ambar.withValues(alpha: 0.3))),
                            child: Column(children: [
                              const Text('TC Aplicado',
                                  style: TextStyle(
                                      color: _ambar,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(_tcSel.toStringAsFixed(4),
                                  style: const TextStyle(
                                      color: _ambar,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace')),
                              const SizedBox(height: 2),
                              const Text('MXN',
                                  style:
                                      TextStyle(color: _ambar, fontSize: 11)),
                            ])),
                      ]),
                    ],
                  ])),
          const SizedBox(height: 24),
          // â”€â”€ Referencia Rápida â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          DecoratedBox(
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _bord)),
            child: Column(children: [
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(children: [
                    Icon(Icons.bolt, color: _ambar, size: 18),
                    SizedBox(width: 10),
                    Text('Referencia Rápida',
                        style: TextStyle(
                            color: _texto,
                            fontSize: 15,
                            fontWeight: FontWeight.bold))
                  ])),
              const Divider(color: _bord, height: 1),
              ...divisas.asMap().entries.map((entry) {
                final i = entry.key;
                final d = entry.value;
                final active = _selIdx == i;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _selIdx = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                          color: active
                              ? _ambar.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: i < divisas.length - 1
                              ? const Border(bottom: BorderSide(color: _bord))
                              : null),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      child: Row(children: [
                        SizedBox(
                            width: 48,
                            child: Text(d['code'] as String,
                                style: TextStyle(
                                    color: active ? _ambar : _texto,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace'))),
                        const SizedBox(width: 12),
                        Text(d['nombre'] as String,
                            style: const TextStyle(color: _sec, fontSize: 14)),
                        const Spacer(),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: (d['tc'] as double).toStringAsFixed(4),
                              style: TextStyle(
                                  color: active ? _ambar : _texto,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace')),
                          const TextSpan(
                              text: '  MXN',
                              style: TextStyle(
                                  color: AppColors.sub, fontSize: 12)),
                        ])),
                      ]),
                    ),
                  ),
                );
              }),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _bord)),
              child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.flag_outlined, color: _sec, size: 16),
                    SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            'Fuente: Banco de México â€“ DOF. Sólo referencial. Verifique el tipo de cambio oficial del día de presentación del pedimento en el DOF o en el portal de Banxico.',
                            style: TextStyle(
                                color: _sec, fontSize: 12, height: 1.5)))
                  ])),
        ]));
  }
}

// â”€â”€ AI Bottom Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _AiSheet extends StatefulWidget {
  final VoidCallback onClose;
  const _AiSheet({required this.onClose});
  @override
  State<_AiSheet> createState() => _AiSheetState();
}

class _AiSheetState extends State<_AiSheet> {
  bool _loading = true;
  String _answer = '';

  @override
  void initState() {
    super.initState();
    _query();
  }

  Future<void> _query() async {
    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un calculador de impuestos de importacion de Mexico. Dados: valor FOB (USD), tipo de cambio, incoterm, fraccion arancelaria, y tipo de arancel (%, ESP, CTA), calcula: Valor en aduana, Arancel (IGI), IVA, DTA, y total a pagar. Muestra el calculo paso a paso. Responde en JSON: {valorAduana, igi, iva, dta, isan, ieps, total, desglose: [{concepto, base, tasa, importe}]}'),
      );
      final response = await model.generateContent([
        Content.text(
            'Calcula los impuestos para un FOB de 10,000 USD, TC 18.50, Incoterm EXW, fraccion 8544.42.01, arancel 15%.')
      ]);
      setState(() {
        _loading = false;
        _answer = response.text ?? 'Sin respuesta';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _answer = 'Error de IA: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 340,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: _bord))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome, color: _ambar, size: 20),
            const SizedBox(width: 12),
            const Text('Gemini AI â€” Tipo de Cambio',
                style: TextStyle(
                    color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: _sec, size: 20))
          ]),
          const Divider(color: _bord, height: 24),
          Expanded(
              child: _loading
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          CircularProgressIndicator(
                              color: _ambar, strokeWidth: 3),
                          SizedBox(height: 16),
                          Text('Consultando normativa aduanera...',
                              style: TextStyle(color: _sec, fontSize: 14))
                        ])
                  : SingleChildScrollView(
                      child: Text(_answer,
                          style: const TextStyle(
                              color: _texto, fontSize: 14, height: 1.7)))),
        ]));
  }
}
