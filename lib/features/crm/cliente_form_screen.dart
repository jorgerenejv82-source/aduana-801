import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ClienteFormScreen extends StatefulWidget {
  final String? clienteId;

  const ClienteFormScreen({super.key, this.clienteId});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _rfcController = TextEditingController();
  final _razonSocialController = TextEditingController();
  final _numImmexController = TextEditingController();
  final _contactoNombreController = TextEditingController();
  final _contactoEmailController = TextEditingController();
  final _contactoTelController = TextEditingController();
  final _emailNotificacionesController = TextEditingController();
  final _diasCreditoController = TextEditingController();
  final _limiteCreditoController = TextEditingController();

  String _tipo = 'importador';
  bool _hasImmex = false;
  bool _hasOea = false;
  List<String> _regimenesFrecuentes = [];
  bool _isLoading = false;

  bool _enPadron = false;
  bool _enPadronSectorial = false;
  List<String> _sectoresEspecificos = [];
  String _rfcStatus = 'No Verificado';
  bool _rfcListaNegra = false;
  final _rfcListaNegraFechaController = TextEditingController();
  final _numPatenteController = TextEditingController();

  String _immexTipo = 'No Aplica';
  final _immexVigenciaController = TextEditingController();

  String _aduana = 'Nuevo Laredo';
  String _regimenFrecuenteOperativo = 'A1';

  final List<String> _availableSectores = [
    'Acero',
    'Textil',
    'Calzado',
    'Químicos',
    'Madera',
    'Electrónicos'
  ];
  final List<String> _rfcStatuses = [
    'Activo',
    'Suspendido',
    'Cancelado',
    'No Verificado'
  ];
  final List<String> _immexTipos = [
    'Maquila',
    'Manufacturera',
    'Albergue',
    'Controladora',
    'No Aplica'
  ];
  final List<String> _aduanas = [
    'Nuevo Laredo',
    'Monterrey',
    'Lázaro Cárdenas',
    'Manzanillo',
    'Ciudad Juárez',
    'Tijuana',
    'Veracruz',
    'AICM',
    'Santa Teresa',
    'Colombia',
    'Otra'
  ];
  final List<String> _regimenesOperativos = ['A1', 'A6', 'IN', 'CT', 'V1'];

  final List<String> _availableRegimenes = [
    'IMD',
    'EXD',
    'ITR',
    'ETR',
    'A1',
    'A6',
    'IN',
    'CT',
    'V1'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.clienteId != null) {
      _loadCliente();
    } else {
      _diasCreditoController.text = '30';
      _limiteCreditoController.text = '0.0';
    }
  }

  Future<void> _loadCliente() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('clientes')
          .doc(widget.clienteId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _rfcController.text = (data['rfc'] as String?) ?? '';
        _razonSocialController.text = (data['razonSocial'] as String?) ?? '';
        _tipo = (data['tipo'] as String?) ?? 'importador';
        _hasImmex = (data['hasImmex'] as bool?) ?? false;
        _numImmexController.text = (data['numImmex'] as String?) ?? '';
        _enPadron = (data['enPadronImportadores'] as bool?) ?? false;
        _enPadronSectorial = (data['enPadronSectorial'] as bool?) ?? false;
        _sectoresEspecificos = List<String>.from(
            (data['sectoresEspecificos'] as Iterable<dynamic>?) ?? <dynamic>[]);
        _rfcStatus = (data['rfcStatus'] as String?) ?? 'No Verificado';
        _rfcListaNegra = (data['rfcListaNegra'] as bool?) ?? false;
        _rfcListaNegraFechaController.text =
            (data['rfcListaNegraFecha'] as String?) ?? '';
        _numPatenteController.text = (data['numPatente'] as String?) ?? '';
        _immexTipo = (data['immexTipo'] as String?) ?? 'No Aplica';
        _immexVigenciaController.text =
            (data['immexVigencia'] as String?) ?? '';
        _aduana = (data['aduana'] as String?) ?? 'Nuevo Laredo';
        _regimenFrecuenteOperativo =
            (data['regimenFrecuente'] as String?) ?? 'A1';
        _hasOea = (data['hasOea'] as bool?) ?? false;
        _regimenesFrecuentes = List<String>.from(
            (data['regimenesFrecuentes'] as Iterable<dynamic>?) ?? <dynamic>[]);
        _contactoNombreController.text =
            (data['contactoNombre'] as String?) ?? '';
        _contactoEmailController.text =
            (data['contactoEmail'] as String?) ?? '';
        _contactoTelController.text = (data['contactoTel'] as String?) ?? '';
        _emailNotificacionesController.text =
            (data['emailNotificaciones'] as String?) ?? '';
        _diasCreditoController.text =
            ((data['diasCredito'] as num?) ?? 30).toString();
        _limiteCreditoController.text =
            ((data['limiteCredito'] as num?) ?? 0.0).toString();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al cargar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _rfcController.dispose();
    _razonSocialController.dispose();
    _numImmexController.dispose();
    _contactoNombreController.dispose();
    _contactoEmailController.dispose();
    _contactoTelController.dispose();
    _emailNotificacionesController.dispose();
    _diasCreditoController.dispose();
    _limiteCreditoController.dispose();
    _rfcListaNegraFechaController.dispose();
    _numPatenteController.dispose();
    _immexVigenciaController.dispose();
    super.dispose();
  }

  Future<void> _saveCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final data = {
        'uid': uid,
        'rfc': _rfcController.text.toUpperCase(),
        'razonSocial': _razonSocialController.text,
        'tipo': _tipo,
        'hasImmex': _hasImmex,
        'numImmex': _hasImmex ? _numImmexController.text : '',
        'hasOea': _hasOea,
        'regimenesFrecuentes': _regimenesFrecuentes,
        'contactoNombre': _contactoNombreController.text,
        'contactoEmail': _contactoEmailController.text,
        'contactoTel': _contactoTelController.text,
        'emailNotificaciones': _emailNotificacionesController.text,
        'diasCredito': int.tryParse(_diasCreditoController.text) ?? 30,
        'limiteCredito': double.tryParse(_limiteCreditoController.text) ?? 0.0,
        'enPadronImportadores': _enPadron,
        'enPadronSectorial': _enPadronSectorial,
        'sectoresEspecificos': _sectoresEspecificos,
        'rfcStatus': _rfcStatus,
        'rfcListaNegra': _rfcListaNegra,
        'rfcListaNegraFecha':
            _rfcListaNegra ? _rfcListaNegraFechaController.text : null,
        'numPatente': _numPatenteController.text,
        'immexTipo': _hasImmex ? _immexTipo : 'No Aplica',
        'immexVigencia': _hasImmex ? _immexVigenciaController.text : null,
        'aduana': _aduana,
        'regimenFrecuente': _regimenFrecuenteOperativo,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.clienteId == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['saldoPendiente'] = 0.0; // Solo al crear
        await FirebaseFirestore.instance.collection('clientes').add(data);
      } else {
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(widget.clienteId)
            .update(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Cliente guardado con éxito',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.green));
        context.go('/clientes');
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
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
            widget.clienteId == null ? 'Nuevo Cliente' : 'Editar Cliente',
            style: const TextStyle(color: Color(0xFFF8FAFC))),
        iconTheme: const IconThemeData(color: Color(0xFFF8FAFC)),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save, color: Color(0xFF3B82F6)),
              onPressed: _saveCliente,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSectionTitle('Datos Generales'),
                  _buildTextField(_rfcController, 'RFC', validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final rfcRegExp = RegExp(
                        r'^([A-ZÑ&]{3,4}) ?(?:- ?)?(\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])) ?(?:- ?)?([A-Z\d]{2})([A\d])$',
                        caseSensitive: false);
                    if (!rfcRegExp.hasMatch(v)) return 'Formato RFC inválido';
                    return null;
                  }),
                  _buildTextField(_razonSocialController, 'Razón Social',
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  DropdownButtonFormField<String>(
                    initialValue: _tipo,
                    dropdownColor: const Color(0xFF334155),
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                    decoration: _inputDecoration('Tipo'),
                    items: const [
                      DropdownMenuItem(
                          value: 'importador', child: Text('Importador')),
                      DropdownMenuItem(
                          value: 'exportador', child: Text('Exportador')),
                      DropdownMenuItem(value: 'ambos', child: Text('Ambos')),
                    ],
                    onChanged: (v) => setState(() => _tipo = v!),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Tiene programa IMMEX',
                        style: TextStyle(color: Color(0xFFF8FAFC))),
                    activeThumbColor: const Color(0xFF3B82F6),
                    value: _hasImmex,
                    onChanged: (v) => setState(() => _hasImmex = v),
                  ),
                  if (_hasImmex) ...[
                    _buildTextField(_numImmexController, 'Número IMMEX',
                        validator: (v) =>
                            _hasImmex && v!.isEmpty ? 'Requerido' : null),
                    DropdownButtonFormField<String>(
                      initialValue: _immexTipo,
                      dropdownColor: const Color(0xFF334155),
                      style: const TextStyle(color: Color(0xFFF8FAFC)),
                      decoration: _inputDecoration('Tipo de programa IMMEX'),
                      items: _immexTipos
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _immexTipo = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_immexVigenciaController,
                        'Vigencia del Programa (fecha)'),
                  ],
                  const SizedBox(height: 24),
                  _buildSectionTitle('Cumplimiento SAT'),
                  SwitchListTile(
                    title: const Text('Inscrito en Padrón de Importadores SAT',
                        style: TextStyle(color: Color(0xFFF8FAFC))),
                    activeThumbColor: const Color(0xFF3B82F6),
                    value: _enPadron,
                    onChanged: (v) => setState(() => _enPadron = v),
                  ),
                  SwitchListTile(
                    title: const Text('Inscrito en Padrón Sectores Específicos',
                        style: TextStyle(color: Color(0xFFF8FAFC))),
                    activeThumbColor: const Color(0xFF3B82F6),
                    value: _enPadronSectorial,
                    onChanged: (v) => setState(() => _enPadronSectorial = v),
                  ),
                  if (_enPadronSectorial) ...[
                    const SizedBox(height: 8),
                    const Text('Sectores',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                    Wrap(
                      spacing: 8.0,
                      children: _availableSectores.map((sector) {
                        final isSelected =
                            _sectoresEspecificos.contains(sector);
                        return FilterChip(
                          label: Text(sector),
                          selected: isSelected,
                          selectedColor:
                              const Color(0xFF3B82F6).withValues(alpha: 0.5),
                          backgroundColor: const Color(0xFF334155),
                          labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFF8FAFC)
                                  : const Color(0xFF94A3B8)),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _sectoresEspecificos.add(sector);
                              } else {
                                _sectoresEspecificos.remove(sector);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<String>(
                    initialValue: _rfcStatus,
                    dropdownColor: const Color(0xFF334155),
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                    decoration: _inputDecoration('Estado RFC en SAT'),
                    items: _rfcStatuses
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _rfcStatus = v!),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('RFC en lista Art. 69-B (EFOS)',
                        style: TextStyle(color: Color(0xFFF8FAFC))),
                    activeThumbColor: const Color(0xFF3B82F6),
                    value: _rfcListaNegra,
                    onChanged: (v) => setState(() => _rfcListaNegra = v),
                  ),
                  if (_rfcListaNegra)
                    _buildTextField(_rfcListaNegraFechaController,
                        'Fecha de última verificación'),
                  _buildTextField(
                      _numPatenteController, 'Número de Patente (si aplica)'),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Datos Operativos'),
                  DropdownButtonFormField<String>(
                    initialValue: _aduana,
                    dropdownColor: const Color(0xFF334155),
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                    decoration: _inputDecoration('Aduana Principal'),
                    items: _aduanas
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _aduana = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _regimenFrecuenteOperativo,
                    dropdownColor: const Color(0xFF334155),
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                    decoration: _inputDecoration('Régimen Frecuente'),
                    items: _regimenesOperativos
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _regimenFrecuenteOperativo = v!),
                  ),
                  SwitchListTile(
                    title: const Text('Operador Económico Autorizado (OEA)',
                        style: TextStyle(color: Color(0xFFF8FAFC))),
                    activeThumbColor: const Color(0xFF3B82F6),
                    value: _hasOea,
                    onChanged: (v) => setState(() => _hasOea = v),
                  ),
                  const SizedBox(height: 16),
                  const Text('Regímenes Frecuentes',
                      style: TextStyle(color: Color(0xFF94A3B8))),
                  Wrap(
                    spacing: 8.0,
                    children: _availableRegimenes.map((regimen) {
                      final isSelected = _regimenesFrecuentes.contains(regimen);
                      return FilterChip(
                        label: Text(regimen),
                        selected: isSelected,
                        selectedColor:
                            const Color(0xFF3B82F6).withValues(alpha: 0.5),
                        backgroundColor: const Color(0xFF334155),
                        labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFF94A3B8)),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _regimenesFrecuentes.add(regimen);
                            } else {
                              _regimenesFrecuentes.remove(regimen);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Contacto'),
                  _buildTextField(
                      _contactoNombreController, 'Nombre del Contacto'),
                  _buildTextField(_contactoEmailController, 'Email de Contacto',
                      keyboardType: TextInputType.emailAddress),
                  _buildTextField(_contactoTelController, 'Teléfono',
                      keyboardType: TextInputType.phone),
                  _buildTextField(_emailNotificacionesController,
                      'Email para Notificaciones Automáticas',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Financiero'),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              _diasCreditoController, 'Días de Crédito',
                              keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildTextField(_limiteCreditoController,
                              'Límite de Crédito (\$)',
                              keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _saveCliente,
                    child: const Text('Guardar Cliente',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title,
          style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 18,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Color(0xFFF8FAFC)),
        keyboardType: keyboardType,
        decoration: _inputDecoration(label),
        validator: validator,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF475569))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF475569))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF3B82F6))),
    );
  }
}
