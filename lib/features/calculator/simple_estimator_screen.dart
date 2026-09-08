// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';
import 'package:aduana_801/core/theme/app_colors.dart';

class SimpleEstimatorScreen extends StatefulWidget {
  const SimpleEstimatorScreen({super.key});

  @override
  State<SimpleEstimatorScreen> createState() => _SimpleEstimatorScreenState();
}

class _SimpleEstimatorScreenState extends State<SimpleEstimatorScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1
  final _productoCtrl = TextEditingController();
  final _paisCtrl = TextEditingController();
  String _uso = 'Para vender en México';
  final _cantidadCtrl = TextEditingController();

  // Step 2
  final _precioCtrl = TextEditingController();
  String _incoterm = 'No sé';
  final _pesoCtrl = TextEditingController();
  final _tcCtrl = TextEditingController(text: '17.15');

  // Step 3
  String _fleteTipo = 'maritimo';
  final _fleteCostCtrl = TextEditingController();
  final _seguroCostCtrl = TextEditingController();

  // Step 4
  final _arancelCtrl = TextEditingController(text: '0');
  bool _tlc = false;
  bool _requiereNom = false;

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _productoCtrl.dispose();
    _paisCtrl.dispose();
    _cantidadCtrl.dispose();
    _precioCtrl.dispose();
    _pesoCtrl.dispose();
    _tcCtrl.dispose();
    _fleteCostCtrl.dispose();
    _seguroCostCtrl.dispose();
    _arancelCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _buscarArancel() async {
    final producto = _productoCtrl.text.trim();
    if (producto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Primero ingresa tu producto en el Paso 1')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt =
          'Para el producto: $producto de ${_paisCtrl.text}, cuál es el arancel IGI aproximado en la TIGIE de México? Responde solo con el porcentaje numérico (ej: 10 para 10%) y una fracción arancelaria probable. JSON: {"igi": 10, "fraccion": "6109.10.01", "nota": "texto breve"}';

      final response = await model.generateContent([Content.text(prompt)]);

      String text = response.text ?? '{}';
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = jsonDecode(text) as Map<String, dynamic>;

      setState(() {
        _arancelCtrl.text = data['igi']?.toString() ?? '15';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('IA Sugiere: ${data['fraccion']} - ${data['nota']}',
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.green));
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Error AI: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('estimados_importacion')
            .add({
          'uid': user.uid,
          'producto': _productoCtrl.text,
          'pais': _paisCtrl.text,
          'precio_usd': double.tryParse(_precioCtrl.text) ?? 0,
          'fecha': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Estimado guardado en Firestore'),
            backgroundColor: AppColors.green));
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.sub),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('PASO 1: Tu producto',
            style: TextStyle(
                color: AppColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildTextField(
            _productoCtrl, '¿Qué quieres importar? (ej: Playeras de algodón)'),
        _buildTextField(_paisCtrl, '¿De qué país viene?'),
        const Text('¿Para qué lo vas a usar?',
            style: TextStyle(color: AppColors.sub, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _uso,
              dropdownColor: AppColors.card,
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: [
                'Para vender en México',
                'Para fabricar y exportar',
                'Para uso propio de mi empresa'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _uso = v!),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(_cantidadCtrl, '¿Cuántas piezas/kilos/unidades?',
            isNumber: true),
      ],
    );
  }

  Widget _buildStep2() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('PASO 2: El precio de tu proveedor',
            style: TextStyle(
                color: AppColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildTextField(
            _precioCtrl, '¿Cuánto te cobra tu proveedor? (total USD)',
            isNumber: true),
        const Text('¿Ese precio incluye el flete hasta México?',
            style: TextStyle(color: AppColors.sub, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _incoterm,
              dropdownColor: AppColors.card,
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: [
                'No, sólo hasta el barco (FOB)',
                'Sí, incluye flete y seguro (CIF)',
                'No sé'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _incoterm = v!),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_incoterm != 'Sí, incluye flete y seguro (CIF)')
          _buildTextField(
              _pesoCtrl, '¿Cuánto pesa aproximadamente tu pedido? (kg)',
              isNumber: true),
        _buildTextField(_tcCtrl, 'Tipo de cambio (MXN/USD)', isNumber: true),
      ],
    );
  }

  Widget _buildStep3() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('PASO 3: El flete',
            style: TextStyle(
                color: AppColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        if (_incoterm == 'Sí, incluye flete y seguro (CIF)')
          const Text(
              'Tu proveedor ya incluyó flete y seguro. Puedes saltar este paso.',
              style: TextStyle(color: Colors.white, fontSize: 16))
        else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile<String>(
                  title: const Text(
                      '🚢 Marítimo Asia → México\nFCL 20 pies: ~\$2,500 USD | FCL 40 pies: ~\$4,000 USD | LCL: \$80-150/CBM',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: 'maritimo',
                  groupValue: _fleteTipo,
                  onChanged: (v) => setState(() => _fleteTipo = v!),
                  activeColor: AppColors.gold,
                ),
                RadioListTile<String>(
                  title: const Text(
                      '✈️ Aéreo Asia → México\n~\$4-8 USD/kg (dep. temporada)',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: 'aereo',
                  groupValue: _fleteTipo,
                  onChanged: (v) => setState(() => _fleteTipo = v!),
                  activeColor: AppColors.gold,
                ),
                RadioListTile<String>(
                  title: const Text(
                      '🚛 Terrestre USA → México\n~\$1,500-3,000 USD por camión',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: 'terrestre',
                  groupValue: _fleteTipo,
                  onChanged: (v) => setState(() => _fleteTipo = v!),
                  activeColor: AppColors.gold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(_fleteCostCtrl, 'Cotización de flete (USD)',
              isNumber: true),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(_seguroCostCtrl, 'Seguro (USD)',
                      isNumber: true)),
              IconButton(
                icon: const Icon(Icons.auto_awesome, color: AppColors.gold),
                tooltip: 'Sugerir (~1%)',
                onPressed: () {
                  final precio = double.tryParse(_precioCtrl.text) ?? 0;
                  _seguroCostCtrl.text = (precio * 0.01).toStringAsFixed(2);
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStep4() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('PASO 4: Configuración final',
            style: TextStyle(
                color: AppColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _buildTextField(
                    _arancelCtrl, '¿Cuál es el arancel de tu producto? (%)',
                    isNumber: true)),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _buscarArancel,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  padding: const EdgeInsets.symmetric(vertical: 20)),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: AppColors.bg))
                  : const Text('🤖', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text(
              '¿Tiene Tratado de Libre Comercio? (TMEC si viene de USA/Canadá)',
              style: TextStyle(color: Colors.white)),
          value: _tlc,
          activeTrackColor: AppColors.gold,
          onChanged: (v) {
            setState(() {
              _tlc = v;
              if (v) _arancelCtrl.text = '0';
            });
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('¿Tu producto requiere NOM o permiso especial?',
              style: TextStyle(color: Colors.white)),
          value: _requiereNom,
          activeTrackColor: AppColors.gold,
          onChanged: (v) => setState(() => _requiereNom = v),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final precioUSD = double.tryParse(_precioCtrl.text) ?? 0;
    final fleteUSD = double.tryParse(_fleteCostCtrl.text) ?? 0;
    final seguroUSD = double.tryParse(_seguroCostCtrl.text) ?? 0;
    final arancel = double.tryParse(_arancelCtrl.text) ?? 0;
    final tc = double.tryParse(_tcCtrl.text) ?? 17.15;

    final precioMXN = precioUSD * tc;
    final fleteSeguroMXN = (fleteUSD + seguroUSD) * tc;
    final valorAduanaMXN = precioMXN + fleteSeguroMXN;

    final igiMXN = valorAduanaMXN * (arancel / 100);
    final dtaMXN = (valorAduanaMXN * 0.008).clamp(423.0, 914.0); // Simplified
    final ivaMXN = (valorAduanaMXN + igiMXN + dtaMXN) * 0.16;

    const agenteMXN = 5000.0;
    const maniobrasMXN = 2500.0;
    final prvMXN = _requiereNom ? 1500.0 : 0.0;

    final totalLandedMXN = valorAduanaMXN +
        igiMXN +
        dtaMXN +
        ivaMXN +
        agenteMXN +
        maniobrasMXN +
        prvMXN;
    final cantidad = double.tryParse(_cantidadCtrl.text) ?? 1;
    final costoUnitarioMXN =
        cantidad > 0 ? totalLandedMXN / cantidad : totalLandedMXN;

    String formatMXN(double v) => '\$${v.toStringAsFixed(2)}';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('RESULTADO ESTIMADO',
            style: TextStyle(
                color: AppColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📦 Tu mercancía puesta en México:',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                  'Precio de compra: ${formatMXN(precioUSD)} USD = ${formatMXN(precioMXN)} MXN',
                  style: const TextStyle(color: AppColors.sub, fontSize: 14)),
              Text('Flete + Seguro: + ${formatMXN(fleteSeguroMXN)} MXN',
                  style: const TextStyle(color: AppColors.sub, fontSize: 14)),
              const SizedBox(height: 8),
              const Text('Impuestos:',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text('  Arancel (IGI $arancel%): + ${formatMXN(igiMXN)} MXN',
                  style: const TextStyle(color: AppColors.sub, fontSize: 14)),
              Text('  DTA: + ${formatMXN(dtaMXN)} MXN',
                  style: const TextStyle(color: AppColors.sub, fontSize: 14)),
              Text('  IVA (16%): + ${formatMXN(ivaMXN)} MXN',
                  style: const TextStyle(color: AppColors.sub, fontSize: 14)),
              const SizedBox(height: 8),
              const Text('Servicios:',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text('  Agente Aduanal est.: + ${formatMXN(agenteMXN)} MXN',
                  style: const TextStyle(color: AppColors.sub, fontSize: 14)),
              Text('  Maniobras est.: + ${formatMXN(maniobrasMXN)} MXN',
                  style: const TextStyle(color: AppColors.sub, fontSize: 14)),
              if (_requiereNom)
                Text('  PRV: + ${formatMXN(prvMXN)} MXN',
                    style: const TextStyle(color: AppColors.sub, fontSize: 14)),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppColors.border)),
              const Text('COSTO TOTAL ESTIMADO:',
                  style: TextStyle(color: AppColors.sub, fontSize: 14)),
              Text('${formatMXN(totalLandedMXN)} MXN',
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Costo por unidad: ${formatMXN(costoUnitarioMXN)} MXN',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold)),
          child: const Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.gold),
              SizedBox(width: 16),
              Expanded(
                  child: Text(
                      'Este es un estimado orientativo. Los impuestos exactos dependen de la fracción arancelaria confirmada por tu agente aduanal.',
                      style: TextStyle(color: AppColors.gold, fontSize: 12))),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.push('/landed_cost'),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Ver cálculo detallado',
                    style: TextStyle(color: AppColors.blue)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Guardar estimado',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
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
        title: const Text('📦 ¿Cuánto me cuesta importar?',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gold),
            onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
                'Responde estas preguntas simples y te decimos el costo estimado total puesto en tu almacén.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildResult(),
              ],
            ),
          ),
          if (_currentStep < 4)
            Container(
              padding: const EdgeInsets.all(24),
              color: AppColors.card,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                        onPressed: _prevStep,
                        child: const Text('Atrás',
                            style:
                                TextStyle(color: AppColors.sub, fontSize: 16)))
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16)),
                    child: Text(
                        _currentStep == 3 ? 'Ver Resultado' : 'Siguiente',
                        style: const TextStyle(
                            color: AppColors.bg, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
