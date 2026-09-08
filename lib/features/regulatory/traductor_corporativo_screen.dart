import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const Color _bg = Color(0xFF0F172A);
const Color _card = Color(0xFF1E293B);
const Color _card2 = Color(0xFF334155);
const Color _texto = Color(0xFFF8FAFC);
const Color _ambar = Color(0xFFF59E0B);
const Color _bord = Color(0xFF475569);
const Color _morado = Color(0xFF8B5CF6);
const Color _verde = AppColors.green;
const Color _sec = Color(0xFF94A3B8);

class _Termino {
  final String termino;
  final String acronimo;
  final String significado;
  final String marcoLegal;

  const _Termino(
      this.termino, this.acronimo, this.significado, this.marcoLegal);
}

const List<_Termino> _glosarioAduanero = [
  _Termino(
      'Pedimento',
      'PED',
      'Declaracion electronica generada para amparar la estancia legal de la mercancia.',
      'Art. 2 LA'),
  _Termino(
      'Reconocimiento Aduanero',
      'RA',
      'Examen de las mercancias de importacion o exportacion para allegarse de elementos que ayuden a cerciorarse de la veracidad de lo declarado.',
      'Art. 43 LA'),
  _Termino(
      'Programa IMMEX',
      'IMMEX',
      'Instrumento que permite importar temporalmente bienes necesarios para ser utilizados en un proceso industrial o de servicio.',
      'Decreto IMMEX'),
  _Termino(
      'Certificado de Origen',
      'CO',
      'Documento que prueba el origen de las mercancias para obtener preferencias arancelarias.',
      'Reglas de Origen T-MEC'),
  _Termino(
      'Valor en Aduana',
      'VA',
      'Valor de transaccion de las mercancias, mas los incrementables (fletes, seguros) pagados hasta el punto de entrada al pais.',
      'Art. 64 LA'),
];

class TraductorCorporativoScreen extends StatefulWidget {
  const TraductorCorporativoScreen({super.key});

  @override
  State<TraductorCorporativoScreen> createState() =>
      _TraductorCorporativoScreenState();
}

