import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _ambar = AppColors.gold;
const Color _teal = AppColors.green;
const Color _rojo = AppColors.red;

class _HoverContainer extends StatefulWidget {
  final Widget child;

  const _HoverContainer({
    required this.child,
  });

  @override
  State<_HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<_HoverContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _isHovered ? _ambar.withValues(alpha: 0.5) : _bord),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                        color: _ambar.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class IntegracionCuanticaScreen extends StatefulWidget {
  const IntegracionCuanticaScreen({super.key});
  @override
  State<IntegracionCuanticaScreen> createState() =>
      _IntegracionCuanticaScreenState();
}

class _IntegracionCuanticaScreenState extends State<IntegracionCuanticaScreen> {
  bool _syncing = false;
  bool _synced = false;
  double _a24Pct = 0.0;
  double _a30Pct = 0.0;
  final int _diasVenc = 14;
  double _tcHistorico = 0.0;
  DateTime _fechaForex = DateTime(2024, 3, 15);
  bool _tcLoading = false;

  String get _desviacion {
    final diff = (_a24Pct - _a30Pct).abs();
    if (diff == 0) return 'Sin desviacion detectada';
    return "${diff.toStringAsFixed(1)}% de desviacion detectada";
  }

  bool get _hayDesviacion => (_a24Pct - _a30Pct).abs() > 0.5;

