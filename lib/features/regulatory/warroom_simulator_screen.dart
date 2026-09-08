import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';

// -- Design Tokens -------------------------------------------------------------
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _card2 = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _rojo = AppColors.red;
const Color _ambar = AppColors.gold;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;
const Color _naran = Color(0xFFF97316);

// -- Tipos de emergencia --------------------------------------------------------
enum _TipoEmergencia { reconocimiento, embargo, acta, auditoria }

class _TipoData {
  final _TipoEmergencia tipo;
  final String label;
  final Color color;
  final IconData icon;
  final List<String> pasos;
  final List<String> documentos;
  final String plazo;

  const _TipoData(
      {required this.tipo,
      required this.label,
      required this.color,
      required this.icon,
      required this.pasos,
      required this.documentos,
      required this.plazo});
}

const _tipos = [
  _TipoData(
    tipo: _TipoEmergencia.reconocimiento,
    label: 'Reconocimiento',
    color: _rojo,
    icon: Icons.search,
    plazo: '4 horas para responder reconocimiento',
    pasos: [
      '1. Notificar inmediatamente al importador y area legal.',
      '2. Verificar que el pedimento y facturas coincidan exactamente.',
      '3. Preparar documentos de soporte: factura, lista de empaque, certificado de origen.',
      '4. Si es reconocimiento aduanero 2do reconocimiento, solicitar presencia del AA.',
      '5. Documentar fisicamente el resultado: descripcion, estado, cantidad.',
      '6. Si hay discrepancia, preparar escrito de aclaracion con fundamento legal.',
    ],
    documentos: [
      'Pedimento',
      'Factura Comercial',
      'Lista de Empaque',
      'Certificado de Origen',
      'Carta de Instrucciones del Importador'
    ],
  ),
  _TipoData(
    tipo: _TipoEmergencia.embargo,
    label: 'Embargo',
    color: _naran,
    icon: Icons.lock_outline,
    plazo: '20 dias habiles para desvirtuar (Art. 155 LA)',
    pasos: [
      '1. URGENTE: Notificar a importador, abogado y direccion general.',
      '2. Solicitar y revisar Acta de Inicio de Embargo y fundamento legal.',
      '3. Identificar causal del embargo: fraccion, origen, valor, permisos.',
      '4. En 20 dias habiles presentar pruebas para desvirtuar embargo.',
      '5. Considerar garantia (deposito o fianza) para liberacion temporal de mercancias.',
      '6. Preparar escrito juridico ante la ALJ correspondiente.',
      '7. Documentar toda la cadena de custodia de la mercancia.',
    ],
    documentos: [
      'Acta de Inicio',
      'Pedimento',
      'Facturas',
      'Certificado de Origen',
      'Analisis de Laboratorio si aplica',
      'Escrito de Desvirtuacion',
      'Garantia Fiscal'
    ],
  ),
  _TipoData(
    tipo: _TipoEmergencia.acta,
    label: 'Acta',
    color: _ambar,
    icon: Icons.description_outlined,
    plazo: '10 dias habiles para ofrecer pruebas',
    pasos: [
      '1. Leer detenidamente el acta y verificar la fecha de notificacion.',
      '2. Identificar los hechos que se asientan y fundamentos legales citados.',
      '3. En 10 dias habiles ofrecer pruebas y alegatos (RGCE).',
      '4. Reunir toda la documentacion que respalde la operacion.',
      '5. Preparar escrito de ofrecimiento de pruebas con argumentos legales.',
      '6. Si el acta deriva en infraccion, evaluar convenio de pago.',
    ],
    documentos: [
      'Acta Circunstanciada',
      'Pedimento',
      'Comprobantes de Pago de Impuestos',
      'Documentacion de Origen',
      'Escrito de Pruebas'
    ],
  ),
  _TipoData(
    tipo: _TipoEmergencia.auditoria,
    label: 'Auditoria',
    color: _azul,
    icon: Icons.policy_outlined,
    plazo: 'Plazo variable: 6-12 meses (RCEE)',
    pasos: [
      '1. Designar equipo de respuesta: contabilidad, legal, AA y direccion.',
      '2. Revisar carta de invitacion o notificacion de auditoria SAT.',
      '3. Localizar y organizar expedientes de los ejercicios auditados.',
      '4. Verificar pedimentos, facturas, pagos de impuestos y clasificaciones.',
      '5. Identificar posibles inconsistencias antes de la visita.',
      '6. Preparar documentacion de precios de transferencia si aplica.',
      '7. Mantener comunicacion formal y documentada con autoridades.',
    ],
    documentos: [
      'Notificacion de Auditoria',
      'Pedimentos del Periodo',
      'Contabilidad Electronica',
      'Facturas de Proveedores',
      'Declaraciones Anuales',
      'Registros IMMEX si aplica'
    ],
  ),
];

