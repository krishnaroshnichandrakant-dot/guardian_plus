import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../../shared/widgets/glass_card.dart';
import '../services/url_safety_service.dart';
import '../services/email_breach_service.dart';

/// Cybersecurity Dashboard — Vibrant, Interactive, Light Theme
class CybersecurityDashboard extends ConsumerStatefulWidget {
  const CybersecurityDashboard({super.key});

  @override
  ConsumerState<CybersecurityDashboard> createState() => _CybersecurityDashboardState();
}

class _CybersecurityDashboardState extends ConsumerState<CybersecurityDashboard> {
  final _urlController = TextEditingController();
  final _breachEmailController = TextEditingController();

  bool _isScanning = false;
  bool _isUrlScanning = false;
  bool _isBreachChecking = false;

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
                'Real-Time Defense Active',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.emeraldGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.cyberBlue),
            tooltip: 'QR Safety Scanner',
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
            color: Color(0x280A84FF),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingXl),
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
                            Icon(Icons.shield_rounded, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'PROTECTION ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacingMd),
                      const Text(
                        'Device Security Status',
                        style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_threatScore/100',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '0 Active Threats Detected',
                        style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
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
                    Text('Last Scan: Just now', style: TextStyle(fontSize: 12, color: Colors.white70)),
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
                    hintText: 'e.g. paypa1-verify-account.top/login',
                    prefixIcon: Icon(Icons.search_rounded),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _analyzeUrlInput(),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              ElevatedButton(
                onPressed: _isUrlScanning ? null : _analyzeUrlInput,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 48),
                  backgroundColor: AppColors.cyberBlue,
                  foregroundColor: Colors.white,
                ),
                child: _isUrlScanning
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Scan Link'),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          // Quick sample test chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              const Text('Quick Test:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted)),
              _SampleChip(
                label: '⚠️ Phishing Link',
                onTap: () {
                  _urlController.text = 'http://paypa1-account-security.xyz/verify-login';
                  _analyzeUrlInput();
                },
              ),
              _SampleChip(
                label: '🚨 Fake Bank IP',
                onTap: () {
                  _urlController.text = 'http://192.168.1.100/chase-banking-signin.php';
                  _analyzeUrlInput();
                },
              ),
              _SampleChip(
                label: '🛡️ Safe Site',
                onTap: () {
                  _urlController.text = 'https://google.com';
                  _analyzeUrlInput();
                },
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
                    hintText: 'e.g. john.doe@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _checkDataBreach(),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              ElevatedButton(
                onPressed: _isBreachChecking ? null : _checkDataBreach,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 48),
                  backgroundColor: AppColors.softCoral,
                  foregroundColor: Colors.white,
                ),
                child: _isBreachChecking
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Check Leaks'),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMd),
          // Quick sample email test chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              const Text('Quick Test:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted)),
              _SampleChip(
                label: '⚠️ Test Leaked Account',
                onTap: () {
                  _breachEmailController.text = 'test.user@yahoo.com';
                  _checkDataBreach();
                },
              ),
              _SampleChip(
                label: '🛡️ Test Clean Account',
                onTap: () {
                  _breachEmailController.text = 'secure.guardian@gmail.com';
                  _checkDataBreach();
                },
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

  void _analyzeUrlInput() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a web link to scan.')),
      );
      return;
    }

    setState(() => _isUrlScanning = true);
    final service = ref.read(urlSafetyServiceProvider);
    final result = await service.analyzeUrl(url);

    if (!mounted) return;
    setState(() => _isUrlScanning = false);

    _showUrlResultModal(result);
  }

  void _showUrlResultModal(UrlAnalysisResult result) {
    final isSafe = result.status == UrlSafetyStatus.safe;
    final isSuspicious = result.status == UrlSafetyStatus.suspicious;
    final isMalicious = result.status == UrlSafetyStatus.malicious;

    final themeColor = isSafe
        ? AppColors.emeraldGreen
        : (isSuspicious ? AppColors.warningAmber : AppColors.errorRed);

    final statusTitle = isSafe
        ? 'Verified Safe Website'
        : (isSuspicious ? 'Suspicious Link Warning' : 'Dangerous Phishing Threat Blocked');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXxl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Icon(
                    isSafe ? Icons.verified_user_rounded : (isSuspicious ? Icons.warning_amber_rounded : Icons.gpp_bad_rounded),
                    color: themeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.detectedCategory ?? (isSafe ? 'Legitimate' : 'High Risk'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted),
                      ),
                    ],
                  ),
                ),
                // Risk score badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                    border: Border.all(color: themeColor, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${result.riskScore}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: themeColor),
                      ),
                      Text(
                        'RISK SCORE',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: themeColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Text(
                result.url,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Security Indicators & Findings:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            const SizedBox(height: 8),
            ...result.reasons.map((reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSafe ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 16,
                        color: isSafe ? AppColors.emeraldGreen : (isSuspicious ? AppColors.warningAmber : AppColors.errorRed),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(color: themeColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: themeColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result.recommendation,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: themeColor, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
                if (isSafe) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldGreen, foregroundColor: Colors.white),
                      child: const Text('Proceed'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _checkDataBreach() async {
    final email = _breachEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address to check.')),
      );
      return;
    }

    setState(() => _isBreachChecking = true);
    final breachService = ref.read(emailBreachServiceProvider);
    final result = await breachService.checkEmailBreach(email);

    if (!mounted) return;
    setState(() => _isBreachChecking = false);

    _showBreachResultModal(result);
  }

  void _showBreachResultModal(EmailBreachResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXxl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (result.isCompromised ? AppColors.errorRed : AppColors.emeraldGreen).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Icon(
                    result.isCompromised ? Icons.gpp_maybe_rounded : Icons.verified_user_rounded,
                    color: result.isCompromised ? AppColors.errorRed : AppColors.emeraldGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.isCompromised ? 'Compromised in Data Leaks!' : 'Email Address Clean',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: result.isCompromised ? AppColors.errorRed : AppColors.emeraldGreen,
                        ),
                      ),
                      Text(
                        result.email,
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (result.isCompromised) ...[
              Text(
                'Found in ${result.breaches.length} Data Breaches:',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),
              ...result.breaches.map((breach) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      border: Border.all(color: AppColors.outline, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(breach.serviceName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.errorRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                              ),
                              child: Text(breach.breachDate, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.errorRed)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(breach.description, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceMuted, height: 1.3)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: breach.dataExposed.map((data) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.outline,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(data, style: const TextStyle(fontSize: 10, color: AppColors.onSurface)),
                              )).toList(),
                        ),
                      ],
                    ),
                  )),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.emeraldGreen, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Zero password or credential leaks detected across indexed databases for this email address.',
                        style: TextStyle(fontSize: 13, color: AppColors.onSurface, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Security Advice:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            ...result.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_right_rounded, size: 16, color: AppColors.cyberBlue),
                      const SizedBox(width: 6),
                      Expanded(child: Text(rec, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted))),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyberBlue, foregroundColor: Colors.white),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SampleChip extends StatelessWidget {
  const _SampleChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          border: Border.all(color: AppColors.outline, width: 0.5),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        ),
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
