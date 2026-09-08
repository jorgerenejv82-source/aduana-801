class TcoCalculator {
  final String name;
  final String country;
  final double precioFob;
  final double flete;
  final double seguro;
  final double arancelPct;
  final double gastosAduana;
  final double mermasPct;
  final double capitalParado;
  final double moq;

  TcoCalculator({
    required this.name,
    required this.country,
    required this.precioFob,
    required this.flete,
    required this.seguro,
    required this.arancelPct,
    required this.gastosAduana,
    required this.mermasPct,
    required this.capitalParado,
    required this.moq,
  });

  double get totalCif => precioFob + flete + seguro;
  double get impuestos => totalCif * (arancelPct / 100);
  double get costoMermas => precioFob * (mermasPct / 100);
  
  double get tcoTotal => totalCif + impuestos + gastosAduana + costoMermas + capitalParado;
  
  double get costoUnitario => moq > 0 ? tcoTotal / moq : 0;
}
