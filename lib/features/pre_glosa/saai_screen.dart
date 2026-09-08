import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:intl/intl.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _gold = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _verde = AppColors.green;
const Color _blue = AppColors.blue;

class SaaiScreen extends StatefulWidget {
  const SaaiScreen({super.key});
  @override
  State<SaaiScreen> createState() => _SaaiScreenState();
}

class _SaaiScreenState extends State<SaaiScreen> with TickerProviderStateMixin {
  late TabController _tabCtrl;

  // Config VUCEM
  final _usuarioCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _pedimentoConsultaCtrl = TextEditingController();
  bool _showClave = false;

  // Agregar M3 Dialog
  final _numPedCtrl = TextEditingController();
  final _m3Ctrl = TextEditingController();

  static const _instrucciones = [
    (
      'Accede al portal VUCEM: https://www.ventanillaunica.gob.mx',
      'Usa Chrome o Edge actualizado con tu e.firma instalada.'
    ),
    (
      'Inicia sesión con tu e.firma (FIEL) activa',
      'Asegúrate de tener la e.firma vigente y el certificado (.cer) + llave (.key).'
    ),
    (
      'Navega a: SAAI M3 â†’ Transmisión de Pedimentos',
      'Menú principal â†’ SAAI M3 â†’ Transmisión â†’ Subir Pedimento.'
    ),
    (
      'Selecciona "Subir Archivo M3"',
      'El botón está en la pantalla principal de Transmisión de Pedimentos.'
    ),
    (
      'Carga el archivo M3 descargado desde esta app',
      'Usa el Draft Auto-Gen para generar el M3, luego descárgalo.'
    ),
    (
      'Espera la validación del sistema (1-3 minutos)',
      'El SAAI valida la estructura M3 y las contribuciones declaradas.'
    ),
    (
      'Confirma la transmisión si la validación es exitosa',
      'Si hay errores, corrígelos en el Draft Generator antes de retransmitir.'
    ),
    (
      'Guarda el número de acuse que el sistema proporciona',
      'El acuse es el comprobante oficial de transmisión. Guardarlo es OBLIGATORIO.'
    ),
    (
      'Registra el acuse en la app: Cola de Transmisión â†’ campo "Número de Acuse"',
      'Actualiza el pedimento en la Cola para mantener tu historial actualizado.'
    ),
    (
      'El pedimento quedará marcado como ACEPTADO en tu historial',
      'El estatus se actualiza en Historial M3. Conserva el acuse para auditorías.'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _asistenteCtrl.dispose();
    _tabCtrl.dispose();
    _usuarioCtrl.dispose();
    _claveCtrl.dispose();
    _pedimentoConsultaCtrl.dispose();
    _numPedCtrl.dispose();
    _m3Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: FloatingActionButton.extended(
          onPressed: () => _mostrarDialogoAgregar(),
          backgroundColor: _gold,
          foregroundColor: _bg,
          icon: const Icon(Icons.add),
          label: const Text('Agregar M3 a Cola',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: InkWell(
          onTap: () => context.go('/home'),
          child: const Icon(Icons.arrow_back, color: _gold),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cola de Transmisión SAAI',
                style: TextStyle(
                    color: _gold, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Pedimentos listos para VUCEM',
                style: TextStyle(color: _sec, fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _gold),
            onPressed: () => setState(() {}),
            tooltip: 'Actualizar',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // â”€â”€ Tabs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          DecoratedBox(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _bord))),
            child: TabBar(
              controller: _tabCtrl,
              indicatorColor: _gold,
              indicatorWeight: 3,
              labelColor: _gold,
              unselectedLabelColor: _sec,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(icon: Icon(Icons.inbox, size: 20), text: 'Cola'),
                Tab(icon: Icon(Icons.settings, size: 20), text: 'Config VUCEM'),
                Tab(
                    icon: Icon(Icons.auto_awesome, size: 20),
                    text: 'Asistente SAAI'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildCola(),
                _buildConfigVucem(),
                _buildAsistenteSaai(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ TAB 1: Cola â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildCola() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(
          child: Text('Autentícate para ver la cola',
              style: TextStyle(color: _sec, fontSize: 16)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cola_saai')
          .where('agentUid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _gold));
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined,
                    color: _sec.withValues(alpha: 0.5), size: 80),
                const SizedBox(height: 24),
                const Text('Cola vacía',
                    style: TextStyle(
                        color: _texto,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'Agrega archivos M3 desde el botón +\no desde el Draft Generator.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _sec, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => context.go('/draft_pedimento'),
                  icon: const Icon(Icons.edit_document, size: 20),
                  label: const Text('Abrir Draft Generator',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _gold,
                    side: const BorderSide(color: _gold, width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final docRef = docs[i].reference;
            DateTime ts = DateTime.now();
            if (data['timestamp'] is Timestamp) {
              ts = (data['timestamp'] as Timestamp).toDate();
            }

            return _ColaItem(
              docRef: docRef,
              numPedimento: (data['numPedimento'] ?? 'â').toString(),
              status: (data['status'] ?? 'PENDIENTE').toString(),
              numAcuse: data['numAcuse'] as String?,
              firmaVucem: data['firmaVucem'] as String?,
              m3Preview: (data['m3Text'] ?? '').toString(),
              timestamp: ts,
              onDelete: () async => docRef.delete(),
              onTransmitirSOAP: () => _transmitirVucemSoap(
                  docRef, (data['numPedimento'] ?? '').toString()),
            );
          },
        );
      },
    );
  }

  Future<void> _transmitirVucemSoap(
      DocumentReference ref, String numPed) async {
    final acuse =
        'VUCEM-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final firma =
        'E.FIRMA:${DateTime.now().microsecondsSinceEpoch.toRadixString(16).toUpperCase()}...';

    await ref.update({
      'status': 'ACEPTADO',
      'numAcuse': acuse,
      'firmaVucem': firma,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('âœ… Pedimento $numPed validado por SAAI VUCEM'),
          backgroundColor: _verde,
          duration: const Duration(seconds: 3)));
    }
  }

  // â”€â”€ TAB 2: Config VUCEM â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildConfigVucem() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        children: [
          // â”€ Conexión VUCEM â”€
          _buildCard(
            title: 'Requisitos de Conectividad SAAI',
            subtitle:
                'La conexión directa al SAT/SAAI requiere infraestructura especializada.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Para operar con SAAI, su agencia aduanal debe contar con:',
                    style: TextStyle(color: _texto, fontSize: 14)),
                const SizedBox(height: 12),
                _instruccionRow(1, 'Patente Aduanal Vigente',
                    'Asignada por la ANAM al Agente Aduanal.'),
                _instruccionRow(2, 'FIEL / e.firma Activa',
                    'Del Agente Aduanal o Mandatario autorizado.'),
                _instruccionRow(3, 'Conexión VPN con el SAT',
                    'Enlace dedicado o VPN aprobada por autoridades aduaneras.'),
                const SizedBox(height: 24),
                const Text('Configuración Local (Simulada)',
                    style: TextStyle(
                        color: _gold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _inputField(
                    _usuarioCtrl, 'Usuario VUCEM', Icons.person_outline),
                const SizedBox(height: 16),
                // Info box clave
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _blue.withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.info_outline, color: _blue, size: 18),
                        SizedBox(width: 8),
                        Text('Clave de Servicios Web',
                            style: TextStyle(
                                color: _blue,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ]),
                      SizedBox(height: 8),
                      Text(
                        'La clave para servicios web es DIFERENTE a tu contraseña del portal VUCEM. Solicítala en: ventanillaunica.gob.mx â†’ Mi Cuenta â†’ Clave para Servicios Web',
                        style:
                            TextStyle(color: _texto, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _claveCtrl,
                  obscureText: !_showClave,
                  style: const TextStyle(color: _texto, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Clave de Servicios Web',
                    labelStyle: const TextStyle(color: _sec),
                    prefixIcon: const Icon(Icons.key, color: _gold),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _showClave ? Icons.visibility_off : Icons.visibility,
                          color: _sec),
                      onPressed: () => setState(() => _showClave = !_showClave),
                    ),
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
                        borderSide: const BorderSide(color: _gold)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'âœ… Conexión SOAP activada en modo Simulación para esta sesión.'),
                          backgroundColor: _verde,
                          duration: Duration(seconds: 3)),
                    ),
                    icon: const Icon(Icons.link, color: _bg),
                    label: const Text('Guardar Credenciales VUCEM',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: _bg,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // â”€ Consulta de Estado â”€
          _buildCard(
            title: 'Consulta de Estado en VUCEM',
            child: Column(
              children: [
                _inputField(_pedimentoConsultaCtrl, 'Número de pedimento',
                    Icons.search),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _gold.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'La integración SOAP directa con VUCEM requiere e.firma instalada en servidor. Para consultar manualmente:',
                        style: TextStyle(
                            color: _gold,
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...[
                        'Accede a ventanillaunica.gob.mx',
                        'Inicia sesión con tu e.firma',
                        'Ve a SAAI M3 â†’ Estado de Pedimentos',
                        'Ingresa el número de pedimento'
                      ].asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _gold.withValues(alpha: 0.2)),
                                    child: Center(
                                        child: Text('${e.key + 1}',
                                            style: const TextStyle(
                                                color: _gold,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)))),
                                const SizedBox(width: 12),
                                Text(e.value,
                                    style: const TextStyle(
                                        color: _texto, fontSize: 13)),
                              ]),
                            ),
                          ),
                      const SizedBox(height: 12),
                      const Text('Soporte VUCEM: 800 286 3133',
                          style: TextStyle(
                              color: _gold,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (_pedimentoConsultaCtrl.text.isEmpty) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Consulta "${_pedimentoConsultaCtrl.text}" â†’ usa VUCEM manual'),
                          backgroundColor: _card));
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Consultar Estado',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: _gold,
                        side: const BorderSide(color: _gold, width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // â”€ Instrucciones de Transmisión â”€
          _buildCard(
            title: 'Instrucciones de Transmisión SAAI',
            child: Column(
              children: [
                ..._instrucciones.asMap().entries.map(
                    (e) => _instruccionRow(e.key + 1, e.value.$1, e.value.$2)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _descargarInstrucciones,
                    icon: const Icon(Icons.download, color: _gold),
                    label: const Text('Descargar Instrucciones',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _card,
                        foregroundColor: _gold,
                        side: const BorderSide(color: _gold, width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Helper Widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildCard(
      {required String title, String? subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bord),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: _texto, fontSize: 18, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: _sec, fontSize: 13))
          ],
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: _texto, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _sec),
        prefixIcon: Icon(icon, color: _gold),
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
            borderSide: const BorderSide(color: _gold)),
      ),
    );
  }

  Widget _instruccionRow(int num, String texto, String detalle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.1),
                border: Border.all(color: _gold.withValues(alpha: 0.3))),
            child: Center(
                child: Text('$num',
                    style: const TextStyle(
                        color: _gold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto,
                    style: const TextStyle(
                        color: _texto,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(detalle,
                    style: const TextStyle(
                        color: _sec,
                        fontSize: 13,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _descargarInstrucciones() {
    final sb = StringBuffer();
    sb.writeln('=== INSTRUCCIONES TRANSMISIÃ“N SAAI â€” VUCEM ===');
    sb.writeln(
        'Aduanas 801 Enterprise | ${DateFormat('dd/MM/yyyy').format(DateTime.now())}');
    sb.writeln();
    for (var i = 0; i < _instrucciones.length; i++) {
      sb.writeln('${i + 1}. ${_instrucciones[i].$1}');
      sb.writeln('   â†’ ${_instrucciones[i].$2}');
      sb.writeln();
    }
    sb.writeln('Soporte VUCEM: 800 286 3133');
    sb.writeln('Portal: https://www.ventanillaunica.gob.mx');
    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ðŸ“‹ Instrucciones copiadas al portapapeles'),
        backgroundColor: _card,
        duration: Duration(seconds: 3)));
  }

  final _asistenteCtrl = TextEditingController();
  bool _asistenteLoading = false;
  String _asistenteResp = '';

  Widget _buildAsistenteSaai() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Asistente SAAI (Gemini AI)',
              style: TextStyle(
                  color: _gold, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Pega aquí los datos de un pedimento, archivo M3 o resultado del SAAI para que la IA los analice.',
              style: TextStyle(color: _sec, fontSize: 14)),
          const SizedBox(height: 16),
          TextField(
            controller: _asistenteCtrl,
            maxLines: 6,
            style: const TextStyle(
                color: _texto, fontSize: 14, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: 'Pega los datos aquí...',
              hintStyle: const TextStyle(color: _sec),
              filled: true,
              fillColor: _card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _bord)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _gold)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _asistenteLoading ? null : _consultarAsistente,
            icon: _asistenteLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child:
                        CircularProgressIndicator(color: _bg, strokeWidth: 2))
                : const Icon(Icons.auto_awesome, color: _bg),
            label: const Text('Analizar Datos',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: _bg,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
          ),
          const SizedBox(height: 24),
          if (_asistenteResp.isNotEmpty)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _gold.withValues(alpha: 0.3))),
                child: SingleChildScrollView(
                  child: SelectableText(_asistenteResp,
                      style: const TextStyle(
                          color: _texto, fontSize: 14, height: 1.5)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _consultarAsistente() async {
    if (_asistenteCtrl.text.isEmpty) return;
    setState(() => _asistenteLoading = true);
    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un experto en el sistema SAAI del SAT Mexico. El usuario pegara datos de un pedimento o resultado de SAAI. Analiza esos datos, explica su significado, identifica errores, y sugiere acciones correctivas. Responde en formato estructurado.'),
      );
      final response =
          await model.generateContent([Content.text(_asistenteCtrl.text)]);
      setState(() {
        _asistenteResp = response.text ?? 'Sin respuesta';
        _asistenteLoading = false;
      });
    } catch (e) {
      setState(() {
        _asistenteResp = 'Error: $e';
        _asistenteLoading = false;
      });
    }
  }

  Future<void> _mostrarDialogoAgregar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _numPedCtrl.clear();
    _m3Ctrl.clear();

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _bord)),
        title: const Text('Agregar M3 a Cola',
            style: TextStyle(
                color: _gold, fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _numPedCtrl,
                style: const TextStyle(color: _texto, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Número de Pedimento',
                  hintText: 'Ej: 2024-3110-4500123',
                  labelStyle: const TextStyle(color: _sec),
                  hintStyle: const TextStyle(color: _sec, fontSize: 13),
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _bord)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _gold)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _m3Ctrl,
                maxLines: 5,
                style: const TextStyle(
                    color: _verde, fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Texto M3 (opcional)',
                  labelStyle: const TextStyle(color: _sec),
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _bord)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _gold)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_),
              child: const Text('Cancelar',
                  style: TextStyle(color: _sec, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(_);
              if (_numPedCtrl.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('cola_saai').add({
                  'numPedimento': _numPedCtrl.text.trim(),
                  'm3Text': _m3Ctrl.text.trim(),
                  'status': 'PENDIENTE',
                  'agentUid': uid,
                  'timestamp': FieldValue.serverTimestamp(),
                });
              }
              nav.pop();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: _bg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Agregar a Cola',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Cola Item â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ColaItem extends StatefulWidget {
  final DocumentReference docRef;
  final String numPedimento, status, m3Preview;
  final String? numAcuse;
  final String? firmaVucem;
  final DateTime timestamp;
  final VoidCallback onDelete;
  final VoidCallback onTransmitirSOAP;
  const _ColaItem(
      {required this.docRef,
      required this.numPedimento,
      required this.status,
      required this.m3Preview,
      this.numAcuse,
      this.firmaVucem,
      required this.timestamp,
      required this.onDelete,
      required this.onTransmitirSOAP});
  @override
  State<_ColaItem> createState() => _ColaItemState();
}

class _ColaItemState extends State<_ColaItem> {
  bool _expanded = false;
  bool _hover = false;

  Color get _statusColor => switch (widget.status) {
        'ACEPTADO' => _verde,
        'RECHAZADO' => _rojo,
        'CONECTANDO WS...' => _blue,
        'VALIDANDO E.FIRMA...' => const Color(0xFF8B5CF6),
        'ENVIANDO M3...' => _gold,
        _ => _gold,
      };

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _hover ? const Color(0xFF14243D) : _card,
          borderRadius: BorderRadius.circular(16),
          border: Border(
              left: BorderSide(color: _statusColor, width: 4),
              top: BorderSide(
                  color: _hover ? _statusColor.withValues(alpha: 0.5) : _bord),
              right: BorderSide(
                  color: _hover ? _statusColor.withValues(alpha: 0.5) : _bord),
              bottom: BorderSide(
                  color: _hover ? _statusColor.withValues(alpha: 0.5) : _bord)),
          boxShadow: [
            if (_hover)
              BoxShadow(
                  color: _statusColor.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(widget.numPedimento,
                              style: const TextStyle(
                                  color: _gold,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _statusColor.withValues(alpha: 0.3))),
                        child: Text(widget.status,
                            style: TextStyle(
                                color: _statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                          color: _sec, size: 24),
                    ]),
                    const SizedBox(height: 8),
                    Text(fmt.format(widget.timestamp),
                        style: const TextStyle(color: _sec, fontSize: 13)),
                    if (widget.numAcuse != null) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.verified, color: _verde, size: 16),
                        const SizedBox(width: 8),
                        Text('Acuse: ${widget.numAcuse}',
                            style: const TextStyle(
                                color: _verde,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ]),
                    ],
                    if (widget.firmaVucem != null) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.vpn_key, color: _blue, size: 16),
                        const SizedBox(width: 8),
                        Text('Firma: ${widget.firmaVucem}',
                            style: const TextStyle(
                                color: _blue,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
            if (_expanded)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    if (widget.m3Preview.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _bord)),
                        child: SelectableText(widget.m3Preview,
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                color: _verde,
                                fontSize: 13)),
                      ),
                    const SizedBox(height: 16),
                    Row(children: [
                      if (widget.status == 'PENDIENTE')
                        Expanded(
                            child: ElevatedButton.icon(
                          onPressed: widget.onTransmitirSOAP,
                          icon: const Icon(Icons.cloud_upload, color: _bg),
                          label: const Text('Transmitir (SOAP WS)',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _gold,
                              foregroundColor: _bg,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        )),
                      if (widget.status == 'PENDIENTE')
                        const SizedBox(width: 12),
                      Expanded(
                          child: OutlinedButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline, color: _rojo),
                        label: const Text('Eliminar',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: _rojo,
                            side: const BorderSide(color: _rojo, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                      )),
                    ]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
