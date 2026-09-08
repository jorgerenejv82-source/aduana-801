import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _verde = AppColors.green;

class _M3Campo {
  final String nombre;
  final String posicion;
  final String descripcion;
  const _M3Campo(
      {required this.nombre,
      required this.posicion,
      required this.descripcion});
}

class _M3Section {
  final String nombre;
  final List<_M3Campo> campos;
  const _M3Section({required this.nombre, required this.campos});
}

class _CampoParsed {
  final String valor;
  final String estado; // VÃƒÂLIDO, MALFORMADO, CORRUPTO, SOSPECHOSO
  const _CampoParsed({required this.valor, required this.estado});
}

class M3ForensicsScreen extends StatefulWidget {
  const M3ForensicsScreen({super.key});

  @override
  State<M3ForensicsScreen> createState() => _M3ForensicsScreenState();
}

class _M3ForensicsScreenState extends State<M3ForensicsScreen> {
  static const _m3Sections = [
    _M3Section(nombre: 'ENCABEZADO', campos: [
      _M3Campo(
          nombre: 'Tipo de OperaciÃƒÂ³n',
          posicion: '1-2',
          descripcion:
              'IM=ImportaciÃƒÂ³n, EX=ExportaciÃƒÂ³n, IT=ImportaciÃƒÂ³n Temporal'),
      _M3Campo(
          nombre: 'Clave de Pedimento',
          posicion: '3-4',
          descripcion: 'A1, A4, B1, B3, C1, G1, etc.'),
      _M3Campo(
          nombre: 'RFC del Importador',
          posicion: '5-17',
          descripcion: 'RFC de la empresa importadora (12-13 chars)'),
      _M3Campo(
          nombre: 'Valor Total en Aduana',
          posicion: '18-30',
          descripcion: 'Valor total declarado en USD'),
      _M3Campo(
          nombre: 'Fecha de Pago', posicion: '31-38', descripcion: 'DDMMAAAA'),
      _M3Campo(
          nombre: 'Aduana de Entrada',
          posicion: '39-42',
          descripcion: 'Clave de la aduana (801=Monterrey, 240=Laredo, etc.)'),
    ]),
    _M3Section(nombre: 'PARTIDAS', campos: [
      _M3Campo(
          nombre: 'NÃƒÂºmero de Partida',
          posicion: 'P-1',
          descripcion: 'NÃƒÂºmero secuencial de la partida'),
      _M3Campo(
          nombre: 'FracciÃƒÂ³n Arancelaria',
          posicion: 'P-2',
          descripcion: '10 dÃƒÂ­gitos LIGIE (8 dÃƒÂ­gitos + 2 de fracciÃƒÂ³n)'),
      _M3Campo(
          nombre: 'DescripciÃƒÂ³n',
          posicion: 'P-3',
          descripcion:
              'DescripciÃƒÂ³n de la mercancÃƒÂ­a (max 80 chars ASCII)'),
      _M3Campo(
          nombre: 'Cantidad',
          posicion: 'P-4',
          descripcion: 'Cantidad en unidad de medida de la fracciÃƒÂ³n'),
      _M3Campo(
          nombre: 'Valor Unitario',
          posicion: 'P-5',
          descripcion: 'Valor unitario en USD'),
      _M3Campo(
          nombre: 'IGI (%)',
          posicion: 'P-6',
          descripcion: 'Tasa del impuesto general de importaciÃƒÂ³n'),
      _M3Campo(
          nombre: 'IVA (%)',
          posicion: 'P-7',
          descripcion: 'Tasa del IVA aplicable (16% o 0%)'),
    ]),
    _M3Section(nombre: 'CARGOS Y DESCUENTOS', campos: [
      _M3Campo(
          nombre: 'Flete',
          posicion: 'C-1',
          descripcion: 'Cargo de flete internacional en USD'),
      _M3Campo(
          nombre: 'Seguro',
          posicion: 'C-2',
          descripcion: 'Cargo de seguro en USD'),
      _M3Campo(
          nombre: 'Embalaje',
          posicion: 'C-3',
          descripcion: 'Cargo de embalaje en USD'),
    ]),
    _M3Section(nombre: 'IDENTIFICADORES', campos: [
      _M3Campo(
          nombre: 'Clave Identificador',
          posicion: 'ID-1',
          descripcion: '2 chars (AF, TL, EP, MA, etc.)'),
      _M3Campo(
          nombre: 'Complemento 1',
          posicion: 'ID-2',
          descripcion: 'Primer complemento del identificador'),
      _M3Campo(
          nombre: 'Complemento 2',
          posicion: 'ID-3',
          descripcion: 'Segundo complemento del identificador'),
    ]),
  ];

  final TextEditingController _m3Controller = TextEditingController();
  Map<String, _CampoParsed> _parsed = {};
  int _tokens = 0;
  int _mapped = 0;
  int _errors = 0;
  bool _analizado = false;

