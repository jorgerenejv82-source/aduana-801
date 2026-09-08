import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aduana_801/core/theme/app_colors.dart';

class FavoritesManager {
  static const _key = 'pinned_modules';

  static Future<List<Map<String, String>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favsStr = prefs.getStringList(_key) ?? [];

    return favsStr.map((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return {
        'route': decoded['route'].toString(),
        'label': decoded['label'].toString(),
        'icon': decoded['icon'].toString(),
      };
    }).toList();
  }

  static Future<void> toggleFavorite(
      String route, String label, String icon) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favsStr = prefs.getStringList(_key) ?? [];

    final List<Map<String, dynamic>> favs = favsStr
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();

    final existingIndex = favs.indexWhere((item) => item['route'] == route);

    if (existingIndex >= 0) {
      favs.removeAt(existingIndex);
    } else {
      favs.add({
        'route': route,
        'label': label,
        'icon': icon,
      });
    }

    final List<String> saveList = favs.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(_key, saveList);
  }

  static Future<bool> isFavorite(String route) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favsStr = prefs.getStringList(_key) ?? [];

    for (final String itemStr in favsStr) {
      final decoded = jsonDecode(itemStr) as Map<String, dynamic>;
      if (decoded['route'] == route) {
        return true;
      }
    }
    return false;
  }
}

class FavoritesSheet extends StatefulWidget {
  const FavoritesSheet({super.key});

  @override
  State<FavoritesSheet> createState() => _FavoritesSheetState();
}

class _FavoritesSheetState extends State<FavoritesSheet> {
  static const _allModules = [
    {
      'route': '/financial/landed_cost',
      'label': 'Landed Cost',
      'icon': 'calculate'
    },
    {
      'route': '/shipment_tracker',
      'label': 'Torre de Tráfico',
      'icon': 'local_shipping'
    },
    {'route': '/expedientes', 'label': 'Expedientes', 'icon': 'folder_open'},
    {'route': '/clientes', 'label': 'CRM Clientes', 'icon': 'people'},
    {'route': '/importer_dashboard', 'label': 'Dashboard', 'icon': 'dashboard'},
    {
      'route': '/tco_comparator',
      'label': 'Comparador TCO',
      'icon': 'compare_arrows'
    },
    {'route': '/duty_drawback', 'label': 'Duty Drawback', 'icon': 'savings'},
    {'route': '/nom_calendar', 'label': 'NOMs Calendar', 'icon': 'event'},
    {
      'route': '/requisitos_producto',
      'label': 'Requisitos Producto',
      'icon': 'checklist'
    },
    {'route': '/regulatory/tmec', 'label': 'TMEC/Origen', 'icon': 'handshake'},
    {
      'route': '/supplier_scorecard',
      'label': 'Scorecard Proveedores',
      'icon': 'star'
    },
    {
      'route': '/simple_estimator',
      'label': 'Estimador Simple',
      'icon': 'calculate'
    },
    {
      'route': '/fraccion_simulator',
      'label': 'Simulador Fracción',
      'icon': 'science'
    },
    {
      'route': '/regimen_comparator',
      'label': 'Comparador Régimen',
      'icon': 'balance'
    },
    {
      'route': '/roi_calculator',
      'label': 'ROI Calculator',
      'icon': 'trending_up'
    },
    {
      'route': '/permisos_previos',
      'label': 'Permisos Previos',
      'icon': 'assignment'
    },
    {
      'route': '/regulatory/noms_advisor',
      'label': 'NOMs Advisor',
      'icon': 'verified'
    },
    {
      'route': '/carta_de_cupo',
      'label': 'Carta de Cupo',
      'icon': 'card_membership'
    },
    {'route': '/glosario', 'label': 'Glosario', 'icon': 'menu_book'},
    {
      'route': '/timeline_estimator',
      'label': 'Timeline Estimador',
      'icon': 'timeline'
    },
  ];

  List<String> _favoriteRoutes = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesManager.getFavorites();
    setState(() {
      _favoriteRoutes = favs.map((e) => e['route']!).toList();
    });
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'calculate':
        return Icons.calculate;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'folder_open':
        return Icons.folder_open;
      case 'people':
        return Icons.people;
      case 'dashboard':
        return Icons.dashboard;
      case 'compare_arrows':
        return Icons.compare_arrows;
      case 'savings':
        return Icons.savings;
      case 'event':
        return Icons.event;
      case 'checklist':
        return Icons.checklist;
      case 'handshake':
        return Icons.handshake;
      case 'star':
        return Icons.star;
      case 'science':
        return Icons.science;
      case 'balance':
        return Icons.balance;
      case 'trending_up':
        return Icons.trending_up;
      case 'assignment':
        return Icons.assignment;
      case 'verified':
        return Icons.verified;
      case 'card_membership':
        return Icons.card_membership;
      case 'menu_book':
        return Icons.menu_book;
      case 'timeline':
        return Icons.timeline;
      default:
        return Icons.extension;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Módulos Favoritos',
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allModules.length,
              itemBuilder: (context, index) {
                final module = _allModules[index];
                final isFav = _favoriteRoutes.contains(module['route']);
                return ListTile(
                  leading:
                      Icon(_getIconData(module['icon']!), color: AppColors.sub),
                  title: Text(module['label']!,
                      style: const TextStyle(color: AppColors.text)),
                  trailing: IconButton(
                    icon: Icon(
                      isFav ? Icons.star : Icons.star_border,
                      color: isFav ? AppColors.gold : AppColors.sub,
                    ),
                    onPressed: () async {
                      await FavoritesManager.toggleFavorite(
                          module['route']!, module['label']!, module['icon']!);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Guardado'),
                            duration: Duration(seconds: 1)),
                      );
                      unawaited(_loadFavorites());
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
