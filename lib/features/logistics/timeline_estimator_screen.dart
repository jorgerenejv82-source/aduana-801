import 'package:flutter/material.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TimelineEstimatorScreen extends StatefulWidget {
  const TimelineEstimatorScreen({super.key});

  @override
  State<TimelineEstimatorScreen> createState() =>
      _TimelineEstimatorScreenState();
}

class _TimelineEstimatorScreenState extends State<TimelineEstimatorScreen> {
  String _pais = 'China';
  String _puerto = 'Manzanillo';
  String _transporte = 'Marítimo FCL';
  bool _tieneProveedor = true;
  bool _tienePadron = true;
  final TextEditingController _produccionCtrl =
      TextEditingController(text: '30');

  List<_TimelineStep>? _steps;
  DateTime? _finalDate;

  final Map<String, Map<String, int>> _transitTimes = {
    'China': {
      'Marítimo FCL_Manzanillo': 28,
      'Marítimo FCL_Lázaro Cárdenas': 30,
      'Marítimo FCL_Veracruz': 35,
      'Aéreo_AICM': 5
    },
    'India': {'Marítimo FCL_Manzanillo': 35, 'Aéreo_AICM': 7},
    'USA': {
      'Terrestre USA-MEX_Nuevo Laredo': 3,
      'Terrestre USA-MEX_Tijuana': 2,
      'Aéreo_AICM': 2
    },
    'Canadá': {'Terrestre USA-MEX_Nuevo Laredo': 4, 'Aéreo_AICM': 3},
    'Alemania': {'Aéreo_AICM': 4, 'Marítimo FCL_Veracruz': 20},
    'España': {'Aéreo_AICM': 3, 'Marítimo FCL_Veracruz': 18},
  };

  @override
  void dispose() {
    _produccionCtrl.dispose();
    super.dispose();
  }

