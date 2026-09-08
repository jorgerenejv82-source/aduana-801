import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF59E0B)),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Elige tu Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Potencia tus operaciones de comercio exterior',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Tier 1
            _buildPricingCard(
              context,
              emoji: '🌱',
              nombre: 'Empezando',
              precio: 'Gratis',
              subtitulo: 'Para quien está iniciando',
              features: const [
                'Calculadora de costos básica',
                'Glosario de comercio exterior',
                'Preguntas frecuentes',
                'Mi Primer Despacho (guía paso a paso)',
                'Copiloto IA (10 consultas/mes)',
                'Clasificador arancelario básico',
              ],
              ctaText: 'Empezar Gratis',
              isPro: false,
              onCtaPressed: () {
                if (FirebaseAuth.instance.currentUser != null) {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                } else {
                  context.push('/register');
                }
              },
            ),
            const SizedBox(height: 24),

            // Tier 2
            _buildPricingCard(
              context,
              emoji: '📦',
              nombre: 'PRO Pyme',
              precio: '\$299 MXN/mes',
              subtitulo: 'Para Pymes que importan regularmente',
              badge: '⭐ MÁS POPULAR',
              features: const [
                'Todo lo de Empezando',
                'Expedientes ilimitados',
                'CRM de clientes y proveedores',
                'Alertas de NOMs y vencimientos',
                'Monitor de embarques en tiempo real',
                'Órdenes de Compra y supply chain',
                'Copiloto IA ilimitado',
                'Resumen anual de operaciones',
                'Dashboard financiero completo',
              ],
              ctaText: 'Activar PRO',
              isPro: true,
              onCtaPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Próximamente - te notificaremos cuando esté disponible!',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Color(0xFFF59E0B),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Tier 3
            _buildPricingCard(
              context,
              emoji: '🏭',
              nombre: 'Enterprise',
              precio: '\$999 MXN/mes',
              subtitulo: 'Para exportadores, maquilas y agentes',
              features: const [
                'Todo lo de PRO Pyme',
                'IMMEX y Anexo 24',
                'Duty Drawback',
                'Anexos 22 y 30',
                'Pre-Glosa y M3 Forense',
                'SAAI y VUCEM integrados',
                'Swarm AI (análisis avanzado)',
                'Soporte prioritario',
                'API access',
              ],
              ctaText: 'Contactar Ventas',
              isPro: false,
              isEnterprise: true,
              onCtaPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Escríbenos a hola@aduanas801.mx'),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),
            const Text(
              'Todos los planes incluyen:',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const _FooterFeatureRow(
                text: 'Acceso web en cualquier dispositivo'),
            const _FooterFeatureRow(text: 'Actualizaciones automáticas'),
            const _FooterFeatureRow(text: 'Datos protegidos con Firebase'),
            const _FooterFeatureRow(text: 'Cancela cuando quieras'),
            const SizedBox(height: 32),
            const Text(
              'Preguntas? Escríbenos a hola@aduanas801.mx',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context, {
    required String emoji,
    required String nombre,
    required String precio,
    required String subtitulo,
    String? badge,
    required List<String> features,
    required String ctaText,
    required bool isPro,
    bool isEnterprise = false,
    required VoidCallback onCtaPressed,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isPro
            ? const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: isPro ? null : Border.all(color: const Color(0xFF334155)),
        color: isPro ? null : const Color(0xFF1E293B),
      ),
      child: Padding(
        padding: isPro ? const EdgeInsets.all(2.0) : EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isPro ? 18 : 20),
            color: const Color(0xFF1E293B),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitulo,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                precio,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCtaPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isPro ? const Color(0xFFF59E0B) : Colors.transparent,
                    foregroundColor: isPro
                        ? Colors.black
                        : (isEnterprise
                            ? const Color(0xFFF59E0B)
                            : Colors.white),
                    side: isPro
                        ? null
                        : BorderSide(
                            color: isEnterprise
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF64748B)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    ctaText,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterFeatureRow extends StatelessWidget {
  final String text;
  const _FooterFeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✅', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }
}
