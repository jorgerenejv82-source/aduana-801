import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:aduana_801/features/home/widgets/breadcrumb_nav.dart';

class GlosarioScreen extends StatefulWidget {
  const GlosarioScreen({super.key});

  @override
  State<GlosarioScreen> createState() => _GlosarioScreenState();
}

class _GlosarioScreenState extends State<GlosarioScreen> {
  final TextEditingController _search = TextEditingController();
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos',
    'Aduanas',
    'Impuestos',
    'Documentos',
    'Incoterms',
    'Logística',
    'Actores',
    'Cumplimiento',
    'Finanzas',
    'Régimenes',
    'Proceso',
    'Clasificación',
    'Acuerdos',
    'Servicios',
    'Operaciones'
  ];

  final List<Map<String, String>> _terminos = [
    {
      'term': 'Pedimento',
      'categoria': 'Aduanas',
      'def':
          'El documento oficial que declara ante el SAT qué mercancía entra o sale de México. Es el equivalente de una declaración de impuestos, pero para tus importaciones. Sin pedimento, tu mercancía no puede cruzar la frontera.',
      'ejemplo':
          'Tu proveedor en China te envía 500 playeras. Tu agente aduanal elabora el pedimento declarando: 500 playeras de algodón, fracción 6109.10.01, valor FOB \$2,500 USD.'
    },
    {
      'term': 'Fracción Arancelaria',
      'categoria': 'Clasificación',
      'def':
          'El código numérico (8 dígitos) que identifica específicamente tu producto en la Tarifa del IGIE. De este código depende cuánto arancel pagas. Si la fracción es incorrecta, el SAT puede multarte.',
      'ejemplo':
          '6109.10.01 = Camisetas de algodón para hombre. 8517.12.01 = Teléfonos celulares.'
    },
    {
      'term': 'Arancel / IGI',
      'categoria': 'Impuestos',
      'def':
          'El impuesto que pagas al importar mercancía extranjera a México. Se calcula como % del valor de tu mercancía. Puede ser 0% (libre) o hasta 300%+ para productos con medidas anti-dumping.',
      'ejemplo':
          'Importas tela por \$10,000 USD. El arancel es 10% = pagas \$1,000 USD de IGI.'
    },
    {
      'term': 'FOB (Free On Board)',
      'categoria': 'Incoterms',
      'def':
          'El precio de tu mercancía puesta en el barco en el puerto de origen, SIN incluir el flete marítimo ni el seguro. Es el precio que más se usa en facturas de importación desde Asia.',
      'ejemplo':
          'Tu proveedor cobra \$5,000 USD FOB Shanghai = precio hasta que sube al barco en Shanghai. El flete hasta México es aparte.'
    },
    {
      'term': 'CIF (Cost, Insurance & Freight)',
      'categoria': 'Incoterms',
      'def':
          'Precio que incluye el costo de la mercancía + el flete marítimo + el seguro hasta el puerto de destino en México. Es la base para calcular el valor en aduana.',
      'ejemplo':
          'Si tu factura dice CIF Manzanillo \$6,000 USD, ese es el valor que el SAT usará para calcular tus impuestos.'
    },
    {
      'term': 'Valor en Aduana',
      'categoria': 'Impuestos',
      'def':
          'El valor oficial sobre el que el SAT calcula tus impuestos. Generalmente es el valor CIF (precio + flete + seguro hasta México). Si tu incoterm es FOB, debes sumar el flete y el seguro para obtener el valor en aduana.',
      'ejemplo':
          'Mercancía FOB \$10,000 + Flete \$800 + Seguro \$200 = Valor en Aduana \$11,000.'
    },
    {
      'term': 'DTA',
      'categoria': 'Impuestos',
      'def':
          'Derecho de Trámite Aduanero. Es una cuota que cobra el gobierno por el servicio de despacho aduanal. Se calcula como el 8 al millar del valor en aduana, con un mínimo de ~\$423 pesos y un máximo de \$914 pesos.',
      'ejemplo': 'Valor en aduana \$100,000 MXN × 0.8% = \$800 MXN de DTA.'
    },
    {
      'term': 'IVA de Importación',
      'categoria': 'Impuestos',
      'def':
          'El 16% de IVA que se paga al importar, calculado sobre el valor en aduana + el arancel. A diferencia del IVA normal, éste se paga en la aduana al momento del despacho. Si eres empresa, puedes acreditarlo en tu declaración mensual.',
      'ejemplo':
          'Valor en aduana \$100,000 + IGI \$10,000 = base \$110,000 × 16% = \$17,600 de IVA.'
    },
    {
      'term': 'Agente Aduanal',
      'categoria': 'Actores',
      'def':
          'La persona con patente del SAT que puede legalmente hacer tus trámites de importación y exportación. Es obligatorio contratar uno para importaciones comerciales. Es como tu contador, pero para aduanas.',
      'ejemplo':
          'Sin agente aduanal, tu contenedor de China no puede salir de la aduana de Manzanillo.'
    },
    {
      'term': 'Padrón de Importadores',
      'categoria': 'Requisitos',
      'def':
          'El registro obligatorio ante el SAT para poder importar mercancía a México. Debes estar en este padrón antes de hacer tu primera importación. Se tramita en el portal del SAT y tarda entre 5-15 días hábiles.',
      'ejemplo':
          'Si no estás en el Padrón, tu agente no puede hacer el pedimento a tu nombre.'
    },
    {
      'term': 'B/L (Bill of Lading)',
      'categoria': 'Documentos',
      'def':
          'El conocimiento de embarque. Es el título de propiedad de tu mercancía durante el transporte marítimo. Sin el B/L original (o telex release), la naviera no entrega tu contenedor.',
      'ejemplo':
          'Maersk te envía el B/L por email cuando tu contenedor sale de Shanghai.'
    },
    {
      'term': 'Incoterm',
      'categoria': 'Incoterms',
      'def':
          'Reglas internacionales que definen quién paga qué y hasta dónde en una compraventa internacional. Determinan quién paga el flete, el seguro, y quién asume el riesgo si la mercancía se pierde o daña.',
      'ejemplo':
          'FOB = el vendedor paga hasta subir al barco. CIF = el vendedor paga hasta tu puerto.'
    },
    {
      'term': 'NOM (Norma Oficial Mexicana)',
      'categoria': 'Cumplimiento',
      'def':
          'Las normas obligatorias que deben cumplir ciertos productos para poder comercializarse en México. Si tu producto requiere NOM y no la tiene, la aduana lo retiene o destruye.',
      'ejemplo':
          'Los juguetes deben cumplir NOM-015-SCFI. Los cargadores eléctricos deben cumplir NOM-019-SCFI.'
    },
    {
      'term': 'TMEC / USMCA',
      'categoria': 'Acuerdos',
      'def':
          'Tratado comercial entre México, USA y Canadá. Si tu mercancía proviene de USA o Canadá y califica como originaria (con Certificado de Origen), puedes importarla pagando 0% de arancel.',
      'ejemplo':
          'Importas máquinas de USA. Con C.O. TMEC válido, tu IGI = 0% en lugar del 5% general.'
    },
    {
      'term': 'Previo de Revisión (PRV)',
      'categoria': 'Servicios',
      'def':
          'La revisión previa que hace el agente aduanal a tus documentos y mercancía antes de presentar el pedimento. Es obligatorio para mercancía sujeta a NOMs o permisos especiales. Cuesta ~\$1,200-\$2,500 MXN.',
      'ejemplo':
          'Importas electrónicos. El PRV verifica que el modelo esté en tu NOM-019 antes de pasar al SAT.'
    },
    {
      'term': 'Semáforo Fiscal',
      'categoria': 'Aduanas',
      'def':
          'El sistema aleatorio del SAT que determina si tu mercancía pasa sin revisión (verde) o requiere revisión documental (naranja) o física (rojo).',
      'ejemplo':
          'Verde = tu contenedor sale de la aduana sin que nadie lo abra. Rojo = el verificador conta y pesa tu mercancía.'
    },
    {
      'term': 'Landed Cost',
      'categoria': 'Finanzas',
      'def':
          'El costo total de tu mercancía PUESTA EN TU ALMACÉN en México. Incluye: precio de compra + flete + seguro + impuestos (IGI+IVA+DTA) + agente aduanal + maniobras.',
      'ejemplo':
          'Compras a \$10,000 USD FOB. Landed Cost final: \$220,000 MXN (ya con todo pagado en tu almacén).'
    },
    {
      'term': 'Carta de Crédito (LC)',
      'categoria': 'Finanzas',
      'def':
          'Instrumento de pago bancario donde tu banco garantiza al proveedor que le pagará cuando cumpla ciertas condiciones (entrega de documentos). Reduce el riesgo de fraude en comercio internacional.',
      'ejemplo':
          'Le pides a BBVA que emita una LC a tu proveedor chino por \$50,000 USD. El proveedor entrega los documentos al banco y cobra.'
    },
    {
      'term': 'Exportación',
      'categoria': 'Operaciones',
      'def':
          'La salida definitiva de mercancía de México hacia el extranjero. También requiere pedimento y agente aduanal. Las exportaciones generalmente no pagan arancel pero deben declararse.',
      'ejemplo':
          'Vendes muebles a un cliente en California. Necesitas pedimento de exportación y factura en dólares.'
    },
    {
      'term': 'IMMEX',
      'categoria': 'Régimenes',
      'def':
          'Programa especial del gobierno para empresas que importan temporalmente insumos para fabricar productos y exportarlos. Las empresas IMMEX no pagan IGI ni IVA en sus importaciones de insumos. Es como el "Free Trade Zone" mexicano.',
      'ejemplo':
          'Maquiladora en Tijuana importa partes de USA, las ensambla y exporta el producto terminado a USA. No paga impuestos en las partes importadas.'
    },
    {
      'term': 'Despacho Aduanal',
      'categoria': 'Proceso',
      'def':
          'El proceso completo de tramitar la entrada o salida de mercancía de México. Incluye: revisar documentos, clasificar la mercancía, calcular impuestos, presentar el pedimento al SAT, pasar el semáforo y recoger la mercancía.',
      'ejemplo':
          'Tu contenedor llega a Lazaro Cárdenas. El despacho aduanal tarda 1-5 días hábiles.'
    },
    {
      'term': 'Factura Comercial',
      'categoria': 'Documentos',
      'def':
          'La factura que te da tu proveedor internacional. Debe describir la mercancía, cantidad, precio unitario, valor total, incoterm, país de origen y datos de comprador/vendedor. Es el documento más importante para el despacho.',
      'ejemplo':
          'Tu proveedor chino te manda: Invoice No. CN2026-001, 500 pcs Cotton T-Shirts, USD \$5,000 FOB Shanghai.'
    },
    {
      'term': 'Packing List',
      'categoria': 'Documentos',
      'def':
          'El documento que detalla exactamente qué viene en cada caja o pallet: peso, dimensiones, número de piezas por caja. La aduana lo usa para verificar que lo que declaras coincide con lo que físicamente viene.',
      'ejemplo':
          'Box 1: 50 pcs White T-Shirt Size M, 5 kg. Box 2: 50 pcs Blue T-Shirt Size L, 5.2 kg.'
    },
    {
      'term': 'Aduana',
      'categoria': 'Actores',
      'def':
          'La oficina gubernamental del SAT ubicada en puertos, aeropuertos y cruces fronterizos donde se despacha la mercancía. Las principales aduanas de México son: Nuevo Laredo, Lázaro Cárdenas, Manzanillo, Veracruz, AICM y Tijuana.',
      'ejemplo':
          'Tu mercancía de China entra por la aduana de Manzanillo o Lázaro Cárdenas.'
    },
    {
      'term': 'Flete',
      'categoria': 'Logística',
      'def':
          'El costo del transporte de tu mercancía. En importaciones desde Asia generalmente se cotiza por contenedor (FCL) o por metro cúbico (LCL). El flete internacional puede variar mucho según la época del año.',
      'ejemplo':
          'Contenedor de 20 pies de Shanghai a Manzanillo: \$2,000-\$4,000 USD dependiendo de la temporada.'
    },
    {
      'term': 'FCL vs LCL',
      'categoria': 'Logística',
      'def':
          'FCL (Full Container Load): alquilas el contenedor completo para tu sola mercancía. LCL (Less than Container Load): compartes el contenedor con otros importadores. FCL sale mejor si tienes suficiente mercancía.',
      'ejemplo':
          'Menos de 10 CBM: usa LCL. Más de 15 CBM: considera FCL (contenedor de 20 pies).'
    },
    {
      'term': 'ETA',
      'categoria': 'Logística',
      'def':
          'Estimated Time of Arrival. La fecha estimada en que llega tu barco al puerto. Es importante monitorear el ETA para tener tus documentos listos antes de que llegue.',
      'ejemplo':
          'ETA Manzanillo: 15/Sep/2026. Si tus documentos no están listos para esa fecha, tu mercancía queda en almacén y pagas demurrage.'
    },
    {
      'term': 'Demurrage',
      'categoria': 'Logística',
      'def':
          'El cargo diario que cobra la naviera si no recoges el contenedor dentro del tiempo libre (free time) acordado. Puede ser \$75-\$200 USD por día por contenedor. Es uno de los costos ocultos más dolorosos para novatos.',
      'ejemplo':
          'Tu contenedor llega el 15/Sep. Tienes 7 días libres. Si lo recoges el 25/Sep, pagas 3 días × \$150 = \$450 USD de demurrage.'
    },
    {
      'term': 'Proveedor (Supplier)',
      'categoria': 'Actores',
      'def':
          'La empresa extranjera que te vende y envía la mercancía. Antes de pagar, verifica su reputación, pide muestras y revisa que puedan darte los documentos correctos (factura, packing list, certificado de origen).',
      'ejemplo':
          'Encuentras proveedores en Alibaba, Canton Fair, o a través de agentes de compras en China.'
    },
    {
      'term': 'Muestra',
      'categoria': 'Proceso',
      'def':
          'Los productos de prueba que pides antes de hacer tu pedido grande. Las muestras se pueden importar libre de impuestos si valen menos de \$300 USD (Art. 61 fracc. VI Ley Aduanera). Es el primer paso siempre.',
      'ejemplo':
          'Pides 3 muestras de tela a tu proveedor en China. Las recibes por DHL sin pagar impuestos porque valen \$150 USD.'
    },
    {
      'term': 'Cuota Compensatoria',
      'categoria': 'Impuestos',
      'def':
          'Arancel adicional que cobra México a ciertos productos de ciertos países por prácticas de dumping (vender muy barato para destruir la industria local). El acero de China tiene cuotas compensatorias de hasta 67.5%.',
      'ejemplo':
          'Quieres importar acero de China. Arancel normal: 5%. Cuota compensatoria: 67.5%. Total: 72.5% sobre tu valor en aduana.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Aduanas':
        return AppColors.blue;
      case 'Impuestos':
        return AppColors.red;
      case 'Documentos':
        return AppColors.sub;
      case 'Incoterms':
        return AppColors.gold;
      case 'Logística':
        return AppColors.green;
      case 'Actores':
        return Colors.purple;
      case 'Cumplimiento':
        return Colors.orange;
      case 'Finanzas':
        return Colors.teal;
      case 'Régimenes':
        return Colors.indigo;
      case 'Proceso':
        return Colors.pink;
      case 'Clasificación':
        return Colors.cyan;
      case 'Acuerdos':
        return Colors.lightBlue;
      case 'Servicios':
        return Colors.lightGreen;
      case 'Operaciones':
        return Colors.amber;
      case 'Requisitos':
        return Colors.deepPurple;
      default:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _search.text.toLowerCase();

    final filteredTerms = _terminos.where((Map<String, String> t) {
      final matchesCategory =
          _selectedCategory == 'Todos' || t['categoria'] == _selectedCategory;
      final matchesSearch =
          (t['term'] ?? '').toLowerCase().contains(searchQuery) ||
              (t['def'] ?? '').toLowerCase().contains(searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Glosario de Comercio Exterior',
            style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.card,
        iconTheme: const IconThemeData(color: AppColors.text),
        bottom: BreadcrumbNav(items: [
          BreadcrumbItem(label: 'Inicio', route: '/'),
          BreadcrumbItem(label: 'Aprender'),
          BreadcrumbItem(label: 'Glosario'),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/copiloto'),
        label: const Text('🤖 Pregunta al Copiloto'),
        backgroundColor: AppColors.gold,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _search,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Buscar término o definición...',
                hintStyle: const TextStyle(color: AppColors.sub),
                prefixIcon: const Icon(Icons.search, color: AppColors.sub),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          const SizedBox(height: 16),
          Expanded(
            child: filteredTerms.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off,
                              size: 64, color: AppColors.sub),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontró "${_search.text}" en el glosario.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.text, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pregunta al Asistente IA abajo.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: AppColors.sub, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTerms.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final Map<String, String> term = filteredTerms[index];
                      final catColor =
                          _getColorForCategory(term['categoria'] ?? '');
                      return Card(
                        color: AppColors.card,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: catColor.withValues(alpha: 0.2),
                              child: Text(
                                (term['term'] ?? '').isNotEmpty
                                    ? (term['term'] ?? '')[0].toUpperCase()
                                    : '',
                                style: TextStyle(
                                    color: catColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(term['term'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(term['categoria'] ?? '',
                                style: const TextStyle(
                                    color: AppColors.sub, fontSize: 12)),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      term['def'] ?? '',
                                      style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 14,
                                          height: 1.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppColors.gold
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.lightbulb_outline,
                                              color: AppColors.gold, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Ejemplo: ${term["ejemplo"] ?? ''}',
                                              style: const TextStyle(
                                                  color: AppColors.gold,
                                                  fontSize: 13,
                                                  height: 1.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
