import 'package:flutter/material.dart';

/// Consistent snackbar/toast helper
class AppToast {
  static void success(BuildContext context, String message) {
    _show(
        context,
        message,
        const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
        const Color(0xFF10B981));
  }

  static void error(BuildContext context, String message) {
    _show(
        context,
        message,
        const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
        const Color(0xFFEF4444));
  }

  static void warning(BuildContext context, String message) {
    _show(
        context,
        message,
        const Icon(Icons.warning_amber_rounded,
            color: Color(0xFFF59E0B), size: 18),
        const Color(0xFFF59E0B));
  }

  static void info(BuildContext context, String message) {
    _show(
        context,
        message,
        const Icon(Icons.info_outline_rounded,
            color: Color(0xFF3B82F6), size: 18),
        const Color(0xFF3B82F6));
  }

  static void _show(
      BuildContext context, String message, Icon icon, Color borderColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(message, style: const TextStyle(color: Colors.white))),
        ]),
        backgroundColor: const Color(0xFF0D1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
