import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/services/ai_auditor_service.dart';
import '../../core/services/xml_sanitizer_service.dart';
import '../../core/models/audit_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/network_provider.dart';

class SwarmAiScreen extends StatefulWidget {
  const SwarmAiScreen({super.key});

  @override
  State<SwarmAiScreen> createState() => _SwarmAiScreenState();
}

class _SwarmAiScreenState extends State<SwarmAiScreen> {
  final AIAuditorService _aiService = AIAuditorService();
  String? _fileName;
  bool _isProcessing = false;
  
  String _streamBuffer = '';
  AuditReport? _finalReport;

  Future<void> _pickAndProcess() async {
    if (context.read<NetworkProvider>().isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La Inteligencia Artificial est� deshabilitada en Modo Garita (Sin Conexi�n)')),
      );
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes == null) return;
      
      setState(() {
        _fileName = file.name;
        _isProcessing = true;
        _streamBuffer = '';
        _finalReport = null;
      });

      try {
        final rawXml = utf8.decode(file.bytes!);
        final sanitizedJson = XmlSanitizerService.sanitize(rawXml);

        final stream = _aiService.analyzePedimentoStream(sanitizedJson);
        
        await for (final chunk in stream) {
          if (!mounted) return;
          setState(() {
            _streamBuffer += chunk;
          });
        }

        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _finalReport = _aiService.parseResponse(_streamBuffer);
          if (_finalReport != null) { _logAiMetrics(_finalReport!); }
        });

      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _streamBuffer = 'Error procesando archivo: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Swarm AI - Auditoria Predictiva', style: TextStyle(color: AppColors.gold)),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/roi_dashboard'),
            icon: const Icon(Icons.dashboard, color: AppColors.gold),
            label: const Text('ROI', style: TextStyle(color: AppColors.gold)),
          ),
        ],
        backgroundColor: AppColors.card,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildDropZone(),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: _buildResultsZone(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZone() {
    return InkWell(
      onTap: _isProcessing ? null : _pickAndProcess,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 64, color: _isProcessing ? AppColors.sub : AppColors.gold),
              const SizedBox(height: 16),
              Text(
                _fileName ?? 'Arrastra un pedimento XML (VUCEM)',
                style: const TextStyle(color: AppColors.text, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (_isProcessing) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: AppColors.gold),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsZone() {
    if (_streamBuffer.isEmpty && _finalReport == null) {
      return const Center(child: Text('Esperando documentos para analizar...', style: TextStyle(color: AppColors.sub)));
    }

    if (_isProcessing || _finalReport == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        ),
        child: SingleChildScrollView(
          child: Text(
            _streamBuffer,
            style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
          ),
        ),
      );
    }

    // Reporte Final
    final r = _finalReport!;
    Color rColor = r.riskLevel == 'high' ? AppColors.red : (r.riskLevel == 'medium' ? Colors.orange : AppColors.green);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rColor, width: 2),
      ),
      child: ListView(
        children: [
          Row(
            children: [
              Icon(r.riskLevel == 'high' ? Icons.warning_amber_rounded : Icons.check_circle, color: rColor, size: 32),
              const SizedBox(width: 12),
              Text('Riesgo: ${r.riskLevel.toUpperCase()}', style: TextStyle(color: rColor, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Multa Potencial Evitada: \$${r.potentialFinesUSD.toStringAsFixed(2)} USD', style: const TextStyle(color: AppColors.gold, fontSize: 18)),
          const SizedBox(height: 16),
          const Text('Resumen:', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          Text(r.summary, style: const TextStyle(color: AppColors.text)),
          const SizedBox(height: 16),
          if (r.discrepancies.isNotEmpty) ...[
            const Text('Discrepancias:', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
            ...r.discrepancies.map((d) => Text('• $d', style: const TextStyle(color: AppColors.red))),
            const SizedBox(height: 16),
          ],
          if (r.semanticAnomalies.isNotEmpty) ...[
            const Text('Anomalias Semanticas:', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
            ...r.semanticAnomalies.map((a) => Text('• $a', style: const TextStyle(color: Colors.orange))),
          ],
        ],
      ),
    );
  }

  Future<void> _logAiMetrics(AuditReport report) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    try {
      await FirebaseFirestore.instance.collection('ai_metrics').add({
        'userId': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'riskLevel': report.riskLevel,
        'potentialFinesUSD': report.potentialFinesUSD,
        'summary': report.summary,
      });
    } catch (e) {
      debugPrint('Error logging AI telemetry: $e');
    }
  }
}
