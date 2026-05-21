import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color clubNavy = Color(0xFF071D2B);
  static const Color deepTeal = Color(0xFF083B3F);
  static const Color squashGreen = Color(0xFF00A86B);
  static const Color courtGold = Color(0xFFF6B23C);
  static const Color rallyOrange = Color(0xFFFF7A45);
  static const Color dangerRed = Color(0xFFE84855);
  static const Color graphite = Color(0xFF17212B);
  static const Color mist = Color(0xFFF3F7F6);
  static const Color porcelain = Color(0xFFFAFCFB);
  static const Color lineGrey = Color(0xFFE0E6E4);

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [clubNavy, deepTeal, squashGreen],
  );
}
