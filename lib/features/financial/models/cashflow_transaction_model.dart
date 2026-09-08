class CashflowTransaction {
  final String id;
  final double amount;
  final String
      type; // 'IN' (Cobrado), 'OUT' (Pagado), 'PENDING_IN', 'PENDING_OUT'
  final String description;
  final DateTime date;
  final String reference;

  const CashflowTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    required this.reference,
  });

  factory CashflowTransaction.fromMap(Map<String, dynamic> map, String docId) {
    return CashflowTransaction(
      id: docId,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] as String? ?? 'IN',
      description: map['description'] as String? ?? '',
      date: map['date'] != null
          ? DateTime.parse(map['date'].toString())
          : DateTime.now(),
      reference: map['reference'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'reference': reference,
    };
  }
}
