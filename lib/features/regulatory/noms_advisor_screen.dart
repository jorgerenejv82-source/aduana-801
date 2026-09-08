import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/nom_requirement_model.dart';
import 'services/noms_pdf_service.dart';

class NomsAdvisorScreen extends StatefulWidget {
  const NomsAdvisorScreen({super.key});

  @override
  State<NomsAdvisorScreen> createState() => _NomsAdvisorScreenState();
}

class _NomsAdvisorScreenState extends State<NomsAdvisorScreen> {
  final _hsCtrl = TextEditingController();
  NomRequirement? _result;
  bool _isLoading = false;

  void _consultar() async {
    final hs = _hsCtrl.text.trim();
    if (hs.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    // Simulacin Anti-Mock: en un escenario real, consultaramos un motor de reglas
    // (Ej. Firebase Vertex AI pasndole la fraccin). Para efectos demostrativos
    // sin el backend de IA activo para esto, inyectamos la respuesta simulada del motor.
    await Future<void>.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      if (hs.startsWith('8543')) {
        _result = NomRequirement(
          id: '1',
          hsCode: hs,
          productName: 'Mquinas y aparatos elctricos',
          requiredNoms: [
            'NOM-001-SCFI-2018 (Seguridad Electrnica)',
            'NOM-024-SCFI-2013 (Informacin Comercial)'
          ],
          requiredPermits: [],
          recommendations:
              'Asegrate de enviar manuales y garantas en espaol antes de embarcar.',
        );
      } else if (hs.startsWith('3004')) {
        _result = NomRequirement(
          id: '2',
          hsCode: hs,
          productName: 'Medicamentos y frmacos',
          requiredNoms: ['NOM-072-SSA1-2012 (Etiquetado Medicamentos)'],
          requiredPermits: [
            'Permiso Sanitario Previo de Importacin (COFEPRIS)',
            'Registro Sanitario'
          ],
          recommendations:
              'Trmite crtico: Obtn el permiso sanitario ANTES de pagarle al proveedor en China.',
        );
      } else {
        _result = NomRequirement(
          id: '3',
          hsCode: hs,
          productName: 'Mercanca General (Fraccin $hs)',
          requiredNoms: ['NOM-050-SCFI-2004 (Etiquetado General)'],
          requiredPermits: [],
          recommendations:
              'Mercanca de fcil importacin. Solo etiqueta de informacin comercial (origen, importador, RFC).',
        );
      }
    });
  }

  @override
  void dispose() {
    _hsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gold),
            onPressed: () => context.pop()),
        title: const Text('Asesor de Regulaciones (NOMs)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'RRNAs y Permisos Previos',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Consulta qu normas y permisos necesitas tramitar ANTES de embarcar.',
              style: TextStyle(color: AppColors.sub, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hsCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Fraccin Arancelaria (ej. 8543, 3004...)',
                      labelStyle: TextStyle(color: AppColors.sub),
                      filled: true,
                      fillColor: AppColors.card,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _consultar,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text('Consultar',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(
                  child: CircularProgressIndicator(color: AppColors.blue))
            else if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border)),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _result!.productName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  NomsPdfService.exportChecklist(_result!),
                              icon: const Icon(Icons.picture_as_pdf,
                                  color: Colors.white, size: 16),
                              label: const Text('Descargar Checklist',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.red),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Fraccin: ${_result!.hsCode}',
                            style: const TextStyle(
                                color: AppColors.gold, fontSize: 16)),
                        const Divider(color: AppColors.border, height: 32),
                        const Text('NOMs Obligatorias:',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (_result!.requiredNoms.isEmpty)
                          const Text('Ninguna',
                              style: TextStyle(color: AppColors.green))
                        else
                          ..._result!.requiredNoms.map((n) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(children: [
                                  const Icon(Icons.warning,
                                      color: AppColors.gold, size: 16),
                                  const SizedBox(width: 8),
                                  Text(n,
                                      style:
                                          const TextStyle(color: Colors.white))
                                ]),
                              )),
                        const SizedBox(height: 24),
                        const Text(
                            'Permisos Especiales (Salud, Ejrcito, SEMARNAT):',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (_result!.requiredPermits.isEmpty)
                          const Text('Ninguno',
                              style: TextStyle(color: AppColors.green))
                        else
                          ..._result!.requiredPermits.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(children: [
                                  const Icon(Icons.gavel,
                                      color: AppColors.red, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(p,
                                          style: const TextStyle(
                                              color: Colors.white)))
                                ]),
                              )),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: AppColors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.blue)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(children: [
                                Icon(Icons.lightbulb_outline,
                                    color: AppColors.blue, size: 18),
                                SizedBox(width: 8),
                                Text('Recomendacin',
                                    style: TextStyle(
                                        color: AppColors.blue,
                                        fontWeight: FontWeight.bold))
                              ]),
                              const SizedBox(height: 8),
                              Text(_result!.recommendations,
                                  style: const TextStyle(
                                      color: Colors.white, height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
