import 'package:flutter/material.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

/// Utility class for showing consistent confirmation dialogs
class ConfirmDialog {
  /// Shows a destructive action confirmation dialog
  /// Returns true if user confirms, false if cancelled
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Eliminar',
    String cancelLabel = 'Cancelar',
    Color confirmColor = AppColors.red,
    IconData icon = Icons.warning_amber_rounded,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return _buildDialog(context, title, message, confirmLabel,
                cancelLabel, confirmColor, icon);
          },
        ) ??
        false;
  }

  /// Shows a non-destructive confirmation dialog (blue confirm button)
  static Future<bool> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Aceptar',
    String cancelLabel = 'Cancelar',
    Color confirmColor = AppColors.blue,
    IconData icon = Icons.info_outline_rounded,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return _buildDialog(context, title, message, confirmLabel,
                cancelLabel, confirmColor, icon);
          },
        ) ??
        false;
  }

  static Widget _buildDialog(
      BuildContext context,
      String title,
      String message,
      String confirmLabel,
      String cancelLabel,
      Color confirmColor,
      IconData icon) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            top: BorderSide(color: AppColors.gold, width: 2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: confirmColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.sub,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
