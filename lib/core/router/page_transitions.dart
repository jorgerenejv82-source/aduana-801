import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for GoRouter
/// Uses fade + slight vertical slide for a premium feel
class AppPageTransition {
  /// Builds a CustomTransitionPage with fade + slide from bottom
  static CustomTransitionPage<void> buildPage({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade + subtle upward slide
        const begin = Offset(0.0, 0.03);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final slideTween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fadeTween =
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// For modal/dialog-style screens: scale + fade from center
  static CustomTransitionPage<void> buildModalPage({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleTween = Tween(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack));
        final fadeTween = Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut));

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }
}
