class LetterOfCredit {
  final String id;
  final String lcNumber;
  final String issuingBank;
  final String beneficiary;
  final double amount;
  final String currency;
  final DateTime expiryDate;
  final String requiredDocuments; // Comma separated

  const LetterOfCredit({
    required this.id,
    required this.lcNumber,
    required this.issuingBank,
    required this.beneficiary,
    required this.amount,
    required this.currency,
    required this.expiryDate,
    required this.requiredDocuments,
  });

  factory LetterOfCredit.fromMap(Map<String, dynamic> map, String docId) {
    return LetterOfCredit(
      id: docId,
      lcNumber: map['lcNumber'] as String? ?? '',
      issuingBank: map['issuingBank'] as String? ?? '',
      beneficiary: map['beneficiary'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'USD',
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'].toString())
          : DateTime.now().add(const Duration(days: 90)),
      requiredDocuments: map['requiredDocuments'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lcNumber': lcNumber,
      'issuingBank': issuingBank,
      'beneficiary': beneficiary,
      'amount': amount,
      'currency': currency,
      'expiryDate': expiryDate.toIso8601String(),
      'requiredDocuments': requiredDocuments,
    };
  }
}