  Future<void> _parseM3() async {
    final text = _m3Controller.text;
    final tokens =
        text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    _tokens = tokens.length;
    _parsed = {};
    _mapped = 0;
    _errors = 0;

    if (tokens.isEmpty) {
      setState(() => _analizado = true);
      return;
    }

    int tIdx = 0;
    for (final sec in _m3Sections) {
      for (final campo in sec.campos) {
        if (tIdx < tokens.length) {
          final String val = tokens[tIdx];
          String estado = 'VÃƒÂLIDO';
          if (RegExp('[ÃƒÂ±Ãƒ¡ÃƒÂ©ÃƒÂ­ÃƒÂ³ÃƒÂº]').hasMatch(val)) {
            estado = 'CORRUPTO';
            _errors++;
          } else if (val.length > 20) {
            estado = 'MALFORMADO';
            _errors++;
          } else if (val == '0' || val == '0.00' || val.contains('??')) {
            estado = 'SOSPECHOSO';
            _errors++;
          }
          _parsed[campo.nombre] = _CampoParsed(valor: val, estado: estado);
          _mapped++;
          tIdx++;
        } else {
          _parsed[campo.nombre] =
              const _CampoParsed(valor: '???', estado: 'MALFORMADO');
          _errors++;
        }
      }
    }
    setState(() => _analizado = true);

    // AI Integration & Firestore
    try {
      final model = FirebaseAI.vertexAI().generativeModel(
          model: 'gemini-1.5-flash',
          systemInstruction: Content.system(
              'Eres un forense de módulo M3 de México. Analiza los datos del pre-pedimento M3 e identifica errores, inconsistencias con la normativa y riesgos de rechazo por el SAT.'));
      final response = await model.generateContent([Content.text(text)]);

      await FirebaseFirestore.instance.collection('historial_m3').add({
        'm3_bruto': text,
        'analisis_ai': response.text,
        'tokens': _tokens,
        'errores': _errors,
        'created_at': FieldValue.serverTimestamp(),
        'uid': FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Análisis IA guardado en Firestore'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint('AI Error: $e');
    }
  }

  void _cargarEjemplo() {
    _m3Controller.text =
        "IM A1 XAXX010101000 25000.00 26072026 801 1 84713001 LaptÃƒÂ³ps 10 2500.00 0 16 500.00 100.00 0.00 AF TM ??";
    _parseM3();
  }

  void _exportar() {
    Clipboard.setData(ClipboardData(
        text: _parsed.entries
            .map((e) => '${e.key}: ${e.value.valor} [${e.value.estado}]')
            .join('\n')));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Reporte copiado', style: TextStyle(color: _bg)),
        backgroundColor: _ambar));
  }

  @override
  @override
  void dispose() {
    _m3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('M3 Forensics Decryptor',
            style: TextStyle(color: _rojo, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _ambar),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _bord, height: 1)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000),
                        border: Border.all(color: _bord),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _m3Controller,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(
                            color: _verde,
                            fontFamily: 'monospace',
                            fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Pega el M3 en bruto...',
                          hintStyle: TextStyle(color: _sec),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _parseM3,
                    icon: const Icon(Icons.bug_report, color: _bg),
                    label: const Text('Desencriptar M3',
                        style:
                            TextStyle(color: _bg, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _rojo,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _cargarEjemplo,
                    child: const Text('Cargar M3 de ejemplo',
                        style: TextStyle(color: _ambar)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: _card,
                  border: Border.all(color: _bord),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '$_tokens tokens detectados Ã‚· $_mapped campos mapeados Ã‚· $_errors errores forenses',
                            style: const TextStyle(
                                color: _texto,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        OutlinedButton.icon(
                          onPressed: _analizado ? _exportar : null,
                          icon: Icon(Icons.copy,
                              size: 16, color: _analizado ? _ambar : _sec),
                          label: Text('Exportar reporte',
                              style:
                                  TextStyle(color: _analizado ? _ambar : _sec)),
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: _analizado ? _ambar : _bord),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: _bord),
                    const SizedBox(height: 16),
                    Expanded(
                      child: !_analizado
                          ? const Center(
                              child: Text(
                                  'Pega una cadena M3 para iniciar el anÃƒ¡lisis forense',
                                  style: TextStyle(color: _sec, fontSize: 16)))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _m3Sections.length,
                              itemBuilder: (context, idxSec) {
                                final sec = _m3Sections[idxSec];
                                return ExpansionTile(
                                  collapsedBackgroundColor: _card,
                                  backgroundColor: _card,
                                  iconColor: _ambar,
                                  collapsedIconColor: _sec,
                                  title: Text(sec.nombre,
                                      style: const TextStyle(
                                          color: _texto,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  children: sec.campos.map((c) {
                                    final p = _parsed[c.nombre] ??
                                        const _CampoParsed(
                                            valor: '???', estado: 'MALFORMADO');
                                    Color badgeCol;
                                    Color bgCol = Colors.transparent;
                                    Color textCol = _texto;
                                    if (p.estado == 'CORRUPTO') {
                                      badgeCol = _rojo;
                                      bgCol = _rojo.withValues(alpha: 0.15);
                                      textCol = _rojo;
                                    } else if (p.estado == 'MALFORMADO') {
                                      badgeCol = _ambar;
                                    } else if (p.estado == 'SOSPECHOSO') {
                                      badgeCol = Colors.yellow;
                                    } else {
                                      badgeCol = _verde;
                                      textCol = _verde.withValues(alpha: 0.8);
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                                '${c.posicion} - ${c.nombre}',
                                                style: const TextStyle(
                                                    color: _sec, fontSize: 13)),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: bgCol,
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Text(p.valor,
                                                  style: TextStyle(
                                                      color: textCol,
                                                      fontFamily: 'monospace',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14)),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: badgeCol.withValues(
                                                    alpha: 0.15),
                                                border: Border.all(
                                                    color: badgeCol.withValues(
                                                        alpha: 0.5)),
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: Text(p.estado,
                                                style: TextStyle(
                                                    color: badgeCol,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
