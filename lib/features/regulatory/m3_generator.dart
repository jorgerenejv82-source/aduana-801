/// Generador de archivos planos estándar M3 (Anexo 22)
/// Utilizado para enviar pedimentos a Pre-Validadores SAAI (CAAAREM, CLAA, etc.)
class M3Generator {
  /// Genera la cadena plana (ASCII) M3 para un pedimento
  static String generarTramaM3({
    required String aduana,
    required String patente,
    required String pedimento,
    required String tipoOperacion, // '1' Impo, '2' Expo
    required String cveDoc,
    required String rfcImportador,
    required String rfcAgenteAduanal,
    required double tipoCambio,
    required List<Map<String, dynamic>> partidas,
  }) {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final fechaSys =
        "${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year}";

    // REGISTRO 500: DATOS GENERALES DEL PEDIMENTO
    // Formato Estándar SAAI Anexo 22
    buffer.write('500|');
    buffer.write('1|'); // Tipo Movimiento (1 = Normal)
    buffer.write('$patente|');
    buffer.write('$pedimento|');
    buffer.write('$aduana|');
    buffer.write('$cveDoc|');
    buffer.write('$tipoOperacion|');
    buffer.write('$rfcImportador|');
    buffer.write('$rfcAgenteAduanal|');
    buffer.write('${tipoCambio.toStringAsFixed(4)}|');
    buffer.write('$fechaSys|');
    buffer.writeln(); // Fin Registro 500

    // REGISTRO 501: TRANSPORTE Y GUÍAS
    // Simulamos los datos del medio de transporte
    buffer.write('501|');
    buffer.write('$patente|');
    buffer.write('$pedimento|');
    buffer.write('$aduana|');
    buffer.write(
        '1|'); // Medio de transporte de entrada (1 = Marítimo, 3 = Carretero, etc)
    buffer.write('GUIA-TEST-1234|');
    buffer.writeln();

    // REGISTROS 551: PARTIDAS (MERCANCÍAS)
    int numPartida = 1;
    for (final partida in partidas) {
      final fraccion =
          partida['fraccion']?.toString().padRight(8, '0') ?? '00000000';
      final valorAduana = (partida['valorAduana'] as num?)?.toInt() ?? 0;
      final cantidadCve = (partida['cantidadCve'] as num?)?.toInt() ?? 0;
      final paisOrigen = partida['origen']?.toString() ?? 'XXX';

      buffer.write('551|');
      buffer.write('$patente|');
      buffer.write('$pedimento|');
      buffer.write('$aduana|');
      buffer.write('$numPartida|'); // Número de partida
      buffer.write('$fraccion|'); // Fracción arancelaria TIGIE
      buffer.write('$valorAduana|'); // Valor Aduana (entero)
      buffer.write('$cantidadCve|'); // Cantidad UMT
      buffer.write('$paisOrigen|'); // País Origen/Destino
      buffer.writeln();
      numPartida++;
    }

    // REGISTRO 800: FIN DEL ARCHIVO
    buffer.write('800|');
    buffer.write('$patente|');
    buffer.write('$pedimento|');
    buffer.write('$aduana|');
    buffer.write('${partidas.length}|'); // Total partidas
    buffer.writeln();

    return buffer.toString();
  }
}
