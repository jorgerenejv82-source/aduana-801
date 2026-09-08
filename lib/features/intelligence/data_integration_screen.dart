import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;
const Color _morado = Color(0xFF8B5CF6);
const Color _naran = Color(0xFFF97316);

enum _PipelineStatus { idle, running, completed, error }

class _Pipeline {
  final String id;
  final String nombre;
  final String descripcion;
  final String source;
  final String sourceIcon;
  final String dest;
  final String destIcon;
  final Color color;
  final String schedule;
  final String lastRun;
  final int recordsLast;
  _PipelineStatus status;
  double progreso;
  String? logOutput;

  _Pipeline({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.source,
    required this.sourceIcon,
    required this.dest,
    required this.destIcon,
    required this.color,
    required this.schedule,
    required this.lastRun,
    required this.recordsLast,
  })  : status = _PipelineStatus.idle,
        progreso = 0.0;
}

class _TransformRule {
  final String nombre;
  final String descripcion;
  final String input;
  final String output;
  final String logica;
  final Color color;
  const _TransformRule(
      {required this.nombre,
      required this.descripcion,
      required this.input,
      required this.output,
      required this.logica,
      required this.color});
}

class _EtlRun {
  final String pipeline;
  final DateTime inicio;
  final String duracion;
  final int registros;
  final bool exito;
  final String mensaje;
  const _EtlRun(
      {required this.pipeline,
      required this.inicio,
      required this.duracion,
      required this.registros,
      required this.exito,
      required this.mensaje});
}

const _transformRules = [
  _TransformRule(
      nombre: 'Normalizar RFC',
      descripcion: 'Convierte RFC a mayúsculas y valida formato',
      input: 'xaxx010101000',
      output: 'XAXX010101000',
      logica: 'rfc.toUpperCase().trim() + validar patrón RGCE',
      color: _azul),
  _TransformRule(
      nombre: 'Convertir Moneda',
      descripcion: 'Convierte USD a MXN usando TC DOF del día',
      input: 'USD 50,000.00',
      output: 'MXN 875,000.00',
      logica: 'valor * tcDof (actualizado diariamente vía Banxico API)',
      color: _verde),
  _TransformRule(
      nombre: 'Fracción a TARIC EU',
      descripcion: 'Traduce fracción LIGIE mexicana a código TARIC europeo',
      input: '8471.30.01',
      output: '8471.30.00 (TARIC EU)',
      logica: 'Mapeo HS2022 → TARIC DB. 6 primeros dígitos son universales HS.',
      color: _ambar),
  _TransformRule(
      nombre: 'Incoterm a SAP',
      descripcion: 'Traduce incoterm libre a código SAP MM',
      input: 'CIF / FOB / DDP',
      output: 'C3F / C2F / DDU (códigos SAP EKKO)',
      logica: 'Tabla de mapeo hardcoded según configuración SAP del cliente',
      color: _naran),
  _TransformRule(
      nombre: 'Fecha DOF a ISO8601',
      descripcion: 'Convierte fechas del DOF al formato estándar ISO',
      input: '26 de julio de 2024',
      output: '2024-07-26T00:00:00Z',
      logica: 'DateFormat("d \'de\' MMMM \'de\' y", "es_MX").parse(fechaDof)',
      color: _morado),
  _TransformRule(
      nombre: 'Peso KG a CBM estimado',
      descripcion: 'Estima volumen CBM desde peso bruto (para LCL)',
      input: '1,000 kg',
      output: '~3.33 CBM',
      logica: 'peso / 300 (densidad estándar general cargo por IATA/IMO)',
      color: _ambar),
];

class DataIntegrationScreen extends StatefulWidget {
  const DataIntegrationScreen({super.key});
  @override
  State<DataIntegrationScreen> createState() => _DataIntegrationScreenState();
}

