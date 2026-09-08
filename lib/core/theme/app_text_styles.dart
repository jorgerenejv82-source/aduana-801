import 'package:flutter/material.dart';

/// Centralized typography scale for Aduanas 801
/// Based on Material Design type scale adapted for dark B2B dashboard
class AppTextStyles {
  // Display (large titles, hero numbers)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: Color(0xFFE2E8F0),
    letterSpacing: -0.5,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Color(0xFFE2E8F0),
    letterSpacing: -0.3,
  );

  // Headlines (section titles, card headers)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Color(0xFFE2E8F0),
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE2E8F0),
  );
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE2E8F0),
  );

  // Body (main content)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color(0xFFE2E8F0),
    height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFFE2E8F0),
    height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Color(0xFF8A9BB5),
    height: 1.4,
  );

  // Labels (chips, badges, buttons)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFFE2E8F0),
    letterSpacing: 0.1,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Color(0xFF8A9BB5),
    letterSpacing: 0.5,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Color(0xFF8A9BB5),
    letterSpacing: 0.8,
  );

  // Monospace (amounts, codes, fracciones arancelarias)
  static const TextStyle mono = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFFE2E8F0),
    fontFamily: 'monospace',
  );
  static const TextStyle monoLarge = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    color: Color(0xFFDCA311), // gold for amounts
    fontFamily: 'monospace',
  );

  // Semantic colors
  static TextStyle get success =>
      bodyMedium.copyWith(color: const Color(0xFF10B981));
  static TextStyle get error =>
      bodyMedium.copyWith(color: const Color(0xFFEF4444));
  static TextStyle get warning =>
      bodyMedium.copyWith(color: const Color(0xFFF59E0B));
  static TextStyle get link => bodyMedium.copyWith(
      color: const Color(0xFF38BDF8), decoration: TextDecoration.underline);
}
