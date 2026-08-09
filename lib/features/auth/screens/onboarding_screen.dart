import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardPage(
      icon: Icons.shield_rounded,
      gradient: AppColors.gradientPrimary,
      title: 'Cybersecurity\nFor Everyone',
      body: 'Scan URLs, audit app permissions, and stay safe on public Wi-Fi — all on-device, never sending your data to the cloud.',
    ),
    _OnboardPage(
      icon: Icons.family_restroom_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      title: 'Keep Your\nFamily Safe',
      body: 'Transparent, consensual parental monitoring. Your child always knows Guardian Plus is active — no hidden surveillance.',
    ),
    _OnboardPage(
      icon: Icons.favorite_rounded,
      gradient: AppColors.gradientDanger,
      title: 'Personal Safety\nAlways With You',
      body: 'SOS panic button, live location sharing, and fake call — self-activated tools you control.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) => _pages[i].build(context),
              ),
            ),
            // Indicators + buttons
            Padding(
              padding: const EdgeInsets.all(DesignTokens.screenPadding),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: DesignTokens.animFast,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                          color: _currentPage == i
                              ? AppColors.cyberBlue
                              : AppColors.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingXl),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: DesignTokens.animNormal,
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        context.go(Routes.roleSelection);
                      }
                    },
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () => context.go(Routes.roleSelection),
                      child: const Text('Skip', style: TextStyle(color: AppColors.onSurfaceMuted)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  const _OnboardPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Gradient gradient;
  final String title;
  final String body;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyberBlue.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 64),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: DesignTokens.spacingXxl),
          Text(
            title,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: DesignTokens.spacingLg),
          Text(
            body,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceMuted,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
