import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

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

class _Ruta {
  final String id;
  final String origen;
  final String destino;
  final String modo;
  final int transitDays;
  final double costUsd;
  final String naviera;
  final List<String> puertosEscala;
  final String riesgo;
  final List<String> ventajas;
  const _Ruta(
      {required this.id,
      required this.origen,
      required this.destino,
      required this.modo,
      required this.transitDays,
      required this.costUsd,
      required this.naviera,
      required this.puertosEscala,
      required this.riesgo,
      required this.ventajas});
}

const _rutasMaestras = <_Ruta>[
  _Ruta(
      id: 'R01',
      origen: 'Shanghai (CNSHA)',
      destino: 'Manzanillo (MZMZL)',
      modo: 'Maritimo FCL',
      transitDays: 28,
      costUsd: 2800,
      naviera: 'MAERSK/MSC',
      puertosEscala: ['Long Beach (USLAX)', 'Manzanillo (MZMZL)'],
      riesgo: 'BAJO',
      ventajas: [
        'Ruta directa disponible',
        'Frecuencia semanal',
        'Sin transshipment'
      ]),
  _Ruta(
      id: 'R02',
      origen: 'Shanghai (CNSHA)',
      destino: 'Lazaro Cardenas (MZLZC)',
      modo: 'Maritimo FCL',
      transitDays: 24,
      costUsd: 2600,
      naviera: 'COSCO/Evergreen',
      puertosEscala: ['Lazaro Cardenas (MZLZC)'],
      riesgo: 'BAJO',
      ventajas: [
        'Puerto mas cercano a CDMX',
        'Menor congestion',
        'Sin reexpedicion'
      ]),
  _Ruta(
      id: 'R03',
      origen: 'Hamburg (DEHAM)',
      destino: 'Veracruz (MZVER)',
      modo: 'Maritimo FCL',
      transitDays: 22,
      costUsd: 3200,
      naviera: 'Hapag-Lloyd',
      puertosEscala: ['Le Havre (FRLEH)', 'Veracruz (MZVER)'],
      riesgo: 'BAJO',
      ventajas: [
        'Conexion Europa directa',
        'Sin transshipment',
        'Buena frecuencia'
      ]),
  _Ruta(
      id: 'R04',
      origen: 'Los Angeles (USLAX)',
      destino: 'Nuevo Laredo (MZNLD)',
      modo: 'Terrestre',
      transitDays: 4,
      costUsd: 3800,
      naviera: 'Transportes',
      puertosEscala: ['El Paso TX', 'Ciudad Juarez', 'Monterrey'],
      riesgo: 'MEDIO',
      ventajas: [
        'Rapido y flexible',
        'Door-to-door posible',
        'Sin demoras maritimas'
      ]),
];

const _alertasRutas = [
  (
    'Panama Canal',
    'Restricciones de calado por sequías. Demoras de 7-14 días adicionales.',
    _rojo
  ),
  (
    'Long Beach Port',
    'Congestión moderada. Tiempo de descarga: 3-5 días extra.',
    _naran
  ),
  (
    'Manzanillo',
    'Huelga programada IMSS/STPS: Verificar semana del 15-20.',
    _ambar
  ),
];

class RutasGlobalesScreen extends StatefulWidget {
  const RutasGlobalesScreen({super.key});
  @override
  State<RutasGlobalesScreen> createState() => _RutasGlobalesScreenState();
}

