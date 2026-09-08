import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';

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
const Color _naran = Color(0xFFF97316);

// -- Catálogos ------------------------------------------------------------------
const _incoterms = [
  'EXW',
  'FCA',
  'FAS',
  'FOB',
  'CFR',
  'CIF',
  'CPT',
  'CIP',
  'DAP',
  'DPU',
  'DDP'
];
const _modos = [
  'Maritimo FCL',
  'Maritimo LCL',
  'Aereo',
  'Terrestre',
  'Multimodal'
];
const _monedas = ['USD', 'MXN', 'EUR', 'CAD'];
const _paises = [
  'Mexico',
  'USA',
  'Canada',
  'China',
  'Alemania',
  'Japon',
  'Korea',
  'Vietnam',
  'India',
  'Brasil',
  'Espana',
  'Italia',
  'Francia'
];

// -- Screen --------------------------------------------------------------------
class CotizadorDoorToDoorScreen extends StatefulWidget {
  const CotizadorDoorToDoorScreen({super.key});
  @override
  State<CotizadorDoorToDoorScreen> createState() =>
      _CotizadorDoorToDoorScreenState();
}

class _CotizadorDoorToDoorScreenState extends State<CotizadorDoorToDoorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // -- Formulario ------------------------------------------------------------
  String _origen = 'China';
  String _destino = 'Mexico';
  String _incoterm = 'FOB';
  String _modo = 'Maritimo FCL';
  String _moneda = 'USD';

  final _origenCiudadCtrl = TextEditingController();
  final _destinoCiudadCtrl =
      TextEditingController(text: 'Nuevo Laredo, Tamaulipas');
  final _pesoCtrl = TextEditingController();
  final _volumenCtrl = TextEditingController();
  final _valorMercCtrl = TextEditingController();
  final _descripCtrl = TextEditingController();
  final _fraccionCtrl = TextEditingController();

  // -- Configuraciones -------------------------------------------------------
  bool _incluyeFlete = true;
  bool _incluyeSeguro = true;
  bool _incluyeAduanas = true;
  bool _incluyeEntrega = true;
  bool _incluyeIva = true;

  // Tasas
  final _fleteCtrl = TextEditingController(text: '2800');
  final _seguroPctCtrl = TextEditingController(text: '0.5');
  final _arancelPctCtrl = TextEditingController(text: '15');
  final _honorariosCtrl = TextEditingController(text: '8500');
  final _dta = 847.84; // Derecho de Tramite Aduanero 2024

  bool _calculando = false;
  Map<String, double>? _resultado;

  // -- Historial -------------------------------------------------------------
  final List<Map<String, dynamic>> _historial = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _origenCiudadCtrl.dispose();
    _destinoCiudadCtrl.dispose();
    _pesoCtrl.dispose();
    _volumenCtrl.dispose();
    _valorMercCtrl.dispose();
    _descripCtrl.dispose();
    _fraccionCtrl.dispose();
    _fleteCtrl.dispose();
    _seguroPctCtrl.dispose();
    _arancelPctCtrl.dispose();
    _honorariosCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: _ambar),
          ),
          title: const Text('Cotizador Door-to-Door',
              style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Column(
              children: [
                TabBar(
                  controller: _tabCtrl,
                  indicatorColor: _ambar,
                  labelColor: _ambar,
                  unselectedLabelColor: _sec,
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontSize: 14),
                  tabs: const [
                    Tab(
                        icon: Icon(Icons.calculate_outlined, size: 18),
                        text: 'Nueva Cotización'),
                    Tab(icon: Icon(Icons.history, size: 18), text: 'Historial'),
                  ],
                ),
                Container(height: 1, color: _bord),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _tabCotizar(),
            _tabHistorial(),
          ],
        ),
      );

  // --------------------------------------------------------------------------
  Widget _tabCotizar() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Origen / Destino
          _HoverCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.route, color: _ambar, size: 18),
                SizedBox(width: 8),
                Text('Ruta',
                    style: TextStyle(
                        color: _ambar,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      _dlabel('País Origen'),
                      _ddrop(_paises, _origen,
                          (v) => setState(() => _origen = v!)),
                      const SizedBox(height: 8),
                      _fi(_origenCiudadCtrl, 'Ciudad / Puerto de origen'),
                    ])),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.arrow_forward, color: _sec, size: 24)),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      _dlabel('País Destino'),
                      _ddrop(_paises, _destino,
                          (v) => setState(() => _destino = v!)),
                      const SizedBox(height: 8),
                      _fi(_destinoCiudadCtrl, 'Ciudad / Aduana de destino'),
                    ])),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      _dlabel('Incoterm'),
                      _ddrop(_incoterms, _incoterm,
                          (v) => setState(() => _incoterm = v!))
                    ])),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      _dlabel('Modo de transporte'),
                      _ddrop(_modos, _modo, (v) => setState(() => _modo = v!))
                    ])),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      _dlabel('Moneda'),
                      _ddrop(_monedas, _moneda,
                          (v) => setState(() => _moneda = v!))
                    ])),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          // Mercancía
          _HoverCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.inventory_outlined, color: _ambar, size: 18),
                SizedBox(width: 8),
                Text('Mercancía',
                    style: TextStyle(
                        color: _ambar,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 16),
              _fi(_descripCtrl, 'Descripción de la mercancía'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _fi(_fraccionCtrl, 'Fracción arancelaria')),
                const SizedBox(width: 12),
                Expanded(
                    child: _fi(_valorMercCtrl, 'Valor mercancía',
                        Icons.attach_money, true)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child:
                        _fi(_pesoCtrl, 'Peso bruto (kg)', Icons.scale, true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _fi(
                        _volumenCtrl, 'Volumen (m3)', Icons.straighten, true)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          // Componentes de costo
          _HoverCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.tune, color: _ambar, size: 18),
                SizedBox(width: 8),
                Text('Componentes del Costo',
                    style: TextStyle(
                        color: _ambar,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 16),
              _componenteRow('Flete internacional', _incluyeFlete, _fleteCtrl,
                  (v) => setState(() => _incluyeFlete = v),
                  isMoney: true),
              _componenteRow('Seguro de carga (%)', _incluyeSeguro,
                  _seguroPctCtrl, (v) => setState(() => _incluyeSeguro = v)),
              _componenteRow('Arancel de importación (%)', _incluyeAduanas,
                  _arancelPctCtrl, (v) => setState(() => _incluyeAduanas = v)),
              _componenteRow('Honorarios agente aduanal', _incluyeEntrega,
                  _honorariosCtrl, (v) => setState(() => _incluyeEntrega = v),
                  isMoney: true),
              // DTA fijo
              Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _bord)),
                  child: Row(children: [
                    const Icon(Icons.receipt_long_outlined,
                        color: _sec, size: 16),
                    const SizedBox(width: 12),
                    const Expanded(
                        child: Text('DTA (Derecho de Trámite Aduanero)',
                            style: TextStyle(color: _sec, fontSize: 13))),
                    Text('\$${_dta.toStringAsFixed(2)} MXN',
                        style: const TextStyle(
                            color: _texto,
                            fontSize: 13,
                            fontWeight: FontWeight.bold))
                  ])),
              const SizedBox(height: 12),
              _switchRow('Incluir IVA (16%) sobre contribuciones', _incluyeIva,
                  (v) => setState(() => _incluyeIva = v)),
            ]),
          ),
          const SizedBox(height: 24),
          // Calcular
          SizedBox(
            width: double.infinity,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton.icon(
                  onPressed: _calculando ? null : _calcular,
                  icon: _calculando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: _bg, strokeWidth: 2))
                      : const Icon(Icons.calculate, color: _bg),
                  label: Text(
                      _calculando
                          ? 'Calculando...'
                          : 'Calcular Costo Door-to-Door',
                      style: const TextStyle(
                          color: _bg,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ambar,
                    disabledBackgroundColor: _ambar.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ),
          if (_resultado != null) ...[
            const SizedBox(height: 24),
            _buildResultado()
          ],
          const SizedBox(height: 40),
        ]),
      );

  Widget _componenteRow(String label, bool activo, TextEditingController ctrl,
          ValueChanged<bool> onToggle,
          {bool isMoney = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Switch(
              value: activo,
              onChanged: onToggle,
              activeThumbColor: _ambar,
              activeTrackColor: _ambar.withValues(alpha: 0.2)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style:
                      TextStyle(color: activo ? _texto : _sec, fontSize: 13))),
          const SizedBox(width: 12),
          SizedBox(
              width: 140,
              child: TextField(
                  controller: ctrl,
                  enabled: activo,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: _texto, fontSize: 13),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    prefixText: isMoney ? '\$ ' : '',
                    suffixText: isMoney ? '' : '%',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: _bg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _bord)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _bord)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _ambar)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: _bord.withValues(alpha: 0.5))),
                  ))),
        ]),
      );

  Widget _switchRow(String label, bool val, ValueChanged<bool> onCh) =>
      Row(children: [
        Switch(
            value: val,
            onChanged: onCh,
            activeThumbColor: _ambar,
            activeTrackColor: _ambar.withValues(alpha: 0.2)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: val ? _texto : _sec, fontSize: 13))
      ]);

  Widget _buildResultado() {
    final r = _resultado!;
    final total = r['total']!;
    final moneda = _moneda;
    return Column(children: [
      // Total destacado
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ambar.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
                color: _ambar.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 1),
          ],
        ),
        child: Column(children: [
          const Text('Costo Total Door-to-Door',
              style: TextStyle(color: _sec, fontSize: 14)),
          const SizedBox(height: 12),
          Text('\$${_fmt(total)} $moneda',
              style: const TextStyle(
                  color: _ambar, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (moneda == 'USD')
            Text('˜ \$${_fmt(total * 17.5)} MXN (TC estimado: 17.50)',
                style: const TextStyle(color: _sec, fontSize: 12)),
        ]),
      ),
      const SizedBox(height: 16),
      // Desglose
      _HoverCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Desglose del Costo',
              style: TextStyle(
                  color: _texto, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...[
            if (r['flete'] != null)
              _desgRow('Flete Internacional', r['flete']!, moneda, _azul,
                  Icons.directions_boat_outlined),
            if (r['seguro'] != null)
              _desgRow('Seguro de Carga', r['seguro']!, moneda, _verde,
                  Icons.health_and_safety_outlined),
            if (r['valorAduana'] != null)
              _desgRow('Valor en Aduana (CIF)', r['valorAduana']!, moneda, _sec,
                  Icons.account_balance_outlined),
            if (r['arancel'] != null)
              _desgRow('Arancel de Importación', r['arancel']!, moneda, _rojo,
                  Icons.percent),
            if (r['dta'] != null)
              _desgRow('DTA', r['dta']!, 'MXN', _ambar, Icons.receipt_outlined),
            if (r['iva'] != null)
              _desgRow('IVA (16%)', r['iva']!, moneda, _naran,
                  Icons.percent_outlined),
            if (r['honorarios'] != null)
              _desgRow('Honorarios Agente Aduanal', r['honorarios']!, 'MXN',
                  _verde, Icons.person_outlined),
          ],
          const Divider(color: _bord, height: 32),
          Row(children: [
            const Expanded(
                child: Text('TOTAL',
                    style: TextStyle(
                        color: _ambar,
                        fontSize: 15,
                        fontWeight: FontWeight.bold))),
            Text('\$${_fmt(total)} $moneda',
                style: const TextStyle(
                    color: _ambar, fontSize: 15, fontWeight: FontWeight.bold))
          ]),
        ]),
      ),
    ]);
  }

  Widget _desgRow(String label, double val, String m, Color c, IconData ic) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Icon(ic, color: c, size: 16),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: _sec, fontSize: 13))),
          Text('\$${_fmt(val)} $m',
              style: TextStyle(
                  color: c, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      );

  // -- Tab Historial ---------------------------------------------------------
  Widget _tabHistorial() {
    if (_historial.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.history, color: _sec.withValues(alpha: 0.5), size: 64),
        const SizedBox(height: 16),
        const Text('No hay cotizaciones previas.',
            style: TextStyle(color: _sec, fontSize: 15))
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historial.length,
      itemBuilder: (_, i) {
        final h = _historial[i];
        return _HoverCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _bord)),
                child: const Icon(Icons.calculate, color: _ambar, size: 24)),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('${h['origen']} ? ${h['destino']}',
                      style: const TextStyle(
                          color: _texto,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${h['modo']} · ${h['incoterm']} · ${h['fecha']}',
                      style: const TextStyle(color: _sec, fontSize: 12)),
                ])),
            Text(
                '\$${_fmt((h['total'] as num?)?.toDouble() ?? 0.0)} ${h['moneda']}',
                style: const TextStyle(
                    color: _ambar, fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
        );
      },
    );
  }

  // -- Calcular --------------------------------------------------------------
  Future<void> _calcular() async {
    setState(() => _calculando = true);

    final valor = double.tryParse(_valorMercCtrl.text) ?? 0;

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un cotizador experto de logística internacional y aduanas. Estima los costos basándote en la ruta, mercancía y modo de transporte. Devuelve un JSON puro con: flete (double), seguroPct (double), arancelPct (double), honorarios (double).'),
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt =
          'Ruta: $_origen a $_destino. Modo: $_modo. Incoterm: $_incoterm. Valor: $valor $_moneda. Mercancía: ${_descripCtrl.text}. Peso: ${_pesoCtrl.text}kg. Volumen: ${_volumenCtrl.text}m3. Estima los componentes (flete, % seguro, % arancel, honorarios).';
      final response = await model.generateContent([Content.text(prompt)]);

      final Map<String, dynamic> data =
          jsonDecode(response.text ?? '{}') as Map<String, dynamic>;

      final flete = _incluyeFlete
          ? ((data['flete'] as num?)?.toDouble() ??
              (double.tryParse(_fleteCtrl.text) ?? 0))
          : 0.0;
      final segPct = _incluyeSeguro
          ? ((data['seguroPct'] as num?)?.toDouble() ??
                  (double.tryParse(_seguroPctCtrl.text) ?? 0)) /
              100
          : 0.0;
      final aranPct = _incluyeAduanas
          ? ((data['arancelPct'] as num?)?.toDouble() ??
                  (double.tryParse(_arancelPctCtrl.text) ?? 0)) /
              100
          : 0.0;
      final honor = _incluyeEntrega
          ? ((data['honorarios'] as num?)?.toDouble() ??
              (double.tryParse(_honorariosCtrl.text) ?? 0))
          : 0.0;

      final valorCIF = valor + flete;
      final seguro = valorCIF * segPct;
      final arancel = valorCIF * aranPct;
      final iva = _incluyeIva ? (arancel + _dta / 17.5) * 0.16 : 0.0;
      final total = valor +
          flete +
          seguro +
          arancel +
          (honor / 17.5) +
          (_dta / 17.5) +
          iva;

      final now = DateTime.now();
      final fecha =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      setState(() {
        _calculando = false;
        _resultado = {
          'flete': flete,
          'seguro': seguro,
          'valorAduana': valorCIF,
          'arancel': arancel,
          'dta': _dta,
          'iva': iva,
          'honorarios': honor,
          'total': total,
        };
        _historial.insert(0, {
          'origen': _origen,
          'destino': _destino,
          'modo': _modo,
          'incoterm': _incoterm,
          'moneda': _moneda,
          'total': total,
          'fecha': fecha
        });
      });
    } catch (e) {
      setState(() => _calculando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error IA: $e'), backgroundColor: _rojo));
    }
  }

  // -- Helpers ---------------------------------------------------------------
  String _fmt(double v) => v.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  Widget _fi(TextEditingController c, String hint,
          [IconData? icon, bool num = false]) =>
      TextField(
          controller: c,
          keyboardType: num ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: _texto, fontSize: 14),
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _sec, fontSize: 13),
              prefixIcon:
                  icon != null ? Icon(icon, color: _sec, size: 18) : null,
              filled: true,
              fillColor: _bg,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _bord)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _bord)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _ambar))));

  Widget _dlabel(String l) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(l, style: const TextStyle(color: _sec, fontSize: 12)));
  Widget _ddrop(
          List<String> opts, String val, ValueChanged<String?> onCh) =>
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _bord)),
          child: DropdownButton<String>(
              value: opts.contains(val) ? val : opts.first,
              isExpanded: true,
              dropdownColor: _bg,
              underline: const SizedBox(),
              icon:
                  const Icon(Icons.keyboard_arrow_down, color: _sec, size: 20),
              style: const TextStyle(color: _texto, fontSize: 14),
              items: opts
                  .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: onCh));
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  const _HoverCard({required this.child, this.margin});

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
        padding: const EdgeInsets.all(20),
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