class _TraductorCorporativoScreenState extends State<TraductorCorporativoScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  List<_Termino> _glosarioFiltrado = _glosarioAduanero;

  // Variables Multimodal
  final _clausulaCtrl = TextEditingController();
  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;
  bool _analizando = false;
  Map<String, dynamic>? _datosExtraidos;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    _clausulaCtrl.dispose();
    super.dispose();
  }

  void _filtrar(String query) {
    if (query.isEmpty) {
      setState(() => _glosarioFiltrado = _glosarioAduanero);
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _glosarioFiltrado = _glosarioAduanero
          .where((t) =>
              t.termino.toLowerCase().contains(q) ||
              t.acronimo.toLowerCase().contains(q) ||
              t.significado.toLowerCase().contains(q))
          .toList();
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
        _fileBytes = result.files.first.bytes;
        _datosExtraidos = null;
      });
    }
  }

  Future<void> _traducir() async {
    setState(() => _analizando = true);

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
        systemInstruction: Content.system(
            'Eres un Liquidador Experto de Aduanas de México y Traductor Multilingüe.'
            'Analiza el documento o texto proporcionado. Extrae y traduce al español los siguientes datos críticos para un Pedimento Aduanal en formato JSON estricto.'
            'Llaves obligatorias: "proveedor", "comprador", "mercancia" (descripción detallada), "valor", "incoterm", "origen".'
            'Si no encuentras algún dato en la imagen o texto, pon "No identificado".'),
      );

      final List<Part> parts = [];
      if (_clausulaCtrl.text.isNotEmpty) {
        parts.add(TextPart(_clausulaCtrl.text));
      } else {
        parts.add(TextPart(
            'Por favor analiza este documento comercial y extrae la información aduanal.'));
      }

      if (_fileBytes != null) {
        // En un caso real, identificar el MIME exacto según extensión. Asumimos jpeg/png.
        final mimeType =
            _selectedFile!.extension == 'png' ? 'image/png' : 'image/jpeg';
        parts.add(InlineDataPart(mimeType, _fileBytes!));
      }

      if (parts.isEmpty) {
        setState(() => _analizando = false);
        return;
      }

      final res = await model.generateContent([Content.multi(parts)]);
      final jsonText = res.text ?? "{}";
      final Map<String, dynamic> decoded =
          jsonDecode(jsonText) as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _analizando = false;
          _datosExtraidos = decoded;
        });
      }
    } catch (e) {
      debugPrint('Traductor AI error: \$e');
      if (mounted) {
        setState(() {
          _analizando = false;
          _datosExtraidos = {
            'proveedor': 'Error de IA',
            'comprador': '\$e',
            'mercancia': 'N/A',
            'valor': 'N/A',
            'incoterm': 'N/A',
            'origen': 'N/A'
          };
        });
      }
    }
  }

  Future<void> _generarPdf() async {
    if (_datosExtraidos == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                  level: 0,
                  text: 'Aduanas 801 - Reporte de Extraccion Aduanal',
                  textStyle: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Text(
                  'La Inteligencia Artificial ha traducido y extraido la siguiente informacion de la factura/documento para su uso en la proforma del pedimento:',
                  style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Campo', 'Valor Extraido (Traducido)'],
                data: [
                  ['Proveedor (Shipper)', _datosExtraidos!['proveedor'] ?? ''],
                  [
                    'Comprador (Consignee)',
                    _datosExtraidos!['comprador'] ?? ''
                  ],
                  ['Mercancia', _datosExtraidos!['mercancia'] ?? ''],
                  ['Valor Declarado', _datosExtraidos!['valor'] ?? ''],
                  ['Incoterm', _datosExtraidos!['incoterm'] ?? ''],
                  ['Pais de Origen', _datosExtraidos!['origen'] ?? ''],
                ],
                border:
                    pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                headerStyle: const pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(8),
              ),
              pw.SizedBox(height: 40),
              pw.Text('Generado por Aduanas 801 AI',
                  style: const pw.TextStyle(
                      color: PdfColors.grey600, fontSize: 10)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Extraccion_Aduanal.pdf');
  }

  Widget _header() => Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 14, 0),
        decoration: const BoxDecoration(
            color: _bg, border: Border(bottom: BorderSide(color: _bord))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: _ambar)),
            const SizedBox(width: 8),
            Expanded(
              child: TabBar(
                controller: _tabCtrl,
                indicatorColor: _ambar,
                labelColor: _ambar,
                unselectedLabelColor: _texto.withAlpha(150),
                tabs: const [
                  Tab(text: 'Glosario Tecnico'),
                  Tab(text: 'Traductor Multimodal')
                ],
              ),
            ),
          ],
        ),
      );

  Widget _tabGlosario() => Column(children: [
        Container(
            color: _card2,
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              TextField(
                controller: _searchCtrl,
                onChanged: _filtrar,
                style: const TextStyle(color: _texto, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar termino o acronimo (ej. IMMEX)...',
                  hintStyle: TextStyle(color: _sec.withAlpha(150)),
                  prefixIcon: const Icon(Icons.search, color: _sec, size: 18),
                  filled: true,
                  fillColor: _bg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                ),
              ),
            ])),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _glosarioFiltrado.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _terminoDetalle(_glosarioFiltrado[i]),
          ),
        ),
      ]);

  Widget _terminoDetalle(_Termino t) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _bord)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: _morado.withAlpha(50),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(t.acronimo,
                    style: const TextStyle(
                        color: _morado,
                        fontWeight: FontWeight.bold,
                        fontSize: 12))),
            const SizedBox(width: 8),
            Expanded(
                child: Text(t.termino,
                    style: const TextStyle(
                        color: _ambar,
                        fontSize: 16,
                        fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 12),
          Text(t.significado,
              style: const TextStyle(color: _texto, fontSize: 14, height: 1.4)),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.gavel, size: 14, color: _sec),
            const SizedBox(width: 6),
            Text(t.marcoLegal,
                style: const TextStyle(color: _sec, fontSize: 12))
          ]),
        ]),
      );

  Widget _tabTraductor() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Inteligencia Artificial Multimodal',
              style: TextStyle(
                  color: _texto, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Sube un documento comercial (ej. Factura en Chino) y/o escribe un texto. La IA lo traducira y extraera los datos criticos.',
              style: TextStyle(color: _sec, fontSize: 14)),
          const SizedBox(height: 24),

          // File Picker Area
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _ambar, width: 1.5),
              ),
              child: Column(
                children: [
                  if (_fileBytes == null) ...[
                    const Icon(Icons.upload_file, size: 48, color: _ambar),
                    const SizedBox(height: 12),
                    const Text('Seleccionar Imagen/Documento',
                        style: TextStyle(
                            color: _ambar, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Soporta PNG, JPG',
                        style: TextStyle(color: _sec, fontSize: 12)),
                  ] else ...[
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(_fileBytes!,
                            height: 150, fit: BoxFit.contain)),
                    const SizedBox(height: 12),
                    const Text('Archivo: \${_selectedFile!.name}',
                        style: TextStyle(
                            color: _verde, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextButton.icon(
                        onPressed: () => setState(() {
                              _fileBytes = null;
                              _selectedFile = null;
                              _datosExtraidos = null;
                            }),
                        icon: const Icon(Icons.delete,
                            color: Colors.redAccent, size: 16),
                        label: const Text('Quitar Archivo',
                            style: TextStyle(color: Colors.redAccent))),
                  ]
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text('Contexto adicional (opcional)',
              style: TextStyle(color: _sec, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: _clausulaCtrl,
            maxLines: 3,
            style: const TextStyle(color: _texto, fontSize: 14),
            decoration: InputDecoration(
              hintText:
                  'Ej. Presta especial atencion al incoterm oculto en las letras chiquitas...',
              hintStyle: TextStyle(color: _sec.withAlpha(150)),
              filled: true,
              fillColor: _bg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _bord)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _morado)),
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _analizando ||
                        (_fileBytes == null && _clausulaCtrl.text.isEmpty)
                    ? null
                    : _traducir,
                icon: _analizando
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome,
                        size: 16, color: Colors.black),
                label: Text(
                    _analizando
                        ? 'Extrayendo Inteligencia...'
                        : 'Traducir y Extraer (IA)',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _morado,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              )),

          if (_datosExtraidos != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: _card2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _verde)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.check_circle, color: _verde, size: 18),
                      SizedBox(width: 8),
                      Text('Datos Aduanales Extraidos',
                          style: TextStyle(
                              color: _verde,
                              fontSize: 14,
                              fontWeight: FontWeight.bold))
                    ]),
                    const SizedBox(height: 16),
                    _buildDataRow('Proveedor:',
                        _datosExtraidos!['proveedor']?.toString() ?? ''),
                    const Divider(color: _bord),
                    _buildDataRow('Comprador:',
                        _datosExtraidos!['comprador']?.toString() ?? ''),
                    const Divider(color: _bord),
                    _buildDataRow('Mercancia:',
                        _datosExtraidos!['mercancia']?.toString() ?? ''),
                    const Divider(color: _bord),
                    _buildDataRow(
                        'Valor:', _datosExtraidos!['valor']?.toString() ?? ''),
                    const Divider(color: _bord),
                    _buildDataRow('Incoterm:',
                        _datosExtraidos!['incoterm']?.toString() ?? ''),
                    const Divider(color: _bord),
                    _buildDataRow('Origen:',
                        _datosExtraidos!['origen']?.toString() ?? ''),
                    const SizedBox(height: 24),
                    SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _generarPdf,
                          icon: const Icon(Icons.picture_as_pdf,
                              color: Colors.white, size: 16),
                          label: const Text('Exportar Proforma a PDF',
                              style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        )),
                  ]),
            ),
          ],
          const SizedBox(height: 80),
        ]),
      );

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(
                      color: _sec, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(color: _texto, fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(children: [
            _header(),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _tabGlosario(),
                  _tabTraductor(),
                ],
              ),
            ),
          ]),
        ),
      );
}
