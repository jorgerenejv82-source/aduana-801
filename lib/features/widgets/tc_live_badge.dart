import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import '../../core/services/tc_service.dart';

class TcLiveBadge extends StatefulWidget {
  const TcLiveBadge({super.key});

  @override
  _TcLiveBadgeState createState() => _TcLiveBadgeState();
}

class _TcLiveBadgeState extends State<TcLiveBadge>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isHovering = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const Color card = AppColors.card;
  static const Color border = AppColors.border;
  static const Color texto = AppColors.text;
  static const Color sec = AppColors.sub;
  static const Color ambar = AppColors.gold;
  static const Color verde = AppColors.green;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _loadTc();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadTc() async {
    final service = TcService();
    await service.fetchTc();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = TcService();
    final dotColor = service.isLive ? verde : ambar;
    final formattedTc = service.lastTc.toStringAsFixed(4);

    final String labelText = 'TC DOF: \$$formattedTc';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovering ? card.withValues(alpha: 0.8) : card,
          border: Border.all(
              color: _isHovering ? ambar.withValues(alpha: 0.5) : border),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: _isHovering ? 12 : 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _pulseAnimation,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: dotColor.withValues(alpha: 0.6), blurRadius: 6)
                    ]),
              ),
            ),
            const SizedBox(width: 10),
            if (_isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: sec,
                ),
              )
            else
              Text(
                labelText,
                style: const TextStyle(
                  color: texto,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
