import 'package:flutter/material.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class RoiCalculatorScreen extends StatefulWidget {
  const RoiCalculatorScreen({super.key});

  @override
  State<RoiCalculatorScreen> createState() => _RoiCalculatorScreenState();
}

class _RoiCalculatorScreenState extends State<RoiCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Section 1: Inversión en Importación
  double _fob = 0;
  double _tc = 17.15;
  double _impuestos = 0;
  double _logistica = 0;
  double _almacenajeManiobras = 0;
  double _extras = 0;

  // Section 2: Ingresos por Venta
  double _precioVenta = 0;
  double _volumen = 0;
  double _plazo = 0;
  double _costoVenta = 0;

  // Section 3: Costos Operativos
  double _almacenamientoMensual = 0;
  double _intereses = 0;
  bool _tieneDrawback = false;
  double _montoDrawback = 0;

  // Results
  double _roi = 0;
  double _utilidadBruta = 0;
  double _paybackMeses = 0;
  double _margenBruto = 0;
  double _breakEven = 0;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final fobMxn = _fob * _tc;
    final totalInversion =
        fobMxn + _impuestos + _logistica + _almacenajeManiobras + _extras;
    final costoCapital = totalInversion * (_intereses / 100) * (_plazo / 12);
    final inversionTotal = totalInversion + costoCapital;

    final ingresosBrutos = _precioVenta * _volumen;
    final ingresosNetos = ingresosBrutos - _costoVenta;

    final almacenamientoTotal = _almacenamientoMensual * _plazo;
    final drawback = _tieneDrawback ? _montoDrawback : 0.0;

    final utilidadBruta =
        ingresosNetos - inversionTotal - almacenamientoTotal + drawback;

    setState(() {
      _utilidadBruta = utilidadBruta;
      _roi = inversionTotal > 0 ? (utilidadBruta / inversionTotal) * 100 : 0;
      _paybackMeses = (ingresosNetos > 0 && _plazo > 0)
          ? inversionTotal / (ingresosNetos / _plazo)
          : 0;
      _margenBruto =
          ingresosNetos > 0 ? (utilidadBruta / ingresosNetos) * 100 : 0;

      final gananciaUnitaria =
          _precioVenta - (_costoVenta / (_volumen > 0 ? _volumen : 1));
      _breakEven = gananciaUnitaria > 0
          ? (inversionTotal - drawback + almacenamientoTotal) / gananciaUnitaria
          : 0;
    });
  }

  Widget _buildTextField(
      String label, String? hint, void Function(String?) onSaved,
      {String initialValue = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          labelStyle: const TextStyle(color: AppColors.sub),
        ),
        style: const TextStyle(color: AppColors.text),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onSaved: onSaved,
        validator: (v) => v != null && double.tryParse(v) != null
            ? null
            : 'Ingrese un valor numérico',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Calculadora de ROI de Importación',
            style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.bg,
        iconTheme: const IconThemeData(color: AppColors.text),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        '¿Vale la pena este negocio? Calcula el retorno sobre tu inversión de comercio exterior.',
                        style: TextStyle(color: AppColors.sub, fontSize: 16)),
                    const SizedBox(height: 24),
                    const Text('Inversión en Importación',
                        style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTextField('Costo FOB total (USD)', null,
                        (v) => _fob = double.parse(v ?? '0')),
                    _buildTextField('Tipo de Cambio (MXN/USD)', null,
                        (v) => _tc = double.parse(v ?? '17.15'),
                        initialValue: '17.15'),
                    _buildTextField('IGI + Impuestos pagados (MXN)', null,
                        (v) => _impuestos = double.parse(v ?? '0')),
                    _buildTextField('Flete + Seguro + Agente (MXN)', null,
                        (v) => _logistica = double.parse(v ?? '0')),
                    _buildTextField('Almacenaje + Maniobras (MXN)', null,
                        (v) => _almacenajeManiobras = double.parse(v ?? '0')),
                    _buildTextField(
                        'Costo adicional (PRV, Previo, permisos) (MXN)',
                        null,
                        (v) => _extras = double.parse(v ?? '0')),
                    const SizedBox(height: 24),
                    const Text('Ingresos por Venta',
                        style: TextStyle(
                            color: AppColors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTextField('Precio de venta unitario (MXN)', null,
                        (v) => _precioVenta = double.parse(v ?? '0')),
                    _buildTextField('Volumen de venta estimado (unidades)',
                        null, (v) => _volumen = double.parse(v ?? '0')),
                    _buildTextField('Plazo de venta estimado (meses)', null,
                        (v) => _plazo = double.parse(v ?? '0')),
                    _buildTextField('Costo de venta / comisiones (MXN)', null,
                        (v) => _costoVenta = double.parse(v ?? '0')),
                    const SizedBox(height: 24),
                    const Text('Costos Operativos',
                        style: TextStyle(
                            color: AppColors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Costo de almacenamiento mensual (MXN)',
                        null,
                        (v) => _almacenamientoMensual = double.parse(v ?? '0')),
                    _buildTextField(
                        'Costo financiero / intereses (%)',
                        '12% anual si financias',
                        (v) => _intereses = double.parse(v ?? '0')),
                    SwitchListTile(
                      title: const Text(
                          'Aplica Duty Drawback (recuperación de impuestos)',
                          style: TextStyle(color: AppColors.text)),
                      value: _tieneDrawback,
                      onChanged: (v) => setState(() => _tieneDrawback = v),
                      activeThumbColor: AppColors.gold,
                    ),
                    if (_tieneDrawback)
                      _buildTextField('Monto estimado de Drawback (MXN)', null,
                          (v) => _montoDrawback = double.parse(v ?? '0')),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          minimumSize: const Size(double.infinity, 50)),
                      onPressed: _calculate,
                      child: const Text('Calcular ROI',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.bg2,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resultados del Análisis',
                      style: TextStyle(
                          color: AppColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildResultRow(
                      'ROI', '${_roi.toStringAsFixed(2)}%', _getRoiColor()),
                  const SizedBox(height: 16),
                  _buildResultRow(
                      'Utilidad Bruta',
                      '\$${_utilidadBruta.toStringAsFixed(2)} MXN',
                      AppColors.text),
                  const SizedBox(height: 16),
                  _buildResultRow(
                      'Payback',
                      '${_paybackMeses.toStringAsFixed(1)} meses',
                      AppColors.text),
                  const SizedBox(height: 16),
                  _buildResultRow('Margen Bruto',
                      '${_margenBruto.toStringAsFixed(2)}%', AppColors.text),
                  const SizedBox(height: 16),
                  _buildResultRow('Break-even', '${_breakEven.ceil()} unidades',
                      AppColors.text),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Text(_getSemaforoEmoji(),
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Text(_getSemaforoText(),
                            style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: AppColors.gold),
                            SizedBox(width: 8),
                            Text('Gemini CFO',
                                style: TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Análisis AI generado dinámicamente...',
                          style: TextStyle(color: AppColors.text, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        minimumSize: const Size(double.infinity, 50)),
                    onPressed: () {
                      // Save to Firestore
                    },
                    child: const Text('Guardar Análisis',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoiColor() {
    if (_roi > 20) return AppColors.green;
    if (_roi > 0) return AppColors.gold;
    return AppColors.red;
  }

  String _getSemaforoEmoji() {
    if (_roi > 30) return '🟢';
    if (_roi > 10) return '🟡';
    if (_roi >= 0) return '🔴';
    return '⚪';
  }

  String _getSemaforoText() {
    if (_roi > 30) return 'Excelente';
    if (_roi > 10) return 'Aceptable';
    if (_roi >= 0) return 'Riesgoso';
    return 'No rentable';
  }

  Widget _buildResultRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.sub, fontSize: 16)),
        Text(value,
            style: TextStyle(
                color: valueColor, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
