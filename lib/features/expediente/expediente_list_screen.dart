import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/error_state_widget.dart';

class ExpedienteListScreen extends StatefulWidget {
  const ExpedienteListScreen({super.key});

  @override
  State<ExpedienteListScreen> createState() => _ExpedienteListScreenState();
}

class _ExpedienteListScreenState extends State<ExpedienteListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  final List<String> _filters = [
    'Todos',
    'Importación',
    'Exportación',
    'Activos',
    'Liberados',
    'Cerrados'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    final formKey = GlobalKey<FormState>();
    final String numExpediente =
        'EXP-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
    String clienteNombre = '';
    String tipo = 'importacion';
    String aduana = '';

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Nuevo Expediente',
              style: TextStyle(color: Color(0xFFF8FAFC))),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: numExpediente,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Número de Expediente',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Cliente',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                    onSaved: (v) => clienteNombre = v ?? '',
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: tipo,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                    items: const [
                      DropdownMenuItem(
                          value: 'importacion', child: Text('Importación')),
                      DropdownMenuItem(
                          value: 'exportacion', child: Text('Exportación')),
                    ],
                    onChanged: (v) => tipo = v ?? 'importacion',
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Aduana',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                    onSaved: (v) => aduana = v ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6)),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  try {
                    await FirebaseFirestore.instance
                        .collection('expedientes_completos')
                        .add({
                      'uid': user.uid,
                      'numExpediente': numExpediente,
                      'clienteId': '',
                      'clienteNombre': clienteNombre,
                      'tipo': tipo,
                      'regimen': 'A1',
                      'aduana': aduana,
                      'fraccionPrincipal': '',
                      'valorFob': 0.0,
                      'moneda': 'USD',
                      'incoterm': '',
                      'descripcionMercancia': '',
                      'embarqueId': '',
                      'numPedimento': '',
                      'estado': 'pendiente_docs',
                      'score_preglosa': null,
                      'cartaInstrucciones': '',
                      'resultadoSemaforo': '',
                      'fechaLiberacion': null,
                      'notas': '',
                      'documentos': <String>[],
                      'created_at': FieldValue.serverTimestamp(),
                      'updated_at': FieldValue.serverTimestamp(),
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Expediente creado con éxito')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Crear', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendiente_docs':
        return const Color(0xFFF59E0B);
      case 'en_transito':
        return const Color(0xFF3B82F6);
      case 'listo_despacho':
        return AppColors.green;
      case 'presentado':
        return const Color(0xFFF97316); // Naranja
      case 'liberado':
        return const Color(0xFF22C55E); // Verde fuerte
      case 'cerrado':
        return const Color(0xFF6B7280); // Gris
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pendiente_docs':
        return 'Pendiente Docs';
      case 'en_transito':
        return 'En Tránsito';
      case 'listo_despacho':
        return 'Listo Despacho';
      case 'presentado':
        return 'Presentado';
      case 'liberado':
        return 'Liberado';
      case 'cerrado':
        return 'Cerrado';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Expedientes Digitales',
            style: TextStyle(color: Color(0xFFF8FAFC))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                  decoration: InputDecoration(
                    hintText: 'Buscar por expediente, cliente, fracción...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF334155),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: _filters
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(f),
                              selected: _selectedFilter == f,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedFilter = f);
                                }
                              },
                              selectedColor: const Color(0xFF3B82F6),
                              backgroundColor: const Color(0xFF334155),
                              labelStyle: TextStyle(
                                color: _selectedFilter == f
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text('Inicia sesión para ver expedientes',
                  style: TextStyle(color: Color(0xFF94A3B8))))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('expedientes_completos')
                  .where('uid', isEqualTo: user.uid)
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorStateWidget(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(() {}),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SkeletonListView();
                }

                final docs = snapshot.data?.docs ?? [];

                // Client-side filtering because Firestore doesn't easily support all these combined with search
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final numExp =
                      (data['numExpediente'] ?? '').toString().toLowerCase();
                  final cliente =
                      (data['clienteNombre'] ?? '').toString().toLowerCase();
                  final fraccion = (data['fraccionPrincipal'] ?? '')
                      .toString()
                      .toLowerCase();
                  final estado = data['estado'] as String? ?? '';
                  final tipo = data['tipo'] as String? ?? '';

                  if (_searchQuery.isNotEmpty &&
                      !numExp.contains(_searchQuery) &&
                      !cliente.contains(_searchQuery) &&
                      !fraccion.contains(_searchQuery)) {
                    return false;
                  }

                  switch (_selectedFilter) {
                    case 'Importación':
                      return tipo == 'importacion';
                    case 'Exportación':
                      return tipo == 'exportacion';
                    case 'Activos':
                      return estado != 'liberado' && estado != 'cerrado';
                    case 'Liberados':
                      return estado == 'liberado';
                    case 'Cerrados':
                      return estado == 'cerrado';
                    default:
                      return true; // Todos
                  }
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                      child: Text('No hay expedientes',
                          style: TextStyle(color: Color(0xFF94A3B8))));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    await Future<void>.delayed(
                        const Duration(milliseconds: 800));
                  },
                  color: AppColors.gold,
                  backgroundColor: AppColors.card,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                          filteredDocs[index].data() as Map<String, dynamic>;
                      final docId = filteredDocs[index].id;
                      final createdTs = data['created_at'] as Timestamp?;
                      int dias = 0;
                      if (createdTs != null) {
                        dias = DateTime.now()
                            .difference(createdTs.toDate())
                            .inDays;
                      }

                      return Card(
                        color: const Color(0xFF1E293B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF475569)),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () => context.push('/expediente/$docId'),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        (data['numExpediente'] ?? 'S/N')
                                            .toString(),
                                        style: const TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                                (data['estado'] ?? '')
                                                    .toString())
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _formatStatus(
                                            (data['estado'] ?? '').toString()),
                                        style: TextStyle(
                                            color: _getStatusColor(
                                                (data['estado'] ?? '')
                                                    .toString()),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    (data['clienteNombre'] ?? 'Sin Cliente')
                                        .toString(),
                                    style: const TextStyle(
                                        color: Color(0xFFF8FAFC),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.route,
                                        color: Color(0xFF94A3B8), size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                          'Destino: ${data['aduana'] ?? 'N/A'}',
                                          style: const TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 14)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Chip(
                                      label: Text(data['tipo'] == 'exportacion'
                                          ? 'Exportación'
                                          : 'Importación'),
                                      backgroundColor: const Color(0xFF334155),
                                      labelStyle: const TextStyle(
                                          color: Color(0xFFF8FAFC),
                                          fontSize: 12),
                                      side: BorderSide.none,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    if ((data['fraccionPrincipal']
                                                ?.toString() ??
                                            '')
                                        .isNotEmpty)
                                      Chip(
                                        label: Text(data['fraccionPrincipal']
                                            .toString()),
                                        backgroundColor:
                                            const Color(0xFF334155),
                                        labelStyle: const TextStyle(
                                            color: Color(0xFFF8FAFC),
                                            fontSize: 12),
                                        side: BorderSide.none,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    Chip(
                                      label: Text('$dias días'),
                                      backgroundColor: const Color(0xFF334155),
                                      labelStyle: const TextStyle(
                                          color: Color(0xFFF8FAFC),
                                          fontSize: 12),
                                      side: BorderSide.none,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
