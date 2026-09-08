import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';

// Feature screens matching the mockup tabs
import '../../home/screens/guardian_home_screen.dart';
import '../../womens_safety/screens/womens_dashboard.dart';
import '../../cybersecurity/screens/cybersecurity_dashboard.dart';
import '../../parental/screens/parent_dashboard.dart';
import '../../settings/screens/settings_screen.dart';

/// Main Application Shell — 5-Tab Navigation matching the reference mockups:
/// [Home] · [Safety] · [Cyber] · [Family] · [Profile]
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateProvider);
    final user = authAsync.valueOrNull;
    final role = user?.role ?? UserRole.individual;

    final tabs = _buildTabs();

    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: safeIndex,
        children: tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: _buildNavBar(tabs, safeIndex, role),
    );
  }

  List<_TabConfig> _buildTabs() => [
    const _TabConfig(
      screen: GuardianHomeScreen(),
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      activeColor: AppColors.emeraldGreen,
    ),
    const _TabConfig(
      screen: WomensDashboard(),
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Safety',
      activeColor: AppColors.safetyPink,
    ),
    const _TabConfig(
      screen: CybersecurityDashboard(),
      icon: Icons.shield_outlined,
      activeIcon: Icons.shield_rounded,
      label: 'Cyber',
      activeColor: AppColors.cyberBlue,
    ),
    const _TabConfig(
      screen: ParentDashboard(),
      icon: Icons.family_restroom_outlined,
      activeIcon: Icons.family_restroom_rounded,
      label: 'Family',
      activeColor: AppColors.neonPurple,
    ),
    const _TabConfig(
      screen: SettingsScreen(),
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      activeColor: AppColors.emeraldGreen,
    ),
  ];

  Widget _buildNavBar(List<_TabConfig> tabs, int currentIndex, UserRole role) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBarBackground,
        border: const Border(top: BorderSide(color: AppColors.outline, width: 1.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Interactive Role Switcher Header
            GestureDetector(
              onTap: () => _showRoleSwitchSheet(context, role),
              child: Container(
                width: double.infinity,
                color: AppColors.surfaceElevated,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌿', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 4),
                      Text(
                        '${role.displayName.toUpperCase()} MODE • SWITCH ROLE ▾',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emeraldGreen,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Navigation items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;
                  final isSelected = currentIndex == index;
                  return Flexible(
                    child: _NavItem(
                      icon: tab.icon,
                      activeIcon: tab.activeIcon,
                      label: tab.label,
                      isSelected: isSelected,
                      activeColor: tab.activeColor,
                      onTap: () {
                        if (_currentIndex == index) return;
                        HapticFeedback.selectionClick();
                        setState(() => _currentIndex = index);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleSwitchSheet(BuildContext context, UserRole currentRole) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Switch Experience',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Text('🌿', style: TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Instant passwordless switch to any Guardian Plus role:',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceMuted),
              ),
              const SizedBox(height: 16),
              ...UserRole.values.map((r) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: r == currentRole ? AppColors.emeraldGreen : AppColors.outline,
                      ),
                    ),
                    tileColor: r == currentRole ? AppColors.surfaceElevated : AppColors.surface,
                    leading: Icon(
                      r == UserRole.individual
                          ? Icons.security_rounded
                          : r == UserRole.womensSafety
                              ? Icons.favorite_rounded
                              : r == UserRole.parent
                                  ? Icons.family_restroom_rounded
                                  : Icons.child_care_rounded,
                      color: r == UserRole.womensSafety
                          ? AppColors.safetyPink
                          : r == UserRole.parent
                              ? AppColors.neonPurple
                              : AppColors.emeraldGreen,
                    ),
                    title: Text(
                      r.displayName,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    trailing: r == currentRole
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.emeraldGreen)
                        : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.onSurfaceMuted),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await ref.read(authServiceProvider).setDirectSession(ref, r);
                      setState(() => _currentIndex = 0);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabConfig {
  const _TabConfig({
    required this.screen,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.activeColor,
  });
  final Widget screen;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color activeColor;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: DesignTokens.animFast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? activeColor : AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
