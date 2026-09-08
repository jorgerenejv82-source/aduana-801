import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/services/auth_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/push_notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final AuthService _authService = AuthService();

  late AnimationController _bgController;
  late AnimationController _cardController;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  static const Color bg1 = AppColors.bg;
  static const Color gold = AppColors.gold;
  static const Color text = AppColors.text;
  static const Color sub = AppColors.sub;
  static const Color border = AppColors.border;
  static const Color cardBg = AppColors.card;

  @override
  void initState() {
    super.initState();
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
    _cardController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _cardFade = CurvedAnimation(parent: _cardController, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
    _cardController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _cardController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      await AnalyticsService.instance.logLogin('email');
      unawaited(PushNotificationService.instance.initialize());
      if (!mounted) return;
      context.go('/role_selection');
    } catch (e) {
      if (!mounted) return;
      _showError('Credenciales incorrectas. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: gold, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: text))),
      ]),
      backgroundColor: const Color(0xFF111C2E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: border)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _fillDemo() {
    _emailController.text = 'demo@aduana801.mx';
    _passwordController.text = 'Demo123456!';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 900;

    return Scaffold(
      backgroundColor: bg1,
      body: Stack(
        children: [
          // --- Animated Background ---
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) {
              return CustomPaint(
                painter: _BgPainter(_bgController.value),
                child: const SizedBox.expand(),
              );
            },
          ),

          // --- Content ---
          SafeArea(
            child: isWide
                ? Row(children: [
                    // Left Panel (branding)
                    Expanded(flex: 5, child: _buildBrandPanel()),
                    // Right Panel (form)
                    Expanded(flex: 4, child: _buildFormPanel()),
                  ])
                : _buildMobileLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(children: [
        _buildLogo(size: 60),
        const SizedBox(height: 16),
        _buildBrandText(center: true),
        const SizedBox(height: 40),
        _buildCard(),
      ]),
    );
  }

  Widget _buildBrandPanel() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(size: 72),
          const SizedBox(height: 32),
          _buildBrandText(center: false),
          const SizedBox(height: 48),
          _buildFeatureList(),
        ],
      ),
    );
  }

  Widget _buildLogo({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.gold, Color(0xFFF5C842)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: gold.withValues(alpha: 0.4),
              blurRadius: 24,
              spreadRadius: 2),
        ],
      ),
      child: Icon(Icons.shield_rounded, color: bg1, size: size * 0.5),
    );
  }

  Widget _buildBrandText({required bool center}) {
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            colors: [AppColors.gold, Color(0xFFFFE08A)],
          ).createShader(r),
          child: Text(
            'Entiende tu importación',
            style: TextStyle(
              fontSize: center ? 28 : 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'La herramienta definitiva para Pymes que importan o exportan en México.',
          style: TextStyle(
            fontSize: center ? 14 : 16,
            color: sub,
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureList() {
    final features = [
      (Icons.calculate_outlined, 'Calcula tu costo real de importación'),
      (Icons.description_outlined, 'Entiende tu pedimento sin jerón'),
      (Icons.warning_amber_rounded, 'Recibe alertas de cumplimiento'),
      (Icons.smart_toy_outlined, 'Copiloto IA para tus preguntas de ComEx'),
      (Icons.local_shipping_outlined, 'Monitorea tus embarques en tiempo real'),
    ];
    return Column(
      children: features
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: gold.withValues(alpha: 0.3)),
                    ),
                    child: Icon(f.$1, color: gold, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Text(f.$2,
                      style: const TextStyle(
                          color: text,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ]),
              ))
          .toList(),
    );
  }

  Widget _buildFormPanel() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return FadeTransition(
      opacity: _cardFade,
      child: SlideTransition(
        position: _cardSlide,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20)),
              BoxShadow(
                  color: gold.withValues(alpha: 0.05),
                  blurRadius: 60,
                  spreadRadius: 10),
            ],
          ),
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text('Bienvenido de vuelta',
                  style: TextStyle(
                      color: text, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Ingresa tus credenciales para continuar',
                  style: TextStyle(color: sub, fontSize: 13)),
              const SizedBox(height: 32),

              // Divider
              Container(height: 1, color: border),
              const SizedBox(height: 28),

              // Email
              _buildLabel('Correo Electrónico'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'usuario@empresa.com',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password
              _buildLabel('Contraseña'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                hint: '••••••••••••',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 32),

              // Login Button
              _buildLoginButton(),
              const SizedBox(height: 20),

              // Demo button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _fillDemo,
                  icon: const Icon(Icons.play_circle_outline,
                      color: sub, size: 18),
                  label: const Text('Acceso con cuenta Demo',
                      style: TextStyle(color: sub, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Register link
              Center(
                  child: TextButton(
                onPressed: () => context.push('/register'),
                child: RichText(
                    text: const TextSpan(
                  text: '¿No tienes cuenta? ',
                  style: TextStyle(color: sub, fontSize: 13),
                  children: [
                    TextSpan(
                        text: 'Regístrate aquí',
                        style: TextStyle(
                            color: gold, fontWeight: FontWeight.w600)),
                  ],
                )),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label,
        style: const TextStyle(
            color: sub,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: text, fontSize: 14),
      onSubmitted: isPassword ? (_) => _login() : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: sub.withValues(alpha: 0.5), fontSize: 14),
        filled: true,
        fillColor: AppColors.bg,
        prefixIcon: Icon(icon, color: sub, size: 18),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: sub,
                    size: 18),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: gold.withValues(alpha: 0.7), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: bg1,
          disabledBackgroundColor: gold.withValues(alpha: 0.5),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          shadowColor: gold.withValues(alpha: 0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: AppColors.bg, strokeWidth: 2.5))
            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.lock_open_rounded, size: 18, color: AppColors.bg),
                SizedBox(width: 10),
                Text('Iniciar Sesión',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bg,
                        letterSpacing: 0.3)),
              ]),
      ),
    );
  }
}

// Custom Painter for the animated background
class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Gradient base
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    const bgGrad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.bg, Color(0xFF0A1628), AppColors.bg],
    );
    paint.shader = bgGrad.createShader(bgRect);
    canvas.drawRect(bgRect, paint);

    // Orbs
    final orbData = [
      (0.15, 0.2, 280.0, AppColors.gold, 0.0),
      (0.85, 0.75, 220.0, const Color(0xFF1E4080), 0.3),
      (0.5, 0.9, 180.0, const Color(0xFF0D5C8A), 0.6),
    ];

    for (final o in orbData) {
      final phase = (t + o.$5) % 1.0;
      final dx = math.sin(phase * math.pi * 2) * 30;
      final dy = math.cos(phase * math.pi * 2) * 20;
      final center = Offset(size.width * o.$1 + dx, size.height * o.$2 + dy);
      paint.shader = RadialGradient(
        colors: [o.$4.withValues(alpha: 0.15), o.$4.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: o.$3));
      canvas.drawCircle(center, o.$3, paint);
    }

    // Grid lines
    final linePaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.25)
      ..strokeWidth = 0.5;

    const step = 60.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}
