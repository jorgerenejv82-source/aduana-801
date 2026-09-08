import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';
import 'dart:math';

// â”€â”€ Design Tokens â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
const Color _naran = Color(0xFFF97316);
const double _tc = 17.1500;

// â”€â”€ Models â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _Linea {
  TextEditingController desc = TextEditingController();
  TextEditingController fraccion = TextEditingController();
  TextEditingController sku = TextEditingController();
  TextEditingController cant = TextEditingController(text: '1');
  TextEditingController pu = TextEditingController(text: '0');
  String unidad = 'PZA';

  double get subtotal =>
      (double.tryParse(cant.text) ?? 0) * (double.tryParse(pu.text) ?? 0);

  void dispose() {
    desc.dispose();
    fraccion.dispose();
    sku.dispose();
    cant.dispose();
    pu.dispose();
  }
}

class _Proforma {
  final String ref;
  final String emisor;
  final String receptor;
  final double total;
  final String fecha;
  final String incoterm;
  final String moneda;
  _Proforma(
      {required this.ref,
      required this.emisor,
      required this.receptor,
      required this.total,
      required this.fecha,
      required this.incoterm,
      required this.moneda});
}

String _genRef() {
  final r = Random();
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final suffix = List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  final now = DateTime.now();
  return 'PROF-${now.year}-$suffix';
}

// â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class MotorProformasScreen extends StatefulWidget {
  const MotorProformasScreen({super.key});
  @override
  State<MotorProformasScreen> createState() => _MotorProformasScreenState();
}

