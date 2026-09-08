import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Constants for Theme Colors
const Color bg = Color(0xFF0F172A);
const Color cardColor = Color(0xFF1E293B);
const Color card2Color = Color(0xFF334155);
const Color textColor = Color(0xFFF8FAFC);
const Color subText = Color(0xFF94A3B8);
const Color borderColor = Color(0xFF475569);
const Color gold = Color(0xFFF59E0B);
const Color green = AppColors.green;
const Color blue = Color(0xFF3B82F6);
const Color red = AppColors.red;
const Color purple = Color(0xFF8B5CF6);

class TraficoDespachoScreen extends StatefulWidget {
  const TraficoDespachoScreen({super.key});

  @override
  State<TraficoDespachoScreen> createState() => _TraficoDespachoScreenState();
}

class _TraficoDespachoScreenState extends State<TraficoDespachoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _searchQuery = '';
  String? _selectedEstado;
  String? _selectedUrgencia;

  final List<String> _estados = [
    'documentos',
    'pre_validacion',
    'pago',
    'liberado',
    'en_transito',
    'entregado'
  ];

  final List<String> _urgencias = [
    'Normal',
    'Alta',
    'Crítica',
  ];

  @override
  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('Tráfico y Despacho',
            style: TextStyle(color: textColor)),
        iconTheme: const IconThemeData(color: textColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderColor, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          _buildFilterBar(),
          Expanded(
            child: _buildOperacionesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: blue,
        onPressed: () => _showAddOperacionDialog(context),
        child: const Icon(Icons.add, color: textColor),
      ),
    );
  }

  Widget _buildStatsHeader() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('operaciones')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator(color: blue)),
          );
        }

        final docs = snapshot.data!.docs;
        final total = docs.length;

        final hoy = DateTime.now();
        final liberadasHoy = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['estado'] != 'liberado') return false;
          final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
          if (updatedAt == null) return false;
          return updatedAt.year == hoy.year &&
              updatedAt.month == hoy.month &&
              updatedAt.day == hoy.day;
        }).length;

        final urgentes = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['urgencia'] == 'Alta' || data['urgencia'] == 'Crítica';
        }).length;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: cardColor,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', total.toString(), blue),
              _buildStatItem('Liberadas Hoy', liberadasHoy.toString(), green),
              _buildStatItem('Urgentes', urgentes.toString(), red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: subText)),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Buscar RFC, Pedimento o Cliente...',
              hintStyle: const TextStyle(color: subText),
              prefixIcon: const Icon(Icons.search, color: subText),
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DropdownButton<String>(
                  dropdownColor: cardColor,
                  style: const TextStyle(color: textColor),
                  hint: const Text('Estado', style: TextStyle(color: subText)),
                  value: _selectedEstado,
                  items: [
                    const DropdownMenuItem(child: Text('Todos')),
                    ..._estados
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedEstado = val;
                    });
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  dropdownColor: cardColor,
                  style: const TextStyle(color: textColor),
                  hint:
                      const Text('Urgencia', style: TextStyle(color: subText)),
                  value: _selectedUrgencia,
                  items: [
                    const DropdownMenuItem(child: Text('Todas')),
                    ..._urgencias
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedUrgencia = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperacionesList() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Center(
          child:
              Text('Please login first', style: TextStyle(color: textColor)));
    }

    Query query =
        _firestore.collection('operaciones').where('uid', isEqualTo: uid);

    if (_selectedEstado != null) {
      query = query.where('estado', isEqualTo: _selectedEstado);
    }
    if (_selectedUrgencia != null) {
      query = query.where('urgencia', isEqualTo: _selectedUrgencia);
    }

    query = query.orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: red)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: blue));
        }

        var docs = snapshot.data!.docs;

        // Apply local search filter
        if (_searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final rfc = (data['rfcCliente'] ?? '').toString().toLowerCase();
            final pedimento =
                (data['numPedimento'] ?? '').toString().toLowerCase();
            final cliente =
                (data['nombreCliente'] ?? '').toString().toLowerCase();
            return rfc.contains(_searchQuery) ||
                pedimento.contains(_searchQuery) ||
                cliente.contains(_searchQuery);
          }).toList();
        }

        if (docs.isEmpty) {
          return const Center(
              child: Text('No hay operaciones.',
                  style: TextStyle(color: subText)));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          padding: const EdgeInsets.all(8.0),
          itemBuilder: (context, index) {
            return _buildOperacionCard(docs[index]);
          },
        );
      },
    );
  }

  Widget _buildOperacionCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final estado = data['estado'] as String? ?? 'documentos';
    final urgencia = data['urgencia'] as String? ?? 'Normal';

    Color urgenciaColor = green;
    if (urgencia == 'Alta') urgenciaColor = gold;
    if (urgencia == 'Crítica') urgenciaColor = red;

    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final elapsed = DateTime.now().difference(createdAt);
    final String elapsedStr = '${elapsed.inDays}d ${elapsed.inHours % 24}h';

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (data['numPedimento'] ?? 'Sin Pedimento').toString(),
                  style: const TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: urgenciaColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: urgenciaColor),
                  ),
                  child: Text(
                    urgencia,
                    style: TextStyle(
                        color: urgenciaColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${data['nombreCliente']} (${data['rfcCliente']})',
                style: const TextStyle(color: subText)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: subText),
                const SizedBox(width: 4),
                Text((data['aduana'] ?? '').toString(),
                    style: const TextStyle(color: subText, fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.category, size: 14, color: subText),
                const SizedBox(width: 4),
                Text('Fracc: ${data['fraccion']}',
                    style: const TextStyle(color: subText, fontSize: 12)),
                const Spacer(),
                const Icon(Icons.timer, size: 14, color: subText),
                const SizedBox(width: 4),
                Text(elapsedStr,
                    style: const TextStyle(color: subText, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            _buildPipeline(estado),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.note_add, size: 18, color: blue),
                  label: const Text('Nota', style: TextStyle(color: blue)),
                  onPressed: () => _addNotaDialog(context, id),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.info_outline, size: 18, color: gold),
                  label: const Text('Detalles', style: TextStyle(color: gold)),
                  onPressed: () => _showDetalles(context, data),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Avanzar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onPressed: () => _avanzarEstado(id, estado),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipeline(String currentState) {
    int currentIndex = _estados.indexOf(currentState);
    if (currentIndex == -1) currentIndex = 0;

    return Row(
      children: List.generate(_estados.length * 2 - 1, (index) {
        if (index.isOdd) {
          final int stepIndex = index ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepIndex < currentIndex ? green : borderColor,
            ),
          );
        } else {
          final int stepIndex = index ~/ 2;
          final bool isCompleted = stepIndex < currentIndex;
          final bool isCurrent = stepIndex == currentIndex;

          Color nodeColor = borderColor;
          if (isCompleted) nodeColor = green;
          if (isCurrent) nodeColor = blue;

          return Tooltip(
            message: _estados[stepIndex],
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: nodeColor,
                border:
                    isCurrent ? Border.all(color: textColor, width: 2) : null,
              ),
            ),
          );
        }
      }),
    );
  }

  Future<void> _avanzarEstado(String id, String currentState) async {
    final int currentIndex = _estados.indexOf(currentState);
    if (currentIndex < _estados.length - 1) {
      final String nextState = _estados[currentIndex + 1];
      try {
        await _firestore.collection('operaciones').doc(id).update({
          'estado': nextState,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Estado actualizado a $nextState')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _showDetalles(BuildContext context, Map<String, dynamic> data) {
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: cardColor,
            title: const Text('Detalles de Operación',
                style: TextStyle(color: textColor)),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('${e.key}: ${e.value}',
                              style: const TextStyle(color: subText)),
                        ))
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar', style: TextStyle(color: blue)),
              ),
            ],
          );
        });
  }

  void _addNotaDialog(BuildContext context, String docId) {
    final noteController = TextEditingController();
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: cardColor,
            title:
                const Text('Agregar Nota', style: TextStyle(color: textColor)),
            content: TextField(
              controller: noteController,
              style: const TextStyle(color: textColor),
              decoration: const InputDecoration(
                hintText: 'Escriba una nota...',
                hintStyle: TextStyle(color: subText),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: borderColor)),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: subText)),
              ),
              TextButton(
                onPressed: () async {
                  if (noteController.text.isNotEmpty) {
                    try {
                      await _firestore
                          .collection('operaciones')
                          .doc(docId)
                          .update({
                        'notas': FieldValue.arrayUnion([
                          {
                            'texto': noteController.text,
                            'fecha': DateTime.now().toIso8601String()
                          }
                        ]),
                        'updatedAt': FieldValue.serverTimestamp(),
                      });
                      if (!mounted) return;
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nota agregada')));
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text('Guardar', style: TextStyle(color: blue)),
              ),
            ],
          );
        });
  }

  void _showAddOperacionDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddOperacionForm(),
    );
  }
}