// -- Emergencia activa ---------------------------------------------------------
class _Emergencia {
  final String id;
  final _TipoEmergencia tipo;
  final String numPedimento;
  final String aduana;
  final String descripcion;
  final DateTime fechaInicio;
  bool resuelta = false;
  final List<bool> pasosCompletados;

  _Emergencia({
    required this.id,
    required this.tipo,
    required this.numPedimento,
    required this.aduana,
    required this.descripcion,
    required this.fechaInicio,
  }) : pasosCompletados = List.filled(
            _tipos.firstWhere((t) => t.tipo == tipo).pasos.length, false);

  _TipoData get tipoData => _tipos.firstWhere((t) => t.tipo == tipo);
}

// -- Main Screen ---------------------------------------------------------------
class WarroomSimulatorScreen extends StatefulWidget {
  const WarroomSimulatorScreen({super.key});
  @override
  State<WarroomSimulatorScreen> createState() => _WarroomSimulatorScreenState();
}

class _WarroomSimulatorScreenState extends State<WarroomSimulatorScreen> {
  final List<_Emergencia> _activas = [];
  final List<_Emergencia> _resueltas = [];
  _TipoEmergencia _aiTipo = _TipoEmergencia.reconocimiento;
  String _aiQuery = '';
  String _aiResponse = '';
  bool _aiLoading = false;

  _TipoData get _aiData => _tipos.firstWhere((t) => t.tipo == _aiTipo);

