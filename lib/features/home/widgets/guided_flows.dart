import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _bg = AppColors.bg;
const _card = AppColors.card;
const _gold = AppColors.gold;
const _text = AppColors.text;
const _sub = AppColors.sub;
const _border = AppColors.border;
const _green = AppColors.green;
const _blue = AppColors.blue;

class GuidedFlowsSection extends StatelessWidget {
  const GuidedFlowsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.map_outlined, color: _sub, size: 20),
            SizedBox(width: 8),
            Text(
              'Flujos de Trabajo',
              style: TextStyle(
                  color: _text, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FlowCard(
                icon: Icons.public,
                title: 'Importación Completa',
                description: 'Del B/L al despacho en 6 pasos',
                steps: [
                  'Shipment Tracker',
                  'Previo',
                  'Pre-Glosa',
                  'Despacho',
                  'Semáforo',
                  'Cuenta de Gastos',
                ],
                ctaText: 'Comenzar',
                route: '/shipment_tracker/nuevo',
                accent: _blue,
              ),
              SizedBox(width: 16),
              _FlowCard(
                icon: Icons.search,
                title: 'Clasificar y Calcular',
                description: 'De la descripción al costo final',
                steps: [
                  'Consultor TIGIE',
                  'Cross-Match',
                  'Landed Cost',
                ],
                ctaText: 'Clasificar',
                route: '/consultor_tigie',
                accent: _gold,
              ),
              SizedBox(width: 16),
              _FlowCard(
                icon: Icons.check_circle_outline,
                title: 'Compliance Check',
                description: 'Auditoría preventiva antes del SAT',
                steps: [
                  'SAT Radar',
                  'Warroom',
                  'Escritos Legales',
                ],
                ctaText: 'Auditar',
                route: '/sat_radar',
                accent: _green,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlowCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> steps;
  final String ctaText;
  final String route;
  final Color accent;

  const _FlowCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.steps,
    required this.ctaText,
    required this.route,
    required this.accent,
  });

  @override
  State<_FlowCard> createState() => _FlowCardState();
}

class _FlowCardState extends State<_FlowCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 320,
        height: 200,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.accent.withOpacity(_isHovered ? 0.6 : 0.25),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.accent.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.accent.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: widget.accent, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.description,
              style: const TextStyle(color: _sub, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    widget.steps.length,
                    (index) {
                      final isLast = index == widget.steps.length - 1;
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: widget.accent.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: widget.accent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.steps[index],
                                  style: const TextStyle(
                                    color: _text,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text('→',
                                  style:
                                      TextStyle(color: _sub.withOpacity(0.5))),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () => context.go(widget.route),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accent.withOpacity(0.15),
                  foregroundColor: widget.accent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: widget.accent.withOpacity(0.5)),
                  ),
                ),
                child: Text(
                  widget.ctaText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
