import 'package:flutter/material.dart';

/// Guardian Plus fresh light color palette
/// Primary: Indigo / Sky Blue (#4F46E5 & #0284C7) — clarity, security, modern aesthetic
/// Secondary: Emerald Green (#10B981) — safety & trust
/// Clean light surfaces with soft borders and crisp typography
class AppColors {
  AppColors._();

  // ── Brand Primary ─────────────────────────────────────────────────
  static const cyberBlue = Color(0xFF4F46E5);
  static const cyberBlueDark = Color(0xFF3730A3);
  static const cyberBlueLight = Color(0xFF6366F1);
  static const cyberBlueGlow = Color(0x1F4F46E5);

  // ── Brand Secondary ───────────────────────────────────────────────
  static const emeraldGreen = Color(0xFF10B981);
  static const emeraldGreenDark = Color(0xFF059669);
  static const emeraldGreenLight = Color(0xFF34D399);
  static const emeraldGreenGlow = Color(0x1F10B981);

  // ── Accent ────────────────────────────────────────────────────────
  static const neonPurple = Color(0xFF8B5CF6);
  static const neonPurpleGlow = Color(0x1F8B5CF6);
  static const softCoral = Color(0xFFF43F5E);
  static const amber = Color(0xFFF59E0B);

  // ── Light Backgrounds ─────────────────────────────────────────────
  /// Main scaffold background: fresh soft light gray
  static const background = Color(0xFFF8FAFC);
  /// Card / elevated surface: pure white
  static const surface = Color(0xFFFFFFFF);
  /// Cards on surface
  static const cardBackground = Color(0xFFFFFFFF);
  /// Second elevation level
  static const surfaceElevated = Color(0xFFF1F5F9);
  /// Highest elevation
  static const surfaceHighest = Color(0xFFE2E8F0);
  /// Navigation bar background
  static const navBarBackground = Color(0xFFFFFFFF);

  // ── Light Borders & Dividers ──────────────────────────────────────
  static const outline = Color(0xFFE2E8F0);
  static const outlineVariant = Color(0xFFCBD5E1);

  // ── Typography Colors ──────────────────────────────────────────────
  static const onSurface = Color(0xFF0F172A);
  static const onSurfaceMuted = Color(0xFF64748B);
  static const onSurfaceSubtle = Color(0xFF94A3B8);
  static const onPrimary = Color(0xFFFFFFFF);

  // ── Semantic Colors ───────────────────────────────────────────────
  static const errorRed = Color(0xFFEF4444);
  static const errorRedGlow = Color(0x1FEF4444);
  static const warningOrange = Color(0xFFF97316);
  static const warningAmber = Color(0xFFF59E0B);
  static const successGreen = emeraldGreen;
  static const infoBlue = cyberBlue;

  // ── Light Gradient Presets ────────────────────────────────────────
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF0284C7)],
  );

  static const gradientSafety = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emeraldGreen, Color(0xFF0D9488)],
  );

  static const gradientDanger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softCoral, Color(0xFFE11D48)],
  );

  static const gradientBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), background],
  );

  // ── Light Card Surface Presets ────────────────────────────────────
  static const glassWhite = Color(0xFFFFFFFF);
  static const glassBorder = Color(0xFFE2E8F0);
  static const glassDark = Color(0xFFF8FAFC);
}
