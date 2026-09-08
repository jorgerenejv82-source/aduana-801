import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _card2 = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;
const Color _teal = Color(0xFF4ECCA3);

// -----------------------------------------------------------------------------
// Calculadora de Seguros de Carga Internacional
// -----------------------------------------------------------------------------
class CalculadoraSegurosScreen extends StatefulWidget {
  const CalculadoraSegurosScreen({super.key});
  @override
  State<CalculadoraSegurosScreen> createState() =>
      _CalculadoraSegurosScreenState();
}

class _CalculadoraSegurosScreenState extends State<CalculadoraSegurosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // Form state
  String _tipoCarga = 'General';
  String _modo = 'Maritimo FCL';
  String _clausula = 'Clausula A (All Risks)';
  String _deducible = '0%';
  final _fobCtrl = TextEditingController();
  final _fleteCtrl = TextEditingController();
  final _origenCtrl = TextEditingController();
  final _destinoCtrl = TextEditingController();

  // Resultado
  Map<String, double>? _resultado;
  bool _calculando = false;

  // -- Tablas de tasas --------------------------------------------------------
  static const _tasas = {
    'General': 0.0040,
    'Carga Peligrosa': 0.0085,
    'Refrigerada': 0.0060,
    'Automotriz': 0.0035,
    'Textil y Calzado': 0.0030,
    'Granel (Bulk)': 0.0025,
    'Arte y Objetos Valor': 0.0120,
  };
  static const _modoMult = {
    'Maritimo FCL': 1.00,
    'Maritimo LCL': 1.15,
    'Aereo': 0.80,
    'Terrestre': 0.90,
    'Multimodal': 1.05,
  };
  static const _clausMult = {
    'Clausula A (All Risks)': 1.00,
    'Clausula B (Named Perils)': 0.75,
    'Clausula C (Basica)': 0.55,
  };
  static const _deducDesc = {
    '0%': 0.00,
    '1%': 0.05,
    '2%': 0.10,
    '5%': 0.20,
  };

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _fobCtrl.dispose();
    _fleteCtrl.dispose();
    _origenCtrl.dispose();
    _destinoCtrl.dispose();
    super.dispose();
  }

  Future<void> _calcular() async {
    final fob = double.tryParse(_fobCtrl.text.replaceAll(',', '')) ?? 0;
    final flete = double.tryParse(_fleteCtrl.text.replaceAll(',', '')) ?? 0;
    if (fob <= 0) {
      setState(() => _resultado = null);
      return;
    }

    setState(() {
      _calculando = true;
      _resultado = null;
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un actuario experto en seguros de carga internacional. Estima las tasas y primas de seguro. Devuelve JSON con: primaBase (double), descuentoMonto (double), primaFinal (double), tasa (double).'),
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt =
          'Carga: $_tipoCarga. Origen: ${_origenCtrl.text}. Destino: ${_destinoCtrl.text}. FOB: $fob. Flete: $flete. Modo: $_modo. Cláusula: $_clausula. Deducible: $_deducible.';
      final response = await model.generateContent([Content.text(prompt)]);

      final Map<String, dynamic> data =
          jsonDecode(response.text ?? '{}') as Map<String, dynamic>;

      const tcMxn = 17.50;
      final cif = fob + flete;
      final sumaAsegurada = cif * 1.10;

      final primaBase = (data['primaBase'] as num?)?.toDouble() ?? 0.0;
      final descuentoMonto =
          (data['descuentoMonto'] as num?)?.toDouble() ?? 0.0;
      final primaFinal = (data['primaFinal'] as num?)?.toDouble() ?? 0.0;
      final tasa = (data['tasa'] as num?)?.toDouble() ?? 0.0;
      final desc = descuentoMonto / (primaBase > 0 ? primaBase : 1);

      setState(() {
        _calculando = false;
        _resultado = {
          'fob': fob,
          'cif': cif,
          'sumaAsegurada': sumaAsegurada,
          'primaBase': primaBase,
          'descuentoMonto': descuentoMonto,
          'primaFinal': primaFinal,
          'primaFinalMxn': primaFinal * tcMxn,
          'tasa': tasa,
          'descuento': desc * 100,
        };
      });
    } catch (e) {
      setState(() => _calculando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error IA: $e'), backgroundColor: _rojo));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          _buildHeader(),
          Expanded(
              child: TabBarView(controller: _tabCtrl, children: [
            _tabCalcular(),
            _tabCoberturas(),
          ])),
        ]),
      );

  Widget _buildHeader() => Container(
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
                  child: const Icon(Icons.chevron_left, color: _sec, size: 20)),
            ),
            const SizedBox(width: 10),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: _verde.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _verde.withAlpha(80))),
              child:
                  const Icon(Icons.health_and_safety, color: _verde, size: 16),
            ),
            const SizedBox(width: 10),
            const Expanded(
                child: Text('Calculadora de Seguros',
                    style: TextStyle(
                        color: _texto,
                        fontSize: 15,
                        fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: _verde.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _verde.withAlpha(40))),
              child: const Text('ICC 2009 A/B/C',
                  style: TextStyle(
                      color: _verde,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabCtrl,
            indicatorColor: _verde,
            labelColor: _verde,
            unselectedLabelColor: _sec,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(
                  icon: Icon(Icons.calculate_outlined, size: 13),
                  text: 'Calcular Prima'),
              Tab(
                  icon: Icon(Icons.table_chart_outlined, size: 13),
                  text: 'Coberturas'),
            ],
          ),
        ]),
      );

  // -- Tab Calcular ----------------------------------------------------------
  Widget _tabCalcular() => SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          // Tipo de carga
          _sec2('Tipo de Carga y Ruta', Icons.inventory_2_outlined, _ambar, [
            _label('Tipo de Mercancia'),
            _drop(
                _tasas.keys.toList(),
                _tipoCarga,
                (v) => setState(() {
                      _tipoCarga = v!;
                      _resultado = null;
                    })),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _label('Puerto / Ciudad Origen'),
                    _fi(_origenCtrl, 'Ej. Shanghai', Icons.flight_takeoff),
                  ])),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _label('Puerto / Ciudad Destino'),
                    _fi(_destinoCtrl, 'Ej. Manzanillo', Icons.flight_land),
                  ])),
            ]),
          ]),
          const SizedBox(height: 12),

          // Valores
          _sec2('Valores de la Mercancia', Icons.attach_money, _azul, [
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _label('Valor FOB (USD)'),
                    _fi(_fobCtrl, '0', Icons.attach_money, num: true),
                  ])),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _label('Flete Internacional (USD)'),
                    _fi(_fleteCtrl, '0', Icons.directions_boat_outlined,
                        num: true),
                  ])),
            ]),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: _azul.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _azul.withAlpha(40))),
              child: const Text(
                  'Suma asegurada = (FOB + Flete) x 1.10  (CIF + 10%, norma internacional ICC)',
                  style: TextStyle(color: _azul, fontSize: 10)),
            ),
          ]),
          const SizedBox(height: 12),

          // Modo y cobertura
          _sec2('Modo de Transporte y Cobertura', Icons.local_shipping_outlined,
              _teal, [
            _label('Modo de Transporte'),
            _drop(
                _modoMult.keys.toList(),
                _modo,
                (v) => setState(() {
                      _modo = v!;
                      _resultado = null;
                    })),
            const SizedBox(height: 10),
            _label('Clausula de Cobertura'),
            _drop(
                _clausMult.keys.toList(),
                _clausula,
                (v) => setState(() {
                      _clausula = v!;
                      _resultado = null;
                    })),
            const SizedBox(height: 10),
            _label('Deducible (reduce prima)'),
            _drop(
                _deducDesc.keys.toList(),
                _deducible,
                (v) => setState(() {
                      _deducible = v!;
                      _resultado = null;
                    })),
          ]),
          const SizedBox(height: 14),

          // Botón calcular
          SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculando ? null : _calcular,
                icon: _calculando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.calculate,
                        color: Colors.black, size: 16),
                label: Text(
                    _calculando ? 'Calculando...' : 'Calcular Prima de Seguro',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _verde,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              )),

          // Resultado
          if (_resultado != null) ...[
            const SizedBox(height: 16),
            _resultCard(_resultado!),
          ],
        ]),
      );

  Widget _resultCard(Map<String, double> r) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _verde.withAlpha(80)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.check_circle_outline, color: _verde, size: 16),
            const SizedBox(width: 8),
            const Text('Resultado del Calculo',
                style: TextStyle(
                    color: _verde, fontSize: 13, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('Tasa efectiva: ${r['tasa']!.toStringAsFixed(3)}%',
                style: const TextStyle(color: _sec, fontSize: 10)),
          ]),
          const Divider(color: _bord, height: 20),
          _rRow('Valor FOB', 'USD ${_fmt(r['fob']!)}', _sec),
          _rRow('Valor CIF (FOB + Flete)', 'USD ${_fmt(r['cif']!)}', _sec),
          const Divider(color: _bord, height: 12),
          _rRow('Suma Asegurada (CIF x 1.10)',
              'USD ${_fmt(r['sumaAsegurada']!)}', _texto),
          _rRow('Prima Base', 'USD ${_fmt(r['primaBase']!)}', _texto),
          if (r['descuento']! > 0)
            _rRow('Descuento Deducible', '-USD ${_fmt(r['descuentoMonto']!)}',
                _verde),
          const Divider(color: _bord, height: 12),
          Row(children: [
            const Text('PRIMA FINAL',
                style: TextStyle(
                    color: _texto, fontSize: 14, fontWeight: FontWeight.bold)),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('USD ${_fmt(r['primaFinal']!)}',
                  style: const TextStyle(
                      color: _verde,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('MXN ${_fmt(r['primaFinalMxn']!)}',
                  style: const TextStyle(color: _sec, fontSize: 11)),
            ]),
          ]),
          const SizedBox(height: 14),
          const Text('Aseguradoras recomendadas:',
              style: TextStyle(color: _sec, fontSize: 10)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final a in const [
              'Chubb',
              'AXA XL',
              'Mapfre',
              'Zurich',
              'HDI'
            ])
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: _azul.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _azul.withAlpha(50))),
                child: Text(a,
                    style: const TextStyle(
                        color: _azul,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: _ambar.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _ambar.withAlpha(40))),
            child: const Row(children: [
              Icon(Icons.info_outline, color: _ambar, size: 13),
              SizedBox(width: 8),
              Expanded(
                  child: Text(
                      'Certificado de seguro es documento obligatorio en aduana (Art. 36-A Ley Aduanera).',
                      style: TextStyle(color: _ambar, fontSize: 10))),
            ]),
          ),
        ]),
      );

  Widget _rRow(String l, String v, Color c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(l, style: const TextStyle(color: _sec, fontSize: 11)),
          const Spacer(),
          Text(v,
              style: TextStyle(
                  color: c, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      );

  // -- Tab Coberturas --------------------------------------------------------
  Widget _tabCoberturas() => SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              'Comparativa de Clausulas ICC (Institute Cargo Clauses) 2009',
              style: TextStyle(
                  color: _texto, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(
              'Segun publicacion de Lloyd\'s Market Association (LMA) y International Underwriting Association (IUA)',
              style: TextStyle(color: _sec, fontSize: 10)),
          const SizedBox(height: 14),
          _coberturaTable(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _bord)),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.lightbulb_outline, color: _ambar, size: 13),
                    SizedBox(width: 6),
                    Text('Recomendacion del Experto',
                        style: TextStyle(
                            color: _ambar,
                            fontSize: 11,
                            fontWeight: FontWeight.bold))
                  ]),
                  SizedBox(height: 8),
                  Text(
                      'Para mercancia general de valor medio-alto (electronica, maquinaria, textil): CLAUSULA A. Para graneles secos o materias primas de bajo valor: CLAUSULA C. Para mercancias en contenedor refrigerado: CLAUSULA A + cobertura adicional cambio de temperatura.',
                      style:
                          TextStyle(color: _texto, fontSize: 11, height: 1.5)),
                ]),
          ),
        ]),
      );

  Widget _coberturaTable() {
    const riesgos = [
      ('Perdida total', true, true, true),
      ('Robo total', true, false, false),
      ('Dano parcial', true, false, false),
      ('Agua de mar', true, true, true),
      ('Lluvia / agua dulce', true, false, false),
      ('Dano por calor/frio', true, false, false),
      ('Rotura', true, false, false),
      ('Contaminacion', true, false, false),
      ('Demora (adicional)', false, false, false),
      ('Guerra y huelga (adicional)', false, false, false),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _bord)),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
              color: _card2,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
          child: Row(children: [
            const Expanded(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text('Riesgo',
                        style: TextStyle(
                            color: _sec,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)))),
            for (final h in const ['Clausula A', 'Clausula B', 'Clausula C'])
              Expanded(
                  child: Center(
                      child: Text(h,
                          style: const TextStyle(
                              color: _texto,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)))),
          ]),
        ),
        for (int i = 0; i < riesgos.length; i++)
          Container(
            color: i.isEven ? _card : _card2,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Expanded(
                  flex: 3,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(riesgos[i].$1,
                          style:
                              const TextStyle(color: _texto, fontSize: 10)))),
              Expanded(child: Center(child: _coverIcon(riesgos[i].$2))),
              Expanded(child: Center(child: _coverIcon(riesgos[i].$3))),
              Expanded(child: Center(child: _coverIcon(riesgos[i].$4))),
            ]),
          ),
      ]),
    );
  }

  Widget _coverIcon(bool covered) => Icon(
        covered ? Icons.check_circle : Icons.cancel_outlined,
        color: covered ? _verde : _rojo,
        size: 16,
      );

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

  Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(t, style: const TextStyle(color: _sec, fontSize: 10)));

  Widget _fi(TextEditingController c, String hint, IconData icon,
          {bool num = false}) =>
      TextField(
        controller: c,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: _texto, fontSize: 12),
        onChanged: (_) => _calcular(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _sec, fontSize: 11),
          prefixIcon: Icon(icon, color: _sec, size: 14),
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
              borderSide: const BorderSide(color: _verde)),
        ),
      );

  Widget _drop(List<String> opts, String val, ValueChanged<String?> onCh) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
            color: _card2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _bord)),
        child: DropdownButton<String>(
          value: val,
          isExpanded: true,
          dropdownColor: _card2,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, color: _sec, size: 16),
          style: const TextStyle(color: _texto, fontSize: 11),
          items: opts
              .map((o) => DropdownMenuItem(
                  value: o, child: Text(o, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onCh,
        ),
      );

  String _fmt(double v) => v
      .toStringAsFixed(2)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');
}
