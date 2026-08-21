import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/glass_card.dart';

/// Family Setup Screen — shown to any user who hasn't joined a family group yet.
/// Choice: [Create Family] as Admin, or [Join Family] as Member with a code.
class FamilySetupScreen extends ConsumerStatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  ConsumerState<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends ConsumerState<FamilySetupScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DesignTokens.spacingXl),
              _buildHeroHeader(),
              const SizedBox(height: DesignTokens.spacingXxl),
              _buildTabBar(),
              const SizedBox(height: DesignTokens.spacingXl),
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonPurple.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.family_restroom_rounded, color: Colors.white, size: 32),
        )
            .animate()
            .scale(duration: DesignTokens.animSlow, curve: Curves.elasticOut),
        const SizedBox(height: DesignTokens.spacingLg),
        Text(
          'Set Up Your\nFamily Group',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.onSurface,
                height: 1.15,
              ),
        )
            .animate()
            .fadeIn(delay: 150.ms, duration: DesignTokens.animNormal)
            .slideY(begin: 0.1, end: 0),
        const SizedBox(height: DesignTokens.spacingSm),
        Text(
          'One admin manages the family. Members get safety features only.',
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate().fadeIn(delay: 250.ms),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.onSurface,
        unselectedLabelColor: AppColors.onSurfaceMuted,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '👑  Create Family'),
          Tab(text: '🔗  Join Family'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 460,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateTab(),
          _buildJoinTab(),
        ],
      ),
    );
  }

  // ── Create Family Tab ──────────────────────────────────────────────

  Widget _buildCreateTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                icon: Icons.admin_panel_settings_rounded,
                color: AppColors.neonPurple,
                title: 'Family Admin',
                subtitle: 'Full access: monitor devices, set rules, view locations',
              ),
              const SizedBox(height: DesignTokens.spacingMd),
              _buildInfoRow(
                icon: Icons.group_rounded,
                color: AppColors.cyberBlue,
                title: 'Family Members',
                subtitle: 'Security features only — no parental controls visible',
              ),
              const SizedBox(height: DesignTokens.spacingMd),
              _buildInfoRow(
                icon: Icons.share_rounded,
                color: AppColors.emeraldGreen,
                title: 'Share Code',
                subtitle: 'Share the family code so members can join on their devices',
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms)
            .slideY(begin: 0.05, end: 0),
        const SizedBox(height: DesignTokens.spacingXl),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Your Name (as Family Admin)',
            hintText: 'e.g. Rajesh',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          textCapitalization: TextCapitalization.words,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: DesignTokens.spacingXl),
        ElevatedButton.icon(
          onPressed: _loading ? null : _handleCreateFamily,
          icon: _loading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.add_home_rounded),
          label: const Text('Create Family Group'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonPurple,
            foregroundColor: Colors.white,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  // ── Join Family Tab ────────────────────────────────────────────────

  Widget _buildJoinTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cyberBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: const Icon(Icons.info_outline_rounded, color: AppColors.cyberBlue),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              const Expanded(
                child: Text(
                  'Ask your Family Admin for the 6-character family code. You\'ll have access to Cybersecurity and Women\'s Safety features.',
                  style: TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted, height: 1.4),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: DesignTokens.spacingXl),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'e.g. Priya',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          textCapitalization: TextCapitalization.words,
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: DesignTokens.spacingMd),
        TextField(
          controller: _codeCtrl,
          decoration: const InputDecoration(
            labelText: 'Family Code',
            hintText: 'e.g. GTR-7K2',
            prefixIcon: Icon(Icons.vpn_key_rounded),
          ),
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
            LengthLimitingTextInputFormatter(7),
          ],
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: DesignTokens.spacingXl),
        ElevatedButton.icon(
          onPressed: _loading ? null : _handleJoinFamily,
          icon: _loading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.link_rounded),
          label: const Text('Join Family Group'),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: DesignTokens.spacingMd),
        // Demo shortcut
        OutlinedButton.icon(
          onPressed: () {
            _codeCtrl.text = 'GTR-7K2';
            _nameCtrl.text = 'Priya';
          },
          icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
          label: const Text('Use Demo Code (GTR-7K2)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.onSurfaceMuted,
            side: const BorderSide(color: AppColors.outlineVariant),
            minimumSize: const Size(double.infinity, 44),
          ),
        ).animate().fadeIn(delay: 350.ms),
      ],
    );
  }

  // ── Actions ────────────────────────────────────────────────────────

  Future<void> _handleCreateFamily() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Please enter your name.');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    ref.read(familyProfileProvider.notifier).createFamily(
          adminName: _nameCtrl.text.trim(),
        );
    final profile = ref.read(familyProfileProvider);
    if (mounted) {
      setState(() => _loading = false);
      _showFamilyCodeDialog(profile.familyCode, profile.familyName);
    }
  }

  Future<void> _handleJoinFamily() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Please enter your name.');
      return;
    }
    if (_codeCtrl.text.trim().length < 4) {
      _showError('Please enter a valid family code.');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    final success = ref.read(familyProfileProvider.notifier).joinFamily(
          code: _codeCtrl.text.trim(),
          memberName: _nameCtrl.text.trim(),
        );
    if (mounted) {
      setState(() => _loading = false);
      if (success) {
        context.go(Routes.cybersecurityDashboard);
      } else {
        _showError('Invalid family code. Please check and try again.');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFamilyCodeDialog(String code, String familyName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusXl)),
        title: const Row(
          children: [
            Text('🎉', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Text('Family Created!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to $familyName. Share this code with your family members:',
              style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Code copied!')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.neonPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                        color: AppColors.neonPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.copy_rounded, color: AppColors.neonPurple, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(Routes.parentDashboard);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPurple),
            child: const Text('Go to Parent Hub'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: DesignTokens.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
