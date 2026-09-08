import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/firestore_collections.dart';
import 'alert_model.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _markAllAsRead() async {
    if (uid == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.notificaciones)
          .where('uid', isEqualTo: uid)
          .where('read', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas las alertas marcadas como leídas')),
      );
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> _deleteAllRead() async {
    if (uid == null) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Eliminar alertas',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            '¿Estás seguro de que deseas eliminar todas las alertas leídas?',
            style: TextStyle(color: AppColors.sub)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                const Text('Cancelar', style: TextStyle(color: AppColors.sub)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                const Text('Eliminar', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm != true) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.notificaciones)
          .where('uid', isEqualTo: uid)
          .where('read', isEqualTo: true)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alertas eliminadas correctamente')),
      );
    } catch (e) {
      debugPrint('Error deleting read alerts: $e');
    }
  }

  Future<void> _deleteAlert(String alertId) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.notificaciones)
          .doc(alertId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting alert: $e');
    }
  }

  Future<void> _markAsRead(String alertId) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.notificaciones)
          .doc(alertId)
          .update({'read': true});
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        backgroundColor: AppColors.bg2,
        title: const Text('🔔 Alertas y Avisos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.gold),
            onPressed: _markAllAsRead,
            tooltip: 'Marcar todas como leídas',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.red),
            onPressed: _deleteAllRead,
            tooltip: 'Eliminar leídas',
          ),
        ],
      ),
      body: uid == null
          ? const Center(
              child: Text('Inicia sesión para ver alertas',
                  style: TextStyle(color: AppColors.sub)))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FirestoreCollections.notificaciones)
                  .where('uid', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.gold));
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.red)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none,
                            color: AppColors.green, size: 64),
                        SizedBox(height: 16),
                        Text('✅ Sin alertas pendientes. Todo en orden.',
                            style: TextStyle(
                                color: AppColors.green, fontSize: 16)),
                      ],
                    ),
                  );
                }

                final alertsData = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return AlertModel.fromMap(data, doc.id);
                }).toList();

                final critical = alertsData
                    .where((a) => a.severity == AlertSeverity.critical)
                    .toList();
                final warning = alertsData
                    .where((a) => a.severity == AlertSeverity.warning)
                    .toList();
                final info = alertsData
                    .where((a) => a.severity == AlertSeverity.info)
                    .toList();

                final List<AlertModel> sortedAlerts = [
                  ...critical,
                  ...warning,
                  ...info
                ];

                return ListView.builder(
                  itemCount: sortedAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = sortedAlerts[index];
                    return Dismissible(
                      key: Key(alert.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: AppColors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteAlert(alert.id),
                      child: ListTile(
                        leading: _severityIcon(alert.severity),
                        title: Text(alert.title,
                            style: TextStyle(
                              color: alert.read ? AppColors.sub : Colors.white,
                              fontWeight: alert.read
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            )),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert.body,
                                style: const TextStyle(
                                    color: AppColors.sub, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(_timeAgo(alert.createdAt),
                                style: const TextStyle(
                                    color: AppColors.sub, fontSize: 10)),
                          ],
                        ),
                        trailing: alert.read
                            ? null
                            : Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: AppColors.blue,
                                    shape: BoxShape.circle),
                              ),
                        onTap: () {
                          _markAsRead(alert.id);
                          context.push(alert.route);
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _severityIcon(AlertSeverity s) {
    return switch (s) {
      AlertSeverity.critical =>
        const Icon(Icons.error, color: AppColors.red, size: 28),
      AlertSeverity.warning =>
        const Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 28),
      AlertSeverity.info =>
        const Icon(Icons.info_outline, color: AppColors.blue, size: 28),
    };
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} días';
  }
}
