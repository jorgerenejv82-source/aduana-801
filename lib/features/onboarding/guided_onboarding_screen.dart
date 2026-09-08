import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/analytics_service.dart';

class GuidedOnboardingScreen extends StatefulWidget {
  const GuidedOnboardingScreen({super.key});

  @override
  State<GuidedOnboardingScreen> createState() => _GuidedOnboardingScreenState();
}

class _GuidedOnboardingScreenState extends State<GuidedOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 1
  List<String> selectedCategories = [];
  final TextEditingController _otherCategoryController =
      TextEditingController();

  // Step 2
  String? selectedAgentOption;

  // Step 3
  String? selectedFrequency;

  bool _isLoading = false;

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final prefs = await SharedPreferences.getInstance();

      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'onboarding_completed': true,
          'import_categories': selectedCategories,
          'has_agent': selectedAgentOption,
          'import_frequency': selectedFrequency,
        }, SetOptions(merge: true));
      }

      await prefs.setBool('onboarding_completed', true);
      await AnalyticsService.instance.logOnboardingCompleted('novato');

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      String answer = '';
      if (_currentPage == 0) answer = selectedCategories.join(',');
      if (_currentPage == 1) answer = selectedAgentOption ?? 'none';
      AnalyticsService.instance.logOnboardingStep(_currentPage + 1, answer);

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      AnalyticsService.instance
          .logOnboardingStep(3, selectedFrequency ?? 'none');
      _completeOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paso ${_currentPage + 1}/3',
                    style:
                        const TextStyle(color: Color(0xFF64748B), fontSize: 16),
                  ),
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: const Text('Omitir',
                        style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),

            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _prevPage,
                      child: const Text('← Volver',
                          style: TextStyle(color: Colors.white)),
                    )
                  else
                    const SizedBox(
                        width: 80), // Placeholder to maintain alignment

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _nextPage,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(
                            _currentPage == 2
                                ? 'Comenzar mi experiencia →'
                                : 'Continuar →',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    final categories = [
      'Ropa y textiles',
      'Electrónica',
      'Alimentos',
      'Maquinaria',
      'Cosméticos',
      'Otro'
    ];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📦', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              'Cuéntanos qué quieres importar',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Así te damos la información más relevante para ti',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = selectedCategories.contains(cat);
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedCategories.add(cat);
                      } else {
                        selectedCategories.remove(cat);
                      }
                    });
                  },
                  backgroundColor: const Color(0xFF1E293B),
                  selectedColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFFF59E0B),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFF59E0B) : Colors.white,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF334155),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'También puedes escribirlo:',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _otherCategoryController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ej: zapatos de China',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Could update state or just be read at the end
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🤝', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              '¿Trabajas con un agente aduanal?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Personalizamos tu experiencia según tu situación',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
            ),
            const SizedBox(height: 32),
            _OptionCard(
              title: '✅ Sí, ya tengo uno',
              subtitle:
                  'Te ayudamos a verificar sus cobros y entender tus pedimentos',
              isSelected: selectedAgentOption == 'si',
              onTap: () => setState(() => selectedAgentOption = 'si'),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              title: '🔍 Estoy buscando uno',
              subtitle: 'Te mostramos cómo evaluar y elegir un buen agente',
              isSelected: selectedAgentOption == 'buscando',
              onTap: () => setState(() => selectedAgentOption = 'buscando'),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              title: '❓ No sé qué es un agente aduanal',
              subtitle: 'Empezamos desde cero, paso a paso',
              isSelected: selectedAgentOption == 'no_sabe',
              onTap: () => setState(() => selectedAgentOption = 'no_sabe'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              '¿Con qué frecuencia planeas importar?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esto nos ayuda a mostrarte las herramientas correctas',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
            ),
            const SizedBox(height: 32),
            _OptionCard(
              title: '🌱 Por primera vez',
              subtitle: 'Nunca he importado nada',
              isSelected: selectedFrequency == 'primera_vez',
              onTap: () => setState(() => selectedFrequency = 'primera_vez'),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              title: '📅 Ocasionalmente',
              subtitle: '1-3 veces al año',
              isSelected: selectedFrequency == 'ocasional',
              onTap: () => setState(() => selectedFrequency = 'ocasional'),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              title: '📦 Regularmente',
              subtitle: '4-12 veces al año',
              isSelected: selectedFrequency == 'regular',
              onTap: () => setState(() => selectedFrequency = 'regular'),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              title: '🚀 Frecuentemente',
              subtitle: 'Más de una vez al mes',
              isSelected: selectedFrequency == 'frecuente',
              onTap: () => setState(() => selectedFrequency = 'frecuente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFF59E0B) : const Color(0xFF334155),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFF59E0B)),
          ],
        ),
      ),
    );
  }
}
