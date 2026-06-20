import 'package:flutter/material.dart';
import 'package:honset_app/config/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();

  // ─────────────────────────────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────────────────────────────
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.electricBlue,
      brightness: Brightness.light,
      primary: AppColors.electricBlue,
      secondary: AppColors.subtitleGray,
      tertiary: AppColors.electricBlue,
      surface: const Color(0xFFF5F6FA),
      error: AppColors.dangerRed,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF0F2F7),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.scaffoldDark,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // DARK THEME  –  Premium Sports-App Palette
  // ─────────────────────────────────────────────────────────────────────
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.electricBlue,
      brightness: Brightness.dark,
      primary: AppColors.electricBlue,
      onPrimary: AppColors.pureWhite,
      secondary: AppColors.subtitleGray,
      onSecondary: AppColors.pureWhite,
      tertiary: AppColors.electricBlue,
      surface: AppColors.cardDark,
      onSurface: AppColors.pureWhite,
      onSurfaceVariant: AppColors.subtitleGray,
      error: AppColors.dangerRed,
      outline: AppColors.inputBorder,
      outlineVariant: AppColors.divider,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.scaffoldDark,
      cardColor: AppColors.cardDark,
      canvasColor: AppColors.scaffoldDark,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: AppColors.scaffoldDark,
        foregroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        titleTextStyle: const TextStyle(
          color: AppColors.pureWhite,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
        ),
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.electricBlue,
        unselectedItemColor: AppColors.subtitleGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        indicatorColor: AppColors.electricBlue.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.electricBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.subtitleGray,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.electricBlue);
          }
          return const IconThemeData(color: AppColors.subtitleGray);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardDarkHover,
        selectedColor: AppColors.electricBlue,
        labelStyle: const TextStyle(color: AppColors.pureWhite),
        secondaryLabelStyle: const TextStyle(color: AppColors.pureWhite),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardDark,
        contentTextStyle: const TextStyle(color: AppColors.pureWhite),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // SHARED BASE
  // ─────────────────────────────────────────────────────────────────────
  static ThemeData _base(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // ── Typography ──────────────────────────────────────────────────
      textTheme: Typography.material2021().englishLike.apply(
        bodyColor: isDark ? AppColors.subtitleGray : scheme.onSurface,
        displayColor: isDark ? AppColors.pureWhite : scheme.onSurface,
      ).copyWith(
        // Headlines – pure white, bold
        headlineLarge: TextStyle(
          color: isDark ? AppColors.pureWhite : scheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: isDark ? AppColors.pureWhite : scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: isDark ? AppColors.pureWhite : scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        // Titles – pure white
        titleLarge: TextStyle(
          color: isDark ? AppColors.pureWhite : scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: isDark ? AppColors.pureWhite : scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: isDark ? AppColors.pureWhite : scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        // Body – metallic gray for comfortable reading
        bodyLarge: TextStyle(
          color: isDark ? AppColors.subtitleGray : scheme.onSurface,
        ),
        bodyMedium: TextStyle(
          color: isDark ? AppColors.subtitleGray : scheme.onSurface,
        ),
        bodySmall: TextStyle(
          color: isDark ? AppColors.subtitleGray : scheme.onSurface,
          fontSize: 12,
        ),
        // Labels
        labelLarge: TextStyle(
          color: isDark ? AppColors.pureWhite : scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: isDark ? AppColors.subtitleGray : scheme.onSurface,
        ),
        labelSmall: TextStyle(
          color: isDark ? AppColors.subtitleGray : scheme.onSurface,
          fontSize: 11,
        ),
      ),

      // ── Cards ───────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.cardDark : scheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDark
              ? const BorderSide(color: AppColors.divider, width: 0.5)
              : BorderSide.none,
        ),
      ),

      // ── Buttons ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: AppColors.pureWhite,
          minimumSize: const Size(48, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: AppColors.pureWhite,
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.electricBlue : scheme.primary,
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(
            color: isDark ? AppColors.electricBlue : scheme.primary,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppColors.electricBlue : scheme.primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      // ── Input Fields ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.cardDark : scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          color: isDark ? AppColors.subtitleGray.withValues(alpha: 0.6) : null,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.inputBorder : scheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.inputBorder : scheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.electricBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dangerRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
        ),
      ),

      // ── Misc ────────────────────────────────────────────────────────
      iconTheme: IconThemeData(
        color: isDark ? AppColors.subtitleGray : scheme.onSurface,
      ),
      listTileTheme: ListTileThemeData(
        textColor: isDark ? AppColors.pureWhite : scheme.onSurface,
        iconColor: isDark ? AppColors.subtitleGray : scheme.onSurfaceVariant,
        tileColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.pureWhite
              : AppColors.subtitleGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.electricBlue
              : isDark
                  ? AppColors.divider
                  : scheme.outlineVariant;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.electricBlue,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.electricBlue,
        foregroundColor: AppColors.pureWhite,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.cardDark : scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.cardDark : scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
