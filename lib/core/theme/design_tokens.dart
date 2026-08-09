/// Guardian Plus Design Tokens
/// Single source of truth for all spacing, sizing, radius, elevation, animation
class DesignTokens {
  DesignTokens._();

  // ── Spacing Scale (4px base) ──────────────────────────────────────
  static const double spacingXxs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacingXxl = 32.0;
  static const double spacingXxxl = 48.0;
  static const double spacingHuge = 64.0;

  // ── Border Radius ─────────────────────────────────────────────────
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;  // Fully rounded (pills, avatars)

  // ── Icon Sizes ────────────────────────────────────────────────────
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconHero = 72.0;    // Large dashboard icons

  // ── Elevation ─────────────────────────────────────────────────────
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // ── Animation Durations (Optimized for Fast Response Rate) ────────
  static const Duration animXfast = Duration(milliseconds: 80);
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 220);
  static const Duration animSlow = Duration(milliseconds: 350);
  static const Duration animXslow = Duration(milliseconds: 500);

  // ── Animation Curves ──────────────────────────────────────────────
  // Use flutter's Curves constants directly
  // spring: Curves.elasticOut, smooth: Curves.easeOutCubic

  // ── Component Sizes ───────────────────────────────────────────────
  static const double buttonHeightLg = 56.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightSm = 36.0;
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 72.0;
  static const double cardMinHeight = 80.0;

  // ── Screen Margins ────────────────────────────────────────────────
  static const double screenPadding = 20.0;
  static const double screenPaddingWide = 24.0;

  // ── Blur values (glassmorphism) ────────────────────────────────────
  static const double blurSm = 8.0;
  static const double blurMd = 16.0;
  static const double blurLg = 24.0;
  static const double blurXl = 40.0;

  // ── Security-specific ─────────────────────────────────────────────
  static const double riskRingStroke = 12.0;     // Risk score ring chart stroke
  static const double sosButtonSize = 120.0;     // SOS panic button diameter
  static const double monitoringBannerHeight = 48.0; // Persistent monitoring banner
}
