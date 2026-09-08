import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';

// -- Design Tokens -------------------------------------------------------------
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

class TmecScreen extends StatefulWidget {
  const TmecScreen({super.key});
  @override
  State<TmecScreen> createState() => _TmecScreenState();
}

class _TmecScreenState extends State<TmecScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // -- Form fields ------------------------------------------------------------
  final _descCtrl = TextEditingController();
  final _fracCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();
  final _matCtrl = TextEditingController();

  bool _validating = false;
  String _dictamen = '';
  bool _originado = false;
  double _vcr = 0;

  // -- Certificates list ------------------------------------------------------
  final List<Map<String, String>> _certs = [
    {
      'num': 'CERT-2026-091',
      'proveedor': 'Automotive Parts LLC',
      'origen': 'USA',
      'fraccion': '870899',
      'status': 'Valido'
    },
    {
      'num': 'CERT-2026-092',
      'proveedor': 'Canadian Tech Supplies',
      'origen': 'CAN',
      'fraccion': '854290',
      'status': 'Por Expirar'
    },
    {
      'num': 'CERT-2026-093',
      'proveedor': 'Texas Components Inc',
      'origen': 'USA',
      'fraccion': '731815',
      'status': 'Rechazado'
    },
    {
      'num': 'CERT-2026-094',
      'proveedor': 'Monterrey Plasticos SA',
      'origen': 'MEX',
      'fraccion': '390210',
      'status': 'Valido'
    },
    {
      'num': 'CERT-2026-095',
      'proveedor': 'Silicon Valley Circuits',
      'origen': 'USA',
      'fraccion': '854231',
      'status': 'Valido'
    },
    {
      'num': 'CERT-2026-096',
      'proveedor': 'Ontario Metals Ltd',
      'origen': 'CAN',
      'fraccion': '720919',
      'status': 'Por Expirar'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _descCtrl.dispose();
    _fracCtrl.dispose();
    _costoCtrl.dispose();
    _matCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        // -- Header -----------------------------------------------------------
        Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 14, 0),
          decoration: const BoxDecoration(
              color: _bg, border: Border(bottom: BorderSide(color: _bord))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconButton(
                icon:
                    const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
              ),
              const SizedBox(width: 12),
              Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: _ambar.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _ambar.withAlpha(80))),
                  child: const Icon(Icons.balance, color: _ambar, size: 16)),
              const SizedBox(width: 10),
              const Text('Modulo de Tratados y Origen (T-MEC)',
                  style: TextStyle(
                      color: _texto,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              indicatorColor: _ambar,
              labelColor: _ambar,
              unselectedLabelColor: _sec,
              labelStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              tabs: const [
                Tab(text: 'Validador de Reglas de Origen'),
                Tab(text: 'Certificados de Origen'),
                Tab(text: 'Consulta de Tratados'),
              ],
            ),
          ]),
        ),
        Expanded(
            child: TabBarView(controller: _tabCtrl, children: [
          _tabValidador(),
          _tabCertificados(),
          _tabTratados(),
        ])),
      ]),
    );
  }

  // --------------------------------------------------------------------------
  // TAB 1 â€” Validador de Reglas de Origen
  // --------------------------------------------------------------------------
  Widget _tabValidador() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Validador de Reglas de Origen',
            style: TextStyle(
                color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text(
            'Valida el Salto Arancelario y el Valor de Contenido Regional (VCR) para emitir Certificados de Origen validos.',
            style: TextStyle(color: _sec, fontSize: 11, height: 1.5)),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Left â€” Datos del Bien
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _bord)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: _ambar, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Text('Datos del Bien',
                    style: TextStyle(
                        color: _ambar,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 16),
              _fi(_descCtrl, 'Descripcion Comercial',
                  Icons.description_outlined),
              const SizedBox(height: 12),
              _fi(_fracCtrl, 'Fraccion Arancelaria (Minimo 6 digitos)',
                  Icons.tag),
              const SizedBox(height: 12),
              _fi(_costoCtrl, 'Costo Total de Produccion (USD)',
                  Icons.attach_money,
                  isNum: true),
              const SizedBox(height: 12),
              _fi(_matCtrl, 'Valor de Materiales Originarios (USD)',
                  Icons.inventory_2_outlined,
                  isNum: true),
              const SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _validating ? null : _validarOrigen,
                    icon: _validating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline,
                            size: 16, color: Colors.black),
                    label: Text(
                        _validating
                            ? 'Validando...'
                            : 'Validar Regla de Origen',
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _ambar,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  )),
            ]),
          )),
          const SizedBox(width: 16),
          // Right â€” Dictamen de Origen
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _dictamen.isEmpty
                        ? _bord
                        : _originado
                            ? _verde
                            : _rojo)),
            child: _dictamen.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.gavel_outlined,
                            color: _sec.withAlpha(80), size: 40),
                        const SizedBox(height: 12),
                        const Text('Dictamen de Origen',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        const Text(
                            'Complete los datos y presione "Validar Regla de Origen"',
                            style: TextStyle(color: _sec, fontSize: 10),
                            textAlign: TextAlign.center),
                      ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(children: [
                          Icon(
                              _originado
                                  ? Icons.verified
                                  : Icons.cancel_outlined,
                              color: _originado ? _verde : _rojo,
                              size: 20),
                          const SizedBox(width: 8),
                          Text(
                              _originado
                                  ? 'PRODUCTO ORIGINARIO'
                                  : 'NO ORIGINARIO',
                              style: TextStyle(
                                  color: _originado ? _verde : _rojo,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 12),
                        _dictRow('Fraccion', _fracCtrl.text),
                        _dictRow(
                            'VCR Calculado', '${_vcr.toStringAsFixed(1)}%'),
                        _dictRow('VCR Requerido', '62.5%'),
                        _dictRow('Resultado VCR',
                            _vcr >= 62.5 ? 'CUMPLE' : 'NO CUMPLE'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color:
                                  (_originado ? _verde : _rojo).withAlpha(15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: (_originado ? _verde : _rojo)
                                      .withAlpha(60))),
                          child: Text(_dictamen,
                              style: TextStyle(
                                  color: _originado ? _verde : _rojo,
                                  fontSize: 11,
                                  height: 1.5)),
                        ),
                        if (_originado) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => _agregarCertificado(),
                                style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: _ambar),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                child: const Text(
                                    'Emitir Certificado de Origen',
                                    style: TextStyle(
                                        color: _ambar,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              )),
                        ],
                      ]),
          )),
        ]),
      ]),
    );
  }

  void _validarOrigen() async {
    final costo = double.tryParse(_costoCtrl.text) ?? 0;
    final mat = double.tryParse(_matCtrl.text) ?? 0;
    setState(() => _validating = true);

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un experto clasificador y validador del T-MEC. Analiza los datos de la mercancía y dictamina su origen bajo las reglas del tratado. Devuelve un JSON con: "vcr" (doble), "originado" (booleano), "dictamen" (texto explicativo detallado).'),
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt =
          'Fracción: ${_fracCtrl.text}, Descripción: ${_descCtrl.text}, Costo Total: $costo, Materiales Originarios: $mat. Validar regla de origen.';
      final response = await model.generateContent([Content.text(prompt)]);

      final Map<String, dynamic> data =
          jsonDecode(response.text ?? '{}') as Map<String, dynamic>;

      setState(() {
        _vcr = (data['vcr'] as num?)?.toDouble() ??
            (costo > 0 ? (mat / costo) * 100 : 0);
        _originado = data['originado'] as bool? ?? false;
        _dictamen =
            data['dictamen']?.toString() ?? 'Error al procesar dictamen.';
        _validating = false;
      });
    } catch (e) {
      setState(() => _validating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error IA: $e'), backgroundColor: _rojo));
      }
    }
  }

  void _agregarCertificado() {
    final num = 'CERT-2026-0${97 + _certs.length}';
    setState(() {
      _certs.insert(0, {
        'num': num,
        'proveedor': _descCtrl.text.isEmpty ? 'Producto Nuevo' : _descCtrl.text,
        'origen': 'MEX',
        'fraccion': _fracCtrl.text,
        'status': 'Valido'
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Certificado $num emitido y agregado al registro.'),
        backgroundColor: _verde,
        behavior: SnackBarBehavior.floating));
    _tabCtrl.animateTo(1);
  }

  Widget _dictRow(String l, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text('$l:',
              style: const TextStyle(
                  color: _sec, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(v,
              style: const TextStyle(
                  color: _texto, fontSize: 11, fontWeight: FontWeight.bold)),
        ]),
      );

  // --------------------------------------------------------------------------
  // TAB 2 â€” Certificados de Origen
  // --------------------------------------------------------------------------
  Widget _tabCertificados() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Certificados de Origen T-MEC',
              style: TextStyle(
                  color: _texto, fontSize: 14, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _azul.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _azul.withAlpha(60))),
              child: Text('${_certs.length} registros',
                  style: const TextStyle(
                      color: _azul,
                      fontSize: 10,
                      fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 4),
        const Text('Certificados registrados y su estado de validez.',
            style: TextStyle(color: _sec, fontSize: 11)),
        const SizedBox(height: 14),
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: _card2,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              border: Border.all(color: _bord)),
          child: const Row(children: [
            SizedBox(width: 36),
            Expanded(
                flex: 2,
                child: Text('No. Certificado',
                    style: TextStyle(
                        color: _sec,
                        fontSize: 10,
                        fontWeight: FontWeight.w600))),
            Expanded(
                flex: 3,
                child: Text('Proveedor',
                    style: TextStyle(
                        color: _sec,
                        fontSize: 10,
                        fontWeight: FontWeight.w600))),
            Expanded(
                flex: 2,
                child: Text('Fraccion',
                    style: TextStyle(
                        color: _sec,
                        fontSize: 10,
                        fontWeight: FontWeight.w600))),
            SizedBox(
                width: 80,
                child: Text('Status',
                    style: TextStyle(
                        color: _sec, fontSize: 10, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center)),
            SizedBox(width: 40),
          ]),
        ),
        Expanded(
            child: DecoratedBox(
          decoration: BoxDecoration(
              color: _card,
              border: Border.all(color: _bord),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(10))),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _certs.length,
            separatorBuilder: (_, __) => const Divider(color: _bord, height: 1),
            itemBuilder: (_, i) {
              final c = _certs[i];
              final st = c['status']!;
              final stColor = st == 'Valido'
                  ? _verde
                  : st == 'Por Expirar'
                      ? _naran
                      : _rojo;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(children: [
                  Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: _azul.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _azul.withAlpha(60))),
                      child: Center(
                          child: Text(c['origen']!,
                              style: const TextStyle(
                                  color: _azul,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 8),
                  Expanded(
                      flex: 2,
                      child: Text(c['num']!,
                          style: const TextStyle(
                              color: _texto,
                              fontSize: 11,
                              fontWeight: FontWeight.w600))),
                  Expanded(
                      flex: 3,
                      child: Text(c['proveedor']!,
                          style: const TextStyle(color: _sec, fontSize: 11),
                          overflow: TextOverflow.ellipsis)),
                  Expanded(
                      flex: 2,
                      child: Text(c['fraccion']!,
                          style: const TextStyle(
                              color: _texto,
                              fontSize: 11,
                              fontFamily: 'monospace'))),
                  SizedBox(
                      width: 80,
                      child: Center(
                          child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: stColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: stColor.withAlpha(60))),
                        child: Text(st,
                            style: TextStyle(
                                color: stColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ))),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(Icons.picture_as_pdf_outlined,
                          color: _ambar, size: 18),
                      tooltip: 'Ver Certificado T-MEC',
                      onPressed: () => _mostrarCertificadoVisual(c),
                    ),
                  ),
                ]),
              );
            },
          ),
        )),
      ]),
    );
  }

  void _mostrarCertificadoVisual(Map<String, String> c) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        child: Container(
          width: 600,
          height: 800,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('CERTIFICADO DE ORIGEN',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                  textAlign: TextAlign.center),
              const Text(
                  'TRATADO ENTRE MÃ‰XICO, ESTADOS UNIDOS Y CANADÁ (T-MEC)',
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: _campoCertificado('1. Certificador:',
                        'Aduanas 801 Enterprise\nBlvd. Nuevo Laredo 123, Tamaulipas, MX')),
                const SizedBox(width: 16),
                Expanded(
                    child: _campoCertificado(
                        '2. Exportador:',
                        '${c['proveedor']}\n${c['origen'] == 'USA' ? 'Texas, USA' : c['origen'] == 'CAN' ? 'Ontario, CAN' : 'Monterrey, MEX'}')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _campoCertificado(
                        '3. Productor:', 'Mismo que el exportador')),
                const SizedBox(width: 16),
                Expanded(
                    child: _campoCertificado('4. Importador:',
                        'Empresa IMMEX Titan-Tier\nParque Industrial 45, Nuevo León, MX')),
              ]),
              const SizedBox(height: 16),
              _campoCertificado('5. Descripción de las mercancías:',
                  'Bienes originarios amparados bajo el número de parte y descripción comercial correspondientes.'),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _campoCertificado(
                        '6. Clasificación Arancelaria (SA):', c['fraccion']!)),
                const SizedBox(width: 16),
                Expanded(
                    child: _campoCertificado('7. Criterio de Origen:',
                        'Valor de Contenido Regional (VCR) >= 62.5%')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _campoCertificado('8. Período global:',
                        'Del: 01/01/2026  Al: 31/12/2026')),
                const SizedBox(width: 16),
                Expanded(
                    child: _campoCertificado('Número de Documento:', c['num']!,
                        bold: true)),
              ]),
              const SizedBox(height: 32),
              const Text('DECLARACIÃ“N BAJO PROTESTA DE DECIR VERDAD',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                  'Certifico que las mercancías descritas en este documento califican como originarias y la información contenida en este documento es verdadera y exacta. Asumo la responsabilidad de comprobar lo aquí declarado y me comprometo a conservar y presentar en caso de ser requeridos los documentos necesarios que respalden esta certificación.',
                  style: TextStyle(
                      color: Colors.black87, fontSize: 10, height: 1.5),
                  textAlign: TextAlign.justify),
              const Spacer(),
              const Divider(color: Colors.black26),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Firma Autorizada',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      Text('Representante Legal',
                          style:
                              TextStyle(color: Colors.black54, fontSize: 10)),
                    ]),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(_),
                  icon: const Icon(Icons.print, size: 16, color: Colors.white),
                  label: const Text('Imprimir PDF',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A)),
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoCertificado(String titulo, String valor, {bool bold = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(valor,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TAB 3 â€” Consulta de Tratados
  // --------------------------------------------------------------------------
  Widget _tabTratados() {
    final tratados = [
      {
        'nombre': 'T-MEC / USMCA',
        'paises': 'Mexico, EUA, Canada',
        'vigencia': '01/Jul/2020',
        'status': 'Vigente',
        'desgravacion': '100%'
      },
      {
        'nombre': 'TLC Mexico-UE',
        'paises': 'Mexico, Union Europea',
        'vigencia': '01/Oct/2000',
        'status': 'Vigente',
        'desgravacion': '97%'
      },
      {
        'nombre': 'TLC Mexico-Japon',
        'paises': 'Mexico, Japon',
        'vigencia': '01/Abr/2005',
        'status': 'Vigente',
        'desgravacion': '95%'
      },
      {
        'nombre': 'TLCAC',
        'paises':
            'Mexico, Costa Rica, El Salvador, Guatemala, Honduras, Nicaragua',
        'vigencia': '01/Ene/2012',
        'status': 'Vigente',
        'desgravacion': '100%'
      },
      {
        'nombre': 'AELC',
        'paises': 'Mexico, Suiza, Noruega, Islandia, Liechtenstein',
        'vigencia': '01/Jul/2001',
        'status': 'Vigente',
        'desgravacion': '82%'
      },
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tratados Comerciales de Mexico',
            style: TextStyle(
                color: _texto, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text(
            'Consulta los tratados vigentes y sus condiciones de desgravacion arancelaria.',
            style: TextStyle(color: _sec, fontSize: 11)),
        const SizedBox(height: 14),
        ...tratados.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _bord)),
              child: Row(children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: _ambar.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _ambar.withAlpha(60))),
                    child: const Icon(Icons.handshake_outlined,
                        color: _ambar, size: 22)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(t['nombre']!,
                          style: const TextStyle(
                              color: _texto,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text(t['paises']!,
                          style: const TextStyle(color: _sec, fontSize: 10),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(children: [
                        _tag('Vigente desde ${t['vigencia']}', _azul),
                        const SizedBox(width: 6),
                        _tag('Desgravacion ${t['desgravacion']}', _verde),
                      ]),
                    ])),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: _verde.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _verde.withAlpha(60))),
                    child: Text(t['status']!,
                        style: const TextStyle(
                            color: _verde,
                            fontSize: 10,
                            fontWeight: FontWeight.bold))),
              ]),
            )),
      ]),
    );
  }

  Widget _tag(String l, Color c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: c.withAlpha(15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: c.withAlpha(50))),
      child: Text(l, style: TextStyle(color: c, fontSize: 9)));

  Widget _fi(TextEditingController c, String hint, IconData icon,
          {bool isNum = false}) =>
      TextField(
        controller: c,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: _texto, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _sec, fontSize: 12),
          prefixIcon: Icon(icon, color: _sec, size: 16),
          filled: true,
          fillColor: _bg,
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
              borderSide: const BorderSide(color: _ambar)),
        ),
      );
}
