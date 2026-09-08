import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen>
    with SingleTickerProviderStateMixin {
  bool _usarTcBanxico = true;
  bool _alertasCriticas = true;
  bool _vencimientosProximos = true;
  bool _notifChat = true;
  final _tcController = TextEditingController(text: '18.50');
  final _umaController = TextEditingController(text: '118.23');
  final _patenteController = TextEditingController();
  final _agenteController = TextEditingController();
  final _tokenController = TextEditingController();
  String _monedaDefault = 'MXN — Peso Mexicano';

  static const Color bg1 = AppColors.bg;
  static const Color card = AppColors.card;
  static const Color gold = AppColors.gold;
  static const Color text = AppColors.text;
  static const Color sub = AppColors.sub;
  static const Color border = AppColors.border;
  static const Color blue = AppColors.blue;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _tcController.dispose();
    _umaController.dispose();
    _patenteController.dispose();
    _agenteController.dispose();
    _tokenController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje,
            style: const TextStyle(color: text, fontWeight: FontWeight.bold)),
        backgroundColor: card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: gold),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: gold, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: border, height: 1),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
      {String? labelText,
      String? hintText,
      Widget? prefixIcon,
      Widget? suffixIcon,
      String? prefixText}) {
    return InputDecoration(
      filled: true,
      fillColor: bg1,
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: gold, fontWeight: FontWeight.bold),
      hintStyle: const TextStyle(color: sub),
      labelStyle: const TextStyle(color: sub),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gold, width: 2),
      ),
    );
  }

  Widget _buildPremiumSwitch(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: text, fontSize: 16, fontWeight: FontWeight.w500)),
          Switch(
            // ignore: deprecated_member_use
            value: value,
            activeThumbColor: bg1,
            activeTrackColor: gold,
            inactiveThumbColor: sub,
            inactiveTrackColor: bg1,
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return gold;
              return border;
            }),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed,
      {IconData? icon}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: bg1,
          elevation: 5,
          shadowColor: gold.withValues(alpha: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8)
            ],
            Text(
              text,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg1,
      appBar: AppBar(
        backgroundColor: bg1,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: text, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Configuración Global',
          style: TextStyle(
            color: text,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: border, height: 1),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECCIÓN 1: Tipo de Cambio
              _buildSection(
                icon: Icons.currency_exchange,
                title: 'Tipo de Cambio (MXN/USD)',
                children: [
                  TextField(
                    controller: _tcController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                        color: text, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: _inputDecoration(
                      labelText: 'TC por defecto',
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPremiumSwitch(
                      'Usar TC Banxico en tiempo real',
                      _usarTcBanxico,
                      (val) => setState(() => _usarTcBanxico = val)),
                  if (_usarTcBanxico) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: blue.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: blue, size: 18),
                          SizedBox(width: 8),
                          Text('TC actual: \$17.1500 MXN/USD (Fallback)',
                              style: TextStyle(
                                  color: blue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildPrimaryButton('Guardar Tipo de Cambio', () {
                    _mostrarSnackBar('Configuración guardada correctamente');
                  }, icon: Icons.save),
                ],
              ),

              // SECCIÓN 2: Notificaciones
              _buildSection(
                icon: Icons.notifications_active,
                title: 'Alertas y Preferencias',
                children: [
                  _buildPremiumSwitch('Alertas Críticas', _alertasCriticas,
                      (val) => setState(() => _alertasCriticas = val)),
                  const Divider(color: border),
                  _buildPremiumSwitch(
                      'Vencimientos Próximos',
                      _vencimientosProximos,
                      (val) => setState(() => _vencimientosProximos = val)),
                  const Divider(color: border),
                  _buildPremiumSwitch('Notificaciones del Copiloto IA',
                      _notifChat, (val) => setState(() => _notifChat = val)),
                ],
              ),

              // SECCIÓN 3: Exportaciones
              _buildSection(
                icon: Icons.picture_as_pdf,
                title: 'Plantillas de Exportación',
                children: [
                  TextField(
                    controller: _patenteController,
                    style: const TextStyle(color: text),
                    decoration: _inputDecoration(
                      labelText: 'Patente Aduanal',
                      prefixIcon: const Icon(Icons.badge, color: gold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _agenteController,
                    style: const TextStyle(color: text),
                    decoration: _inputDecoration(
                      labelText: 'Nombre del Agente',
                      prefixIcon: const Icon(Icons.person, color: gold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _monedaDefault,
                    dropdownColor: card,
                    icon: const Icon(Icons.keyboard_arrow_down, color: gold),
                    style: const TextStyle(
                        color: text, fontWeight: FontWeight.bold),
                    decoration: _inputDecoration(
                      labelText: 'Moneda Default',
                      prefixIcon:
                          const Icon(Icons.monetization_on, color: gold),
                    ),
                    items: [
                      'MXN — Peso Mexicano',
                      'USD — Dólar Americano',
                      'EUR — Euro'
                    ]
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _monedaDefault = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildPrimaryButton('Guardar Preferencias de Exportación',
                      () {
                    _mostrarSnackBar('Preferencias de exportación guardadas');
                  }, icon: Icons.save),
                ],
              ),

              // SECCIÓN 4: Sistema
              _buildSection(
                icon: Icons.shield,
                title: 'Sistema & Seguridad',
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Versión Core', style: TextStyle(color: sub)),
                      Text('v2.4.0 (God-Tier Build)',
                          style: TextStyle(
                              color: gold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: border)),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Motor IA', style: TextStyle(color: sub)),
                      Text('Gemini Pro Advanced',
                          style: TextStyle(
                              color: blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: text,
                      side: const BorderSide(color: border, width: 2),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () =>
                        _mostrarSnackBar('Caché del sistema depurado'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cleaning_services, size: 20),
                        SizedBox(width: 8),
                        Text('Depurar Caché Local',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
