import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/email_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _empresaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  Role _role = Role.agente;
  final AuthService _authService = AuthService();

  late AnimationController _bgCtrl;
  late AnimationController _cardCtrl;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  static const bg1 = AppColors.bg;
  static const cardBg = AppColors.card;
  static const gold = AppColors.gold;
  static const text = AppColors.text;
  static const sub = AppColors.sub;
  static const border = AppColors.border;

  @override
  void initState() {
    super.initState();
    _bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _cardCtrl.dispose();
    _nameCtrl.dispose();
    _empresaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _empresaCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      _showError('Por favor llena todos los campos');
      return;
    }
    if (!_emailCtrl.text.contains('@')) {
      _showError('Correo no válido');
      return;
    }
    if (_passCtrl.text.length < 8) {
      _showError('Contraseña mínimo 8 caracteres');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      _showError('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.registerWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _nameCtrl.text.trim(),
        _role,
        _empresaCtrl.text.trim(),
      );
      await AnalyticsService.instance.logSignUp('email');
      await EmailService.instance.sendWelcomeEmail(
        email: _emailCtrl.text.trim(),
        displayName: _nameCtrl.text.trim(),
        persona: 'novato', // default, will be updated after persona selection
      );
      if (!mounted) return;
      context.go('/role_selection');
    } catch (e) {
      if (!mounted) return;
      _showError('Error al crear cuenta: $e');
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: bg1,
      body: Stack(children: [
        AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
                painter: _RegBgPainter(_bgCtrl.value),
                child: const SizedBox.expand())),
        SafeArea(
            child: isWide
                ? Row(children: [
                    Expanded(flex: 5, child: _buildBrandPanel()),
                    Expanded(flex: 4, child: _buildFormPanel()),
                  ])
                : _buildMobileLayout()),
      ]),
    );
  }

  Widget _buildMobileLayout() => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(children: [
          Align(
              alignment: Alignment.topLeft,
              child: TextButton.icon(
                onPressed: () => context.pop(),
                icon:
                    const Icon(Icons.arrow_back_ios_new, size: 14, color: sub),
                label: const Text('Volver',
                    style: TextStyle(color: sub, fontSize: 13)),
              )),
          const SizedBox(height: 16),
          _buildCard(),
        ]),
      );

  Widget _buildBrandPanel() => Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new, size: 14, color: sub),
              label: const Text('Volver al inicio de sesión',
                  style: TextStyle(color: sub, fontSize: 13)),
            ),
            const SizedBox(height: 32),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [AppColors.gold, Color(0xFFF5C842)]),
                boxShadow: [
                  BoxShadow(color: gold.withValues(alpha: 0.4), blurRadius: 20)
                ],
              ),
              child: const Icon(Icons.shield_rounded, color: bg1, size: 32),
            ),
            const SizedBox(height: 28),
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                  colors: [AppColors.gold, Color(0xFFFFE08A)]).createShader(r),
              child: const Text('Crea tu cuenta gratis',
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
            const SizedBox(height: 10),
            const Text(
                'Empieza a entender y controlar tu comercio exterior hoy.',
                style: TextStyle(color: sub, fontSize: 15, height: 1.6)),
            const SizedBox(height: 40),
            ...[
              (
                Icons.verified_user_outlined,
                'Perfil para importadores y exportadores'
              ),
              (Icons.cloud_sync_outlined, 'Datos sincronizados en la nube'),
              (Icons.lock_outline_rounded, 'Seguridad con Firebase Auth'),
              (
                Icons.support_agent_outlined,
                'Soporte especializado en aduanas'
              ),
            ].map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: gold.withValues(alpha: 0.3)),
                      ),
                      child: Icon(f.$1, color: gold, size: 17),
                    ),
                    const SizedBox(width: 12),
                    Text(f.$2,
                        style: const TextStyle(
                            color: text,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ]),
                )),
          ],
        ),
      );

  Widget _buildFormPanel() => Center(
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(40), child: _buildCard()));

  Widget _buildCard() => FadeTransition(
        opacity: _cardFade,
        child: SlideTransition(
          position: _cardSlide,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
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
                    color: gold.withValues(alpha: 0.04),
                    blurRadius: 60,
                    spreadRadius: 10),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nuevo usuario',
                    style: TextStyle(
                        color: text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Completa tu perfil profesional',
                    style: TextStyle(color: sub, fontSize: 13)),
                const SizedBox(height: 24),
                Container(height: 1, color: border),
                const SizedBox(height: 24),
                _label('Nombre Completo'),
                const SizedBox(height: 8),
                _field(_nameCtrl, 'Ej. Juan Pérez García',
                    Icons.person_outline_rounded),
                const SizedBox(height: 16),
                _label('Empresa / Agencia Aduanal'),
                const SizedBox(height: 8),
                _field(_empresaCtrl, 'Ej. Agencia Aduanal SA de CV',
                    Icons.business_outlined),
                const SizedBox(height: 20),
                _label('Rol en la Plataforma'),
                const SizedBox(height: 12),
                _buildRoleSelector(),
                const SizedBox(height: 20),
                _label('Correo Electrónico'),
                const SizedBox(height: 8),
                _field(_emailCtrl, 'usuario@empresa.com',
                    Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _label('Contraseña'),
                const SizedBox(height: 8),
                _field(_passCtrl, '••••••••', Icons.lock_outline_rounded,
                    isPassword: true,
                    obscure: _obscurePass,
                    onToggle: () =>
                        setState(() => _obscurePass = !_obscurePass)),
                const SizedBox(height: 16),
                _label('Confirmar Contraseña'),
                const SizedBox(height: 8),
                _field(_confirmCtrl, '••••••••', Icons.lock_outline_rounded,
                    isPassword: true,
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: bg1, strokeWidth: 2.5))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Icon(Icons.person_add_rounded,
                                    size: 18, color: bg1),
                                SizedBox(width: 10),
                                Text('Crear Cuenta',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: bg1)),
                              ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildRoleSelector() {
    final roles = [
      (Role.agente, Icons.gavel_rounded, 'Agente Aduanal', AppColors.gold),
      (
        Role.importador,
        Icons.local_shipping_rounded,
        'Importador/Exportador',
        AppColors.blue
      ),
      (
        Role.consultor,
        Icons.factory_outlined,
        'Empresa IMMEX',
        AppColors.green
      ),
    ];
    return Column(
        children: roles.map((r) {
      final selected = _role == r.$1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () => setState(() => _role = r.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? r.$4.withValues(alpha: 0.1) : AppColors.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: selected ? r.$4 : border, width: selected ? 1.5 : 1),
            ),
            child: Row(children: [
              Icon(r.$2, color: selected ? r.$4 : sub, size: 20),
              const SizedBox(width: 12),
              Text(r.$3,
                  style: TextStyle(
                      color: selected ? r.$4 : text,
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal)),
              const Spacer(),
              if (selected)
                Icon(Icons.check_circle_rounded, color: r.$4, size: 18),
            ]),
          ),
        ),
      );
    }).toList());
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: sub,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5));

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType? keyboardType,
      bool isPassword = false,
      bool obscure = false,
      VoidCallback? onToggle}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      obscureText: isPassword ? obscure : false,
      style: const TextStyle(color: text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: sub.withValues(alpha: 0.5), fontSize: 14),
        filled: true,
        fillColor: AppColors.bg,
        prefixIcon: Icon(icon, color: sub, size: 18),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: sub,
                    size: 18),
                onPressed: onToggle,
              )
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: gold.withValues(alpha: 0.7), width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _RegBgPainter extends CustomPainter {
  final double t;
  _RegBgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.bg, Color(0xFF0A1628), AppColors.bg],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final orbData = [
      (0.8, 0.15, 250.0, AppColors.gold, 0.2),
      (0.1, 0.8, 200.0, const Color(0xFF1E4080), 0.0),
      (0.5, 0.5, 150.0, const Color(0xFF0D5C8A), 0.5),
    ];
    for (final o in orbData) {
      final phase = (t + o.$5) % 1.0;
      final dx = math.sin(phase * math.pi * 2) * 25;
      final dy = math.cos(phase * math.pi * 2) * 18;
      final center = Offset(size.width * o.$1 + dx, size.height * o.$2 + dy);
      paint.shader = RadialGradient(
        colors: [o.$4.withValues(alpha: 0.12), o.$4.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: o.$3));
      canvas.drawCircle(center, o.$3, paint);
    }
    final lp = Paint()
      ..color = AppColors.border.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), lp);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lp);
    }
  }

  @override
  bool shouldRepaint(_RegBgPainter old) => old.t != t;
}
