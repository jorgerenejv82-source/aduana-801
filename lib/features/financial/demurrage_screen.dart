import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'dart:math';

// -- Design Tokens -------------------------------------------------------------
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;

// -- Models --------------------------------------------------------------------
enum _EstadoCont { libre, enRiesgo, generandoCargos, retirado }

class _Contenedor {
  final String id;
  final String naviera;
  final String buque;
  final String aduana;
  final String tipo;
  final DateTime arribo;
  final int diasLibres;
  double costoXDia;
  _EstadoCont estado;

  _Contenedor({
    required this.id,
    required this.naviera,
    required this.buque,
    required this.aduana,
    required this.tipo,
    required this.arribo,
    required this.diasLibres,
    required this.costoXDia,
    required this.estado,
  });

  int get diasEnPuerto => DateTime.now().difference(arribo).inDays;
  int get diasDemora => max(0, diasEnPuerto - diasLibres);
  double get totalCargo => diasDemora * costoXDia;
  bool get enRiesgo => diasEnPuerto >= diasLibres - 2 && diasDemora == 0;
}

String _rndId() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final r = Random();
  return '${List.generate(4, (_) => chars[r.nextInt(chars.length)]).join()}${r.nextInt(9000000) + 1000000}';
}

// -- Screen --------------------------------------------------------------------
class DemurrageScreen extends StatefulWidget {
  const DemurrageScreen({super.key});
  @override
  State<DemurrageScreen> createState() => _DemurrageScreenState();
}

class _DemurrageScreenState extends State<DemurrageScreen> {
  final navCtrl = TextEditingController();
  final buqCtrl = TextEditingController();
  final dlCtrl = TextEditingController(text: '7');
  final cosCtrl = TextEditingController(text: '120');

  final idCtrl = TextEditingController();
  final List<_Contenedor> _contenedores = [];
  String _filtro = 'Todos';

  @override
  void initState() {
    super.initState();
    _contenedores.addAll([
      _Contenedor(
          id: 'MSCU7423019',
          naviera: 'MSC',
          buque: 'MSC OSCAR',
          aduana: 'Manzanillo',
          tipo: '40HC',
          arribo: DateTime.now().subtract(const Duration(days: 8)),
          diasLibres: 7,
          costoXDia: 120.0,
          estado: _EstadoCont.generandoCargos),
      _Contenedor(
          id: 'HLBU4129873',
          naviera: 'Hapag-Lloyd',
          buque: 'HL CAPE TOWN',
          aduana: 'Lazaro Cardenas',
          tipo: '20ST',
          arribo: DateTime.now().subtract(const Duration(days: 6)),
          diasLibres: 7,
          costoXDia: 85.0,
          estado: _EstadoCont.enRiesgo),
      _Contenedor(
          id: 'TCKU5012384',
          naviera: 'Triton',
          buque: 'EVER GIVEN',
          aduana: 'Veracruz',
          tipo: '40RF',
          arribo: DateTime.now().subtract(const Duration(days: 3)),
          diasLibres: 7,
          costoXDia: 200.0,
          estado: _EstadoCont.libre),
    ]);
  }

  List<_Contenedor> get _filtrados {
    if (_filtro == 'Todos') return _contenedores;
    final label = {
      'Libres': _EstadoCont.libre,
      'En Riesgo': _EstadoCont.enRiesgo,
      'Generando Cargos': _EstadoCont.generandoCargos,
      'Retirado': _EstadoCont.retirado
    };
    return _contenedores.where((c) => c.estado == label[_filtro]).toList();
  }

  int get _activos =>
      _contenedores.where((c) => c.estado != _EstadoCont.retirado).length;
  int get _enRiesgoCount =>
      _contenedores.where((c) => c.estado == _EstadoCont.enRiesgo).length;
  int get _generandoCount => _contenedores
      .where((c) => c.estado == _EstadoCont.generandoCargos)
      .length;
  double get _totalCargoHoy =>
      _contenedores.fold(0.0, (s, c) => s + c.totalCargo);

