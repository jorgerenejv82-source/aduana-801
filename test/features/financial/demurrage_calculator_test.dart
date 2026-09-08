import 'package:flutter_test/flutter_test.dart';
import 'package:aduana_801/features/financial/models/demurrage_calculator.dart';

void main() {
  group('DemurrageCalculator', () {
    test('calculates demoras correctly for delayed container', () {
      final calculator = DemurrageCalculator(
        aduana: 'Manzanillo', tipo: '40HC',
        arribo: DateTime.now().subtract(const Duration(days: 10)),
        diasLibres: 7, costoXDia: 100.0,
      );

      expect(calculator.diasEnPuerto, 10);
      expect(calculator.diasDemora, 3);
      expect(calculator.totalCargo, 300.0);
      expect(calculator.estado, EstadoCont.generandoCargos);
    });

    test('identifies container at risk', () {
      final calculator = DemurrageCalculator(
        aduana: 'Manzanillo', tipo: '40HC',
        arribo: DateTime.now().subtract(const Duration(days: 6)),
        diasLibres: 7, costoXDia: 100.0,
      );

      expect(calculator.diasEnPuerto, 6);
      expect(calculator.diasDemora, 0);
      expect(calculator.totalCargo, 0.0);
      expect(calculator.enRiesgo, true);
      expect(calculator.estado, EstadoCont.enRiesgo);
    });
  });
}
