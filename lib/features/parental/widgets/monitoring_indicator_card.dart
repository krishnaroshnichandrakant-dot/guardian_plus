import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// Transparent, non-dismissible monitoring indicator widget for child devices.
/// Mandatory requirement under Google Play Safety / Stalkerware policies and §5 of spec.
class ChildMonitoringIndicatorCard extends StatelessWidget {
  const ChildMonitoringIndicatorCard({
    super.key,
    required this.parentName,
    required this.pairedAt,
    required this.onRequestUnpair,
  });

  final String parentName;
  final String pairedAt;
  final VoidCallback onRequestUnpair;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.cyberBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.cyberBlue.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.cyberBlue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, color: AppColors.cyberBlue, size: 20),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Guardian Plus Active',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Paired with parent: $parentName',
                      style: const TextStyle(fontSize: 12, color: AppColors.cyberBlue),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: const Text(
                  'VISIBLE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.emeraldGreen,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          const Text(
            'This device is actively monitored for your safety (SMS risk scoring, URL safety, screen time). '
            'Guardian Plus NEVER operates covertly.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted, height: 1.5),
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          Row(
            children: [
              Text(
                'Paired on $pairedAt',
                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onRequestUnpair,
                icon: const Icon(Icons.link_off_rounded, size: 16, color: AppColors.warningAmber),
                label: const Text(
                  'Request Unpair',
                  style: TextStyle(fontSize: 12, color: AppColors.warningAmber),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: DesignTokens.animNormal);
  }
}
