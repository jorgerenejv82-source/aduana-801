import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:aduana_801/features/regulatory/m3_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _gold = AppColors.gold;
const Color _text = AppColors.text;
const Color _sub = AppColors.sub;
const Color _border = AppColors.border;
const Color _red = AppColors.red;
const Color _blue = AppColors.blue;

enum _Severity { error, warning, info }

class _ValidationResult {
  final String codigo;
  final _Severity severity;
  final String mensaje;
  final String? referencia;

  _ValidationResult({
    required this.codigo,
    required this.severity,
    required this.mensaje,
    this.referencia,
  });
}

class PreValidadorM3Screen extends StatefulWidget {
  const PreValidadorM3Screen({super.key});

  @override
  State<PreValidadorM3Screen> createState() => _PreValidadorM3ScreenState();
}

class _PreValidadorM3ScreenState extends State<PreValidadorM3Screen> {
  final TextEditingController _m3Controller = TextEditingController();
  List<_ValidationResult> _resultados = [];
  bool _validado = false;
  bool _isHoveringValidate = false;
  bool _isHoveringCopy = false;

  void _cargarEjemplo() {
    final m3Text = M3Generator.generarTramaM3(
        aduana: '430',
        patente: '3941',
        pedimento: '1234567',
        tipoOperacion: '1',
        cveDoc: 'IN',
        rfcImportador: 'XAXX010101000',
        rfcAgenteAduanal: 'XEXX010101000',
        tipoCambio: 17.5020,
        partidas: [
          {
            'fraccion': '84713001',
            'valorAduana': 45000,
            'cantidadCve': 100,
            'origen': 'CHN'
          },
          {
            'fraccion': '85171201',
            'valorAduana': 23000,
            'cantidadCve': 50,
            'origen': 'USA'
          },
        ]);
    _m3Controller.text = m3Text;
    _validarM3();
  }

