import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale built on Plus Jakarta Sans — modern, highly legible, and
/// distinct from the generic Roboto/SF look of a default Flutter/chatbot app.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(Color primaryText, Color secondaryText) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.5,
        height: 1.15,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.3,
        height: 1.2,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: primaryText,
        height: 1.25,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryText,
        height: 1.3,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryText,
        height: 1.3,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryText,
        height: 1.5,
      ),
      // bodyMedium/bodySmall/labelMedium are used as the primary readable
      // text almost everywhere (card descriptions, tile subtitles, settings
      // rows) — bumped a notch above their Material defaults (14/12/12) so
      // they clear the ~16px-body / no-sub-13px-for-content guidance that
      // came back from testers finding the app hard to read.
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: secondaryText,
        height: 1.5,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: secondaryText,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondaryText,
        height: 1.4,
      ),
    );
  }
}
