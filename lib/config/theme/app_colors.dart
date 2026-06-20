import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // ─── Core Palette (Premium Sports Theme) ───────────────────────────
  /// Deep midnight black/navy – scaffold & splash background
  static const Color scaffoldDark = Color(0xFF0B0E14);

  /// Sleek dark charcoal – cards, containers, elevated surfaces
  static const Color cardDark = Color(0xFF161B26);

  /// Premium electric blue from the logo – primary / accent
  static const Color electricBlue = Color(0xFF0A84FF);

  /// Pure white – headers, bold text
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// Soft metallic gray – subtitles, secondary text, timestamps
  static const Color subtitleGray = Color(0xFF8E9AA8);

  // ─── Semantic Colors ───────────────────────────────────────────────
  static const Color dangerRed = Color(0xFFE84855);
  static const Color successGreen = Color(0xFF34C759);
  static const Color warningAmber = Color(0xFFFFB800);

  // ─── Surface Variants ──────────────────────────────────────────────
  /// Slightly lighter card for hover / pressed states
  static const Color cardDarkHover = Color(0xFF1C2333);

  /// Subtle border / divider color
  static const Color divider = Color(0xFF252D3D);

  /// Input field border (unfocused)
  static const Color inputBorder = Color(0xFF2A3347);

  // ─── Legacy Aliases (backward-compat for existing widgets) ─────────
  static const Color clubNavy = scaffoldDark;
  static const Color deepTeal = scaffoldDark;
  static const Color squashGreen = electricBlue;
  static const Color courtGold = subtitleGray;
  static const Color rallyOrange = electricBlue;
  static const Color graphite = cardDark;
  static const Color mist = scaffoldDark;
  static const Color porcelain = cardDark;
  static const Color lineGrey = divider;

  static const Color primaryBlue = electricBlue;
  static const Color matteBlack = scaffoldDark;
  static const Color charcoal = cardDark;
  static const Color metallicGray = subtitleGray;

  // ─── Gradients ─────────────────────────────────────────────────────
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [scaffoldDark, cardDark, electricBlue],
  );

  /// Subtle blue glow gradient for hero sections
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0B0E14),
      Color(0xFF0D1420),
      Color(0xFF0B0E14),
    ],
  );
}
