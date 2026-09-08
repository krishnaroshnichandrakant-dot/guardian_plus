import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'design_tokens.dart';

/// Guardian Plus Design System — Dark Tech (v2)
///
/// Space Grotesk for headings (authority, tech), Inter for body (readable),
/// per-role accent identities unified by a single dark base.
class AppTheme {
  AppTheme._();

  static ThemeData get dark => _buildLight();
  static ThemeData get light => _buildLight();

  static ThemeData _buildLight() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.emeraldGreen,
      onPrimary: AppColors.onPrimary,
      primaryContainer: Color(0xFFD1FAE5),
      onPrimaryContainer: AppColors.emeraldGreenDark,
      secondary: AppColors.cyberBlue,
      onSecondary: AppColors.onPrimary,
      secondaryContainer: Color(0xFFE0F2FE),
      onSecondaryContainer: AppColors.cyberBlueDark,
      tertiary: AppColors.neonPurple,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFEDE9FE),
      onTertiaryContainer: AppColors.neonPurpleDark,
      error: AppColors.errorRed,
      onError: Colors.white,
      errorContainer: Color(0xFFFFE4E6),
      onErrorContainer: AppColors.safetyPinkDark,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceHighest,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: Color(0x14000000),
      scrim: Color(0x66000000),
      inverseSurface: Color(0xFF0F1E17),
      onInverseSurface: AppColors.surface,
      inversePrimary: AppColors.emeraldGreenLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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
      dividerTheme: const DividerThemeData(color: AppColors.outline, thickness: 1.0),
      bottomNavigationBarTheme: _buildBottomNavTheme(),
      navigationBarTheme: _buildNavigationBarTheme(),
      snackBarTheme: _buildSnackBarTheme(),
      dialogTheme: _buildDialogTheme(),
      chipTheme: _buildChipTheme(),
      switchTheme: _buildSwitchTheme(),
      checkboxTheme: _buildCheckboxTheme(),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.emeraldGreen,
        linearMinHeight: 3,
      ),
      extensions: const [GuardianThemeExtension()],
    );
  }

  // ── Typography ─────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme() {
    // Space Grotesk for headings, Inter for body text — defined inline per style
    return TextTheme(
      // Display / Hero
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 57, fontWeight: FontWeight.w700,
        color: AppColors.onSurface, letterSpacing: -1.5, height: 1.1,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 45, fontWeight: FontWeight.w700,
        color: AppColors.onSurface, letterSpacing: -1.0, height: 1.1,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 36, fontWeight: FontWeight.w700,
        color: AppColors.onSurface, letterSpacing: -0.5, height: 1.2,
      ),
      // Headlines — Space Grotesk
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: AppColors.onSurface, letterSpacing: -0.5, height: 1.2,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.w600,
        color: AppColors.onSurface, letterSpacing: -0.25, height: 1.25,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 24, fontWeight: FontWeight.w600,
        color: AppColors.onSurface, height: 1.3,
      ),
      // Titles — Space Grotesk
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22, fontWeight: FontWeight.w600,
        color: AppColors.onSurface, letterSpacing: -0.15, height: 1.3,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: AppColors.onSurface, letterSpacing: 0.1, height: 1.4,
      ),
      titleSmall: GoogleFonts.spaceGrotesk(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.onSurface, letterSpacing: 0.1, height: 1.4,
      ),
      // Body — Inter
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: AppColors.onSurface, height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceMuted, height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceMuted, height: 1.5,
      ),
      // Labels — Inter
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.onSurface, letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceMuted, letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceSubtle, letterSpacing: 0.5,
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────

  static AppBarTheme _buildAppBarTheme() => AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: Colors.black.withValues(alpha: 0.5),
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    titleTextStyle: GoogleFonts.spaceGrotesk(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
      letterSpacing: -0.2,
    ),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.navBarBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Card ───────────────────────────────────────────────────────────────

  static CardThemeData _buildCardTheme() => CardThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      side: const BorderSide(color: AppColors.outline, width: 1.0),
    ),
    margin: EdgeInsets.zero,
  );

  // ── Buttons ────────────────────────────────────────────────────────────

  static ElevatedButtonThemeData _buildElevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyberBlue,
          foregroundColor: const Color(0xFF000D12),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, DesignTokens.buttonHeightLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          animationDuration: DesignTokens.animFast,
        ),
      );

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cyberBlue,
          minimumSize: const Size(double.infinity, DesignTokens.buttonHeightLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          side: const BorderSide(color: AppColors.cyberBlue, width: 1.5),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static TextButtonThemeData _buildTextButtonTheme() =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.cyberBlue,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // ── Input ──────────────────────────────────────────────────────────────

  static InputDecorationTheme _buildInputTheme() => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceElevated,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(color: AppColors.outline, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(color: AppColors.outline, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(color: AppColors.cyberBlue, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(color: AppColors.errorRed, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
    ),
    labelStyle: GoogleFonts.inter(
      color: AppColors.onSurfaceMuted,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: GoogleFonts.inter(
      color: AppColors.onSurfaceSubtle,
      fontSize: 14,
    ),
    errorStyle: GoogleFonts.inter(
      color: AppColors.errorRed,
      fontSize: 12,
    ),
    prefixIconColor: AppColors.onSurfaceMuted,
    suffixIconColor: AppColors.onSurfaceMuted,
  );

  // ── Bottom Navigation ──────────────────────────────────────────────────

  static BottomNavigationBarThemeData _buildBottomNavTheme() =>
      const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBarBackground,
        selectedItemColor: AppColors.cyberBlue,
        unselectedItemColor: AppColors.onSurfaceMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      );

  static NavigationBarThemeData _buildNavigationBarTheme() =>
      NavigationBarThemeData(
        backgroundColor: AppColors.navBarBackground,
        indicatorColor: AppColors.cyberBlue.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.cyberBlue : AppColors.onSurfaceMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.cyberBlue : AppColors.onSurfaceMuted,
            size: 22,
          );
        }),
      );

  // ── SnackBar ───────────────────────────────────────────────────────────

  static SnackBarThemeData _buildSnackBarTheme() => SnackBarThemeData(
    backgroundColor: AppColors.surfaceHighest,
    contentTextStyle: GoogleFonts.inter(
      color: AppColors.onSurface,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    actionTextColor: AppColors.cyberBlue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 0,
  );

  // ── Dialog ─────────────────────────────────────────────────────────────

  static DialogThemeData _buildDialogTheme() => DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      side: const BorderSide(color: AppColors.outline, width: 1.0),
    ),
    titleTextStyle: GoogleFonts.spaceGrotesk(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),
    contentTextStyle: GoogleFonts.inter(
      fontSize: 14,
      color: AppColors.onSurfaceMuted,
      height: 1.5,
    ),
  );

  // ── Chip ───────────────────────────────────────────────────────────────

  static ChipThemeData _buildChipTheme() => ChipThemeData(
    backgroundColor: AppColors.surfaceElevated,
    selectedColor: AppColors.cyberBlue.withValues(alpha: 0.2),
    labelStyle: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceMuted,
    ),
    side: const BorderSide(color: AppColors.outline, width: 1.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  );

  // ── Switch ─────────────────────────────────────────────────────────────

  static SwitchThemeData _buildSwitchTheme() => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return const Color(0xFF000D12);
      return AppColors.onSurfaceMuted;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.cyberBlue;
      return AppColors.surfaceHighest;
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );

  // ── Checkbox ───────────────────────────────────────────────────────────

  static CheckboxThemeData _buildCheckboxTheme() => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.cyberBlue;
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(const Color(0xFF000D12)),
    side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

