import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;
  AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> _safeLog(Future<void> Function() logAction) async {
    try {
      await logAction();
    } catch (e) {
      debugPrint('Analytics failed (ignored): $e');
    }
  }

  // ---- Auth Events ----
  Future<void> logLogin(String method) =>
      _safeLog(() => _analytics.logLogin(loginMethod: method));

  Future<void> logSignUp(String method) =>
      _safeLog(() => _analytics.logSignUp(signUpMethod: method));

  Future<void> setUserPersona(String persona) =>
      _safeLog(() => _analytics.setUserProperty(name: 'persona', value: persona));

  // ---- Screen Events ----
  Future<void> logScreen(String screenName) =>
      _safeLog(() => _analytics.logScreenView(screenName: screenName));

  // ---- Feature Events ----
  Future<void> logFeatureUsed(String featureName, {String? persona}) =>
      _safeLog(() => _analytics.logEvent(name: 'feature_used', parameters: {
        'feature': featureName,
        if (persona != null) 'persona': persona,
      }));

  Future<void> logCalculation(String calculatorType, {double? result}) =>
      _safeLog(() => _analytics.logEvent(name: 'calculation_performed', parameters: {
        'type': calculatorType,
        if (result != null) 'result_usd': result,
      }));

  Future<void> logCopilotoQuery(String persona) => 
      _safeLog(() => _analytics.logEvent(name: 'copiloto_query', parameters: {'persona': persona}));

  Future<void> logShare(String contentType, String method) => 
      _safeLog(() => _analytics.logShare(contentType: contentType, itemId: contentType, method: method));

  Future<void> logOnboardingStep(int step, String answer) =>
      _safeLog(() => _analytics.logEvent(name: 'onboarding_step', parameters: {
        'step': step,
        'answer': answer,
      }));

  Future<void> logOnboardingCompleted(String persona) => 
      _safeLog(() => _analytics.logEvent(name: 'onboarding_completed', parameters: {'persona': persona}));

  Future<void> logUpgradePrompt(String feature, String requiredPlan) =>
      _safeLog(() => _analytics.logEvent(name: 'upgrade_prompt_shown', parameters: {
        'feature': feature,
        'required_plan': requiredPlan,
      }));

  Future<void> logUpgradeClick(String plan) =>
      _safeLog(() => _analytics.logEvent(name: 'upgrade_clicked', parameters: {'plan': plan}));

  Future<void> logPersonaSelected(String persona) => 
      _safeLog(() => _analytics.logEvent(name: 'persona_selected', parameters: {'persona': persona}));
}
