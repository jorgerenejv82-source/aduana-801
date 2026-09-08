import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:aduana_801/core/utils/fiel_signer.dart';
import 'package:aduana_801/features/crypto/vucem_soap_client.dart';
import 'package:aduana_801/core/services/secure_storage_service.dart';

class BovedaFielScreen extends StatefulWidget {
  const BovedaFielScreen({super.key});

  @override
  State<BovedaFielScreen> createState() => _BovedaFielScreenState();
}

class _BovedaFielScreenState extends State<BovedaFielScreen> {
  String? _cerFileName;
  String? _keyFileName;
  String? _cerBase64;
  String? _keyBase64;

  final _pwdCtrl = TextEditingController();
  bool _isObscured = true;
  bool _isValidating = false;

  String? _rfcDetectado;
  String? _serieDetectada;
  bool? _isPasswordValid;
  bool _isTransmitting = false;
  @override
  void initState() {
    super.initState();
    _cargarFielGuardada();
  }

  Future<void> _cargarFielGuardada() async {
    final data = await SecureStorageService.getFielData();
    if (data['cer'] != null && data['key'] != null && data['pwd'] != null) {
      if (mounted) {
        setState(() {
          _cerBase64 = data['cer'];
          _keyBase64 = data['key'];
          _pwdCtrl.text = data['pwd']!;
          _cerFileName = "CER_Guardado_Seguro.cer";
          _keyFileName = "KEY_Guardado_Seguro.key";
          _isPasswordValid = true;
          _procesarCer();
        });
      }
    }
  }


