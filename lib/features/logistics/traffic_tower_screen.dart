import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;

class TrafficTowerScreen extends StatefulWidget {
  const TrafficTowerScreen({super.key});
  @override
  State<TrafficTowerScreen> createState() => _TrafficTowerScreenState();
}

class _TrafficTowerScreenState extends State<TrafficTowerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _hoveredIndex;
  int? _hoveredChip;
  String _activeFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _ambar),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: _azul.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _azul.withValues(alpha: 0.3))),
                child: const Icon(Icons.radar, color: _azul, size: 18)),
            const SizedBox(width: 12),
            const Text('Traffic Tower',
                style: TextStyle(
                    color: _ambar, fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _verde.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _verde.withValues(alpha: 0.3))),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.circle, size: 8, color: _verde),
                SizedBox(width: 6),
                Text('LIVE',
                    style: TextStyle(
                        color: _verde,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _azul,
          labelColor: _azul,
          unselectedLabelColor: _sec,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Mapa de Operaciones'),
            Tab(text: 'Lista de Embarques')
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                _buildStat('En Tránsito', '3', _azul),
                const SizedBox(width: 16),
                _buildStat('En Garita', '2', _ambar),
                const SizedBox(width: 16),
                _buildStat('Liberados Hoy', '4', _verde),
                const SizedBox(width: 16),
                _buildStat('Alertas', '1', _rojo),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildMapaTab(), _buildListaTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10)
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: _sec, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildMapaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _bord)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  Icon(Icons.location_city, color: _texto, size: 28),
                  SizedBox(height: 8),
                  Text('ORIGEN',
                      style: TextStyle(
                          color: _sec,
                          fontSize: 11,
                          fontWeight: FontWeight.bold))
                ]),
                Icon(Icons.arrow_forward, color: _sec, size: 20),
                Icon(Icons.directions_boat, color: _azul, size: 32),
                Icon(Icons.arrow_forward, color: _sec, size: 20),
                Column(children: [
                  Icon(Icons.account_balance, color: _texto, size: 28),
                  SizedBox(height: 8),
                  Text('ADUANA',
                      style: TextStyle(
                          color: _sec,
                          fontSize: 11,
                          fontWeight: FontWeight.bold))
                ]),
                Icon(Icons.arrow_forward, color: _sec, size: 20),
                Icon(Icons.local_shipping, color: _verde, size: 32),
                Icon(Icons.arrow_forward, color: _sec, size: 20),
                Column(children: [
                  Icon(Icons.home, color: _texto, size: 28),
                  SizedBox(height: 8),
                  Text('DESTINO',
                      style: TextStyle(
                          color: _sec,
                          fontSize: 11,
                          fontWeight: FontWeight.bold))
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _buildMapColumn('En Origen', [
                {
                  'ref': 'SHG-001',
                  'desc': 'Shanghai -> Manzanillo',
                  'status': '18 días en mar',
                  'color': _azul
                },
                {
                  'ref': 'SHG-002',
                  'desc': 'Hamburg -> Veracruz',
                  'status': '5 días en mar',
                  'color': _azul
                },
                {
                  'ref': 'TKO-001',
                  'desc': 'Tokyo -> Lázaro Cárdenas',
                  'status': '22 días en mar',
                  'color': _azul
                },
              ])),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildMapColumn('En Aduana', [
                {
                  'ref': 'MZL-2024-001',
                  'desc': 'Manzanillo',
                  'status': 'Semáforo ROJO - Reconocimiento',
                  'color': _rojo
                },
                {
                  'ref': 'VER-2024-005',
                  'desc': 'Veracruz',
                  'status': 'En trámite - Semáforo Amarillo',
                  'color': _ambar
                },
              ])),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildMapColumn('Liberados Hoy', [
                {
                  'ref': 'NLD-2024-088',
                  'desc': 'Nuevo Laredo',
                  'status': 'Liberado 08:30',
                  'color': _verde
                },
                {
                  'ref': 'NLD-2024-089',
                  'desc': 'Nuevo Laredo',
                  'status': 'Liberado 09:15',
                  'color': _verde
                },
                {
                  'ref': 'MZL-2024-099',
                  'desc': 'Manzanillo',
                  'status': 'Liberado 11:00',
                  'color': _verde
                },
                {
                  'ref': 'TIJ-2024-033',
                  'desc': 'Tijuana',
                  'status': 'Liberado 14:45',
                  'color': _verde
                },
              ])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapColumn(String title, List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _bord)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.circle, size: 8, color: _sec),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    color: _texto, fontWeight: FontWeight.bold, fontSize: 14))
          ]),
          const SizedBox(height: 16),
          for (final item in items)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: (item['color'] as Color).withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4)
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(item['ref'] as String,
                            style: const TextStyle(
                                color: _texto,
                                fontWeight: FontWeight.bold,
                                fontSize: 13))),
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: item['color'] as Color,
                            shape: BoxShape.circle))
                  ]),
                  const SizedBox(height: 8),
                  Text(item['desc'] as String,
                      style: const TextStyle(color: _sec, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(item['status'] as String,
                      style: TextStyle(
                          color: item['color'] as Color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListaTab() {
    final filters = ['Todos', 'En Mar', 'En Aduana', 'Liberado', 'Alerta'];
    final shipments = [
      {
        'ref': 'SHG-001',
        'ruta': 'Shanghai -> Manzanillo',
        'modo': 'Marítimo',
        'icon': Icons.directions_boat,
        'status': '18 días en mar',
        'color': _azul,
        'pedimento': 'PENDIENTE',
        'agente': 'Jorge M',
        'valor': 'USD 50,000',
        'incoterm': 'FOB',
        'obs': 'Sin novedad'
      },
      {
        'ref': 'SHG-002',
        'ruta': 'Hamburg -> Veracruz',
        'modo': 'Marítimo',
        'icon': Icons.directions_boat,
        'status': '5 días en mar',
        'color': _azul,
        'pedimento': 'PENDIENTE',
        'agente': 'Ana G',
        'valor': 'USD 20,000',
        'incoterm': 'CIF',
        'obs': 'Documentos listos'
      },
      {
        'ref': 'MZL-2024-001',
        'ruta': 'Manzanillo -> CDMX',
        'modo': 'Terrestre',
        'icon': Icons.local_shipping,
        'status': 'ROJO',
        'color': _rojo,
        'pedimento': '8099123',
        'agente': 'Jorge M',
        'valor': 'USD 45,000',
        'incoterm': 'DDP',
        'obs': 'En reconocimiento'
      },
      {
        'ref': 'VER-2024-005',
        'ruta': 'Veracruz -> Puebla',
        'modo': 'Terrestre',
        'icon': Icons.local_shipping,
        'status': 'AMARILLO',
        'color': _ambar,
        'pedimento': '8099124',
        'agente': 'Ana G',
        'valor': 'USD 15,000',
        'incoterm': 'DDP',
        'obs': 'Trámite pendiente'
      },
      {
        'ref': 'NLD-2024-088',
        'ruta': 'Laredo -> MTY',
        'modo': 'Terrestre',
        'icon': Icons.local_shipping,
        'status': 'VERDE',
        'color': _verde,
        'pedimento': '8099125',
        'agente': 'Luis T',
        'valor': 'USD 10,000',
        'incoterm': 'DAP',
        'obs': 'Liberado'
      },
    ];

    var filtered = shipments;
    if (_activeFilter != 'Todos') {
      if (_activeFilter == 'En Mar') {
        filtered = shipments
            .where((s) => (s['status'] as String).contains('mar'))
            .toList();
      } else if (_activeFilter == 'En Aduana') {
        filtered = shipments
            .where((s) => (s['status'] as String) == 'AMARILLO')
            .toList();
      } else if (_activeFilter == 'Liberado') {
        filtered =
            shipments.where((s) => (s['status'] as String) == 'VERDE').toList();
      } else if (_activeFilter == 'Alerta') {
        filtered =
            shipments.where((s) => (s['status'] as String) == 'ROJO').toList();
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            style: const TextStyle(color: _texto),
            decoration: InputDecoration(
              hintText: 'Buscar referencia, pedimento...',
              hintStyle: const TextStyle(color: _sec),
              prefixIcon: const Icon(Icons.search, color: _sec),
              filled: true,
              fillColor: _card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _bord)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _bord)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _ambar)),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              for (int i = 0; i < filters.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoveredChip = i),
                    onExit: (_) => setState(() => _hoveredChip = null),
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilter = filters[i]),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeFilter == filters[i]
                              ? _azul.withValues(alpha: 0.15)
                              : (_hoveredChip == i
                                  ? _card.withValues(alpha: 0.8)
                                  : _card),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                                  _activeFilter == filters[i] ? _azul : _bord),
                        ),
                        child: Text(filters[i],
                            style: TextStyle(
                                color: _activeFilter == filters[i]
                                    ? _azul
                                    : _texto,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              for (int i = 0; i < filtered.length; i++)
                MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = i),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: _hoveredIndex == i
                          ? _card.withValues(alpha: 0.8)
                          : _card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _hoveredIndex == i
                              ? (filtered[i]['color'] as Color)
                                  .withValues(alpha: 0.5)
                              : _bord),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10)
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        collapsedIconColor: _sec,
                        iconColor: _sec,
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                color: (filtered[i]['color'] as Color)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: (filtered[i]['color'] as Color)
                                        .withValues(alpha: 0.3))),
                            child: Icon(filtered[i]['icon'] as IconData,
                                color: filtered[i]['color'] as Color,
                                size: 24)),
                        title: Text(filtered[i]['ref'] as String,
                            style: const TextStyle(
                                color: _ambar,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(filtered[i]['ruta'] as String,
                                  style: const TextStyle(
                                      color: _texto, fontSize: 13)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text('${filtered[i]['modo']}  |  ',
                                      style: const TextStyle(
                                          color: _sec, fontSize: 12)),
                                  Text(filtered[i]['status'] as String,
                                      style: TextStyle(
                                          color: filtered[i]['color'] as Color,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: _bord)),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: _detailCol(
                                            'Pedimento',
                                            filtered[i]['pedimento']
                                                as String)),
                                    Expanded(
                                        child: _detailCol('Agente',
                                            filtered[i]['agente'] as String)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _detailCol('Valor',
                                            filtered[i]['valor'] as String)),
                                    Expanded(
                                        child: _detailCol('Incoterm',
                                            filtered[i]['incoterm'] as String)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _detailCol('Observaciones',
                                    filtered[i]['obs'] as String),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailCol(String label, String value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: _sec, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: _texto, fontSize: 14)),
      ]);
}
