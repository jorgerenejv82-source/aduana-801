import 'package:flutter/material.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class PermisosPreviosScreen extends StatefulWidget {
  const PermisosPreviosScreen({super.key});

  @override
  State<PermisosPreviosScreen> createState() => _PermisosPreviosScreenState();
}

class _PermisosPreviosScreenState extends State<PermisosPreviosScreen> {
  final _formKey = GlobalKey<FormState>();

  String _fraccion = '';
  String _descripcion = '';
  String _paisOrigen = '';

  List<Map<String, dynamic>> _aiResults = [];

  void _analyzePermits() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Use variables to avoid lints
    debugPrint(
        'Consultando permisos para: $_fraccion, $_descripcion, $_paisOrigen');

    // Simulate AI response
    setState(() {
      _aiResults = [
        {
          "nombre": "Aviso Sanitario de Importación",
          "autoridad": "COFEPRIS",
          "requerido": true,
          "costo": 5000,
          "diasTramite": 15,
          "portal": "https://www.gob.mx/cofepris",
          "notas": "Requiere certificado de libre venta"
        },
        {
          "nombre": "Permiso Previo de Importación",
          "autoridad": "SE",
          "requerido": true,
          "costo": 0,
          "diasTramite": 5,
          "portal": "https://www.snice.gob.mx",
          "notas": "Cupo máximo 1000 ton"
        }
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Identificador de Permisos Previos',
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
          // Dialog to add manual permit
        },
        label: const Text('Agregar Permiso',
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
                    const Text('Consultor IA',
                        style: TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Fracción Arancelaria', (v) => _fraccion = v ?? ''),
                    _buildTextField('Descripción de la mercancía',
                        (v) => _descripcion = v ?? ''),
                    _buildTextField(
                        'País de origen', (v) => _paisOrigen = v ?? ''),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          minimumSize: const Size(double.infinity, 50)),
                      onPressed: _analyzePermits,
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      label: const Text('Identificar Permisos con IA',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 32),
                    if (_aiResults.isNotEmpty) ...[
                      const Text('Resultados de IA',
                          style: TextStyle(
                              color: AppColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ..._aiResults.map((r) => _buildAiResultCard(r)),
                    ]
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
                  const Text('Mis Permisos Activos',
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
                        _buildPermitCard('Aviso Sanitario - Alimentos',
                            'COFEPRIS', 'Vigente', AppColors.green),
                        _buildPermitCard('Permiso Previo Textil', 'SE',
                            'Por Vencer', AppColors.gold),
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

  Widget _buildAiResultCard(Map<String, dynamic> data) {
    Color cardColor = AppColors.card;
    if (data['autoridad'] == 'COFEPRIS') {
      cardColor = AppColors.red.withValues(alpha: 0.1);
    } else if (data['autoridad'] == 'SENASICA') {
      cardColor = AppColors.green.withValues(alpha: 0.1);
    } else if (data['autoridad'] == 'SE') {
      cardColor = AppColors.blue.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(data['nombre'].toString(),
                      style: const TextStyle(
                          color: AppColors.text, fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4)),
                child: Text(data['autoridad'].toString(),
                    style: const TextStyle(color: AppColors.sub, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
              'Costo est.: \$${data['costo']} MXN | Plazo: ${data['diasTramite']} días',
              style: const TextStyle(color: AppColors.sub)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => launchUrl(Uri.parse(data['portal'].toString())),
            child: const Row(
              children: [
                Icon(Icons.link, color: AppColors.blue, size: 16),
                SizedBox(width: 4),
                Text('Portal de Trámite',
                    style: TextStyle(
                        color: AppColors.blue,
                        decoration: TextDecoration.underline)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPermitCard(
      String title, String auth, String status, Color statusColor) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(
                color: AppColors.text, fontWeight: FontWeight.bold)),
        subtitle: Text('Autoridad: $auth',
            style: const TextStyle(color: AppColors.sub)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16)),
          child: Text(status,
              style:
                  TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
