class SaldoImmex {
  final String id;
  final String pedimentoImportacion; // IN
  final String fraccion;
  final double cantidadInicial;
  final double cantidadRestante;
  final DateTime fechaEntrada;
  final DateTime fechaVencimiento; // Usually fechaEntrada + 18 months

  const SaldoImmex({
    required this.id,
    required this.pedimentoImportacion,
    required this.fraccion,
    required this.cantidadInicial,
    required this.cantidadRestante,
    required this.fechaEntrada,
    required this.fechaVencimiento,
  });

  factory SaldoImmex.fromMap(Map<String, dynamic> map, String docId) {
    return SaldoImmex(
      id: docId,
      pedimentoImportacion: map['pedimentoImportacion'] as String? ?? '',
      fraccion: map['fraccion'] as String? ?? '',
      cantidadInicial: (map['cantidadInicial'] as num?)?.toDouble() ?? 0.0,
      cantidadRestante: (map['cantidadRestante'] as num?)?.toDouble() ?? 0.0,
      fechaEntrada: map['fechaEntrada'] != null
          ? DateTime.parse(map['fechaEntrada'].toString())
          : DateTime.now(),
      fechaVencimiento: map['fechaVencimiento'] != null
          ? DateTime.parse(map['fechaVencimiento'].toString())
          : DateTime.now().add(const Duration(days: 540)), // 18 months
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pedimentoImportacion': pedimentoImportacion,
      'fraccion': fraccion,
      'cantidadInicial': cantidadInicial,
      'cantidadRestante': cantidadRestante,
      'fechaEntrada': fechaEntrada.toIso8601String(),
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
    };
  }

  int get diasRestantes => fechaVencimiento.difference(DateTime.now()).inDays;
  bool get estaVencido => diasRestantes < 0;
  bool get enRiesgo => diasRestantes >= 0 && diasRestantes <= 30;
}