  @override
  void dispose() {
    super.dispose();
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
        title: const Text('Reloj de Demoras (Demurrage)',
            style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
        actions: [
          if (_totalCargoHoy > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: _rojo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _rojo.withValues(alpha: 0.3))),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: _rojo, size: 16),
                  const SizedBox(width: 8),
                  Text('\$${_totalCargoHoy.toStringAsFixed(0)} USD hoy',
                      style: const TextStyle(
                          color: _rojo,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _bord, height: 1),
        ),
      ),
      body: Column(children: [
        _buildStats(),
        _buildFilters(),
        Expanded(child: _contenedores.isEmpty ? _buildEmpty() : _buildList()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _ambar,
        icon: const Icon(Icons.add, color: _bg),
        label: const Text('Nuevo',
            style: TextStyle(color: _bg, fontWeight: FontWeight.bold)),
        onPressed: _dialogNuevo,
      ),
    );
  }

  Widget _buildStats() => Container(
        margin: const EdgeInsets.all(16),
        child: Row(children: [
          _statCard(Icons.inventory_2_outlined, _activos.toString(), 'Activos',
              _azul),
          const SizedBox(width: 12),
          _statCard(Icons.warning_amber_rounded, _enRiesgoCount.toString(),
              'En Riesgo', _ambar),
          const SizedBox(width: 12),
          _statCard(Icons.money_off_outlined, _generandoCount.toString(),
              'Con Cargos', _rojo),
        ]),
      );

