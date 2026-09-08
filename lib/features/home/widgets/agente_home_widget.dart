import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/app_toast.dart';
import 'empty_state_widget.dart';

class AgenteHomeWidget extends StatefulWidget {
  final String userName;
  const AgenteHomeWidget({super.key, required this.userName});

  @override
  State<AgenteHomeWidget> createState() => _AgenteHomeWidgetState();
}

class _AgenteHomeWidgetState extends State<AgenteHomeWidget> {
  DateTime? _fielVigenciaDate;
  String? _clientActiveId;
  bool _isLoadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isoDate = prefs.getString('fiel_vigencia_date');
      if (isoDate != null) {
        try {
          _fielVigenciaDate = DateTime.parse(isoDate);
        } catch (e) {
          _fielVigenciaDate = null;
        }
      }
      _clientActiveId = prefs.getString('client_active_id');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPrefs = false;
        });
      }
    }
  }

  Future<void> _saveFielDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fiel_vigencia_date', date.toIso8601String());
    setState(() {
      _fielVigenciaDate = date;
    });
  }

  Future<void> _pickDate() async {
    final initial = _fielVigenciaDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      await _saveFielDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (uid == null)
              const SkeletonLoader(height: 400)
            else ...[
              _buildKpis(uid),
              const SizedBox(height: 24),
              _buildFielSection(context),
              const SizedBox(height: 24),
              _buildClientSwitcher(context, uid),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentExpedientes(uid),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido, ${widget.userName} ⚖️',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Panel de Control Aduanal',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agente Aduanal Certificado',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.gold,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildKpis(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('expedientes_completos')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorStateWidget(
            message: 'Error al cargar KPIs',
            onRetry: () => setState(() {}),
          );
        }
        if (!snapshot.hasData) {
          return const Row(
            children: [
              Expanded(child: SkeletonLoader(height: 120)),
              SizedBox(width: 16),
              Expanded(child: SkeletonLoader(height: 120)),
            ],
          );
        }

        final docs = snapshot.data!.docs;
        int activos = 0;
        int alertas = 0;

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final estado = data['estado'] as String?;
          if (estado != 'liberado') activos++;
          if (estado == 'pendiente_docs') alertas++;
        }

        return Row(
          children: [
            Expanded(
              child: Card(
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expedientes Activos',
                          style: TextStyle(color: AppColors.sub)),
                      const SizedBox(height: 8),
                      Text(
                        '$activos',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold),
                      ),
                      const Text('En proceso',
                          style:
                              TextStyle(color: AppColors.text, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => context.push('/expedientes'),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  color: AppColors.card,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Alertas Pendientes',
                            style: TextStyle(color: AppColors.sub)),
                        const SizedBox(height: 8),
                        Text(
                          '$alertas',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber),
                        ),
                        const Text('Documentos faltantes',
                            style:
                                TextStyle(color: AppColors.text, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFielSection(BuildContext context) {
    if (_isLoadingPrefs) {
      return const SkeletonLoader(height: 80);
    }
    if (_fielVigenciaDate == null) {
      return Card(
        color: AppColors.card,
        child: ListTile(
          leading: const Icon(Icons.security, color: AppColors.gold),
          title: const Text('Registra tu e.firma/FIEL',
              style: TextStyle(color: AppColors.text)),
          trailing: ElevatedButton(
            onPressed: _pickDate,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child:
                const Text('Registrar', style: TextStyle(color: AppColors.bg)),
          ),
        ),
      );
    } else {
      final days = _fielVigenciaDate!.difference(DateTime.now()).inDays;
      Color statusColor;
      String statusText;

      if (days > 30) {
        statusColor = AppColors.green;
        statusText = 'Vence en $days días';
      } else if (days >= 7) {
        statusColor = Colors.amber;
        statusText = 'Vence en $days días';
      } else if (days >= 0) {
        statusColor = AppColors.red;
        statusText = 'Vence en $days días';
      } else {
        statusColor = AppColors.red;
        statusText = 'Vencida hace ${-days} días';
      }

      return Card(
        color: AppColors.card,
        child: InkWell(
          onTap: _pickDate,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.shield, color: statusColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('e.firma/FIEL',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                              fontSize: 16)),
                      Text(statusText, style: TextStyle(color: statusColor)),
                    ],
                  ),
                ),
                const Icon(Icons.edit, color: AppColors.sub),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildClientSwitcher(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('clientes_crm')
          .where('uid', isEqualTo: uid)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorStateWidget(
            message: 'Error al cargar clientes',
            onRetry: () => setState(() {}),
          );
        }
        if (!snapshot.hasData) {
          return const SkeletonLoader(height: 50);
        }

        if (snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: ActionChip(
              label: const Text('Sin clientes — Agregar'),
              onPressed: () => context.push('/clientes'),
              backgroundColor: AppColors.card,
              labelStyle: const TextStyle(color: AppColors.text),
              side: const BorderSide(color: AppColors.border),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final items = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['nombre'] ?? 'Sin nombre').toString();
          return DropdownMenuItem<String>(
            value: doc.id,
            child: Text(name),
          );
        }).toList();

        if (_clientActiveId != null &&
            !docs.any((d) => d.id == _clientActiveId)) {
          // If active client isn't in the list anymore
          // We can't setState during build easily without issues, but we can display it as null
          // Let's rely on the user to pick a new one
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: docs.any((d) => d.id == _clientActiveId)
                  ? _clientActiveId
                  : null,
              hint: const Text('Seleccionar cliente activo',
                  style: TextStyle(color: AppColors.sub)),
              dropdownColor: AppColors.card,
              style: const TextStyle(color: AppColors.text),
              isExpanded: true,
              items: items,
              onChanged: (val) async {
                if (val != null) {
                  final selectedDoc = docs.firstWhere((d) => d.id == val);
                  final data = selectedDoc.data() as Map<String, dynamic>;
                  final name = (data['nombre'] ?? 'Sin nombre').toString();

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('client_active_id', val);
                  await prefs.setString('client_active_name', name);

                  setState(() {
                    _clientActiveId = val;
                  });

                  if (context.mounted) {
                    AppToast.success(context, 'Cliente activo: $name');
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _actionChip(
              '📋 Nuevo Expediente', Icons.add_box_outlined, '/expedientes'),
          const SizedBox(width: 8),
          _actionChip('🔍 Pre-Glosa', Icons.document_scanner, '/pre_glosa'),
          const SizedBox(width: 8),
          _actionChip('📁 CRM', Icons.people_outline, '/clientes'),
          const SizedBox(width: 8),
          _actionChip(
              '⚖️ M3 Forensics', Icons.analytics_outlined, '/m3_forensics'),
          const SizedBox(width: 8),
          _actionChip('📊 Semáforo', Icons.traffic_outlined, '/semaforo'),
        ],
      ),
    );
  }

  Widget _actionChip(String label, IconData icon, String route) {
    return ElevatedButton.icon(
      onPressed: () => context.push(route),
      icon: Icon(icon, size: 18, color: AppColors.gold),
      label: Text(label, style: const TextStyle(color: AppColors.text)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.card,
        side: const BorderSide(color: AppColors.gold),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildRecentExpedientes(String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expedientes Recientes',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('expedientes_completos')
              .where('uid', isEqualTo: uid)
              .orderBy('updatedAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorStateWidget(
                message: 'Error al cargar expedientes',
                onRetry: () => setState(() {}),
              );
            }
            if (!snapshot.hasData) {
              return const SkeletonLoader(height: 150);
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.folder_open,
                title: 'Sin expedientes activos',
                subtitle: 'Crea tu primer expediente',
                actionLabel: 'Crear expediente',
                onAction: () => context.push('/expedientes'),
              );
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final numExpediente =
                    (data['numExpediente'] ?? 'S/N').toString();
                final clienteNombre = data['clienteNombre'] ?? 'Sin cliente';
                final estado = data['estado'] ?? 'desconocido';

                final fechaTs = data['updatedAt'] as Timestamp?;
                final fechaStr = fechaTs != null
                    ? '${fechaTs.toDate().day}/${fechaTs.toDate().month}/${fechaTs.toDate().year}'
                    : '';

                Color estadoColor;
                switch (estado) {
                  case 'pendiente_docs':
                    estadoColor = Colors.amber;
                    break;
                  case 'en_proceso':
                    estadoColor = AppColors.blue;
                    break;
                  case 'liberado':
                    estadoColor = AppColors.green;
                    break;
                  case 'cancelado':
                    estadoColor = AppColors.red;
                    break;
                  default:
                    estadoColor = AppColors.sub;
                }

                return Card(
                  color: AppColors.card,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      numExpediente,
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppColors.text,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('$clienteNombre • $fechaStr',
                        style: const TextStyle(color: AppColors.sub)),
                    trailing: Chip(
                      label: Text(
                        estado.toString().replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                            color: estadoColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: estadoColor.withAlpha(25),
                      side: BorderSide(color: estadoColor),
                    ),
                    onTap: () => context.push('/expedientes/${doc.id}'),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
