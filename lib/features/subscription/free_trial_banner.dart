import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:aduana_801/core/theme/app_text_styles.dart';

class FreeTrialBanner extends StatefulWidget {
  const FreeTrialBanner({super.key});

  @override
  State<FreeTrialBanner> createState() => _FreeTrialBannerState();
}

class _FreeTrialBannerState extends State<FreeTrialBanner> {
  String? _tier;
  int _daysLeft = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTier();
  }

  Future<void> _loadTier() async {
    final prefs = await SharedPreferences.getInstance();
    final tier = prefs.getString('subscription_tier');
    final trialStartStr = prefs.getString('trial_start');

    int daysLeft = 0;
    if (tier == 'trial' && trialStartStr != null) {
      final trialStart = DateTime.parse(trialStartStr);
      final now = DateTime.now();
      final diff = now.difference(trialStart).inDays;
      daysLeft = 14 - diff;
    }

    setState(() {
      _tier = tier;
      _daysLeft = daysLeft;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();

    if (_tier == 'pro' || _tier == 'agente') {
      return const SizedBox.shrink();
    }

    Color bgColor;
    const Color textColor = AppColors.bg;
    String message;
    String buttonText;

    if (_tier == null || _tier == 'free') {
      bgColor = AppColors.gold;
      message = 'Prueba PRO gratis 14 días — Sin tarjeta';
      buttonText = 'Ver →';
    } else if (_tier == 'trial' && _daysLeft > 0) {
      bgColor = const Color(0xFF10B981);
      message = '⚡ PRO activo · $_daysLeft días restantes';
      buttonText = 'Suscribirse →';
    } else {
      bgColor = AppColors.red;
      message = '⏰ Tu prueba terminó. Actualiza para seguir.';
      buttonText = '→';
    }

    return GestureDetector(
      onTap: () => context.go('/pricing'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: bgColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelLarge.copyWith(color: textColor),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                buttonText,
                style: AppTextStyles.labelMedium.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
