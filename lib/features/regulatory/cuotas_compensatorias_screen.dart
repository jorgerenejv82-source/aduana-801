import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _gold = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;

class CuotaCompensatoria {
  final String fraccion;
  final String desc;
  final String pais;
  final double cuota;
  final String tipo;
  final String estado;
  final String resolucion;
  final String vigencia;

  CuotaCompensatoria({
    required this.fraccion,
    required this.desc,
    required this.pais,
    required this.cuota,
    required this.tipo,
    required this.estado,
    required this.resolucion,
    required this.vigencia,
  });
}

class CuotasCompensatoriasScreen extends StatefulWidget {
  const CuotasCompensatoriasScreen({super.key});

  @override
  _CuotasCompensatoriasScreenState createState() =>
      _CuotasCompensatoriasScreenState();
}

class _CuotasCompensatoriasScreenState extends State<CuotasCompensatoriasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  final List<String> _filters = [
    'Todos',
    'Antidumping',
    'Cuota Compensatoria',
    'Provisional',
    'Definitiva'
  ];

  final List<CuotaCompensatoria> _db = [
    CuotaCompensatoria(
        fraccion: '7208.10.01',
        desc: 'Lamina de acero laminada en caliente',
        pais: 'China',
        cuota: 28.5,
        tipo: 'Antidumping',
        estado: 'Definitiva',
        resolucion: 'DOF 15-Mar-2023',
        vigencia: 'Indefinida'),
    CuotaCompensatoria(
        fraccion: '6401.10.01',
        desc: 'Calzado impermeable con suela y parte superior de caucho',
        pais: 'China',
        cuota: 255.0,
        tipo: 'Cuota Compensatoria',
        estado: 'Definitiva',
        resolucion: 'DOF 20-Ene-2022',
        vigencia: 'Indefinida'),
    CuotaCompensatoria(
        fraccion: '0207.13.01',
        desc: 'Trozos y despojos de gallo o gallina, frescos o refrigerados',
        pais: 'USA',
        cuota: 45.95,
        tipo: 'Cuota Compensatoria',
        estado: 'Definitiva',
        resolucion: 'DOF 05-Jul-2022',
        vigencia: 'Indefinida'),
    CuotaCompensatoria(
        fraccion: '7209.16.01',
        desc: 'Lamina de acero laminada en frio',
        pais: 'China',
        cuota: 52.8,
        tipo: 'Antidumping',
        estado: 'Definitiva',
        resolucion: 'DOF 10-May-2023',
        vigencia: 'Indefinida'),
    CuotaCompensatoria(
        fraccion: '7210.70.01',
        desc: 'Lamina de acero recubierta de cinc',
        pais: 'China',
        cuota: 37.2,
        tipo: 'Antidumping',
        estado: 'Definitiva',
        resolucion: 'DOF 22-Ago-2023',
        vigencia: 'Indefinida'),
    CuotaCompensatoria(
        fraccion: '3901.10.01',
        desc: 'Polietileno de densidad inferior a 0.94 en formas primarias',
        pais: 'USA',
        cuota: 24.3,
        tipo: 'Cuota Compensatoria',
        estado: 'Definitiva',
        resolucion: 'DOF 18-Feb-2023',
        vigencia: '5 a�os'),
    CuotaCompensatoria(
        fraccion: '8544.42.01',
        desc: 'Conductores electricos para tension <= 1000V con conector',
        pais: 'China',
        cuota: 63.5,
        tipo: 'Antidumping',
        estado: 'Definitiva',
        resolucion: 'DOF 30-Nov-2022',
        vigencia: 'Indefinida'),
    CuotaCompensatoria(
        fraccion: '7304.31.01',
        desc: 'Tubo sin costura de hierro o acero, seccion circular',
        pais: 'China',
        cuota: 41.7,
        tipo: 'Antidumping',
        estado: 'Provisional',
        resolucion: 'DOF 12-Ene-2024',
        vigencia: '4 meses'),
    CuotaCompensatoria(
        fraccion: '4802.55.01',
        desc: 'Papel para escribir o imprimir en bobinas',
        pais: 'China',
        cuota: 33.0,
        tipo: 'Cuota Compensatoria',
        estado: 'Definitiva',
        resolucion: 'DOF 25-Sep-2023',
        vigencia: 'Indefinida'),
    CuotaCompensatoria(
        fraccion: '7601.10.01',
        desc: 'Aluminio sin alear en formas en bruto',
        pais: 'China',
        cuota: 18.9,
        tipo: 'Antidumping',
        estado: 'Definitiva',
        resolucion: 'DOF 14-Jun-2023',
        vigencia: 'Indefinida'),
  ];

  final List<String> _historial = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CuotaCompensatoria> get _filteredResults {
    return _db.where((item) {
      final matchesSearch =
          item.fraccion.toLowerCase().contains(_searchQuery) ||
              item.desc.toLowerCase().contains(_searchQuery);

      bool matchesFilter = true;
      if (_selectedFilter != 'Todos') {
        if (_selectedFilter == 'Antidumping' ||
            _selectedFilter == 'Cuota Compensatoria') {
          matchesFilter = item.tipo == _selectedFilter;
        } else {
          matchesFilter = item.estado == _selectedFilter;
        }
      }
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _saveToHistorial(CuotaCompensatoria item) {
    final entry = '${item.fraccion} - ${item.desc}';
    if (!_historial.contains(entry)) {
      setState(() {
        _historial.insert(0, entry);
      });
    }
  }

  void _showCalculateDialog(CuotaCompensatoria item) {
    showDialog<void>(
      context: context,
      builder: (context) => CalcularImpactoDialog(item: item),
    );
  }

  String _getFlagEmoji(String country) {
    if (country == 'China') return '????';
    if (country == 'USA') return '????';
    return '???';
  }

  @override
  Widget build(BuildContext context) {
    final int definitivasCount =
        _db.where((e) => e.estado == 'Definitiva').length;
    final int provisionalesCount =
        _db.where((e) => e.estado == 'Provisional').length;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: _texto),
        ),
        title: const Text('Cuotas Compensatorias',
            style: TextStyle(color: _texto)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _azul,
          labelColor: _azul,
          unselectedLabelColor: _sec,
          tabs: const [
            Tab(text: 'Consultar'),
            Tab(text: 'Historial de Consultas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Consultar
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: _card,
                  border: Border(bottom: BorderSide(color: _bord)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                            label: 'Total',
                            value: '${_db.length}',
                            color: _azul),
                        _StatItem(
                            label: 'Definitivas',
                            value: '$definitivasCount',
                            color: _rojo),
                        _StatItem(
                            label: 'Provisionales',
                            value: '$provisionalesCount',
                            color: _gold),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: _texto),
                      decoration: InputDecoration(
                        hintText: 'Buscar por fracci�n o palabra clave...',
                        hintStyle: const TextStyle(color: _sec),
                        prefixIcon: const Icon(Icons.search, color: _sec),
                        filled: true,
                        fillColor: _bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: _bord),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: _bord),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final filter in _filters)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(filter),
                                selected: _selectedFilter == filter,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  }
                                },
                                backgroundColor: _bg,
                                selectedColor: _bord,
                                labelStyle: TextStyle(
                                  color:
                                      _selectedFilter == filter ? _texto : _sec,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _filteredResults.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron resultados',
                          style: TextStyle(color: _sec, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredResults.length,
                        itemBuilder: (context, index) {
                          final item = _filteredResults[index];
                          return GestureDetector(
                            onTap: () => _saveToHistorial(item),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _bord),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.fraccion,
                                        style: const TextStyle(
                                          color: _gold,
                                          fontFamily: 'monospace',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${item.cuota}%',
                                        style: const TextStyle(
                                          color: _rojo,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.desc,
                                    style: const TextStyle(
                                        color: _texto, fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                          '${_getFlagEmoji(item.pais)} ${item.pais}',
                                          style:
                                              const TextStyle(color: _texto)),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _bg,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(color: _bord),
                                        ),
                                        child: Text(
                                          item.tipo,
                                          style: const TextStyle(
                                              color: _texto, fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: item.estado == 'Definitiva'
                                              ? _rojo.withValues(alpha: 0.2)
                                              : _gold.withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: item.estado == 'Definitiva'
                                                  ? _rojo
                                                  : _gold),
                                        ),
                                        child: Text(
                                          item.estado,
                                          style: TextStyle(
                                            color: item.estado == 'Definitiva'
                                                ? _rojo
                                                : _gold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.description_outlined,
                                          color: _sec, size: 16),
                                      const SizedBox(width: 4),
                                      Text(item.resolucion,
                                          style: const TextStyle(
                                              color: _sec, fontSize: 12)),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.timer_outlined,
                                          color: _sec, size: 16),
                                      const SizedBox(width: 4),
                                      Text(item.vigencia,
                                          style: const TextStyle(
                                              color: _sec, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _saveToHistorial(item);
                                        _showCalculateDialog(item);
                                      },
                                      icon: const Icon(Icons.calculate,
                                          color: Colors.white),
                                      label: const Text('Calcular Impacto',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _azul,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          // Tab 2: Historial
          _historial.isEmpty
              ? const Center(
                  child: Text('No hay historial de consultas',
                      style: TextStyle(color: _sec)),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _historial.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _bord),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.history, color: _sec),
                        title: Text(_historial[index],
                            style: const TextStyle(color: _texto)),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: _sec, fontSize: 12)),
      ],
    );
  }
}

