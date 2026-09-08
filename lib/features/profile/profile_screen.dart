import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/subscription_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _user = FirebaseAuth.instance.currentUser;
  final _db = FirebaseFirestore.instance;
  final _nameCtrl = TextEditingController();
  final _rfcCtrl = TextEditingController();
  bool _savingName = false;
  bool _savingRfc = false;
  String _persona = 'importador';
  bool _loading = true;

  static const _gold = AppColors.gold;
  static const _red = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rfcCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _nameCtrl.text = _user?.displayName ?? '';
    final prefs = await SharedPreferences.getInstance();
    final uid = _user?.uid;
    String rfc = '';
    if (uid != null) {
      try {
        final doc = await _db.collection('users').doc(uid).get();
        rfc = doc.data()?['rfc'] as String? ?? '';
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _rfcCtrl.text = rfc;
      _persona = prefs.getString('user_persona') ?? 'importador';
      _loading = false;
    });
  }

  Future<void> _saveName() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _savingName = true);
    try {
      await _user?.updateDisplayName(_nameCtrl.text.trim());
      final uid = _user?.uid;
      if (uid != null) {
        await _db.collection('users').doc(uid).set(
            {'displayName': _nameCtrl.text.trim()}, SetOptions(merge: true));
      }
      if (mounted) _showSnack('✅ Nombre actualizado');
    } catch (_) {
      if (mounted) _showSnack('Error al guardar nombre', isError: true);
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _saveRfc() async {
    setState(() => _savingRfc = true);
    try {
      final uid = _user?.uid;
      if (uid != null) {
        await _db.collection('users').doc(uid).set(
            {'rfc': _rfcCtrl.text.trim().toUpperCase()},
            SetOptions(merge: true));
      }
      if (mounted) _showSnack('✅ RFC guardado');
    } catch (_) {
      if (mounted) _showSnack('Error al guardar RFC', isError: true);
    } finally {
      if (mounted) setState(() => _savingRfc = false);
    }
  }

  Future<void> _changePassword() async {
    final email = _user?.email;
    if (email == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) _showSnack('📧 Email de recuperación enviado a $email');
    } catch (_) {
      if (mounted) _showSnack('Error al enviar email', isError: true);
    }
  }

  Future<void> _changePersona(String persona) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_persona', persona);
    final uid = _user?.uid;
    if (uid != null) {
      await _db
          .collection('users')
          .doc(uid)
          .set({'persona': persona}, SetOptions(merge: true));
    }
    if (mounted) {
      setState(() => _persona = persona);
      _showSnack('✅ Perfil actualizado a ${_personaLabel(persona)}');
    }
  }

  Future<void> _deleteDemoData() async {
    final uid = _user?.uid;
    if (uid == null) return;
    try {
      final snap = await _db
          .collection('immex_inventario')
          .where('esDemoData', isEqualTo: true)
          .where('uid', isEqualTo: uid)
          .get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      // Also clear the flag so seed can run again
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('seed_data_created');
      if (mounted) _showSnack('🗑️ Datos de demo eliminados');
    } catch (_) {
      if (mounted) _showSnack('Error al eliminar', isError: true);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('¿Eliminar cuenta?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Esta acción es IRREVERSIBLE. Se eliminarán todos tus datos.',
          style: TextStyle(color: AppColors.sub),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.sub))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _user?.delete();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: re-autenticate primero', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? _red : AppColors.card,
    ));
  }

  String _personaLabel(String p) {
    switch (p) {
      case 'importador':
        return 'Importador';
      case 'exportador':
        return 'Exportador';
      case 'agente':
        return 'Profesional';
      default:
        return 'Empezando';
    }
  }

  String _personaEmoji(String p) {
    switch (p) {
      case 'importador':
        return '📦';
      case 'exportador':
        return '🌎';
      case 'agente':
        return '⚖️';
      default:
        return '🌱';
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = SubscriptionService.instance.planName;
    final initials = (_user?.displayName?.isNotEmpty ?? false)
        ? _user!.displayName!
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : (_user?.email?[0].toUpperCase() ?? 'U');

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Mi Perfil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── User Header ──
                _buildUserHeader(initials, plan),
                const SizedBox(height: 24),

                // ── Cuenta ──
                _buildSection('CUENTA', [
                  _EditField(
                    label: 'Nombre completo',
                    ctrl: _nameCtrl,
                    isSaving: _savingName,
                    onSave: _saveName,
                    hint: 'Ej: Juan García',
                  ),
                  const SizedBox(height: 12),
                  _ReadonlyField(
                      label: 'Correo electrónico', value: _user?.email ?? '-'),
                  const SizedBox(height: 12),
                  _EditField(
                    label: 'RFC',
                    ctrl: _rfcCtrl,
                    isSaving: _savingRfc,
                    onSave: _saveRfc,
                    hint: 'Ej: ABCD850101XXX',
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_reset, color: AppColors.sub),
                    title: const Text('Cambiar contraseña',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: const Text('Se enviará un email de recuperación',
                        style: TextStyle(color: AppColors.sub, fontSize: 12)),
                    trailing: TextButton(
                      onPressed: _changePassword,
                      child: const Text('Enviar email',
                          style: TextStyle(color: _gold)),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Preferencias ──
                _buildSection('PREFERENCIAS', [
                  const Text('Perfil de usuario',
                      style: TextStyle(color: AppColors.sub, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in [
                        'novato',
                        'importador',
                        'exportador',
                        'agente'
                      ])
                        _PersonaChip(
                          emoji: _personaEmoji(p),
                          label: _personaLabel(p),
                          selected: _persona == p,
                          onTap: () => _changePersona(p),
                        ),
                    ],
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Suscripción ──
                _buildSection('SUSCRIPCIÓN', [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.workspace_premium,
                          color: _gold, size: 20),
                    ),
                    title: Text('Plan actual: $plan',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Toca para ver o cambiar tu plan',
                        style: TextStyle(color: AppColors.sub, fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: AppColors.sub, size: 14),
                    onTap: () => context.go('/subscription'),
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Zona de Peligro ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _red.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ZONA DE PELIGRO',
                          style: TextStyle(
                              color: _red,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.delete_sweep_outlined,
                              color: AppColors.sub, size: 16),
                          label: const Text('Eliminar datos de demo',
                              style: TextStyle(
                                  color: AppColors.sub, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border)),
                          onPressed: _deleteDemoData,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.logout, color: _red, size: 16),
                          label: const Text('Cerrar sesión',
                              style: TextStyle(color: _red, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _red)),
                          onPressed: _signOut,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.person_off_outlined,
                              color: _red, size: 16),
                          label: const Text('Eliminar cuenta',
                              style: TextStyle(color: _red, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _red)),
                          onPressed: _deleteAccount,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildUserHeader(String initials, String plan) {
    final isPaid = plan != 'Empezando';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isPaid ? _gold.withValues(alpha: 0.4) : AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: _gold.withValues(alpha: 0.2),
            child: Text(initials,
                style: const TextStyle(
                    color: _gold, fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    _user?.displayName?.isNotEmpty ?? false
                        ? _user!.displayName!
                        : 'Usuario',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 2),
                Text(_user?.email ?? '',
                    style: const TextStyle(color: AppColors.sub, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:
                        isPaid ? _gold.withValues(alpha: 0.15) : AppColors.bg,
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: isPaid ? _gold : AppColors.border),
                  ),
                  child: Text(plan,
                      style: TextStyle(
                          color: isPaid ? _gold : AppColors.sub,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
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
          Text(title,
              style: const TextStyle(
                  color: _gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ── Sub-widgets ──

class _EditField extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final bool isSaving;
  final VoidCallback onSave;
  const _EditField(
      {required this.label,
      required this.ctrl,
      required this.isSaving,
      required this.onSave,
      required this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: const TextStyle(color: AppColors.sub, fontSize: 12),
              hintStyle: const TextStyle(color: AppColors.border, fontSize: 12),
              filled: true,
              fillColor: AppColors.bg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.gold)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : const Text('Guardar',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String label, value;
  const _ReadonlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: AppColors.sub, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.lock_outline, color: AppColors.border, size: 14),
        ],
      ),
    );
  }
}

class _PersonaChip extends StatelessWidget {
  final String emoji, label;
  final bool selected;
  final VoidCallback onTap;
  const _PersonaChip(
      {required this.emoji,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.gold.withValues(alpha: 0.15) : AppColors.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? AppColors.gold : AppColors.border,
              width: selected ? 1.5 : 1),
        ),
        child: Text('$emoji $label',
            style: TextStyle(
                color: selected ? AppColors.gold : AppColors.sub,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}
