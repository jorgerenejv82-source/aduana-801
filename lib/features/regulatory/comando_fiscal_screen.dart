import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _gold = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _verde = AppColors.green;

class ComandoFiscalScreen extends StatefulWidget {
  const ComandoFiscalScreen({super.key});

  @override
  _ComandoFiscalScreenState createState() => _ComandoFiscalScreenState();
}

class _ComandoFiscalScreenState extends State<ComandoFiscalScreen> {
  int _currentIndex = 0;

  // Tab 1 state
  final TextEditingController _rfcController = TextEditingController();
  bool _isVerifying = false;
  String _rfcStatus = '';
  final List<String> _recentRFCs = [
    'AAA801101AAA - ACTIVO',
    'XYZ991212XYZ - CANCELADO',
    'BBB550101BBB - ACTIVO',
    'CCC440303CCC - ACTIVO',
    'DDD770707DDD - NO ENCONTRADO',
  ];

  // Tab 2 state
  final TextEditingController _guiaController = TextEditingController();
  String _selectedTransportista = 'DHL';
  final List<String> _transportistas = [
    'DHL',
    'FedEx',
    'Estafeta',
    'Redpack',
    'AMPM',
    'UPS',
    'Castores',
    'TUM'
  ];
  bool _isTracking = false;
  bool _showTimeline = false;
  List<Map<String, dynamic>> _timelineItems = [];
  String _timelineStatus = '';

  // Tab 3 state
  String _alertFilter = 'Todos';
  final List<String> _alertFilters = [
    'Todos',
    'Criticas',
    'Importantes',
    'Informativos'
  ];

