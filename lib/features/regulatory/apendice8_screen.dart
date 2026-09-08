import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _gold = AppColors.gold;
const Color _red = AppColors.red;

class _Identifier {
  final String clave;
  final String desc;
  final String detalle;
  final String categoria;
  final List<String> incompatibleCon;
  const _Identifier(
      {required this.clave,
      required this.desc,
      required this.detalle,
      required this.categoria,
      required this.incompatibleCon});
}

class Apendice8Screen extends StatefulWidget {
  const Apendice8Screen({super.key});

  @override
  State<Apendice8Screen> createState() => _Apendice8ScreenState();
}

class _Apendice8ScreenState extends State<Apendice8Screen> {
  static const _identifiers = [
    _Identifier(
        clave: 'AF',
        desc: 'Acuerdo de Libre Comercio',
        detalle: 'Clave del tratado: TM=T-MEC, UE=UE, JP=Japón, CH=Chile, etc.',
        categoria: 'Origen',
        incompatibleCon: []),
    _Identifier(
        clave: 'TL',
        desc: 'Preferencia T-MEC/USMCA',
        detalle:
            'Preferencia arancelaria bajo T-MEC. Requiere AF=TM y certificado de origen.',
        categoria: 'Origen',
        incompatibleCon: ['BX']),
    _Identifier(
        clave: 'AI',
        desc: 'Tipo de Valor en Aduana',
        detalle:
            '1=Valor de Transacción (Art.64 LA), 2=Idénticas, 3=Similares, 4=Deductivo, 5=Reconstruido, 6=Último recurso',
        categoria: 'Valoración',
        incompatibleCon: []),
    _Identifier(
        clave: 'VM',
        desc: 'Valor en Moneda Extranjera',
        detalle: 'Valor de la factura en moneda original de la transacción',
        categoria: 'Valoración',
        incompatibleCon: []),
    _Identifier(
        clave: 'FJ',
        desc: 'Factura de Tercero',
        detalle:
            'Cuando la factura es expedida por un tercero diferente al vendedor',
        categoria: 'Valoración',
        incompatibleCon: []),
    _Identifier(
        clave: 'EP',
        desc: 'Empresa IMMEX',
        detalle: 'Número de programa IMMEX de la empresa importadora',
        categoria: 'IMMEX',
        incompatibleCon: []),
    _Identifier(
        clave: 'FR',
        desc: 'Fracción IMMEX',
        detalle:
            'Fracción del bien de capital o materia prima autorizada en el programa IMMEX',
        categoria: 'IMMEX',
        incompatibleCon: []),
    _Identifier(
        clave: 'SP',
        desc: 'Sector Productivo IMMEX',
        detalle:
            'Sector productivo de la empresa IMMEX: 1=Manufactura, 2=Servicios, etc.',
        categoria: 'IMMEX',
        incompatibleCon: []),
    _Identifier(
        clave: 'TR',
        desc: 'Tránsito Aduanero',
        detalle: 'Clave de tránsito interno o internacional',
        categoria: 'Transporte',
        incompatibleCon: []),
    _Identifier(
        clave: 'MN',
        desc: 'Número de Manifiesto',
        detalle: 'Número de manifiesto de carga del transportista',
        categoria: 'Transporte',
        incompatibleCon: []),
    _Identifier(
        clave: 'BL',
        desc: 'Bill of Lading',
        detalle: 'Número del conocimiento de embarque marítimo',
        categoria: 'Transporte',
        incompatibleCon: []),
    _Identifier(
        clave: 'SC',
        desc: 'Pedimento Consolidado',
        detalle: 'Tipo de consolidación: 1=Diaria, 2=Semanal, 3=Mensual',
        categoria: 'Régimen',
        incompatibleCon: []),
    _Identifier(
        clave: 'OA',
        desc: 'Operación Anterior',
        detalle: 'Número de pedimento de la operación anterior relacionada',
        categoria: 'Régimen',
        incompatibleCon: []),
    _Identifier(
        clave: 'PF',
        desc: 'Pedimento de Extracción',
        detalle:
            'Pedimento con el que se realizó la extracción de recinto fiscal',
        categoria: 'Régimen',
        incompatibleCon: []),
    _Identifier(
        clave: 'AN',
        desc: 'Número de Autorización Previa',
        detalle:
            'Número de autorización previa emitida por SE, COFEPRIS, SADER, etc.',
        categoria: 'Régimen',
        incompatibleCon: []),
    _Identifier(
        clave: 'PA',
        desc: 'Patente del Agente Aduanal',
        detalle:
            'Número de patente del agente aduanal que despacha la operación',
        categoria: 'Otros',
        incompatibleCon: []),
    _Identifier(
        clave: 'MA',
        desc: 'Medida de Administración (NOM/Permiso)',
        detalle:
            'Número de NOM, permiso previo o regulación no arancelaria aplicable',
        categoria: 'Otros',
        incompatibleCon: []),
    _Identifier(
        clave: 'CN',
        desc: 'Cuota Compensatoria',
        detalle: 'Clave de la cuota compensatoria aplicable a la fracción',
        categoria: 'Otros',
        incompatibleCon: []),
    _Identifier(
        clave: 'HA',
        desc: 'Marca del Producto',
        detalle: 'Marca comercial del bien importado/exportado',
        categoria: 'Otros',
        incompatibleCon: []),
    _Identifier(
        clave: 'E1',
        desc: 'Empresa Certificada (OEA)',
        detalle:
            'Número de certificación OEA (Operador Económico Autorizado) o CTPAT',
        categoria: 'Otros',
        incompatibleCon: []),
    _Identifier(
        clave: 'GE',
        desc: 'Tipo de Garantía',
        detalle:
            'Tipo de garantía utilizada: 1=Efectivo, 2=Fianza, 3=Embargo precautorio',
        categoria: 'Otros',
        incompatibleCon: []),
    _Identifier(
        clave: 'DH',
        desc: 'Datos del Importador',
        detalle:
            'Datos adicionales del importador para pedimentos sin domicilio fiscal en México',
        categoria: 'Otros',
        incompatibleCon: []),
    _Identifier(
        clave: 'AX',
        desc: 'Número de Parte / Subfracción',
        detalle:
            'Part number o número de parte del fabricante. Requerido en algunos regímenes IMMEX',
        categoria: 'Otros',
        incompatibleCon: []),
    _Identifier(
        clave: 'ID',
        desc: 'Identificador de Documento',
        detalle:
            'Referencia a documento adicional (factura, packing list, etc.)',
        categoria: 'Otros',
        incompatibleCon: []),
  ];

