import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/amazon_weather_card.dart';

/// Home Dashboard — Screen 2 from reference mockups.
class GuardianHomeScreen extends ConsumerStatefulWidget {
  const GuardianHomeScreen({super.key});

  @override
  ConsumerState<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends ConsumerState<GuardianHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildAppDrawer(context, user),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context, user),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenPadding,
                12,
                DesignTokens.screenPadding,
                100,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildGuardianStatusCard(context),
                  const SizedBox(height: 18),
                  _buildQuickStatusGrid(context),
                  const SizedBox(height: 22),
                  _buildQuickActionsRow(context),
                  const SizedBox(height: 22),
                  const AmazonWeatherCard(),
                  const SizedBox(height: 22),
                  _buildRecentAlertsSection(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Header ────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, GuardianUser? user) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.screenPadding,
          DesignTokens.spacingMd,
          DesignTokens.screenPadding,
          0,
        ),
        child: Row(
          children: [
            // Menu icon (Hamburger button)
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.menu_rounded, color: AppColors.onSurface, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            // Greeting text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Good Morning,',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Krishna 👋',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Stay Safe. Stay Empowered.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.emeraldGreen,
                    ),
                  ),
                ],
              ),
            ),
            // User Avatar with Online Badge
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradientPrimary,
                    border: Border.all(color: AppColors.emeraldGreen, width: 1.5),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppColors.onPrimary, size: 24),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Guardian Status Hero Card ─────────────────────────────────────────────

  Widget _buildGuardianStatusCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push(Routes.cyberShield);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: AppColors.emeraldGreen.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Glowing Shield Badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppColors.emeraldGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guardian Status',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Protected',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emeraldGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'All systems active',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.onSurfaceSubtle,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceMuted,
              size: 24,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0);
  }

  // ── 4 Quick Status Cards (2x2 Grid) ───────────────────────────────────────

  Widget _buildQuickStatusGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatusCard(
                icon: Icons.shield_rounded,
                title: 'Personal Safety',
                status: 'Safe',
                accentColor: AppColors.safetyPink,
                onTap: () => context.push(Routes.guardianSafety),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatusCard(
                icon: Icons.radar_rounded,
                title: 'Cyber Security',
                status: '1 issue',
                accentColor: AppColors.cyberBlue,
                statusColor: AppColors.scamAmber,
                onTap: () => context.push(Routes.cyberShield),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatusCard(
                icon: Icons.family_restroom_rounded,
                title: 'Family',
                status: 'Connected',
                accentColor: AppColors.neonPurple,
                onTap: () => context.push(Routes.guardianFamily),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatusCard(
                icon: Icons.fingerprint_rounded,
                title: 'Identity',
                status: 'Secure',
                accentColor: AppColors.emeraldGreen,
                onTap: () => context.push(Routes.guardianIdentity),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Quick Actions Row ─────────────────────────────────────────────────────

  Widget _buildQuickActionsRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _QuickActionButton(
              label: 'SOS',
              icon: Icons.emergency_rounded,
              gradient: AppColors.gradientSafety,
              onTap: () => context.push(Routes.guardianSafety),
            ),
            _QuickActionButton(
              label: 'Scan',
              icon: Icons.qr_code_scanner_rounded,
              gradient: AppColors.gradientCyber,
              onTap: () => context.push(Routes.qrScanner),
            ),
            _QuickActionButton(
              label: 'Safe Route',
              icon: Icons.alt_route_rounded,
              gradient: AppColors.gradientPrimary,
              onTap: () => context.push(Routes.safeRoute),
            ),
            _QuickActionButton(
              label: 'Family',
              icon: Icons.family_restroom_rounded,
              gradient: AppColors.gradientParent,
              onTap: () => context.push(Routes.guardianFamily),
            ),
          ],
        ),
      ],
    );
  }

  // ── Recent Alerts Section ─────────────────────────────────────────────────

  Widget _buildRecentAlertsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Alerts',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => context.push(Routes.scamGuard),
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.emeraldGreen,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.emeraldGreen),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.scamAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.scamAmber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suspicious QR detected',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '2 min ago · ScamGuard flag',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.onSurfaceMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Functional Navigation Drawer ──────────────────────────────────────────

  Widget _buildAppDrawer(BuildContext context, GuardianUser? user) {
    return Drawer(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                border: Border(bottom: BorderSide(color: AppColors.outline)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.gradientPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emeraldGreen.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GUARDIAN PLUS',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.emeraldGreen,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Krishna · Protected',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Quick Role Switch Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Role: ${user?.role.displayName ?? "Individual"}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showRolePickerModal(context);
                          },
                          child: Text(
                            'Switch ▾',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.emeraldGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Menu List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.home_rounded,
                    title: 'Home Dashboard',
                    color: AppColors.emeraldGreen,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(Routes.guardianHome);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.emergency_rounded,
                    title: 'Personal Safety (SOS)',
                    color: AppColors.safetyPink,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.guardianSafety);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.alt_route_rounded,
                    title: 'Safe Route Navigation',
                    color: AppColors.emeraldGreen,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.safeRoute);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.radar_rounded,
                    title: 'CyberShield Security',
                    color: AppColors.cyberBlue,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.cyberShield);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'QR & Link Scanner',
                    color: AppColors.cyberBlue,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.qrScanner);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.warning_amber_rounded,
                    title: 'ScamGuard Fraud Shield',
                    color: AppColors.scamAmber,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.scamGuard);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.family_restroom_rounded,
                    title: 'Family & Parental Dashboard',
                    color: AppColors.neonPurple,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.guardianFamily);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.fingerprint_rounded,
                    title: 'Identity & Biometrics',
                    color: AppColors.emeraldGreen,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.guardianIdentity);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings & Preferences',
                    color: AppColors.onSurfaceMuted,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(Routes.settings);
                    },
                  ),

                  const Divider(color: AppColors.outline, height: 24),

                  // Emergency Speed Dial Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: Text(
                      'EMERGENCY HELPLINES',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceSubtle,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  _buildHelplineTile('112', 'National Emergency', AppColors.safetyPink),
                  _buildHelplineTile('1091', 'Women Safety Helpline', AppColors.emeraldGreen),
                  _buildHelplineTile('1930', 'National Cyber Crime', AppColors.cyberBlue),
                ],
              ),
            ),

            // Bottom Profile Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.outline)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: AppColors.emeraldGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Guardian OS v2.4 · Active',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.onSurfaceSubtle),
      dense: true,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }

  Widget _buildHelplineTile(String number, String label, Color color) {
    return ListTile(
      dense: true,
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          number,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceMuted),
      ),
      trailing: Icon(Icons.phone_in_talk_rounded, size: 16, color: color),
      onTap: () {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dialing $label ($number)...'),
            backgroundColor: color,
          ),
        );
      },
    );
  }

  void _showRolePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Switch Guardian Persona',
                  style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.shield_rounded, color: AppColors.safetyPink),
                  title: const Text('Woman / Individual Mode'),
                  subtitle: const Text('Personal Safety, Safe Route & CyberShield'),
                  onTap: () {
                    ref.read(authServiceProvider).setDirectSession(ref, UserRole.womensSafety);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.family_restroom_rounded, color: AppColors.neonPurple),
                  title: const Text('Parent Mode'),
                  subtitle: const Text('Family Safety, ScamGuard, Child Protection'),
                  onTap: () {
                    ref.read(authServiceProvider).setDirectSession(ref, UserRole.parent);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.child_care_rounded, color: AppColors.detectiveTeal),
                  title: const Text('Child Mode'),
                  subtitle: const Text('Link Detective, Simplified SOS & Learning'),
                  onTap: () {
                    ref.read(authServiceProvider).setDirectSession(ref, UserRole.child);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Supporting Widget Models ────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.status,
    required this.accentColor,
    this.statusColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String status;
  final Color accentColor;
  final Color? statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: accentColor.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: statusColor ?? accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
