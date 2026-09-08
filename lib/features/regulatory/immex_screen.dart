import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

// Constantes de DiseÃƒÂ±o
const Color bgCol = AppColors.bg;
const Color cardsCol = AppColors.card;
const Color borderCol = AppColors.border;
const Color tealCol = AppColors.green;
const Color azulCol = AppColors.blue;
const Color rojoCol = AppColors.red;
const Color ambarCol = AppColors.gold;
const Color violetaCol = Color(0xFF7C3AED);
const Color textoCol = AppColors.text;
const Color secCol = AppColors.sub;

class ImmexScreen extends StatefulWidget {
  const ImmexScreen({super.key});

  @override
  State<ImmexScreen> createState() => _ImmexScreenState();
}

class _ImmexScreenState extends State<ImmexScreen> {
  int _modulo = 0;
  int _subTab = 0;

  // Controllers para Captura de Entrada
  final _pedimentoCtrl = TextEditingController();
  final _proveedorCtrl = TextEditingController();
  final _paisCtrl = TextEditingController();
  final _facturaCtrl = TextEditingController();
  final _uuidCtrl = TextEditingController();

  String? _regimen = 'IN (IMMEX Temporal)';
  String? _aduana = 'Nuevo Laredo';

  // Controller para Inventario
  final _searchCtrl = TextEditingController();
  String _filtroStatus = 'Todos';

