import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../home/widgets/amazon_weather_card.dart';

/// Child Home Screen — the kid-safe landing experience.
///
/// Always shows an honest "MONITORING ACTIVE — monitored by [Parent Name]"
/// banner. Never hidden, never disguised. Child cannot dismiss this.
///
/// Features: simplified SOS big button, friendly status, quick access
/// to Link Detective game and CyberShield-lite. No parental controls,
/// no other family members' data visible.
class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key, required this.parentName});
  final String parentName;

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _sosActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Always-visible monitoring banner (mandatory transparency) ──
            _buildMonitoringBanner(),
            Expanded(
              child: CustomScrollView(
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
                        _buildGreeting(),
                        const SizedBox(height: DesignTokens.spacingLg),
                        const AmazonWeatherCard(),
                        const SizedBox(height: DesignTokens.spacingXl),
                        _buildSosButton(),
                        const SizedBox(height: 8),
                        _buildSosDisclaimer(),
                        const SizedBox(height: DesignTokens.spacingXl),
                        _buildActivityCards(),
                        const SizedBox(height: DesignTokens.spacingXl),
                        _buildRequestChanges(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Monitoring Banner (mandatory — never hidden) ─────────────────────────

  Widget _buildMonitoringBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: AppColors.surfaceElevated,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.emeraldGreen,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .fadeOut(duration: 800.ms)
              .then()
              .fadeIn(duration: 800.ms),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'MONITORING ACTIVE — monitored by ${widget.parentName}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.emeraldGreen,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: AppColors.onSurfaceMuted,
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────

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
              gradient: AppColors.gradientDetective,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GUARDIAN PLUS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Your safe space 🛡️',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.detectiveTeal,
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

  // ── Greeting ─────────────────────────────────────────────────────────────

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? '☀️ Good Morning!'
        : hour < 17
            ? '🌤️ Good Afternoon!'
            : '🌙 Good Evening!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Stay safe out there. You\'re protected! 💚',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceMuted,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0);
  }

  // ── SOS Button ───────────────────────────────────────────────────────────

  Widget _buildSosButton() {
    return Center(
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.heavyImpact();
          setState(() => _sosActive = true);
        },
        onTapUp: (_) => setState(() => _sosActive = false),
        onTapCancel: () => setState(() => _sosActive = false),
        onLongPress: _triggerSos,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final glow = 0.15 + (_pulseController.value * 0.25);
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                AnimatedContainer(
                  duration: DesignTokens.animFast,
                  width: _sosActive ? 200 : 180,
                  height: _sosActive ? 200 : 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.safetyPink.withValues(alpha: glow * 0.4),
                  ),
                ),
                // Middle ring
                AnimatedContainer(
                  duration: DesignTokens.animFast,
                  width: _sosActive ? 165 : 148,
                  height: _sosActive ? 165 : 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.safetyPink.withValues(alpha: glow * 0.6),
                  ),
                ),
                // Main button
                AnimatedContainer(
                  duration: DesignTokens.animFast,
                  width: _sosActive ? 122 : 130,
                  height: _sosActive ? 122 : 130,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradientSafety,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emergency_rounded, color: Colors.white, size: 36),
                      const SizedBox(height: 4),
                      Text(
                        'SOS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      Text(
                        'HOLD',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSosDisclaimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: AppColors.onSurfaceMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This notifies your trusted contacts. It does not call emergency services automatically.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerSos() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚨 SOS alert sent to your trusted contacts',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.safetyPink,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Activity Cards ────────────────────────────────────────────────────────

  Widget _buildActivityCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TODAY\'S ACTIVITIES',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceMuted,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActivityCard(
                icon: '🕵️',
                title: 'Link Detective',
                subtitle: 'Today\'s challenges',
                accent: AppColors.detectiveTeal,
                badge: '3 left',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActivityCard(
                icon: '🛡️',
                title: 'CyberShield',
                subtitle: 'Check a link',
                accent: AppColors.cyberBlue,
                badge: 'Scan',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Request Changes ───────────────────────────────────────────────────────

  Widget _buildRequestChanges() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.neonPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.send_rounded,
                color: AppColors.neonPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Changes',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Ask ${widget.parentName} to adjust settings',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.onSurfaceSubtle, size: 20),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 300.ms);
  }
}

// ── Activity Card ─────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.badge,
  });
  final String icon;
  final String title;
  final String subtitle;
  final Color accent;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
            child: Text(
              badge,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
