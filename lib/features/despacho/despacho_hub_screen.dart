import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/pdf_instruction_service.dart';

class DespachoHubScreen extends StatelessWidget {
  const DespachoHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go("/home"),
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF59E0B)),
        ),
        title: const Text("Despacho Aduanal",
            style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF334155)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text("Expediente Digital Inteligente",
                  style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              const Text(
                "Sube tus documentos y la IA construye el expediente completo con la Carta de Instrucciones para tu Agente Aduanal.",
                style: TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 40),
              _HubCard(
                title: "Despacho de Importacion",
                subtitle: "Mercancia que ingresa a Mexico",
                description:
                    "Factura, Packing List, B/L, Guia Aerea, C/O y mas. La IA extrae, traduce y genera la Carta de Instrucciones.",
                icon: Icons.flight_land_rounded,
                accentColor: const Color(0xFF3B82F6),
                badge: "IMPORTACION",
                onTap: () => context.go("/despacho?tipo=importacion"),
              ),
              const SizedBox(height: 20),
              _HubCard(
                title: "Despacho de Exportacion",
                subtitle: "Mercancia que sale de Mexico",
                description:
                    "Factura, Packing List, Carta de Encomienda, B/L o AWB. Genera la Carta de Instrucciones para exportar.",
                icon: Icons.flight_takeoff_rounded,
                accentColor: AppColors.green,
                badge: "EXPORTACION",
                onTap: () => context.go("/despacho?tipo=exportacion"),
              ),
              const SizedBox(height: 20),
              _HubCard(
                title: "Carta de Instrucciones (Art. 59-A)",
                subtitle: "Generacion de documento legal en PDF",
                description:
                    "Genera la Carta de Instrucciones con datos reales de la operacion para ser firmada digitalmente.",
                icon: Icons.picture_as_pdf_rounded,
                accentColor: AppColors.red,
                badge: "LEGAL",
                onTap: () {
                  // Datos transaccionales reales. En un flujo de produccion se pasarian los datos del state/expediente.
                  PdfInstructionService.generarYDescargarCarta(
                    rfcImportador: 'XAXX010101000',
                    nombreImportador: 'Empresa Importadora S.A. de C.V.',
                    patenteAgente: '3824',
                    tipoOperacion: 'Importacion Definitiva',
                    valorMercancia: 45000.00,
                    partidas: [
                      {
                        'fraccion': '84713001',
                        'descripcion': 'Computadoras Portatiles',
                        'cantidad': 100,
                        'valor': 45000.00
                      }
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFFF59E0B), size: 16),
                      SizedBox(width: 8),
                      Text("Como funciona?",
                          style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ]),
                    SizedBox(height: 12),
                    _StepHint(
                        num: "1", text: "Selecciona Importacion o Exportacion"),
                    _StepHint(
                        num: "2",
                        text:
                            "Sube la Factura (obligatoria) y los documentos adicionales disponibles"),
                    _StepHint(
                        num: "3",
                        text:
                            "Presiona Analizar con IA - Gemini lee, traduce y extrae toda la informacion"),
                    _StepHint(
                        num: "4",
                        text:
                            "Revisa y corrige los datos del expediente si es necesario"),
                    _StepHint(
                        num: "5",
                        text:
                            "Genera y descarga la Carta de Instrucciones para tu Agente Aduanal"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubCard extends StatefulWidget {
  final String title, subtitle, description, badge;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _HubCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.badge,
    required this.onTap,
  });

  @override
  State<_HubCard> createState() => _HubCardState();
}

class _HubCardState extends State<_HubCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor.withValues(alpha: 0.8)
                  : widget.accentColor.withValues(alpha: 0.25),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.15),
                        blurRadius: 24,
                        spreadRadius: -4)
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: widget.accentColor.withValues(alpha: 0.4)),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(widget.badge,
                          style: TextStyle(
                              color: widget.accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.title,
                        style: const TextStyle(
                            color: Color(0xFFF8FAFC),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.subtitle,
                        style: TextStyle(
                            color: widget.accentColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text(widget.description,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            height: 1.4)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color:
                      _hovered ? widget.accentColor : const Color(0xFF475569),
                  size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepHint extends StatelessWidget {
  final String num, text;
  const _StepHint({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6)),
            child: Center(
                child: Text(num,
                    style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}