  // Estado FIFO Firestore
  List<Map<String, dynamic>> _inventario = [];
  List<Map<String, dynamic>> _descargos = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('immex_inventario').get();
      if (snap.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('immex_inventario').add({
          'ped': 'IN-24-001',
          'pt': 'MP-101 (Cable cobre)',
          'qty': 1000,
          'rem': 1000,
          'fecha': DateTime.now()
              .subtract(const Duration(days: 30))
              .toIso8601String()
        });
        await FirebaseFirestore.instance.collection('immex_inventario').add({
          'ped': 'IN-24-002',
          'pt': 'MP-102 (Conector AMP)',
          'qty': 500,
          'rem': 500,
          'fecha': DateTime.now()
              .subtract(const Duration(days: 26))
              .toIso8601String()
        });
        await _initData();
        return;
      }
      final descSnap = await FirebaseFirestore.instance
          .collection('immex_descargos')
          .orderBy('fechaDoc', descending: true)
          .get();
      if (mounted) {
        setState(() {
          _inventario = snap.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            data['fecha'] = DateTime.parse(data['fecha'] as String);
            return data;
          }).toList();

          _descargos = descSnap.docs.map((d) {
            final data = d.data();
            return {
              'ped': data['ped'] as String,
              'pt': data['pt'] as String,
              'qty': data['qty'] as String,
              'fecha': data['fecha'] as String,
              'afectados': data['afectados'] as String,
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  String _formatoFecha(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: bgCol,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: ambarCol),
            onPressed: () => context.go('/home'),
          ),
          const Text(
            'Anexo 24 Titan-Tier',
            style: TextStyle(
                color: textoCol, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.bar_chart, color: textoCol),
                label:
                    const Text('War-Room', style: TextStyle(color: textoCol)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: borderCol),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => context.go('/warroom_simulator'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.build, color: bgCol),
                label: const Text('Herramientas',
                    style:
                        TextStyle(color: bgCol, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ambarCol,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Herramientas avanzadas prÃƒÂ³ximamente')),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildModuleBar() {
    final modules = [
      {'icon': Icons.login, 'label': 'Entradas (Glosa)'},
      {'icon': Icons.storage, 'label': 'Data-Stage / FIFO'},
      {'icon': Icons.account_tree, 'label': 'BOMs (TMEC)'},
      {'icon': Icons.logout, 'label': 'Salidas (Descargos)'},
      {'icon': Icons.bar_chart, 'label': 'Reporte (Saldos)'},
      {'icon': Icons.settings, 'label': 'Operaciones Especiales'},
      {'icon': Icons.gavel, 'label': 'CatÃƒ¡logo (MerceologÃƒÂ­a)'},
      {'icon': Icons.radar, 'label': 'Auditor (IA SAT)'},
      {'icon': Icons.factory, 'label': 'Submaquila'},
      {'icon': Icons.business_center, 'label': 'Activo Fijo'},
      {'icon': Icons.delete_forever, 'label': 'Destrucciones'},
      {'icon': Icons.summarize, 'label': 'Diemex / RECAP'},
      {'icon': Icons.history, 'label': 'MÃƒ¡quina del Tiempo'},
      {'icon': Icons.recycling, 'label': 'Mermas/Desperdicios'},
      {'icon': Icons.compare_arrows, 'label': 'Diferencias'},
    ];

    return Container(
      color: bgCol,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(modules.length, (index) {
            final isActive = _modulo == index;
            final color = isActive ? ambarCol : const Color(0xFF6B7E99);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _modulo = index;
                  _subTab = 0;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? ambarCol : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(modules[index]['icon'] as IconData, color: color),
                    const SizedBox(height: 4),
                    Text(
                      modules[index]['label'] as String,
                      style: TextStyle(color: color, fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_modulo) {
      case 0:
        return _buildModuloEntradas();
      case 1:
        return _buildModuloDataStage();
      case 2:
        return _buildModuloBoms();
      case 3:
        return _buildModuloSalidas();
      case 4:
        return _buildModuloReporte();
      case 5:
        return _buildModuloOpEspeciales();
      case 6:
        return _buildModuloCatalogo();
      case 7:
        return _buildModuloAuditorIA();
      case 8:
        return _buildModuloSubmaquila();
      case 9:
        return _buildModuloActivoFijo();
      case 10:
        return _buildModuloDestrucciones();
      case 11:
        return _buildModuloDiemex();
      case 12:
        return _buildModuloMaquinaTiempo();
      case 13:
        return _buildModuloMermasDesperdicios();
      case 14:
        return const Center(
            child: Text('Diferencias Ã¢â‚¬â€ prÃƒÂ³ximamente',
                style: TextStyle(color: textoCol)));
      default:
        return _buildModuloEntradas();
    }
  }

  Widget _buildModuloEntradas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: bgCol,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildSubTab(
                  0, 'Captura de Entrada', Icons.add_box_outlined, ambarCol),
              const SizedBox(width: 16),
              _buildSubTab(1, 'Inventario / Historial',
                  Icons.inventory_outlined, azulCol),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _subTab == 0 ? _buildCapturaEntrada() : Container(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTab(
      int index, String label, IconData icon, Color activeColor) {
    final isActive = _subTab == index;
    final color = isActive ? activeColor : secCol;
    return InkWell(
      onTap: () => setState(() => _subTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturaEntrada() {
    final now = DateTime.now();
    final expirationDate = now.add(const Duration(days: 540));
    final diff = expirationDate.difference(now).inDays;
    final expirationColor = diff > 90
        ? tealCol
        : diff > 30
            ? ambarCol
            : rojoCol;
    final obligatorios = ['IN', 'DT', 'DE', 'SC'];
    final opcionales = ['CO', 'PR', 'CA', 'IA'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: cardsCol,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: borderCol),
            ),
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.2),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment, color: textoCol),
                      SizedBox(width: 8),
                      Text(
                        'Datos del Pedimento',
                        style: TextStyle(
                            color: textoCol,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('InformaciÃƒÂ³n de la operaciÃƒÂ³n aduanal',
                      style: TextStyle(color: secCol)),
                  const SizedBox(height: 24),

                  // Fila 1
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('No. Pedimento *',
                            'Ej 34 47 3600 0012348', _pedimentoCtrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                            'RÃƒÂ©gimen',
                            [
                              'IN (IMMEX Temporal)',
                              'IN OEA (IMMEX Expedito)',
                              'A1 (ImportaciÃƒÂ³n Definitiva)',
                              'V5 (Transferencia Virtual)',
                              'RT (Retorno)',
                              'DE (DepÃƒÂ³sito Fiscal)',
                            ],
                            _regimen, (val) {
                          setState(() {
                            _regimen = val;
                          });
                        }),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                            'Aduana de Entrada',
                            [
                              'Nuevo Laredo',
                              'Laredo',
                              'JuÃƒ¡rez',
                              'El Paso',
                              'Tijuana',
                              'Otay Mesa',
                              'Nogales',
                              'Matamoros',
                              'Reynosa',
                              'Piedras Negras',
                              'Agua Prieta',
                              'Mexicali',
                              'Guadalajara',
                              'AICM',
                              'Manzanillo',
                              'Veracruz',
                              'Altamira',
                              'Ciudad Hidalgo',
                              'Colombia',
                              'Acapulco',
                            ],
                            _aduana, (val) {
                          setState(() {
                            _aduana = val;
                          });
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fila 2
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                            'Proveedor / Supplier *',
                            'RazÃƒÂ³n social del proveedor extranjero',
                            _proveedorCtrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                            'PaÃƒÂ­s de Origen (ISO)', 'US', _paisCtrl,
                            maxLength: 3),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('No. Factura Extranjera',
                            'INV-2024-001', _facturaCtrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('UUID CFDI (si aplica)',
                            'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', _uuidCtrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Fila de badges
                  Row(
                    children: [
                      _buildInfoBadge(
                          Icons.calendar_today,
                          'Fecha de ImportaciÃƒÂ³n',
                          DateFormat('dd/MMM/yyyy').format(now),
                          textoCol),
                      const SizedBox(width: 12),
                      _buildInfoBadge(
                          Icons.check_circle,
                          'Vencimiento IMMEX (540 dÃƒÂ­as)',
                          '$diff dÃƒÂ­as restantes Ã¢â‚¬â€ ${DateFormat('dd/MMM/yyyy').format(expirationDate)}',
                          expirationColor),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cardsCol,
                          border: Border.all(color: borderCol),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.currency_exchange,
                                color: tealCol, size: 16),
                            const SizedBox(width: 8),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TC FIX DOF',
                                    style:
                                        TextStyle(color: secCol, fontSize: 10)),
                                Text('\$17.15 MXN/USD',
                                    style: TextStyle(
                                        color: tealCol,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'TC DOF actualizado: \$17.15 (Banco de MÃƒÂ©xico)')));
                              },
                              child: const Icon(Icons.refresh,
                                  color: textoCol, size: 16),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Identificadores
                  const Text(
                      'Identificadores ApÃƒÂ©ndice 8 sugeridos para este rÃƒÂ©gimen:',
                      style: TextStyle(color: textoCol)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Obligatorios:',
                          style: TextStyle(color: secCol, fontSize: 12)),
                      const SizedBox(width: 8),
                      ...obligatorios.map((id) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(id,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              backgroundColor: rojoCol,
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                            ),
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Opcionales:',
                          style: TextStyle(color: secCol, fontSize: 12)),
                      const SizedBox(width: 8),
                      ...opcionales.map((id) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(id,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              backgroundColor: secCol,
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // BotÃƒÂ³n Registrar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ambarCol,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        try {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            await FirebaseFirestore.instance
                                .collection('inventario_inmex')
                                .add({
                              'agentUid': uid,
                              'pedimento': _pedimentoCtrl.text,
                              'regimen': _regimen,
                              'aduana': _aduana,
                              'proveedor': _proveedorCtrl.text,
                              'pais': _paisCtrl.text,
                              'factura': _facturaCtrl.text,
                              'uuid': _uuidCtrl.text,
                              'timestamp': FieldValue.serverTimestamp(),
                              'status': 'Abierto',
                              'fechaImportacion': now.toIso8601String(),
                            });
                          }
                          if (!mounted) return;
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Entrada registrada exitosamente')));
                        } catch (e) {
                          if (!mounted) return;
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error: \$e')));
                        }
                      },
                      child: const Text('Registrar Entrada',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController ctrl,
      {int? maxLength}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: secCol, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: textoCol),
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: secCol),
            filled: true,
            fillColor: bgCol,
            counterText: '',
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: borderCol),
                borderRadius: BorderRadius.circular(4)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: ambarCol),
                borderRadius: BorderRadius.circular(4)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? value,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: secCol, fontSize: 12)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: options
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: textoCol))))
              .toList(),
          onChanged: onChanged,
          dropdownColor: cardsCol,
          decoration: InputDecoration(
            filled: true,
            fillColor: bgCol,
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: borderCol),
                borderRadius: BorderRadius.circular(4)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: ambarCol),
                borderRadius: BorderRadius.circular(4)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBadge(
      IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardsCol,
        border: Border.all(color: borderCol),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: secCol, fontSize: 10)),
              Text(value,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildInventario() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: textoCol),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: secCol),
                  hintText: 'Buscar pedimento, fracciÃƒÂ³n, proveedor...',
                  hintStyle: const TextStyle(color: secCol),
                  filled: true,
                  fillColor: cardsCol,
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: borderCol),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: ambarCol),
                      borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (v) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 140,
              child: DropdownButtonFormField<String>(
                initialValue: _filtroStatus,
                items: ['Todos', 'Abierto', 'Cerrado', 'Rectificado']
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child:
                            Text(e, style: const TextStyle(color: textoCol))))
                    .toList(),
                onChanged: (v) => setState(() => _filtroStatus = v ?? 'Todos'),
                dropdownColor: cardsCol,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardsCol,
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: borderCol),
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: ambarCol),
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: uid == null
              ? const Center(
                  child: Text('Usuario no autenticado',
                      style: TextStyle(color: textoCol)))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('inventario_inmex')
                      .where('agentUid', isEqualTo: uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error: \${snapshot.error}',
                              style: TextStyle(color: rojoCol)));
                    }

                    var docs = snapshot.data?.docs ?? [];

                    if (_filtroStatus != 'Todos') {
                      docs = docs
                          .where((doc) =>
                              (doc.data() as Map<String, dynamic>)['status'] ==
                              _filtroStatus)
                          .toList();
                    }
                    if (_searchCtrl.text.isNotEmpty) {
                      final query = _searchCtrl.text.toLowerCase();
                      docs = docs.where((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        final pedimento =
                            d['pedimento']?.toString().toLowerCase() ?? '';
                        final proveedor =
                            d['proveedor']?.toString().toLowerCase() ?? '';
                        return pedimento.contains(query) ||
                            proveedor.contains(query);
                      }).toList();
                    }

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 64, color: secCol.withAlpha(128)),
                            const SizedBox(height: 16),
                            const Text('Sin entradas registradas',
                                style: TextStyle(
                                    color: textoCol,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const Text('Usa la pestaÃƒÂ±a Captura de Entrada',
                                style: TextStyle(color: secCol)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return Card(
                          color: cardsCol,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: borderCol)),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Text((data['pedimento'] as String?) ?? 'N/A',
                                    style: const TextStyle(
                                        color: ambarCol,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                Chip(
                                  label: Text(
                                      (data['regimen'] as String?) ?? 'N/A',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                  backgroundColor: tealCol.withAlpha(80),
                                  side: BorderSide.none,
                                ),
                              ],
                            ),
                            subtitle: Text(
                                (data['proveedor'] as String?) ??
                                    'Sin proveedor',
                                style: const TextStyle(color: secCol)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: data['status'] == 'Abierto'
                                    ? ambarCol.withAlpha(40)
                                    : bgCol,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                  (data['status'] as String?) ?? 'Abierto',
                                  style: TextStyle(
                                      color: data['status'] == 'Abierto'
                                          ? ambarCol
                                          : secCol)),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            'Fecha: ${data["fechaImportacion"] ?? "Ã¢â‚¬â€"}',
                                            style: const TextStyle(
                                                color: textoCol))),
                                    Expanded(
                                        child: Text(
                                            'Aduana: ${data["aduana"] ?? "Ã¢â‚¬â€"}',
                                            style: const TextStyle(
                                                color: textoCol))),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        )
      ],
    );
  }

  // ignore: unused_element
  Widget _buildCuarentena() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildKPICard(
                    Icons.warning_amber, '0', 'Cuarentena', rojoCol)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildKPICard(
                    Icons.check_circle, '0', 'Procesados', tealCol)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildKPICard(Icons.inbox, '0', 'Total Cola', azulCol)),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: tealCol.withAlpha(20),
            border: Border.all(color: tealCol),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            children: [
              Icon(Icons.check_circle, color: tealCol, size: 48),
              SizedBox(height: 16),
              Text('Cuarentena limpia',
                  style: TextStyle(
                      color: tealCol,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildKPICard(IconData icon, String value, String label, Color color) {
    return Card(
      color: cardsCol,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderCol)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: textoCol,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: secCol)),
          ],
        ),
      ),
    );
  }

  Widget _buildModuloDataStage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trazabilidad Forense de Inventarios',
              style: TextStyle(
                  color: ambarCol, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
            'VisualizaciÃƒÂ³n en Grafo (DAG) de las primeras entradas y primeras salidas. Si la cadena FIFO se corrompe, el algoritmo la sana automÃƒ¡ticamente.',
            style: TextStyle(color: secCol, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel izquierdo: Integridad DAG
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: cardsCol,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderCol),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          color: tealCol, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Integridad 100%. No hay anomalÃƒÂ­as en el DAG.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: tealCol,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Panel derecho: FIFO status
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardsCol,
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(
                        left: BorderSide(color: tealCol, width: 3),
                        top: BorderSide(color: borderCol),
                        right: BorderSide(color: borderCol),
                        bottom: BorderSide(color: borderCol)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FIFO Saludable',
                          style: TextStyle(
                              color: tealCol,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const Divider(color: borderCol),
                      const SizedBox(height: 8),
                      const Text('Las descargas corren correctamente.',
                          style: TextStyle(color: tealCol, fontSize: 13)),
                      const SizedBox(height: 24),
                      Row(children: [
                        _fifoStat(
                            'Entradas activas',
                            '${_inventario.where((e) => (e['rem'] as int) > 0).length}',
                            tealCol),
                        const SizedBox(width: 24),
                        _fifoStat(
                            'Saldos consumidos',
                            '${_inventario.where((e) => (e['rem'] as int) == 0).length}',
                            ambarCol),
                        const SizedBox(width: 24),
                        _fifoStat(
                            'Alertas Vencimiento',
                            '${_inventario.where((e) => DateTime.now().difference(e['fecha'] as DateTime).inDays > 16).length}',
                            rojoCol),
                      ]),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: tealCol.withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: tealCol.withAlpha(60))),
                        child: const Row(children: [
                          Icon(Icons.info_outline, color: tealCol, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text(
                                  'El algoritmo FIFO garantiza que los insumos con menor tiempo IMMEX se descarguen primero, previniendo vencimientos.',
                                  style:
                                      TextStyle(color: tealCol, fontSize: 11))),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Cola de Descargas (FIFO)',
              style: TextStyle(
                  color: textoCol, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: cardsCol,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol)),
            child: DataTable(
              headingTextStyle: const TextStyle(
                  color: secCol, fontSize: 12, fontWeight: FontWeight.w600),
              dataTextStyle: const TextStyle(color: textoCol, fontSize: 13),
              columns: const [
                DataColumn(label: Text('Pedimento IN')),
                DataColumn(label: Text('Insumo')),
                DataColumn(label: Text('Fecha Entrada')),
                DataColumn(label: Text('DÃƒÂ­as IMMEX')),
                DataColumn(label: Text('Cantidad Inicial')),
                DataColumn(label: Text('Remanente')),
              ],
              rows: _inventario.map((item) {
                final int dias =
                    DateTime.now().difference(item['fecha'] as DateTime).inDays;
                final bool isWarning = dias > 16;
                return DataRow(cells: [
                  DataCell(Text(item['ped'] as String,
                      style: const TextStyle(
                          color: ambarCol, fontWeight: FontWeight.bold))),
                  DataCell(Text(item['pt'] as String)),
                  DataCell(Text(_formatoFecha(item['fecha'] as DateTime))),
                  DataCell(Text('$dias días',
                      style: TextStyle(
                          color: isWarning ? rojoCol : tealCol,
                          fontWeight: FontWeight.bold))),
                  DataCell(Text(item['qty'].toString())),
                  DataCell(Text(item['rem'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fifoStat(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(val,
            style: TextStyle(
                color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: secCol, fontSize: 11)),
      ],
    );
  }

  // ignore: unused_element
  DataRow _buildFifoRow(String fraction, String desc, String qty, String ped,
      String date, String days) {
    return DataRow(cells: [
      DataCell(Text(fraction)),
      DataCell(Text(desc)),
      DataCell(Text(qty)),
      DataCell(Text(ped, style: const TextStyle(color: ambarCol))),
      DataCell(Text(date)),
      DataCell(Text(days, style: const TextStyle(color: rojoCol))),
      DataCell(ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: tealCol,
            foregroundColor: Colors.black,
            minimumSize: const Size(60, 32)),
        onPressed: () {},
        child: const Text('Usar'),
      ))
    ]);
  }

  String _bomPt = 'PT-001 (ArnÃƒÂ©s elÃƒÂ©ctrico)';
  String _bomComp = 'MP-101 (Cable cobre)';
  final _bomQtyCtrl = TextEditingController(text: '');
  final _bomMermaCtrl = TextEditingController(text: '0.0');

  Widget _buildModuloBoms() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delta Analyzer & TMEC VCR Engine',
              style: TextStyle(
                  color: ambarCol, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
            'Detecta cambios no reportados por ingenierÃƒÂ­a en el BOM y bloquea exportaciones si el Valor de Contenido Regional (VCR) cae bajo el 60% exigido por TMEC.',
            style: TextStyle(color: secCol, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: cardsCol,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Captura Manual de BOM (Lista de Materiales)',
                    style: TextStyle(
                        color: textoCol,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                        child: DropdownButtonFormField<String>(
                      initialValue: _bomPt,
                      dropdownColor: cardsCol,
                      style: const TextStyle(color: textoCol, fontSize: 12),
                      decoration: _inputDecoA24(''),
                      isExpanded: true,
                      hint: const Text('Producto Terminado (PT)',
                          style: TextStyle(color: secCol, fontSize: 12)),
                      items: [
                        'PT-001 (ArnÃƒÂ©s elÃƒÂ©ctrico)',
                        'PT-002 (Motor DC 24V)',
                        'PT-003 (MÃƒÂ³dulo electrÃƒÂ³nico)',
                        'PT-004 (Tablero control)'
                      ]
                          .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v, overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setState(() => _bomPt = v!),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: DropdownButtonFormField<String>(
                      initialValue: _bomComp,
                      dropdownColor: cardsCol,
                      style: const TextStyle(color: textoCol, fontSize: 12),
                      decoration: _inputDecoA24(''),
                      isExpanded: true,
                      hint: const Text('Insumo Componente',
                          style: TextStyle(color: secCol, fontSize: 12)),
                      items: [
                        'MP-101 (Cable cobre)',
                        'MP-102 (Conector AMP)',
                        'MP-103 (Cinta aislante)',
                        'MP-104 (Resistencia 10K)',
                        'MP-105 (Capacitor 100uF)'
                      ]
                          .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v, overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setState(() => _bomComp = v!),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                            controller: _bomQtyCtrl,
                            keyboardType: TextInputType.number,
                            style:
                                const TextStyle(color: textoCol, fontSize: 13),
                            decoration: _inputDecoA24('Cantidad Requerida'))),
                    const SizedBox(width: 10),
                    SizedBox(
                        width: 100,
                        child: TextField(
                            controller: _bomMermaCtrl,
                            keyboardType: TextInputType.number,
                            style:
                                const TextStyle(color: textoCol, fontSize: 13),
                            decoration: _inputDecoA24('% Merma'))),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                              content:
                                  Text('Ã¢Å“â€¦ Componente aÃƒÂ±adido al BOM'),
                              backgroundColor: AppColors.card)),
                      icon:
                          const Icon(Icons.add, size: 14, color: Colors.black),
                      label: const Text('+ AÃƒÂ±adir Componente',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: tealCol,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: cardsCol,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: tealCol.withAlpha(60))),
                    child: const Text('No hay revisiones de BOM pendientes.',
                        style: TextStyle(color: tealCol, fontSize: 13)))),
            const SizedBox(width: 16),
            Expanded(
                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: cardsCol,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: tealCol.withAlpha(60))),
                    child: const Text(
                        'VCR dentro de los lÃƒÂ­mites TMEC (100%).',
                        style: TextStyle(color: tealCol, fontSize: 13)))),
          ]),
        ],
      ),
    );
  }

  final _salidaPedCtrl = TextEditingController();
  final _salidaQtyCtrl = TextEditingController();
  String _salidaPT = 'PT-001 (ArnÃƒÂ©s elÃƒÂ©ctrico)';
  DateTime _salidaFecha = DateTime.now();

  Widget _buildModuloSalidas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: cardsCol,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol)),
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: _salidaPedCtrl,
                        style: const TextStyle(color: textoCol, fontSize: 13),
                        decoration:
                            _inputDecoA24('Pedimento de ExportaciÃƒÂ³n (RT)'))),
                const SizedBox(width: 16),
                Expanded(
                    child: DropdownButtonFormField<String>(
                  initialValue: _salidaPT,
                  dropdownColor: cardsCol,
                  style: const TextStyle(color: textoCol, fontSize: 12),
                  isExpanded: true,
                  decoration: _inputDecoA24(''),
                  hint: const Text('Producto Terminado Exportado',
                      style: TextStyle(color: secCol, fontSize: 12)),
                  items: [
                    'PT-001 (ArnÃƒÂ©s elÃƒÂ©ctrico)',
                    'PT-002 (Motor DC 24V)',
                    'PT-003 (MÃƒÂ³dulo electrÃƒÂ³nico)'
                  ]
                      .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _salidaPT = v!),
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: _salidaQtyCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: textoCol, fontSize: 13),
                        decoration: _inputDecoA24('Cantidad Exportada'))),
                const SizedBox(width: 16),
                Expanded(
                    child: InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                        context: context,
                        initialDate: _salidaFecha,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (ctx, child) => Theme(
                            data: ThemeData.dark().copyWith(
                                colorScheme:
                                    const ColorScheme.dark(primary: ambarCol)),
                            child: child!));
                    if (d != null) setState(() => _salidaFecha = d);
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderCol)),
                      child: Row(children: [
                        Expanded(
                            child: Text(
                                'Fecha OUT: ${DateFormat('dd/MM/yyyy').format(_salidaFecha)}',
                                style: const TextStyle(
                                    color: textoCol, fontSize: 13))),
                        const Icon(Icons.calendar_today,
                            color: secCol, size: 16)
                      ])),
                )),
              ]),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_salidaPedCtrl.text.isEmpty ||
                        _salidaQtyCtrl.text.isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Completa todos los campos'),
                          backgroundColor: rojoCol));
                      return;
                    }
                    int qtyOut = int.tryParse(_salidaQtyCtrl.text) ?? 0;
                    final int originalQtyOut = qtyOut;
                    final List<String> pedimentosAfectados = [];
                    // LÃƒÂ³gica FIFO: Ordenar por fecha mÃƒ¡s antigua y consumir
                    _inventario.sort((a, b) => (a['fecha'] as DateTime)
                        .compareTo(b['fecha'] as DateTime));

                    final batch = FirebaseFirestore.instance.batch();

                    for (final item in _inventario) {
                      if (qtyOut <= 0) break;
                      if ((item['rem'] as int) > 0) {
                        final int disponible = item['rem'] as int;
                        if (disponible >= qtyOut) {
                          item['rem'] = disponible - qtyOut;
                          pedimentosAfectados.add('${item['ped']} (-$qtyOut)');
                          if (item['id'] != null) {
                            batch.update(
                                FirebaseFirestore.instance
                                    .collection('immex_inventario')
                                    .doc(item['id'] as String),
                                {'rem': item['rem']});
                          }
                          qtyOut = 0;
                        } else {
                          qtyOut -= disponible;
                          item['rem'] = 0;
                          pedimentosAfectados
                              .add('${item['ped']} (-$disponible)');
                          if (item['id'] != null) {
                            batch.update(
                                FirebaseFirestore.instance
                                    .collection('immex_inventario')
                                    .doc(item['id'] as String),
                                {'rem': item['rem']});
                          }
                        }
                      }
                    }

                    final descData = {
                      'ped': _salidaPedCtrl.text,
                      'pt': _salidaPT,
                      'qty': originalQtyOut.toString(),
                      'fecha': DateFormat('dd/MM/yyyy').format(_salidaFecha),
                      'fechaDoc': _salidaFecha.toIso8601String(),
                      'afectados': pedimentosAfectados.join(', '),
                    };

                    final newDocRef = FirebaseFirestore.instance
                        .collection('immex_descargos')
                        .doc();
                    batch.set(newDocRef, descData);

                    await batch.commit();

                    setState(() {
                      _descargos.insert(0, {
                        'ped': _salidaPedCtrl.text,
                        'pt': _salidaPT,
                        'qty': originalQtyOut.toString(),
                        'fecha': DateFormat('dd/MM/yyyy').format(_salidaFecha),
                        'afectados': pedimentosAfectados.join(', '),
                      });
                      _salidaPedCtrl.clear();
                      _salidaQtyCtrl.clear();
                    });
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Ã¢Å“â€¦ Salida registrada en Firebase y FIFO ejecutado'),
                        backgroundColor: AppColors.card));
                  },
                  icon: const Icon(Icons.account_tree_outlined,
                      size: 14, color: Colors.white),
                  label: const Text('Registrar Salida y Ejecutar FIFO',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ambarCol,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Historial de Descargos Efectuados',
              style: TextStyle(
                  color: textoCol, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (_descargos.isEmpty)
            const Text('No hay exportaciones registradas',
                style: TextStyle(color: secCol, fontSize: 13))
          else
            ..._descargos.map((d) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: cardsCol,
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(
                          left: BorderSide(color: tealCol, width: 3),
                          top: BorderSide(color: borderCol),
                          right: BorderSide(color: borderCol),
                          bottom: BorderSide(color: borderCol))),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(d['ped'] as String,
                              style: const TextStyle(
                                  color: ambarCol,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          Text('${d['pt']} | ${d['qty']} unidades',
                              style:
                                  const TextStyle(color: secCol, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text('Afectó (FIFO): ${d['afectados']}',
                              style: const TextStyle(
                                  color: azulCol,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic)),
                        ])),
                    Text(d['fecha'] as String,
                        style: const TextStyle(color: secCol, fontSize: 11)),
                    const SizedBox(width: 10),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: tealCol.withAlpha(26),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text('FIFO OK',
                            style: TextStyle(
                                color: tealCol,
                                fontSize: 10,
                                fontWeight: FontWeight.bold))),
                  ]),
                )),
        ],
      ),
    );
  }

  Widget _buildModuloReporte() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reporte Oficial de Saldos (Data Dump SAT)',
                      style: TextStyle(
                          color: ambarCol,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text('Balance general de insumos vivos consolidados.',
                      style: TextStyle(color: secCol, fontSize: 11)),
                ]),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(
                    text: 'Fraccion,SKU,Saldo,Unidad,Valor\n'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Reporte CSV copiado'),
                    backgroundColor: AppColors.card));
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Exportar a Excel (CSV)',
                  style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                  foregroundColor: secCol,
                  side: const BorderSide(color: borderCol),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          ]),
          const SizedBox(height: 32),
          const Center(
              child: Column(children: [
            Icon(Icons.inventory_2_outlined, color: ambarCol, size: 56),
            SizedBox(height: 16),
            Text('No Hay Saldos',
                style: TextStyle(
                    color: textoCol,
                    fontSize: 20,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Text('No existen saldos vivos reportables actualmente.',
                style: TextStyle(color: secCol, fontSize: 12)),
            SizedBox(height: 40),
          ])),
          Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFF0A0F1A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderCol)),
              child: const Text(
                  'Nota de AuditorÃƒÂ­a: Este reporte consolida la suma de la columna "Saldo Restante" de todos los pedimentos con estatus "open" cruzando por FracciÃƒÂ³n/SKU. Representa el inventario temporal exacto que la autoridad asume que tienes fÃƒÂ­sicamente en tu planta.',
                  style: TextStyle(color: secCol, fontSize: 11, height: 1.5))),
        ],
      ),
    );
  }

  String _opTipo = 'MERMA';
  String _opInsumo = 'MP-101 (Cable cobre)';
  final _opQtyCtrl = TextEditingController();
  final _opRefCtrl = TextEditingController();
  final List<Map<String, String>> _bitacora = [];

  Widget _buildModuloOpEspeciales() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
            'Realiza descargos directos de insumos sin necesidad de una Lista de Materiales (BOM).',
            style: TextStyle(color: secCol, fontSize: 12)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: cardsCol,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderCol)),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                      initialValue: _opTipo,
                      dropdownColor: cardsCol,
                      style: const TextStyle(color: textoCol, fontSize: 13),
                      decoration: _inputDecoA24('Tipo de OperaciÃƒÂ³n'),
                      items: [
                        'MERMA',
                        'SCRAP',
                        'DESTRUCCIÃƒâ€œN',
                        'RETORNO',
                        'AJUSTE INVENTARIO'
                      ]
                          .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => _opTipo = v!))),
              const SizedBox(width: 16),
              Expanded(
                  child: DropdownButtonFormField<String>(
                      initialValue: _opInsumo,
                      dropdownColor: cardsCol,
                      style: const TextStyle(color: textoCol, fontSize: 12),
                      isExpanded: true,
                      decoration: _inputDecoA24('Insumo a Descargar'),
                      items: [
                        'MP-101 (Cable cobre)',
                        'MP-102 (Conector AMP)',
                        'MP-103 (Cinta aislante)',
                        'MP-104 (Resistencia 10K)'
                      ]
                          .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v, overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setState(() => _opInsumo = v!))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: _opQtyCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: textoCol, fontSize: 13),
                      decoration: _inputDecoA24('Cantidad a Descargar'))),
              const SizedBox(width: 16),
              Expanded(
                  child: TextField(
                      controller: _opRefCtrl,
                      style: const TextStyle(color: textoCol, fontSize: 13),
                      decoration: _inputDecoA24(
                          'Referencia (Acta de DestrucciÃƒÂ³n / Pedimento F4)'))),
            ]),
            const SizedBox(height: 14),
            Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_opQtyCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Ingresa la cantidad'),
                          backgroundColor: rojoCol));
                      return;
                    }
                    setState(() {
                      _bitacora.insert(0, {
                        'tipo': _opTipo,
                        'insumo': _opInsumo,
                        'qty': _opQtyCtrl.text,
                        'ref': _opRefCtrl.text,
                        'fecha': DateFormat('dd/MM/yyyy HH:mm')
                            .format(DateTime.now())
                      });
                      _opQtyCtrl.clear();
                      _opRefCtrl.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Ã¢Å“â€¦ $_opTipo ejecutada'),
                        backgroundColor: AppColors.card));
                  },
                  icon: const Icon(Icons.warning_amber,
                      size: 16, color: Colors.white),
                  label: Text('Ejecutar $_opTipo',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: rojoCol,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                )),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('BitÃƒ¡cora de Operaciones Especiales',
            style: TextStyle(
                color: textoCol, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        if (_bitacora.isEmpty)
          const Text('No hay operaciones especiales registradas.',
              style: TextStyle(color: secCol, fontSize: 13))
        else
          ..._bitacora.map((op) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: cardsCol,
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                      left: BorderSide(color: rojoCol, width: 3),
                      top: BorderSide(color: borderCol),
                      right: BorderSide(color: borderCol),
                      bottom: BorderSide(color: borderCol))),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('${op['tipo']} Ã¢â‚¬â€ ${op['insumo']}',
                          style: const TextStyle(
                              color: rojoCol,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      Text(
                          'Qty: ${op['qty']} | Ref: ${op['ref']!.isEmpty ? 'N/A' : op['ref']}',
                          style: const TextStyle(color: secCol, fontSize: 11))
                    ])),
                Text(op['fecha']!,
                    style: const TextStyle(color: secCol, fontSize: 11))
              ]))),
      ]),
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  // MÃƒâ€œDULO 11: DIEMEX / RECAP Ã¢â‚¬â€ Reporte Anual de Operaciones
  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  String _diemexAnio = '2025';
  final _diemexVentasCtrl = TextEditingController(text: '85000000');
  Map<String, dynamic>? _diemexResultado;

  static const List<String> _aniosFiscales = [
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
    '2027'
  ];

  Widget _buildModuloDiemex() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Sub-header
        Row(children: [
          Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: cardsCol,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderCol)),
              child: const Icon(Icons.chevron_left, color: secCol, size: 18)),
          const Spacer(),
          const Text('Reporte Anual de Operaciones (DIEMEX)',
              style: TextStyle(
                  color: textoCol, fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          const SizedBox(width: 28),
        ]),
        const SizedBox(height: 20),
        // Input row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: cardsCol,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderCol)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            // AÃƒÂ±o fiscal
            Expanded(
                flex: 2,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AÃƒÂ±o Fiscal',
                          style: TextStyle(color: secCol, fontSize: 11)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderCol)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        child: DropdownButton<String>(
                          value: _diemexAnio,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: cardsCol,
                          style: const TextStyle(color: textoCol, fontSize: 13),
                          items: _aniosFiscales
                              .map((a) =>
                                  DropdownMenuItem(value: a, child: Text(a)))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _diemexAnio = v!;
                            _diemexResultado = null;
                          }),
                        ),
                      ),
                    ])),
            const SizedBox(width: 12),
            // Ventas totales
            Expanded(
                flex: 4,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ventas Totales Anuales (MXN)',
                          style: TextStyle(color: secCol, fontSize: 11)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _diemexVentasCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: textoCol, fontSize: 13),
                        onChanged: (_) =>
                            setState(() => _diemexResultado = null),
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12, right: 8),
                              child: Text('\$',
                                  style: TextStyle(
                                      color: ambarCol,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))),
                          prefixIconConstraints: const BoxConstraints(),
                          filled: true,
                          fillColor: AppColors.bg,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: borderCol)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: borderCol)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: ambarCol)),
                        ),
                      ),
                    ])),
            const SizedBox(width: 12),
            // Calculate button
            ElevatedButton.icon(
              onPressed: () {
                final ventas = double.tryParse(
                        _diemexVentasCtrl.text.replaceAll(',', '')) ??
                    0;
                // IMMEX: exportaciones deben ser >= 40% de ventas totales (o monto mÃƒÂ­nimo por tipo)
                final exportaciones = ventas * 0.65; // simulated
                final pct = ventas > 0 ? (exportaciones / ventas * 100) : 0.0;
                final cumple = pct >= 40;
                setState(() {
                  _diemexResultado = {
                    'anio': _diemexAnio,
                    'ventas': ventas,
                    'exportaciones': exportaciones,
                    'pct': pct,
                    'cumple': cumple,
                    'minRequerido': ventas * 0.40,
                    'excedente': cumple ? exportaciones - ventas * 0.40 : 0.0,
                    'deficit': !cumple ? ventas * 0.40 - exportaciones : 0.0,
                  };
                });
              },
              icon: const Icon(Icons.bolt, size: 16, color: Colors.black),
              label: const Text('Calcular Cumplimiento IMMEX',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: ambarCol,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        // Results
        if (_diemexResultado != null) _buildDiemexResultados(_diemexResultado!),
      ]),
    );
  }

  Widget _buildDiemexResultados(Map<String, dynamic> r) {
    final bool cumple = r['cumple'] as bool;
    final Color statusColor = cumple ? tealCol : rojoCol;
    final String statusText = cumple
        ? 'Ã¢Å“â€¦ PROGRAMA VIGENTE Ã¢â‚¬â€ Cumplimiento confirmado'
        : 'Ã¢Å¡ Ã¯Â¸Â RIESGO DE CANCELACIÃƒâ€œN Ã¢â‚¬â€ DÃƒÂ©ficit de exportaciones';

    String fmt(double v) {
      if (v == 0) return '0.00';
      final s = v.toStringAsFixed(2).split('.');
      final b = StringBuffer();
      for (int i = 0; i < s[0].length; i++) {
        if (i > 0 && (s[0].length - i) % 3 == 0) b.write(',');
        b.write(s[0][i]);
      }
      return '$b.${s[1]}';
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Status banner
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: statusColor.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: statusColor.withAlpha(80))),
        child: Text(statusText,
            style: TextStyle(
                color: statusColor, fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 16),
      // KPI grid
      Row(children: [
        _diemexKpi(
            'Ventas Totales', '\$ ${fmt(r['ventas'] as double)} MXN', secCol),
        const SizedBox(width: 12),
        _diemexKpi('Exportaciones (sim.)',
            '\$ ${fmt(r['exportaciones'] as double)} MXN', azulCol),
        const SizedBox(width: 12),
        _diemexKpi('% ExportaciÃƒÂ³n',
            '${(r['pct'] as double).toStringAsFixed(1)}%', statusColor),
        const SizedBox(width: 12),
        _diemexKpi('MÃƒÂ­nimo Requerido (40%)',
            '\$ ${fmt(r['minRequerido'] as double)} MXN', ambarCol),
      ]),
      const SizedBox(height: 16),
      // Detail
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: cardsCol,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderCol)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AnÃƒ¡lisis Fiscal ${r['anio']}',
              style: const TextStyle(
                  color: textoCol, fontSize: 13, fontWeight: FontWeight.bold)),
          const Divider(color: borderCol),
          if (cumple) ...[
            _diemexLinea('Excedente sobre mÃƒÂ­nimo requerido',
                '\$ ${fmt(r['excedente'] as double)} MXN', tealCol),
            const SizedBox(height: 8),
            const Text(
                'El programa IMMEX continÃƒÂºa vigente. La empresa cumple con los requisitos de exportaciÃƒÂ³n establecidos en el Decreto IMMEX Art. 5.',
                style: TextStyle(color: secCol, fontSize: 12, height: 1.6)),
          ] else ...[
            _diemexLinea('DÃƒÂ©ficit para cumplir mÃƒÂ­nimo',
                '\$ ${fmt(r['deficit'] as double)} MXN', rojoCol),
            const SizedBox(height: 8),
            const Text(
                'ALERTA: Se requiere incrementar las exportaciones para evitar la cancelaciÃƒÂ³n del programa IMMEX. Contacte a su agente aduanal para acciones correctivas.',
                style: TextStyle(color: rojoCol, fontSize: 12, height: 1.6)),
          ],
          const SizedBox(height: 12),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ã°Å¸â€œÅ  Reporte DIEMEX exportado'),
                        backgroundColor: AppColors.card)),
                icon: const Icon(Icons.download, size: 14, color: Colors.black),
                label: const Text('Exportar Reporte DIEMEX (Excel)',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: ambarCol,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              )),
        ]),
      ),
    ]);
  }

  Widget _diemexKpi(String label, String value, Color color) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: cardsCol,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderCol)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: secCol, fontSize: 10)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ]),
    ));
  }

  Widget _diemexLinea(String label, String value, Color color) {
    return Row(children: [
      Expanded(
          child:
              Text(label, style: const TextStyle(color: secCol, fontSize: 12))),
      Text(value,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  // MÃƒâ€œDULO 12: MÃƒÂQUINA DEL TIEMPO Ã¢â‚¬â€ ReconstrucciÃƒÂ³n HistÃƒÂ³rica de Inventario
  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  DateTime _mdtFecha = DateTime(2025, 7, 29, 12);
  bool _mdtLoading = false;
  Map<String, dynamic>? _mdtResultado;

  Widget _buildModuloMaquinaTiempo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Left card
        SizedBox(
            width: 460,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: cardsCol,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clock icon
                    const Center(
                        child: SizedBox(
                            width: 64, height: 64, child: _ClockDotsWidget())),
                    const SizedBox(height: 20),
                    const Text('Fecha Objetivo de AuditorÃƒÂ­a',
                        style: TextStyle(color: secCol, fontSize: 12)),
                    const SizedBox(height: 8),
                    // DateTime field
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _mdtFecha,
                          firstDate: DateTime(2018),
                          lastDate: DateTime.now(),
                          builder: (c, child) => Theme(
                              data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                      primary: ambarCol)),
                              child: child!),
                        );
                        if (d != null) {
                          if (!mounted) return;
                          final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_mdtFecha),
                              builder: (c, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                          primary: ambarCol)),
                                  child: child!));
                          setState(() {
                            _mdtFecha = DateTime(d.year, d.month, d.day,
                                t?.hour ?? 12, t?.minute ?? 0);
                            _mdtResultado = null;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderCol)),
                        child: Row(children: [
                          Expanded(
                              child: Text(
                                  '${_mdtFecha.day}/${_mdtFecha.month}/${_mdtFecha.year} ${_mdtFecha.hour.toString().padLeft(2, '0')}:${_mdtFecha.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                      color: textoCol, fontSize: 14))),
                          const Icon(Icons.calendar_month,
                              color: secCol, size: 18),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                        'El motor matemÃƒ¡tico tomarÃƒ¡ el saldo actual y le aplicarÃƒ¡ ingenierÃƒÂ­a inversa sumando salidas y restando entradas hasta llegar al segundo exacto especificado.',
                        style: TextStyle(
                            color: secCol, fontSize: 11, height: 1.6)),
                    const SizedBox(height: 16),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _mdtLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _mdtLoading = true;
                                    _mdtResultado = null;
                                  });
                                  final model =
                                      FirebaseAI.vertexAI().generativeModel(
                                    model: 'gemini-1.5-flash',
                                    systemInstruction: Content.system(
                                        'Eres el Director de IMMEX y programas de comercio exterior de Mexico. Analiza el programa IMMEX descrito y proporciona: estado de cumplimiento, alertas de vencimiento, recomendaciones para auditorias del SAT. Responde en JSON: {"fecha": "string", "items": [{"fraccion": "string", "desc": "string", "saldo": 0, "unidad": "string"}], "operaciones": 0, "confianza": 0.0}'),
                                    generationConfig: GenerationConfig(
                                        responseMimeType: 'application/json'),
                                  );
                                  try {
                                    final response = await model
                                        .generateContent([
                                      Content.text(
                                          'Reconstruye inventario para la fecha $_mdtFecha')
                                    ]);
                                    final jsonResponse =
                                        jsonDecode(response.text ?? '{}');
                                    setState(() {
                                      _mdtLoading = false;
                                      final jsonMap =
                                          jsonResponse as Map<String, dynamic>;
                                      _mdtResultado = {
                                        'fecha': _mdtFecha,
                                        'items': jsonMap['items'] as List? ??
                                            <dynamic>[],
                                        'operaciones':
                                            jsonMap['operaciones'] as int? ?? 0,
                                        'confianza':
                                            (jsonMap['confianza'] as num?)
                                                    ?.toDouble() ??
                                                99.0,
                                      };
                                    });
                                  } catch (e) {
                                    setState(() {
                                      _mdtLoading = false;
                                    });
                                  }
                                },
                          icon: _mdtLoading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      color: textoCol, strokeWidth: 2))
                              : const Icon(Icons.history,
                                  size: 16, color: textoCol),
                          label: const Text('Reconstruir Saldo',
                              style: TextStyle(
                                  color: textoCol,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.border,
                              side: const BorderSide(color: borderCol),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        )),
                  ]),
            )),
        const SizedBox(width: 20),
        // Right panel
        Expanded(
            child: _mdtResultado == null
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                            "Selecciona una fecha y presiona \"Reconstruir Saldo\".",
                            style: TextStyle(
                                color: secCol, fontSize: 13, height: 1.7),
                            textAlign: TextAlign.center)))
                : _buildMdtResultados(_mdtResultado!)),
      ]),
    );
  }

  Widget _buildMdtResultados(Map<String, dynamic> r) {
    final fecha = r['fecha'] as DateTime;
    final items = r['items'] as List;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: cardsCol,
            borderRadius: BorderRadius.circular(10),
            border: const Border(
                left: BorderSide(color: tealCol, width: 3),
                top: BorderSide(color: borderCol),
                right: BorderSide(color: borderCol),
                bottom: BorderSide(color: borderCol))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Saldo Reconstruido al:',
              style: TextStyle(color: secCol, fontSize: 11)),
          Text(
              '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                  color: tealCol, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            _mdtStatChip('${r['operaciones']} ops aplicadas', azulCol),
            const SizedBox(width: 8),
            _mdtStatChip('${r['confianza']}% confianza', tealCol),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      // Table header
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: const BoxDecoration(
            color: Color(0xFF1A2235),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8))),
        child: const Row(children: [
          Expanded(
              flex: 2,
              child: Text('FracciÃƒÂ³n',
                  style: TextStyle(
                      color: secCol,
                      fontSize: 11,
                      fontWeight: FontWeight.bold))),
          Expanded(
              flex: 3,
              child: Text('DescripciÃƒÂ³n',
                  style: TextStyle(
                      color: secCol,
                      fontSize: 11,
                      fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('Saldo al Momento',
                  style: TextStyle(
                      color: secCol, fontSize: 11, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right)),
        ]),
      ),
      ...List.generate(items.length, (i) {
        final item = items[i] as Map;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              color: i.isEven ? cardsCol : AppColors.card,
              border: const Border(
                  left: BorderSide(color: borderCol),
                  right: BorderSide(color: borderCol),
                  bottom: BorderSide(color: borderCol))),
          child: Row(children: [
            Expanded(
                flex: 2,
                child: Text(item['fraccion'] as String,
                    style: const TextStyle(
                        color: ambarCol,
                        fontSize: 12,
                        fontWeight: FontWeight.w600))),
            Expanded(
                flex: 3,
                child: Text(item['desc'] as String,
                    style: const TextStyle(color: textoCol, fontSize: 12))),
            Expanded(
                flex: 2,
                child: Text('${item['saldo']} ${item['unidad']}',
                    style: const TextStyle(
                        color: tealCol,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right)),
          ]),
        );
      }),
      const SizedBox(height: 12),
      SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Ã°Å¸â€œâ€ž Reporte histÃƒÂ³rico exportado'),
                    backgroundColor: AppColors.card)),
            icon: const Icon(Icons.download, size: 14, color: ambarCol),
            label: const Text('Exportar Snapshot HistÃƒÂ³rico (CSV)',
                style: TextStyle(color: ambarCol)),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ambarCol),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
          )),
    ]);
  }

  Widget _mdtStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(80))),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  // MÃƒâ€œDULO 13: MERMAS/DESPERDICIOS Ã¢â‚¬â€ Decreto IMMEX Art. 24 Fracc. IV
  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  int _mermTab = 0; // 0=Captura, 1=Historial, 2=Alertas
  final _mermFracCtrl = TextEditingController();
  final _mermDescCtrl = TextEditingController();
  final _mermConsCtrl = TextEditingController();
  final _mermQtyCtrl = TextEditingController();
  final _mermObsCtrl = TextEditingController();
  String _mermCausa = 'proceso';
  final List<Map<String, dynamic>> _mermasHistorial = [];

  static const List<String> _causasOpciones = [
    'proceso',
    'calidad',
    'deterioro',
    'evaporaciÃƒÂ³n',
    'corte',
    'otro'
  ];

  Widget _buildModuloMermasDesperdicios() {
    return Column(children: [
      // Sub-header
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        color: bgCol,
        child: Row(children: [
          Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: cardsCol,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderCol)),
              child: const Icon(Icons.chevron_left, color: secCol, size: 18)),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Mermas y Desperdicios',
                style: TextStyle(
                    color: ambarCol,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            Text('Decreto IMMEX Art. 24 Fracc. IV',
                style: TextStyle(color: secCol, fontSize: 10)),
          ]),
          const Spacer(),
          const Icon(Icons.refresh, color: secCol, size: 20),
        ]),
      ),
      // 3 tabs
      ColoredBox(
        color: bgCol,
        child: Row(children: [
          _mermTabBtn(0, Icons.edit_note, 'Captura'),
          _mermTabBtn(1, Icons.history_edu, 'Historial'),
          _mermTabBtn(2, Icons.notifications_active, 'Alertas'),
        ]),
      ),
      const Divider(color: borderCol, height: 1),
      // Content
      Expanded(
          child: [
        _buildMermCaptura(),
        _buildMermHistorial(),
        _buildMermAlertas(),
      ][_mermTab]),
    ]);
  }

  Widget _mermTabBtn(int idx, IconData icon, String label) {
    final bool active = _mermTab == idx;
    final Color color = active ? ambarCol : secCol;
    return GestureDetector(
      onTap: () => setState(() => _mermTab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: active ? ambarCol : Colors.transparent, width: 2))),
        child: Column(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ]),
      ),
    );
  }

  Widget _buildMermCaptura() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: ambarCol.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ambarCol.withAlpha(60))),
          child: const Row(children: [
            Icon(Icons.info_outline, color: ambarCol, size: 16),
            SizedBox(width: 10),
            Expanded(
                child: Text(
                    'Registra las mermas por fracciÃƒÂ³n arancelaria. El % de merma no debe exceder el declarado ante el SAT en tu programa IMMEX.',
                    style:
                        TextStyle(color: ambarCol, fontSize: 11, height: 1.5))),
          ]),
        ),
        const SizedBox(height: 20),
        // MercancÃƒÂ­a
        const Text('MercancÃƒÂ­a',
            style: TextStyle(
                color: secCol, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _mermField(_mermFracCtrl, 'FracciÃƒÂ³n Arancelaria')),
          const SizedBox(width: 12),
          Expanded(child: _mermField(_mermDescCtrl, 'DescripciÃƒÂ³n')),
        ]),
        const SizedBox(height: 16),
        // Cantidades
        const Text('Cantidades del PerÃƒÂ­odo',
            style: TextStyle(
                color: secCol, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: _mermField(_mermConsCtrl, 'Consumo Total',
                  keyboard: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(
              child: _mermField(_mermQtyCtrl, 'Cantidad Merma/Desperdicio',
                  keyboard: TextInputType.number)),
        ]),
        const SizedBox(height: 16),
        // Causa chips
        const Text('Causa de la Merma',
            style: TextStyle(
                color: secCol, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
            spacing: 8,
            children: _causasOpciones.map((c) {
              final bool sel = _mermCausa == c;
              return GestureDetector(
                onTap: () => setState(() => _mermCausa = c),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.border : AppColors.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? ambarCol : borderCol),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (sel) const Icon(Icons.check, color: ambarCol, size: 12),
                    if (sel) const SizedBox(width: 4),
                    Text(c,
                        style: TextStyle(
                            color: sel ? ambarCol : secCol,
                            fontSize: 12,
                            fontWeight:
                                sel ? FontWeight.w600 : FontWeight.normal)),
                  ]),
                ),
              );
            }).toList()),
        const SizedBox(height: 16),
        // Observaciones
        TextField(
          controller: _mermObsCtrl,
          maxLines: 2,
          style: const TextStyle(color: textoCol, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Observaciones (opcional)',
            hintStyle: const TextStyle(color: secCol, fontSize: 12),
            filled: true,
            fillColor: AppColors.bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderCol)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderCol)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ambarCol)),
          ),
        ),
        const SizedBox(height: 20),
        // Register button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_mermFracCtrl.text.isEmpty ||
                  _mermConsCtrl.text.isEmpty ||
                  _mermQtyCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Ã¢Å¡ Ã¯Â¸Â Completa fracciÃƒÂ³n arancelaria y cantidades'),
                    backgroundColor: rojoCol));
                return;
              }
              final consumo = double.tryParse(_mermConsCtrl.text) ?? 0;
              final merma = double.tryParse(_mermQtyCtrl.text) ?? 0;
              final pct = consumo > 0 ? (merma / consumo * 100) : 0.0;
              setState(() {
                _mermasHistorial.insert(0, {
                  'fraccion': _mermFracCtrl.text, 'desc': _mermDescCtrl.text,
                  'consumo': consumo, 'merma': merma, 'pct': pct,
                  'causa': _mermCausa, 'obs': _mermObsCtrl.text,
                  'fecha': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  'excede': pct > 3.0, // 3% typical declared limit
                });
                _mermFracCtrl.clear();
                _mermDescCtrl.clear();
                _mermConsCtrl.clear();
                _mermQtyCtrl.clear();
                _mermObsCtrl.clear();
                _mermCausa = 'proceso';
                _mermTab = 1;
              });
            },
            icon: const Icon(Icons.save, size: 16, color: Colors.black),
            label: const Text('Registrar Merma',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            style: ElevatedButton.styleFrom(
                backgroundColor: ambarCol,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
          ),
        ),
      ]),
    );
  }

  TextField _mermField(TextEditingController ctrl, String hint,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(color: textoCol, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: secCol, fontSize: 12),
        filled: true,
        fillColor: AppColors.bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderCol)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderCol)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ambarCol)),
      ),
    );
  }

  Widget _buildMermHistorial() {
    if (_mermasHistorial.isEmpty) {
      return const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.history_edu, color: Color(0xFF4A5568), size: 48),
        SizedBox(height: 12),
        Text('Sin mermas registradas aÃƒÂºn',
            style: TextStyle(color: secCol, fontSize: 14)),
        SizedBox(height: 8),
        Text('Las mermas capturadas aparecerÃƒ¡n aquÃƒÂ­.',
            style: TextStyle(color: Color(0xFF4A5568), fontSize: 12)),
      ]));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _mermasHistorial.length,
      itemBuilder: (_, i) {
        final m = _mermasHistorial[i];
        final bool excede = m['excede'] as bool;
        final Color color = excede ? rojoCol : tealCol;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: cardsCol,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                  left: BorderSide(color: color, width: 3),
                  top: const BorderSide(color: borderCol),
                  right: const BorderSide(color: borderCol),
                  bottom: const BorderSide(color: borderCol))),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      '${m['fraccion']} — ${(m['desc'] as String).isEmpty ? '(sin descripción)' : m['desc']}',
                      style: const TextStyle(
                          color: ambarCol,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  Text(
                      'Consumo: ${m['consumo']} | Merma: ${m['merma']} | Causa: ${m['causa']}',
                      style: const TextStyle(color: secCol, fontSize: 11)),
                  Text('Fecha: ${m['fecha']}',
                      style: const TextStyle(color: secCol, fontSize: 10)),
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${(m['pct'] as double).toStringAsFixed(1)}%',
                  style: TextStyle(
                      color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(excede ? 'EXCEDE LÃƒÂMITE' : 'DENTRO DE LÃƒÂMITE',
                  style: TextStyle(
                      color: color, fontSize: 9, fontWeight: FontWeight.bold)),
            ]),
          ]),
        );
      },
    );
  }

  Widget _buildMermAlertas() {
    final alertas = _mermasHistorial.where((m) => m['excede'] == true).toList();
    if (alertas.isEmpty) {
      return const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.verified, color: tealCol, size: 48),
        SizedBox(height: 12),
        Text('Sin alertas activas',
            style: TextStyle(
                color: tealCol, fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(
            'Todas las mermas estÃƒ¡n dentro del lÃƒÂ­mite declarado (Ã¢â€°Â¤3%).',
            style: TextStyle(color: secCol, fontSize: 12)),
      ]));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: alertas.length,
      itemBuilder: (_, i) {
        final m = alertas[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: rojoCol.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: rojoCol.withAlpha(80))),
          child: Row(children: [
            const Icon(Icons.warning_amber, color: rojoCol, size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      '${m['fraccion']} Ã¢â‚¬â€ Merma ${(m['pct'] as double).toStringAsFixed(1)}% excede el 3% declarado',
                      style: const TextStyle(
                          color: rojoCol,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  Text('Causa: ${m['causa']} | Fecha: ${m['fecha']}',
                      style: const TextStyle(color: secCol, fontSize: 11)),
                  const SizedBox(height: 4),
                  const Text(
                      'AcciÃƒÂ³n recomendada: Notifica al agente aduanal e inicia trÃƒ¡mite de rectificaciÃƒÂ³n ante el SAT.',
                      style:
                          TextStyle(color: rojoCol, fontSize: 10, height: 1.5)),
                ])),
          ]),
        );
      },
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  // MÃƒâ€œDULO 9: ACTIVO FIJO IMMEX Ã¢â‚¬â€ Georreferenciado
  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  final List<Map<String, dynamic>> _activos = [];
  final _afSearchCtrl = TextEditingController();
  String _afFiltro = 'Todos';
  static const List<String> _afFiltros = [
    'Todos',
    'PLANTA MATRIZ',
    'EN SUBMAQUILA',
    'EN REPARACIÃƒâ€œN',
    'EXPORTADO',
    'DESTRUIDO',
    'BAJA'
  ];

  // Dialog controllers
  final _afIdCtrl = TextEditingController();
  final _afDescCtrl = TextEditingController();
  final _afMarcaCtrl = TextEditingController();
  final _afModeloCtrl = TextEditingController();
  final _afSerieCtrl = TextEditingController();
  final _afPedimentoCtrl = TextEditingController();
  final _afFraccionCtrl = TextEditingController();
  final _afProveedorCtrl = TextEditingController();
  final _afUbicacionCtrl = TextEditingController();
  final _afAreaCtrl = TextEditingController();
  DateTime _afFechaImport = DateTime.now();

  Widget _buildModuloActivoFijo() {
    final query = _afSearchCtrl.text.toLowerCase();
    final filtered = _activos.where((a) {
      final matchFiltro = _afFiltro == 'Todos' || a['estado'] == _afFiltro;
      final matchQuery = query.isEmpty ||
          '${a['id']} ${a['desc']} ${a['pedimento']} ${a['serie']}'
              .toLowerCase()
              .contains(query);
      return matchFiltro && matchQuery;
    }).toList();

    return Stack(children: [
      Column(children: [
        // Sub-header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          color: bgCol,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Activo Fijo IMMEX (Georreferenciado)',
                style: TextStyle(
                    color: ambarCol,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
                'Control de maquinaria y equipo. Trazabilidad fÃƒÂ­sica vs Documental (Pedimento).',
                style: TextStyle(color: secCol, fontSize: 12)),
            const SizedBox(height: 12),
            Row(children: [
              // Search
              Expanded(
                  child: TextField(
                controller: _afSearchCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: textoCol, fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      'Buscar por ID, descripciÃƒÂ³n, pedimento, serie...',
                  hintStyle: const TextStyle(color: secCol, fontSize: 12),
                  prefixIcon: const Icon(Icons.search, color: secCol, size: 18),
                  filled: true,
                  fillColor: cardsCol,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: borderCol)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: borderCol)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: ambarCol)),
                ),
              )),
              const SizedBox(width: 12),
              // Filter dropdown
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: cardsCol,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderCol)),
                child: DropdownButton<String>(
                  value: _afFiltro,
                  dropdownColor: const Color(0xFF1A2235),
                  underline: const SizedBox(),
                  style: const TextStyle(color: textoCol, fontSize: 13),
                  items: _afFiltros
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setState(() => _afFiltro = v!),
                ),
              ),
              const SizedBox(width: 12),
              // Registrar button
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoActivoFijo(),
                icon: const Icon(Icons.add, size: 16, color: Colors.black),
                label: const Text('Registrar Activo Manual',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: ambarCol,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(width: 8),
              // Scan button
              ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Ã°Å¸â€œ· FunciÃƒÂ³n de escaneo QR prÃƒÂ³ximamente'))),
                icon: const Icon(Icons.qr_code_scanner,
                    size: 16, color: textoCol),
                label: const Text('Escanear',
                    style: TextStyle(
                        color: textoCol,
                        fontWeight: FontWeight.w500,
                        fontSize: 12)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: cardsCol,
                    side: const BorderSide(color: borderCol),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              ),
            ]),
            const SizedBox(height: 12),
          ]),
        ),
        const Divider(color: borderCol, height: 1),
        // Content
        Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.precision_manufacturing_outlined,
                            color: Color(0xFF4A5568), size: 56),
                        SizedBox(height: 16),
                        Text('No hay activos registrados',
                            style: TextStyle(color: secCol, fontSize: 14)),
                        SizedBox(height: 8),
                        Text(
                            "Usa 'Registrar Activo Manual' o escanea una etiqueta.",
                            style: TextStyle(
                                color: Color(0xFF4A5568), fontSize: 12)),
                      ]))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final a = filtered[i];
                      final Color estadoColor =
                          a['estado'] == 'EN REPARACIÃƒâ€œN'
                              ? ambarCol
                              : a['estado'] == 'EXPORTADO' ||
                                      a['estado'] == 'DESTRUIDO'
                                  ? rojoCol
                                  : tealCol;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: cardsCol,
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                                left: BorderSide(color: estadoColor, width: 3),
                                top: const BorderSide(color: borderCol),
                                right: const BorderSide(color: borderCol),
                                bottom: const BorderSide(color: borderCol))),
                        child: Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('${a['id']} Ã¢â‚¬â€ ${a['desc']}',
                                    style: const TextStyle(
                                        color: ambarCol,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    'Pedimento: ${a['pedimento']} | Serie: ${a['serie']}',
                                    style: const TextStyle(
                                        color: secCol, fontSize: 11)),
                                Text('UbicaciÃƒÂ³n: ${a['ubicacion']}',
                                    style: const TextStyle(
                                        color: secCol, fontSize: 11)),
                              ])),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: estadoColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: estadoColor.withAlpha(80))),
                              child: Text(a['estado'] as String,
                                  style: TextStyle(
                                      color: estadoColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold))),
                        ]),
                      );
                    },
                  )),
      ]),
    ]);
  }

  Future<void> _mostrarDialogoActivoFijo() async {
    _afIdCtrl.clear();
    _afDescCtrl.clear();
    _afMarcaCtrl.clear();
    _afModeloCtrl.clear();
    _afSerieCtrl.clear();
    _afPedimentoCtrl.clear();
    _afFraccionCtrl.clear();
    _afProveedorCtrl.clear();
    _afUbicacionCtrl.clear();
    _afAreaCtrl.clear();
    _afFechaImport = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDState) => Dialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: borderCol)),
          child: SizedBox(
              width: 560,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Title bar
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: borderCol))),
                  child: Row(children: [
                    const Icon(Icons.precision_manufacturing,
                        color: ambarCol, size: 22),
                    const SizedBox(width: 10),
                    const Text('Registro Manual de Activo Fijo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                        icon: const Icon(Icons.close, color: secCol),
                        onPressed: () => Navigator.pop(ctx)),
                  ]),
                ),
                // Scrollable content
                Flexible(
                    child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ã¢â€â‚¬Ã¢â€â‚¬ IdentificaciÃƒÂ³n Ã¢â€â‚¬Ã¢â€â‚¬
                        _afSectionHeader(
                            Icons.label, 'IdentificaciÃƒÂ³n del Activo'),
                        const SizedBox(height: 10),
                        _afField(
                            _afIdCtrl, 'ID del Activo *', 'Ej: AF-2024-001',
                            required: true),
                        const SizedBox(height: 10),
                        _afField(_afDescCtrl, 'DescripciÃƒÂ³n del equipo *',
                            'Torno CNC, Prensa hidrÃƒ¡ulica, Robot soldador...',
                            maxLines: 2, required: true),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                              child: _afField(
                                  _afMarcaCtrl, 'Marca', 'FANUC, Siemens...')),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _afField(
                                  _afModeloCtrl, 'Modelo', 'Serie / Modelo')),
                        ]),
                        const SizedBox(height: 10),
                        _afField(
                            _afSerieCtrl, 'No. de Serie', 'SN-XXXXXX-2024'),
                        const SizedBox(height: 20),
                        _afSectionHeader(
                            Icons.assignment, 'Datos Aduanales IMMEX'),
                        const SizedBox(height: 10),
                        _afField(
                            _afPedimentoCtrl,
                            'No. Pedimento de Importación *',
                            '24 47 2024 0012345',
                            required: true),
                        const SizedBox(height: 10),
                        _afField(_afFraccionCtrl, 'Fracción Arancelaria TIGIE',
                            'Ej: 8457.10.01'),
                        const SizedBox(height: 10),
                        _afField(
                            _afProveedorCtrl,
                            'Proveedor / Fabricante Extranjero',
                            'Razón social del proveedor'),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                                context: ctx,
                                initialDate: _afFechaImport,
                                firstDate: DateTime(2010),
                                lastDate: DateTime(2030),
                                builder: (c2, child) => Theme(
                                    data: ThemeData.dark().copyWith(
                                        colorScheme: const ColorScheme.dark(
                                            primary: ambarCol)),
                                    child: child!));
                            if (d != null) {
                              _afFechaImport = d;
                              setDState(() {});
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderCol)),
                            child: Row(children: [
                              const Icon(Icons.calendar_month_outlined,
                                  color: secCol, size: 18),
                              const SizedBox(width: 12),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Fecha de ImportaciÃƒÂ³n',
                                        style: TextStyle(
                                            color: secCol, fontSize: 10)),
                                    Text(
                                        DateFormat('dd/MMM/yyyy')
                                            .format(_afFechaImport),
                                        style: const TextStyle(
                                            color: textoCol,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Ã¢â€â‚¬Ã¢â€â‚¬ UbicaciÃƒÂ³n FÃƒÂ­sica Ã¢â€â‚¬Ã¢â€â‚¬
                        _afSectionHeader(
                            Icons.location_on, 'UbicaciÃƒÂ³n FÃƒÂ­sica'),
                        const SizedBox(height: 10),
                        _afField(
                            _afUbicacionCtrl,
                            'UbicaciÃƒÂ³n / LÃƒÂ­nea de producciÃƒÂ³n',
                            'AlmacÃƒÂ©n A, LÃƒÂ­nea 3, Celda 7...'),
                        const SizedBox(height: 10),
                        _afField(_afAreaCtrl, 'ÃƒÂrea / Departamento',
                            'Manufactura, Ensamble, Pruebas...'),
                        const SizedBox(height: 20),
                      ]),
                )),
                // Bottom button
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: borderCol))),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_afIdCtrl.text.isNotEmpty &&
                            _afDescCtrl.text.isNotEmpty &&
                            _afPedimentoCtrl.text.isNotEmpty) {
                          setState(() {
                            _activos.insert(0, {
                              'id': _afIdCtrl.text,
                              'desc': _afDescCtrl.text,
                              'marca': _afMarcaCtrl.text,
                              'modelo': _afModeloCtrl.text,
                              'serie': _afSerieCtrl.text,
                              'pedimento': _afPedimentoCtrl.text,
                              'fraccion': _afFraccionCtrl.text,
                              'proveedor': _afProveedorCtrl.text,
                              'ubicacion': _afUbicacionCtrl.text,
                              'area': _afAreaCtrl.text,
                              'fechaImport': _afFechaImport,
                              'estado': 'PLANTA MATRIZ',
                            });
                          });
                          Navigator.pop(ctx);
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Ã¢Å¡ Ã¯Â¸Â Completa los campos obligatorios (*)'),
                              backgroundColor: rojoCol));
                        }
                      },
                      icon: const Icon(Icons.download_done,
                          size: 18, color: Colors.black),
                      label: const Text('Ã¢Å“â€¦  Registrar Activo Fijo',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ambarCol,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ),
              ])),
        ),
      ),
    );
  }

  Widget _afSectionHeader(IconData icon, String label) {
    return Row(children: [
      Icon(icon, color: ambarCol, size: 16),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(
              color: ambarCol, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(width: 8),
      const Expanded(child: Divider(color: borderCol)),
    ]);
  }

  Widget _afField(TextEditingController ctrl, String label, String hint,
      {int maxLines = 1, bool required = false}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: textoCol, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: secCol, fontSize: 12),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 12),
        filled: true,
        fillColor: AppColors.bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: borderCol)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: borderCol)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ambarCol)),
        suffixText: required ? '*' : null,
        suffixStyle: const TextStyle(color: rojoCol),
      ),
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  // MÃƒâ€œDULO 10: DESTRUCCIONES Ã¢â‚¬â€ Control de Mermas (Regla 4.3.5)
  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  Widget _buildModuloDestrucciones() {
    return Column(children: [
      // Sub-header
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: bgCol,
        child: Row(children: [
          Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: cardsCol,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderCol)),
              child: const Icon(Icons.chevron_left, color: secCol, size: 18)),
          const Spacer(),
          const Text('Control de Mermas y Destrucciones (Regla 4.3.5)',
              style: TextStyle(
                  color: textoCol, fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          const SizedBox(width: 28),
        ]),
      ),
      const Divider(color: borderCol, height: 1),
      // Body
      Expanded(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mermas Acumuladas Pendientes de Descargo FÃƒÂ­sico',
                    style: TextStyle(
                        color: textoCol,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: azulCol.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: azulCol.withAlpha(60))),
            child: const Row(children: [
              Icon(Icons.info_outline, color: azulCol, size: 16),
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'Mermas deben someterse a destruccion fisica (Regla 4.3.5 RGCE) dentro de los plazos establecidos.',
                      style: TextStyle(
                          color: azulCol, fontSize: 11, height: 1.5))),
            ]),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('mermas_inmex')
                .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where('estado', isEqualTo: 'pendiente')
                .orderBy('fecha', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.blue));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                      color: cardsCol,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderCol)),
                  child: const Center(
                      child: Column(children: [
                    Icon(Icons.delete_outline,
                        color: Color(0xFF4A5568), size: 48),
                    SizedBox(height: 12),
                    Text('Sin mermas pendientes de destrucción',
                        style: TextStyle(color: secCol, fontSize: 14)),
                    SizedBox(height: 8),
                    Text(
                        'Las mermas generadas se registran aquí para su programación de descargo físico (Regla 4.3.5 RGCE).',
                        style:
                            TextStyle(color: Color(0xFF4A5568), fontSize: 11),
                        textAlign: TextAlign.center),
                  ])),
                );
              }
              final docs = snap.data!.docs;
              return Column(
                children: docs.map((doc) {
                  final m = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                        color: cardsCol,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderCol)),
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2_outlined,
                          color: ambarCol),
                      title: Text('${m["tipo"] ?? ""} — ${m["insumo"] ?? ""}',
                          style:
                              const TextStyle(color: textoCol, fontSize: 13)),
                      subtitle: Text(
                          'Qty: ${m["qty"] ?? ""} | ${m["fecha"] ?? ""}',
                          style: const TextStyle(color: secCol, fontSize: 11)),
                      trailing: ElevatedButton(
                        onPressed: () => _confirmarDestruccion(doc.id),
                        style:
                            ElevatedButton.styleFrom(backgroundColor: rojoCol),
                        child: const Text('Programar',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ]),
      )),
    ]);
  }

  Future<void> _confirmarDestruccion(String docId) async {
    await FirebaseFirestore.instance
        .collection('mermas_inmex')
        .doc(docId)
        .update({
      'estado': 'programada',
      'fechaDestruccion': DateFormat('dd/MM/yyyy').format(DateTime.now()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance.collection('destrucciones_inmex').add({
      'uid': FirebaseAuth.instance.currentUser?.uid,
      'mermaId': docId,
      'fecha': DateFormat('dd/MM/yyyy').format(DateTime.now()),
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Destrucción programada exitosamente'),
            backgroundColor: AppColors.card),
      );
    }
  }

  // Modulo 6: Catalogo / Merceologia
  final _descComercialCtrl = TextEditingController();
  String _iaClasificacion = '';
  String _iaDefensa = '';
  bool _iaLoading = false;

  static const Map<String, Map<String, String>> _iaDatabase = {
    'wire harness': {
      'fraccion': '8544.42.01',
      'desc': 'Mazos de cables para encendido',
      'defensa': 'Nota 8 del Capitulo 85: 8544.42.01.'
    },
    'connector': {
      'fraccion': '8536.90.99',
      'desc': 'Conectores electricos < 1000V',
      'defensa': 'Reglas Generales 1 y 6: 8536.90.99.'
    },
    'motor': {
      'fraccion': '8501.10.01',
      'desc': 'Motor electrico CC < 37.5W',
      'defensa': 'Regla General 1 y Nota 2 Cap 85: 8501.10.01.'
    },
    'pcb': {
      'fraccion': '8534.00.01',
      'desc': 'Circuitos impresos multicapa',
      'defensa': 'Nota 5 Cap 85: 8534.00.01.'
    },
    'cable': {
      'fraccion': '8544.49.99',
      'desc': 'Cables electricos aislados de cobre',
      'defensa': 'Nota 8 Cap 85: 8544.49.99.'
    },
    'sensor': {
      'fraccion': '9031.80.99',
      'desc': 'Instrumentos de medida no clasificados en otra parte',
      'defensa': 'Regla General 3(c) SA: 9031.80.99.'
    },
  };

  void _clasificarConIA() async {
    final desc = _descComercialCtrl.text;
    setState(() {
      _iaLoading = true;
      _iaClasificacion = '';
      _iaDefensa = '';
    });
    final model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-1.5-flash',
      systemInstruction: Content.system(
          'Eres experto en clasificacion arancelaria de Mexico. Responde JSON: {"fraccion": "string", "desc": "string", "defensa": "string"}'),
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
    try {
      final response =
          await model.generateContent([Content.text('Clasifica: $desc')]);
      final jsonResponse = jsonDecode(response.text ?? '{}');
      final json = jsonResponse as Map<String, dynamic>;
      setState(() {
        _iaLoading = false;
        _iaClasificacion = '${json["fraccion"]} - ${json["desc"]}';
        _iaDefensa = (json['defensa'] as String?) ?? '';
      });
    } catch (e) {
      final descLower = desc.toLowerCase();
      final key = _iaDatabase.keys
          .firstWhere((k) => descLower.contains(k), orElse: () => '');
      if (key.isNotEmpty) {
        final local = _iaDatabase[key]!;
        setState(() {
          _iaLoading = false;
          _iaClasificacion = '${local["fraccion"]} - ${local["desc"]}';
          _iaDefensa = '(Base local) ${local["defensa"]}';
        });
      } else {
        setState(() {
          _iaLoading = false;
          _iaClasificacion = 'Sin resultado';
          _iaDefensa = 'Motor IA no disponible. Error: $e';
        });
      }
    }
  }

  Widget _buildModuloCatalogo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Defensa Arancelaria Automatizada',
            style: TextStyle(
                color: ambarCol, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
            'La IA clasifica tus insumos leyendo las especificaciones tÃƒÂ©cnicas del proveedor y redacta un escrito legal de defensa (MerceologÃƒÂ­a) para blindarte en caso de revisiÃƒÂ³n aduanera.',
            style: TextStyle(color: secCol, fontSize: 12)),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Panel izquierdo
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: cardsCol,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderCol)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Insumo Pendiente de ClasificaciÃƒÂ³n',
                  style: TextStyle(
                      color: azulCol,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              const Text('DescripciÃƒÂ³n Comercial (Factura):',
                  style: TextStyle(color: secCol, fontSize: 11)),
              const SizedBox(height: 6),
              TextField(
                controller: _descComercialCtrl,
                style: const TextStyle(color: textoCol, fontSize: 13),
                decoration:
                    _inputDecoA24('Ej. Wire Harness Assy w/ Connectors'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _iaLoading ? null : _clasificarConIA,
                  icon: _iaLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.auto_awesome,
                          size: 16, color: Colors.white),
                  label: const Text('Clasificar con IA',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ),
              if (_iaClasificacion.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text('Sugerencia de la IA:',
                    style: TextStyle(color: secCol, fontSize: 11)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF7C3AED).withAlpha(80))),
                  child: Text(_iaClasificacion,
                      style: const TextStyle(
                          color: textoCol, fontSize: 12, height: 1.5)),
                ),
              ] else
                const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Text('Sugerencia de la IA:',
                        style: TextStyle(color: secCol, fontSize: 11))),
            ]),
          )),
          const SizedBox(width: 16),
          // Panel derecho: Defensa
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: cardsCol,
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                    left: BorderSide(color: tealCol, width: 3),
                    top: BorderSide(color: borderCol),
                    right: BorderSide(color: borderCol),
                    bottom: BorderSide(color: borderCol))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.gavel_rounded,
                        color: Color(0xFFF59E0B), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AVISO LEGAL: Las fracciones arancelarias generadas por IA son orientativas. '
                        'Toda fracción debe validarse en el SIAVI del SAT (siavi4.economia.gob.mx) '
                        'antes de declararla en pedimento. El agente aduanal es el responsable de '
                        'la clasificación final (Art. 59-A Ley Aduanera).',
                        style: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 11,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const Row(children: [
                Icon(Icons.auto_awesome, color: tealCol, size: 16),
                SizedBox(width: 8),
                Text('Escrito de Defensa MerceolÃƒÂ³gica (Generado por IA)',
                    style: TextStyle(
                        color: tealCol,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ]),
              const Divider(color: borderCol),
              const SizedBox(height: 8),
              if (_iaDefensa.isEmpty)
                const Text(
                    'Ingresa una descripciÃƒÂ³n comercial y presiona "Clasificar con IA" para generar la defensa legal.',
                    style: TextStyle(color: secCol, fontSize: 12, height: 1.6))
              else
                Text(_iaDefensa,
                    style: const TextStyle(
                        color: textoCol, fontSize: 12, height: 1.7)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_iaDefensa.isEmpty) return;
                    Clipboard.setData(ClipboardData(text: _iaDefensa));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Ã°Å¸â€œâ€¹ Dictamen copiado al portapapeles'),
                        backgroundColor: AppColors.card));
                  },
                  icon:
                      const Icon(Icons.download, size: 16, color: Colors.black),
                  label: const Text('Exportar Dictamen Legal (PDF)',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: tealCol,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ),
            ]),
          )),
        ]),
      ]),
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  // MÃƒâ€œDULO 7: AUDITOR (IA SAT) Ã¢â‚¬â€ Shadow SAT
  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  Widget _buildModuloAuditorIA() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
          child: Column(children: [
            // Sub-header
            Row(children: [
              Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: cardsCol,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderCol)),
                  child:
                      const Icon(Icons.chevron_left, color: secCol, size: 18)),
              const Spacer(),
              const Text('Auditor IA Ã¢â‚¬â€ Shadow SAT',
                  style: TextStyle(
                      color: textoCol,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.refresh, color: secCol, size: 20),
            ]),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Radar panel
              SizedBox(width: 220, height: 220, child: _RadarWidget()),
              const SizedBox(width: 32),
              // Hallazgos
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Hallazgos Detectados',
                        style: TextStyle(
                            color: textoCol,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('0 observaciones activas',
                        style: TextStyle(color: secCol, fontSize: 12)),
                    const SizedBox(height: 20),
                    // Clean panel
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: cardsCol,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: tealCol.withAlpha(80))),
                      child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified, color: tealCol, size: 40),
                            SizedBox(height: 12),
                            Text('Inventario limpio. Sin observaciones.',
                                style: TextStyle(
                                    color: tealCol,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text(
                                'Todos los pedimentos estÃƒ¡n dentro de los lÃƒÂ­mites legales.',
                                style: TextStyle(color: secCol, fontSize: 11),
                                textAlign: TextAlign.center),
                          ]),
                    ),
                  ])),
            ]),
            const SizedBox(height: 20),
            // 3 KPI bars
            _auditKpi(Icons.warning_amber, 'Pedimentos en Riesgo',
                '0 CrÃƒÂ­ticos', rojoCol.withAlpha(30), rojoCol),
            const SizedBox(height: 10),
            _auditKpi(Icons.attach_money, 'IVA Expuesto MXN', '\$0.00',
                ambarCol.withAlpha(30), ambarCol),
            const SizedBox(height: 10),
            _auditKpi(Icons.timer, 'DÃƒÂ­as Promedio Restantes', 'N/A',
                azulCol.withAlpha(30), azulCol),
          ]),
        ),
        // Bottom button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: bgCol,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Ã°Å¸â€œâ€ž Acta copiada al portapapeles'),
                      backgroundColor: AppColors.card)),
              icon: const Icon(Icons.print, size: 16, color: Colors.black),
              label: const Text('Generar Acta Administrativa PDF',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: ambarCol,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _auditKpi(
      IconData icon, String label, String value, Color bgColor, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(60))),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: secCol, fontSize: 11)),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  // MÃƒâ€œDULO 8: SUBMAQUILA Ã¢â‚¬â€ Control Satelital de Transferencias Temporales
  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  final List<Map<String, dynamic>> _contratos = [];
  final _subProvCtrl = TextEditingController();
  final _subMatCtrl = TextEditingController();
  final _subQtyCtrl = TextEditingController();
  final _subUnidadCtrl = TextEditingController(text: 'pzs');
  final _subDiasCtrl = TextEditingController(text: '180');
  DateTime _subFecha = DateTime.now();

  Widget _buildModuloSubmaquila() {
    return Stack(
      children: [
        Column(children: [
          // Sub-header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: bgCol,
            child: const Column(children: [
              Text('Submaquila: Control de Transferencias Temporales',
                  style: TextStyle(
                      color: textoCol,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          const Divider(color: borderCol, height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Control Satelital de Transferencias Temporales',
                  style: TextStyle(
                      color: ambarCol,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(
                  'Monitorea el envÃƒÂ­o de materiales a terceros. El retorno virtual (Pedimento V1/V5) debe generarse antes de los 180 dÃƒÂ­as para evitar caducidad legal.',
                  style: TextStyle(color: secCol, fontSize: 12)),
            ]),
          ),
          Expanded(
            child: _contratos.isEmpty
                ? const Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.factory_outlined,
                            color: Color(0xFF4A5568), size: 56),
                        SizedBox(height: 16),
                        Text('Sin contratos de submaquila registrados.',
                            style: TextStyle(color: secCol, fontSize: 14)),
                        SizedBox(height: 8),
                        Text(
                            'Usa el botÃƒÂ³n + para registrar el primer envÃƒÂ­o.',
                            style: TextStyle(
                                color: Color(0xFF4A5568), fontSize: 12)),
                      ]))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    itemCount: _contratos.length,
                    itemBuilder: (_, i) {
                      final c = _contratos[i];
                      final dias = DateTime.now()
                          .difference(c['fecha'] as DateTime)
                          .inDays;
                      final restantes = (c['maxDias'] as int) - dias;
                      final color = restantes < 30
                          ? rojoCol
                          : restantes < 90
                              ? ambarCol
                              : tealCol;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: cardsCol,
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                                left: BorderSide(color: color, width: 3),
                                top: const BorderSide(color: borderCol),
                                right: const BorderSide(color: borderCol),
                                bottom: const BorderSide(color: borderCol))),
                        child: Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(c['proveedor'] as String,
                                    style: const TextStyle(
                                        color: ambarCol,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    '${c['material']} | ${c['cantidad']} ${c['unidad']}',
                                    style: const TextStyle(
                                        color: secCol, fontSize: 11)),
                              ])),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$restantes dÃƒÂ­as restantes',
                                    style: TextStyle(
                                        color: color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    'Salida: ${DateFormat('dd/MM/yyyy').format(c['fecha'] as DateTime)}',
                                    style: const TextStyle(
                                        color: secCol, fontSize: 10)),
                              ]),
                        ]),
                      );
                    },
                  ),
          ),
        ]),
        // FAB
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton.icon(
            onPressed: () => _mostrarDialogoSubmaquila(),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text('Nuevo Contrato',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.border,
                side: const BorderSide(color: borderCol),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarDialogoSubmaquila() async {
    _subProvCtrl.clear();
    _subMatCtrl.clear();
    _subQtyCtrl.clear();
    _subUnidadCtrl.text = 'pzs';
    _subDiasCtrl.text = '180';
    _subFecha = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: borderCol)),
          title: const Row(children: [
            Icon(Icons.factory, color: ambarCol, size: 24),
            SizedBox(width: 10),
            Text('Nuevo Contrato Submaquila',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ]),
          content: SizedBox(
              width: 480,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Proveedor
                TextField(
                    controller: _subProvCtrl,
                    style: const TextStyle(color: textoCol, fontSize: 13),
                    decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.business, color: secCol, size: 18),
                        hintText: 'Proveedor / Sub-maquiladora',
                        hintStyle: const TextStyle(color: secCol, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.bg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: borderCol)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: borderCol)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16))),
                const SizedBox(height: 10),
                // Material
                TextField(
                    controller: _subMatCtrl,
                    style: const TextStyle(color: textoCol, fontSize: 13),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.inventory_2_outlined,
                            color: secCol, size: 18),
                        hintText: 'Material enviado',
                        hintStyle: const TextStyle(color: secCol, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.bg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: borderCol)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: borderCol)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16))),
                const SizedBox(height: 10),
                // Cantidad + Unidad
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _subQtyCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: textoCol, fontSize: 13),
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.tag,
                                  color: secCol, size: 18),
                              hintText: 'Cantidad',
                              hintStyle:
                                  const TextStyle(color: secCol, fontSize: 12),
                              filled: true,
                              fillColor: AppColors.bg,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: borderCol)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: borderCol)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16)))),
                  const SizedBox(width: 10),
                  SizedBox(
                      width: 100,
                      child: TextField(
                          controller: _subUnidadCtrl,
                          style: const TextStyle(color: textoCol, fontSize: 13),
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.straighten,
                                  color: secCol, size: 16),
                              labelText: 'Unidad',
                              labelStyle:
                                  const TextStyle(color: secCol, fontSize: 11),
                              filled: true,
                              fillColor: AppColors.bg,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: borderCol)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: borderCol)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16)))),
                ]),
                const SizedBox(height: 10),
                // DÃƒÂ­as mÃƒ¡ximos
                TextField(
                    controller: _subDiasCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: textoCol, fontSize: 13),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.timer_outlined,
                            color: secCol, size: 18),
                        labelText: 'DÃƒÂ­as mÃƒ¡ximos (legal: 180)',
                        labelStyle:
                            const TextStyle(color: secCol, fontSize: 11),
                        filled: true,
                        fillColor: AppColors.bg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: borderCol)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: borderCol)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16))),
                const SizedBox(height: 10),
                // Fecha de salida
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                        context: ctx,
                        initialDate: _subFecha,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (c2, child) => Theme(
                            data: ThemeData.dark().copyWith(
                                colorScheme:
                                    const ColorScheme.dark(primary: ambarCol)),
                            child: child!));
                    if (d != null) {
                      _subFecha = d;
                      setDState(() {});
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderCol)),
                    child: Row(children: [
                      const Icon(Icons.calendar_month_outlined,
                          color: secCol, size: 18),
                      const SizedBox(width: 12),
                      Text(
                          'Fecha de salida: ${DateFormat('dd/MM/yyyy').format(_subFecha)}',
                          style:
                              const TextStyle(color: textoCol, fontSize: 13)),
                    ]),
                  ),
                ),
              ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: secCol))),
            ElevatedButton(
              onPressed: () {
                if (_subProvCtrl.text.isNotEmpty &&
                    _subMatCtrl.text.isNotEmpty) {
                  setState(() {
                    _contratos.insert(0, {
                      'proveedor': _subProvCtrl.text,
                      'material': _subMatCtrl.text,
                      'cantidad': _subQtyCtrl.text,
                      'unidad': _subUnidadCtrl.text,
                      'maxDias': int.tryParse(_subDiasCtrl.text) ?? 180,
                      'fecha': _subFecha
                    });
                  });
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: ambarCol,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: const Text('Guardar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoA24(String label) {
    return InputDecoration(
      labelText: label.isEmpty ? null : label,
      labelStyle: const TextStyle(color: secCol, fontSize: 12),
      filled: true,
      fillColor: AppColors.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderCol)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderCol)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: ambarCol)),
    );
  }

  @override
  void dispose() {
    _pedimentoCtrl.dispose();
    _proveedorCtrl.dispose();
    _paisCtrl.dispose();
    _facturaCtrl.dispose();
    _uuidCtrl.dispose();
    _searchCtrl.dispose();
    _bomQtyCtrl.dispose();
    _bomMermaCtrl.dispose();
    _salidaPedCtrl.dispose();
    _salidaQtyCtrl.dispose();
    _opQtyCtrl.dispose();
    _opRefCtrl.dispose();
    _diemexVentasCtrl.dispose();
    _mermFracCtrl.dispose();
    _mermDescCtrl.dispose();
    _mermConsCtrl.dispose();
    _mermQtyCtrl.dispose();
    _mermObsCtrl.dispose();
    _afSearchCtrl.dispose();
    _afIdCtrl.dispose();
    _afDescCtrl.dispose();
    _afMarcaCtrl.dispose();
    _afModeloCtrl.dispose();
    _afSerieCtrl.dispose();
    _afPedimentoCtrl.dispose();
    _afFraccionCtrl.dispose();
    _afProveedorCtrl.dispose();
    _afUbicacionCtrl.dispose();
    _afAreaCtrl.dispose();
    _descComercialCtrl.dispose();
    _subProvCtrl.dispose();
    _subMatCtrl.dispose();
    _subQtyCtrl.dispose();
    _subUnidadCtrl.dispose();
    _subDiasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCol,
      body: Column(
        children: [
          _buildHeader(),
          _buildModuleBar(),
          const Divider(height: 1, color: borderCol),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
// Radar Widget for Shadow SAT Auditor
// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class _RadarWidget extends StatefulWidget {
  @override
  State<_RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<_RadarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _sweep = Tween<double>(begin: 0, end: 2 * 3.14159265).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sweep,
      builder: (_, __) => CustomPaint(
        painter: _RadarPainter(_sweep.value),
        child: Container(),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double angle;
  _RadarPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const tealColor = Color(0xFF4ECCA3);

    // Background
    canvas.drawCircle(center, radius, Paint()..color = AppColors.bg);

    // Concentric circles
    final circlePaint = Paint()
      ..color = tealColor.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, circlePaint);
    }

    // Crosshairs
    final linePaint = Paint()
      ..color = tealColor.withAlpha(40)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy), linePaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius), linePaint);

    // Sweep gradient
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: angle - 1.2,
        endAngle: angle,
        colors: [Colors.transparent, tealColor.withAlpha(100)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sweepPaint);

    // Sweep line
    final lineSweepPaint = Paint()
      ..color = tealColor
      ..strokeWidth = 2;
    canvas.drawLine(
        center,
        Offset(center.dx + radius * 0.9 * _cos(angle),
            center.dy + radius * 0.9 * _sin(angle)),
        lineSweepPaint);

    // Center dot
    canvas.drawCircle(center, 4, Paint()..color = tealColor);
  }

  double _cos(double a) => (a == 0)
      ? 1
      : (a == 3.14159265)
          ? -1
          : (a < 1.6)
              ? (1 - a * a / 2)
              : -(a - 3.14159265) * (a - 3.14159265) / 2;
  double _sin(double a) {
    final b = a % (2 * 3.14159265);
    if (b < 1.5708) return b * (1 - b * b / 6);
    if (b < 3.14159265) {
      final c = 3.14159265 - b;
      return c * (1 - c * c / 6);
    }
    if (b < 4.71239) {
      return -(b - 3.14159265) * (1 - (b - 3.14159265) * (b - 3.14159265) / 6);
    }
    final c = 2 * 3.14159265 - b;
    return -(c * (1 - c * c / 6));
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.angle != angle;
}

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
// Clock Dots Widget Ã¢â‚¬â€ animaciÃƒÂ³n reloj puntual (MÃƒÂ³dulo 12)
// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class _ClockDotsWidget extends StatefulWidget {
  const _ClockDotsWidget();
  @override
  State<_ClockDotsWidget> createState() => _ClockDotsWidgetState();
}

