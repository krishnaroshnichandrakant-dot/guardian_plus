import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../auth/providers/auth_provider.dart';

/// Guardian Family / Parental Dashboard (PS #21) — Screen 6 from reference mockups.
class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key});

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  int _selectedTab = 0; // 0 = Members, 1 = Rules

  final List<Map<String, dynamic>> _members = [
    {'name': 'Aarav', 'avatar': '👦', 'status': 'Online · 78%', 'battery': 78, 'isOnline': true},
    {'name': 'Myra', 'avatar': '👧', 'status': 'Online · 62%', 'battery': 62, 'isOnline': true},
    {'name': 'Vivaan', 'avatar': '👦', 'status': 'Last seen 1h ago · 30%', 'battery': 30, 'isOnline': false},
  ];

  @override
  Widget build(BuildContext context) {
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
                10,
                DesignTokens.screenPadding,
                100,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSegmentedTabSwitch(),
                  const SizedBox(height: 16),
                  if (_selectedTab == 0) ...[
                    _buildMembersList(context),
                    const SizedBox(height: 20),
                    _buildFamilySafetyIndexCard(),
                    const SizedBox(height: 20),
                    _buildControlsGrid(context),
                  ] else ...[
                    _buildRulesListTab(context),
                  ],
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
              color: AppColors.neonPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.family_restroom_rounded, color: AppColors.neonPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guardian Family',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'Together Towards a Safer Tomorrow.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.neonPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.outline),
      ),
    );
  }

  // ── Segmented Tab Switch: [Members] [Rules] ───────────────────────────────

  Widget _buildSegmentedTabSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = 0);
              },
              child: AnimatedContainer(
                duration: DesignTokens.animFast,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? AppColors.surfaceElevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _selectedTab == 0 ? Border.all(color: AppColors.outline) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Members',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _selectedTab == 0 ? AppColors.onSurface : AppColors.onSurfaceMuted,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = 1);
              },
              child: AnimatedContainer(
                duration: DesignTokens.animFast,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? AppColors.surfaceElevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _selectedTab == 1 ? Border.all(color: AppColors.outline) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Rules',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _selectedTab == 1 ? AppColors.onSurface : AppColors.onSurfaceMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Family Members List ───────────────────────────────────────────────────

  Widget _buildMembersList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: _members.asMap().entries.map((entry) {
          final isLast = entry.key == _members.length - 1;
          final m = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceElevated,
                    border: Border.all(
                      color: m['isOnline'] as bool ? AppColors.emeraldGreen : AppColors.outline,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(m['avatar'] as String, style: const TextStyle(fontSize: 22)),
                ),
                title: Text(
                  m['name'] as String,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Icon(
                      Icons.battery_5_bar_rounded,
                      size: 14,
                      color: (m['battery'] as int) > 40 ? AppColors.emeraldGreen : AppColors.scamAmber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      m['status'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceSubtle,
                  size: 20,
                ),
                onTap: () {
                  HapticFeedback.selectionClick();
                  _showMemberDetail(context, m['name'] as String);
                },
              ),
              if (!isLast)
                const Divider(color: AppColors.outline, height: 1, indent: 68),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Family Safety Index Radial Card ───────────────────────────────────────

  Widget _buildFamilySafetyIndexCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldGreen.withValues(alpha: 0.08),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 6,
                    backgroundColor: AppColors.surfaceHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.emeraldGreen),
                  ),
                ),
                Text(
                  '85%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Family Safety Index',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Good',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.emeraldGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your family is doing well!',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceSubtle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4 Control Tiles (2x2 Grid) ────────────────────────────────────────────

  Widget _buildControlsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ControlCard(
                icon: Icons.timer_rounded,
                title: 'Screen Time',
                color: AppColors.neonPurple,
                onTap: () => _showControlModal(context, 'Screen Time Limits', 'Daily limit: 2 hours · YouTube & Games'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ControlCard(
                icon: Icons.apps_rounded,
                title: 'App Rules',
                color: const Color(0xFF6366F1),
                onTap: () => _showControlModal(context, 'App Installation & Filter Rules', 'Require parental permission for downloads.'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ControlCard(
                icon: Icons.location_on_rounded,
                title: 'Safe Zones',
                color: AppColors.emeraldGreen,
                onTap: () => _showControlModal(context, 'Safe Zones & Geofencing', 'Green Park School · Home Sector 18'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ControlCard(
                icon: Icons.bedtime_rounded,
                title: 'Bedtime',
                color: AppColors.cyberBlue,
                onTap: () => _showControlModal(context, 'Bedtime Curfew', 'Device lockout after 9:30 PM on school nights.'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRulesListTab(BuildContext context) {
    final rules = [
      {'title': 'Screen Time Limit', 'desc': '2 hours/day per child', 'enabled': true},
      {'title': 'Bedtime Curfew', 'desc': '9:30 PM device lockdown', 'enabled': true},
      {'title': 'School Safe Zone', 'desc': 'Alert on leaving campus', 'enabled': true},
      {'title': 'Adult Content Filter', 'desc': 'Strict SafeSearch & Web guard', 'enabled': true},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: rules.map((r) => SwitchListTile(
              title: Text(r['title'] as String, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              subtitle: Text(r['desc'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceMuted)),
              value: r['enabled'] as bool,
              activeThumbColor: AppColors.neonPurple,
              onChanged: (v) => setState(() => r['enabled'] = v),
            )).toList(),
      ),
    );
  }

  void _showMemberDetail(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$name\'s Activity Overview', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
            const SizedBox(height: 12),
            Text('• Screen Time: 1h 24m today\n• Location: Green Park School (Safe Zone)\n• Battery: 78% · Wi-Fi Active', style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: AppColors.onSurfaceMuted)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPurple),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close Overview', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showControlModal(BuildContext context, String title, String detail) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: Text(detail, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceMuted)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPurple),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Save Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final Color color;
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
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
