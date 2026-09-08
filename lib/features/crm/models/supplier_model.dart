class Supplier {
  final String id;
  final String name;
  final String taxId;
  final String country;
  final String currency;
  final String bankDetails;
  final String paymentTerms;
  final double reliabilityScore; // 0.0 to 10.0

  const Supplier({
    required this.id,
    required this.name,
    required this.taxId,
    required this.country,
    required this.currency,
    required this.bankDetails,
    required this.paymentTerms,
    this.reliabilityScore = 10.0,
  });

  factory Supplier.fromMap(Map<String, dynamic> map, String docId) {
    return Supplier(
      id: docId,
      name: map['name'] as String? ?? '',
      taxId: map['taxId'] as String? ?? '',
      country: map['country'] as String? ?? '',
      currency: map['currency'] as String? ?? '',
      bankDetails: map['bankDetails'] as String? ?? '',
      paymentTerms: map['paymentTerms'] as String? ?? '',
      reliabilityScore: (map['reliabilityScore'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'taxId': taxId,
      'country': country,
      'currency': currency,
      'bankDetails': bankDetails,
      'paymentTerms': paymentTerms,
      'reliabilityScore': reliabilityScore,
    };
  }
}
