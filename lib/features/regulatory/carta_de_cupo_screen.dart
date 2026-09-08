import 'package:flutter/material.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class CartaDeCupoScreen extends StatefulWidget {
  const CartaDeCupoScreen({super.key});

  @override
  State<CartaDeCupoScreen> createState() => _CartaDeCupoScreenState();
}

class _CartaDeCupoScreenState extends State<CartaDeCupoScreen> {
  final _formKey = GlobalKey<FormState>();

  String _fraccion = '';
  String _paisOrigen = '';
  String _descripcion = '';

  String _aiResponse = '';

  void _consultAI() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Use variables to avoid lints
    debugPrint(
        'Consultando cupo para: $_fraccion, $_descripcion, $_paisOrigen');

    // Simulate AI response
    setState(() {
      _aiResponse =
          'Sí existe un cupo arancelario para esta mercancía bajo el TMEC. El arancel dentro del cupo es 0%, y fuera del cupo es 15%. Se solicita mediante la SE...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Gestión de Cartas de Cupo',
            style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.bg,
        iconTheme: const IconThemeData(color: AppColors.text),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        onPressed: () {
          // Dialog to add manual letter
        },
        label: const Text('Registrar Carta de Cupo',
            style: TextStyle(color: Colors.black)),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Consultor de Cupos IA',
                        style: TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Fracción Arancelaria', (v) => _fraccion = v ?? ''),
                    _buildTextField(
                        'País de origen', (v) => _paisOrigen = v ?? ''),
                    _buildTextField('Descripción del producto',
                        (v) => _descripcion = v ?? ''),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          minimumSize: const Size(double.infinity, 50)),
                      onPressed: _consultAI,
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      label: const Text('Consultar Cupo Disponible',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 32),
                    if (_aiResponse.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Text(_aiResponse,
                            style: const TextStyle(color: AppColors.text)),
                      )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.bg2,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mis Cartas de Cupo',
                      style: TextStyle(
                          color: AppColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  // Firestore StreamBuilder would go here. Showing mock data for now.
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildCartaCupoCard('CUP-2024-001',
                            'Pollo Entero Congelado', 500, 200, '0%', '20%'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, void Function(String?) onSaved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          labelStyle: const TextStyle(color: AppColors.sub),
        ),
        style: const TextStyle(color: AppColors.text),
        onSaved: onSaved,
        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
      ),
    );
  }

  Widget _buildCartaCupoCard(String numCarta, String producto, double asignado,
      double utilizado, String arancelIn, String arancelOut) {
    final double progress = asignado > 0 ? utilizado / asignado : 0;
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(numCarta,
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('Vigente',
                      style: TextStyle(color: AppColors.green, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(producto,
                style: const TextStyle(color: AppColors.text, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Dentro cupo: $arancelIn',
                    style: const TextStyle(
                        color: AppColors.green, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Text('Fuera cupo: $arancelOut',
                    style: const TextStyle(color: AppColors.red)),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              color: AppColors.blue,
            ),
            const SizedBox(height: 8),
            Text('Utilizado: $utilizado / $asignado tons',
                style: const TextStyle(color: AppColors.sub, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
