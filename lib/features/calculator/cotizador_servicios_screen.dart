import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

// â”€â”€ Servicio Model â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _Servicio {
  final String id;
  final String nombre;
  final String descripcion;
  final IconData icon;
  final Color color;
  bool activo;
  double precio;
  final bool editable;
  final bool hasCounter;
  int dias = 1;
  final bool autoCalc;
  final bool esHonorario;

  _Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icon,
    required this.color,
    this.activo = false,
    required this.precio,
    this.editable = true,
    this.hasCounter = false,
    this.autoCalc = false,
    this.esHonorario = false,
  });

  double get total => hasCounter ? precio * dias : precio;
}

// â”€â”€ Historial Model â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _Cotizacion {
  final String id;
  final String cliente;
  final String regimen;
  final double total;
  final DateTime fecha;

  const _Cotizacion(
      {required this.id,
      required this.cliente,
      required this.regimen,
      required this.total,
      required this.fecha});
}

// â”€â”€ Main Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class CotizadorServiciosScreen extends StatefulWidget {
  const CotizadorServiciosScreen({super.key});
  @override
  State<CotizadorServiciosScreen> createState() =>
      _CotizadorServiciosScreenState();
}

class _CotizadorServiciosScreenState extends State<CotizadorServiciosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _vaCtrl = TextEditingController(text: '0');

  // Cliente
  String _regimen = 'Importacion Definitiva';

  // Valor en Aduana
  double get _va =>
      double.tryParse(_vaCtrl.text.replaceAll(',', '').replaceAll('\$', '')) ??
      0;

  // DTA calculation Art. 49 LFD
  double get _dta {
    final d = _va * 0.08;
    return d.clamp(380.06, 920093.44);
  }

  double get _seguro => _va * 0.01;

  // AI Justification
  bool _showJustif = false;
  bool _loadingJustif = false;
  String _justifText = '';

  // Servicios
  late final List<_Servicio> _servicios = [
    _Servicio(
        id: 'hon_bas',
        nombre: 'Honorarios AA (Basico)',
        descripcion: 'Honorarios por despacho aduanal pedimento regular',
        icon: Icons.account_balance_wallet,
        color: _azul,
        activo: true,
        precio: 4500,
        esHonorario: true),
    _Servicio(
        id: 'hon_urg',
        nombre: 'Honorarios AA (Urgente)',
        descripcion: 'Honorarios despacho urgente / fuera de horario',
        icon: Icons.bolt,
        color: _naran,
        precio: 7500,
        esHonorario: true),
    _Servicio(
        id: 'dta',
        nombre: 'DTA (8% Valor en Aduana)',
        descripcion: 'Derecho de Tramite Aduanero â€” Art. 49 LFD (topes DOF)',
        icon: Icons.account_balance,
        color: _ambar,
        activo: true,
        precio: 0,
        editable: false,
        autoCalc: true),
    _Servicio(
        id: 'alm',
        nombre: 'Almacenaje (por dia)',
        descripcion: 'Almacenaje en recinto fiscal / fiscal estrategico',
        icon: Icons.warehouse,
        color: _azul,
        activo: true,
        precio: 850,
        hasCounter: true),
    _Servicio(
        id: 'man',
        nombre: 'Maniobras de Descarga',
        descripcion: 'Carga y descarga en puerto / recinto',
        icon: Icons.local_shipping,
        color: _verde,
        activo: true,
        precio: 2200),
    _Servicio(
        id: 'prev',
        nombre: 'Despacho en Previo',
        descripcion: 'Inspeccion fisica anticipada en almacen fiscal',
        icon: Icons.search,
        color: _sec,
        precio: 3500),
    _Servicio(
        id: 'prv',
        nombre: 'Previo de Revisión (PRV)',
        descripcion: 'Obligatorio para mercancía sujeta a NOM',
        icon: Icons.fact_check_outlined,
        color: _ambar,
        precio: 1200),
    _Servicio(
        id: 'flete',
        nombre: 'Flete Nacional',
        descripcion: 'Transportacion terrestre local a destino final',
        icon: Icons.local_shipping,
        color: _azul,
        activo: true,
        precio: 4800),
    _Servicio(
        id: 'seg',
        nombre: 'Seguro de Carga (1%)',
        descripcion: 'Prima de seguro calculada sobre valor declarado',
        icon: Icons.shield,
        color: _verde,
        activo: true,
        precio: 0,
        editable: false,
        autoCalc: true),
    _Servicio(
        id: 'semar',
        nombre: 'Permiso Previo SEMARNAT',
        descripcion: 'Gestion de permiso de importacion SEMARNAT',
        icon: Icons.eco,
        color: _verde,
        precio: 2500),
    _Servicio(
        id: 'cofep',
        nombre: 'Permiso COFEPRIS',
        descripcion: 'Registro / permiso sanitario ante COFEPRIS',
        icon: Icons.medical_services,
        color: _rojo,
        precio: 3000),
    _Servicio(
        id: 'apos',
        nombre: 'Apostilla / Traduccion',
        descripcion: 'Apostilla de documentos y/o traduccion oficial',
        icon: Icons.translate,
        color: _sec,
        precio: 1800),
    _Servicio(
        id: 'carta',
        nombre: 'Carta Porte',
        descripcion: 'Generacion de Carta Porte conforme CFDI 4.0',
        icon: Icons.description,
        color: _sec,
        precio: 1200),
  ];

  // Historial
  final List<_Cotizacion> _historial = [
    _Cotizacion(
        id: 'Q001',
        cliente: 'General Motors de Mexico',
        regimen: 'Importacion Definitiva',
        total: 18450.00,
        fecha: DateTime.now().subtract(const Duration(days: 2))),
    _Cotizacion(
        id: 'Q002',
        cliente: 'Foxconn Baja California',
        regimen: 'Importacion Temporal',
        total: 9200.00,
        fecha: DateTime.now().subtract(const Duration(days: 5))),
    _Cotizacion(
        id: 'Q003',
        cliente: 'BASF de Mexico',
        regimen: 'Importacion Definitiva',
        total: 13070.00,
        fecha: DateTime.now().subtract(const Duration(days: 7))),
    _Cotizacion(
        id: 'Q004',
        cliente: 'Samsung Tijuana',
        regimen: 'Importacion Temporal',
        total: 22800.00,
        fecha: DateTime.now().subtract(const Duration(days: 10))),
  ];

  double get _tc => 18.50;

  // Calculations
  double _servicioTotal(_Servicio s) {
    if (!s.activo) return 0;
    if (s.id == 'dta') return _dta;
    if (s.id == 'seg') return _seguro;
    return s.total;
  }

  double get _honorarios => _servicios
      .where((s) => s.esHonorario && s.activo)
      .fold(0, (acc, s) => acc + s.total);
  double get _subtotal =>
      _servicios.fold(0, (acc, s) => acc + _servicioTotal(s));
  double get _iva => _honorarios * 0.16;
  double get _totalMxn => _subtotal + _iva;
  double get _totalUsd => _totalMxn / _tc;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
    
  }

  @override
  void dispose() {
    _tabs.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        DecoratedBox(
          decoration: const BoxDecoration(
              color: _bg, border: Border(bottom: BorderSide(color: _bord))),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
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
                          child: const Icon(Icons.chevron_left,
                              color: _sec, size: 20))),
                  const SizedBox(width: 12),
                  Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: _ambar.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: _ambar.withValues(alpha: 0.3))),
                      child: const Icon(Icons.request_quote,
                          color: _ambar, size: 16)),
                  const SizedBox(width: 10),
                  const Text('Cotizador de Servicios Aduanales',
                      style: TextStyle(
                          color: _texto,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ])),
            TabBar(
                controller: _tabs,
                indicatorColor: _ambar,
                labelColor: _ambar,
                unselectedLabelColor: _sec,
                labelStyle:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                tabs: const [
                  Tab(
                      icon: Icon(Icons.add_box_outlined, size: 15),
                      text: 'Nueva Cotizacion'),
                  Tab(icon: Icon(Icons.history, size: 15), text: 'Historial'),
                ]),
          ]),
        ),

        // â”€â”€ Body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Expanded(
            child: TabBarView(controller: _tabs, children: [
          _buildNuevaCotizacion(),
          _buildHistorial(),
        ])),
      ]),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // NUEVA COTIZACIÃ“N
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildNuevaCotizacion() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // LEFT â€” form
      Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _infoCliente(),
              const SizedBox(height: 16),
              _constructorServicios(),
              const SizedBox(height: 16),
              _justificacionBlock(),
              const SizedBox(height: 16),
              _accionesRow(),
            ]),
          )),
      // RIGHT â€” summary
      Container(width: 1, color: _bord),
      Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _resumenCotizacion(),
          )),
    ]);
  }

  // â”€â”€ Información del Cliente â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _infoCliente() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _bord)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.person_outline, color: _azul, size: 16),
            SizedBox(width: 8),
            Text('Informacion del Cliente',
                style: TextStyle(
                    color: _texto, fontSize: 13, fontWeight: FontWeight.w600))
          ]),
          const SizedBox(height: 14),
          _fi(TextEditingController(), 'Nombre del cliente', icon: Icons.business),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _fi(TextEditingController(), 'RFC del cliente', icon: Icons.badge)),
            const SizedBox(width: 10),
            Expanded(
                child: _fi(TextEditingController(), 'Num. de operacion / referencia',
                    icon: Icons.tag)),
          ]),
          const SizedBox(height: 10),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _bord)),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                value: _regimen,
                isExpanded: true,
                dropdownColor: _card2,
                style: const TextStyle(color: _texto, fontSize: 12),
                onChanged: (v) => setState(() => _regimen = v!),
                items: [
                  'Importacion Definitiva',
                  'Importacion Temporal',
                  'Exportacion Definitiva',
                  'IMMEX Elaboracion',
                  'IMMEX Maquila',
                  'Transbordo',
                  'Transito de Mercancias',
                  'Deposito Fiscal'
                ]
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
              ))),
        ]),
      );

  // â”€â”€ Constructor de Servicios â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _constructorServicios() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _ambar.withValues(alpha: 0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.build_outlined, color: _ambar, size: 16),
            SizedBox(width: 8),
            Text('Constructor de Servicios',
                style: TextStyle(
                    color: _texto, fontSize: 13, fontWeight: FontWeight.w600))
          ]),
          const SizedBox(height: 14),
          // Valor en Aduana
          Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: _ambar.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _ambar.withValues(alpha: 0.25))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.attach_money, color: _ambar, size: 14),
                      SizedBox(width: 6),
                      Text('Valor en Aduana (MXN)',
                          style: TextStyle(
                              color: _ambar,
                              fontSize: 11,
                              fontWeight: FontWeight.w600))
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Text('\$ ',
                          style: TextStyle(color: _sec, fontSize: 14)),
                      Expanded(
                          child: TextField(
                              controller: TextEditingController(),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                  color: _texto,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace'),
                              decoration: InputDecoration(
                                  hintText: '0',
                                  hintStyle: const TextStyle(color: _sec),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  filled: true,
                                  fillColor: _bg,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          const BorderSide(color: _bord)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          const BorderSide(color: _bord)),
                                  suffix: const Text('MXN',
                                      style: TextStyle(
                                          color: _sec, fontSize: 11))))),
                    ]),
                    const SizedBox(height: 6),
                    Text(
                        'DTA = 8% del valor (min \$380.06 / max \$920,093.44) â€” Actual: \$${_dta.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: _sec, fontSize: 9, height: 1.4)),
                  ])),
          const SizedBox(height: 12),
          // Services list
          ..._servicios.map((s) => _CotizadorServicioRow(
              servicio: s, onChanged: () => setState(() {}))),
        ]),
      );

  // â”€â”€ Justificación Profesional â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _justificacionBlock() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _verde.withValues(alpha: 0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.auto_awesome, color: _verde, size: 15),
            SizedBox(width: 8),
            Text('Justificacion Profesional (Gemini AI)',
                style: TextStyle(
                    color: _texto, fontSize: 12, fontWeight: FontWeight.w600))
          ]),
          const SizedBox(height: 12),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadingJustif ? null : _generarJustificacion,
                icon: _loadingJustif
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome,
                        size: 15, color: Colors.black),
                label: Text(
                    _loadingJustif
                        ? 'Generando...'
                        : '+ Generar Justificacion Profesional',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _verde,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              )),
          if (_showJustif && _justifText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _verde.withValues(alpha: 0.25))),
                child: Text(_justifText,
                    style: const TextStyle(
                        color: _texto, fontSize: 11, height: 1.7))),
          ],
        ]),
      );

  Future<void> _generarJustificacion() async {
    setState(() => _loadingJustif = true);
    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un agente aduanal mexicano y calculas honorarios y servicios para una operacion aduanal. Dado el tipo de operacion, valor de la mercancia, y aduana, calcula: honorarios del agente, gastos de maniobra, almacenaje estimado, previo (si aplica), y total de servicios. Responde en JSON: {honorarios, maniobras, almacenaje, previo, otros, total, notas}'),
      );
      final prompt =
          'Calcula para: Tipo de operacion $_regimen, Valor \$${_va.toStringAsFixed(2)} MXN, Aduana local.';
      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _loadingJustif = false;
        _showJustif = true;
        _justifText = response.text ?? 'Sin respuesta';
      });
    } catch (e) {
      setState(() {
        _loadingJustif = false;
        _showJustif = true;
        _justifText = 'Error de IA: $e';
      });
    }
  }

  // â”€â”€ Bottom Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _accionesRow() => Column(children: [
        Row(children: [
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: _limpiar,
                  icon: const Icon(Icons.refresh, size: 14, color: _sec),
                  label: const Text('Limpiar',
                      style: TextStyle(color: _sec, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _bord),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))))),
          const SizedBox(width: 12),
          Expanded(
              child: ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save_outlined,
                      size: 14, color: Colors.black),
                  label: const Text('Guardar Cotizacion',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _azul,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))))),
        ]),
        const SizedBox(height: 8),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
                onPressed: _exportarPDF,
                icon: const Icon(Icons.picture_as_pdf_outlined,
                    size: 14, color: _rojo),
                label: const Text('Exportar PDF',
                    style: TextStyle(
                        color: _rojo,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _rojo),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))))),
      ]);

  // â”€â”€ Resumen de Cotización â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _resumenCotizacion() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _bord)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.receipt, color: _ambar, size: 15),
            SizedBox(width: 8),
            Text('Resumen de Cotizacion',
                style: TextStyle(
                    color: _texto, fontSize: 13, fontWeight: FontWeight.w600))
          ]),
          const SizedBox(height: 14),
          // Line items
          ..._servicios.map((s) {
            final v = _servicioTotal(s);
            return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Icon(s.icon, color: s.activo ? s.color : _sec, size: 12),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(s.nombre,
                          style: TextStyle(
                              color: s.activo ? _texto : _sec, fontSize: 11))),
                  Text('\$${v.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: s.activo
                              ? (s.id == 'dta' || s.id == 'seg'
                                  ? s.color
                                  : _azul)
                              : _sec,
                          fontSize: 11,
                          fontFamily: 'monospace',
                          fontWeight:
                              s.activo ? FontWeight.bold : FontWeight.normal)),
                ]));
          }),
          const Divider(color: _bord, height: 20),
          _sumRow('Subtotal', _subtotal, bold: true),
          const SizedBox(height: 6),
          _sumRow('IVA 16% (solo honorarios)', _iva),
          const SizedBox(height: 14),
          // TOTAL card
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _ambar.withValues(alpha: 0.15),
                    _ambar.withValues(alpha: 0.05)
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _ambar.withValues(alpha: 0.3))),
              child: Row(children: [
                const Text('TOTAL',
                    style: TextStyle(
                        color: _ambar,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('\$${_totalMxn.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: _ambar,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace')),
                  Text('USD ${_totalUsd.toStringAsFixed(2)}',
                      style: const TextStyle(color: _sec, fontSize: 11)),
                ]),
              ])),
          const SizedBox(height: 10),
          const Text(
              '* IVA aplica unicamente sobre honorarios del Agente Aduanal. DTA y derechos gubernamentales estan exentos de IVA.',
              style: TextStyle(color: _sec, fontSize: 9, height: 1.5)),
          const SizedBox(height: 14),
          const Divider(color: _bord, height: 1),
          const SizedBox(height: 12),
          // TC
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _bord)),
              child: Row(children: [
                const Icon(Icons.currency_exchange, color: _sec, size: 14),
                const SizedBox(width: 8),
                const Text('TC (MXN/USD)',
                    style: TextStyle(color: _sec, fontSize: 11)),
                const Spacer(),
                Text(_tc.toStringAsFixed(2),
                    style: const TextStyle(
                        color: _texto,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace')),
              ])),
        ]),
      );

  Widget _sumRow(String l, double v, {bool bold = false}) => Row(children: [
        Text(bold ? 'â–  $l' : '% $l',
            style: TextStyle(
                color: _sec,
                fontSize: 11,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
        const Spacer(),
        Text('\$${v.toStringAsFixed(2)}',
            style: TextStyle(
                color: bold ? _texto : _sec,
                fontSize: 11,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'monospace')),
      ]);

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // HISTORIAL
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildHistorial() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.history, color: _ambar, size: 15),
            SizedBox(width: 8),
            Text('Cotizaciones Guardadas',
                style: TextStyle(
                    color: _texto, fontSize: 13, fontWeight: FontWeight.w600))
          ]),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _bord)),
            child: Column(children: [
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    SizedBox(
                        width: 60,
                        child: Text('ID',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 11,
                                fontWeight: FontWeight.w600))),
                    Expanded(
                        child: Text('Cliente',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 11,
                                fontWeight: FontWeight.w600))),
                    Text('Regimen',
                        style: TextStyle(
                            color: _sec,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    SizedBox(
                        width: 100,
                        child: Text('Total',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: _sec,
                                fontSize: 11,
                                fontWeight: FontWeight.w600))),
                  ])),
              const Divider(color: _bord, height: 1),
              ..._historial.asMap().entries.map((e) {
                final i = e.key;
                final q = e.value;
                final d = DateTime.now().difference(q.fecha);
                final ago = d.inDays > 0 ? 'hace ${d.inDays} d' : 'hoy';
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: i < _historial.length - 1
                          ? const Border(bottom: BorderSide(color: _bord))
                          : null),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(children: [
                    SizedBox(
                        width: 60,
                        child: Text(q.id,
                            style: const TextStyle(
                                color: _ambar,
                                fontSize: 11,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(q.cliente,
                              style:
                                  const TextStyle(color: _texto, fontSize: 12)),
                          Text(ago,
                              style: const TextStyle(color: _sec, fontSize: 9)),
                        ])),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: _azul.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: _azul.withValues(alpha: 0.25))),
                        child: Text(q.regimen.split(' ').first,
                            style: const TextStyle(color: _azul, fontSize: 9))),
                    SizedBox(
                        width: 100,
                        child: Text('\$${q.total.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: _verde,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace'))),
                  ]),
                );
              }),
            ]),
          ),
        ]));
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _fi(TextEditingController c, String hint, {IconData? icon}) =>
      TextField(
          controller: c,
          style: const TextStyle(color: _texto, fontSize: 12),
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _sec, fontSize: 11),
              prefixIcon:
                  icon != null ? Icon(icon, color: _sec, size: 14) : null,
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
                  borderSide: const BorderSide(color: _bord))));

  void _limpiar() => setState(() {
        
        
        
        
        for (final s in _servicios) {
          s.activo =
              ['hon_bas', 'alm', 'man', 'flete', 'seg', 'dta'].contains(s.id);
          s.dias = 1;
        }
        _showJustif = false;
        _justifText = '';
      });

  void _guardar() async {
    if ("".isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ingresa el nombre del cliente'),
          backgroundColor: _rojo));
      return;
    }

    final cotizacion = _Cotizacion(
        id: 'Q${_historial.length + 1}',
        cliente: '',
        regimen: _regimen,
        total: _totalMxn,
        fecha: DateTime.now());
    setState(() => _historial.insert(0, cotizacion));

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('cotizaciones').add({
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'cliente': cotizacion.cliente,
        'regimen': cotizacion.regimen,
        'total': cotizacion.total,
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cotizacion guardada en historial y Firestore'),
          backgroundColor: _verde));
    }
  }

  void _exportarPDF() =>
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('PDF generado: Cotizacion_Aduanal.pdf'),
          backgroundColor: _azul));
}

