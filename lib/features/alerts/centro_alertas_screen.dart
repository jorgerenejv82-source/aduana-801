import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';

// -- Design Tokens -------------------------------------------------------------
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _card2 = Color(0xFF13233E);
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold; // gold
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;
const Color _naran = Color(0xFFF97316);

// -- Model ----------------------------------------------------------------------
enum _Nivel { critica, alta, media, info }

enum _TipoAlerta { pedimento, vencimiento, efos, compliance, sistema }

class _Alerta {
  final String id;
  String titulo;
  String mensaje;
  String? referencia;
  DateTime fecha;
  _Nivel nivel;
  _TipoAlerta tipo;
  bool leida;

  _Alerta({
    required this.id,
    required this.titulo,
    required this.mensaje,
    this.referencia,
    required this.fecha,
    required this.nivel,
    required this.tipo,
    this.leida = false,
  });
}

// -- Demo data -----------------------------------------------------------------
List<_Alerta> _buildDemo() {
  final now = DateTime.now();
  return [
    _Alerta(
        id: 'A001',
        titulo: 'Pedimento vence en 24 hrs',
        mensaje:
            'El pedimento 24-25-2026-0000123 en aduana Nuevo Laredo debe ser retirado antes de las 17:00 hrs de manana.',
        referencia: '24-25-2026-0000123',
        fecha: now.subtract(const Duration(minutes: 1)),
        nivel: _Nivel.critica,
        tipo: _TipoAlerta.pedimento),
    _Alerta(
        id: 'A002',
        titulo: 'Bienvenido a Alertas',
        mensaje:
            'Este es tu centro de alertas unificado. Las notificaciones de pedimentos, vencimientos, EFOS y padron apareceran aqui automaticamente.',
        fecha: now.subtract(const Duration(minutes: 10)),
        nivel: _Nivel.info,
        tipo: _TipoAlerta.sistema,
        leida: false),
    _Alerta(
        id: 'A003',
        titulo: 'Proveedor en lista EFOS',
        mensaje:
            'El proveedor XAXX010101000 aparece en la lista provisional 69-B. Suspender operaciones inmediatamente.',
        referencia: 'XAXX010101000',
        fecha: now.subtract(const Duration(hours: 2)),
        nivel: _Nivel.alta,
        tipo: _TipoAlerta.efos),
    _Alerta(
        id: 'A004',
        titulo: 'Reporte IMMEX vence en 3 dias',
        mensaje:
            'El reporte mensual IMMEX Anexo 24 correspondiente a julio 2026 vence el proximo lunes. Presentarlo ante VUCEM.',
        referencia: 'Anexo 24 - Jul 2026',
        fecha: now.subtract(const Duration(hours: 5)),
        nivel: _Nivel.alta,
        tipo: _TipoAlerta.vencimiento),
    _Alerta(
        id: 'A005',
        titulo: 'Alerta Compliance � Fraccion PAMA',
        mensaje:
            'La fraccion 7219.21.01.00 de origen China tiene cuota compensatoria del 60%. Pedimento #4302 en revision.',
        referencia: '7219.21.01.00',
        fecha: now.subtract(const Duration(hours: 8)),
        nivel: _Nivel.critica,
        tipo: _TipoAlerta.compliance,
        leida: true),
    _Alerta(
        id: 'A006',
        titulo: 'Actualizacion sistema',
        mensaje:
            'Se actualizo la base de EFOS/EDOS con 847 nuevas entidades. Revisa tus proveedores activos.',
        fecha: now.subtract(const Duration(days: 1)),
        nivel: _Nivel.media,
        tipo: _TipoAlerta.sistema,
        leida: true),
  ];
}

// -- Colors per level ----------------------------------------------------------
Color _nivelColor(_Nivel n) {
  switch (n) {
    case _Nivel.critica:
      return _rojo;
    case _Nivel.alta:
      return _naran;
    case _Nivel.media:
      return _ambar;
    case _Nivel.info:
      return _azul;
  }
}

IconData _tipoIcon(_TipoAlerta t) {
  switch (t) {
    case _TipoAlerta.pedimento:
      return Icons.receipt_long;
    case _TipoAlerta.vencimiento:
      return Icons.event;
    case _TipoAlerta.efos:
      return Icons.gps_fixed;
    case _TipoAlerta.compliance:
      return Icons.shield;
    case _TipoAlerta.sistema:
      return Icons.notifications;
  }
}

