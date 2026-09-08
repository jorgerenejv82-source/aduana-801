import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _verde = AppColors.green;

class _HoverContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const _HoverContainer(
      {required this.child, this.onTap, this.margin, this.padding});

  @override
  State<_HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<_HoverContainer> {
  bool _isHovered = false;

  @override
  @override
  void dispose() {
    
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: widget.margin,
          padding: widget.padding,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _isHovered ? _ambar.withValues(alpha: 0.5) : _bord),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                        color: _ambar.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class HistorialM3Screen extends StatefulWidget {
  const HistorialM3Screen({super.key});
  @override
  State<HistorialM3Screen> createState() => _HistorialM3ScreenState();
}

class _HistorialM3ScreenState extends State<HistorialM3Screen> {
  // Filtro: null = Todos
  String? _filtro; // null=Todos, 'Pendiente', 'Saneado', 'Error'
  final _filtros = [null, 'Pendiente', 'Saneado', 'Error'];
  final _filtroLabels = ['Todos', 'Pendiente', 'Saneado', 'Error'];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _ambar),
          onPressed: () => context.go('/inmex'),
        ),
        title: const Text(
          'Historial de Transmisiones M3',
          style: TextStyle(
              color: _texto, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: _ambar, size: 22),
            onPressed: () => _mostrarDialogoNuevo(uid),
            tooltip: 'Nueva transmisión',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filtros chips ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_filtros.length, (i) {
                final isActive = _filtro == _filtros[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filtroLabels[i],
                        style: TextStyle(
                            color: isActive ? _ambar : _sec,
                            fontSize: 12,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    selected: isActive,
                    onSelected: (_) => setState(() => _filtro = _filtros[i]),
                    backgroundColor: _card,
                    selectedColor: _ambar.withValues(alpha: 0.15),
                    checkmarkColor: _ambar,
                    showCheckmark: false,
                    side: BorderSide(color: isActive ? _ambar : _bord),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                );
              }),
            ),
          ),

          const Divider(color: _bord, height: 1),

          // ── Lista ───────────────────────────────────────────────────────
          Expanded(
            child: uid == null
                ? _emptyState('No autenticado')
                : StreamBuilder<QuerySnapshot>(
                    stream: _buildQuery(uid),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(color: _ambar));
                      }
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return _emptyState(
                          _filtro == null
                              ? 'No hay transmisiones M3 registradas'
                              : 'No hay transmisiones con estado "$_filtro"',
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (ctx, i) {
                          final data = docs[i].data() as Map<String, dynamic>;
                          DateTime ts = DateTime.now();
                          if (data['timestamp'] is Timestamp) {
                            ts = (data['timestamp'] as Timestamp).toDate();
                          }
                          return _HistorialItem(
                            docRef: docs[i].reference,
                            numPedimento:
                                (data['numPedimento'] ?? '—').toString(),
                            status: (data['status'] ?? 'Pendiente').toString(),
                            compliance:
                                (data['compliance'] ?? 'WARNINGS').toString(),
                            m3Raw: (data['m3Raw'] ?? '').toString(),
                            timestamp: ts,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoNuevo(uid),
        backgroundColor: _ambar,
        foregroundColor: _bg,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Transmisión',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Stream<QuerySnapshot> _buildQuery(String uid) {
    Query q = FirebaseFirestore.instance
        .collection('historial_m3')
        .where('agentUid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(50);
    if (_filtro != null) q = q.where('status', isEqualTo: _filtro);
    return q.snapshots();
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, color: _sec, size: 52),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: _sec, fontSize: 14)),
          const SizedBox(height: 8),
          const Text(
              'Las transmisiones aparecerán aquí una vez que se procesen pedimentos',
              textAlign: TextAlign.center,
              style: TextStyle(color: _sec, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoNuevo(String? uid) async {
    if (uid == null) return;
    final pedCtrl = TextEditingController();
    final m3Ctrl = TextEditingController();
    String status = 'Pendiente';
    String compliance = 'WARNINGS';

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: _bord)),
          title: const Text('Nueva Transmisión M3',
              style: TextStyle(
                  color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _dialogField(pedCtrl, 'Número de Pedimento',
                    hint: 'Ej: 2024-3110-4500123'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: DropdownButtonFormField<String>(
                    initialValue: status,
                    dropdownColor: _card,
                    style: const TextStyle(color: _texto, fontSize: 13),
                    decoration: _dropDeco('Status'),
                    items: ['Pendiente', 'Saneado', 'Error', 'Transmitido']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setS(() => status = v!),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: DropdownButtonFormField<String>(
                    initialValue: compliance,
                    dropdownColor: _card,
                    style: const TextStyle(color: _texto, fontSize: 13),
                    decoration: _dropDeco('Compliance'),
                    items: ['VERIFIED', 'WARNINGS', 'ERRORS']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setS(() => compliance = v!),
                  )),
                ]),
                const SizedBox(height: 10),
                TextField(
                  controller: m3Ctrl,
                  maxLines: 4,
                  style: const TextStyle(
                      color: _verde, fontFamily: 'monospace', fontSize: 11),
                  decoration: InputDecoration(
                    labelText: 'Texto M3 Raw (opcional)',
                    labelStyle: const TextStyle(color: _sec, fontSize: 12),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(_),
                child: const Text('Cancelar', style: TextStyle(color: _sec))),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(_);
                if (pedCtrl.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('historial_m3')
                      .add({
                    'numPedimento': pedCtrl.text.trim(),
                    'status': status,
                    'compliance': compliance,
                    'm3Raw': m3Ctrl.text.trim(),
                    'agentUid': uid,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }
                nav.pop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _ambar,
                  foregroundColor: _bg,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text('Guardar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label,
      {String? hint}) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: _texto, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: _sec, fontSize: 11),
        labelStyle: const TextStyle(color: _sec),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  InputDecoration _dropDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _sec, fontSize: 12),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );
}

// ── Historial Item ─────────────────────────────────────────────────────────
class _HistorialItem extends StatefulWidget {
  final DocumentReference docRef;
  final String numPedimento, status, compliance, m3Raw;
  final DateTime timestamp;
  const _HistorialItem(
      {required this.docRef,
      required this.numPedimento,
      required this.status,
      required this.compliance,
      required this.m3Raw,
      required this.timestamp});
  @override
  State<_HistorialItem> createState() => _HistorialItemState();
}

class _HistorialItemState extends State<_HistorialItem> {
  bool _expanded = false;

  Color get _statusColor => switch (widget.status) {
        'Saneado' || 'Transmitido' => _verde,
        'Error' => _rojo,
        _ => _ambar,
      };

  Color get _complianceColor => switch (widget.compliance) {
        'VERIFIED' => _verde,
        'ERRORS' => _rojo,
        _ => _ambar,
      };

  IconData get _complianceIcon => switch (widget.compliance) {
        'VERIFIED' => Icons.verified,
        'ERRORS' => Icons.cancel,
        _ => Icons.warning_amber,
      };

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Column(
      children: [
        _HoverContainer(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(14),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                // Número pedimento
                Text(widget.numPedimento,
                    style: const TextStyle(
                        color: _texto,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: _statusColor.withValues(alpha: 0.5))),
                  child: Text(widget.status,
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
                // Compliance badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                      color: _complianceColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_complianceIcon, color: _complianceColor, size: 12),
                    const SizedBox(width: 3),
                    Text(widget.compliance,
                        style: TextStyle(
                            color: _complianceColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(width: 8),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    color: _sec, size: 18),
              ]),
              const SizedBox(height: 6),
              Text(fmt.format(widget.timestamp),
                  style: const TextStyle(color: _sec, fontSize: 12)),
              if (widget.m3Raw.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.m3Raw.length > 120
                      ? '${widget.m3Raw.substring(0, 120)}...'
                      : widget.m3Raw,
                  style: const TextStyle(
                      fontFamily: 'monospace', color: _verde, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (_expanded && widget.m3Raw.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _bord)),
            child: SelectableText(widget.m3Raw,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    color: _verde,
                    fontSize: 12,
                    height: 1.5)),
          ),
      ],
    );
  }
}
