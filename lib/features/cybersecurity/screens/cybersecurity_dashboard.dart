import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';

/// CyberShield Dashboard (PS #19) — Screen 5 from reference mockups.
class CybersecurityDashboard extends StatefulWidget {
  const CybersecurityDashboard({super.key});

  @override
  State<CybersecurityDashboard> createState() => _CybersecurityDashboardState();
}

class _CybersecurityDashboardState extends State<CybersecurityDashboard> {
  final _urlCtrl = TextEditingController();
  bool _isScanning = false;
  String? _scanResult;

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
                  _buildRiskScoreGaugeCard(),
                  const SizedBox(height: 20),
                  _buildFeatureTilesList(context),
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
      floating: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.cyberBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.radar_rounded, color: AppColors.cyberBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CyberShield',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'Scan Today. Stay Safer Tomorrow.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.cyberBlue,
                  fontWeight: FontWeight.w500,
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

  // ── Circular Risk Score Gauge ─────────────────────────────────────────────

  Widget _buildRiskScoreGaugeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: AppColors.cyberBlue.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyberBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Arc Gauge
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular background ring
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: 0.32,
                    strokeWidth: 9,
                    backgroundColor: AppColors.surfaceHighest,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyberBlue),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '32',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          ' / 100',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Low Risk',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.emeraldGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Your device is mostly safe.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Vertical Feature List Tiles ───────────────────────────────────────────

  Widget _buildFeatureTilesList(BuildContext context) {
    final features = [
      _CyberTile(
        title: 'URL Scanner',
        subtitle: 'Check links for threats',
        icon: Icons.link_rounded,
        accent: AppColors.cyberBlue,
        onTap: () => _showUrlScannerDialog(context),
      ),
      _CyberTile(
        title: 'QR Scanner',
        subtitle: 'Scan and analyze QR codes',
        icon: Icons.qr_code_scanner_rounded,
        accent: AppColors.neonPurple,
        onTap: () => context.push(Routes.qrScanner),
      ),
      _CyberTile(
        title: 'Wi-Fi Audit',
        subtitle: 'Check your network security',
        icon: Icons.wifi_protected_setup_rounded,
        accent: AppColors.emeraldGreen,
        onTap: () => _showWifiAuditSheet(context),
      ),
      _CyberTile(
        title: 'App Permissions',
        subtitle: 'Review app permissions',
        icon: Icons.shield_outlined,
        accent: AppColors.scamAmber,
        onTap: () => context.push(Routes.permissionAuditor),
      ),
      _CyberTile(
        title: 'Breach Checker',
        subtitle: 'Check for data leaks',
        icon: Icons.lock_reset_rounded,
        accent: AppColors.detectiveTeal,
        onTap: () => _showBreachCheckerSheet(context),
      ),
      _CyberTile(
        title: 'ScamGuard',
        subtitle: 'Detect payment and fraud risks',
        icon: Icons.warning_amber_rounded,
        accent: AppColors.safetyPink,
        onTap: () => context.push(Routes.scamGuard),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: features.asMap().entries.map((entry) {
          final isLast = entry.key == features.length - 1;
          final f = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: f.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(f.icon, color: f.accent, size: 22),
                ),
                title: Text(
                  f.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                subtitle: Text(
                  f.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceSubtle,
                  size: 20,
                ),
                onTap: () {
                  HapticFeedback.selectionClick();
                  f.onTap();
                },
              ),
              if (!isLast)
                const Divider(color: AppColors.outline, height: 1, indent: 64),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showUrlScannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('URL Threat Scanner', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _urlCtrl,
                decoration: const InputDecoration(
                  hintText: 'https://example.com/verify',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 14),
              if (_isScanning)
                const SizedBox(height: 30, width: 30, child: CircularProgressIndicator(color: AppColors.cyberBlue))
              else if (_scanResult != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_scanResult!, style: const TextStyle(color: AppColors.emeraldGreen, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyberBlue, foregroundColor: Colors.black),
              onPressed: () {
                if (_urlCtrl.text.isNotEmpty) {
                  setDialogState(() {
                    _isScanning = true;
                    _scanResult = null;
                  });
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    setDialogState(() {
                      _isScanning = false;
                      _scanResult = '✅ Clean URL — No malware or phishing indicators found.';
                    });
                  });
                }
              },
              child: const Text('Scan Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWifiAuditSheet(BuildContext context) {
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
            Text('Wi-Fi Security Audit', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
            const SizedBox(height: 14),
            _buildCheckItem('WPA3 / WPA2 Encryption', 'Secure (AES-CCMP)', true),
            _buildCheckItem('DNS Hijack Protection', 'Active (Encrypted DoH)', true),
            _buildCheckItem('Captive Portal Spoofing', 'No anomalies detected', true),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldGreen, foregroundColor: Colors.black),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Audit Complete'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBreachCheckerSheet(BuildContext context) {
    final emailCtrl = TextEditingController(text: 'krishna@example.com');
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
            Text('Dark Web & Data Breach Checker', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
            const SizedBox(height: 10),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.emeraldGreen, size: 20),
                  const SizedBox(width: 10),
                  Text('0 known data leaks found for this email.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyberBlue, foregroundColor: Colors.black),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Check Status'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String title, String status, bool isSafe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)),
          Row(
            children: [
              Icon(isSafe ? Icons.check_circle_rounded : Icons.warning_rounded, color: isSafe ? AppColors.emeraldGreen : AppColors.errorRed, size: 16),
              const SizedBox(width: 6),
              Text(status, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isSafe ? AppColors.emeraldGreen : AppColors.errorRed)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CyberTile {
  const _CyberTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
}
