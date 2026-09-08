import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import '../../services/normativa_service.dart';

// -- Design Tokens -------------------------------------------------------------
const Color _bg    = AppColors.bg;
const Color _card  = AppColors.card;
const Color _card2 = AppColors.card;
const Color _bord  = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec   = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo  = AppColors.red;
const Color _azul  = AppColors.blue;
const Color _verde = AppColors.green;
const Color _naran = Color(0xFFF97316);

// -- Tasa IGIE options ---------------------------------------------------------
const _tasas = ['0%', '5%', '7%', '10%', '15%', '20%', '25%', '30%', '35%'];

// -- Landed Cost Result ---------------------------------------------------------
class _LCResult {
  final double exWorks, fleteInt, seguro, cif, cifMxn;
  final double valorAduana, dta, prv, cnt, igie, iva;
  final double honorariosAA, fleteNac;
  final double totalMxn, totalUsd, costoPorPieza;
  final int piezas;
  const _LCResult({
    required this.exWorks, required this.fleteInt, required this.seguro, required this.cif, required this.cifMxn,
    required this.valorAduana, required this.dta, required this.prv, required this.cnt, required this.igie, required this.iva,
    required this.honorariosAA, required this.fleteNac,
    required this.totalMxn, required this.totalUsd, required this.costoPorPieza, required this.piezas,
  });
}

// -- Main Screen ---------------------------------------------------------------
class LandedCostScreen extends StatefulWidget {
  const LandedCostScreen({super.key});
  @override
  State<LandedCostScreen> createState() => _LandedCostScreenState();
}

class _LandedCostScreenState extends State<LandedCostScreen> {
  // Inputs
  final _exWorksCtrl   = TextEditingController(text: '10000');
  final _piezasCtrl    = TextEditingController(text: '500');
  final _fleteIntCtrl  = TextEditingController(text: '2500');
  final _seguroCtrl    = TextEditingController(text: '150');
  final _honorCtrl     = TextEditingController(text: '4500');
  final _fleteNacCtrl  = TextEditingController(text: '800');
  final _tcCtrl        = TextEditingController(text: '17.35');
  String _tasaIGIE     = '15%';

  _LCResult? _result;
  bool _calculating = false;