  void _verifyRFC() async {
    if (_rfcController.text.isEmpty) return;
    setState(() {
      _isVerifying = true;
      _rfcStatus = '';
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
          model: 'gemini-1.5-flash',
          systemInstruction: Content.system(
              'Eres el Director de Cumplimiento Fiscal de Aduanas en Mexico. Analiza la situacion fiscal descrita y proporciona un diagnostico completo con acciones correctivas, referencias al CFF, Ley Aduanera y RGCE. Responde en JSON: {"estado": "ACTIVO", "alertas": [{"tipo": "string", "descripcion": "string", "urgencia": "ALTA", "articulo": "string"}], "acciones": ["string"], "semaforo": "VERDE"}'));
      final res = await model.generateContent(
          [Content.text('Verifica el RFC: ${_rfcController.text}')]);
      final text =
          res.text?.replaceAll('```json', '').replaceAll('```', '').trim() ??
              '{}';
      final data = jsonDecode(text) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _rfcStatus =
            '${data['estado'] as String? ?? ''} (${data['semaforo'] as String? ?? ''})';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Acciones: ${(data['acciones'] as List?)?.join(', ') ?? 'N/A'}'),
          backgroundColor:
              (data['semaforo'] as String?) == 'ROJO' ? _rojo : _verde));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _rfcStatus = 'ERROR';
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error AI: $e'), backgroundColor: _rojo));
    }
  }

  void _trackShipment() async {
    if (_guiaController.text.isEmpty) return;
    setState(() {
      _isTracking = true;
      _showTimeline = false;
      _timelineItems = [];
      _timelineStatus = '';
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres el Director de Cumplimiento Fiscal y Aduanal de México. Dado el RFC o información de empresa proporcionada, genera un diagnóstico fiscal aduanal completo con: alertas activas, estado de cumplimiento, acciones urgentes y semáforo de riesgo. Responde SOLO en JSON: {"semaforo": "VERDE", "alertas": [{"tipo": "tipo", "descripcion": "desc", "urgencia": "alta", "accion": "accion"}], "estadoCumplimiento": "ok", "acciones": ["accion1"], "puntajeRiesgo": 100}'),
      );
      final res = await model.generateContent([
        Content.text(
            'Analiza transportista $_selectedTransportista guia ${_guiaController.text}')
      ]);
      final text =
          res.text?.replaceAll('```json', '').replaceAll('```', '').trim() ??
              '{}';
      final data = jsonDecode(text) as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _isTracking = false;
          _showTimeline = true;
          _timelineStatus =
              '${data['estadoCumplimiento'] as String? ?? ''} - Semáforo: ${data['semaforo'] as String? ?? ''}';

          final alertas = (data['alertas'] as List?) ?? [];
          _timelineItems = alertas.map((a) {
            final aMap = a as Map<String, dynamic>;
            return {
              'desc': aMap['descripcion'] as String? ?? '',
              'time': aMap['urgencia'] as String? ?? '',
            };
          }).toList();

          final acciones = (data['acciones'] as List?)?.join(', ') ?? '';
          if (acciones.isNotEmpty) {
            _timelineItems.insert(0, {
              'desc': 'Acciones: $acciones',
              'time': 'Ahora',
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTracking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error AI: $e'), backgroundColor: _rojo));
      }
    }
  }

  @override
  void dispose() {
    _rfcController.dispose();
    _guiaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: _texto),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Comando Fiscal y Log. Nacional',
              style: TextStyle(
                  color: _texto, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: _gold, size: 8),
                SizedBox(width: 4),
                Text('LIVE',
                    style: TextStyle(
                        color: _gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['SAT Dashboard', 'Logistica Nacional', 'Alertas Fiscales'];
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _bord)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _currentIndex = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _currentIndex == i ? _gold : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _currentIndex == i ? _gold : _sec,
                      fontWeight: _currentIndex == i
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildTab1();
      case 1:
        return _buildTab2();
      case 2:
        return _buildTab3();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTab1() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAlertBanner(),
        const SizedBox(height: 16),
        _buildKPIGrid(),
        const SizedBox(height: 16),
        _buildRFCVerifier(),
        const SizedBox(height: 16),
        _buildObligacionesCalendar(),
      ],
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _gold),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'ATENCION: Buzon Tributario requiere verificacion de medios de contacto antes del 31 de este mes.',
              style: TextStyle(color: _gold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildKPICard('Constancia SAT', 'ACTIVO', 'RFC: AAA801101AAA', _verde),
        _buildKPICard(
            'Opinion Cumplimiento', 'POSITIVA', 'Vigencia: 28/08/2024', _verde),
        _buildKPICard(
            'Buzon Tributario', '3 MENS', 'Ultimo: 15/07/2024', _gold),
        _buildKPICard(
            'Lista EFOS/EDOS', 'SIN ALERT', 'Proveedores: 127', _verde),
      ],
    );
  }

  Widget _buildKPICard(
      String title, String status, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bord),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: _sec, fontSize: 12)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color),
            ),
            child: Text(status,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          Text(subtitle, style: const TextStyle(color: _sec, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRFCVerifier() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bord),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Verificacion de RFC',
              style: TextStyle(
                  color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rfcController,
                  style: const TextStyle(color: _texto),
                  decoration: InputDecoration(
                    hintText: 'Ingrese RFC',
                    hintStyle: const TextStyle(color: _sec),
                    filled: true,
                    fillColor: _bg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isVerifying ? null : _verifyRFC,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: _bg, strokeWidth: 2))
                    : const Text('Consultar',
                        style:
                            TextStyle(color: _bg, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (_rfcStatus.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Resultado: $_rfcStatus',
                  style: TextStyle(
                      color: _rfcStatus == 'ACTIVO' ? _verde : _rojo,
                      fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 16),
          const Text('Ultimas verificaciones:',
              style: TextStyle(color: _sec, fontSize: 12)),
          const SizedBox(height: 8),
          for (final rfc in _recentRFCs)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(rfc,
                  style: const TextStyle(color: _texto, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildObligacionesCalendar() {
    final obligaciones = [
      {
        'title': 'DIOT (Declaracion Informativa de Operaciones)',
        'date': '17 del mes'
      },
      {'title': 'Declaracion mensual ISR/IVA', 'date': '17 del mes'},
      {'title': 'Pago provisional ISR', 'date': '17 del mes'},
      {'title': 'INEGI', 'date': 'trimestral'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bord),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Obligaciones Fiscales',
              style: TextStyle(
                  color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          for (final ob in obligaciones)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: _sec, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(ob['title']!,
                          style: const TextStyle(color: _texto, fontSize: 13))),
                  Text(ob['date']!,
                      style: const TextStyle(
                          color: _gold,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTab2() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTrackingPanel(),
        const SizedBox(height: 16),
        _buildActiveShipments(),
        const SizedBox(height: 16),
        _buildCartaPorteGenerator(),
      ],
    );
  }

  Widget _buildTrackingPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bord),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rastreo de Guia',
              style: TextStyle(
                  color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _guiaController,
                  style: const TextStyle(color: _texto),
                  decoration: InputDecoration(
                    hintText: 'Numero de guia',
                    hintStyle: const TextStyle(color: _sec),
                    filled: true,
                    fillColor: _bg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTransportista,
                      dropdownColor: _card,
                      style: const TextStyle(color: _texto),
                      isExpanded: true,
                      onChanged: (v) =>
                          setState(() => _selectedTransportista = v!),
                      items: [
                        for (final t in _transportistas)
                          DropdownMenuItem(value: t, child: Text(t)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isTracking ? null : _trackShipment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isTracking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(color: _bg, strokeWidth: 2))
                  : const Text('Rastrear',
                      style:
                          TextStyle(color: _bg, fontWeight: FontWeight.bold)),
            ),
          ),
          if (_showTimeline)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      _timelineStatus.isNotEmpty
                          ? 'Estado: $_timelineStatus'
                          : 'Historial de ruta:',
                      style: const TextStyle(color: _sec, fontSize: 12)),
                  const SizedBox(height: 8),
                  if (_timelineItems.isNotEmpty) ...[
                    for (int i = 0; i < _timelineItems.length; i++)
                      _buildTimelineItem(_timelineItems[i]['desc'] as String,
                          _timelineItems[i]['time'] as String, i == 0),
                  ] else ...[
                    _buildTimelineItem(
                        'En transito hacia destino', 'Hoy 10:30', true),
                    _buildTimelineItem('Salida de centro de distribucion',
                        'Ayer 22:15', false),
                    _buildTimelineItem('Recolectado', 'Ayer 15:00', false),
                  ]
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String desc, String time, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.circle, color: isLast ? _gold : _sec, size: 12),
            if (!isLast) Container(width: 2, height: 20, color: _sec),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(desc,
                style: TextStyle(
                    color: _texto,
                    fontSize: 13,
                    fontWeight: isLast ? FontWeight.bold : FontWeight.normal))),
        Text(time, style: const TextStyle(color: _sec, fontSize: 12)),
      ],
    );
  }

  Widget _buildActiveShipments() {
    final shipments = [
      {
        'guia': 'EST-2024-88991',
        'trans': 'Estafeta',
        'ruta': 'CDMX -> Monterrey',
        'status': 'EN TRANSITO',
        'eta': 'ETA: Manana 14:00',
        'color': _gold
      },
      {
        'guia': 'DHL-MX-447788',
        'trans': 'DHL',
        'ruta': 'Manzanillo -> Guadalajara',
        'status': 'ENTREGADO',
        'eta': '15/07 09:30',
        'color': _verde
      },
      {
        'guia': 'RED-2024-33211',
        'trans': 'Redpack',
        'ruta': 'Nuevo Laredo -> CDMX',
        'status': 'ADUANA',
        'eta': 'Pendiente',
        'color': _rojo
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bord),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Envios Nacionales Activos',
              style: TextStyle(
                  color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          for (final s in shipments)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: _bg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s['guia'] as String,
                          style: const TextStyle(
                              color: _texto, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: (s['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(s['status'] as String,
                            style: TextStyle(
                                color: s['color'] as Color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${s['trans']} | ${s['ruta']}',
                      style: const TextStyle(color: _sec, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(s['eta'] as String,
                      style: const TextStyle(color: _sec, fontSize: 11)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartaPorteGenerator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bord),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Generador Rapido Carta Porte',
              style: TextStyle(
                  color: _texto, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Formato CCP 3.0 Obligatorio',
              style: TextStyle(color: _gold, fontSize: 11)),
          const SizedBox(height: 12),
          _buildTextField('RFC Transportista'),
          const SizedBox(height: 8),
          _buildTextField('Placas'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField('Origen')),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField('Destino')),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('UUID Generado: 8A7B2C...')));
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _gold),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Generar UUID Carta Porte',
                  style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      style: const TextStyle(color: _texto),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _sec, fontSize: 13),
        filled: true,
        fillColor: _bg,
        isDense: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildTab3() {
    final alerts = [
      {
        'sev': 'CRITICA',
        'title':
            'Nuevas reglas CFDI 4.0 vigentes desde enero 2024. RFC receptor obligatorio.',
        'source': 'DOF',
        'date': '15-Dic-2023',
        'color': _rojo
      },
      {
        'sev': 'IMPORTANTE',
        'title':
            'Reforma Ley Aduanera 2024: Nuevas causales de cancelacion de patente.',
        'source': 'DOF',
        'date': '01-Feb-2024',
        'color': _gold
      },
      {
        'sev': 'INFORMATIVO',
        'title': 'UMA 2024: MXN 108.57 diarios / MXN 3,300.93 mensuales.',
        'source': 'INEGI',
        'date': 'Feb-2024',
        'color': _verde
      },
      {
        'sev': 'IMPORTANTE',
        'title':
            'IMMEX: Obligatorio presentar Informe de Produccion 2023 antes del 31 de marzo.',
        'source': 'SAT',
        'date': 'Mar-2024',
        'color': _gold
      },
      {
        'sev': 'CRITICA',
        'title':
            'Lista EFOS actualizada con 2,847 nuevas empresas. Verificar proveedores.',
        'source': 'SAT',
        'date': 'Jul-2024',
        'color': _rojo
      },
    ];

    List<Map<String, dynamic>> filteredAlerts = alerts;
    if (_alertFilter == 'Criticas') {
      filteredAlerts = alerts.where((a) => a['sev'] == 'CRITICA').toList();
    } else if (_alertFilter == 'Importantes') {
      filteredAlerts = alerts.where((a) => a['sev'] == 'IMPORTANTE').toList();
    } else if (_alertFilter == 'Informativos') {
      filteredAlerts = alerts.where((a) => a['sev'] == 'INFORMATIVO').toList();
    }

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              for (final filter in _alertFilters)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter,
                        style: TextStyle(
                            color: _alertFilter == filter ? _bg : _texto)),
                    selected: _alertFilter == filter,
                    selectedColor: _gold,
                    backgroundColor: _card,
                    onSelected: (val) => setState(() => _alertFilter = filter),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredAlerts.length,
            itemBuilder: (context, index) {
              final alert = filteredAlerts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _bord),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: (alert['color'] as Color)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(alert['sev'] as String,
                              style: TextStyle(
                                  color: alert['color'] as Color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Text('${alert['source']} | ${alert['date']}',
                            style: const TextStyle(color: _sec, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(alert['title'] as String,
                        style: const TextStyle(color: _texto, fontSize: 14)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {},
                      child: const Text('Ver detalle',
                          style: TextStyle(
                              color: _gold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
