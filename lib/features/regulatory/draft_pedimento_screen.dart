import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class _Partida {
  String fraccion = '';
  String descripcion = '';
  double cantidad = 0;
  String unidad = 'PZA';
  double valorUnitario = 0;
  double tasaIGI = 0;
  double tasaIVA = 16;
}

class DraftPedimentoScreen extends StatefulWidget {
  const DraftPedimentoScreen({super.key});

  @override
  State<DraftPedimentoScreen> createState() => _DraftPedimentoScreenState();
}

class _DraftPedimentoScreenState extends State<DraftPedimentoScreen> {
  final _rfcImportadorCtrl = TextEditingController();
  final _rfcExportadorCtrl = TextEditingController();
  final _patenteCtrl = TextEditingController();
  final _valorFacturaCtrl = TextEditingController();
  final _fleteCtrl = TextEditingController();
  final _seguroCtrl = TextEditingController();
  final _tipoCambioCtrl = TextEditingController(text: '1.0');

  String _aduana = '801';
  String _regimen = 'IM A4';
  String _moneda = 'USD';
  final List<_Partida> _partidas = [];
  String _m3Generado = '';

  @override
  void dispose() {
    _rfcImportadorCtrl.dispose();
    _rfcExportadorCtrl.dispose();
    _patenteCtrl.dispose();
    _valorFacturaCtrl.dispose();
    _fleteCtrl.dispose();
    _seguroCtrl.dispose();
    _tipoCambioCtrl.dispose();
    super.dispose();
  }

  void _addPartida() {
    setState(() => _partidas.add(_Partida()));
  }

