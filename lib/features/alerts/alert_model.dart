import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertSeverity { info, warning, critical }

enum AlertCategory { fiel, nom, po, embarque, immex, general }

class AlertModel {
  final String id; // auto-generated Firestore ID
  final String uid;
  final String title;
  final String body;
  final AlertSeverity severity;
  final AlertCategory category;
  final String route; // where to navigate on tap
  final DateTime createdAt;
  final bool read;
  final String dedupeKey; // prevents duplicate alerts same day

  const AlertModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.body,
    required this.severity,
    required this.category,
    required this.route,
    required this.createdAt,
    this.read = false,
    required this.dedupeKey,
  });

  factory AlertModel.fromMap(Map<String, dynamic> map, String id) {
    return AlertModel(
      id: id,
      uid: (map['uid'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == ((map['severity'] as String?) ?? 'info'),
        orElse: () => AlertSeverity.info,
      ),
      category: AlertCategory.values.firstWhere(
        (e) => e.name == ((map['category'] as String?) ?? 'general'),
        orElse: () => AlertCategory.general,
      ),
      route: (map['route'] as String?) ?? '/notifications',
      createdAt: (map['createdAt'] as dynamic)?.toDate() as DateTime? ??
          DateTime.now(),
      read: (map['read'] as bool?) ?? false,
      dedupeKey: (map['dedupeKey'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'title': title,
        'body': body,
        'severity': severity.name,
        'category': category.name,
        'route': route,
        'createdAt': FieldValue.serverTimestamp(),
        'read': read,
        'dedupeKey': dedupeKey,
      };
}
