import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

// Theme colors
const Color _bg = Color(0xFF0F172A);
const Color _card = Color(0xFF1E293B);
const Color _card2 = Color(0xFF334155);
const Color _gold = Color(0xFFF59E0B);
const Color _green = AppColors.green;
const Color _red = AppColors.red;
const Color _text = Color(0xFFF8FAFC);
const Color _sub = Color(0xFF94A3B8);
const Color _border = Color(0xFF475569);
const Color _blue = Color(0xFF3B82F6);

class ConciliadorVisorBScreen extends StatefulWidget {
  const ConciliadorVisorBScreen({super.key});

  @override
  State<ConciliadorVisorBScreen> createState() =>
      _ConciliadorVisorBScreenState();
}

class _ConciliadorVisorBScreenState extends State<ConciliadorVisorBScreen> {
  bool _saaiLoaded = false;
  bool _erpLoaded = false;
  bool _running = false;
  bool _done = false;
  bool _aiLoading = false;
  String _aiAnalysis = '';
  int _matches = 0;
  int _diffs = 0;
  int _missingSaai = 0;
  int _missingErp = 0;
  double _totalVariance = 0.0;
  String _filterStatus = 'Todos'; // Todos, Match, Diferencia, Faltante

  List<Map<String, dynamic>> _demoData = [];

  List<Map<String, dynamic>> get _filtered {
    if (_filterStatus == 'Todos') return _demoData;
    return _demoData.where((item) => item['status'] == _filterStatus).toList();
  }

  String _saaiFile = '';
  String _erpFile = '';