class _RutasGlobalesScreenState extends State<RutasGlobalesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  String _filtroModo = 'Todos';
  String _filtroRiesgo = 'Todos';
  _Ruta? _rutaSel;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<_Ruta> get _filtradas {
    var r = _rutasMaestras.toList();
    if (_filtroModo != 'Todos') {
      r = r.where((x) => x.modo.contains(_filtroModo)).toList();
    }
    if (_filtroRiesgo != 'Todos') {
      r = r.where((x) => x.riesgo == _filtroRiesgo).toList();
    }
    return r;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                      color: _azul.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _azul.withValues(alpha: 0.3))),
                  child: const Icon(Icons.public, color: _azul, size: 18)),
              const SizedBox(width: 12),
              const Expanded(
                  child: Text('Rutas Globales',
                      style: TextStyle(
                          color: _ambar,
                          fontSize: 16,
                          fontWeight: FontWeight.bold))),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _rojo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _rojo.withValues(alpha: 0.3))),
                  child: Row(children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: _ambar, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('1 Alerta activa',
                        style: TextStyle(
                            color: _ambar,
                            fontSize: 12,
                            fontWeight: FontWeight.bold))
                  ])),
            ],
          ),
          bottom: TabBar(
            controller: _tabCtrl,
            indicatorColor: _azul,
            labelColor: _azul,
            unselectedLabelColor: _sec,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(icon: Icon(Icons.route), text: 'Rutas'),
              Tab(
                  icon: Icon(Icons.warning_amber_rounded),
                  text: 'Alertas Portuarias'),
              Tab(icon: Icon(Icons.compare_arrows), text: 'Comparador'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [_tabRutas(), _tabAlertas(), _tabComparador()],
        ),
      );

  Widget _tabRutas() => Column(children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: _bg,
            child: Row(children: [
              Expanded(
                  child: _chipRow(
                      'Modo',
                      ['Todos', 'Maritimo', 'Aereo', 'Terrestre'],
                      _filtroModo,
                      (v) => setState(() {
                            _filtroModo = v;
                            _rutaSel = null;
                          }))),
              const SizedBox(width: 16),
              _chipRow(
                  'Riesgo',
                  ['Todos', 'BAJO', 'MEDIO', 'ALTO'],
                  _filtroRiesgo,
                  (v) => setState(() {
                        _filtroRiesgo = v;
                        _rutaSel = null;
                      })),
            ])),
        Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 360,
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _filtradas.length,
                itemBuilder: (_, i) {
                  final r = _filtradas[i];
                  final sel = _rutaSel?.id == r.id;
                  final rc = r.riesgo == 'BAJO'
                      ? _verde
                      : r.riesgo == 'MEDIO'
                          ? _ambar
                          : _rojo;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setState(() => _rutaSel = r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: sel ? _card : _bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: sel ? _azul : _bord),
                            boxShadow: sel
                                ? [
                                    BoxShadow(
                                        color: _azul.withValues(alpha: 0.2),
                                        blurRadius: 10)
                                  ]
                                : []),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(_modoIcon(r.modo), color: _azul, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(r.modo,
                                        style: const TextStyle(
                                            color: _sec,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold))),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: rc.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: rc.withValues(alpha: 0.3))),
                                    child: Text(r.riesgo,
                                        style: TextStyle(
                                            color: rc,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold))),
                              ]),
                              const SizedBox(height: 12),
                              Text(r.origen,
                                  style: const TextStyle(
                                      color: _texto,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis),
                              Row(children: [
                                const Icon(Icons.arrow_downward,
                                    color: _sec, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                    child: Text(r.destino,
                                        style: const TextStyle(
                                            color: _verde,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis))
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                _chip(
                                    Icons.schedule, '${r.transitDays}d', _sec),
                                const SizedBox(width: 12),
                                _chip(
                                    Icons.attach_money,
                                    '\$${r.costUsd.toStringAsFixed(0)}',
                                    _verde),
                              ]),
                            ]),
                      ),
                    ),
                  );
                },
              )),
          Expanded(
              child: _rutaSel == null
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(Icons.route,
                              color: _sec.withValues(alpha: 0.3), size: 80),
                          const SizedBox(height: 24),
                          const Text('Selecciona una ruta para ver el detalle.',
                              style: TextStyle(
                                  color: _sec,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))
                        ]))
                  : _detailPanel(_rutaSel!)),
        ])),
      ]);

  Widget _detailPanel(_Ruta r) {
    final rc = r.riesgo == 'BAJO'
        ? _verde
        : r.riesgo == 'MEDIO'
            ? _ambar
            : _rojo;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _azul.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(color: _azul.withValues(alpha: 0.1), blurRadius: 10)
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(_modoIcon(r.modo), color: _azul, size: 24),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(r.modo,
                        style: const TextStyle(
                            color: _azul,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: rc.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: rc.withValues(alpha: 0.3))),
                    child: Text('Riesgo ${r.riesgo}',
                        style: TextStyle(
                            color: rc,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)))
              ]),
              const SizedBox(height: 20),
              Text(r.origen,
                  style: const TextStyle(
                      color: _texto,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Row(children: [
                Icon(Icons.arrow_downward, color: _sec, size: 20)
              ]),
              Text(r.destino,
                  style: const TextStyle(
                      color: _verde,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                    child: _kpiCard('Tránsito', '${r.transitDays} días',
                        Icons.schedule, _azul)),
                const SizedBox(width: 16),
                Expanded(
                    child: _kpiCard(
                        'Costo Est.',
                        '\$${r.costUsd.toStringAsFixed(0)} USD',
                        Icons.payments_outlined,
                        _verde)),
              ]),
            ])),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _bord)),
          child: _infoRow(
              'Naviera', r.naviera, Icons.directions_boat_outlined, _sec),
        ),
        const SizedBox(height: 16),
        _seccionCard('Escala de Puertos', Icons.anchor, _ambar, [
          for (int i = 0; i < r.puertosEscala.length; i++)
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: _ambar.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: _ambar.withValues(alpha: 0.3))),
                      child: Center(
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: _ambar,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 12),
                  Text(r.puertosEscala[i],
                      style: const TextStyle(color: _texto, fontSize: 14))
                ])),
        ]),
        const SizedBox(height: 16),
        _seccionCard('Ventajas de esta Ruta', Icons.thumb_up_outlined, _verde, [
          for (final v in r.ventajas)
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline,
                      color: _verde, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(v,
                          style: const TextStyle(color: _texto, fontSize: 14)))
                ])),
        ]),
      ]),
    );
  }

  Widget _tabAlertas() => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Alertas Portuarias en Tiempo Real',
              style: TextStyle(
                  color: _ambar, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Actualización diaria · Fuente: NaviSite / Lloyd\'s Intelligence',
              style: TextStyle(color: _sec, fontSize: 13)),
          const SizedBox(height: 24),
          for (final a in _alertasRutas)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: a.$3.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                        color: a.$3.withValues(alpha: 0.05), blurRadius: 10)
                  ]),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: a.$3.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: a.$3.withValues(alpha: 0.3))),
                    child: Icon(
                        a.$3 == _verde
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_rounded,
                        color: a.$3,
                        size: 24)),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(a.$1,
                          style: const TextStyle(
                              color: _texto,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(a.$2,
                          style: const TextStyle(
                              color: _sec, fontSize: 14, height: 1.5)),
                    ])),
              ]),
            ),
        ],
      );

  Widget _tabComparador() {
    final top3 = _rutasMaestras.take(3).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Comparador de Rutas (Top 3 Shanghai → Mexico)',
            style: TextStyle(
                color: _ambar, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        DecoratedBox(
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Table(
              border:
                  const TableBorder.symmetric(inside: BorderSide(color: _bord)),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth()
              },
              children: [
                TableRow(
                    decoration: const BoxDecoration(color: _bg),
                    children: [
                      _thCell('Parámetro'),
                      _thCell(top3[0].id),
                      _thCell(top3[1].id),
                      _thCell(top3[2].id),
                    ]),
                _compRow('Modo', [
                  top3[0].modo.split(' ').first,
                  top3[1].modo.split(' ').first,
                  top3[2].modo.split(' ').first
                ]),
                _compRow('Tránsito', [
                  '${top3[0].transitDays}d',
                  '${top3[1].transitDays}d',
                  '${top3[2].transitDays}d'
                ]),
                _compRow('Costo USD', [
                  '\$${top3[0].costUsd.toInt()}',
                  '\$${top3[1].costUsd.toInt()}',
                  '\$${top3[2].costUsd.toInt()}'
                ]),
                _compRow('Naviera', [
                  top3[0].naviera.split('/').first,
                  top3[1].naviera.split('/').first,
                  top3[2].naviera.split('/').first
                ]),
                _compRow(
                    'Riesgo', [top3[0].riesgo, top3[1].riesgo, top3[2].riesgo]),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  TableRow _compRow(String label, List<String> vals) => TableRow(children: [
        _tdCell(label, isLabel: true),
        ...[for (final v in vals) _tdCell(v)],
      ]);

  Widget _thCell(String t) => Padding(
      padding: const EdgeInsets.all(16),
      child: Text(t,
          style: const TextStyle(
              color: _ambar, fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center));
  Widget _tdCell(String t, {bool isLabel = false}) => Padding(
      padding: const EdgeInsets.all(16),
      child: Text(t,
          style: TextStyle(
              color: isLabel ? _sec : _texto,
              fontSize: 14,
              fontWeight: isLabel ? FontWeight.bold : FontWeight.normal),
          textAlign: TextAlign.center));

  Widget _chipRow(String label, List<String> opts, String val,
          ValueChanged<String> onCh) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        for (final o in opts)
          Padding(
              padding: const EdgeInsets.only(right: 8),
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => onCh(o),
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              color: val == o
                                  ? _azul.withValues(alpha: 0.1)
                                  : _card,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: val == o ? _azul : _bord)),
                          child: Text(o,
                              style: TextStyle(
                                  color: val == o ? _azul : _sec,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)))))),
      ]);

  Widget _chip(IconData ic, String t, Color c) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ic, color: c, size: 14),
        const SizedBox(width: 6),
        Text(t,
            style:
                TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold))
      ]);

  Widget _kpiCard(String l, String v, IconData ic, Color c) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(ic, color: c, size: 20),
        const SizedBox(height: 8),
        Text(v,
            style:
                TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(l,
            style: const TextStyle(
                color: _sec, fontSize: 12, fontWeight: FontWeight.bold))
      ]));

  Widget _infoRow(String l, String v, IconData ic, Color c) => Row(children: [
        Icon(ic, color: c, size: 18),
        const SizedBox(width: 12),
        Text('$l: ',
            style: const TextStyle(
                color: _sec, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(v,
            style: const TextStyle(
                color: _texto, fontSize: 14, fontWeight: FontWeight.bold))
      ]);

  Widget _seccionCard(
          String titulo, IconData icon, Color c, List<Widget> children) =>
      Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, color: c, size: 20),
              const SizedBox(width: 12),
              Text(titulo,
                  style: TextStyle(
                      color: c, fontSize: 15, fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 16),
            ...children
          ]));

  IconData _modoIcon(String m) {
    if (m.contains('Aereo')) return Icons.flight;
    if (m.contains('Terrestre')) return Icons.local_shipping;
    return Icons.directions_boat;
  }
}
