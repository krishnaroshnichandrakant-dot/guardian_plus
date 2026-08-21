import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';
import '../widgets/child_rule_editor_sheet.dart';

/// Full-screen rules management for a single child.
/// Shows all rules grouped by category, toggle on/off, edit and delete.
class ChildRulesScreen extends ConsumerStatefulWidget {
  const ChildRulesScreen({
    super.key,
    required this.child,
  });

  final ChildProfile child;

  @override
  ConsumerState<ChildRulesScreen> createState() => _ChildRulesScreenState();
}

class _ChildRulesScreenState extends ConsumerState<ChildRulesScreen> {
  @override
  Widget build(BuildContext context) {
    final rules = ref.watch(childRulesProvider(widget.child.id));
    final notifier = ref.read(familyProfileProvider.notifier);

    // Group by RuleType category
    final groupedRules = <RuleType, List<ChildRule>>{};
    for (final rule in rules) {
      groupedRules.putIfAbsent(rule.type, () => []).add(rule);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, rules.length),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenPadding,
                DesignTokens.spacingMd,
                DesignTokens.screenPadding,
                120,
              ),
              sliver: rules.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState())
                  : SliverList(
                      delegate: SliverChildListDelegate(
                        _buildGroupedRules(groupedRules, notifier),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRuleEditor(context),
        backgroundColor: AppColors.neonPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Rule', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, int ruleCount) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.child.avatarEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spacingSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.child.name}'s Rules",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              Text(
                '$ruleCount rule${ruleCount == 1 ? '' : 's'} applied',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.neonPurple, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedRules(
      Map<RuleType, List<ChildRule>> groupedRules, FamilyProfileNotifier notifier) {
    final widgets = <Widget>[];
    var delay = 0;
    for (final entry in groupedRules.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(
              top: DesignTokens.spacingLg, bottom: DesignTokens.spacingSm),
          child: Row(
            children: [
              Text(
                entry.key.emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                entry.key.displayName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceMuted,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Text(
                  '${entry.value.length}',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: DesignTokens.animFast),
      );
      for (final rule in entry.value) {
        widgets.add(
          _RuleCard(
            rule: rule,
            onToggle: (enabled) {
              notifier.updateRule(rule.copyWith(isEnabled: enabled));
            },
            onEdit: () => _openRuleEditor(context, existing: rule),
            onDelete: () => _confirmDelete(context, rule, notifier),
          )
              .animate()
              .fadeIn(
                  delay: Duration(milliseconds: delay + 60),
                  duration: DesignTokens.animNormal)
              .slideX(begin: 0.03, end: 0),
        );
        widgets.add(const SizedBox(height: DesignTokens.spacingSm));
        delay += 40;
      }
    }
    return widgets;
  }

  Widget _buildEmptyState() {
    return Center(
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
            child: const Icon(Icons.rule_rounded, color: AppColors.neonPurple, size: 40),
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          Text(
            'No rules yet for ${widget.child.name}',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          const Text(
            'Tap "Add Rule" to set screen time limits,\napp blocks, bedtime curfews, and more.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, height: 1.4),
          ),
        ],
      ).animate().fadeIn(duration: DesignTokens.animNormal).scale(begin: const Offset(0.95, 0.95)),
    );
  }

  void _openRuleEditor(BuildContext context, {ChildRule? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChildRuleEditorSheet(
        childId: widget.child.id,
        childName: widget.child.name,
        existingRule: existing,
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, ChildRule rule, FamilyProfileNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl)),
        title: const Text('Delete Rule?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text('Remove "${rule.label}" from ${widget.child.name}\'s rules?',
            style: const TextStyle(color: AppColors.onSurfaceMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      notifier.deleteRule(rule.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${rule.label}" removed.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
}

// ── Rule Card ─────────────────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.rule,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final ChildRule rule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(rule.type);
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Center(
              child: Text(rule.type.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: DesignTokens.spacingMd),
          // Label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: rule.isEnabled ? AppColors.onSurface : AppColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                      ),
                      child: Text(
                        rule.value,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  rule.detail,
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Actions
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch(
                value: rule.isEnabled,
                onChanged: onToggle,
                activeColor: typeColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(Icons.edit_rounded, color: AppColors.onSurfaceMuted, size: 18),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 18),
                  ),
                ],
              ),
            ],
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
