import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class NomCalendarScreen extends StatefulWidget {
  const NomCalendarScreen({super.key});

  @override
  State<NomCalendarScreen> createState() => _NomCalendarScreenState();
}

class _NomCalendarScreenState extends State<NomCalendarScreen> {
  void _addNom() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final nomCtrl = TextEditingController();
        final descCtrl = TextEditingController();
        final prodCtrl = TextEditingController();
        final authCtrl = TextEditingController();
        final startCtrl = TextEditingController();
        final endCtrl = TextEditingController();

        return AlertDialog(
          title: const Text('Agregar NOM/Permiso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nomCtrl,
                    decoration: const InputDecoration(labelText: 'NOM')),
                TextField(
                    controller: descCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Descripción')),
                TextField(
                    controller: prodCtrl,
                    decoration: const InputDecoration(labelText: 'Producto')),
                TextField(
                    controller: authCtrl,
                    decoration: const InputDecoration(labelText: 'Autoridad')),
                TextField(
                    controller: startCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Fecha Emisión (YYYY-MM-DD)')),
                TextField(
                    controller: endCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Fecha Vigencia (YYYY-MM-DD)')),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('nom_vigencias').add({
                  'uid': 'user_id', // mock
                  'nom': nomCtrl.text,
                  'descripcion': descCtrl.text,
                  'producto': prodCtrl.text,
                  'autoridad': authCtrl.text,
                  'fechaEmision': startCtrl.text,
                  'fechaVigencia': endCtrl.text,
                  'renovacionSolicitada': false,
                  'notas': '',
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _consultarIA(String nom, String autoridad) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Consultar Requisitos: $nom'),
          content: FutureBuilder(
            future: Future.delayed(
                const Duration(seconds: 2),
                () =>
                    'Análisis de IA: 1) Proceso de renovación... 2) Documentos requeridos... 3) Tiempo promedio: 15 días. 4) Costo aprox: \$5,000 MXN. 5) Consecuencias: Multas y retención.'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.red, size: 32),
                      const SizedBox(height: 8),
                      const Text('Error al cargar NOMs',
                          style: TextStyle(color: AppColors.sub)),
                      TextButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Reintentar',
                            style: TextStyle(color: AppColors.gold)),
                      ),
                    ],
                  ),
                );
              }
              return Text(snapshot.data as String);
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar')),
          ],
        );
      },
    );
  }

  @override
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vigencias NOM'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNom,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('nom_vigencias')
            .orderBy('fechaVigencia')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.red, size: 32),
                  const SizedBox(height: 8),
                  const Text('Error al cargar NOMs',
                      style: TextStyle(color: AppColors.sub)),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Reintentar',
                        style: TextStyle(color: AppColors.gold)),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final today = DateTime.now();
          int vigentes = 0;
          int porVencer = 0;
          int vencidos = 0;
          int renovaciones = 0;

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final vigencia =
                DateTime.tryParse((data['fechaVigencia'] as String?) ?? '');
            if (vigencia != null) {
              final days = vigencia.difference(today).inDays;
              if (days < 0) {
                vencidos++;
              } else if (days <= 90) {
                porVencer++;
              } else {
                vigentes++;
              }
            }
            if (data['renovacionSolicitada'] == true) {
              renovaciones++;
            }
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Vigentes: $vigentes 🟢'),
                    Text('Por Vencer: $porVencer 🟡'),
                    Text('Vencidos: $vencidos 🔴'),
                    Text('Renovaciones: $renovaciones 🔄'),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    await Future<void>.delayed(
                        const Duration(milliseconds: 800));
                  },
                  color: AppColors.gold,
                  backgroundColor: AppColors.card,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;
                      final vigencia = DateTime.tryParse(
                              (data['fechaVigencia'] as String?) ?? '') ??
                          DateTime.now();
                      final days = vigencia.difference(today).inDays;

                      Color cardColor;
                      if (days < 0) {
                        cardColor = Colors.red.shade100;
                      } else if (days <= 90) {
                        cardColor = Colors.amber.shade100;
                      } else {
                        cardColor = Colors.green.shade100;
                      }

                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((data['nom'] as String?) ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(
                                  '${data['descripcion']} - ${data['producto']}'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child:
                                    Text((data['autoridad'] as String?) ?? ''),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                days < 0
                                    ? 'Venció hace ${days.abs()} días'
                                    : 'Vence en $days días',
                                style: TextStyle(
                                    color: days < 0 ? Colors.red : Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              SwitchListTile(
                                title: const Text('Renovación solicitada'),
                                value:
                                    (data['renovacionSolicitada'] as bool?) ??
                                        false,
                                onChanged: (val) {
                                  FirebaseFirestore.instance
                                      .collection('nom_vigencias')
                                      .doc(docId)
                                      .update({'renovacionSolicitada': val});
                                },
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _consultarIA(
                                    (data['nom'] as String?) ?? '',
                                    (data['autoridad'] as String?) ?? ''),
                                icon: const Icon(Icons.smart_toy),
                                label: const Text(
                                    'Consultar Requisitos de Renovación'),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
