import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'design_tokens.dart';

/// Guardian Plus Design System — Fresh Light Theme
class AppTheme {
  AppTheme._();

  static ThemeData get dark => _buildLight();
  static ThemeData get light => _buildLight();

  static ThemeData _buildLight() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.cyberBlue,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.emeraldGreen,
      onSecondary: AppColors.onPrimary,
      tertiary: AppColors.neonPurple,
      onTertiary: AppColors.onPrimary,
      error: AppColors.errorRed,
      onError: AppColors.onPrimary,
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
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputTheme(),
      iconTheme: const IconThemeData(color: AppColors.onSurface, size: DesignTokens.iconMd),
      dividerTheme: const DividerThemeData(color: AppColors.outline, thickness: 1.0),
      bottomNavigationBarTheme: _buildBottomNavTheme(),
      navigationBarTheme: _buildNavigationBarTheme(),
      snackBarTheme: _buildSnackBarTheme(),
      dialogTheme: _buildDialogTheme(),
      chipTheme: _buildChipTheme(colorScheme),
      switchTheme: _buildSwitchTheme(colorScheme),
      checkboxTheme: _buildCheckboxTheme(colorScheme),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.cyberBlue,
        linearMinHeight: 4,
      ),
      extensions: const [GuardianThemeExtension()],
    );
  }

  static TextTheme _buildTextTheme() {
    return GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.25,
          color: AppColors.onSurface,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w300,
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
          letterSpacing: -0.5,
          color: AppColors.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          color: AppColors.onSurface,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: AppColors.onSurface,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: AppColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: AppColors.onSurfaceMuted,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: AppColors.onSurfaceMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: AppColors.onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.onSurface,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceMuted,
        ),
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme() => const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        iconTheme: IconThemeData(color: AppColors.onSurface),
      );

  static CardThemeData _buildCardTheme() => CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shadowColor: const Color(0x0F0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          side: const BorderSide(color: AppColors.outline, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      );

  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme cs) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyberBlue,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: const Color(0x1F4F46E5),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXl,
            vertical: DesignTokens.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
      );

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme cs) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cyberBlue,
          side: const BorderSide(color: AppColors.cyberBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXl,
            vertical: DesignTokens.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
      );

  static TextButtonThemeData _buildTextButtonTheme(ColorScheme cs) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.cyberBlue,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      );

  static InputDecorationTheme _buildInputTheme() => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingLg,
          vertical: DesignTokens.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.cyberBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        hintStyle: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 14),
        prefixIconColor: AppColors.onSurfaceMuted,
        suffixIconColor: AppColors.onSurfaceMuted,
      );

  static BottomNavigationBarThemeData _buildBottomNavTheme() =>
      const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.cyberBlue,
        unselectedItemColor: AppColors.onSurfaceMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      );

  static NavigationBarThemeData _buildNavigationBarTheme() =>
      NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 4,
        indicatorColor: AppColors.cyberBlue.withOpacity(0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.cyberBlue, size: 24);
          }
          return const IconThemeData(color: AppColors.onSurfaceMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.cyberBlue,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceMuted,
          );
        }),
      );

  static SnackBarThemeData _buildSnackBarTheme() => SnackBarThemeData(
        backgroundColor: AppColors.onSurface,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
        behavior: SnackBarBehavior.floating,
      );

  static DialogThemeData _buildDialogTheme() => DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusXl)),
        elevation: 8,
      );

  static ChipThemeData _buildChipTheme(ColorScheme cs) => ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.cyberBlue.withOpacity(0.15),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
      );

  static SwitchThemeData _buildSwitchTheme(ColorScheme cs) => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.onSurfaceMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.cyberBlue;
          }
          return AppColors.surfaceHighest;
        }),
      );

  static CheckboxThemeData _buildCheckboxTheme(ColorScheme cs) => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.cyberBlue;
          return Colors.transparent;
        }),
        side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      );
}

/// Theme extension for Guardian Plus-specific design tokens
@immutable
class GuardianThemeExtension extends ThemeExtension<GuardianThemeExtension> {
  const GuardianThemeExtension({
    this.glassBackground = const Color(0xFFFFFFFF),
    this.glassBorder = const Color(0xFFE2E8F0),
    this.riskCritical = AppColors.errorRed,
    this.riskHigh = const Color(0xFFFF6B35),
    this.riskMedium = const Color(0xFFFFB800),
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
