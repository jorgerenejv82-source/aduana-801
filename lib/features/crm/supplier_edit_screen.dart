import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/supplier_model.dart';

/// Pantalla de edición de proveedor existente.
/// Carga los datos desde Firestore al inicializar y guarda los cambios con update().
class SupplierEditScreen extends StatefulWidget {
  final String supplierId;
  const SupplierEditScreen({super.key, required this.supplierId});

  @override
  State<SupplierEditScreen> createState() => _SupplierEditScreenState();
}

class _SupplierEditScreenState extends State<SupplierEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  // Controladores para prellenar los campos
  final _nameCtrl = TextEditingController();
  final _taxIdCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();
  String _currency = 'USD';
  double _reliabilityScore = 10.0;

  @override
  void initState() {
    super.initState();
    _loadSupplier();
  }

  Future<void> _loadSupplier() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('suppliers')
          .doc(widget.supplierId)
          .get();
      if (!doc.exists) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final s = Supplier.fromMap(doc.data()!, doc.id);
      _nameCtrl.text = s.name;
      _taxIdCtrl.text = s.taxId;
      _countryCtrl.text = s.country;
      _bankCtrl.text = s.bankDetails;
      _termsCtrl.text = s.paymentTerms;
      _currency = s.currency.isNotEmpty ? s.currency : 'USD';
      _reliabilityScore = s.reliabilityScore;
    } catch (_) {
      // El error se mostrará al usuario vía el estado de _isLoading
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('suppliers')
          .doc(widget.supplierId)
          .update({
        'name': _nameCtrl.text.trim(),
        'taxId': _taxIdCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'currency': _currency,
        'bankDetails': _bankCtrl.text.trim(),
        'paymentTerms': _termsCtrl.text.trim(),
        'reliabilityScore': _reliabilityScore,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Proveedor actualizado.'),
          backgroundColor: AppColors.green,
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppColors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taxIdCtrl.dispose();
    _countryCtrl.dispose();
    _bankCtrl.dispose();
    _termsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gold),
            onPressed: () => context.pop()),
        title: const Text('Editar Proveedor',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: AppColors.blue, strokeWidth: 2)),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined, color: AppColors.blue),
              label: const Text('Guardar',
                  style: TextStyle(
                      color: AppColors.blue, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _field('Nombre o Razón Social', _nameCtrl),
                    const SizedBox(height: 16),
                    _field('Tax ID (RFC / EIN / VAT)', _taxIdCtrl),
                    const SizedBox(height: 16),
                    _field('País de Origen', _countryCtrl),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: const InputDecoration(
                        labelText: 'Moneda Habitual',
                        labelStyle: TextStyle(color: AppColors.sub),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.blue)),
                      ),
                      dropdownColor: AppColors.card,
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                            value: 'USD', child: Text('USD - Dólar')),
                        DropdownMenuItem(
                            value: 'EUR', child: Text('EUR - Euro')),
                        DropdownMenuItem(
                            value: 'CNY', child: Text('CNY - Yuan')),
                        DropdownMenuItem(
                            value: 'MXN', child: Text('MXN - Peso')),
                      ],
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                    const SizedBox(height: 16),
                    _field('Términos de Pago', _termsCtrl),
                    const SizedBox(height: 16),
                    _field('Detalles Bancarios', _bankCtrl, maxLines: 3),
                    const SizedBox(height: 24),
                    Text(
                        'Calificación de Confianza: ${_reliabilityScore.toStringAsFixed(1)} / 10.0',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Slider(
                      value: _reliabilityScore,
                      max: 10,
                      divisions: 20,
                      activeColor: AppColors.gold,
                      inactiveColor: AppColors.border,
                      onChanged: (v) => setState(() => _reliabilityScore = v),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Guardar Cambios',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.sub),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.blue)),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
    );
  }
}
