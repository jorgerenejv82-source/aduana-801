class NomRequirement {
  final String id;
  final String hsCode; // Fraccin Arancelaria
  final String productName;
  final List<String> requiredNoms;
  final List<String> requiredPermits; // COFEPRIS, SEMARNAT, etc.
  final String recommendations;

  const NomRequirement({
    required this.id,
    required this.hsCode,
    required this.productName,
    required this.requiredNoms,
    required this.requiredPermits,
    required this.recommendations,
  });

  factory NomRequirement.fromMap(Map<String, dynamic> map, String docId) {
    return NomRequirement(
      id: docId,
      hsCode: map['hsCode'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      requiredNoms:
          List<String>.from((map['requiredNoms'] as List<dynamic>?) ?? []),
      requiredPermits:
          List<String>.from((map['requiredPermits'] as List<dynamic>?) ?? []),
      recommendations: map['recommendations'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hsCode': hsCode,
      'productName': productName,
      'requiredNoms': requiredNoms,
      'requiredPermits': requiredPermits,
      'recommendations': recommendations,
    };
  }
}
