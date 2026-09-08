import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ComparadorIncotermsScreen extends StatefulWidget {
  const ComparadorIncotermsScreen({super.key});
  @override
  State<ComparadorIncotermsScreen> createState() =>
      _ComparadorIncotermsScreenState();
}

class _ComparadorIncotermsScreenState extends State<ComparadorIncotermsScreen> {
  final _valorCtrl = TextEditingController(text: '10000');
  final _fleteCtrl = TextEditingController(text: '500');
  final _seguroCtrl = TextEditingController(text: '100');
  final _arancelCtrl = TextEditingController(text: '5');
  final _tcCtrl = TextEditingController(text: '17.15');
  bool _esImmex = false;
  bool _calculado = false;

  List<_IncotermResult> _resultados = [];

  static const _incotermsData = [
    _IncotermDef(
        'EXW',
        'Ex Works',
        'El comprador asume todos los riesgos desde el origen. Valor en aduana m�s alto.',
        1.15,
        false),
    _IncotermDef(
        'FCA',
        'Free Carrier',
        'Vendedor entrega en punto designado. Com�n en transporte multimodal.',
        1.12,
        false),
    _IncotermDef(
        'FAS',
        'Free Alongside Ship',
        'Solo mar�timo. Vendedor lleva mercanc�a al costado del buque.',
        1.10,
        false),
    _IncotermDef('FOB', 'Free On Board',
        'El m�s com�n en MX-USA. VA incluye despacho origen.', 1.08, false),
    _IncotermDef(
        'CFR',
        'Cost and Freight',
        'Vendedor paga flete principal. Riesgo pasa al cargar el buque.',
        1.05,
        true),
    _IncotermDef('CIF', 'Cost Insurance Freight',
        'Est�ndar mar�timo. Incluye seguro + flete en VA.', 1.03, true),
    _IncotermDef('CPT', 'Carriage Paid To',
        'Similar a CFR para cualquier modo de transporte.', 1.03, true),
    _IncotermDef('CIP', 'Carriage Insurance Paid',
        'Similar a CIF multimodal. Cobertura seguro m�nima ICC-A.', 1.02, true),
    _IncotermDef('DAP', 'Delivered At Place',
        'Vendedor asume riesgo hasta destino final (sin descarga).', 1.0, true),
    _IncotermDef(
        'DPU',
        'Delivered Place Unloaded',
        'Incluye descarga en destino. M�ximo riesgo vendedor excepto aranceles.',
        1.0,
        true),
    _IncotermDef(
        'DDP',
        'Delivered Duty Paid',
        'Vendedor paga aranceles. Base VA puede ser menor por ajuste.',
        0.95,
        true),
  ];

