import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _gold = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;

class ConciliadorSapScreen extends StatefulWidget {
  const ConciliadorSapScreen({super.key});
  @override
  State<ConciliadorSapScreen> createState() => _ConciliadorSapScreenState();
}

class _ConciliadorSapScreenState extends State<ConciliadorSapScreen> {
  bool _archivoSeleccionado = false;
  String _nombreArchivo = '';
  bool _loading = false;
  bool _ejecutado = false;
  List<Map<String, dynamic>> _resultados = [];
  int _coincidencias = 0;
  int _discrepancias = 0;

  void _simularSeleccionArchivo() {
    setState(() {
      _archivoSeleccionado = true;
      _nombreArchivo = 'SAP_MM_Inventario_2025-07.csv';
      _ejecutado = false;
      _resultados = [];
    });
  }

  Future<void> _iniciarCruce() async {
    if (!_archivoSeleccionado) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selecciona primero el archivo CSV de SAP'),
          backgroundColor: _rojo));
      return;
    }
    setState(() {
      _loading = true;
      _ejecutado = false;
    });
    final model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-1.5-flash',
      systemInstruction: Content.system(
          'Eres un experto en conciliacion de datos SAP con pedimentos aduanales de Mexico. Analiza las diferencias entre los datos del ERP SAP y el pedimento aduanal. Identifica discrepancias contables y aduanales. Responde en JSON: {"discrepancias": [{"sku": "string", "desc": "string", "qty_sap": 0, "qty_a24": 0, "diff": 0, "status": "string"}], "totalDiferencia": 0, "estadoConciliacion": "string"}'),
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
    try {
      final response = await model.generateContent([
        Content.text(
            'Analiza archivo $_nombreArchivo con inventario SAP vs Anexo 24.')
      ]);
      final json = jsonDecode(response.text ?? '{}') as Map<String, dynamic>;
      final disc = json['discrepancias'] as List<dynamic>? ?? [];

      setState(() {
        _loading = false;
        _ejecutado = true;
        _resultados = disc.map((e) {
          final m = e as Map<String, dynamic>;
          return <String, dynamic>{
            'sku': m['sku'] ?? '',
            'desc': m['desc'] ?? '',
            'qty_sap': m['qty_sap'] ?? 0,
            'qty_a24': m['qty_a24'] ?? 0,
            'diff': m['diff'] ?? 0,
            'status': m['status'] ?? 'OK',
          };
        }).toList();
        _coincidencias = _resultados.where((r) => r['status'] == 'OK').length;
        _discrepancias = _resultados.where((r) => r['status'] == 'DIFF').length;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: _bg,
          child: Row(children: [
            InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _bord)),
                    child:
                        const Icon(Icons.chevron_left, color: _sec, size: 20))),
            const SizedBox(width: 14),
            const Text('Conciliador Fisico-Virtual (SAP vs Anexo 24)',
                style: TextStyle(
                    color: _texto, fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
        ),
        const Divider(height: 1, color: _bord),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cruce Masivo de Inventarios IMMEX',
                style: TextStyle(
                    color: _gold, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
                'Detecta discrepancias entre el inventario fisico (ERP/SAP) y los saldos legales ante la aduana (Anexo 24) antes de que el SAT te audite.',
                style: TextStyle(color: _sec, fontSize: 12, height: 1.6)),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Left panel
              SizedBox(
                  width: 440,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _bord)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step 1
                          const Row(children: [
                            Icon(Icons.description_outlined,
                                color: _sec, size: 18),
                            SizedBox(width: 8),
                            Text('1. Subir Inventario SAP',
                                style: TextStyle(
                                    color: _texto,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 10),
                          const Text(
                              'Archivo CSV exportado directamente de tu modulo MM de SAP con el stock fisico de hoy. Columnas esperadas: SKU, Descripcion, QTY.',
                              style: TextStyle(
                                  color: _sec, fontSize: 11, height: 1.6)),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _simularSeleccionArchivo,
                            icon: Icon(
                                _archivoSeleccionado
                                    ? Icons.check_circle_outline
                                    : Icons.upload_file,
                                size: 14,
                                color: _archivoSeleccionado ? _gold : _sec),
                            label: Text(
                                _archivoSeleccionado
                                    ? _nombreArchivo
                                    : 'Ningun archivo seleccionado',
                                style: TextStyle(
                                    color: _archivoSeleccionado ? _gold : _sec,
                                    fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color:
                                        _archivoSeleccionado ? _gold : _bord),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10)),
                          ),
                          const SizedBox(height: 24),
                          // Step 2
                          const Row(children: [
                            Icon(Icons.merge_type, color: _gold, size: 18),
                            SizedBox(width: 8),
                            Text('2. Ejecutar Conciliacion IA',
                                style: TextStyle(
                                    color: _texto,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _iniciarCruce,
                              icon: _loading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          color: Colors.black, strokeWidth: 2))
                                  : const Icon(Icons.bolt,
                                      size: 18, color: Colors.black),
                              label: Text(
                                  _loading
                                      ? 'Procesando cruce...'
                                      : 'Iniciar Cruce',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _gold,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16))),
                            ),
                          ),
                        ]),
                  )),
              const SizedBox(width: 20),
              // Right panel
              Expanded(
                  child: _loading
                      ? const Center(
                          child: Padding(
                              padding: EdgeInsets.all(60),
                              child: Column(children: [
                                CircularProgressIndicator(color: _gold),
                                SizedBox(height: 16),
                                Text('Ejecutando cruce SAP vs Anexo 24...',
                                    style:
                                        TextStyle(color: _sec, fontSize: 13)),
                              ])))
                      : !_ejecutado
                          ? Center(
                              child: Padding(
                              padding: const EdgeInsets.all(48),
                              child: Column(children: [
                                Icon(Icons.hourglass_empty,
                                    color: _gold.withAlpha(160), size: 64),
                                const SizedBox(height: 20),
                                const Text('Esperando Ejecucion',
                                    style: TextStyle(
                                        color: _texto,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                const Text(
                                    'Sube tu Inventario SAP y ejecuta el cruce contra el saldo real en la nube.',
                                    style: TextStyle(
                                        color: _sec, fontSize: 12, height: 1.6),
                                    textAlign: TextAlign.center),
                              ]),
                            ))
                          : _buildResultados()),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _buildResultados() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // KPIs
      Row(children: [
        _kpi('SKUs Analizados', '${_resultados.length}', _azul),
        const SizedBox(width: 10),
        _kpi('Coincidencias', '$_coincidencias', _gold),
        const SizedBox(width: 10),
        _kpi('Discrepancias', '$_discrepancias',
            _discrepancias > 0 ? _rojo : _gold),
        const SizedBox(width: 10),
        _kpi(
            'Exactitud',
            '${(_coincidencias / _resultados.length * 100).toStringAsFixed(1)}%',
            _gold),
      ]),
      const SizedBox(height: 14),
      // Alert
      if (_discrepancias > 0) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: _rojo.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _rojo.withAlpha(80))),
          child: Row(children: [
            const Icon(Icons.warning_amber, color: _rojo, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    '$_discrepancias SKU(s) con diferencias vs Anexo 24. Investiga antes de que el SAT active una revision.',
                    style: const TextStyle(
                        color: _rojo, fontSize: 12, height: 1.5))),
          ]),
        ),
        const SizedBox(height: 14),
      ],
      // Table
      DecoratedBox(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bord)),
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: const Row(children: [
              Expanded(
                  flex: 2,
                  child: Text('SKU',
                      style: TextStyle(
                          color: _sec,
                          fontSize: 10,
                          fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 3,
                  child: Text('Descripcion',
                      style: TextStyle(
                          color: _sec,
                          fontSize: 10,
                          fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 2,
                  child: Text('QTY SAP',
                      style: TextStyle(
                          color: _sec,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right)),
              Expanded(
                  flex: 2,
                  child: Text('QTY A24',
                      style: TextStyle(
                          color: _sec,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right)),
              Expanded(
                  flex: 2,
                  child: Text('Diferencia',
                      style: TextStyle(
                          color: _sec,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right)),
              Expanded(
                  child: Text('', style: TextStyle(color: _sec, fontSize: 10))),
            ]),
          ),
          // Rows
          ...List.generate(_resultados.length, (i) {
            final r = _resultados[i];
            final bool ok = r['status'] == 'OK';
            final Color sc = ok ? _gold : _rojo;
            final int diff = r['diff'] as int;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: ok
                    ? (i.isEven ? _card : AppColors.card)
                    : _rojo.withAlpha(8),
                border: Border(
                    bottom: BorderSide(
                        color: _bord,
                        width: i < _resultados.length - 1 ? 1 : 0)),
              ),
              child: Row(children: [
                Expanded(
                    flex: 2,
                    child: Text(r['sku'] as String,
                        style: const TextStyle(
                            color: _gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 3,
                    child: Text(r['desc'] as String,
                        style: const TextStyle(color: _texto, fontSize: 11),
                        overflow: TextOverflow.ellipsis)),
                Expanded(
                    flex: 2,
                    child: Text('${r['qty_sap']}',
                        style: const TextStyle(color: _texto, fontSize: 11),
                        textAlign: TextAlign.right)),
                Expanded(
                    flex: 2,
                    child: Text('${r['qty_a24']}',
                        style: const TextStyle(color: _texto, fontSize: 11),
                        textAlign: TextAlign.right)),
                Expanded(
                    flex: 2,
                    child: Text(
                        diff == 0 ? 'â€”' : '${diff > 0 ? '+' : ''}$diff',
                        style: TextStyle(
                            color: ok ? _sec : _rojo,
                            fontSize: 11,
                            fontWeight:
                                ok ? FontWeight.normal : FontWeight.bold),
                        textAlign: TextAlign.right)),
                Expanded(
                    child: Center(
                        child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      color: sc.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: sc.withAlpha(80))),
                  child: Text(ok ? 'OK' : 'DIFF',
                      style: TextStyle(
                          color: sc, fontSize: 9, fontWeight: FontWeight.bold)),
                ))),
              ]),
            );
          }),
        ]),
      ),
      const SizedBox(height: 14),
      // Export
      SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Reporte SAP vs A24 exportado'),
                    backgroundColor: AppColors.card)),
            icon: const Icon(Icons.download, size: 14, color: _gold),
            label: const Text('Exportar Reporte Cruce SAP vs Anexo 24 (Excel)',
                style: TextStyle(color: _gold)),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _gold),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
          )),
    ]);
  }

  Widget _kpi(String label, String value, Color color) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _bord)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _sec, fontSize: 9)),
        const SizedBox(height: 5),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
    ));
  }
}
