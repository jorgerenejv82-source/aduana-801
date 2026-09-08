import 'package:flutter/material.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/share_utils.dart';

class UtilidadNetaScreen extends StatefulWidget {
  const UtilidadNetaScreen({super.key});

  @override
  State<UtilidadNetaScreen> createState() => _UtilidadNetaScreenState();
}

class _UtilidadNetaScreenState extends State<UtilidadNetaScreen> {
  final _formKey = GlobalKey<FormState>();

  final fobCtrl = TextEditingController();
  final tcCtrl = TextEditingController(text: '17.15');
  final igiCtrl = TextEditingController(text: '5.0');
  final fleteCtrl = TextEditingController(text: '0');
  final agenteCtrl = TextEditingController(text: '0');
  final almacenajeCtrl = TextEditingController(text: '0');
  final unidadesCtrl = TextEditingController();

  @override
  void dispose() {
    fobCtrl.dispose();
    tcCtrl.dispose();
    igiCtrl.dispose();
    fleteCtrl.dispose();
    agenteCtrl.dispose();
    almacenajeCtrl.dispose();
    unidadesCtrl.dispose();
    precioVentaCtrl.dispose();
    comisionCtrl.dispose();
    super.dispose();
  }

  bool acreditaIva = false;

  final precioVentaCtrl = TextEditingController();
  final comisionCtrl = TextEditingController(text: '0');

  Map<String, double>? _resultado;

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;

    final unidades = int.tryParse(unidadesCtrl.text) ?? 0;
    if (unidades == 0) return;

    final fob = double.parse(fobCtrl.text);
    final tc = double.parse(tcCtrl.text);
    final igiPct = double.parse(igiCtrl.text);
    final flete = double.parse(fleteCtrl.text);
    final agente = double.parse(agenteCtrl.text);
    final almacenaje = double.parse(almacenajeCtrl.text);
    final precioVenta = double.parse(precioVentaCtrl.text);
    final comisionPct = double.parse(comisionCtrl.text);

    final valorAduana = (fob * tc) + flete;
    final igi = valorAduana * (igiPct / 100);
    final iva = (valorAduana + igi) * 0.16;
    final ivaEfectivo = acreditaIva ? 0.0 : iva;
    final totalImportacion =
        valorAduana + igi + ivaEfectivo + agente + almacenaje;
    final landedCostUnit = totalImportacion / unidades;

    final ingresosBrutos = precioVenta * unidades;
    final comision = ingresosBrutos * (comisionPct / 100);
    final ingresosNetos = ingresosBrutos - comision;

    final utilidadBruta = ingresosNetos - totalImportacion;
    final utilidadUnit = utilidadBruta / unidades;
    final margen = (utilidadBruta / ingresosNetos) * 100;

