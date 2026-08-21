import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';

/// Home screen for Family Members (non-admin).
/// Shows their family info, rules that apply to them (transparency),
/// and shortcuts to their allowed features.
class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(familyProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(profile),
            SliverPadding(
              padding: const EdgeInsets.all(DesignTokens.screenPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildWelcomeBanner(context, profile),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildFamilyInfoCard(context, profile),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildActiveRulesSection(context, profile),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildFeaturesSection(context),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(FamilyProfile profile) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      floating: true,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.cyberBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.cyberBlue, size: 20),
          ),
          const SizedBox(width: DesignTokens.spacingSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.currentUserName,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              Text(
                profile.familyName,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.cyberBlue, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cyberBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              border: Border.all(color: AppColors.cyberBlue.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'Member',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.cyberBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, FamilyProfile profile) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingXl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyberBlue.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, ${profile.currentUserName}! 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'You\'re protected by Guardian Plus.\nYour security features are ready.',
                  style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: DesignTokens.animNormal)
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildFamilyInfoCard(BuildContext context, FamilyProfile profile) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.family_restroom_rounded, color: AppColors.neonPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'Your Family',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          _InfoRow(
            icon: Icons.home_rounded,
            label: 'Family Name',
            value: profile.familyName,
          ),
          _InfoRow(
            icon: Icons.vpn_key_rounded,
            label: 'Family Code',
            value: profile.familyCode,
          ),
          _InfoRow(
            icon: Icons.admin_panel_settings_rounded,
            label: 'Admin',
            value: '${profile.currentUserName} (You)',
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: DesignTokens.animNormal)
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildActiveRulesSection(BuildContext context, FamilyProfile profile) {
    // Show transparency — member can see their own applied rules (read-only)
    // In member view there are no child profiles, so show a placeholder.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Monitoring Status',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        GlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: const Icon(Icons.visibility_outlined, color: AppColors.emeraldGreen, size: 22),
                  ),
                  const SizedBox(width: DesignTokens.spacingMd),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monitored by Family Admin',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Guardian Plus is transparent. You can always see your monitoring status.',
                          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacingMd),
              const Divider(color: AppColors.outline),
              const SizedBox(height: DesignTokens.spacingSm),
              _StatusChip(label: 'Location Sharing', isActive: false),
              const SizedBox(height: 6),
              _StatusChip(label: 'Screen Time Tracking', isActive: false),
              const SizedBox(height: 6),
              _StatusChip(label: 'Parental Controls', isActive: false, note: 'Not applicable — Admin only'),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.05, end: 0),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Features',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.shield_rounded,
                label: 'Cybersecurity',
                subtitle: 'Threat scanner\nPhishing check',
                gradient: AppColors.gradientPrimary,
                onTap: () {},
              ),
            ),
            const SizedBox(width: DesignTokens.spacingMd),
            Expanded(
              child: _FeatureCard(
                icon: Icons.favorite_rounded,
                label: "Women's Safety",
                subtitle: 'SOS button\nSafe route',
                gradient: AppColors.gradientDanger,
                onTap: () {},
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 300.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: DesignTokens.spacingMd),
        GlassCard(
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceMuted, size: 20),
              const SizedBox(width: DesignTokens.spacingMd),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parental Hub',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted),
                    ),
                    Text(
                      'Only accessible by the Family Admin',
                      style: TextStyle(fontSize: 11, color: AppColors.onSurfaceSubtle),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: const Text(
                  'Admin only',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms),
      ],
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceMuted),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isActive, this.note});
  final String label;
  final bool isActive;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.emeraldGreen : AppColors.onSurfaceMuted;
    return Row(
      children: [
        Icon(
          isActive ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        if (note != null) ...[
          const SizedBox(width: 8),
          Text(note!,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.onSurfaceSubtle, fontStyle: FontStyle.italic)),
        ],
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacingLg),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 11, color: Colors.white70, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
