import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _border = AppColors.border;
const Color _text = AppColors.text;
const Color _sub = AppColors.sub;
const Color _gold = AppColors.gold;
const Color _green = AppColors.green;
const Color _red = AppColors.red;
const Color _blue = AppColors.blue;

class OeaSeciitScreen extends StatefulWidget {
  const OeaSeciitScreen({super.key});
  @override
  State<OeaSeciitScreen> createState() => _OeaSeciitScreenState();
}

class _OeaSeciitScreenState extends State<OeaSeciitScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;

  // ── Certificación ────────────────────────────────────────────────────────
  final _numCertCtrl = TextEditingController();
  String _nivelCert = 'OEA-A';
  DateTime? _fechaEmision;
  DateTime? _fechaVencimiento;

  // ── Checklist ────────────────────────────────────────────────────────────
  // 60 criterios en 5 secciones
  static const _secciones = [
    _OeaSeccion('Legal', 12, [
      'No tiene resoluciones de créditos fiscales firmes no pagados',
      'Ha cumplido con sus obligaciones fiscales en los últimos 3 años',
      'No tiene sentencias condenatorias por delitos fiscales o aduaneros',
      'Tiene documentados todos sus procesos de importación/exportación',
      'Mantiene registros de transacciones por mínimo 5 años',
      'Tiene procedimientos escritos de selección de proveedores',
      'Tiene procedimientos de control de calidad documentados',
      'Notifica al SAT dentro de 24h cualquier irregularidad detectada',
      'Cuenta con representante legal designado ante el SAT',
      'Realiza autoevaluaciones anuales de cumplimiento',
      'Tiene manual de políticas y procedimientos de seguridad',
      'Implementa plan de continuidad del negocio',
    ]),
    _OeaSeccion('Instalaciones', 15, [
      'Periferia y edificios protegidos con bardas, cercas o barreras',
      'Puertas de entrada supervisadas por guardias',
      'CCTV en áreas críticas con grabación mínima de 30 días',
      'Iluminación adecuada en áreas de carga/descarga',
      'Sistema de alarma contra intrusos activo 24/7',
      'Procedimiento de inspección de contenedores documentado',
      'Sellos de seguridad de alta integridad en todos los contenedores',
      'Área segregada para mercancía en cuarentena',
      'Control de llaves y accesos físicos documentado',
      'Procedimiento de respuesta a incidentes de seguridad',
      'Inspección de vehículos en entrada/salida',
      'Manifiesto de visitantes y proveedores',
      'Zona de inspección aduanal designada y señalizada',
      'Medidas anti-tunneling en bodegas',
      'Programa de mantenimiento de infraestructura de seguridad',
    ]),
    _OeaSeccion('Acceso', 10, [
      'Sistema electrónico de control de acceso (tarjetas/biométrico)',
      'Insignias o credenciales para todo el personal',
      'Acceso restringido por roles a áreas sensibles',
      'Procedimiento de revocación inmediata de accesos',
      'Registro de accesos con trazabilidad de 90 días',
      'Escolta obligatoria para visitantes en áreas restringidas',
      'Procedimiento de acceso de proveedores de mantenimiento',
      'Inspección de paquetes personales en entrada/salida',
      'Prohibición de dispositivos no autorizados en áreas de carga',
      'Auditorías periódicas de accesos activos',
    ]),
    _OeaSeccion('Asociados', 8, [
      'Procedimiento de evaluación y selección de agentes aduanales',
      'Contratos escritos con cláusulas de seguridad con transportistas',
      'Verificación de lista negra OFAC/SAT en proveedores',
      'Auditorías a instalaciones de proveedores críticos',
      'Acuerdos de confidencialidad con asociados de negocio',
      'Evaluación de riesgo país de proveedores extranjeros',
      'Monitoreo continuo del desempeño de asociados',
      'Plan de acción ante incumplimiento de asociados',
    ]),
    _OeaSeccion('Personal', 15, [
      'Verificación de antecedentes en contratación (5 años histórico)',
      'Capacitación anual en seguridad de la cadena de suministro',
      'Procedimiento de reporte de actividades sospechosas',
      'Plan de seguridad para personal en tránsito',
      'Política de uso de tecnología e informática',
      'Procedimiento de despido con revocación de accesos',
      'Designación de responsable de seguridad OEA',
      'Programa de concientización de amenazas internas',
      'Canal anónimo de denuncias (whistleblower)',
      'Evaluaciones periódicas de confiabilidad del personal',
      'Política de rotación en puestos de alto riesgo',
      'Registro de capacitaciones por empleado',
      'Simulacros de respuesta a incidentes semestrales',
      'Política de control de dispositivos móviles',
      'Evaluación médica para personal en áreas de riesgo',
    ]),
  ];

  // Lista plana de estados de checkboxes
  late List<bool> _checks;
  // Secciones expandidas
  late List<bool> _expanded;

  // Índice base de cada sección en la lista plana
  List<int> get _baseIdx {
    final bases = <int>[];
    int acc = 0;
    for (final s in _secciones) {
      bases.add(acc);
      acc += s.criterios.length;
    }
    return bases;
  }

  int get _totalChecked => _checks.where((c) => c).length;
  int get _totalCriteria =>
      _secciones.fold(0, (acc, s) => acc + s.criterios.length);
  static const _renovacionThreshold = 50;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _checks = List.filled(_totalCriteria, false);
    _expanded = List.filled(_secciones.length, false)..[0] = true;
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _numCertCtrl.dispose();
    super.dispose();
  }

  String get _badgeLabel {
    final pct =
        _totalCriteria > 0 ? (_totalChecked / _totalCriteria * 100).round() : 0;
    if (pct >= 85) return '✅ APTO PARA CERTIFICACIÓN OEA';
    if (pct >= 60) return '🔄 EN PROCESO — Nivel OEA-A posible';
    return '⚠️ Faltan ${_renovacionThreshold - _totalChecked} criterios para renovación';
  }

  Color get _badgeColor {
    final pct =
        _totalCriteria > 0 ? (_totalChecked / _totalCriteria * 100).round() : 0;
    if (pct >= 85) return _green;
    if (pct >= 60) return _blue;
    return _gold;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _gold, size: 24),
            onPressed: () => context.go('/inmex')),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OEA / SECIIT Expedito',
                style: TextStyle(
                    color: _text, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Operador Económico Autorizado — Certificación exclusiva SAT',
                style: TextStyle(color: _sub, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: _sub, size: 24),
              onPressed: () => setState(() {})),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: DecoratedBox(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _border))),
            child: TabBar(
              controller: _tabCtrl,
              indicatorColor: _gold,
              labelColor: _gold,
              unselectedLabelColor: _sub,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(
                    icon: Icon(Icons.verified_outlined, size: 20),
                    text: 'Certificación'),
                Tab(icon: Icon(Icons.tune, size: 20), text: 'Checklist'),
                Tab(icon: Icon(Icons.history, size: 20), text: 'Historial'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildCertificacion(),
          _buildChecklist(),
          _buildHistorial(),
        ],
      ),
    );
  }

  // ── TAB 1: Certificación ─────────────────────────────────────────────────
  Widget _buildCertificacion() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.lightbulb_outline, color: _gold, size: 24),
                  SizedBox(width: 12),
                  Text('Registrar Certificación OEA',
                      style: TextStyle(
                          color: _text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 24),
                const Text('Nivel de Certificación',
                    style: TextStyle(
                        color: _sub,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _nivelCert,
                  dropdownColor: _card,
                  style: const TextStyle(color: _text, fontSize: 16),
                  decoration: _inputDeco(''),
                  items: [
                    'OEA-A',
                    'OEA-AA',
                    'C-TPAT Tier 1',
                    'C-TPAT Tier 2',
                    'C-TPAT Tier 3'
                  ]
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => _nivelCert = v!),
                ),
                const SizedBox(height: 24),
                const Text('Número de certificado',
                    style: TextStyle(
                        color: _sub,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _numCertCtrl,
                  style: const TextStyle(color: _text, fontSize: 16),
                  decoration: _inputDeco('Número de certificado'),
                ),
                const SizedBox(height: 24),
                // Fecha emisión
                const Text('Fecha de emisión',
                    style: TextStyle(
                        color: _sub,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2015),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Theme(
                              data: ThemeData.dark().copyWith(
                                  colorScheme:
                                      const ColorScheme.dark(primary: _gold)),
                              child: child!));
                      if (d != null) setState(() => _fechaEmision = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border)),
                      child: Row(children: [
                        Text(
                            _fechaEmision == null
                                ? 'Seleccionar fecha'
                                : DateFormat('dd/MM/yyyy')
                                    .format(_fechaEmision!),
                            style: TextStyle(
                                color: _fechaEmision == null ? _sub : _text,
                                fontSize: 16)),
                        const Spacer(),
                        const Icon(Icons.calendar_today, color: _sub, size: 20),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Fecha de vencimiento',
                    style: TextStyle(
                        color: _sub,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 730)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2040),
                          builder: (ctx, child) => Theme(
                              data: ThemeData.dark().copyWith(
                                  colorScheme:
                                      const ColorScheme.dark(primary: _gold)),
                              child: child!));
                      if (d != null) setState(() => _fechaVencimiento = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border)),
                      child: Row(children: [
                        Text(
                            _fechaVencimiento == null
                                ? 'Seleccionar fecha'
                                : DateFormat('dd/MM/yyyy')
                                    .format(_fechaVencimiento!),
                            style: TextStyle(
                                color: _fechaVencimiento == null ? _sub : _text,
                                fontSize: 16)),
                        const Spacer(),
                        const Icon(Icons.calendar_today, color: _sub, size: 20),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _registrarCertificacion,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: _bg,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('Registrar Certificación',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Info card DTA
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _green.withValues(alpha: 0.3))),
            child: const Row(children: [
              Icon(Icons.savings_outlined, color: _green, size: 32),
              SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Beneficio: DTA reducida al 0.4%',
                        style: TextStyle(
                            color: _green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                        'Las empresas certificadas OEA pagan DTA de 0.4% en vez del 0.8% estándar — Art. 49 LFD.',
                        style: TextStyle(color: _sub, fontSize: 14)),
                  ])),
            ]),
          ),
        ],
      ),
    );
  }

  // ── TAB 2: Checklist ─────────────────────────────────────────────────────
  Widget _buildChecklist() {
    final pct =
        _totalCriteria > 0 ? (_totalChecked / _totalCriteria * 100).round() : 0;
    return Column(
      children: [
        // Progress header
        Container(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
          color: _card,
          child: Column(
            children: [
              Row(children: [
                Text('$_totalChecked / $_totalCriteria criterios cumplidos',
                    style: const TextStyle(
                        color: _gold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('$pct%',
                    style: const TextStyle(
                        color: _gold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value:
                      _totalCriteria > 0 ? _totalChecked / _totalCriteria : 0,
                  backgroundColor: _border,
                  valueColor: AlwaysStoppedAnimation<Color>(_badgeColor),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    color: _badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: _badgeColor.withValues(alpha: 0.5))),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.account_balance, size: 20, color: _sub),
                  const SizedBox(width: 12),
                  Text(_badgeLabel,
                      style: TextStyle(
                          color: _badgeColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ],
          ),
        ),

        // Secciones
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(_secciones.length, (si) {
                final sec = _secciones[si];
                final baseI = _baseIdx[si];
                final secChecked = List.generate(
                        sec.criterios.length, (ci) => _checks[baseI + ci])
                    .where((c) => c)
                    .length;
                return Column(
                  children: [
                    // Header de sección
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _expanded[si] = !_expanded[si]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 20),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: _expanded[si] ? _border : _card)),
                            color: _expanded[si] ? _card : _bg,
                          ),
                          child: Row(children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(sec.nombre,
                                      style: const TextStyle(
                                          color: _text,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '$secChecked/${sec.criterios.length} cumplidos',
                                      style: const TextStyle(
                                          color: _sub, fontSize: 14)),
                                ])),
                            if (secChecked > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                    color: _green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                    '$secChecked/${sec.criterios.length}',
                                    style: const TextStyle(
                                        color: _green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ),
                            const SizedBox(width: 16),
                            Icon(
                                _expanded[si]
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: _sub,
                                size: 24),
                          ]),
                        ),
                      ),
                    ),
                    // Criterios
                    if (_expanded[si])
                      ...List.generate(sec.criterios.length, (ci) {
                        final globalI = baseI + ci;
                        return DecoratedBox(
                          decoration: const BoxDecoration(
                              border:
                                  Border(bottom: BorderSide(color: _border))),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: _sub,
                            ),
                            child: CheckboxListTile(
                              value: _checks[globalI],
                              onChanged: (v) =>
                                  setState(() => _checks[globalI] = v!),
                              title: Text(sec.criterios[ci],
                                  style: TextStyle(
                                      color: _checks[globalI] ? _green : _text,
                                      fontSize: 14)),
                              activeColor: _green,
                              checkColor: _bg,
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 8),
                            ),
                          ),
                        );
                      }),
                  ],
                );
              }),
            ),
          ),
        ),

        // Footer actions
        Container(
          padding: const EdgeInsets.all(24),
          color: _card,
          child: Row(children: [
            Expanded(
                child: OutlinedButton.icon(
              onPressed: () =>
                  setState(() => _checks = List.filled(_totalCriteria, false)),
              icon: const Icon(Icons.clear_all, size: 20),
              label: const Text('Limpiar',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                  foregroundColor: _sub,
                  side: const BorderSide(color: _border),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            )),
            const SizedBox(width: 16),
            Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _exportarChecklist,
                  icon: const Icon(Icons.copy, size: 20),
                  label: const Text('Exportar Checklist',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: _bg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                )),
          ]),
        ),
      ],
    );
  }

  // ── TAB 3: Historial ─────────────────────────────────────────────────────
  Widget _buildHistorial() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null
        ? const Center(
            child: Text('Autentícate para ver el historial',
                style: TextStyle(color: _sub, fontSize: 16)))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('oea_historial')
                .where('agentUid', isEqualTo: uid)
                .orderBy('timestamp', descending: true)
                .limit(20)
                .snapshots(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: _gold));
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_edu,
                            color: _sub.withValues(alpha: 0.5), size: 80),
                        const SizedBox(height: 24),
                        const Text('No hay auditorías OEA registradas',
                            style: TextStyle(
                                color: _sub,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _tabCtrl.animateTo(0),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Registrar primera certificación',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _gold,
                              foregroundColor: _bg,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                        ),
                      ]),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(32),
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  DateTime ts = DateTime.now();
                  if (data['timestamp'] is Timestamp) {
                    ts = (data['timestamp'] as Timestamp).toDate();
                  }
                  final pct = (data['porcentaje'] ?? 0) as num;
                  final color = pct >= 85
                      ? _green
                      : pct >= 60
                          ? _blue
                          : _gold;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]),
                      child: Row(children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((data['nivel'] ?? '—').toString(),
                                  style: const TextStyle(
                                      color: _gold,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(DateFormat('dd/MM/yyyy').format(ts),
                                  style: const TextStyle(
                                      color: _sub, fontSize: 14)),
                              const SizedBox(height: 4),
                              if (data['numCert'] != null)
                                Text('Cert: ${data['numCert']}',
                                    style: const TextStyle(
                                        color: _sub, fontSize: 14)),
                            ]),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: color.withValues(alpha: 0.5))),
                          child: Text('$pct%',
                              style: TextStyle(
                                  color: color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ]),
                    ),
                  );
                },
              );
            },
          );
  }

  // ── Acciones ─────────────────────────────────────────────────────────────
  Future<void> _registrarCertificacion() async {
    if (_numCertCtrl.text.isEmpty ||
        _fechaEmision == null ||
        _fechaVencimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Completa todos los campos', style: TextStyle(color: _text)),
          backgroundColor: _red));
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final pct =
        _totalCriteria > 0 ? (_totalChecked / _totalCriteria * 100).round() : 0;
    await FirebaseFirestore.instance.collection('oea_historial').add({
      'nivel': _nivelCert,
      'numCert': _numCertCtrl.text.trim(),
      'fechaEmision': Timestamp.fromDate(_fechaEmision!),
      'fechaVencimiento': Timestamp.fromDate(_fechaVencimiento!),
      'porcentaje': pct,
      'criteriosCumplidos': _totalChecked,
      'agentUid': uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Certificación OEA registrada',
              style: TextStyle(color: _text)),
          backgroundColor: _card));
      _tabCtrl.animateTo(2);
    }
  }

  void _exportarChecklist() {
    final sb = StringBuffer();
    sb.writeln('=== CHECKLIST OEA / SECIIT — Aduanas 801 ===');
    sb.writeln(
        'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    sb.writeln('Criterios cumplidos: $_totalChecked / $_totalCriteria');
    final pct =
        _totalCriteria > 0 ? (_totalChecked / _totalCriteria * 100).round() : 0;
    sb.writeln('Score: $pct%');
    sb.writeln();
    for (var si = 0; si < _secciones.length; si++) {
      final sec = _secciones[si];
      final base = _baseIdx[si];
      final secChecked =
          List.generate(sec.criterios.length, (ci) => _checks[base + ci])
              .where((c) => c)
              .length;
      sb.writeln('--- ${sec.nombre} ($secChecked/${sec.criterios.length}) ---');
      for (var ci = 0; ci < sec.criterios.length; ci++) {
        sb.writeln(
            '  [${_checks[base + ci] ? 'X' : ' '}] ${sec.criterios[ci]}');
      }
      sb.writeln();
    }
    Clipboard.setData(ClipboardData(text: sb.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('📋 Checklist copiado al portapapeles',
              style: TextStyle(color: _text)),
          backgroundColor: _card));
    }
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        hintText: label.isEmpty ? null : label,
        hintStyle: const TextStyle(color: _sub, fontSize: 14),
        filled: true,
        fillColor: _bg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _gold)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
}

// ── Data model ─────────────────────────────────────────────────────────────
class _OeaSeccion {
  final String nombre;
  final int total;
  final List<String> criterios;
  const _OeaSeccion(this.nombre, this.total, this.criterios);
}
