import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';

// â”€â”€ Design Tokens â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _verde = AppColors.green;
const Color _azul = AppColors.blue;

// â”€â”€ Catálogos â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const _countries = [
  'Mexico (MX)',
  'USA (US)',
  'Canada (CA)',
  'China (CN)',
  'Alemania (DE)',
  'Japan (JP)',
  'Korea (KR)',
  'Vietnam (VN)',
  'India (IN)',
  'Brasil (BR)',
  'Francia (FR)',
  'Italia (IT)'
];
const _capitulos = [
  '01 â€“ Animales vivos',
  '39 â€“ Plasticos y manufacturas',
  '61 â€“ Prendas y complementos de punto',
  '62 â€“ Prendas y complementos excepto de punto',
  '72 â€“ Hierro y acero',
  '73 â€“ Manufacturas de hierro o acero',
  '84 â€“ Reactores nucleares, calderas, maquinas',
  '85 â€“ Maquinas aparatos y material electrico',
  '87 â€“ Vehiculos automoviles, tractores',
  '90 â€“ Instrumentos de optica, medida',
  '94 â€“ Muebles, mobiliario medico',
  '95 â€“ Juguetes, juegos, articulos de deporte',
];

// â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AuditorTmecBomScreen extends StatefulWidget {
  const AuditorTmecBomScreen({super.key});
  @override
  State<AuditorTmecBomScreen> createState() => _AuditorTmecBomScreenState();
}

class _AuditorTmecBomScreenState extends State<AuditorTmecBomScreen> {
  // â”€â”€ BOM (Bill of Materials) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final _productCtrl = TextEditingController();
  final _fraccionCtrl = TextEditingController();
  String _capituloSel = '85 â€“ Maquinas aparatos y material electrico';
  final List<_Material> _materiales = [];
  bool _calculando = false;
  double? _vrn; // Valor de Contenido Regional calculado

  // â”€â”€ Resultado â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool _aprueba = false;

  @override
  void dispose() {
    
    
    _productCtrl.dispose();
    _fraccionCtrl.dispose();
    super.dispose();
  }

