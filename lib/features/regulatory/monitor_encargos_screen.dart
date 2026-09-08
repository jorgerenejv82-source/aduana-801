import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MonitorEncargosScreen extends StatefulWidget {
  const MonitorEncargosScreen({super.key});

  @override
  State<MonitorEncargosScreen> createState() => _MonitorEncargosScreenState();
}

class _MonitorEncargosScreenState extends State<MonitorEncargosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _filtroEstado = 'todos';
  String _filtroPrioridad = 'todos';
  String _filtroTipo = 'todos';

  final tituloController = TextEditingController();
  final descController = TextEditingController();
  final clienteController = TextEditingController();
  final asignadoController = TextEditingController();
  final notasController = TextEditingController();

  @override
  void dispose() {
    notasController.dispose();
    asignadoController.dispose();
    clienteController.dispose();
    descController.dispose();
    tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Monitor de Encargos'),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStats(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('encargos')
                  .where('uid', isEqualTo: _auth.currentUser?.uid ?? 'unknown')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No hay encargos.',
                          style: TextStyle(color: Colors.white)));
                }

                var docs = snapshot.data!.docs;

                // Filtrado en cliente
                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final estado = data['estado'] ?? 'pendiente';
                  final prioridad = data['prioridad'] ?? 'NORMAL';
                  final tipo = data['tipo'] ?? 'otros';

                  if (_filtroEstado != 'todos' && estado != _filtroEstado) {
                    return false;
                  }
                  if (_filtroPrioridad != 'todos' &&
                      prioridad != _filtroPrioridad) {
                    return false;
                  }
                  if (_filtroTipo != 'todos' && tipo != _filtroTipo) {
                    return false;
                  }
                  return true;
                }).toList();

                // Grouping and sorting
                docs.sort((a, b) {
                  final Map<String, int> estadoOrder = {
                    'pendiente': 0,
                    'en_progreso': 1,
                    'completado': 2,
                    'cancelado': 3,
                  };
                  final estadoA = (a.data() as Map)['estado'] ?? 'pendiente';
                  final estadoB = (b.data() as Map)['estado'] ?? 'pendiente';
                  return (estadoOrder[estadoA] ?? 4)
                      .compareTo(estadoOrder[estadoB] ?? 4);
                });

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return _buildEncargoCard(docs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        onPressed: () => _mostrarDialogoEncargo(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('encargos')
          .where('uid', isEqualTo: _auth.currentUser?.uid ?? 'unknown')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        int pendientes = 0;
        int vencenHoy = 0;
        int completadosSemana = 0;

        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final estado = data['estado'];
          if (estado == 'pendiente') pendientes++;

          if (data['fechaVencimiento'] != null) {
            final fechaV = (data['fechaVencimiento'] as Timestamp).toDate();
            if (fechaV.year == now.year &&
                fechaV.month == now.month &&
                fechaV.day == now.day &&
                estado != 'completado') {
              vencenHoy++;
            }
          }

          if (estado == 'completado' && data['updatedAt'] != null) {
            final updated = (data['updatedAt'] as Timestamp).toDate();
            if (updated.isAfter(startOfWeek)) {
              completadosSemana++;
            }
          }
        }

        return Container(
          padding: const EdgeInsets.all(16.0),
          color: const Color(0xFF1E293B),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  'Pendientes', pendientes.toString(), const Color(0xFFF59E0B)),
              _buildStatItem('Vencen Hoy', vencenHoy.toString(), AppColors.red),
              _buildStatItem(
                  'Completados', completadosSemana.toString(), AppColors.green),
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
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildEncargoCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final titulo = data['titulo'] ?? '';
    final cliente = data['cliente'] ?? '';
    final tipo = data['tipo'] ?? 'otros';
    final prioridad = data['prioridad'] ?? 'NORMAL';
    final estado = data['estado'] ?? 'pendiente';
    final asignadoA = data['asignadoA'] ?? '';

    DateTime? fechaVencimiento;
    if (data['fechaVencimiento'] != null) {
      fechaVencimiento = (data['fechaVencimiento'] as Timestamp).toDate();
    }

    String diasRestantesStr = '';
    if (fechaVencimiento != null) {
      final diff = fechaVencimiento.difference(DateTime.now()).inDays;
      if (diff < 0) {
        diasRestantesStr = 'Vencido por ${diff.abs()} días';
      } else if (diff == 0) {
        diasRestantesStr = 'Vence hoy';
      } else {
        diasRestantesStr = 'Vence en $diff días';
      }
    }

    Color priorityColor = Colors.grey;
    switch (prioridad) {
      case 'CRITICA':
        priorityColor = const Color(0xFF8B5CF6);
        break; // Purple
      case 'URGENTE':
        priorityColor = AppColors.red;
        break; // Red
      case 'ALTA':
        priorityColor = const Color(0xFFF59E0B);
        break; // Gold
      case 'NORMAL':
        priorityColor = const Color(0xFF3B82F6);
        break; // Blue
    }

    return Dismissible(
      key: Key(id),
      background: Container(
        color: AppColors.green,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      direction: estado == 'completado'
          ? DismissDirection.none
          : DismissDirection.endToStart,
      onDismissed: (direction) {
        _actualizarEstado(id, 'completado');
      },
      child: Card(
        color: const Color(0xFF1E293B),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _mostrarDialogoEncargo(context, doc),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(titulo.toString(),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: priorityColor.withAlpha(51),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(prioridad.toString(),
                          style: TextStyle(
                              color: priorityColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Cliente: $cliente',
                    style: const TextStyle(color: Color(0xFFF8FAFC))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFF475569),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(tipo.toString().toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                    ),
                    const Spacer(),
                    if (diasRestantesStr.isNotEmpty)
                      Text(diasRestantesStr,
                          style: TextStyle(
                              color: diasRestantesStr.contains('Vencido')
                                  ? AppColors.red
                                  : const Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Asignado: $asignadoA',
                        style: const TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 12)),
                    Text(estado.toString().toUpperCase(),
                        style: TextStyle(
                            color: estado == 'completado'
                                ? AppColors.green
                                : const Color(0xFFF59E0B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarFiltros(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF1E293B),
        builder: (context) {
          return StatefulBuilder(builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Filtros',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Estado',
                      style: TextStyle(color: Color(0xFF94A3B8))),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFF334155),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                    value: _filtroEstado,
                    items: [
                      'todos',
                      'pendiente',
                      'en_progreso',
                      'completado',
                      'cancelado'
                    ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => _filtroEstado = val!),
                  ),
                  const SizedBox(height: 16),
                  const Text('Prioridad',
                      style: TextStyle(color: Color(0xFF94A3B8))),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFF334155),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                    value: _filtroPrioridad,
                    items: ['todos', 'CRITICA', 'URGENTE', 'ALTA', 'NORMAL']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => _filtroPrioridad = val!),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tipo',
                      style: TextStyle(color: Color(0xFF94A3B8))),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFF334155),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                    value: _filtroTipo,
                    items: [
                      'todos',
                      'pedimento',
                      'previo',
                      'clasificacion',
                      'documentacion',
                      'liberacion',
                      'otros'
                    ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setModalState(() => _filtroTipo = val!),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            );
          });
        });
  }

  void _mostrarDialogoEncargo(BuildContext context, DocumentSnapshot? doc) {
    final bool isEdit = doc != null;
    final data = isEdit ? doc.data() as Map<String, dynamic> : null;

    final tituloController =
        TextEditingController(text: data?['titulo'] as String?);
    final descController =
        TextEditingController(text: data?['descripcion'] as String?);
    final clienteController =
        TextEditingController(text: data?['cliente'] as String?);
    final asignadoController =
        TextEditingController(text: data?['asignadoA'] as String?);
    final notasController =
        TextEditingController(text: data?['notas'] as String?);

    String prioridad = (data?['prioridad'] as String?) ?? 'NORMAL';
    String estado = (data?['estado'] as String?) ?? 'pendiente';
    String tipo = (data?['tipo'] as String?) ?? 'pedimento';
    DateTime? fecha = data?['fechaVencimiento'] != null
        ? (data!['fechaVencimiento'] as Timestamp).toDate()
        : null;

    showDialog<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: Text(isEdit ? 'Editar Encargo' : 'Nuevo Encargo',
                  style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          labelText: 'Título',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    TextField(
                      controller: clienteController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          labelText: 'Cliente',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    const SizedBox(height: 16),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Prioridad',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        contentPadding: EdgeInsets.zero,
                      ),
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF334155),
                        value: prioridad,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.white),
                        items: ['CRITICA', 'URGENTE', 'ALTA', 'NORMAL']
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) =>
                            setDialogState(() => prioridad = val!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        contentPadding: EdgeInsets.zero,
                      ),
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF334155),
                        value: tipo,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          'pedimento',
                          'previo',
                          'clasificacion',
                          'documentacion',
                          'liberacion',
                          'otros'
                        ]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setDialogState(() => tipo = val!),
                      ),
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 16),
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          contentPadding: EdgeInsets.zero,
                        ),
                        child: DropdownButton<String>(
                          dropdownColor: const Color(0xFF334155),
                          value: estado,
                          isExpanded: true,
                          underline: const SizedBox(),
                          style: const TextStyle(color: Colors.white),
                          items: [
                            'pendiente',
                            'en_progreso',
                            'completado',
                            'cancelado'
                          ]
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) =>
                              setDialogState(() => estado = val!),
                        ),
                      ),
                    ],
                    TextField(
                      controller: asignadoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          labelText: 'Asignado A',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                                fecha == null
                                    ? 'Sin fecha'
                                    : DateFormat('dd/MM/yyyy').format(fecha!),
                                style: const TextStyle(color: Colors.white))),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: fecha ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setDialogState(() => fecha = date);
                            }
                          },
                          child: const Text('Sel. Fecha'),
                        )
                      ],
                    ),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          labelText: 'Descripción',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: notasController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          labelText: 'Notas/Comentarios',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Color(0xFF94A3B8)))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6)),
                  onPressed: () async {
                    if (tituloController.text.isEmpty) return;

                    final encargoData = {
                      'titulo': tituloController.text,
                      'descripcion': descController.text,
                      'asignadoA': asignadoController.text,
                      'cliente': clienteController.text,
                      'prioridad': prioridad,
                      'tipo': tipo,
                      'estado': estado,
                      'notas': notasController.text,
                      'fechaVencimiento':
                          fecha != null ? Timestamp.fromDate(fecha!) : null,
                      'updatedAt': FieldValue.serverTimestamp(),
                      'uid': _auth.currentUser?.uid ?? 'unknown',
                    };

                    try {
                      if (isEdit) {
                        await _firestore
                            .collection('encargos')
                            .doc(doc.id)
                            .update(encargoData);
                      } else {
                        encargoData['createdAt'] = FieldValue.serverTimestamp();
                        encargoData['creadoPor'] =
                            _auth.currentUser?.email ?? 'Desconocido';
                        await _firestore
                            .collection('encargos')
                            .add(encargoData);
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Encargo guardado con éxito')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          });
        });
  }

  Future<void> _actualizarEstado(String id, String nuevoEstado) async {
    try {
      await _firestore.collection('encargos').doc(id).update({
        'estado': nuevoEstado,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Estado actualizado')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
