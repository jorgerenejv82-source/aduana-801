import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "dart:convert";
import "package:file_picker/file_picker.dart";
import "package:firebase_ai/firebase_ai.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;
import "package:printing/printing.dart";
import "package:go_router/go_router.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

// â”€â”€â”€ Design tokens â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const _bg = Color(0xFF0F172A);
const _card = Color(0xFF1E293B);
const _card2 = Color(0xFF334155);
const _txt = Color(0xFFF8FAFC);
const _sub = Color(0xFF94A3B8);
const _bord = Color(0xFF475569);
const _gold = Color(0xFFF59E0B);

class DespachoScreen extends StatefulWidget {
  final String tipo; // "importacion" | "exportacion"
  const DespachoScreen({super.key, required this.tipo});

  @override
  State<DespachoScreen> createState() => _DespachoScreenState();
}

class _DespachoScreenState extends State<DespachoScreen> {
  // Docs
  final Map<String, _DocSlot> _docs = {};
  bool _analizando = false;
  Map<String, dynamic>? _expediente;
  bool _cartaGenerada = false;
  String _cartaTexto = "";
  String? _currentDocId;

  // Editable controllers - filled after AI extraction
  final Map<String, TextEditingController> _ctrl = {};

  bool get _esImpo => widget.tipo == "importacion";
  Color get _accent => _esImpo ? const Color(0xFF3B82F6) : AppColors.green;
  String get _titulo =>
      _esImpo ? "Despacho de Importacion" : "Despacho de Exportacion";

  List<_DocSlot> get _requeridos {
    final base = [
      const _DocSlot(
          id: "factura",
          label: "Factura Comercial",
          icon: Icons.receipt_long,
          obligatorio: true),
      const _DocSlot(
          id: "packing",
          label: "Packing List (PL)",
          icon: Icons.inventory_2_outlined),
    ];
    if (_esImpo) {
      base.addAll([
        const _DocSlot(
            id: "bl",
            label: "Bill of Lading (B/L)",
            icon: Icons.directions_boat_outlined),
        const _DocSlot(
            id: "awb",
            label: "Guia Aerea (AWB)",
            icon: Icons.airplanemode_active_outlined),
        const _DocSlot(
            id: "origen",
            label: "Certificado de Origen",
            icon: Icons.public_outlined),
      ]);
    } else {
      base.addAll([
        const _DocSlot(
            id: "bl",
            label: "Bill of Lading (B/L)",
            icon: Icons.directions_boat_outlined),
        const _DocSlot(
            id: "awb",
            label: "Guia Aerea (AWB)",
            icon: Icons.airplanemode_active_outlined),
        const _DocSlot(
            id: "encomienda",
            label: "Carta de Encomienda",
            icon: Icons.description_outlined),
      ]);
    }
    return base;
  }