  void _validarM3() {
    final texto = _m3Controller.text;
    final List<_ValidationResult> res = [];

    if (texto.trim().isEmpty) {
      res.add(_ValidationResult(
          codigo: 'A22-R01',
          severity: _Severity.error,
          mensaje: 'El pedimento M3 está vacío'));
      setState(() {
        _resultados = res;
        _validado = true;
      });
      return;
    }

    if (texto.length < 50) {
      res.add(_ValidationResult(
          codigo: 'A22-R02',
          severity: _Severity.error,
          mensaje: 'El M3 es demasiado corto para ser válido'));
    }

    final rfcRegExp = RegExp('[A-Z]{3,4}[0-9]{6}[A-Z0-9]{3}');
    if (!texto.contains('RFC') || !rfcRegExp.hasMatch(texto)) {
      res.add(_ValidationResult(
          codigo: 'A22-R03',
          severity: _Severity.warning,
          mensaje: 'RFC del importador no detectado o formato inválido'));
    }

    final regimenes = [
      'IM',
      'EX',
      'IT',
      'IN',
      'IP',
      'TE',
      'TR',
      'TN',
      'RT',
      'CT',
      'EV',
      'ET'
    ];
    if (!regimenes.any((r) => texto.contains(r))) {
      res.add(_ValidationResult(
          codigo: 'A22-R04',
          severity: _Severity.error,
          mensaje:
              'Clave de régimen aduanero no identificada. Verifique campo de régimen.'));
    }

    if (texto.contains('TL') && !texto.contains('AF')) {
      res.add(_ValidationResult(
          codigo: 'A22-R05',
          severity: _Severity.warning,
          mensaje:
              'Identificador TL (T-MEC) presente sin identificador AF (Acuerdo). Regla Apéndice 8 RGCE.',
          referencia: 'Apéndice 8 RGCE'));
    }

    if (texto.contains('EP') && !texto.contains('FR')) {
      res.add(_ValidationResult(
          codigo: 'A22-R06',
          severity: _Severity.warning,
          mensaje:
              'Empresa IMMEX (EP) sin fracción IMMEX (FR). Verifique inscripción al programa.'));
    }

    if ((texto.contains('NOM') || texto.contains('nom')) &&
        !texto.contains('MA')) {
      res.add(_ValidationResult(
          codigo: 'A22-R07',
          severity: _Severity.error,
          mensaje:
              'Fracción sujeta a NOM sin identificador MA. Art. 36-A Ley Aduanera.',
          referencia: 'Art. 36-A LA'));
    }

    if (texto.contains('0.00 USD') ||
        texto.contains('0.00  USD') ||
        RegExp(r'0\.00\s+USD').hasMatch(texto)) {
      res.add(_ValidationResult(
          codigo: 'A22-R08',
          severity: _Severity.warning,
          mensaje:
              'Valor declarado en cero. Verifique valoración aduanera (Arts. 64-78 LA).',
          referencia: 'Arts. 64-78 LA'));
    }

    if (!texto.contains('DTA')) {
      res.add(_ValidationResult(
          codigo: 'A22-R09',
          severity: _Severity.info,
          mensaje:
              'DTA (Derecho de Trámite Aduanero) no detectado. Verifique si aplica.'));
    }

    final lineas = texto.split('\n');
    if (lineas.any((l) => l.length > 300)) {
      res.add(_ValidationResult(
          codigo: 'A22-R10',
          severity: _Severity.error,
          mensaje:
              'Campo excede longitud máxima permitida por SAAI (300 chars por línea).'));
    }

    final especialChars = RegExp('[ñáéíóúÑÁÉÍÓÚ]');
    if (especialChars.hasMatch(texto)) {
      res.add(_ValidationResult(
          codigo: 'A22-R11',
          severity: _Severity.warning,
          mensaje:
              'Caracteres especiales detectados. SAAI solo acepta ASCII básico.'));
    }

    if (texto.contains('|')) {
      res.add(_ValidationResult(
          codigo: 'A22-R12',
          severity: _Severity.info,
          mensaje:
              'Formato de separadores | detectado. Verifique versión del layout M3.'));
    }

    final pedimentoRegExp = RegExp(r'\d{10,}');
    if (!pedimentoRegExp.hasMatch(texto.replaceAll('-', ''))) {
      res.add(_ValidationResult(
          codigo: 'A22-R13',
          severity: _Severity.warning,
          mensaje:
              'Número de pedimento no detectado. Formato: AAAA-XXXXXX-XXXXXX'));
    }

    if (RegExp(r'\s{3,}').hasMatch(texto)) {
      res.add(_ValidationResult(
          codigo: 'A22-R14',
          severity: _Severity.error,
          mensaje:
              'Múltiples espacios en blanco. Pueden causar error de parsing en SAAI.'));
    }

    res.add(_ValidationResult(
        codigo: 'A22-R15',
        severity: _Severity.info,
        mensaje: 'Pedimento con ${lineas.length} líneas detectadas'));

    setState(() {
      _resultados = res;
      _validado = true;
    });
  }

  void _copiarReporte() {
    final rep = _resultados
        .map((r) =>
            '[${r.severity.name.toUpperCase()}] ${r.codigo}: ${r.mensaje}')
        .join('\n');
    Clipboard.setData(ClipboardData(text: rep));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte copiado al portapapeles')));
  }