class _MotorProformasScreenState extends State<MotorProformasScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // â”€â”€ Emisor â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final _emisorNombre = TextEditingController();
  final _emisorRfc = TextEditingController();
  final _emisorDir = TextEditingController();
  final _emisorPais = TextEditingController();
  // â”€â”€ Receptor â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final _recNombre = TextEditingController();
  final _recFiscal = TextEditingController();
  final _recDir = TextEditingController();
  final _recPais = TextEditingController();
  // â”€â”€ Embarque â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String _incoterm = 'FOB';
  String _moneda = 'USD';
  String _transporte = 'Maritimo';
  final _puertoCarga = TextEditingController();
  final _puertoDescarga = TextEditingController();
  DateTime _fechaEmbarque = DateTime.now().add(const Duration(days: 30));
  String _numRef = _genRef();
  // â”€â”€ Líneas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final List<_Linea> _lineas = [_Linea()];
  // â”€â”€ Totales â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final _fleteCtrl = TextEditingController(text: '0');
  final _seguroCtrl = TextEditingController(text: '0');
  bool _generando = false;

  final List<_Proforma> _historial = [];

  // â”€â”€ Computed â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  double get _subtotalMerc => _lineas.fold(0.0, (s, l) => s + l.subtotal);
  double get _flete => double.tryParse(_fleteCtrl.text) ?? 0;
  double get _seguro => double.tryParse(_seguroCtrl.text) ?? 0;
  double get _grandTotal => _subtotalMerc + _flete + _seguro;
  double get _valorAduanaMx => _grandTotal * _tc;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    // Listen for changes to recalculate
    for (final l in _lineas) {
      l.cant.addListener(() => setState(() {}));
      l.pu.addListener(() => setState(() {}));
    }
    _fleteCtrl.addListener(() => setState(() {}));
    _seguroCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final l in _lineas) {
      l.dispose();
    }
    _tabCtrl.dispose();
    _emisorNombre.dispose();
    _emisorRfc.dispose();
    _emisorDir.dispose();
    _emisorPais.dispose();
    _recNombre.dispose();
    _recFiscal.dispose();
    _recDir.dispose();
    _recPais.dispose();
    _puertoCarga.dispose();
    _puertoDescarga.dispose();
    _fleteCtrl.dispose();
    _seguroCtrl.dispose();
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
        title: const Text('Generador de Proformas Comerciales',
            style: TextStyle(
                color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: _nuevaProforma,
              icon: const Icon(Icons.add, color: _azul)),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: DecoratedBox(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _bord))),
            child: TabBar(
              controller: _tabCtrl,
              indicatorColor: _azul,
              labelColor: _azul,
              unselectedLabelColor: _sec,
              labelStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              tabs: const [
                Tab(
                    icon: Icon(Icons.description_outlined, size: 18),
                    text: 'Nueva Proforma'),
                Tab(icon: Icon(Icons.history, size: 18), text: 'Historial'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(controller: _tabCtrl, children: [
        _tabNuevaProforma(),
        _tabHistorial(),
      ]),
      persistentFooterButtons: [
        Container(
          color: _bg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: MediaQuery.of(context).size.width,
          child: Row(children: [
            Expanded(
                child: ElevatedButton.icon(
              onPressed: _generarConIA,
              icon: _generando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2))
                  : const Icon(Icons.auto_awesome,
                      size: 18, color: Colors.black),
              label: Text(_generando ? 'Generando...' : 'Generar con IA',
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _azul,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            )),
            const SizedBox(width: 16),
            Expanded(
                child: ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Exportando PDF...',
                          style: TextStyle(color: _bg)),
                      backgroundColor: _rojo,
                      behavior: SnackBarBehavior.floating)),
              icon: const Icon(Icons.picture_as_pdf_outlined,
                  size: 18, color: Colors.white),
              label: const Text('Exportar PDF',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _rojo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            )),
            const SizedBox(width: 16),
            Expanded(
                child: ElevatedButton.icon(
              onPressed: _guardarProforma,
              icon: const Icon(Icons.save_outlined,
                  size: 18, color: Colors.white),
              label: const Text('Guardar',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _verde,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            )),
          ]),
        ),
      ],
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // TAB 1 â€” Nueva Proforma
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _tabNuevaProforma() => SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // TC Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _bord)),
            child: Row(children: [
              const Icon(Icons.currency_exchange, color: _ambar, size: 20),
              const SizedBox(width: 12),
              const Text('TC FIX Banxico: ',
                  style: TextStyle(
                      color: _sec, fontSize: 14, fontWeight: FontWeight.bold)),
              const Text('\$17.1500 MXN/USD',
                  style: TextStyle(
                      color: _ambar,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: _naran.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _naran.withValues(alpha: 0.5))),
                  child: const Text('Fallback',
                      style: TextStyle(
                          color: _naran,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
              const Spacer(),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, color: _sec, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints()),
            ]),
          ),
          const SizedBox(height: 24),

          // Datos del Emisor | Receptor
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: _seccionCard(
                    'Datos del Emisor', Icons.business_outlined, _azul, [
              _fi(_emisorNombre, 'Empresa exportadora (razon social)',
                  Icons.business_outlined),
              const SizedBox(height: 12),
              _fi(_emisorRfc, 'RFC o Tax ID', Icons.badge_outlined),
              const SizedBox(height: 12),
              _fi(_emisorDir, 'Direccion completa', Icons.home_outlined),
              const SizedBox(height: 12),
              _fi(_emisorPais, 'Pais de origen', Icons.flag_outlined),
            ])),
            const SizedBox(width: 24),
            Expanded(
                child: _seccionCard(
                    'Datos del Receptor', Icons.person_outlined, _azul, [
              _fi(_recNombre, 'Nombre comprador/importador',
                  Icons.person_outlined),
              const SizedBox(height: 12),
              _fi(_recFiscal, 'ID fiscal del comprador', Icons.badge_outlined),
              const SizedBox(height: 12),
              _fi(_recDir, 'Direccion de destino', Icons.location_on_outlined),
              const SizedBox(height: 12),
              _fi(_recPais, 'Pais de destino', Icons.flag_outlined),
            ])),
          ]),
          const SizedBox(height: 24),

          // Detalles del Embarque
          _seccionCard(
              'Detalles del Embarque', Icons.local_shipping_outlined, _ambar, [
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Incoterm',
                        style: TextStyle(
                            color: _sec,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _dropdown([
                      'FOB',
                      'CIF',
                      'EXW',
                      'DAP',
                      'DDP',
                      'CFR',
                      'FAS',
                      'CPT',
                      'CIP',
                      'DAT'
                    ], _incoterm, (v) => setState(() => _incoterm = v!),
                        icon: Icons.handshake_outlined),
                  ])),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Moneda',
                        style: TextStyle(
                            color: _sec,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _dropdown(['USD', 'MXN', 'EUR', 'CAD', 'JPY'], _moneda,
                        (v) => setState(() => _moneda = v!),
                        icon: Icons.attach_money),
                  ])),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Medio de transporte',
                        style: TextStyle(
                            color: _sec,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _dropdown([
                      'Maritimo',
                      'Aereo',
                      'Terrestre',
                      'Ferroviario',
                      'Multimodal'
                    ], _transporte, (v) => setState(() => _transporte = v!),
                        icon: Icons.directions_boat_outlined),
                  ])),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: _fi(_puertoCarga, 'Puerto de carga', Icons.anchor)),
              const SizedBox(width: 16),
              Expanded(
                  child:
                      _fi(_puertoDescarga, 'Puerto de descarga', Icons.anchor)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                      context: context,
                      initialDate: _fechaEmbarque,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (c, ch) => Theme(
                          data: ThemeData.dark().copyWith(
                              colorScheme:
                                  const ColorScheme.dark(primary: _azul)),
                          child: ch!));
                  if (d != null) setState(() => _fechaEmbarque = d);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _bord)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: _sec, size: 20),
                    const SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha estimada de embarque',
                              style: TextStyle(
                                  color: _sec,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                              '${_fechaEmbarque.day.toString().padLeft(2, '0')} / ${_mesAbrev(_fechaEmbarque.month)} / ${_fechaEmbarque.year}',
                              style: const TextStyle(
                                  color: _texto,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ]),
                  ]),
                ),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _bord)),
                child: Row(children: [
                  const Icon(Icons.tag, color: _sec, size: 20),
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Numero de referencia proforma',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_numRef,
                            style: const TextStyle(
                                color: _texto,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace')),
                      ]),
                ]),
              )),
            ]),
          ]),
          const SizedBox(height: 24),

          // Líneas de producto
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _bord),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                        color: _azul, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                const Text('Lineas de Producto',
                    style: TextStyle(
                        color: _azul,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_outlined,
                      size: 16, color: _ambar),
                  label: const Text('Importar de Pedimento',
                      style: TextStyle(
                          color: _ambar,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _ambar),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _agregarLinea,
                  icon: const Icon(Icons.add, size: 16, color: Colors.black),
                  label: const Text('Agregar Linea',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _azul,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ]),
              const SizedBox(height: 16),
              // Table header
              const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    SizedBox(width: 32),
                    Expanded(
                        flex: 3,
                        child: Text('Descripcion',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    SizedBox(width: 8),
                    Expanded(
                        flex: 2,
                        child: Text('Fraccion',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    SizedBox(width: 8),
                    Expanded(
                        flex: 2,
                        child: Text('SKU / Parte',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    SizedBox(width: 8),
                    SizedBox(
                        width: 80,
                        child: Text('Cant.',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    SizedBox(width: 8),
                    SizedBox(
                        width: 100,
                        child: Text('Unidad',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    SizedBox(width: 8),
                    Expanded(
                        flex: 2,
                        child: Text('P.U.',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    SizedBox(width: 8),
                    SizedBox(
                        width: 120,
                        child: Text('Subtotal',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right)),
                  ])),
              const Divider(color: _bord, height: 1),
              ..._lineas.asMap().entries.map((e) {
                final i = e.key;
                final l = e.value;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(children: [
                    SizedBox(
                        width: 24,
                        child: Text('${i + 1}.',
                            style: const TextStyle(
                                color: _sec,
                                fontSize: 14,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 3,
                        child: _mini(l.desc, 'Descripcion del producto')),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 2,
                        child: _mini(l.fraccion, 'Fraccion arancelaria')),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _mini(l.sku, 'SKU / No. parte')),
                    const SizedBox(width: 8),
                    SizedBox(
                        width: 80,
                        child: _mini(l.cant, '1',
                            isNum: true, onCh: () => setState(() {}))),
                    const SizedBox(width: 8),
                    SizedBox(
                        width: 100,
                        child: _dropdownMini([
                          'PZA',
                          'KG',
                          'LT',
                          'MT',
                          'M2',
                          'M3',
                          'TON',
                          'JGO',
                          'PAQ',
                          'CAJ'
                        ], l.unidad, (v) => setState(() => l.unidad = v!))),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 2,
                        child: _mini(l.pu, '0',
                            isNum: true, onCh: () => setState(() {}))),
                    const SizedBox(width: 8),
                    SizedBox(
                        width: 120,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _bord)),
                          child: Text(
                              '${l.subtotal.toStringAsFixed(2)} $_moneda',
                              style: const TextStyle(
                                  color: _ambar,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right),
                        )),
                    if (_lineas.length > 1) ...[
                      const SizedBox(width: 8),
                      InkWell(
                          onTap: () => setState(() => _lineas.removeAt(i)),
                          child:
                              const Icon(Icons.close, color: _rojo, size: 20)),
                    ],
                  ]),
                );
              }),
            ]),
          ),
          const SizedBox(height: 24),

          // Totales
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _bord),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Left â€” Flete / Seguro
              SizedBox(
                  width: 350,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                    color: _azul, shape: BoxShape.circle)),
                            const SizedBox(width: 12),
                            const Text('Totales',
                                style: TextStyle(
                                    color: _azul,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Flete estimado (USD)',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _fi(_fleteCtrl, '0', Icons.directions_boat_outlined,
                            isNum: true),
                        const SizedBox(height: 16),
                        const Text('Seguro estimado (USD)',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _fi(_seguroCtrl, '0', Icons.security_outlined,
                            isNum: true),
                      ])),
              const SizedBox(width: 48),
              // Right â€” Summary
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _totRow('Subtotal mercancia',
                        '${_subtotalMerc.toStringAsFixed(2)} $_moneda', _sec),
                    _totRow(
                        'Flete', '${_flete.toStringAsFixed(2)} $_moneda', _sec),
                    _totRow('Seguro', '${_seguro.toStringAsFixed(2)} $_moneda',
                        _sec),
                    const Divider(color: _bord, height: 32),
                    _totRow('Grand Total',
                        '${_grandTotal.toStringAsFixed(2)} $_moneda', _azul,
                        bold: true, big: true),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: _card2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _bord)),
                      child: Row(children: [
                        const Icon(Icons.currency_exchange,
                            color: _ambar, size: 24),
                        const SizedBox(width: 16),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Valor en Aduana MX',
                                  style: TextStyle(
                                      color: _sec,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('MXN ${_valorAduanaMx.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: _ambar,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text('TC: $_tc | Fallback',
                                  style: TextStyle(color: _sec, fontSize: 11)),
                            ]),
                      ]),
                    ),
                  ])),
            ]),
          ),
          const SizedBox(height: 80),
        ]),
      );

  Widget _totRow(String l, String v, Color c,
          {bool bold = false, bool big = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Text(l,
              style: TextStyle(
                  color: big ? _texto : _sec,
                  fontSize: big ? 16 : 14,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          Text(v,
              style: TextStyle(
                  color: c,
                  fontSize: big ? 24 : 14,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ]),
      );

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // TAB 2 â€” Historial
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _tabHistorial() {
    if (_historial.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.description_outlined,
            color: _sec.withValues(alpha: 0.5), size: 80),
        const SizedBox(height: 24),
        const Text('Sin proformas guardadas.',
            style: TextStyle(
                color: _sec, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _tabCtrl.animateTo(0),
            child: const Text('Crear la primera proforma',
                style: TextStyle(
                    color: _azul,
                    fontSize: 14,
                    decoration: TextDecoration.underline)),
          ),
        ),
      ]));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      itemCount: _historial.length,
      itemBuilder: (_, i) {
        final p = _historial[i];
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _bord),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child: Row(children: [
              Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: _verde.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _verde.withValues(alpha: 0.3))),
                  child:
                      const Icon(Icons.receipt_long, color: _verde, size: 28)),
              const SizedBox(width: 24),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(p.ref,
                        style: const TextStyle(
                            color: _texto,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace')),
                    const SizedBox(height: 8),
                    Text(
                        '${p.emisor.isEmpty ? "Emisor" : p.emisor}  â†’  ${p.receptor.isEmpty ? "Receptor" : p.receptor}',
                        style: const TextStyle(color: _sec, fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(children: [
                      _pill(p.incoterm, _azul),
                      const SizedBox(width: 12),
                      _pill(p.moneda, _ambar),
                      const SizedBox(width: 12),
                      _pill(p.fecha, _sec),
                    ]),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${p.total.toStringAsFixed(2)} ${p.moneda}',
                    style: const TextStyle(
                        color: _ambar,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: _verde.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: _verde.withValues(alpha: 0.3))),
                    child: const Text('Guardada',
                        style: TextStyle(
                            color: _verde,
                            fontSize: 12,
                            fontWeight: FontWeight.bold))),
              ]),
            ]),
          ),
        );
      },
    );
  }

  // â”€â”€ Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _agregarLinea() {
    final l = _Linea();
    l.cant.addListener(() => setState(() {}));
    l.pu.addListener(() => setState(() {}));
    setState(() => _lineas.add(l));
  }

  void _nuevaProforma() => setState(() {
        _emisorNombre.clear();
        _emisorRfc.clear();
        _emisorDir.clear();
        _emisorPais.clear();
        _recNombre.clear();
        _recFiscal.clear();
        _recDir.clear();
        _recPais.clear();
        _puertoCarga.clear();
        _puertoDescarga.clear();
        _fleteCtrl.text = '0';
        _seguroCtrl.text = '0';
        _incoterm = 'FOB';
        _moneda = 'USD';
        _transporte = 'Maritimo';
        _fechaEmbarque = DateTime.now().add(const Duration(days: 30));
        _numRef = _genRef();
        _lineas.clear();
        _lineas.add(_Linea());
        _tabCtrl.animateTo(0);
      });

  Future<void> _generarConIA() async {
    setState(() => _generando = true);
    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un agente aduanal mexicano experto en calculo de impuestos de importacion. Calcula los impuestos estimados (Arancel, IVA, DTA, IGI) para la operacion descrita y genera datos de proforma en JSON.'),
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      const prompt =
          '''Genera datos para autocompletar una proforma comercial aduanal.
Devuelve un JSON con la siguiente estructura exacta:
{
  "emisorNombre": "Nombre de la empresa exportadora",
  "receptorNombre": "Nombre de la empresa importadora",
  "puertoCarga": "Puerto de origen (ej. Manzanillo)",
  "puertoDescarga": "Puerto de destino",
  "flete": "Monto numerico de flete (como texto, ej '1200')",
  "seguro": "Monto numerico de seguro (como texto, ej '150')",
  "linea": {
    "desc": "Descripcion detallada de la mercancia",
    "fraccion": "Fraccion arancelaria (8 digitos)",
    "sku": "SKU o numero de parte",
    "cant": "Cantidad (como texto, ej '500')",
    "pu": "Precio unitario (como texto, ej '12.50')"
  }
}''';

      final response = await model.generateContent([Content.text(prompt)]);
      final jsonResponse =
          jsonDecode(response.text ?? '{}') as Map<String, dynamic>;

      setState(() {
        _generando = false;
        if (_lineas.isNotEmpty) {
          final l = jsonResponse['linea'] as Map<String, dynamic>?;
          if (l != null) {
            _lineas.first.desc.text = l['desc']?.toString() ?? '';
            _lineas.first.fraccion.text = l['fraccion']?.toString() ?? '';
            _lineas.first.sku.text = l['sku']?.toString() ?? '';
            _lineas.first.cant.text = l['cant']?.toString() ?? '1';
            _lineas.first.pu.text = l['pu']?.toString() ?? '0';
          }
        }
        _emisorNombre.text =
            jsonResponse['emisorNombre']?.toString() ?? _emisorNombre.text;
        _recNombre.text =
            jsonResponse['receptorNombre']?.toString() ?? _recNombre.text;
        _puertoCarga.text =
            jsonResponse['puertoCarga']?.toString() ?? _puertoCarga.text;
        _puertoDescarga.text =
            jsonResponse['puertoDescarga']?.toString() ?? _puertoDescarga.text;
        _fleteCtrl.text = jsonResponse['flete']?.toString() ?? _fleteCtrl.text;
        _seguroCtrl.text =
            jsonResponse['seguro']?.toString() ?? _seguroCtrl.text;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Proforma completada con IA.', style: TextStyle(color: _bg)),
          backgroundColor: _azul,
          behavior: SnackBarBehavior.floating));
    } catch (e) {
      setState(() => _generando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error: \$e', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red));
      }
    }
  }

  void _guardarProforma() {
    final now = DateTime.now();
    final p = _Proforma(
      ref: _numRef,
      emisor: _emisorNombre.text,
      receptor: _recNombre.text,
      total: _grandTotal,
      fecha:
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
      incoterm: _incoterm,
      moneda: _moneda,
    );
    setState(() {
      _historial.insert(0, p);
      _numRef = _genRef();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Proforma ${p.ref} guardada.',
            style: const TextStyle(color: _bg)),
        backgroundColor: _verde,
        behavior: SnackBarBehavior.floating));
    _tabCtrl.animateTo(1);
  }

  String _mesAbrev(int m) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m - 1];

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _seccionCard(
          String titulo, IconData icon, Color c, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bord),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 12),
            Text(titulo,
                style: TextStyle(
                    color: c, fontSize: 16, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 24),
          ...children,
        ]),
      );

  Widget _fi(TextEditingController c, String hint, IconData icon,
          {bool isNum = false, VoidCallback? onCh}) =>
      TextField(
        controller: c,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        onChanged: onCh != null ? (_) => onCh() : null,
        style: const TextStyle(color: _texto, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _sec, fontSize: 14),
          prefixIcon: Icon(icon, color: _sec, size: 20),
          filled: true,
          fillColor: _bg,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _bord)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _bord)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _azul)),
        ),
      );

  Widget _mini(TextEditingController c, String hint,
          {bool isNum = false, VoidCallback? onCh}) =>
      TextField(
        controller: c,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        onChanged: onCh != null ? (_) => onCh() : null,
        style: const TextStyle(color: _texto, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _sec, fontSize: 12),
          filled: true,
          fillColor: _bg,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _bord)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _bord)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _azul)),
        ),
      );

  Widget _dropdown(List<String> opts, String val, ValueChanged<String?> onCh,
          {required IconData icon}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _bord)),
        child: DropdownButton<String>(
          value: val,
          isExpanded: true,
          dropdownColor: _card2,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, color: _sec, size: 20),
          style: const TextStyle(color: _texto, fontSize: 14),
          items: opts
              .map((o) => DropdownMenuItem(
                  value: o,
                  child: Row(children: [
                    Icon(icon, color: _sec, size: 18),
                    const SizedBox(width: 12),
                    Text(o)
                  ])))
              .toList(),
          onChanged: onCh,
        ),
      );

  Widget _dropdownMini(
          List<String> opts, String val, ValueChanged<String?> onCh) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _bord)),
        child: DropdownButton<String>(
          value: val,
          isExpanded: true,
          dropdownColor: _card2,
          underline: const SizedBox(),
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _sec, size: 16),
          style: const TextStyle(color: _texto, fontSize: 12),
          items: opts
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onCh,
        ),
      );

  Widget _pill(String l, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: c.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.withValues(alpha: 0.5))),
        child: Text(l,
            style:
                TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold)),
      );
}
