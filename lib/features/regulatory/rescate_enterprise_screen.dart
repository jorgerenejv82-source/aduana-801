import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'dart:async';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _verde = AppColors.green;
const Color _teal = AppColors.blue;
const Color _naran = Color(0xFFF97316);

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────
enum _EmergType {
  cargaRetenida,
  pedimentoRechazado,
  mercanciaExtraviada,
  reconocimiento,
  multaImpuesta,
  embargoPrecautorio,
  contenedorExtraviado,
  errorPedimento,
}

class _Protocol {
  final _EmergType type;
  final String nombre;
  final String tiempoCritico;
  final String baseLegal;
  final List<String> pasos;
  final List<String> documentos;
  final String fundamento;
  const _Protocol({
    required this.type,
    required this.nombre,
    required this.tiempoCritico,
    required this.baseLegal,
    required this.pasos,
    required this.documentos,
    required this.fundamento,
  });
}

class _Emergencia {
  final _EmergType type;
  final DateTime inicio;
  String estado; // Activa, En Proceso, Resuelta
  _Emergencia({required this.type, required this.inicio}) : estado = 'Activa';
}

const _protocols = <_EmergType, _Protocol>{
  _EmergType.cargaRetenida: _Protocol(
    type: _EmergType.cargaRetenida,
    nombre: 'Carga Retenida / Embargada',
    tiempoCritico: '48 horas habiles para presentar aclaracion',
    baseLegal: 'Art. 150-152 Ley Aduanera / Art. 117 CFF',
    pasos: [
      'Solicitar ACTA DE EMBARGO a la autoridad aduanera (Art. 150 LA). Sin ella no procede ningun recurso.',
      'Identificar la CAUSA de retencion: valor, clasificacion, documentacion faltante, origen, NOM, cuota compensatoria.',
      'Contactar al agente aduanal Y abogado fiscal de inmediato. No actuar solo.',
      'Presentar escrito de aclaracion con documentacion complementaria dentro de 10 dias habiles.',
      'Si persiste retencion: Recurso de Revocacion en 30 dias habiles (Art. 121 CFF).',
      'Tramitar garantia del credito fiscal si la autoridad lo exige (Art. 89 LA).',
      'Documentar TODO: fotografias, comunicados, fechas exactas con hora.',
    ],
    documentos: [
      'Pedimento original con acuse electronico',
      'Factura comercial del proveedor',
      'BL / Guia aerea / Carta porte',
      'COVE (Comprobante de Valor Electronico)',
      'Certificado de origen si aplica TLC',
      'Catalogo o ficha tecnica del producto',
      'Carta explicativa del importador firmada',
    ],
    fundamento:
        'Art. 150 LA: La autoridad aduanera levantara acta circunstanciada. Art. 152 LA: El importador puede subsanar irregularidades. Art. 121 CFF: Recurso de Revocacion plazo 30 dias habiles.',
  ),
  _EmergType.pedimentoRechazado: _Protocol(
    type: _EmergType.pedimentoRechazado,
    nombre: 'Pedimento Rechazado (SAAI)',
    tiempoCritico: '24 horas: corregir y retransmitir para no vencer plazos',
    baseLegal: 'Art. 36-A Ley Aduanera / RGCE 3.1.3',
    pasos: [
      'Identificar el ERROR ESPECIFICO del rechazo SAAI M3: codigo de error + descripcion.',
      'Clasificar el tipo de error: estructural (formato), de datos (valor, RFC, fraccion), o documental.',
      'Corregir el pedimento en el sistema del agente aduanal (Softland, SADE, ProAA, etc.).',
      'Verificar que los datos coincidan EXACTAMENTE con el COVE en VUCEM.',
      'Retransmitir el pedimento corregido. Si sigue rechazando, escalar con el SAT (SAAI Help Desk: 55 5480-2000).',
      'Si el rechazo implica cambio de valor o clasificacion: actualizar toda la documentacion soporte.',
      'Documentar causa del rechazo y correccion para expediente.',
    ],
    documentos: [
      'Impresion del error SAAI con codigo y descripcion',
      'Pedimento corregido',
      'COVE actualizado si aplica',
      'Factura y documentos de soporte actualizados',
    ],
    fundamento:
        'RGCE 3.1.3: El pedimento transmitido con errores podra corregirse dentro del mismo dia habil. Despues de validado y seleccionado, requiere pedimento de rectificacion.',
  ),
  _EmergType.mercanciaExtraviada: _Protocol(
    type: _EmergType.mercanciaExtraviada,
    nombre: 'Mercancia Perdida en Transito',
    tiempoCritico: '72 horas: notificar a naviera/carrier y seguro',
    baseLegal: 'Art. 82 Ley de Navegacion / COGSA / CMR',
    pasos: [
      'Notificar INMEDIATAMENTE al carrier (naviera/aerolinea/transportista) via escrito formal. Plazo: 72 horas.',
      'Notificar al asegurador de carga. Iniciar el proceso de reclamacion.',
      'Obtener CARTA DE PROTESTA o Note of Protest del capitan del buque.',
      'Solicitar al carrier: Carta de No Responsabilidad o Acuse de Recibo de la Reclamacion.',
      'Si hay robo: levantar denuncia ante el Ministerio Publico o equivalente en pais de origen.',
      'Solicitar Certificado de Averias al representante de la naviera en Mexico.',
      'Calcular el monto del seguro: valor CIF + 10% de acuerdo al certificado de seguro.',
      'Archivar TODA la correspondencia con fechas. La prescripcion es 1 ano (maritimo) o 180 dias (aereo).',
    ],
    documentos: [
      'BL / AWB original',
      'Poliza de seguro de carga',
      'Factura comercial',
      'Packing List',
      'Fotos del ultimo punto de rastreo conocido',
      'Nota de protesta del capitan',
      'Denuncia ante MP si aplica robo',
    ],
    fundamento:
        'Ley de Navegacion Art. 82: Responsabilidad del transportista por perdida o dano. COGSA (Carriage of Goods by Sea Act) para rutas con USA. Plazo de prescripcion: 1 ano segun Convenio de La Haya.',
  ),
  _EmergType.reconocimiento: _Protocol(
    type: _EmergType.reconocimiento,
    nombre: 'Reconocimiento Aduanero (Semaforo Rojo)',
    tiempoCritico: '2-8 horas tipicamente. Estar DISPONIBLE y comunicado.',
    baseLegal: 'Art. 43-46 Ley Aduanera / Art. 3 RGCE',
    pasos: [
      'NUNCA abandonar el area de reconocimiento. Estar disponible por telefono en todo momento.',
      'El reconocedor tiene facultad de revisar fisicamente Y documentalmente (Art. 43 LA).',
      'Proporcionar TODA la documentacion requerida de inmediato: pedimento, factura, BL, COVE, catalogo.',
      'Si hay discrepancia de valor: presentar documentacion soporte (orden de compra, estado de cuenta, precio de referencia).',
      'Si hay discrepancia de clasificacion: presentar ficha tecnica, catalogo del fabricante, analisis quimico si aplica.',
      'NO DISCUTIR con el personal de aduana. Documentar cualquier irregularidad del reconocimiento.',
      'Si se determina irregularidad: solicitar ACTA CIRCUNSTANCIADA inmediatamente (Art. 150 LA).',
      'Contactar al importador para posibles aclaraciones tecnicas sobre la mercancia.',
    ],
    documentos: [
      'Pedimento impreso con acuse',
      'Factura comercial',
      'BL / Guia aerea',
      'COVE impreso',
      'Certificado de origen (si aplica)',
      'Catalogo del fabricante / Ficha tecnica',
      'Analisis quimico si la fraccion lo requiere',
      'NOM certificados si aplica',
    ],
    fundamento:
        'Art. 43 LA: El reconocimiento aduanero es la verificacion de la veracidad de lo declarado. Art. 44 LA: La autoridad puede tomar muestras. Art. 46 LA: Resultado del reconocimiento.',
  ),
  _EmergType.multaImpuesta: _Protocol(
    type: _EmergType.multaImpuesta,
    nombre: 'Multa Impuesta por el SAT',
    tiempoCritico: '30 dias habiles: pagar con descuento del 20% o recursar',
    baseLegal: 'Art. 70-91 CFF / Art. 178-199 Ley Aduanera',
    pasos: [
      'Analizar la RESOLUCION de la multa: fundamento legal, articulo infringido, calculo del monto.',
      'Verificar si la multa es REDUCIBLE: pago voluntario en 30 dias = 20% de descuento (Art. 70 CFF).',
      'Evaluar si procede impugnarla: causa legal invalida, incorrecto calculo, prescripcion del credito.',
      'Si se impugna: Recurso de Revocacion en 30 dias habiles (Art. 121 CFF) ante la autoridad que la emitio.',
      'Alternativa: Juicio Contencioso Administrativo ante el TFJA en 30 dias habiles (Art. 13 LFPCA).',
      'Documentar EVIDENCIA de haber actuado de buena fe (atenuante Art. 75 CFF).',
      'Si el monto es menor y sin riesgo de recurrencia: pagar con el 20% de descuento para cerrar el asunto.',
      'Evitar acumular multas: el SAT aplica recargos del 1.47% mensual (Art. 21 CFF).',
    ],
    documentos: [
      'Resolucion de multa original',
      'Comprobante de pago si se decide pagar',
      'Escrito de Recurso de Revocacion si se impugna',
      'Pruebas de buena fe (comunicaciones, documentacion)',
      'Poder notarial del representante legal',
    ],
    fundamento:
        'Art. 70 CFF: Reduccion del 20% si se paga en 30 dias. Art. 75 CFF: Atenuantes (primera infraccion, correccion voluntaria). Art. 121 CFF: Recurso de Revocacion. Art. 21 CFF: Recargos por mora.',
  ),
  _EmergType.embargoPrecautorio: _Protocol(
    type: _EmergType.embargoPrecautorio,
    nombre: 'Embargo Precautorio',
    tiempoCritico: '10 dias habiles: presentar prueba de legal estancia',
    baseLegal: 'Art. 151 Ley Aduanera',
    pasos: [
      'LEER el acta de embargo completa. Identificar causal exacta (Art. 151 LA fraccion aplicable).',
      'Causales frecuentes: mercancia no declarada, exceso de valor, documentacion falsa, cuota compensatoria.',
      'Presentar PRUEBA DE LEGAL ESTANCIA dentro de 10 dias habiles (Art. 153 LA).',
      'Si no se acredita: el SAT procede a la determinacion del credito fiscal.',
      'Garantizar el credito fiscal si se quiere liberar la mercancia (Art. 155 LA): fianza, efectivo o carta de credito.',
      'Contratar abogado especialista en aduanas INMEDIATAMENTE.',
      'No mover ni disponer de la mercancia embargada bajo ninguna circunstancia.',
    ],
    documentos: [
      'Acta de embargo precautorio completa',
      'Pedimento y documentos originales de la operacion',
      'Documentos que acrediten legal estancia',
      'Garantia (fianza o deposito) si se requiere',
      'Poder notarial del abogado',
    ],
    fundamento:
        'Art. 151 LA: Causales de embargo precautorio. Art. 153 LA: 10 dias para acreditar legal estancia. Art. 155 LA: Para liberar mercancia: garantizar el credito fiscal.',
  ),
  _EmergType.contenedorExtraviado: _Protocol(
    type: _EmergType.contenedorExtraviado,
    nombre: 'Contenedor Extraviado',
    tiempoCritico: '24 horas: contactar naviera y rastrear inmediatamente',
    baseLegal: 'Art. 82 Ley de Navegacion / HM Rules',
    pasos: [
      'Verificar con la naviera el tracking del contenedor (numero de contenedor + BL).',
      'Verificar en el sistema del puerto de destino si el contenedor ya descargo.',
      'Si no hay rastro: escalar con el agente de la naviera a nivel gerencial.',
      'Solicitar CARGO TRACER a la naviera (proceso formal de localizacion).',
      'Notificar al seguro de carga inmediatamente.',
      'Verificar si fue transbordado en un puerto equivocado.',
      'Si se confirma perdida total: iniciar proceso de reclamacion. Plazo: 1 ano segun BL.',
    ],
    documentos: [
      'BL original con numero de contenedor',
      'Poliza de seguro de carga',
      'Factura comercial',
      'Comunicado formal a naviera',
    ],
    fundamento:
        'Convenio de Hamburgo / Reglas de Rotterdam: Responsabilidad del naviero por perdida. Plazo de prescripcion: 2 anos. Responsabilidad limitada: DEG 835 por bulto o 2.5 DEG por kg.',
  ),
  _EmergType.errorPedimento: _Protocol(
    type: _EmergType.errorPedimento,
    nombre: 'Error en Pedimento (ya validado)',
    tiempoCritico: '3 dias habiles: presentar pedimento de rectificacion',
    baseLegal: 'Art. 89 Ley Aduanera / RGCE 4.7.1',
    pasos: [
      'Identificar el CAMPO INCORRECTO: fraccion, valor, cantidad, datos del importador, etc.',
      'Verificar si el campo es RECTIFICABLE (Art. 89 LA - campos que NO se pueden rectificar: regimen, aduana, fecha).',
      'Si es rectificable: elaborar PEDIMENTO DE RECTIFICACION (modality R) dentro de 3 dias habiles para campos criticos.',
      'La rectificacion NO requiere nuevo reconocimiento si no cambia el valor declarado significativamente.',
      'Si hay diferencia de contribuciones: pagar la diferencia + recargos en el mismo pedimento de rectificacion.',
      'Si el error es de clasificacion arancelaria con diferencia de arancel: notificar al importador urgentemente.',
      'Documentar el error y la correccion en el expediente del despacho.',
    ],
    documentos: [
      'Pedimento original',
      'Pedimento de rectificacion (modalidad R)',
      'Documentos soporte que acrediten el dato correcto',
      'Pago de diferencias de contribuciones si aplica',
    ],
    fundamento:
        'Art. 89 LA: Los campos del pedimento que pueden modificarse mediante pedimento de rectificacion. RGCE 4.7.1: Procedimiento de rectificacion y plazos.',
  ),
};

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class RescateEnterpriseScreen extends StatefulWidget {
  const RescateEnterpriseScreen({super.key});
  @override
  State<RescateEnterpriseScreen> createState() =>
      _RescateEnterpriseScreenState();
}

