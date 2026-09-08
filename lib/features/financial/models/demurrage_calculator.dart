import 'dart:math';

enum EstadoCont { libre, enRiesgo, generandoCargos }

class DemurrageCalculator {
  final String aduana;
  final String tipo;
  final DateTime arribo;
  final int diasLibres;
  final double costoXDia;

  DemurrageCalculator({
    required this.aduana,
    required this.tipo,
    required this.arribo,
    required this.diasLibres,
    required this.costoXDia,
  });

  int get diasEnPuerto => DateTime.now().difference(arribo).inDays;
  int get diasDemora => max(0, diasEnPuerto - diasLibres);
  double get totalCargo => diasDemora * costoXDia;
  bool get enRiesgo => diasEnPuerto >= diasLibres - 2 && diasDemora == 0;

  EstadoCont get estado {
    if (diasDemora > 0) return EstadoCont.generandoCargos;
    if (enRiesgo) return EstadoCont.enRiesgo;
    return EstadoCont.libre;
  }
}
