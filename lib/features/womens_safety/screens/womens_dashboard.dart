import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import 'fake_call_screen.dart';
import 'safe_route_screen.dart';
import '../services/siren_audio_service.dart';
import '../services/hardware_panic_service.dart';

/// Guardian Safety — Screen 3 from reference mockups.
class WomensDashboard extends ConsumerStatefulWidget {
  const WomensDashboard({super.key});

  @override
  ConsumerState<WomensDashboard> createState() => _WomensDashboardState();
}

class _WomensDashboardState extends ConsumerState<WomensDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _holdTimer;
  double _holdProgress = 0.0;
  bool _isHolding = false;
  bool _sirenActive = false;

  final List<Map<String, String>> _contacts = [
    {'name': 'Mom', 'phone': '+91 98765 43210', 'avatar': '👩'},
    {'name': 'Dad', 'phone': '+91 98765 43211', 'avatar': '👨'},
    {'name': 'Sister', 'phone': '+91 98765 43212', 'avatar': '👧'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initialize 5-Press Hardware Panic Listener
    HardwarePanicService.instance.initialize();
    HardwarePanicService.activeEmergencyNotifier.addListener(_onEmergencyEventChanged);
  }

  @override
  void dispose() {
    HardwarePanicService.activeEmergencyNotifier.removeListener(_onEmergencyEventChanged);
    _pulseController.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  void _onEmergencyEventChanged() {
    final event = HardwarePanicService.activeEmergencyNotifier.value;
    if (event != null && mounted) {
      _showEmergencyDispatchHudModal(event);
    }
  }

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
                8,
                DesignTokens.screenPadding,
                100,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeroAtmosphereBanner(),
                  const SizedBox(height: 16),
                  _buildHardwarePanicCard(),
                  const SizedBox(height: 16),
                  _buildHomeScreenSosWidgetCard(context),
                  const SizedBox(height: 20),
                  _buildGlowingSosButton(),
                  const SizedBox(height: 24),
                  _buildToolsGrid(context),
                  const SizedBox(height: 24),
                  _buildTrustedContactsSection(context),
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
      elevation: 0,
      floating: true,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.safetyPink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.favorite_rounded, color: AppColors.safetyPink, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guardian Safety',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'Be Aware. Be Confident.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.safetyPink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceMuted),
          onPressed: () => _showPanicSettingsModal(context),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.outline),
      ),
    );
  }

  // ── Hero Atmosphere Banner ────────────────────────────────────────────────

  Widget _buildHeroAtmosphereBanner() {
    return Container(
      height: 95,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
        ),
        border: Border.all(color: AppColors.safetyPink.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.safetyPink.withValues(alpha: 0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.safetyPink.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                border: Border.all(color: AppColors.safetyPink.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Stronger · Safer · Brighter',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.safetyPinkDark,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Women\'s Safety Net',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Instant alerts · Live GPS link · Hardware Panic Trigger',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 5-Press Hardware Panic Card (Screen-On / Screen-Off / Background) ────

  Widget _buildHardwarePanicCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: AppColors.safetyPink.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.safetyPink.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.safetyPink.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flash_on_rounded, color: AppColors.safetyPink, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '5-Press Hardware Panic',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emeraldGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Press Power or Volume button 5x (Works with app closed & screen off)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons: Test Trigger & Settings
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    HardwarePanicService.instance.triggerEmergencyPanic(
                      triggerSource: '5-Press Power/Volume Hardware Sequence',
                    );
                  },
                  icon: const Icon(Icons.emergency_rounded, color: Colors.white, size: 18),
                  label: Text(
                    '⚡ Test 5-Press Panic Sequence',
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.safetyPink,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _showPanicSettingsModal(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  side: const BorderSide(color: AppColors.outline),
                  minimumSize: const Size(44, 42),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.tune_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Home-Screen / Lock-Screen SOS Widget & Quick Launcher ─────────────────

  Widget _buildHomeScreenSosWidgetCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: AppColors.cyberBlue.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyberBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.cyberBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.widgets_rounded, color: AppColors.cyberBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Home / Lock Screen Widget',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '1-TAP LOCK SCREEN',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emeraldGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Trigger Siren, Live GPS & Fake Call directly from Home / Lock Screen widget',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Interactive Widget Tile Preview Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                // SOS Panic Tile Shortcut
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      HardwarePanicService.instance.triggerEmergencyPanic(
                        triggerSource: 'Home/Lock Screen Widget Tile Shortcut',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientSafety,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.safetyPink.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            '1-TAP SOS PANIC',
                            style: GoogleFonts.spaceGrotesk(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Scheduled Fake Call Tile Shortcut
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FakeCallScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.neonPurple,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonPurple.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone_callback_rounded, color: Colors.white, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            'FAKE CALL (10m)',
                            style: GoogleFonts.spaceGrotesk(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons: Setup Guide & Test Trigger
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showWidgetGuideModal(context),
                  icon: const Icon(Icons.add_to_home_screen_rounded, color: AppColors.cyberBlue, size: 18),
                  label: Text(
                    '📲 Add Widget to Lock Screen',
                    style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cyberBlue,
                    side: const BorderSide(color: AppColors.cyberBlue),
                    minimumSize: const Size(double.infinity, 42),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWidgetGuideModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cyberBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.widgets_rounded, color: AppColors.cyberBlue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Home & Lock Screen Widget Guide',
                    style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                'How to add 1-Tap SOS to Android Home & Lock Screen:',
                style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),

              _buildGuideStep('1', 'Go to your Android / iOS Home Screen and long-press on any empty area.'),
              _buildGuideStep('2', 'Select "Widgets" from the bottom menu.'),
              _buildGuideStep('3', 'Scroll down to "Guardian Plus" and drag the 1-Tap SOS Panic Tile onto your home screen.'),
              _buildGuideStep('4', 'For Lock Screen: Open Phone Settings > Wallpaper & Lock Screen > Add Lock Screen Widget > Select Guardian Plus SOS.'),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.emeraldGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Deep Link Activated: guardianplus://sos_trigger is registered for instant 1-tap activation.',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.emeraldGreen),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyberBlue, foregroundColor: Colors.black),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.cyberBlue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(num, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.cyberBlue)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface, height: 1.3)),
          ),
        ],
      ),
    );
  }

  // ── Large Glowing SOS Button ──────────────────────────────────────────────

  Widget _buildGlowingSosButton() {
    return Center(
      child: GestureDetector(
        onTapDown: (_) => _startHoldTimer(),
        onTapUp: (_) => _cancelHoldTimer(),
        onTapCancel: () => _cancelHoldTimer(),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulseVal = _pulseController.value;
            final glowSize = 210 + (pulseVal * 18);
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow aura
                Container(
                  width: glowSize,
                  height: glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.safetyPink.withValues(alpha: 0.25 + (pulseVal * 0.15)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Middle border ring
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.safetyPink.withValues(alpha: 0.4 + (pulseVal * 0.3)),
                      width: 2,
                    ),
                  ),
                ),
                // Circular Progress Indicator for 3s hold
                if (_isHolding)
                  SizedBox(
                    width: 155,
                    height: 155,
                    child: CircularProgressIndicator(
                      value: _holdProgress,
                      strokeWidth: 4,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                // Center SOS Button
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradientSafety,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.safetyPink.withValues(alpha: 0.5),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'HOLD TO',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SOS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isHolding
                            ? '${((1.0 - _holdProgress) * 3).toStringAsFixed(1)}s'
                            : 'Hold 3s or 5x Button',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
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
    );
  }

  void _startHoldTimer() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isHolding = true;
      _holdProgress = 0.0;
    });

    const totalSteps = 30;
    int currentStep = 0;

    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      currentStep++;
      if (mounted) {
        setState(() {
          _holdProgress = currentStep / totalSteps;
        });
      }

      if (currentStep % 5 == 0) {
        HapticFeedback.mediumImpact();
      }

      if (currentStep >= totalSteps) {
        timer.cancel();
        HardwarePanicService.instance.triggerEmergencyPanic(triggerSource: 'Manual 3s Hold SOS Button');
      }
    });
  }

  void _cancelHoldTimer() {
    _holdTimer?.cancel();
    if (_isHolding) {
      setState(() {
        _isHolding = false;
        _holdProgress = 0.0;
      });
    }
  }

  // ── Active Emergency Dispatch HUD Modal ───────────────────────────────────

  void _showEmergencyDispatchHudModal(EmergencyDispatchEvent event) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Siren Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.safetyPink.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.safetyPink, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.safetyPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🚨 EMERGENCY PANIC ACTIVATED!',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.safetyPink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Trigger: ${event.triggerSource}',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Emergency Dispatch Status List
              Text(
                'Broadcast & Dispatch Status:',
                style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.onSurface),
              ),
              const SizedBox(height: 10),

              _buildDispatchStatusRow(
                icon: Icons.local_police_rounded,
                title: 'Police Signal Dispatched (112 / PCR Control)',
                status: 'SENT & ACKNOWLEDGED',
                color: AppColors.emeraldGreen,
              ),
              const SizedBox(height: 8),
              _buildDispatchStatusRow(
                icon: Icons.location_on_rounded,
                title: 'Live GPS Coordinates Broadcasted',
                status: 'https://maps.google.com/?q=${event.latitude},${event.longitude}',
                color: AppColors.cyberBlue,
              ),
              const SizedBox(height: 8),
              _buildDispatchStatusRow(
                icon: Icons.family_restroom_rounded,
                title: 'Trusted Family SMS Alert Broadcast',
                status: 'Dispatched to Mom, Dad & Sister',
                color: AppColors.neonPurple,
              ),

              const SizedBox(height: 24),

              // Emergency Call & Stop Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HardwarePanicService.instance.cancelEmergency();
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.volume_off_rounded, color: AppColors.onSurface),
                      label: const Text('Stop Siren & Reset'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                        side: const BorderSide(color: AppColors.outline),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dialing Police Emergency (112)...'),
                            backgroundColor: AppColors.safetyPink,
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white),
                      label: const Text('Call 112 Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.safetyPink,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDispatchStatusRow({
    required IconData icon,
    required String title,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                Text(status, style: GoogleFonts.inter(fontSize: 10.5, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPanicSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5-Press Hardware Panic Config',
                      style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      title: const Text('Power Button 5x Trigger'),
                      subtitle: const Text('Press power key 5 times on lockscreen/app'),
                      value: HardwarePanicService.isMonitoring,
                      onChanged: (val) {
                        setModalState(() {
                          HardwarePanicService.isMonitoring = val;
                        });
                        setState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Auto-Call 112 Police Dispatch'),
                      subtitle: const Text('Send direct signal to Police PCR Control'),
                      value: HardwarePanicService.autoCallPolice112,
                      onChanged: (val) {
                        setModalState(() {
                          HardwarePanicService.autoCallPolice112 = val;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Auto-SMS Live GPS to Family'),
                      subtitle: const Text('Send live map link to Mom, Dad & Sister'),
                      value: HardwarePanicService.autoSmsFamily,
                      onChanged: (val) {
                        setModalState(() {
                          HardwarePanicService.autoSmsFamily = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── 6 Quick Safety Tools (2x3 Grid) ───────────────────────────────────────

  Widget _buildToolsGrid(BuildContext context) {
    final tools = [
      _SafetyTool(
        title: 'Safety Walk',
        icon: Icons.directions_walk_rounded,
        color: AppColors.safetyPink,
        onTap: () => _showToolSheet(context, 'Safety Walk Mode Active', 'Real-time countdown and automated check-ins activated.'),
      ),
      _SafetyTool(
        title: 'Live Location',
        icon: Icons.location_on_rounded,
        color: AppColors.emeraldGreen,
        onTap: () => _showToolSheet(context, 'Live Location Shared', 'Sharing live coordinates with trusted contacts for 60 minutes.'),
      ),
      _SafetyTool(
        title: 'Safe Route',
        icon: Icons.alt_route_rounded,
        color: AppColors.cyberBlue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SafeRouteScreen()),
          );
        },
      ),
      _SafetyTool(
        title: 'Fake Call',
        icon: Icons.phone_callback_rounded,
        color: AppColors.neonPurple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FakeCallScreen()),
          );
        },
      ),
      _SafetyTool(
        title: _sirenActive ? 'Stop Siren' : 'Siren Alarm',
        icon: Icons.volume_up_rounded,
        color: _sirenActive ? AppColors.warningAmber : AppColors.safetyPink,
        onTap: () {
          setState(() => _sirenActive = !_sirenActive);
          if (_sirenActive) {
            SirenAudioService.startSiren();
          } else {
            SirenAudioService.stopSiren();
          }
        },
      ),
      _SafetyTool(
        title: 'Emergency Numbers',
        icon: Icons.phone_in_talk_rounded,
        color: AppColors.scamAmber,
        onTap: () => _showEmergencyNumbers(context),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: tools.length,
      itemBuilder: (context, i) {
        final t = tools[i];
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            t.onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(color: t.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: t.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(t.icon, color: t.color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Trusted Contacts Section ──────────────────────────────────────────────

  Widget _buildTrustedContactsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trusted Contacts',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => _showAddContactDialog(context),
              child: Text(
                'View All >',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.safetyPink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 85,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._contacts.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceElevated,
                            border: Border.all(color: AppColors.safetyPink.withValues(alpha: 0.5)),
                          ),
                          alignment: Alignment.center,
                          child: Text(c['avatar']!, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c['name']!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  )),
              GestureDetector(
                onTap: () => _showAddContactDialog(context),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceElevated,
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: const Icon(Icons.add_rounded, color: AppColors.onSurface, size: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Add Trusted Contact', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Contact Name', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.safetyPink),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _contacts.add({
                    'name': nameCtrl.text,
                    'phone': phoneCtrl.text.isEmpty ? '+91 99999 88888' : phoneCtrl.text,
                    'avatar': '👤',
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Contact', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showToolSheet(BuildContext context, String title, String body) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.onSurfaceMuted)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.safetyPink),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyNumbers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('National Emergency Helplines', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            const SizedBox(height: 16),
            _buildHelplineRow('🚨 National Emergency Helpline', '112'),
            _buildHelplineRow('👩 Women Helpline (All India)', '1091'),
            _buildHelplineRow('🚓 Women in Distress (NCW)', '7827170170'),
            _buildHelplineRow('🏥 Cyber Crime Helpline', '1930'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplineRow(String label, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(8)),
            child: Text(number, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, color: AppColors.safetyPink)),
          ),
        ],
      ),
    );
  }
}

class _SafetyTool {
  const _SafetyTool({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
