import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aduana_801/features/widgets/beginner_tip_widget.dart';
import 'package:aduana_801/features/home/widgets/breadcrumb_nav.dart';
import '../../core/utils/share_utils.dart';
import '../../core/services/pdf_generator_service.dart';

class LandedCostScreen extends StatefulWidget {
  const LandedCostScreen({super.key});

  @override
  State<LandedCostScreen> createState() => _LandedCostScreenState();
}

class _LandedCostScreenState extends State<LandedCostScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fobCtrl = TextEditingController();
  final _fleteCtrl = TextEditingController();
  final _seguroCtrl = TextEditingController();

  // Impuestos %
  final _arancelCtrl = TextEditingController(text: '0');
  final _dtaCtrl = TextEditingController(text: '0.8');
  final _ivaCtrl = TextEditingController(text: '16');

  // Gastos extra
  final _agenteCtrl = TextEditingController(text: '5000');
  final _almacenajeCtrl = TextEditingController(text: '2500');
  final _maniobrasCtrl = TextEditingController(text: '4500');

  final _prvCtrl = TextEditingController(text: '0');
  bool _prvAplica = false;

  final _fraccionCtrl = TextEditingController();
  final _paisOrigenCtrl = TextEditingController();
  bool _tieneCertOrigen = false;
  bool _cuotaAplica = false;
  final _cuotaPctCtrl = TextEditingController(text: '0');

  Map<String, dynamic>? _resultado;

  @override
  void dispose() {
    _fobCtrl.dispose();
    _fleteCtrl.dispose();
    _seguroCtrl.dispose();
    _arancelCtrl.dispose();
    _dtaCtrl.dispose();
    _ivaCtrl.dispose();
    _agenteCtrl.dispose();
    _almacenajeCtrl.dispose();
    _maniobrasCtrl.dispose();
    _prvCtrl.dispose();
    _fraccionCtrl.dispose();
    _paisOrigenCtrl.dispose();
    _cuotaPctCtrl.dispose();
    super.dispose();
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;

    final fob = double.tryParse(_fobCtrl.text.replaceAll(',', '')) ?? 0.0;
    final flete = double.tryParse(_fleteCtrl.text.replaceAll(',', '')) ?? 0.0;
    final seguro = double.tryParse(_seguroCtrl.text.replaceAll(',', '')) ?? 0.0;
    final arancelPct =
        double.tryParse(_arancelCtrl.text.replaceAll(',', '')) ?? 0.0;
    final dtaPct = double.tryParse(_dtaCtrl.text.replaceAll(',', '')) ?? 0.0;
    final ivaPct = double.tryParse(_ivaCtrl.text.replaceAll(',', '')) ?? 0.0;

    final agente = double.tryParse(_agenteCtrl.text.replaceAll(',', '')) ?? 0.0;
    final almacenaje =
        double.tryParse(_almacenajeCtrl.text.replaceAll(',', '')) ?? 0.0;
    final maniobras =
        double.tryParse(_maniobrasCtrl.text.replaceAll(',', '')) ?? 0.0;

    final baseGravable = fob + flete + seguro;

    final igiNormal = baseGravable * (arancelPct / 100);
    final igiPreferencial = _tieneCertOrigen ? 0.0 : igiNormal;
    final cuota = _cuotaAplica
        ? baseGravable * (double.tryParse(_cuotaPctCtrl.text) ?? 0) / 100
        : 0.0;
    final ahorro = igiNormal - igiPreferencial;

    final igi = igiPreferencial;
    final dta = baseGravable * (dtaPct / 100);
    final iva = (baseGravable + igi + dta) * (ivaPct / 100);

    final impuestos = igi + dta + iva + cuota;
    final prv = _prvAplica
        ? (double.tryParse(_prvCtrl.text.replaceAll(',', '')) ?? 0.0)
        : 0.0;
    final extra = agente + almacenaje + maniobras + prv;
    final totalLandedCost = baseGravable + impuestos + extra;

    setState(() {
      _resultado = {
        'fob': fob,
        'flete': flete,
        'seguro': seguro,
        'agente': agente,
        'almacenaje': almacenaje,
        'maniobras': maniobras,
        'baseGravable': baseGravable,
        'igi': igi,
        'dta': dta,
        'iva': iva,
        'impuestos': impuestos,
        'prv': prv,
        'total': totalLandedCost,
        'igiNormal': igiNormal,
        'igiPreferencial': igiPreferencial,
        'cuota': cuota,
        'ahorro': ahorro,
        'tieneCO': _tieneCertOrigen,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Calculadora de Landed Cost',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: BreadcrumbNav(items: [
          BreadcrumbItem(label: 'Inicio', route: '/'),
          BreadcrumbItem(label: 'Finanzas'),
          BreadcrumbItem(label: 'Landed Cost'),
        ]),
      ),
      body: Row(
        children: [
          // Lado Izquierdo: Formulario
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Valor en Aduana',
                        style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: Row(children: [
                          Expanded(
                              child: _Input(
                                  label: 'FOB (Mercancía)',
                                  ctrl: _fobCtrl,
                                  req: true)),
                          const BeginnerTipWidget(
                              term: 'FOB',
                              explanation:
                                  'Free On Board (Libre a Bordo): El valor de la mercancía puesto en el puerto de origen, sin incluir fletes ni seguros internacionales.')
                        ])),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _Input(label: 'Flete', ctrl: _fleteCtrl)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _Input(label: 'Seguro', ctrl: _seguroCtrl)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('2. Impuestos y Contribuciones (%)',
                        style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: Row(children: [
                          Expanded(
                              child:
                                  _Input(label: 'IGI (%)', ctrl: _arancelCtrl)),
                          const BeginnerTipWidget(
                              term: 'IGI',
                              explanation:
                                  'Impuesto General de Importación: El arancel principal aplicable a las mercancías que entran al país.')
                        ])),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Row(children: [
                          Expanded(
                              child: _Input(label: 'DTA (%)', ctrl: _dtaCtrl)),
                          const BeginnerTipWidget(
                              term: 'DTA',
                              explanation:
                                  'Derecho de Trámite Aduanero: Una cuota que se paga por el uso de las instalaciones y los servicios aduanales.')
                        ])),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _Input(label: 'IVA (%)', ctrl: _ivaCtrl)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Aplica Previo de Revisión (PRV)',
                          style: TextStyle(color: Colors.white)),
                      value: _prvAplica,
                      onChanged: (val) => setState(() => _prvAplica = val),
                      activeTrackColor: AppColors.gold,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_prvAplica)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: _Input(
                            label: 'Monto PRV (MXN)',
                            ctrl: _prvCtrl,
                            req: true),
                      ),
                    const Text(
                      'El PRV es obligatorio para mercancía sujeta a NOM (electrónicos, alimentos, químicos, textil).',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 32),
                    const Text('3. Clasificación y Origen',
                        style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _Input(
                                label: 'Fracción Arancelaria (TIGIE)',
                                ctrl: _fraccionCtrl)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _Input(
                                label: 'País de Origen',
                                ctrl: _paisOrigenCtrl)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text(
                          '✅ Tiene Certificado de Origen (TMEC/USMCA/TIPAN)',
                          style: TextStyle(color: Colors.white)),
                      value: _tieneCertOrigen,
                      onChanged: (val) =>
                          setState(() => _tieneCertOrigen = val),
                      activeTrackColor: AppColors.gold,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_tieneCertOrigen)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gold)),
                        child: const Text(
                            'Con C.O. válido, el IGI puede ser 0%. El cálculo mostrará ambos escenarios.',
                            style: TextStyle(color: AppColors.gold)),
                      ),
                    SwitchListTile(
                      title: const Text(
                          '⚠️ Aplica Cuota Compensatoria (Anti-dumping)',
                          style: TextStyle(color: Colors.white)),
                      value: _cuotaAplica,
                      onChanged: (val) => setState(() => _cuotaAplica = val),
                      activeTrackColor: AppColors.red,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_cuotaAplica)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: _Input(
                            label: 'Cuota Compensatoria (%)',
                            ctrl: _cuotaPctCtrl),
                      ),
                    if (_cuotaAplica)
                      const Text(
                          'Consulta las cuotas vigentes en la DOF o en la pantalla de Cuotas Compensatorias',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 32),
                    const Text('4. Gastos Logísticos y Despacho',
                        style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _Input(
                                label: 'Agente Aduanal', ctrl: _agenteCtrl)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _Input(
                                label: 'Almacenaje', ctrl: _almacenajeCtrl)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _Input(
                                label: 'Maniobras / DUM',
                                ctrl: _maniobrasCtrl)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calcular,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text('CALCULAR COSTO TOTAL',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lado Derecho: Resultados
          Container(width: 1, color: AppColors.border),
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFF162032),
              padding: const EdgeInsets.all(24),
              child: _resultado == null
                  ? const Center(
                      child: Text(
                          'Completa el formulario para ver el resultado',
                          style: TextStyle(color: AppColors.sub)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Resumen Financiero',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: () async {
                                final bytes = await PdfGeneratorService.instance
                                    .generateLandedCostReport(
                                  producto: 'Producto (Landed Cost)',
                                  valorFactura:
                                      (_resultado!['fob']! as num).toDouble(),
                                  flete:
                                      (_resultado!['flete']! as num).toDouble(),
                                  seguro: (_resultado!['seguro']! as num)
                                      .toDouble(),
                                  valorAduana:
                                      (_resultado!['baseGravable']! as num)
                                          .toDouble(),
                                  arancel:
                                      (_resultado!['igi']! as num).toDouble(),
                                  iva: (_resultado!['iva']! as num).toDouble(),
                                  ieps: 0,
                                  dta: (_resultado!['dta']! as num).toDouble(),
                                  totalImpuestos:
                                      (_resultado!['impuestos']! as num)
                                          .toDouble(),
                                  costoTotal:
                                      (_resultado!['total']! as num).toDouble(),
                                  tipoCambio:
                                      20.0, // Replace with actual exchange rate if available
                                );
                                await PdfGeneratorService.instance
                                    .downloadPdf(bytes, 'LandedCost.pdf');
                              },
                              icon: const Icon(Icons.picture_as_pdf,
                                  color: AppColors.red),
                              tooltip: 'Exportar PDF',
                            ),
                            IconButton(
                              icon: const Icon(Icons.share,
                                  color: Color(0xFFF59E0B)),
                              tooltip: 'Compartir por WhatsApp',
                              onPressed: () {
                                ShareUtils.shareViaWhatsApp(
                                    '💰 Cálculo de Landed Cost\n'
                                    'Analizado con Aduanas 801 🛡️\n'
                                    'https://aduana-801.web.app');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _ResRow('Base Gravable (Valor en Aduana)',
                            fmt.format(_resultado!['baseGravable'])),
                        const Divider(color: AppColors.border, height: 24),
                        if (_resultado!['tieneCO'] == true) ...[
                          const Text('--- SIN preferencia arancelaria ---',
                              style: TextStyle(
                                  color: AppColors.sub, fontSize: 12)),
                          _ResRow('IGI (Arancel General)',
                              fmt.format(_resultado!['igiNormal'])),
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              Text('--- CON Certificado de Origen TMEC ---',
                                  style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.verified,
                                  color: AppColors.gold, size: 14),
                            ],
                          ),
                          _ResRow('IGI Preferencial',
                              fmt.format(_resultado!['igiPreferencial']),
                              isBold: true, valueColor: AppColors.green),
                          _ResRow(
                              'Ahorro TMEC', fmt.format(_resultado!['ahorro']),
                              isBold: true, valueColor: AppColors.green),
                        ] else ...[
                          _ResRow('IGI', fmt.format(_resultado!['igi'])),
                        ],
                        if (((_resultado!['cuota'] as num?) ?? 0) > 0)
                          _ResRow('Cuota Compensatoria',
                              fmt.format(_resultado!['cuota']),
                              valueColor: AppColors.red),
                        _ResRow('DTA', fmt.format(_resultado!['dta'])),
                        _ResRow('IVA', fmt.format(_resultado!['iva'])),
                        if (((_resultado!['prv'] as num?) ?? 0) > 0)
                          _ResRow('PRV', fmt.format(_resultado!['prv'])),
                        _ResRow('Total Impuestos',
                            fmt.format(_resultado!['impuestos']),
                            isBold: true),
                        const Divider(color: AppColors.border, height: 24),
                        _ResRow('Honorarios Agente',
                            fmt.format(_resultado!['agente'])),
                        _ResRow('Almacenaje',
                            fmt.format(_resultado!['almacenaje'])),
                        _ResRow('Maniobras / DUM',
                            fmt.format(_resultado!['maniobras'])),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.blue),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('TOTAL LANDED COST',
                                  style: TextStyle(
                                      color: AppColors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(fmt.format(_resultado!['total']),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        if (_resultado!['tieneCO'] == true) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.gold)),
                            child: Row(children: [
                              const Icon(Icons.savings_outlined,
                                  color: AppColors.gold),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      'Ahorro con C.O. TMEC/USMCA: ${fmt.format(_resultado!["ahorro"])}',
                                      style: const TextStyle(
                                          color: AppColors.gold,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                            ]),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool req;

  const _Input({required this.label, required this.ctrl, this.req = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.sub, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
      validator: req ? (v) => v!.isEmpty ? 'Requerido' : null : null,
    );
  }
}

class _ResRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _ResRow(this.label, this.value, {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: isBold ? Colors.white : AppColors.sub,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
