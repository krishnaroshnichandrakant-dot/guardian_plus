import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';
import 'child_rules_screen.dart';
import '../widgets/child_rule_editor_sheet.dart';

enum RiskLevel { clean, low, medium, high, critical }

/// Parent Dashboard — Admin-only view.
/// Shows child selector, per-child device stats, and per-child rules panel.
class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key});

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  int _selectedChildIndex = 0;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(familyProfileProvider);
    final children = profile.children;

    if (children.isEmpty) {
      return _buildNoChildrenView(context, profile);
    }

    final selectedChild = children[_selectedChildIndex.clamp(0, children.length - 1)];
    final rules = ref.watch(childRulesProvider(selectedChild.id));
    final enabledRules = rules.where((r) => r.isEnabled).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, profile),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenPadding,
                0,
                DesignTokens.screenPadding,
                120,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Family Safety Index ──────────────────────────────
                  _buildFamilySafetyBanner(children, profile),
                  const SizedBox(height: DesignTokens.spacingXl),

                  // ── Child Selector ───────────────────────────────────
                  _buildChildSelector(children),
                  const SizedBox(height: DesignTokens.spacingXl),

                  // ── Selected Child Device Card ───────────────────────
                  _buildChildDeviceCard(context, selectedChild),
                  const SizedBox(height: DesignTokens.spacingXl),

                  // ── Rules Panel ──────────────────────────────────────
                  _buildRulesHeader(context, selectedChild, rules.length, enabledRules),
                  const SizedBox(height: DesignTokens.spacingMd),
                  if (rules.isEmpty)
                    _buildEmptyRulesHint(context, selectedChild)
                  else
                    ...rules.take(4).map((rule) => Padding(
                          padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
                          child: _RuleListTile(
                            rule: rule,
                            onToggle: (v) {
                              ref.read(familyProfileProvider.notifier)
                                  .updateRule(rule.copyWith(isEnabled: v));
                            },
                            onEdit: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => ChildRuleEditorSheet(
                                  childId: selectedChild.id,
                                  childName: selectedChild.name,
                                  existingRule: rule,
                                ),
                              );
                            },
                          ),
                        )),

                  if (rules.length > 4)
                    Padding(
                      padding: const EdgeInsets.only(top: DesignTokens.spacingSm),
                      child: TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChildRulesScreen(child: selectedChild),
                          ),
                        ),
                        icon: const Icon(Icons.expand_more_rounded),
                        label: Text('View all ${rules.length} rules'),
                      ),
                    ),

                  const SizedBox(height: DesignTokens.spacingXl),

                  // ── Recent Alerts ────────────────────────────────────
                  _buildSectionTitle('Recent Alerts'),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _buildAlertFeed(),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'parent_fab',
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ChildRuleEditorSheet(
            childId: selectedChild.id,
            childName: selectedChild.name,
          ),
        ),
        backgroundColor: AppColors.neonPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Rule', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(BuildContext context, FamilyProfile profile) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      floating: true,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: DesignTokens.spacingSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Parent Hub',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              Text(profile.familyName,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.neonPurple, fontWeight: FontWeight.w500)),
            ],
          ),
          const Spacer(),
          // Family code badge
          GestureDetector(
            onTap: () => _showFamilyInfoSheet(context, profile),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.neonPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.vpn_key_rounded, size: 12, color: AppColors.neonPurple),
                  const SizedBox(width: 4),
                  Text(profile.familyCode,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.neonPurple)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.cyberBlue),
            tooltip: 'Add Child',
            onPressed: () => _showAddChildSheet(context),
          ),
        ],
      ),
    );
  }

  // ── Family Safety Banner ─────────────────────────────────────────────

  Widget _buildFamilySafetyBanner(List<ChildProfile> children, FamilyProfile profile) {
    final totalRules = profile.rules.where((r) => r.isEnabled).length;
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingLg),
      decoration: BoxDecoration(
        gradient: AppColors.gradientParent,
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
                const Text('Family Safety Index',
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 4),
                const Text('All Systems Active',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatPill(label: '${children.length} Children', icon: Icons.child_care_rounded),
                    const SizedBox(width: 8),
                    _StatPill(label: '$totalRules Active Rules', icon: Icons.gavel_rounded),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 30),
          ),
        ],
      ),
    ).animate().fadeIn(duration: DesignTokens.animNormal).slideY(begin: 0.05, end: 0);
  }

  // ── Child Selector ───────────────────────────────────────────────────

  Widget _buildChildSelector(List<ChildProfile> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Child',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        const SizedBox(height: DesignTokens.spacingMd),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final child = children[index];
              final isSelected = _selectedChildIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedChildIndex = index),
                child: AnimatedContainer(
                  duration: DesignTokens.animFast,
                  width: 76,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.cyberBlue.withValues(alpha: 0.08)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                    border: Border.all(
                      color: isSelected ? AppColors.cyberBlue : AppColors.outline,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.cyberBlue.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(child.avatarEmoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        child.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.cyberBlue : AppColors.onSurfaceMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  // ── Child Device Card ────────────────────────────────────────────────

  Widget _buildChildDeviceCard(BuildContext context, ChildProfile child) {
    // Mock device data based on child
    final isRiya = child.id == 'child_riya';
    final screenTime = isRiya ? '4h 23m' : '1h 45m';
    final battery = isRiya ? 78 : 92;
    final location = isRiya ? 'Green Park High School' : 'Home Wi-Fi';
    final riskColor = isRiya ? AppColors.warningAmber : AppColors.emeraldGreen;
    final riskLabel = isRiya ? 'Medium Risk' : 'Safe';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.neonPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Center(
                  child: Text(child.avatarEmoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                    Text('${child.deviceModel} • $location',
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  border: Border.all(color: riskColor.withValues(alpha: 0.5)),
                ),
                child: Text(riskLabel,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: riskColor)),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          const Divider(color: AppColors.outline),
          const SizedBox(height: DesignTokens.spacingMd),
          // Stats row
          Row(
            children: [
              _DeviceStat(icon: Icons.timer_outlined, label: 'Screen time', value: screenTime),
              const SizedBox(width: DesignTokens.spacingXl),
              _DeviceStat(
                  icon: Icons.battery_charging_full_rounded,
                  label: 'Battery',
                  value: '$battery%'),
              const Spacer(),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          // Quick controls
          Row(
            children: [
              _QuickControl(
                icon: Icons.pause_rounded,
                label: 'Pause Net',
                color: AppColors.warningOrange,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Internet paused for ${child.name}')),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              _QuickControl(
                icon: Icons.location_on_rounded,
                label: 'Live Track',
                color: AppColors.neonPurple,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${child.name} is at $location')),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              _QuickControl(
                icon: Icons.notifications_active_rounded,
                label: 'Ring',
                color: AppColors.cyberBlue,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ringing ${child.deviceName}...')),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.03, end: 0);
  }

  // ── Rules Header ─────────────────────────────────────────────────────

  Widget _buildRulesHeader(
      BuildContext context, ChildProfile child, int total, int enabled) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${child.name}'s Rules",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              Text(
                '$enabled/$total active',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.neonPurple, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChildRulesScreen(child: child),
            ),
          ),
          icon: const Icon(Icons.open_in_full_rounded, size: 16),
          label: const Text('Manage All'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.neonPurple,
            side: BorderSide(color: AppColors.neonPurple.withValues(alpha: 0.5)),
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildEmptyRulesHint(BuildContext context, ChildProfile child) {
    return GlassCard(
      child: Column(
        children: [
          const Icon(Icons.rule_rounded, color: AppColors.neonPurple, size: 36),
          const SizedBox(height: DesignTokens.spacingMd),
          Text(
            'No rules set for ${child.name} yet',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
          const SizedBox(height: DesignTokens.spacingXs),
          const Text(
            'Tap "Add Rule" to set up screen time limits, app blocks, bedtime curfews, and more.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted, height: 1.4),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
    );
  }

  Widget _buildAlertFeed() {
    final alerts = [
      (
        category: 'Possible explicit language',
        source: 'SMS • Riya',
        time: '14 min ago',
        level: RiskLevel.medium,
      ),
      (
        category: 'Unknown URL in message',
        source: 'SMS • Riya',
        time: '1 hr ago',
        level: RiskLevel.high,
      ),
      (
        category: 'Screen time limit reached',
        source: 'App Usage • Riya',
        time: '2 hr ago',
        level: RiskLevel.low,
      ),
    ];

    return Column(
      children: alerts.asMap().entries.map((e) {
        final a = e.value;
        Color levelColor;
        switch (a.level) {
          case RiskLevel.high:
          case RiskLevel.critical:
            levelColor = AppColors.errorRed;
            break;
          case RiskLevel.medium:
            levelColor = AppColors.warningAmber;
            break;
          default:
            levelColor = AppColors.emeraldGreen;
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
          child: GlassCard(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.warning_amber_rounded, color: levelColor, size: 18),
                ),
                const SizedBox(width: DesignTokens.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.category,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                      Text(a.source,
                          style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                    ],
                  ),
                ),
                Text(a.time,
                    style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceMuted)),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 300 + e.key * 60)),
        );
      }).toList(),
    );
  }

  // ── No Children View ─────────────────────────────────────────────────

  Widget _buildNoChildrenView(BuildContext context, FamilyProfile profile) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.neonPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.child_care_rounded, color: AppColors.neonPurple, size: 40),
                ),
                const SizedBox(height: DesignTokens.spacingXl),
                const Text(
                  'No Children Added Yet',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                const SizedBox(height: DesignTokens.spacingSm),
                const Text(
                  'Add your child\'s device to start monitoring and setting rules.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted, height: 1.4),
                ),
                const SizedBox(height: DesignTokens.spacingXxl),
                ElevatedButton.icon(
                  onPressed: () => _showAddChildSheet(context),
                  icon: const Icon(Icons.person_add_rounded),
                  label: const Text('Add Child'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: DesignTokens.animNormal),
          ),
        ),
      ),
    );
  }

  // ── Modals ───────────────────────────────────────────────────────────

  void _showAddChildSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emojiOptions = ['👧', '👦', '🧒', '👶'];
    String selectedEmoji = '👧';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXxl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Add Child',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Choose Avatar',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted)),
              const SizedBox(height: 8),
              Row(
                children: emojiOptions.map((e) {
                  final isSelected = selectedEmoji == e;
                  return GestureDetector(
                    onTap: () => setSheet(() => selectedEmoji = e),
                    child: AnimatedContainer(
                      duration: DesignTokens.animFast,
                      margin: const EdgeInsets.only(right: 10),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.neonPurple.withValues(alpha: 0.1)
                            : AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.neonPurple : AppColors.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Child's Name",
                  hintText: 'e.g. Riya',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  ref.read(familyProfileProvider.notifier).addChild(
                        ChildProfile(
                          id: 'child_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          avatarEmoji: selectedEmoji,
                          deviceId: '',
                          deviceName: "${nameCtrl.text.trim()}'s Device",
                          deviceModel: 'Unknown Device',
                        ),
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${nameCtrl.text.trim()} added to your family!'),
                      backgroundColor: AppColors.emeraldGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPurple, foregroundColor: Colors.white),
                child: const Text('Add Child'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFamilyInfoSheet(BuildContext context, FamilyProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXxl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Family Info',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  _InfoRow(label: 'Family Name', value: profile.familyName),
                  _InfoRow(label: 'Your Role', value: '👑 Family Admin'),
                  _InfoRow(label: 'Children', value: '${profile.children.length}'),
                  _InfoRow(label: 'Members', value: '${profile.members.length}'),
                  const Divider(color: AppColors.outline),
                  const SizedBox(height: 8),
                  const Text('Family Code (share with members)',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.neonPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profile.familyCode,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                            color: AppColors.neonPurple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.copy_rounded, color: AppColors.neonPurple, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (profile.members.isNotEmpty) ...[
              const Text('Family Members',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              ...profile.members.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.person_rounded,
                            color: AppColors.cyberBlue, size: 18),
                        const SizedBox(width: 8),
                        Text(m.name,
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.onSurface)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cyberBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                          ),
                          child: const Text('Member',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cyberBlue)),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Compact Rule List Tile (for dashboard) ────────────────────────────────

class _RuleListTile extends StatelessWidget {
  const _RuleListTile({
    required this.rule,
    required this.onToggle,
    required this.onEdit,
  });

  final ChildRule rule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(rule.type);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Text(rule.type.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: rule.isEnabled ? AppColors.onSurface : AppColors.onSurfaceMuted,
                    )),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                      ),
                      child: Text(rule.value,
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700, color: typeColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.edit_rounded, color: AppColors.onSurfaceMuted, size: 16),
            ),
          ),
          const SizedBox(width: 4),
          Switch(
            value: rule.isEnabled,
            onChanged: onToggle,
            activeColor: typeColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Color _typeColor(RuleType type) {
    switch (type) {
      case RuleType.screenTimeLimit: return AppColors.cyberBlue;
      case RuleType.appBlock:        return AppColors.errorRed;
      case RuleType.bedtimeCurfew:   return AppColors.neonPurple;
      case RuleType.safeZone:        return AppColors.emeraldGreen;
      case RuleType.contentFilter:   return AppColors.warningOrange;
      case RuleType.webFilter:       return AppColors.warningAmber;
    }
  }
}

// ── Shared Sub-widgets ────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DeviceStat extends StatelessWidget {
  const _DeviceStat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceMuted),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 9, color: AppColors.onSurfaceMuted)),
            Text(value,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          ],
        ),
      ],
    );
  }
}

class _QuickControl extends StatelessWidget {
  const _QuickControl(
      {required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}
