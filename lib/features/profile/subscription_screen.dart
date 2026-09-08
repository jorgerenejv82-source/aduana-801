import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/subscription_service.dart';
import '../../core/theme/app_colors.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = SubscriptionService.instance.currentPlan;
    final planName = SubscriptionService.instance.planName;
    final isFree = SubscriptionService.instance.isFree;
    final isPro = plan == UserPlan.pro;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title:
            const Text('Mi Suscripción', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.bg,
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan Actual: $planName',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (isFree)
              const Text('Incluye: funciones básicas.',
                  style: TextStyle(color: AppColors.sub, fontSize: 16)),
            if (isPro)
              const Text(
                  'Incluye: Expedientes, CRM, NOMs, Copiloto, Dashboard Importador.',
                  style: TextStyle(color: AppColors.sub, fontSize: 16)),
            if (plan == UserPlan.enterprise)
              const Text(
                  'Incluye: Todo en PRO, M3, SAAI, Inteligencia Artificial Avanzada.',
                  style: TextStyle(color: AppColors.sub, fontSize: 16)),
            const SizedBox(height: 32),
            if (isFree || isPro)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black),
                onPressed: () async {
                  final url = Uri.parse(isFree
                      ? SubscriptionService.stripePro
                      : SubscriptionService.stripeEnterprise);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                    isFree ? 'Mejorar a PRO Pyme' : 'Mejorar a Enterprise'),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                final url = Uri.parse(
                    'https://billing.stripe.com/p/session/placeholder');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Gestionar suscripción',
                  style: TextStyle(
                      color: AppColors.gold,
                      decoration: TextDecoration.underline)),
            )
          ],
        ),
      ),
    );
  }
}
