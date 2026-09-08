import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ai/firebase_ai.dart';
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
const Color _morado = Color(0xFF8B5CF6);

// -- Catálogos ------------------------------------------------------------------
const _navieras = [
  'MAERSK',
  'MSC',
  'COSCO',
  'CMA CGM',
  'Hapag-Lloyd',
  'ONE',
  'Evergreen',
  'Yang Ming',
  'HMM',
  'Zim'
];
const _puertosOrigen = [
  'Shanghai (CNSHA)',
  'Qingdao (CNTAO)',
  'Ningbo (CNNBO)',
  'Shenzhen (CNSZX)',
  'Guangzhou (CNGZU)',
  'Busan (KRPUS)',
  'Tokyo (JPTYO)',
  'Hong Kong (HKHKG)',
  'Singapore (SGSIN)',
  'Rotterdam (NLRTM)',
  'Hamburg (DEHAM)',
  'Los Angeles (USLAX)'
];
const _puertosDestino = [
  'Manzanillo, Col. (MZMZL)',
  'Lazaro Cardenas, Mich. (MZLZC)',
  'Altamira, Tamps. (MZATM)',
  'Veracruz, Ver. (MZVER)',
  'Progreso, Yuc. (MZPGO)'
];
const _tiposContenedor = [
  '20ST (20\' Standard)',
  '40ST (40\' Standard)',
  '40HC (40\' High Cube)',
  '40RF (40\' Reefer)',
  '20OT (20\' Open Top)',
  '45HC (45\' High Cube)'
];

// -- Screen --------------------------------------------------------------------
class SliVgmGeneratorScreen extends StatefulWidget {
  const SliVgmGeneratorScreen({super.key});
  @override
  State<SliVgmGeneratorScreen> createState() => _SliVgmGeneratorScreenState();
}

