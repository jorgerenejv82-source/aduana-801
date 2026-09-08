import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// â”€â”€ Design Tokens â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;
const Color _naran = Color(0xFFF97316);

// â”€â”€ Models â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _Criterio {
  final String titulo;
  bool cumplido = false;
  _Criterio(this.titulo);
}

class _Categoria {
  final String nombre;
  final IconData icon;
  final Color color;
  final List<_Criterio> criterios;
  _Categoria(
      {required this.nombre,
      required this.icon,
      required this.color,
      required this.criterios});

  int get total => criterios.length;
  int get done => criterios.where((c) => c.cumplido).length;
  double get score => total == 0 ? 0 : done / total * 100;

  String get statusLabel {
    final s = score;
    if (s >= 80) return 'Compliant';
    if (s >= 40) return 'Partial';
    return 'Non-compliant';
  }

  Color get statusColor {
    final s = score;
    if (s >= 80) return _verde;
    if (s >= 40) return _naran;
    return _rojo;
  }
}

class _Perfil {
  String empresa = 'Mi Empresa';
  String membresia = '';
  String estado = 'Pending';
  String tier = 'Tier 1';
}

// â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class CtpatHubScreen extends StatefulWidget {
  const CtpatHubScreen({super.key});
  @override
  State<CtpatHubScreen> createState() => _CtpatHubScreenState();
}

