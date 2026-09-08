import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _card = AppColors.card;
const _gold = AppColors.gold;
const _text = AppColors.text;
const _sub = AppColors.sub;
const _green = AppColors.green;
const _blue = AppColors.blue;
const _purple = Color(0xFF8B5CF6);

class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 600;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ActionCard(
              title: 'Nuevo Expediente',
              subtitle: 'Inicia una operación',
              icon: Icons.folder_open,
              accent: _gold,
              route: '/expedientes',
              width: isSmall ? 200 : constraints.maxWidth / 4 - 12,
            ),
            const SizedBox(width: 16),
            _ActionCard(
              title: 'Clasificar con IA',
              subtitle: 'TIGIE + Gemini',
              icon: Icons.auto_awesome,
              accent: _blue,
              route: '/clasificador_ia',
              width: isSmall ? 200 : constraints.maxWidth / 4 - 12,
            ),
            const SizedBox(width: 16),
            _ActionCard(
              title: 'Pre-Glosa Rápida',
              subtitle: 'Valida antes de despachar',
              icon: Icons.check_circle_outline,
              accent: _green,
              route: '/pre_glosa',
              width: isSmall ? 200 : constraints.maxWidth / 4 - 12,
            ),
            const SizedBox(width: 16),
            _ActionCard(
              title: 'Nuevo Embarque',
              subtitle: 'Tracking + B/L',
              icon: Icons.directions_boat_outlined,
              accent: _purple,
              route: '/shipment_tracker/nuevo',
              width: isSmall ? 200 : constraints.maxWidth / 4 - 12,
            ),
          ],
        ),
      );
    });
  }
}

class _ActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String route;
  final double width;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.route,
    required this.width,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: 120,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.02 : 1.0, _isHovered ? 1.02 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.accent.withOpacity(_isHovered ? 0.6 : 0.3),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.accent.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: widget.accent,
                    size: 28,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                widget.title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  color: _sub,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
