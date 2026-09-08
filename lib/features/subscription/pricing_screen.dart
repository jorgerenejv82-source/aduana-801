import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:aduana_801/core/theme/app_text_styles.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool _isAnual = false;

  void _activateTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_tier', 'trial');
    await prefs.setString('trial_start', DateTime.now().toIso8601String());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Prueba PRO activada! 🎉')),
      );
      context.go('/home');
    }
  }

  void _contactSales() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title:
            const Text('Contactar ventas', style: AppTextStyles.headlineMedium),
        content: const Text(
          'Escríbenos a ventas@aduana801.mx o al WhatsApp +52 55 XXXX XXXX',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cerrar', style: TextStyle(color: AppColors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proPrice = _isAnual ? '\$159/mes' : '\$199/mes';
    final agentePrice = _isAnual ? '\$399/mes' : '\$499/mes';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Planes y Precios'),
        backgroundColor: AppColors.bg2,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('🚀 Elige tu plan', style: AppTextStyles.displayMedium),
            const SizedBox(height: 8),
            const Text('Sin contratos. Cancela cuando quieras.',
                style: AppTextStyles.bodyLarge),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Mensual', style: AppTextStyles.bodyMedium),
                Switch(
                  value: _isAnual,
                  activeThumbColor: AppColors.gold,
                  onChanged: (val) => setState(() => _isAnual = val),
                ),
                const Text('Anual', style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 32),

            // FREE
            _buildPlanCard(
              title: 'GRATIS',
              price: '\$0 /siempre',
              borderColor: const Color(0xFF334155),
              features: [
                _Feature(text: 'Estimador (3 cálculos/mes)', included: true),
                _Feature(text: 'Glosario completo', included: true),
                _Feature(text: 'Mi Primera Importación', included: true),
                _Feature(text: 'Centro de Aprendizaje', included: true),
                _Feature(text: 'FAQs', included: true),
                _Feature(text: 'Expedientes en la nube', included: false),
                _Feature(text: 'Clasificador IA', included: false),
                _Feature(text: 'Dashboard Importador', included: false),
                _Feature(text: 'Notificaciones', included: false),
                _Feature(text: 'Exportar PDFs', included: false),
                _Feature(text: 'CRM', included: false),
              ],
              button: OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  disabledForegroundColor: AppColors.sub,
                  side: const BorderSide(color: AppColors.sub),
                ),
                child: const Text('Plan actual'),
              ),
            ),
            const SizedBox(height: 24),

            // PRO
            DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _buildPlanCard(
                title: 'PRO',
                badge: 'MÁS POPULAR',
                price: proPrice,
                subtitle: _isAnual ? 'facturado \$1,908 anuales' : null,
                borderColor: AppColors.gold,
                borderWidth: 2,
                features: [
                  _Feature(text: 'TODO lo del plan Gratuito', included: true),
                  _Feature(text: 'Estimaciones ilimitadas', included: true),
                  _Feature(text: 'Expedientes Firestore', included: true),
                  _Feature(text: 'Clasificador IA', included: true),
                  _Feature(text: 'Dashboard Importador', included: true),
                  _Feature(text: 'Notificaciones', included: true),
                  _Feature(text: 'PDFs', included: true),
                  _Feature(text: 'CRM', included: true),
                  _Feature(text: 'Órdenes de Compra', included: true),
                  _Feature(text: 'Torre de Tráfico', included: true),
                  _Feature(text: 'Análisis TMEC', included: true),
                  _Feature(text: 'Soporte WhatsApp', included: true),
                ],
                button: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _activateTrial,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.bg,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Empezar prueba de 14 días GRATIS'),
                    ),
                    const SizedBox(height: 8),
                    const Text('No se requiere tarjeta de crédito',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // AGENTE
            _buildPlanCard(
              title: 'AGENTE',
              price: agentePrice,
              borderColor: AppColors.blue,
              features: [
                _Feature(text: 'Pre-Glosa SAAI', included: true),
                _Feature(text: 'Bóveda FIEL', included: true),
                _Feature(text: 'VUCEM Sync', included: true),
                _Feature(text: 'M3 Forensics', included: true),
                _Feature(text: 'Swarm AI', included: true),
                _Feature(text: 'API Gateway', included: true),
                _Feature(text: '5 usuarios', included: true),
              ],
              button: OutlinedButton(
                onPressed: _contactSales,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.blue,
                  side: const BorderSide(color: AppColors.blue),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Contactar ventas'),
              ),
            ),
            const SizedBox(height: 48),

            // Guarantee section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGuaranteeIcon('🔒', 'Seguro'),
                _buildGuaranteeIcon('🇲🇽', 'Hecho en MX'),
                _buildGuaranteeIcon('🔐', 'Privado'),
              ],
            ),
            const SizedBox(height: 48),

            // FAQ section
            const Text('Preguntas Frecuentes',
                style: AppTextStyles.headlineLarge),
            const SizedBox(height: 16),
            _buildFaqItem('¿Puedo cancelar en cualquier momento?',
                'Sí, puedes cancelar tu suscripción desde los ajustes en cualquier momento sin penalización.'),
            _buildFaqItem('¿Cómo funciona la prueba gratis?',
                'Tienes 14 días para usar todas las funciones PRO sin costo. No pedimos tarjeta de crédito.'),
            _buildFaqItem('¿Emiten factura fiscal (CFDI)?',
                'Sí, emitimos CFDI 4.0 para todas tus suscripciones con IVA desglosado.'),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    String? badge,
    required String price,
    String? subtitle,
    required Color borderColor,
    double borderWidth = 1,
    required List<_Feature> features,
    required Widget button,
  }) {
    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badge,
                    style: const TextStyle(
                        color: AppColors.bg,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            if (badge != null) const SizedBox(height: 8),
            Text(title,
                style:
                    AppTextStyles.headlineLarge.copyWith(color: borderColor)),
            const SizedBox(height: 8),
            Text(price, style: AppTextStyles.displayLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.bodySmall),
            ],
            const SizedBox(height: 24),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        f.included ? Icons.check_circle : Icons.cancel,
                        color: f.included ? AppColors.green : AppColors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          f.text,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: f.included ? AppColors.text : AppColors.sub,
                            decoration:
                                f.included ? null : TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: button),
          ],
        ),
      ),
    );
  }

  Widget _buildGuaranteeIcon(String emoji, String text) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(text, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(question, style: AppTextStyles.headlineSmall),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(answer, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final String text;
  final bool included;
  _Feature({required this.text, required this.included});
}
