import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _gold = AppColors.gold;
const Color _text = AppColors.text;
const Color _sub = AppColors.sub;
const Color _border = AppColors.border;
const Color _blue = AppColors.blue;
const Color _green = AppColors.green;
const Color _red = AppColors.red;

class ClassifierScreen extends StatelessWidget {
  const ClassifierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Clasificador Arancelario',
            style: TextStyle(color: _text, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: _text, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Buscar por descripción o código HS...',
                hintStyle: const TextStyle(color: _sub),
                prefixIcon: const Icon(Icons.search, color: _sub),
                suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list, color: _gold),
                    onPressed: () {}),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _gold)),
                filled: true,
                fillColor: _card,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.gavel_rounded, color: Color(0xFFF59E0B), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AVISO LEGAL: Las fracciones arancelarias generadas por IA son orientativas. '
                      'Toda fracción debe validarse en el SIAVI del SAT (siavi4.economia.gob.mx) '
                      'antes de declararla en pedimento. El agente aduanal es el responsable de '
                      'la clasificación final (Art. 59-A Ley Aduanera).',
                      style: TextStyle(
                          color: Color(0xFFF59E0B), fontSize: 11, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: const [
                  _HSCard(
                    code: '8517.13.00',
                    desc: 'Teléfonos inteligentes (smartphones).',
                    igi: '0%',
                    iva: '16%',
                    restrictions: 'NOM-024-SCFI, NOM-208-SCFI',
                  ),
                  _HSCard(
                    code: '8471.30.01',
                    desc:
                        'Máquinas automáticas para tratamiento o procesamiento de datos, portátiles.',
                    igi: '0%',
                    iva: '16%',
                    restrictions: 'NOM-019-SCFI, NOM-024-SCFI',
                  ),
                  _HSCard(
                    code: '8703.23.01',
                    desc:
                        'Vehículos con motor de émbolo, cilindrada superior a 1500 cm3 pero inferior o igual a 3000 cm3.',
                    igi: '20%',
                    iva: '16%',
                    restrictions: 'NOM-042-SEMARNAT, Permiso Previo SE',
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

class _HSCard extends StatefulWidget {
  final String code;
  final String desc;
  final String igi;
  final String iva;
  final String restrictions;

  const _HSCard(
      {required this.code,
      required this.desc,
      required this.igi,
      required this.iva,
      required this.restrictions});

  @override
  State<_HSCard> createState() => _HSCardState();
}

class _HSCardState extends State<_HSCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _isHovered ? _gold.withValues(alpha: 0.5) : _border),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.code,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _gold,
                        fontFamily: 'monospace')),
                Icon(Icons.bookmark_border, color: _isHovered ? _gold : _sub),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.desc,
                style:
                    const TextStyle(fontSize: 16, color: _text, height: 1.4)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _blue.withValues(alpha: 0.3)),
                  ),
                  child: Text('IGI: ${widget.igi}',
                      style: const TextStyle(
                          color: _blue, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _green.withValues(alpha: 0.3)),
                  ),
                  child: Text('IVA: ${widget.iva}',
                      style: const TextStyle(
                          color: _green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Restricciones y Regulaciones No Arancelarias (RRNA):',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: _sub, fontSize: 13)),
            const SizedBox(height: 8),
            Text(widget.restrictions,
                style: const TextStyle(
                    color: _red, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