  final Set<String> _selectedClaves = {};
  String _search = '';
  String _categoriaSeleccionada = 'Todos';

  void _toggle(String clave) {
    setState(() {
      if (_selectedClaves.contains(clave)) {
        _selectedClaves.remove(clave);
      } else {
        final iden = _identifiers.firstWhere((i) => i.clave == clave);
        for (final ic in iden.incompatibleCon) {
          if (_selectedClaves.contains(ic)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('\$clave es incompatible con \$ic',
                    style: TextStyle(color: _bg)),
                backgroundColor: _gold));
            return;
          }
        }
        for (final sel in _selectedClaves) {
          final selIden = _identifiers.firstWhere((i) => i.clave == sel);
          if (selIden.incompatibleCon.contains(clave)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('\$clave es incompatible con \$sel',
                    style: TextStyle(color: _bg)),
                backgroundColor: _gold));
            return;
          }
        }
        _selectedClaves.add(clave);
      }
    });
  }

  void _copiar() {
    final str = _selectedClaves.map((c) => '\$c=VALOR').join('|');
    Clipboard.setData(ClipboardData(text: str));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Combinación copiada al portapapeles',
            style: TextStyle(color: _bg)),
        backgroundColor: _gold));
  }

  @override
  Widget build(BuildContext context) {
    final cats = [
      'Todos',
      'Régimen',
      'Valoración',
      'Origen',
      'Transporte',
      'IMMEX',
      'Otros'
    ];
    final filtered = _identifiers.where((i) {
      if (_categoriaSeleccionada != 'Todos' &&
          i.categoria != _categoriaSeleccionada) {
        return false;
      }
      if (_search.isEmpty) return true;
      return i.clave.toLowerCase().contains(_search.toLowerCase()) ||
          i.desc.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Apéndice 8 · Matriz de Identificadores',
            style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Identificadores Complementarios del Pedimento (RGCE Apéndice 8). Selecciona los que aplican a tu operación.',
                style: TextStyle(color: _sec, fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: _texto),
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Buscar por clave o descripción...',
                      hintStyle: const TextStyle(color: _sec),
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
                          borderSide: const BorderSide(color: _gold)),
                      prefixIcon: const Icon(Icons.search, color: _gold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cats.map((c) {
                  final selected = c == _categoriaSeleccionada;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(c,
                          style: TextStyle(
                              color: selected ? _bg : _texto,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      selected: selected,
                      selectedColor: _gold,
                      backgroundColor: _card,
                      side: BorderSide(color: selected ? _gold : _bord),
                      onSelected: (val) {
                        if (val) setState(() => _categoriaSeleccionada = c);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final iden = filtered[index];
                        final isSelected = _selectedClaves.contains(iden.clave);
                        bool isConflict = false;
                        if (!isSelected) {
                          for (final s in _selectedClaves) {
                            final sIden =
                                _identifiers.firstWhere((i) => i.clave == s);
                            if (sIden.incompatibleCon.contains(iden.clave) ||
                                iden.incompatibleCon.contains(s)) {
                              isConflict = true;
                              break;
                            }
                          }
                        }
                        return _IdentifierCard(
                          iden: iden,
                          isSelected: isSelected,
                          isConflict: isConflict,
                          onToggle: () => _toggle(iden.clave),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _card,
                        border: Border.all(color: _bord),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.fact_check, color: _gold),
                              SizedBox(width: 8),
                              Text('Seleccionados',
                                  style: TextStyle(
                                      color: _gold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: _bord),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _selectedClaves.isEmpty
                                ? const Center(
                                    child: Text(
                                        'No hay identificadores seleccionados',
                                        style: TextStyle(
                                            color: _sec, fontSize: 14),
                                        textAlign: TextAlign.center),
                                  )
                                : ListView(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: _selectedClaves.map((c) {
                                      final iden = _identifiers
                                          .firstWhere((i) => i.clave == c);
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _bg,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(color: _bord),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(iden.clave,
                                                style: const TextStyle(
                                                    color: _gold,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            const SizedBox(width: 12),
                                            Expanded(
                                                child: Text(iden.desc,
                                                    style: const TextStyle(
                                                        color: _sec,
                                                        fontSize: 12),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () => _toggle(c),
                                                child: const Icon(Icons.close,
                                                    color: _red, size: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                          if (_selectedClaves.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _copiar,
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Copiar combinación',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: _bg,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  setState(() => _selectedClaves.clear()),
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Limpiar selección'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _sec,
                                side: const BorderSide(color: _bord),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ]
                        ],
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

class _IdentifierCard extends StatefulWidget {
  final _Identifier iden;
  final bool isSelected;
  final bool isConflict;
  final VoidCallback onToggle;

  const _IdentifierCard(
      {required this.iden,
      required this.isSelected,
      required this.isConflict,
      required this.onToggle});

  @override
  State<_IdentifierCard> createState() => _IdentifierCardState();
}

class _IdentifierCardState extends State<_IdentifierCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.isConflict
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isConflict ? null : widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _gold.withValues(alpha: 0.1)
                : (_hover && !widget.isConflict
                    ? const Color(0xFF14243D)
                    : _card),
            border: Border.all(
                color: widget.isConflict
                    ? _red
                    : widget.isSelected
                        ? _gold
                        : (_hover ? _gold.withValues(alpha: 0.5) : _bord),
                width: widget.isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (widget.isSelected || _hover)
                BoxShadow(
                    color: widget.isConflict
                        ? _red.withValues(alpha: 0.1)
                        : _gold.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.iden.clave,
                      style: TextStyle(
                          color: widget.isSelected ? _gold : _texto,
                          fontWeight: FontWeight.bold,
                          fontSize: 22)),
                  if (widget.isConflict)
                    const Icon(Icons.warning_amber, color: _red, size: 20)
                  else if (widget.isSelected)
                    const Icon(Icons.check_circle, color: _gold, size: 20)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _bord)),
                      child: Text(widget.iden.categoria,
                          style: const TextStyle(
                              color: _sec,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    )
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                  child: Text(widget.iden.desc,
                      style: TextStyle(
                          color: widget.isSelected ? _texto : _sec,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2)),
              const SizedBox(height: 4),
              Text(widget.iden.detalle,
                  style: const TextStyle(color: _sec, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
