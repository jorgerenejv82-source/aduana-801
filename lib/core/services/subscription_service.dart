import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserPlan { free, pro, enterprise }

class SubscriptionService {
  static SubscriptionService? _instance;
  static SubscriptionService get instance =>
      _instance ??= SubscriptionService._();
  SubscriptionService._();

  UserPlan _currentPlan = UserPlan.free;
  UserPlan get currentPlan => _currentPlan;

  // Stripe Payment Links (replace with real links from Stripe Dashboard)
  static const String stripePro = 'https://buy.stripe.com/pro_pyme_placeholder';
  static const String stripeEnterprise =
      'https://buy.stripe.com/enterprise_placeholder';

  // Load user plan from Firestore
  Future<void> loadPlan() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _currentPlan = UserPlan.free;
      return;
    }
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final plan = doc.data()?['plan'] as String? ?? 'free';
      _currentPlan = _parsePlan(plan);
    } catch (_) {
      _currentPlan = UserPlan.free;
    }
  }

  UserPlan _parsePlan(String plan) {
    switch (plan) {
      case 'pro':
        return UserPlan.pro;
      case 'enterprise':
        return UserPlan.enterprise;
      default:
        return UserPlan.free;
    }
  }

  bool get isPro =>
      _currentPlan == UserPlan.pro || _currentPlan == UserPlan.enterprise;
  bool get isEnterprise => _currentPlan == UserPlan.enterprise;
  bool get isFree => _currentPlan == UserPlan.free;

  String get planName {
    switch (_currentPlan) {
      case UserPlan.pro:
        return 'PRO Pyme';
      case UserPlan.enterprise:
        return 'Enterprise';
      default:
        return 'Empezando';
    }
  }
}
