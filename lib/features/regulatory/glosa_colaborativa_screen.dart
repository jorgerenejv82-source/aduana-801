import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;

class _HoverContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const _HoverContainer({required this.child, this.margin, this.padding})
      : onTap = null;

  @override
  State<_HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<_HoverContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: widget.margin,
          padding: widget.padding,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _isHovered ? _ambar.withValues(alpha: 0.5) : _bord),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                        color: _ambar.withValues(alpha: 0.15),
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
          child: widget.child,
        ),
      ),
    );
  }
}

class GlosaColaborativaScreen extends StatefulWidget {
  const GlosaColaborativaScreen({super.key});

  @override
  _GlosaColaborativaScreenState createState() =>
      _GlosaColaborativaScreenState();
}

class _GlosaColaborativaScreenState extends State<GlosaColaborativaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: _ambar),
        ),
        title: Row(
          children: [
            const Text('Glosa Colaborativa',
                style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: _azul.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _azul.withValues(alpha: 0.5))),
              child: const Text('BETA',
                  style: TextStyle(
                      color: _azul, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _ambar,
          labelColor: _ambar,
          unselectedLabelColor: _sec,
          tabs: const [
            Tab(text: 'Documentos'),
            Tab(text: 'Anotaciones'),
            Tab(text: 'Equipo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDocumentosTab(),
          _buildAnotacionesTab(),
          _buildEquipoTab(),
        ],
      ),
    );
  }

  Widget _buildDocumentosTab() {
    final docs = [
      {
        'title': 'Pedimento 2024-8099123 | Factura CHINA-2024-445566',
        'status': 'EN REVISION',
        'color': _ambar,
        'assignee': 'Jorge Martinez'
      },
      {
        'title': 'Factura Comercial FAC-001 | PDF',
        'status': 'REVISADO',
        'color': _verde,
        'assignee': 'Ana Gomez'
      },
      {
        'title': 'Bill of Lading BL-MAERSK-2024',
        'status': 'PENDIENTE',
        'color': _sec,
        'assignee': 'Sin asignar'
      },
      {
        'title': 'Packing List PL-2024-007',
        'status': 'CON OBSERVACIONES',
        'color': _rojo,
        'assignee': 'Luis Torres'
      },
      {
        'title': 'Certificado de Origen FORM A',
        'status': 'APROBADO',
        'color': _verde,
        'assignee': 'Jorge Martinez'
      },
    ];

    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Total docs', '5'),
                _buildStat('Revisados', '2'),
                _buildStat('Pendientes', '2'),
                _buildStat('Observaciones', '1', color: _rojo),
              ],
            ),
            const SizedBox(height: 16),
            for (final doc in docs)
              _HoverContainer(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc['title'] as String,
                        style: const TextStyle(
                            color: _texto, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: (doc['color'] as Color)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: (doc['color'] as Color)
                                      .withValues(alpha: 0.5))),
                          child: Text(doc['status'] as String,
                              style: TextStyle(
                                  color: doc['color'] as Color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.person, size: 14, color: _sec),
                        const SizedBox(width: 4),
                        Text(doc['assignee'] as String,
                            style: const TextStyle(color: _sec, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _texto,
                              side: const BorderSide(color: _bord),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Revisar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _texto,
                              side: const BorderSide(color: _bord),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Ver Anotaciones'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            backgroundColor: _ambar,
            onPressed: () => _analizarConIA(),
            icon: const Icon(Icons.psychology, color: _bg),
            label: const Text('Analizar con IA',
                style: TextStyle(color: _bg, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Future<void> _analizarConIA() async {
    final textController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        title:
            const Text('Análisis IA de Glosa', style: TextStyle(color: _texto)),
        content: TextField(
          controller: textController,
          maxLines: 5,
          style: const TextStyle(color: _texto),
          decoration: const InputDecoration(
            hintText: 'Pega el pedimento y factura aquí...',
            hintStyle: TextStyle(color: _sec),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: _bord)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: _ambar)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: _sec))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analizando con IA...')));
              try {
                final model = FirebaseAI.vertexAI().generativeModel(
                    model: 'gemini-1.5-flash',
                    systemInstruction: Content.system(
                        'Eres un experto en glosa aduanal colaborativa de México. Analiza el pedimento y la factura comercial proporcionados e identifica inconsistencias para la glosa. Responde con un análisis detallado de cada partida.'));
                final response = await model
                    .generateContent([Content.text(textController.text)]);

                await FirebaseFirestore.instance
                    .collection('glosas_colaborativas')
                    .add({
                  'analisis': response.text,
                  'input': textController.text,
                  'created_at': FieldValue.serverTimestamp(),
                  'uid': FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Análisis guardado exitosamente'),
                      backgroundColor: _verde));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: $e'), backgroundColor: _rojo));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _ambar),
            child: const Text('Analizar', style: TextStyle(color: _bg)),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color color = _texto}) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: _sec, fontSize: 12)),
      ],
    );
  }

  Widget _buildAnotacionesTab() {
    final annotations = [
      {
        'name': 'Jorge M.',
        'role': 'Agente Aduanal',
        'doc': 'Factura FAC-001',
        'text':
            'El valor FOB declarado no coincide con el valor en la factura. Diferencia de USD 500. Solicito aclaracion.',
        'severity': 'ERROR',
        'color': _rojo
      },
      {
        'name': 'Ana G.',
        'role': 'Importador',
        'doc': 'Factura FAC-001',
        'text': 'Confirmado, error tipografico. Factura rectificada adjunta.',
        'severity': 'OBSERVACION',
        'color': _ambar
      },
      {
        'name': 'Luis T.',
        'role': 'Auditor',
        'doc': 'Pedimento 8099123',
        'text':
            'Fraccion arancelaria 8471.30.01 correcta segun descripcion. Aprobado.',
        'severity': 'APROBADO',
        'color': _verde
      },
      {
        'name': 'Jorge M.',
        'role': 'Agente Aduanal',
        'doc': 'BL-MAERSK-2024',
        'text': 'Pendiente recibir BL original del cliente. ETD: 3 dias.',
        'severity': 'CONSULTA',
        'color': _azul
      },
    ];

    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            for (final ann in annotations)
              _HoverContainer(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                            backgroundColor: _azul.withValues(alpha: 0.15),
                            radius: 16,
                            child: Text((ann['name'] as String).substring(0, 1),
                                style: const TextStyle(
                                    color: _azul, fontSize: 12))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ann['name'] as String,
                                  style: const TextStyle(
                                      color: _texto,
                                      fontWeight: FontWeight.bold)),
                              Text(ann['role'] as String,
                                  style: const TextStyle(
                                      color: _sec, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Text('10:30 AM',
                            style: TextStyle(color: _sec, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Ref: ${ann['doc']}',
                        style: const TextStyle(
                            color: _sec,
                            fontSize: 12,
                            fontStyle: FontStyle.italic)),
                    const SizedBox(height: 4),
                    Text(ann['text'] as String,
                        style: const TextStyle(color: _texto)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: (ann['color'] as Color)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: (ann['color'] as Color)
                                      .withValues(alpha: 0.5))),
                          child: Text(ann['severity'] as String,
                              style: TextStyle(
                                  color: ann['color'] as Color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon:
                              const Icon(Icons.reply, size: 16, color: _ambar),
                          label: const Text('Responder',
                              style: TextStyle(color: _ambar)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: _ambar,
            onPressed: () {},
            child: const Icon(Icons.add_comment, color: _bg),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipoTab() {
    final team = [
      {
        'name': 'Jorge Martinez',
        'role': 'Agente Aduanal',
        'access': 'ADMIN',
        'online': true
      },
      {
        'name': 'Ana Gomez',
        'role': 'Importador',
        'access': 'EDITOR',
        'online': false
      },
      {
        'name': 'Luis Torres',
        'role': 'Auditor',
        'access': 'VIEWER',
        'online': false
      },
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              for (final member in team)
                _HoverContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                              backgroundColor: _sec.withValues(alpha: 0.15),
                              child: Text(
                                  (member['name'] as String).substring(0, 1),
                                  style: const TextStyle(color: _texto))),
                          if (member['online'] as bool)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                      color: _verde, shape: BoxShape.circle)),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member['name'] as String,
                                style: const TextStyle(
                                    color: _texto,
                                    fontWeight: FontWeight.bold)),
                            Text(member['role'] as String,
                                style:
                                    const TextStyle(color: _sec, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: _bord,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(member['access'] as String,
                            style:
                                const TextStyle(color: _texto, fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: _ambar,
                    foregroundColor: _bg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                icon: const Icon(Icons.person_add),
                label: const Text('Invitar Miembro',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: _card,
            border: Border(top: BorderSide(color: _bord)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Niveles de Permiso:',
                  style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Ã¢â‚¬Â¢ ADMIN: Acceso total a documentos y equipo.',
                  style: TextStyle(color: _sec, fontSize: 12)),
              Text('Ã¢â‚¬Â¢ EDITOR: Puede agregar y responder anotaciones.',
                  style: TextStyle(color: _sec, fontSize: 12)),
              Text('Ã¢â‚¬Â¢ VIEWER: Solo lectura, sin posibilidad de editar.',
                  style: TextStyle(color: _sec, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
