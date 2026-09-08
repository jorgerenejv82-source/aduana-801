import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SharedWorkspaceScreen extends StatelessWidget {
  const SharedWorkspaceScreen({super.key});

  static const bg1 = AppColors.bg;
  static const card = AppColors.card;
  static const gold = AppColors.gold;
  static const text = AppColors.text;
  static const sub = AppColors.sub;
  static const border = AppColors.border;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg1,
      appBar: AppBar(
        backgroundColor: bg1,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: gold),
        ),
        title: const Text('Espacio Compartido',
            style: TextStyle(color: text, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: border, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Documentos del Expediente',
                style: TextStyle(
                    color: text, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Sube y gestiona archivos compartidos con el agente aduanal.',
                style: TextStyle(color: sub, fontSize: 14)),
            const SizedBox(height: 24),
            _HoverCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: gold.withValues(alpha: 0.3))),
                    child: const Icon(Icons.upload_file, color: gold),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Subir archivo al expediente',
                            style: TextStyle(
                                color: text,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Formatos soportados: PDF, XML, DOCX',
                            style: TextStyle(color: sub, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: bg1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text('Seleccionar Archivo',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_off_outlined, color: sub, size: 64),
                    SizedBox(height: 16),
                    Text('No hay documentos compartidos',
                        style: TextStyle(
                            color: text,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Los archivos subidos aparecerán aquí.',
                        style: TextStyle(color: sub, fontSize: 14)),
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

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SharedWorkspaceScreen.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _isHovered
                  ? SharedWorkspaceScreen.gold.withValues(alpha: 0.5)
                  : SharedWorkspaceScreen.border),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                  color: SharedWorkspaceScreen.gold.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 1)
            else
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
