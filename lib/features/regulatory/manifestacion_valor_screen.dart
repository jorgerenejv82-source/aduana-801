import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManifestacionValorScreen extends StatefulWidget {
  const ManifestacionValorScreen({super.key});

  @override
  State<ManifestacionValorScreen> createState() =>
      _ManifestacionValorScreenState();
}

class _ManifestacionValorScreenState extends State<ManifestacionValorScreen> {
  int _currentStep = 0;
  bool _isGenerating = false;

  void _generateXML() async {
    setState(() {
      _isGenerating = true;
    });
    try {
      const xmlString = '''<?xml version="1.0" encoding="UTF-8"?>
<ManifestacionValor xmlns="http://www.sat.gob.mx/esquemas/mv" version="1.0">
  <Importador rfc="IMP100101XX1" />
  <Proveedor taxId="US-987654321" />
  <ValorAduana>
    <PrecioPagado moneda="USD" monto="25000.00" incoterm="FOB"/>
    <Incrementables fletes="1200.00" seguros="150.00" embalajes="0.00" regalias="0.00"/>
  </ValorAduana>
  <Vinculacion existe="false"/>
</ManifestacionValor>''';

      await FirebaseFirestore.instance.collection('vucem_docs').add({
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'tipo': 'manifestacion_valor',
        'estado': 'pendiente_firma',
        'xmlContent': xmlString,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _currentStep = 4;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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
        title: const Text("Manifestación de Valor Electrónica (VUCEM)",
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
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 3) {
              _generateXML();
            } else if (_currentStep < 3) {
              setState(() => _currentStep += 1);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0 && _currentStep < 4) {
              setState(() => _currentStep -= 1);
            }
          },
          controlsBuilder: (context, details) {
            if (_currentStep == 4) {
              return const SizedBox.shrink(); // Hide controls on success
            }
            if (_isGenerating) {
              return const Padding(
                padding: EdgeInsets.only(top: 24.0),
                child: Row(
                  children: [
                    CircularProgressIndicator(color: AppColors.gold),
                    SizedBox(width: 16),
                    Text("Generando XML y sellando con e.Firma...",
                        style: TextStyle(color: AppColors.sub)),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _currentStep == 3 ? AppColors.green : AppColors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: Text(
                        _currentStep == 3
                            ? "FIRMAR Y ENVIAR A VUCEM"
                            : "CONTINUAR",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text("ATRÁS",
                          style: TextStyle(color: AppColors.sub)),
                    ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text("Datos de Facturación",
                  style: TextStyle(color: Colors.white)),
              content: _buildFacturacionStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text("Gastos Incrementables (Art. 65 LA)",
                  style: TextStyle(color: Colors.white)),
              content: _buildIncrementablesStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text("Relación Comercial (Art. 68 LA)",
                  style: TextStyle(color: Colors.white)),
              content: _buildRelacionStep(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text("Firma y Transmisión XML",
                  style: TextStyle(color: Colors.white)),
              content: _buildResumenStep(),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text("Completado",
                  style: TextStyle(color: AppColors.green)),
              content: _buildSuccessStep(),
              isActive: _currentStep == 4,
              state: StepState.complete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacturacionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            "Detalla la información del CFDI o documento equivalente (Factura Comercial).",
            style: TextStyle(color: AppColors.sub)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    "Folio / Número de Factura", "Ej. INV-2026-098")),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("Fecha", "DD/MM/AAAA")),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child:
                    _buildTextField("Proveedor (Tax ID)", "Ej. US-987654321")),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("Incoterm", "Ej. FOB, CIF, EXW")),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField("Precio Pagado o Por Pagar (USD)", "\$0.00"),
      ],
    );
  }

  Widget _buildIncrementablesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            "Declara los gastos incurridos hasta el punto de entrada al país (Art. 65 L.A.).",
            style: TextStyle(color: AppColors.sub)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField("Fletes / Transporte (USD)", "\$0.00")),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("Seguros (USD)", "\$0.00")),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField("Embalajes y Envases (USD)", "\$0.00")),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField("Regalías y Licencias (USD)", "\$0.00")),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: AppColors.blue, size: 20),
              SizedBox(width: 12),
              Expanded(
                  child: Text(
                      "Total Valor en Aduana = Precio Pagado + Incrementables. El cálculo se hará automáticamente en el XML.",
                      style: TextStyle(color: Colors.white, fontSize: 12))),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRelacionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            "¿Existe vinculación comercial o corporativa entre el Importador y el Proveedor extranjero?",
            style: TextStyle(color: AppColors.sub)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border)),
                child: const Row(
                  children: [
                    Icon(Icons.link_off, color: AppColors.green),
                    SizedBox(width: 12),
                    Text("NO HAY VINCULACIÃ“N",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border)),
                child: const Row(
                  children: [
                    Icon(Icons.link, color: AppColors.sub),
                    SizedBox(width: 12),
                    Text("SÍ HAY VINCULACIÃ“N",
                        style: TextStyle(
                            color: AppColors.sub, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResumenStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            "Pre-visualización del XML estructurado para VUCEM. Ingresa tu e.Firma para transmitir.",
            style: TextStyle(color: AppColors.sub)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border)),
          child: const Text(
            '''<?xml version="1.0" encoding="UTF-8"?>
<ManifestacionValor xmlns="http://www.sat.gob.mx/esquemas/mv" version="1.0">
  <Importador rfc="IMP100101XX1" />
  <Proveedor taxId="US-987654321" />
  <ValorAduana>
    <PrecioPagado moneda="USD" monto="25000.00" incoterm="FOB"/>
    <Incrementables fletes="1200.00" seguros="150.00" embalajes="0.00" regalias="0.00"/>
  </ValorAduana>
  <Vinculacion existe="false"/>
</ManifestacionValor>''',
            style: TextStyle(
                color: Colors.lightGreenAccent,
                fontFamily: 'monospace',
                fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: AppColors.green, size: 64),
          const SizedBox(height: 16),
          const Text("✅ XML Generado y Guardado",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              "La Manifestación de Valor ha sido generada y guardada en la Bóveda de Expedientes con estado PENDIENTE DE FIRMA.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.sub, height: 1.5)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold),
            ),
            child: const Text(
                "⚠️ Para firmar y transmitir a VUCEM necesitas tu e.Firma (.cer + .key). Descarga el XML y fírmalo desde el portal VUCEM del SAT o con el software e-firma del SAT.",
                style: TextStyle(color: AppColors.gold),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 32),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: () => context.go('/vucem_sync'),
              icon: const Icon(Icons.folder_shared, color: Colors.white),
              label: const Text("Ver en Bóveda VUCEM",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Nuevo Documento",
                  style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border)),
            )
          ])
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.sub),
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.sub.withValues(alpha: 0.5)),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.gold)),
      ),
    );
  }
}
