import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class LearningCenterScreen extends StatefulWidget {
  const LearningCenterScreen({super.key});

  @override
  State<LearningCenterScreen> createState() => _LearningCenterScreenState();
}

class _LearningCenterScreenState extends State<LearningCenterScreen> {
  final PageController _tipsController = PageController();

  final List<String> tips = [
    '⚠️ Nunca pagues 100% adelantado a un proveedor nuevo. Usa 30% anticipo + 70% contra documentos.',
    '📅 Ten tus documentos listos ANTES de que llegue el barco. Cada día en almacén cuesta dinero.',
    '🔍 Pide siempre muestras antes del pedido grande. Las muestras de <\$300 USD entran sin impuestos.',
    '🇺🇸🇲🇽 Si importas de USA o Canadá, verifica si aplica TMEC. Puede bajar tu arancel a 0%.',
    '🤐 La fracción arancelaria la decide el agente aduanal, no el proveedor. Verifica siempre en SIAVI.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('Centro de Aprendizaje',
            style: TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue, AppColors.card],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎓 Centro de Aprendizaje',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      'Todo lo que necesitas para empezar en el comercio exterior, explicado sin jerga técnica.',
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 16),
                  Text('Has completado 15% de tu viaje de aprendizaje',
                      style: TextStyle(
                          color: AppColors.gold, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                      value: 0.15,
                      backgroundColor: Colors.white24,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.gold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1
            const Text('Empieza Aquí',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildLargeCard(
                      '🧭 Mi Primera Importación',
                      '10 pasos desde cero hasta tu mercancía en manos',
                      '/mi_primer_despacho',
                      AppColors.green),
                  _buildLargeCard(
                      '🧭 ¿Cuánto me cuesta importar?',
                      'Calculadora en lenguaje simple, sin jerga',
                      '/simple_estimator',
                      AppColors.blue),
                  _buildLargeCard(
                      '🧭 ¿Qué necesito para MI producto?',
                      'Permisos, NOMs y restricciones específicas',
                      '/requisitos_producto',
                      Colors.purple),
                  _buildLargeCard(
                      '🧭 ¿Cuándo llega mi mercancía?',
                      'Estimador de tiempos de entrega',
                      '/timeline_estimator',
                      AppColors.gold),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2
            const Text('Aprende los conceptos',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildGridItem('📖 Glosario ComEx', '30+ términos explicados',
                    '/glosario', Icons.menu_book),
                _buildGridItem('❓ Preguntas Frecuentes', '12 dudas resueltas',
                    '/faq', Icons.help_outline),
                _buildGridItem(
                    '🚢 Guía de Incoterms',
                    'FOB, CIF, EXW... explicados',
                    '/incoterms',
                    Icons.directions_boat),
                _buildGridItem('🤖 Pregunta al Copiloto IA',
                    'En lenguaje natural, 24/7', '/copiloto', Icons.smart_toy),
              ],
            ),
            const SizedBox(height: 24),

            // Section 3
            const Text('Herramientas del Novato',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildListTile(
                'Clasificador de producto',
                'Encuentra la fracción arancelaria de lo que quieres importar',
                '/clasificador_ia'),
            _buildListTile(
                'Comparador de Incoterms', '¿Quién paga qué?', '/incoterms'),
            _buildListTile('Comparador de regímenes',
                'A1 vs IMMEX vs RFE ¿cuál me conviene?', '/regimen_comparator'),
            _buildListTile('Verificador de proveedores',
                '¿Mi proveedor es confiable ante el SAT?', '/rfc_verificador'),
            _buildListTile('Permisos y NOMs de mi producto',
                '¿Qué autoridades regulan mi mercancía?', '/permisos_previos'),
            const SizedBox(height: 24),

            // Section 4
            const Text('Tips del experto',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: PageView.builder(
                controller: _tipsController,
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(tips[index],
                          style: const TextStyle(
                              color: AppColors.text, fontSize: 16),
                          textAlign: TextAlign.center),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeCard(
      String title, String subtitle, String route, Color color) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(color: AppColors.sub, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(
      String title, String subtitle, String route, IconData icon) {
    return InkWell(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blue, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(subtitle,
                      style:
                          const TextStyle(color: AppColors.sub, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle, String route) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: const TextStyle(
              color: AppColors.text, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.sub)),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: AppColors.sub, size: 16),
      onTap: () => context.push(route),
    );
  }
}
