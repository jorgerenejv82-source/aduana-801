import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';

class VucemSyncScreen extends StatefulWidget {
  const VucemSyncScreen({super.key});

  @override
  State<VucemSyncScreen> createState() => _VucemSyncScreenState();
}

class _VucemSyncScreenState extends State<VucemSyncScreen>
    with SingleTickerProviderStateMixin {
  bool _isSyncing = false;
  bool _syncComplete = false;
  String _cerFile = "Ningún archivo seleccionado";
  String _keyFile = "Ningún archivo seleccionado";
  final TextEditingController _passController = TextEditingController();

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _passController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _pickFile(bool isCer) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [isCer ? 'cer' : 'key'],
    );
    if (result != null) {
      setState(() {
        if (isCer) {
          _cerFile = result.files.single.name;
        } else {
          _keyFile = result.files.single.name;
        }
      });
    }
  }

  void _startSync() async {
    if (_cerFile == "Ningún archivo seleccionado" ||
        _keyFile == "Ningún archivo seleccionado" ||
        _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Ingresa tu e.Firma completa (CER, KEY y Contraseña).")),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncComplete = false;
    });

    // Simulate WS VUCEM extraction delay
    await Future<void>.delayed(const Duration(seconds: 4));

    setState(() {
      _isSyncing = false;
      _syncComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
        ),
        title: const Text("Bóveda VUCEM: Extracción e-Documents",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.cloud_sync, color: AppColors.blue, size: 64),
                  const SizedBox(height: 16),
                  const Text("Sincronización de Expediente Aduanero",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    "Conecta tu e.Firma para extraer Acuses de Valor (COVEs), DODAs y pedimentos firmados digitalmente directo desde Ventanilla Ãšnica.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.sub, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 48),
                  if (_isSyncing)
                    _buildSyncingAnimation()
                  else if (_syncComplete)
                    _buildSuccessCard()
                  else
                    _buildEFirmaForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEFirmaForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Credenciales SAT (e.Firma)",
              style: TextStyle(
                  color: AppColors.gold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildFileUploader(
              title: "Certificado (.cer)",
              fileName: _cerFile,
              onTap: () => _pickFile(true)),
          const SizedBox(height: 16),
          _buildFileUploader(
              title: "Llave Privada (.key)",
              fileName: _keyFile,
              onTap: () => _pickFile(false)),
          const SizedBox(height: 16),
          const Text("Contraseña de Clave Privada",
              style: TextStyle(color: AppColors.sub, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: _passController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢",
              hintStyle: const TextStyle(color: AppColors.sub),
              filled: true,
              fillColor: AppColors.bg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.gold)),
              prefixIcon: const Icon(Icons.lock, color: AppColors.sub),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Iniciar Sincronización Web Service",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploader(
      {required String title,
      required String fileName,
      required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.sub, fontSize: 12)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.upload_file,
                    color: fileName.contains('Ningún')
                        ? AppColors.sub
                        : AppColors.green,
                    size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName,
                    style: TextStyle(
                        color: fileName.contains('Ningún')
                            ? AppColors.sub
                            : Colors.white,
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncingAnimation() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_animationController.value * 0.1),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blue.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.blue, width: 2),
                ),
                child: const Center(
                    child: CircularProgressIndicator(color: AppColors.blue)),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text("Comunicando con Web Service VUCEM...",
            style:
                TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Descargando XMLs (COVE, e-Documents) firmados...",
            style: TextStyle(color: AppColors.sub)),
      ],
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: AppColors.green, size: 64),
          const SizedBox(height: 16),
          const Text("Sincronización Exitosa",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              "Se descargaron y encriptaron los siguientes documentos para tu expediente electrónico:",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.sub, height: 1.5)),
          const SizedBox(height: 24),
          _buildDocStat(
              Icons.request_quote, "Acuses de Valor (COVEs)", "1,245"),
          _buildDocStat(Icons.qr_code_scanner, "DODAs / Gafetes PITA", "890"),
          _buildDocStat(Icons.description, "Pedimentos (XML / PDF)", "890"),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() => _syncComplete = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.card,
              side: const BorderSide(color: AppColors.border),
            ),
            child:
                const Text("Finalizar", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildDocStat(IconData icon, String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white)),
            ],
          ),
          Text(count,
              style: const TextStyle(
                  color: AppColors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
