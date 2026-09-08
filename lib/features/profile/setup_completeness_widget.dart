import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/firestore_collections.dart';

class _SetupItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool completed;
  final String actionRoute;
  final Color color;

  const _SetupItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.completed,
    required this.actionRoute,
    required this.color,
  });
}

class SetupCompletenessWidget extends StatefulWidget {
  final String userPersona;
  const SetupCompletenessWidget({super.key, required this.userPersona});

  @override
  State<SetupCompletenessWidget> createState() =>
      _SetupCompletenessWidgetState();
}

class _SetupCompletenessWidgetState extends State<SetupCompletenessWidget> {
  bool _isLoading = true;
  bool _isExpanded = false;
  List<_SetupItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadSetupStatus();
  }

  Future<void> _loadSetupStatus() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final personaSelected = prefs.getString('persona_selected') == 'true';
    final fielRegistered = prefs.getString('fiel_vigencia_date') != null;

    bool hasCliente = false;
    bool hasSupplier = false;
    bool hasExpediente = false;
    bool hasEmbarque = false;
    bool hasNom = false;
    bool hasPo = false;

    if (uid != null) {
      try {
        final clientSnap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.clientesCrm)
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();
        hasCliente = clientSnap.docs.isNotEmpty;

        final supplierSnap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.suppliers)
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();
        hasSupplier = supplierSnap.docs.isNotEmpty;

        final expSnap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.expedientesCompletos)
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();
        hasExpediente = expSnap.docs.isNotEmpty;

        final embarqueSnap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.embarques)
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();
        hasEmbarque = embarqueSnap.docs.isNotEmpty;

        final nomSnap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.nomVigencias)
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();
        hasNom = nomSnap.docs.isNotEmpty;

        final poSnap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.purchaseOrders)
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();
        hasPo = poSnap.docs.isNotEmpty;
      } catch (_) {}
    }

    final tier = prefs.getString('subscription_tier');
    final hasPro = tier == 'pro' || tier == 'agente' || tier == 'trial';

    final items = <_SetupItem>[];

    items.add(_SetupItem(
      id: 'persona',
      title: 'Configura tu perfil',
      subtitle: personaSelected
          ? 'Perfil configurado correctamente'
          : 'Elige tu tipo de usuario',
      icon: Icons.person_outline,
      completed: personaSelected,
      actionRoute: '/persona_selection',
      color: const Color(0xFF6366F1),
    ));

    if (widget.userPersona != 'novato') {
      items.add(_SetupItem(
        id: 'cliente',
        title: 'Agrega tu primer cliente',
        subtitle: hasCliente
            ? 'Clientes registrados en CRM'
            : 'Añade clientes a tu CRM para contexto',
        icon: Icons.people_outline,
        completed: hasCliente,
        actionRoute: '/clientes',
        color: AppColors.blue,
      ));

      items.add(_SetupItem(
        id: 'supplier',
        title: 'Registra un proveedor',
        subtitle: hasSupplier
            ? 'Proveedores en tu base de datos'
            : 'Añade tus proveedores para calcular TCO',
        icon: Icons.factory_outlined,
        completed: hasSupplier,
        actionRoute: '/suppliers',
        color: AppColors.blue,
      ));

      items.add(_SetupItem(
        id: 'po',
        title: 'Crea tu primera Orden de Compra',
        subtitle: hasPo
            ? 'POs registradas en supply chain'
            : 'Gestiona tus compras internacionales',
        icon: Icons.shopping_cart_outlined,
        completed: hasPo,
        actionRoute: '/supply_chain/po/nueva',
        color: AppColors.blue,
      ));
    }

    if (widget.userPersona == 'agente') {
      items.add(_SetupItem(
        id: 'fiel',
        title: 'Registra tu e.firma/FIEL',
        subtitle: fielRegistered
            ? 'e.firma registrada y monitoreada'
            : 'Configura la fecha de vencimiento de tu FIEL',
        icon: Icons.security_outlined,
        completed: fielRegistered,
        actionRoute: '/home',
        color: AppColors.gold,
      ));

      items.add(_SetupItem(
        id: 'expediente',
        title: 'Crea tu primer expediente',
        subtitle: hasExpediente
            ? 'Expedientes aduanales registrados'
            : 'Comienza a gestionar operaciones',
        icon: Icons.folder_outlined,
        completed: hasExpediente,
        actionRoute: '/expedientes',
        color: AppColors.gold,
      ));

      items.add(_SetupItem(
        id: 'nom',
        title: 'Registra NOMs y vigencias',
        subtitle: hasNom
            ? 'NOMs registradas y monitoreadas'
            : 'Evita sorpresas en aduana',
        icon: Icons.gavel_outlined,
        completed: hasNom,
        actionRoute: '/nom_calendar',
        color: const Color(0xFFF59E0B),
      ));
    }

    if (widget.userPersona == 'importador') {
      items.add(_SetupItem(
        id: 'embarque',
        title: 'Agrega un embarque',
        subtitle: hasEmbarque
            ? 'Embarques en seguimiento'
            : 'Monitorea tus contenedores en tiempo real',
        icon: Icons.directions_boat_outlined,
        completed: hasEmbarque,
        actionRoute: '/shipment_tracker',
        color: AppColors.blue,
      ));

      items.add(_SetupItem(
        id: 'nom',
        title: 'Registra tus NOMs',
        subtitle:
            hasNom ? 'NOMs monitoreadas' : 'Evita multas por normas vencidas',
        icon: Icons.verified_outlined,
        completed: hasNom,
        actionRoute: '/nom_calendar',
        color: const Color(0xFFF59E0B),
      ));
    }

    if (widget.userPersona == 'exportador') {
      items.add(_SetupItem(
        id: 'tmec',
        title: 'Configura Certificados de Origen',
        subtitle: hasCliente
            ? 'Rutas de exportación configuradas'
            : 'Registra tus productos para c.o. TMEC',
        icon: Icons.verified_outlined,
        completed: hasCliente,
        actionRoute: '/tmec',
        color: const Color(0xFF10B981),
      ));
      items.add(_SetupItem(
        id: 'immex',
        title: 'Configura tu programa IMMEX',
        subtitle: hasExpediente
            ? 'IMMEX configurado'
            : 'Habilita importación temporal para exportar',
        icon: Icons.factory_outlined,
        completed: hasExpediente,
        actionRoute: '/immex',
        color: AppColors.blue,
      ));
      items.add(_SetupItem(
        id: 'drawback',
        title: 'Activa Duty Drawback',
        subtitle: hasPo
            ? 'Drawback configurado'
            : 'Recupera impuestos de importación',
        icon: Icons.savings_outlined,
        completed: hasPo,
        actionRoute: '/duty_drawback',
        color: const Color(0xFF10B981),
      ));
    }

    items.add(_SetupItem(
      id: 'pro',
      title: 'Activa PRO o prueba gratuita',
      subtitle: hasPro
          ? 'Plan activo ✅'
          : 'Desbloquea todas las funciones por 14 días gratis',
      icon: Icons.star_outline,
      completed: hasPro,
      actionRoute: '/pricing',
      color: AppColors.gold,
    ));

    setState(() {
      _items = items;
      _isLoading = false;
      if (items.every((i) => i.completed)) {
        _isExpanded = false;
      }
    });
  }

  Color _progressColor(double ratio) {
    if (ratio >= 1.0) return const Color(0xFF10B981);
    if (ratio >= 0.6) return AppColors.gold;
    return AppColors.blue;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        color: AppColors.card,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Configurando...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }

    final completedCount = _items.where((i) => i.completed).length;
    final totalCount = _items.length;
    final pct = totalCount == 0 ? 0 : (completedCount * 100 ~/ totalCount);
    final nextIncomplete =
        _items.firstWhere((i) => !i.completed, orElse: () => _items.first);

    return Card(
      color: AppColors.card,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (pct < 100 || _isExpanded) {
                setState(() => _isExpanded = !_isExpanded);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          value:
                              totalCount == 0 ? 0 : completedCount / totalCount,
                          color: _progressColor(totalCount == 0
                              ? 0
                              : completedCount / totalCount),
                          backgroundColor: AppColors.border,
                          strokeWidth: 4,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          color: _progressColor(pct / 100),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pct == 100
                              ? '✅ App completamente configurada'
                              : 'Tu app está configurada al $pct%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (pct < 100)
                          Text(
                            'Siguiente: ${nextIncomplete.title}',
                            style: const TextStyle(
                              color: AppColors.sub,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (pct < 100)
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.sub,
                    ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            ..._items.map((item) => ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: item.completed
                          ? item.color.withValues(alpha: 0.15)
                          : AppColors.border.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: item.completed
                        ? Icon(Icons.check, color: item.color, size: 18)
                        : Icon(item.icon, color: AppColors.sub, size: 18),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: item.completed ? AppColors.sub : Colors.white,
                      decoration:
                          item.completed ? TextDecoration.lineThrough : null,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    item.subtitle,
                    style: const TextStyle(color: AppColors.sub, fontSize: 11),
                  ),
                  trailing: item.completed
                      ? null
                      : TextButton(
                          onPressed: () => context.go(item.actionRoute),
                          child: Text(
                            'Completar',
                            style: TextStyle(color: item.color, fontSize: 12),
                          ),
                        ),
                )),
        ],
      ),
    );
  }
}
