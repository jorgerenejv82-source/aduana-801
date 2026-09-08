class PurchaseOrder {
  final String id;
  final String poNumber;
  final String supplierName;
  final String incoterm;
  final String currency;
  final double totalAmount;
  final String status; // 'PENDING', 'SENT', 'RECEIVED'
  final DateTime issueDate;
  final DateTime expectedDeliveryDate;

  final String fraccionArancelaria;
  final String paisOrigen;
  final int leadTimeDias;
  final bool tieneCertOrigen;
  final double precioUnitario;
  final int cantidadUnidades;
  final String descripcionMercancia;
  final double costoFleteEstimado;
  final String unidadMedida;

  const PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.supplierName,
    required this.incoterm,
    required this.currency,
    required this.totalAmount,
    required this.status,
    required this.issueDate,
    required this.expectedDeliveryDate,
    required this.fraccionArancelaria,
    required this.paisOrigen,
    required this.leadTimeDias,
    required this.tieneCertOrigen,
    required this.precioUnitario,
    required this.cantidadUnidades,
    required this.descripcionMercancia,
    required this.costoFleteEstimado,
    required this.unidadMedida,
  });

  factory PurchaseOrder.fromMap(Map<String, dynamic> map, String docId) {
    return PurchaseOrder(
      id: docId,
      poNumber: map['poNumber'] as String? ?? '',
      supplierName: map['supplierName'] as String? ?? '',
      incoterm: map['incoterm'] as String? ?? '',
      currency: map['currency'] as String? ?? 'USD',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'PENDING',
      issueDate: map['issueDate'] != null
          ? DateTime.parse(map['issueDate'].toString())
          : DateTime.now(),
      expectedDeliveryDate: map['expectedDeliveryDate'] != null
          ? DateTime.parse(map['expectedDeliveryDate'].toString())
          : DateTime.now().add(const Duration(days: 30)),
      fraccionArancelaria: map['fraccionArancelaria'] as String? ?? '',
      paisOrigen: map['paisOrigen'] as String? ?? '',
      leadTimeDias: map['leadTimeDias'] as int? ?? 30,
      tieneCertOrigen: map['tieneCertOrigen'] as bool? ?? false,
      precioUnitario: (map['precioUnitario'] as num?)?.toDouble() ?? 0.0,
      cantidadUnidades: map['cantidadUnidades'] as int? ?? 0,
      descripcionMercancia: map['descripcionMercancia'] as String? ?? '',
      costoFleteEstimado:
          (map['costoFleteEstimado'] as num?)?.toDouble() ?? 0.0,
      unidadMedida: map['unidadMedida'] as String? ?? 'PZA',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'poNumber': poNumber,
      'supplierName': supplierName,
      'incoterm': incoterm,
      'currency': currency,
      'totalAmount': totalAmount,
      'status': status,
      'issueDate': issueDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'fraccionArancelaria': fraccionArancelaria,
      'paisOrigen': paisOrigen,
      'leadTimeDias': leadTimeDias,
      'tieneCertOrigen': tieneCertOrigen,
      'precioUnitario': precioUnitario,
      'cantidadUnidades': cantidadUnidades,
      'descripcionMercancia': descripcionMercancia,
      'costoFleteEstimado': costoFleteEstimado,
      'unidadMedida': unidadMedida,
    };
  }
}
