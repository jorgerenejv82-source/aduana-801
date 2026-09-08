import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class NextStepWidget extends StatefulWidget {
  const NextStepWidget({super.key});

  @override
  State<NextStepWidget> createState() => _NextStepWidgetState();

  static Future<void> markStepComplete(BuildContext context, int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primer_importacion_step', step + 1);
  }
}

class _NextStepWidgetState extends State<NextStepWidget> {
  int _currentStep = 0;

  static const _steps = [
    {
      'label': 'Obtener tu RFC',
      'sub': 'Persona física o moral ante el SAT',
      'icon': Icons.badge_outlined,
      'route': '/learning_center'
    },
    {
      'label': 'Registrarte como importador',
      'sub': 'Padrón de Importadores ante el SAT',
      'icon': Icons.assignment_outlined,
      'route': '/learning_center'
    },
    {
      'label': 'Contratar un Agente Aduanal',
      'sub': 'Busca uno certificado y con experiencia en tu sector',
      'icon': Icons.handshake_outlined,
      'route': '/simple_estimator'
    },
    {
      'label': 'Clasificar tu mercancía',
      'sub': 'La fracción arancelaria define cuánto pagas',
      'icon': Icons.qr_code_outlined,
      'route': '/clasificador_ia'
    },
    {
      'label': 'Calcular el costo total',
      'sub': 'Landed cost + impuestos + logística',
      'icon': Icons.calculate_outlined,
      'route': '/simple_estimator'
    },
    {
      'label': 'Verificar permisos previos',
      'sub': 'COFEPRIS, SENASICA, SE según tu producto',
      'icon': Icons.verified_outlined,
      'route': '/permisos_previos'
    },
    {
      'label': 'Negociar y crear la Orden de Compra',
      'sub': 'Con fracción arancelaria y Certificado de Origen',
      'icon': Icons.shopping_cart_outlined,
      'route': '/supply_chain/po/nueva'
    },
    {
      'label': 'Monitorear tu embarque',
      'sub': 'Tracking en tiempo real de tu contenedor',
      'icon': Icons.directions_boat_outlined,
      'route': '/shipment_tracker'
    },
    {
      'label': 'Despacho aduanal',
      'sub': 'Tu agente presenta el pedimento. Semáforo. Liberación.',
      'icon': Icons.local_shipping_outlined,
      'route': '/mi_primer_despacho'
    },
    {
      'label': '¡Mercancía liberada! Analiza tu ROI',
      'sub': '¿Fue rentable? Registra tus ganancias reales.',
      'icon': Icons.celebration_outlined,
      'route': '/roi_calculator'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStep();
  }

  Future<void> _loadStep() async {
    final prefs = await SharedPreferences.getInstance();
    final step = prefs.getInt('primer_importacion_step') ?? 0;
    setState(() {
      _currentStep = step.clamp(0, 10);
    });
  }

  void _incrementStep() async {
    if (_currentStep < 10) {
      await NextStepWidget.markStepComplete(context, _currentStep);
      unawaited(_loadStep());
    }
  }

  void _resetSteps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primer_importacion_step', 0);
    unawaited(_loadStep());
  }

  void _navigate(String route) {
    try {
      context.push(route);
    } catch (_) {
      context.push(route);
    }
  }

  void _showAllSteps(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Todos los pasos',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      final isCompleted = index < _currentStep;
                      final isCurrent = index == _currentStep;

                      return ListTile(
                        leading: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : (isCurrent
                                  ? Icons.circle_outlined
                                  : Icons.circle),
                          color: isCompleted
                              ? AppColors.green
                              : (isCurrent ? AppColors.gold : AppColors.sub),
                        ),
                        title: Text(
                          step['label'] as String,
                          style: TextStyle(
                            color: isCompleted ? AppColors.sub : AppColors.text,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          step['sub'] as String,
                          style: TextStyle(
                            color: AppColors.sub,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _navigate(step['route'] as String);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep >= 10) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF047857), Color(0xFF10B981)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              '🎉 ¡Felicidades! Completaste tu primera importación',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigate('/roi_calculator'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              child: const Text('Analizar mi ROI',
                  style: TextStyle(color: AppColors.bg)),
            ),
            TextButton(
              onPressed: _resetSteps,
              child: const Text('Empezar otra operación',
                  style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      );
    }

    final stepData = _steps[_currentStep];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📍 Tu próximo paso',
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sub.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Paso ${_currentStep + 1} de 10',
                    style: const TextStyle(color: AppColors.sub, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _currentStep / 10,
            color: AppColors.gold,
            backgroundColor: AppColors.border,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _navigate(stepData['route'] as String),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                    left: BorderSide(color: AppColors.gold, width: 4)),
              ),
              child: Row(
                children: [
                  Icon(stepData['icon'] as IconData,
                      color: AppColors.gold, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stepData['label'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stepData['sub'] as String,
                          style: const TextStyle(
                              color: AppColors.sub, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.sub),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () => _showAllSteps(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const Text('Ver todos los pasos'),
              ),
              TextButton(
                onPressed: _incrementStep,
                child: const Text('Marcar completado →',
                    style: TextStyle(color: AppColors.gold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
