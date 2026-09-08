import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/po_model.dart';

class PoFormScreen extends StatefulWidget {
  const PoFormScreen({super.key});

  @override
  State<PoFormScreen> createState() => _PoFormScreenState();
}

class _PoFormScreenState extends State<PoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  String _poNumber = '';
  String _supplierName = '';
  String _incoterm = 'FOB';
  String _currency = 'USD';
  double _totalAmount = 0.0;

  String _fraccionArancelaria = '';
  String _paisOrigen = '';
  int _leadTimeDias = 30;
  bool _tieneCertOrigen = false;
  double _precioUnitario = 0.0;
  int _cantidadUnidades = 0;
  String _descripcionMercancia = '';
  double _costoFleteEstimado = 0.0;
  String _unidadMedida = 'PZA';

  Future<void> _savePo() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final po = PurchaseOrder(
        id: '',
        poNumber: _poNumber,
        supplierName: _supplierName,
        incoterm: _incoterm,
        currency: _currency,
        totalAmount: _totalAmount,
        status: 'PENDING',
        issueDate: DateTime.now(),
        expectedDeliveryDate: DateTime.now().add(const Duration(days: 30)),
        fraccionArancelaria: _fraccionArancelaria,
        paisOrigen: _paisOrigen,
        leadTimeDias: _leadTimeDias,
        tieneCertOrigen: _tieneCertOrigen,
        precioUnitario: _precioUnitario,
        cantidadUnidades: _cantidadUnidades,
        descripcionMercancia: _descripcionMercancia,
        costoFleteEstimado: _costoFleteEstimado,
        unidadMedida: _unidadMedida,
      );

      await _firestore.collection('purchase_orders').add(po.toMap());

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('PO creada correctamente'),
            backgroundColor: AppColors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'), backgroundColor: AppColors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text('Nueva Orden de Compra',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                        label: 'Número de PO (ej. PO-2026-001)',
                        onSaved: (v) => _poNumber = v!),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Proveedor', onSaved: (v) => _supplierName = v!),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _incoterm,
                            decoration: const InputDecoration(
                                labelText: 'Incoterm',
                                labelStyle: TextStyle(color: AppColors.sub)),
                            dropdownColor: AppColors.card,
                            style: const TextStyle(color: Colors.white),
                            items: ['EXW', 'FOB', 'CIF', 'DDP', 'FCA', 'DAP']
                                .map((i) =>
                                    DropdownMenuItem(value: i, child: Text(i)))
                                .toList(),
                            onChanged: (v) => setState(() => _incoterm = v!),
                            onSaved: (v) => _incoterm = v!,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _currency,
                            decoration: const InputDecoration(
                                labelText: 'Moneda',
                                labelStyle: TextStyle(color: AppColors.sub)),
                            dropdownColor: AppColors.card,
                            style: const TextStyle(color: Colors.white),
                            items: ['USD', 'EUR', 'CNY', 'MXN']
                                .map((i) =>
                                    DropdownMenuItem(value: i, child: Text(i)))
                                .toList(),
                            onChanged: (v) => setState(() => _currency = v!),
                            onSaved: (v) => _currency = v!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Monto Total',
                      isNumeric: true,
                      onSaved: (v) =>
                          _totalAmount = double.tryParse(v ?? '0') ?? 0.0,
                    ),
                    const SizedBox(height: 32),
                    const Text('Datos Aduanales',
                        style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Fracción Arancelaria (8 dígitos)',
                        onSaved: (v) => _fraccionArancelaria = v!),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'País de Origen',
                        onSaved: (v) => _paisOrigen = v!),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Descripción de Mercancía',
                        onSaved: (v) => _descripcionMercancia = v!),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            label: 'Precio Unitario FOB (USD)',
                            isNumeric: true,
                            onSaved: (v) => _precioUnitario =
                                double.tryParse(v ?? '0') ?? 0.0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _unidadMedida,
                            decoration: const InputDecoration(
                                labelText: 'Unidad',
                                labelStyle: TextStyle(color: AppColors.sub)),
                            dropdownColor: AppColors.card,
                            style: const TextStyle(color: Colors.white),
                            items: ['PZA', 'KG', 'M2', 'LT', 'PAR']
                                .map((i) =>
                                    DropdownMenuItem(value: i, child: Text(i)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _unidadMedida = v!),
                            onSaved: (v) => _unidadMedida = v!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Cantidad de Unidades',
                      isNumeric: true,
                      onSaved: (v) =>
                          _cantidadUnidades = int.tryParse(v ?? '0') ?? 0,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Lead Time (días)',
                      isNumeric: true,
                      onSaved: (v) =>
                          _leadTimeDias = int.tryParse(v ?? '30') ?? 30,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('✅ Proveedor tiene C.O. TMEC/USMCA',
                          style: TextStyle(color: Colors.white)),
                      value: _tieneCertOrigen,
                      onChanged: (val) =>
                          setState(() => _tieneCertOrigen = val),
                      activeTrackColor: AppColors.gold,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Flete Estimado (USD)',
                      isNumeric: true,
                      onSaved: (v) => _costoFleteEstimado =
                          double.tryParse(v ?? '0') ?? 0.0,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _savePo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Generar Orden de Compra',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required void Function(String?) onSaved,
      bool isNumeric = false}) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.sub),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.blue)),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
      onSaved: onSaved,
    );
  }
}
