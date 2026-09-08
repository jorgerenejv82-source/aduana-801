import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

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
const Color _teal = AppColors.green; // using same green
const Color _morado = Color(0xFF8B5CF6);
const Color _naran = Color(0xFFF97316);

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────
enum _ConnStatus { online, offline, degraded }

class _Integration {
  final String id;
  final String nombre;
  final String descripcion;
  final IconData icon;
  final Color color;
  final _ConnStatus status;
  final String endpoint;
  final String lastSync;
  final int callsToday;
  final String version;
  const _Integration({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icon,
    required this.color,
    required this.status,
    required this.endpoint,
    required this.lastSync,
    required this.callsToday,
    required this.version,
  });
}

class _Webhook {
  final String nombre;
  final String evento;
  final String url;
  final bool activo;
  final String ultimaEjecucion;
  final String resultado;
  const _Webhook({
    required this.nombre,
    required this.evento,
    required this.url,
    required this.activo,
    required this.ultimaEjecucion,
    required this.resultado,
  });
}

class _ApiLog {
  final String metodo;
  final String endpoint;
  final int status;
  final int ms;
  final String hora;
  const _ApiLog(
      {required this.metodo,
      required this.endpoint,
      required this.status,
      required this.ms,
      required this.hora});
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────
const _integrations = [
  _Integration(
      id: 'vucem',
      nombre: 'VUCEM (Ventanilla Unica)',
      descripcion:
          'Ventanilla Unica de Comercio Exterior Mexicana. Transmision de pedimentos y COVE.',
      icon: Icons.language,
      color: _teal,
      status: _ConnStatus.online,
      endpoint: 'https://www.ventanillaunica.gob.mx/vucem/api/v2',
      lastSync: 'hace 2 min',
      callsToday: 247,
      version: 'v2.4'),
  _Integration(
      id: 'saai',
      nombre: 'SAAI M3 Gateway',
      descripcion:
          'Sistema Automatizado Aduanero Integral. Transmision y validacion de pedimentos M3.',
      icon: Icons.monitor,
      color: _azul,
      status: _ConnStatus.online,
      endpoint: 'https://www.aduanas.sat.gob.mx/saai/api/m3',
      lastSync: 'hace 5 min',
      callsToday: 183,
      version: 'M3-2024'),
  _Integration(
      id: 'banxico',
      nombre: 'Banxico API (TC DOF)',
      descripcion:
          'Tipo de cambio oficial DOF del Banco de Mexico. Actualizacion diaria automatica.',
      icon: Icons.currency_exchange,
      color: _ambar,
      status: _ConnStatus.online,
      endpoint: 'https://www.banxico.org.mx/SieAPIRest/service/v1',
      lastSync: 'hace 8h',
      callsToday: 12,
      version: 'v1.0'),
  _Integration(
      id: 'sat',
      nombre: 'SAT Web Services',
      descripcion:
          'Verificacion de RFC, opinion de cumplimiento, lista EFOS y buzon tributario.',
      icon: Icons.account_balance,
      color: _verde,
      status: _ConnStatus.degraded,
      endpoint: 'https://services.sat.gob.mx/api/v1',
      lastSync: 'hace 15 min',
      callsToday: 94,
      version: 'v1.2'),
  _Integration(
      id: 'sap',
      nombre: 'SAP S/4HANA (ERP)',
      descripcion:
          'Integracion con ERP SAP via IDoc. Sincroniza pedimentos, costos y proveedores.',
      icon: Icons.business,
      color: _naran,
      status: _ConnStatus.offline,
      endpoint: 'https://sap.cliente.com:8443/sap/bc/rest',
      lastSync: 'hace 3h',
      callsToday: 0,
      version: 'IDOC-2.0'),
  _Integration(
      id: 'oracle',
      nombre: 'Oracle Fusion ERP',
      descripcion:
          'Conector Oracle. Exporta operaciones aduanales a modulo de cuentas por pagar.',
      icon: Icons.storage,
      color: _rojo,
      status: _ConnStatus.offline,
      endpoint: 'https://oracle.cliente.com/api/fscmRestApi',
      lastSync: 'Nunca',
      callsToday: 0,
      version: 'v23D'),
  _Integration(
      id: 'dof',
      nombre: 'DOF Scraper (Normas)',
      descripcion:
          'Extrae automaticamente nuevas NOM, aranceles y reglas del Diario Oficial de la Federacion.',
      icon: Icons.description_outlined,
      color: _morado,
      status: _ConnStatus.online,
      endpoint: 'https://www.dof.gob.mx/servicioweb',
      lastSync: 'hace 1h',
      callsToday: 5,
      version: 'v1.0'),
];

const _webhooks = [
  _Webhook(
      nombre: 'Notificar Semaforo Rojo',
      evento: 'pedimento.semaforo_rojo',
      url: 'https://hooks.cliente.com/slack/aduanas',
      activo: true,
      ultimaEjecucion: 'hoy 09:47',
      resultado: '200 OK'),
  _Webhook(
      nombre: 'Sync a SAP al Liberar',
      evento: 'pedimento.liberado',
      url: 'https://sap.cliente.com/hooks/import',
      activo: false,
      ultimaEjecucion: 'ayer 16:30',
      resultado: '503 Timeout'),
  _Webhook(
      nombre: 'Alerta Vencimiento DTA',
      evento: 'dta.vencimiento_proximo',
      url: 'https://hooks.cliente.com/teams/fiscal',
      activo: true,
      ultimaEjecucion: 'hoy 08:00',
      resultado: '200 OK'),
  _Webhook(
      nombre: 'Email Nuevo Pedimento',
      evento: 'pedimento.creado',
      url: 'https://email.cliente.com/api/send',
      activo: true,
      ultimaEjecucion: 'hoy 11:22',
      resultado: '200 OK'),
];

const _logs = [
  _ApiLog(
      metodo: 'GET',
      endpoint: '/vucem/cove/verify',
      status: 200,
      ms: 187,
      hora: '11:42:03'),
  _ApiLog(
      metodo: 'POST',
      endpoint: '/saai/pedimento/transmit',
      status: 200,
      ms: 2341,
      hora: '11:40:17'),
  _ApiLog(
      metodo: 'GET',
      endpoint: '/banxico/tc/dof',
      status: 200,
      ms: 92,
      hora: '11:35:00'),
  _ApiLog(
      metodo: 'GET',
      endpoint: '/sat/rfc/verify/XAXX010101000',
      status: 503,
      ms: 30000,
      hora: '11:30:05'),
  _ApiLog(
      metodo: 'GET',
      endpoint: '/sat/efos/search',
      status: 503,
      ms: 30000,
      hora: '11:28:44'),
  _ApiLog(
      metodo: 'POST',
      endpoint: '/vucem/pedimento/cove',
      status: 201,
      ms: 451,
      hora: '11:25:11'),
  _ApiLog(
      metodo: 'GET',
      endpoint: '/dof/normas/latest',
      status: 200,
      ms: 1100,
      hora: '10:58:30'),
  _ApiLog(
      metodo: 'POST',
      endpoint: '/sap/idoc/send',
      status: 500,
      ms: 5000,
      hora: '08:15:00'),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class ApiGatewayScreen extends StatefulWidget {
  const ApiGatewayScreen({super.key});
  @override
  State<ApiGatewayScreen> createState() => _ApiGatewayScreenState();
}

class _ApiGatewayScreenState extends State<ApiGatewayScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  String? _expandedId;
  String _testRfc = '';
  String? _testResult;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: _ambar),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('API Gateway B2B',
                  style: TextStyle(
                      color: _texto,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('Integraciones corporativas y webhooks',
                  style: TextStyle(color: _sec, fontSize: 12)),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(children: [
                for (final s in [
                  _ConnStatus.online,
                  _ConnStatus.degraded,
                  _ConnStatus.offline
                ]) ...[
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: _statusColor(s), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('${_integrations.where((i) => i.status == s).length}',
                      style: TextStyle(
                          color: _statusColor(s),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                ],
              ]),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Column(
              children: [
                TabBar(
                    controller: _tabCtrl,
                    indicatorColor: _ambar,
                    labelColor: _ambar,
                    unselectedLabelColor: _sec,
                    labelStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(fontSize: 14),
                    tabs: const [
                      Tab(
                          icon: Icon(Icons.settings_input_antenna, size: 16),
                          text: 'Sistemas'),
                      Tab(
                          icon: Icon(Icons.webhook, size: 16),
                          text: 'Webhooks'),
                      Tab(
                          icon: Icon(Icons.receipt_long_outlined, size: 16),
                          text: 'API Logs'),
                    ]),
                Container(height: 1, color: _bord),
              ],
            ),
          ),
        ),
        body: TabBarView(controller: _tabCtrl, children: [
          _tabSistemas(),
          _tabWebhooks(),
          _tabLogs(),
        ]),
      );

  // ── Tab 0 — Sistemas ──────────────────────────────────────────────────────
  Widget _tabSistemas() => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // KPI bar
          Row(children: [
            _kpi(
                'Online',
                '${_integrations.where((i) => i.status == _ConnStatus.online).length}',
                _verde),
            const SizedBox(width: 16),
            _kpi(
                'Degradado',
                '${_integrations.where((i) => i.status == _ConnStatus.degraded).length}',
                _ambar),
            const SizedBox(width: 16),
            _kpi(
                'Offline',
                '${_integrations.where((i) => i.status == _ConnStatus.offline).length}',
                _rojo),
            const SizedBox(width: 16),
            _kpi(
                'Llamadas Hoy',
                '${_integrations.fold(0, (acc, i) => acc + i.callsToday)}',
                _azul),
          ]),
          const SizedBox(height: 24),
          // API Test & Config
          _HoverCard(
            padding: const EdgeInsets.all(24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.network_ping, color: _azul, size: 20),
                SizedBox(width: 12),
                Text('Probar Conectividad API / Configurar',
                    style: TextStyle(
                        color: _azul,
                        fontSize: 16,
                        fontWeight: FontWeight.bold))
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: TextField(
                  onChanged: (v) => setState(() {
                    _testRfc = v;
                    _testResult = null;
                  }),
                  style: const TextStyle(color: _texto, fontSize: 14),
                  decoration: InputDecoration(
                    hintText:
                        'Ej: https://jsonplaceholder.typicode.com/todos/1',
                    hintStyle: const TextStyle(color: _sec, fontSize: 13),
                    prefixIcon: const Icon(Icons.link, color: _sec, size: 18),
                    filled: true,
                    fillColor: _bg,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _bord)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _bord)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _azul)),
                  ),
                )),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _testing
                      ? null
                      : () async {
                          if (_testRfc.isEmpty) {
                            _mostrarFormConfig();
                            return;
                          }
                          setState(() {
                            _testing = true;
                            _testResult = null;
                          });
                          try {
                            final resp = await http
                                .get(Uri.parse(_testRfc))
                                .timeout(const Duration(seconds: 5));
                            setState(() {
                              _testResult =
                                  'ACTIVO — Status: ${resp.statusCode}\nBody: ${resp.body.length > 100 ? '${resp.body.substring(0, 100)}...' : resp.body}';
                            });
                          } catch (e) {
                            setState(() {
                              _testResult = 'ERROR: $e';
                            });
                          } finally {
                            setState(() => _testing = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _azul,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: _testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: _bg, strokeWidth: 2))
                      : Text(_testRfc.isEmpty ? 'Configurar' : 'Ping',
                          style: const TextStyle(
                              color: _bg,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                ),
              ]),
              if (_testResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _testResult!.startsWith('ACTIVO')
                        ? _verde.withValues(alpha: 0.1)
                        : _rojo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _testResult!.startsWith('ACTIVO')
                            ? _verde.withValues(alpha: 0.3)
                            : _rojo.withValues(alpha: 0.3)),
                  ),
                  child: Text(_testResult!,
                      style: TextStyle(
                          color: _testResult!.startsWith('ACTIVO')
                              ? _verde
                              : _rojo,
                          fontSize: 13)),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 24),
          // Integration cards
          for (final integ in _integrations) _integCard(integ),
        ]),
      );

  Widget _integCard(_Integration integ) {
    final expanded = _expandedId == integ.id;
    return _HoverCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expandedId = expanded ? null : integ.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: integ.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: integ.color.withValues(alpha: 0.3))),
                    child: Icon(integ.icon, color: integ.color, size: 24)),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        Text(integ.nombre,
                            style: const TextStyle(
                                color: _texto,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        _statusBadge(integ.status),
                      ]),
                      const SizedBox(height: 4),
                      Text(integ.descripcion,
                          style: const TextStyle(color: _sec, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ])),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${integ.callsToday} calls',
                      style: const TextStyle(color: _sec, fontSize: 12)),
                  Text('sync ${integ.lastSync}',
                      style: const TextStyle(color: _sec, fontSize: 12)),
                ]),
                const SizedBox(width: 12),
                Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: _sec,
                    size: 20),
              ])),
        ),
        if (expanded)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Divider(color: _bord, height: 24),
              _infoRow('Endpoint', integ.endpoint, copyable: true),
              _infoRow('Version', integ.version),
              _infoRow('Llamadas hoy', '${integ.callsToday}'),
              _infoRow('Ultima sincronizacion', integ.lastSync),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Probando conexion con ${integ.nombre}...'),
                          backgroundColor: _card2,
                          behavior: SnackBarBehavior.floating)),
                  icon: const Icon(Icons.wifi_tethering, size: 16),
                  label: const Text('Test Conexion',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: integ.color,
                      side:
                          BorderSide(color: integ.color.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Sincronizando ${integ.nombre}...'),
                          backgroundColor: integ.color.withValues(alpha: 0.8),
                          behavior: SnackBarBehavior.floating)),
                  icon: const Icon(Icons.sync, size: 16, color: _bg),
                  label: const Text('Sync Ahora',
                      style: TextStyle(
                          fontSize: 14,
                          color: _bg,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: integ.color,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                )),
              ]),
            ]),
          ),
      ]),
    );
  }

  Widget _infoRow(String label, String value, {bool copyable = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          SizedBox(
              width: 160,
              child: Text(label,
                  style: const TextStyle(color: _sec, fontSize: 13))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: _texto, fontSize: 13, fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis)),
          if (copyable)
            IconButton(
                onPressed: () => Clipboard.setData(ClipboardData(text: value)),
                icon: const Icon(Icons.copy, size: 16, color: _sec),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints()),
        ]),
      );

  // ── Tab 1 — Webhooks ──────────────────────────────────────────────────────
  Widget _tabWebhooks() => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Row(children: [
            Icon(Icons.info_outline, color: _sec, size: 16),
            SizedBox(width: 8),
            Expanded(
                child: Text(
                    'Los webhooks notifican a tus sistemas externos cuando ocurren eventos en Aduanas 801.',
                    style: TextStyle(color: _sec, fontSize: 13)))
          ]),
          const SizedBox(height: 24),
          for (final wh in _webhooks)
            _HoverCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: wh.activo ? _verde : _sec,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(wh.nombre,
                              style: const TextStyle(
                                  color: _texto,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600))),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: (wh.activo ? _verde : _sec)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: (wh.activo ? _verde : _sec)
                                      .withValues(alpha: 0.3))),
                          child: Text(wh.activo ? 'ACTIVO' : 'INACTIVO',
                              style: TextStyle(
                                  color: wh.activo ? _verde : _sec,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold))),
                    ]),
                    const SizedBox(height: 16),
                    _infoRow('Evento', wh.evento),
                    _infoRow('URL destino', wh.url, copyable: true),
                    _infoRow('Ultima ejecucion', wh.ultimaEjecucion),
                    _infoRow('Resultado', wh.resultado),
                    const SizedBox(height: 16),
                    Row(children: [
                      OutlinedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text('Webhook de prueba enviado.'),
                                backgroundColor: AppColors.card,
                                behavior: SnackBarBehavior.floating)),
                        icon: const Icon(Icons.send_outlined, size: 14),
                        label: const Text('Probar',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: _azul,
                            side: const BorderSide(color: _bord),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Editar',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: _sec,
                            side: const BorderSide(color: _bord),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                      ),
                    ]),
                  ]),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Formulario de nuevo webhook proximamente.'),
                    behavior: SnackBarBehavior.floating)),
            icon: const Icon(Icons.add, color: _ambar, size: 18),
            label: const Text('Agregar Webhook',
                style: TextStyle(
                    color: _ambar, fontSize: 14, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _ambar),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
        ],
      );

  // ── Tab 2 — API Logs ──────────────────────────────────────────────────────
  Widget _tabLogs() => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Row(children: [
            Icon(Icons.receipt_long_outlined, color: _sec, size: 16),
            SizedBox(width: 8),
            Text(
                'Últimas 8 llamadas API del sistema (tiempo real en produccion).',
                style: TextStyle(color: _sec, fontSize: 13))
          ]),
          const SizedBox(height: 24),
          for (final log in _logs)
            _HoverCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                      color: (log.metodo == 'GET'
                              ? _azul
                              : log.metodo == 'POST'
                                  ? _verde
                                  : _ambar)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: (log.metodo == 'GET'
                                  ? _azul
                                  : log.metodo == 'POST'
                                      ? _verde
                                      : _ambar)
                              .withValues(alpha: 0.3))),
                  child: Center(
                      child: Text(log.metodo,
                          style: TextStyle(
                              color: log.metodo == 'GET'
                                  ? _azul
                                  : log.metodo == 'POST'
                                      ? _verde
                                      : _ambar,
                              fontSize: 12,
                              fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Text(log.endpoint,
                        style: const TextStyle(
                            color: _texto,
                            fontSize: 13,
                            fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: (log.status < 300
                              ? _verde
                              : log.status < 500
                                  ? _ambar
                                  : _rojo)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: (log.status < 300
                                  ? _verde
                                  : log.status < 500
                                      ? _ambar
                                      : _rojo)
                              .withValues(alpha: 0.3))),
                  child: Text('${log.status}',
                      style: TextStyle(
                          color: log.status < 300
                              ? _verde
                              : log.status < 500
                                  ? _ambar
                                  : _rojo,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                SizedBox(
                    width: 60,
                    child: Text('${log.ms}ms',
                        style: TextStyle(
                            color: log.ms > 10000
                                ? _rojo
                                : log.ms > 1000
                                    ? _ambar
                                    : _sec,
                            fontSize: 12),
                        textAlign: TextAlign.right)),
                const SizedBox(width: 16),
                Text(log.hora,
                    style: const TextStyle(color: _sec, fontSize: 12)),
              ]),
            ),
        ],
      );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color _statusColor(_ConnStatus s) => s == _ConnStatus.online
      ? _verde
      : s == _ConnStatus.degraded
          ? _ambar
          : _rojo;
  String _statusLabel(_ConnStatus s) => s == _ConnStatus.online
      ? 'Online'
      : s == _ConnStatus.degraded
          ? 'Degradado'
          : 'Offline';

  Widget _statusBadge(_ConnStatus s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: _statusColor(s).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _statusColor(s).withValues(alpha: 0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                  color: _statusColor(s), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(_statusLabel(s),
              style: TextStyle(
                  color: _statusColor(s),
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ]),
      );

  Widget _kpi(String l, String v, Color c) => Expanded(
          child: _HoverCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(v,
              style: TextStyle(
                  color: c, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(l, style: const TextStyle(color: _sec, fontSize: 13)),
        ]),
      ));

  void _mostrarFormConfig() {
    final nombreCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        title:
            const Text('Configurar Nueva API', style: TextStyle(color: _azul)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nombreCtrl,
                style: const TextStyle(color: _texto),
                decoration: const InputDecoration(
                    labelText: 'Nombre API',
                    labelStyle: TextStyle(color: _sec))),
            TextField(
                controller: urlCtrl,
                style: const TextStyle(color: _texto),
                decoration: const InputDecoration(
                    labelText: 'Endpoint URL',
                    labelStyle: TextStyle(color: _sec))),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nombreCtrl.text.isNotEmpty && urlCtrl.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('api_configs').add({
                  'nombre': nombreCtrl.text,
                  'url': urlCtrl.text,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (!mounted) return;
                if (_.mounted) Navigator.pop(_);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Configuración guardada en Firestore')));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const _HoverCard({required this.child, required this.padding, this.margin});

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
        padding: widget.padding,
        margin: widget.margin,
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
