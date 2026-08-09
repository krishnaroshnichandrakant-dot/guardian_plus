import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../shared/widgets/glass_card.dart';

/// Role selection screen — the first screen a new user sees after onboarding.
/// Each role gets a distinct visual identity and feature summary.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DesignTokens.spacingXl),
              _buildHeader(),
              const SizedBox(height: DesignTokens.spacingXxl),
              Expanded(child: _buildRoleGrid()),
              const SizedBox(height: DesignTokens.spacingLg),
              _buildContinueButton(),
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
        // Logo
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
        )
            .animate()
            .scale(duration: DesignTokens.animSlow, curve: Curves.elasticOut),
        const SizedBox(height: DesignTokens.spacingLg),
        Text(
          'Who are you\nprotecting?',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.onSurface,
                height: 1.15,
              ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: DesignTokens.animNormal)
            .slideY(begin: 0.1, end: 0),
        const SizedBox(height: DesignTokens.spacingSm),
        Text(
          'Choose your role to get started. You can change this later.',
          style: Theme.of(context).textTheme.bodyMedium,
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: DesignTokens.animNormal),
      ],
    );
  }

  Widget _buildRoleGrid() {
    return ListView(
      children: [
        _RoleCard(
          role: UserRole.individual,
          icon: Icons.security_rounded,
          title: 'Individual',
          subtitle: 'Cybersecurity & threat scanner for yourself',
          gradient: AppColors.gradientPrimary,
          features: const ['Phishing & URL scanner', 'App permission auditor', 'Wi-Fi safety check'],
          isSelected: _selectedRole == UserRole.individual,
          onTap: () => setState(() => _selectedRole = UserRole.individual),
          delay: 0,
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        _RoleCard(
          role: UserRole.parent,
          icon: Icons.family_restroom_rounded,
          title: 'Parent',
          subtitle: 'Monitor and protect your child\'s device',
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          features: const ['Screen time & app limits', 'SMS risk alerts', 'Web content filter'],
          isSelected: _selectedRole == UserRole.parent,
          onTap: () => setState(() => _selectedRole = UserRole.parent),
          delay: 100,
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        _RoleCard(
          role: UserRole.womensSafety,
          icon: Icons.favorite_rounded,
          title: "Women's Safety",
          subtitle: 'Personal safety tools you control',
          gradient: AppColors.gradientDanger,
          features: const ['SOS panic button', 'Live location sharing', 'Safe route planner'],
          isSelected: _selectedRole == UserRole.womensSafety,
          onTap: () => setState(() => _selectedRole = UserRole.womensSafety),
          delay: 200,
        ),
        const SizedBox(height: DesignTokens.spacingMd),
        _RoleCard(
          role: UserRole.child,
          icon: Icons.child_care_rounded,
          title: 'Child',
          subtitle: 'Pair with your parent\'s Guardian Plus account',
          gradient: AppColors.gradientSafety,
          features: const ['Always transparent monitoring', 'Request unpairing anytime', 'Safe browsing'],
          isSelected: _selectedRole == UserRole.child,
          onTap: () => setState(() => _selectedRole = UserRole.child),
          delay: 300,
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return AnimatedOpacity(
      opacity: _selectedRole != null ? 1.0 : 0.4,
      duration: DesignTokens.animFast,
      child: ElevatedButton(
        onPressed: _selectedRole != null ? _onContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyberBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, DesignTokens.buttonHeightLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue as ${_selectedRole?.displayName ?? 'Guest'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: DesignTokens.spacingSm),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  void _onContinue() {
    context.push(Routes.consent, extra: _selectedRole);
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
    required this.features,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DesignTokens.animFast,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: isSelected ? AppColors.cyberBlue : AppColors.outlineVariant,
          width: isSelected ? 2 : 0.5,
        ),
        color: isSelected
            ? AppColors.cyberBlue.withOpacity(0.08)
            : AppColors.cardBackground,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingLg),
          child: Row(
            children: [
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: DesignTokens.spacingLg),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingXs),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingSm),
                    Wrap(
                      spacing: DesignTokens.spacingXs,
                      runSpacing: DesignTokens.spacingXs,
                      children: features
                          .map((f) => _FeatureChip(label: f))
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Selection indicator
              AnimatedContainer(
                duration: DesignTokens.animFast,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.cyberBlue : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.cyberBlue
                        : AppColors.outlineVariant,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: DesignTokens.animNormal,
        )
        .slideY(begin: 0.05, end: 0);
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceMuted,
        ),
      ),
    );
  }
}

extension _RoleExt on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.individual:
        return 'Individual';
      case UserRole.parent:
        return 'Parent';
      case UserRole.child:
        return 'Child';
      case UserRole.womensSafety:
        return 'Self';
    }
  }
}
