import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'dart:async';

const Color _bg    = AppColors.bg;
const Color _card  = AppColors.card;
const Color _bord  = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec   = AppColors.sub;
const Color _gold  = AppColors.gold;
const Color _rojo  = AppColors.red;
const Color _azul  = AppColors.blue;
const Color _verde = AppColors.green;

class DefensaLegalLigieScreen extends StatefulWidget {
  const DefensaLegalLigieScreen({super.key});

  @override
  _DefensaLegalLigieScreenState createState() => _DefensaLegalLigieScreenState();
}

class _DefensaLegalLigieScreenState extends State<DefensaLegalLigieScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final TextEditingController _fraccionSatController = TextEditingController();
  final TextEditingController _fraccionCorrectaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  bool _isAnalyzing = false;
  bool _hasAnalysis = false;
  DateTime? _fechaNotificacion;

  // Analysis results
  double _diferenciaArancelaria = 0.0;
  String _riesgo = '';
  Color _riesgoColor = _verde;
  String _recursoRecomendado = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fraccionSatController.dispose();
    _fraccionCorrectaController.dispose();
    _descripcionController.dispose();
    _valorController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNotificacion ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _azul,
              onPrimary: Colors.white,
              surface: _card,
              onSurface: _texto,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaNotificacion = picked;
        _fechaController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _analizar() {
    if (_fraccionSatController.text.isEmpty ||
        _fraccionCorrectaController.text.isEmpty ||
        _valorController.text.isEmpty ||
        _fechaNotificacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete los campos obligatorios.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _hasAnalysis = false;
    });

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      final valor = double.tryParse(_valorController.text) ?? 0.0;
      final diff = valor * 0.15; // Mock calculation
      
      String risk = 'MEDIO';
      Color riskColor = _gold;
      String resource = 'Recurso de Revocación';
      
      if (diff > 50000) {
        risk = 'ALTO';
        riskColor = _rojo;
        resource = 'Juicio Contencioso Administrativo';
      } else if (diff < 10000) {
        risk = 'BAJO';
        riskColor = _verde;
      }

      setState(() {
        _isAnalyzing = false;
        _hasAnalysis = true;
        _diferenciaArancelaria = diff;
        _riesgo = risk;
        _riesgoColor = riskColor;
        _recursoRecomendado = resource;
      });
    });
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, VoidCallback? onTap, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(color: _texto),
        onTap: onTap,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _sec),
          filled: true,
          fillColor: _bg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _bord),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _bord),
          ),
        ),
      ),
    );
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
        title: const Text('Defensa Legal LIGIE', style: TextStyle(color: _texto)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _azul,
          labelColor: _azul,
          unselectedLabelColor: _sec,
          tabs: const [
            Tab(text: 'Análisis'),
            Tab(text: 'Argumentos'),
            Tab(text: 'Plazos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Prevent swipe to disabled tabs
        children: [
          _buildAnalisisTab(),
          _buildArgumentosTab(),
          _buildPlazosTab(),
        ],
      ),
    );
  }

  Widget _buildAnalisisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Datos del Caso', style: TextStyle(color: _texto, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(_fraccionSatController, 'Fracción SAT (Determinada)'),
                _buildTextField(_fraccionCorrectaController, 'Fracción Correcta (Importador)'),
                _buildTextField(_descripcionController, 'Descripción detallada de mercancía'),
                _buildTextField(_valorController, 'Valor comercial en USD', isNumber: true),
                _buildTextField(
                  _fechaController, 
                  'Fecha de notificación del SAT', 
                  readOnly: true, 
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAnalyzing ? null : _analizar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _azul,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isAnalyzing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Analizar Clasificación', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          if (_hasAnalysis) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _bord),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resultados del Análisis', style: TextStyle(color: _texto, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildAnalysisRow('Diferencia arancelaria estimada:', '\$${_diferenciaArancelaria.toStringAsFixed(2)}', _texto),
                  const SizedBox(height: 12),
                  _buildAnalysisRow('Riesgo de la defensa:', _riesgo, _riesgoColor),
                  const SizedBox(height: 12),
                  const Text('Tipo de recurso recomendado:', style: TextStyle(color: _sec)),
                  const SizedBox(height: 4),
                  Text(_recursoRecomendado, style: const TextStyle(color: _azul, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: _sec))),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildArgumentosTab() {
    if (!_hasAnalysis) {
      return const Center(
        child: Text('Complete el análisis primero', style: TextStyle(color: _sec, fontSize: 16)),
      );
    }

    final List<Map<String, String>> reglas = [
      {
        'regla': 'Regla 1',
        'desc': 'La clasificación se determina por los textos de las partidas y notas de sección/capítulo.',
        'aplica': 'Se demostrará que el texto de la partida propuesta describe mejor la mercancía que la del SAT.'
      },
      {
        'regla': 'Regla 3a',
        'desc': 'La partida más específica tiene preferencia sobre la más general.',
        'aplica': 'La fracción del importador es más específica en su descripción comercial y técnica.'
      },
      {
        'regla': 'Regla 3b',
        'desc': 'Las mezclas se clasifican según el material o componente que les da carácter esencial.',
        'aplica': 'El componente principal de la mercancía encuadra en la fracción propuesta.'
      },
      {
        'regla': 'Regla 6',
        'desc': 'La clasificación de subpartidas se determina por los textos de las propias subpartidas.',
        'aplica': 'A nivel subpartida, las notas legales apoyan la clasificación del importador.'
      },
    ];

    final List<String> documentos = [
      'Factura comercial',
      'BL / Guía aérea',
      'Catálogo del fabricante',
      'Ficha técnica',
      'Análisis químico (si aplica)',
      'Certificado de origen',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Argumentos (Reglas Generales LIGIE)', style: TextStyle(color: _texto, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                for (final regla in reglas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(regla['regla']!, style: const TextStyle(color: _gold, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(regla['desc']!, style: const TextStyle(color: _texto)),
                        const SizedBox(height: 4),
                        Text('Aplicación: ${regla['aplica']}', style: const TextStyle(color: _sec, fontStyle: FontStyle.italic)),
                      ],
                    ),
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
              border: Border.all(color: _bord),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Artículos CFF Aplicables', style: TextStyle(color: _texto, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('• Art. 42 (Facultades de comprobación)', style: TextStyle(color: _texto)),
                Text('• Art. 145 (Procedimiento administrativo)', style: TextStyle(color: _texto)),
                Text('• Art. 152 (Reconocimiento aduanero)', style: TextStyle(color: _texto)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Documentación Requerida', style: TextStyle(color: _texto, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                for (final doc in documentos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: _verde, size: 20),
                        const SizedBox(width: 8),
                        Text(doc, style: const TextStyle(color: _texto)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlazosTab() {
    if (!_hasAnalysis || _fechaNotificacion == null) {
      return const Center(
        child: Text('Complete el análisis primero', style: TextStyle(color: _sec, fontSize: 16)),
      );
    }

    // Calcular fechas (mock simple omitiendo festivos exactos para simplificar)
    final d0 = _fechaNotificacion!;
    final revDate = d0.add(const Duration(days: 42)); // Aprox 30 hábiles
    final juicioDate = d0.add(const Duration(days: 42)); // Aprox 30 hábiles
    final amparoDate = d0.add(const Duration(days: 63)); // Aprox 45 hábiles
    
    final today = DateTime.now();
    final daysToRev = revDate.difference(today).inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (daysToRev >= 0 && daysToRev < 5)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _rojo.withValues(alpha: 0.1),
                border: Border.all(color: _rojo),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: _rojo),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡ATENCIÓN! Quedan menos de 5 días hábiles para presentar la defensa.',
                      style: TextStyle(color: _rojo, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _bord),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimelineItem(
                  title: 'D+0: Inicio del plazo legal',
                  subtitle: 'Fecha notificación: ${_formatDate(d0)}',
                  icon: Icons.calendar_today,
                  color: _sec,
                ),
                _buildTimelineItem(
                  title: 'D+30: LÍMITE Recurso Revocación',
                  subtitle: 'Art. 121 CFF - Vence aprox: ${_formatDate(revDate)}',
                  icon: Icons.gavel,
                  color: _gold,
                  daysRemaining: daysToRev,
                ),
                _buildTimelineItem(
                  title: 'D+30: LÍMITE Juicio Contencioso',
                  subtitle: 'Art. 13 LFPCA - Vence aprox: ${_formatDate(juicioDate)}',
                  icon: Icons.account_balance,
                  color: _gold,
                  daysRemaining: juicioDate.difference(today).inDays,
                ),
                _buildTimelineItem(
                  title: 'D+45: Amparo Directo (Último)',
                  subtitle: 'Vence aprox: ${_formatDate(amparoDate)}',
                  icon: Icons.shield,
                  color: _rojo,
                  daysRemaining: amparoDate.difference(today).inDays,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plazos agregados a la agenda'),
                    backgroundColor: _verde,
                  ),
                );
              },
              icon: const Icon(Icons.event_available, color: Colors.white),
              label: const Text('Agregar a mi Agenda', style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _azul,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    int? daysRemaining,
    bool isLast = false,
  }) {
    final bool isOverdue = daysRemaining != null && daysRemaining < 0;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: _bord,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: _sec)),
                  if (daysRemaining != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOverdue ? _rojo.withValues(alpha: 0.2) : _verde.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: isOverdue ? _rojo : _verde),
                      ),
                      child: Text(
                        isOverdue ? 'Vencido por ${-daysRemaining} días' : 'Faltan $daysRemaining días',
                        style: TextStyle(
                          color: isOverdue ? _rojo : _verde,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

