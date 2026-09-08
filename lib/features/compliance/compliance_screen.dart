import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _gold = AppColors.gold;
const Color _text = AppColors.text;
const Color _sub = AppColors.sub;
const Color _border = AppColors.border;
const Color _green = AppColors.green;
const Color _blue = AppColors.blue;
const Color _red = AppColors.red;
const Color _orange = Color(0xFFF97316);

class ComplianceScreen extends StatelessWidget {
  const ComplianceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Compliance & Riesgo',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: _green.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                              color: _green.withValues(alpha: 0.1),
                              blurRadius: 20,
                              spreadRadius: 2)
                        ]),
                    child: const Column(
                      children: [
                        Text('Compliance Score Global',
                            style: TextStyle(
                                color: _sub,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 16),
                        Text('98.5%',
                            style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: _green,
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                const Expanded(
                  child: Column(
                    children: [
                      _AlertBox('Multas Potenciales Prevenidas',
                          '\$1,250,000 MXN', _blue),
                      SizedBox(height: 16),
                      _AlertBox('Alertas Críticas de Origen', '3', _red),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),
            const Text('Alertas Recientes',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: _text)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _AlertRow(
                      title: 'Fracción Arancelaria con nueva RRNA',
                      desc: 'HS 8517.13.00 requiere NOM-208',
                      severity: 'Alta'),
                  _AlertRow(
                      title: 'Proveedor en Lista Negra SAT (69-B)',
                      desc:
                          'Global Logistics SRL detectado en operaciones pasadas',
                      severity: 'Crítica'),
                  _AlertRow(
                      title: 'Certificado de Origen Expirando',
                      desc: 'AutoParts LLC expira en 5 días',
                      severity: 'Media'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AlertBox extends StatelessWidget {
  final String title;
  final String val;
  final Color color;

  const _AlertBox(this.title, this.val, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: _sub, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(val,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

class _AlertRow extends StatefulWidget {
  final String title;
  final String desc;
  final String severity;

  const _AlertRow(
      {required this.title, required this.desc, required this.severity});

  @override
  State<_AlertRow> createState() => _AlertRowState();
}

class _AlertRowState extends State<_AlertRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color sColor = _orange;
    if (widget.severity == 'Crítica') sColor = _red;
    if (widget.severity == 'Alta') sColor = Colors.deepOrange;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _isHovered ? sColor.withValues(alpha: 0.5) : _border),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
            ]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_amber_rounded, color: sColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _text,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(widget.desc,
                      style: const TextStyle(color: _sub, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: sColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                widget.severity,
                style: TextStyle(
                    color: sColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
