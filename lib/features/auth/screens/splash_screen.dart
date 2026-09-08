import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// Splash Screen — Screen 1 from reference mockups with Amazon Forest ambient backdrop.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) context.go(Routes.guardianHome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient Rainforest Gradient & Foliage Layers
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF040A08),
                  Color(0xFF091410),
                  Color(0xFF0D1D18),
                  Color(0xFF050B09),
                ],
              ),
            ),
          ),
          // Glow orbs
          Positioned(
            top: 150,
            left: MediaQuery.of(context).size.width / 2 - 120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emeraldGreen.withValues(alpha: 0.12),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                duration: 2.seconds,
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
              ),

          // Main Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Leaf Shield Logo Badge
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(
                      color: AppColors.emeraldGreen.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emeraldGreen.withValues(alpha: 0.35),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.emeraldGreen,
                        size: 56,
                      ),
                      const Icon(
                        Icons.eco_rounded,
                        color: AppColors.emeraldGreen,
                        size: 26,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .scale(duration: 700.ms, curve: Curves.elasticOut)
                    .then()
                    .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.4)),

                const SizedBox(height: 28),

                // App Title
                Text(
                  'Guardian Plus',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'People  ·  Families  ·  A Safer Tomorrow',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceMuted,
                    letterSpacing: 0.8,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
              ],
            ),
          ),

          // Bottom Tagline
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Safety today\nfor a brighter tomorrow',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurfaceSubtle,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
