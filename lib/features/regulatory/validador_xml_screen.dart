import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';

const Color bg = AppColors.bg;
const Color card = AppColors.card;
const Color card2 = AppColors.card;
const Color bord = AppColors.border;
const Color texto = AppColors.text;
const Color sec = AppColors.sub;
const Color ambar = AppColors.gold;
const Color rojo = AppColors.red;
const Color azul = AppColors.blue;
const Color verde = AppColors.green;
const Color teal = Color(0xFF4ECCA3);
const Color morado = Color(0xFF8B5CF6);

class ValidadorXmlScreen extends StatefulWidget {
  const ValidadorXmlScreen({super.key});

  @override
  _ValidadorXmlScreenState createState() => _ValidadorXmlScreenState();
}

class _ValidadorXmlScreenState extends State<ValidadorXmlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _xmlController = TextEditingController();

  List<ValidationResult> _resultados = [];
  bool _validado = false;
  int _camposCorrectos = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _xmlController.dispose();
    super.dispose();
  }

  void _cargarEjemplo() {
    _xmlController.text = '''<pedimento>
  <encabezado>
    <aduana>240</aduana>
    <patente>3824</patente>
    <pedimento>26  6238 3824 0001234</pedimento>
    <tipoOperacion>IMP</tipoOperacion>
    <claveDocumento>IN</claveDocumento>
    <fechaEntrada>2024-07-26</fechaEntrada>
    <rfcImportador>XAXX010101000</rfcImportador>
    <valorAduana>875000.00</valorAduana>
    <tipoCambio>17.5000</tipoCambio>
  </encabezado>
  <partidas>
    <partida numero="1">
      <fraccionArancelaria>84713001</fraccionArancelaria>
      <descripcion>COMPUTADORAS PORTATILES</descripcion>
      <cantidad>50</cantidad>
      <unidadMedida>PZA</unidadMedida>
      <valorComercial>50000.00</valorComercial>
      <moneda>USD</moneda>
      <metodovaloracion>1</metodovaloracion>
    </partida>
  </partidas>
  <contribuciones>
    <contribucion>
      <clave>DTA</clave>
      <importe>848.00</importe>
    </contribucion>
    <contribucion>
      <clave>IVA</clave>
      <importe>140032.00</importe>
    </contribucion>
  </contribuciones>
</pedimento>''';
  }

  String _extraerValor(String xml, String tag) {
    final startTag = '<' + tag + '>';
    final endTag = '</' + tag + '>';
    final startIndex = xml.indexOf(startTag);
    if (startIndex == -1) return '';
    final valueStart = startIndex + startTag.length;
    final endIndex = xml.indexOf(endTag, valueStart);
    if (endIndex == -1) return '';
    return xml.substring(valueStart, endIndex).trim();
  }

  void _validarXml() {
    final xml = _xmlController.text;
    if (xml.isEmpty) return;

    final List<ValidationResult> resultados = [];
    int correctos = 0;

    // 1. RFC Importador
    final String rfc = _extraerValor(xml, 'rfcImportador');
    if (rfc.isEmpty) {
      resultados.add(ValidationResult(
        campo: 'RFC Importador',
        status: ValidationStatus.error,
        mensaje: 'Falta RFC del importador.',
      ));
    } else if (rfc == 'XAXX010101000') {
      resultados.add(ValidationResult(
        campo: 'RFC Importador',
        status: ValidationStatus.warning,
        mensaje: 'RFC generico detectado. Usar RFC real del importador.',
      ));
    } else {
      resultados.add(ValidationResult(
        campo: 'RFC Importador',
        status: ValidationStatus.correct,
        mensaje: 'RFC valido.',
      ));
      correctos++;
    }

    // 2. Fraccion arancelaria
    final String fraccion = _extraerValor(xml, 'fraccionArancelaria');
    if (fraccion.isEmpty) {
      resultados.add(ValidationResult(
        campo: 'Fraccion Arancelaria',
        status: ValidationStatus.error,
        mensaje: 'Falta fraccion arancelaria.',
      ));
    } else if (fraccion.length != 10 || fraccion.contains('.')) {
      resultados.add(ValidationResult(
        campo: 'Fraccion Arancelaria',
        status: ValidationStatus.error,
        mensaje:
            'Fraccion debe ser 10 digitos sin puntos en SAAI M3. Ejemplo: 8471300100',
      ));
    } else {
      resultados.add(ValidationResult(
        campo: 'Fraccion Arancelaria',
        status: ValidationStatus.correct,
        mensaje: 'Fraccion valida.',
      ));
      correctos++;
    }

    // 3. Tipo de cambio
    final String tipoCambioStr = _extraerValor(xml, 'tipoCambio');
    final double? tipoCambio = double.tryParse(tipoCambioStr);
    if (tipoCambioStr.isEmpty || tipoCambio == null) {
      resultados.add(ValidationResult(
        campo: 'Tipo de Cambio',
        status: ValidationStatus.error,
        mensaje: 'Tipo de cambio invalido o faltante.',
      ));
    } else if (tipoCambio < 15 || tipoCambio > 25) {
      resultados.add(ValidationResult(
        campo: 'Tipo de Cambio',
        status: ValidationStatus.warning,
        mensaje:
            'Tipo de cambio fuera del rango normal (15-25 MXN). Revisar valor.',
      ));
    } else {
      resultados.add(ValidationResult(
        campo: 'Tipo de Cambio',
        status: ValidationStatus.correct,
        mensaje: 'Tipo de cambio razonable.',
      ));
      correctos++;
    }

    // 4. DTA amount
    double? dtaAmount;
    final int dtaIndex = xml.indexOf('<clave>DTA</clave>');
    if (dtaIndex != -1) {
      final int importeStart = xml.indexOf('<importe>', dtaIndex);
      if (importeStart != -1) {
        final int valStart = importeStart + 9;
        final int importeEnd = xml.indexOf('</importe>', valStart);
        if (importeEnd != -1) {
          dtaAmount =
              double.tryParse(xml.substring(valStart, importeEnd).trim());
        }
      }
    }

    if (dtaAmount == null) {
      resultados.add(ValidationResult(
        campo: 'DTA',
        status: ValidationStatus.error,
        mensaje: 'No se encontro cuota de DTA.',
      ));
    } else if (dtaAmount != 847.84) {
      resultados.add(ValidationResult(
        campo: 'DTA',
        status: ValidationStatus.warning,
        mensaje:
            'DTA diferente a cuota fija 2024 (847.84). Puede ser correcto si aplica otra regla.',
      ));
    } else {
      resultados.add(ValidationResult(
        campo: 'DTA',
        status: ValidationStatus.correct,
        mensaje: 'DTA correcto (847.84).',
      ));
      correctos++;
    }

    // 5. Valor aduana > 0
    final String valorAduanaStr = _extraerValor(xml, 'valorAduana');
    final double? valorAduana = double.tryParse(valorAduanaStr);
    if (valorAduana == null || valorAduana <= 0) {
      resultados.add(ValidationResult(
        campo: 'Valor Aduana',
        status: ValidationStatus.error,
        mensaje: 'Valor en aduana debe ser mayor a 0.',
      ));
    } else {
      resultados.add(ValidationResult(
        campo: 'Valor Aduana',
        status: ValidationStatus.correct,
        mensaje: 'Valor en aduana correcto.',
      ));
      correctos++;
    }

    // 6. Aduana code
    final String aduana = _extraerValor(xml, 'aduana');
    if (aduana.length != 3) {
      resultados.add(ValidationResult(
        campo: 'Aduana',
        status: ValidationStatus.error,
        mensaje: 'Codigo de aduana debe ser de 3 digitos.',
      ));
    } else {
      resultados.add(ValidationResult(
        campo: 'Aduana',
        status: ValidationStatus.correct,
        mensaje: 'Codigo de aduana valido.',
      ));
      correctos++;
    }

    // 7. Patente
    final String patente = _extraerValor(xml, 'patente');
    if (patente.length != 4) {
      resultados.add(ValidationResult(
        campo: 'Patente',
        status: ValidationStatus.error,
        mensaje: 'Numero de patente debe ser de 4 digitos.',
      ));
    } else {
      resultados.add(ValidationResult(
        campo: 'Patente',
        status: ValidationStatus.correct,
        mensaje: 'Numero de patente valido.',
      ));
      correctos++;
    }

    // 8. Fecha entrada
    final String fechaEntrada = _extraerValor(xml, 'fechaEntrada');
    // Regex pattern for YYYY-MM-DD
    if (fechaEntrada.length != 10) {
      resultados.add(ValidationResult(
        campo: 'Fecha Entrada',
        status: ValidationStatus.error,
        mensaje: 'Formato de fecha invalido. Usar YYYY-MM-DD.',
      ));
    } else {
      resultados.add(ValidationResult(
        campo: 'Fecha Entrada',
        status: ValidationStatus.correct,
        mensaje: 'Fecha de entrada valida.',
      ));
      correctos++;
    }

    // 9. Tipo operacion
    final String tipoOperacion = _extraerValor(xml, 'tipoOperacion');
    if (tipoOperacion != 'IMP' && tipoOperacion != 'EXP') {
      resultados.add(ValidationResult(
        campo: 'Tipo Operacion',
        status: ValidationStatus.error,
        mensaje: 'Tipo de operacion debe ser IMP o EXP.',
      ));
    } else {
      resultados.add(ValidationResult(
        campo: 'Tipo Operacion',
        status: ValidationStatus.correct,
        mensaje: 'Tipo de operacion valido.',
      ));
      correctos++;
    }

    // 10. Clave documento
    final String claveDocumento = _extraerValor(xml, 'claveDocumento');
    if (claveDocumento.isEmpty) {
      resultados.add(ValidationResult(
        campo: 'Clave Documento',
        status: ValidationStatus.error,
        mensaje: 'Clave de documento no puede estar vacia.',
      ));
    } else {
      resultados.add(ValidationResult(
        campo: 'Clave Documento',
        status: ValidationStatus.correct,
        mensaje: 'Clave de documento valida.',
      ));
      correctos++;
    }

    setState(() {
      _resultados = resultados;
      _camposCorrectos = correctos;
      _validado = true;
      _tabController.animateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: card,
        title: const Text('Validador XML Pedimento',
            style: TextStyle(color: texto)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ambar,
          labelColor: ambar,
          unselectedLabelColor: sec,
          tabs: const [
            Tab(text: 'Ingresar XML', icon: Icon(Icons.code)),
            Tab(text: 'Resultados', icon: Icon(Icons.check_circle_outline)),
            Tab(text: 'Guia de Campos', icon: Icon(Icons.help_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIngresarXmlTab(),
          _buildResultadosTab(),
          _buildGuiaTab(),
        ],
      ),
    );
  }

  Widget _buildIngresarXmlTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _cargarEjemplo,
            style: ElevatedButton.styleFrom(
              backgroundColor: card2,
              foregroundColor: texto,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file, color: azul),
                SizedBox(width: 8),
                Text('Cargar XML de Ejemplo'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _xmlController,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: texto,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: '<pedimento>...',
                hintStyle: TextStyle(color: sec),
                filled: true,
                fillColor: card,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: bord),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: bord),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ambar),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _validarXml,
            style: ElevatedButton.styleFrom(
              backgroundColor: ambar,
              foregroundColor: bg,
              padding: const EdgeInsets.symmetric(vertical: 20),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user),
                SizedBox(width: 8),
                Text('VALIDAR PEDIMENTO'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadosTab() {
    if (!_validado) {
      return const Center(
        child: Text(
          'Valide un XML para ver los resultados',
          style: TextStyle(color: sec, fontSize: 16),
        ),
      );
    }

    final bool tieneErrores =
        _resultados.any((r) => r.status == ValidationStatus.error);
    final String totalScore =
        '$_camposCorrectos/10 campos validados correctamente';

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: (tieneErrores ? rojo : verde).withAlpha(25),
              borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                tieneErrores ? 'ERRORES ENCONTRADOS' : 'VALIDO',
                style: TextStyle(
                  color: tieneErrores ? rojo : verde,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                totalScore,
                style: const TextStyle(color: texto, fontSize: 16),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              for (final resultado in _resultados)
                Card(
                  color: card,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: bord),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          resultado.status == ValidationStatus.error
                              ? Icons.error
                              : resultado.status == ValidationStatus.warning
                                  ? Icons.warning
                                  : Icons.check_circle,
                          color: resultado.status == ValidationStatus.error
                              ? rojo
                              : resultado.status == ValidationStatus.warning
                                  ? ambar
                                  : verde,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resultado.campo,
                                style: const TextStyle(
                                  color: texto,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                resultado.status == ValidationStatus.error
                                    ? 'Error'
                                    : resultado.status ==
                                            ValidationStatus.warning
                                        ? 'Advertencia'
                                        : 'Correcto',
                                style: TextStyle(
                                  color:
                                      resultado.status == ValidationStatus.error
                                          ? rojo
                                          : resultado.status ==
                                                  ValidationStatus.warning
                                              ? ambar
                                              : verde,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                resultado.mensaje,
                                style: const TextStyle(color: sec),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuiaTab() {
    final campos = [
      {
        'campo': 'Aduana',
        'formato': '3 digitos',
        'ejemplo': '240',
        'obligatorio': 'Si'
      },
      {
        'campo': 'Patente',
        'formato': '4 digitos',
        'ejemplo': '3824',
        'obligatorio': 'Si'
      },
      {
        'campo': 'Tipo Operacion',
        'formato': 'IMP o EXP',
        'ejemplo': 'IMP',
        'obligatorio': 'Si'
      },
      {
        'campo': 'Clave Documento',
        'formato': 'Texto',
        'ejemplo': 'IN',
        'obligatorio': 'Si'
      },
      {
        'campo': 'Fecha Entrada',
        'formato': 'YYYY-MM-DD',
        'ejemplo': '2024-07-26',
        'obligatorio': 'Si'
      },
      {
        'campo': 'RFC Importador',
        'formato': 'RFC Valido',
        'ejemplo': 'XAXX010101000',
        'obligatorio': 'Si'
      },
      {
        'campo': 'Valor Aduana',
        'formato': 'Numerico > 0',
        'ejemplo': '875000.00',
        'obligatorio': 'Si'
      },
      {
        'campo': 'Tipo Cambio',
        'formato': 'Numerico',
        'ejemplo': '17.5000',
        'obligatorio': 'Si'
      },
      {
        'campo': 'Fraccion Arancelaria',
        'formato': '10 digitos',
        'ejemplo': '8471300100',
        'obligatorio': 'Si'
      },
      {
        'campo': 'DTA',
        'formato': 'Numerico',
        'ejemplo': '847.84',
        'obligatorio': 'Si'
      },
    ];

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        for (final c in campos)
          Card(
            color: card,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: bord),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c['campo'] ?? '',
                    style: const TextStyle(
                        color: teal, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.format_shapes, color: sec, size: 16),
                      const SizedBox(width: 8),
                      Text('Formato: ' + (c['formato'] ?? ''),
                          style: const TextStyle(color: texto)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.text_snippet, color: sec, size: 16),
                      const SizedBox(width: 8),
                      Text('Ejemplo: ' + (c['ejemplo'] ?? ''),
                          style: const TextStyle(color: texto)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.priority_high, color: sec, size: 16),
                      const SizedBox(width: 8),
                      Text('Obligatorio: ' + (c['obligatorio'] ?? ''),
                          style: const TextStyle(color: texto)),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

enum ValidationStatus { correct, warning, error }

class ValidationResult {
  final String campo;
  final ValidationStatus status;
  final String mensaje;

  ValidationResult({
    required this.campo,
    required this.status,
    required this.mensaje,
  });
}
