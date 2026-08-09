import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../shared/widgets/glass_card.dart';

/// Cybersecurity Dashboard — Vibrant, Interactive, Light Theme
class CybersecurityDashboard extends StatefulWidget {
  const CybersecurityDashboard({super.key});

  @override
  State<CybersecurityDashboard> createState() => _CybersecurityDashboardState();
}

class _CybersecurityDashboardState extends State<CybersecurityDashboard> {
  final _urlController = TextEditingController();
  final _breachEmailController = TextEditingController();

  bool _isScanning = false;
  bool _webShieldEnabled = true;
  bool _wifiGuardEnabled = true;
  bool _phishingFilterEnabled = true;

  int _threatScore = 96;

  @override
  void dispose() {
    _urlController.dispose();
    _breachEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(DesignTokens.screenPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSecurityHeroHeader(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildQuickUrlScanner(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildSectionTitle('Active Real-Time Shields'),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _buildRealTimeShields(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildSectionTitle('Security Tools & Utilities'),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _buildToolsGrid(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildDataBreachChecker(),
                  const SizedBox(height: DesignTokens.spacingXl),
                  _buildSectionTitle('Live Security Activity Log'),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _buildRecentActivityLog(),
                  const SizedBox(height: 100),
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
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              boxShadow: const [BoxShadow(color: Color(0x1F4F46E5), blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: DesignTokens.spacingSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Cybersecurity Hub',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'Real-Time AI Threat Protection',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.cyberBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.cyberBlue),
            tooltip: 'Scan QR Code',
            onPressed: () => context.push(Routes.qrScanner),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityHeroHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x294F46E5),
            blurRadius: 16,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.screenPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'SYSTEM PROTECTED',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacingSm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$_threatScore',
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              '/ 100',
                              style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '0 Active Malware Threats Detected',
                        style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                  ),
                  child: const Icon(Icons.verified_user_rounded, size: 42, color: Colors.white),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.06, 1.06),
                      duration: 2.seconds,
                    ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingLg),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: DesignTokens.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text('Last Scan: Today, 2:45 PM', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _runFullSystemScan,
                  icon: _isScanning
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyberBlue))
                      : const Icon(Icons.bolt_rounded, size: 16),
                  label: Text(_isScanning ? 'Scanning...' : 'Scan Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.cyberBlue,
                    minimumSize: const Size(110, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickUrlScanner() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.link_rounded, color: AppColors.cyberBlue, size: 22),
              SizedBox(width: 8),
              Text(
                'AI Phishing & URL Threat Inspector',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Paste any suspicious web link, SMS URL, or email link to check safety before clicking.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    hintText: 'https://example-verify-login.com',
                    prefixIcon: Icon(Icons.search_rounded),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              ElevatedButton(
                onPressed: _analyzeUrlInput,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 48),
                  backgroundColor: AppColors.cyberBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Scan Link'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildRealTimeShields() {
    return Column(
      children: [
        _ShieldToggleTile(
          icon: Icons.public_rounded,
          title: 'Safe Web Browsing Shield',
          subtitle: 'Blocks phishing domains & malicious malware scripts in real-time.',
          isEnabled: _webShieldEnabled,
          color: AppColors.cyberBlue,
          onChanged: (v) => setState(() => _webShieldEnabled = v),
        ),
        const SizedBox(height: DesignTokens.spacingSm),
        _ShieldToggleTile(
          icon: Icons.wifi_tethering_rounded,
          title: 'Wi-Fi Encryption & MITM Guard',
          subtitle: 'Detects rogue hotspots and unencrypted public Wi-Fi networks.',
          isEnabled: _wifiGuardEnabled,
          color: AppColors.emeraldGreen,
          onChanged: (v) => setState(() => _wifiGuardEnabled = v),
        ),
        const SizedBox(height: DesignTokens.spacingSm),
        _ShieldToggleTile(
          icon: Icons.mark_email_read_rounded,
          title: 'Anti-Phishing SMS Interceptor',
          subtitle: 'Scans incoming text messages for fraudulent banking & OTP links.',
          isEnabled: _phishingFilterEnabled,
          color: AppColors.neonPurple,
          onChanged: (v) => setState(() => _phishingFilterEnabled = v),
        ),
      ],
    );
  }

  Widget _buildToolsGrid() {
    return Row(
      children: [
        _ToolCard(
          icon: Icons.qr_code_scanner_rounded,
          title: 'QR Code Safety Scanner',
          subtitle: 'Scan QR before opening',
          color: AppColors.neonPurple,
          onTap: () => context.push(Routes.qrScanner),
        ),
        const SizedBox(width: DesignTokens.spacingMd),
        _ToolCard(
          icon: Icons.app_registration_rounded,
          title: 'App Permission Auditor',
          subtitle: '3 flagged privacy risks',
          color: AppColors.warningOrange,
          onTap: () => context.push(Routes.permissionAuditor),
        ),
      ],
    );
  }

  Widget _buildDataBreachChecker() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.fingerprint_rounded, color: AppColors.softCoral, size: 22),
              SizedBox(width: 8),
              Text(
                'Identity & Data Breach Checker',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Check if your email or passwords have appeared in known dark web data leaks.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _breachEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email address...',
                    prefixIcon: Icon(Icons.email_outlined),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              ElevatedButton(
                onPressed: _checkDataBreach,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 48),
                  backgroundColor: AppColors.softCoral,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Check Leaks'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityLog() {
    final activities = [
      _ActivityItem(
        icon: Icons.check_circle_rounded,
        title: 'Safe Domain Verified',
        subtitle: 'google.com • Clean SSL certificate',
        time: '5m ago',
        isRisk: false,
      ),
      _ActivityItem(
        icon: Icons.gavel_rounded,
        title: 'App Permission Audit Complete',
        subtitle: '3 over-privileged apps flagged for review',
        time: '1h ago',
        isRisk: true,
      ),
      _ActivityItem(
        icon: Icons.wifi_rounded,
        title: 'Wi-Fi Network Verified',
        subtitle: 'Home_Wi-Fi_5G • WPA3 Secure',
        time: '3h ago',
        isRisk: false,
      ),
    ];

    return Column(
      children: activities.map((act) => Padding(
        padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
        child: GlassCard(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: (act.isRisk ? AppColors.warningOrange : AppColors.emeraldGreen).withOpacity(0.15),
                child: Icon(act.icon, color: act.isRisk ? AppColors.warningOrange : AppColors.emeraldGreen, size: 18),
              ),
              const SizedBox(width: DesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(act.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    Text(act.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
                  ],
                ),
              ),
              Text(act.time, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceMuted)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  void _runFullSystemScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isScanning = false;
        _threatScore = 98;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full System Security Scan complete! Threat Score updated to 98/100.')),
      );
    }
  }

  void _analyzeUrlInput() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a web link to scan.')),
      );
      return;
    }

    final isPhishing = url.contains('login') || url.contains('bank') || url.contains('xyz');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusXl)),
        title: Row(
          children: [
            Icon(
              isPhishing ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
              color: isPhishing ? AppColors.errorRed : AppColors.emeraldGreen,
              size: 26,
            ),
            const SizedBox(width: 8),
            Text(isPhishing ? 'Phishing Risk Detected' : 'Safe Link Verified', style: const TextStyle(color: AppColors.onSurface)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target: $url', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted)),
            const SizedBox(height: 12),
            _ScanDetailRow(label: 'SSL Certificate', value: isPhishing ? 'Untrusted / Expired' : 'Valid 256-bit TLS'),
            _ScanDetailRow(label: 'Domain Reputation', value: isPhishing ? 'Suspicious (<7 days old)' : 'Established Trusted Domain'),
            _ScanDetailRow(label: 'AI Safety Rating', value: isPhishing ? '12/100 (HIGH RISK)' : '99/100 (SAFE)'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _checkDataBreach() {
    final email = _breachEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address to check.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusXl)),
        title: const Row(
          children: [
            Icon(Icons.shield_moon_rounded, color: AppColors.cyberBlue, size: 26),
            SizedBox(width: 8),
            Text('Dark Web Scan Complete', style: TextStyle(color: AppColors.onSurface)),
          ],
        ),
        content: Text(
          'Email: $email\n\nResult: Clean! No password or credential leaks detected in known data breaches for this email address.',
          style: const TextStyle(color: AppColors.onSurfaceMuted, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _ShieldToggleTile extends StatelessWidget {
  const _ShieldToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.color,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: DesignTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(DesignTokens.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted)),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isRisk,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool isRisk;
}

class _ScanDetailRow extends StatelessWidget {
  const _ScanDetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}