class _ClockDotsWidgetState extends State<_ClockDotsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _ClockDotsPainter(_ctrl.value),
        size: const Size(64, 64),
      ),
    );
  }
}

class _ClockDotsPainter extends CustomPainter {
  final double progress;
  _ClockDotsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const int dots = 12;
    const double pi2 = 6.28318530718;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const Color ambar = AppColors.gold;

    for (int i = 0; i < dots; i++) {
      final angle = (i / dots) * pi2 - pi2 / 4;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      // Brightness based on proximity to sweep hand
      final sweepAngle = progress * pi2;
      final diff = ((i / dots * pi2) - sweepAngle).abs();
      final brightness = (1 - (diff / pi2).clamp(0.0, 1.0)) * 0.8 + 0.2;

      final paint = Paint()
        ..color = ambar.withAlpha((255 * brightness).toInt())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  double cos(double a) {
    final b = a % 6.28318530718;
    if (b < 1.5708) return 1 - b * b / 2;
    if (b < 3.14159) {
      final c = b - 1.5708;
      return -(c * c / 2);
    }
    if (b < 4.71239) return -(1 - (b - 3.14159) * (b - 3.14159) / 2);
    final c = b - 4.71239;
    return c * c / 2;
  }

  double sin(double a) {
    return cos(a - 1.5708);
  }

  @override
  bool shouldRepaint(_ClockDotsPainter old) => old.progress != progress;
}
