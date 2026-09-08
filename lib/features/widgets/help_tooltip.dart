import 'package:flutter/material.dart';

class HelpTooltip extends StatelessWidget {
  final String text;
  final String explanation;

  const HelpTooltip({
    super.key,
    required this.text,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: explanation,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Color(0xFFF8FAFC),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF3B82F6),
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          decorationColor: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