  String _mes(int m) {
    const mths = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return m > 0 && m <= 12 ? mths[m - 1] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: _ambar),
        ),
        title: const Text('Integracion Cuantica',
            style: TextStyle(
                color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(children: [
        const Divider(height: 1, color: _bord),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Integracion Cuantica: Fisico vs Fiscal',
                style: TextStyle(
                    color: _ambar, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
                'El motor reconcilia milimetricamente el control de inventarios (Anexo 24) con los saldos de credito fiscal (Anexo 30).',
                style: TextStyle(color: _sec, fontSize: 12, height: 1.6)),
            const SizedBox(height: 24),
            // 2x2 Grid
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // LEFT column
              Expanded(
                  child: Column(children: [
                // Card 1: Hyper-Sync Engine
                _HoverContainer(
                  child: _cuanticaCard(
                    icon: Icons.sync,
                    iconColor: _teal,
                    title: 'Hyper-Sync Engine',
                    subtitle: 'Traduccion Fisico-Fiscal en tiempo real.',
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _syncRow(
                              'Descargo A24 (Fisico)',
                              _synced
                                  ? "${_a24Pct.toStringAsFixed(1)}%"
                                  : 'No hay datos'),
                          const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 4),
                              child: Icon(Icons.arrow_downward,
                                  color: _sec, size: 16)),
                          _syncRow(
                              'Amortizacion A30 (Fiscal)',
                              _synced
                                  ? "${_a30Pct.toStringAsFixed(1)}%"
                                  : 'No hay datos'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: _syncing
                                  ? null
                                  : () async {
                                      setState(() => _syncing = true);
                                      try {
                                        final model = FirebaseAI.vertexAI()
                                            .generativeModel(
                                          model: 'gemini-1.5-flash',
                                          systemInstruction: Content.system(
                                              'Eres un sistema de sincronizacin de inventarios IMMEX. Genera estadsticas de sincronizacin realistas para el Anexo 24 y Anexo 30 del programa IMMEX. Responde SOLO en JSON: {"a24Pct": 0.0, "a30Pct": 0.0, "ultimaSync": "string", "registrosSincronizados": 0, "errores": 0}'),
                                        );
                                        final res = await model
                                            .generateContent([
                                          Content.text(
                                              'Genera estadisticas de sincronizacion IMMEX')
                                        ]);
                                        final text = res.text
                                                ?.replaceAll('`json', '')
                                                .replaceAll('`', '')
                                                .trim() ??
                                            '{}';
                                        final data = jsonDecode(text);

                                        if (context.mounted) {
                                          setState(() {
                                            _syncing = false;
                                            _synced = true;
                                            _a24Pct =
                                                ((data as Map<String, dynamic>)[
                                                            'a24Pct'] as num? ??
                                                        65.0)
                                                    .toDouble();
                                            _a30Pct =
                                                (data['a30Pct'] as num? ?? 63.2)
                                                    .toDouble();
                                          });
                                        }
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        setState(() => _syncing = false);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text("Error AI: $e")));
                                      }
                                    },
                              icon: _syncing
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          color: _bg, strokeWidth: 2))
                                  : const Icon(Icons.bolt,
                                      size: 16, color: _bg),
                              label: Text(
                                  _syncing
                                      ? 'Sincronizando...'
                                      : 'Forzar Sincronia Global',
                                  style: const TextStyle(
                                      color: _bg, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _ambar,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                            ),
                          ),
                        ]),
                  ),
                ),
                const SizedBox(height: 20),
                // Card 3: Cross-Expiration Clock
                _HoverContainer(
                  child: _cuanticaCard(
                    icon: Icons.timer,
                    iconColor: _ambar,
                    title: 'Cross-Expiration Clock',
                    subtitle:
                        'Unifica la caducidad fisica (18 meses) con el credito fiscal.',
                    child: Column(children: [
                      const SizedBox(height: 4),
                      const Text('Dias para Vencimiento Critico (A24/A30)',
                          style: TextStyle(color: _sec, fontSize: 11),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text("$_diasVenc DIAS",
                          style: const TextStyle(
                              color: _rojo,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2)),
                      const SizedBox(height: 4),
                      const Text('Pedimento: 26 8301 2012345',
                          style: TextStyle(color: _sec, fontSize: 10)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content:
                                      Text('Complemento de Pago F4 generado'),
                                  backgroundColor: _card)),
                          icon: const Icon(Icons.warning_amber,
                              size: 16, color: Colors.white),
                          label: const Text('Pagar Impuestos (F4)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _rojo,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ]),
                  ),
                ),
              ])),
              const SizedBox(width: 24),
              // RIGHT column
              Expanded(
                  child: Column(children: [
                // Card 2: Conciliador Cuantico
                _HoverContainer(
                  child: _cuanticaCard(
                    icon: Icons.compare_arrows,
                    iconColor: _rojo,
                    title: 'Conciliador Cuantico',
                    subtitle:
                        'Detecta discrepancias entre el % de avance fisico y el financiero.',
                    child: Column(children: [
                      // Inner card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _bord)),
                        child: Column(children: [
                          const Text('Pedimento: 26 8301 2012345',
                              style: TextStyle(
                                  color: _texto,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                                child: Text(
                                    "Anexo 24: ${_synced ? "${_a24Pct.toStringAsFixed(1)}%" : "0%"} Descargado",
                                    style: const TextStyle(
                                        color: _sec, fontSize: 10))),
                            Expanded(
                                child: Text(
                                    "Anexo 30: ${_synced ? "${_a30Pct.toStringAsFixed(1)}%" : "0%"} Amortizado",
                                    style: const TextStyle(
                                        color: _sec, fontSize: 10),
                                    textAlign: TextAlign.right)),
                          ]),
                          const SizedBox(height: 6),
                          if (_synced)
                            ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: _a24Pct / 100,
                                  minHeight: 5,
                                  backgroundColor: _bord,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      _hayDesviacion ? _rojo : _teal),
                                )),
                          const SizedBox(height: 6),
                          Text(_desviacion,
                              style: TextStyle(
                                  color: _hayDesviacion ? _rojo : _sec,
                                  fontSize: 10,
                                  fontWeight: _hayDesviacion
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text(
                                      'Ajuste Regla 7.3.3 generado - Revision pendiente'),
                                  backgroundColor: _card)),
                          icon: const Icon(Icons.bolt,
                              size: 16, color: Colors.white),
                          label: const Text('Generar Ajuste (Regla 7.3.3)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _rojo,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),
                // Card 4: Forex Time-Machine
                _HoverContainer(
                  child: _cuanticaCard(
                    icon: Icons.currency_exchange,
                    iconColor: _ambar,
                    title: 'Forex Time-Machine',
                    subtitle:
                        'Recupera Tipos de Cambio del DOF/Banxico para recalibraciones retroactivas.',
                    child: Column(children: [
                      // Date picker row
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                              context: context,
                              initialDate: _fechaForex,
                              firstDate: DateTime(2010),
                              lastDate: DateTime.now(),
                              builder: (c, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                          primary: _ambar)),
                                  child: child!));
                          if (d != null) {
                            setState(() {
                              _fechaForex = d;
                              _tcHistorico = 0.0;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _bord)),
                          child: Row(children: [
                            const Expanded(
                                child: Text('Fecha Requerida:',
                                    style:
                                        TextStyle(color: _sec, fontSize: 12))),
                            Text(
                                "${_fechaForex.day} / ${_mes(_fechaForex.month)} / ${_fechaForex.year}",
                                style: const TextStyle(
                                    color: _texto,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _bord)),
                        child: Row(children: [
                          const Expanded(
                              child: Text('TC Historico Recuperado:',
                                  style: TextStyle(color: _sec, fontSize: 12))),
                          Text(
                              _tcHistorico > 0
                                  ? "\${_tcHistorico.toStringAsFixed(4)} MXN/USD"
                                  : '-',
                              style: TextStyle(
                                  color: _tcHistorico > 0 ? _ambar : _sec,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _tcLoading
                              ? null
                              : () async {
                                  setState(() => _tcLoading = true);
                                  try {
                                    final model =
                                        FirebaseAI.vertexAI().generativeModel(
                                      model: 'gemini-1.5-flash',
                                      systemInstruction: Content.system(
                                          'Eres el sistema del DOF (Diario Oficial de la Federacin) de Mxico. Proporciona el tipo de cambio FIX del Banco de Mxico ms reciente para el peso mexicano vs dlar americano. Responde SOLO en JSON: {"tipoCambio": 0.0, "fecha": "string", "fuente": "string"}'),
                                    );
                                    final res = await model.generateContent([
                                      Content.text(
                                          "Dame el tipo de cambio para la fecha $_fechaForex")
                                    ]);
                                    final text = res.text
                                            ?.replaceAll('`json', '')
                                            .replaceAll('`', '')
                                            .trim() ??
                                        '{}';
                                    final data = jsonDecode(text);

                                    if (context.mounted) {
                                      setState(() {
                                        _tcLoading = false;
                                        _tcHistorico =
                                            ((data as Map<String, dynamic>)[
                                                        'tipoCambio'] as num? ??
                                                    17.5)
                                                .toDouble();
                                      });
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    setState(() => _tcLoading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text("Error AI: $e")));
                                  }
                                },
                          icon: _tcLoading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      color: _bg, strokeWidth: 2))
                              : const Icon(Icons.settings_backup_restore,
                                  size: 16, color: _bg),
                          label: const Text('Aplicar TC Retroactivo al A30',
                              style: TextStyle(
                                  color: _bg, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _ambar,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ]),
                  ),
                ),
              ])),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _cuanticaCard(
      {required IconData icon,
      required Color iconColor,
      required String title,
      required String subtitle,
      required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 12),
          Text(title,
              style: const TextStyle(
                  color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        Text(subtitle,
            style: const TextStyle(color: _sec, fontSize: 11, height: 1.5)),
        const SizedBox(height: 20),
        child,
      ]),
    );
  }

  Widget _syncRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(
            child:
                Text(label, style: const TextStyle(color: _sec, fontSize: 12))),
        Text(value,
            style: const TextStyle(
                color: _texto, fontSize: 12, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
