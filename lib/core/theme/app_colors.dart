import 'package:flutter/material.dart';

/// Guardian Plus — Clean White Pro
/// Inspired by Apple's design language: pure whites, deep charcoal text,
/// a single bold blue accent, generous whitespace and clean borders.
class AppColors {
  AppColors._();

  // ── Primary Accent (Apple Blue) ───────────────────────────────────
  static const cyberBlue        = Color(0xFF0A84FF);   // iOS 17 system blue
  static const cyberBlueDark    = Color(0xFF0071E3);   // Apple.com button blue
  static const cyberBlueLight   = Color(0xFF40A9FF);   // hover / lighter
  static const cyberBlueGlow    = Color(0x220A84FF);   // subtle glow

  // ── Secondary Accent (Teal — for Women's Safety, Safe zones) ──────
  static const emeraldGreen     = Color(0xFF30D158);   // iOS 17 system green
  static const emeraldGreenDark = Color(0xFF25A244);
  static const emeraldGreenLight = Color(0xFF57E07A);
  static const emeraldGreenGlow = Color(0x2230D158);

  // ── Tertiary (Purple — Parent Hub only) ───────────────────────────
  static const neonPurple       = Color(0xFF6E56CF);   // warm indigo — not neon
  static const neonPurpleGlow   = Color(0x226E56CF);

  // ── Danger (Women's Safety / Errors) ──────────────────────────────
  static const softCoral        = Color(0xFFFF453A);   // iOS system red
  static const amber            = Color(0xFFFFD60A);   // iOS system yellow

  // ── Pure White Backgrounds ────────────────────────────────────────
  /// Scaffold — absolute white
  static const background       = Color(0xFFFFFFFF);
  /// Cards — white
  static const surface          = Color(0xFFFFFFFF);
  static const cardBackground   = Color(0xFFFFFFFF);
  /// Second level — almost invisible light gray (like iOS grouped cells)
  static const surfaceElevated  = Color(0xFFF2F2F7);   // iOS systemGroupedBackground
  /// Highest — divider-level gray
  static const surfaceHighest   = Color(0xFFE5E5EA);   // iOS separator
  static const navBarBackground = Color(0xFFFFFFFF);

  // ── Borders (razor thin, like Apple) ─────────────────────────────
  static const outline          = Color(0xFFE5E5EA);   // iOS separator color
  static const outlineVariant   = Color(0xFFD1D1D6);   // slightly darker

  // ── Typography (Charcoal — Apple style) ──────────────────────────
  static const onSurface        = Color(0xFF1C1C1E);   // iOS label color
  static const onSurfaceMuted   = Color(0xFF6C6C70);   // iOS secondaryLabel
  static const onSurfaceSubtle  = Color(0xFFAEAEB2);   // iOS tertiaryLabel
  static const onPrimary        = Color(0xFFFFFFFF);

  // ── Semantic ──────────────────────────────────────────────────────
  static const errorRed         = Color(0xFFFF453A);   // iOS system red
  static const errorRedGlow     = Color(0x22FF453A);
  static const warningOrange    = Color(0xFFFF9F0A);   // iOS system orange
  static const warningAmber     = Color(0xFFFFD60A);   // iOS system yellow
  static const successGreen     = emeraldGreen;
  static const infoBlue         = cyberBlue;

  // ── Gradient Presets ──────────────────────────────────────────────
  /// Primary CTA — clean blue (used sparingly)
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A84FF), Color(0xFF0071E3)],
  );

  /// Parent Hub — calm purple gradient
  static const gradientParent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6E56CF), Color(0xFF4E3D9C)],
  );

  /// Safety gradient — green to teal
  static const gradientSafety = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF30D158), Color(0xFF0D9488)],
  );

  /// Danger — Women's Safety
  static const gradientDanger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF453A), Color(0xFFD70015)],
  );

  static const gradientBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF2F2F7)],
  );

  // ── Glass / card surface ──────────────────────────────────────────
  static const glassWhite  = Color(0xFFFFFFFF);
  static const glassBorder = Color(0xFFE5E5EA);
  static const glassDark   = Color(0xFFF2F2F7);
}
