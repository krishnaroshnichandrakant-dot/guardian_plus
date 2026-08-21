import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cybersecurity/screens/cybersecurity_dashboard.dart';
import '../../parental/screens/parent_dashboard.dart';
import '../../womens_safety/screens/womens_dashboard.dart';
import '../../cybersecurity/screens/permission_auditor_screen.dart';
import '../../family/screens/member_home_screen.dart';

/// Main Application Shell — role-aware navigation.
/// - Family Admin: sees all 4 tabs including Parental Hub.
/// - Family Member: sees 3 tabs only (Cybersecurity, Women's Safety, Auditor).
/// - No family: shows Cybersecurity tab only (family setup prompted elsewhere).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final familyRole = ref.watch(familyRoleProvider);
    final isAdmin = familyRole == FamilyRole.admin;
    final isMember = familyRole == FamilyRole.member;

    // Build the tab configuration based on role
    final tabs = _buildTabs(isAdmin, isMember);

    // Clamp index to valid range if role changed
    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);
    if (safeIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = safeIndex);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: DesignTokens.animFast,
        switchInCurve: Curves.easeOutQuad,
        switchOutCurve: Curves.easeInQuad,
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: tabs[safeIndex].screen,
        ),
      ),
      bottomNavigationBar: _buildNavBar(tabs, safeIndex, isAdmin),
    );
  }

  // ── Tab Config ────────────────────────────────────────────────────────

  List<_TabConfig> _buildTabs(bool isAdmin, bool isMember) {
    final tabs = <_TabConfig>[
      const _TabConfig(
        screen: CybersecurityDashboard(),
        icon: Icons.shield_outlined,
        activeIcon: Icons.shield_rounded,
        label: 'Security',
        activeColor: AppColors.cyberBlue,
      ),
    ];

    // Parental Hub — Admin only
    if (isAdmin) {
      tabs.add(const _TabConfig(
        screen: ParentDashboard(),
        icon: Icons.admin_panel_settings_outlined,
        activeIcon: Icons.admin_panel_settings_rounded,
        label: 'Parent Hub',
        activeColor: AppColors.neonPurple,
      ));
    }

    tabs.add(const _TabConfig(
      screen: WomensDashboard(),
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Safety',
      activeColor: AppColors.softCoral,
    ));

    tabs.add(const _TabConfig(
      screen: PermissionAuditorScreen(),
      icon: Icons.app_registration_rounded,
      activeIcon: Icons.app_registration_rounded,
      label: 'Auditor',
      activeColor: AppColors.emeraldGreen,
    ));

    // Member home replaces a placeholder — actually we handle member view
    // by keeping the same screens but hiding Parental tab.

    return tabs;
  }

  // ── Navigation Bar ────────────────────────────────────────────────────

  Widget _buildNavBar(List<_TabConfig> tabs, int currentIndex, bool isAdmin) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline, width: 1.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Role indicator strip
            if (isAdmin)
              Container(
                width: double.infinity,
                color: AppColors.surfaceElevated,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.admin_panel_settings_rounded,
                          size: 11, color: AppColors.onSurfaceMuted),
                      SizedBox(width: 4),
                      Text(
                        'Family Admin',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                color: AppColors.surfaceElevated,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_rounded, size: 11, color: AppColors.onSurfaceMuted),
                      SizedBox(width: 4),
                      Text(
                        'Family Member',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;
                  final isSelected = currentIndex == index;
                  return _NavItem(
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
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────

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

// ── Nav Item ───────────────────────────────────────────────────────────────

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
      child: AnimatedContainer(
        duration: DesignTokens.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : AppColors.onSurfaceMuted,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