  double _v(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '')) ?? 0;
  double get _tasaPct => double.tryParse(_tasaIGIE.replaceAll('%', '')) ?? 0;
  double get _tc => double.tryParse(_tcCtrl.text) ?? 17.35;

  @override
  void dispose() {
    _exWorksCtrl.dispose(); _piezasCtrl.dispose(); _fleteIntCtrl.dispose();
    _seguroCtrl.dispose(); _honorCtrl.dispose(); _fleteNacCtrl.dispose(); _tcCtrl.dispose();
    super.dispose();
  }

  Future<void> _calcular() async {
    setState(() { _calculating = true; });
    
    final ns = NormativaService();
    await ns.fetchLatestTipoCambio();
    
    if (_tcCtrl.text.isEmpty || _tcCtrl.text == '17.35') {
      _tcCtrl.text = ns.tipoCambioFix.toStringAsFixed(4);
    }
    
    final exW  = _v(_exWorksCtrl);
    final flI  = _v(_fleteIntCtrl);
    final seg  = _v(_seguroCtrl);
    final cif  = exW + flI + seg;
    final cifM = cif * _tc;
    final va   = cifM;
    
    // DTA dinamico
    final dta  = ns.calcularDTA(va, 'Importacion Definitiva');
    final prv  = ns.prv;
    final cnt  = ns.cnt;
    
    final igie = va * (_tasaPct / 100);
    final iva  = (va + dta + prv + cnt + igie) * 0.16;
    final hon  = _v(_honorCtrl);
    final flN  = _v(_fleteNacCtrl);
    
    // Total includes PRV + CNT
    final total = va + dta + prv + cnt + igie + iva + hon + flN;
    final totalUsd = total / _tc;
    final pzs  = _v(_piezasCtrl).toInt();
    final double cpp = pzs > 0 ? total / pzs : 0.0;

    setState(() {
      _calculating = false;
      _result = _LCResult(
        exWorks: exW, fleteInt: flI, seguro: seg, cif: cif, cifMxn: cifM,
        valorAduana: va, dta: dta, prv: prv, cnt: cnt, igie: igie, iva: iva,
        honorariosAA: hon, fleteNac: flN,
        totalMxn: total, totalUsd: totalUsd,
        costoPorPieza: cpp, piezas: pzs,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        // -- Header -------------------------------------------------------------
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: const BoxDecoration(color: _bg, border: Border(bottom: BorderSide(color: _bord))),
          child: Row(children: [
            InkWell(onTap: () => Navigator.of(context).pop(), borderRadius: BorderRadius.circular(8),
              child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(8), border: Border.all(color: _bord)), child: const Icon(Icons.chevron_left, color: _sec, size: 20))),
            const SizedBox(width: 16),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Simulador de Landed Cost (Costo Puesto en Puerta)', style: TextStyle(color: _texto, fontSize: 15, fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),

        // -- Body ---------------------------------------------------------------
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Page title
            const Text('Visibilidad Total del Costo de Importacion', style: TextStyle(color: _texto, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Calculamos el Valor en Aduana, sumamos impuestos (DTA 8 al millar, IVA 16%, IGIE) y gastos logisticos para conocer el margen real.', style: TextStyle(color: _sec, fontSize: 12, height: 1.5)),
            const SizedBox(height: 24),

            // -- Input form ------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _bord)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Section label
                const Row(children: [Icon(Icons.input, color: _ambar, size: 15), SizedBox(width: 8), Text('Variables de Importacion (USD)', style: TextStyle(color: _ambar, fontSize: 13, fontWeight: FontWeight.w600))]),
                const SizedBox(height: 20),
                // Row 1
                Row(children: [
                  Expanded(child: _labeled('Valor Mercancia (Ex-Works)', _exWorksCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _labeled('Cantidad de Piezas', _piezasCtrl)),
                ]),
                const SizedBox(height: 14),
                // Row 2
                Row(children: [
                  Expanded(child: _labeled('Flete Internacional', _fleteIntCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _labeled('Seguro de Carga', _seguroCtrl)),
                ]),
                const SizedBox(height: 20),
                // Divider label
                const Row(children: [Icon(Icons.balance, color: _sec, size: 13), SizedBox(width: 6), Text('Variables Aduanales & Locales', style: TextStyle(color: _sec, fontSize: 11, fontWeight: FontWeight.w500))]),
                const SizedBox(height: 12),
                // Row 3
                Row(children: [
                  Expanded(child: _dropdownTasa()),
                  const SizedBox(width: 16),
                  Expanded(child: _labeled('Honorarios AA / Maniobras (MXN)', _honorCtrl)),
                ]),
                const SizedBox(height: 14),
                // Row 4
                Row(children: [
                  Expanded(child: _labeled('Flete Nacional a Bodega (MXN)', _fleteNacCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _labeled('TC (MXN/USD)', _tcCtrl, hint: '17.35')),
                ]),
                const SizedBox(height: 24),
                // Calculate button
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: _calculating ? null : _calcular,
                  icon: _calculating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.calculate, size: 18, color: Colors.black),
                  label: Text(_calculating ? 'Calculando...' : 'Calcular Landed Cost', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                  style: ElevatedButton.styleFrom(backgroundColor: _ambar, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                )),
              ]),
            ),

            // -- Results --------------------------------------------------------
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResults(_result!),
            ],
          ]),
        )),
      ]),
    );
  }

  Widget _buildResults(_LCResult r) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.bar_chart, color: _verde, size: 16), SizedBox(width: 8), Text('Desglose del Landed Cost', style: TextStyle(color: _texto, fontSize: 15, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 16),
      // -- Resultado layout: 2 columns ----------------------------------------
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Left: breakdown table
        Expanded(child: Column(children: [
          // CIF block
          _resultBlock('Valor en Aduana (CIF)', _ambar, [
            _rRow('Ex-Works',               '\$${r.exWorks.toStringAsFixed(2)} USD'),
            _rRow('Flete Internacional',    '+\$${r.fleteInt.toStringAsFixed(2)} USD'),
            _rRow('Seguro de Carga',        '+\$${r.seguro.toStringAsFixed(2)} USD'),
            _rRow('CIF Total (USD)',         '= \$${r.cif.toStringAsFixed(2)} USD', bold: true),
            _rRow('TC Aplicado',             '\$${_tc.toStringAsFixed(4)} MXN/USD'),
            _rRow('Valor en Aduana (MXN)',   '= \$${r.valorAduana.toStringAsFixed(2)} MXN', bold: true, color: _ambar),
          ]),
          const SizedBox(height: 12),
          // Impuestos block
          _resultBlock('Impuestos & Derechos', _rojo, [
            _rRow('DTA (Dinamico UMA)',       '\$${r.dta.toStringAsFixed(2)} MXN', color: _rojo),
            _rRow('Prevalidacion (PRV)',     '\$${r.prv.toStringAsFixed(2)} MXN', color: _rojo),
            _rRow('Contraprestacion (CNT)',  '\$${r.cnt.toStringAsFixed(2)} MXN', color: _rojo),
            _rRow('IGIE ($_tasaIGIE)',        '\$${r.igie.toStringAsFixed(2)} MXN', color: _rojo),
            _rRow('IVA 16%',                 '\$${r.iva.toStringAsFixed(2)} MXN', color: _naran),
            _rRow('Total Impuestos',         '\$${(r.dta + r.prv + r.cnt + r.igie + r.iva).toStringAsFixed(2)} MXN', bold: true, color: _rojo),
          ]),
          const SizedBox(height: 12),
          // Logística block
          _resultBlock('Gastos Logisticos', _azul, [
            _rRow('Honorarios AA + Maniobras', '\$${r.honorariosAA.toStringAsFixed(2)} MXN', color: _azul),
            _rRow('Flete Nacional a Bodega',  '\$${r.fleteNac.toStringAsFixed(2)} MXN', color: _azul),
            _rRow('Total Logistica',          '\$${(r.honorariosAA + r.fleteNac).toStringAsFixed(2)} MXN', bold: true, color: _azul),
          ]),
        ])),
        const SizedBox(width: 16),
        // Right: totals + chart
        Expanded(child: Column(children: [
          // TOTAL card
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [_verde.withAlpha(40), _verde.withAlpha(10)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12), border: Border.all(color: _verde.withAlpha(80))),
            child: Column(children: [
              const Text('LANDED COST TOTAL', style: TextStyle(color: _verde, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 10),
              Text('\$${r.totalMxn.toStringAsFixed(2)}', style: const TextStyle(color: _verde, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              const Text('MXN', style: TextStyle(color: _sec, fontSize: 11)),
              const SizedBox(height: 6),
              Text('˜ USD \$${r.totalUsd.toStringAsFixed(2)}', style: const TextStyle(color: _sec, fontSize: 12)),
              const SizedBox(height: 14),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 14),
              // Per unit
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.inventory_2_outlined, color: _ambar, size: 14),
                const SizedBox(width: 6),
                Column(children: [
                  Text('\$${r.costoPorPieza.toStringAsFixed(2)} MXN', style: const TextStyle(color: _ambar, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  Text('por pieza (${r.piezas} pzs)', style: const TextStyle(color: _sec, fontSize: 10)),
                ]),
              ]),
            ])),
          const SizedBox(height: 16),
          // Pie-style breakdown chart
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _bord)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.pie_chart_outline, color: _ambar, size: 14), SizedBox(width: 6), Text('Composicion del Costo', style: TextStyle(color: _texto, fontSize: 12, fontWeight: FontWeight.w600))]),
              const SizedBox(height: 14),
              _stackBar(r),
              const SizedBox(height: 12),
              _legend('Valor en Aduana', r.valorAduana, r.totalMxn, _ambar),
              _legend('IGIE ($_tasaIGIE)',  r.igie,        r.totalMxn, _rojo),
              _legend('IVA 16%',           r.iva,         r.totalMxn, _naran),
              _legend('DTA',               r.dta,         r.totalMxn, const Color(0xFFA855F7)),
              _legend('Logistica',         r.honorariosAA + r.fleteNac, r.totalMxn, _azul),
            ])),
          const SizedBox(height: 16),
          // Alert if IGIE > 20%
          if (_tasaPct >= 20)
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _rojo.withAlpha(15), borderRadius: BorderRadius.circular(10), border: Border.all(color: _rojo.withAlpha(80))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.warning_amber_rounded, color: _rojo, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Arancel Alto Detectado', style: TextStyle(color: _rojo, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('La tasa IGIE de $_tasaIGIE puede hacer inviable la importacion. Evalua alternativas: T-MEC, fracciones alternas, o proveedor de pais con TLC.', style: const TextStyle(color: _sec, fontSize: 10, height: 1.5)),
                ])),
              ])),
          const SizedBox(height: 12),
          // Effective rate
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _card2, borderRadius: BorderRadius.circular(10), border: Border.all(color: _bord)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Analisis de Carga Fiscal', style: TextStyle(color: _texto, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _fRow('Carga fiscal total', '${((r.dta + r.igie + r.iva) / r.totalMxn * 100).toStringAsFixed(1)}% del landed cost'),
              _fRow('Factor multiplicador', '${(r.totalMxn / r.cifMxn).toStringAsFixed(3)}x sobre CIF'),
              _fRow('Impacto por pieza (imp.)', '\$${((r.dta + r.igie + r.iva) / (r.piezas > 0 ? r.piezas : 1)).toStringAsFixed(2)} MXN'),
            ])),
        ])),
      ]),
    ]);
  }

  // -- Stack bar chart ----------------------------------------------------------
  Widget _stackBar(_LCResult r) {
    final total = r.totalMxn;
    final segments = [
      (r.valorAduana, _ambar),
      (r.igie, _rojo),
      (r.iva, _naran),
      (r.dta, const Color(0xFFA855F7)),
      (r.honorariosAA + r.fleteNac, _azul),
    ];
    return ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(height: 20, child: Row(children: segments.map((seg) {
      final pct = total > 0 ? (seg.$1 / total) : 0.0;
      return Expanded(flex: (pct * 1000).round(), child: Container(color: seg.$2));
    }).toList())));
  }

  Widget _legend(String l, double v, double total, Color c) {
    final pct = total > 0 ? (v / total * 100) : 0.0;
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Expanded(child: Text(l, style: const TextStyle(color: _sec, fontSize: 10))),
      Text('\$${v.toStringAsFixed(0)}', style: const TextStyle(color: _texto, fontSize: 10, fontFamily: 'monospace')),
      const SizedBox(width: 8),
      Text('(${pct.toStringAsFixed(1)}%)', style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.bold)),
    ]));
  }

  Widget _resultBlock(String title, Color c, List<Widget> rows) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(10), border: Border(left: BorderSide(color: c, width: 3), top: const BorderSide(color: _bord), right: const BorderSide(color: _bord), bottom: const BorderSide(color: _bord))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ...rows,
    ]),
  );

  Widget _rRow(String l, String v, {bool bold = false, Color? color}) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Row(children: [
    Expanded(child: Text(l, style: const TextStyle(color: _sec, fontSize: 11))),
    Text(v, style: TextStyle(color: color ?? (bold ? _texto : _sec), fontSize: 11, fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontFamily: 'monospace')),
  ]));

  Widget _fRow(String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
    const Icon(Icons.chevron_right, color: _sec, size: 12),
    const SizedBox(width: 4),
    Expanded(child: Text(l, style: const TextStyle(color: _sec, fontSize: 11))),
    Text(v, style: const TextStyle(color: _texto, fontSize: 11, fontWeight: FontWeight.w600)),
  ]));

  Widget _labeled(String label, TextEditingController c, {String? hint}) => TextField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    onChanged: (_) => setState(() {}),
    style: const TextStyle(color: _texto, fontSize: 13, fontFamily: 'monospace'),
    decoration: InputDecoration(
      labelText: label, labelStyle: const TextStyle(color: _sec, fontSize: 11),
      hintText: hint, hintStyle: const TextStyle(color: _sec),
      filled: true, fillColor: _bg, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _bord)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _bord)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _ambar)),
    ),
  );

  Widget _dropdownTasa() => DropdownButtonFormField<String>(
    initialValue: _tasaIGIE,
    dropdownColor: _card2,
    style: const TextStyle(color: _texto, fontSize: 13),
    decoration: InputDecoration(
      labelText: 'Tasa IGIE (%)', labelStyle: const TextStyle(color: _sec, fontSize: 11),
      filled: true, fillColor: _bg, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _bord)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _bord)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _ambar)),
    ),
    items: _tasas.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
    onChanged: (v) => setState(() => _tasaIGIE = v!),
  );
}



