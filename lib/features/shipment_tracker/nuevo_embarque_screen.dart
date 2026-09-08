import 'dart:async';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:intl/intl.dart';

class NuevoEmbarqueScreen extends StatefulWidget {
  const NuevoEmbarqueScreen({super.key});

  @override
  State<NuevoEmbarqueScreen> createState() => _NuevoEmbarqueScreenState();
}

class _NuevoEmbarqueScreenState extends State<NuevoEmbarqueScreen> {
  PlatformFile? _uploadedFile;
  bool _isAnalyzing = false;
  bool _isSaving = false;

  Map<String, dynamic>? _extractedData;

  String? _selectedClienteId;
  DateTime? _selectedEta;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _tipoController = TextEditingController();
  final _navieraController = TextEditingController();
  final _bookingController = TextEditingController();
  final _contenedorController = TextEditingController();
  final _vesselController = TextEditingController();
  final _voyageController = TextEditingController();
  final _polController = TextEditingController();
  final _podController = TextEditingController();
  final _etaPolController = TextEditingController();
  final _etaPodController = TextEditingController();
  final _shipperController = TextEditingController();
  final _consignatarioController = TextEditingController();
  final _notifyController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _pesoController = TextEditingController();
  final _bultosController = TextEditingController();
  final _volumenController = TextEditingController();
  final _incotermController = TextEditingController();
  final _valorController = TextEditingController();
  final _monedaController = TextEditingController(text: 'USD');
  final _trackingUrlController = TextEditingController();
  final _aduanaDestinoController = TextEditingController();

