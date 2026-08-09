import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../screens/parent_dashboard.dart';

class RiskAlertDetailScreen extends StatelessWidget {
  const RiskAlertDetailScreen({
    super.key,
    required this.category,
    required this.source,
    required this.confidence,
    required this.signals,
    required this.time,
    required this.level,
  });

  final String category;
  final String source;
  final int confidence;
  final String signals;
  final String time;
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(level);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Risk Alert Details'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlertHeader(color),
            const SizedBox(height: DesignTokens.spacingXl),
            _buildSignalBasisCard(color),
            const SizedBox(height: DesignTokens.spacingXl),
            _buildPrivacyDisclosureNotice(),
            const SizedBox(height: DesignTokens.spacingXxl),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertHeader(Color color) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Text(
                  _riskLabel(level).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Text(
                  source,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted),
                ),
              ),
              const Spacer(),
              Text(time, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          Text(
            category,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          Row(
            children: [
              Text(
                'Confidence Score: ',
                style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceMuted),
              ),
              Text(
                '$confidence%',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: DesignTokens.animNormal);
  }

  Widget _buildSignalBasisCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Signal Basis & Explanation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingSm),
          Text(
            signals,
            style: const TextStyle(fontSize: 13, color: AppColors.onSurface, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyDisclosureNotice() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.cyberBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        border: Border.all(color: AppColors.cyberBlue.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.cyberBlue, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Per privacy guidelines (§4), raw message text is never sent or displayed. '
              'Only category risk indicators and matched signals are reported.',
              style: TextStyle(fontSize: 11, color: AppColors.cyberBlue, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss Alert'),
          ),
        ),
        const SizedBox(width: DesignTokens.spacingMd),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Action flow (e.g., restrict app / talk to child)
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyberBlue),
            child: const Text('Take Action'),
          ),
        ),
      ],
    );
  }

  Color _riskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.clean:
      case RiskLevel.low:
        return AppColors.emeraldGreen;
      case RiskLevel.medium:
        return AppColors.warningAmber;
      case RiskLevel.high:
        return AppColors.warningOrange;
      case RiskLevel.critical:
        return AppColors.errorRed;
    }
  }

  String _riskLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.clean:
        return 'Clean';
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.critical:
        return 'Critical';
    }
  }
}
