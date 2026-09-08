import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// Fraud Detection (PS #17) — Screen 8 from reference mockups.
class ScamguardDashboard extends StatefulWidget {
  const ScamguardDashboard({super.key});

  @override
  State<ScamguardDashboard> createState() => _ScamguardDashboardState();
}

class _ScamguardDashboardState extends State<ScamguardDashboard> {
  int _selectedTab = 0; // 0 = Payment QR, 1 = Transaction Link

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ScamGuard',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Think Before You Pay.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.scamAmber,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(DesignTokens.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSegmentSwitch(),
                    const SizedBox(height: 18),
                    _buildHighRiskCard(),
                    const SizedBox(height: 20),
                    _buildPossibleReasonsSection(),
                    const SizedBox(height: 18),
                    _buildWarningGuidancePill(),
                  ],
                ),
              ),
            ),
            _buildBottomActionButtons(context),
          ],
        ),
      ),
    );
  }

  // ── Segment Switch: [Payment QR] [Transaction Link] ───────────────────────

  Widget _buildSegmentSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = 0);
              },
              child: AnimatedContainer(
                duration: DesignTokens.animFast,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? AppColors.surfaceElevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _selectedTab == 0 ? Border.all(color: AppColors.outline) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Payment QR',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _selectedTab == 0 ? AppColors.onSurface : AppColors.onSurfaceMuted,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = 1);
              },
              child: AnimatedContainer(
                duration: DesignTokens.animFast,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? AppColors.surfaceElevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _selectedTab == 1 ? Border.all(color: AppColors.outline) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Transaction Link',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _selectedTab == 1 ? AppColors.onSurface : AppColors.onSurfaceMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── High Risk Hero Card ───────────────────────────────────────────────────

  Widget _buildHighRiskCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: AppColors.safetyPink.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.safetyPink.withValues(alpha: 0.12),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.safetyPink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: AppColors.safetyPink,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'High Risk',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.safetyPink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Risk Score',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                Text(
                  '91 / 100',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Possible Reasons Section ──────────────────────────────────────────────

  Widget _buildPossibleReasonsSection() {
    final reasons = [
      'Unknown payment destination',
      'Suspicious payment request',
      'Matches known scam patterns',
      'Unusual transaction context',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Possible Reasons',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...reasons.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.cancel_rounded, color: AppColors.safetyPink, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      r,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ── Guidance Warning Pill ─────────────────────────────────────────────────

  Widget _buildWarningGuidancePill() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.scamAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: AppColors.scamAmber.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.scamAmber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Stop and verify the recipient before making the payment.',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Action Buttons ─────────────────────────────────────────────────

  Widget _buildBottomActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.screenPadding),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showDetailsModal(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurface,
                side: const BorderSide(color: AppColors.outlineVariant),
                minimumSize: const Size(0, DesignTokens.buttonHeightLg),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
              ),
              child: const Text('View Details'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🚨 Fraudulent account reported to National Cyber Crime Portal.'),
                    backgroundColor: AppColors.safetyPink,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.report_rounded, color: Colors.white, size: 18),
              label: const Text('Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.safetyPink,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, DesignTokens.buttonHeightLg),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Technical Fraud Analysis', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
            const SizedBox(height: 12),
            Text('• VPA: unknown.fake@ybl\n• Domain Created: 2 days ago\n• Threat Signature: High Confidence UPI Reverse-Pay Scam\n• Recommendation: Do not approve UPI auto-debit.', style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: AppColors.onSurfaceMuted)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldGreen, foregroundColor: Colors.black),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got It'),
            ),
          ],
        ),
      ),
    );
  }
}