  @override
  void dispose() {
    _m3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int errors =
        _resultados.where((r) => r.severity == _Severity.error).length;
    final int warnings =
        _resultados.where((r) => r.severity == _Severity.warning).length;
    final int infos =
        _resultados.where((r) => r.severity == _Severity.info).length;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Row(
          children: [
            const Text('Pre-Validador M3 (Zero-Ping-Pong)',
                style: TextStyle(
                    color: _text, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _gold)),
              child: const Text('1,500 reglas',
                  style: TextStyle(
                      color: _gold, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Escanea el borrador del pedimento contra reglas locales del Anexo 22 antes de enviarlo a la agencia aduanal.',
                style: TextStyle(color: _sub, fontSize: 14)),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _card,
                              border: Border.all(color: _border),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: TextField(
                              controller: _m3Controller,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(
                                  color: _gold,
                                  fontFamily: 'monospace',
                                  fontSize: 13),
                              decoration: InputDecoration(
                                hintText:
                                    'Pega el M3 aquí...\nEjemplo:\n801  26072026  A4  ED  A1  2400.00  USD  17.15  0000',
                                hintStyle: TextStyle(
                                    color: _sub.withValues(alpha: 0.7)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _isHoveringValidate = true),
                              onExit: (_) =>
                                  setState(() => _isHoveringValidate = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _isHoveringValidate
                                      ? [
                                          BoxShadow(
                                              color:
                                                  _gold.withValues(alpha: 0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4))
                                        ]
                                      : [],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _validarM3,
                                  icon:
                                      const Icon(Icons.play_arrow, color: _bg),
                                  label: const Text('Validar Pedimento',
                                      style: TextStyle(
                                          color: _bg,
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _gold,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: _cargarEjemplo,
                              style:
                                  TextButton.styleFrom(foregroundColor: _blue),
                              child: const Text('Cargar ejemplo',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _card,
                        border: Border.all(color: _border),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _Badge(label: '$errors errores', color: _red),
                                  const SizedBox(width: 8),
                                  _Badge(
                                      label: '$warnings advertencias',
                                      color: _gold),
                                  const SizedBox(width: 8),
                                  _Badge(
                                      label: '$infos informativos',
                                      color: _blue),
                                ],
                              ),
                              MouseRegion(
                                onEnter: (_) =>
                                    setState(() => _isHoveringCopy = true),
                                onExit: (_) =>
                                    setState(() => _isHoveringCopy = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            _isHoveringCopy ? _gold : _border),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextButton.icon(
                                    onPressed: _resultados.isNotEmpty
                                        ? _copiarReporte
                                        : null,
                                    icon: const Icon(Icons.copy, size: 16),
                                    label: const Text('Copiar reporte'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: _text,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: _border),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _validado && _resultados.isEmpty
                                ? const Center(
                                    child: Text('Sin resultados',
                                        style: TextStyle(color: _sub)))
                                : _validado && errors == 0 && warnings == 0
                                    ? const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: AppColors.green,
                                                size: 64),
                                            SizedBox(height: 16),
                                            Text(
                                                'Pedimento listo para transmisión',
                                                style: TextStyle(
                                                    color: AppColors.green,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _resultados.length,
                                        itemBuilder: (context, index) {
                                          final r = _resultados[index];
                                          Color c;
                                          IconData i;
                                          if (r.severity == _Severity.error) {
                                            c = _red;
                                            i = Icons.error;
                                          } else if (r.severity ==
                                              _Severity.warning) {
                                            c = _gold;
                                            i = Icons.warning_amber;
                                          } else {
                                            c = _blue;
                                            i = Icons.info_outline;
                                          }
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            decoration: BoxDecoration(
                                              color: _bg,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border:
                                                  Border.all(color: _border),
                                            ),
                                            child: ListTile(
                                              leading: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    color: c.withValues(
                                                        alpha: 0.1),
                                                    shape: BoxShape.circle),
                                                child:
                                                    Icon(i, color: c, size: 20),
                                              ),
                                              title: Text(r.mensaje,
                                                  style: const TextStyle(
                                                      color: _text,
                                                      fontSize: 14)),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4.0),
                                                child: Text(
                                                    '${r.codigo}${r.referencia != null ? ' - ${r.referencia}' : ''}',
                                                    style: const TextStyle(
                                                        color: _sub,
                                                        fontSize: 12)),
                                              ),
                                            ),
                                          );
                                        },
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
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
