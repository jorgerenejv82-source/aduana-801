import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../importer/widgets/quick_calculator_widget.dart';

class ImporterHubScreen extends StatelessWidget {
  const ImporterHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Portal del Importador',
          style: TextStyle(color: Color(0xFFF8FAFC)),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF8FAFC)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '¡Hola! ¿Listo para tu próxima importación?',
              style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simplificamos tus procesos de aduanas con inteligencia artificial.',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Hero CTA
            InkWell(
              onTap: () => context.go('/mi_primer_despacho'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inicia tu Primera Importación',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Guiada por Inteligencia Artificial',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Calculator Section
            const QuickCalculatorWidget(),

            const SizedBox(height: 32),
            const Text(
              'Herramientas',
              style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Secondary Section (4 original options)
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildToolCard(
                    icon: Icons.history,
                    title: 'Historia\nOperaciones',
                    onTap: () {
                      // Navigate to history
                    },
                  ),
                  _buildToolCard(
                    icon: Icons.monetization_on_outlined,
                    title: 'Landed\nCost',
                    onTap: () {
                      // Navigate to landed cost
                    },
                  ),
                  _buildToolCard(
                    icon: Icons.verified_user_outlined,
                    title: 'Compliance',
                    onTap: () {
                      // Navigate to compliance
                    },
                  ),
                  _buildToolCard(
                    icon: Icons.folder_outlined,
                    title: 'Documentos',
                    onTap: () {
                      // Navigate to documents
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 16),
      child: Material(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF475569)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFFF59E0B), size: 32),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
