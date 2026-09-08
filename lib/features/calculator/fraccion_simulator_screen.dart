import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class FraccionSimulatorScreen extends StatefulWidget {
  const FraccionSimulatorScreen({super.key});

  @override
  State<FraccionSimulatorScreen> createState() =>
      _FraccionSimulatorScreenState();
}

class _FraccionSimulatorScreenState extends State<FraccionSimulatorScreen> {
  final _actualFraccionCtrl = TextEditingController();
  final _actualIgiCtrl = TextEditingController();
  final _propuestaFraccionCtrl = TextEditingController();
  final _propuestaIgiCtrl = TextEditingController();
  final _fobCtrl = TextEditingController();
  final _tcCtrl = TextEditingController(text: '17.15');
  final _paisCtrl = TextEditingController();
  final _volumenCtrl = TextEditingController();

  double? _igiActualMonto;
  double? _igiPropuestoMonto;

  @override
  void dispose() {
    _actualFraccionCtrl.dispose();
    _actualIgiCtrl.dispose();
    _propuestaFraccionCtrl.dispose();
    _propuestaIgiCtrl.dispose();
    _fobCtrl.dispose();
    _tcCtrl.dispose();
    _paisCtrl.dispose();
    _volumenCtrl.dispose();
    super.dispose();
  }

  double? _diferencia;
  double? _ahorroAnual;
  String? _aiResponse;
  bool _isLoadingAi = false;

  void _simular() {
    final fob = double.tryParse(_fobCtrl.text) ?? 0.0;
    final tc = double.tryParse(_tcCtrl.text) ?? 17.15;
    final arancelActual = double.tryParse(_actualIgiCtrl.text) ?? 0.0;
    final arancelPropuesto = double.tryParse(_propuestaIgiCtrl.text) ?? 0.0;

    final valorAduana = fob * tc;
    final igiActual = valorAduana * (arancelActual / 100);
    final igiPropuesto = valorAduana * (arancelPropuesto / 100);
    final diferencia = igiActual - igiPropuesto;
    final ahorro12meses = diferencia * 12;

    setState(() {
      _igiActualMonto = igiActual;
      _igiPropuestoMonto = igiPropuesto;
      _diferencia = diferencia;
      _ahorroAnual = ahorro12meses;
    });

    _saveSimulation();
  }

  Future<void> _saveSimulation() async {
    try {
      await FirebaseFirestore.instance.collection('simulaciones_fraccion').add({
        'uid': 'user_id', // mock
        'fraccionActual': _actualFraccionCtrl.text,
        'igiActual': _actualIgiCtrl.text,
        'fraccionPropuesta': _propuestaFraccionCtrl.text,
        'igiPropuesta': _propuestaIgiCtrl.text,
        'fob': _fobCtrl.text,
        'tc': _tcCtrl.text,
        'pais': _paisCtrl.text,
        'volumen': _volumenCtrl.text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving simulation: $e');
    }
  }

  Future<void> _analizarConIA() async {
    setState(() => _isLoadingAi = true);
    // Simulated Gemini call
    await Future<void>.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoadingAi = false;
      _aiResponse =
          'Análisis de IA: Legalmente viable siempre que la mercancía cumpla con las Notas Explicativas. No se detectan cuotas compensatorias para el país indicado.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: const Text('Simulador de Cambio de Fracción')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
              'Analiza el impacto fiscal de clasificar tu mercancía en una fracción distinta antes de negociar la factura con tu proveedor.',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                      controller: _actualFraccionCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Fracción Actual'))),
              const SizedBox(width: 10),
              Expanded(
                  child: TextFormField(
                      controller: _actualIgiCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Arancel IGI Actual (%)'))),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                      controller: _propuestaFraccionCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Fracción Propuesta'))),
              const SizedBox(width: 10),
              Expanded(
                  child: TextFormField(
                      controller: _propuestaIgiCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Arancel IGI Propuesto (%)'))),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                      controller: _fobCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Valor FOB (USD)'))),
              const SizedBox(width: 10),
              Expanded(
                  child: TextFormField(
                      controller: _tcCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Tipo de Cambio (MXN/USD)'))),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                      controller: _paisCtrl,
                      decoration:
                          const InputDecoration(labelText: 'País de Origen'))),
              const SizedBox(width: 10),
              Expanded(
                  child: TextFormField(
                      controller: _volumenCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Volumen mensual (unidades o valor)'))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _simular,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('SIMULAR IMPACTO',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _analizarConIA,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: _isLoadingAi
                      ? const CircularProgressIndicator()
                      : const Text('🤖 Analizar con IA',
                          style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
          if (_diferencia != null) ...[
            const SizedBox(height: 20),
            DataTable(
              columns: const [
                DataColumn(label: Text('')),
                DataColumn(label: Text('Fracción Actual')),
                DataColumn(label: Text('Fracción Propuesta')),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('Fracción')),
                  DataCell(Text(_actualFraccionCtrl.text)),
                  DataCell(Text(_propuestaFraccionCtrl.text)),
                ]),
                DataRow(cells: [
                  const DataCell(Text('IGI %')),
                  DataCell(Text('${_actualIgiCtrl.text}%')),
                  DataCell(Text('${_propuestaIgiCtrl.text}%')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('IGI por operación')),
                  DataCell(Text('\$${_igiActualMonto?.toStringAsFixed(2)}')),
                  DataCell(Text('\$${_igiPropuestoMonto?.toStringAsFixed(2)}')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Proyección 12 meses')),
                  DataCell(
                      Text('\$${(_igiActualMonto! * 12).toStringAsFixed(2)}')),
                  DataCell(Text(
                      '\$${(_igiPropuestoMonto! * 12).toStringAsFixed(2)}')),
                ]),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              color: _ahorroAnual! >= 0 ? Colors.amber : Colors.red,
              child: Text(
                _ahorroAnual! >= 0
                    ? 'Ahorro anual estimado: \$${_ahorroAnual!.toStringAsFixed(2)} MXN'
                    : 'Costo adicional: \$${_ahorroAnual!.abs().toStringAsFixed(2)} MXN',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (_aiResponse != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_aiResponse!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