  void _generarDraftM3() {
    double valorFactura = double.tryParse(_valorFacturaCtrl.text) ?? 0;
    double flete = double.tryParse(_fleteCtrl.text) ?? 0;
    double seguro = double.tryParse(_seguroCtrl.text) ?? 0;
    double tc = double.tryParse(_tipoCambioCtrl.text) ?? 1.0;

    double valorAduana = valorFactura + flete + seguro;
    double dta = max(422.0, valorAduana * tc * 0.008);
    
    double igi = 0;
    for (var p in _partidas) {
      double prop = (p.cantidad * p.valorUnitario) / (valorFactura > 0 ? valorFactura : 1);
      double vaPartida = valorAduana * prop;
      double tasa = _regimen.contains('IT') ? 0 : p.tasaIGI / 100;
      igi += vaPartida * tc * tasa;
    }

    double baseIva = (valorAduana * tc) + igi + dta;
    double iva = _regimen.contains('EX') ? 0 : baseIva * 0.16;
    double total = igi + iva + dta;

    String identificadores = '';
    if (_regimen == 'IM A4') {
      identificadores = 'PA=${_patenteCtrl.text} | AI=1 | MN=PENDIENTE';
    } else if (_regimen.contains('IT')) {
      identificadores = 'EP=PROG_IMMEX | FR=${_partidas.isNotEmpty ? _partidas[0].fraccion : ''} | SP=1 | PA=${_patenteCtrl.text} | AI=1';
    } else if (_regimen.contains('EX')) {
      identificadores = 'PA=${_patenteCtrl.text} | VM=$valorFactura';
    }

    final draft = '''------------------------------------------
DRAFT M3 - Generado por Aduanas 801
Fecha: ${DateTime.now()}
------------------------------------------
ENCABEZADO:
Régimen: $_regimen
RFC Importador: ${_rfcImportadorCtrl.text}
Aduana: $_aduana
Fecha Pago: ${DateFormat('ddMMyyyy').format(DateTime.now())}
Valor Total USD: $valorFactura
Tipo Cambio: $tc

PARTIDAS:
${_partidas.map((p) => '  Fracción: ${p.fraccion} | Desc: ${p.descripcion} | Cant: ${p.cantidad} ${p.unidad} | Val: \$${p.valorUnitario} | IGI: ${p.tasaIGI}% | IVA: ${p.tasaIVA}%').join('\n')}

CARGOS:
Flete: \$ $flete USD
Seguro: \$ $seguro USD
Valor en Aduana: \$ $valorAduana USD

IMPUESTOS CALCULADOS:
IGI: \$ ${igi.toStringAsFixed(2)} MXN
IVA: \$ ${iva.toStringAsFixed(2)} MXN (16%)
DTA: \$ ${dta.toStringAsFixed(2)} MXN (0.8% min \$422 MXN)
TOTAL A PAGAR: \$ ${total.toStringAsFixed(2)} MXN

IDENTIFICADORES SUGERIDOS:
$identificadores
------------------------------------------''';

    setState(() {
      _m3Generado = draft;
    });
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.card,
        labelStyle: const TextStyle(color: AppColors.sub),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text('Draft-Pedimento Auto-Generator', style: TextStyle(color: AppColors.gold)),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Integración PDF requiere configuración. Use el formulario manual.')));
              },
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold, width: 2, style: BorderStyle.none),
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.card,
                ),
                child: const Column(
                  children: [
                    Icon(Icons.upload_file, color: AppColors.gold, size: 48),
                    SizedBox(height: 16),
                    Text('Selecciona Factura', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Haz clic para subir y generar borrador M3', style: TextStyle(color: AppColors.sub)),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('-- O ingresa los datos manualmente --', style: TextStyle(color: AppColors.sub))),
            ),
            Row(
              children: [
                Expanded(child: _buildField('RFC Importador *', _rfcImportadorCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('RFC Exportador', _rfcExportadorCtrl)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildField('Patente Aduanal', _patenteCtrl)),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _aduana,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(filled: true, fillColor: AppColors.card, labelText: 'Número de Aduana', labelStyle: const TextStyle(color: AppColors.sub), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                    items: const [
                      DropdownMenuItem(value: '800', child: Text('800 - Nuevo Laredo')),
                      DropdownMenuItem(value: '801', child: Text('801 - Monterrey')),
                      DropdownMenuItem(value: '240', child: Text('240 - Laredo/Colombia')),
                      DropdownMenuItem(value: '010', child: Text('010 - Tijuana')),
                      DropdownMenuItem(value: '121', child: Text('121 - Manzanillo')),
                      DropdownMenuItem(value: '141', child: Text('141 - Veracruz')),
                      DropdownMenuItem(value: '720', child: Text('720 - CD Juárez')),
                    ],
                    onChanged: (v) => setState(() => _aduana = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _regimen,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(filled: true, fillColor: AppColors.card, labelText: 'Régimen', labelStyle: const TextStyle(color: AppColors.sub), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                    items: const [
                      DropdownMenuItem(value: 'IM A4', child: Text('IM A4 - Importación Definitiva')),
                      DropdownMenuItem(value: 'IM IT', child: Text('IM IT - Importación Temporal IMMEX')),
                      DropdownMenuItem(value: 'EX V1', child: Text('EX V1 - Exportación Definitiva')),
                      DropdownMenuItem(value: 'EX A2', child: Text('EX A2 - Exportación Virtual IMMEX')),
                    ],
                    onChanged: (v) => setState(() => _regimen = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _moneda,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(filled: true, fillColor: AppColors.card, labelText: 'Moneda', labelStyle: const TextStyle(color: AppColors.sub), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      DropdownMenuItem(value: 'MXN', child: Text('MXN')),
                      DropdownMenuItem(value: 'CAD', child: Text('CAD')),
                    ],
                    onChanged: (v) => setState(() => _moneda = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Tipo de Cambio', _tipoCambioCtrl)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildField('Valor Factura', _valorFacturaCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Flete (USD)', _fleteCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Seguro (USD)', _seguroCtrl)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('PARTIDAS', style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(onPressed: _addPartida, icon: const Icon(Icons.add), label: const Text('Agregar')),
              ],
            ),
            ..._partidas.asMap().entries.map((entry) {
              int idx = entry.key;
              _Partida p = entry.value;
              return Card(
                color: AppColors.card,
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: TextFormField(initialValue: p.fraccion, onChanged: (v) => p.fraccion = v, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Fracción LIGIE', labelStyle: TextStyle(color: AppColors.sub)))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(initialValue: p.descripcion, onChanged: (v) => p.descripcion = v, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Descripción', labelStyle: TextStyle(color: AppColors.sub)))),
                          IconButton(icon: const Icon(Icons.delete, color: AppColors.red), onPressed: () => setState(() => _partidas.removeAt(idx))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: TextFormField(initialValue: p.cantidad.toString(), onChanged: (v) => p.cantidad = double.tryParse(v) ?? 0, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Cantidad', labelStyle: TextStyle(color: AppColors.sub)))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(initialValue: p.unidad, onChanged: (v) => p.unidad = v, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Unidad', labelStyle: TextStyle(color: AppColors.sub)))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(initialValue: p.valorUnitario.toString(), onChanged: (v) => p.valorUnitario = double.tryParse(v) ?? 0, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Valor Unitario', labelStyle: TextStyle(color: AppColors.sub)))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(initialValue: p.tasaIGI.toString(), onChanged: (v) => p.tasaIGI = double.tryParse(v) ?? 0, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Tasa IGI%', labelStyle: TextStyle(color: AppColors.sub)))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(initialValue: p.tasaIVA.toString(), onChanged: (v) => p.tasaIVA = double.tryParse(v) ?? 0, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Tasa IVA%', labelStyle: TextStyle(color: AppColors.sub)))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _generarDraftM3,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.bg,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text('? Generar Borrador M3'),
            ),
            if (_m3Generado.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(_m3Generado, style: const TextStyle(color: Colors.green, fontFamily: 'monospace')),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _m3Generado));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado')));
                    },
                    icon: const Icon(Icons.copy, color: AppColors.sub),
                    label: const Text('?? Copiar M3', style: TextStyle(color: AppColors.sub)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enviando a Pre-Validador...')));
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('? Enviar a Pre-Validador'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.bg),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}

