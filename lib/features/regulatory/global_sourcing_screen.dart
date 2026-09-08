import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Constantes de Diseño
const Color _bgCol = AppColors.bg;
const Color _cardsCol = AppColors.card;
const Color _borderCol = AppColors.border;
const Color _tealCol = AppColors.green;
const Color _ambarCol = AppColors.gold;
const Color _azulCol = AppColors.blue;
const Color _rojoCol = AppColors.red;
const Color _textoCol = AppColors.text;
const Color _secCol = AppColors.sub;

class GlobalSourcingScreen extends StatefulWidget {
  const GlobalSourcingScreen({super.key});

  @override
  State<GlobalSourcingScreen> createState() => _GlobalSourcingScreenState();
}

class _GlobalSourcingScreenState extends State<GlobalSourcingScreen> {
  // Directorio de proveedores mockeado
  final List<Map<String, dynamic>> _suppliers = [
    {
      'name': 'Shenzhen Tech Components Ltd.',
      'country': 'China',
      'countryCode': 'CN',
      'rating': 4.8,
      'category': 'Electrónica',
      'leadTime': '15-20 días',
      'moq': '1,000 uds',
      'certifications': ['ISO 9001', 'RoHS', 'CE'],
      'risk': 'Bajo'
    },
    {
      'name': 'Guangzhou Textiles & Apparel Co.',
      'country': 'China',
      'countryCode': 'CN',
      'rating': 4.5,
      'category': 'Textiles',
      'leadTime': '25-30 días',
      'moq': '5,000 uds',
      'certifications': ['ISO 9001', 'Oeko-Tex'],
      'risk': 'Medio'
    },
    {
      'name': 'Hindustan Auto Parts Mfg.',
      'country': 'India',
      'countryCode': 'IN',
      'rating': 4.7,
      'category': 'Automotriz',
      'leadTime': '30-40 días',
      'moq': '500 uds',
      'certifications': ['IATF 16949', 'ISO 14001'],
      'risk': 'Bajo'
    },
    {
      'name': 'Vietnam Woods & Furniture Export',
      'country': 'Vietnam',
      'countryCode': 'VN',
      'rating': 4.2,
      'category': 'Muebles',
      'leadTime': '40-45 días',
      'moq': '1 contenedor 20ft',
      'certifications': ['FSC'],
      'risk': 'Alto'
    },
    {
      'name': 'Taiwan Semiconductor Manufacturing (TSMC)',
      'country': 'Taiwán',
      'countryCode': 'TW',
      'rating': 5.0,
      'category': 'Semiconductores',
      'leadTime': '90-120 días',
      'moq': '10,000 uds',
      'certifications': ['ISO 9001', 'ISO 14001', 'IATF 16949'],
      'risk': 'Muy Bajo'
    },
    {
      'name': 'Bayerische Motoren Werke (Parts Div)',
      'country': 'Alemania',
      'countryCode': 'DE',
      'rating': 4.9,
      'category': 'Automotriz',
      'leadTime': '10-15 días',
      'moq': '100 uds',
      'certifications': ['TÜV', 'IATF 16949'],
      'risk': 'Muy Bajo'
    },
  ];

  String _filterCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = _suppliers;
    if (_filterCategory != 'Todos') {
      filtered =
          _suppliers.where((s) => s['category'] == _filterCategory).toList();
    }

    return Scaffold(
      backgroundColor: _bgCol,
      appBar: AppBar(
        backgroundColor: _bgCol,
        elevation: 0,
        title: const Text('Directorio Global Sourcing',
            style: TextStyle(
                color: _textoCol, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _ambarCol),
            onPressed: () => context.go('/home')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: _ambarCol),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Buscador avanzado no disponible en demo')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _SupplierCard(supplier: filtered[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: _bgCol,
        border: Border(bottom: BorderSide(color: _borderCol)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.filter_list, color: _secCol, size: 20),
            const SizedBox(width: 12),
            _filterChip('Todos'),
            const SizedBox(width: 8),
            _filterChip('Electrónica'),
            const SizedBox(width: 8),
            _filterChip('Automotriz'),
            const SizedBox(width: 8),
            _filterChip('Textiles'),
            const SizedBox(width: 8),
            _filterChip('Semiconductores'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final bool isSelected = _filterCategory == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _filterCategory = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _ambarCol.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? _ambarCol : _borderCol),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: isSelected ? _ambarCol : _secCol,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }
}

class _SupplierCard extends StatefulWidget {
  final Map<String, dynamic> supplier;
  const _SupplierCard({required this.supplier});

