import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:aduana_801/features/home/widgets/breadcrumb_nav.dart';

class RequisitosProductoScreen extends StatefulWidget {
  const RequisitosProductoScreen({super.key});

  @override
  State<RequisitosProductoScreen> createState() =>
      _RequisitosProductoScreenState();
}

class _RequisitosProductoScreenState extends State<RequisitosProductoScreen> {
  final TextEditingController _productoCtrl = TextEditingController();
  final TextEditingController _paisCtrl = TextEditingController();
  String _uso = 'Vender en México';
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  Future<void> _analizar() async {
    setState(() => _isLoading = true);
    // Simulate AI delay
    await Future<void>.delayed(const Duration(seconds: 2));

    // Mock response
    setState(() {
      _isLoading = false;
      _result = {
        "fraccionProbable": "9503.00.99",
        "arancel": "15%",
        "requierePadron": true,
        "requiereNOM": true,
        "noms": [
          {
            "nom": "NOM-015-SCFI",
            "descripcion": "Información comercial",
            "autoridad": "SE"
          }
        ],
        "requierePermisoPrevio": false,
        "permisos": <Map<String, dynamic>>[],
        "requiereCofepris": false,
        "requiereSenasica": false,
        "documentosNecesarios": [
          "Factura comercial",
          "Packing list",
          "B/L",
          "Certificado de Origen"
        ],
        "alertas": [
          "Verifica que los juguetes no contengan materiales tóxicos restringidos."
        ],
        "tmecAplica": false,
        "resumen":
            "Importar juguetes es común pero requiere cumplir con normas de etiquetado. Necesitarás pagar 15% de arancel y estar en el padrón de importadores."
      };
    });
  }

  @override
  @override
  void dispose() {
    _productoCtrl.dispose();
    _paisCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('Requisitos de Producto',
            style: TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
        bottom: BreadcrumbNav(items: [
          BreadcrumbItem(label: 'Inicio', route: '/'),
          BreadcrumbItem(label: 'Cumplimiento'),
          BreadcrumbItem(label: 'Requisitos de Producto'),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📦 ¿Qué necesito para importar mi producto?',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Describe tu producto en lenguaje simple y te diremos todo lo que necesitas.',
                style: TextStyle(color: AppColors.sub, fontSize: 16)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _productoCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: '¿Qué quieres importar?',
                hintText:
                    'Ej: Juguetes de plástico para niños, Cargadores USB tipo C...',
                hintStyle: const TextStyle(color: AppColors.sub),
                labelStyle: const TextStyle(color: AppColors.sub),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.blue),
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paisCtrl,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: '¿De qué país viene?',
                hintText: 'China, USA, España...',
                hintStyle: const TextStyle(color: AppColors.sub),
                labelStyle: const TextStyle(color: AppColors.sub),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.blue),
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _uso,
              dropdownColor: AppColors.card,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: '¿Para qué lo vas a usar?',
                labelStyle: const TextStyle(color: AppColors.sub),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.blue),
                    borderRadius: BorderRadius.circular(8)),
              ),
              items: ['Vender en México', 'Fabricación', 'Uso interno']
                  .map((String val) {
                return DropdownMenuItem<String>(value: val, child: Text(val));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _uso = val!;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _analizar,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.smart_toy, color: Colors.white),
                label: Text(
                    _isLoading ? 'ANALIZANDO...' : 'ANALIZAR REQUISITOS',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
            if (_result != null) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final res = _result!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.gold, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Resumen',
                  style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 8),
              Text(res['resumen'].toString(),
                  style: const TextStyle(color: AppColors.text, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Fraccion
        _buildChecklistCard(
            '✅ Fracción Arancelaria probable: ${res['fraccionProbable']} | Arancel: ${res['arancel']}',
            AppColors.blue),

        // Padron
        if (res['requierePadron'] as bool)
          _buildChecklistCard('✅ Padrón de Importadores', AppColors.green,
              subtitle: 'Requisito obligatorio para importar.'),

        // NOMs
        if ((res['requiereNOM'] as bool) && res['noms'] != null)
          ...List<Widget>.from((res['noms'] as List).map((nomRaw) {
            final nom = nomRaw as Map<String, dynamic>;
            return _buildChecklistCard('✅ NOM: ${nom['nom']}', Colors.purple,
                subtitle:
                    '${nom['descripcion']} (Autoridad: ${nom['autoridad']})');
          })),

        // Permisos
        if ((res['requierePermisoPrevio'] as bool) && res['permisos'] != null)
          ...List<Widget>.from((res['permisos'] as List).map((pRaw) {
            final p = pRaw as Map<String, dynamic>;
            return _buildChecklistCard(
                '✅ Permiso: ${p['nombre']}', Colors.orange,
                subtitle: 'Autoridad: ${p['autoridad']}');
          })),

        // Cofepris / Senasica
        if (res['requiereCofepris'] as bool)
          _buildChecklistCard('⚠️ Requiere Permiso COFEPRIS', AppColors.red),
        if (res['requiereSenasica'] as bool)
          _buildChecklistCard('⚠️ Requiere Permiso SENASICA', AppColors.green),

        // TMEC
        if (res['tmecAplica'] as bool)
          _buildChecklistCard(
              '🇺🇸🇲🇽 Este producto puede calificar para arancel 0% con TMEC si tienes C.O.',
              AppColors.blue),

        const SizedBox(height: 16),
        const Text('Documentos necesarios:',
            style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 8),
        ...List<Widget>.from((res['documentosNecesarios'] as List).map((d) =>
            Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $d',
                    style: const TextStyle(color: AppColors.text))))),
        const SizedBox(height: 16),

        // Alertas
        if (res['alertas'] != null && (res['alertas'] as List).isNotEmpty)
          ...List<Widget>.from((res['alertas'] as List).map((a) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.red),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppColors.red),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(a.toString(),
                            style: const TextStyle(color: AppColors.red))),
                  ],
                ),
              ))),

        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.card,
                    side: const BorderSide(color: AppColors.border)),
                onPressed: () => context.push('/simple_estimator'),
                child: const Text('Calcular costo',
                    style: TextStyle(color: AppColors.text)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Análisis guardado')));
                },
                child: const Text('Guardar análisis',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChecklistCard(String title, Color color, {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          top: const BorderSide(color: AppColors.border),
          right: const BorderSide(color: AppColors.border),
          bottom: const BorderSide(color: AppColors.border),
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.text, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: AppColors.sub, fontSize: 12)),
          ]
        ],
      ),
    );
  }
}
