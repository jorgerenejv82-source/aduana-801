import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:intl/intl.dart';
import '../../../services/normativa_service.dart';
import '../../../core/theme/app_colors.dart';

class ExpedienteDetailScreen extends StatefulWidget {
  final String expedienteId;

  const ExpedienteDetailScreen({super.key, required this.expedienteId});

  @override
  State<ExpedienteDetailScreen> createState() => _ExpedienteDetailScreenState();
}

class _ExpedienteDetailScreenState extends State<ExpedienteDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _currency =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  bool _dataLoaded = false;

  // Tab 2 Controllers
  final _numPedimentoCtrl = TextEditingController();
  final _igiPctCtrl = TextEditingController();
  bool _prvDespacho = false;

  // Tab 3 Controllers
  final _docsAduanaCtrl = TextEditingController();
  final _verificadorCtrl = TextEditingController();
  final _mercanciaDeclaradaCtrl = TextEditingController();
  final _mercanciaEncontradaCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();

  // Tab 4 Controllers
  final _honorariosCtrl = TextEditingController();
  bool _prvCuenta = false;
  bool _previoCuenta = false;
  final _almacenajeDiasCtrl = TextEditingController();
  final _tarifaDiaCtrl = TextEditingController();
  final _maniobrasCtrl = TextEditingController();
  final _otrosCtrl = TextEditingController();

  // Tab 5
  final _notasCtrl = TextEditingController();

  final List<String> _requiredDocs = [
    'Factura Comercial',
    'Packing List',
    'B/L o AWB',
    'Certificado de Origen',
    'Permiso Previo',
    'Pedimento M3'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _numPedimentoCtrl.dispose();
    _igiPctCtrl.dispose();
    _docsAduanaCtrl.dispose();
    _verificadorCtrl.dispose();
    _mercanciaDeclaradaCtrl.dispose();
    _mercanciaEncontradaCtrl.dispose();
    _observacionesCtrl.dispose();
    _honorariosCtrl.dispose();
    _almacenajeDiasCtrl.dispose();
    _tarifaDiaCtrl.dispose();
    _maniobrasCtrl.dispose();
    _otrosCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  void _initData(Map<String, dynamic> data) {
    if (_dataLoaded) return;
    _dataLoaded = true;

    _numPedimentoCtrl.text = data['numPedimento']?.toString() ?? '';
    _igiPctCtrl.text = (data['igiPct'] ?? 0).toString();
    _prvDespacho =
        data['prvMonto'] != null && (data['prvMonto'] as num).toDouble() > 0;

    _notasCtrl.text = data['notas']?.toString() ?? '';

    final cuenta = data['cuentaGastos'] as Map<String, dynamic>? ?? {};
    _honorariosCtrl.text = (cuenta['honorarios'] ?? 0).toString();
    _prvCuenta = cuenta['prv'] as bool? ?? false;
    _previoCuenta = cuenta['previo'] as bool? ?? false;
    _almacenajeDiasCtrl.text = (cuenta['almacenajeDias'] ?? 0).toString();
    _tarifaDiaCtrl.text = (cuenta['tarifaDia'] ?? 0).toString();
    _maniobrasCtrl.text = (cuenta['maniobras'] ?? 0).toString();
    _otrosCtrl.text = (cuenta['otros'] ?? 0).toString();
  }

  Future<void> _marcarComoCargado(
      String docName, List<dynamic> currentDocs) async {
    final newDocs = List<dynamic>.from(currentDocs);
    newDocs.add({
      'nombre': docName,
      'fileName': '${docName.replaceAll(' ', '_')}.pdf',
      'uploadedAt': Timestamp.now(),
    });
    await FirebaseFirestore.instance
        .collection('expedientes_completos')
        .doc(widget.expedienteId)
        .update({
      'documentos': newDocs,
    });
  }

  Future<void> _guardarDespacho() async {
    final igiPct = double.tryParse(_igiPctCtrl.text) ?? 0.0;
    final prvMonto = _prvDespacho ? NormativaService().prvCntTotal : 0.0;

    await FirebaseFirestore.instance
        .collection('expedientes_completos')
        .doc(widget.expedienteId)
        .update({
      'numPedimento': _numPedimentoCtrl.text,
      'igiPct': igiPct,
      'prvMonto': prvMonto,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos de despacho guardados')),
      );
    }
  }

  Future<void> _analizarRojoConGemini(Map<String, dynamic> data) async {
    try {
      unawaited(showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      ));

      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un experto en reconocimientos aduanales de México (Ley Aduanera Art. 43-46). Analiza los datos del reconocimiento físico y determina: si hay incidencia real, el fundamento legal del SAT, acciones correctivas, y si procede recurso de revocación. Responde con análisis detallado en español.'),
      );

      final prompt = '''
Verificador: ${_verificadorCtrl.text}
Mercancía declarada: ${_mercanciaDeclaradaCtrl.text}
Mercancía encontrada: ${_mercanciaEncontradaCtrl.text}
Observaciones: ${_observacionesCtrl.text}
Valor Aduana: ${data['valorFob']} ${data['moneda']}
''';

      final response = await model.generateContent([Content.text(prompt)]);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      unawaited(showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Análisis Gemini AI',
              style: TextStyle(color: AppColors.gold)),
          content: SingleChildScrollView(
            child: Text(response.text ?? 'Sin respuesta',
                style: const TextStyle(color: AppColors.text)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cerrar'),
            )
          ],
        ),
      ));
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _guardarCuentaGastos() async {
    final cuenta = {
      'honorarios': double.tryParse(_honorariosCtrl.text) ?? 0.0,
      'prv': _prvCuenta,
      'previo': _previoCuenta,
      'almacenajeDias': int.tryParse(_almacenajeDiasCtrl.text) ?? 0,
      'tarifaDia': double.tryParse(_tarifaDiaCtrl.text) ?? 0.0,
      'maniobras': double.tryParse(_maniobrasCtrl.text) ?? 0.0,
      'otros': double.tryParse(_otrosCtrl.text) ?? 0.0,
    };

    await FirebaseFirestore.instance
        .collection('expedientes_completos')
        .doc(widget.expedienteId)
        .update({
      'cuentaGastos': cuenta,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta de gastos guardada')),
      );
    }
  }

  Future<void> _actualizarSemaforo(String color) async {
    final updateData = <String, dynamic>{
      'resultadoSemaforo': color,
    };

    if (color == 'verde') {
      updateData['estado'] = 'liberado';
      updateData['fechaLiberacion'] = Timestamp.now();
    }

    await FirebaseFirestore.instance
        .collection('expedientes_completos')
        .doc(widget.expedienteId)
        .update(updateData);

    if (!mounted) return;
    if (color == 'verde') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('¡Mercancía liberada! ✅', style: TextStyle(fontSize: 16)),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // --- UI Builders ---

  Widget _buildTopBanner(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.card,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bannerItem('Tipo', data['tipo']?.toString().toUpperCase() ?? ''),
          _bannerItem('Aduana', data['aduana']?.toString() ?? ''),
          _bannerItem(
              'Fracción', data['fraccionPrincipal']?.toString() ?? 'N/A'),
          _bannerItem('Valor FOB', _currency.format(data['valorFob'] ?? 0)),
        ],
      ),
    );
  }

  Widget _bannerItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.sub, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: AppColors.text, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDocumentosTab(Map<String, dynamic> data) {
    final docsCargados =
        (data['documentos'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final cargadosNombres =
        docsCargados.map((d) => d['nombre'] as String).toList();

    final int loadedCount =
        _requiredDocs.where((d) => cargadosNombres.contains(d)).length;
    final double progress = loadedCount / _requiredDocs.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Progreso: $loadedCount / ${_requiredDocs.length}',
            style: const TextStyle(color: AppColors.text)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            color: AppColors.gold),
        const SizedBox(height: 16),
        ..._requiredDocs.map((docReq) {
          final isLoaded = cargadosNombres.contains(docReq);
          return Card(
            color: AppColors.card,
            child: ListTile(
              leading: Icon(isLoaded ? Icons.check_circle : Icons.cancel,
                  color: isLoaded ? AppColors.green : AppColors.red),
              title:
                  Text(docReq, style: const TextStyle(color: AppColors.text)),
              trailing: isLoaded
                  ? const Text('Cargado',
                      style: TextStyle(color: AppColors.green))
                  : TextButton(
                      onPressed: () => _marcarComoCargado(docReq, docsCargados),
                      child: const Text('Marcar como cargado',
                          style: TextStyle(color: AppColors.blue)),
                    ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDespachoTab(Map<String, dynamic> data) {
    final normativa = NormativaService();
    final tipoCambio = normativa.tipoCambioFix;
    final valorFob = (data['valorFob'] as num? ?? 0).toDouble();
    final valorAduana = valorFob * tipoCambio;

    final igiPct = double.tryParse(_igiPctCtrl.text) ?? 0.0;
    final igiMonto = valorAduana * (igiPct / 100);
    final dta =
        normativa.calcularDTA(valorAduana, data['regimen']?.toString() ?? '');
    final prvMonto = _prvDespacho ? normativa.prvCntTotal : 0.0;

    final iva = (valorAduana + igiMonto + dta + prvMonto) * 0.16;
    final totalImpuestos = igiMonto + dta + prvMonto + iva;

    final score = data['score_preglosa'] as num?;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (score != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (score >= 85
                        ? AppColors.green
                        : score >= 60
                            ? AppColors.gold
                            : AppColors.red)
                    .withValues(alpha: 0.2),
              ),
              child: Text(
                score.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: score >= 85
                      ? AppColors.green
                      : score >= 60
                          ? AppColors.gold
                          : AppColors.red,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _numPedimentoCtrl,
          style: const TextStyle(color: AppColors.text),
          decoration: const InputDecoration(
            labelText: 'Número de Pedimento',
            labelStyle: TextStyle(color: AppColors.sub),
            fillColor: AppColors.card,
            filled: true,
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Tipo de Cambio DOF',
              style: TextStyle(color: AppColors.text)),
          subtitle: Text('Última actualización: ${normativa.tcLastUpdate}',
              style: const TextStyle(color: AppColors.sub)),
          trailing: Text(tipoCambio.toStringAsFixed(4),
              style: const TextStyle(color: AppColors.text, fontSize: 16)),
        ),
        ListTile(
          title: Text('Fracción Principal: ${data['fraccionPrincipal']}',
              style: const TextStyle(color: AppColors.text)),
          subtitle: Row(
            children: [
              const Text('IGI %:', style: TextStyle(color: AppColors.sub)),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _igiPctCtrl,
                  style: const TextStyle(color: AppColors.text),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(isDense: true),
                ),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: const Text('Aplicar PRV/CNT',
              style: TextStyle(color: AppColors.text)),
          value: _prvDespacho,
          onChanged: (v) => setState(() => _prvDespacho = v),
          activeThumbColor: AppColors.blue,
        ),
        const Divider(color: AppColors.border),
        ListTile(
          title: const Text('DTA Calculado',
              style: TextStyle(color: AppColors.text)),
          trailing: Text(_currency.format(dta),
              style: const TextStyle(color: AppColors.text)),
        ),
        ListTile(
          title: const Text('IVA Calculado',
              style: TextStyle(color: AppColors.text)),
          trailing: Text(_currency.format(iva),
              style: const TextStyle(color: AppColors.text)),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              const Text('TOTAL IMPUESTOS',
                  style: TextStyle(color: AppColors.sub)),
              Text(_currency.format(totalImpuestos),
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.all(16)),
          onPressed: _guardarDespacho,
          child: const Text('Guardar Datos Despacho',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSemaforoTab(Map<String, dynamic> data) {
    final status = data['resultadoSemaforo'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (status.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            color: status == 'verde'
                ? AppColors.green.withValues(alpha: 0.2)
                : status == 'naranja'
                    ? AppColors.gold.withValues(alpha: 0.2)
                    : AppColors.red.withValues(alpha: 0.2),
            child: Text(
              'Estado Actual: ${status.toUpperCase()}',
              style: TextStyle(
                  color: status == 'verde'
                      ? AppColors.green
                      : status == 'naranja'
                          ? AppColors.gold
                          : AppColors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
              onPressed: () => _actualizarSemaforo('verde'),
              child:
                  const Text('VERDE 🟢', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              onPressed: () => _actualizarSemaforo('naranja'),
              child: const Text('NARANJA 🟡',
                  style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
              onPressed: () => _actualizarSemaforo('rojo'),
              child:
                  const Text('ROJO 🔴', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (status == 'naranja')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Documentos requeridos por aduana',
                  style: TextStyle(color: AppColors.text)),
              const SizedBox(height: 8),
              TextField(
                controller: _docsAduanaCtrl,
                style: const TextStyle(color: AppColors.text),
                maxLines: 3,
                decoration: const InputDecoration(
                    fillColor: AppColors.card, filled: true),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => FirebaseFirestore.instance
                    .collection('expedientes_completos')
                    .doc(widget.expedienteId)
                    .update({'docsSemaforoNaranja': _docsAduanaCtrl.text}),
                child: const Text('Guardar'),
              ),
            ],
          ),
        if (status == 'rojo')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                  controller: _verificadorCtrl,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                      labelText: 'Verificador',
                      fillColor: AppColors.card,
                      filled: true)),
              const SizedBox(height: 8),
              TextField(
                  controller: _mercanciaDeclaradaCtrl,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                      labelText: 'Mercancía Declarada',
                      fillColor: AppColors.card,
                      filled: true)),
              const SizedBox(height: 8),
              TextField(
                  controller: _mercanciaEncontradaCtrl,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                      labelText: 'Mercancía Encontrada',
                      fillColor: AppColors.card,
                      filled: true)),
              const SizedBox(height: 8),
              TextField(
                  controller: _observacionesCtrl,
                  style: const TextStyle(color: AppColors.text),
                  maxLines: 4,
                  decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      fillColor: AppColors.card,
                      filled: true)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.all(16)),
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: const Text('Analizar con Gemini',
                    style: TextStyle(color: Colors.white)),
                onPressed: () => _analizarRojoConGemini(data),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCuentaGastosTab(Map<String, dynamic> data) {
    final honorarios = double.tryParse(_honorariosCtrl.text) ?? 0.0;
    final prvMonto = _prvCuenta ? 250.0 : 0.0;
    final previoMonto = _previoCuenta ? 1500.0 : 0.0;
    final almacenajeDias = int.tryParse(_almacenajeDiasCtrl.text) ?? 0;
    final tarifaDia = double.tryParse(_tarifaDiaCtrl.text) ?? 0.0;
    final almacenajeTotal = almacenajeDias * tarifaDia;
    final maniobras = double.tryParse(_maniobrasCtrl.text) ?? 0.0;
    final otros = double.tryParse(_otrosCtrl.text) ?? 0.0;

    final subtotal = honorarios +
        prvMonto +
        previoMonto +
        almacenajeTotal +
        maniobras +
        otros;
    final iva = subtotal * 0.16;
    final total = subtotal + iva;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
            controller: _honorariosCtrl,
            style: const TextStyle(color: AppColors.text),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
                labelText: 'Honorarios',
                fillColor: AppColors.card,
                filled: true)),
        SwitchListTile(
            title: const Text('PRV', style: TextStyle(color: AppColors.text)),
            value: _prvCuenta,
            onChanged: (v) => setState(() => _prvCuenta = v)),
        SwitchListTile(
            title:
                const Text('Previo', style: TextStyle(color: AppColors.text)),
            value: _previoCuenta,
            onChanged: (v) => setState(() => _previoCuenta = v)),
        Row(
          children: [
            Expanded(
                child: TextField(
                    controller: _almacenajeDiasCtrl,
                    style: const TextStyle(color: AppColors.text),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                        labelText: 'Días Almacenaje',
                        fillColor: AppColors.card,
                        filled: true))),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                    controller: _tarifaDiaCtrl,
                    style: const TextStyle(color: AppColors.text),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                        labelText: 'Tarifa/Día',
                        fillColor: AppColors.card,
                        filled: true))),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
            controller: _maniobrasCtrl,
            style: const TextStyle(color: AppColors.text),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
                labelText: 'Maniobras',
                fillColor: AppColors.card,
                filled: true)),
        const SizedBox(height: 8),
        TextField(
            controller: _otrosCtrl,
            style: const TextStyle(color: AppColors.text),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
                labelText: 'Otros Gastos',
                fillColor: AppColors.card,
                filled: true)),
        const Divider(color: AppColors.border, height: 32),
        ListTile(
            title:
                const Text('Subtotal', style: TextStyle(color: AppColors.text)),
            trailing: Text(_currency.format(subtotal),
                style: const TextStyle(color: AppColors.text))),
        ListTile(
            title:
                const Text('IVA 16%', style: TextStyle(color: AppColors.text)),
            trailing: Text(_currency.format(iva),
                style: const TextStyle(color: AppColors.text))),
        const SizedBox(height: 8),
        Center(
          child: Text('TOTAL: ${_currency.format(total)}',
              style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.all(16)),
          onPressed: _guardarCuentaGastos,
          child: const Text('Guardar Cuenta de Gastos',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTimelineTab(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> events = [];

    if (data['created_at'] != null) {
      events.add({
        'title': 'Expediente creado',
        'date': (data['created_at'] as Timestamp).toDate(),
        'icon': Icons.folder,
        'color': AppColors.sub
      });
    }

    final docs =
        (data['documentos'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    for (final doc in docs) {
      if (doc['uploadedAt'] != null) {
        events.add({
          'title': 'Documento cargado: ${doc['nombre']}',
          'date': (doc['uploadedAt'] as Timestamp).toDate(),
          'icon': Icons.description,
          'color': AppColors.blue
        });
      }
    }

    if ((data['numPedimento']?.toString() ?? '').isNotEmpty) {
      events.add({
        'title': 'Pedimento asignado: ${data['numPedimento']}',
        'date': DateTime.now(),
        'icon': Icons.assignment,
        'color': AppColors.gold
      });
    }

    if ((data['resultadoSemaforo']?.toString() ?? '').isNotEmpty) {
      final colorSemaforo = data['resultadoSemaforo']?.toString() == 'verde'
          ? AppColors.green
          : data['resultadoSemaforo']?.toString() == 'rojo'
              ? AppColors.red
              : AppColors.gold;
      events.add({
        'title':
            'Semáforo: ${data['resultadoSemaforo'].toString().toUpperCase()}',
        'date': DateTime.now(),
        'icon': Icons.traffic,
        'color': colorSemaforo
      });
    }

    if (data['fechaLiberacion'] != null) {
      events.add({
        'title': 'Mercancía liberada ✅',
        'date': (data['fechaLiberacion'] as Timestamp).toDate(),
        'icon': Icons.check_circle,
        'color': AppColors.green
      });
    }

    events.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: (event['color'] as Color)
                                .withValues(alpha: 0.2),
                            shape: BoxShape.circle),
                        child: Icon(event['icon'] as IconData,
                            color: event['color'] as Color, size: 20),
                      ),
                      if (index < events.length - 1)
                        Container(
                            width: 2, height: 40, color: AppColors.border),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event['title'] as String,
                            style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_dateFormat.format(event['date'] as DateTime),
                            style: const TextStyle(
                                color: AppColors.sub, fontSize: 12)),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                FirebaseFirestore.instance
                    .collection('expedientes_completos')
                    .doc(widget.expedienteId)
                    .update({'notas': _notasCtrl.text});
              }
            },
            child: TextField(
              controller: _notasCtrl,
              style: const TextStyle(color: AppColors.text),
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notas',
                labelStyle: TextStyle(color: AppColors.sub),
                fillColor: AppColors.card,
                filled: true,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        iconTheme: const IconThemeData(color: AppColors.text),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('expedientes_completos')
              .doc(widget.expedienteId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data?.data() == null) {
              return const Text('Detalle de Expediente',
                  style: TextStyle(color: AppColors.text));
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final estado = data['estado'] as String? ?? 'pendiente_docs';
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['numExpediente']?.toString() ?? '',
                          style: const TextStyle(
                              color: AppColors.text, fontSize: 16)),
                      Text(data['clienteNombre']?.toString() ?? '',
                          style: const TextStyle(
                              color: AppColors.sub, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(estado.toUpperCase(),
                      style:
                          const TextStyle(color: AppColors.gold, fontSize: 12)),
                ),
              ],
            );
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.sub,
          indicatorColor: AppColors.gold,
          tabs: const [
            Tab(icon: Icon(Icons.folder), text: 'Documentos'),
            Tab(icon: Icon(Icons.assignment), text: 'Despacho'),
            Tab(icon: Icon(Icons.traffic), text: 'Semáforo'),
            Tab(icon: Icon(Icons.attach_money), text: 'Gastos'),
            Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('expedientes_completos')
            .doc(widget.expedienteId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text('No encontrado',
                    style: TextStyle(color: AppColors.text)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          _initData(data);

          return Column(
            children: [
              _buildTopBanner(data),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDocumentosTab(data),
                    _buildDespachoTab(data),
                    _buildSemaforoTab(data),
                    _buildCuentaGastosTab(data),
                    _buildTimelineTab(data),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