class _DataIntegrationScreenState extends State<DataIntegrationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final List<Timer> _timers = [];
  late final List<_Pipeline> _pipelines;
  final _historial = [
    _EtlRun(
        pipeline: 'SAAI → Firestore',
        inicio: DateTime(2026, 8, 1, 11, 30),
        duracion: '2.3s',
        registros: 183,
        exito: true,
        mensaje: '183 pedimentos sincronizados. 0 errores.'),
    _EtlRun(
        pipeline: 'Excel → Pedimentos',
        inicio: DateTime(2026, 8, 1, 10, 15),
        duracion: '5.1s',
        registros: 47,
        exito: true,
        mensaje: '47 registros importados. 2 duplicados omitidos.'),
    _EtlRun(
        pipeline: 'Firestore → SAP IDOC',
        inicio: DateTime(2026, 8, 1, 8),
        duracion: 'Error',
        registros: 0,
        exito: false,
        mensaje: 'Error: SAP offline. Connection refused en puerto 8443.'),
    _EtlRun(
        pipeline: 'Banxico → TC Cache',
        inicio: DateTime(2026, 7, 31, 18),
        duracion: '0.9s',
        registros: 1,
        exito: true,
        mensaje: 'TC actualizado: 1 USD = 17.1500 MXN.'),
    _EtlRun(
        pipeline: 'DOF → Normas DB',
        inicio: DateTime(2026, 7, 31, 9),
        duracion: '12.4s',
        registros: 3,
        exito: true,
        mensaje: '3 nuevas NOM detectadas: NOM-019, NOM-051, NOM-003.'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _pipelines = [
      _Pipeline(
          id: 'saai',
          nombre: 'SAAI M3 → Firestore',
          descripcion:
              'Extrae pedimentos del día desde SAAI M3 y los replica en Firestore.',
          source: 'SAAI M3',
          sourceIcon: 'M3',
          dest: 'Firestore',
          destIcon: 'FB',
          color: _azul,
          schedule: 'Cada hora',
          lastRun: 'hace 30 min',
          recordsLast: 183),
      _Pipeline(
          id: 'excel',
          nombre: 'Excel/CSV → Pedimentos',
          descripcion: 'Importa pedimentos desde archivos Excel o CSV.',
          source: 'Excel/CSV',
          sourceIcon: 'XL',
          dest: 'Firestore',
          destIcon: 'FB',
          color: _verde,
          schedule: 'Manual',
          lastRun: 'hace 2h',
          recordsLast: 47),
      _Pipeline(
          id: 'sap',
          nombre: 'Firestore → SAP S/4HANA',
          descripcion: 'Exporta pedimentos liberados como IDoc a SAP.',
          source: 'Firestore',
          sourceIcon: 'FB',
          dest: 'SAP ERP',
          destIcon: 'SP',
          color: _naran,
          schedule: 'Al liberar',
          lastRun: 'hace 3h (ERROR)',
          recordsLast: 0),
      _Pipeline(
          id: 'banxico',
          nombre: 'Banxico API → TC Cache',
          descripcion: 'Descarga el tipo de cambio DOF de Banxico.',
          source: 'Banxico API',
          sourceIcon: 'BX',
          dest: 'Cache Local',
          destIcon: 'LC',
          color: _ambar,
          schedule: 'Diario 18:00',
          lastRun: 'ayer 18:00',
          recordsLast: 1),
      _Pipeline(
          id: 'dof',
          nombre: 'DOF → Base de Normas',
          descripcion: 'Escanea el DOF diariamente y extrae nuevas NOM.',
          source: 'DOF.gob.mx',
          sourceIcon: 'DF',
          dest: 'Normas DB',
          destIcon: 'NB',
          color: _morado,
          schedule: 'Diario 09:00',
          lastRun: 'hoy 09:00',
          recordsLast: 3),
    ];
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  void _runPipeline(_Pipeline p) {
    if (p.status == _PipelineStatus.running) return;
    setState(() {
      p.status = _PipelineStatus.running;
      p.progreso = 0.0;
      p.logOutput = null;
    });
    final rnd = Random();
    final steps = 30 + rnd.nextInt(20);
    int current = 0;
    final t = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      current++;
      setState(() => p.progreso = current / steps);
      if (current >= steps) {
        timer.cancel();
        final exito = p.id != 'sap';
        setState(() {
          p.status = exito ? _PipelineStatus.completed : _PipelineStatus.error;
          p.logOutput = exito
              ? '[INFO] Iniciando extracción...\n[INFO] Conectado a ${p.source}\n[INFO] ${20 + rnd.nextInt(200)} registros extraídos\n[INFO] Validando...\n[INFO] Cargando en ${p.dest}...\n[SUCCESS] Pipeline completado sin errores.'
              : '[INFO] Iniciando pipeline...\n[INFO] Conectando a ${p.source}...\n[ERROR] Connection refused: ${p.dest} no disponible\n[ERROR] Pipeline terminado con error.';
        });
      }
    });
    _timers.add(t);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _ambar),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: _ambar.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _ambar.withValues(alpha: 0.3))),
                  child:
                      const Icon(Icons.upload_file, color: _ambar, size: 18)),
              const SizedBox(width: 12),
              const Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Data Integration Hub (ETL)',
                      style: TextStyle(
                          color: _ambar,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text('Extract · Transform · Load — Pipelines de datos',
                      style: TextStyle(color: _sec, fontSize: 11)),
                ],
              )),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: _ambar.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _ambar.withValues(alpha: 0.3))),
                child: Text('${_pipelines.length} pipelines',
                    style: const TextStyle(
                        color: _ambar,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabCtrl,
            indicatorColor: _ambar,
            labelColor: _ambar,
            unselectedLabelColor: _sec,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(icon: Icon(Icons.account_tree_outlined), text: 'Pipelines'),
              Tab(icon: Icon(Icons.transform), text: 'Transformaciones'),
              Tab(icon: Icon(Icons.history), text: 'Historial'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _tabPipelines(),
            _tabTransformaciones(),
            _tabHistorial(),
          ],
        ),
      );

  Widget _tabPipelines() => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(children: [
            _kpi('Total', '${_pipelines.length}', _ambar),
            const SizedBox(width: 16),
            _kpi(
                'Activos',
                '${_pipelines.where((p) => p.status == _PipelineStatus.running).length}',
                _azul),
            const SizedBox(width: 16),
            _kpi(
                'Con Error',
                '${_pipelines.where((p) => p.status == _PipelineStatus.error || p.lastRun.contains("ERROR")).length}',
                _rojo),
          ]),
          const SizedBox(height: 24),
          for (final p in _pipelines) _pipelineCard(p),
        ],
      );

  Widget _pipelineCard(_Pipeline p) {
    final statusColor = p.status == _PipelineStatus.completed
        ? _verde
        : p.status == _PipelineStatus.error
            ? _rojo
            : p.status == _PipelineStatus.running
                ? _azul
                : p.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: p.status == _PipelineStatus.running
                ? p.color.withValues(alpha: 0.5)
                : _bord),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _nodeBox(p.sourceIcon, p.color),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                for (int i = 0; i < 3; i++)
                  Container(
                      width: 6,
                      height: 2,
                      color:
                          p.status == _PipelineStatus.running ? p.color : _bord,
                      margin: const EdgeInsets.only(right: 4)),
                Icon(Icons.arrow_forward,
                    color: p.status == _PipelineStatus.running ? p.color : _sec,
                    size: 16),
              ])),
          _nodeBox(p.destIcon, p.color.withValues(alpha: 0.8)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(p.nombre,
                    style: const TextStyle(
                        color: _texto,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(p.descripcion,
                    style: const TextStyle(color: _sec, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ])),
        ]),
        const SizedBox(height: 16),
        if (p.status == _PipelineStatus.running) ...[
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                  value: p.progreso,
                  backgroundColor: _bg,
                  color: p.color,
                  minHeight: 6)),
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${(p.progreso * 100).toInt()}%',
                    style: TextStyle(
                        color: p.color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              )),
          const SizedBox(height: 12),
        ],
        Row(children: [
          const Icon(Icons.schedule, color: _sec, size: 14),
          const SizedBox(width: 6),
          Text(p.schedule, style: const TextStyle(color: _sec, fontSize: 12)),
          const SizedBox(width: 16),
          const Icon(Icons.history, color: _sec, size: 14),
          const SizedBox(width: 6),
          Expanded(
              child: Text('Último: ${p.lastRun}',
                  style: TextStyle(
                      color: p.lastRun.contains('ERROR') ? _rojo : _sec,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
          if (p.recordsLast > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: _verde.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _verde.withValues(alpha: 0.3))),
              child: Text('${p.recordsLast} reg',
                  style: const TextStyle(
                      color: _verde,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
        ]),
        if (p.logOutput != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _bord)),
            child: Text(p.logOutput!,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    height: 1.6)),
          ),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: MouseRegion(
            cursor: p.status == _PipelineStatus.running
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: p.status == _PipelineStatus.running
                  ? null
                  : () => _runPipeline(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: p.status == _PipelineStatus.running ? _bord : p.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (p.status == _PipelineStatus.running)
                      const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              color: _texto, strokeWidth: 2))
                    else
                      const Icon(Icons.play_arrow, size: 18, color: _bg),
                    const SizedBox(width: 8),
                    Text(
                        p.status == _PipelineStatus.running
                            ? 'Ejecutando...'
                            : 'Ejecutar Ahora',
                        style: const TextStyle(
                            color: _bg,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          )),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              p.status = _PipelineStatus.idle;
              p.progreso = 0.0;
              p.logOutput = null;
            }),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
                foregroundColor: _sec,
                side: const BorderSide(color: _bord),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
          ),
        ]),
      ]),
    );
  }

  Widget _nodeBox(String label, Color c) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color: c.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.withValues(alpha: 0.4))),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    color: c, fontSize: 12, fontWeight: FontWeight.bold))),
      );

  Widget _tabTransformaciones() => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Reglas de Transformación de Datos',
              style: TextStyle(
                  color: _ambar, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Operaciones aplicadas automáticamente durante los pipelines ETL para normalizar y enriquecer los datos.',
              style: TextStyle(color: _sec, fontSize: 13)),
          const SizedBox(height: 24),
          for (final rule in _transformRules)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _bord),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10)
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: rule.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: rule.color.withValues(alpha: 0.4),
                                    blurRadius: 4)
                              ])),
                      const SizedBox(width: 12),
                      Text(rule.nombre,
                          style: TextStyle(
                              color: rule.color,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    Text(rule.descripcion,
                        style: const TextStyle(color: _sec, fontSize: 13)),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('INPUT',
                                style: TextStyle(
                                    color: _sec,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: _rojo.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: _rojo.withValues(alpha: 0.2))),
                                child: Text(rule.input,
                                    style: const TextStyle(
                                        color: _rojo,
                                        fontSize: 12,
                                        fontFamily: 'monospace'))),
                          ])),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.arrow_forward,
                              color: rule.color, size: 24)),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('OUTPUT',
                                style: TextStyle(
                                    color: _sec,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: _verde.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: _verde.withValues(alpha: 0.2))),
                                child: Text(rule.output,
                                    style: const TextStyle(
                                        color: _verde,
                                        fontSize: 12,
                                        fontFamily: 'monospace'))),
                          ])),
                    ]),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _bord)),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.code, color: _sec, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(rule.logica,
                                    style: const TextStyle(
                                        color: _sec,
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                        height: 1.4))),
                          ]),
                    ),
                  ]),
            ),
        ],
      );

  Widget _tabHistorial() {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Historial de Ejecuciones',
            style: TextStyle(
                color: _ambar, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        for (final run in _historial)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: run.exito ? _bord : _rojo.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (run.exito ? _verde : _rojo).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                          (run.exito ? _verde : _rojo).withValues(alpha: 0.3)),
                ),
                child: Icon(run.exito ? Icons.check : Icons.close,
                    color: run.exito ? _verde : _rojo, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(run.pipeline,
                        style: const TextStyle(
                            color: _texto,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(run.mensaje,
                        style: TextStyle(
                            color: run.exito ? _sec : _rojo, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ])),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(fmt(run.inicio),
                    style: const TextStyle(color: _sec, fontSize: 11)),
                const SizedBox(height: 4),
                Text(run.duracion,
                    style: TextStyle(
                        color: run.exito ? _ambar : _rojo,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                if (run.registros > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${run.registros} reg.',
                        style: const TextStyle(
                            color: _verde,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
              ]),
            ]),
          ),
      ],
    );
  }

  Widget _kpi(String l, String v, Color c) => Expanded(
          child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(color: c.withValues(alpha: 0.05), blurRadius: 10)
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(v,
              style: TextStyle(
                  color: c, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(l,
              style: const TextStyle(
                  color: _sec, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
      ));
}