class _RescateEnterpriseScreenState extends State<RescateEnterpriseScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  _EmergType? _emergSel;
  Timer? _pulseTimer;
  bool _pulse = true;
  final List<_Emergencia> _emergencias = [];
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 800),
        (_) => setState(() => _pulse = !_pulse));
    _ticker =
        Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    // Pre-load 1 sample emergency
    _emergencias.add(_Emergencia(
      type: _EmergType.reconocimiento,
      inicio: DateTime.now().subtract(const Duration(hours: 2)),
    ));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _pulseTimer?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        body: Column(children: [
          _buildHeader(),
          Expanded(
              child: TabBarView(
                  controller: _tabCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                _tabProtocolo(),
                _tabMisEmergencias(),
              ])),
        ]),
      );

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 20, 0),
        decoration: const BoxDecoration(
            color: _bg, border: Border(bottom: BorderSide(color: _bord))),
        child: Column(children: [
          Row(children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _bord)),
                  child: const Icon(Icons.arrow_back, color: _ambar, size: 24)),
            ),
            const SizedBox(width: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _pulse
                    ? _rojo.withValues(alpha: 0.15)
                    : _rojo.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _rojo.withValues(alpha: _pulse ? 0.6 : 0.3)),
              ),
              child: const Icon(Icons.emergency, color: _rojo, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Rescate Enterprise',
                      style: TextStyle(
                          color: _texto,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text('Centro de Crisis Aduanero',
                      style: TextStyle(color: _sec, fontSize: 14)),
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: _rojo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _rojo.withValues(alpha: 0.3))),
              child: Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: _pulse ? _rojo : _rojo.withValues(alpha: 0.4),
                        shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(
                    '${_emergencias.where((e) => e.estado == 'Activa').length} activa(s)',
                    style: const TextStyle(
                        color: _rojo,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          TabBar(
              controller: _tabCtrl,
              indicatorColor: _rojo,
              labelColor: _rojo,
              unselectedLabelColor: _sec,
              labelStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(
                    icon: Icon(Icons.shield_outlined, size: 18),
                    text: 'Protocolo de Emergencia'),
                Tab(
                    icon: Icon(Icons.list_alt, size: 18),
                    text: 'Mis Emergencias'),
              ]),
        ]),
      );

  // ── Tab 1 — Protocolo ─────────────────────────────────────────────────────
  Widget _tabProtocolo() => Column(children: [
        // Grid de tipos de emergencia
        Container(
          padding: const EdgeInsets.all(20),
          color: _card,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Selecciona el tipo de emergencia:',
                style: TextStyle(
                    color: _texto, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _EmergCard(
                    type: _EmergType.cargaRetenida,
                    icon: Icons.block,
                    label: 'Carga\nRetenida',
                    c: _rojo,
                    isSelected: _emergSel == _EmergType.cargaRetenida,
                    onTap: () =>
                        setState(() => _emergSel = _EmergType.cargaRetenida)),
                _EmergCard(
                    type: _EmergType.pedimentoRechazado,
                    icon: Icons.cancel_outlined,
                    label: 'Pedimento\nRechazado',
                    c: _naran,
                    isSelected: _emergSel == _EmergType.pedimentoRechazado,
                    onTap: () => setState(
                        () => _emergSel = _EmergType.pedimentoRechazado)),
                _EmergCard(
                    type: _EmergType.mercanciaExtraviada,
                    icon: Icons.search_off,
                    label: 'Mercancía\nExtraviada',
                    c: _rojo,
                    isSelected: _emergSel == _EmergType.mercanciaExtraviada,
                    onTap: () => setState(
                        () => _emergSel = _EmergType.mercanciaExtraviada)),
                _EmergCard(
                    type: _EmergType.reconocimiento,
                    icon: Icons.manage_search,
                    label: 'Reconoci-\nmiento',
                    c: _ambar,
                    isSelected: _emergSel == _EmergType.reconocimiento,
                    onTap: () =>
                        setState(() => _emergSel = _EmergType.reconocimiento)),
                _EmergCard(
                    type: _EmergType.multaImpuesta,
                    icon: Icons.gavel,
                    label: 'Multa\nImpuesta',
                    c: _naran,
                    isSelected: _emergSel == _EmergType.multaImpuesta,
                    onTap: () =>
                        setState(() => _emergSel = _EmergType.multaImpuesta)),
                _EmergCard(
                    type: _EmergType.embargoPrecautorio,
                    icon: Icons.lock_outline,
                    label: 'Embargo\nPrecautorio',
                    c: _rojo,
                    isSelected: _emergSel == _EmergType.embargoPrecautorio,
                    onTap: () => setState(
                        () => _emergSel = _EmergType.embargoPrecautorio)),
                _EmergCard(
                    type: _EmergType.contenedorExtraviado,
                    icon: Icons.view_in_ar,
                    label: 'Contenedor\nExtraviado',
                    c: _naran,
                    isSelected: _emergSel == _EmergType.contenedorExtraviado,
                    onTap: () => setState(
                        () => _emergSel = _EmergType.contenedorExtraviado)),
                _EmergCard(
                    type: _EmergType.errorPedimento,
                    icon: Icons.edit_off,
                    label: 'Error en\nPedimento',
                    c: _ambar,
                    isSelected: _emergSel == _EmergType.errorPedimento,
                    onTap: () =>
                        setState(() => _emergSel = _EmergType.errorPedimento)),
              ],
            ),
          ]),
        ),
        // Panel de protocolo
        Expanded(
            child: _emergSel == null
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.touch_app,
                            color: _sec.withValues(alpha: 0.3), size: 64),
                        const SizedBox(height: 20),
                        const Text(
                            'Selecciona una emergencia\npara ver el protocolo de acción.',
                            style: TextStyle(color: _sec, fontSize: 16),
                            textAlign: TextAlign.center),
                      ]))
                : _protocolPanel(_protocols[_emergSel]!)),
      ]);

  Widget _protocolPanel(_Protocol p) {
    final c = p.type == _EmergType.reconocimiento ||
            p.type == _EmergType.multaImpuesta ||
            p.type == _EmergType.errorPedimento
        ? _ambar
        : _rojo;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Encabezado de la emergencia
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: c.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.withValues(alpha: 0.3))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.nombre,
                style: TextStyle(
                    color: c, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.timer_outlined, color: _ambar, size: 16),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(p.tiempoCritico,
                      style: const TextStyle(
                          color: _ambar,
                          fontSize: 14,
                          fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.gavel, color: _sec, size: 16),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(p.baseLegal,
                      style: const TextStyle(color: _sec, fontSize: 14))),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        // Pasos
        _secCard('Protocolo de Acción', Icons.checklist_outlined, c, [
          for (int i = 0; i < p.pasos.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: c.withValues(alpha: 0.3))),
                  child: Center(
                      child: Text('${i + 1}',
                          style: TextStyle(
                              color: c,
                              fontSize: 14,
                              fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(p.pasos[i],
                        style: const TextStyle(
                            color: _texto, fontSize: 14, height: 1.5))),
              ]),
            ),
        ]),
        const SizedBox(height: 16),
        // Documentos
        _secCard('Documentos Necesarios', Icons.folder_outlined, _ambar, [
          for (final d in p.documentos)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                const Icon(Icons.description_outlined, color: _ambar, size: 16),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(d,
                        style: const TextStyle(color: _texto, fontSize: 14))),
              ]),
            ),
        ]),
        const SizedBox(height: 16),
        // Fundamento
        _secCard('Fundamento Legal', Icons.balance_outlined, _teal, [
          Text(p.fundamento,
              style: const TextStyle(color: _texto, fontSize: 14, height: 1.5)),
        ]),
        const SizedBox(height: 24),
        // Accion
        SizedBox(
            width: double.infinity,
            child: _HoverButton(
              onPressed: () {
                setState(() => _emergencias
                    .add(_Emergencia(type: p.type, inicio: DateTime.now())));
                _tabCtrl.animateTo(1);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'Emergencia "${p.nombre}" guardada y en seguimiento.',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: _rojo,
                  behavior: SnackBarBehavior.floating,
                ));
              },
              label: 'Activar Seguimiento de Esta Emergencia',
            )),
      ]),
    );
  }

  Widget _secCard(
          String titulo, IconData icon, Color c, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bord)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: c, size: 18),
            const SizedBox(width: 12),
            Text(titulo,
                style: TextStyle(
                    color: c, fontSize: 16, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 16),
          ...children,
        ]),
      );

  // ── Tab 2 — Mis Emergencias ───────────────────────────────────────────────
  Widget _tabMisEmergencias() => _emergencias.isEmpty
      ? Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.shield_outlined,
              color: _sec.withValues(alpha: 0.3), size: 64),
          const SizedBox(height: 20),
          const Text('Sin emergencias activas.',
              style: TextStyle(color: _sec, fontSize: 16)),
          const Text('Activa el seguimiento desde el protocolo.',
              style: TextStyle(color: _sec, fontSize: 14)),
        ]))
      : ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: _emergencias.length,
          itemBuilder: (_, i) {
            final e = _emergencias[i];
            final p = _protocols[e.type]!;
            final elapsed = DateTime.now().difference(e.inicio);
            final h = elapsed.inHours;
            final m = elapsed.inMinutes % 60;
            final s = elapsed.inSeconds % 60;
            final stateColor = e.estado == 'Activa'
                ? _rojo
                : e.estado == 'En Proceso'
                    ? _ambar
                    : _verde;
            return _EmergenciaCard(
                e: e,
                p: p,
                h: h,
                m: m,
                s: s,
                stateColor: stateColor,
                onStateChanged: (s) => setState(() => e.estado = s));
          },
        );
}