// -- Main Screen ---------------------------------------------------------------
class CentroAlertasScreen extends StatefulWidget {
  const CentroAlertasScreen({super.key});
  @override
  State<CentroAlertasScreen> createState() => _CentroAlertasScreenState();
}

class _CentroAlertasScreenState extends State<CentroAlertasScreen> {
  final tituloCtrl = TextEditingController();
  final mensajeCtrl = TextEditingController();
  final refCtrl = TextEditingController();

  @override
  void dispose() {
    tituloCtrl.dispose();
    mensajeCtrl.dispose();
    refCtrl.dispose();
    super.dispose();
  }

  final List<_Alerta> _alertas = _buildDemo();
  int _filtroIdx = 0;

  static const _filtros = [
    'Todas',
    'Criticas',
    'Pedimentos',
    'Vencimientos',
    'Compliance'
  ];

  List<_Alerta> get _filtered {
    switch (_filtroIdx) {
      case 1:
        return _alertas.where((a) => a.nivel == _Nivel.critica).toList();
      case 2:
        return _alertas.where((a) => a.tipo == _TipoAlerta.pedimento).toList();
      case 3:
        return _alertas
            .where((a) => a.tipo == _TipoAlerta.vencimiento)
            .toList();
      case 4:
        return _alertas.where((a) => a.tipo == _TipoAlerta.compliance).toList();
      default:
        return _alertas;
    }
  }

