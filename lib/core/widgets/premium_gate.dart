import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/subscription_service.dart';
import '../services/analytics_service.dart';
import '../theme/app_colors.dart';

class PremiumGate extends StatelessWidget {
  final Widget child;
  final UserPlan requiredPlan; // UserPlan.pro or UserPlan.enterprise
  final String featureName;
  final String featureDescription;

  const PremiumGate({
    super.key,
    required this.child,
    required this.requiredPlan,
    required this.featureName,
    required this.featureDescription,
  });

  bool get _hasAccess {
    final plan = SubscriptionService.instance.currentPlan;
    if (requiredPlan == UserPlan.pro) {
      return plan == UserPlan.pro || plan == UserPlan.enterprise;
    }
    if (requiredPlan == UserPlan.enterprise) return plan == UserPlan.enterprise;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasAccess) return child;
    return _UpgradeWall(
        featureName: featureName,
        featureDescription: featureDescription,
        requiredPlan: requiredPlan);
  }
}

class _UpgradeWall extends StatelessWidget {
  final String featureName;
  final String featureDescription;
  final UserPlan requiredPlan;
  const _UpgradeWall(
      {required this.featureName,
      required this.featureDescription,
      required this.requiredPlan});

  @override
  Widget build(BuildContext context) {
    final isPro = requiredPlan == UserPlan.pro;
    final price = isPro ? '\$299 MXN/mes' : '\$999 MXN/mes';
    final planName = isPro ? 'PRO Pyme' : 'Enterprise';
    final stripeUrl = isPro
        ? SubscriptionService.stripePro
        : SubscriptionService.stripeEnterprise;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.lock_outline,
                    color: AppColors.gold, size: 48),
              ),
              const SizedBox(height: 24),
              Text(featureName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(featureDescription,
                  style: const TextStyle(color: AppColors.sub, fontSize: 15),
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold, width: 1.5),
                  color: AppColors.card,
                ),
                child: Column(
                  children: [
                    Text('Plan $planName',
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(price,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          await AnalyticsService.instance
                              .logUpgradeClick(planName);
                          final url = Uri.parse(stripeUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text('Activar $planName',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Volver',
                    style: TextStyle(color: AppColors.sub)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
