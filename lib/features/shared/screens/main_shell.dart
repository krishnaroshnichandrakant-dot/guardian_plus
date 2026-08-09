import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../cybersecurity/screens/cybersecurity_dashboard.dart';
import '../../parental/screens/parent_dashboard.dart';
import '../../womens_safety/screens/womens_dashboard.dart';
import '../../cybersecurity/screens/permission_auditor_screen.dart';

/// Main Application Shell providing instant, 1-tap switching between features
/// without any login barriers. Built with fresh light aesthetics & fast response times.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  late int _currentIndex;

  final List<Widget> _screens = const [
    CybersecurityDashboard(),
    ParentDashboard(),
    WomensDashboard(),
    PermissionAuditorScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: DesignTokens.animFast,
        switchInCurve: Curves.easeOutQuad,
        switchOutCurve: Curves.easeInQuad,
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.outline, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.shield_outlined,
                  activeIcon: Icons.shield_rounded,
                  label: 'Cybersecurity',
                  isSelected: _currentIndex == 0,
                  activeColor: AppColors.cyberBlue,
                  onTap: () => _onTabTapped(0),
                ),
                _NavItem(
                  icon: Icons.family_restroom_outlined,
                  activeIcon: Icons.family_restroom_rounded,
                  label: 'Parental',
                  isSelected: _currentIndex == 1,
                  activeColor: AppColors.neonPurple,
                  onTap: () => _onTabTapped(1),
                ),
                _NavItem(
                  icon: Icons.favorite_border_rounded,
                  activeIcon: Icons.favorite_rounded,
                  label: 'Women Safety',
                  isSelected: _currentIndex == 2,
                  activeColor: AppColors.softCoral,
                  onTap: () => _onTabTapped(2),
                ),
                _NavItem(
                  icon: Icons.app_registration_rounded,
                  activeIcon: Icons.app_registration_rounded,
                  label: 'Auditor',
                  isSelected: _currentIndex == 3,
                  activeColor: AppColors.emeraldGreen,
                  onTap: () => _onTabTapped(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
      child: AnimatedContainer(
        duration: DesignTokens.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
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