  double get _costoTotal => _materiales.fold(0, (s, m) => s + m.costo);
  double get _costoOriginario =>
      _materiales.where((m) => m.originario).fold(0, (s, m) => s + m.costo);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          leading: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back, color: _ambar)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: _ambar.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _ambar.withValues(alpha: 0.3))),
                child: const Icon(Icons.verified_user, color: _ambar, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Auditor T-MEC / BOM',
                  style: TextStyle(
                      color: _ambar,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _ambar.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _ambar.withValues(alpha: 0.4))),
                child: const Text('USMCA / T-MEC',
                    style: TextStyle(
                        color: _ambar,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _intro(),
                    const SizedBox(height: 24),
                    _secProducto(),
                    const SizedBox(height: 24),
                    _secMateriales(),
                    const SizedBox(height: 24),
                    _botonCalcular(),
                    if (_vrn != null) ...[
                      const SizedBox(height: 24),
                      _resultado()
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _intro() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bord)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: _ambar.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _ambar.withValues(alpha: 0.3))),
              child:
                  const Icon(Icons.calculate_outlined, color: _ambar, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cálculo de Valor de Contenido Regional (VCR)',
                      style: TextStyle(
                          color: _texto,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      'Determina si tu producto califica como originario del T-MEC/USMCA. Registra los materiales del BOM con su origen y costo. El sistema calculará el VCR y determinará el método aplicable (Transacción o Costo Neto).',
                      style: TextStyle(color: _sec, fontSize: 13, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _secProducto() =>
      _seccion('Producto Final', Icons.inventory_2_outlined, _azul, [
        TextField(
          controller: _productCtrl,
          style: const TextStyle(color: _texto, fontSize: 14),
          decoration: _dec('Descripción del producto terminado'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _fraccionCtrl,
                style: const TextStyle(color: _texto, fontSize: 14),
                decoration: _dec('Fracción arancelaria (HS Code)'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Capítulo LIGIE',
                      style: TextStyle(
                          color: _sec,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _ddrop(_capitulos, _capituloSel,
                      (v) => setState(() => _capituloSel = v!)),
                ],
              ),
            ),
          ],
        ),
      ]);

  Widget _secMateriales() => _seccion(
          'Lista de Materiales (BOM)', Icons.format_list_bulleted, _ambar, [
        if (_materiales.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.layers_outlined,
                      color: _sec.withValues(alpha: 0.5), size: 48),
                  const SizedBox(height: 12),
                  const Text(
                      'No hay materiales. Agrega los componentes del producto.',
                      style: TextStyle(color: _sec, fontSize: 14),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ..._materiales.asMap().entries.map((e) => _materialRow(e.key, e.value)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _dialogAgregarMaterial,
            icon: const Icon(Icons.add, size: 16, color: _ambar),
            label: const Text('Agregar Material',
                style: TextStyle(
                    color: _ambar, fontSize: 14, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _ambar, width: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ]);

  Widget _materialRow(int idx, _Material m) => _MaterialRowWidget(
        m: m,
        onDelete: () => setState(() => _materiales.removeAt(idx)),
      );

  Widget _botonCalcular() => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _materiales.isEmpty || _calculando ? null : _calcularVCR,
          icon: _calculando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: _bg, strokeWidth: 2))
              : const Icon(Icons.calculate, size: 20, color: _bg),
          label: Text(
            _calculando
                ? 'Calculando VCR...'
                : 'Calcular Valor de Contenido Regional',
            style: const TextStyle(
                color: _bg, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _ambar,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  Widget _resultado() {
    final pct = ((_vrn ?? 0) * 100).toStringAsFixed(1);
    final c = _aprueba ? _verde : _rojo;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                  color: c.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: c.withValues(alpha: 0.3))),
                    child: Center(
                        child: Text('$pct%',
                            style: TextStyle(
                                color: c,
                                fontSize: 18,
                                fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VCR: $pct%',
                            style: TextStyle(
                                color: c,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          _aprueba
                              ? 'CALIFICA como producto originario T-MEC'
                              : 'NO califica â€” VCR mínimo: 60% (Transacción) / 50% (Costo Neto)',
                          style: TextStyle(
                              color: _aprueba ? _verde : _rojo,
                              fontSize: 13,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  Icon(_aprueba ? Icons.verified : Icons.cancel_outlined,
                      color: c, size: 40),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: _bord),
              const SizedBox(height: 20),
              Row(
                children: [
                  _vcrStat('Costo Total', '\$${_costoTotal.toStringAsFixed(2)}',
                      _sec),
                  _vcrStat('Originario',
                      '\$${_costoOriginario.toStringAsFixed(2)}', _verde),
                  _vcrStat(
                      'No Originario',
                      '\$${(_costoTotal - _costoOriginario).toStringAsFixed(2)}',
                      _rojo),
                  _vcrStat('VCR (Transacción)', '$pct%', c),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _bord),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Interpretación de Resultados:',
                  style: TextStyle(
                      color: _ambar,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                      ((_vrn ?? 0) * 100) >= 60
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: ((_vrn ?? 0) * 100) >= 60 ? _verde : _rojo,
                      size: 16),
                  const SizedBox(width: 8),
                  Text('Método de Transacción: VCR >= 60%',
                      style: TextStyle(
                          color: ((_vrn ?? 0) * 100) >= 60 ? _verde : _rojo,
                          fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                      ((_vrn ?? 0) * 100) >= 50
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: ((_vrn ?? 0) * 100) >= 50 ? _verde : _rojo,
                      size: 16),
                  const SizedBox(width: 8),
                  Text('Método de Costo Neto:  VCR >= 50%',
                      style: TextStyle(
                          color: ((_vrn ?? 0) * 100) >= 50 ? _verde : _rojo,
                          fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vcrStat(String l, String v, Color c) => Expanded(
        child: Column(
          children: [
            Text(v,
                style: TextStyle(
                    color: c, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(l,
                style: const TextStyle(color: _sec, fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      );

  // â”€â”€ Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _calcularVCR() async {
    setState(() => _calculando = true);
    try {
      final model = FirebaseAI.vertexAI().generativeModel(
          model: 'gemini-1.5-flash',
          systemInstruction: Content.system(
              'Eres un experto en Reglas de Origen del T-MEC (USMCA) y analisis de Bill of Materials. Analiza la BOM proporcionada para determinar si la mercancia califica para preferencias del T-MEC. Calcula el VCR (Valor de Contenido Regional) y determina el criterio de origen aplicable. Responde en JSON: {"califica": true, "criterio": "string", "vcr": 65.5, "deficiencias": ["string"], "recomendaciones": ["string"]}'));

      final bomText = _materiales
          .map((m) =>
              '${m.descripcion}: \$${m.costo} (${m.pais} - ${m.originario ? "Originario" : "No Originario"})')
          .join(', ');
      final prompt =
          'Producto: ${_productCtrl.text}. Fraccion: ${_fraccionCtrl.text}. Materiales: $bomText';

      final res = await model.generateContent([Content.text(prompt)]);
      final text =
          res.text?.replaceAll('```json', '').replaceAll('```', '').trim() ??
              '{}';
      final data = jsonDecode(text) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        _calculando = false;
        _vrn = (data['vcr'] is num)
            ? (data['vcr'] as num).toDouble() / 100.0
            : (_costoTotal > 0 ? _costoOriginario / _costoTotal : 0.0);
        _aprueba = data['califica'] == true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _calculando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error AI: $e'), backgroundColor: _rojo));
    }
  }

  void _dialogAgregarMaterial() {
    final descCtrl = TextEditingController();
    final costoCtrl = TextEditingController();
    String pais = 'Mexico (MX)';
    bool originario = true;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => StatefulBuilder(
        builder: (ctx, ss) => Dialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: _bord)),
          child: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: _bg,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(bottom: BorderSide(color: _bord)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_box_outlined,
                          color: _ambar, size: 20),
                      const SizedBox(width: 12),
                      const Text('Agregar Material',
                          style: TextStyle(
                              color: _texto,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      InkWell(
                          onTap: () => Navigator.pop(ctx),
                          child:
                              const Icon(Icons.close, color: _sec, size: 20)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: descCtrl,
                        style: const TextStyle(color: _texto, fontSize: 14),
                        decoration:
                            _dec('Descripción del material / componente'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: costoCtrl,
                              keyboardType: TextInputType.number,
                              style:
                                  const TextStyle(color: _texto, fontSize: 14),
                              decoration: _dec('Costo USD'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('País de Origen',
                                    style: TextStyle(
                                        color: _sec,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                _ddrop(_countries, pais,
                                    (v) => ss(() => pais = v!)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: originario
                                  ? _verde.withValues(alpha: 0.5)
                                  : _rojo.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Text('¿Es material originario T-MEC?',
                                style: TextStyle(
                                    color: _texto,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Switch(
                              value: originario,
                              onChanged: (v) => ss(() => originario = v),
                              activeThumbColor: _verde,
                              inactiveThumbColor: _rojo,
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                originario ? 'Sí' : 'No',
                                style: TextStyle(
                                    color: originario ? _verde : _rojo,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _materiales.add(_Material(
                                  descripcion: descCtrl.text.isEmpty
                                      ? 'Material'
                                      : descCtrl.text,
                                  costo: double.tryParse(costoCtrl.text) ?? 0,
                                  pais: pais,
                                  originario: originario,
                                )));
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _ambar,
                            foregroundColor: _bg,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Agregar al BOM',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _seccion(
          String titulo, IconData icon, Color c, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _bord),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: c, size: 20),
                ),
                const SizedBox(width: 12),
                Text(titulo,
                    style: TextStyle(
                        color: c, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      );

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _sec),
        filled: true,
        fillColor: _bg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _bord)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _bord)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _ambar)),
      );

  Widget _ddrop(List<String> opts, String val, ValueChanged<String?> onCh) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _bord)),
        child: DropdownButton<String>(
          value: opts.contains(val) ? val : opts.first,
          isExpanded: true,
          dropdownColor: _card,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, color: _ambar, size: 20),
          style: const TextStyle(color: _texto, fontSize: 14),
          items: opts
              .map((o) => DropdownMenuItem(
                  value: o, child: Text(o, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onCh,
        ),
      );
}

class _Material {
  String descripcion;
  double costo;
  String pais;
  bool originario;
  _Material(
      {required this.descripcion,
      required this.costo,
      required this.pais,
      required this.originario});
}

class _MaterialRowWidget extends StatefulWidget {
  final _Material m;
  final VoidCallback onDelete;
  const _MaterialRowWidget({required this.m, required this.onDelete});

  @override
  State<_MaterialRowWidget> createState() => _MaterialRowWidgetState();
}

class _MaterialRowWidgetState extends State<_MaterialRowWidget> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _hover ? const Color(0xFF14243D) : _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: widget.m.originario
                  ? _verde.withValues(alpha: 0.5)
                  : _rojo.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: widget.m.originario ? _verde : _rojo,
                    shape: BoxShape.circle)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.m.descripcion,
                      style: const TextStyle(
                          color: _texto,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                      '${widget.m.pais}  ·  \$${widget.m.costo.toStringAsFixed(2)} USD',
                      style: const TextStyle(color: _sec, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.m.originario
                    ? _verde.withValues(alpha: 0.1)
                    : _rojo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: widget.m.originario
                        ? _verde.withValues(alpha: 0.3)
                        : _rojo.withValues(alpha: 0.3)),
              ),
              child: Text(
                widget.m.originario ? 'Originario' : 'No Originario',
                style: TextStyle(
                    color: widget.m.originario ? _verde : _rojo,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _rojo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child:
                      const Icon(Icons.delete_outline, color: _rojo, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
