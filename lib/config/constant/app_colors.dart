import 'package:flutter/material.dart';

/// Semantic color tokens for Voya.
///
/// Never hardcode a hex value in a widget — add or reuse a token here so the
/// whole app can be re-themed (and dark mode kept in sync) from one place.
class AppColors {
  const AppColors._();

  // Brand — deep indigo/violet communicates intelligence, trust, technology.
  static const Color primary = Color(0xFF4F46E5); // indigo-600
  static const Color primaryLight = Color(0xFF818CF8); // indigo-400
  static const Color primaryDark = Color(0xFF3730A3); // indigo-800
  static const Color accent = Color(0xFF7C3AED); // violet-600

  // Light theme surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceAltLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Dark theme surfaces — the interview screen leans on this: avatar and
  // waveform become the visual focus against a calm near-black indigo.
  static const Color backgroundDark = Color(0xFF0B0F1D);
  static const Color surfaceDark = Color(0xFF141A2B);
  static const Color surfaceAltDark = Color(0xFF1C2338);
  static const Color borderDark = Color(0xFF262E45);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFFA0AAC2);
  static const Color textMutedDark = Color(0xFF6B7591);

  // Semantic status colors (same in both themes for consistent meaning)
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0EA5E9);

  // Voice / avatar state accents
  static const Color listening = Color(0xFF22D3EE); // cyan — mic active
  static const Color speaking = Color(0xFF818CF8); // indigo — AI speaking
  static const Color thinking = Color(0xFFA78BFA); // violet — processing

  static const List<Color> primaryGradient = [primary, accent];
}
