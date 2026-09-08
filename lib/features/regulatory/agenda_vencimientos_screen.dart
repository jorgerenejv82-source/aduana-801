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
const Color _verde = AppColors.green;
const Color _blue = AppColors.blue;

class AgendaVencimientosScreen extends StatefulWidget {
  const AgendaVencimientosScreen({super.key});

  @override
  _AgendaVencimientosScreenState createState() =>
      _AgendaVencimientosScreenState();
}

class _AgendaVencimientosScreenState extends State<AgendaVencimientosScreen> {
  int _currentIndex = 0;
  String _vencFilter = 'Todos';
  final List<String> _vencFilters = [
    'Todos',
    'Hoy',
    'Esta Semana',
    'Este Mes',
    'Vencidos'
  ];

  final List<Map<String, dynamic>> _vencimientos = [
    {
      'time': 'HOY',
      'sev': 'CRITICO',
      'title': 'Pago DTA pedimento 8099123',
      'desc': 'Monto: MXN 847.84 | Ref: AAA801101AAA',
      'color': _rojo,
      'isVencido': false
    },
    {
      'time': 'HOY',
      'sev': 'CRITICO',
      'title': 'Presentar declaracion IVA mensual (Junio)',
      'desc': 'SAT',
      'color': _rojo,
      'isVencido': false
    },
    {
      'time': 'MANANA',
      'sev': 'URGENTE',
      'title': 'Renovar e.firma FIEL - Vence en 2 dias',
      'desc': 'SAT e.firma portal',
      'color': _gold,
      'isVencido': false
    },
    {
      'time': '3 DIAS',
      'sev': 'URGENTE',
      'title': 'Contestar requerimiento SAT OF-2024-88991',
      'desc': '5 dias habiles restantes',
      'color': _gold,
      'isVencido': false
    },
    {
      'time': '5 DIAS',
      'sev': 'NORMAL',
      'title': 'Pago Cuota Compensatoria pedimento 8100001',
      'desc': 'Monto: MXN 12,500',
      'color': _verde,
      'isVencido': false
    },
    {
      'time': '8 DIAS',
      'sev': 'NORMAL',
      'title': 'Presentar DIOT Julio 2024',
      'desc': 'SAT portal',
      'color': _verde,
      'isVencido': false
    },
    {
      'time': '15 DIAS',
      'sev': 'NORMAL',
      'title': 'Renovar patente aduanal - Vigencia anual',
      'desc': 'SAT Aduanas',
      'color': _verde,
      'isVencido': false
    },
    {
      'time': '20 DIAS',
      'sev': 'NORMAL',
      'title': 'Informe IMMEX trimestral Q3 2024',
      'desc': 'SE portal',
      'color': _verde,
      'isVencido': false
    },
    {
      'time': 'VENCIDO -45 dias',
      'sev': 'CRITICO',
      'title': 'Declaracion anual ISR 2023',
      'desc': 'SAT - MULTA PROBABLE',
      'color': _rojo,
      'isVencido': true
    },
    {
      'time': 'VENCIDO -10 dias',
      'sev': 'CRITICO',
      'title': 'Pago multa SAT OF-2023-44512',
      'desc': 'Interes moratorio acumulando',
      'color': _rojo,
      'isVencido': true
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: _currentIndex == 1
          ? MouseRegion(
              cursor: SystemMouseCursors.click,
              child: FloatingActionButton(
                onPressed: _showAddDialog,
                backgroundColor: _gold,
                child: const Icon(Icons.add, color: _bg),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: _gold),
        ),
        title: const Text(
          'Agenda de Vencimientos',
          style: TextStyle(
              color: _gold, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: _rojo,
                  shape: BoxShape.circle,
                ),
                child: const Text('4',
                    style: TextStyle(
                        color: _texto,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabs(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Próximos', 'Calendario', 'Historial'];
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _bord)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () => setState(() => _currentIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              _currentIndex == i ? _gold : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      color: _currentIndex == i
                          ? _gold.withValues(alpha: 0.05)
                          : Colors.transparent,
                    ),
                    child: Text(
                      tabs[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _currentIndex == i ? _gold : _sec,
                        fontWeight: _currentIndex == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildTab1();
      case 1:
        return _buildTab2();
      case 2:
        return _buildTab3();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTab1() {
    List<Map<String, dynamic>> filtered = _vencimientos;
    if (_vencFilter == 'Hoy') {
      filtered = _vencimientos.where((v) => v['time'] == 'HOY').toList();
    } else if (_vencFilter == 'Vencidos') {
      filtered = _vencimientos.where((v) => v['isVencido'] == true).toList();
    }

    return Column(
      children: [
        _buildSummaryBar(),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              for (final filter in _vencFilters)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter,
                        style: TextStyle(
                            color: _vencFilter == filter ? _bg : _texto,
                            fontWeight: _vencFilter == filter
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    selected: _vencFilter == filter,
                    selectedColor: _gold,
                    backgroundColor: _card,
                    side: BorderSide(
                        color: _vencFilter == filter ? _gold : _bord),
                    onSelected: (val) => setState(() => _vencFilter = filter),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final v = filtered[index];
              return _VencimientoCard(v: v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        color: _card,
        border: Border(bottom: BorderSide(color: _bord)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryStat(val: '2', label: 'Vencidos', color: _rojo),
          _SummaryStat(val: '4', label: 'Críticos', color: _rojo),
          _SummaryStat(val: '6', label: 'Semana', color: _gold),
          _SummaryStat(val: '10', label: 'Total', color: _blue),
        ],
      ),
    );
  }

  Widget _buildTab2() {
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Icon(Icons.chevron_left, color: _gold)),
                    Text('Agosto 1 - Agosto 7',
                        style: TextStyle(
                            color: _texto,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Icon(Icons.chevron_right, color: _gold)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    for (final day in days)
                      Expanded(
                        child: Column(
                          children: [
                            Text(day,
                                style: const TextStyle(
                                    color: _sec,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Container(
                              height: 60,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: day == 'Mié'
                                    ? _gold.withValues(alpha: 0.1)
                                    : _bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: day == 'Mié' ? _gold : _bord),
                              ),
                              child: Center(
                                child:
                                    day == 'Mar' || day == 'Mié' || day == 'Vie'
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.circle,
                                                  color: day == 'Mar'
                                                      ? _rojo
                                                      : (day == 'Mié'
                                                          ? _gold
                                                          : _verde),
                                                  size: 10),
                                            ],
                                          )
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Vencimientos del día seleccionado:',
                style: TextStyle(
                    color: _gold, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDayItem('Renovar e.firma FIEL', 'URGENTE', _gold),
                _buildDayItem('Contestar requerimiento', 'URGENTE', _gold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(String title, String sev, Color c) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _bord),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.circle, color: c, size: 12),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: _texto, fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.withValues(alpha: 0.3)),
              ),
              child: Text(sev,
                  style: TextStyle(
                      color: c, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab3() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        for (int i = 0; i < 5; i++) _HistorialItem(index: i),
      ],
    );
  }

  void _showAddDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _bord)),
        title: const Text('Agregar Vencimiento',
            style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: _texto),
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: const TextStyle(color: _sec),
                filled: true,
                fillColor: _bg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _bord)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _gold)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(color: _texto),
              decoration: InputDecoration(
                labelText: 'Fecha límite',
                labelStyle: const TextStyle(color: _sec),
                filled: true,
                fillColor: _bg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _bord)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _gold)),
                suffixIcon: const Icon(Icons.calendar_today, color: _gold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: _sec))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: _bg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Guardar',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String val;
  final String label;
  final Color color;

  const _SummaryStat(
      {required this.val, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(val,
            style: TextStyle(
                color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                color: _sec, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _VencimientoCard extends StatefulWidget {
  final Map<String, dynamic> v;
  const _VencimientoCard({required this.v});

  @override
  State<_VencimientoCard> createState() => _VencimientoCardState();
}

class _VencimientoCardState extends State<_VencimientoCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.v;
    final isVencido = v['isVencido'] as bool;
    final color = v['color'] as Color;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isVencido
              ? _rojo.withValues(alpha: 0.05)
              : (_hover ? const Color(0xFF14243D) : _card),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isVencido
                  ? _rojo.withValues(alpha: 0.5)
                  : (_hover ? color : _bord)),
          boxShadow: [
            if (_hover)
              BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 120,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                                isVencido
                                    ? Icons.warning_rounded
                                    : Icons.label_important,
                                color: color,
                                size: 16),
                            const SizedBox(width: 6),
                            Text(v['sev'] as String,
                                style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Text(v['time'] as String,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(v['title'] as String,
                        style: const TextStyle(
                            color: _texto,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(v['desc'] as String,
                        style: const TextStyle(color: _sec, fontSize: 13)),
                    if (isVencido)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: _rojo, shape: BoxShape.circle),
                              child: const Icon(Icons.priority_high,
                                  color: _bg, size: 10),
                            ),
                            const SizedBox(width: 8),
                            const Text('ACCIÓN INMEDIATA REQUERIDA',
                                style: TextStyle(
                                    color: _rojo,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: IconButton(
                            icon: const Icon(Icons.alarm_add,
                                color: _sec, size: 22),
                            onPressed: () {},
                            tooltip: 'Agregar Recordatorio',
                          ),
                        ),
                        const SizedBox(width: 8),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Marcar Resuelto',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: color,
                              side: BorderSide(color: color),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorialItem extends StatefulWidget {
  final int index;
  const _HistorialItem({required this.index});

  @override
  State<_HistorialItem> createState() => _HistorialItemState();
}

class _HistorialItemState extends State<_HistorialItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hover ? const Color(0xFF14243D) : _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hover ? _verde : _bord),
          boxShadow: [
            if (_hover)
              BoxShadow(
                  color: _verde.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _verde.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: _verde, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pago derechos trámite aduanero',
                      style: TextStyle(
                          color: _texto,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Resuelto el ${15 - widget.index}/07/2024',
                      style: const TextStyle(color: _sec, fontSize: 13)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _bg,
                foregroundColor: _gold,
                side: const BorderSide(color: _gold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Ver detalle',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
