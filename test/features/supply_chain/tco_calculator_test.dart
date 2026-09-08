import 'package:flutter_test/flutter_test.dart';
import 'package:aduana_801/features/supply_chain/models/tco_calculator.dart';

void main() {
  group('TcoCalculator', () {
    test('calculates CIF correctly', () {
      final tco = TcoCalculator(
        name: 'China Supplier', country: 'CN',
        precioFob: 10000.0, flete: 2000.0, seguro: 50.0,
        arancelPct: 5.0, gastosAduana: 1000.0, mermasPct: 2.0,
        capitalParado: 500.0, moq: 100.0,
      );

      expect(tco.totalCif, 12050.0);
    });

    test('calculates Impuestos correctly', () {
      final tco = TcoCalculator(
        name: 'China Supplier', country: 'CN',
        precioFob: 10000.0, flete: 2000.0, seguro: 50.0,
        arancelPct: 5.0, gastosAduana: 1000.0, mermasPct: 2.0,
        capitalParado: 500.0, moq: 100.0,
      );

      // CIF = 12050, Impuestos = 12050 * 0.05 = 602.5
      expect(tco.impuestos, 602.5);
    });

    test('calculates Costo Unitario correctly', () {
      final tco = TcoCalculator(
        name: 'China Supplier', country: 'CN',
        precioFob: 10000.0, flete: 2000.0, seguro: 50.0,
        arancelPct: 5.0, gastosAduana: 1000.0, mermasPct: 2.0,
        capitalParado: 500.0, moq: 100.0,
      );

      // Mermas = 10000 * 0.02 = 200
      // TCO Total = 12050 + 602.5 + 1000 + 200 + 500 = 14352.5
      // Unitario = 14352.5 / 100 = 143.525
      expect(tco.tcoTotal, 14352.5);
      expect(tco.costoUnitario, 143.525);
    });
  });
}
