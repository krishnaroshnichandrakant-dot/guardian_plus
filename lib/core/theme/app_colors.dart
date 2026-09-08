import 'package:flutter/material.dart';

/// Guardian Plus — Clean Light Design System
///
/// Refined light theme with crisp white cards, clean backgrounds,
/// high-contrast readable typography, and vibrant emerald, cyan, coral, and purple accents.
class AppColors {
  AppColors._();

  // ── Clean Light Backgrounds ─────────────────────────────────────────
  /// Primary scaffold background — clean soft light mint-white
  static const background       = Color(0xFFF4F7F5);
  /// Primary card and container surface
  static const surface          = Color(0xFFFFFFFF);
  static const cardBackground   = Color(0xFFFFFFFF);
  /// Elevated card surface (modals, active containers, inputs)
  static const surfaceElevated  = Color(0xFFEDF4F0);
  /// Highest surface (chip backgrounds, borders, highlights)
  static const surfaceHighest   = Color(0xFFE2EFE9);
  static const navBarBackground = Color(0xFFFFFFFF);

  // ── Borders & Outlines ──────────────────────────────────────────────
  static const outline          = Color(0xFFDFE9E4);
  static const outlineVariant   = Color(0xFFCCDCD4);

  // ── Typography (High Contrast & Legible) ───────────────────────────
  static const onSurface        = Color(0xFF0F1E17);  // Deep dark slate/forest for sharp readability
  static const onSurfaceMuted   = Color(0xFF4E6B5F);  // Medium readable slate
  static const onSurfaceSubtle  = Color(0xFF7A968B);  // Subtle secondary text
  static const onPrimary        = Color(0xFFFFFFFF);  // White contrast on colored buttons

  // ── Vibrant Color Accents (Light Mode Optimized) ───────────────────
  // Emerald / Primary — Amazon Forest Emerald
  static const emeraldGreen     = Color(0xFF059669);
  static const emeraldGreenDark = Color(0xFF047857);
  static const emeraldGreenLight = Color(0xFF10B981);
  static const emeraldGreenGlow = Color(0x33059669);

  // CyberShield — Electric Cyan / Blue
  static const cyberBlue        = Color(0xFF0284C7);
  static const cyberBlueDark    = Color(0xFF0369A1);
  static const cyberBlueLight   = Color(0xFF38BDF8);
  static const cyberBlueGlow    = Color(0x330284C7);

  // Guardian Safety / SOS — Vibrant Rose Crimson
  static const safetyPink       = Color(0xFFE11D48);
  static const safetyPinkDark   = Color(0xFFBE123C);
  static const safetyPinkLight  = Color(0xFFF43F5E);
  static const safetyPinkGlow   = Color(0x33E11D48);

  // Guardian Family — Royal Violet
  static const neonPurple       = Color(0xFF7C3AED);
  static const neonPurpleDark   = Color(0xFF6D28D9);
  static const neonPurpleLight  = Color(0xFF8B5CF6);
  static const neonPurpleGlow   = Color(0x337C3AED);

  // ScamGuard — Warm Amber Gold
  static const scamAmber        = Color(0xFFD97706);
  static const scamAmberDark    = Color(0xFFB45309);
  static const scamAmberGlow    = Color(0x33D97706);

  // Link Detective — River Teal & Toucan Orange
  static const detectiveTeal    = Color(0xFF0D9488);
  static const detectiveOrange  = Color(0xFFEA580C);

  // Semantics
  static const errorRed         = Color(0xFFE11D48);
  static const warningAmber     = Color(0xFFD97706);
  static const warningOrange    = Color(0xFFEA580C);
  static const successGreen     = Color(0xFF059669);
  static const infoBlue         = Color(0xFF0284C7);

  // ── Gradients ───────────────────────────────────────────────────────
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const gradientSafety = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
  );

  static const gradientDanger = gradientSafety;

  static const gradientCyber = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
  );

  static const gradientParent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  );

  static const gradientDetective = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14B8A6), Color(0xFFF97316)],
  );

  static const gradientScam = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
  );

  static const gradientWeather = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
  );

  static const gradientBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4F7F5), Color(0xFFEBF2EE)],
  );

  static const gradientSosRing = RadialGradient(
    colors: [Color(0xFFE11D48), Color(0xFF9F1239), Color(0x00E11D48)],
    stops: [0.0, 0.7, 1.0],
  );

  // Glassmorphic tokens
  static const glassWhite  = Color(0x14059669);
  static const glassBorder = Color(0x33CCDCD4);
  static const glassDark   = Color(0xFFFFFFFF);
}
