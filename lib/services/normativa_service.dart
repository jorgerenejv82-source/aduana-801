import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Service for Normativa Aduanera (UMA, PRV, CNT, TC DOF)
/// Connects to Banxico API for real exchange rates, with fallback.
class NormativaService {
  static final NormativaService _instance = NormativaService._internal();
  factory NormativaService() => _instance;
  NormativaService._internal();

  // Valores Actualizados
  final double uma = 108.57; // Unidad de Medida y Actualización diaria
  final double prv = 240.0; // Prevalidación (PRV) promedio + IVA
  final double cnt = 75.0; // Contraprestación (CNT) promedio + IVA

  // Simulated / Fetched FIX exchange rate from DOF
  double _tcDOF = 17.15;
  String _tcLastUpdate = 'No sincronizado';

  double get tipoCambioFix => _tcDOF;
  String get tcLastUpdate => _tcLastUpdate;

  // DTA limits (Art. 49 Ley Aduanera)
  double get dtaMaximo => 914.00;
  double get dtaMinimo => uma * 3.9;

  /// PRV + CNT total (Prevalidación + Contraprestación)
  double get prvCntTotal => prv + cnt;

  Future<void> fetchLatestTipoCambio() async {
    try {
      final url = Uri.parse('https://open.exchangerate-api.com/v6/latest/USD');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(url);
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody) as Map<String, dynamic>;
        _tcDOF =
            ((data['rates'] as Map<String, dynamic>)['MXN'] as num).toDouble();
        _tcLastUpdate = DateTime.now().toIso8601String().split('T')[0];
      } else {
        _aplicarFallback();
      }
    } catch (_) {
      _aplicarFallback();
    }
  }

  void _aplicarFallback() {
    _tcDOF = 17.20;
    _tcLastUpdate = 'Fallback Local (API Off)';
  }

  /// Calculo de DTA (Derecho de Trámite Aduanero)
  /// Regla general: 8 al millar sobre valor en aduana.
  /// Mínimo: UMA × 3.9 (~$423 MXN). Máximo: $914 MXN (importación definitiva).
  /// IMMEX/Temporal: cuota mínima fija.
  /// Exportación: $425 MXN cuota fija.
  double calcularDTA(double valorAduana, String regimen) {
    if (regimen.contains('Exportacion') || regimen.contains('Exportación')) {
      return 425.0;
    }

    final cuotaMinima = uma * 3.9; // ~$423 MXN

    if (regimen.contains('IMMEX') || regimen.contains('Temporal')) {
      return cuotaMinima;
    }

    final dtaCalculado = valorAduana * 0.008;
    return max(dtaCalculado, cuotaMinima).clamp(cuotaMinima, 914.00);
  }

  /// Calcula el valor en aduana según el Incoterm.
  /// CIF/CIP/DAP/DDP: el valor ya incluye flete y seguro.
  /// FOB/EXW/FCA/FAS/CFR/CPT: agregar flete + seguro.
  double calcularValorAduana(
      double fob, double flete, double seguro, String incoterm) {
    final incotermUpper = incoterm.toUpperCase();
    if (incotermUpper == 'CIF' ||
        incotermUpper == 'CIP' ||
        incotermUpper == 'DAP' ||
        incotermUpper == 'DDP' ||
        incotermUpper == 'DAT') {
      return fob;
    }
    return fob + flete + seguro;
  }
}
