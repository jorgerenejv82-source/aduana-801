import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/supplier_model.dart';

class SupplierFormScreen extends StatefulWidget {
  const SupplierFormScreen({super.key});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  String _name = '';
  String _taxId = '';
  String _country = '';
  String _currency = 'USD';
  String _bankDetails = '';
  String _paymentTerms = '';

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final supplier = Supplier(
        id: '', // Firestore auto-id
        name: _name,
        taxId: _taxId,
        country: _country,
        currency: _currency,
        bankDetails: _bankDetails,
        paymentTerms: _paymentTerms,
      );

      await _firestore.collection('suppliers').add(supplier.toMap());

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Proveedor creado correctamente',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Error: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.red));
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
        title: const Text('Nuevo Proveedor',
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
                        label: 'Nombre o Razn Social',
                        onSaved: (v) => _name = v!),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Tax ID (RFC / EIN / VAT)',
                        onSaved: (v) => _taxId = v!),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Pas de Origen', onSaved: (v) => _country = v!),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: const InputDecoration(
                          labelText: 'Moneda Habitual',
                          labelStyle: TextStyle(color: AppColors.sub)),
                      dropdownColor: AppColors.card,
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                            value: 'USD',
                            child: Text('USD - Dlar Estadounidense')),
                        DropdownMenuItem(
                            value: 'EUR', child: Text('EUR - Euro')),
                        DropdownMenuItem(
                            value: 'CNY', child: Text('CNY - Yuan Chino')),
                        DropdownMenuItem(
                            value: 'MXN', child: Text('MXN - Peso Mexicano')),
                      ],
                      onChanged: (v) => setState(() => _currency = v!),
                      onSaved: (v) => _currency = v!,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Trminos de Pago (ej. 30% Adv / 70% BL)',
                        onSaved: (v) => _paymentTerms = v!),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Detalles Bancarios',
                        onSaved: (v) => _bankDetails = v!,
                        maxLines: 3),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSupplier,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Guardar Proveedor',
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
      int maxLines = 1}) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.sub),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.blue)),
      ),
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
      onSaved: onSaved,
    );
  }
}