  Future<void> _cargarSAAI() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
      );
      if (result != null) {
        setState(() {
          _saaiLoaded = true;
          _saaiFile = result.files.single.name;
          _done = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al cargar SAAI: $e')));
      }
    }
  }

  Future<void> _cargarERP() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
      );
      if (result != null) {
        setState(() {
          _erpLoaded = true;
          _erpFile = result.files.single.name;
          _done = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al cargar ERP: $e')));
      }
    }
  }

  Future<void> _correrAuditoria() async {
    setState(() {
      _running = true;
      _done = false;
      _aiAnalysis = '';
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres experto en conciliación SAAI vs ERP. Analiza los datos y encuentra discrepancias entre el sistema aduanal SAAI y el ERP SAP. Responde en JSON: {"inconsistencias": [{"campo": "string", "cfd": "string", "pedimento": "string", "diferencia": 0.0, "status": "string"}], "matches": 0, "diffs": 0, "totalVarianza": 0.0, "recomendaciones": ["string"]}'),
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt =
          'Por favor genera un reporte de diferencias simulado basado en el archivo SAAI ($_saaiFile) y ERP ($_erpFile). Crea de 5 a 10 registros con diferentes status (Match, Diferencia, Faltante). Para "status", usa "Match", "Diferencia", o "Faltante".';

      final response = await model.generateContent([Content.text(prompt)]);
      final String jsonString = response.text ?? '{}';
      final Map<String, dynamic> data =
          jsonDecode(jsonString) as Map<String, dynamic>;

      final List<dynamic> inconsistencias =
          (data['inconsistencias'] ?? <dynamic>[]) as List<dynamic>;

      final List<Map<String, dynamic>> newData = [];
      for (final dynamic incRaw in inconsistencias) {
        final inc = incRaw as Map<String, dynamic>;
        newData.add({
          'folio': inc['pedimento'] ?? 'N/A',
          'desc': inc['campo'] ?? 'N/A',
          'cfd': inc['cfd'] ?? 'N/A',
          'diff': (inc['diferencia'] as num? ?? 0).toDouble(),
          'status': inc['status'] ?? 'Diferencia',
          'saai': 0.0,
          'erp': 0.0,
        });
      }

      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

      int missingS = 0;
      int missingE = 0;
      for (final item in newData) {
        if (item['status'] == 'Faltante') {
          if (missingS > missingE) {
            missingE++;
          } else {
            missingS++;
          }
        }
      }

      setState(() {
        _matches = (data['matches'] as num? ?? 0).toInt();
        _diffs = (data['diffs'] as num? ?? 0).toInt();
        _totalVariance = (data['totalVarianza'] as num? ?? 0).toDouble();

        _demoData = newData;
        _missingSaai = missingS;
        _missingErp = missingE;

        final recs =
            (data['recomendaciones'] as List<dynamic>? ?? []).join('\nâ€¢ ');
        _aiAnalysis = recs.isNotEmpty ? 'â€¢ $recs' : 'Sin recomendaciones';

        _running = false;
        _done = true;
      });

      await FirebaseFirestore.instance
          .collection('conciliaciones_visor_b')
          .add({
        'uid': uid,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'saai_file': _saaiFile,
        'erp_file': _erpFile,
        'matches': _matches,
        'diffs': _diffs,
        'total_variance': _totalVariance,
        'ai_analysis': _aiAnalysis,
        'inconsistencias': inconsistencias,
      });
    } catch (e) {
      setState(() {
        _running = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error en la auditoría: $e')));
      }
    }
  }

  Future<void> _consultarAI() async {
    setState(() => _aiLoading = true);
    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un experto en conciliación SAAI vs Visor B del SAT México. Analiza los datos de conciliación cargados y proporciona: análisis de consistencia, discrepancias encontradas, y recomendaciones. Responde SOLO en JSON: {"consistente": true, "analisis": "string", "discrepancias": [{"campo": "x", "valorSaai": "y", "valorVisorB": "z", "impacto": "w"}], "recomendaciones": ["r1"]}'),
      );

      final res = await model.generateContent([
        Content.text(
            'Analiza la conciliación con Varianza de $_totalVariance y $_diffs diferencias.')
      ]);
      final text =
          res.text?.replaceAll('```json', '').replaceAll('```', '').trim() ??
              '{}';
      final Map<String, dynamic> data =
          jsonDecode(text) as Map<String, dynamic>;

      final analisis = (data['analisis'] ?? '') as String;
      final recs =
          (data['recomendaciones'] as List<dynamic>?)?.join('\n• ') ?? '';

      if (mounted) {
        setState(() {
          _aiAnalysis = '$analisis\n\nRecomendaciones:\nâ€¢ $recs';
          _aiLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _aiLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error AI: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canRun = _saaiLoaded && _erpLoaded && !_running;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Auditoria Forense Ciega (DataStage vs ERP)',
                style: TextStyle(
                    color: _text, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
                'Cruza la verdad del SAT contra la contabilidad de tu ERP impulsado por IA.',
                style: TextStyle(color: _sub, fontSize: 12)),
          ],
        ),
        iconTheme: const IconThemeData(color: _sub),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: _border, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _uploadCard(
                    title: 'DataStage SAT (SAAI)',
                    subtitle:
                        _saaiLoaded ? _saaiFile : 'Ningún archivo cargado',
                    icon: Icons.cloud_upload_outlined,
                    color: _blue,
                    loaded: _saaiLoaded,
                    onTap: _cargarSAAI,
                    btnLabel: 'Cargar CSV SAAI',
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _card2,
                      shape: BoxShape.circle,
                      border: Border.all(color: _border)),
                  child:
                      const Icon(Icons.compare_arrows, color: _sub, size: 20),
                ),
                Expanded(
                  child: _uploadCard(
                    title: 'Contabilidad SAP/ERP',
                    subtitle: _erpLoaded ? _erpFile : 'Ningún archivo cargado',
                    icon: Icons.dashboard_outlined,
                    color: _gold,
                    loaded: _erpLoaded,
                    onTap: _cargarERP,
                    btnLabel: 'Cargar CSV ERP',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canRun ? _correrAuditoria : null,
                icon: _running
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: _bg, strokeWidth: 2))
                    : const Icon(Icons.bolt, size: 18, color: _bg),
                label: Text(
                  _running
                      ? 'Ejecutando Auditoría Forense...'
                      : 'Correr Auditoría Forense',
                  style: const TextStyle(
                      color: _bg, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canRun ? _gold : _border,
                  foregroundColor: _bg,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (!_saaiLoaded || !_erpLoaded)
              Text('Carga ambos archivos para habilitar la auditoría forense.',
                  style: TextStyle(color: _sub.withAlpha(160), fontSize: 12)),
            if (_done) ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  _kpi('Conciliados', _matches, _green,
                      Icons.check_circle_outline),
                  const SizedBox(width: 10),
                  _kpi('Diferencias', _diffs, _gold, Icons.swap_vert),
                  const SizedBox(width: 10),
                  _kpi('Sin SAAI', _missingSaai, _red, Icons.cloud_off),
                  const SizedBox(width: 10),
                  _kpi('Sin ERP', _missingErp, _blue, Icons.storage_outlined),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [_red.withAlpha(30), _bg],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _red.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: _red, size: 24),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Varianza Total Detectada',
                            style: TextStyle(
                                color: _red,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Suma de diferencias absolutas SAAI vs ERP',
                            style: TextStyle(color: _sub, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Text('\$${_totalVariance.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: _red,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace')),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.filter_list, color: _sub, size: 16),
                  const SizedBox(width: 8),
                  const Text('Filtrar:',
                      style: TextStyle(color: _sub, fontSize: 14)),
                  const SizedBox(width: 16),
                  ...['Todos', 'Match', 'Diferencia', 'Faltante'].map((t) {
                    final active = _filterStatus == t;
                    Color badgeColor = _sub;
                    if (t == 'Match') badgeColor = _green;
                    if (t == 'Diferencia') badgeColor = _gold;
                    if (t == 'Faltante') badgeColor = _red;

                    return GestureDetector(
                      onTap: () => setState(() => _filterStatus = t),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? badgeColor.withAlpha(25) : _card,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: active ? badgeColor : _border),
                        ),
                        child: Text(t,
                            style: TextStyle(
                                color: active ? badgeColor : _sub,
                                fontSize: 12,
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                          color: _card2,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15))),
                      child: const Row(
                        children: [
                          SizedBox(width: 32),
                          Expanded(
                              flex: 3,
                              child: Text('Folio / Descripción',
                                  style: TextStyle(
                                      color: _sub,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600))),
                          Expanded(
                              flex: 2,
                              child: Text('SAAI',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: _blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600))),
                          Expanded(
                              flex: 2,
                              child: Text('ERP',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: _gold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600))),
                          Expanded(
                              flex: 2,
                              child: Text('Diferencia',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: _red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600))),
                          SizedBox(
                              width: 80,
                              child: Text('Status',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: _sub,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ),
                    const Divider(color: _border, height: 1),
                    ..._filtered.asMap().entries.map((entry) {
                      final i = entry.key;
                      final r = entry.value;
                      final status = r['status'] as String;
                      final diff = r['diff'] as double;
                      final isLast = i == _filtered.length - 1;

                      Color statusColor = _sub;
                      IconData statusIcon = Icons.info_outline;
                      if (status == 'Match') {
                        statusColor = _green;
                        statusIcon = Icons.check_circle;
                      } else if (status == 'Diferencia') {
                        statusColor = _gold;
                        statusIcon = Icons.swap_vert;
                      } else if (status == 'Faltante') {
                        statusColor = _red;
                        statusIcon = Icons.cloud_off;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: status == 'Match'
                              ? Colors.transparent
                              : statusColor.withAlpha(10),
                          border: isLast
                              ? null
                              : const Border(
                                  bottom: BorderSide(color: _border)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 16),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r['folio'].toString(),
                                      style: const TextStyle(
                                          color: _text,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'monospace')),
                                  const SizedBox(height: 2),
                                  Text(r['desc'].toString(),
                                      style: const TextStyle(
                                          color: _sub, fontSize: 11)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                  '\$${(r['saai'] as double).toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: r['saai'] == 0 ? _sub : _blue,
                                      fontSize: 13,
                                      fontFamily: 'monospace')),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                  '\$${(r['erp'] as double).toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: r['erp'] == 0 ? _sub : _gold,
                                      fontSize: 13,
                                      fontFamily: 'monospace')),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                  diff == 0
                                      ? 'â€”'
                                      : '${diff > 0 ? '+' : ''}\$${diff.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: diff == 0
                                          ? _green
                                          : (diff > 0 ? _gold : _red),
                                      fontSize: 13,
                                      fontFamily: 'monospace',
                                      fontWeight: diff != 0
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ),
                            SizedBox(
                              width: 80,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: statusColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: statusColor.withAlpha(60))),
                                  child: Text(status.toUpperCase(),
                                      style: TextStyle(
                                          color: statusColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (_filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No hay resultados para este filtro',
                            style: TextStyle(color: _sub, fontSize: 14)),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _green.withAlpha(80))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: _green, size: 20),
                        const SizedBox(width: 12),
                        const Text('Análisis Forense Gemini AI',
                            style: TextStyle(
                                color: _text,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _aiLoading ? null : _consultarAI,
                          icon: _aiLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      color: _bg, strokeWidth: 2))
                              : const Icon(Icons.bolt, size: 16, color: _bg),
                          label: Text(
                              _aiLoading ? 'Analizando...' : 'Analizar con AI',
                              style: const TextStyle(
                                  color: _bg,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                      ],
                    ),
                    if (_aiAnalysis.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(color: _border, height: 1),
                      const SizedBox(height: 16),
                      Text(_aiAnalysis,
                          style: const TextStyle(
                              color: _text, fontSize: 14, height: 1.6)),
                    ] else if (!_aiLoading) ...[
                      const SizedBox(height: 16),
                      const Text(
                          'Presiona "Analizar con AI" para obtener un diagnóstico forense adicional.',
                          style: TextStyle(color: _sub, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _uploadCard(
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required bool loaded,
      required VoidCallback onTap,
      required String btnLabel}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: loaded ? color.withAlpha(80) : _border)),
      child: Column(
        children: [
          Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withAlpha(80))),
              child: Icon(icon, color: color, size: 28)),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: _text, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(color: loaded ? color : _sub, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(loaded ? Icons.check_circle : Icons.upload_file_outlined,
                size: 16, color: loaded ? _green : color),
            label: Text(loaded ? 'Archivo cargado' : btnLabel,
                style: TextStyle(color: loaded ? _green : color, fontSize: 13)),
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: loaded ? _green : color),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
          ),
        ],
      ),
    );
  }

  Widget _kpi(String l, int n, Color c, IconData icon) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.withAlpha(50))),
          child: Row(
            children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: c.withAlpha(20),
                      borderRadius: BorderRadius.circular(20)),
                  child: Icon(icon, color: c, size: 20)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$n',
                      style: TextStyle(
                          color: c,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1)),
                  const SizedBox(height: 4),
                  Text(l, style: const TextStyle(color: _sub, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      );
}
