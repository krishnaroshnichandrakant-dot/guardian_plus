import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';

/// Settings & Profile Dashboard — Screen 10 from the reference design.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenPadding,
                0,
                DesignTokens.screenPadding,
                100,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: DesignTokens.spacingLg),
                  _buildProfileHeader(user),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildSettingsList(context),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildInspirationalQuoteCard(),
                  const SizedBox(height: DesignTokens.spacingXl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      floating: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outline),
            ),
            child: const Icon(Icons.settings_outlined, color: AppColors.onSurface, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Settings',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.outline),
      ),
    );
  }

  Widget _buildProfileHeader(GuardianUser? user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
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
            child: const Icon(Icons.person_rounded, color: AppColors.onPrimary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Krishna Vishwakarma',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.emeraldGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Protected · ${user?.role.displayName ?? "Active"}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              border: Border.all(color: AppColors.outline),
            ),
            child: Text(
              'v2.4',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.emeraldGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final items = [
      _SettingsItem(
        icon: Icons.tune_rounded,
        title: 'App Preferences',
        subtitle: 'Theme, animations & haptics',
        onTap: () => _showMessage(context, 'App preferences updated.'),
      ),
      _SettingsItem(
        icon: Icons.notifications_none_rounded,
        title: 'Notifications',
        subtitle: 'Push alerts & SOS sirens',
        onTap: () => _showMessage(context, 'Notification settings configured.'),
      ),
      _SettingsItem(
        icon: Icons.security_rounded,
        title: 'Permissions',
        subtitle: 'GPS, microphone & storage status',
        onTap: () => _showMessage(context, 'Permissions are all green.'),
      ),
      _SettingsItem(
        icon: Icons.language_rounded,
        title: 'Language',
        subtitle: 'English (US) · Multi-lingual ready',
        onTap: () => _showMessage(context, 'Language set to English.'),
      ),
      _SettingsItem(
        icon: Icons.help_outline_rounded,
        title: 'Help & Support',
        subtitle: 'Guides, FAQs & emergency contacts',
        onTap: () => _showMessage(context, 'Guardian 24/7 Helpline: 112 / 1091'),
      ),
      _SettingsItem(
        icon: Icons.info_outline_rounded,
        title: 'About Guardian Plus',
        subtitle: 'Version 2.4 · Privacy First Design',
        onTap: () => _showMessage(context, 'Guardian Plus — Built with Love for Safety.'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: AppColors.onSurface, size: 20),
                ),
                title: Text(
                  item.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceSubtle,
                  size: 20,
                ),
                onTap: () {
                  HapticFeedback.selectionClick();
                  item.onTap();
                },
              ),
              if (!isLast)
                const Divider(color: AppColors.outline, height: 1, indent: 64),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInspirationalQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF14241E), Color(0xFF0C1613)],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌲', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'GUARDIAN PLUS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: AppColors.emeraldGreen,
                ),
              ),
              const SizedBox(width: 8),
              const Text('🌲', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '“A safer world\nbegins with aware people.”',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'People · Families · A Safer Tomorrow',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.05, end: 0);
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
