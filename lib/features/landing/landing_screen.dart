import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const bg = Color(0xFF0F172A);
const card = Color(0xFF1E293B);
const gold = Color(0xFFF59E0B);
const white = Colors.white;
const gray = Color(0xFF94A3B8);
const red = Color(0xFFEF4444);
const green = Color(0xFF10B981);

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            _PainPointsSection(),
            _FeaturesSection(),
            _ForWhoSection(),
            _PricingPreviewSection(),
            _CtaFinalSection(),
            _FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height,
      decoration: const BoxDecoration(
        color: bg,
        // Optional: add a grid or subtle particle background here
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security, color: gold, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'ADUANAS 801',
                    style: TextStyle(
                      color: white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    'Entiende tu ',
                    style: TextStyle(
                      color: white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [gold, Colors.orangeAccent],
                    ).createShader(bounds),
                    child: const Text(
                      'importación',
                      style: TextStyle(
                        color: white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '¿Tu agente te cobra justo? ¿Sabes qué dice tu pedimento?\nCon Aduanas 801, cualquier Pyme puede importar con confianza.',
                style: TextStyle(
                  color: gray,
                  fontSize: 18,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  ElevatedButton(
                    onPressed: () => context.push('/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: bg,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Registrarse Gratis →'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.push('/pricing'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gold,
                      side: const BorderSide(color: gold),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Ver Precios'),
                  ),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: gray,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Iniciar Sesión'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 12,
                children: [
                  _SocialProofItem('✓ Sin tarjeta de crédito'),
                  _SocialProofItem('✓ Gratis para empezar'),
                  _SocialProofItem('✓ Cancela cuando quieras'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialProofItem extends StatelessWidget {
  final String text;
  const _SocialProofItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: gray, fontSize: 14),
    );
  }
}

class _PainPointsSection extends StatelessWidget {
  const _PainPointsSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
      child: Column(
        children: [
          const Text(
            '¿Te suena familiar?',
            style: TextStyle(
                color: white, fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Estos son los problemas más comunes de los importadores en México',
            style: TextStyle(color: gray, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: _PainPointCard(
                  icon: '💸',
                  title: '¿Cuánto te cobra tu agente?',
                  description:
                      'La mayoría de las Pymes no sabe si los honorarios de su agente son justos. La falta de transparencia cuesta miles de pesos al año.',
                ),
              ),
              if (isDesktop)
                const SizedBox(width: 24)
              else
                const SizedBox(height: 24),
              const Expanded(
                child: _PainPointCard(
                  icon: '📄',
                  title: 'Tu pedimento parece otro idioma',
                  description:
                      'La A1, la fracción arancelaria, el DTA... ¿Qué significa todo eso? No deberías necesitar un traductor para entender tus propios documentos.',
                ),
              ),
              if (isDesktop)
                const SizedBox(width: 24)
              else
                const SizedBox(height: 24),
              const Expanded(
                child: _PainPointCard(
                  icon: '⏰',
                  title: '¿Cuándo llega tu mercancía?',
                  description:
                      'Hacer seguimiento de embarques, NOMs, permisos y vencimientos sin una herramienta dedicada es caótico y costoso.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PainPointCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _PainPointCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        border: const Border(left: BorderSide(color: red, width: 4)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
                color: white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: gray, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: card,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
      child: Column(
        children: [
          const Text(
            'La solución que las Pymes necesitaban',
            style: TextStyle(
                color: white, fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          _FeatureRow(
            icon: '💰',
            title: 'Calcula tu costo real antes de importar',
            description:
                'Landed Cost, impuestos, honorarios, flete... todo en una calculadora que te da el precio real de tu mercancía antes de comprometerte.',
            buttonText: 'Probar calculadora',
            onPressed: () => context.push('/login'),
            isLeft: true,
          ),
          const SizedBox(height: 80),
          _FeatureRow(
            icon: '📊',
            title: 'Entiende cada número de tu pedimento',
            description:
                'Traducimos el pedimento a lenguaje normal. Verifica que tu agente clasificó bien tu mercancía y que los impuestos son correctos.',
            buttonText: 'Ver demo',
            onPressed: () => context.push('/login'),
            isLeft: false,
          ),
          const SizedBox(height: 80),
          _FeatureRow(
            icon: '🤖',
            title: 'Tu Copiloto IA de comercio exterior',
            description:
                'Pregúntale lo que quieras: ¿qué fracción arancelaria tiene mi producto?, ¿necesito permiso previo?, ¿qué es el TMEC?',
            buttonText: 'Hablar con el Copiloto',
            onPressed: () => context.push('/login'),
            isLeft: true,
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;
  final bool isLeft;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
              color: white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(color: gray, fontSize: 18, height: 1.5),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: gold,
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            padding: EdgeInsets.zero,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(buttonText),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16),
            ],
          ),
        ),
      ],
    );

    final placeholder = Container(
      height: 300,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white24, size: 64),
      ),
    );

    if (!isDesktop) {
      return Column(
        children: [
          textContent,
          const SizedBox(height: 32),
          placeholder,
        ],
      );
    }

    return Row(
      children: isLeft
          ? [
              Expanded(child: textContent),
              const SizedBox(width: 48),
              Expanded(child: placeholder),
            ]
          : [
              Expanded(child: placeholder),
              const SizedBox(width: 48),
              Expanded(child: textContent),
            ],
    );
  }
}

class _ForWhoSection extends StatelessWidget {
  const _ForWhoSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
      child: Column(
        children: [
          const Text(
            '¿Para quién es Aduanas 801?',
            style: TextStyle(
                color: white, fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: _PersonaCard(
                  icon: '🌱',
                  title: 'Empezando a importar',
                  description:
                      'Nunca has importado y quieres hacerlo bien desde el inicio sin pagar de más ni cometer errores.',
                ),
              ),
              if (isDesktop)
                const SizedBox(width: 24)
              else
                const SizedBox(height: 24),
              const Expanded(
                child: _PersonaCard(
                  icon: '📦',
                  title: 'Ya importo regularmente',
                  description:
                      'Tienes operaciones activas y quieres más control, visibilidad y certeza sobre tus costos y cumplimiento.',
                ),
              ),
              if (isDesktop)
                const SizedBox(width: 24)
              else
                const SizedBox(height: 24),
              const Expanded(
                child: _PersonaCard(
                  icon: '🌎',
                  title: 'Exporto o tengo maquila',
                  description:
                      'Necesitas certificados de origen, IMMEX, Drawback y herramientas para competir en mercados internacionales.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          TextButton(
            onPressed: () => context.push('/pricing'),
            style: TextButton.styleFrom(
              foregroundColor: gray,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text(
                '¿Eres Agente Aduanal? → Tenemos un plan Enterprise para ti'),
          ),
        ],
      ),
    );
  }
}

class _PersonaCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _PersonaCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
                color: white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: gray, fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PricingPreviewSection extends StatelessWidget {
  const _PricingPreviewSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      width: double.infinity,
      color: card,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
      child: Column(
        children: [
          const Text(
            'Planes claros y honestos',
            style: TextStyle(
                color: white, fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin letra chica. Sin sorpresas.',
            style: TextStyle(color: gray, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _PricingTeaser(title: '🌱 Empezando', price: 'Gratis'),
              SizedBox(width: 24, height: 24),
              _PricingTeaser(
                  title: '📦 PRO Pyme',
                  price: '\$299/mes',
                  isHighlighted: true),
              SizedBox(width: 24, height: 24),
              _PricingTeaser(title: '🏭 Enterprise', price: '\$999/mes'),
            ],
          ),
          const SizedBox(height: 48),
          TextButton(
            onPressed: () => context.push('/pricing'),
            style: TextButton.styleFrom(
              foregroundColor: gold,
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Text('Ver todos los detalles →'),
          ),
        ],
      ),
    );
  }
}

class _PricingTeaser extends StatelessWidget {
  final String title;
  final String price;
  final bool isHighlighted;

  const _PricingTeaser({
    required this.title,
    required this.price,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isHighlighted ? bg : bg.withValues(alpha: 0.5),
        border: Border.all(color: isHighlighted ? gold : Colors.white10),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  color: white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(price,
              style: TextStyle(
                  color: isHighlighted ? gold : white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CtaFinalSection extends StatelessWidget {
  const _CtaFinalSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [gold, Colors.orangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
      child: Column(
        children: [
          const Text(
            '¿Listo para importar con confianza?',
            style:
                TextStyle(color: bg, fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Únete a las Pymes que ya controlan sus operaciones de comercio exterior.',
            style: TextStyle(color: Color(0xCC0F172A), fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Crear cuenta gratis'),
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.all(24.0),
      child: const Text(
        'Aduanas 801 © 2026 · hola@aduanas801.mx · Términos · Privacidad',
        style: TextStyle(color: gray, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}
