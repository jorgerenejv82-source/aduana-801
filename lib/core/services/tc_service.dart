// ignore_for_file: library_private_types_in_public_api
import 'dart:convert';
import 'package:http/http.dart' as http;

class TcService {
  static final TcService _instance = TcService._internal();

  factory TcService() {
    return _instance;
  }

  TcService._internal();

  double lastTc = 17.50;
  DateTime lastUpdated = DateTime.now();
  bool isLive = false;

  final Map<String, double> crossRates = {
    'USD': 17.3456,
    'EUR': 19.1283,
    'GBP': 22.4878,
    'JPY': 0.1154,
    'CNY': 2.3981,
    'CAD': 12.8745,
    'MXN': 1.0,
  };

  Future<void> fetchTc() async {
    try {
      final response =
          await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final apiRates = data['rates'] as Map<String, dynamic>?;
        if (apiRates != null && apiRates['MXN'] != null) {
          final mxnRate = (apiRates['MXN'] as num).toDouble();
          lastTc = mxnRate;

          final targetCurrencies = [
            'USD',
            'EUR',
            'GBP',
            'JPY',
            'CNY',
            'CAD',
            'MXN'
          ];
          for (final code in targetCurrencies) {
            if (apiRates[code] != null) {
              final rateToUsd = (apiRates[code] as num).toDouble();
              if (rateToUsd > 0) {
                crossRates[code] = mxnRate / rateToUsd;
              }
            }
          }

          lastUpdated = DateTime.now();
          isLive = true;
          return;
        }
      }
    } catch (e) {
      // Ignored, will fall through to fallback
    }

    // Fallback
    lastTc = 17.50;
    lastUpdated = DateTime.now();
    isLive = false;
  }
}
