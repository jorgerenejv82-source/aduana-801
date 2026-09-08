import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _gold = AppColors.gold;
const Color _text = AppColors.text;
const Color _sub = AppColors.sub;
const Color _border = AppColors.border;

class M3AnalyzerScreen extends StatefulWidget {
  const M3AnalyzerScreen({super.key});

  @override
  State<M3AnalyzerScreen> createState() => _M3AnalyzerScreenState();
}

class _M3AnalyzerScreenState extends State<M3AnalyzerScreen> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('M3 Analyzer',
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
            const Text('Análisis de archivos M3',
                style: TextStyle(
                    color: _text, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Pegue el contenido del archivo M3 o el texto del pedimento para analizar su estructura y validez.',
                style: TextStyle(color: _sub, fontSize: 14)),
            const SizedBox(height: 24),
            TextField(
              maxLines: 12,
              style: const TextStyle(
                  color: _text, fontFamily: 'monospace', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Ej: 500|1|24|... (Registros M3)',
                hintStyle: const TextStyle(color: _sub),
                filled: true,
                fillColor: _card,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _gold)),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (_isHovered)
                          BoxShadow(
                              color: _gold.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                      ]),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: _bg,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.analytics_outlined, size: 20),
                    label: const Text('Analizar M3',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
