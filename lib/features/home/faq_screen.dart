import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos',
    '💼 Requisitos',
    '💰 Costos',
    '⏱️ Tiempos',
    '⚠️ Problemas',
    '📚 Clasificación',
    '🚢 Logística',
    '🌍 Incoterms',
    '🏷️ Régimenes'
  ];

  final List<Map<String, String>> _faqs = [
    {
      'q': '¿Necesito ser empresa para importar?',
      'a':
          'No necesariamente. Puedes importar como persona física con RFC de actividad empresarial. Sin embargo, para importaciones frecuentes o de alto valor, se recomienda operar como persona moral (empresa) porque puedes acreditar el IVA de importación y llevar mejor control contable.',
      'cat': '💼 Requisitos'
    },
    {
      'q': '¿Qué necesito para inscribirme al Padrón de Importadores?',
      'a':
          'Para inscribirte necesitas: 1) RFC activo con al menos 2 meses de antiguedad, 2) E-firma (FIEL) vigente, 3) Domicilio fiscal verificable, 4) Estar al corriente en tus obligaciones fiscales. El trámite es en linea en el portal del SAT (sat.gob.mx) y tarda 5-15 días hábiles. Tu agente aduanal puede ayudarte.',
      'cat': '💼 Requisitos'
    },
    {
      'q': '¿Cuánto cuesta contratar un agente aduanal?',
      'a':
          'Los honorarios varían mucho. Un despacho simple puede costar \$2,500-\$8,000 MXN. Algunos cobran por operación, otros por volumen. Además de honorarios, hay gastos de maniobras, almacenaje, previo, etc. Pide siempre una cotización detallada antes de contratar.',
      'cat': '💰 Costos'
    },
    {
      'q': '¿Cuánto tiempo tarda una importación desde China?',
      'a':
          'El tiempo total aproximado es: Producción: 15-45 días. Flete marítimo Shanghai-Manzanillo: 22-28 días. Despacho aduanal: 1-5 días. Transporte interno: 1-3 días. Total: 40-80 días desde que colocas el pedido hasta que tienes la mercancía en tu almacén.',
      'cat': '⏱️ Tiempos'
    },
    {
      'q': '¿Cuánto voy a pagar de impuestos?',
      'a':
          'Depende del producto y su origen. La fórmula básica: (Valor en Aduana × % Arancel) + DTA + (Base × 16% IVA). Un importador promedio paga entre 18-25% del valor de su mercancía en impuestos. Usa la calculadora de Landed Cost en esta app para estimar tu caso específico.',
      'cat': '💰 Costos'
    },
    {
      'q': '¿Qué pasa si mi producto llega y no tengo todos los documentos?',
      'a':
          'Tu mercancía queda en el almacén de la aduana y empiezas a acumular cargos de almacenaje y demurrage (cobro de la naviera por el contenedor). Si en 3 meses no se despacha, el SAT puede declarar la mercancía en abandono. Siempre ten tus documentos listos ANTES de que llegue el barco.',
      'cat': '⚠️ Problemas'
    },
    {
      'q': '¿Puedo importar cualquier producto?',
      'a':
          'La mayoría sí, pero algunos productos tienen restricciones: armas y explosivos (requieren permiso SEDENA), medicamentos y alimentos (requieren registro COFEPRIS), plantas y animales (requieren SENASICA), sustancias químicas peligrosas (requieren SEMARNAT). Y algunos productos están prohibidos completamente.',
      'cat': '💼 Requisitos'
    },
    {
      'q': '¿Cómo encuentro la fracción arancelaria de mi producto?',
      'a':
          'Tienes 3 opciones: 1) Usa el Clasificador IA de esta app (recomendado para empezar, pero valida el resultado). 2) Busca en el SIAVI del SAT (siavi4.economia.gob.mx). 3) Pregunta a tu agente aduanal. La fracción arancelaria es de 8 dígitos y determina el arancel que pagarás.',
      'cat': '📚 Clasificación'
    },
    {
      'q': '¿Qué es mejor: importar por mar o por avion?',
      'a':
          'Depende de tu mercancía. Marítimo: más barato pero tarda 30-35 días desde Asia. Aéreo: 5-7 veces más caro pero llega en 3-7 días. Regla general: si tu mercancía vale más de \$50 USD/kg, considera aéreo. Si vale menos, marítimo. Para muestras o urgencias, siempre aéreo.',
      'cat': '🚢 Logística'
    },
    {
      'q': '¿Qué es el Incoterm FOB y por qué todos lo usan?',
      'a':
          'FOB (Free On Board) significa que el precio de tu proveedor incluye la mercancía hasta subirla al barco en el puerto de origen. Tú pagas el flete marítimo y el seguro desde ahí. Es el más común porque te da control sobre el flete (puedes comparar precios de freight forwarders) y es claro para calcular impuestos.',
      'cat': '🌍 Incoterms'
    },
    {
      'q': '¿Puedo hacer mi primera importación sin agente aduanal?',
      'a':
          'Para importaciones comerciales mayores a \$1,000 USD, por ley necesitas un agente aduanal o apoderado aduanal. Solo puedes despachar sin agente si importas para uso personal (no para venta) y el valor está bajo el límite de exención (~\$1,000 USD). Para cualquier negocio, usa un agente.',
      'cat': '💼 Requisitos'
    },
    {
      'q': '¿Cuándo conviene tener programa IMMEX?',
      'a':
          'El programa IMMEX conviene si: 1) Importas insumos para fabricar productos y exportarlos. 2) Importas más de \$500K USD al año. 3) Quieres diferir el pago de IGI e IVA. No conviene para importaciones para venta directa en México. El trámite ante SE tarda 2-3 meses.',
      'cat': '🏷️ Régimenes'
    },
  ];

  Color _getColorForCategory(String category) {
    if (category.contains('Requisitos')) return AppColors.blue;
    if (category.contains('Costos')) return AppColors.green;
    if (category.contains('Tiempos')) return Colors.orange;
    if (category.contains('Problemas')) return AppColors.red;
    if (category.contains('Clasificación')) return Colors.cyan;
    if (category.contains('Logística')) return Colors.indigo;
    if (category.contains('Incoterms')) return AppColors.gold;
    if (category.contains('Régimenes')) return Colors.purple;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _selectedCategory == 'Todos'
        ? _faqs
        : _faqs.where((f) => f['cat'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Preguntas Frecuentes (FAQ)',
            style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.card,
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat,
                        style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.sub)),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    backgroundColor: AppColors.card,
                    selectedColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFaqs.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final faq = filteredFaqs[index];
                final catColor = _getColorForCategory(faq['cat']!);
                return Card(
                  color: AppColors.card,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(faq['q']!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(faq['cat']!,
                                  style:
                                      TextStyle(color: catColor, fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faq['a']!,
                            style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('¿No encontraste tu respuesta?',
                    style: TextStyle(color: AppColors.sub)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => context.push('/copiloto'),
                  icon: const Text('🤖', style: TextStyle(fontSize: 18)),
                  label: const Text('Preguntar al Copiloto IA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