  void _calcular() {
    int currentDay = 0;
    final List<_TimelineStep> steps = [];
    final DateTime today = DateTime.now();

    steps.add(_TimelineStep(
        name: 'Hoy', day: currentDay, color: AppColors.blue, date: today));

    if (!_tieneProveedor) {
      steps.add(_TimelineStep(
          name: 'Búsqueda de proveedor',
          day: currentDay,
          duration: 30,
          color: AppColors.blue,
          date: today.add(const Duration(days: 30))));
      currentDay += 30;
    }

    if (!_tienePadron) {
      steps.add(_TimelineStep(
          name: 'Inscripción Padrón Importadores',
          day: currentDay,
          duration: 15,
          color: AppColors.blue,
          date: today.add(Duration(days: currentDay + 15))));
      // Padron can happen in parallel
    }

    steps.add(_TimelineStep(
        name: 'Inspección de proveedor + pedido',
        day: currentDay,
        duration: 3,
        color: AppColors.blue,
        date: today.add(Duration(days: currentDay + 3))));
    currentDay += 3;

    final int prodDays = int.tryParse(_produccionCtrl.text) ?? 30;
    steps.add(_TimelineStep(
        name: 'Producción del producto',
        day: currentDay,
        duration: prodDays,
        color: AppColors.blue,
        date: today.add(Duration(days: currentDay + prodDays))));
    currentDay += prodDays;

    steps.add(_TimelineStep(
        name: 'Preparación y embarque',
        day: currentDay,
        duration: 3,
        color: AppColors.blue,
        date: today.add(Duration(days: currentDay + 3))));
    currentDay += 3;

    const String key = '\${_transporte}_\${_puerto}';
    final int transitDays =
        _transitTimes[_pais]?[key] ?? 15; // default fallback
    steps.add(_TimelineStep(
        name: 'Tránsito (\$transporte)',
        day: currentDay,
        duration: transitDays,
        color: AppColors.blue,
        date: today.add(Duration(days: currentDay + transitDays))));
    currentDay += transitDays;

    steps.add(_TimelineStep(
        name: 'Llegada a \$_puerto',
        day: currentDay,
        color: AppColors.red,
        date: today.add(Duration(days: currentDay)),
        warning: '⚠️ TENER DOCUMENTOS LISTOS ACÁ para evitar demurrage'));

    steps.add(_TimelineStep(
        name: 'Despacho aduanal',
        day: currentDay,
        duration: 5,
        color: AppColors.blue,
        date: today.add(Duration(days: currentDay + 5))));
    currentDay += 5;

    steps.add(_TimelineStep(
        name: 'Transporte a tu almacén',
        day: currentDay,
        duration: 3,
        color: AppColors.blue,
        date: today.add(Duration(days: currentDay + 3))));
    currentDay += 3;

    steps.add(_TimelineStep(
        name: '✅ Mercancía en tu almacén',
        day: currentDay,
        color: AppColors.green,
        date: today.add(Duration(days: currentDay))));

    setState(() {
      _steps = steps;
      _finalDate = today.add(Duration(days: currentDay));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('¿Cuándo llega?',
            style: TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildForm(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                onPressed: _calcular,
                child: const Text('ESTIMAR MI TIMELINE',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            if (_steps != null) _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _pais,
            dropdownColor: AppColors.card,
            style: const TextStyle(color: AppColors.text),
            decoration: _inputDeco('País de origen del proveedor'),
            items: [
              'China',
              'India',
              'USA',
              'Canadá',
              'Alemania',
              'España',
              'Otro'
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _pais = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _puerto,
            dropdownColor: AppColors.card,
            style: const TextStyle(color: AppColors.text),
            decoration: _inputDeco('Puerto de destino en México'),
            items: [
              'Manzanillo',
              'Lázaro Cárdenas',
              'Veracruz',
              'Altamira',
              'AICM',
              'Nuevo Laredo',
              'Tijuana',
              'Otra frontera'
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _puerto = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _transporte,
            dropdownColor: AppColors.card,
            style: const TextStyle(color: AppColors.text),
            decoration: _inputDeco('Tipo de transporte'),
            items: [
              'Marítimo FCL',
              'Marítimo LCL',
              'Aéreo',
              'Terrestre USA-MEX'
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _transporte = v!),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('¿Ya tienes listo al proveedor?',
                style: TextStyle(color: AppColors.text)),
            activeThumbColor: AppColors.blue,
            value: _tieneProveedor,
            onChanged: (v) => setState(() => _tieneProveedor = v),
          ),
          SwitchListTile(
            title: const Text('¿Ya estás inscrito al Padrón?',
                style: TextStyle(color: AppColors.text)),
            activeThumbColor: AppColors.blue,
            value: _tienePadron,
            onChanged: (v) => setState(() => _tienePadron = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _produccionCtrl,
            style: const TextStyle(color: AppColors.text),
            keyboardType: TextInputType.number,
            decoration: _inputDeco('Tiempo de producción (días)'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.sub),
      enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.blue),
          borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildTimeline() {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tu Timeline Estimado',
            style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._steps!.map((step) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(Icons.circle, color: step.color, size: 16),
                    if (step != _steps!.last)
                      Container(width: 2, height: 40, color: AppColors.border),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.name,
                          style: TextStyle(
                              color: AppColors.text,
                              fontWeight: step.color == AppColors.green
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      Text(dateFormat.format(step.date),
                          style: const TextStyle(
                              color: AppColors.sub, fontSize: 12)),
                      if (step.warning != null) ...[
                        const SizedBox(height: 4),
                        Text(step.warning!,
                            style: const TextStyle(
                                color: AppColors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ]
                    ],
                  ),
                )
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.gold),
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              const Text('Tu mercancía llega aproximadamente el:',
                  style: TextStyle(color: AppColors.sub)),
              const SizedBox(height: 8),
              Text(dateFormat.format(_finalDate!),
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.card,
                    side: const BorderSide(color: AppColors.border)),
                icon: const Icon(Icons.calendar_today,
                    color: AppColors.text, size: 16),
                label: const Text('Agregar',
                    style: TextStyle(color: AppColors.text)),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Agregado para ${dateFormat.format(_finalDate!)}'))),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                icon: const Icon(Icons.save, color: Colors.white, size: 16),
                label: const Text('Guardar',
                    style: TextStyle(color: Colors.white)),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Timeline guardado'))),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _TimelineStep {
  final String name;
  final int day;
  final int duration;
  final Color color;
  final DateTime date;
  final String? warning;

  _TimelineStep(
      {required this.name,
      required this.day,
      this.duration = 0,
      required this.color,
      required this.date,
      this.warning});
}
