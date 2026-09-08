import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../core/providers/dashboard_provider.dart';
import '../../core/widgets/animated_counter.dart';
import '../widgets/command_palette.dart';
import '../alerts/alerts_engine.dart';
import 'widgets/smart_sidebar.dart';
import 'widgets/onboarding_tour.dart';
import '../../core/widgets/skeleton_widgets.dart';

import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aduana_801/features/home/widgets/empty_state_widget.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/services/subscription_service.dart';
import 'package:aduana_801/features/home/widgets/novato_home_widget.dart';
import 'package:aduana_801/features/subscription/free_trial_banner.dart';
import 'package:aduana_801/features/home/widgets/agente_home_widget.dart';
import 'widgets/importador_home_widget.dart';
import 'widgets/exportador_home_widget.dart';

import 'widgets/notification_center_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  StreamSubscription<QuerySnapshot>? _alertsSubscription;
  String _userRole = 'Agente Aduanal';
  String _userPersona = 'importador';
  String _userName = 'usuario';
  final _searchController = TextEditingController();
  String _drawerSection = 'operacion';
  

  // Animations
  late AnimationController _bellController;
  late AnimationController _fadeController;

  bool _sidebarCollapsed = false;
  bool _showTour = false; // loaded from prefs in _loadUserPersona
  int _unreadAlertCount = 0;
  bool _isLoading = true;

  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode.requestFocus();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..value = 1.0; // Start fully visible â€” no delay

    _loadUserPersona();
  }

  Future<void> _loadUserPersona() async {
    final prefs = await SharedPreferences.getInstance();
    await SubscriptionService.instance.loadPlan();
    final userPersona = prefs.getString('user_persona') ?? 'importador';
    final completed = prefs.getBool('onboarding_completed') ?? true;

    if (!completed && userPersona == 'novato') {
      if (!mounted) return;
      context.go('/guided_onboarding');
      return;
    }

    // Only show tour once
    final tourShown = prefs.getBool('tour_shown') ?? false;

    setState(() {
      _userPersona = userPersona;
      _userName = FirebaseAuth.instance.currentUser?.displayName ??
          FirebaseAuth.instance.currentUser?.email?.split('@').first ??
          'usuario';
      // _activeClientName = prefs.getString('client_active_name') ?? '';
      _showTour = !tourShown;
      _isLoading = false;
    });

    if (!mounted) return;
    unawaited(AlertsEngine().initialize(context, _userPersona));
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      unawaited(_alertsSubscription?.cancel());
      _alertsSubscription = FirebaseFirestore.instance
          .collection(FirestoreCollections.notificaciones)
          .where('uid', isEqualTo: uid)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snap) {
        if (mounted) {
          final newCount = snap.docs.length;
          if (newCount > _unreadAlertCount) {
            _bellController.forward(from: 0.0);
          }
          setState(() => _unreadAlertCount = newCount);
        }
      });
    }
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    _searchController.dispose();
    _bellController.dispose();
    _fadeController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required for AutomaticKeepAliveClientMixin
    final isWide = MediaQuery.of(context).size.width > 900;

    final childScaffold = KeyboardListener(
        focusNode: _keyboardFocusNode,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyK &&
              (HardwareKeyboard.instance.isControlPressed ||
                  HardwareKeyboard.instance.isMetaPressed)) {
            CommandPalette.show(context);
          }
        },
        child: Scaffold(
      backgroundColor: AppColors.bg,
      drawer: isWide ? null : _buildDrawer(context),
      body: Column(
        children: [
          _buildTopBar(context, isWide),
          Expanded(
            child: Row(
              children: [
                if (isWide) _buildSidebar(context),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWide ? _buildBottomNavBar(context) : null,
    ));

    if (_showTour) {
      return OnboardingTour(
        onComplete: () {
          setState(() {
            _showTour = false;
          });
        },
        child: childScaffold,
      );
    }
    return childScaffold;
  }

  // â”€â”€â”€ TOP APP BAR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildTopBar(BuildContext context, bool isWide) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.bg2,
        border: Border(bottom: BorderSide(color: AppColors.border)),
        gradient: LinearGradient(
          colors: [Color(0xFF081223), AppColors.bg2],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (!isWide)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.sub),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          if (isWide)
            IconButton(
              icon: Icon(_sidebarCollapsed ? Icons.menu_open : Icons.menu,
                  color: AppColors.sub),
              onPressed: () =>
                  setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),

          if (isWide && _sidebarCollapsed) ...[
            const SizedBox(width: 8),
            const Icon(Icons.shield, color: AppColors.gold, size: 24),
          ],

          const SizedBox(width: 16),

          // Command Palette Button
          Expanded(
            child: InkWell(
              onTap: () => CommandPalette.show(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: AppColors.sub, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Buscar módulo o función...',
                        style: TextStyle(color: AppColors.sub, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_command_key,
                              color: AppColors.gold, size: 12),
                          SizedBox(width: 4),
                          Text('Ctrl+K',
                              style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Search Button
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.gold),
            tooltip: 'Buscar módulos y datos',
            onPressed: () =>
                context.go('/search', extra: {'persona': _userPersona}),
          ),
          const SizedBox(width: 8),

                    // Search Button
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.sub),
            onPressed: () => _showGlobalSearch(context),
          ),
          const SizedBox(width: 8),
          
          // Selector de Rol
          if (isWide)
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _userRole,
                  dropdownColor: AppColors.card,
                  icon:
                      const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _userRole = newValue;
                      });
                    }
                  },
                  items: <String>[
                    'Agente Aduanal',
                    'Importador/Exportador',
                    'Empresa IMMEX'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

          const SizedBox(width: 16),

          // Badge OPERADOR GLOBAL
          if (isWide)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.green.withAlpha(50)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.language, color: AppColors.green, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'OPERADOR GLOBAL',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 16),

          if (_userPersona != 'novato') const TcWatchWidget(),
          if (_userPersona != 'novato') const SizedBox(width: 16),

          // Notificaciones con pulso
          Stack(
            children: [
              AnimatedBuilder(
                animation: _bellController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _bellController.value *
                        0.5 *
                        (1 - _bellController.value) *
                        10 *
                        3.1416 /
                        180, // Subtle shake
                    child: child,
                  );
                },
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColors.gold),
                  onPressed: () => NotificationCenterSheet.show(context),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedScale(
                  scale: _unreadAlertCount > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: AppColors.red, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        _unreadAlertCount > 9 ? '9+' : '$_unreadAlertCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Avatar with PopupMenuButton
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            color: AppColors.card,
            onSelected: (value) async {
              if (value == 'cambiar_tipo') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('persona_selected');
                if (!mounted) return;
                context.go('/persona_selection');
              } else if (value == 'profile') {
                if (!mounted) return;
                context.go('/profile');
              } else if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                context.go('/login');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Mi Perfil', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'cambiar_tipo',
                child: Text('Cambiar tipo de usuario',
                    style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar sesión',
                    style: TextStyle(color: AppColors.red)),
              ),
            ],
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.5), width: 2),
              ),
              child: const Center(
                child: Icon(Icons.person, color: AppColors.bg, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ DRAWER (Mobile) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bg,
      child: Column(
        children: [
          // Drawer Header
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.shield, color: AppColors.gold, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Aduanas 801',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userRole,
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildImmexAlertBadge(),
                _drawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard Importador',
                  id: 'importer_dashboard',
                  onTap: () {
                    setState(() => _drawerSection = 'importer_dashboard');
                    Navigator.pop(context);
                    context.go('/importer_dashboard');
                  },
                ),
                _drawerItem(
                  context,
                  icon: Icons.grid_view_rounded,
                  label: 'Operación',
                  id: 'operacion',
                  onTap: () {
                    setState(() => _drawerSection = 'operacion');
                    Navigator.pop(context);
                    context.go('/home');
                  },
                ),
                _drawerItem(
                  context,
                  icon: Icons.bar_chart,
                  label: 'Métricas BI',
                  id: 'metricas',
                  onTap: () {
                    setState(() => _drawerSection = 'metricas');
                    Navigator.pop(context);
                    context.go('/financial_dashboard');
                  },
                ),
                _drawerItem(
                  context,
                  icon: Icons.smart_toy_outlined,
                  label: 'Copiloto IA',
                  id: 'copiloto',
                  onTap: () {
                    setState(() => _drawerSection = 'copiloto');
                    Navigator.pop(context);
                    context.go('/ai_copilot');
                  },
                ),
                _drawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Ajustes',
                  id: 'ajustes',
                  onTap: () {
                    setState(() => _drawerSection = 'ajustes');
                    Navigator.pop(context);
                    context.go('/profile');
                  },
                ),
                _drawerItem(
                  context,
                  icon: Icons.security,
                  label: 'Bóveda FIEL',
                  id: 'boveda_fiel',
                  onTap: () {
                    setState(() => _drawerSection = 'boveda_fiel');
                    Navigator.pop(context);
                    context.go('/boveda_fiel');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImmexAlertBadge() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final alertCount = provider.immexAlertsCount;
        if (alertCount == 0) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
          ),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B), size: 16),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
              '$alertCount cliente${alertCount > 1 ? "s" : ""} con IMMEX por vencer',
              style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            )),
            const Icon(Icons.arrow_forward_ios,
                color: Color(0xFFF59E0B), size: 12),
          ]),
        );
      },
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String id,
    required VoidCallback onTap,
  }) {
    final isActive = _drawerSection == id;
    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.gold : AppColors.sub),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.sub,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.card,
      onTap: onTap,
    );
  }

  // â”€â”€â”€ SIDEBAR (Desktop) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildSidebar(BuildContext context) {
    return SmartSidebar(
      isCollapsed: _sidebarCollapsed,
      currentRoute: '/',
      onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
      userRole: _userRole,
    );
  }

  // ——— MAIN CONTENT —————————————————————————————————————————————————————————
  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const SkeletonDashboard();
    }
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _fadeController, curve: Curves.easeOutCubic)),
        child: _userPersona == 'agente'
            ? AgenteHomeWidget(userName: _userName)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: _userPersona == 'novato'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FreeTrialBanner(),
                          const SizedBox(height: 16),
                          NovatoHomeWidget(userName: _userName),
                          const SizedBox(height: 32),
                          _buildZoneA(context),
                          const SizedBox(height: 32),
                          _buildZoneB(context),
                          const SizedBox(height: 32),
                          _buildZoneC(context),
                        ],
                      )
                    : _userPersona == 'importador'
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FreeTrialBanner(),
                              const SizedBox(height: 16),
                              ImportadorHomeWidget(userName: _userName),
                              const SizedBox(height: 32),
                              _buildZoneA(context),
                              const SizedBox(height: 32),
                              _buildZoneB(context),
                              const SizedBox(height: 32),
                              _buildZoneC(context),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FreeTrialBanner(),
                              const SizedBox(height: 16),
                              if (_userPersona == 'exportador')
                                ExportadorHomeWidget(userName: _userName),
                              const SizedBox(height: 32),
                              _buildZoneA(context),
                              const SizedBox(height: 32),
                              _buildZoneB(context),
                              const SizedBox(height: 32),
                              _buildZoneC(context),
                            ],
                          ),
              ),
      ),
    );
  }

  Widget _buildZoneA(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alertas y KPIs',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Consumer<DashboardProvider>(builder: (context, provider, child) {
            final isMobile = MediaQuery.of(context).size.width < 768;
            final userEmail = FirebaseAuth.instance.currentUser?.email ??
                'usuario@aduana.com';
            final sessionAbbrev = userEmail.split('@').first;

            return GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.2 : 2,
              children: [
                _KpiCardPremium(
                  icon: Icons.local_shipping_outlined,
                  numericValue: provider.embarquesActivos,
                  label: 'Embarques Activos',
                  accentColor: AppColors.blue,
                  trend: '',
                  trendUp: true,
                ),
                _KpiCardPremium(
                  icon: Icons.folder_open_outlined,
                  numericValue: provider.expedientesPendientes,
                  label: 'Expedientes Pendientes',
                  accentColor: AppColors.gold,
                  trend: '',
                  trendUp: true,
                ),
                _KpiCardPremium(
                  icon: Icons.warning_amber_rounded,
                  numericValue: provider.alertasDia,
                  label: 'Alertas del Día',
                  accentColor: AppColors.red,
                  trend: '',
                  trendUp: false,
                ),
                _KpiCardPremium(
                  icon: Icons.person_outline,
                  stringValue: sessionAbbrev,
                  label: 'Sesión',
                  accentColor: AppColors.green,
                  trend: '',
                  trendUp: true,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildZoneB(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Acceso Rápido',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Tus módulos más usados',
            style: TextStyle(color: AppColors.sub, fontSize: 14)),
        const SizedBox(height: 20),
        FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              final prefs = snapshot.data!;
              final List<String> recents =
                  prefs.getStringList('recent_routes') ?? [];
              final List<String> pinned =
                  prefs.getStringList('pinned_modules') ?? [];

              final defaultRecents = [
                'ðŸ  Dashboard',
                'ðŸ“¦ Embarques',
                'ðŸ’° Landed Cost',
                'ðŸ“‹ Expedientes',
                'ðŸ” Clasificar'
              ];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Para empezar / Recientes:',
                      style: TextStyle(
                          color: AppColors.sub,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: (recents.isEmpty ? defaultRecents : recents)
                          .take(5)
                          .map((r) => _buildChip(r))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Favoritos pinned:',
                      style: TextStyle(
                          color: AppColors.sub,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...pinned.map((p) => _buildChip(p, isPinned: true)),
                        ActionChip(
                          label: const Text('Personalizar'),
                          avatar: const Icon(Icons.add, size: 16),
                          onPressed: () => _showFavoritesBottomSheet(context),
                          backgroundColor: AppColors.card,
                          labelStyle: const TextStyle(color: Colors.white),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ],
    );
  }

  Widget _buildChip(String label, {bool isPinned = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        avatar: isPinned
            ? const Icon(Icons.star, color: AppColors.gold, size: 16)
            : null,
        backgroundColor: AppColors.card,
        labelStyle: const TextStyle(color: Colors.white),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }

  Widget _buildZoneC(BuildContext context) {
    final sections = [
      {
        'title': 'ðŸ« Aprender',
        'key': 'novato',
        'modules': [
          const _ModuleCardPremium(
              icon: Icons.menu_book_outlined,
              title: 'Glosario ComEx',
              desc: 'Términos',
              route: '/glosario',
              color: Color(0xFF6366F1)),
          const _ModuleCardPremium(
              icon: Icons.help_outline_outlined,
              title: 'FAQ',
              desc: 'Dudas',
              route: '/faq',
              color: Color(0xFF0891B2)),
        ]
      },
      {
        'title': 'ðŸ“¦ Operaciones',
        'key': 'agente',
        'modules': [
          const _ModuleCardPremium(
              icon: Icons.directions_boat_outlined,
              title: 'Shipment Tracker',
              desc: 'Rastrea',
              route: '/shipment_tracker',
              color: Color(0xFF0EA5E9)),
          const _ModuleCardPremium(
              icon: Icons.folder_open_outlined,
              title: 'Expedientes',
              desc: 'Archivo',
              route: '/expedientes',
              color: Color(0xFF8B5CF6)),
        ]
      },
      {
        'title': 'ðŸ’° Finanzas',
        'key': 'all',
        'modules': [
          const _ModuleCardPremium(
              icon: Icons.calculate_outlined,
              title: 'Landed Cost',
              desc: 'Costos',
              route: '/landed_cost',
              color: AppColors.green),
        ]
      },
      {
        'title': 'âš–ï¸ Cumplimiento',
        'key': 'all',
        'modules': [
          const _ModuleCardPremium(
              icon: Icons.gavel_outlined,
              title: 'Compliance OEA',
              desc: 'Auditorías',
              route: '/compliance',
              color: AppColors.gold),
        ]
      },
      {
        'title': 'ðŸ”¬ IA & Análisis',
        'key': 'agente',
        'modules': [
          const _ModuleCardPremium(
              icon: Icons.psychology_outlined,
              title: 'AI Copilot',
              desc: 'Asistencia',
              route: '/ai_copilot',
              color: AppColors.gold),
        ]
      },
      {
        'title': 'ðŸ› ï¸ Herramientas',
        'key': 'all',
        'modules': [
          const _ModuleCardPremium(
              icon: Icons.category_outlined,
              title: 'Clasificador HS',
              desc: 'Búsqueda',
              route: '/classifier',
              color: AppColors.blue),
        ]
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Módulos por Categoría',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...sections.map((sec) {
          final title = sec['title'] as String;
          final modules = sec['modules'] as List<Widget>;

          if (title.contains('IA & Análisis') &&
              _userRole != 'Agente Aduanal') {
            return const SizedBox.shrink();
          }

          bool expanded = false;
          if (title.contains('Aprender') && _userRole == 'novato') {
            expanded = true; // Assume there's a novato role logic or similar
          }
          if (title.contains('Operaciones') &&
              (_userRole == 'Importador/Exportador' ||
                  _userRole == 'Agente Aduanal')) {
            expanded = true;
          }

          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: expanded,
              title: Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              iconColor: AppColors.gold,
              collapsedIconColor: AppColors.sub,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final int crossAxisCount = constraints.maxWidth > 1200
                        ? 3
                        : constraints.maxWidth > 800
                            ? 2
                            : 1;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3,
                      children: modules,
                    );
                  }),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.bg2,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.sub,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 0) {
          // scroll to top logic could be implemented with a ScrollController
        } else if (index == 1) {
          _showGlobalSearch(context);
        } else if (index == 2) {
          context.go('/shipment_tracker');
        } else if (index == 3) {
          context.go('/importer_dashboard');
        } else if (index == 4) {
          Scaffold.of(context).openDrawer();
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined), label: 'Ops'),
        BottomNavigationBarItem(
            icon: Icon(Icons.attach_money), label: 'Finanzas'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Más'),
      ],
    );
  }

  void _showGlobalSearch(BuildContext context) {
    showSearch(context: context, delegate: _GlobalSearchDelegate());
  }

  void _showFavoritesBottomSheet(BuildContext context) {
    // Implement bottom sheet
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bg,
      builder: (context) => const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('Personalizar Favoritos',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}

// â”€â”€â”€ CUSTOM WIDGETS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _HoverSidebarItem extends StatefulWidget {
  final bool isActive;
  final bool isCollapsed;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HoverSidebarItem({
    required this.isActive,
    required this.isCollapsed,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HoverSidebarItem> createState() => _HoverSidebarItemState();
}

class _HoverSidebarItemState extends State<_HoverSidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 0 : 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.gold.withValues(alpha: 0.15)
                : _hovered
                    ? AppColors.card
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.gold.withValues(alpha: 0.5)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: widget.isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                widget.icon,
                color: widget.isActive
                    ? AppColors.gold
                    : (_hovered ? Colors.white : AppColors.sub),
                size: 20,
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isActive
                          ? AppColors.gold
                          : (_hovered ? Colors.white : AppColors.sub),
                      fontWeight:
                          widget.isActive ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCardPremium extends StatelessWidget {
  final IconData icon;
  final int? numericValue;
  final String? stringValue;
  final String label;
  final Color accentColor;
  final String trend;
  final bool trendUp;

  const _KpiCardPremium({
    required this.icon,
    this.numericValue,
    this.stringValue,
    required this.label,
    required this.accentColor,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 200;

      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.05),
              blurRadius: 20,
              spreadRadius: -5,
            )
          ],
        ),
        child: Stack(
          children: [
            // Background Glow
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                          color: accentColor.withValues(alpha: 0.1),
                          blurRadius: 40)
                    ]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isCompact ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isCompact ? 8 : 10),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: accentColor.withValues(alpha: 0.3)),
                        ),
                        child: Icon(icon,
                            color: accentColor, size: isCompact ? 20 : 24),
                      ),
                      if (!isCompact ||
                          trend.isNotEmpty) // Hide empty trends on small cards
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (trendUp ? AppColors.green : AppColors.red)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                  trendUp
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  size: 14,
                                  color: trendUp
                                      ? AppColors.green
                                      : AppColors.red),
                              if (trend.isNotEmpty) const SizedBox(width: 4),
                              if (trend.isNotEmpty)
                                Text(trend,
                                    style: TextStyle(
                                        color: trendUp
                                            ? AppColors.green
                                            : AppColors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (numericValue != null)
                        AnimatedCounter(
                          value: numericValue!,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 24 : 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1),
                        )
                      else
                        Text(
                          stringValue ?? '',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 20 : 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: isCompact ? 2 : 4),
                      Text(
                        label,
                        style: TextStyle(
                            color: AppColors.sub,
                            fontSize: isCompact ? 12 : 14,
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ModuleCardPremium extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String route;
  final Color color;

  const _ModuleCardPremium({
    required this.icon,
    required this.title,
    required this.desc,
    required this.route,
    required this.color,
  });

  @override
  State<_ModuleCardPremium> createState() => _ModuleCardPremiumState();
}

class _ModuleCardPremiumState extends State<_ModuleCardPremium> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          // ignore: deprecated_member_use
          transform: Matrix4.identity()..scale(_hovered ? 1.02 : 1.0),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _hovered
                    ? widget.color.withValues(alpha: 0.5)
                    : AppColors.border),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: widget.color.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: -5)
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withValues(alpha: 0.2),
                        widget.color.withValues(alpha: 0.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: widget.color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(widget.desc,
                          style: const TextStyle(
                              color: AppColors.sub, fontSize: 13, height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _hovered ? 1.0 : 0.0,
                  child: Icon(Icons.arrow_forward_ios,
                      color: widget.color, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlobalSearchDelegate extends SearchDelegate<String> {
  final List<String> allModules = [
    'Dashboard',
    'Embarques',
    'Landed Cost',
    'Expedientes',
    'Clasificar',
    'Shipment Tracker',
    'AI Copilot',
    'Compliance OEA',
    'Glosario ComEx'
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.bg2),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final results = allModules
        .where((m) => m.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No se encontró "$query"',
        subtitle: '¿Pregunta al Copiloto IA?',
        actionLabel: 'Ir a Copiloto',
        onAction: () {
          close(context, '');
          context.go('/ai_copilot');
        },
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.extension, color: AppColors.gold),
          title:
              Text(results[index], style: const TextStyle(color: Colors.white)),
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            final List<String> recents =
                prefs.getStringList('recent_routes') ?? [];
            if (!context.mounted) return;
            if (!recents.contains(results[index])) {
              recents.insert(0, results[index]);
              if (recents.length > 5) recents.removeLast();
              await prefs.setStringList('recent_routes', recents);
            }
            if (!context.mounted) return;
            close(context, results[index]);
          },
        );
      },
    );
  }
}