  @override
  State<_SupplierCard> createState() => _SupplierCardState();
}

class _SupplierCardState extends State<_SupplierCard> {
  bool _isHovering = false;
  bool _isHoveringAudit = false;
  bool _isHoveringPO = false;

  @override
  Widget build(BuildContext context) {
    Color riskColor = _tealCol;
    if (widget.supplier['risk'] == 'Medio') riskColor = _ambarCol;
    if (widget.supplier['risk'] == 'Alto') riskColor = _rojoCol;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: _cardsCol,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _isHovering ? _ambarCol : _borderCol),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovering ? 0.4 : 0.2),
              blurRadius: _isHovering ? 15 : 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _borderCol)),
              ),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _borderCol),
                    ),
                    child: CircleAvatar(
                      backgroundColor: _bgCol,
                      radius: 24,
                      child: Text(widget.supplier['countryCode'].toString(),
                          style: const TextStyle(
                              color: _textoCol,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.supplier['name'].toString(),
                            style: const TextStyle(
                                color: _textoCol,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: _secCol, size: 14),
                            const SizedBox(width: 4),
                            Text(widget.supplier['country'].toString(),
                                style: const TextStyle(
                                    color: _secCol, fontSize: 14)),
                            const SizedBox(width: 16),
                            const Icon(Icons.star, color: _ambarCol, size: 14),
                            const SizedBox(width: 4),
                            Text('${widget.supplier['rating']} / 5.0',
                                style: const TextStyle(
                                    color: _ambarCol,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: riskColor),
                    ),
                    child: Text('Riesgo ${widget.supplier['risk']}',
                        style: TextStyle(
                            color: riskColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Categoría',
                            style: TextStyle(
                                color: _secCol,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(widget.supplier['category'].toString(),
                            style: const TextStyle(
                                color: _textoCol,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        const Text('Lead Time',
                            style: TextStyle(
                                color: _secCol,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(widget.supplier['leadTime'].toString(),
                            style: const TextStyle(
                                color: _textoCol,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MOQ (Min. Order Qty)',
                            style: TextStyle(
                                color: _secCol,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(widget.supplier['moq'].toString(),
                            style: const TextStyle(
                                color: _textoCol,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        const Text('Certificaciones',
                            style: TextStyle(
                                color: _secCol,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (widget.supplier['certifications']
                                  as List<String>)
                              .map((cert) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: _azulCol.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: _azulCol.withValues(
                                                alpha: 0.5))),
                                    child: Text(cert,
                                        style: const TextStyle(
                                            color: _azulCol,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _bgCol.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHoveringAudit = true),
                    onExit: (_) => setState(() => _isHoveringAudit = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _isHoveringAudit
                                ? _secCol
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Generando auditoría de riesgo...')));
                        },
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12)),
                        child: const Text('Auditoría Compliance',
                            style: TextStyle(
                                color: _secCol,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHoveringPO = true),
                    onExit: (_) => setState(() => _isHoveringPO = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _isHoveringPO
                            ? [
                                BoxShadow(
                                    color: _ambarCol.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4))
                              ]
                            : [],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Abriendo creador de Purchase Order...'),
                                  backgroundColor: _ambarCol));
                        },
                        icon: const Icon(Icons.shopping_cart_checkout,
                            size: 16, color: _bgCol),
                        label: const Text('Crear PO',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _ambarCol,
                          foregroundColor: _bgCol,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
