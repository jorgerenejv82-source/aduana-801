import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _gold = AppColors.gold;
const Color _text = AppColors.text;
const Color _sub = AppColors.sub;
const Color _border = AppColors.border;

class MotorA22Screen extends StatefulWidget {
  const MotorA22Screen({super.key});

  @override
  State<MotorA22Screen> createState() => _MotorA22ScreenState();
}

class _MotorA22ScreenState extends State<MotorA22Screen> {
  final _nombreController = TextEditingController();
  final _rfcController = TextEditingController();
  final _programaController = TextEditingController();
  final _patenteController = TextEditingController();

  String _regimen = 'IM A4';
  String _aduana = '430 - Veracruz';
  bool _isHoveringFab = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _rfcController.dispose();
    _programaController.dispose();
    _patenteController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _border),
        ),
        title: const Text('Nuevo Cliente',
            style: TextStyle(
                color: _text, fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput('Nombre Empresa', _nombreController),
              const SizedBox(height: 16),
              _buildInput('RFC', _rfcController),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _regimen,
                dropdownColor: _card,
                style: const TextStyle(color: _text, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Régimen',
                  labelStyle: const TextStyle(color: _sub),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _border),
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _gold),
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: _bg.withValues(alpha: 0.5),
                ),
                items: const [
                  DropdownMenuItem(value: 'IM A4', child: Text('IM A4')),
                  DropdownMenuItem(value: 'IM IT', child: Text('IM IT')),
                  DropdownMenuItem(value: 'EX V1', child: Text('EX V1')),
                ],
                onChanged: (v) => setState(() => _regimen = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _aduana,
                dropdownColor: _card,
                style: const TextStyle(color: _text, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Aduana',
                  labelStyle: const TextStyle(color: _sub),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _border),
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _gold),
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: _bg.withValues(alpha: 0.5),
                ),
                items: [
                  '430 - Veracruz',
                  '240 - Nuevo Laredo',
                  '160 - Manzanillo',
                  '070 - Cd. Juarez',
                  '530 - AICM',
                  '800 - Colombia',
                  '650 - Toluca',
                  '810 - Altamira'
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _aduana = v!),
              ),
              const SizedBox(height: 16),
              _buildInput('Num Programa IMMEX', _programaController),
              const SizedBox(height: 16),
              _buildInput('Patente', _patenteController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: _sub, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Guardar',
                style: TextStyle(
                    color: _bg, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: _text, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _sub),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _border),
            borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _gold),
            borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: _bg.withValues(alpha: 0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Motor Inteligente Anexo 22',
            style: TextStyle(
                color: _text, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _border, height: 1)),
        actions: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sincronizando TC DOF...',
                          style: TextStyle(color: _bg)),
                      backgroundColor: AppColors.blue),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 24, top: 10, bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _gold.withValues(alpha: 0.5)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'TC DOF: \$17.15 MXN/USD • $date',
                  style: const TextStyle(
                      color: _gold, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: MouseRegion(
        onEnter: (_) => setState(() => _isHoveringFab = true),
        onExit: (_) => setState(() => _isHoveringFab = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _isHoveringFab
                ? [
                    BoxShadow(
                        color: _gold.withValues(alpha: 0.4), blurRadius: 16)
                  ]
                : [],
          ),
          child: FloatingActionButton(
            backgroundColor: _gold,
            onPressed: _showAddDialog,
            child: const Icon(Icons.add, color: _bg),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('clientes_a22').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _gold));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.domain_outlined,
                      size: 80, color: _sub.withValues(alpha: 0.5)),
                  const SizedBox(height: 24),
                  const Text('No hay clientes registrados',
                      style: TextStyle(
                          color: _sub,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(32),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return _ClientCard(doc: doc);
            },
          );
        },
      ),
    );
  }
}

class _ClientCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  const _ClientCard({required this.doc});

  @override
  State<_ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<_ClientCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(24),
        transform: Matrix4.translationValues(0, _isHovering ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _isHovering ? _gold.withValues(alpha: 0.5) : _border),
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                      color: _gold.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8))
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _gold.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.business, color: _gold, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    (widget.doc['nombre'] ?? 'Sin nombre').toString(),
                    style: const TextStyle(
                        color: _text,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RFC',
                          style: TextStyle(
                              color: _sub,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text((widget.doc['rfc'] ?? '').toString(),
                          style: const TextStyle(color: _text, fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Régimen',
                          style: TextStyle(
                              color: _sub,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.15),
                          border: Border.all(
                              color: AppColors.green.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text((widget.doc['regimen'] ?? '').toString(),
                            style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: _bg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  onPressed: () {
                    if (context.mounted) {
                      context.go('/draft_pedimento');
                    }
                  },
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Usar en Motor',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
