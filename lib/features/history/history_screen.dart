import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistoryItem {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime date;
  final String? status;
  final Map<String, dynamic> rawData;

  HistoryItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.status,
    required this.rawData,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  List<HistoryItem> _allItems = [];
  List<HistoryItem> _filteredItems = [];
  String _selectedFilter = 'Todos';
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  final List<String> _filters = [
    'Todos',
    'Despacho',
    'Pre-Glosa',
    'Clasificacion',
    'Previo',
    'Encargos',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _allItems = [];
          _filteredItems = [];
        });
        return;
      }

      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;

      // Ensure queries match requirements
      final queries = [
        firestore
            .collection('expedientes')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get(),
        firestore
            .collection('operaciones')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get(),
        firestore
            .collection('pre_glosas')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get(),
        firestore
            .collection('glosas')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get(),
        firestore
            .collection('previos')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get(),
        firestore
            .collection('clasificaciones')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get(),
        firestore
            .collection('encargos')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get(),
      ];

      final results = await Future.wait(queries);

      final List<HistoryItem> items = [];

      void addItems(QuerySnapshot snapshot, String type,
          String Function(Map<String, dynamic>) titleBuilder) {
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final createdAt = data['createdAt'] as Timestamp?;
          if (createdAt == null) continue;

          items.add(HistoryItem(
            id: doc.id,
            type: type,
            title: titleBuilder(data),
            description: (data['description'] as String?) ?? 'Sin descripción',
            date: createdAt.toDate(),
            status: data['status'] as String?,
            rawData: data,
          ));
        }
      }

      addItems(results[0], 'Despacho',
          (data) => (data['referencia'] as String?) ?? 'Expediente');
      addItems(results[1], 'Operación',
          (data) => (data['tipo'] as String?) ?? 'Operación');
      addItems(results[2], 'Pre-Glosa',
          (data) => (data['pedimento'] as String?) ?? 'Pre-glosa');
      addItems(results[3], 'Glosa',
          (data) => (data['pedimento'] as String?) ?? 'Glosa');
      addItems(results[4], 'Previo',
          (data) => (data['guia'] as String?) ?? 'Previo');
      addItems(results[5], 'Clasificacion',
          (data) => (data['fraccion'] as String?) ?? 'Clasificación');
      addItems(results[6], 'Encargos',
          (data) => (data['tarea'] as String?) ?? 'Encargo');

      // Sort globally by date descending
      items.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _allItems = items;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar historial: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        // Text filter
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          if (!item.title.toLowerCase().contains(q) &&
              !item.description.toLowerCase().contains(q) &&
              !item.type.toLowerCase().contains(q)) {
            return false;
          }
        }

        // Category filter
        if (_selectedFilter != 'Todos') {
          if (_selectedFilter == 'Despacho' &&
              item.type != 'Despacho' &&
              item.type != 'Operación') {
            return false;
          }
          if (_selectedFilter == 'Pre-Glosa' &&
              item.type != 'Pre-Glosa' &&
              item.type != 'Glosa') {
            return false;
          }
          if (_selectedFilter == 'Clasificacion' &&
              item.type != 'Clasificacion') {
            return false;
          }
          if (_selectedFilter == 'Previo' && item.type != 'Previo') {
            return false;
          }
          if (_selectedFilter == 'Encargos' && item.type != 'Encargos') {
            return false;
          }
        }

        // Date range
        if (_selectedDateRange != null) {
          if (item.date.isBefore(_selectedDateRange!.start) ||
              item.date.isAfter(
                  _selectedDateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Historial de Operaciones - Aduanas 801',
                  style: const pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
                'Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              headers: ['Fecha', 'Tipo', 'Título', 'Estado'],
              data: _filteredItems
                  .map((item) => [
                        DateFormat('dd/MM/yyyy HH:mm').format(item.date),
                        item.type,
                        item.title,
                        item.status ?? '-',
                      ])
                  .toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Historial_Operaciones.pdf',
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Despacho':
      case 'Operación':
        return Icons.local_shipping;
      case 'Pre-Glosa':
      case 'Glosa':
        return Icons.fact_check;
      case 'Previo':
        return Icons.inventory;
      case 'Clasificacion':
        return Icons.category;
      case 'Encargos':
        return Icons.assignment;
      default:
        return Icons.history;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Despacho':
      case 'Operación':
        return const Color(0xFF3B82F6); // blue
      case 'Pre-Glosa':
      case 'Glosa':
        return AppColors.green; // green
      case 'Previo':
        return const Color(0xFFF59E0B); // gold
      case 'Clasificacion':
        return const Color(0xFF8B5CF6); // purple
      case 'Encargos':
        return AppColors.red; // red
      default:
        return const Color(0xFF94A3B8); // sub
    }
  }

  void _showItemDetails(HistoryItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getColorForType(item.type)
                            .withAlpha(51), // 0.2 * 255 ≈ 51
                        child: Icon(_getIconForType(item.type),
                            color: _getColorForType(item.type)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF8FAFC))),
                            Text(item.type,
                                style: TextStyle(
                                    color: _getColorForType(item.type),
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                      'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(item.date)}',
                      style: const TextStyle(color: Color(0xFF94A3B8))),
                  const SizedBox(height: 10),
                  Text('Descripción: ${item.description}',
                      style: const TextStyle(color: Color(0xFFF8FAFC))),
                  if (item.status != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Estado: ${item.status}',
                          style: const TextStyle(color: Color(0xFFF8FAFC))),
                    ),
                  ],
                  const Divider(color: Color(0xFF475569), height: 30),
                  const Text('Datos Adicionales:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC))),
                  const SizedBox(height: 10),
                  ...item.rawData.entries.map((e) {
                    if (e.key == 'createdAt' ||
                        e.key == 'updatedAt' ||
                        e.key == 'uid') {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(e.key,
                                  style: const TextStyle(
                                      color: Color(0xFF94A3B8)))),
                          Expanded(
                              flex: 3,
                              child: Text(e.value.toString(),
                                  style: const TextStyle(
                                      color: Color(0xFFF8FAFC)))),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Stats calculation
    final now = DateTime.now();
    final thisMonthItems = _allItems
        .where((i) => i.date.month == now.month && i.date.year == now.year);
    final totalThisMonth = thisMonthItems.length;
    final despachosCompletados = _allItems
        .where((i) =>
            (i.type == 'Despacho' || i.type == 'Operación') &&
            i.status?.toLowerCase() == 'completado')
        .length;
    final clasificacionesHechas =
        _allItems.where((i) => i.type == 'Clasificacion').length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Historial de Operaciones',
            style: TextStyle(color: Color(0xFFF8FAFC))),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Color(0xFFF8FAFC)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFF59E0B)),
            onPressed: _allItems.isEmpty ? null : _exportPdf,
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.date_range, color: Color(0xFF3B82F6)),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _selectedDateRange,
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF3B82F6),
                        onPrimary: Colors.white,
                        surface: Color(0xFF1E293B),
                        onSurface: Color(0xFFF8FAFC),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (range != null) {
                setState(() => _selectedDateRange = range);
                _applyFilters();
              }
            },
            tooltip: 'Rango de fechas',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E293B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatWidget(
                    title: 'Este Mes',
                    value: totalThisMonth.toString(),
                    icon: Icons.calendar_today,
                    color: const Color(0xFF3B82F6)),
                _StatWidget(
                    title: 'Despachos',
                    value: despachosCompletados.toString(),
                    icon: Icons.local_shipping,
                    color: AppColors.green),
                _StatWidget(
                    title: 'Clasific.',
                    value: clasificacionesHechas.toString(),
                    icon: Icons.category,
                    color: const Color(0xFF8B5CF6)),
              ],
            ),
          ),

          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedFilter = filter);
                              _applyFilters();
                            }
                          },
                          backgroundColor: const Color(0xFF1E293B),
                          selectedColor: const Color(0xFF3B82F6),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Text(
                          'Fechas: ${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}',
                          style: const TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.red, size: 18),
                          onPressed: () {
                            setState(() => _selectedDateRange = null);
                            _applyFilters();
                          },
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // History List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                : _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: const Color(0xFF3B82F6),
                        backgroundColor: const Color(0xFF1E293B),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return Card(
                              color: const Color(0xFF1E293B),
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      _getColorForType(item.type).withAlpha(51),
                                  child: Icon(_getIconForType(item.type),
                                      color: _getColorForType(item.type)),
                                ),
                                title: Text(item.title,
                                    style: const TextStyle(
                                        color: Color(0xFFF8FAFC),
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(item.type,
                                        style: TextStyle(
                                            color: _getColorForType(item.type),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                        DateFormat('dd MMM yyyy - HH:mm')
                                            .format(item.date),
                                        style: const TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 12)),
                                  ],
                                ),
                                trailing: item.status != null
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF334155),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(item.status!,
                                            style: const TextStyle(
                                                color: Color(0xFFF8FAFC),
                                                fontSize: 10)),
                                      )
                                    : const Icon(Icons.chevron_right,
                                        color: Color(0xFF475569)),
                                onTap: () => _showItemDetails(item),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off,
              size: 80, color: const Color(0xFF475569).withAlpha(128)),
          const SizedBox(height: 16),
          const Text('No hay historial',
              style: TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Tus operaciones, clasificaciones y más\naparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _StatWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatWidget({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(title,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
      ],
    );
  }
}
