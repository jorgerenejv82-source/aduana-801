class ClienteCrm {
  final String id;
  final String name;
  final String taxId;
  final String country;
  final String industry;
  final double creditLimit;
  final double currentBalance;
  final String paymentTerms;
  final String email;
  final String phone;

  // SAT / Cumplimiento
  final bool enPadronImportadores;
  final bool enPadronSectorial;
  final List<String> sectoresEspecificos;
  final String rfcStatus;
  final bool rfcListaNegra;
  final String? rfcListaNegraFecha;
  final String? numPatente;

  // IMMEX
  final bool hasImmex;
  final String numImmex;
  final String immexTipo;
  final String? immexVigencia;
  final String immexStatus;

  // Operativo
  final String aduana;
  final List<String> aduanasSecundarias;
  final String regimenFrecuente;

  const ClienteCrm({
    required this.id,
    required this.name,
    required this.taxId,
    required this.country,
    required this.industry,
    required this.creditLimit,
    required this.currentBalance,
    required this.paymentTerms,
    required this.email,
    required this.phone,
    this.enPadronImportadores = false,
    this.enPadronSectorial = false,
    this.sectoresEspecificos = const [],
    this.rfcStatus = 'no_verificado',
    this.rfcListaNegra = false,
    this.rfcListaNegraFecha,
    this.numPatente,
    this.hasImmex = false,
    this.numImmex = '',
    this.immexTipo = 'no_aplica',
    this.immexVigencia,
    this.immexStatus = 'no_aplica',
    this.aduana = '',
    this.aduanasSecundarias = const [],
    this.regimenFrecuente = '',
  });

  factory ClienteCrm.fromMap(Map<String, dynamic> map, String docId) {
    return ClienteCrm(
      id: docId,
      name: map['name'] as String? ?? '',
      taxId: map['taxId'] as String? ?? '',
      country: map['country'] as String? ?? '',
      industry: map['industry'] as String? ?? '',
      creditLimit: (map['creditLimit'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (map['currentBalance'] as num?)?.toDouble() ?? 0.0,
      paymentTerms: map['paymentTerms'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      enPadronImportadores: map['enPadronImportadores'] as bool? ?? false,
      enPadronSectorial: map['enPadronSectorial'] as bool? ?? false,
      sectoresEspecificos: List<String>.from(
          (map['sectoresEspecificos'] as List<dynamic>?) ?? []),
      rfcStatus: map['rfcStatus'] as String? ?? 'no_verificado',
      rfcListaNegra: map['rfcListaNegra'] as bool? ?? false,
      rfcListaNegraFecha: map['rfcListaNegraFecha'] as String?,
      numPatente: map['numPatente'] as String?,
      hasImmex: map['hasImmex'] as bool? ?? false,
      numImmex: map['numImmex'] as String? ?? '',
      immexTipo: map['immexTipo'] as String? ?? 'no_aplica',
      immexVigencia: map['immexVigencia'] as String?,
      immexStatus: map['immexStatus'] as String? ?? 'no_aplica',
      aduana: map['aduana'] as String? ?? '',
      aduanasSecundarias: List<String>.from(
          (map['aduanasSecundarias'] as List<dynamic>?) ?? []),
      regimenFrecuente: map['regimenFrecuente'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'taxId': taxId,
      'country': country,
      'industry': industry,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'paymentTerms': paymentTerms,
      'email': email,
      'phone': phone,
      'enPadronImportadores': enPadronImportadores,
      'enPadronSectorial': enPadronSectorial,
      'sectoresEspecificos': sectoresEspecificos,
      'rfcStatus': rfcStatus,
      'rfcListaNegra': rfcListaNegra,
      'rfcListaNegraFecha': rfcListaNegraFecha,
      'numPatente': numPatente,
      'hasImmex': hasImmex,
      'numImmex': numImmex,
      'immexTipo': immexTipo,
      'immexVigencia': immexVigencia,
      'immexStatus': immexStatus,
      'aduana': aduana,
      'aduanasSecundarias': aduanasSecundarias,
      'regimenFrecuente': regimenFrecuente,
    };
  }
}
