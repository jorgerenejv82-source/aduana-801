import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';

class QuickCalculatorWidget extends StatefulWidget {
  const QuickCalculatorWidget({super.key});

  @override
  State<QuickCalculatorWidget> createState() => _QuickCalculatorWidgetState();
}

class _QuickCalculatorWidgetState extends State<QuickCalculatorWidget> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  String _selectedOrigin = 'China';

  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;

  Future<void> _estimateTaxes() async {
    final item = _itemController.text.trim();
    final valueStr = _valueController.text.trim();

    if (item.isEmpty || valueStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa la mercancía y el valor estimado.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
      _errorMessage = null;
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
          'Eres un experto en aduanas. Estima los impuestos de importación para un principiante en México basado en la mercancía, valor y origen. Devuelve SOLAMENTE un JSON: {"arancel_aprox_pct": 0, "iva_pct": 16, "dta_fijo": 0, "total_impuestos_usd": 0, "explicacion_amigable_corta": ""}',
        ),
      );

      final prompt =
          'Mercancía: $item, Valor: $valueStr USD, Origen: $_selectedOrigin';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text != null) {
        // Clean markdown JSON formatting if any
        final jsonString =
            text.replaceAll('```json', '').replaceAll('```', '').trim();
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        setState(() {
          _result = decoded;
        });
      } else {
        setState(() {
          _errorMessage = 'No se pudo generar la estimación. Intenta de nuevo.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al calcular impuestos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF475569)),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Calculadora Rápida de Impuestos',
              style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _itemController,
              style: const TextStyle(color: Color(0xFFF8FAFC)),
              decoration: InputDecoration(
                labelText: '¿Qué vas a traer?',
                hintText: 'Ej. Laptops, Tenis, Ropa',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                hintStyle: const TextStyle(color: Color(0xFF475569)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF475569)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Valor estimado total (USD)',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF475569)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedOrigin,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                    decoration: InputDecoration(
                      labelText: 'País de origen',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF475569)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'China', child: Text('China')),
                      DropdownMenuItem(value: 'USA', child: Text('USA')),
                      DropdownMenuItem(value: 'Europa', child: Text('Europa')),
                      DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedOrigin = val);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _estimateTaxes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _isLoading ? 'Estimando...' : 'Estimar con IA',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.red),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF475569)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resultados Estimados',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                        'Arancel aprox.', '${_result!["arancel_aprox_pct"]}%'),
                    _buildResultRow('IVA', '${_result!["iva_pct"]}%'),
                    _buildResultRow(
                        'DTA fijo', '\$${_result!["dta_fijo"]} MXN'),
                    const Divider(color: Color(0xFF475569), height: 24),
                    _buildResultRow(
                      'Total Impuestos Aprox.',
                      '\$${_result!["total_impuestos_usd"]} USD',
                      isTotal: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      (_result!["explicacion_amigable_corta"] ?? '') as String,
                      style: const TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color:
                  isTotal ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? AppColors.green : const Color(0xFFF8FAFC),
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