  Widget _statCard(IconData icon, String val, String label, Color c) =>
      Expanded(
        child: _HoverCard(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Icon(icon, color: c, size: 28),
            const SizedBox(height: 12),
            Text(val,
                style: TextStyle(
                    color: c, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: _sec, fontSize: 12),
                textAlign: TextAlign.center),
          ]),
        ),
      );

  Widget _buildFilters() => SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            'Todos',
            'Libres',
            'En Riesgo',
            'Generando Cargos',
            'Retirado'
          ].map((f) {
            final sel = _filtro == f;
            final c = f == 'En Riesgo'
                ? _ambar
                : f == 'Generando Cargos'
                    ? _rojo
                    : f == 'Retirado'
                        ? _sec
                        : f == 'Libres'
                            ? _verde
                            : _azul;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () => setState(() => _filtro = f),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: sel ? c.withValues(alpha: 0.15) : _card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? c : _bord)),
                  child: Center(
                    child: Text(f,
                        style: TextStyle(
                            color: sel ? c : _sec,
                            fontSize: 13,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );

  Widget _buildEmpty() => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inventory_2_outlined,
            color: _sec.withValues(alpha: 0.3), size: 64),
        const SizedBox(height: 16),
        const Text('No hay contenedores registrados.',
            style: TextStyle(color: _sec, fontSize: 15)),
      ]));

  Widget _buildList() {
    final lista = _filtrados;
    if (lista.isEmpty) {
      return Center(
          child: Text('No hay contenedores con estado "$_filtro".',
              style: const TextStyle(color: _sec, fontSize: 14)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: lista.length,
      itemBuilder: (_, i) => _buildCard(lista[i]),
    );
  }

  Widget _buildCard(_Contenedor c) {
    final stColor = _estadoColor(c.estado);
    final urgFrac = c.diasEnPuerto / (c.diasLibres + 2);

    return _HoverCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: _ambar,
          collapsedIconColor: _sec,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: stColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: stColor.withValues(alpha: 0.3))),
              child:
                  Icon(Icons.inventory_2_outlined, color: stColor, size: 24)),
          title: Row(children: [
            Expanded(
                child: Text(c.id,
                    style: const TextStyle(
                        color: _texto,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace'))),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: stColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: stColor.withValues(alpha: 0.3))),
                child: Text(_estadoLabel(c.estado),
                    style: TextStyle(
                        color: stColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold))),
          ]),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('${c.naviera} ? ${c.aduana} ? ${c.tipo}',
                style: const TextStyle(color: _sec, fontSize: 13)),
          ),
          children: [
            const Divider(color: _bord, height: 24),
            Row(children: [
              const Text('D?as libres restantes:',
                  style: TextStyle(color: _sec, fontSize: 13)),
              const SizedBox(width: 12),
              Expanded(
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: urgFrac.clamp(0.0, 1.0),
                  backgroundColor: _bg,
                  valueColor: AlwaysStoppedAnimation<Color>(urgFrac > 0.9
                      ? _rojo
                      : urgFrac > 0.7
                          ? _ambar
                          : _verde),
                  minHeight: 8,
                ),
              )),
              const SizedBox(width: 12),
              Text('${max(0, c.diasLibres - c.diasEnPuerto)} d?as',
                  style: TextStyle(
                      color: urgFrac > 0.9
                          ? _rojo
                          : urgFrac > 0.7
                              ? _ambar
                              : _verde,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: _detRow('Arribo',
                      '${c.arribo.day.toString().padLeft(2, '0')}/${c.arribo.month.toString().padLeft(2, '0')}/${c.arribo.year}')),
              Expanded(
                  child: _detRow('D?as en Puerto', '${c.diasEnPuerto} d?as')),
              Expanded(
                  child: _detRow('D?as de Demora', '${c.diasDemora} d?as')),
              Expanded(
                  child: _detRow('Costo x D?a',
                      '\$${c.costoXDia.toStringAsFixed(0)} USD')),
            ]),
            const SizedBox(height: 16),
            if (c.diasDemora > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: _rojo.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _rojo.withValues(alpha: 0.2))),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Cargo Acumulado:',
                                style: TextStyle(
                                    color: _rojo,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('\$${c.totalCargo.toStringAsFixed(2)} USD',
                                style: const TextStyle(
                                    color: _rojo,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ]),
                      Text(
                          '${c.diasDemora} d?as x \$${c.costoXDia.toStringAsFixed(0)}',
                          style: const TextStyle(color: _rojo, fontSize: 13)),
                    ]),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _EstadoCont.values.where((e) => e != c.estado).map((e) {
                final ec = _estadoColor(e);
                return InkWell(
                  onTap: () => setState(() => c.estado = e),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _bord)),
                      child: Text('Cambiar a ${_estadoLabel(e)}',
                          style: TextStyle(
                              color: ec,
                              fontSize: 12,
                              fontWeight: FontWeight.bold))),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detRow(String l, String v) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l,
            style: const TextStyle(
                color: _sec, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(v,
            style: const TextStyle(color: _texto, fontSize: 13),
            overflow: TextOverflow.ellipsis),
      ]);

  // -- Dialog ----------------------------------------------------------------
  void _dialogNuevo() {
    idCtrl.text = _rndId();
    String aduana = 'Manzanillo';
    String tipo = '40HC';
    DateTime arribo = DateTime.now();

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => StatefulBuilder(
          builder: (ctx, setS) => Dialog(
                backgroundColor: _card,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: _bord)),
                child: SizedBox(
                    width: 480,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: _bord))),
                          child: Row(children: [
                            const Icon(Icons.add_box_outlined,
                                color: _ambar, size: 24),
                            const SizedBox(width: 12),
                            const Text('Nuevo Contenedor',
                                style: TextStyle(
                                    color: _texto,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            InkWell(
                                onTap: () => Navigator.pop(ctx),
                                child: const Icon(Icons.close,
                                    color: _sec, size: 24)),
                          ])),
                      SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(children: [
                            _dfi(idCtrl, 'ID Contenedor'),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(child: _dfi(navCtrl, 'Naviera')),
                              const SizedBox(width: 16),
                              Expanded(child: _dfi(buqCtrl, 'Buque')),
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    const Text('Aduana',
                                        style: TextStyle(
                                            color: _sec, fontSize: 13)),
                                    const SizedBox(height: 8),
                                    _ddrop([
                                      'Manzanillo',
                                      'Lazaro Cardenas',
                                      'Veracruz',
                                      'Altamira',
                                      'Ensenada'
                                    ], aduana, (v) => setS(() => aduana = v!)),
                                  ])),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    const Text('Tipo',
                                        style: TextStyle(
                                            color: _sec, fontSize: 13)),
                                    const SizedBox(height: 8),
                                    _ddrop([
                                      '20ST',
                                      '40ST',
                                      '40HC',
                                      '40RF',
                                      '20RF'
                                    ], tipo, (v) => setS(() => tipo = v!)),
                                  ])),
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(
                                  child:
                                      _dfi(dlCtrl, 'D?as Libres', isNum: true)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _dfi(cosCtrl, 'Costo/D?a (USD)',
                                      isNum: true)),
                            ]),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () async {
                                final d = await showDatePicker(
                                    context: ctx,
                                    initialDate: arribo,
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime.now(),
                                    builder: (c, ch) => Theme(
                                        data: ThemeData.dark().copyWith(
                                            colorScheme: const ColorScheme.dark(
                                                primary: _ambar,
                                                surface: _card)),
                                        child: ch!));
                                  if (!mounted) return;
                                  if (d != null) setS(() => arribo = d);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                    color: _bg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: _bord)),
                                child: Row(children: [
                                  const Icon(Icons.calendar_today,
                                      color: _sec, size: 18),
                                  const SizedBox(width: 12),
                                  Text(
                                      'Fecha de Arribo: ${arribo.day.toString().padLeft(2, '0')}/${arribo.month.toString().padLeft(2, '0')}/${arribo.year}',
                                      style: const TextStyle(
                                          color: _texto, fontSize: 14)),
                                ]),
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final diasEnP = DateTime.now()
                                        .difference(arribo)
                                        .inDays;
                                    final diasLib =
                                        int.tryParse(dlCtrl.text) ?? 7;
                                    final demora = max(0, diasEnP - diasLib);
                                    setState(() => _contenedores.insert(
                                        0,
                                        _Contenedor(
                                          id: idCtrl.text,
                                          naviera: navCtrl.text.isEmpty
                                              ? 'Naviera'
                                              : navCtrl.text,
                                          buque: buqCtrl.text.isEmpty
                                              ? 'Buque'
                                              : buqCtrl.text,
                                          aduana: aduana,
                                          tipo: tipo,
                                          arribo: arribo,
                                          diasLibres: diasLib,
                                          costoXDia:
                                              double.tryParse(cosCtrl.text) ??
                                                  120,
                                          estado: demora > 0
                                              ? _EstadoCont.generandoCargos
                                              : diasEnP >= diasLib - 2
                                                  ? _EstadoCont.enRiesgo
                                                  : _EstadoCont.libre,
                                        )));
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Contenedor registrado con ?xito.'),
                                            backgroundColor: _verde,
                                            behavior:
                                                SnackBarBehavior.floating));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: _ambar,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12))),
                                  child: const Text('Guardar Contenedor',
                                      style: TextStyle(
                                          color: _bg,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                )),
                          ])),
                    ])),
              )),
    );
  }

  Widget _dfi(TextEditingController c, String label, {bool isNum = false}) =>
      TextField(
        controller: c,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: _texto, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _sec, fontSize: 13),
          filled: true,
          fillColor: _bg,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _bord)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _bord)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _ambar)),
        ),
      );

  Widget _ddrop(List<String> opts, String val, ValueChanged<String?> onCh) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _bord)),
        child: DropdownButton<String>(
          value: val,
          isExpanded: true,
          dropdownColor: _bg,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, color: _sec, size: 20),
          style: const TextStyle(color: _texto, fontSize: 14),
          items: opts
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onCh,
        ),
      );

  String _estadoLabel(_EstadoCont e) {
    switch (e) {
      case _EstadoCont.libre:
        return 'Libre';
      case _EstadoCont.enRiesgo:
        return 'En Riesgo';
      case _EstadoCont.generandoCargos:
        return 'Generando Cargos';
      case _EstadoCont.retirado:
        return 'Retirado';
    }
  }

  Color _estadoColor(_EstadoCont e) {
    switch (e) {
      case _EstadoCont.libre:
        return _verde;
      case _EstadoCont.enRiesgo:
        return _ambar;
      case _EstadoCont.generandoCargos:
        return _rojo;
      case _EstadoCont.retirado:
        return _sec;
    }
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  const _HoverCard({required this.child, this.padding, this.margin});

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
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _isHovered ? _ambar.withValues(alpha: 0.5) : _bord),
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

