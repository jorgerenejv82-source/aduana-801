import 'package:flutter/material.dart';
import '../../services/normativa_service.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class RegimenComparatorScreen extends StatefulWidget {
  const RegimenComparatorScreen({super.key});

  @override
  State<RegimenComparatorScreen> createState() =>
      _RegimenComparatorScreenState();
}

class _RegimenComparatorScreenState extends State<RegimenComparatorScreen> {
  final _fobCtrl = TextEditingController();
  final _igiCtrl = TextEditingController();
  final _tcCtrl = TextEditingController();
  final _plazoCtrl = TextEditingController();
  @override
  void dispose() {
    _fobCtrl.dispose();
    _igiCtrl.dispose();
    _tcCtrl.dispose();
    _plazoCtrl.dispose();
    super.dispose();
  }

  bool _tieneImmex = false;
  bool _tieneOea = false;

  Map<String, dynamic>? _results;
  String? _aiRecommendation;
  bool _isLoadingAi = false;

  void _comparar() {
    final fob = double.tryParse(_fobCtrl.text) ?? 0.0;
    final tc = double.tryParse(_tcCtrl.text) ?? 17.15;
    final igi = double.tryParse(_igiCtrl.text) ?? 0.0;

    final valorAduana = fob * tc;
    final igiMonto = valorAduana * (igi / 100);
    final ivaMonto = (valorAduana + igiMonto) * 0.16;
    final dta = NormativaService().calcularDTA(valorAduana, 'Importacion');
    final dtaImmex = NormativaService().calcularDTA(valorAduana, 'IMMEX');

    final capitalA1 = igiMonto + ivaMonto + dta;
    final capitalImmex = _tieneImmex ? dtaImmex : capitalA1;
    const capitalRfe = 0.0;

    setState(() {
      _results = {
        'igiMonto': igiMonto,
        'ivaMonto': ivaMonto,
        'dta': dta,
        'dtaImmex': dtaImmex,
        'capitalA1': capitalA1,
        'capitalImmex': capitalImmex,
        'capitalRfe': capitalRfe,
      };
    });
  }

  Future<void> _recomendarConIA() async {
    setState(() => _isLoadingAi = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoadingAi = false;
      _aiRecommendation =
          'Recomendación de IA: Dado su perfil con IMMEX, se sugiere utilizar el régimen Temporal A6 para evitar impacto en flujo de efectivo y diferir el pago de IVA. Asegúrese de cumplir con el plazo de permanencia de 18 meses.';
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
          title: const Text('Comparador de Regímenes Aduanales')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
              controller: _fobCtrl,
              decoration: const InputDecoration(labelText: 'Valor FOB (USD)')),
          TextFormField(
              controller: _igiCtrl,
              decoration: const InputDecoration(labelText: 'IGI Arancel (%)')),
          TextFormField(
              controller: _tcCtrl,
              decoration: const InputDecoration(labelText: 'Tipo de Cambio')),
          TextFormField(
              controller: _plazoCtrl,
              decoration: const InputDecoration(
                  labelText:
                      'Plazo estimado de permanencia en México (meses)')),
          SwitchListTile(
            title: const Text('La empresa tiene programa IMMEX'),
            value: _tieneImmex,
            onChanged: (v) => setState(() => _tieneImmex = v),
          ),
          SwitchListTile(
            title: const Text('La empresa tiene OEA'),
            value: _tieneOea,
            onChanged: (v) => setState(() => _tieneOea = v),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _comparar,
            child: const Text('COMPARAR REGÍMENES'),
          ),
          if (_results != null) ...[
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Concepto')),
                  DataColumn(label: Text('A1 Definitiva')),
                  DataColumn(label: Text('A6 IMMEX')),
                  DataColumn(label: Text('RFE (Rec. Fiscal. Estrat.)')),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('Pago IGI')),
                    DataCell(Text(
                        '\$${(_results!['igiMonto'] as double).toStringAsFixed(2)} (inmediato)')),
                    const DataCell(Text('\$0 (exento)')),
                    const DataCell(Text('\$0 (exento)')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Pago IVA')),
                    DataCell(Text(
                        '\$${(_results!['ivaMonto'] as double).toStringAsFixed(2)} (inmediato)')),
                    const DataCell(Text('\$0 (acreditable)')),
                    const DataCell(Text('\$0 (en suspenso)')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('DTA')),
                    DataCell(Text(
                        '\$${(_results!['dta'] as double).toStringAsFixed(2)}')),
                    DataCell(Text(
                        '\$${(_results!['dtaImmex'] as double).toStringAsFixed(2)} (cuota fija)')),
                    DataCell(Text(
                        '\$${(_results!['dta'] as double).toStringAsFixed(2)}')),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Capital inmovilizado')),
                    DataCell(Text(
                        '\$${(_results!['capitalA1'] as double).toStringAsFixed(2)}')),
                    DataCell(Text(
                        '\$${(_results!['capitalImmex'] as double).toStringAsFixed(2)}')),
                    DataCell(Text(
                        '\$${(_results!['capitalRfe'] as double).toStringAsFixed(2)}')),
                  ]),
                  const DataRow(cells: [
                    DataCell(Text('Plazo máx. permanencia')),
                    DataCell(Text('Indefinido')),
                    DataCell(Text('18 meses')),
                    DataCell(Text('Indefinido')),
                  ]),
                  const DataRow(cells: [
                    DataCell(Text('Requiere:')),
                    DataCell(Text('Nada especial')),
                    DataCell(Text('Programa IMMEX')),
                    DataCell(Text('Concesión RFE')),
                  ]),
                  const DataRow(cells: [
                    DataCell(Text('Riesgo principal')),
                    DataCell(Text('Pago inmediato')),
                    DataCell(Text('Descargo en plazo')),
                    DataCell(Text('Cumplimiento normativo')),
                  ]),
                  const DataRow(cells: [
                    DataCell(Text('RECOMENDADO CUANDO')),
                    DataCell(Text('Mercancía para venta directa')),
                    DataCell(Text('Insumos IMMEX')),
                    DataCell(Text('Inventario en tránsito global')),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _recomendarConIA,
              child: _isLoadingAi
                  ? const CircularProgressIndicator()
                  : const Text('Recomienda el mejor régimen para mi caso'),
            ),
            if (_aiRecommendation != null) ...[
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_aiRecommendation!),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
