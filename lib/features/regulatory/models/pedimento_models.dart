class Pedimento {
  final String id; // Doc ID in Firestore
  final String patente;
  final String aduana;
  final String numero;
  final String tipoOperacion; // IMP/EXP
  final String rfcImportador;
  final double valorAduana;
  final DateTime fechaPago;

  const Pedimento({
    required this.id,
    required this.patente,
    required this.aduana,
    required this.numero,
    required this.tipoOperacion,
    required this.rfcImportador,
    required this.valorAduana,
    required this.fechaPago,
  });

  factory Pedimento.fromMap(Map<String, dynamic> map, String docId) {
    return Pedimento(
      id: docId,
      patente: map['patente'] as String? ?? '',
      aduana: map['aduana'] as String? ?? '',
      numero: map['numero'] as String? ?? '',
      tipoOperacion: map['tipoOperacion'] as String? ?? '',
      rfcImportador: map['rfcImportador'] as String? ?? '',
      valorAduana: (map['valorAduana'] as num?)?.toDouble() ?? 0.0,
      fechaPago: map['fechaPago'] != null
          ? DateTime.parse(map['fechaPago'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patente': patente,
      'aduana': aduana,
      'numero': numero,
      'tipoOperacion': tipoOperacion,
      'rfcImportador': rfcImportador,
      'valorAduana': valorAduana,
      'fechaPago': fechaPago.toIso8601String(),
    };
  }

  String get pedimentoCompleto => '$aduana-$patente-$numero';
}

class Rectificacion {
  final String id;
  final String pedimentoOriginalId;
  final String campoModificado;
  final String valorAnterior;
  final String valorNuevo;
  final DateTime fechaRectificacion;
  final String justificacion;

  const Rectificacion({
    required this.id,
    required this.pedimentoOriginalId,
    required this.campoModificado,
    required this.valorAnterior,
    required this.valorNuevo,
    required this.fechaRectificacion,
    required this.justificacion,
  });

  factory Rectificacion.fromMap(Map<String, dynamic> map, String docId) {
    return Rectificacion(
      id: docId,
      pedimentoOriginalId: map['pedimentoOriginalId'] as String? ?? '',
      campoModificado: map['campoModificado'] as String? ?? '',
      valorAnterior: map['valorAnterior'] as String? ?? '',
      valorNuevo: map['valorNuevo'] as String? ?? '',
      fechaRectificacion: map['fechaRectificacion'] != null
          ? DateTime.parse(map['fechaRectificacion'].toString())
          : DateTime.now(),
      justificacion: map['justificacion'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pedimentoOriginalId': pedimentoOriginalId,
      'campoModificado': campoModificado,
      'valorAnterior': valorAnterior,
      'valorNuevo': valorNuevo,
      'fechaRectificacion': fechaRectificacion.toIso8601String(),
      'justificacion': justificacion,
    };
  }
}