  int get _noLeidas => _alertas.where((a) => !a.leida).length;
  int get _criticas =>
      _alertas.where((a) => a.nivel == _Nivel.critica && !a.leida).length;
  int get _altas =>
      _alertas.where((a) => a.nivel == _Nivel.alta && !a.leida).length;
  int get _leidas => _alertas.where((a) => a.leida).length;

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _texto),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Centro de Alertas',
            style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh, color: _ambar)),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                  onPressed: () {},
                  icon:
                      const Icon(Icons.notifications_outlined, color: _ambar)),
              if (_noLeidas > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        color: _rojo, borderRadius: BorderRadius.circular(8)),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('$_noLeidas',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            color: _card2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: _bord)),
            onSelected: (v) {
              if (v == 'read')
                setState(() {
                  for (final a in _alertas) {
                    a.leida = true;
                  }
                });
              if (v == 'clear')
                setState(() => _alertas.removeWhere((a) => a.leida));
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'read',
                  child: Row(children: [
                    Icon(Icons.done_all, color: _verde, size: 16),
                    SizedBox(width: 10),
                    Text('Marcar todas como le�das',
                        style: TextStyle(color: _texto, fontSize: 13))
                  ])),
              const PopupMenuItem(
                  value: 'clear',
                  child: Row(children: [
                    Icon(Icons.delete_sweep, color: _rojo, size: 16),
                    SizedBox(width: 10),
                    Text('Limpiar le�das',
                        style: TextStyle(color: _texto, fontSize: 13))
                  ])),
            ],
            icon: const Icon(Icons.more_vert, color: _ambar),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearAlerta,
        backgroundColor: _ambar,
        icon: const Icon(Icons.add_alert, color: _bg, size: 18),
        label: const Text('Crear Alerta',
            style: TextStyle(color: _bg, fontWeight: FontWeight.bold)),
      ),
      body: Column(children: [
        // -- Header -------------------------------------------------------------
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: const BoxDecoration(
              color: _bg, border: Border(bottom: BorderSide(color: _bord))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // KPI row
            Row(children: [
              _kpi('Cr�ticas', _criticas, _rojo),
              const SizedBox(width: 8),
              _kpi('Altas', _altas, _naran),
              const SizedBox(width: 8),
              _kpi('Le�das', _leidas, _verde),
              const SizedBox(width: 8),
              _kpi('Total', _alertas.length, _azul),
            ]),
            const SizedBox(height: 16),
            // Filter tabs
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: List.generate(_filtros.length, (i) {
                  final active = _filtroIdx == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() => _filtroIdx = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                active ? _ambar.withValues(alpha: 0.15) : _card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: active ? _ambar : _bord),
                          ),
                          child: Text(_filtros[i],
                              style: TextStyle(
                                  color: active ? _ambar : _sec,
                                  fontSize: 13,
                                  fontWeight: active
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                      ),
                    ),
                  );
                }))),
          ]),
        ),

        // -- Alert list ---------------------------------------------------------
        Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.notifications_none, color: _bord, size: 52),
                        SizedBox(height: 12),
                        Text('Sin alertas en esta categor�a',
                            style: TextStyle(color: _sec, fontSize: 13)),
                      ]))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildCard(_filtered[i]),
                  )),
      ]),
    );
  }

  Widget _kpi(String l, int n, Color c) => Expanded(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _bord)),
          child: Column(children: [
            Text('$n',
                style: TextStyle(
                    color: c,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1)),
            const SizedBox(height: 4),
            Text(l,
                style: const TextStyle(color: _sec, fontSize: 11, height: 1.3)),
          ])));

  Widget _buildCard(_Alerta a) {
    final c = _nivelColor(a.nivel);
    return Dismissible(
      key: Key(a.id),
      direction: DismissDirection.endToStart,
      background: Container(
          decoration: BoxDecoration(
              color: _rojo.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline, color: _rojo)),
      onDismissed: (_) => setState(() => _alertas.remove(a)),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => a.leida = true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: a.leida ? _card.withValues(alpha: 0.6) : _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: a.leida ? _bord : c.withValues(alpha: 0.5)),
                boxShadow: [
                  if (!a.leida)
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                ]),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Icon
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.withValues(alpha: 0.3))),
                  child: Icon(_tipoIcon(a.tipo),
                      color: a.leida ? c.withValues(alpha: 0.6) : c, size: 20)),
              const SizedBox(width: 16),
              // Content
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(a.titulo,
                        style: TextStyle(
                            color: a.leida ? _sec : _texto,
                            fontSize: 14,
                            fontWeight:
                                a.leida ? FontWeight.normal : FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(a.mensaje,
                        style: TextStyle(
                            color: a.leida ? _sec.withValues(alpha: 0.8) : _sec,
                            fontSize: 12,
                            height: 1.5)),
                    if (a.referencia != null) ...[
                      const SizedBox(height: 8),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: c.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: c.withValues(alpha: 0.3))),
                          child: Text(a.referencia!,
                              style: TextStyle(
                                  color: c,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold))),
                    ],
                  ])),
              const SizedBox(width: 12),
              // Right: time + unread dot
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (!a.leida)
                  Container(
                      width: 10,
                      height: 10,
                      decoration:
                          BoxDecoration(color: c, shape: BoxShape.circle)),
                if (a.leida) const SizedBox(height: 10),
                const SizedBox(height: 12),
                Text(_timeAgo(a.fecha),
                    style: const TextStyle(color: _sec, fontSize: 10)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  // -- Create Alert Dialog ----------------------------------------------------
  void _crearAlerta() {
    String tipo = 'Pedimento';
    String nivel = 'Critica';
    DateTime? fechaVenc;

    showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        builder: (_) => StatefulBuilder(
            builder: (ctx, setS) => Dialog(
                  backgroundColor: _card,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: _bord)),
                  child: Container(
                      width: 500,
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(children: [
                              Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: _ambar.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color:
                                              _ambar.withValues(alpha: 0.3))),
                                  child: const Icon(Icons.add_alert,
                                      color: _ambar, size: 20)),
                              const SizedBox(width: 16),
                              const Text('Nueva Alerta Manual',
                                  style: TextStyle(
                                      color: _texto,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ]),
                            const SizedBox(height: 24),
                            _label('Tipo de alerta'),
                            _dropdown(
                                tipo,
                                [
                                  'Pedimento',
                                  'Vencimiento',
                                  'EFOS/EDOS',
                                  'Compliance',
                                  'Sistema'
                                ],
                                (v) => setS(() => tipo = v!)),
                            const SizedBox(height: 16),
                            _label('Nivel de urgencia'),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                    color: _bg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: _bord)),
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                  value: nivel,
                                  isExpanded: true,
                                  dropdownColor: _card2,
                                  style: const TextStyle(
                                      color: _texto, fontSize: 14),
                                  items: ['Critica', 'Alta', 'Media', 'Info']
                                      .map((n) {
                                    final c = n == 'Critica'
                                        ? _rojo
                                        : n == 'Alta'
                                            ? _naran
                                            : n == 'Media'
                                                ? _ambar
                                                : _azul;
                                    return DropdownMenuItem(
                                        value: n,
                                        child: Row(children: [
                                          Icon(Icons.circle,
                                              color: c, size: 12),
                                          const SizedBox(width: 10),
                                          Text(n)
                                        ]));
                                  }).toList(),
                                  onChanged: (v) => setS(() => nivel = v!),
                                ))),
                            const SizedBox(height: 16),
                            _label('T�tulo'),
                            _input(tituloCtrl, 'Ej: Pedimento vence en 24 hrs'),
                            const SizedBox(height: 16),
                            _label('Mensaje'),
                            _input(mensajeCtrl,
                                'Descripci�n detallada de la alerta...',
                                maxLines: 4),
                            const SizedBox(height: 16),
                            _label('Referencia (opcional)'),
                            _input(refCtrl,
                                'RFC, pedimento, n�mero de expediente...'),
                            const SizedBox(height: 16),
                            _label('Fecha de vencimiento (opcional)'),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () async {
                                  final p = await showDatePicker(
                                      context: ctx,
                                      initialDate: DateTime.now()
                                          .add(const Duration(days: 7)),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2030),
                                      builder: (c, w) => Theme(
                                          data: ThemeData.dark().copyWith(
                                              colorScheme:
                                                  const ColorScheme.dark(
                                                      primary: _ambar,
                                                      surface: _card,
                                                      onPrimary: _bg,
                                                      onSurface: _texto)),
                                          child: w!));
                                  if (p != null) setS(() => fechaVenc = p);
                                },
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                        color: _bg,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: _bord)),
                                    child: Row(children: [
                                      const Icon(Icons.calendar_today,
                                          color: _ambar, size: 18),
                                      const SizedBox(width: 12),
                                      Text(
                                          fechaVenc != null
                                              ? '${fechaVenc!.day}/${fechaVenc!.month}/${fechaVenc!.year}'
                                              : 'Seleccionar fecha...',
                                          style: TextStyle(
                                              color: fechaVenc != null
                                                  ? _texto
                                                  : _sec,
                                              fontSize: 14)),
                                    ])),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(children: [
                              Expanded(
                                  child: OutlinedButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: _bord),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16)),
                                      child: const Text('Cancelar',
                                          style: TextStyle(
                                              color: _texto, fontSize: 14)))),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: ElevatedButton(
                                onPressed: () {
                                  if (tituloCtrl.text.isEmpty) return;
                                  final nivelMap = {
                                    'Critica': _Nivel.critica,
                                    'Alta': _Nivel.alta,
                                    'Media': _Nivel.media,
                                    'Info': _Nivel.info
                                  };
                                  final tipoMap = {
                                    'Pedimento': _TipoAlerta.pedimento,
                                    'Vencimiento': _TipoAlerta.vencimiento,
                                    'EFOS/EDOS': _TipoAlerta.efos,
                                    'Compliance': _TipoAlerta.compliance,
                                    'Sistema': _TipoAlerta.sistema
                                  };
                                  setState(() {
                                    _alertas.insert(
                                        0,
                                        _Alerta(
                                          id: 'M${DateTime.now().millisecondsSinceEpoch}',
                                          titulo: tituloCtrl.text,
                                          mensaje: mensajeCtrl.text.isEmpty
                                              ? 'Sin descripci�n.'
                                              : mensajeCtrl.text,
                                          referencia: refCtrl.text.isEmpty
                                              ? null
                                              : refCtrl.text,
                                          fecha: DateTime.now(),
                                          nivel: nivelMap[nivel]!,
                                          tipo: tipoMap[tipo]!,
                                        ));
                                  });
                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: _ambar,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16)),
                                child: const Text('Guardar',
                                    style: TextStyle(
                                        color: _bg,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              )),
                            ]),
                          ]))),
                )));
  }

  Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t,
          style: const TextStyle(
              color: _sec, fontSize: 12, fontWeight: FontWeight.w600)));

  Widget _input(TextEditingController c, String hint, {int maxLines = 1}) =>
      TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(color: _texto, fontSize: 14),
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _sec, fontSize: 13),
            filled: true,
            fillColor: _bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _bord)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _bord)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _ambar))),
      );

  Widget _dropdown(
          String val, List<String> opts, ValueChanged<String?> onChanged) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _bord)),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          value: val,
          isExpanded: true,
          dropdownColor: _card2,
          style: const TextStyle(color: _texto, fontSize: 14),
          items: opts
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onChanged,
        )),
      );
}
