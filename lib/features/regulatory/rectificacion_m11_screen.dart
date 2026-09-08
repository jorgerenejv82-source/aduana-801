import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'models/pedimento_models.dart';

class RectificacionM11Screen extends StatefulWidget {
  const RectificacionM11Screen({super.key});

  @override
  State<RectificacionM11Screen> createState() => _RectificacionM11ScreenState();
}

class _RectificacionM11ScreenState extends State<RectificacionM11Screen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _justificacionController =
      TextEditingController();
  final TextEditingController _nuevoValorController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  Pedimento? _pedimentoActual;
  String _campoARectificar = 'valorAduana';

  @override
  void dispose() {
    _searchController.dispose();
    _justificacionController.dispose();
    _nuevoValorController.dispose();
    super.dispose();
  }

  Future<void> _buscarPedimento() async {
    final term = _searchController.text.trim();
    if (term.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _pedimentoActual = null;
    });

    try {
      final query = await _firestore
          .collection('pedimentos')
          .where('numero', isEqualTo: term)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(
            () => _error = 'No se encontr ningn pedimento con el nmero: $term');
      } else {
        setState(() {
          _pedimentoActual =
              Pedimento.fromMap(query.docs.first.data(), query.docs.first.id);
        });
      }
    } catch (e) {
      setState(() => _error = 'Error de conexin: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _ejecutarRectificacion() async {
    if (_pedimentoActual == null) return;
    if (_nuevoValorController.text.trim().isEmpty ||
        _justificacionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completar todos los campos')));
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rect = Rectificacion(
        id: '', // Firestore will auto-generate
        pedimentoOriginalId: _pedimentoActual!.id,
        campoModificado: _campoARectificar,
        valorAnterior: _campoARectificar == 'valorAduana'
            ? _pedimentoActual!.valorAduana.toString()
            : _pedimentoActual!.rfcImportador,
        valorNuevo: _nuevoValorController.text.trim(),
        fechaRectificacion: DateTime.now(),
        justificacion: _justificacionController.text.trim(),
      );

      // Transaccin real en Firestore
      await _firestore.runTransaction((transaction) async {
        // 1. Guardar log de rectificacin
        final rectRef = _firestore.collection('rectificaciones').doc();
        transaction.set(rectRef, rect.toMap());

        // 2. Actualizar el pedimento original
        final pedRef =
            _firestore.collection('pedimentos').doc(_pedimentoActual!.id);
        final Map<String, dynamic> updateData = {};
        if (_campoARectificar == 'valorAduana') {
          updateData['valorAduana'] =
              double.tryParse(_nuevoValorController.text) ?? 0.0;
        } else {
          updateData['rfcImportador'] = _nuevoValorController.text;
        }
        transaction.update(pedRef, updateData);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('M-11 procesado correctamente',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.green));
        context.pop(); // Regresar
      }
    } catch (e) {
      setState(() => _error = 'Error al procesar M-11: $e');
    } finally {
      setState(() => _isLoading = false);
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
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => context.pop(),
        ),
        title: const Text('Rectificacin (M-11)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.gold))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBuscador(),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!,
                          style: const TextStyle(color: AppColors.red)),
                    ],
                    if (_pedimentoActual != null) ...[
                      const SizedBox(height: 32),
                      _buildResumenPedimento(),
                      const SizedBox(height: 32),
                      _buildFormularioRectificacion(),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBuscador() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Buscar Pedimento Pagado',
            style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nmero de pedimento (ej. 1234567)',
                  hintStyle: const TextStyle(color: AppColors.sub),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.gold)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _buscarPedimento,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20)),
              child: const Icon(Icons.search, color: Colors.white),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildResumenPedimento() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pedimento: ${_pedimentoActual!.pedimentoCompleto}',
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('PAGADO',
                      style: TextStyle(
                          color: AppColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
            ],
          ),
          const Divider(color: AppColors.border, height: 32),
          Text('RFC Importador: ${_pedimentoActual!.rfcImportador}',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text('Operacin: ${_pedimentoActual!.tipoOperacion}',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
              'Valor Aduana: \$${_pedimentoActual!.valorAduana.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildFormularioRectificacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Datos a Rectificar',
            style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _campoARectificar,
          dropdownColor: AppColors.card,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Campo',
            labelStyle: const TextStyle(color: AppColors.sub),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border)),
          ),
          items: const [
            DropdownMenuItem(
                value: 'valorAduana', child: Text('Valor en Aduana')),
            DropdownMenuItem(
                value: 'rfcImportador', child: Text('RFC Importador')),
          ],
          onChanged: (v) => setState(() => _campoARectificar = v!),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nuevoValorController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nuevo Valor',
            labelStyle: const TextStyle(color: AppColors.sub),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _justificacionController,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Justificacin Legal',
            labelStyle: const TextStyle(color: AppColors.sub),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _ejecutarRectificacion,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('TRANSMITIR M-11',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }
}
