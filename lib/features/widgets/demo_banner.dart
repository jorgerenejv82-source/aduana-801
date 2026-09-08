import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DemoBanner extends StatefulWidget {
  final Widget child;
  const DemoBanner({super.key, required this.child});

  @override
  State<DemoBanner> createState() => _DemoBannerState();
}

class _DemoBannerState extends State<DemoBanner> {
  bool _isDismissed = false;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return widget.child;
    
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: _isHovering 
                    ? AppColors.gold.withValues(alpha: 0.95) 
                    : AppColors.gold.withValues(alpha: 0.85),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.workspace_premium, color: AppColors.bg, size: 18),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'MODO DEMO: Los datos mostrados en esta pantalla son simulados. Requiere configuración enterprise.',
                        style: TextStyle(
                          color: AppColors.bg,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => _isDismissed = true),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.bg.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: AppColors.bg, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

