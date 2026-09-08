import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// -- Design Tokens -------------------------------------------------------------
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _gold = AppColors.gold;
const Color _text = AppColors.text;
const Color _sub = AppColors.sub;
const Color _border = AppColors.border;
const Color _green = AppColors.green;
const Color _red = AppColors.red;

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Auditor�a Preventiva y Expedientes',
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: _text),
                    decoration: InputDecoration(
                      hintText: 'Buscar por Pedimento, RFC o Referencia',
                      hintStyle: const TextStyle(color: _sub),
                      prefixIcon: const Icon(Icons.search, color: _sub),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: _bg,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.download, size: 20),
                    label: const Text('Exportar Reporte',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _AuditRow(
                      pedimento: '21 470 3911 1002345',
                      date: '24 Jul 2026',
                      risk: 'Bajo',
                      status: 'Completo'),
                  _AuditRow(
                      pedimento: '21 470 3911 1001980',
                      date: '22 Jul 2026',
                      risk: 'Alto',
                      status: 'Falta COVE'),
                  _AuditRow(
                      pedimento: '21 470 3911 1002105',
                      date: '20 Jul 2026',
                      risk: 'Medio',
                      status: 'Revisi�n Manual'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AuditRow extends StatefulWidget {
  final String pedimento;
  final String date;
  final String risk;
  final String status;

  const _AuditRow(
      {required this.pedimento,
      required this.date,
      required this.risk,
      required this.status});

  @override
  State<_AuditRow> createState() => _AuditRowState();
}

class _AuditRowState extends State<_AuditRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color riskColor = _green;
    if (widget.risk == 'Medio') riskColor = _gold;
    if (widget.risk == 'Alto') riskColor = _red;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _isHovered ? _gold.withValues(alpha: 0.5) : _border),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
            ]),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: riskColor.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.folder_shared, color: riskColor, size: 24),
          ),
          title: Text('Pedimento: ${widget.pedimento}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: _text, fontSize: 16)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
                'Fecha Pago: ${widget.date}  �  Estatus: ${widget.status}',
                style: const TextStyle(color: _sub, fontSize: 13)),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: riskColor.withValues(alpha: 0.5)),
            ),
            child: Text('Riesgo ${widget.risk}',
                style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ),
      ),
    );
  }
}
