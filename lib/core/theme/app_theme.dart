import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'design_tokens.dart';

/// Guardian Plus Design System — Clean White Pro (Apple-inspired)
class AppTheme {
  AppTheme._();

  static ThemeData get dark => _buildLight();
  static ThemeData get light => _buildLight();

  static ThemeData _buildLight() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.cyberBlue,           // iOS blue #0A84FF
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE8F4FF),
      onPrimaryContainer: Color(0xFF0071E3),
      secondary: AppColors.emeraldGreen,       // iOS green
      onSecondary: Colors.white,
      tertiary: AppColors.neonPurple,          // Purple for Parent Hub
      onTertiary: Colors.white,
      error: AppColors.errorRed,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceElevated,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      cardTheme: _buildCardTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      inputDecorationTheme: _buildInputTheme(),
      iconTheme: const IconThemeData(color: AppColors.onSurface, size: DesignTokens.iconMd),
      dividerTheme: const DividerThemeData(color: AppColors.outline, thickness: 0.5),
      bottomNavigationBarTheme: _buildBottomNavTheme(),
      navigationBarTheme: _buildNavigationBarTheme(),
      snackBarTheme: _buildSnackBarTheme(),
      dialogTheme: _buildDialogTheme(),
      chipTheme: _buildChipTheme(),
      switchTheme: _buildSwitchTheme(),
      checkboxTheme: _buildCheckboxTheme(),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.cyberBlue,
        linearMinHeight: 3,
      ),
      extensions: const [GuardianThemeExtension()],
    );
  }

  // ── Typography (SF Pro feel via Inter) ────────────────────────────

  static TextTheme _buildTextTheme() {
    return GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
          color: AppColors.onSurface,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.25,
          color: AppColors.onSurface,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.75,
          color: AppColors.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.onSurface,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: AppColors.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: AppColors.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: AppColors.onSurface,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: AppColors.onSurface,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: AppColors.onSurfaceMuted,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: AppColors.onSurfaceMuted,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: AppColors.onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: AppColors.onSurface,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          color: AppColors.onSurfaceMuted,
        ),
      ),
    );
  }

  // ── AppBar — clean white, no shadow ──────────────────────────────

  static AppBarTheme _buildAppBarTheme() => const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.outline,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: AppColors.onSurface, size: 22),
      );

  // ── Card — flat, white, subtle border ─────────────────────────────

  static CardThemeData _buildCardTheme() => CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          side: const BorderSide(color: AppColors.outline, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      );

  // ── Elevated Button — Apple blue, rounded ─────────────────────────

  static ElevatedButtonThemeData _buildElevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyberBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXl,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
      );

  // ── Outlined Button ───────────────────────────────────────────────

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cyberBlue,
          side: const BorderSide(color: AppColors.outline, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXl,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
      );

  // ── Text Button ───────────────────────────────────────────────────

  static TextButtonThemeData _buildTextButtonTheme() =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.cyberBlue,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      );

  // ── Input — clean iOS-style ────────────────────────────────────────

  static InputDecorationTheme _buildInputTheme() => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingLg,
          vertical: DesignTokens.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.cyberBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        hintStyle: const TextStyle(color: AppColors.onSurfaceSubtle, fontSize: 15),
        labelStyle: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 14),
        prefixIconColor: AppColors.onSurfaceMuted,
        suffixIconColor: AppColors.onSurfaceMuted,
      );

  // ── Bottom Nav ────────────────────────────────────────────────────

  static BottomNavigationBarThemeData _buildBottomNavTheme() =>
      const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.cyberBlue,
        unselectedItemColor: AppColors.onSurfaceMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      );

  static NavigationBarThemeData _buildNavigationBarTheme() =>
      NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.cyberBlue.withOpacity(0.10),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.cyberBlue, size: 22);
          }
          return const IconThemeData(color: AppColors.onSurfaceMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.cyberBlue,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceMuted,
          );
        }),
      );

  // ── Snack Bar — charcoal pill ─────────────────────────────────────

  static SnackBarThemeData _buildSnackBarTheme() => SnackBarThemeData(
        backgroundColor: AppColors.onSurface,
        contentTextStyle: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      );

  // ── Dialog ───────────────────────────────────────────────────────

  static DialogThemeData _buildDialogTheme() => DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl)),
        elevation: 0,
        shadowColor: Colors.transparent,
      );

  // ── Chip ─────────────────────────────────────────────────────────

  static ChipThemeData _buildChipTheme() => ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.cyberBlue.withOpacity(0.12),
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      );

  // ── Switch — iOS style ────────────────────────────────────────────

  static SwitchThemeData _buildSwitchTheme() => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.cyberBlue;
          return AppColors.outlineVariant;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      );

  // ── Checkbox ─────────────────────────────────────────────────────

  static CheckboxThemeData _buildCheckboxTheme() => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.cyberBlue;
          return Colors.transparent;
        }),
        side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      );
}

// ── Theme Extension ───────────────────────────────────────────────────────

@immutable
class GuardianThemeExtension extends ThemeExtension<GuardianThemeExtension> {
  const GuardianThemeExtension({
    this.glassBackground = AppColors.surface,
    this.glassBorder = AppColors.outline,
    this.riskCritical = AppColors.errorRed,
    this.riskHigh = AppColors.warningOrange,
    this.riskMedium = AppColors.warningAmber,
    this.riskLow = AppColors.emeraldGreen,
    this.riskNone = AppColors.onSurfaceMuted,
  });

  final Color glassBackground;
  final Color glassBorder;
  final Color riskCritical;
  final Color riskHigh;
  final Color riskMedium;
  final Color riskLow;
  final Color riskNone;

  @override
  GuardianThemeExtension copyWith({
    Color? glassBackground,
    Color? glassBorder,
    Color? riskCritical,
    Color? riskHigh,
    Color? riskMedium,
    Color? riskLow,
    Color? riskNone,
  }) =>
      GuardianThemeExtension(
        glassBackground: glassBackground ?? this.glassBackground,
        glassBorder: glassBorder ?? this.glassBorder,
        riskCritical: riskCritical ?? this.riskCritical,
        riskHigh: riskHigh ?? this.riskHigh,
        riskMedium: riskMedium ?? this.riskMedium,
        riskLow: riskLow ?? this.riskLow,
        riskNone: riskNone ?? this.riskNone,
      );

  @override
  GuardianThemeExtension lerp(GuardianThemeExtension? other, double t) {
    if (other == null) return this;
    return GuardianThemeExtension(
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      riskCritical: Color.lerp(riskCritical, other.riskCritical, t)!,
      riskHigh: Color.lerp(riskHigh, other.riskHigh, t)!,
      riskMedium: Color.lerp(riskMedium, other.riskMedium, t)!,
      riskLow: Color.lerp(riskLow, other.riskLow, t)!,
      riskNone: Color.lerp(riskNone, other.riskNone, t)!,
    );
  }
}