class _AddOperacionForm extends StatefulWidget {
  const _AddOperacionForm();

  @override
  State<_AddOperacionForm> createState() => _AddOperacionFormState();
}

class _AddOperacionFormState extends State<_AddOperacionForm> {
  final _formKey = GlobalKey<FormState>();

  String numPedimento = '';
  String rfcCliente = '';
  String nombreCliente = '';
  String aduana = '';
  String regimen = '';
  String fraccion = '';
  double valorFob = 0.0;
  String urgencia = 'Normal';
  String patente = '';
  String etaEstimado = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        children: [
          const Text('Nueva Operación',
              style: TextStyle(
                  color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildTextField('Num Pedimento', (val) => numPedimento = val),
                  _buildTextField('RFC Cliente', (val) => rfcCliente = val),
                  _buildTextField(
                      'Nombre Cliente', (val) => nombreCliente = val),
                  _buildTextField('Aduana', (val) => aduana = val),
                  _buildTextField('Régimen', (val) => regimen = val),
                  _buildTextField('Fracción', (val) => fraccion = val),
                  _buildTextField('Valor FOB',
                      (val) => valorFob = double.tryParse(val) ?? 0.0,
                      keyboardType: TextInputType.number),
                  _buildTextField('Patente', (val) => patente = val),
                  _buildTextField(
                      'ETA Estimado (YYYY-MM-DD)', (val) => etaEstimado = val),
                  const SizedBox(height: 16),
                  const Text('Urgencia', style: TextStyle(color: subText)),
                  DropdownButtonFormField<String>(
                    dropdownColor: cardColor,
                    initialValue: urgencia,
                    style: const TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: borderColor)),
                    ),
                    items: ['Normal', 'Alta', 'Crítica']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        if (val != null) urgencia = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveOperacion,
              child: const Text('Guardar Operación',
                  style: TextStyle(color: textColor, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, void Function(String) onSave,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        style: const TextStyle(color: textColor),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: subText),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: borderColor)),
          focusedBorder:
              const UnderlineInputBorder(borderSide: BorderSide(color: blue)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Requerido' : null,
        onSaved: (val) => onSave(val ?? ''),
      ),
    );
  }

  Future<void> _saveOperacion() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no autenticado')));
        return;
      }

      try {
        final docRef =
            FirebaseFirestore.instance.collection('operaciones').doc();
        await docRef.set({
          'id': docRef.id,
          'numPedimento': numPedimento,
          'rfcCliente': rfcCliente,
          'nombreCliente': nombreCliente,
          'aduana': aduana,
          'regimen': regimen,
          'fraccion': fraccion,
          'valorFob': valorFob,
          'urgencia': urgencia,
          'patente': patente,
          'etaEstimado': etaEstimado,
          'estado': 'documentos',
          'notas': <Map<String, dynamic>>[],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'uid': uid,
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Operación creada exitosamente')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error al crear: $e')));
        }
      }
    }
  }
}
