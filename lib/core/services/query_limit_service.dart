import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'subscription_service.dart';

class QueryLimitService {
  static QueryLimitService? _instance;
  static QueryLimitService get instance => _instance ??= QueryLimitService._();
  QueryLimitService._();

  static const int freeLimit = 10;

  Future<int> getQueriesThisMonth() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;
    try {
      final now = DateTime.now();
      final monthKey = '${now.year}_${now.month.toString().padLeft(2, '0')}';
      final doc = await FirebaseFirestore.instance
          .collection('copiloto_usage')
          .doc('${uid}_$monthKey')
          .get();
      return (doc.data()?['count'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<bool> canQuery() async {
    if (SubscriptionService.instance.isPro) return true;
    final count = await getQueriesThisMonth();
    return count < freeLimit;
  }

  Future<int> getRemainingQueries() async {
    if (SubscriptionService.instance.isPro) return 999;
    final count = await getQueriesThisMonth();
    return (freeLimit - count).clamp(0, freeLimit);
  }

  Future<void> incrementCount() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (SubscriptionService.instance.isPro) return; // don't track for PRO
    try {
      final now = DateTime.now();
      final monthKey = '${now.year}_${now.month.toString().padLeft(2, '0')}';
      final ref = FirebaseFirestore.instance
          .collection('copiloto_usage')
          .doc('${uid}_$monthKey');
      await ref.set({
        'uid': uid,
        'month': monthKey,
        'count': FieldValue.increment(1),
        'lastQuery': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
