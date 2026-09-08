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

class IncotermsScreen extends StatefulWidget {
  const IncotermsScreen({super.key});

  @override
  State<IncotermsScreen> createState() => _IncotermsScreenState();
}

class _IncotermsScreenState extends State<IncotermsScreen> {
  // Lista de los 11 Incoterms 2020
  final List<Map<String, dynamic>> _incoterms = [
    {
      'code': 'EXW', 'name': 'Ex Works',
      'type': 'Cualquier medio de transporte',
      'desc':
          'El vendedor entrega la mercancía poniéndola a disposición del comprador en sus propias instalaciones.',
      'riesgo': 10, 'costo': 10 // 0-100 (10 = vendedor, 90 = comprador)
    },
    {
      'code': 'FCA',
      'name': 'Free Carrier',
      'type': 'Cualquier medio de transporte',
      'desc':
          'El vendedor entrega la mercancía al porteador o a otra persona designada por el comprador en las instalaciones del vendedor u otro lugar designado.',
      'riesgo': 20,
      'costo': 20
    },
    {
      'code': 'FAS',
      'name': 'Free Alongside Ship',
      'type': 'Marítimo y vías navegables',
      'desc':
          'El vendedor entrega cuando la mercancía se coloca al costado del buque (ej. en un muelle) designado por el comprador en el puerto de embarque.',
      'riesgo': 30,
      'costo': 30
    },
    {
      'code': 'FOB',
      'name': 'Free On Board',
      'type': 'Marítimo y vías navegables',
      'desc':
          'El vendedor entrega la mercancía a bordo del buque designado por el comprador en el puerto de embarque designado.',
      'riesgo': 40,
      'costo': 40
    },
    {
      'code': 'CFR',
      'name': 'Cost and Freight',
      'type': 'Marítimo y vías navegables',
      'desc':
          'El vendedor asume el costo y flete necesarios para llevar la mercancía al puerto de destino, pero el riesgo se transmite a bordo del buque.',
      'riesgo': 40,
      'costo': 60
    },
    {
      'code': 'CIF',
      'name': 'Cost, Insurance and Freight',
      'type': 'Marítimo y vías navegables',
      'desc':
          'Igual que CFR, pero el vendedor también contrata y paga el seguro a favor del comprador.',
      'riesgo': 40,
      'costo': 70
    },
    {
      'code': 'CPT',
      'name': 'Carriage Paid To',
      'type': 'Cualquier medio de transporte',
      'desc':
          'El vendedor entrega la mercancía al porteador y paga los costos de transporte para llevarla al destino designado, pero el riesgo se transmite al entregar al primer porteador.',
      'riesgo': 20,
      'costo': 60
    },
    {
      'code': 'CIP',
      'name': 'Carriage and Insurance Paid To',
      'type': 'Cualquier medio de transporte',
      'desc':
          'Igual que CPT, pero el vendedor además contrata el seguro contra el riesgo de pérdida o daño durante el transporte.',
      'riesgo': 20,
      'costo': 70
    },
    {
      'code': 'DAP',
      'name': 'Delivered at Place',
      'type': 'Cualquier medio de transporte',
      'desc':
          'El vendedor asume todos los riesgos y costos asociados con el transporte de la mercancía hasta el lugar de destino designado, lista para la descarga.',
      'riesgo': 80,
      'costo': 80
    },
    {
      'code': 'DPU',
      'name': 'Delivered at Place Unloaded',
      'type': 'Cualquier medio de transporte',
      'desc':
          'El vendedor asume todos los riesgos y costos, incluida la descarga en el lugar de destino designado. (Reemplaza a DAT).',
      'riesgo': 90,
      'costo': 90
    },
    {
      'code': 'DDP',
      'name': 'Delivered Duty Paid',
      'type': 'Cualquier medio de transporte',
      'desc':
          'El vendedor asume todos los riesgos, costos, transportes y despachos (exportación e importación) hasta entregar en el destino.',
      'riesgo': 100,
      'costo': 100
    },
  ];

  String _filter = 'Todos';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = _incoterms;
    if (_filter != 'Todos') {
      filtered = _incoterms
          .where((i) => (i['type'] as String).contains(_filter))
          .toList();
    }

    return Scaffold(
      backgroundColor: _bgCol,
      appBar: AppBar(
        backgroundColor: _bgCol,
        elevation: 0,
        title: const Text('Guía de Incoterms 2020',
            style: TextStyle(
                color: _textoCol, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _ambarCol),
            onPressed: () => context.go('/home')),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _borderCol, height: 1)),
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
                return _IncotermCard(incoterm: filtered[index]);
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
      child: Row(
        children: [
          const Text('Modo de Transporte:',
              style: TextStyle(
                  color: _secCol, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          _filterChip('Todos'),
          const SizedBox(width: 12),
          _filterChip('Cualquier medio de transporte'),
          const SizedBox(width: 12),
          _filterChip('Marítimo y vías navegables'),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final bool isSelected = _filter == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _filter = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _ambarCol.withValues(alpha: 0.1) : _cardsCol,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? _ambarCol : _borderCol),
          ),
          child: Text(
            label == 'Cualquier medio de transporte'
                ? 'Multimodal'
                : (label == 'Marítimo y vías navegables' ? 'Marítimo' : label),
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

class _IncotermCard extends StatefulWidget {
  final Map<String, dynamic> incoterm;
  const _IncotermCard({required this.incoterm});

  @override
  State<_IncotermCard> createState() => _IncotermCardState();
}

class _IncotermCardState extends State<_IncotermCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bool isMaritimo =
        widget.incoterm['type'] == 'Marítimo y vías navegables';
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        transform: Matrix4.translationValues(0, _isHovering ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: _cardsCol,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  _isHovering ? _ambarCol.withValues(alpha: 0.5) : _borderCol),
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                      color: _ambarCol.withValues(alpha: 0.15),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: _ambarCol, borderRadius: BorderRadius.circular(8)),
                  child: Text(widget.incoterm['code'] as String,
                      style: const TextStyle(
                          color: _bgCol,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.incoterm['name'] as String,
                          style: const TextStyle(
                              color: _textoCol,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                              isMaritimo
                                  ? Icons.directions_boat
                                  : Icons.language,
                              color: _secCol,
                              size: 16),
                          const SizedBox(width: 6),
                          Text(widget.incoterm['type'] as String,
                              style: const TextStyle(
                                  color: _secCol, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(widget.incoterm['desc'] as String,
                style: const TextStyle(
                    color: _textoCol, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            _buildProgressBar('Responsabilidad y Costo (Vendedor vs Comprador)',
                widget.incoterm['costo'] as int, context),
            const SizedBox(height: 16),
            _buildProgressBar('Transmisión de Riesgo (Vendedor vs Comprador)',
                widget.incoterm['riesgo'] as int, context,
                isRisk: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
      String label, int sellerPercentage, BuildContext context,
      {bool isRisk = false}) {
    final Color sellerColor = isRisk ? _rojoCol : _azulCol;
    const Color buyerColor = _tealCol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: _secCol, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 14,
          width: double.infinity,
          decoration: BoxDecoration(
              color: buyerColor, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: MediaQuery.of(context).size.width > 600
                    ? 500 * (sellerPercentage / 100)
                    : 300 * (sellerPercentage / 100),
                decoration: BoxDecoration(
                  color: sellerColor,
                  borderRadius: sellerPercentage == 100
                      ? BorderRadius.circular(8)
                      : const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Vendedor ($sellerPercentage%)',
                style: TextStyle(
                    color: sellerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            Text('Comprador (${100 - sellerPercentage}%)',
                style: const TextStyle(
                    color: buyerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