  Future<void> _uploadFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _uploadedFile = result.files.first;
      });
    }
  }

  Future<void> _analyzeWithIA() async {
    if (_uploadedFile == null || _uploadedFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sube un archivo primero')));
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
        systemInstruction: Content.system(
            'Eres un experto en documentos de transporte internacional (B/L marÃƒÂ­timos y AWB aÃƒÂ©reos). '
            'Extrae TODOS los datos del documento proporcionado. '
            'Responde SOLO en JSON con estos campos exactos: '
            '{"tipo": "maritimo|aereo", "naviera": "", "booking": "", '
            '"contenedor": "", "vessel": "", "voyage": "", '
            '"pol": "", "pod": "", "etaPol": "", "etaPod": "", '
            '"shipper": "", "consignatario": "", "notify": "", '
            '"descripcion": "", "peso": "", "bultos": "", "volumen": "", '
            '"incoterm": "", "valorDeclarado": "", "moneda": "USD", '
            '"trackingUrl": ""}'),
      );

      final extension = _uploadedFile!.extension?.toLowerCase() ?? 'jpeg';
      String mimeType = 'image/jpeg';
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'pdf') {
        mimeType = 'application/pdf';
      }

      final response = await model.generateContent([
        Content.multi([
          InlineDataPart(mimeType, _uploadedFile!.bytes!),
          TextPart('Extrae todos los datos de este documento de transporte')
        ])
      ]);

      if (response.text != null) {
        final data = jsonDecode(response.text!) as Map<String, dynamic>;
        setState(() {
          _extractedData = data;
          _fillControllers(data);
        });
      } else {
        throw Exception('La IA no devolviÃƒÂ³ respuesta');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error IA: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _fillControllers(Map<String, dynamic> data) {
    _tipoController.text = data['tipo']?.toString() ?? '';
    _navieraController.text = data['naviera']?.toString() ?? '';
    _bookingController.text = data['booking']?.toString() ?? '';
    _contenedorController.text = data['contenedor']?.toString() ?? '';
    _vesselController.text = data['vessel']?.toString() ?? '';
    _voyageController.text = data['voyage']?.toString() ?? '';
    _polController.text = data['pol']?.toString() ?? '';
    _podController.text = data['pod']?.toString() ?? '';
    _etaPolController.text = data['etaPol']?.toString() ?? '';
    _etaPodController.text = data['etaPod']?.toString() ?? '';
    _shipperController.text = data['shipper']?.toString() ?? '';
    _consignatarioController.text = data['consignatario']?.toString() ?? '';
    _notifyController.text = data['notify']?.toString() ?? '';
    _descripcionController.text = data['descripcion']?.toString() ?? '';
    _pesoController.text = data['peso']?.toString() ?? '';
    _bultosController.text = data['bultos']?.toString() ?? '';
    _volumenController.text = data['volumen']?.toString() ?? '';
    _incotermController.text = data['incoterm']?.toString() ?? '';
    _valorController.text = data['valorDeclarado']?.toString() ?? '';
    _monedaController.text = data['moneda']?.toString() ?? 'USD';

    String url = data['trackingUrl']?.toString() ?? '';
    if (url.isEmpty && _navieraController.text.isNotEmpty) {
      url = _generateTrackingUrl(_navieraController.text,
          _contenedorController.text, _bookingController.text);
    }
    _trackingUrlController.text = url;
  }

  String _generateTrackingUrl(
      String naviera, String contenedor, String booking) {
    final n = naviera.toLowerCase();
    if (n.contains('maersk')) {
      return 'https://www.maersk.com/tracking/$contenedor';
    }
    if (n.contains('msc')) {
      return 'https://www.msc.com/en/search-a-shipment?trackingNumber=$booking';
    }
    if (n.contains('cma') || n.contains('cgm')) {
      return 'https://www.cma-cgm.com/ebusiness/tracking/$contenedor';
    }
    if (n.contains('hapag') || n.contains('lloyd')) {
      return 'https://www.hapag-lloyd.com/en/online-business/tracing/tracing-by-booking.html?bookingId=$booking';
    }
    if (n.contains('one')) {
      return 'https://ecomm.one-line.com/one-ecom/manage-shipment/cargo-tracking?tno=$contenedor';
    }
    if (n.contains('evergreen')) {
      return 'https://ct.evermarts.com/ct_login.do?num=$contenedor';
    }
    if (n.contains('cosco')) {
      return 'https://elines.coscoshipping.com/ebusiness/cargoTracking?trackingType=BOOKING&number=$booking';
    }
    if (n.contains('yang') || n.contains('ming')) {
      return 'https://www.yangming.com/e-service/Track_Trace/track_trace_cargo_tracking.aspx?number=$contenedor';
    }
    if (n.contains('fedex')) {
      return 'https://www.fedex.com/fedextrack/?tracknumbers=$booking';
    }
    if (n.contains('dhl')) {
      return 'https://www.dhl.com/mx-es/home/tracking.html?tracking-id=$booking';
    }
    if (n.contains('ups')) return 'https://www.ups.com/track?tracknum=$booking';
    if (n.contains('aeromexico') || n.contains('aeromÃƒÂ©xico')) {
      return 'https://aeromexico.com/cargo/tracking/$booking';
    }
    if (n.contains('latam')) {
      return 'https://www.latamcargo.com/en/trackyourshipment?awbnumber=$booking';
    }
    return 'https://www.google.com/search?q=tracking+$naviera+$contenedor';
  }

  Future<void> _saveAndCreateExpediente() async {
    if (!_formKey.currentState!.validate() || _selectedClienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Completa los campos requeridos y selecciona un cliente')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      final data = {
        'uid': uid,
        'clienteId': _selectedClienteId,
        'tipo': _tipoController.text,
        'naviera': _navieraController.text,
        'booking': _bookingController.text,
        'contenedor': _contenedorController.text,
        'vessel': _vesselController.text,
        'voyage': _voyageController.text,
        'pol': _polController.text,
        'pod': _podController.text,
        'etaPol': _etaPolController.text,
        'etaPod': _selectedEta != null
            ? Timestamp.fromDate(_selectedEta!)
            : _etaPodController.text,
        'shipper': _shipperController.text,
        'consignatario': _consignatarioController.text,
        'notify': _notifyController.text,
        'descripcion': _descripcionController.text,
        'peso': _pesoController.text,
        'bultos': _bultosController.text,
        'volumen': _volumenController.text,
        'incoterm': _incotermController.text,
        'valorDeclarado': _valorController.text,
        'moneda': _monedaController.text,
        'trackingUrl': _trackingUrlController.text,
        'aduanaDestino': _aduanaDestinoController.text,
        'status': 'en_transito',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef =
          await FirebaseFirestore.instance.collection('embarques').add(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Embarque guardado Ã¢Å“â€¦',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.green));
        // Navigate options
        unawaited(showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Embarque Creado',
                style: TextStyle(color: Color(0xFFF8FAFC))),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('¿Qué deseas hacer ahora?',
                    style: TextStyle(color: Color(0xFF94A3B8))),
                SizedBox(height: 8),
                Text(
                  '📌 El botón "Ver Tracking" abre el portal de rastreo de la naviera en el navegador. '
                  'Para rastreo automatizado en tiempo real integrado, se requiere API de Project44 o acuerdo directo con la naviera.',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/trafico_despacho');
                },
                child: const Text('Ver en Torre de TrÃƒ¡fico',
                    style: TextStyle(color: Color(0xFF94A3B8))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/despacho_hub', extra: {
                    'clienteId': _selectedClienteId,
                    'embarqueId': docRef.id
                  });
                },
                child: const Text('+ Iniciar Expediente de Despacho',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _navieraController.dispose();
    _bookingController.dispose();
    _contenedorController.dispose();
    _vesselController.dispose();
    _voyageController.dispose();
    _polController.dispose();
    _podController.dispose();
    _etaPolController.dispose();
    _etaPodController.dispose();
    _shipperController.dispose();
    _consignatarioController.dispose();
    _notifyController.dispose();
    _descripcionController.dispose();
    _pesoController.dispose();
    _bultosController.dispose();
    _volumenController.dispose();
    _incotermController.dispose();
    _valorController.dispose();
    _monedaController.dispose();
    _trackingUrlController.dispose();
    _aduanaDestinoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Nuevo Embarque (IA)',
            style: TextStyle(color: Color(0xFFF8FAFC))),
        iconTheme: const IconThemeData(color: Color(0xFFF8FAFC)),
      ),
      body: _extractedData == null ? _buildUploadStep() : _buildReviewStep(),
    );
  }

  Widget _buildUploadStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.document_scanner,
                size: 80, color: Color(0xFF3B82F6)),
            const SizedBox(height: 24),
            const Text(
              'Sube un B/L o AWB para extraer los datos mÃƒ¡gicamente',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 18),
            ),
            const SizedBox(height: 32),
            if (_uploadedFile != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.file_present, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 12),
                    Text(_uploadedFile!.name,
                        style: const TextStyle(color: Color(0xFFF8FAFC))),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334155),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                  icon: const Icon(Icons.upload_file, color: Color(0xFFF8FAFC)),
                  label: const Text('Seleccionar Documento',
                      style: TextStyle(color: Color(0xFFF8FAFC))),
                  onPressed: _uploadFile,
                ),
                const SizedBox(width: 16),
                if (_uploadedFile != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.auto_awesome, color: Colors.white),
                    label: Text(
                        _isAnalyzing ? 'Analizando...' : 'Analizar con IA',
                        style: const TextStyle(color: Colors.white)),
                    onPressed: _isAnalyzing ? null : _analyzeWithIA,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.green.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.green),
                SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'Datos extraÃƒÂ­dos con ÃƒÂ©xito. Revisa y confirma la informaciÃƒÂ³n.',
                        style: TextStyle(color: AppColors.green))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Cliente Selector
          const Text('Asignar Cliente',
              style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('clientes')
                .where('uid', isEqualTo: uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final docs = snapshot.data!.docs;
              return DropdownButtonFormField<String>(
                initialValue: _selectedClienteId,
                dropdownColor: const Color(0xFF334155),
                decoration: _inputDecoration('Selecciona un Cliente'),
                items: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child:
                        Text(data['razonSocial']?.toString() ?? 'Sin Nombre'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedClienteId = v),
                validator: (v) => v == null ? 'Requerido' : null,
              );
            },
          ),

          const SizedBox(height: 24),
          const Text('Datos Generales',
              style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                      _tipoController, 'Tipo (maritimo/aereo)')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildTextField(
                      _navieraController, 'Naviera / AerolÃƒÂ­nea')),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(_bookingController, 'Booking / AWB')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildTextField(_contenedorController, 'Contenedor')),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(_vesselController, 'Vessel (Buque)')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildTextField(_voyageController, 'Voyage (Viaje)')),
            ],
          ),

          const SizedBox(height: 24),
          const Text('Ruta y Fechas',
              style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(_polController, 'POL (Origen)')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_podController, 'POD (Destino)')),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(_etaPolController, 'ETD (Salida)')),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedEta = date;
                        _etaPodController.text =
                            DateFormat('yyyy-MM-dd').format(date);
                      });
                    }
                  },
                  child: IgnorePointer(
                    child: _buildTextField(_etaPodController, 'ETA Confirmada',
                        suffixIcon: const Icon(Icons.calendar_today,
                            color: Color(0xFF94A3B8))),
                  ),
                ),
              ),
            ],
          ),
          _buildTextField(_aduanaDestinoController,
              'Aduana de Despacho (Ej. Manzanillo, AICM)'),

          const SizedBox(height: 24),
          const Text('Partes Involucradas',
              style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 16),
          _buildTextField(_shipperController, 'Shipper'),
          _buildTextField(_consignatarioController, 'Consignee'),
          _buildTextField(_notifyController, 'Notify'),

          const SizedBox(height: 24),
          const Text('MercancÃƒÂ­a',
              style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 16),
          _buildTextField(
              _descripcionController, 'DescripciÃƒÂ³n de la mercancÃƒÂ­a',
              maxLines: 3),
          Row(
            children: [
              Expanded(child: _buildTextField(_pesoController, 'Peso Bruto')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_bultosController, 'Bultos')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildTextField(_volumenController, 'Volumen / CBM')),
            ],
          ),

          const SizedBox(height: 24),
          const Text('Tracking y Valores',
              style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 16),
          _buildTextField(_trackingUrlController, 'URL de Rastreo'),
          Row(
            children: [
              Expanded(child: _buildTextField(_incotermController, 'Incoterm')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildTextField(_valorController, 'Valor Comercial')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_monedaController, 'Moneda')),
            ],
          ),

          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save, color: Colors.white),
            label: Text(_isSaving ? 'Guardando...' : 'Guardar y Continuar',
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            onPressed: _isSaving ? null : _saveAndCreateExpediente,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Color(0xFFF8FAFC)),
        maxLines: maxLines,
        decoration: _inputDecoration(label, suffixIcon: suffixIcon),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF475569))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF475569))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF3B82F6))),
    );
  }
}
