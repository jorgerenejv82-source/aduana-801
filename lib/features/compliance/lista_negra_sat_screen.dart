import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';

class ListaNegraSatScreen extends StatefulWidget {
  const ListaNegraSatScreen({super.key});

  @override
  State<ListaNegraSatScreen> createState() => _ListaNegraSatScreenState();
}

class _ListaNegraSatScreenState extends State<ListaNegraSatScreen> {
  final TextEditingController _rfcController = TextEditingController();
  bool _isScanning = false;
  Map<String, dynamic>? _scanResult;
  bool _isUploadingPdf = false;

  void _scanRfc() async {
    final rfc = _rfcController.text.trim().toUpperCase();
    if (rfc.isEmpty) return;

    setState(() {
      _isScanning = true;
      _scanResult = null;
    });

    // Simulate API delay to the DOF/SAT database
    await Future<void>.delayed(const Duration(seconds: 2));

    setState(() {
      _isScanning = false;
      // Dummy logic for demo: If RFC contains 'X', it's blacklisted
      if (rfc.contains('EFOS')) {
        _scanResult = {
          'rfc': rfc,
          'status': 'DEFINITIVO',
          'description': 'Empresa que Factura Operaciones Simuladas (EFOS).',
          'dof_date': '15/03/2026',
          'risk': 'ALTO RIESGO - PELIGRO FISCAL',
          'color': AppColors.red,
        };
      } else {
        _scanResult = {
          'rfc': rfc,
          'status': 'LIMPIO',
          'description':
              'El RFC no se encuentra en el listado del Art. 69-B del CFF.',
          'dof_date': 'N/A',
          'risk': 'SIN RIESGO',
          'color': AppColors.green,
        };
      }
    });
  }

  void _scanPdfInvoice() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null) return;

    setState(() {
      _isUploadingPdf = true;
      _scanResult = null;
    });

    // Simulate AI extraction and scanning
    await Future<void>.delayed(const Duration(seconds: 3));

    setState(() {
      _isUploadingPdf = false;
      _rfcController.text =
          'EFOS991231XYZ'; // Auto-fill with a detected risky RFC
      _scanRfc();
    });
  }

  @override
  void dispose() {
    _rfcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
        ),
        title: const Text("Radar Art. 69-B (Listas Negras SAT)",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildScannerPanel(),
              const SizedBox(height: 32),
              if (_isScanning || _isUploadingPdf)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.gold),
                      SizedBox(height: 16),
                      Text("Analizando matrices del SAT y DOF...",
                          style: TextStyle(color: AppColors.sub)),
                    ],
                  ),
                )
              else if (_scanResult != null)
                _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield, color: AppColors.blue, size: 48),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Escudo Fiscal 2026",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                    "Evita la nulidad de tus pedimentos y embargos precautorios asegurándote de no transaccionar con EFOS (Empresas que Facturan Operaciones Simuladas).",
                    style: TextStyle(
                        color: AppColors.sub, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Analizar Proveedor",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rfcController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Ej. LOGI980101XX1",
                    hintStyle: const TextStyle(color: AppColors.sub),
                    labelText: "RFC del Proveedor / Transportista",
                    labelStyle: const TextStyle(color: AppColors.gold),
                    filled: true,
                    fillColor: AppColors.bg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.gold)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _scanRfc,
                icon: const Icon(Icons.search, color: AppColors.bg),
                label: const Text("Consultar DOF",
                    style: TextStyle(
                        color: AppColors.bg, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("O EXTRAE DESDE FACTURA",
                    style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _scanPdfInvoice,
              icon: const Icon(Icons.document_scanner, color: AppColors.blue),
              label: const Text("Subir Factura PDF (IA Extrae y Analiza)",
                  style: TextStyle(color: AppColors.blue)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _scanResult!;
    final Color statusColor = result['color'] as Color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("RESULTADO DEL DICTAMEN",
                      style: TextStyle(
                          color: AppColors.sub,
                          fontSize: 12,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(result['rfc'].toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor),
                ),
                child: Text(result['status'].toString(),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.5)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(
                  result['status'] == 'LIMPIO'
                      ? Icons.check_circle
                      : Icons.warning_rounded,
                  color: statusColor,
                  size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result['risk'].toString(),
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(result['description'].toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, height: 1.5)),
                    if (result['dof_date'] != 'N/A') ...[
                      const SizedBox(height: 8),
                      Text("Fecha de publicación DOF: ${result['dof_date']}",
                          style: const TextStyle(
                              color: AppColors.sub, fontSize: 12)),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