  Future<void> _pickFile(bool isCer) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: isCer ? ['cer'] : ['key'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;

      final base64String = base64Encode(bytes);

      setState(() {
        if (isCer) {
          _cerFileName = file.name;
          _cerBase64 = base64String;
          _procesarCer();
        } else {
          _keyFileName = file.name;
          _keyBase64 = base64String;
          _isPasswordValid = null; // reset validation on new key
        }
      });
    }
  }

  void _procesarCer() {
    if (_cerBase64 == null) return;
    try {
      final rfc = FielSigner.getRfc(_cerBase64!);
      final serie = FielSigner.getSerialNumber(_cerBase64!);
      setState(() {
        _rfcDetectado = rfc;
        _serieDetectada = serie;
      });
    } catch (e) {
      debugPrint("Error procesando CER: $e");
    }
  }

  void _validarFiel() {
    if (_cerBase64 == null || _keyBase64 == null || _pwdCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Carga ambos archivos e ingresa la contraseña."),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() => _isValidating = true);

    // Simulate a tiny delay for UX purposes, JS is instant
    Future.delayed(const Duration(milliseconds: 600), () {
      final isValid = FielSigner.validateKey(_keyBase64!, _pwdCtrl.text);

      if (mounted) {
        setState(() {
          _isValidating = false;
          _isPasswordValid = isValid;
        });

        if (isValid) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "FIEL Validada Exitosamente. ¡Llave privada desencriptada localmente!"),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ));
          SecureStorageService.saveFielData(cerBase64: _cerBase64!, keyBase64: _keyBase64!, password: _pwdCtrl.text);
          // La llave ahora se guarda encriptada AES-GCM en el dispositivo (Criptografía God Level)
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Error: Contraseña incorrecta o el archivo .key no corresponde al certificado."),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    });
  }

  Future<void> _probarConexionVucem() async {
    if (_cerBase64 == null || _keyBase64 == null) return;

    setState(() => _isTransmitting = true);

    try {
      final xmlResponse = await VucemSoapClient.consultarPedimento(
        cerBase64: _cerBase64!,
        keyBase64: _keyBase64!,
        password: _pwdCtrl.text,
        pedimento: "1234567-8901234",
      );

      if (mounted) {
        setState(() => _isTransmitting = false);
        _mostrarDialogoXml(xmlResponse);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTransmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error: \$e"),
          backgroundColor: AppColors.red,
        ));
      }
    }
  }

  void _mostrarDialogoXml(String xml) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.green),
            SizedBox(width: 8),
            Text("Respuesta VUCEM Simulada",
                style: TextStyle(color: AppColors.text, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Text(
              xml,
              style: const TextStyle(
                  color: AppColors.gold, fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("CERRAR", style: TextStyle(color: AppColors.gold)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pwdCtrl.dispose();
    super.dispose();
  }

  Widget _buildFileBox(
      {required bool isCer,
      required String title,
      required String? fileName,
      required IconData icon}) {
    final hasFile = fileName != null;
    return GestureDetector(
      onTap: () => _pickFile(isCer),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:
              hasFile ? AppColors.green.withValues(alpha: 0.1) : AppColors.card,
          border: Border.all(
              color: hasFile ? AppColors.green : AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(hasFile ? Icons.check_circle : icon,
                size: 48, color: hasFile ? AppColors.green : AppColors.sub),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 8),
            Text(
                hasFile
                    ? fileName
                    : (isCer ? "Cargar archivo .cer" : "Cargar archivo .key"),
                style: TextStyle(
                    color: hasFile ? AppColors.green : AppColors.sub,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('Bóveda FIEL (Zero-Trust)',
            style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: AppColors.gold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.security, color: AppColors.gold, size: 32),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Procesamiento 100% Local (Client-Side)",
                                style: TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            SizedBox(height: 4),
                            Text(
                                "Tu e.firma no se sube a ningún servidor. La encriptación ocurre en la memoria de tu navegador.",
                                style: TextStyle(
                                    color: AppColors.sub, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // File Boxes
                Row(
                  children: [
                    Expanded(
                        child: _buildFileBox(
                            isCer: true,
                            title: "Certificado Público",
                            fileName: _cerFileName,
                            icon: Icons.badge)),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildFileBox(
                            isCer: false,
                            title: "Llave Privada",
                            fileName: _keyFileName,
                            icon: Icons.key)),
                  ],
                ),
                const SizedBox(height: 32),

                // Data Display & Password
                if (_cerFileName != null) ...[
                  const Text("Datos del Certificado:",
                      style: TextStyle(
                          color: AppColors.sub,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                            label: "RFC",
                            value: _rfcDetectado ?? "Procesando..."),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoChip(
                            label: "No. Serie",
                            value: _serieDetectada ?? "Procesando..."),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],

                const Text("Contraseña de Clave Privada:",
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(
                  controller: _pwdCtrl,
                  obscureText: _isObscured,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: "Ingresa tu contraseña",
                    hintStyle: const TextStyle(color: AppColors.sub),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.gold, width: 2)),
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: AppColors.sub),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isObscured ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.sub),
                      onPressed: () =>
                          setState(() => _isObscured = !_isObscured),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Validation Status
                if (_isPasswordValid != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isPasswordValid!
                          ? AppColors.green.withValues(alpha: 0.1)
                          : AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _isPasswordValid!
                              ? AppColors.green
                              : AppColors.red),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            _isPasswordValid!
                                ? Icons.check_circle
                                : Icons.error,
                            color: _isPasswordValid!
                                ? AppColors.green
                                : AppColors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isPasswordValid!
                                ? "Llave privada verificada exitosamente. Lista para firmar XML de VUCEM."
                                : "Contraseña incorrecta. La llave privada no pudo ser descifrada.",
                            style: TextStyle(
                                color: _isPasswordValid!
                                    ? AppColors.green
                                    : AppColors.red,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isValidating ? null : _validarFiel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bg,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isValidating
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: AppColors.bg, strokeWidth: 3))
                        : const Text("Vincular y Desencriptar",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                  ),
                ),

                if (_isPasswordValid ?? false) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isTransmitting ? null : _probarConexionVucem,
                      icon: _isTransmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send),
                      label: Text(_isTransmitting
                          ? "Transmitiendo XML Seguro..."
                          : "Prueba: Consultar Pedimento (VUCEM)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.sub,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