  @override
  void initState() {
    super.initState();
    // Init doc slots
    for (final slot in _requeridos) {
      _docs[slot.id] = slot;
    }
    // Init controllers for expediente fields
    for (final k in _camposExpediente) {
      _ctrl[k] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  static const List<String> _camposExpediente = [
    "exportador",
    "exportadorDireccion",
    "importador",
    "importadorDireccion",
    "mercancia",
    "cantidad",
    "pesoKg",
    "valor",
    "moneda",
    "incoterm",
    "origen",
    "destino",
    "puertoEmbarque",
    "puertoDesembarque",
    "referenciaBL",
    "fraccionSugerida",
    "observaciones",
    "regulaciones",
    "documentosFaltantes",
  ];

  Future<void> _pickDoc(String id) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["png", "jpg", "jpeg", "pdf"],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _docs[id] = _docs[id]!.copyWith(
          file: result.files.first,
          bytes: result.files.first.bytes,
        );
        _expediente = null;
        _cartaGenerada = false;
      });
    }
  }

  Future<void> _pickAllDocs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["png", "jpg", "jpeg", "pdf"],
      withData: true,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        int fileIndex = 0;
        for (final slotKey in _docs.keys) {
          if (fileIndex >= result.files.length) break;
          // Fill empty slots with the uploaded files
          if (_docs[slotKey]!.bytes == null) {
            _docs[slotKey] = _docs[slotKey]!.copyWith(
              file: result.files[fileIndex],
              bytes: result.files[fileIndex].bytes,
            );
            fileIndex++;
          }
        }
        _expediente = null;
        _cartaGenerada = false;
      });
    }
  }

  void _removeDoc(String id) {
    setState(() {
      _docs[id] = _requeridos.firstWhere((s) => s.id == id);
      _expediente = null;
      _cartaGenerada = false;
    });
  }

  bool get _facturaSubida => _docs["factura"]?.bytes != null;

  Future<void> _analizarConIA() async {
    if (!_facturaSubida) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("La Factura Comercial es obligatoria para continuar."),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() {
      _analizando = true;
      _expediente = null;
      _cartaGenerada = false;
    });

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: "gemini-1.5-flash",
        generationConfig:
            GenerationConfig(responseMimeType: "application/json"),
        systemInstruction: Content.system(
            "Eres un Agente Aduanal experto de Mexico y traductor poliglota. "
            "Se te proporcionan documentos de comercio exterior (pueden estar en cualquier idioma: chino, ingles, japones, etc.). "
            "Analiza TODOS los documentos y extrae la informacion en formato JSON con las siguientes llaves exactas: "
            "exportador, exportadorDireccion, importador, importadorDireccion, "
            "mercancia (descripcion detallada de la mercancia en español), cantidad, pesoKg, "
            "valor (numero con 2 decimales), moneda (USD/CNY/EUR/etc), incoterm, "
            "origen (pais de origen de la mercancia), destino (pais de destino), "
            "puertoEmbarque, puertoDesembarque, referenciaBL (numero de B/L o AWB), "
            "fraccionSugerida (fraccion arancelaria sugerida TIGIE de 8 digitos, pon N/A si no puedes determinar), "
            "observaciones (notas importantes sobre la carga), "
            "regulaciones (lista de regulaciones no arancelarias, permisos y NOMs aplicables según la mercancía), "
            "documentosFaltantes (lista de documentos que el importador NO anexó pero que son obligatorios según la fracción y el régimen, e.g. 'Falta NOM-050', 'Falta Padrón Textil'. Si todo está completo pon 'Ninguno'). "
            "Si algun dato no aparece en los documentos, escribe No identificado. "
            "Traduce TODO al español. El JSON debe ser plano (sin objetos anidados)."),
      );

      final List<Part> parts = [];
      parts.add(TextPart(
          "Analiza los siguientes documentos de comercio exterior para una operacion de ${_esImpo ? "IMPORTACION a Mexico" : "EXPORTACION de Mexico"}. "
          "Extrae TODA la informacion disponible y traducela al español."));

      for (final slot in _docs.values) {
        if (slot.bytes != null && slot.file != null) {
          final ext = slot.file!.extension?.toLowerCase() ?? "jpg";
          final mime = ext == "png" ? "image/png" : "image/jpeg";
          if (ext != "pdf") {
            // Gemini 1.5 Flash handles images directly
            parts.add(InlineDataPart(mime, slot.bytes!));
          }
        }
      }

      final res = await model.generateContent([Content.multi(parts)]);
      final jsonText = res.text ?? "{}";

      Map<String, dynamic> decoded = {};
      try {
        decoded = jsonDecode(jsonText) as Map<String, dynamic>;
      } catch (_) {
        // Try to extract JSON from text
        final match = RegExp(r"\{[\s\S]+\}").firstMatch(jsonText);
        if (match != null) {
          decoded = jsonDecode(match.group(0)!) as Map<String, dynamic>;
        }
      }

      // Fill controllers with extracted data
      for (final k in _camposExpediente) {
        _ctrl[k]?.text = decoded[k]?.toString() ?? "";
      }

      if (mounted) {
        setState(() {
          _analizando = false;
          _expediente = decoded;
        });
        await _guardarBorrador(decoded);
      }
    } catch (e) {
      debugPrint("Despacho AI error: $e");
      if (mounted) {
        setState(() {
          _analizando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error de IA: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _generarCarta() async {
    final tipo = _esImpo ? "IMPORTACION" : "EXPORTACION";
    final fecha = DateTime.now();
    final fechaStr =
        "${fecha.day.toString().padLeft(2, "0")}/${fecha.month.toString().padLeft(2, "0")}/${fecha.year}";

    final carta = """
CARTA DE INSTRUCCIONES PARA AGENTE ADUANAL
Tipo de Operacion: DESPACHO DE $tipo
Fecha: $fechaStr

â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
1. DATOS DEL EXPORTADOR
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
Empresa: ${_ctrl["exportador"]?.text}
Direccion: ${_ctrl["exportadorDireccion"]?.text}

â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
2. DATOS DEL IMPORTADOR / CONSIGNATARIO
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
Empresa: ${_ctrl["importador"]?.text}
Direccion: ${_ctrl["importadorDireccion"]?.text}

â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
3. DESCRIPCION DE LA MERCANCIA
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
Descripcion: ${_ctrl["mercancia"]?.text}
Cantidad: ${_ctrl["cantidad"]?.text}
Peso Total: ${_ctrl["pesoKg"]?.text} kg
Fraccion Arancelaria TIGIE: ${_ctrl["fraccionSugerida"]?.text}

â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
4. DATOS COMERCIALES
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
Valor de la Mercancia: ${_ctrl["moneda"]?.text} ${_ctrl["valor"]?.text}
Incoterm Pactado: ${_ctrl["incoterm"]?.text}
Pais de Origen: ${_ctrl["origen"]?.text}
Pais de Destino: ${_ctrl["destino"]?.text}

â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
5. DATOS DEL TRANSPORTE
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
Puerto / Aduana de Embarque: ${_ctrl["puertoEmbarque"]?.text}
Puerto / Aduana de Desembarque: ${_ctrl["puertoDesembarque"]?.text}
Numero de B/L o AWB: ${_ctrl["referenciaBL"]?.text}

â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
6. INSTRUCCIONES ESPECIALES / OBSERVACIONES
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
${_ctrl["observaciones"]?.text}

â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
DOCUMENTOS ADJUNTOS EN ESTE EXPEDIENTE:
${_docs.values.where((d) => d.bytes != null).map((d) => "  âœ“ ${d.label}").join("\n")}

â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
Generado por Aduanas 801 â€” Expediente Digital Inteligente
""";

    setState(() {
      _cartaTexto = carta;
      _cartaGenerada = true;
    });

    if (_currentDocId != null) {
      try {
        await FirebaseFirestore.instance
            .collection("expedientes")
            .doc(_currentDocId)
            .update({
          "cartaInstrucciones": carta,
          "estado": "completado",
          "updatedAt": FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Expediente guardado"),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } catch (e) {
        debugPrint("Error updating carta: $e");
      }
    }
  }

  void _cargarExpediente(Map<String, dynamic> data, String docId) {
    setState(() {
      _currentDocId = docId;
      _expediente = data;
      _cartaGenerada = data['estado'] == 'completado';
      _cartaTexto = (data['cartaInstrucciones'] ?? "").toString();

      for (final k in _camposExpediente) {
        _ctrl[k]?.text = data[k]?.toString() ?? "";
      }
    });
  }

  void _repetirAccion(Map<String, dynamic> data) {
    setState(() {
      _currentDocId = null; // Set to null so it saves as a new document
      _expediente = data;
      _cartaGenerada = false;
      _cartaTexto = "";

      for (final k in _camposExpediente) {
        _ctrl[k]?.text = data[k]?.toString() ?? "";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            "Expediente duplicado. Edita los datos y guárdalo como nuevo."),
        backgroundColor: _accent,
        behavior: SnackBarBehavior.floating,
      ));
    });
  }

  Future<void> _guardarBorrador(Map<String, dynamic> datos) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docNames = _docs.values
        .where((d) => d.file != null)
        .map((d) => d.file!.name)
        .toList();

    final Map<String, dynamic> dataToSave = {
      ...datos,
      "tipo": widget.tipo,
      "docSubidos": docNames,
      "estado": "borrador",
      "updatedAt": FieldValue.serverTimestamp(),
      "uid": uid,
    };

    try {
      if (_currentDocId == null) {
        dataToSave["createdAt"] = FieldValue.serverTimestamp();
        final docRef = await FirebaseFirestore.instance
            .collection("expedientes")
            .add(dataToSave);
        _currentDocId = docRef.id;
      } else {
        await FirebaseFirestore.instance
            .collection("expedientes")
            .doc(_currentDocId)
            .update(dataToSave);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Expediente guardado"),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      debugPrint("Error saving to Firestore: $e");
    }
  }

  Widget _buildRecentExpedientes() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: "Expedientes Recientes", accent: _accent),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("expedientes")
              .where("uid", isEqualTo: uid)
              .where("tipo", isEqualTo: widget.tipo)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: _gold));
            }
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.redAccent));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text("No hay expedientes recientes.",
                  style: TextStyle(color: _sub));
            }

            final allDocs = snapshot.data!.docs.toList();
            allDocs.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTime = aData['updatedAt'] != null
                  ? (aData['updatedAt'] as Timestamp).toDate()
                  : DateTime.fromMillisecondsSinceEpoch(0);
              final bTime = bData['updatedAt'] != null
                  ? (bData['updatedAt'] as Timestamp).toDate()
                  : DateTime.fromMillisecondsSinceEpoch(0);
              return bTime.compareTo(aTime);
            });
            final topDocs = allDocs.take(5).toList();

            return Column(
              children: topDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final estado = (data["estado"] ?? "borrador") as String;
                final isCompletado = estado == "completado";
                final mercancia =
                    data["mercancia"]?.toString() ?? "Sin mercancía";
                final mercanciaCorto = mercancia.length > 50
                    ? "${mercancia.substring(0, 47)}..."
                    : mercancia;
                final fecha = data["updatedAt"] != null
                    ? (data["updatedAt"] as Timestamp)
                        .toDate()
                        .toString()
                        .split(" ")[0]
                    : "";

                return Card(
                  color: _card,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                        "${data['exportador'] ?? '?'} â†’ ${data['importador'] ?? '?'}",
                        style: const TextStyle(
                            color: _txt,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    subtitle: Text("$fecha - $mercanciaCorto",
                        style: const TextStyle(color: _sub, fontSize: 11)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(estado.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white)),
                          backgroundColor: isCompletado
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.replay, color: _accent, size: 20),
                          tooltip: 'Repetir Acción (Duplicar)',
                          onPressed: () => _repetirAccion(data),
                        ),
                      ],
                    ),
                    onTap: () => _cargarExpediente(data, doc.id),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _exportarPdf() async {
    final pdf = pw.Document();
    final tipo = _esImpo ? "IMPORTACION" : "EXPORTACION";
    final fecha = DateTime.now();
    final fechaStr =
        "${fecha.day.toString().padLeft(2, "0")}/${fecha.month.toString().padLeft(2, "0")}/${fecha.year}";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("ADUANAS 801",
                        style: const pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 20,
                            color: PdfColors.blueGrey800)),
                    pw.Text("Carta de Instrucciones â€” Despacho de $tipo",
                        style: const pw.TextStyle(
                            fontSize: 13, color: PdfColors.blueGrey600)),
                    pw.Text("Fecha: $fechaStr",
                        style: const pw.TextStyle(
                            fontSize: 11, color: PdfColors.grey600)),
                    pw.Divider(color: PdfColors.blueGrey300, thickness: 1),
                  ]),
            ),
            pw.SizedBox(height: 12),
            _pdfSection("1. DATOS DEL EXPORTADOR", [
              ["Empresa", _ctrl["exportador"]?.text ?? ""],
              ["Direccion", _ctrl["exportadorDireccion"]?.text ?? ""],
            ]),
            _pdfSection("2. DATOS DEL IMPORTADOR / CONSIGNATARIO", [
              ["Empresa", _ctrl["importador"]?.text ?? ""],
              ["Direccion", _ctrl["importadorDireccion"]?.text ?? ""],
            ]),
            _pdfSection("3. DESCRIPCION DE LA MERCANCIA", [
              ["Descripcion", _ctrl["mercancia"]?.text ?? ""],
              ["Cantidad", _ctrl["cantidad"]?.text ?? ""],
              ["Peso Total", "${_ctrl["pesoKg"]?.text ?? ""} kg"],
              ["Fraccion TIGIE", _ctrl["fraccionSugerida"]?.text ?? ""],
            ]),
            _pdfSection("4. DATOS COMERCIALES", [
              [
                "Valor",
                "${_ctrl["moneda"]?.text ?? ""} ${_ctrl["valor"]?.text ?? ""}"
              ],
              ["Incoterm", _ctrl["incoterm"]?.text ?? ""],
              ["Pais Origen", _ctrl["origen"]?.text ?? ""],
              ["Pais Destino", _ctrl["destino"]?.text ?? ""],
            ]),
            _pdfSection("5. TRANSPORTE", [
              ["Puerto Embarque", _ctrl["puertoEmbarque"]?.text ?? ""],
              ["Puerto Desembarque", _ctrl["puertoDesembarque"]?.text ?? ""],
              ["B/L o AWB", _ctrl["referenciaBL"]?.text ?? ""],
            ]),
            _pdfSection("6. INSTRUCCIONES ESPECIALES", [
              ["Observaciones", _ctrl["observaciones"]?.text ?? ""],
            ]),
            pw.SizedBox(height: 16),
            pw.Text("DOCUMENTOS INCLUIDOS EN EL EXPEDIENTE:",
                style: const pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: PdfColors.blueGrey700)),
            pw.SizedBox(height: 8),
            ..._docs.values
                .where((d) => d.bytes != null)
                .map((d) => pw.Row(children: [
                      pw.Text("âœ“ ",
                          style: const pw.TextStyle(
                              color: PdfColors.green700,
                              fontWeight: pw.FontWeight.bold)),
                      pw.Text(d.label, style: const pw.TextStyle(fontSize: 11)),
                    ])),
            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.blueGrey200),
            pw.Text(
                "Generado automaticamente por Aduanas 801 AI â€” Expediente Digital Inteligente",
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "Carta_Instrucciones_${tipo}_$fechaStr.pdf",
    );
  }

  pw.Widget _pdfSection(String title, List<List<String>> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
          child: pw.Text(title,
              style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11)),
        ),
        pw.TableHelper.fromTextArray(
          headers: const ["Campo", "Valor"],
          data: rows,
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          headerStyle: const pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColors.blueGrey700),
          cellStyle: const pw.TextStyle(fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding:
              const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          columnWidths: {
            0: const pw.FixedColumnWidth(120),
            1: const pw.FlexColumnWidth()
          },
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  // â”€â”€â”€ Labels for form fields â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const Map<String, String> _labels = {
    "exportador": "Exportador / Proveedor",
    "exportadorDireccion": "Direccion del Exportador",
    "importador": "Importador / Consignatario",
    "importadorDireccion": "Direccion del Importador",
    "mercancia": "Descripcion de la Mercancia",
    "cantidad": "Cantidad / Bultos",
    "pesoKg": "Peso Total (kg)",
    "valor": "Valor",
    "moneda": "Moneda (USD/CNY/EUR...)",
    "incoterm": "Incoterm",
    "origen": "Pais de Origen",
    "destino": "Pais de Destino",
    "puertoEmbarque": "Puerto / Aduana de Embarque",
    "puertoDesembarque": "Puerto / Aduana de Desembarque",
    "referenciaBL": "Numero de B/L o AWB",
    "fraccionSugerida": "Fraccion TIGIE Sugerida",
    "observaciones": "Observaciones / Instrucciones Especiales",
    "regulaciones": "Regulaciones y NOMs Aplicables",
    "documentosFaltantes": "Documentos Faltantes (Riesgo Aduanero)",
  };

  // â”€â”€â”€ UI BUILD â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go("/despacho_hub"),
          icon: const Icon(Icons.arrow_back, color: _gold),
        ),
        title: Text(_titulo,
            style: const TextStyle(
                color: _txt, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (_expediente != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: const Text("Expediente Listo",
                    style: TextStyle(color: Colors.white, fontSize: 11)),
                backgroundColor: Colors.green.shade800,
                avatar: const Icon(Icons.check_circle,
                    color: Colors.white, size: 14),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _bord),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecentExpedientes(),
              const SizedBox(height: 28),

              // â”€â”€â”€ PASO 1: DOCUMENTOS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionHeader(
                      label: "Paso 1 â€” Sube los Documentos", accent: _accent),
                  TextButton.icon(
                    onPressed: _pickAllDocs,
                    icon: const Icon(Icons.upload_file, color: _gold, size: 18),
                    label: const Text("Cargar en Lote",
                        style: TextStyle(
                            color: _gold, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      backgroundColor: _gold.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                  "La Factura Comercial es obligatoria. Puedes subir varios de golpe con 'Cargar en Lote'.",
                  style: TextStyle(color: _sub, fontSize: 13)),
              const SizedBox(height: 16),
              ...(_docs.values.map((slot) => _DocUploadTile(
                    slot: slot,
                    accent: _accent,
                    onPick: () => _pickDoc(slot.id),
                    onRemove: () => _removeDoc(slot.id),
                  ))),

              const SizedBox(height: 28),

              // â”€â”€â”€ PASO 2: ANALIZAR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _SectionHeader(
                  label: "Paso 2 â€” Analizar con Inteligencia Artificial",
                  accent: _accent),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _analizando || !_facturaSubida ? null : _analizarConIA,
                  icon: _analizando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2))
                      : const Icon(Icons.auto_awesome,
                          color: Colors.black, size: 18),
                  label: Text(
                    _analizando
                        ? "Analizando documentos..."
                        : "Analizar con IA â€” Construir Expediente",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: _card2,
                  ),
                ),
              ),
              if (!_facturaSubida)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                      "Necesitas subir la Factura Comercial para poder analizar.",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                ),

              // â”€â”€â”€ PASO 3: EXPEDIENTE / FORMULARIO â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (_expediente != null) ...[
                const SizedBox(height: 32),
                _SectionHeader(
                    label: "Paso 3 â€” Revisa y Edita el Expediente",
                    accent: _accent),
                const SizedBox(height: 4),
                const Text(
                    "La IA extrajo y tradujo los datos. Revisa cada campo y corrige si es necesario.",
                    style: TextStyle(color: _sub, fontSize: 13)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _accent.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._camposExpediente.map((k) => _FieldRow(
                            label: _labels[k] ?? k,
                            controller: _ctrl[k]!,
                            multiline: k == "mercancia" ||
                                k == "observaciones" ||
                                k == "regulaciones" ||
                                k == "documentosFaltantes",
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // â”€â”€â”€ COMPLIANCE TRAFFIC LIGHT â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Builder(builder: (context) {
                  final missingDocs =
                      _ctrl["documentosFaltantes"]?.text.toLowerCase() ?? "";
                  final isComplete = missingDocs.isEmpty ||
                      missingDocs.contains("ninguno") ||
                      missingDocs == "no identificado";
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppColors.green.withAlpha(20)
                          : AppColors.red.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isComplete ? AppColors.green : AppColors.red),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            isComplete
                                ? Icons.check_circle
                                : Icons.warning_amber_rounded,
                            color: isComplete ? AppColors.green : AppColors.red,
                            size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  isComplete
                                      ? "Expediente Completo"
                                      : "Riesgo de Cumplimiento Detectado",
                                  style: TextStyle(
                                      color: isComplete
                                          ? AppColors.green
                                          : AppColors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                  isComplete
                                      ? "Tienes todos los documentos necesarios para esta fracción arancelaria."
                                      : "La IA detectó que faltan documentos clave: \${_ctrl['documentosFaltantes']?.text}",
                                  style: const TextStyle(
                                      color: AppColors.text, fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Expediente enviado al Agente Aduanal por WhatsApp/Email.")));
                          },
                          icon: const Icon(Icons.share,
                              color: Colors.white, size: 16),
                          label: const Text("Share to Broker",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 28),

                // â”€â”€â”€ PASO 4: GENERAR CARTA â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _SectionHeader(
                    label: "Paso 4 â€” Generar Carta de Instrucciones",
                    accent: _accent),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generarCarta,
                    icon: const Icon(Icons.description_outlined,
                        color: Colors.white, size: 18),
                    label: const Text("Generar Carta de Instrucciones",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],

              // â”€â”€â”€ PASO 5: CARTA GENERADA â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (_cartaGenerada) ...[
                const SizedBox(height: 28),
                _SectionHeader(
                    label: "Paso 5 â€” Carta Lista para Enviar",
                    accent: _accent),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_cartaTexto,
                          style: const TextStyle(
                              color: _txt,
                              fontSize: 12,
                              height: 1.7,
                              fontFamily: "monospace")),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _cartaTexto));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Carta copiada al portapapeles"),
                                backgroundColor: AppColors.green,
                                behavior: SnackBarBehavior.floating,
                              ));
                            },
                            icon: const Icon(Icons.copy, color: _sub, size: 16),
                            label: const Text("Copiar",
                                style: TextStyle(color: _sub)),
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _bord)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _exportarPdf,
                            icon: const Icon(Icons.picture_as_pdf,
                                color: Colors.white, size: 16),
                            label: const Text("Exportar PDF",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Supporting Widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color accent;
  const _SectionHeader({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
              color: accent, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(label,
          style: TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5)),
    ]);
  }
}

