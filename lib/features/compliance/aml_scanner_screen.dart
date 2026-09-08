import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _gold = AppColors.gold;
const Color _text = AppColors.text;
const Color _sub = AppColors.sub;
const Color _border = AppColors.border;

class AmlScannerScreen extends StatefulWidget {
  const AmlScannerScreen({super.key});

  @override
  State<AmlScannerScreen> createState() => _AmlScannerScreenState();
}

class _AmlScannerScreenState extends State<AmlScannerScreen> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('AML Scanner',
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
            MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _isHovered
                            ? _gold.withValues(alpha: 0.5)
                            : _border),
                    boxShadow: [
                      if (_isHovered)
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                    ]),
                child: const TextField(
                  style: TextStyle(color: _text, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Buscar Entidad (OFAC/ONU/SAT)',
                    hintStyle: TextStyle(color: _sub),
                    suffixIcon: Icon(Icons.search, color: _gold),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.policy_outlined, size: 64, color: _border),
                    SizedBox(height: 16),
                    Text('Historial de búsquedas',
                        style: TextStyle(
                            color: _sub,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
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
