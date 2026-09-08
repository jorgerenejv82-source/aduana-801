import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/normativa_service.dart';

class SimuladorPedimentoScreen extends StatefulWidget {
  const SimuladorPedimentoScreen({super.key});
  @override
  State<SimuladorPedimentoScreen> createState() =>
      _SimuladorPedimentoScreenState();
}

class _SimuladorPedimentoScreenState extends State<SimuladorPedimentoScreen> {
  int _step = 0; // 0=Datos, 1=Cálculo, 2=Vista Previa

  // Controllers
  final _fraccionCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _paisCtrl = TextEditingController();
  final _proveedorCtrl = TextEditingController();
  final _valorCtrl = TextEditingController(text: '0');
  final _fleteCtrl = TextEditingController(text: '0');
  final _seguroCtrl = TextEditingController(text: '0');
  final _otrosIncrCtrl = TextEditingController(text: '0');
  final _arancelCtrl = TextEditingController(text: '0');
  final _tcCtrl = TextEditingController(text: '17.15');

  String _incoterm = 'FOB';
  String _regimen = 'Definitiva';

  // Resultados calculados
  double _va = 0, _igi = 0, _iva = 0, _dta = 0, _prv = 0, _cnt = 0, _total = 0;
  String _semaforo = '';

  static const _incoterms = [
    'EXW',
    'FCA',
    'FAS',
    'FOB',
    'CFR',
    'CIF',
    'CPT',
    'CIP',
    'DAP',
    'DPU',
    'DDP'
  ];
  static const _regimenes = [
    'Definitiva',
    'Temporal IMMEX',
    'Exportación Definitiva',
    'Exportación Virtual IMMEX',
    'Tránsito'
  ];

  Future<void> _calcular() async {
    final ns = NormativaService();
    await ns.fetchLatestTipoCambio();
    if (_tcCtrl.text.isEmpty || _tcCtrl.text == '17.15') {
      _tcCtrl.text = ns.tipoCambioFix.toStringAsFixed(4);
    }

    final valor = double.tryParse(_valorCtrl.text) ?? 0;
    final flete = double.tryParse(_fleteCtrl.text) ?? 0;
    final seguro = double.tryParse(_seguroCtrl.text) ?? 0;
    final otros = double.tryParse(_otrosIncrCtrl.text) ?? 0;
    final arancel = double.tryParse(_arancelCtrl.text) ?? 0;
    final tc = double.tryParse(_tcCtrl.text) ?? 17.15;

    // Se eliminó la factorizacion ficticia por Incoterm, ahora se suman incrementables reales
    final vaUSD = valor + flete + seguro + otros;
    _va = vaUSD * tc;

    // Si régimen temporal IMMEX: IGI = 0
    final esIMMEX = _regimen.contains('IMMEX') || _regimen.contains('Temporal');
    _igi = esIMMEX ? 0 : _va * (arancel / 100);

    // DTA Dinámico + PRV + CNT
    _dta = ns.calcularDTA(_va, _regimen);
    _prv = ns.prv;
    _cnt = ns.cnt;

    _iva = (_va + _igi + _dta + _prv + _cnt) * 0.16;
    if (_regimen.contains('Exportación')) _iva = 0; // IVA 0% en exportación

    _total = _igi + _dta + _prv + _cnt + _iva;

    // Semáforo
    final fraccion = _fraccionCtrl.text;
    if (fraccion.isEmpty || valor <= 0) {
      _semaforo = 'rojo';
    } else if (valor < 100 || _regimen == 'Definitiva' && arancel == 0) {
      _semaforo = 'amarillo';
    } else {
      _semaforo = 'verde';
    }

    setState(() => _step = 1);
  }

