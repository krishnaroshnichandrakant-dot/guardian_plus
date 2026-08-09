import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// Pairing screen — QR-based device linking for parent ↔ child.
/// QR codes are single-use, expire in 5 minutes, Ed25519 signed.
class PairingScreen extends StatelessWidget {
  const PairingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pair Devices'),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DesignTokens.spacingXl),
            const Text(
              'Connect your devices',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            const Text(
              'Show this QR code on the child\'s device, or enter the code manually. '
              'The code expires in 5 minutes and can only be used once.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceMuted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXxl),
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  border: Border.all(
                    color: AppColors.cyberBlue.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyberBlue.withOpacity(0.2),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2_rounded, size: 120, color: Colors.black),
                      Text(
                        'QR Code\n(Requires Firebase setup)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXl),
            // Countdown timer
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  border: Border.all(color: AppColors.warningAmber.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, color: AppColors.warningAmber, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Expires in 4:59',
                      style: TextStyle(
                        color: AppColors.warningAmber,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXl),
            // Transparency notice
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.emeraldGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                border: Border.all(color: AppColors.emeraldGreen.withOpacity(0.3)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_user_rounded, color: AppColors.emeraldGreen, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Once paired, the child\'s device will always display a visible '
                      '"Guardian Plus is monitoring this device" notification. '
                      'The child can always see who is paired and request unpairing.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.emeraldGreen,
                        height: 1.5,
                      ),
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
}
