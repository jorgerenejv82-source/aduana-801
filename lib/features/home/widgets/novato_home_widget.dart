import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:aduana_801/core/theme/app_text_styles.dart';
import 'next_step_widget.dart';
import '../../profile/setup_completeness_widget.dart';

class NovatoHomeWidget extends StatefulWidget {
  final String userName;
  const NovatoHomeWidget({super.key, required this.userName});

  @override
  State<NovatoHomeWidget> createState() => _NovatoHomeWidgetState();
}

class _NovatoHomeWidgetState extends State<NovatoHomeWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tips = [
      'El IVA en importaciones se paga ANTES de retirar la mercancía de la aduana.',
      'El FOB es el precio puesta en el barco. El flete y seguro se agregan después.',
      'La fracción arancelaria son 8 dígitos que clasifican tu producto: el CURP de tu mercancía.',
      'El DTA es un derecho que pagas al gobierno por usar la aduana: entre \$423 y \$914 MXN.',
      'IMMEX permite importar materias primas sin impuestos si las exportas transformadas.',
      'El B/L es el título de propiedad en el barco. Sin él, no retiras nada.',
      'El semáforo es al azar: Verde = pasa. Rojo = revisión física. Naranja = revisión documental.',
    ];
    final tipIndex = (DateTime.now().weekday - 1) % 7;
    final tip = tips[tipIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${widget.userName}! 🌱',
                style:
                    AppTextStyles.displayMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Empieza tu viaje en el comercio exterior',
                style: AppTextStyles.headlineMedium
                    .copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Text(
                'Tu guía de comercio exterior',
                style:
                    AppTextStyles.labelMedium.copyWith(color: AppColors.gold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const NextStepWidget(),
        const SizedBox(height: 24),
        const SetupCompletenessWidget(userPersona: 'novato'),
        const SizedBox(height: 24),

        // 3 Primary Action Cards
        _buildActionCard(
          context,
          title: '¿Cuánto cuesta importar algo?',
          subtitle: 'Calcula el costo total en menos de 2 minutos',
          icon: Icons.search,
          borderColor: const Color(0xFF10B981),
          onTap: () => context.push('/simple_estimator'),
        ),
        const SizedBox(height: 8),
        _buildActionCard(
          context,
          title: 'Entiende tu pedimento',
          subtitle: 'Glosario, FAQs y guías en español claro',
          icon: Icons.menu_book,
          borderColor: AppColors.gold,
          onTap: () => context.push('/learning_center'),
        ),
        const SizedBox(height: 8),
        _buildActionCard(
          context,
          title: 'Hablar con el Copiloto',
          subtitle: 'Resuelve tus dudas al instante',
          icon: Icons.smart_toy,
          borderColor: const Color(0xFF6366F1),
          onTap: () => context.push('/copiloto'),
        ),
        const SizedBox(height: 24),

        // Tip del día
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: const Icon(Icons.lightbulb, color: AppColors.gold),
            title:
                const Text('Tip del día', style: AppTextStyles.headlineSmall),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(tip, style: AppTextStyles.bodyMedium),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickChip(
                  context, '💰 ¿Cuánto cuesta?', '/simple_estimator'),
              const SizedBox(width: 8),
              _buildQuickChip(context, '📚 Aprender ComEx', '/learning_center'),
              const SizedBox(width: 8),
              _buildQuickChip(context, '🤖 Preguntarle a la IA', '/copiloto'),
              const SizedBox(width: 8),
              _buildQuickChip(
                  context, '📄 Mi Primer Despacho', '/mi_primer_despacho'),
              const SizedBox(width: 8),
              _buildQuickChip(context, '🏢 Verificar RFC', '/rfc_verificador'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color borderColor,
    required VoidCallback onTap,
    double? progress,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: borderColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                  if (progress != null) ...[
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.bg,
                      color: borderColor,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.sub),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(BuildContext context, String label, String route) {
    return ActionChip(
      label: Text(label),
      backgroundColor: AppColors.card,
      labelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: AppColors.border),
      onPressed: () => context.push(route),
    );
  }
}