  @override
  void dispose() {
    _tcCtrl.dispose();
    _arancelCtrl.dispose();
    _seguroCtrl.dispose();
    _fleteCtrl.dispose();
    _valorCtrl.dispose();
    for (final c in [
      _valorCtrl,
      _fleteCtrl,
      _seguroCtrl,
      _arancelCtrl,
      _tcCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _comparar() {
    final valor = double.tryParse(_valorCtrl.text) ?? 0;
    final flete = double.tryParse(_fleteCtrl.text) ?? 0;
    final seguro = double.tryParse(_seguroCtrl.text) ?? 0;
    final arancel = double.tryParse(_arancelCtrl.text) ?? 0;
    final tc = double.tryParse(_tcCtrl.text) ?? 17.15;

    _resultados = _incotermsData.map((inc) {
      final vaUSD = (valor * inc.factor) +
          (inc.incluyeFlete ? flete : flete * 1.1) +
          (inc.incluyeFlete ? seguro : seguro * 1.05);
      final vaMXN = vaUSD * tc;
      final igi = _esImmex ? 0.0 : vaMXN * (arancel / 100);
      final dta = vaMXN * 0.008 < 422 ? 422.0 : vaMXN * 0.008;
      final iva = (vaMXN + igi + dta) * 0.16;
      final total = igi + dta + iva;
      return _IncotermResult(
          inc: inc, vaMXN: vaMXN, igi: igi, dta: dta, iva: iva, total: total);
    }).toList();

    // Ordenar para identificar el menor total
    final minTotal =
        _resultados.map((r) => r.total).reduce((a, b) => a < b ? a : b);
    for (var r in _resultados) {
      r.esMejor = (r.total - minTotal).abs() < 1;
    }

    setState(() => _calculado = true);
  }

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            child: Row(children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 20),
                  onPressed: () => context.go('/inmex')),
              const Expanded(
                  child: Text('Comparador de Incoterms � Impacto Fiscal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 16,
                          fontWeight: FontWeight.w600))),
              IconButton(
                  icon: const Icon(Icons.refresh,
                      color: Color(0xFF6B7E99), size: 20),
                  onPressed: () => setState(() {
                        _calculado = false;
                        _resultados = [];
                      })),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card de par�metros
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Par�metros de la operaci�n',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(
                              child: _inputField(_valorCtrl,
                                  'Valor Factura (USD)', Icons.attach_money)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _inputField(_fleteCtrl, 'Flete (USD)',
                                  Icons.directions_boat)),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                              child: _inputField(
                                  _seguroCtrl, 'Seguro (USD)', Icons.security)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _inputField(_arancelCtrl, 'Tasa Arancel %',
                                  Icons.percent)),
                        ]),
                        const SizedBox(height: 10),
                        SizedBox(
                            width: 280,
                            child: _inputField(
                                _tcCtrl,
                                'Tipo de Cambio MXN/USD',
                                Icons.currency_exchange)),
                        const SizedBox(height: 14),
                        // Toggle IMMEX
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                              color: _esImmex
                                  ? const Color(0xFF1A2A1A)
                                  : const Color(0xFF0F1521),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: _esImmex
                                      ? AppColors.gold
                                      : AppColors.border)),
                          child: Row(children: [
                            Switch(
                              value: _esImmex,
                              onChanged: (v) => setState(() => _esImmex = v),
                              activeThumbColor: AppColors.gold,
                              trackColor:
                                  WidgetStateProperty.all(AppColors.border),
                            ),
                            const SizedBox(width: 10),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('R�gimen IMMEX (IGI exento)',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                      'Importaci�n temporal bajo programa IMMEX � IGI = \$0',
                                      style: TextStyle(
                                          color: _esImmex
                                              ? AppColors.gold
                                              : const Color(0xFF6B7E99),
                                          fontSize: 11)),
                                ]),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _comparar,
                            icon: const Icon(Icons.compare_arrows, size: 18),
                            label: const Text('Comparar todos los Incoterms',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: AppColors.bg,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16))),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabla de resultados
                  if (_calculado) ...[
                    const SizedBox(height: 20),
                    const Text('Resultados por Incoterm',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: AppColors.gold)),
                      const SizedBox(width: 6),
                      const Text('= Menor costo total',
                          style:
                              TextStyle(color: AppColors.gold, fontSize: 11)),
                      const SizedBox(width: 14),
                      if (_esImmex)
                        const Text('?? IMMEX: IGI = \$0 en todos',
                            style:
                                TextStyle(color: AppColors.gold, fontSize: 11)),
                    ]),
                    const SizedBox(height: 12),

                    // Header tabla
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: const BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8))),
                      child: const Row(children: [
                        SizedBox(
                            width: 70,
                            child: Text('Incoterm',
                                style: TextStyle(
                                    color: AppColors.sub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600))),
                        Expanded(
                            child: Text('VA (MXN)',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: AppColors.sub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600))),
                        Expanded(
                            child: Text('IGI',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: AppColors.sub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600))),
                        Expanded(
                            child: Text('DTA',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: AppColors.sub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600))),
                        Expanded(
                            child: Text('IVA',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: AppColors.sub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600))),
                        Expanded(
                            child: Text('TOTAL',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: AppColors.sub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600))),
                      ]),
                    ),

                    // Filas
                    ..._resultados.asMap().entries.map((entry) {
                      final i = entry.key;
                      final r = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: r.esMejor
                              ? const Color(0xFF0A2A1A)
                              : i.isEven
                                  ? AppColors.card
                                  : const Color(0xFF0F1521),
                          border: Border(
                            left: r.esMejor
                                ? const BorderSide(
                                    color: AppColors.gold, width: 3)
                                : BorderSide.none,
                            bottom: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Row(children: [
                          SizedBox(
                              width: 70,
                              child: Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF1A2A40),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: r.esMejor
                                              ? AppColors.gold
                                              : AppColors.blue)),
                                  child: Text(r.inc.clave,
                                      style: TextStyle(
                                          color: r.esMejor
                                              ? AppColors.gold
                                              : AppColors.blue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ),
                                if (r.esMejor)
                                  const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(Icons.star,
                                          color: AppColors.gold, size: 12)),
                              ])),
                          Expanded(
                              child: Text(fmt.format(r.vaMXN),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: Color(0xFFCBD5E1), fontSize: 12))),
                          Expanded(
                              child: Text(fmt.format(r.igi),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: _esImmex
                                          ? const Color(0xFF4A5568)
                                          : AppColors.gold,
                                      fontSize: 12))),
                          Expanded(
                              child: Text(fmt.format(r.dta),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: AppColors.blue, fontSize: 12))),
                          Expanded(
                              child: Text(fmt.format(r.iva),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: AppColors.gold, fontSize: 12))),
                          Expanded(
                              child: Text(fmt.format(r.total),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: r.esMejor
                                          ? AppColors.gold
                                          : Colors.white,
                                      fontSize: 12,
                                      fontWeight: r.esMejor
                                          ? FontWeight.bold
                                          : FontWeight.normal))),
                        ]),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.sub, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.blue, size: 18),
        filled: true,
        fillColor: AppColors.bg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.gold)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

// -- Data models ------------------------------------------------------------
class _IncotermDef {
  final String clave, nombre, descripcion;
  final double factor;
  final bool incluyeFlete;
  const _IncotermDef(this.clave, this.nombre, this.descripcion, this.factor,
      this.incluyeFlete);
}

class _IncotermResult {
  final _IncotermDef inc;
  final double vaMXN, igi, dta, iva, total;
  bool esMejor = false;
  _IncotermResult(
      {required this.inc,
      required this.vaMXN,
      required this.igi,
      required this.dta,
      required this.iva,
      required this.total});
}
