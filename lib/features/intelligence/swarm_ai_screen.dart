import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:async';

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

enum _AgentStatus { idle, running, done }

class _Agent {
  final String id;
  final String nombre;
  final String descripcion;
  final IconData icon;
  final Color color;
  _AgentStatus status = _AgentStatus.idle;
  String? resultado;
  double progreso = 0.0;
  int durationMs;

  _Agent(
      {required this.id,
      required this.nombre,
      required this.descripcion,
      required this.icon,
      required this.color,
      this.durationMs = 2000});
}

class _SwarmOperation {
  final String fraccion;
  final String descripcion;
  final double valorUsd;
  final String pais;
  final String incoterm;
  _SwarmOperation(
      {required this.fraccion,
      required this.descripcion,
      required this.valorUsd,
      required this.pais,
      required this.incoterm});
}

class SwarmAiScreen extends StatefulWidget {
  const SwarmAiScreen({super.key});
  @override
  State<SwarmAiScreen> createState() => _SwarmAiScreenState();
}

class _SwarmAiScreenState extends State<SwarmAiScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  final _fraccionCtrl = TextEditingController(text: '8471.30.01');
  final _descripcionCtrl = TextEditingController(
      text: 'Computadoras portatiles con procesador Intel i7');
  final _valorCtrl = TextEditingController(text: '50000');
  String _pais = 'China';
  String _incoterm = 'CIF';
  bool _swarmRunning = false;
  bool _swarmDone = false;
  bool _btnHovered = false;

  late final List<_Agent> _agents;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _agents = _buildAgents();
  }

  List<_Agent> _buildAgents() => [
        _Agent(
            id: 'clasificador',
            nombre: 'Agente Clasificador',
            descripcion:
                'Verifica la fracción arancelaria LIGIE 2024 y sugiere alternativas.',
            icon: Icons.category_outlined,
            color: _azul,
            durationMs: 2200),
        _Agent(
            id: 'valorador',
            nombre: 'Agente Valorador',
            descripcion:
                'Analiza el valor declarado vs precios referenciales de mercado.',
            icon: Icons.monetization_on_outlined,
            color: _verde,
            durationMs: 2800),
        _Agent(
            id: 'origen',
            nombre: 'Agente de Origen',
            descripcion:
                'Verifica reglas de origen para TLC aplicables y requisitos de documentación.',
            icon: Icons.flag_outlined,
            color: _ambar,
            durationMs: 1800),
        _Agent(
            id: 'compliance',
            nombre: 'Agente Compliance',
            descripcion:
                'Revisa NOMs, permisos previos, cuotas compensatorias y restricciones.',
            icon: Icons.verified_user_outlined,
            color: _morado,
            durationMs: 3200),
        _Agent(
            id: 'riesgo',
            nombre: 'Agente de Riesgo',
            descripcion:
                'Calcula probabilidad de semáforo rojo y factores de riesgo aduanero.',
            icon: Icons.radar,
            color: _rojo,
            durationMs: 2500),
        _Agent(
            id: 'fiscal',
            nombre: 'Agente Fiscal',
            descripcion:
                'Calcula IGI, IVA, DTA, cuotas compensatorias y total de contribuciones.',
            icon: Icons.calculate_outlined,
            color: _azul),
      ];

  @override
  void dispose() {
    _tabCtrl.dispose();
    _fraccionCtrl.dispose();
    _descripcionCtrl.dispose();
    _valorCtrl.dispose();
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  Future<void> _launchSwarm() async {
    if (_swarmRunning) return;
    final op = _SwarmOperation(
      fraccion: _fraccionCtrl.text,
      descripcion: _descripcionCtrl.text,
      valorUsd: double.tryParse(_valorCtrl.text) ?? 0,
      pais: _pais,
      incoterm: _incoterm,
    );
    setState(() {
      _swarmRunning = true;
      _swarmDone = false;
      for (final a in _agents) {
        a.status = _AgentStatus.running;
        a.progreso = 0.0;
        a.resultado = null;
      }
    });

    // Run parallel AI calls
    await Future.wait(_agents.map((a) => _launchAgent(a, op)));

    if (mounted) {
      setState(() {
        _swarmDone = true;
        _swarmRunning = false;
      });
    }
  }

  Future<void> _launchAgent(_Agent agent, _SwarmOperation op) async {
    // Fake progress animation
    final Timer progTimer =
        Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (agent.progreso < 0.9) agent.progreso += 0.05;
      });
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
          model: 'gemini-1.5-flash',
          systemInstruction: Content.system('Eres el agente . . '
              'Analiza la operación: Fracción: , Desc: , Valor: , Pais: . '
              'Responde en un solo párrafo corto (máx 3 líneas) si está correcto o hay riesgo. Sé muy técnico y preciso.'));

      final res = await model
          .generateContent([Content.text('Analiza esta operación aduanera.')]);

      progTimer.cancel();
      if (!mounted) return;
      setState(() {
        agent.progreso = 1.0;
        agent.status = _AgentStatus.done;
        agent.resultado = res.text ?? 'Sin hallazgos';
      });
    } catch (e) {
      progTimer.cancel();
      if (!mounted) return;
      setState(() {
        agent.progreso = 1.0;
        agent.status = _AgentStatus.done;
        agent.resultado = 'Error de IA: ';
      });
    }
  }

  void _resetSwarm() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    setState(() {
      _swarmRunning = false;
      _swarmDone = false;
      for (final a in _agents) {
        a.status = _AgentStatus.idle;
        a.progreso = 0.0;
        a.resultado = null;
      }
    });
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
                  child: const Icon(Icons.hub, color: _ambar, size: 18)),
              const SizedBox(width: 12),
              const Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Swarm AI â€” Enjambre de Agentes',
                      style: TextStyle(
                          color: _ambar,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text('6 agentes autónomos en paralelo',
                      style: TextStyle(color: _sec, fontSize: 11)),
                ],
              )),
              if (_swarmRunning)
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: _ambar, strokeWidth: 2)),
            ],
          ),
          bottom: TabBar(
            controller: _tabCtrl,
            indicatorColor: _ambar,
            labelColor: _ambar,
            unselectedLabelColor: _sec,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            tabs: [
              const Tab(icon: Icon(Icons.input), text: 'Configurar'),
              Tab(
                  icon: const Icon(Icons.grid_view),
                  text:
                      'Enjambre${_swarmRunning ? " ..." : _swarmDone ? " âœ“" : ""}'),
              Tab(
                  icon: const Icon(Icons.summarize_outlined),
                  text: 'Reporte${_swarmDone ? " âœ“" : ""}'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [_tabInput(), _tabAgentes(), _tabReporte()],
        ),
      );

  Widget _tabInput() => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: _ambar.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _ambar.withValues(alpha: 0.3))),
            child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, color: _ambar, size: 24),
                  SizedBox(width: 16),
                  Expanded(
                      child: Text(
                          'El Swarm AI lanza 6 agentes autónomos en paralelo que analizan tu operación simultáneamente: clasificación, valoración, origen, compliance, riesgo y cálculo fiscal. Resultado en segundos.',
                          style: TextStyle(
                              color: _ambar,
                              fontSize: 13,
                              height: 1.5,
                              fontWeight: FontWeight.bold))),
                ]),
          ),
          const SizedBox(height: 24),
          _sec2('Datos de la Operación', Icons.assignment_outlined, _azul, [
            _label('Fracción Arancelaria (10 dígitos)'),
            _fi(_fraccionCtrl, '8471.30.01', Icons.tag),
            const SizedBox(height: 16),
            _label('Descripción de la Mercancía'),
            TextField(
              controller: _descripcionCtrl,
              maxLines: 2,
              style: const TextStyle(color: _texto, fontSize: 14),
              decoration: _inputDec('Descripción detallada de la mercancía',
                  Icons.description_outlined),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _label('Valor CIF (USD)'),
                    _fi(_valorCtrl, '50000', Icons.attach_money, num: true),
                  ])),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _label('País de Origen'),
                    _dropStr([
                      'China',
                      'USA',
                      'Canada',
                      'Mexico',
                      'Alemania',
                      'Japon',
                      'Korea',
                      'India',
                      'Brasil',
                      'Italia'
                    ], _pais, (v) => setState(() => _pais = v!)),
                  ])),
            ]),
            const SizedBox(height: 16),
            _label('Incoterm'),
            _dropStr(['CIF', 'FOB', 'DDP', 'DAP', 'EXW', 'CFR'], _incoterm,
                (v) => setState(() => _incoterm = v!)),
          ]),
          const SizedBox(height: 24),
          _sec2('Agentes que se Activarán', Icons.group_outlined, _ambar, [
            for (final a in _agents)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: a.color.withValues(alpha: 0.3))),
                      child: Icon(a.icon, color: a.color, size: 20)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(a.nombre,
                            style: const TextStyle(
                                color: _texto,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(a.descripcion,
                            style: const TextStyle(color: _sec, fontSize: 12)),
                      ])),
                ]),
              ),
          ]),
          const SizedBox(height: 32),
          MouseRegion(
            onEnter: (_) => setState(() => _btnHovered = true),
            onExit: (_) => setState(() => _btnHovered = false),
            cursor: _swarmRunning
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _swarmRunning ? null : _launchSwarm,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _swarmRunning
                      ? _bord
                      : (_btnHovered ? const Color(0xFFE5B322) : _ambar),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: !_swarmRunning && _btnHovered
                      ? [
                          BoxShadow(
                              color: _ambar.withValues(alpha: 0.4),
                              blurRadius: 12)
                        ]
                      : [],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rocket_launch, color: _bg, size: 20),
                    SizedBox(width: 12),
                    Text('Lanzar Enjambre de Agentes',
                        style: TextStyle(
                            color: _bg,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ]),
      );

  Widget _tabAgentes() => _swarmRunning || _swarmDone
      ? ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: _agents.length + (_swarmDone ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == _agents.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetSwarm,
                        icon: const Icon(Icons.refresh, color: _sec, size: 18),
                        label: const Text('Nuevo Análisis',
                            style: TextStyle(color: _texto)),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _bord),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                    if (_swarmDone) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.picture_as_pdf,
                              color: _bg, size: 18),
                          label: const Text('Exportar Reporte',
                              style: TextStyle(
                                  color: _bg, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _ambar,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
            final a = _agents[i];
            return _agentCard(a);
          },
        )
      : Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.hub, color: _sec.withValues(alpha: 0.3), size: 80),
          const SizedBox(height: 24),
          const Text('Configura la operación y lanza el enjambre.',
              style: TextStyle(
                  color: _sec, fontSize: 16, fontWeight: FontWeight.bold)),
        ]));

  Widget _agentCard(_Agent a) {
    final Color stateC = a.status == _AgentStatus.done
        ? a.color
        : a.status == _AgentStatus.running
            ? a.color.withValues(alpha: 0.6)
            : _sec;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: a.status == _AgentStatus.done
                ? a.color.withValues(alpha: 0.4)
                : _bord),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: stateC.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: stateC.withValues(alpha: 0.3))),
              child: Icon(a.icon, color: stateC, size: 20)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(a.nombre,
                    style: TextStyle(
                        color: stateC,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  a.status == _AgentStatus.idle
                      ? 'En espera...'
                      : a.status == _AgentStatus.running
                          ? 'Analizando...'
                          : a.status == _AgentStatus.done
                              ? 'Análisis completado'
                              : 'Error',
                  style: const TextStyle(color: _sec, fontSize: 12),
                ),
              ])),
          if (a.status == _AgentStatus.running)
            SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(color: a.color, strokeWidth: 2)),
          if (a.status == _AgentStatus.done)
            Icon(Icons.check_circle, color: a.color, size: 22),
        ]),
        if (a.status == _AgentStatus.running) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
                value: a.progreso,
                backgroundColor: _bg,
                color: a.color,
                minHeight: 6),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${(a.progreso * 100).toInt()}%',
                    style: TextStyle(
                        color: a.color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              )),
        ],
        if (a.status == _AgentStatus.done && a.resultado != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _bord)),
            child: Text(a.resultado!,
                style:
                    const TextStyle(color: _texto, fontSize: 13, height: 1.6)),
          ),
        ],
      ]),
    );
  }

  Widget _tabReporte() => !_swarmDone
      ? Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.summarize_outlined,
              color: _sec.withValues(alpha: 0.3), size: 80),
          const SizedBox(height: 24),
          const Text('Ejecuta el enjambre para generar el reporte.',
              style: TextStyle(
                  color: _sec, fontSize: 16, fontWeight: FontWeight.bold)),
        ]))
      : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _verde.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _verde.withValues(alpha: 0.3))),
              child: Row(children: [
                const Icon(Icons.check_circle, color: _verde, size: 28),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Análisis Swarm Completado',
                          style: TextStyle(
                              color: _verde,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                          '${_agents.length} agentes procesaron la operación â€¢ Fracción: ${_fraccionCtrl.text} â€¢ Origen: $_pais',
                          style: const TextStyle(color: _texto, fontSize: 12)),
                    ])),
              ]),
            ),
            const SizedBox(height: 24),
            for (final a in _agents) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: a.color.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10)
                    ]),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(a.icon, color: a.color, size: 18),
                        const SizedBox(width: 12),
                        Text(a.nombre,
                            style: TextStyle(
                                color: a.color,
                                fontSize: 14,
                                fontWeight: FontWeight.bold))
                      ]),
                      const SizedBox(height: 12),
                      Text(a.resultado ?? '',
                          style: const TextStyle(
                              color: _texto, fontSize: 13, height: 1.6)),
                    ]),
              ),
              const SizedBox(height: 16),
            ],
          ]),
        );

  Widget _sec2(String titulo, IconData icon, Color c, List<Widget> children) =>
      Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, color: c, size: 20),
              const SizedBox(width: 12),
              Text(titulo,
                  style: TextStyle(
                      color: c, fontSize: 16, fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 20),
            ...children
          ]));

  Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t,
          style: const TextStyle(
              color: _sec, fontSize: 12, fontWeight: FontWeight.bold)));

  InputDecoration _inputDec(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _sec, fontSize: 14),
        prefixIcon: Icon(icon, color: _sec, size: 18),
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
            borderSide: const BorderSide(color: _ambar)),
      );

  Widget _fi(TextEditingController c, String hint, IconData icon,
          {bool num = false}) =>
      TextField(
          controller: c,
          keyboardType: num ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: _texto, fontSize: 14),
          decoration: _inputDec(hint, icon));

  Widget _dropStr(List<String> opts, String val, ValueChanged<String?> onCh) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _bord)),
        child: DropdownButton<String>(
            value: val,
            isExpanded: true,
            dropdownColor: _card,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, color: _sec, size: 20),
            style: const TextStyle(color: _texto, fontSize: 14),
            items: [
              for (final o in opts) DropdownMenuItem(value: o, child: Text(o))
            ],
            onChanged: onCh),
      );
}
