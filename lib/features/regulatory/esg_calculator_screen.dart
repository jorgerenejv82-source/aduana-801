import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _verde = AppColors.green;
const Color _azul = AppColors.blue;

class EsgCalculatorScreen extends StatefulWidget {
  const EsgCalculatorScreen({super.key});

  @override
  _EsgCalculatorScreenState createState() => _EsgCalculatorScreenState();
}

class _EsgCalculatorScreenState extends State<EsgCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedTransport = 'Maritimo FCL';
  String _selectedRoute = 'Shanghai -> Manzanillo (18,200 km)';
  final TextEditingController _weightController =
      TextEditingController(text: '10');
  final TextEditingController _containersController =
      TextEditingController(text: '1');

  bool _isLoading = false;
  bool _showResults = false;
  double _co2e = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weightController.dispose();
    _containersController.dispose();
    super.dispose();
  }

  void _calculate() async {
    setState(() {
      _isLoading = true;
      _showResults = false;
    });

    final model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-1.5-flash',
      systemInstruction: Content.system(
          'Eres un experto en ESG y comercio exterior sostenible. Calcula el score ESG de la operacion aduanal descrita considerando: huella de carbono del transporte, cumplimiento de NOMs ambientales, practicas laborales del proveedor, y gobernanza de la cadena de suministro. Responde en JSON: {"scoreTotal": 0, "scoreE": 0, "scoreS": 0, "scoreG": 0, "nivel": "EXCELENTE", "recomendaciones": ["string"]}'),
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
    try {
      final response = await model.generateContent([
        Content.text(
            'Calcula score para ruta $_selectedRoute en transporte $_selectedTransport con peso ${_weightController.text}')
      ]);
      // (Fake delay to simulate api/AI call)
      // ignore: unused_local_variable
      final jsonResponse = jsonDecode(response.text ?? '{}');
      // Podriamos usar los scores para algo mas adelante
    } catch (e) {
      // Ignore
    }

    double distance = 18200.0;
    if (_selectedRoute.contains('10,800')) distance = 10800.0;
    if (_selectedRoute.contains('2,900')) distance = 2900.0;

    double factor = 0.0089;
    if (_selectedTransport == 'Maritimo LCL') factor = 0.0120;
    if (_selectedTransport == 'Aereo') factor = 0.6020;
    if (_selectedTransport == 'Terrestre') factor = 0.0962;

    final double weight = double.tryParse(_weightController.text) ?? 0.0;

    setState(() {
      _co2e = distance * weight * factor;
      _isLoading = false;
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: _texto),
        ),
        title: const Row(
          children: [
            Text('ESG Calculator',
                style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.eco, color: _verde),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _verde,
          labelColor: _verde,
          unselectedLabelColor: _sec,
          tabs: const [
            Tab(text: 'Calculadora CO2'),
            Tab(text: 'Reporte ESG'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalcTab(),
          _buildReportTab(),
        ],
      ),
    );
  }

  Widget _buildCalcTab() {
    final transports = ['Maritimo FCL', 'Maritimo LCL', 'Aereo', 'Terrestre'];
    final routes = [
      'Shanghai -> Manzanillo (18,200 km)',
      'Hamburg -> Veracruz (10,800 km)',
      'LA -> Laredo (2,900 km)'
    ];

    final bool isMaritimo = _selectedTransport.contains('Maritimo');

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord)),
          child: const Text(
            'Calcula la huella de carbono de tus embarques para reportes ESG, cumplimiento con directivas europeas (CBAM) y licitaciones corporativas.',
            style: TextStyle(color: _sec, fontSize: 14),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tipo de transporte',
                  style: TextStyle(color: _texto, fontSize: 12)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTransport,
                dropdownColor: _card,
                style: const TextStyle(color: _texto),
                items: [
                  for (final t in transports)
                    DropdownMenuItem(value: t, child: Text(t)),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTransport = val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Ruta estimada',
                  style: TextStyle(color: _texto, fontSize: 12)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRoute,
                dropdownColor: _card,
                style: const TextStyle(color: _texto),
                items: [
                  for (final r in routes)
                    DropdownMenuItem(value: r, child: Text(r)),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRoute = val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Peso de la carga (toneladas)',
                  style: TextStyle(color: _texto, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: _weightController,
                style: const TextStyle(color: _texto),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _bg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              if (isMaritimo) ...[
                const SizedBox(height: 16),
                const Text('Numero de contenedores',
                    style: TextStyle(color: _texto, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: _containersController,
                  style: const TextStyle(color: _texto),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _bg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _calculate,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _verde, foregroundColor: _bg),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: _bg, strokeWidth: 2))
                      : const Text('Calcular Huella de Carbono',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        if (_showResults) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _verde)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resultados',
                    style:
                        TextStyle(color: _texto, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text('${_co2e.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                              color: _verde,
                              fontSize: 32,
                              fontWeight: FontWeight.bold)),
                      const Text('CO2e Total Emitido',
                          style: TextStyle(color: _sec)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: _bord),
                const SizedBox(height: 8),
                _buildResultRow(Icons.park,
                    '${(_co2e / 21).toStringAsFixed(1)} arboles necesarios para compensar (1 ano)'),
                _buildResultRow(Icons.flight,
                    '${(_co2e / 1800).toStringAsFixed(2)} vuelos equivalentes MEX-MAD'),
                _buildResultRow(Icons.attach_money,
                    'Costo compensacion: USD ${((_co2e / 1000) * 15).toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Categoria: ', style: TextStyle(color: _sec)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: _getCategoryColor().withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(_getCategoryText(),
                          style: TextStyle(
                              color: _getCategoryColor(),
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tips para reducir huella:',
                  style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('â€¢ Consolida carga LCL en FCL para mejor eficiencia.',
                  style: TextStyle(color: _sec, fontSize: 12)),
              Text(
                  'â€¢ Prefiere rutas maritimas sobre aereas cuando sea posible.',
                  style: TextStyle(color: _sec, fontSize: 12)),
              Text(
                  'â€¢ Utiliza navieras con buques "Eco-Friendly" o combustibles alternativos.',
                  style: TextStyle(color: _sec, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    if (_co2e < 1000) return _verde;
    if (_co2e <= 5000) return Colors.amber;
    return Colors.red;
  }

  String _getCategoryText() {
    if (_co2e < 1000) return 'BAJO';
    if (_co2e <= 5000) return 'MEDIO';
    return 'ALTO';
  }

  Widget _buildResultRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _azul),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(color: _texto, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildReportTab() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Metricas del Ano',
                  style: TextStyle(color: _texto, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total CO2e emitido:', style: TextStyle(color: _sec)),
                  Text('45,230 kg',
                      style: TextStyle(
                          color: _texto, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reduccion vs 2023:', style: TextStyle(color: _sec)),
                  Text('-12%',
                      style: TextStyle(
                          color: _verde, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Maritimo vs Aereo:', style: TextStyle(color: _sec)),
                  Text('78% / 22%', style: TextStyle(color: _texto)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Objetivo 2025: -20% vs 2024',
                  style: TextStyle(color: _sec, fontSize: 12)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.6,
                backgroundColor: _bg,
                color: _verde,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _azul)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: _azul, size: 16),
                  SizedBox(width: 8),
                  Text('CBAM - Union Europea',
                      style:
                          TextStyle(color: _azul, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'La UE aplica CBAM desde 2026 para importaciones de acero, aluminio, cemento, electricidad y fertilizantes. Si exportas a Europa, debes reportar contenido de carbono.',
                style: TextStyle(color: _texto, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Descargando reporte ESG...'),
                  backgroundColor: _verde),
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: _azul,
              foregroundColor: _bg,
              padding: const EdgeInsets.all(16)),
          icon: const Icon(Icons.download),
          label: const Text('Descargar Reporte Completo',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
