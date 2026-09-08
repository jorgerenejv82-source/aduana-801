import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LoadOptimizerScreen extends StatefulWidget {
  const LoadOptimizerScreen({super.key});
  @override
  State<LoadOptimizerScreen> createState() => _LoadOptimizerScreenState();
}

class _LoadOptimizerScreenState extends State<LoadOptimizerScreen> with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Optimizador de Carga',
          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Parámetros de Optimización', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      labelText: 'Dimensiones Caja (cm)',
                      labelStyle: const TextStyle(color: AppColors.sub),
                      filled: true,
                      fillColor: AppColors.bg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      labelText: 'Tipo de Contenedor',
                      labelStyle: const TextStyle(color: AppColors.sub),
                      filled: true,
                      fillColor: AppColors.bg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold)),
                    ),
                    items: const [
                      DropdownMenuItem(value: '20ft', child: Text('20ft')),
                      DropdownMenuItem(value: '40ft', child: Text('40ft')),
                      DropdownMenuItem(value: '40hc', child: Text('40HC')),
                    ],
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: 32),
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHovered = true),
                    onExit: (_) => setState(() => _isHovered = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isHovered ? const Color(0xFFE5B322) : AppColors.gold,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _isHovered ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))] : [],
                      ),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(12),
                        child: const Center(
                          child: Text('Calcular Optimización', style: TextStyle(color: AppColors.bg, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

