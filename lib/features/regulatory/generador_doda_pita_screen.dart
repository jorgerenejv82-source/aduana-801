import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';
import 'dart:math';

// -- Design Tokens -------------------------------------------------------------
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _card2 = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _gold = AppColors.gold;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;
const Color _morado = AppColors.blue;

// -- Catálogos ------------------------------------------------------------------
const List<String> _aduanas = [
  'Nuevo Laredo',
  'Tijuana',
  'Ciudad Juarez',
  'Nogales',
  'Matamoros',
  'Reynosa',
  'Piedras Negras',
  'Agua Prieta',
  'Mexicali',
  'Tecate',
  'Altamira',
  'Manzanillo',
  'Lazaro Cardenas',
  'Veracruz',
  'Progreso',
];

const List<String> _tiposOp = [
  'Importacion',
  'Exportacion',
  'Transito Internacional',
  'Importacion Temporal',
  'Exportacion Temporal',
  'Deposito Fiscal',
];

// -- Model ---------------------------------------------------------------------
class _DodaRecord {
  final String folio;
  final String aduana;
  final String patente;
  final String pedimento;
  final String tipo;
  final String rfc;
  final String nombre;
  final String fecha;
  final String placas;
  _DodaRecord(
      {required this.folio,
      required this.aduana,
      required this.patente,
      required this.pedimento,
      required this.tipo,
      required this.rfc,
      required this.nombre,
      required this.fecha,
      required this.placas});
}

String _genFolio() {
  final r = Random();
  const chars = '0123456789ABCDEF';
  return 'DODA-${List.generate(8, (_) => chars[r.nextInt(chars.length)]).join()}';
}

// -- Screen --------------------------------------------------------------------
class GeneradorDodaPitaScreen extends StatefulWidget {
  const GeneradorDodaPitaScreen({super.key});
  @override
  State<GeneradorDodaPitaScreen> createState() =>
      _GeneradorDodaPitaScreenState();
}

