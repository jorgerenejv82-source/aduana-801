import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Design Tokens ─────────────────────────────────────────────────────────────
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _verde = AppColors.green;
const Color _azul = AppColors.blue;

// ── Screen ────────────────────────────────────────────────────────────────────
class BovedaVucemScreen extends StatefulWidget {
  const BovedaVucemScreen({super.key});
  @override
  State<BovedaVucemScreen> createState() => _BovedaVucemScreenState();
}

class _BovedaVucemScreenState extends State<BovedaVucemScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // ── e.firma state ─────────────────────────────────────────────────────────
  final _rfcCtrl = TextEditingController(text: 'AAA801101AAA');
  final _razonCtrl =
      TextEditingController(text: 'Agencia Aduanal 801 SA de CV');
  final DateTime _vencimientoEfirma = DateTime(2026, 11, 15);
  bool _claveLoaded = false;
  bool _cerLoaded = false;

  // ── VUCEM credentials ─────────────────────────────────────────────────────
  final _vucemUserCtrl = TextEditingController();
  final _vucemPassCtrl = TextEditingController();
  bool _showPass = false;
  bool _vucemConectado = false;
  bool _conectando = false;

  // ── Documentos ────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _docs = [
    {
      'nombre': 'e.firma (FIEL) — Certificado',
      'tipo': '.cer',
      'vigente': true,
      'vence': '15/11/2026',
      'icon': Icons.security
    },
    {
      'nombre': 'e.firma (FIEL) — Clave Privada',
      'tipo': '.key',
      'vigente': true,
      'vence': '15/11/2026',
      'icon': Icons.vpn_key_outlined
    },
    {
      'nombre': 'e.Firma SAT Renovación',
      'tipo': '.pdf',
      'vigente': true,
      'vence': '—',
      'icon': Icons.picture_as_pdf_outlined
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
    _rfcCtrl.dispose();
    _razonCtrl.dispose();
    _vucemUserCtrl.dispose();
    _vucemPassCtrl.dispose();
    super.dispose();
  }

  int get _diasRestantes =>
      _vencimientoEfirma.difference(DateTime.now()).inDays;
  Color get _alertColor => _diasRestantes < 30
      ? _rojo
      : _diasRestantes < 90
          ? _ambar
          : _verde;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          leading: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back, color: _ambar)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: _ambar.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _ambar.withValues(alpha: 0.3))),
                child: const Icon(Icons.lock_outlined, color: _ambar, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Bóveda VUCEM (e.firma)',
                  style: TextStyle(
                      color: _ambar,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _alertColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: _alertColor.withValues(alpha: 0.3))),
                child: Text('e.firma: $_diasRestantes días',
                    style: TextStyle(
                        color: _alertColor,
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
                const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            tabs: const [
              Tab(icon: Icon(Icons.security, size: 20), text: 'e.firma'),
              Tab(icon: Icon(Icons.cloud_outlined, size: 20), text: 'VUCEM'),
              Tab(
                  icon: Icon(Icons.folder_outlined, size: 20),
                  text: 'Documentos'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _tabEfirma(),
            _tabVucem(),
            _tabDocumentos(),
          ],
        ),
      );

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1 — e.firma
  // ══════════════════════════════════════════════════════════════════════════
  Widget _tabEfirma() => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _alertColor.withValues(alpha: 0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: _alertColor.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                        color: _alertColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _alertColor.withValues(alpha: 0.3))),
                    child: Icon(Icons.security, color: _alertColor, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            _diasRestantes < 30
                                ? 'e.firma PRÓXIMA A VENCER'
                                : 'e.firma VIGENTE',
                            style: TextStyle(
                                color: _alertColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                            'Vence: ${_vencimientoEfirma.day.toString().padLeft(2, '0')}/${_vencimientoEfirma.month.toString().padLeft(2, '0')}/${_vencimientoEfirma.year}   |   $_diasRestantes días restantes',
                            style: const TextStyle(color: _sec, fontSize: 14)),
                      ],
                    ),
                  ),
                  if (_diasRestantes < 90)
                    ElevatedButton(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                              content: Text(
                                  'Abriendo portal SAT para renovación...'),
                              backgroundColor: _azul)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _ambar,
                        foregroundColor: _bg,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Renovar',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _seccion('Datos del Contribuyente',
                          Icons.business_outlined, _azul, [
                        _fiShow('RFC', _rfcCtrl.text),
                        const SizedBox(height: 16),
                        _fiShow('Razón Social', _razonCtrl.text),
                      ]),
                      const SizedBox(height: 24),
                      _seccion('Alertas de Vencimiento',
                          Icons.notifications_outlined, _ambar, [
                        _alertRow('90 días antes del vencimiento', true),
                        _alertRow('30 días antes del vencimiento', true),
                        _alertRow('7 días antes del vencimiento',
                            _diasRestantes <= 90),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _seccion('Archivos e.firma',
                      Icons.folder_special_outlined, _ambar, [
                    _archivoRow('.cer — Certificado de Sello Digital',
                        _cerLoaded, () => setState(() => _cerLoaded = true)),
                    const SizedBox(height: 16),
                    const Divider(color: _bord),
                    const SizedBox(height: 16),
                    _archivoRow('.key — Clave Privada', _claveLoaded,
                        () => setState(() => _claveLoaded = true)),
                    const SizedBox(height: 24),
                    if (_cerLoaded && _claveLoaded)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: _verde.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _verde.withValues(alpha: 0.3))),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: _verde, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                                child: Text(
                                    'e.firma cargada y lista para firmar documentos.',
                                    style: TextStyle(
                                        color: _verde, fontSize: 14))),
                          ],
                        ),
                      ),
                  ]),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _archivoRow(String label, bool loaded, VoidCallback onLoad) => Row(
        children: [
          Icon(
              loaded
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              color: loaded ? _verde : _sec,
              size: 24),
          const SizedBox(width: 16),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: loaded ? _verde : _texto,
                      fontSize: 14,
                      fontWeight: FontWeight.bold))),
          OutlinedButton.icon(
            onPressed: onLoad,
            icon: Icon(loaded ? Icons.refresh : Icons.upload_file,
                size: 16, color: loaded ? _sec : _ambar),
            label: Text(loaded ? 'Cambiar' : 'Cargar',
                style: TextStyle(
                    color: loaded ? _sec : _ambar,
                    fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: loaded
                      ? _sec.withValues(alpha: 0.5)
                      : _ambar.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      );

  Widget _alertRow(String l, bool activa) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: activa ? _verde : _bord, shape: BoxShape.circle)),
            const SizedBox(width: 16),
            Expanded(
                child: Text(l,
                    style: TextStyle(
                        color: activa ? _texto : _sec, fontSize: 14))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: (activa ? _verde : _sec).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(activa ? 'Activa' : 'Inactiva',
                  style: TextStyle(
                      color: activa ? _verde : _sec,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2 — VUCEM
  // ══════════════════════════════════════════════════════════════════════════
  Widget _tabVucem() => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color:
                        _vucemConectado ? _verde.withValues(alpha: 0.5) : _bord,
                    width: _vucemConectado ? 2 : 1),
                boxShadow: [
                  if (_vucemConectado)
                    BoxShadow(
                        color: _verde.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color:
                          _vucemConectado ? _verde.withValues(alpha: 0.1) : _bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _vucemConectado
                              ? _verde.withValues(alpha: 0.3)
                              : _bord),
                    ),
                    child: Icon(Icons.cloud_outlined,
                        color: _vucemConectado ? _verde : _sec, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            _vucemConectado
                                ? 'VUCEM Conectado'
                                : 'VUCEM Desconectado',
                            style: TextStyle(
                                color: _vucemConectado ? _verde : _rojo,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                            _vucemConectado
                                ? 'Sesión activa · Ventanilla Única'
                                : 'Ingresa tus credenciales para conectar',
                            style: const TextStyle(color: _sec, fontSize: 14)),
                      ],
                    ),
                  ),
                  if (_vucemConectado)
                    TextButton.icon(
                      onPressed: () => setState(() => _vucemConectado = false),
                      icon: const Icon(Icons.logout, size: 16, color: _sec),
                      label: const Text('Salir',
                          style: TextStyle(
                              color: _sec, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!_vucemConectado) ...[
              _seccion('Credenciales VUCEM', Icons.cloud_outlined, _azul, [
                TextField(
                    controller: _vucemUserCtrl,
                    style: const TextStyle(color: _texto, fontSize: 14),
                    decoration: _dec('Usuario VUCEM (RFC o correo)',
                        prefixIcon: Icons.person_outline)),
                const SizedBox(height: 16),
                TextField(
                    controller: _vucemPassCtrl,
                    obscureText: !_showPass,
                    style: const TextStyle(color: _texto, fontSize: 14),
                    decoration: _dec('Contraseña VUCEM',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                            icon: Icon(
                                _showPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: _ambar,
                                size: 20),
                            onPressed: () =>
                                setState(() => _showPass = !_showPass)))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _conectando
                        ? null
                        : () async {
                            if (_vucemUserCtrl.text.isEmpty ||
                                _vucemPassCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Llena los campos'),
                                      backgroundColor: _rojo));
                              return;
                            }
                            setState(() => _conectando = true);
                            try {
                              final uid =
                                  FirebaseAuth.instance.currentUser?.uid ??
                                      'unknown';
                              await FirebaseFirestore.instance
                                  .collection('vucem_docs')
                                  .add({
                                'uid': uid,
                                'usuario': _vucemUserCtrl.text,
                                'password': _vucemPassCtrl.text,
                                'created_at': FieldValue.serverTimestamp(),
                                'updated_at': FieldValue.serverTimestamp(),
                              });
                              if (!mounted) return;
                              setState(() {
                                _conectando = false;
                                _vucemConectado = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Credenciales VUCEM guardadas en Firestore'),
                                      backgroundColor: _verde));
                            } catch (e) {
                              if (!mounted) return;
                              setState(() => _conectando = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: _rojo));
                            }
                          },
                    icon: _conectando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: _bg, strokeWidth: 2))
                        : const Icon(Icons.cloud_upload_outlined,
                            size: 20, color: _bg),
                    label: Text(
                        _conectando ? 'Conectando...' : 'Conectar a VUCEM',
                        style: const TextStyle(
                            color: _bg,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _ambar,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                ),
              ]),
            ] else ...[
              _seccion('Acciones VUCEM Disponibles', Icons.cloud_done_outlined,
                  _verde, [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    ('Consultar Pedimentos', Icons.search, '/pedimentos'),
                    (
                      'Generar e.Documento',
                      Icons.create_new_folder_outlined,
                      '/edoc'
                    ),
                    ('Validar COVE', Icons.verified_outlined, '/cove'),
                    (
                      'Portal Ventanilla Única',
                      Icons.open_in_browser,
                      '/portal'
                    ),
                  ]
                      .map((item) => MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                  color: _bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _bord)),
                              child: Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: _verde.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Icon(item.$2,
                                          color: _verde, size: 20)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: Text(item.$1,
                                          style: const TextStyle(
                                              color: _texto,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold))),
                                  const Icon(Icons.chevron_right,
                                      color: _sec, size: 20),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ]),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: _ambar.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _ambar.withValues(alpha: 0.3))),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: _ambar, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                      child: Text(
                          'VUCEM (Ventanilla Única de Comercio Exterior Mexicano) es el portal oficial del SAT/SE para operaciones de comercio exterior. Tus credenciales se almacenan de forma segura y nunca se envían a terceros.',
                          style: TextStyle(
                              color: _ambar, fontSize: 13, height: 1.5))),
                ],
              ),
            ),
          ],
        ),
      );

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 3 — Documentos
  // ══════════════════════════════════════════════════════════════════════════
  Widget _tabDocumentos() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Expanded(
                    child: Text('Documentos Digitales',
                        style: TextStyle(
                            color: _texto,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _docs.add({
                          'nombre': 'Documento ${_docs.length + 1}',
                          'tipo': '.pdf',
                          'vigente': true,
                          'vence': '—',
                          'icon': Icons.picture_as_pdf_outlined
                        }));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Documento agregado.'),
                        backgroundColor: _verde));
                  },
                  icon: const Icon(Icons.upload_file, size: 16, color: _bg),
                  label: const Text('Agregar',
                      style:
                          TextStyle(color: _bg, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _ambar,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _docs.length,
              itemBuilder: (_, i) {
                final d = _docs[i];
                return _DocumentRow(d: d);
              },
            ),
          ),
        ],
      );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _seccion(
          String titulo, IconData icon, Color c, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bord)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: c, size: 20)),
                const SizedBox(width: 12),
                Text(titulo,
                    style: TextStyle(
                        color: c, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      );

  Widget _fiShow(String label, String val) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _bord)),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: _sec, fontSize: 14)),
            const Spacer(),
            Text(val,
                style: const TextStyle(
                    color: _texto,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace')),
          ],
        ),
      );

  InputDecoration _dec(String hint,
          {IconData? prefixIcon, Widget? suffixIcon}) =>
      InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: _sec),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: _ambar, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _bg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _bord)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _bord)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _ambar)),
      );
}

class _DocumentRow extends StatefulWidget {
  final Map<String, dynamic> d;
  const _DocumentRow({required this.d});

  @override
  State<_DocumentRow> createState() => _DocumentRowState();
}

class _DocumentRowState extends State<_DocumentRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hover ? const Color(0xFF14243D) : _card,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: _hover ? _ambar.withValues(alpha: 0.5) : _bord),
          boxShadow: [
            if (_hover)
              BoxShadow(
                  color: _ambar.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: _azul.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _azul.withValues(alpha: 0.3))),
                child:
                    Icon(widget.d['icon'] as IconData, color: _azul, size: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.d['nombre'] as String,
                      style: const TextStyle(
                          color: _texto,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${widget.d['tipo']}  ·  Vence: ${widget.d['vence']}',
                      style: const TextStyle(color: _sec, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _verde.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _verde.withValues(alpha: 0.3))),
              child: const Text('Vigente',
                  style: TextStyle(
                      color: _verde,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.copy, size: 20, color: _sec),
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: widget.d['nombre'] as String));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Copiado.'), backgroundColor: _verde));
              },
            ),
          ],
        ),
      ),
    );
  }
}
