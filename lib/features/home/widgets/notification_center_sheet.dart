import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/widgets/skeleton_widgets.dart';

class NotificationCenterSheet extends StatefulWidget {
  const NotificationCenterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const NotificationCenterSheet(),
    );
  }

  @override
  State<NotificationCenterSheet> createState() =>
      _NotificationCenterSheetState();
}

class _NotificationCenterSheetState extends State<NotificationCenterSheet> {
  final _db = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final snap = await _db
          .collection(FirestoreCollections.notificaciones)
          .where('uid', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      if (!mounted) return;
      setState(() {
        _notifications =
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    if (_uid == null) return;
    final batch = _db.batch();
    for (final n in _notifications.where((n) => n['read'] == false)) {
      batch.update(
          _db
              .collection(FirestoreCollections.notificaciones)
              .doc(n['id'] as String?),
          {'read': true});
    }
    await batch.commit();
    setState(() {
      _notifications = _notifications.map((n) => {...n, 'read': true}).toList();
    });
  }

  Future<void> _markRead(String id) async {
    await _db
        .collection(FirestoreCollections.notificaciones)
        .doc(id)
        .update({'read': true});
    setState(() {
      final idx = _notifications.indexWhere((n) => n['id'] == id);
      if (idx != -1) {
        _notifications[idx] = {..._notifications[idx], 'read': true};
      }
    });
  }

  Future<void> _deleteNotification(String id) async {
    await _db.collection(FirestoreCollections.notificaciones).doc(id).delete();
    setState(() => _notifications.removeWhere((n) => n['id'] == id));
  }

  int get _unreadCount =>
      _notifications.where((n) => n['read'] == false).length;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ── Handle ──
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: AppColors.gold, size: 22),
                  const SizedBox(width: 8),
                  const Text('Notificaciones',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$_unreadCount',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                  const Spacer(),
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: _markAllRead,
                      child: const Text('Marcar todas leídas',
                          style:
                              TextStyle(color: AppColors.gold, fontSize: 12)),
                    ),
                ],
              ),
            ),

            const Divider(color: AppColors.border, height: 16),

            // ── List ──
            Expanded(
              child: _isLoading
                  ? ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      children: const [
                        SkeletonCard(height: 80),
                        SkeletonCard(height: 80),
                        SkeletonCard(height: 80),
                        SkeletonCard(height: 80),
                      ],
                    )
                  : _notifications.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _notifications.length,
                          itemBuilder: (_, i) =>
                              _buildNotificationTile(_notifications[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, color: AppColors.sub, size: 56),
            SizedBox(height: 12),
            Text('Sin notificaciones',
                style: TextStyle(color: AppColors.sub, fontSize: 16)),
            Text('Te avisaremos aquí cuando haya alertas.',
                style: TextStyle(color: AppColors.border, fontSize: 13)),
          ],
        ),
      );

  Widget _buildNotificationTile(Map<String, dynamic> n) {
    final bool isRead = n['read'] == true;
    final String tipo = n['tipo'] as String? ?? 'general';
    final String titulo = n['titulo'] as String? ?? 'Notificación';
    final String mensaje = n['mensaje'] as String? ?? '';
    final ts = n['createdAt'];
    final DateTime? fecha = ts != null ? (ts as Timestamp).toDate() : null;
    final String fechaStr =
        fecha != null ? DateFormat('dd MMM, HH:mm', 'es_MX').format(fecha) : '';

    // Icon and color based on tipo
    IconData icon;
    Color color;
    switch (tipo) {
      case 'immex_vencido':
        icon = Icons.error;
        color = Colors.red;
        break;
      case 'immex_vencimiento':
        icon = Icons.warning_amber;
        color = Colors.orange;
        break;
      case 'bienvenida':
        icon = Icons.celebration;
        color = AppColors.gold;
        break;
      case 'nom':
        icon = Icons.gavel;
        color = AppColors.blue;
        break;
      default:
        icon = Icons.info_outline;
        color = AppColors.sub;
        break;
    }

    return Dismissible(
      key: Key(n['id'] as String),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => _deleteNotification(n['id'] as String),
      child: GestureDetector(
        onTap: () => _markRead(n['id'] as String),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                isRead ? AppColors.card.withValues(alpha: 0.5) : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead ? AppColors.border : color.withValues(alpha: 0.4),
              width: isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ──
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              // ── Content ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(titulo,
                              style: TextStyle(
                                color: isRead ? AppColors.sub : Colors.white,
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 13,
                              )),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(mensaje,
                        style:
                            const TextStyle(color: AppColors.sub, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (fechaStr.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(fechaStr,
                          style: const TextStyle(
                              color: AppColors.border, fontSize: 10)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
