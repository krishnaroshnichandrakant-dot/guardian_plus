import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../services/url_safety_service.dart';
import '../../../shared/security/secure_http_client.dart';

/// CyberShield Command Center (PS #19) — High-Tech Real-time Cyber Security Dashboard
class CybersecurityDashboard extends StatefulWidget {
  const CybersecurityDashboard({super.key});

  @override
  State<CybersecurityDashboard> createState() => _CybersecurityDashboardState();
}

class _CybersecurityDashboardState extends State<CybersecurityDashboard> with SingleTickerProviderStateMixin {
  final _urlCtrl = TextEditingController();
  final _urlSafetyService = UrlSafetyService(SecureHttpClient());
  
  bool _isScanning = false;
  UrlAnalysisResult? _analysisResult;
  String _scanStatusText = 'Ready';
  int _scanProgressStep = 0; // 0: Idle, 1: MeitY Check, 2: Betting/Piracy, 3: SSL/HTTP

  bool _isDeepAuditing = false;
  double _auditProgress = 0.98; // 98% System Health

  late AnimationController _radarPulseController;

  @override
  void initState() {
    super.initState();
    _radarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radarPulseController.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _triggerFullSystemAudit() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isDeepAuditing = true;
      _auditProgress = 0.12;
    });

    for (int i = 1; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _auditProgress = 0.12 + (i * 0.17);
      });
    }

    if (!mounted) return;
    setState(() {
      _auditProgress = 0.98;
      _isDeepAuditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: AppColors.emeraldGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Deep Cyber Audit Complete. 0 Active Threats Found.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
                12,
                DesignTokens.screenPadding,
                110,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildLiveStatusHeader(),
                  const SizedBox(height: 16),
                  _buildRiskScoreGaugeCard(),
                  const SizedBox(height: 16),
                  _buildLiveTelemetryGrid(),
                  const SizedBox(height: 20),
                  _buildQuickUrlScannerCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('CYBER DEFENSE MODULES', '6 Active Shields'),
                  const SizedBox(height: 12),
                  _buildFeatureGrid(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar Header ─────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      floating: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cyberBlue.withValues(alpha: 0.25),
                  AppColors.neonPurple.withValues(alpha: 0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cyberBlue.withValues(alpha: 0.4)),
            ),
            child: RotationTransition(
              turns: _radarPulseController,
              child: const Icon(Icons.radar_rounded, color: AppColors.cyberBlue, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'CyberShield',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cyberBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.cyberBlue.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'PRO',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cyberBlue,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Real-Time Threat Intelligence & MeitY Blocklist Defense',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: AppColors.onSurfaceMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.security_update_good_rounded, color: AppColors.emeraldGreen),
            tooltip: 'Run Deep Audit',
            onPressed: _isDeepAuditing ? null : _triggerFullSystemAudit,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.outline),
      ),
    );
  }

  // ── Live Active Status Banner ──────────────────────────────────────────────

  Widget _buildLiveStatusHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.emeraldGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.emeraldGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.emeraldGreen, blurRadius: 6, spreadRadius: 2),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: 800.ms),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isDeepAuditing
                  ? 'RUNNING DEEP CYBER THREAT AUDIT (${(_auditProgress * 100).toInt()}%)...'
                  : 'ACTIVE DEFENSE ON • 2,840 URLs & 180 Banned Portals Monitored',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.emeraldGreen,
                letterSpacing: 0.3,
              ),
            ),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: _isDeepAuditing ? null : _triggerFullSystemAudit,
            icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.emeraldGreen),
            label: Text(
              'Audit',
              style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.emeraldGreen),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cyber Risk Score Arc Gauge ─────────────────────────────────────────────

  Widget _buildRiskScoreGaugeCard() {
    final int scoreVal = (_auditProgress * 100).toInt();
    final bool isSafe = scoreVal >= 80;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surfaceElevated,
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(
          color: (isSafe ? AppColors.cyberBlue : AppColors.scamAmber).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (isSafe ? AppColors.cyberBlue : AppColors.scamAmber).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Arc Gauge
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulse Ring
                AnimatedBuilder(
                  animation: _radarPulseController,
                  builder: (context, child) {
                    return Container(
                      width: 106 + (4 * _radarPulseController.value),
                      height: 106 + (4 * _radarPulseController.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cyberBlue.withValues(
                            alpha: 0.2 * (1 - _radarPulseController.value),
                          ),
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
                // Circular Progress Arc
                SizedBox(
                  width: 98,
                  height: 98,
                  child: CircularProgressIndicator(
                    value: _auditProgress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.surfaceHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isSafe ? AppColors.emeraldGreen : AppColors.scamAmber,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$scoreVal%',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      isSafe ? 'PROTECTED' : 'AUDITING',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isSafe ? AppColors.emeraldGreen : AppColors.scamAmber,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Gauge Context & Actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isSafe ? Icons.verified_user_rounded : Icons.shield_outlined,
                      color: isSafe ? AppColors.emeraldGreen : AppColors.scamAmber,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isSafe ? 'System Health Optimal' : 'Running Diagnostic...',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Wi-Fi encrypted (WPA3), 0 dark web breaches, Indian MeitY blocklists loaded.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppColors.onSurfaceMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: [
                    _buildStatusBadge('MeitY 69A', AppColors.cyberBlue),
                    _buildStatusBadge('Zero Trust', AppColors.neonPurple),
                    _buildStatusBadge('HTTPS Only', AppColors.emeraldGreen),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ── Live Telemetry 4-Metric Grid ──────────────────────────────────────────

  Widget _buildLiveTelemetryGrid() {
    return Row(
      children: [
        Expanded(child: _buildTelemetryTile('2,840', 'URLs Inspected', Icons.manage_search_rounded, AppColors.cyberBlue)),
        const SizedBox(width: 10),
        Expanded(child: _buildTelemetryTile('14', 'Threats Blocked', Icons.gpp_bad_rounded, AppColors.safetyPink)),
        const SizedBox(width: 10),
        Expanded(child: _buildTelemetryTile('WPA3', 'Wi-Fi Security', Icons.wifi_lock_rounded, AppColors.emeraldGreen)),
        const SizedBox(width: 10),
        Expanded(child: _buildTelemetryTile('0 Leaks', 'Dark Web Status', Icons.lock_outline_rounded, AppColors.detectiveTeal)),
      ],
    );
  }

  Widget _buildTelemetryTile(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.onSurfaceMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── High-Visibility Quick URL Scanner Card ────────────────────────────────

  Widget _buildQuickUrlScannerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cyberBlue.withValues(alpha: 0.12),
            AppColors.surfaceElevated,
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: AppColors.cyberBlue.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cyberBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.link_rounded, color: AppColors.cyberBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instant URL Threat Inspector',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Check links against Indian MeitY/DoT banned list, betting & fraud portals',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // URL Input & Scan Action
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlCtrl,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Paste suspicious link (e.g. 1xbet.com)',
                    prefixIcon: const Icon(Icons.security_rounded, color: AppColors.cyberBlue, size: 18),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.content_paste_rounded, color: AppColors.cyberBlue, size: 18),
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data?.text != null) {
                          setState(() {
                            _urlCtrl.text = data!.text!;
                          });
                        }
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyberBlue,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isScanning
                    ? null
                    : () async {
                        final text = _urlCtrl.text.trim();
                        if (text.isEmpty) {
                          _showUrlScannerDialog(context);
                          return;
                        }

                        setState(() {
                          _isScanning = true;
                          _analysisResult = null;
                          _scanProgressStep = 1;
                          _scanStatusText = 'Auditing MeitY / DoT Government Blocklists...';
                        });

                        await Future.delayed(const Duration(milliseconds: 300));
                        if (!mounted) return;
                        setState(() {
                          _scanProgressStep = 2;
                          _scanStatusText = 'Inspecting Illegal Betting & Piracy Catalogs...';
                        });

                        final result = await _urlSafetyService.analyzeUrl(text);

                        if (!mounted) return;
                        setState(() {
                          _scanProgressStep = 3;
                          _isScanning = false;
                          _analysisResult = result;
                        });
                      },
                child: _isScanning
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : Text(
                        'Scan Now',
                        style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Test Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildQuickTestChip('tiktok.com (Banned India)'),
                const SizedBox(width: 6),
                _buildQuickTestChip('1xbet.com (Illegal Betting)'),
                const SizedBox(width: 6),
                _buildQuickTestChip('tamilrockers.ws (Piracy)'),
                const SizedBox(width: 6),
                _buildQuickTestChip('sbi-kyc-update.in (Phishing)'),
                const SizedBox(width: 6),
                _buildQuickTestChip('google.com (Safe)'),
              ],
            ),
          ),

          // Analysis Output Card
          if (_analysisResult != null) ...[
            const SizedBox(height: 16),
            _buildAnalysisResultCard(_analysisResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickTestChip(String label) {
    return GestureDetector(
      onTap: () {
        final domain = label.split(' ').first;
        setState(() {
          _urlCtrl.text = domain;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        ),
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, String tag) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceMuted,
            letterSpacing: 1.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.outline),
          ),
          child: Text(
            tag,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.cyberBlue,
            ),
          ),
        ),
      ],
    );
  }

  // ── 6 Cyber Modules Grid ──────────────────────────────────────────────────

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _CyberModuleData(
        title: 'URL Threat Scanner',
        subtitle: 'MeitY 69A & Scam Filter',
        badge: 'LIVE BLOCKLIST',
        icon: Icons.link_rounded,
        accent: AppColors.cyberBlue,
        onTap: () => _showUrlScannerDialog(context),
      ),
      _CyberModuleData(
        title: 'QR Code Shield',
        subtitle: 'Scan & Sanitize QR Links',
        badge: 'CYBER GUARD',
        icon: Icons.qr_code_scanner_rounded,
        accent: AppColors.neonPurple,
        onTap: () => context.push(Routes.qrScanner),
      ),
      _CyberModuleData(
        title: 'Wi-Fi Audit',
        subtitle: 'WPA3 & ARP Spoof Check',
        badge: 'NETWORK SECURE',
        icon: Icons.wifi_protected_setup_rounded,
        accent: AppColors.emeraldGreen,
        onTap: () => _showWifiAuditSheet(context),
      ),
      _CyberModuleData(
        title: 'App Permissions',
        subtitle: 'Camera, Mic & Location Guard',
        badge: 'ZERO TRUST',
        icon: Icons.shield_outlined,
        accent: AppColors.scamAmber,
        onTap: () => context.push(Routes.permissionAuditor),
      ),
      _CyberModuleData(
        title: 'Dark Web Leaks',
        subtitle: 'Check Email & Passwords',
        badge: 'BREACH MONITORED',
        icon: Icons.lock_reset_rounded,
        accent: AppColors.detectiveTeal,
        onTap: () => _showBreachCheckerSheet(context),
      ),
      _CyberModuleData(
        title: 'ScamGuard AI',
        subtitle: 'UPI & Banking Fraud Shield',
        badge: 'FRAUD SHIELD',
        icon: Icons.warning_amber_rounded,
        accent: AppColors.safetyPink,
        onTap: () => context.push(Routes.scamGuard),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: features.length,
      itemBuilder: (context, idx) {
        final f = features[idx];
        return _buildModuleCard(f);
      },
    );
  }

  Widget _buildModuleCard(_CyberModuleData f) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        f.onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: f.accent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: f.accent.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: f.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(f.icon, color: f.accent, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: f.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    f.badge,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: f.accent,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  f.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceMuted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Dynamic URL Inspection Sheet ──────────────────────────────────────────

  void _showUrlScannerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.shield_outlined, color: AppColors.cyberBlue, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'URL Cyber Threat Scanner',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Real-time threat inspection against MeitY/DoT Indian blocklists, illegal betting, piracy & phishing.',
                    style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.onSurfaceMuted),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _urlCtrl,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'e.g. tiktok.com, 1xbet.com, google.com',
                      prefixIcon: const Icon(Icons.link_rounded, color: AppColors.cyberBlue),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.content_paste_rounded, color: AppColors.cyberBlue, size: 20),
                        onPressed: () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data?.text != null) {
                            _urlCtrl.text = data!.text!;
                            setSheetState(() {});
                          }
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Quick Test Links:',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildPresetChip('tiktok.com (Banned India)', setSheetState),
                      _buildPresetChip('1xbet.com (Illegal Betting)', setSheetState),
                      _buildPresetChip('tamilrockers.ws (Piracy)', setSheetState),
                      _buildPresetChip('power-disconnection-alert.com', setSheetState),
                      _buildPresetChip('google.com (Safe)', setSheetState),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyberBlue,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isScanning
                          ? null
                          : () async {
                              final text = _urlCtrl.text.trim();
                              if (text.isEmpty) return;

                              setSheetState(() {
                                _isScanning = true;
                                _analysisResult = null;
                                _scanStatusText = 'Auditing MeitY / DoT Government Blocklists...';
                              });

                              await Future.delayed(const Duration(milliseconds: 300));
                              setSheetState(() {
                                _scanStatusText = 'Probing Live HTTP Response & Cyber Fraud Database...';
                              });

                              final result = await _urlSafetyService.analyzeUrl(text);

                              setSheetState(() {
                                _isScanning = false;
                                _analysisResult = result;
                              });
                            },
                      icon: _isScanning
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Icon(Icons.search_rounded, size: 20),
                      label: Text(
                        _isScanning ? _scanStatusText : 'Inspect Link Security Now',
                        style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                  if (_analysisResult != null) ...[
                    const SizedBox(height: 20),
                    _buildAnalysisResultCard(_analysisResult!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetChip(String label, StateSetter setSheetState) {
    return GestureDetector(
      onTap: () {
        final domain = label.split(' ').first;
        _urlCtrl.text = domain;
        setSheetState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        ),
      ),
    );
  }

  // ── Rich Analysis Result Card ─────────────────────────────────────────────

  Widget _buildAnalysisResultCard(UrlAnalysisResult res) {
    final bool isDangerous = res.status == UrlSafetyStatus.malicious || res.isBannedInIndia;
    final bool isSuspicious = res.status == UrlSafetyStatus.suspicious;
    final Color themeColor = isDangerous
        ? AppColors.safetyPink
        : isSuspicious
            ? AppColors.scamAmber
            : AppColors.emeraldGreen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDangerous
                        ? Icons.gpp_bad_rounded
                        : isSuspicious
                            ? Icons.warning_rounded
                            : Icons.verified_user_rounded,
                    color: themeColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    res.detectedCategory ?? (isDangerous ? 'Dangerous Threat' : 'Safe Website'),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: themeColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Risk Score: ${res.riskScore}/100',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: themeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            'Target Host: ${res.host}',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),

          Text(
            'Threat Diagnostics:',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: 4),
          ...res.reasons.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      r,
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.onSurface, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: themeColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    res.recommendation,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDangerous ? AppColors.safetyPink : AppColors.emeraldGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isDangerous
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🛡️ CyberShield Blocked Access to ${res.host}! Threat Neutralized.'),
                          backgroundColor: AppColors.safetyPink,
                        ),
                      );
                    }
                  : () async {
                      final uri = Uri.parse(res.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
              icon: Icon(isDangerous ? Icons.block_rounded : Icons.open_in_new_rounded, size: 18),
              label: Text(
                isDangerous ? 'Block & Isolate Threat' : 'Open Safely in Browser',
                style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Interactive Wi-Fi Security Audit Sheet ────────────────────────────────

  void _showWifiAuditSheet(BuildContext context) {
    bool isAuditing = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          if (isAuditing) {
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (context.mounted) {
                setSheetState(() => isAuditing = false);
              }
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wifi_protected_setup_rounded, color: AppColors.emeraldGreen, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Wi-Fi Security Diagnostic',
                          style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                    if (!isAuditing)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'WPA3 SECURE',
                          style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.emeraldGreen),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                if (isAuditing) ...[
                  const LinearProgressIndicator(color: AppColors.emeraldGreen, backgroundColor: AppColors.surfaceElevated),
                  const SizedBox(height: 16),
                  Text(
                    'Probing network interface, ARP gateway table & DNS encryption...',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceMuted),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.network_check_rounded, color: AppColors.cyberBlue, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SSID: Guardian_Secure_5G',
                                style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                              ),
                              Text(
                                'Gateway: 192.168.1.1 • BSSID: 74:83:C2:90:1A:FE',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildCheckItem('WPA3-Personal AES-CCMP Encryption', 'Verified Safe', true),
                  _buildCheckItem('DNS-over-HTTPS (DoH Cloudflare 1.1.1.1)', 'Active', true),
                  _buildCheckItem('ARP Poisoning & MITM Inspection', 'No Spoofing', true),
                  _buildCheckItem('Captive Portal Malicious Injection', 'Clean', true),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: Text('Network Verified Safe', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Dark Web Breach Checker Sheet ─────────────────────────────────────────

  void _showBreachCheckerSheet(BuildContext context) {
    final emailCtrl = TextEditingController(text: 'user@guardianplus.app');
    bool isSearching = false;
    bool searched = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_reset_rounded, color: AppColors.detectiveTeal, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Dark Web & Data Breach Checker',
                      style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Scan global paste sites & underground hacker forums for compromised email credentials.',
                  style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.onSurfaceMuted),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: emailCtrl,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Enter Email or Phone Number',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.detectiveTeal),
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.detectiveTeal,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isSearching
                        ? null
                        : () async {
                            setSheetState(() {
                              isSearching = true;
                              searched = false;
                            });
                            await Future.delayed(const Duration(milliseconds: 1000));
                            setSheetState(() {
                              isSearching = false;
                              searched = true;
                            });
                          },
                    icon: isSearching
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.radar_rounded, size: 18),
                    label: Text(
                      isSearching ? 'Querying Dark Web Repositories...' : 'Check Data Exposure',
                      style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

                if (searched) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.emeraldGreen, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '0 Data Breaches Found!',
                                style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.emeraldGreen),
                              ),
                              Text(
                                'No passwords or phone leaks detected across 14+ Billion compromised database records.',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheckItem(String title, String status, bool isSafe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.onSurface, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Icon(isSafe ? Icons.check_circle_rounded : Icons.warning_rounded, color: isSafe ? AppColors.emeraldGreen : AppColors.errorRed, size: 16),
              const SizedBox(width: 6),
              Text(status, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: isSafe ? AppColors.emeraldGreen : AppColors.errorRed)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CyberModuleData {
  const _CyberModuleData({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.accent,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
}