class _CtpatHubScreenState extends State<CtpatHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _perfil = _Perfil();
  int _expanded = -1;
  bool _planGenerated = false;
  bool _planLoading = false;

  // Historial: each entry = {fecha, score, items, pendientes: [{nombre, score}]}
  final List<Map<String, dynamic>> _historial = [];

  final List<_Categoria> _cats = [
    _Categoria(
        nombre: 'Business Partner Requirements',
        icon: Icons.handshake_outlined,
        color: _azul,
        criterios: [
          _Criterio('Acuerdos escritos de seguridad con proveedores clave'),
          _Criterio('Cuestionarios de seguridad enviados anualmente'),
          _Criterio('Validación de membresía C-TPAT / OEA de socios'),
          _Criterio('Proceso de calificación de nuevos socios documentado'),
          _Criterio('Revisión periódica de socios existentes (mínimo anual)'),
          _Criterio('Plan de respuesta ante incumplimiento de socio'),
        ]),
    _Categoria(
        nombre: 'Cybersecurity',
        icon: Icons.security_outlined,
        color: _azul,
        criterios: [
          _Criterio('Política de seguridad de TI documentada y vigente'),
          _Criterio('Control de acceso por rol (RBAC) implementado'),
          _Criterio('Respaldos de datos verificados mensualmente'),
          _Criterio('Capacitación anual en phishing / ingeniería social'),
          _Criterio('Antivirus / EDR activo en todos los equipos'),
          _Criterio('Plan de respuesta a incidentes cibernéticos'),
        ]),
    _Categoria(
        nombre: 'Conveyance & Equipment Security',
        icon: Icons.local_shipping_outlined,
        color: _azul,
        criterios: [
          _Criterio('Inspección de 17 puntos para tráileres documentada'),
          _Criterio('Sellos de alta seguridad ISO 17712 utilizados'),
          _Criterio('Registro fotográfico de sellos aplicados'),
          _Criterio('GPS/AVL instalado en unidades propias'),
          _Criterio('Procedimiento de inspección de regreso documentado'),
          _Criterio('Mantenimiento preventivo de unidades registrado'),
        ]),
    _Categoria(
        nombre: 'Physical Access Controls',
        icon: Icons.door_front_door_outlined,
        color: _azul,
        criterios: [
          _Criterio('Credenciales de identificación emitidas a empleados'),
          _Criterio('Control de acceso electrónico en áreas restringidas'),
          _Criterio('Registro de visitantes mantenido'),
          _Criterio('Procedimiento de revocación de acceso al terminar empleo'),
          _Criterio('Controles de acceso para entrega de llaves/tarjetas'),
          _Criterio('Revisión periódica de registros de acceso'),
        ]),
    _Categoria(
        nombre: 'Personnel Security',
        icon: Icons.badge_outlined,
        color: _azul,
        criterios: [
          _Criterio('Verificación de antecedentes preempleo documentada'),
          _Criterio('Verificación de referencias de empleo anterior'),
          _Criterio('Procedimiento para reportar actividades sospechosas'),
          _Criterio('Programa de concientización en seguridad activo'),
          _Criterio('Investigación de antecedentes a contratistas temporales'),
          _Criterio('Procedimiento de terminación de empleados de alto riesgo'),
        ]),
    _Categoria(
        nombre: 'Physical Security',
        icon: Icons.shield_outlined,
        color: _azul,
        criterios: [
          _Criterio('Perímetro físico con barrera adecuada (barda/cerca)'),
          _Criterio('Iluminación adecuada en todos los puntos de acceso'),
          _Criterio('CCTV operativo con retención mínimo 30 días'),
          _Criterio('Alarmas de intrusión activas y monitoreadas'),
          _Criterio('Guardias de seguridad con procedimientos escritos'),
        ]),
    _Categoria(
        nombre: 'Procedural Security',
        icon: Icons.assignment_outlined,
        color: _azul,
        criterios: [
          _Criterio('Documentos de embarque verificados antes de cargar'),
          _Criterio('Manifiestos de carga conciliados contra pedidos'),
          _Criterio('Procedimientos para manejo de discrepancias documentados'),
          _Criterio(
              'Auditorías internas de cumplimiento realizadas anualmente'),
          _Criterio('POE de respuesta ante violación de sellos escrito'),
        ]),
  ];

  // â”€â”€ Computed â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  int get _totalItems => _cats.fold(0, (s, c) => s + c.total);
  int get _doneItems => _cats.fold(0, (s, c) => s + c.done);
  double get _globalScore =>
      _cats.fold(0.0, (s, c) => s + c.score) / _cats.length;

  Color get _globalColor {
    final s = _globalScore;
    if (s >= 80) return _verde;
    if (s >= 40) return _naran;
    return _rojo;
  }

  String get _globalLabel {
    final s = _globalScore;
    if (s >= 80) return 'Certificado';
    if (s >= 40) return 'En Proceso';
    return 'Crítico';
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
        title: const Text('Hub C-TPAT',
            style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                indicatorColor: _ambar,
                labelColor: _ambar,
                unselectedLabelColor: _sec,
                labelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                tabs: const [
                  Tab(
                      icon: Icon(Icons.person_outlined, size: 18),
                      text: 'Mi Perfil C-TPAT'),
                  Tab(
                      icon: Icon(Icons.auto_awesome, size: 18),
                      text: 'Plan de Acción IA'),
                  Tab(icon: Icon(Icons.checklist, size: 18), text: 'Checklist'),
                  Tab(icon: Icon(Icons.history, size: 18), text: 'Historial'),
                ],
              ),
              Container(height: 1, color: _bord),
            ],
          ),
        ),
      ),
      body: TabBarView(controller: _tabCtrl, children: [
        _tabPerfil(),
        _tabPlanIA(),
        _tabChecklist(),
        _tabHistorial(),
      ]),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // TAB 1 â€” Mi Perfil C-TPAT
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _tabPerfil() => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Profile card
          _HoverCard(
            child: Row(children: [
              Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: _ambar.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _ambar.withValues(alpha: 0.3))),
                  child: const Icon(Icons.domain, color: _ambar, size: 28)),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(_perfil.empresa,
                        style: const TextStyle(
                            color: _texto,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        'Membresía: ${_perfil.membresia.isEmpty ? "â€”" : _perfil.membresia}',
                        style: const TextStyle(color: _sec, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(children: [
                      _pill(
                          _perfil.estado,
                          _perfil.estado == 'Active'
                              ? _verde
                              : _perfil.estado == 'Pending'
                                  ? _ambar
                                  : _rojo),
                      const SizedBox(width: 8),
                      _pill(_perfil.tier, _azul),
                    ]),
                  ])),
              OutlinedButton.icon(
                onPressed: _editarPerfil,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: _ambar,
                    side: const BorderSide(color: _ambar),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Gauge
            _HoverCard(
              width: 180,
              child: Column(children: [
                const Text('Puntuación Global',
                    style: TextStyle(
                        color: _texto,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _DonutPainter(_globalScore / 100, _globalColor),
                      child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text('${_globalScore.toStringAsFixed(0)}%',
                                style: TextStyle(
                                    color: _globalColor,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    height: 1)),
                            const SizedBox(height: 4),
                            Text(_globalLabel,
                                style: TextStyle(
                                    color: _globalColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ])),
                    )),
                const SizedBox(height: 24),
                _lgd('Certificado', _verde),
                _lgd('En Proceso', _naran),
                _lgd('Crítico', _rojo),
              ]),
            ),
            const SizedBox(width: 16),
            // Category rows
            Expanded(
                child: Column(
                    children: List.generate(_cats.length, (i) {
              final cat = _cats[i];
              final isOpen = _expanded == i;
              return _HoverCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.zero,
                child: Column(children: [
                  InkWell(
                    onTap: () => setState(() => _expanded = isOpen ? -1 : i),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Row(children: [
                          Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                  color: cat.statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: cat.statusColor, width: 2))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(cat.nombre,
                                  style: const TextStyle(
                                      color: _texto,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600))),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: cat.statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: cat.statusColor
                                        .withValues(alpha: 0.3))),
                            child: Text(cat.statusLabel,
                                style: TextStyle(
                                    color: cat.statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 16),
                          Text(cat.score.toStringAsFixed(0),
                              style: TextStyle(
                                  color: cat.statusColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Icon(
                              isOpen
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: _sec,
                              size: 20),
                        ])),
                  ),
                  if (isOpen) ...[
                    const Divider(color: _bord, height: 1),
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Text('Progreso:',
                                    style:
                                        TextStyle(color: _sec, fontSize: 13)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                            value: cat.score / 100,
                                            backgroundColor: _bg,
                                            color: cat.statusColor,
                                            minHeight: 8))),
                                const SizedBox(width: 12),
                                Text('${cat.score.toStringAsFixed(0)}/100',
                                    style: TextStyle(
                                        color: cat.statusColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                              ]),
                              const SizedBox(height: 16),
                              ...cat.criterios.map((cr) => CheckboxListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    value: cr.cumplido,
                                    activeColor: _ambar,
                                    checkColor: _bg,
                                    onChanged: (v) =>
                                        setState(() => cr.cumplido = v!),
                                    title: Text(cr.titulo,
                                        style: TextStyle(
                                            color: cr.cumplido ? _sec : _texto,
                                            fontSize: 13,
                                            decoration: cr.cumplido
                                                ? TextDecoration.lineThrough
                                                : null)),
                                  )),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => _verCriterios(cat),
                                    icon: const Icon(Icons.remove_red_eye,
                                        color: _ambar, size: 16),
                                    label: const Text('Ver Criterios CBP',
                                        style: TextStyle(
                                            color: _ambar,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  )),
                            ])),
                  ],
                ]),
              );
            }))),
          ]),
        ]),
      );

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // TAB 2 â€” Plan de Accion IA
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _tabPlanIA() {
    final bajo80 = _cats.where((c) => c.score < 80).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Análisis de Brechas card
        _HoverCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: _ambar.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _ambar.withValues(alpha: 0.3))),
                  child: const Icon(Icons.bar_chart, color: _ambar, size: 20)),
              const SizedBox(width: 16),
              const Text('Análisis de Brechas',
                  style: TextStyle(
                      color: _texto,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _rojo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _rojo.withValues(alpha: 0.3))),
                  child: Text('${bajo80.length} pilares bajo 80%',
                      style: const TextStyle(
                          color: _rojo,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 24),
            ..._cats.map((cat) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    Icon(cat.icon, color: cat.statusColor, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(cat.nombre,
                            style: const TextStyle(color: _sec, fontSize: 14))),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: cat.statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: cat.statusColor.withValues(alpha: 0.3))),
                        child: Text('${cat.score.toStringAsFixed(0)}/100',
                            style: TextStyle(
                                color: cat.statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold))),
                  ]),
                )),
          ]),
        ),
        const SizedBox(height: 24),

        // Generated plan
        if (_planGenerated) ...[
          const Text('Plan de Acción Sugerido',
              style: TextStyle(
                  color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...bajo80.asMap().entries.map((e) {
            final n = e.key + 1;
            final cat = e.value;
            final pend = cat.criterios.where((c) => !c.cumplido).toList();
            return _HoverCard(
              margin: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(color: cat.statusColor, width: 4))),
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                                color: cat.statusColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: cat.statusColor
                                        .withValues(alpha: 0.3))),
                            child: Center(
                                child: Text('$n',
                                    style: TextStyle(
                                        color: cat.statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(cat.nombre,
                                style: const TextStyle(
                                    color: _texto,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold))),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: cat.statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text('${cat.score.toStringAsFixed(0)}/100',
                                style: TextStyle(
                                    color: cat.statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold))),
                      ]),
                      if (pend.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('Criterios pendientes:',
                            style: TextStyle(
                                color: _sec,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        ...pend.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                          color: _sec, shape: BoxShape.circle)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(c.titulo,
                                          style: const TextStyle(
                                              color: _texto,
                                              fontSize: 13,
                                              height: 1.4))),
                                ]))),
                      ],
                    ]),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _planLoading
                ? null
                : () async {
                    setState(() => _planLoading = true);
                    String planText = '';
                    try {
                      final model = FirebaseAI.vertexAI().generativeModel(
                        model: 'gemini-1.5-flash',
                        systemInstruction: Content.system(
                            'Eres el Director de Cumplimiento C-TPAT y OEA de Mexico. Evalua el perfil de seguridad de la cadena de suministro descrita y genera un reporte de cumplimiento con areas de mejora.'),
                      );
                      final bajo80Names = _cats
                          .where((c) => c.score < 80)
                          .map((c) => c.nombre)
                          .join(', ');
                      final response = await model.generateContent([
                        Content.text(
                            'Evalua este perfil C-TPAT con un score global de ${_globalScore.toStringAsFixed(0)}% y las areas debiles: $bajo80Names.')
                      ]);
                      planText = response.text ?? 'Sin reporte generado.';

                      final user = FirebaseAuth.instance.currentUser;
                      await FirebaseFirestore.instance
                          .collection('ctpat_evaluaciones')
                          .add({
                        'uid': user?.uid ?? 'anon',
                        'score': _globalScore,
                        'plan': planText,
                        'created_at': FieldValue.serverTimestamp(),
                        'updated_at': FieldValue.serverTimestamp(),
                      });
                    } catch (e) {
                      planText = 'Error generating plan: $e';
                    }
                    final now = DateTime.now();
                    final bajo80 = _cats.where((c) => c.score < 80).toList();
                    final entry = <String, dynamic>{
                      'fecha':
                          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
                      'score': _globalScore,
                      'items': _cats.fold(
                          0,
                          (s, c) =>
                              s +
                              c.criterios.where((cr) => !cr.cumplido).length),
                      'pendientes': bajo80
                          .map((c) => {'nombre': c.nombre, 'score': c.score})
                          .toList(),
                    };
                    if (!mounted) return;
                    setState(() {
                      _planLoading = false;
                      _planGenerated = true;
                      _historial.insert(0, entry);
                    });
                  },
            icon: _planLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(color: _bg, strokeWidth: 2))
                : const Icon(Icons.auto_awesome, size: 20, color: _bg),
            label: Text(
                _planLoading
                    ? 'Generando...'
                    : _planGenerated
                        ? 'Regenerar Plan de Acción IA'
                        : 'Generar Plan de Acción IA',
                style: const TextStyle(
                    color: _bg, fontWeight: FontWeight.bold, fontSize: 15)),
            style: ElevatedButton.styleFrom(
                backgroundColor: _ambar,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ]),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // TAB 3 â€” Checklist de Inspeccion
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _tabChecklist() {
    final pct = _totalItems == 0 ? 0.0 : _doneItems / _totalItems;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Progress header
        _HoverCard(
          child: Row(children: [
            SizedBox(
                width: 64,
                height: 64,
                child: CustomPaint(
                  painter: _DonutPainter(
                      pct,
                      pct >= 0.8
                          ? _verde
                          : pct >= 0.4
                              ? _naran
                              : _rojo),
                  child: Center(
                      child: Text('${(pct * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                              color: pct >= 0.8
                                  ? _verde
                                  : pct >= 0.4
                                      ? _naran
                                      : _rojo,
                              fontSize: 14,
                              fontWeight: FontWeight.bold))),
                )),
            const SizedBox(width: 20),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('$_doneItems / $_totalItems items',
                      style: const TextStyle(
                          color: _texto,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Conformes',
                      style: TextStyle(color: _sec, fontSize: 13)),
                ])),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
              label: const Text('Exportar PDF'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: _ambar,
                  side: const BorderSide(color: _ambar),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        // Per-category sections
        DecoratedBox(
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord)),
          child: Column(
              children: _cats.asMap().entries.map((e) {
            final i = e.key;
            final cat = e.value;
            final isLast = i == _cats.length - 1;
            return _checklistSection(cat, isLast: isLast);
          }).toList()),
        ),
      ]),
    );
  }

  Widget _checklistSection(_Categoria cat, {required bool isLast}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: EdgeInsets.zero,
        backgroundColor: _bg,
        collapsedBackgroundColor: Colors.transparent,
        shape: isLast
            ? const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(15)))
            : const RoundedRectangleBorder(),
        collapsedShape: isLast
            ? const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(15)))
            : const RoundedRectangleBorder(),
        leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: _ambar.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _ambar.withValues(alpha: 0.3))),
            child: Icon(cat.icon, color: _ambar, size: 20)),
        title: Text(cat.nombre,
            style: const TextStyle(
                color: _texto, fontSize: 14, fontWeight: FontWeight.bold)),
        trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: cat.statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: cat.statusColor.withValues(alpha: 0.3))),
            child: Text('${cat.done}/${cat.total}',
                style: TextStyle(
                    color: cat.statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold))),
        children: [
          const Divider(color: _bord, height: 1),
          ...cat.criterios.asMap().entries.map((e) {
            final isLastCrit = e.key == cat.criterios.length - 1;
            final cr = e.value;
            return DecoratedBox(
              decoration: BoxDecoration(
                  border: isLastCrit
                      ? null
                      : const Border(bottom: BorderSide(color: _bord))),
              child: ListTile(
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                title: Text(cr.titulo,
                    style: TextStyle(
                        color: cr.cumplido ? _sec : _texto,
                        fontSize: 13,
                        decoration:
                            cr.cumplido ? TextDecoration.lineThrough : null)),
                trailing: GestureDetector(
                  onTap: () => setState(() => cr.cumplido = !cr.cumplido),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        color: cr.cumplido ? _ambar : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: cr.cumplido ? _ambar : _bord, width: 2)),
                    child: cr.cumplido
                        ? const Icon(Icons.check, color: _bg, size: 16)
                        : null,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // TAB 4 â€” Historial
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _tabHistorial() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Historial de Planes de Acción',
              style: TextStyle(
                  color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Registro de auditorías y planes de mejora anteriores.',
              style: TextStyle(color: _sec, fontSize: 13)),
          const SizedBox(height: 24),
          if (_historial.isEmpty)
            // Empty state
            Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history,
                              color: _sec.withValues(alpha: 0.3), size: 64),
                          const SizedBox(height: 20),
                          const Text('No hay planes guardados aún.',
                              style: TextStyle(
                                  color: _texto,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                              'Genera tu primer plan en la pestaña "Plan de Acción IA".',
                              style: TextStyle(color: _sec, fontSize: 13),
                              textAlign: TextAlign.center),
                        ]))),
          ..._historial.asMap().entries.map((e) {
            final idx = e.key;
            final p = e.value;
            final score = p['score'] as double;
            final c = score >= 80
                ? _verde
                : score >= 40
                    ? _naran
                    : _rojo;
            final pendientes = p['pendientes'] as List<Map<String, dynamic>>;
            return _HoverCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.zero,
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor: _ambar,
                  collapsedIconColor: _sec,
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  leading: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.withValues(alpha: 0.3))),
                      child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text('${score.toStringAsFixed(0)}%',
                                style: TextStyle(
                                    color: c,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    height: 1)),
                            const SizedBox(height: 2),
                            const Text('score',
                                style: TextStyle(color: _sec, fontSize: 9)),
                          ]))),
                  title: Text(
                      'Plan ${idx == 0 ? "(Actual) " : ""}â€” ${p['fecha']}',
                      style: const TextStyle(
                          color: _texto,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${p['items']} criterios pendientes',
                        style: const TextStyle(color: _sec, fontSize: 12)),
                  ),
                  trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: _verde.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: _verde.withValues(alpha: 0.3))),
                      child: const Text('Completado',
                          style: TextStyle(
                              color: _verde,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))),
                  children: [
                    const Divider(color: _bord, height: 24),
                    ...pendientes.map((cat) {
                      final cs = cat['score'] as double;
                      final cc = cs >= 80
                          ? _verde
                          : cs >= 40
                              ? _naran
                              : _rojo;
                      return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(children: [
                            Icon(Icons.circle, color: cc, size: 8),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(cat['nombre'] as String,
                                    style: const TextStyle(
                                        color: _sec, fontSize: 13))),
                            Text('${cs.toStringAsFixed(0)}/100',
                                style: TextStyle(
                                    color: cc,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ]));
                    }),
                  ],
                ),
              ),
            );
          }),
        ]));
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _pill(String l, Color c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withValues(alpha: 0.3))),
      child: Text(l,
          style:
              TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold)));

  Widget _lgd(String l, Color c) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(l, style: const TextStyle(color: _sec, fontSize: 11))
      ]));

  // â”€â”€ Ver Criterios Bottom Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _verCriterios(_Categoria cat) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
          builder: (ctx, setS) => Container(
                height: MediaQuery.of(context).size.height * 0.72,
                decoration: const BoxDecoration(
                    color: _card,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Container(
                              margin:
                                  const EdgeInsets.only(top: 16, bottom: 20),
                              width: 48,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: _bord,
                                  borderRadius: BorderRadius.circular(2)))),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cat.nombre,
                                    style: const TextStyle(
                                        color: _texto,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                const Text('Criterios mínimos de cumplimiento',
                                    style:
                                        TextStyle(color: _sec, fontSize: 13)),
                                const SizedBox(height: 16),
                                Row(children: [
                                  Expanded(
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                              value: cat.score / 100,
                                              backgroundColor: _bg,
                                              color: cat.statusColor,
                                              minHeight: 8))),
                                  const SizedBox(width: 12),
                                  Text('${cat.score.toStringAsFixed(0)}/100',
                                      style: TextStyle(
                                          color: cat.statusColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                ]),
                              ])),
                      const Divider(color: _bord, height: 1),
                      Expanded(
                          child: ListView(
                              children: cat.criterios
                                  .map((cr) => DecoratedBox(
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom:
                                                    BorderSide(color: _bord))),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 12),
                                          title: Text(cr.titulo,
                                              style: TextStyle(
                                                  color: cr.cumplido
                                                      ? _sec
                                                      : _texto,
                                                  fontSize: 14,
                                                  decoration: cr.cumplido
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null)),
                                          trailing: GestureDetector(
                                            onTap: () {
                                              setS(() =>
                                                  cr.cumplido = !cr.cumplido);
                                              setState(() {});
                                            },
                                            child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                    color: cr.cumplido
                                                        ? _ambar
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        color: cr.cumplido
                                                            ? _ambar
                                                            : _bord,
                                                        width: 2)),
                                                child: cr.cumplido
                                                    ? const Icon(Icons.check,
                                                        color: _bg, size: 16)
                                                    : null),
                                          ),
                                        ),
                                      ))
                                  .toList())),
                      Padding(
                          padding: const EdgeInsets.all(24),
                          child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: _ambar,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16)),
                                child: const Text('Cerrar',
                                    style: TextStyle(
                                        color: _bg,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ))),
                    ]),
              )),
    );
  }

  // â”€â”€ Edit Profile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _editarPerfil() {
    final empCtrl = TextEditingController(text: _perfil.empresa);
    final memCtrl = TextEditingController(text: _perfil.membresia);
    String estado = _perfil.estado;
    String tier = _perfil.tier;
    showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        builder: (_) => StatefulBuilder(
            builder: (ctx, setS) => Dialog(
                  backgroundColor: _card,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: _bord)),
                  child: Container(
                      width: 480,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Editar Perfil C-TPAT',
                                style: TextStyle(
                                    color: _texto,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 24),
                            _fi(empCtrl, 'Nombre de Empresa'),
                            const SizedBox(height: 16),
                            _fi(memCtrl, 'Número de Membresía'),
                            const SizedBox(height: 16),
                            _dd(
                                'Estado',
                                estado,
                                ['Active', 'Pending', 'Suspended'],
                                (v) => setS(() => estado = v!)),
                            const SizedBox(height: 16),
                            _dd(
                                'Tier Level',
                                tier,
                                ['Tier 1', 'Tier 2', 'Tier 3'],
                                (v) => setS(() => tier = v!)),
                            const SizedBox(height: 32),
                            Row(children: [
                              IconButton(
                                onPressed: () {
                                  setS(() {
                                    empCtrl.clear();
                                    memCtrl.clear();
                                    estado = 'Pending';
                                    tier = 'Tier 1';
                                  });
                                },
                                icon: const Icon(Icons.refresh,
                                    color: _sec, size: 24),
                                tooltip: 'Resetear',
                              ),
                              const Spacer(),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancelar',
                                      style: TextStyle(
                                          color: _sec,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold))),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _perfil.empresa = empCtrl.text.isEmpty
                                        ? 'Mi Empresa'
                                        : empCtrl.text;
                                    _perfil.membresia = memCtrl.text;
                                    _perfil.estado = estado;
                                    _perfil.tier = tier;
                                  });
                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: _ambar,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 14)),
                                child: const Text('Guardar',
                                    style: TextStyle(
                                        color: _bg,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ),
                            ]),
                          ])),
                )));
  }

  Widget _fi(TextEditingController c, String hint) => TextField(
        controller: c,
        style: const TextStyle(color: _texto, fontSize: 14),
        decoration: InputDecoration(
            labelText: hint,
            labelStyle: const TextStyle(color: _sec, fontSize: 13),
            filled: true,
            fillColor: _bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _bord)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _bord)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _ambar))),
      );

  Widget _dd(String lbl, String val, List<String> opts,
          ValueChanged<String?> onCh) =>
      DropdownButtonFormField<String>(
        initialValue: val,
        dropdownColor: _bg,
        style: const TextStyle(color: _texto, fontSize: 14),
        icon: const Icon(Icons.keyboard_arrow_down, color: _sec),
        decoration: InputDecoration(
            labelText: lbl,
            labelStyle: const TextStyle(color: _sec, fontSize: 13),
            filled: true,
            fillColor: _bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _bord)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _bord)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _ambar))),
        items: opts
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onCh,
      );
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;

  const _HoverCard(
      {required this.child, this.padding, this.margin, this.width});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        margin: widget.margin,
        padding: widget.padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _isHovered ? _ambar.withValues(alpha: 0.5) : _bord),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

// â”€â”€ Donut Painter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DonutPainter extends CustomPainter {
  final double value;
  final Color color;
  const _DonutPainter(this.value, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    const start = -1.5707963267948966;
    const full = 6.283185307179586;
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = AppColors.border
          ..strokeWidth = 12
          ..style = PaintingStyle.stroke);
    if (value > 0) {
      canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          start,
          full * value,
          false,
          Paint()
            ..color = color
            ..strokeWidth = 12
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_DonutPainter o) => o.value != value || o.color != color;
}
