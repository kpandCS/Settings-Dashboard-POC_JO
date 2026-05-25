import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── EG A/S Construction BrandSync Design Tokens ──────────────────────────────
//
// Source: construction-mobile-pocketlink-app / lib/core/theme/
// Do NOT use raw Color(0x…) literals elsewhere — reference these constants.

abstract class AppColors {
  // ── Brand / Primary ──────────────────────────────────────────────────────
  static const brandOrange = Color(0xFFA24907); // Orange-600 — primary action
  static const brandOrangeLight =
      Color(0xFFD26D2B); // Orange-400 — dark-mode primary
  static const brandOrangeContainer =
      Color(0xFFFFF0E6); // soft tint for icon bg / chips
  static const brandOrangeDark =
      Color(0xFF6B2E03); // on-container label colour

  // ── Neutral Scale ────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF5D6472);
  static const textDisabled = Color(0xFF9CA3AF);

  // ── Surface ──────────────────────────────────────────────────────────────
  static const surfaceBase = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFF9FAFB); // page background
  static const surfaceHover = Color(0xFFEFF0F8); // hovered / highest

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const successGreen = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFFE8F5E9);
  static const manualBlue = Color(0xFF3D5A87);
  static const lightManualBlue = Color(0xFFE8EDF5);
  static const errorRed = Color(0xFFB00020);

  // ── Border / Divider ─────────────────────────────────────────────────────
  static const outline = Color(0xFFE0E0E0);
  static const outlineVariant = Color(0xFFEEEEEE);
}

// ── Border Radius Tokens ─────────────────────────────────────────────────────
abstract class AppRadius {
  static const double extraSmall = 6;
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double pill = 120;
}

// ── Spacing Tokens ───────────────────────────────────────────────────────────
abstract class AppSpacing {
  static const double pageHorizontal = 16;
  static const double buttonVertical = 12;
  static const double buttonHorizontal = 24;
}

// ── Theme ────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandOrange,
      brightness: Brightness.light,
      primary: AppColors.brandOrange,
      onPrimary: Colors.white,
      primaryContainer: AppColors.brandOrangeContainer,
      onPrimaryContainer: AppColors.brandOrangeDark,
      secondary: AppColors.textSecondary,
      onSecondary: Colors.white,
      surface: AppColors.surfaceBase,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceHover,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      error: AppColors.errorRed,
    );

    // Roboto base — inherit colour from colorScheme so we don't hard-code
    // individual text colours in every widget.
    final textTheme = GoogleFonts.robotoTextTheme().copyWith(
      displayLarge: GoogleFonts.roboto(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      // Used for section labels and "Smart Defaults" header badge
      labelMedium: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.brandOrange,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceBase,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.outline,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.brandOrange),
        actionsIconTheme: const IconThemeData(color: AppColors.brandOrange),
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────
      // elevation=0, 1px border, large radius — matches BrandSync card spec
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: const BorderSide(color: AppColors.outline),
        ),
        color: AppColors.surfaceBase,
        margin: EdgeInsets.zero,
      ),

      // ── Switch ─────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandOrange;
          }
          return const Color(0xFFCCCCCC);
        }),
        trackOutlineColor:
            WidgetStateProperty.resolveWith((_) => Colors.transparent),
      ),

      // ── Divider ────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 0,
      ),

      // ── FilledButton ───────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.outline,
          disabledForegroundColor: AppColors.textDisabled,
          textStyle: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.buttonVertical,
            horizontal: AppSpacing.buttonHorizontal,
          ),
          elevation: 0,
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandOrange,
          side: const BorderSide(color: AppColors.outline),
          textStyle: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.buttonVertical,
            horizontal: AppSpacing.buttonHorizontal,
          ),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandOrange,
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
      ),

      // ── Input / TextField ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide:
              const BorderSide(color: AppColors.brandOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: AppColors.textDisabled,
        ),
        labelStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: GoogleFonts.roboto(
          fontSize: 12,
          color: AppColors.brandOrange,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // ── Snack Bar ──────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1C1C1E),
        contentTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── List Tile ──────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),

      // ── NavigationBar (bottom nav) ─────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceBase,
        indicatorColor: AppColors.brandOrangeContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.brandOrange
                : AppColors.textSecondary,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? AppColors.brandOrange
                : AppColors.textSecondary,
          );
        }),
      ),
    );
  }
}
