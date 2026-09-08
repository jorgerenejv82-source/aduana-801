class FreightQuote {
  final String id;
  final String forwarder;
  final String originPort;
  final String destinationPort;
  final String mode; // 'AEREO', 'MARITIMO', 'TERRESTRE'
  final double totalCost;
  final String currency;
  final int transitTimeDays;
  final bool isAwarded;
  final DateTime quoteDate;

  const FreightQuote({
    required this.id,
    required this.forwarder,
    required this.originPort,
    required this.destinationPort,
    required this.mode,
    required this.totalCost,
    required this.currency,
    required this.transitTimeDays,
    required this.isAwarded,
    required this.quoteDate,
  });

  factory FreightQuote.fromMap(Map<String, dynamic> map, String docId) {
    return FreightQuote(
      id: docId,
      forwarder: map['forwarder'] as String? ?? '',
      originPort: map['originPort'] as String? ?? '',
      destinationPort: map['destinationPort'] as String? ?? '',
      mode: map['mode'] as String? ?? '',
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      transitTimeDays: map['transitTimeDays'] as int? ?? 0,
      isAwarded: map['isAwarded'] as bool? ?? false,
      quoteDate: map['quoteDate'] != null
          ? DateTime.parse(map['quoteDate'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'forwarder': forwarder,
      'originPort': originPort,
      'destinationPort': destinationPort,
      'mode': mode,
      'totalCost': totalCost,
      'currency': currency,
      'transitTimeDays': transitTimeDays,
      'isAwarded': isAwarded,
      'quoteDate': quoteDate.toIso8601String(),
    };
  }
}
