import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/seed_data_service.dart';

class PersonaSelectionScreen extends StatefulWidget {
  const PersonaSelectionScreen({super.key});

  @override
  State<PersonaSelectionScreen> createState() => _PersonaSelectionScreenState();
}

class _PersonaSelectionScreenState extends State<PersonaSelectionScreen> {
  bool _isLoading = false;

  Future<void> _selectPersona(String value) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_persona', value);
      await prefs.setString('persona_selected', 'true');
      await prefs.setString('user_role', value);

      await AnalyticsService.instance.logPersonaSelected(value);
      await AnalyticsService.instance.setUserPersona(value);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'persona': value},
          SetOptions(merge: true),
        );
      }

      await SeedDataService.instance.seedIfNeeded();

      if (mounted) {
        if (value == 'novato') {
          context.go('/guided_onboarding');
        } else {
          context.go('/home');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.gold))
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        'Aduanas 801',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Entiende tu importación. Habla con tu agente de igual a igual.',
                        style: TextStyle(
                          color: AppColors.sub,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    const Text(
                      'Tu perfil en Aduanas 801',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¿Cómo usas el comercio exterior? Elige tu perfil para personalizar tu experiencia.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _PersonaCard(
                      emoji: '🌱',
                      title: 'Empezando 🌱',
                      subtitle:
                          'Nunca he importado o apenas inicio. Te guiamos paso a paso, sin jerón.',
                      accentColor: const Color(0xFF6366F1),
                      onTap: () => _selectPersona('novato'),
                    ),
                    const SizedBox(height: 16),
                    _PersonaCard(
                      emoji: '📦',
                      title: 'Importador 📦',
                      subtitle:
                          'Ya importo y quiero controlar mis costos, expedientes y cumplimiento.',
                      accentColor: const Color(0xFF10B981),
                      onTap: () => _selectPersona('importador'),
                    ),
                    const SizedBox(height: 16),
                    _PersonaCard(
                      emoji: '⚖️',
                      title: 'Profesional ⚖️',
                      subtitle:
                          'Soy Agente Aduanal o consultor. Suite avanzada: M3, SAAI, Pre-Glosa y pedimentos.',
                      accentColor: AppColors.gold,
                      onTap: () => _selectPersona('agente'),
                    ),
                    const SizedBox(height: 16),
                    _PersonaCard(
                      emoji: '🌎',
                      title: 'Exportador 🌎',
                      subtitle:
                          'Exporto, tengo maquila o vendo al extranjero. IMMEX, Drawback y Cert. Origen.',
                      accentColor: const Color(0xFF10B981),
                      onTap: () => _selectPersona('exportador'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PersonaCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _PersonaCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_PersonaCard> createState() => _PersonaCardState();
}

class _PersonaCardState extends State<_PersonaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: widget.accentColor, width: 4),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Text(
                widget.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: widget.accentColor,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
