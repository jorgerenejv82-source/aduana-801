import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'dart:math';

// -- Design Tokens -------------------------------------------------------------
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _card2 = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;
const Color _teal = Color(0xFF4ECCA3);

// -- Models --------------------------------------------------------------------
class _Turno {
  final String id;
  final String garita;
  final String aduana;
  final String operador;
  final String tipo;
  final DateTime inicio;
  final DateTime fin;
  final String placas;
  final String pedimento;
  bool asistio;

  _Turno({
    required this.id,
    required this.garita,
    required this.aduana,
    required this.operador,
    required this.tipo,
    required this.inicio,
    required this.fin,
    required this.placas,
    required this.pedimento,
    required this.asistio,
  });

  bool get activo =>
      DateTime.now().isAfter(inicio) && DateTime.now().isBefore(fin);
  bool get proximo =>
      DateTime.now().isBefore(inicio) &&
      inicio.difference(DateTime.now()).inHours < 4;
}

String _rndId() => 'TG-${Random().nextInt(9000) + 1000}';

// -- Screen --------------------------------------------------------------------
class TurnosGaritaScreen extends StatefulWidget {
  const TurnosGaritaScreen({super.key});
  @override
  State<TurnosGaritaScreen> createState() => _TurnosGaritaScreenState();
}