    setState(() {
      _resultado = {
        'landedCostUnit': landedCostUnit,
        'totalImportacion': totalImportacion,
        'ingresosBrutos': ingresosBrutos,
        'comision': comision,
        'utilidadBruta': utilidadBruta,
        'utilidadUnit': utilidadUnit,
        'margen': margen,
        'ivaNote': acreditaIva ? iva : 0.0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('💰 Calculadora de Utilidad Neta'),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Descubre si tu importación es rentable ANTES de invertir',
                style: TextStyle(color: AppColors.sub, fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text('Costo de Importación',
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: fobCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                    labelText: 'Precio FOB del producto (USD)',
                    labelStyle: TextStyle(color: AppColors.sub)),
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                    ? 'Debe ser > 0'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: tcCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                    labelText: 'Tipo de Cambio MXN/USD',
                    labelStyle: TextStyle(color: AppColors.sub)),
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                    ? 'Debe ser > 0'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: igiCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                    labelText: 'Arancel IGI (%)',
                    labelStyle: TextStyle(color: AppColors.sub)),
                validator: (v) => (double.tryParse(v ?? '') ?? -1) < 0
                    ? 'Debe ser >= 0'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: fleteCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                    labelText: 'Flete + Seguro (MXN)',
                    labelStyle: TextStyle(color: AppColors.sub)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: agenteCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                    labelText: 'Honorarios Agente Aduanal (MXN)',
                    labelStyle: TextStyle(color: AppColors.sub)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: almacenajeCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                    labelText: 'Almacenaje + Maniobras (MXN)',
                    labelStyle: TextStyle(color: AppColors.sub)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: unidadesCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                    labelText: 'Número de unidades importadas',
                    labelStyle: TextStyle(color: AppColors.sub)),
                validator: (v) =>
                    (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Debe ser > 0' : null,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('¿Eres empresa y acreditas IVA?',
                    style: TextStyle(color: AppColors.text)),
                value: acreditaIva,
                activeThumbColor: AppColors.gold,
                onChanged: (v) => setState(() => acreditaIva = v),
              ),
              const SizedBox(height: 24),
              const Text('Precio de Venta',
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: precioVentaCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                    labelText: 'Precio de venta por unidad (MXN)',
                    labelStyle: TextStyle(color: AppColors.sub)),
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                    ? 'Debe ser > 0'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: comisionCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                    labelText: 'Comisión de venta / marketplace (%)',
                    labelStyle: TextStyle(color: AppColors.sub)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calcular,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('📊 CALCULAR MI GANANCIA',
                    style: TextStyle(
                        color: AppColors.bg, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              if (_resultado != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                            '📦 Landed Cost por unidad: \$${_resultado!['landedCostUnit']!.toStringAsFixed(2)} MXN',
                            style: const TextStyle(color: AppColors.text)),
                        const SizedBox(height: 4),
                        Text(
                            '💰 Precio de venta: \$${precioVentaCtrl.text} MXN',
                            style: const TextStyle(color: AppColors.text)),
                        const Divider(color: AppColors.border, height: 16),
                        Text(
                            '🏷️ Comisión de venta: -\$${_resultado!['comision']!.toStringAsFixed(2)} MXN',
                            style: const TextStyle(color: AppColors.red)),
                        const Divider(color: AppColors.border, height: 16),
                        Text(
                            'UTILIDAD POR UNIDAD: \$${_resultado!['utilidadUnit']!.toStringAsFixed(2)} MXN',
                            style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            'UTILIDAD TOTAL: \$${_resultado!['utilidadBruta']!.toStringAsFixed(2)} MXN',
                            style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            'MARGEN BRUTO: ${_resultado!['margen']!.toStringAsFixed(1)}%',
                            style: const TextStyle(color: AppColors.text)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _resultado!['margen']! >= 30
                                ? AppColors.green.withValues(alpha: 0.2)
                                : _resultado!['margen']! >= 10
                                    ? AppColors.gold.withValues(alpha: 0.2)
                                    : _resultado!['margen']! >= 0
                                        ? AppColors.red.withValues(alpha: 0.2)
                                        : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _resultado!['margen']! >= 30
                                ? '🟢 Excelente (≥30%)'
                                : _resultado!['margen']! >= 10
                                    ? '🟡 Aceptable (10-29%)'
                                    : _resultado!['margen']! >= 0
                                        ? '🔴 Riesgoso (<10%)'
                                        : '⚪ No rentable (<0%)',
                            style: const TextStyle(color: AppColors.text),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_resultado != null && acreditaIva) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.blue.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'ℹ️ IVA \$${_resultado!['ivaNote']!.toStringAsFixed(2)} recuperable en tu declaración mensual',
                    style: const TextStyle(color: AppColors.blue),
                  ),
                ),
              ],
              if (_resultado != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir resultado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ShareUtils.shareViaWhatsApp(
                        '📊 Mi análisis de Landed Cost\n'
                        'Resultado calculado con Aduanas 801 🛡️\n'
                        'https://aduana-801.web.app');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
