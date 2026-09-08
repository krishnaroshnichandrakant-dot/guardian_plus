import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../providers/auth_provider.dart';

/// Role selection screen — Amazon Forest Edition.
/// Instant passwordless entry for all roles (Individual, Parent, Women's Safety, Child).
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.individual;
  bool _isEntering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DesignTokens.spacingLg),
              _buildHeader(),
              const SizedBox(height: DesignTokens.spacingLg),
              Expanded(child: _buildRoleList()),
              const SizedBox(height: DesignTokens.spacingMd),
              _buildInstantEnterButton(),
              const SizedBox(height: DesignTokens.spacingLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Amazon Canopy Shield
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emeraldGreen.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.shield_rounded, color: AppColors.onPrimary, size: 26),
            ).animate().scale(duration: DesignTokens.animSlow, curve: Curves.elasticOut),
            // Amazon Forest indicator badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 5),
                  Text(
                    'AMAZON FOREST',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emeraldGreen,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        Text(
          'Select Your\nExperience',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        )
            .animate()
            .fadeIn(delay: 150.ms, duration: DesignTokens.animNormal)
            .slideY(begin: 0.08, end: 0),
        const SizedBox(height: 6),
        Text(
          'No passwords required — tap any role to enter instantly.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceMuted,
            height: 1.4,
          ),
        ).animate().fadeIn(delay: 250.ms, duration: DesignTokens.animNormal),
      ],
    );
  }

  Widget _buildRoleList() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _RoleCard(
          role: UserRole.individual,
          icon: Icons.security_rounded,
          title: 'Individual / CyberShield',
          subtitle: 'Threat scanner, phishing detector & Wi-Fi safety',
          gradient: AppColors.gradientCyber,
          accentColor: AppColors.cyberBlue,
          features: const ['URL Threat Scanner', 'Wi-Fi Auditor', 'App Permissions'],
          isSelected: _selectedRole == UserRole.individual,
          onTap: () => setState(() => _selectedRole = UserRole.individual),
          onDirectEnter: () => _enterWithRole(UserRole.individual),
          delay: 0,
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        _RoleCard(
          role: UserRole.womensSafety,
          icon: Icons.favorite_rounded,
          title: "Women's Safety",
          subtitle: 'Personal safety tools, SOS panic button & safe routes',
          gradient: AppColors.gradientSafety,
          accentColor: AppColors.safetyPink,
          features: const ['One-Tap SOS', 'Live Tracking', 'Fake Call Trigger'],
          isSelected: _selectedRole == UserRole.womensSafety,
          onTap: () => setState(() => _selectedRole = UserRole.womensSafety),
          onDirectEnter: () => _enterWithRole(UserRole.womensSafety),
          delay: 80,
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        _RoleCard(
          role: UserRole.parent,
          icon: Icons.family_restroom_rounded,
          title: 'Guardian Parent',
          subtitle: 'Transparent family protection, rules & ScamGuard',
          gradient: AppColors.gradientParent,
          accentColor: AppColors.neonPurple,
          features: const ['Screen Time Rules', 'ScamGuard Payment Risk', 'Live Safe Zones'],
          isSelected: _selectedRole == UserRole.parent,
          onTap: () => setState(() => _selectedRole = UserRole.parent),
          onDirectEnter: () => _enterWithRole(UserRole.parent),
          delay: 160,
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        _RoleCard(
          role: UserRole.child,
          icon: Icons.child_care_rounded,
          title: 'Child / Member',
          subtitle: 'Kid-safe dashboard & Link Detective phishing game',
          gradient: AppColors.gradientDetective,
          accentColor: AppColors.detectiveTeal,
          features: const ['Link Detective Game', 'Kid SOS', 'Transparent Status'],
          isSelected: _selectedRole == UserRole.child,
          onTap: () => setState(() => _selectedRole = UserRole.child),
          onDirectEnter: () => _enterWithRole(UserRole.child),
          delay: 240,
        ),
      ],
    );
  }

  Widget _buildInstantEnterButton() {
    return ElevatedButton(
      onPressed: _isEntering ? null : () => _enterWithRole(_selectedRole),
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentForRole(_selectedRole),
        foregroundColor: _selectedRole == UserRole.parent ? Colors.white : AppColors.onPrimary,
        minimumSize: const Size(double.infinity, DesignTokens.buttonHeightLg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        elevation: 0,
      ),
      child: _isEntering
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter as ${_selectedRole.displayName}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
    );
  }

  Future<void> _enterWithRole(UserRole role) async {
    HapticFeedback.mediumImpact();
    setState(() => _isEntering = true);

    // Set passwordless active session
    await ref.read(authServiceProvider).setDirectSession(ref, role);

    if (mounted) {
      if (role == UserRole.child) {
        context.go(Routes.childHome);
      } else {
        context.go(Routes.guardianHome);
      }
    }
  }

  Color _accentForRole(UserRole role) {
    switch (role) {
      case UserRole.womensSafety: return AppColors.safetyPink;
      case UserRole.parent:       return AppColors.neonPurple;
      case UserRole.child:        return AppColors.detectiveTeal;
      case UserRole.individual:   return AppColors.emeraldGreen;
    }
  }
}

// ── Role Card ──────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
    required this.features,
    required this.isSelected,
    required this.onTap,
    required this.onDirectEnter,
    required this.delay,
  });

  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final Color accentColor;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDirectEnter;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DesignTokens.animFast,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: isSelected ? accentColor : AppColors.outline,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? accentColor.withValues(alpha: 0.1)
            : AppColors.surface,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingLg),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    child: Icon(
                      icon,
                      color: role == UserRole.individual ? AppColors.onPrimary : Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingMd),
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Radio Indicator
                  AnimatedContainer(
                    duration: DesignTokens.animFast,
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? accentColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? accentColor : AppColors.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: role == UserRole.parent ? Colors.white : AppColors.onPrimary,
                            size: 14,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacingMd),
              // Feature chips
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: features.map((f) => _FeatureChip(label: f)).toList(),
                    ),
                  ),
                  // Direct Quick Enter button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onDirectEnter();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Enter',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: accentColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: DesignTokens.animNormal)
        .slideY(begin: 0.05, end: 0);
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(color: AppColors.outline, width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceMuted,
        ),
      ),
    );
  }
}
