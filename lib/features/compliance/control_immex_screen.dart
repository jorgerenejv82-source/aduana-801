import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:aduana_801/core/constants/firestore_collections.dart';
import '../regulatory/models/saldo_immex_model.dart';
import '../../core/services/pdf_generator_service.dart';
import '../../core/widgets/skeleton_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Anexo 24 — Control Temporalidad IMMEX
// ─────────────────────────────────────────────────────────────────────────────
class ControlImmexScreen extends StatefulWidget {
  const ControlImmexScreen({super.key});
  @override
  State<ControlImmexScreen> createState() => _ControlImmexScreenState();
}

class _ControlImmexScreenState extends State<ControlImmexScreen>
    with SingleTickerProviderStateMixin {
  final _db = FirebaseFirestore.instance;
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  bool _isLoading = true;
  String? _error;
  List<SaldoImmex> _all = [];
  String _filter = 'todos'; // todos | riesgo | vencido | ok
  String _search = '';
  String _sortBy = 'vencimiento'; // vencimiento | fraccion | pedimento

  static const _gold = AppColors.gold;
  static const _red = Color(0xFFEF4444);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() {
          _filter = ['todos', 'ok', 'riesgo', 'vencido'][_tabCtrl.index];
        });
      }
    });
    _cargarSaldos();
  }

  @override
  void dispose() {
    
    
    
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  Future<void> _cargarSaldos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final snap =
          await _db.collection(FirestoreCollections.immexInventario).get();
      final lista =
          snap.docs.map((d) => SaldoImmex.fromMap(d.data(), d.id)).toList();
      lista.sort(_sortFn);
      if (!mounted) return;
      setState(() {
        _all = lista;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  int Function(SaldoImmex, SaldoImmex) get _sortFn {
    switch (_sortBy) {
      case 'fraccion':
        return (a, b) => a.fraccion.compareTo(b.fraccion);
      case 'pedimento':
        return (a, b) =>
            a.pedimentoImportacion.compareTo(b.pedimentoImportacion);
      default:
        return (a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento);
    }
  }

  List<SaldoImmex> get _filtered {
    var list = _all;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((s) =>
              s.fraccion.toLowerCase().contains(q) ||
              s.pedimentoImportacion.toLowerCase().contains(q))
          .toList();
    }
    switch (_filter) {
      case 'vencido':
        return list.where((s) => s.estaVencido).toList();
      case 'riesgo':
        return list.where((s) => s.enRiesgo && !s.estaVencido).toList();
      case 'ok':
        return list.where((s) => !s.estaVencido && !s.enRiesgo).toList();
      default:
        return list;
    }
  }

  // ─── KPI helpers ──────────────────────────────────────────────────────────

  int get _totalVencidos => _all.where((s) => s.estaVencido).length;
  int get _totalRiesgo =>
      _all.where((s) => s.enRiesgo && !s.estaVencido).length;
  int get _totalOk => _all.where((s) => !s.estaVencido && !s.enRiesgo).length;

  double get _pctExportado {
    if (_all.isEmpty) return 0;
    final ini = _all.fold(0.0, (s, e) => s + e.cantidadInicial);
    final rem = _all.fold(0.0, (s, e) => s + e.cantidadRestante);
    if (ini == 0) return 0;
    return ((ini - rem) / ini * 100).clamp(0, 100);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFab(),
      body: _isLoading
          ? const SkeletonListScreen()
          : _error != null
              ? _buildErrorState()
              : Column(children: [
                  _buildKpiRow(),
                  _buildSearchAndSort(),
                  _buildTabs(),
                  Expanded(child: _buildList()),
                ]),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Anexo 24 — IMMEX',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text('Control de Temporalidad',
                style: TextStyle(color: AppColors.sub, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: _gold),
            tooltip: 'Generar Reporte',
            onPressed: _mostrarReporte,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.sub),
            onPressed: _cargarSaldos,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      );

  // ─── KPI row ──────────────────────────────────────────────────────────────

  Widget _buildKpiRow() {
    final fmt = NumberFormat('#,##0.0', 'es_MX');
    return Container(
      color: AppColors.bg2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _KpiCard(
              label: 'Total',
              value: '${_all.length}',
              icon: Icons.inventory_2_outlined,
              color: AppColors.blue),
          _KpiCard(
              label: 'En Regla',
              value: '$_totalOk',
              icon: Icons.check_circle_outline,
              color: _green),
          _KpiCard(
              label: 'En Riesgo',
              value: '$_totalRiesgo',
              icon: Icons.warning_amber_rounded,
              color: _amber),
          _KpiCard(
              label: 'Vencidos',
              value: '$_totalVencidos',
              icon: Icons.error_outline,
              color: _red),
          _KpiCard(
              label: '% Export.',
              value: '${fmt.format(_pctExportado)}%',
              icon: Icons.trending_up,
              color: _gold),
        ],
      ),
    );
  }

  // ─── Search + Sort ────────────────────────────────────────────────────────

  Widget _buildSearchAndSort() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por fracción o pedimento...',
                hintStyle: const TextStyle(color: AppColors.sub, fontSize: 13),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.sub, size: 18),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.sub, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        })
                    : null,
                filled: true,
                fillColor: AppColors.card,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppColors.sub),
            color: AppColors.card,
            tooltip: 'Ordenar',
            onSelected: (v) => setState(() {
              _sortBy = v;
              _all.sort(_sortFn);
            }),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'vencimiento',
                  child: Text('Por vencimiento',
                      style: TextStyle(color: Colors.white))),
              const PopupMenuItem(
                  value: 'fraccion',
                  child: Text('Por fracción',
                      style: TextStyle(color: Colors.white))),
              const PopupMenuItem(
                  value: 'pedimento',
                  child: Text('Por pedimento',
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tabs ─────────────────────────────────────────────────────────────────

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicatorColor: _gold,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: _gold,
        unselectedLabelColor: AppColors.sub,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: [
          Tab(text: 'Todos (${_all.length})'),
          Tab(text: '✅ OK ($_totalOk)'),
          Tab(text: '⚠️ Riesgo ($_totalRiesgo)'),
          Tab(text: '🔴 Vencidos ($_totalVencidos)'),
        ],
      ),
    );
  }

  // ─── List ─────────────────────────────────────────────────────────────────

  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined,
                color: AppColors.sub, size: 64),
            const SizedBox(height: 16),
            Text(
              _all.isEmpty
                  ? 'Sin saldos registrados\nToca + para agregar el primer registro'
                  : 'Sin resultados para "$_search"',
              style: const TextStyle(color: AppColors.sub, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _buildCard(items[i]),
    );
  }

  // ─── Product Card ─────────────────────────────────────────────────────────

  Widget _buildCard(SaldoImmex s) {
    final fmt = DateFormat('dd MMM yyyy', 'es_MX');
    final pct = s.cantidadInicial > 0
        ? ((s.cantidadInicial - s.cantidadRestante) / s.cantidadInicial)
            .clamp(0.0, 1.0)
        : 0.0;
    final Color statusColor = s.estaVencido
        ? _red
        : s.enRiesgo
            ? _amber
            : _green;
    final String statusText = s.estaVencido
        ? 'VENCIDO'
        : s.enRiesgo
            ? 'EN RIESGO'
            : 'EN REGLA';
    final String diasLabel = s.estaVencido
        ? '${s.diasRestantes.abs()} días vencido'
        : '${s.diasRestantes} días restantes';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: statusColor.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                      s.estaVencido
                          ? Icons.error
                          : s.enRiesgo
                              ? Icons.warning_amber
                              : Icons.check_circle,
                      color: statusColor,
                      size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.fraccion,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text('Pedimento IN: ${s.pedimentoImportacion}',
                          style: const TextStyle(
                              color: AppColors.sub, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Progress Bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Exportado: ${(pct * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: AppColors.sub, fontSize: 12)),
                    Text(
                        'Restante: ${s.cantidadRestante.toStringAsFixed(1)} / ${s.cantidadInicial.toStringAsFixed(1)} u',
                        style: const TextStyle(
                            color: AppColors.sub, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Dates row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _DateChip(
                    label: 'Entrada',
                    value: fmt.format(s.fechaEntrada),
                    icon: Icons.login),
                const SizedBox(width: 8),
                _DateChip(
                    label: 'Vence',
                    value: fmt.format(s.fechaVencimiento),
                    icon: Icons.timer_outlined,
                    color: statusColor),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(diasLabel,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Actions ──
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.upload_outlined,
                        size: 16, color: _gold),
                    label: const Text('Registrar Salida',
                        style: TextStyle(color: _gold, fontSize: 12)),
                    onPressed: () => _showRegistrarSalidaDialog(s),
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.border),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.bar_chart,
                        size: 16, color: AppColors.sub),
                    label: const Text('Ver Historial',
                        style: TextStyle(color: AppColors.sub, fontSize: 12)),
                    onPressed: () => _showHistorial(s),
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.border),
                Expanded(
                  child: TextButton.icon(
                    icon:
                        const Icon(Icons.delete_outline, size: 16, color: _red),
                    label: const Text('Eliminar',
                        style: TextStyle(color: _red, fontSize: 12)),
                    onPressed: () => _confirmarEliminar(s),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── FAB ──────────────────────────────────────────────────────────────────

  FloatingActionButton _buildFab() => FloatingActionButton.extended(
        backgroundColor: _gold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Saldo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showNuevoSaldoDialog,
      );

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  void _showNuevoSaldoDialog() {
    final pedCtrl = TextEditingController();
    final fracCtrl = TextEditingController();
    final cantCtrl = TextEditingController();
    final form = GlobalKey<FormState>();
    DateTime fechaEntrada = DateTime.now();
    DateTime fechaVencimiento = DateTime.now().add(const Duration(days: 540));

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          backgroundColor: AppColors.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: _gold),
              SizedBox(width: 8),
              Text('Registrar Importación IMMEX',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FormField(
                      ctrl: pedCtrl,
                      label: 'Pedimento de Importación',
                      hint: 'Ej: 24  48  0000001'),
                  const SizedBox(height: 12),
                  _FormField(
                      ctrl: fracCtrl,
                      label: 'Fracción Arancelaria',
                      hint: 'Ej: 8471.30.01'),
                  const SizedBox(height: 12),
                  _FormField(
                      ctrl: cantCtrl,
                      label: 'Cantidad Importada (u)',
                      hint: 'Ej: 1000',
                      isNumber: true),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DateButton(
                          label: 'Fecha Entrada',
                          value: fechaEntrada,
                          onPicked: (d) => setDialog(() {
                            fechaEntrada = d;
                            fechaVencimiento = d.add(const Duration(days: 540));
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DateButton(
                          label: 'Vencimiento (18 m)',
                          value: fechaVencimiento,
                          onPicked: (d) =>
                              setDialog(() => fechaVencimiento = d),
                          color: _amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.sub)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _gold, foregroundColor: Colors.black),
              onPressed: () async {
                if (!form.currentState!.validate()) return;
                Navigator.pop(ctx);
                final cant = double.tryParse(cantCtrl.text) ?? 0;
                await _db.collection(FirestoreCollections.immexInventario).add({
                  'pedimentoImportacion': pedCtrl.text.trim(),
                  'fraccion': fracCtrl.text.trim(),
                  'cantidadInicial': cant,
                  'cantidadRestante': cant,
                  'fechaEntrada': fechaEntrada.toIso8601String(),
                  'fechaVencimiento': fechaVencimiento.toIso8601String(),
                  'historial': <Map<String, dynamic>>[],
                  'creadoEn': FieldValue.serverTimestamp(),
                });
                unawaited(_cargarSaldos());
              },
              child: const Text('Registrar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegistrarSalidaDialog(SaldoImmex s) {
    final cantCtrl = TextEditingController();
    final pedCtrl = TextEditingController();
    final form = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.upload_outlined, color: _gold),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Registrar Exportación\n${s.fraccion}',
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Disponible:',
                          style: TextStyle(color: AppColors.sub, fontSize: 13)),
                      Text('${s.cantidadRestante.toStringAsFixed(2)} u',
                          style: const TextStyle(
                              color: _green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _FormField(
                  ctrl: cantCtrl,
                  label: 'Cantidad a exportar (u)',
                  hint: 'Máximo ${s.cantidadRestante.toStringAsFixed(2)}',
                  isNumber: true,
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) {
                      return 'Ingresa una cantidad válida';
                    }
                    if (n > s.cantidadRestante) {
                      return 'Excede la cantidad disponible';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _FormField(
                    ctrl: pedCtrl,
                    label: 'Pedimento de Exportación (opcional)',
                    hint: 'Ej: 24  48  9999999'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancelar', style: TextStyle(color: AppColors.sub)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload, size: 16),
            label: const Text('Registrar Salida',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                backgroundColor: _gold, foregroundColor: Colors.black),
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              Navigator.pop(ctx);
              final cant = double.parse(cantCtrl.text);
              final nuevo =
                  (s.cantidadRestante - cant).clamp(0.0, s.cantidadInicial);
              final entrada = {
                'tipo': 'salida',
                'cantidad': cant,
                'pedimento': pedCtrl.text.trim(),
                'fecha': DateTime.now().toIso8601String(),
              };
              await _db
                  .collection(FirestoreCollections.immexInventario)
                  .doc(s.id)
                  .update({
                'cantidadRestante': nuevo,
                'historial': FieldValue.arrayUnion([entrada]),
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('✅ Salida registrada correctamente'),
                backgroundColor: _green,
              ));
              unawaited(_cargarSaldos());
            },
          ),
        ],
      ),
    );
  }

  void _showHistorial(SaldoImmex s) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, sc) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Historial — ${s.fraccion}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Text('Pedimento: ${s.pedimentoImportacion}',
                  style: const TextStyle(color: AppColors.sub, fontSize: 13)),
              const SizedBox(height: 12),
              _historialTile('Importación inicial', s.cantidadInicial,
                  s.fechaEntrada, Icons.login, _green),
              const Divider(color: AppColors.border),
              const Text('Aquí aparecerán las salidas registradas.',
                  style: TextStyle(color: AppColors.sub, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historialTile(
      String label, double cant, DateTime fecha, IconData icon, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 18)),
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 13)),
      subtitle: Text(DateFormat('dd/MM/yyyy HH:mm', 'es_MX').format(fecha),
          style: const TextStyle(color: AppColors.sub, fontSize: 11)),
      trailing: Text('${cant.toStringAsFixed(2)} u',
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  void _confirmarEliminar(SaldoImmex s) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Eliminar Registro',
            style: TextStyle(color: Colors.white)),
        content: Text(
            '¿Eliminar el saldo de fracción ${s.fraccion} del pedimento ${s.pedimentoImportacion}?',
            style: const TextStyle(color: AppColors.sub)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.sub))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await _db
                  .collection(FirestoreCollections.immexInventario)
                  .doc(s.id)
                  .delete();
              unawaited(_cargarSaldos());
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarReporte() {
    final fmt = DateFormat('dd/MM/yyyy', 'es_MX');
    final now = DateTime.now();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.picture_as_pdf, color: _gold),
          SizedBox(width: 8),
          Text('Reporte Mensual Anexo 24',
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ]),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Generado: ${fmt.format(now)}',
                  style: const TextStyle(color: AppColors.sub, fontSize: 13)),
              const SizedBox(height: 16),
              _ReportRow(label: 'Total partidas', value: '${_all.length}'),
              _ReportRow(label: 'En regla', value: '$_totalOk', color: _green),
              _ReportRow(
                  label: 'En riesgo (<30 días)',
                  value: '$_totalRiesgo',
                  color: _amber),
              _ReportRow(
                  label: 'Vencidos', value: '$_totalVencidos', color: _red),
              _ReportRow(
                  label: '% Exportado global',
                  value: '${_pctExportado.toStringAsFixed(1)}%',
                  color: _gold),
              const SizedBox(height: 8),
              if (_totalVencidos > 0)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: _red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            '⚠️ $_totalVencidos partida(s) vencida(s). Se recomienda regularizar de inmediato ante el SAT.',
                            style: const TextStyle(color: _red, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cerrar', style: TextStyle(color: AppColors.sub))),
          ElevatedButton.icon(
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Exportar PDF',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                backgroundColor: _gold, foregroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)),
                    SizedBox(width: 12),
                    Text('Generando PDF...'),
                  ],
                ),
                duration: Duration(seconds: 3),
                backgroundColor: AppColors.card,
              ));
              // Generate
              final saldosMap = _all
                  .map((s) => {
                        'pedimentoImportacion': s.pedimentoImportacion,
                        'fraccion': s.fraccion,
                        'cantidadInicial': s.cantidadInicial,
                        'cantidadRestante': s.cantidadRestante,
                        'fechaEntrada': s.fechaEntrada.toIso8601String(),
                        'fechaVencimiento':
                            s.fechaVencimiento.toIso8601String(),
                        'diasRestantes': s.diasRestantes,
                      })
                  .toList();
              final bytes =
                  await PdfGeneratorService.instance.generateAnexo24Report(
                saldos: saldosMap,
                empresa: 'Mi Empresa IMMEX',
              );
              await PdfGeneratorService.instance.downloadPdf(bytes,
                  'Anexo24_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
            },
          ),
        ],
      ),
    );
  }

  // ─── Error state ──────────────────────────────────────────────────────────

  Widget _buildErrorState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.orange, size: 56),
              const SizedBox(height: 16),
              const Text('Error al cargar datos IMMEX',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Verifica tu conexión e intenta de nuevo.',
                  style: TextStyle(color: AppColors.sub, fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _gold, foregroundColor: Colors.black),
                onPressed: _cargarSaldos,
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers / sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(color: AppColors.sub, fontSize: 9),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color? color;
  const _DateChip(
      {required this.label,
      required this.value,
      required this.icon,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.sub;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: c, size: 12),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.sub, fontSize: 9)),
            Text(value,
                style: TextStyle(
                    color: c, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final bool isNumber;
  final String? Function(String?)? validator;

  const _FormField(
      {required this.ctrl,
      required this.label,
      required this.hint,
      this.isNumber = false,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.sub, fontSize: 13),
        hintStyle: const TextStyle(color: AppColors.border, fontSize: 12),
        filled: true,
        fillColor: AppColors.bg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.gold)),
      ),
      validator: validator ??
          (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime value;
  final void Function(DateTime) onPicked;
  final Color? color;
  const _DateButton(
      {required this.label,
      required this.value,
      required this.onPicked,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.sub;
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2040),
          builder: (ctx, child) => Theme(data: ThemeData.dark(), child: child!),
        );
        if (d != null) onPicked(d);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.sub, fontSize: 10)),
            const SizedBox(height: 2),
            Text(DateFormat('dd/MM/yyyy').format(value),
                style: TextStyle(
                    color: c, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _ReportRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.sub, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }
}
