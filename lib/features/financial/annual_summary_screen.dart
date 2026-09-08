import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/utils/share_utils.dart';

class AnnualSummaryScreen extends StatefulWidget {
  const AnnualSummaryScreen({super.key});

  @override
  State<AnnualSummaryScreen> createState() => _AnnualSummaryScreenState();
}

class _AnnualSummaryScreenState extends State<AnnualSummaryScreen> {
  bool _isLoading = true;
  int _selectedYear = DateTime.now().year;

  // Aggregated data
  int _totalExpedientes = 0;
  double _totalValorFob = 0; // USD
  double _ahorroTmec = 0; // MXN saved via TMEC/C.O.
  double _totalDrawbackRecuperado = 0; // MXN
  int _totalPos = 0;
  int _topProveedorOps = 0;
  String _topProveedorNombre = '';
  Map<String, int> _operacionesPorMes = {}; // month -> count
  Map<String, int> _operacionesPorAduana = {}; // aduana -> count
  List<Map<String, dynamic>> _topFracciones = []; // [{fraccion, count}]
  int _nomsActivas = 0;
  int _nomsVencidas = 0;
  double _capitalInvertido = 0; // total FOB converted to MXN

  final _fmtCompact = NumberFormat.compact(locale: 'es_MX');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _doLoadData().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          // Partial data is fine, just stop loading
        },
      );
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _doLoadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // We handle uid == null gracefully as silent fail / zero state

    final startOfYear = DateTime(_selectedYear);
    final endOfYear = DateTime(_selectedYear, 12, 31, 23, 59, 59);

    // Reset data
    _totalExpedientes = 0;
    _totalValorFob = 0;
    _ahorroTmec = 0;
    _totalDrawbackRecuperado = 0;
    _totalPos = 0;
    _topProveedorOps = 0;
    _topProveedorNombre = '';
    _operacionesPorMes = {};
    _operacionesPorAduana = {};
    _topFracciones = [];
    _nomsActivas = 0;
    _nomsVencidas = 0;
    _capitalInvertido = 0;

    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Expedientes
      final expSnap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.expedientesCompletos)
          .where('uid', isEqualTo: uid)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfYear))
          .get();

      _totalExpedientes = expSnap.docs.length;

      final Map<String, int> fraccionCount = {};

      for (final doc in expSnap.docs) {
        final data = doc.data();
        // Month
        final ts = data['createdAt'];
        if (ts is Timestamp) {
          final month = ts.toDate().month;
          final key = _monthName(month);
          _operacionesPorMes[key] = (_operacionesPorMes[key] ?? 0) + 1;
        }
        // Aduana
        final aduana = data['aduana'] as String? ?? 'Otra';
        _operacionesPorAduana[aduana] =
            (_operacionesPorAduana[aduana] ?? 0) + 1;
        // FOB value
        _totalValorFob += (data['valorFob'] as num? ?? 0).toDouble();
        // Fraccion
        final fraccion = data['fraccionPrincipal'] as String? ?? '';
        if (fraccion.isNotEmpty) {
          fraccionCount[fraccion] = (fraccionCount[fraccion] ?? 0) + 1;
        }
      }

      // Top 5 fracciones
      final sortedFracciones = fraccionCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _topFracciones = sortedFracciones
          .take(5)
          .map((e) => {'fraccion': e.key, 'count': e.value})
          .toList();

      // Top aduana (No longer used directly as we show top 5 list)

      // 2. Purchase Orders
      final poSnap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.purchaseOrders)
          .where('uid', isEqualTo: uid)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfYear))
          .get();
      _totalPos = poSnap.docs.length;

      final Map<String, int> supplierCount = {};
      for (final doc in poSnap.docs) {
        final supplier = doc.data()['supplierName'] as String? ?? 'Desconocido';
        supplierCount[supplier] = (supplierCount[supplier] ?? 0) + 1;
      }
      if (supplierCount.isNotEmpty) {
        final top =
            supplierCount.entries.reduce((a, b) => a.value > b.value ? a : b);
        _topProveedorNombre = top.key;
        _topProveedorOps = top.value;
      }

      // 3. Drawback recuperado
      final drawbackSnap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.drawbackHistorial)
          .where('uid', isEqualTo: uid)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfYear))
          .get();
      _totalDrawbackRecuperado = drawbackSnap.docs.fold(
          0.0,
          (acc, d) =>
              acc + ((d.data()['totalRecuperable'] as num? ?? 0).toDouble()));

      // 4. TCO / Ahorro TMEC
      final tcoSnap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.tcoAnalisis)
          .where('uid', isEqualTo: uid)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfYear))
          .get();
      _ahorroTmec = tcoSnap.docs.fold(0.0,
          (acc, d) => acc + ((d.data()['ahorro'] as num? ?? 0).toDouble()));

      // 5. NOMs
      final nomSnap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.nomVigencias)
          .where('uid', isEqualTo: uid)
          .get();
      final now = DateTime.now();
      for (final doc in nomSnap.docs) {
        final raw = doc.data()['fechaVigencia'];
        DateTime? vigencia;
        if (raw is Timestamp) {
          vigencia = raw.toDate();
        } else if (raw is String) {
          vigencia = DateTime.tryParse(raw);
        }
        if (vigencia == null) {
          continue;
        }
        if (vigencia.isAfter(now)) {
          _nomsActivas++;
        } else {
          _nomsVencidas++;
        }
      }

      // Capital total (FOB in MXN with estimated TC 17.15)
      _capitalInvertido = _totalValorFob * 17.15;
    } catch (e) {
      // Silent fail
    }
  }

  String _monthName(int month) {
    const names = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return names[month];
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        backgroundColor: AppColors.card,
        title: Text('📅 Resumen Anual $_selectedYear',
            style: AppTextStyles.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFFF59E0B)),
            tooltip: 'Compartir por WhatsApp',
            onPressed: () {
              final msg = '''
🏆 Mi Resumen de Importaciones $_selectedYear
━━━━━━━━━━━━━━━━━━━━
💰 Total importado: ${_fmtCompact.format(_totalValorFob)} USD
📦 Operaciones: $_totalExpedientes

Gestionado con Aduanas 801 🛡️
https://aduana-801.web.app
              '''
                  .trim();
              ShareUtils.shareViaWhatsApp(msg);
            },
          ),
          DropdownButton<int>(
            value: _selectedYear,
            dropdownColor: AppColors.card,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.text),
            items: [currentYear, currentYear - 1, currentYear - 2].map((y) {
              return DropdownMenuItem(
                value: y,
                child: Text('$y', style: AppTextStyles.bodyLarge),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedYear = val);
                _loadData();
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (c, i) => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: SkeletonLoader(height: 120),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 24),
                  _buildKpiGrid(),
                  const SizedBox(height: 24),
                  _buildOperacionesPorMes(),
                  const SizedBox(height: 24),
                  _buildTopAduanas(),
                  const SizedBox(height: 24),
                  _buildTopFracciones(),
                  const SizedBox(height: 24),
                  _buildLogros(),
                  const SizedBox(height: 32),
                  _buildFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F2027),
            const Color(0xFF2C5364),
            const Color(0xFFF59E0B).withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text('$_selectedYear',
              style:
                  AppTextStyles.displayLarge.copyWith(color: AppColors.gold)),
          const Text('Tu año en comercio exterior',
              style: TextStyle(color: Colors.white70, fontSize: 16)),
          if (_totalExpedientes == 0 && _totalPos == 0) ...[
            const SizedBox(height: 16),
            Text('Comienza registrando tus operaciones en $_selectedYear',
                style: AppTextStyles.bodyMedium),
          ],
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeroStat('\$${_fmtCompact.format(_totalValorFob)} USD',
                  'Valor importado'),
              _buildHeroStat('\$${_fmtCompact.format(_capitalInvertido)} MXN',
                  'Capital invertido'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeroStat('$_totalExpedientes', 'Operaciones'),
              _buildHeroStat('$_totalPos', 'POs creadas'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.headlineLarge.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildKpiGrid() {
    if (_ahorroTmec == 0 &&
        _totalDrawbackRecuperado == 0 &&
        _nomsActivas == 0 &&
        _topProveedorOps == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: const Center(
          child: Text(
              'Sin datos suficientes para este año. Comienza registrando tus operaciones.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium),
        ),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildKpiCard('Ahorro TMEC', '\$${_fmtCompact.format(_ahorroTmec)} MXN',
            'Mediante Certificados de Origen', AppColors.green),
        _buildKpiCard(
            'Drawback Recuperado',
            '\$${_fmtCompact.format(_totalDrawbackRecuperado)} MXN',
            'Impuestos recuperados',
            AppColors.green),
        _buildKpiCard('NOMs Activas', '$_nomsActivas',
            '$_nomsVencidas vencidas', AppColors.blue),
        _buildKpiCard(
            'Top Proveedor',
            _topProveedorNombre.isEmpty ? '--' : _topProveedorNombre,
            '$_topProveedorOps operaciones',
            AppColors.text),
      ],
    );
  }

  Widget _buildKpiCard(
      String title, String value, String sub, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.sub, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value,
              style: AppTextStyles.headlineMedium.copyWith(color: valueColor)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: AppColors.sub, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildOperacionesPorMes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 Operaciones por mes',
              style: AppTextStyles.headlineLarge),
          const SizedBox(height: 24),
          if (_operacionesPorMes.isEmpty)
            const Text('Sin datos.', style: AppTextStyles.bodyMedium)
          else
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(12, (i) {
                  final month = _monthName(i + 1);
                  final count = _operacionesPorMes[month] ?? 0;
                  final maxCount = _operacionesPorMes.values.isEmpty
                      ? 1
                      : _operacionesPorMes.values
                          .reduce((a, b) => a > b ? a : b);
                  final safeMax = maxCount == 0 ? 1 : maxCount;
                  final barHeight = count == 0 ? 4.0 : (count / safeMax) * 80.0;
                  final isCurrentMonth = (i + 1) == DateTime.now().month &&
                      _selectedYear == DateTime.now().year;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (count > 0)
                          Text('$count',
                              style: const TextStyle(
                                  color: AppColors.sub, fontSize: 8)),
                        Container(
                          height: barHeight.clamp(4.0, 80.0),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isCurrentMonth
                                ? AppColors.gold
                                : AppColors.blue.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(month,
                            style: const TextStyle(
                                color: AppColors.sub, fontSize: 8)),
                      ],
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopAduanas() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏛️ Operaciones por aduana',
              style: AppTextStyles.headlineLarge),
          const SizedBox(height: 16),
          if (_operacionesPorAduana.isEmpty)
            const Text('Sin datos de aduanas. Registra tus expedientes.',
                style: AppTextStyles.bodyMedium)
          else ...[
            ...(_operacionesPorAduana.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .take(5)
                .map((entry) {
              final pct =
                  _totalExpedientes > 0 ? entry.value / _totalExpedientes : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                        width: 120,
                        child: Text(entry.key,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                            value: pct,
                            color: AppColors.blue,
                            backgroundColor: AppColors.border,
                            minHeight: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                        width: 30,
                        child: Text('${entry.value}',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.right)),
                  ],
                ),
              );
            }),
          ]
        ],
      ),
    );
  }

  Widget _buildTopFracciones() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔢 Fracciones más importadas',
              style: AppTextStyles.headlineLarge),
          const SizedBox(height: 16),
          if (_topFracciones.isEmpty)
            const Text('Registra fracciones arancelarias en tus expedientes.',
                style: AppTextStyles.bodyMedium)
          else
            ..._topFracciones.map((f) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(f['fraccion'].toString(),
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontFamily: 'monospace',
                            fontSize: 13)),
                  ),
                  trailing: Text('${f['count']} ops',
                      style: const TextStyle(color: AppColors.sub)),
                )),
        ],
      ),
    );
  }

  Widget _buildLogros() {
    final achievements = <Map<String, dynamic>>[
      if (_totalExpedientes >= 1)
        {
          'icon': '📦',
          'title': 'Primera operación',
          'sub': 'Completaste tu primer expediente',
          'earned': true
        },
      if (_totalExpedientes >= 10)
        {
          'icon': '🚀',
          'title': 'Operador activo',
          'sub': '10+ expedientes en el año',
          'earned': true
        },
      if (_totalExpedientes >= 50)
        {
          'icon': '🏆',
          'title': 'Maestro del despacho',
          'sub': '50+ expedientes',
          'earned': true
        },
      if (_ahorroTmec > 0)
        {
          'icon': '🇺🇸',
          'title': 'Experto TMEC',
          'sub': 'Usaste Certificados de Origen',
          'earned': true
        },
      if (_totalDrawbackRecuperado > 0)
        {
          'icon': '💰',
          'title': 'Recuperador fiscal',
          'sub': 'Usaste Duty Drawback',
          'earned': true
        },
      if (_nomsVencidas == 0 && _nomsActivas > 0)
        {
          'icon': '✅',
          'title': 'Cumplimiento perfecto',
          'sub': '0 NOMs vencidas',
          'earned': true
        },
      if (_totalExpedientes < 10)
        {
          'icon': '🚀',
          'title': 'Operador activo',
          'sub': '${10 - _totalExpedientes} expedientes más para lograrlo',
          'earned': false
        },
      if (_ahorroTmec == 0)
        {
          'icon': '🇺🇸',
          'title': 'Experto TMEC',
          'sub': 'Registra ahorro con C.O. TMEC',
          'earned': false
        },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏆 Logros $_selectedYear', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: achievements.map((ach) {
              final earned = ach['earned'] as bool;
              return Tooltip(
                message: ach['sub'].toString(),
                child: Chip(
                  avatar: Text(ach['icon'].toString()),
                  label: Text(ach['title'].toString(),
                      style: TextStyle(
                          color: earned ? Colors.white : AppColors.sub)),
                  backgroundColor: earned ? AppColors.bg2 : Colors.transparent,
                  side: BorderSide(
                    color: earned ? AppColors.gold : AppColors.border,
                    style: earned ? BorderStyle.solid : BorderStyle.none,
                  ),
                  shape: earned
                      ? null
                      : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                              color: AppColors
                                  .border) // Dashed effect could be done with package, but solid is fine for basic
                          ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/importer_dashboard'),
            icon: const Icon(Icons.dashboard),
            label: const Text('📊 Ver Dashboard Importador'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context
                .push('/coming_soon', extra: {'title': 'Exportar Reporte PDF'}),
            icon: const Icon(Icons.download),
            label: const Text('📥 Exportar Reporte PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gold,
              side: const BorderSide(color: AppColors.gold),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