class CalcularImpactoDialog extends StatefulWidget {
  final CuotaCompensatoria item;

  const CalcularImpactoDialog({super.key, required this.item});

  @override
  _CalcularImpactoDialogState createState() => _CalcularImpactoDialogState();
}

class _CalcularImpactoDialogState extends State<CalcularImpactoDialog> {
  final TextEditingController _cifController = TextEditingController();
  double _cif = 0.0;

  @override
  void dispose() {
    _cifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cuotaMonto = _cif * (widget.item.cuota / 100);
    final double total = _cif + cuotaMonto;

    return AlertDialog(
      backgroundColor: _card,
      title: const Text('Calcular Impacto', style: TextStyle(color: _texto)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Fracci�n: ${widget.item.fraccion}',
              style: const TextStyle(color: _gold, fontFamily: 'monospace')),
          Text('Cuota: ${widget.item.cuota}%',
              style: const TextStyle(color: _rojo)),
          const SizedBox(height: 16),
          TextField(
            controller: _cifController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: _texto),
            decoration: const InputDecoration(
              labelText: 'Valor en Aduana (CIF)',
              labelStyle: TextStyle(color: _sec),
              prefixIcon: Icon(Icons.attach_money, color: _sec),
              enabledBorder:
                  UnderlineInputBorder(borderSide: BorderSide(color: _bord)),
              focusedBorder:
                  UnderlineInputBorder(borderSide: BorderSide(color: _azul)),
            ),
            onChanged: (val) {
              setState(() {
                _cif = double.tryParse(val) ?? 0.0;
              });
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Base gravable:', style: TextStyle(color: _sec)),
              Text('\$${_cif.toStringAsFixed(2)}',
                  style: const TextStyle(color: _texto)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monto Cuota:', style: TextStyle(color: _sec)),
              Text('\$${cuotaMonto.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: _rojo, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: _bord, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:',
                  style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: _verde,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar', style: TextStyle(color: _azul)),
        ),
      ],
    );
  }
}