  @override
  void dispose() {
    _fraccionCtrl.dispose();
    _descCtrl.dispose();
    _paisCtrl.dispose();
    _proveedorCtrl.dispose();
    _valorCtrl.dispose();
    _fleteCtrl.dispose();
    _seguroCtrl.dispose();
    _otrosIncrCtrl.dispose();
    _arancelCtrl.dispose();
    _tcCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          // ── Stepper lateral izquierdo ──────────────────────────────────
          Container(
            width: 52,
            color: AppColors.bg,
            child: Column(
              children: [
                const SizedBox(height: 72),
                ...List.generate(3, (i) {
                  final labels = ['Datos', 'Cálculo', 'Vista\nPrevia'];
                  final done = i < _step;
                  final active = i == _step;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (i <= _step) setState(() => _step = i);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: active
                                    ? AppColors.gold
                                    : done
                                        ? const Color(0xFF4ECCA3)
                                        : AppColors.border,
                              ),
                              child: Center(
                                child: done
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 14)
                                    : Text('${i + 1}',
                                        style: TextStyle(
                                            color: active
                                                ? Colors.black
                                                : AppColors.sub,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(labels[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: active
                                        ? AppColors.gold
                                        : const Color(0xFF6B7E99),
                                    fontSize: 9)),
                          ],
                        ),
                      ),
                      if (i < 2)
                        Container(
                            width: 2,
                            height: 30,
                            color: i < _step
                                ? const Color(0xFF4ECCA3)
                                : AppColors.border),
                    ],
                  );
                }),
              ],
            ),
          ),

          // ── Contenido principal ────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                          onPressed: () => context.go('/simulador_pedimento')),
                      const Text('Simulador de Pedimento',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Expanded(
                  child: _step == 0
                      ? _buildDatos()
                      : _step == 1
                          ? _buildCalculo(fmt)
                          : _buildVistaPrevia(fmt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PASO 1: Datos ──────────────────────────────────────────────────────
  Widget _buildDatos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _field(_fraccionCtrl, 'Fracción Arancelaria', Icons.grid_on,
              hint: 'Ej: 8544420100'),
          _field(_descCtrl, 'Descripción', Icons.description_outlined),
          _field(_paisCtrl, 'País de Origen', Icons.flag_outlined,
              hint: 'Ej: USA, CHN, DEU'),
          _field(_proveedorCtrl, 'Proveedor', Icons.business_outlined),
          _field(_valorCtrl, 'Valor Factura (USD)', Icons.attach_money,
              isNum: true),
          Row(children: [
            Expanded(
                child: _field(_fleteCtrl, 'Flete (USD)', Icons.directions_boat,
                    isNum: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _field(_seguroCtrl, 'Seguro (USD)', Icons.security,
                    isNum: true)),
          ]),
          Row(children: [
            Expanded(
                child: _field(_otrosIncrCtrl, 'Otros Incr (USD)', Icons.add_box,
                    isNum: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _field(_arancelCtrl, 'Arancel %', Icons.percent,
                    isNum: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _field(
                    _tcCtrl, 'Tipo de Cambio', Icons.currency_exchange,
                    isNum: true)),
          ]),
          Row(children: [
            Expanded(
                child: _dropdown('Incoterm', _incoterm, _incoterms,
                    (v) => setState(() => _incoterm = v!))),
            const SizedBox(width: 12),
            Expanded(
                child: _dropdown('Régimen', _regimen, _regimenes,
                    (v) => setState(() => _regimen = v!))),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _calcular,
              icon: const Icon(Icons.calculate, size: 18),
              label: const Text('Calcular contribuciones',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.bg,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          ),
        ],
      ),
    );
  }

  // ── PASO 2: Cálculo ────────────────────────────────────────────────────
  Widget _buildCalculo(NumberFormat fmt) {
    final Color semaforoColor = _semaforo == 'verde'
        ? const Color(0xFF4ECCA3)
        : _semaforo == 'amarillo'
            ? AppColors.gold
            : AppColors.red;
    final String semaforoLabel = _semaforo == 'verde'
        ? '✅ OPERACIÓN LISTA'
        : _semaforo == 'amarillo'
            ? '⚠️ REVISAR ANTES DE TRANSMITIR'
            : '🚫 CORRECCIÓN NECESARIA';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Semáforo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: semaforoColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: semaforoColor.withAlpha(80))),
            child: Row(children: [
              Icon(Icons.circle, color: semaforoColor, size: 14),
              const SizedBox(width: 10),
              Text(semaforoLabel,
                  style: TextStyle(
                      color: semaforoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 16),

          // Tabla de contribuciones
          _calcCard('Valor en Aduana (MXN)', fmt.format(_va),
              icon: Icons.account_balance_wallet,
              color: const Color(0xFF4A9EFF)),
          const SizedBox(height: 8),
          _calcCard('IGI (Impuesto General de Importación)', fmt.format(_igi),
              sub: _regimen.contains('IMMEX')
                  ? 'EXENTO — Régimen Temporal IMMEX'
                  : '${_arancelCtrl.text}% × Valor en Aduana',
              icon: Icons.monetization_on,
              color: AppColors.gold),
          const SizedBox(height: 8),
          _calcCard('DTA (Derecho de Trámite Aduanero)', fmt.format(_dta),
              sub: 'Cálculo Dinámico UMA',
              icon: Icons.receipt_long,
              color: const Color(0xFF8B5CF6)),
          const SizedBox(height: 8),
          _calcCard('PRV + CNT', fmt.format(_prv + _cnt),
              sub: 'Prevalidación + Contraprestación',
              icon: Icons.verified,
              color: const Color(0xFFF97316)),
          const SizedBox(height: 8),
          _calcCard('IVA', fmt.format(_iva),
              sub: _regimen.contains('Exportación')
                  ? 'TASA 0% — Exportación'
                  : '16% × (VA + IGI + DTA + PRV + CNT)',
              icon: Icons.percent,
              color: const Color(0xFF4ECCA3)),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withAlpha(100))),
            child: Row(children: [
              const Text('TOTAL A PAGAR',
                  style: TextStyle(
                      color: AppColors.sub,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(fmt.format(_total),
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: OutlinedButton(
              onPressed: () => setState(() => _step = 0),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sub,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('← Volver a Datos'),
            )),
            const SizedBox(width: 12),
            Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => setState(() => _step = 2),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bg,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text('Ver Vista Previa →',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )),
          ]),
        ],
      ),
    );
  }

  // ── PASO 3: Vista Previa ───────────────────────────────────────────────
  Widget _buildVistaPrevia(NumberFormat fmt) {
    final now = DateTime.now();
    final draft = '''═══════════════════════════════════════════
BORRADOR PEDIMENTO — Aduanas 801 Enterprise
Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(now)}
═══════════════════════════════════════════
ENCABEZADO:
  Régimen:          $_regimen
  Incoterm:         $_incoterm
  Fracción LIGIE:   ${_fraccionCtrl.text.isEmpty ? '[PENDIENTE]' : _fraccionCtrl.text}
  Descripción:      ${_descCtrl.text.isEmpty ? '[PENDIENTE]' : _descCtrl.text}
  País de Origen:   ${_paisCtrl.text.isEmpty ? '[PENDIENTE]' : _paisCtrl.text}
  Proveedor:        ${_proveedorCtrl.text.isEmpty ? '[PENDIENTE]' : _proveedorCtrl.text}
  Tipo de Cambio:   \$${_tcCtrl.text} MXN/USD

VALORES:
  Valor Factura:    \$${_valorCtrl.text} USD
  Flete:            \$${_fleteCtrl.text} USD
  Seguro:           \$${_seguroCtrl.text} USD
  Valor en Aduana:  ${fmt.format(_va)} MXN

CONTRIBUCIONES:
  IGI (${_arancelCtrl.text}%):       ${fmt.format(_igi)} MXN
  DTA (0.8%):       ${fmt.format(_dta)} MXN
  IVA (16%):        ${fmt.format(_iva)} MXN
  ─────────────────────────────────────
  TOTAL:            ${fmt.format(_total)} MXN

SEMÁFORO: ${_semaforo.toUpperCase()}
═══════════════════════════════════════════''';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border)),
            child: Text(draft,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFF4ADE80),
                    fontSize: 12,
                    height: 1.5)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: draft));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Borrador copiado'),
                    backgroundColor: AppColors.card,
                    duration: Duration(seconds: 2)));
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copiar'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4A9EFF),
                  side: const BorderSide(color: Color(0xFF4A9EFF)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: ElevatedButton.icon(
              onPressed: () => context.go('/draft_pedimento'),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Abrir en Auto-Gen'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.bg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            )),
          ]),
          const SizedBox(height: 8),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 0),
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7E99),
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('← Nueva Simulación'),
              )),
        ],
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────
  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {String? hint, bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 12),
          labelStyle: const TextStyle(color: AppColors.sub, fontSize: 12),
          prefixIcon: Icon(icon, color: const Color(0xFF4A9EFF), size: 18),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gold)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items,
      void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: AppColors.card,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.sub, fontSize: 12),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        items: items
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _calcCard(String label, String valor,
      {String? sub, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: color.withAlpha(26)),
            child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(color: AppColors.sub, fontSize: 12)),
          if (sub != null)
            Text(sub,
                style: const TextStyle(color: Color(0xFF4A5568), fontSize: 11)),
        ])),
        Text(valor,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
