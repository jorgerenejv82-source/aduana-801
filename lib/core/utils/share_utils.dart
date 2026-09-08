import 'package:url_launcher/url_launcher.dart';
import '../services/analytics_service.dart';

class ShareUtils {
  /// Opens WhatsApp with a pre-filled message
  static Future<void> shareViaWhatsApp(String message) async {
    final encoded = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse('https://wa.me/?text=$encoded');
    if (await canLaunchUrl(whatsappUrl)) {
      await AnalyticsService.instance.logShare('content', 'whatsapp');
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens device share sheet (web: copies to clipboard)
  static Future<void> shareText(String text, {String? subject}) async {
    // For Flutter web, use clipboard
    // import 'package:flutter/services.dart';
    // await Clipboard.setData(ClipboardData(text: text));
    await shareViaWhatsApp(text);
  }
}