// ── Theme Extension — per-role accent colors ───────────────────────────────

@immutable
class GuardianThemeExtension extends ThemeExtension<GuardianThemeExtension> {
  const GuardianThemeExtension({
    this.safetyAccent    = AppColors.safetyPink,
    this.cyberAccent     = AppColors.cyberBlue,
    this.familyAccent    = AppColors.neonPurple,
    this.detectiveAccent = AppColors.detectiveTeal,
    this.scamAccent      = AppColors.scamAmber,
    this.safeColor       = AppColors.emeraldGreen,
    this.dangerColor     = AppColors.errorRed,
    this.warningColor    = AppColors.warningAmber,
  });

  final Color safetyAccent;
  final Color cyberAccent;
  final Color familyAccent;
  final Color detectiveAccent;
  final Color scamAccent;
  final Color safeColor;
  final Color dangerColor;
  final Color warningColor;

  @override
  GuardianThemeExtension copyWith({
    Color? safetyAccent,
    Color? cyberAccent,
    Color? familyAccent,
    Color? detectiveAccent,
    Color? scamAccent,
    Color? safeColor,
    Color? dangerColor,
    Color? warningColor,
  }) =>
      GuardianThemeExtension(
        safetyAccent:    safetyAccent    ?? this.safetyAccent,
        cyberAccent:     cyberAccent     ?? this.cyberAccent,
        familyAccent:    familyAccent    ?? this.familyAccent,
        detectiveAccent: detectiveAccent ?? this.detectiveAccent,
        scamAccent:      scamAccent      ?? this.scamAccent,
        safeColor:       safeColor       ?? this.safeColor,
        dangerColor:     dangerColor     ?? this.dangerColor,
        warningColor:    warningColor    ?? this.warningColor,
      );

  @override
  GuardianThemeExtension lerp(GuardianThemeExtension? other, double t) {
    if (other == null) return this;
    return GuardianThemeExtension(
      safetyAccent:    Color.lerp(safetyAccent,    other.safetyAccent,    t)!,
      cyberAccent:     Color.lerp(cyberAccent,     other.cyberAccent,     t)!,
      familyAccent:    Color.lerp(familyAccent,    other.familyAccent,    t)!,
      detectiveAccent: Color.lerp(detectiveAccent, other.detectiveAccent, t)!,
      scamAccent:      Color.lerp(scamAccent,      other.scamAccent,      t)!,
      safeColor:       Color.lerp(safeColor,       other.safeColor,       t)!,
      dangerColor:     Color.lerp(dangerColor,     other.dangerColor,     t)!,
      warningColor:    Color.lerp(warningColor,    other.warningColor,    t)!,
    );
  }
}