class _EmergCard extends StatefulWidget {
  final _EmergType type;
  final IconData icon;
  final String label;
  final Color c;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmergCard(
      {required this.type,
      required this.icon,
      required this.label,
      required this.c,
      required this.isSelected,
      required this.onTap});

  @override
  State<_EmergCard> createState() => _EmergCardState();
}

class _EmergCardState extends State<_EmergCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isSelected ? widget.c.withValues(alpha: 0.1) : _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: widget.isSelected
                    ? widget.c
                    : (_isHovering ? widget.c.withValues(alpha: 0.5) : _bord)),
            boxShadow: widget.isSelected || _isHovering
                ? [
                    BoxShadow(
                        color: widget.c.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(widget.icon, color: widget.c, size: 24),
            const SizedBox(height: 8),
            Text(widget.label,
                style: TextStyle(
                    color: widget.isSelected ? widget.c : _sec,
                    fontSize: 12,
                    fontWeight: widget.isSelected
                        ? FontWeight.bold
                        : FontWeight.normal),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  const _HoverButton({required this.onPressed, required this.label});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                      color: _rojo.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: const Icon(Icons.add_alert, color: _bg, size: 18),
          label: Text(widget.label,
              style: const TextStyle(
                  color: _bg, fontWeight: FontWeight.bold, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _rojo,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class _EmergenciaCard extends StatefulWidget {
  final _Emergencia e;
  final _Protocol p;
  final int h, m, s;
  final Color stateColor;
  final void Function(String) onStateChanged;

  const _EmergenciaCard(
      {required this.e,
      required this.p,
      required this.h,
      required this.m,
      required this.s,
      required this.stateColor,
      required this.onStateChanged});

  @override
  State<_EmergenciaCard> createState() => _EmergenciaCardState();
}

class _EmergenciaCardState extends State<_EmergenciaCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  widget.stateColor.withValues(alpha: _isHovering ? 0.6 : 0.3)),
          boxShadow: [
            BoxShadow(
                color: widget.stateColor.withValues(alpha: 0.1),
                blurRadius: _isHovering ? 12 : 8)
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: widget.stateColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: widget.stateColor.withValues(alpha: 0.3))),
                child: Text(widget.e.estado,
                    style: TextStyle(
                        color: widget.stateColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
                child: Text(widget.p.nombre,
                    style: const TextStyle(
                        color: _texto,
                        fontSize: 16,
                        fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.timer, color: _sec, size: 16),
            const SizedBox(width: 8),
            Text(
                'Tiempo transcurrido: ${widget.h.toString().padLeft(2, '0')}:${widget.m.toString().padLeft(2, '0')}:${widget.s.toString().padLeft(2, '0')}',
                style: TextStyle(
                    color: widget.e.estado == 'Activa' ? _rojo : _sec,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.info_outline, color: _sec, size: 16),
            const SizedBox(width: 8),
            Text(widget.p.tiempoCritico,
                style: const TextStyle(color: _sec, fontSize: 13)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            for (final estado in ['Activa', 'En Proceso', 'Resuelta'])
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => widget.onStateChanged(estado),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.e.estado == estado
                            ? (estado == 'Activa'
                                    ? _rojo
                                    : estado == 'En Proceso'
                                        ? _ambar
                                        : _verde)
                                .withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: widget.e.estado == estado
                                ? (estado == 'Activa'
                                    ? _rojo
                                    : estado == 'En Proceso'
                                        ? _ambar
                                        : _verde)
                                : _bord),
                      ),
                      child: Text(estado,
                          style: TextStyle(
                              color: widget.e.estado == estado
                                  ? (estado == 'Activa'
                                      ? _rojo
                                      : estado == 'En Proceso'
                                          ? _ambar
                                          : _verde)
                                  : _sec,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
          ]),
        ]),
      ),
    );
  }
}