class _DocUploadTile extends StatelessWidget {
  final _DocSlot slot;
  final Color accent;
  final VoidCallback onPick, onRemove;

  const _DocUploadTile(
      {required this.slot,
      required this.accent,
      required this.onPick,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final hasFile = slot.bytes != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFile
              ? AppColors.green.withValues(alpha: 0.6)
              : slot.obligatorio
                  ? Colors.redAccent.withValues(alpha: 0.4)
                  : const Color(0xFF475569),
        ),
      ),
      child: Row(
        children: [
          Icon(slot.icon,
              color: hasFile ? AppColors.green : const Color(0xFF94A3B8),
              size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(slot.label,
                      style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  if (slot.obligatorio) ...[
                    const SizedBox(width: 6),
                    const Text("*",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ]),
                if (hasFile)
                  Text(slot.file!.name,
                      style:
                          const TextStyle(color: AppColors.green, fontSize: 11))
                else
                  Text(
                      slot.obligatorio
                          ? "Obligatorio â€” Toca para seleccionar"
                          : "Opcional â€” Toca para seleccionar",
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ),
          if (hasFile)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
              onPressed: onRemove,
              tooltip: "Quitar",
            )
          else
            TextButton(
              onPressed: onPick,
              child: Text("Subir",
                  style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool multiline;
  const _FieldRow(
      {required this.label, required this.controller, this.multiline = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: multiline ? 3 : 1,
            style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF475569))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF475569))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFF59E0B))),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Data model â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DocSlot {
  final String id, label;
  final IconData icon;
  final bool obligatorio;
  final PlatformFile? file;
  final Uint8List? bytes;

  const _DocSlot({
    required this.id,
    required this.label,
    required this.icon,
    this.obligatorio = false,
    this.file,
    this.bytes,
  });

  _DocSlot copyWith({PlatformFile? file, Uint8List? bytes}) => _DocSlot(
        id: id,
        label: label,
        icon: icon,
        obligatorio: obligatorio,
        file: file ?? this.file,
        bytes: bytes ?? this.bytes,
      );
}
