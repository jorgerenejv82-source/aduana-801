import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _teal = AppColors.green;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;
const Color _naran = Color(0xFFF97316);

class _Pedimento {
  final String id;
  String titulo;
  String importador;
  String fraccion;
  String regimen;
  String aduana;
  String prioridad;
  int columna;
  DateTime fecha;

  _Pedimento({
    required this.id,
    required this.titulo,
    required this.importador,
    required this.fraccion,
    required this.regimen,
    required this.aduana,
    required this.prioridad,
    required this.columna,
    required this.fecha,
  });

  factory _Pedimento.fromMap(String id, Map<String, dynamic> data) {
    return _Pedimento(
      id: id,
      titulo: (data['titulo'] ?? '').toString(),
      importador: (data['importador'] ?? '').toString(),
      fraccion: (data['fraccion'] ?? '').toString(),
      regimen: (data['regimen'] ?? '').toString(),
      aduana: (data['aduana'] ?? '').toString(),
      prioridad: (data['prioridad'] ?? '').toString(),
      columna: data['columna'] != null ? (data['columna'] as num).toInt() : 0,
      fecha: data['fecha'] != null
          ? (data['fecha'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});
  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  final _scroll = ScrollController();
  String _filtro = '';

  List<_Pedimento> _byCol(List<_Pedimento> pedimentos, int col) =>
      pedimentos.where((p) {
        final match = _filtro.isEmpty ||
            p.titulo.toLowerCase().contains(_filtro.toLowerCase()) ||
            p.importador.toLowerCase().contains(_filtro.toLowerCase()) ||
            p.id.contains(_filtro);
        return p.columna == col && match;
      }).toList();

  Color _prioColor(String p) {
    switch (p) {
      case 'CRITICA':
        return _rojo;
      case 'URGENTE':
        return _naran;
      case 'ALTA':
        return _ambar;
      case 'NORMAL':
        return _azul;
      default:
        return _verde;
    }
  }

  static const _cols = [
    'Pendiente',
    'En Proceso',
    'Pre-Glosa / Firma',
    'Liberado'
  ];
  static const _colIcons = [
    Icons.inbox,
    Icons.autorenew,
    Icons.edit_document,
    Icons.check_circle_outline
  ];
  static const _colColors = [_sec, _azul, _ambar, _teal];

  @override
  void dispose() {
    _scroll.dispose();
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
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Tráfico y Despacho',
            style: TextStyle(color: _ambar, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _crearOEditarPedimento(),
        backgroundColor: _ambar,
        child: const Icon(Icons.add, color: _bg),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('kanban').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: _rojo)));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: _ambar));
          }

          final pedimentos = snapshot.data!.docs
              .map((doc) => _Pedimento.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          final tots = List.generate(4, (i) => _byCol(pedimentos, i).length);

          return Column(children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                  color: _bg, border: Border(bottom: BorderSide(color: _bord))),
              child: Column(children: [
                Row(children: [
                  Expanded(
                      child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _bord)),
                    child: TextField(
                      onChanged: (v) => setState(() => _filtro = v),
                      style: const TextStyle(color: _texto, fontSize: 14),
                      decoration: const InputDecoration(
                          hintText: 'Buscar por num. pedimento, importador...',
                          hintStyle: TextStyle(color: _sec, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: _sec, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16)),
                    ),
                  )),
                  const SizedBox(width: 24),
                  _kpiChip(tots[0].toString(), 'Pendiente', _sec),
                  const SizedBox(width: 12),
                  _kpiChip(tots[1].toString(), 'En Proceso', _azul),
                  const SizedBox(width: 12),
                  _kpiChip(tots[2].toString(), 'Por Firmar', _ambar),
                  const SizedBox(width: 12),
                  _kpiChip(tots[3].toString(), 'Listos', _teal),
                ]),
              ]),
            ),
            Expanded(
                child: Scrollbar(
                    controller: _scroll,
                    child: SingleChildScrollView(
                      controller: _scroll,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(24),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int col = 0; col < 4; col++)
                              _buildColumn(col, tots, pedimentos)
                          ]),
                    ))),
          ]);
        },
      ),
    );
  }

  Widget _kpiChip(String n, String l, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: c.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.withValues(alpha: 0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(n,
              style: TextStyle(
                  color: c, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Text(l,
              style: const TextStyle(
                  color: _sec, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
      );

  Widget _buildColumn(int col, List<int> tots, List<_Pedimento> pedimentos) {
    final items = _byCol(pedimentos, col);
    return DragTarget<_Pedimento>(
      onWillAcceptWithDetails: (details) => details.data.columna != col,
      onAcceptWithDetails: (details) {
        FirebaseFirestore.instance
            .collection('kanban')
            .doc(details.data.id)
            .update({'columna': col});
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 320,
          margin: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? _bord.withValues(alpha: 0.5)
                  : _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: candidateData.isNotEmpty ? _colColors[col] : _bord),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                  color: _colColors[col].withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  border: const Border(bottom: BorderSide(color: _bord))),
              child: Row(children: [
                Icon(_colIcons[col], color: _colColors[col], size: 20),
                const SizedBox(width: 12),
                Text(_cols[col],
                    style: TextStyle(
                        color: _colColors[col],
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const Spacer(),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: _colColors[col].withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('${tots[col]}',
                        style: TextStyle(
                            color: _colColors[col],
                            fontSize: 13,
                            fontWeight: FontWeight.bold))),
              ]),
            ),
            Flexible(
                child: items.isEmpty
                    ? Center(
                        child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inbox_outlined,
                                      color: _sec.withValues(alpha: 0.3),
                                      size: 48),
                                  const SizedBox(height: 16),
                                  const Text('Sin pedimentos',
                                      style: TextStyle(
                                          color: _sec,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ])))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (_, i) => _buildDraggableCard(items[i]),
                      )),
          ]),
        );
      },
    );
  }

  Widget _buildDraggableCard(_Pedimento p) {
    return LongPressDraggable<_Pedimento>(
      data: p,
      delay: const Duration(milliseconds: 150),
      feedback: Material(
          color: Colors.transparent,
          child: Opacity(
              opacity: 0.8, child: SizedBox(width: 288, child: _buildCard(p)))),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildCard(p)),
      child: _buildCard(p),
    );
  }

  Widget _buildCard(_Pedimento p) {
    final pc = _prioColor(p.prioridad);
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border(
              left: BorderSide(color: pc, width: 4),
              top: const BorderSide(color: _bord),
              right: const BorderSide(color: _bord),
              bottom: const BorderSide(color: _bord)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: pc.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: pc.withValues(alpha: 0.3))),
                child: Text(p.prioridad,
                    style: TextStyle(
                        color: pc, fontSize: 10, fontWeight: FontWeight.bold))),
            const Spacer(),
            GestureDetector(
                onTap: () => _crearOEditarPedimento(p: p),
                child: const Icon(Icons.edit, color: _sec, size: 18)),
            const SizedBox(width: 12),
            GestureDetector(
                onTap: () => _eliminar(p),
                child: const Icon(Icons.close, color: _sec, size: 18)),
          ]),
          const SizedBox(height: 12),
          Text(p.titulo,
              style: const TextStyle(
                  color: _texto, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(p.id,
              style: const TextStyle(
                  color: _ambar, fontSize: 12, fontFamily: 'monospace')),
          const SizedBox(height: 12),
          _infoRow(Icons.business_outlined, p.importador),
          _infoRow(Icons.tag, '${p.fraccion}  ·  ${p.regimen}'),
          _infoRow(Icons.location_on_outlined, p.aduana),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.calendar_today, color: _sec, size: 14),
            const SizedBox(width: 6),
            Text('${p.fecha.day}/${p.fecha.month}/${p.fecha.year}',
                style: const TextStyle(
                    color: _sec, fontSize: 11, fontWeight: FontWeight.bold)),
            const Spacer(),
            GestureDetector(
              onTap: () => _verDetalle(p),
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _azul.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _azul.withValues(alpha: 0.3))),
                  child: const Text('Detalle',
                      style: TextStyle(
                          color: _azul,
                          fontSize: 11,
                          fontWeight: FontWeight.bold))),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData ico, String txt) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Icon(ico, color: _sec, size: 14),
          const SizedBox(width: 8),
          Expanded(
              child: Text(txt,
                  style: const TextStyle(color: _sec, fontSize: 12),
                  overflow: TextOverflow.ellipsis)),
        ]),
      );

  void _crearOEditarPedimento({_Pedimento? p}) {
    final isEdit = p != null;
    final pedCtrl = TextEditingController(text: isEdit ? p.titulo : '');
    final impCtrl = TextEditingController(text: isEdit ? p.importador : '');
    final fracCtrl = TextEditingController(text: isEdit ? p.fraccion : '');
    String regimen = isEdit ? p.regimen : 'IMT';
    String aduana = isEdit ? p.aduana : 'Laredo';
    String prio = isEdit ? p.prioridad : 'NORMAL';

    showDialog<void>(
        context: context,
        builder: (_) => StatefulBuilder(
              builder: (ctx, setS) => AlertDialog(
                backgroundColor: _card,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: _bord)),
                title: Text(isEdit ? 'Editar Pedimento' : 'Nuevo Pedimento',
                    style: const TextStyle(
                        color: _ambar, fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _dialogField(
                      pedCtrl, 'Descripción / Título', Icons.description),
                  const SizedBox(height: 16),
                  _dialogField(
                      impCtrl, 'Importador (Razón Social)', Icons.business),
                  const SizedBox(height: 16),
                  _dialogField(fracCtrl, 'Fracción Arancelaria', Icons.tag),
                  const SizedBox(height: 16),
                  _dialogDropdown(
                      'Régimen',
                      regimen,
                      const ['IMT', 'IFT', 'DEF', 'EXT', 'TIT'],
                      (v) => setS(() => regimen = v!)),
                  const SizedBox(height: 16),
                  _dialogDropdown(
                      'Aduana',
                      aduana,
                      const [
                        'Laredo',
                        'Manzanillo',
                        'Veracruz',
                        'Altamira',
                        'Lázaro',
                        'Tijuana'
                      ],
                      (v) => setS(() => aduana = v!)),
                  const SizedBox(height: 16),
                  _dialogDropdown(
                      'Prioridad',
                      prio,
                      const [
                        'CRITICA',
                        'URGENTE',
                        'ALTA',
                        'NORMAL',
                        'COMPLETADO'
                      ],
                      (v) => setS(() => prio = v!)),
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar',
                          style: TextStyle(color: _sec))),
                  ElevatedButton(
                    onPressed: () {
                      if (pedCtrl.text.isEmpty) return;
                      if (isEdit) {
                        FirebaseFirestore.instance
                            .collection('kanban')
                            .doc(p.id)
                            .update({
                          'titulo': pedCtrl.text,
                          'importador': impCtrl.text.isEmpty
                              ? 'Sin especificar'
                              : impCtrl.text,
                          'fraccion': fracCtrl.text.isEmpty
                              ? 'Por definir'
                              : fracCtrl.text,
                          'regimen': regimen,
                          'aduana': aduana,
                          'prioridad': prio,
                        });
                      } else {
                        FirebaseFirestore.instance.collection('kanban').add({
                          'titulo': pedCtrl.text,
                          'importador': impCtrl.text.isEmpty
                              ? 'Sin especificar'
                              : impCtrl.text,
                          'fraccion': fracCtrl.text.isEmpty
                              ? 'Por definir'
                              : fracCtrl.text,
                          'regimen': regimen,
                          'aduana': aduana,
                          'prioridad': prio,
                          'columna': 0,
                          'fecha': Timestamp.fromDate(DateTime.now()),
                        });
                      }
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _ambar,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text(isEdit ? 'Guardar' : 'Agregar',
                        style: const TextStyle(
                            color: _bg, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ));
  }

  void _eliminar(_Pedimento p) {
    showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: _card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: _bord)),
              title: const Text('Eliminar pedimento',
                  style: TextStyle(color: _rojo)),
              content: Text('Eliminar "${p.titulo}"?',
                  style: const TextStyle(color: _texto)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        const Text('Cancelar', style: TextStyle(color: _sec))),
                ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('kanban')
                          .doc(p.id)
                          .delete();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _rojo,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('Eliminar',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
              ],
            ));
  }

  void _verDetalle(_Pedimento p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                            color: _bord,
                            borderRadius: BorderRadius.circular(3)))),
                const SizedBox(height: 24),
                Text(p.titulo,
                    style: const TextStyle(
                        color: _ambar,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _detailRow('Num. Pedimento', p.id),
                _detailRow('Importador', p.importador),
                _detailRow('Fracción', p.fraccion),
                _detailRow('Régimen', p.regimen),
                _detailRow('Aduana', p.aduana),
                _detailRow('Prioridad', p.prioridad),
                _detailRow(
                    'Fecha', '${p.fecha.day}/${p.fecha.month}/${p.fecha.year}'),
                _detailRow('Estado', _cols[p.columna]),
                const SizedBox(height: 32),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 18, color: _bg),
                        label: const Text('Cerrar',
                            style: TextStyle(
                                color: _bg,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _ambar,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))))),
              ])),
    );
  }

  Widget _detailRow(String l, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(
            width: 140,
            child: Text(l,
                style: const TextStyle(
                    color: _sec, fontSize: 14, fontWeight: FontWeight.bold))),
        Expanded(
            child:
                Text(v, style: const TextStyle(color: _texto, fontSize: 14))),
      ]));

  Widget _dialogField(TextEditingController c, String hint, IconData ico) =>
      TextField(
        controller: c,
        style: const TextStyle(color: _texto, fontSize: 14),
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _sec, fontSize: 14),
            prefixIcon: Icon(ico, color: _sec, size: 20),
            filled: true,
            fillColor: _bg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _bord)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _bord))),
      );

  Widget _dialogDropdown(String l, String v, List<String> opts,
          ValueChanged<String?> onChanged) =>
      DropdownButtonFormField<String>(
        initialValue: v,
        onChanged: onChanged,
        dropdownColor: _card,
        style: const TextStyle(color: _texto, fontSize: 14),
        decoration: InputDecoration(
            labelText: l,
            labelStyle: const TextStyle(color: _sec, fontSize: 14),
            filled: true,
            fillColor: _bg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _bord)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _bord))),
        items: [
          for (final o in opts) DropdownMenuItem(value: o, child: Text(o))
        ],
      );
}