  Future<void> _consultarAI() async {
    if (_aiQuery.isEmpty) return;
    setState(() {
      _aiLoading = true;
      _aiResponse = '';
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un experto en respuesta a crisis aduaneras (War Room) en México. Proporciona recomendaciones tácticas y fundamentadas legalmente para resolver la emergencia planteada.'),
      );
      final data = _aiData;
      final prompt =
          'Emergencia: ${data.label}\nPlazo: ${data.plazo}\nConsulta: "$_aiQuery"\nPasos y documentos previos:\n${data.pasos.join('\n')}\n${data.documentos.join(', ')}\nResponde a la consulta de forma breve y accionable.';

      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _aiLoading = false;
        _aiResponse = response.text ?? 'No se pudo generar una respuesta.';
      });
    } catch (e) {
      setState(() => _aiLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error IA: $e'), backgroundColor: _rojo));
      }
    }
  }

  @override
  @override
  void dispose() {
    
    
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _registrarEmergencia,
        backgroundColor: _rojo,
        icon: const Icon(Icons.add_alert, color: Colors.white, size: 18),
        label: const Text('Nueva Emergencia',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(children: [
        // -- Header -------------------------------------------------------------
        Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
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
            const SizedBox(width: 14),
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: _rojo.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _rojo.withAlpha(80))),
                child:
                    const Icon(Icons.shield_outlined, color: _rojo, size: 20)),
            const SizedBox(width: 12),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('TORRE DE EMERGENCIAS ADUANALES',
                      style: TextStyle(
                          color: _texto,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  Text('Centro de control para situaciones criticas de aduana',
                      style: TextStyle(color: _sec, fontSize: 10)),
                ])),
            // Badge de emergencias activas
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: _activas.isEmpty ? _card : _rojo.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _activas.isEmpty ? _bord : _rojo.withAlpha(80))),
                child: Column(children: [
                  Text('${_activas.length}',
                      style: TextStyle(
                          color: _activas.isEmpty ? _sec : _rojo,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1)),
                  Text('EMERGENCIAS',
                      style: TextStyle(
                          color: _activas.isEmpty ? _sec : _rojo, fontSize: 8)),
                ])),
          ]),
        ),

        // -- Body ---------------------------------------------------------------
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -- Emergencias activas -----------------------------------------------
                      const Row(children: [
                        Icon(Icons.warning_amber_rounded,
                            color: _rojo, size: 15),
                        SizedBox(width: 6),
                        Text('Situaciones de Emergencia Activas',
                            style: TextStyle(
                                color: _rojo,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 12),
                      if (_activas.isEmpty)
                        Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _bord)),
                            child: const Row(children: [
                              Icon(Icons.check_circle_outline,
                                  color: _verde, size: 16),
                              SizedBox(width: 10),
                              Text(
                                  'Sin emergencias activas. El sistema esta en standby.',
                                  style: TextStyle(color: _sec, fontSize: 12))
                            ]))
                      else
                        ..._activas.map((e) => _buildEmergenciaCard(e)),
                      const SizedBox(height: 24),

                      // -- AI Assistant ------------------------------------------------------
                      const Row(children: [
                        Icon(Icons.auto_awesome, color: _ambar, size: 15),
                        SizedBox(width: 6),
                        Text('Asistente de Emergencias IA',
                            style: TextStyle(
                                color: _ambar,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 12),
                      Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _bord)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tipo de emergencia a consultar',
                                    style: TextStyle(
                                        color: _sec,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                // Type chips
                                Wrap(
                                    spacing: 8,
                                    children: _tipos.map((t) {
                                      final active = _aiTipo == t.tipo;
                                      return GestureDetector(
                                        onTap: () => setState(() {
                                          _aiTipo = t.tipo;
                                          _aiResponse = '';
                                        }),
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                                color: active
                                                    ? t.color.withAlpha(30)
                                                    : _bg,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                    color: active
                                                        ? t.color
                                                        : _bord)),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.circle,
                                                      color: t.color, size: 8),
                                                  const SizedBox(width: 6),
                                                  Text(t.label,
                                                      style: TextStyle(
                                                          color: active
                                                              ? t.color
                                                              : _sec,
                                                          fontSize: 11,
                                                          fontWeight: active
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal)),
                                                ])),
                                      );
                                    }).toList()),
                                const SizedBox(height: 12),
                                // Query input + send
                                Row(children: [
                                  Expanded(
                                      child: TextField(
                                    onChanged: (v) =>
                                        setState(() => _aiQuery = v),
                                    onSubmitted: (_) => _consultarAI(),
                                    style: const TextStyle(
                                        color: _texto, fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Selecciona un tipo de emergencia y describe la situacion...',
                                      hintStyle: const TextStyle(
                                          color: _sec, fontSize: 12),
                                      filled: true,
                                      fillColor: _bg,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              const BorderSide(color: _bord)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              const BorderSide(color: _bord)),
                                    ),
                                  )),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _aiLoading ? null : _consultarAI,
                                    child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                            color: _aiLoading ? _bord : _ambar,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: _aiLoading
                                            ? const Center(
                                                child: SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                            color: Colors.black,
                                                            strokeWidth: 2)))
                                            : const Icon(Icons.send,
                                                color: Colors.black, size: 18)),
                                  ),
                                ]),
                                // AI response
                                if (_aiResponse.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  const Divider(color: _bord, height: 1),
                                  const SizedBox(height: 14),
                                  Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                          color: _bg,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: _ambar.withAlpha(60))),
                                      child: Text(_aiResponse,
                                          style: const TextStyle(
                                              color: _texto,
                                              fontSize: 11,
                                              height: 1.7))),
                                ],
                                const SizedBox(height: 12),
                                // Protocol reference
                                Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: _aiData.color.withAlpha(12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color:
                                                _aiData.color.withAlpha(60))),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Icon(_aiData.icon,
                                                color: _aiData.color, size: 13),
                                            const SizedBox(width: 6),
                                            Text('Protocolo: ${_aiData.label}',
                                                style: TextStyle(
                                                    color: _aiData.color,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const Spacer(),
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                    color: _aiData.color
                                                        .withAlpha(30),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                                child: Text(_aiData.plazo,
                                                    style: TextStyle(
                                                        color: _aiData.color,
                                                        fontSize: 9)))
                                          ]),
                                          const SizedBox(height: 8),
                                          ..._aiData.pasos.take(3).map((p) =>
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 4),
                                                  child: Text(p,
                                                      style: const TextStyle(
                                                          color: _sec,
                                                          fontSize: 10,
                                                          height: 1.5)))),
                                          if (_aiData.pasos.length > 3)
                                            Text(
                                                '... y ${_aiData.pasos.length - 3} pasos mas',
                                                style: TextStyle(
                                                    color: _aiData.color,
                                                    fontSize: 9)),
                                        ])),
                              ])),
                      const SizedBox(height: 24),

                      // -- Historial de Resueltos --------------------------------------------
                      const Row(children: [
                        Icon(Icons.history, color: _sec, size: 15),
                        SizedBox(width: 6),
                        Text('Historial de Resueltos',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 12),
                      _resueltas.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: _card,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _bord)),
                              child: const Row(children: [
                                Icon(Icons.hourglass_empty,
                                    color: _sec, size: 14),
                                SizedBox(width: 8),
                                Text('Sin emergencias resueltas aun.',
                                    style: TextStyle(color: _sec, fontSize: 12))
                              ]))
                          : Column(
                              children: _resueltas
                                  .map((e) => _buildResueltoCard(e))
                                  .toList()),
                    ]))),
      ]),
    );
  }

  // -- Emergencia Card (activa) --------------------------------------------------
  Widget _buildEmergenciaCard(_Emergencia e) {
    final data = e.tipoData;
    final pctDone =
        e.pasosCompletados.where((b) => b).length / e.pasosCompletados.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(10),
          border: Border(
              left: BorderSide(color: data.color, width: 4),
              top: const BorderSide(color: _bord),
              right: const BorderSide(color: _bord),
              bottom: const BorderSide(color: _bord))),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        title: Row(children: [
          Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: data.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: data.color.withAlpha(80))),
              child: Icon(data.icon, color: data.color, size: 16)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                          color: data.color.withAlpha(30),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(data.label.toUpperCase(),
                          style: TextStyle(
                              color: data.color,
                              fontSize: 8,
                              fontWeight: FontWeight.bold))),
                  const SizedBox(width: 6),
                  Text(e.numPedimento,
                      style: const TextStyle(
                          color: _texto,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace')),
                ]),
                Text(e.aduana,
                    style: const TextStyle(color: _sec, fontSize: 10)),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${(pctDone * 100).round()}%',
                style: TextStyle(
                    color: data.color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            const Text('completado',
                style: TextStyle(color: _sec, fontSize: 8)),
          ]),
        ]),
        subtitle: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                    value: pctDone,
                    backgroundColor: _bord,
                    color: data.color,
                    minHeight: 4))),
        children: [
          Text(e.descripcion,
              style: const TextStyle(color: _sec, fontSize: 11, height: 1.5)),
          const SizedBox(height: 10),
          // Steps checklist
          ...List.generate(
              data.pasos.length,
              (i) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: e.pasosCompletados[i],
                    activeColor: data.color,
                    checkColor: Colors.black,
                    onChanged: (v) =>
                        setState(() => e.pasosCompletados[i] = v!),
                    title: Text(data.pasos[i],
                        style: TextStyle(
                            color: e.pasosCompletados[i] ? _sec : _texto,
                            fontSize: 10,
                            decoration: e.pasosCompletados[i]
                                ? TextDecoration.lineThrough
                                : null)),
                  )),
          const SizedBox(height: 8),
          // Documents needed
          const Text('Documentos requeridos:',
              style: TextStyle(
                  color: _sec, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
              spacing: 6,
              runSpacing: 4,
              children: data.documentos
                  .map((d) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: data.color.withAlpha(15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: data.color.withAlpha(50))),
                      child: Text(d,
                          style: TextStyle(color: data.color, fontSize: 9))))
                  .toList()),
          const SizedBox(height: 10),
          // Resolve button
          SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() {
                  e.resuelta = true;
                  _activas.remove(e);
                  _resueltas.insert(0, e);
                }),
                icon: const Icon(Icons.check, size: 14, color: Colors.black),
                label: const Text('Marcar como Resuelta',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _verde,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              )),
        ],
      ),
    );
  }

  Widget _buildResueltoCard(_Emergencia e) {
    final data = e.tipoData;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: _card.withAlpha(160),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _bord)),
      child: Row(children: [
        Icon(data.icon, color: _verde, size: 16),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${data.label} â€” ${e.numPedimento}',
              style: const TextStyle(
                  color: _sec,
                  fontSize: 11,
                  decoration: TextDecoration.lineThrough)),
          Text(e.aduana, style: const TextStyle(color: _sec, fontSize: 9)),
        ])),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: _verde.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _verde.withAlpha(60))),
            child: const Text('RESUELTA',
                style: TextStyle(
                    color: _verde, fontSize: 9, fontWeight: FontWeight.bold))),
      ]),
    );
  }

  // -- Dialog registrar emergencia --------------------------------------------
  void _registrarEmergencia() {
    _TipoEmergencia tipo = _TipoEmergencia.reconocimiento;
    final pedCtrl = TextEditingController();
    final aduCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime fecha = DateTime.now();

    showDialog<void>(
        context: context,
        barrierColor: Colors.black.withAlpha(160),
        builder: (_) => StatefulBuilder(
            builder: (ctx, setS) => Dialog(
                  backgroundColor: _card2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Container(
                      width: 500,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                      color: _rojo.withAlpha(25),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: _rojo.withAlpha(80))),
                                  child: const Icon(Icons.add_alert,
                                      color: _rojo, size: 18)),
                              const SizedBox(width: 12),
                              const Text('Registrar Emergencia',
                                  style: TextStyle(
                                      color: _texto,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                            ]),
                            const SizedBox(height: 20),
                            const Text('Tipo de emergencia',
                                style: TextStyle(
                                    color: _sec,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                    color: _bg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _bord)),
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButton<_TipoEmergencia>(
                                  value: tipo,
                                  isExpanded: true,
                                  dropdownColor: _card2,
                                  items: _tipos
                                      .map((t) => DropdownMenuItem(
                                          value: t.tipo,
                                          child: Row(children: [
                                            Icon(Icons.circle,
                                                color: t.color, size: 10),
                                            const SizedBox(width: 8),
                                            Text(t.label,
                                                style: const TextStyle(
                                                    color: _texto,
                                                    fontSize: 13))
                                          ])))
                                      .toList(),
                                  onChanged: (v) => setS(() => tipo = v!),
                                ))),
                            const SizedBox(height: 14),
                            _fi(pedCtrl, 'Num. Pedimento'),
                            const SizedBox(height: 10),
                            _fi(aduCtrl, 'Aduana'),
                            const SizedBox(height: 10),
                            _fi(descCtrl, 'Descripcion del problema',
                                maxLines: 3),
                            const SizedBox(height: 14),
                            Row(children: [
                              const Text('Fecha inicio: ',
                                  style: TextStyle(color: _sec, fontSize: 12)),
                              Text('${fecha.day}/${fecha.month}/${fecha.year}',
                                  style: const TextStyle(
                                      color: _texto,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const Spacer(),
                              TextButton(
                                  onPressed: () async {
                                    final p = await showDatePicker(
                                        context: ctx,
                                        initialDate: fecha,
                                        firstDate: DateTime(2025),
                                        lastDate: DateTime(2030),
                                        builder: (c, w) => Theme(
                                            data: ThemeData.dark().copyWith(
                                                colorScheme:
                                                    const ColorScheme.dark(
                                                        primary: _rojo,
                                                        surface: _card2)),
                                            child: w!));
                                    if (p != null) setS(() => fecha = p);
                                  },
                                  child: const Text('Cambiar',
                                      style: TextStyle(
                                          color: _ambar,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold))),
                            ]),
                            const SizedBox(height: 20),
                            Row(children: [
                              Expanded(
                                  child: TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancelar',
                                          style: TextStyle(
                                              color: _sec, fontSize: 13)))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: ElevatedButton(
                                onPressed: () {
                                  if (pedCtrl.text.isEmpty) return;
                                  setState(() => _activas.insert(
                                      0,
                                      _Emergencia(
                                          id:
                                              'E${DateTime.now().millisecondsSinceEpoch}',
                                          tipo: tipo,
                                          numPedimento:
                                              pedCtrl.text.toUpperCase(),
                                          aduana: aduCtrl.text.isEmpty
                                              ? 'No especificada'
                                              : aduCtrl.text,
                                          descripcion: descCtrl.text.isEmpty
                                              ? 'Sin descripcion adicional.'
                                              : descCtrl.text,
                                          fechaInicio: fecha)));
                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: _rojo,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14)),
                                child: const Text('Registrar Emergencia',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              )),
                            ]),
                          ])),
                )));
  }

  Widget _fi(TextEditingController c, String hint, {int maxLines = 1}) =>
      TextField(
        controller: c,
        maxLines: maxLines,
        style: const TextStyle(color: _texto, fontSize: 13),
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _sec, fontSize: 12),
            filled: true,
            fillColor: _bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _bord)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _bord))),
      );
}
