import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentRoutesTracker {
  static const _key = 'recent_routes';
  static const _max = 5;

  static Future<void> recordVisit(String route, String label) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentListStr = prefs.getStringList(_key) ?? [];

    List<Map<String, dynamic>> recentList = recentListStr
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();

    // Remove if already exists to move to top
    recentList.removeWhere((item) => item['route'] == route);

    // Add to beginning
    recentList.insert(0, {
      'route': route,
      'label': label,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Trim to max
    if (recentList.length > _max) {
      recentList = recentList.sublist(0, _max);
    }

    // Save back
    final List<String> saveList =
        recentList.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(_key, saveList);
  }

  static Future<List<Map<String, String>>> getRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentListStr = prefs.getStringList(_key) ?? [];

    return recentListStr.map((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return {
        'route': decoded['route'].toString(),
        'label': decoded['label'].toString(),
      };
    }).toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
