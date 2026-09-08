import 'package:flutter/material.dart';

class OnboardingTour extends StatefulWidget {
  final Widget child; // The wrapped home screen
  final VoidCallback onComplete;

  const OnboardingTour(
      {super.key, required this.child, required this.onComplete});

  @override
  State<OnboardingTour> createState() => _OnboardingTourState();
}

class _OnboardingTourState extends State<OnboardingTour>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _visible = true;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': '1 de 5',
      'text':
          'Tu centro de navegación. Todo organizado en categorías. Toca una categoría para expandirla.',
      'spotlight':
          const Rect.fromLTWH(0, 0, 260, 800), // Approximate sidebar area
      'tooltipPos': const Offset(280, 200),
    },
    {
      'title': '2 de 5',
      'text':
          'Busca cualquiera de los 106 módulos en segundos. Pulsa Ctrl+K o toca aquí.',
      'spotlight':
          const Rect.fromLTWH(400, 10, 400, 50), // Approx top search bar
      'tooltipPos': const Offset(400, 80),
    },
    {
      'title': '3 de 5',
      'text':
          'Tus métricas operativas en tiempo real. Directamente de la base de datos.',
      'spotlight': const Rect.fromLTWH(280, 120, 1000, 150), // Approx KPI area
      'tooltipPos': const Offset(400, 290),
    },
    {
      'title': '4 de 5',
      'text': 'Las 4 acciones más comunes a un clic. Sin buscar en el menú.',
      'spotlight':
          const Rect.fromLTWH(280, 290, 1000, 100), // Approx Quick Actions area
      'tooltipPos': const Offset(400, 410),
    },
    {
      'title': '5 de 5',
      'text':
          '¡Listo! Ya eres un experto en Aduanas 801. Recuerda: ⭐ para guardar favoritos, Ctrl+K para buscar cualquier módulo.',
      'spotlight': Rect.zero, // No spotlight for done
      'tooltipPos': const Offset(400, 300), // Centerish
    }
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _finish();
    }
  }

  void _finish() {
    setState(() {
      _visible = false;
    });
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;

    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _TourOverlayPainter(
                spotlight: _steps[_currentStep]['spotlight'] as Rect,
                pulseValue: _pulseController.value,
              ),
            );
          },
        ),
        Positioned(
          left: (_steps[_currentStep]['tooltipPos'] as Offset).dx,
          top: (_steps[_currentStep]['tooltipPos'] as Offset).dy,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _steps[_currentStep]['title'] as String,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                      TextButton(
                        onPressed: _finish,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                        child: const Text('Saltar',
                            style: TextStyle(
                                color: Color(0xFF94A3B8), fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _steps[_currentStep]['text'] as String,
                    style:
                        const TextStyle(color: Color(0xFFF8FAFC), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentStep
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF475569),
                            ),
                          );
                        }),
                      ),
                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child:
                            Text(_currentStep == 4 ? 'Empezar' : 'Siguiente →'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TourOverlayPainter extends CustomPainter {
  final Rect spotlight;
  final double pulseValue;

  _TourOverlayPainter({required this.spotlight, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    if (spotlight == Rect.zero) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    final inflatedRect = spotlight.inflate(pulseValue * 5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(inflatedRect, const Radius.circular(8)),
      clearPaint,
    );

    final borderPaint = Paint()
      ..color = const Color(0xFFF59E0B)
          .withValues(alpha: 0.5 + (0.5 * (1 - pulseValue)))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(inflatedRect, const Radius.circular(8)),
      borderPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TourOverlayPainter oldDelegate) {
    return oldDelegate.spotlight != spotlight ||
        oldDelegate.pulseValue != pulseValue;
  }
}