class _CotizadorServicioRow extends StatefulWidget {
  final _Servicio servicio;
  final VoidCallback onChanged;

  const _CotizadorServicioRow(
      {required this.servicio, required this.onChanged});

  @override
  State<_CotizadorServicioRow> createState() => _CotizadorServicioRowState();
}

class _CotizadorServicioRowState extends State<_CotizadorServicioRow> {
  late final TextEditingController _precioCtrl;

  @override
  void initState() {
    super.initState();
    _precioCtrl =
        TextEditingController(text: widget.servicio.precio.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _precioCtrl.dispose();
    super.dispose();
  }

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.servicio;
    // Actually we compute total based on the same formula:
    final sTotal = s.hasCounter ? s.precio * s.dias : s.precio;
    // BUT we need the parent to compute the final value for DTA/Seguro,
    // so we handle display specifically below.

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: s.activo ? s.color.withValues(alpha: 0.05) : _bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: _isHovered
                  ? s.color.withValues(alpha: 0.5)
                  : (s.activo ? s.color.withValues(alpha: 0.25) : _bord)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color:
                            s.activo ? s.color.withValues(alpha: 0.1) : _card2,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: s.activo
                                ? s.color.withValues(alpha: 0.3)
                                : _bord)),
                    child: Icon(s.icon,
                        color: s.activo ? s.color : _sec, size: 14)),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(s.nombre,
                          style: TextStyle(
                              color: s.activo ? _texto : _sec,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      Text(s.descripcion,
                          style: const TextStyle(
                              color: _sec, fontSize: 9, height: 1.3)),
                    ])),
                Switch(
                    value: s.activo,
                    onChanged: (v) {
                      s.activo = v;
                      widget.onChanged();
                    },
                    activeThumbColor: s.color,
                    activeTrackColor: s.color.withValues(alpha: 0.25),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ])),
          if (s.activo) ...[
            Container(height: 1, color: s.color.withValues(alpha: 0.15)),
            Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Row(children: [
                  const Text('\$ ',
                      style: TextStyle(color: _sec, fontSize: 13)),
                  // Price input or auto-display
                  s.autoCalc
                      ? Text('Auto calculado',
                          style: TextStyle(
                              color: s.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace'))
                      : _priceInput(s),
                  const Spacer(),
                  if (s.id == 'seg')
                    const Text('1% del valor en aduana',
                        style: TextStyle(color: _sec, fontSize: 9)),
                  if (!s.autoCalc && !s.hasCounter)
                    const Text('MXN',
                        style: TextStyle(color: _sec, fontSize: 11)),
                  // Day counter for Almacenaje
                  if (s.hasCounter) ...[
                    const Text('MXN',
                        style: TextStyle(color: _sec, fontSize: 11)),
                    const SizedBox(width: 12),
                    _dayCounter(s),
                  ],
                ])),
            if (s.hasCounter)
              Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Text('Total: \$${sTotal.toStringAsFixed(2)} MXN',
                      style: TextStyle(
                          color: s.color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold))),
          ],
        ]),
      ),
    );
  }

  Widget _priceInput(_Servicio s) {
    return SizedBox(
        width: 120,
        child: TextField(
            controller: _precioCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) {
              s.precio = double.tryParse(v) ?? s.precio;
              widget.onChanged();
            },
            style: const TextStyle(
                color: _texto,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace'),
            decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                filled: true,
                fillColor: _bg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: _bord)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: _bord)))));
  }

  Widget _dayCounter(_Servicio s) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
            onTap: () {
              if (s.dias > 1) {
                s.dias--;
                widget.onChanged();
              }
            },
            child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                    color: _card2,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _bord)),
                child: const Icon(Icons.remove, color: _sec, size: 14))),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _bord)),
            child: Text('${s.dias} d',
                style: const TextStyle(
                    color: _texto, fontSize: 12, fontWeight: FontWeight.bold))),
        GestureDetector(
            onTap: () {
              s.dias++;
              widget.onChanged();
            },
            child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                    color: _card2,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _bord)),
                child: const Icon(Icons.add, color: _sec, size: 14))),
      ]);
}