class _GeneradorDodaPitaScreenState extends State<GeneradorDodaPitaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // -- Operación -------------------------------------------------------------
  String _aduana = 'Nuevo Laredo';
  String _tipoOp = 'Importacion';
  final _patenteCtrl = TextEditingController();
  final _pedimentoCtrl = TextEditingController();
  final _fechaCruceCtrl = TextEditingController();

  // -- Importador ------------------------------------------------------------
  final _rfcImpCtrl = TextEditingController();
  final _nombreImpCtrl = TextEditingController();

  // -- Transportista ---------------------------------------------------------
  final _caatCtrl = TextEditingController();
  final _rfcTransCtrl = TextEditingController();
  final _nomTransCtrl = TextEditingController();
  final _placasCtrl = TextEditingController();
  final _remolqueCtrl = TextEditingController();
  final _candadoCtrl = TextEditingController();

  // -- Mercancía -------------------------------------------------------------
  final _descCtrl = TextEditingController();
  final _bultosCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _coveCtrl = TextEditingController();
  final _contenedorCtrl = TextEditingController();

  bool _generando = false;
  final List<_DodaRecord> _historial = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    // Set default fecha cruce
    final now = DateTime.now().add(const Duration(hours: 2));
    _fechaCruceCtrl.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _patenteCtrl.dispose();
    _pedimentoCtrl.dispose();
    _fechaCruceCtrl.dispose();
    _rfcImpCtrl.dispose();
    _nombreImpCtrl.dispose();
    _caatCtrl.dispose();
    _rfcTransCtrl.dispose();
    _nomTransCtrl.dispose();
    _placasCtrl.dispose();
    _remolqueCtrl.dispose();
    _candadoCtrl.dispose();
    _descCtrl.dispose();
    _bultosCtrl.dispose();
    _pesoCtrl.dispose();
    _coveCtrl.dispose();
    _contenedorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _buildHeader(),
        Expanded(
            child: TabBarView(
                controller: _tabCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
              _tabGenerar(),
              _tabHistorial(),
            ])),
      ]),
    );
  }

  // -- Header ----------------------------------------------------------------
  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 14, 0),
        decoration: const BoxDecoration(
            color: _bg, border: Border(bottom: BorderSide(color: _bord))),
        child: Column(children: [
          Row(children: [
            InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _bord)),
                    child:
                        const Icon(Icons.chevron_left, color: _sec, size: 20))),
            const SizedBox(width: 10),
            Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: _gold.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _gold.withAlpha(80))),
                child: const Icon(Icons.qr_code_2, color: _gold, size: 16)),
            const SizedBox(width: 10),
            const Text('Generador DODA/PITA',
                style: TextStyle(
                    color: _texto, fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabCtrl,
            indicatorColor: _gold,
            labelColor: _gold,
            unselectedLabelColor: _sec,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            tabs: const [
              Tab(
                  icon: Icon(Icons.qr_code_scanner, size: 14),
                  text: 'Generar DODA'),
              Tab(icon: Icon(Icons.history, size: 14), text: 'Historial'),
            ],
          ),
        ]),
      );

  // --------------------------------------------------------------------------
  // TAB 1 — Generar DODA
  // --------------------------------------------------------------------------
  Widget _tabGenerar() => Column(children: [
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            // Banner
            _banner(),
            const SizedBox(height: 14),
            // Operación Aduanera
            _seccion(
                'Operacion Aduanera', Icons.account_balance_outlined, _azul, [
              _dlabel('Aduana'),
              _ddrop(_aduanas, _aduana, (v) => setState(() => _aduana = v!)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _fi(_patenteCtrl, 'Patente')),
                const SizedBox(width: 10),
                Expanded(child: _fi(_pedimentoCtrl, 'Pedimento')),
              ]),
              const SizedBox(height: 10),
              _dlabel('Tipo de Operacion'),
              _ddrop(_tiposOp, _tipoOp, (v) => setState(() => _tipoOp = v!)),
              const SizedBox(height: 10),
              _fi(_fechaCruceCtrl, 'Fecha de cruce esperada (YYYY-MM-DD HH:mm)',
                  Icons.schedule),
            ]),
            const SizedBox(height: 12),
            // Importador / Exportador
            _seccion(
                'Importador / Exportador', Icons.business_outlined, _verde, [
              _fi(_rfcImpCtrl, 'RFC Importador/Exportador'),
              const SizedBox(height: 10),
              _fi(_nombreImpCtrl, 'Nombre / Razon Social'),
            ]),
            const SizedBox(height: 12),
            // Transportista
            _seccion('Transportista', Icons.local_shipping_outlined, _gold, [
              _fi(_caatCtrl, 'CAAT'),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _fi(_rfcTransCtrl, 'RFC Transportista')),
                const SizedBox(width: 10),
                Expanded(child: _fi(_nomTransCtrl, 'Nombre Transportista')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _fi(_placasCtrl, 'Placas')),
                const SizedBox(width: 10),
                Expanded(child: _fi(_remolqueCtrl, 'Remolque/Caja')),
              ]),
              const SizedBox(height: 10),
              _fi(_candadoCtrl, 'Candado / Sello'),
            ]),
            const SizedBox(height: 12),
            // Mercancía
            _seccion('Mercancia', Icons.inventory_outlined, _morado, [
              _fi(_descCtrl, 'Descripcion de mercancia',
                  Icons.description_outlined),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child:
                        _fi(_bultosCtrl, 'Cant. Bultos', Icons.numbers, true)),
                const SizedBox(width: 10),
                Expanded(child: _fi(_pesoCtrl, 'Peso (KG)', Icons.scale, true)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _fi(_coveCtrl, 'COVE # (Opcional)')),
                const SizedBox(width: 10),
                Expanded(
                    child: _fi(_contenedorCtrl, 'Contenedor # (Opcional)')),
              ]),
            ]),
            const SizedBox(height: 80),
          ]),
        )),
        // Bottom button
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          decoration: const BoxDecoration(
              color: _bg, border: Border(top: BorderSide(color: _bord))),
          child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generando ? null : _generarDoda,
                icon: _generando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.qr_code_scanner,
                        size: 16, color: Colors.black),
                label: Text(
                    _generando ? 'Generando DODA...' : 'Generar DODA/PITA',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
              )),
        ),
      ]);

  Widget _banner() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: _card2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bord)),
        child: Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _gold.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _gold.withAlpha(60))),
              child: const Icon(Icons.local_shipping_outlined,
                  color: _gold, size: 18)),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Generador DODA/PITA',
                style: TextStyle(
                    color: _texto, fontSize: 13, fontWeight: FontWeight.bold)),
            Text(
                'Documento de Operacion para Despacho Aduanero con formato QR oficial',
                style: TextStyle(color: _sec, fontSize: 10)),
          ]),
        ]),
      );

  // --------------------------------------------------------------------------
  // TAB 2 — Historial
  // --------------------------------------------------------------------------
  Widget _tabHistorial() {
    if (_historial.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.qr_code_2, color: _sec.withAlpha(80), size: 52),
        const SizedBox(height: 16),
        const Text('No hay DODAs generados.',
            style: TextStyle(color: _sec, fontSize: 13)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _tabCtrl.animateTo(0),
          child: const Text('Generar el primero',
              style: TextStyle(
                  color: _gold,
                  fontSize: 12,
                  decoration: TextDecoration.underline)),
        ),
      ]));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(14),
      itemCount: _historial.length,
      itemBuilder: (_, i) {
        final d = _historial[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: _gold.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _gold.withAlpha(60))),
                  child: const Icon(Icons.qr_code, color: _gold, size: 18)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(d.folio,
                        style: const TextStyle(
                            color: _texto,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace')),
                    Text('${d.aduana} · ${d.tipo}',
                        style: const TextStyle(color: _sec, fontSize: 10)),
                  ])),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: const Center(
                    child:
                        Icon(Icons.qr_code_2, color: Colors.black, size: 40)),
              ),
            ]),
            const SizedBox(height: 10),
            const Divider(color: _bord, height: 1),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _histRow(
                      'Pedimento', d.pedimento.isEmpty ? '—' : d.pedimento)),
              Expanded(child: _histRow('RFC', d.rfc.isEmpty ? '—' : d.rfc)),
              Expanded(
                  child: _histRow('Placas', d.placas.isEmpty ? '—' : d.placas)),
              Expanded(child: _histRow('Fecha', d.fecha)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                      text:
                          '${d.folio}|${d.aduana}|${d.pedimento}|${d.rfc}|${d.placas}'));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('DODA copiado al portapapeles.'),
                      backgroundColor: _verde,
                      behavior: SnackBarBehavior.floating));
                },
                icon: const Icon(Icons.copy, size: 12, color: _sec),
                label: const Text('Copiar',
                    style: TextStyle(color: _sec, fontSize: 10)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _bord),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Compartiendo DODA...'),
                        backgroundColor: _azul,
                        behavior: SnackBarBehavior.floating)),
                icon: const Icon(Icons.share, size: 12, color: _gold),
                label: const Text('Compartir',
                    style: TextStyle(color: _gold, fontSize: 10)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _gold, width: 0.5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
            ]),
          ]),
        );
      },
    );
  }

  Widget _histRow(String l, String v) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l,
            style: const TextStyle(
                color: _sec, fontSize: 8, fontWeight: FontWeight.w600)),
        Text(v,
            style: const TextStyle(color: _texto, fontSize: 10),
            overflow: TextOverflow.ellipsis),
      ]);

  // -- Generar DODA action ---------------------------------------------------
  Future<void> _generarDoda() async {
    setState(() => _generando = true);

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres el sistema aduanero MATCE del SAT. Genera los datos simulados de respuesta para un DODA/PITA exitoso respondiendo en JSON puro con "folio" (folio DODA alfanumérico).'),
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt =
          'Aduana: $_aduana, Patente: ${_patenteCtrl.text}, Pedimento: ${_pedimentoCtrl.text}, RFC: ${_rfcImpCtrl.text}, Placas: ${_placasCtrl.text}. Genera el folio.';
      final response = await model.generateContent([Content.text(prompt)]);

      final Map<String, dynamic> data =
          jsonDecode(response.text ?? '{}') as Map<String, dynamic>;
      final folio = data['folio']?.toString() ?? _genFolio();

      final now = DateTime.now();
      final record = _DodaRecord(
        folio: folio,
        aduana: _aduana,
        patente: _patenteCtrl.text,
        pedimento: _pedimentoCtrl.text,
        tipo: _tipoOp,
        rfc: _rfcImpCtrl.text,
        nombre: _nombreImpCtrl.text,
        fecha:
            '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        placas: _placasCtrl.text,
      );

      setState(() {
        _generando = false;
        _historial.insert(0, record);
      });

      // Show generated dialog
      if (!mounted) return;
      _mostrarDialog(folio);
    } catch (e) {
      setState(() => _generando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error IA: $e'), backgroundColor: _verde));
      }
    }
  }

  void _mostrarDialog(String folio) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha(160),
      builder: (_) => Dialog(
        backgroundColor: _card2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: _gold.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(color: _gold.withAlpha(60))),
                child: const Icon(Icons.check_circle_outline,
                    color: _gold, size: 28)),
            const SizedBox(height: 16),
            const Text('DODA/PITA Generado',
                style: TextStyle(
                    color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(folio,
                style: const TextStyle(
                    color: _gold,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Simulated QR
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Center(
                  child: Icon(Icons.qr_code_2, color: Colors.black, size: 100)),
            ),
            const SizedBox(height: 8),
            const Text('Codigo QR listo para imprimir y presentar en garita',
                style: TextStyle(color: _sec, fontSize: 10),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(_);
                  _tabCtrl.animateTo(1);
                },
                icon: const Icon(Icons.history, size: 14, color: _sec),
                label: const Text('Ver Historial',
                    style: TextStyle(color: _sec, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _bord),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                      text: '$folio|$_aduana|${_pedimentoCtrl.text}'));
                  Navigator.pop(_);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Copiado al portapapeles.'),
                      backgroundColor: _verde,
                      behavior: SnackBarBehavior.floating));
                },
                icon: const Icon(Icons.copy, size: 14, color: Colors.black),
                label: const Text('Copiar',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  // -- Helpers ---------------------------------------------------------------
  Widget _seccion(
          String titulo, IconData icon, Color c, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bord)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: c, size: 14),
            const SizedBox(width: 8),
            Text(titulo,
                style: TextStyle(
                    color: c, fontSize: 12, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          ...children,
        ]),
      );

  Widget _fi(TextEditingController c, String label,
          [IconData? icon, bool isNum = false]) =>
      TextField(
        controller: c,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: _texto, fontSize: 12),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: _sec, fontSize: 11),
          prefixIcon: icon != null ? Icon(icon, color: _sec, size: 14) : null,
          filled: true,
          fillColor: _card2,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _bord)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _bord)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _gold)),
        ),
      );

  Widget _dlabel(String l) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(l, style: const TextStyle(color: _sec, fontSize: 10)));

  Widget _ddrop(List<String> opts, String val, ValueChanged<String?> onCh) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
            color: _card2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bord)),
        child: DropdownButton<String>(
          value: val,
          isExpanded: true,
          dropdownColor: _card2,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, color: _sec, size: 16),
          style: const TextStyle(color: _texto, fontSize: 12),
          items: opts
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onCh,
        ),
      );
}