class _SliVgmGeneratorScreenState extends State<SliVgmGeneratorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  int _paso = 0; // 0=SLI, 1=VGM, 2=Preview

  // -- SLI Data --------------------------------------------------------------
  final _shipperNomCtrl = TextEditingController();
  final _shipperDirCtrl = TextEditingController();
  final _shipperRfcCtrl = TextEditingController();
  final _consigneeCtrl = TextEditingController();
  final _notifyCtrl = TextEditingController();
  String _puertoCarga = 'Shanghai (CNSHA)';
  String _puertoDesc = 'Manzanillo, Col. (MZMZL)';
  String _naviera = 'MAERSK';
  final _barcoCtrll = TextEditingController();
  final _viajeCtrl = TextEditingController();
  final _etdCtrl = TextEditingController();
  final _etaCtrl = TextEditingController();
  final _marcasCtrl = TextEditingController();
  final _descripCtrl = TextEditingController();
  final _bultosCtrl = TextEditingController();
  final _pesoNetoCtrl = TextEditingController();
  final _pesobrutoCtrl = TextEditingController();
  final _volumenCtrl = TextEditingController();
  final _freightCtrl = TextEditingController(text: 'PREPAID');

  // -- Contenedores / VGM ---------------------------------------------------
  final List<_Contenedor> _contenedores = [];
  final String _tipoContenedor = '40HC (40\' High Cube)';
  String _metodVGM = 'Metodo 1 (Peso verificado)';

  bool _generando = false;
  bool _generado = false;
  String _sliNum = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    final now = DateTime.now();
    _etdCtrl.text =
        '${now.add(const Duration(days: 14)).day.toString().padLeft(2, '0')}/${now.add(const Duration(days: 14)).month.toString().padLeft(2, '0')}/${now.year}';
    _etaCtrl.text =
        '${now.add(const Duration(days: 42)).day.toString().padLeft(2, '0')}/${now.add(const Duration(days: 42)).month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  void dispose() {
    
    
    
    
    _tabCtrl.dispose();
    _shipperNomCtrl.dispose();
    _shipperDirCtrl.dispose();
    _shipperRfcCtrl.dispose();
    _consigneeCtrl.dispose();
    _notifyCtrl.dispose();
    _barcoCtrll.dispose();
    _viajeCtrl.dispose();
    _etdCtrl.dispose();
    _etaCtrl.dispose();
    _marcasCtrl.dispose();
    _descripCtrl.dispose();
    _bultosCtrl.dispose();
    _pesoNetoCtrl.dispose();
    _pesobrutoCtrl.dispose();
    _volumenCtrl.dispose();
    _freightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          _header(),
          _pasoIndicator(),
          Expanded(
              child: TabBarView(
                  controller: _tabCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                _tabSLI(),
                _tabVGM(),
                _tabPreview(),
              ])),
        ]),
        bottomNavigationBar: _bottomBar(),
      );

  Widget _header() => Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 14, 12),
        decoration: const BoxDecoration(
            color: _bg, border: Border(bottom: BorderSide(color: _bord))),
        child: Row(children: [
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
                  color: _teal.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _teal.withAlpha(80))),
              child:
                  const Icon(Icons.diamond_outlined, color: _teal, size: 16)),
          const SizedBox(width: 10),
          const Expanded(
              child: Text('SLI / VGM Generator',
                  style: TextStyle(
                      color: _texto,
                      fontSize: 15,
                      fontWeight: FontWeight.bold))),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: _morado.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _morado.withAlpha(40))),
              child: const Text('SOLAS 2024',
                  style: TextStyle(
                      color: _morado,
                      fontSize: 10,
                      fontWeight: FontWeight.bold))),
        ]),
      );

  Widget _pasoIndicator() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: _card2,
        child: Row(children: [
          _pasoChip(0, 'SLI'),
          Expanded(
              child: Container(height: 1, color: _paso > 0 ? _teal : _bord)),
          _pasoChip(1, 'VGM'),
          Expanded(
              child: Container(height: 1, color: _paso > 1 ? _teal : _bord)),
          _pasoChip(2, 'Vista Previa'),
        ]),
      );

  Widget _pasoChip(int p, String label) {
    final active = _paso == p;
    final done = _paso > p;
    final c = done
        ? _verde
        : active
            ? _teal
            : _sec;
    return Column(children: [
      Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              color: c.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: c.withAlpha(80))),
          child: Center(
              child: done
                  ? const Icon(Icons.check, color: _verde, size: 14)
                  : Text('${p + 1}',
                      style: TextStyle(
                          color: c,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)))),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: c, fontSize: 9)),
    ]);
  }

  // --------------------------------------------------------------------------
  // PASO 1 — SLI
  // --------------------------------------------------------------------------
  Widget _tabSLI() => SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          _sec2('Shipper (Exportador)', Icons.business_outlined, _azul, [
            _fi(_shipperNomCtrl, 'Nombre / Razon Social'),
            const SizedBox(height: 8),
            _fi(_shipperDirCtrl, 'Direccion completa'),
            const SizedBox(height: 8),
            _fi(_shipperRfcCtrl, 'RFC / Tax ID'),
          ]),
          const SizedBox(height: 12),
          _sec2('Consignee & Notify', Icons.person_outlined, _verde, [
            _fi(_consigneeCtrl, 'Consignee (Importador)'),
            const SizedBox(height: 8),
            _fi(_notifyCtrl, 'Notify Party (Agente/Broker)'),
          ]),
          const SizedBox(height: 12),
          _sec2('Buque & Ruta', Icons.directions_boat_outlined, _teal, [
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _dlabel('Naviera'),
                    _ddrop(_navieras, _naviera,
                        (v) => setState(() => _naviera = v!))
                  ])),
              const SizedBox(width: 10),
              Expanded(child: _fi(_barcoCtrll, 'Nombre del buque')),
              const SizedBox(width: 10),
              Expanded(child: _fi(_viajeCtrl, 'Numero de viaje')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _dlabel('Puerto de Carga'),
                    _ddrop(_puertosOrigen, _puertoCarga,
                        (v) => setState(() => _puertoCarga = v!))
                  ])),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _dlabel('Puerto de Descarga'),
                    _ddrop(_puertosDestino, _puertoDesc,
                        (v) => setState(() => _puertoDesc = v!))
                  ])),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child:
                      _fi(_etdCtrl, 'ETD (DD/MM/YYYY)', Icons.departure_board)),
              const SizedBox(width: 10),
              Expanded(child: _fi(_etaCtrl, 'ETA (DD/MM/YYYY)', Icons.anchor)),
            ]),
          ]),
          const SizedBox(height: 12),
          _sec2('Mercancia', Icons.inventory_outlined, _ambar, [
            _fi(_marcasCtrl, 'Marcas y numeros de bultos'),
            const SizedBox(height: 8),
            _fi(_descripCtrl, 'Descripcion de la mercancia'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child:
                      _fi(_bultosCtrl, 'Cantidad Bultos', Icons.numbers, true)),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      _fi(_pesoNetoCtrl, 'Peso Neto (kg)', Icons.scale, true)),
              const SizedBox(width: 8),
              Expanded(
                  child: _fi(_pesobrutoCtrl, 'Peso Bruto (kg)',
                      Icons.scale_outlined, true)),
              const SizedBox(width: 8),
              Expanded(
                  child: _fi(
                      _volumenCtrl, 'Volumen (m3)', Icons.straighten, true)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Expanded(
                  child: Text('Flete:',
                      style: TextStyle(color: _sec, fontSize: 11))),
              const SizedBox(width: 10),
              ...['PREPAID', 'COLLECT', 'AS ARRANGED'].map((f) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                      onTap: () => setState(() => _freightCtrl.text = f),
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: _freightCtrl.text == f
                                  ? _teal.withAlpha(25)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      _freightCtrl.text == f ? _teal : _bord)),
                          child: Text(f,
                              style: TextStyle(
                                  color: _freightCtrl.text == f ? _teal : _sec,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)))))),
            ]),
          ]),
          const SizedBox(height: 60),
        ]),
      );

  // --------------------------------------------------------------------------
  // PASO 2 — VGM (Verified Gross Mass)
  // --------------------------------------------------------------------------
  Widget _tabVGM() => SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          // SOLAS info
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: _morado.withAlpha(10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _morado.withAlpha(40))),
              child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: _morado, size: 14),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'SOLAS requiere la declaracion del VGM (Peso Bruto Verificado) antes de embarcar. El armador no puede cargar el contenedor sin este documento.',
                            style: TextStyle(
                                color: _morado, fontSize: 10, height: 1.4)))
                  ])),
          const SizedBox(height: 12),
          // Método
          _sec2('Metodo de Verificacion', Icons.rule_outlined, _teal, [
            for (final item in [
              (
                'Metodo 1 (Peso verificado)',
                'Pesar el contenedor lleno completo en una bascula certificada SOLAS.'
              ),
              (
                'Metodo 2 (Suma de pesos)',
                'Sumar el peso de cada item + material de embalaje + tara del contenedor.'
              ),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _metodVGM = item.$1),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          _metodVGM == item.$1 ? _teal.withAlpha(15) : _card2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _metodVGM == item.$1
                              ? _teal.withAlpha(80)
                              : _bord),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                  color: _metodVGM == item.$1
                                      ? _teal
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                          _metodVGM == item.$1 ? _teal : _sec)),
                              child: _metodVGM == item.$1
                                  ? const Icon(Icons.check,
                                      color: Colors.black, size: 10)
                                  : null),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(item.$1,
                                    style: TextStyle(
                                        color: _metodVGM == item.$1
                                            ? _teal
                                            : _texto,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                                Text(item.$2,
                                    style: const TextStyle(
                                        color: _sec,
                                        fontSize: 10,
                                        height: 1.3)),
                              ])),
                        ]),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 12),
          // Contenedores
          _sec2('Contenedores', Icons.view_in_ar_outlined, _ambar, [
            if (_contenedores.isEmpty)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                      child: Column(children: [
                    Icon(Icons.view_in_ar_outlined,
                        color: _sec.withAlpha(80), size: 40),
                    const SizedBox(height: 8),
                    const Text('Agrega los contenedores de este embarque.',
                        style: TextStyle(color: _sec, fontSize: 11))
                  ]))),
            ..._contenedores
                .asMap()
                .entries
                .map((e) => _contRow(e.key, e.value)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _dialogAgregarContenedor,
              icon: const Icon(Icons.add, size: 14, color: _ambar),
              label: const Text('Agregar Contenedor',
                  style: TextStyle(color: _ambar, fontSize: 11)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _ambar, width: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          ]),
          const SizedBox(height: 60),
        ]),
      );

  Widget _contRow(int idx, _Contenedor c) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: _card2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _bord)),
        child: Row(children: [
          const Icon(Icons.view_in_ar_outlined, color: _teal, size: 16),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(c.numero,
                    style: const TextStyle(
                        color: _texto,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace')),
                Text(
                    '${c.tipo} · Tara: ${c.tara}kg · Cargo: ${c.carga}kg · VGM: ${c.vgm}kg',
                    style: const TextStyle(color: _sec, fontSize: 9)),
              ])),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: _verde.withAlpha(15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _verde.withAlpha(50))),
              child: Text('${c.vgm} kg',
                  style: const TextStyle(
                      color: _verde,
                      fontSize: 9,
                      fontWeight: FontWeight.bold))),
          const SizedBox(width: 6),
          InkWell(
              onTap: () => setState(() => _contenedores.removeAt(idx)),
              child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, color: _sec, size: 14))),
        ]),
      );

  // --------------------------------------------------------------------------
  // PASO 3 — Vista Previa / Generar
  // --------------------------------------------------------------------------
  Widget _tabPreview() => SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          if (!_generado)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _bord)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumen del Documento',
                        style: TextStyle(
                            color: _texto,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    _prevRow('Naviera', _naviera),
                    _prevRow('Puerto Carga', _puertoCarga),
                    _prevRow('Puerto Destino', _puertoDesc),
                    _prevRow(
                        'ETD / ETA', '${_etdCtrl.text} / ${_etaCtrl.text}'),
                    _prevRow('Peso Bruto', '${_pesobrutoCtrl.text} kg'),
                    _prevRow('Volumen', '${_volumenCtrl.text} m3'),
                    _prevRow('Contenedores', '${_contenedores.length}'),
                    _prevRow('Metodo VGM', _metodVGM.split('(').first.trim()),
                    _prevRow('Flete', _freightCtrl.text),
                  ]),
            ),
          if (_generado) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _verde.withAlpha(80))),
              child: Column(children: [
                Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        color: _verde.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(color: _verde.withAlpha(60))),
                    child: const Icon(Icons.task_alt, color: _verde, size: 28)),
                const SizedBox(height: 12),
                const Text('SLI / VGM Generado',
                    style: TextStyle(
                        color: _verde,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_sliNum,
                    style: const TextStyle(
                        color: _teal, fontSize: 12, fontFamily: 'monospace')),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _sliNum));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Copiado.'),
                                    backgroundColor: _verde,
                                    behavior: SnackBarBehavior.floating));
                          },
                          icon: const Icon(Icons.copy, size: 13, color: _sec),
                          label: const Text('Copiar',
                              style: TextStyle(color: _sec, fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _bord),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text('Compartiendo SLI/VGM...'),
                                  backgroundColor: _azul,
                                  behavior: SnackBarBehavior.floating)),
                          icon: const Icon(Icons.share,
                              size: 13, color: Colors.black),
                          label: const Text('Compartir',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _teal,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))))),
                ]),
              ]),
            ),
          ],
          const SizedBox(height: 60),
        ]),
      );

  Widget _prevRow(String l, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: Text(l, style: const TextStyle(color: _sec, fontSize: 11))),
        Expanded(
            flex: 3,
            child: Text(v.isEmpty ? '—' : v,
                style: const TextStyle(
                    color: _texto, fontSize: 11, fontWeight: FontWeight.w600)))
      ]));

  Widget _bottomBar() => Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: const BoxDecoration(
            color: _bg, border: Border(top: BorderSide(color: _bord))),
        child: Row(children: [
          if (_paso > 0)
            Expanded(
                child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _paso--;
                        _tabCtrl.animateTo(_paso);
                      });
                    },
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _bord),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text('Atras',
                        style: TextStyle(color: _sec, fontSize: 13)))),
          if (_paso > 0) const SizedBox(width: 10),
          Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _generando
                    ? null
                    : () async {
                        if (_paso < 2) {
                          setState(() {
                            _paso++;
                            _tabCtrl.animateTo(_paso);
                          });
                        } else {
                          setState(() => _generando = true);
                          try {
                            final model = FirebaseAI.vertexAI().generativeModel(
                              model: 'gemini-1.5-flash',
                              systemInstruction: Content.system(
                                  'Eres un experto en logistica maritima y SOLAS VGM. Genera el SLI y certificado VGM para el embarque descrito.'),
                            );

                            final prompt =
                                '''Genera el texto de un SLI (Shipping Instructions) y certificado VGM con estos datos:
Shipper: ${_shipperNomCtrl.text}
Consignee: ${_consigneeCtrl.text}
Naviera: $_naviera
Puerto Carga: $_puertoCarga
Puerto Descarga: $_puertoDesc
Mercancia: ${_descripCtrl.text}

Devuelve solo el texto completo o un numero de referencia al final.''';

                            final response = await model
                                .generateContent([Content.text(prompt)]);

                            _sliNum = response.text?.trim() ?? 'SLI-ERROR';
                            setState(() {
                              _generando = false;
                              _generado = true;
                            });
                          } catch (e) {
                            setState(() => _generando = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Error: \$e',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.red));
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: _generando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : Text(
                        _paso < 2
                            ? 'Siguiente'
                            : _generado
                                ? 'Nuevo SLI/VGM'
                                : 'Generar SLI / VGM',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
              )),
        ]),
      );

  void _dialogAgregarContenedor() {
    final numCtrl = TextEditingController(
        text: 'MSCU${Random().nextInt(9000000) + 1000000}');
    final taraCtrl = TextEditingController(text: '2200');
    final cargaCtrl = TextEditingController();
    final selloCtrl = TextEditingController();
    String tipo = _tipoContenedor;

    showDialog<void>(
        context: context,
        barrierColor: Colors.black.withAlpha(160),
        builder: (_) => StatefulBuilder(
            builder: (ctx, ss) => Dialog(
                  backgroundColor: _card2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: SizedBox(
                      width: 420,
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
                              const Icon(Icons.view_in_ar_outlined,
                                  color: _teal, size: 16),
                              const SizedBox(width: 10),
                              const Text('Agregar Contenedor',
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
                        Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(children: [
                              Row(children: [
                                Expanded(
                                    child:
                                        _fi(numCtrl, 'Numero de contenedor')),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: _fi(selloCtrl, 'Numero de sello'))
                              ]),
                              const SizedBox(height: 10),
                              _dlabel('Tipo de Contenedor'),
                              _ddrop(
                                  _tiposContenedor,
                                  tipo,
                                  (v) => ss(() {
                                        tipo = v!;
                                        int tara = 2200;
                                        if (v.contains('40HC')) tara = 3900;
                                        if (v.contains('40ST')) tara = 3700;
                                        if (v.contains('20ST')) tara = 2200;
                                        taraCtrl.text = tara.toString();
                                      })),
                              const SizedBox(height: 10),
                              Row(children: [
                                Expanded(
                                    child: _fi(taraCtrl, 'Tara contenedor (kg)',
                                        Icons.scale, true)),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: _fi(
                                        cargaCtrl,
                                        'Peso de la carga (kg)',
                                        Icons.inventory_outlined,
                                        true))
                              ]),
                              const SizedBox(height: 16),
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final tara =
                                          double.tryParse(taraCtrl.text) ?? 0;
                                      final carga =
                                          double.tryParse(cargaCtrl.text) ?? 0;
                                      setState(() => _contenedores.add(
                                          _Contenedor(
                                              numero: numCtrl.text.isEmpty
                                                  ? 'MSCU0000000'
                                                  : numCtrl.text.toUpperCase(),
                                              tipo: tipo.split(' ').first,
                                              tara: tara.toInt(),
                                              carga: carga.toInt(),
                                              vgm: (tara + carga).toInt(),
                                              sello: selloCtrl.text)));
                                      Navigator.pop(ctx);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: _teal,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    child: const Text('Agregar',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                  )),
                            ])),
                      ])),
                )));
  }

  // -- Helpers ---------------------------------------------------------------
  Widget _sec2(String titulo, IconData icon, Color c, List<Widget> children) =>
      Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _bord)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, color: c, size: 14),
              const SizedBox(width: 8),
              Text(titulo,
                  style: TextStyle(
                      color: c, fontSize: 12, fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 12),
            ...children
          ]));
  Widget _fi(TextEditingController c, String hint,
          [IconData? icon, bool num = false]) =>
      TextField(
          controller: c,
          keyboardType: num ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: _texto, fontSize: 12),
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _sec, fontSize: 11),
              prefixIcon:
                  icon != null ? Icon(icon, color: _sec, size: 14) : null,
              filled: true,
              fillColor: _card2,
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
                  borderSide: const BorderSide(color: _teal))));
  Widget _dlabel(String l) => Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 2),
      child: Text(l, style: const TextStyle(color: _sec, fontSize: 10)));
  Widget _ddrop(
          List<String> opts, String val, ValueChanged<String?> onCh) =>
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
              color: _card2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _bord)),
          child: DropdownButton<String>(
              value: opts.contains(val) ? val : opts.first,
              isExpanded: true,
              dropdownColor: _card2,
              underline: const SizedBox(),
              icon:
                  const Icon(Icons.keyboard_arrow_down, color: _sec, size: 16),
              style: const TextStyle(color: _texto, fontSize: 11),
              items: opts
                  .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: onCh));
}

class _Contenedor {
  String numero;
  String tipo;
  int tara;
  int carga;
  int vgm;
  String sello;
  _Contenedor(
      {required this.numero,
      required this.tipo,
      required this.tara,
      required this.carga,
      required this.vgm,
      required this.sello});
}
