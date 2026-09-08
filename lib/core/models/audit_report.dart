class AuditReport {
  final String riskLevel; // low, medium, high
  final List<String> discrepancies;
  final List<String> semanticAnomalies;
  final double potentialFinesUSD;
  final String summary;

  AuditReport({
    required this.riskLevel,
    required this.discrepancies,
    required this.semanticAnomalies,
    required this.potentialFinesUSD,
    required this.summary,
  });

  factory AuditReport.fromJson(Map<String, dynamic> json) {
    return AuditReport(
      riskLevel: (json['riskLevel'] as String?) ?? 'low',
      discrepancies: List<String>.from((json['discrepancies'] as Iterable?) ?? []),
      semanticAnomalies: List<String>.from((json['semanticAnomalies'] as Iterable?) ?? []),
      potentialFinesUSD: (json['potentialFinesUSD'] as num?)?.toDouble() ?? 0.0,
      summary: (json['summary'] as String?) ?? '',
    );
  }
}
