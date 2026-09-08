import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class MiPrimerImportacionScreen extends StatefulWidget {
  const MiPrimerImportacionScreen({super.key});

  @override
  State<MiPrimerImportacionScreen> createState() =>
      _MiPrimerImportacionScreenState();
}

class _MiPrimerImportacionScreenState extends State<MiPrimerImportacionScreen> {
  final List<bool> _completedSteps = List.generate(10, (_) => false);
  bool _isLoading = true;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': '🏢 Constituye o verifica tu empresa',
      'explanation':
          'Necesitas RFC activo con actividad de comercio exterior. Si eres persona física, verifica que tu RFC incluya actividades de importación.',
      'action': 'Ver requisitos RFC',
      'url': 'https://sat.gob.mx',
    },
    {
      'title': '📝 Inscríbete al Padrón de Importadores',
      'explanation':
          'Trámite gratuito en el portal SAT. Necesitas e.Firma vigente. Tarda 5-15 días hábiles.',
      'action': 'Abrir portal SAT',
    },
    {
      'title': '🤝 Encuentra y valida a tu proveedor',
      'explanation':
          'Pide muestras ANTES del pedido grande. Verifica que pueden darte factura con todos los datos requeridos. Busca en Alibaba, Canton Fair, o usa un agente de compras.',
    },
    {
      'title': '📦 Define tu producto y su fracción arancelaria',
      'explanation':
          'La fracción arancelaria (8 dígitos) determina cuánto pagas de impuestos. Usa el Clasificador IA de esta app o consulta con tu agente.',
      'action': 'Ir al Clasificador IA',
      'route': '/clasificador_ia',
    },
    {
      'title': '💰 Calcula tu costo total estimado',
      'explanation':
          'Antes de comprar, calcula si te conviene. Considera: precio del producto + flete + impuestos + agente + gastos locales.',
      'action': '🧮 Calcular ahora',
      'route': '/simple_estimator',
    },
    {
      'title': '🏦 Negocia y paga a tu proveedor',
      'explanation':
          'Para montos grandes, usa Carta de Crédito (LC) para protegerte. Para montos menores, TT (transferencia bancaria) es común. NUNCA pagues 100% adelantado a un proveedor nuevo.',
    },
    {
      'title': '🚢 Coordina el embarque',
      'explanation':
          'Contrata un freight forwarder (agente de carga) para el flete. Obtén el B/L (Bill of Lading) cuando el barco zarpe.',
    },
    {
      'title': '📄 Prepara los documentos para aduanas',
      'explanation':
          'Necesitas tener listos: Factura comercial, Packing list, B/L, Certificado de origen (si aplica), Permisos previos (si aplica).',
    },
    {
      'title': '🏛️ Despacho aduanal',
      'explanation':
          'Tu agente aduanal presentará el pedimento al SAT. Pasarás por el semáforo fiscal (verde=libre, naranja=revisión documental, rojo=revisión física).',
    },
    {
      'title': '🚛 Recoge tu mercancía',
      'explanation':
          'Una vez liberada, coordina el transporte desde la aduana hasta tu almacén. Revisa que todo llegue en buen estado y firma la carta porte.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('primer_importacion')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          for (int i = 0; i < 10; i++) {
            _completedSteps[i] = (data['step_$i'] as bool?) ?? false;
          }
        }
      } catch (e) {
        debugPrint('Error loading progress: $e');
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStep(int index, bool? value) async {
    if (value == null) return;
    setState(() {
      _completedSteps[index] = value;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('primer_importacion')
            .doc(user.uid)
            .set({
          'step_$index': value,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error saving progress: $e');
      }
    }

    if (_completedSteps.every((step) => step)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('¡Felicidades! Completaste tu primera importación 🎉'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completedSteps.where((s) => s).length;
    final progress = completedCount / 10.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text('Mi Primera Importación',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Progreso',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text('$completedCount/10',
                              style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.border,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.gold),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return Card(
                        color: AppColors.card,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.border)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _completedSteps[index],
                                    onChanged: (val) => _toggleStep(index, val),
                                    activeColor: AppColors.green,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        step['title'].toString(),
                                        style: TextStyle(
                                          color: _completedSteps[index]
                                              ? AppColors.sub
                                              : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          decoration: _completedSteps[index]
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 48.0, top: 8.0, bottom: 8.0),
                                child: Text(
                                  step['explanation'].toString(),
                                  style: const TextStyle(
                                      color: AppColors.sub, height: 1.5),
                                ),
                              ),
                              if (step.containsKey('action'))
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 48.0, top: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (step.containsKey('route')) {
                                        context.push(step['route'].toString());
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Abrir: ${step['url']?.toString() ?? step['action'].toString()}')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.blue,
                                    ),
                                    child: Text(step['action'].toString(),
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