class _TurnosGaritaScreenState extends State<TurnosGaritaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final List<_Turno> _turnos = [];
  String _filtroAduana = 'Todas';

  static const _aduanas = [
    'Nuevo Laredo',
    'Ciudad Juarez',
    'Nogales',
    'Matamoros',
    'Reynosa',
    'Tijuana',
    'Piedras Negras'
  ];
  static const _garitas = [
    'Puente Colombia',
    'Puente Juarez-Lincoln',
    'B&M Bridge',
    'Puente Internacional 1',
    'Puente Internacional 2'
  ];
  static const _tipos = [
    'Importacion',
    'Exportacion',
    'Transito',
    'Carga Peligrosa',
    'Carga Refrigerada'
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _turnos.addAll([
      _Turno(
          id: 'TG-1001',
          garita: 'Puente Colombia',
          aduana: 'Nuevo Laredo',
          operador: 'Carlos Mendez',
          tipo: 'Importacion',
          inicio: now.subtract(const Duration(hours: 1)),
          fin: now.add(const Duration(hours: 2)),
          placas: 'NLE-1234-AB',
          pedimento: '800-2024-8892341',
          asistio: true),
      _Turno(
          id: 'TG-1002',
          garita: 'B&M Bridge',
          aduana: 'Nuevo Laredo',
          operador: 'Ana Torres',
          tipo: 'Exportacion',
          inicio: now.add(const Duration(hours: 2)),
          fin: now.add(const Duration(hours: 5)),
          placas: 'TAM-8823-XZ',
          pedimento: '800-2024-7761234',
          asistio: false),
      _Turno(
          id: 'TG-1003',
          garita: 'Puente Juarez-Lincoln',
          aduana: 'Ciudad Juarez',
          operador: 'Pedro Ruiz',
          tipo: 'Transito',
          inicio: now.add(const Duration(hours: 6)),
          fin: now.add(const Duration(hours: 9)),
          placas: 'CHI-4412-BC',
          pedimento: '800-2024-3341298',
          asistio: false),
    ]);
  }

  @override
  void dispose() {
    
    
    
    _tabCtrl.dispose();
    super.dispose();
  }

  List<_Turno> get _filtrados => _filtroAduana == 'Todas'
      ? _turnos
      : _turnos.where((t) => t.aduana == _filtroAduana).toList();
  List<_Turno> get _activos => _filtrados.where((t) => t.activo).toList();
  List<_Turno> get _proximos => _filtrados.where((t) => t.proximo).toList();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          _header(),
          Expanded(
              child: TabBarView(
                  controller: _tabCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                _tabTurnos(),
                _tabCalendario(),
              ])),
        ]),
        floatingActionButton: FloatingActionButton(
            backgroundColor: _ambar,
            tooltip: 'Nuevo Turno',
            onPressed: _dialogNuevo,
            child: const Icon(Icons.add, color: Colors.black)),
      );

  Widget _header() => Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 14, 0),
        decoration: const BoxDecoration(
            color: _bg, border: Border(bottom: BorderSide(color: _bord))),
        child: Column(children: [
          Row(children: [
            InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _bord)),
                    child:
                        const Icon(Icons.chevron_left, color: _sec, size: 20))),
            const SizedBox(width: 10),
            Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: _verde.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _verde.withAlpha(80))),
                child: const Icon(Icons.local_shipping_outlined,
                    color: _verde, size: 16)),
            const SizedBox(width: 10),
            const Expanded(
                child: Text('Turnos de Garita',
                    style: TextStyle(
                        color: _texto,
                        fontSize: 15,
                        fontWeight: FontWeight.bold))),
            if (_activos.isNotEmpty)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: _verde.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _verde.withAlpha(60))),
                  child: Row(children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: _verde, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text('${_activos.length} activos',
                        style: const TextStyle(
                            color: _verde,
                            fontSize: 10,
                            fontWeight: FontWeight.bold))
                  ])),
          ]),
          const SizedBox(height: 12),
          TabBar(
              controller: _tabCtrl,
              indicatorColor: _teal,
              labelColor: _teal,
              unselectedLabelColor: _sec,
              labelStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              tabs: const [
                Tab(
                    icon: Icon(Icons.list_alt, size: 14),
                    text: 'Turnos del Dia'),
                Tab(
                    icon: Icon(Icons.calendar_view_week, size: 14),
                    text: 'Vista Garita')
              ]),
        ]),
      );

  // -- Tab 1: Lista de Turnos -------------------------------------------------
  Widget _tabTurnos() => Column(children: [
        // Aduana filter chips
        Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: _card2,
            child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: ['Todas', ..._aduanas].map((a) {
                  final sel = _filtroAduana == a;
                  return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Center(
                          child: GestureDetector(
                              onTap: () => setState(() => _filtroAduana = a),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: sel
                                          ? _teal.withAlpha(25)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: sel ? _teal : _bord)),
                                  child: Text(a,
                                      style: TextStyle(
                                          color: sel ? _teal : _sec,
                                          fontSize: 10,
                                          fontWeight: sel
                                              ? FontWeight.bold
                                              : FontWeight.normal))))));
                }).toList())),
        // Stats
        Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              _miniStat(Icons.radio_button_checked, _activos.length.toString(),
                  'En Garita Ahora', _verde),
              const SizedBox(width: 10),
              _miniStat(Icons.upcoming, _proximos.length.toString(),
                  'Proximos (< 4h)', _ambar),
              const SizedBox(width: 10),
              _miniStat(
                  Icons.check_circle_outline,
                  _filtrados
                      .where((t) => t.asistio && !t.activo)
                      .length
                      .toString(),
                  'Completados',
                  _azul),
            ])),
        Expanded(
            child: _filtrados.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.local_shipping_outlined,
                            color: _sec.withAlpha(80), size: 48),
                        const SizedBox(height: 12),
                        const Text('No hay turnos. Presiona + para agregar.',
                            style: TextStyle(color: _sec, fontSize: 12))
                      ]))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                    itemCount: _filtrados.length,
                    itemBuilder: (_, i) => _turnoCard(_filtrados[i]))),
      ]);

  Widget _miniStat(IconData ic, String v, String l, Color c) => Expanded(
      child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.withAlpha(60))),
          child: Row(children: [
            Icon(ic, color: c, size: 18),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v,
                  style: TextStyle(
                      color: c, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(l, style: const TextStyle(color: _sec, fontSize: 8))
            ])
          ])));

  Widget _turnoCard(_Turno t) {
    final c = t.activo
        ? _verde
        : t.proximo
            ? _ambar
            : _sec;
    final label = t.activo
        ? 'EN GARITA'
        : t.proximo
            ? 'PROXIMO'
            : t.asistio
                ? 'COMPLETADO'
                : 'PROGRAMADO';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.activo ? _verde.withAlpha(80) : _bord)),
      child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: c.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.withAlpha(60))),
                child: Icon(Icons.local_shipping_outlined, color: c, size: 20)),
            title: Row(children: [
              Expanded(
                  child: Text(t.placas,
                      style: const TextStyle(
                          color: _texto,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace'))),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: c.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: c.withAlpha(60))),
                  child: Text(label,
                      style: TextStyle(
                          color: c, fontSize: 9, fontWeight: FontWeight.bold)))
            ]),
            subtitle: Text('${t.garita} � ${t.operador} � ${t.tipo}',
                style: const TextStyle(color: _sec, fontSize: 10),
                overflow: TextOverflow.ellipsis),
            children: [
              const Divider(color: _bord, height: 1),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: _dr('Inicio',
                        '${t.inicio.hour.toString().padLeft(2, '0')}:${t.inicio.minute.toString().padLeft(2, '0')}')),
                Expanded(
                    child: _dr('Fin',
                        '${t.fin.hour.toString().padLeft(2, '0')}:${t.fin.minute.toString().padLeft(2, '0')}')),
                Expanded(child: _dr('Pedimento', t.pedimento)),
                Expanded(child: _dr('Aduana', t.aduana))
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Checkbox(
                    value: t.asistio,
                    onChanged: (v) => setState(() => t.asistio = v!),
                    activeColor: _verde,
                    checkColor: Colors.black,
                    side: const BorderSide(color: _sec)),
                const Text('Asistencia confirmada',
                    style: TextStyle(color: _sec, fontSize: 11)),
              ]),
            ],
          )),
    );
  }

  Widget _dr(String l, String v) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l,
            style: const TextStyle(
                color: _sec, fontSize: 8, fontWeight: FontWeight.w600)),
        Text(v,
            style: const TextStyle(color: _texto, fontSize: 10),
            overflow: TextOverflow.ellipsis)
      ]);

  // -- Tab 2: Vista Garita ----------------------------------------------------
  Widget _tabCalendario() {
    final slots = List.generate(14, (i) => i + 6); // 06:00 � 19:00
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Vista de Turnos por Hora',
            style: TextStyle(
                color: _texto, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...slots.map((h) {
          final enEsaHora = _turnos
              .where((t) => t.inicio.hour <= h && t.fin.hour > h)
              .toList();
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  width: 44,
                  child: Text('${h.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                          color: enEsaHora.isNotEmpty ? _teal : _sec,
                          fontSize: 10,
                          fontWeight: enEsaHora.isNotEmpty
                              ? FontWeight.bold
                              : FontWeight.normal))),
              Container(
                  width: 1,
                  color: enEsaHora.isNotEmpty ? _teal.withAlpha(80) : _bord,
                  margin: const EdgeInsets.symmetric(horizontal: 8)),
              if (enEsaHora.isEmpty)
                const Expanded(child: SizedBox(height: 20))
              else
                Expanded(
                    child: Wrap(
                        spacing: 6,
                        children: enEsaHora
                            .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: t.activo
                                        ? _verde.withAlpha(20)
                                        : _ambar.withAlpha(15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: t.activo
                                            ? _verde.withAlpha(80)
                                            : _ambar.withAlpha(50))),
                                child: Text(
                                    '${t.placas} � ${t.garita.split(' ').last}',
                                    style: TextStyle(
                                        color: t.activo ? _verde : _ambar,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600))))
                            .toList())),
            ]),
          );
        }),
      ]),
    );
  }

  // -- Dialog Nuevo ----------------------------------------------------------
  void _dialogNuevo() {
    final plCtrl = TextEditingController();
    final pedCtrl = TextEditingController();
    final opCtrl = TextEditingController();
    String aduana = 'Nuevo Laredo';
    String garita = 'Puente Colombia';
    String tipo = 'Importacion';
    DateTime inicioT = DateTime.now().add(const Duration(hours: 1));
    DateTime finT = DateTime.now().add(const Duration(hours: 4));

    showDialog<void>(
        context: context,
        barrierColor: Colors.black.withAlpha(160),
        builder: (_) => StatefulBuilder(
            builder: (ctx, ss) => Dialog(
                  backgroundColor: _card2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: SizedBox(
                      width: 460,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            decoration: const BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                border:
                                    Border(bottom: BorderSide(color: _bord))),
                            child: Row(children: [
                              const Icon(Icons.local_shipping_outlined,
                                  color: _verde, size: 16),
                              const SizedBox(width: 10),
                              const Text('Nuevo Turno de Garita',
                                  style: TextStyle(
                                      color: _texto,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const Spacer(),
                              InkWell(
                                  onTap: () => Navigator.pop(ctx),
                                  child: const Icon(Icons.close,
                                      color: _sec, size: 18))
                            ])),
                        SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(children: [
                              Row(children: [
                                Expanded(
                                    child: _dfi(plCtrl, 'Placas del Vehiculo')),
                                const SizedBox(width: 10),
                                Expanded(child: _dfi(pedCtrl, 'Pedimento'))
                              ]),
                              const SizedBox(height: 10),
                              _dfi(opCtrl, 'Operador / Chofer'),
                              const SizedBox(height: 10),
                              _dlabel('Aduana'),
                              _ddrop(_aduanas, aduana,
                                  (v) => ss(() => aduana = v!)),
                              const SizedBox(height: 10),
                              _dlabel('Garita'),
                              _ddrop(_garitas, garita,
                                  (v) => ss(() => garita = v!)),
                              const SizedBox(height: 10),
                              _dlabel('Tipo de Operacion'),
                              _ddrop(_tipos, tipo, (v) => ss(() => tipo = v!)),
                              const SizedBox(height: 10),
                              Row(children: [
                                Expanded(
                                    child: InkWell(
                                        onTap: () async {
                                          final d = await showTimePicker(
                                              context: ctx,
                                              initialTime: TimeOfDay(
                                                  hour: inicioT.hour,
                                                  minute: inicioT.minute),
                                              builder: (c, ch) => Theme(
                                                  data: ThemeData.dark()
                                                      .copyWith(
                                                          colorScheme:
                                                              const ColorScheme
                                                                  .dark(
                                                                  primary:
                                                                      _ambar)),
                                                  child: ch!));
                                          if (d != null) {
                                            ss(() {
                                              inicioT = DateTime(
                                                  inicioT.year,
                                                  inicioT.month,
                                                  inicioT.day,
                                                  d.hour,
                                                  d.minute);
                                            });
                                          }
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 12),
                                            decoration: BoxDecoration(
                                                color: _bg,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border:
                                                    Border.all(color: _bord)),
                                            child: Row(children: [
                                              const Icon(Icons.schedule,
                                                  color: _sec, size: 14),
                                              const SizedBox(width: 8),
                                              Text(
                                                  'Inicio: ${inicioT.hour.toString().padLeft(2, '0')}:${inicioT.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(
                                                      color: _texto,
                                                      fontSize: 12))
                                            ])))),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: InkWell(
                                        onTap: () async {
                                          final d = await showTimePicker(
                                              context: ctx,
                                              initialTime: TimeOfDay(
                                                  hour: finT.hour,
                                                  minute: finT.minute),
                                              builder: (c, ch) => Theme(
                                                  data: ThemeData.dark()
                                                      .copyWith(
                                                          colorScheme:
                                                              const ColorScheme
                                                                  .dark(
                                                                  primary:
                                                                      _ambar)),
                                                  child: ch!));
                                          if (d != null) {
                                            ss(() {
                                              finT = DateTime(
                                                  finT.year,
                                                  finT.month,
                                                  finT.day,
                                                  d.hour,
                                                  d.minute);
                                            });
                                          }
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 12),
                                            decoration: BoxDecoration(
                                                color: _bg,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border:
                                                    Border.all(color: _bord)),
                                            child: Row(children: [
                                              const Icon(Icons.schedule_send,
                                                  color: _sec, size: 14),
                                              const SizedBox(width: 8),
                                              Text(
                                                  'Fin: ${finT.hour.toString().padLeft(2, '0')}:${finT.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(
                                                      color: _texto,
                                                      fontSize: 12))
                                            ])))),
                              ]),
                              const SizedBox(height: 20),
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() => _turnos.insert(
                                          0,
                                          _Turno(
                                              id: _rndId(),
                                              garita: garita,
                                              aduana: aduana,
                                              operador: opCtrl.text.isEmpty
                                                  ? 'Operador'
                                                  : opCtrl.text,
                                              tipo: tipo,
                                              inicio: inicioT,
                                              fin: finT,
                                              placas: plCtrl.text.isEmpty
                                                  ? 'S/P'
                                                  : plCtrl.text,
                                              pedimento: pedCtrl.text.isEmpty
                                                  ? '�'
                                                  : pedCtrl.text,
                                              asistio: false)));
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Turno registrado.'),
                                              backgroundColor: _verde,
                                              behavior:
                                                  SnackBarBehavior.floating));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: _ambar,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    child: const Text('Guardar Turno',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  )),
                            ])),
                      ])),
                )));
  }

  Widget _dfi(TextEditingController c, String label) => TextField(
      controller: c,
      style: const TextStyle(color: _texto, fontSize: 12),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _sec, fontSize: 12),
          filled: true,
          fillColor: _bg,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _bord)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _bord)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _ambar))));
  Widget _dlabel(String l) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(l, style: const TextStyle(color: _sec, fontSize: 10)));
  Widget _ddrop(
          List<String> opts, String val, ValueChanged<String?> onCh) =>
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _bord)),
          child: DropdownButton<String>(
              value: opts.contains(val) ? val : opts.first,
              isExpanded: true,
              dropdownColor: _card2,
              underline: const SizedBox(),
              icon:
                  const Icon(Icons.keyboard_arrow_down, color: _sec, size: 16),
              style: const TextStyle(color: _texto, fontSize: 12),
              items: opts
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: onCh));
}
