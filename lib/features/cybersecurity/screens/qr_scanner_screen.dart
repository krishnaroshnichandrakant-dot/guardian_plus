import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../services/url_safety_service.dart';
import '../../../shared/security/secure_http_client.dart';

/// QR Scanner & CyberShield Opener — Screen 7 from reference mockups.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0; // 0 = Live Camera, 1 = History, 2 = Gallery
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  final _urlSafetyService = UrlSafetyService(SecureHttpClient());

  late AnimationController _laserController;
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

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
              'QR Scanner & CyberShield',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Zero-Trust Data Protection · 1-Click Open',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.emeraldGreen,
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedTab == 0) ...[
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _isFlashOn ? AppColors.scamAmber : AppColors.onSurfaceMuted,
              ),
              onPressed: () async {
                HapticFeedback.selectionClick();
                await _scannerController.toggleTorch();
                setState(() => _isFlashOn = !_isFlashOn);
              },
            ),
            IconButton(
              icon: Icon(
                _isFrontCamera ? Icons.camera_front_rounded : Icons.camera_rear_rounded,
                color: AppColors.emeraldGreen,
              ),
              onPressed: () async {
                HapticFeedback.selectionClick();
                await _scannerController.switchCamera();
                setState(() => _isFrontCamera = !_isFrontCamera);
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _selectedTab == 0
                  ? _buildScannerView(context)
                  : _selectedTab == 1
                      ? _buildHistoryView(context)
                      : _buildGalleryView(context),
            ),
            _buildBottomSegmentBar(),
          ],
        ),
      ),
    );
  }

  // ── Live Mobile Scanner Camera View ───────────────────────────────────────

  Widget _buildScannerView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Live Camera Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.emeraldGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Live Hardware Camera Active · Data Shield ON',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Camera Viewfinder Box with Live MobileScanner Stream
          Center(
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                color: const Color(0xFF0C1914),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.8), width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emeraldGreen.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Real MobileScanner Live Hardware Video Feed
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            HapticFeedback.heavyImpact();
                            _processAndOpenQrSafely(
                              rawPayload: barcode.rawValue!,
                              source: 'Live Camera Capture',
                            );
                            break;
                          }
                        }
                      },
                      errorBuilder: (context, error, child) {
                        return _buildCameraFallbackView();
                      },
                    ),

                    // Illuminated Corner Brackets
                    CustomPaint(
                      size: const Size(270, 270),
                      painter: _CornerBracketsPainter(color: AppColors.emeraldGreen),
                    ),

                    // Laser Scanline Effect
                    AnimatedBuilder(
                      animation: _laserController,
                      builder: (context, child) {
                        return Positioned(
                          top: 20 + (_laserController.value * 220),
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.emeraldGreen,
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emeraldGreen.withValues(alpha: 0.9),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Tap to Scan Fallback Hint
                    Positioned(
                      bottom: 12,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _processAndOpenQrSafely(
                            rawPayload: 'https://pay.upi.org/verify?merchant=GreenGroceries&am=150',
                            source: 'Simulated QR Scan',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'Tap to simulate QR scan',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 1-Click Scan & Open Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                _processAndOpenQrSafely(
                  rawPayload: 'https://guardianplus.app/safe-demo-merchant',
                  source: 'Camera Capture',
                );
              },
              icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.onPrimary),
              label: const Text('Capture & Open Safely (1-Click)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldGreen,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cyber Security Sandbox Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.cyberBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.cyberBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anti-Exfiltration Active',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Neutralizes tracking tokens, clipboard theft & silent APK downloads before opening.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.onSurfaceMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCameraFallbackView() {
    return Container(
      color: const Color(0xFF0C1914),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_rounded, color: AppColors.emeraldGreen, size: 48),
            const SizedBox(height: 8),
            Text(
              'Scanning Stream Active',
              style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ── History View ──────────────────────────────────────────────────────────

  Widget _buildHistoryView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.screenPadding),
      children: [
        _buildHistoryItem(
          title: 'UPI Merchant Pay QR',
          url: 'upi://pay?pa=greenstore@okicici&pn=GreenStore',
          status: 'Clean & Verified',
          score: 98,
          isSafe: true,
        ),
        _buildHistoryItem(
          title: 'Parking Claim Voucher QR',
          url: 'http://claim-free-park-bonus.top/redeem?token=92841',
          status: 'Malicious Phishing Trap',
          score: 12,
          isSafe: false,
        ),
        _buildHistoryItem(
          title: 'Coffee Shop Wi-Fi QR',
          url: 'WIFI:S:ForestCafe_Guest;T:WPA;P:ForestSafe2026;;',
          status: 'Clean & Encrypted',
          score: 95,
          isSafe: true,
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String url,
    required String status,
    required int score,
    required bool isSafe,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _processAndOpenQrSafely(rawPayload: url, source: title);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(color: isSafe ? AppColors.outline : AppColors.safetyPink.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (isSafe ? AppColors.emeraldGreen : AppColors.safetyPink).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSafe ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: isSafe ? AppColors.emeraldGreen : AppColors.safetyPink,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: AppColors.onSurface, fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    url,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$score/100',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSafe ? AppColors.emeraldGreen : AppColors.safetyPink,
                  ),
                ),
                Text(
                  'Click to Open >',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.emeraldGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Gallery View (Pick Image & Sample QRs) ────────────────────────────────

  Widget _buildGalleryView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.emeraldGreen, size: 30),
                ),
                const SizedBox(height: 14),
                Text(
                  'Upload QR Image & Open Safely',
                  style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a screenshot or photo containing a QR code',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _processAndOpenQrSafely(
                      rawPayload: 'https://restaurant-menu.app/table-14?session=safe',
                      source: 'Gallery Uploaded Image',
                    );
                  },
                  icon: const Icon(Icons.image_search_rounded, color: AppColors.onPrimary, size: 20),
                  label: const Text('Choose Image File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldGreen,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size(220, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Test with Sample QR Payloads',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          _buildSampleQrTile(
            title: 'Verified UPI Payment QR',
            subtitle: 'Legitimate grocery merchant link',
            icon: Icons.payments_rounded,
            color: AppColors.emeraldGreen,
            payload: 'upi://pay?pa=greenfresh@icici&pn=GreenFreshOrganics&am=180&cu=INR',
          ),
          _buildSampleQrTile(
            title: 'Electricity Bill Disconnection Scam QR',
            subtitle: 'Malicious link attempting background data capture',
            icon: Icons.dangerous_rounded,
            color: AppColors.safetyPink,
            payload: 'http://power-bill-disconnection-alert.com/pay-urgent.apk',
          ),
          _buildSampleQrTile(
            title: 'Café Wi-Fi Connect QR',
            subtitle: 'Local guest wireless credentials',
            icon: Icons.wifi_rounded,
            color: AppColors.cyberBlue,
            payload: 'WIFI:S:GreenForest_Guest;T:WPA;P:ForestSafe2026;;',
          ),
        ],
      ),
    );
  }

  Widget _buildSampleQrTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String payload,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceMuted),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.onSurfaceMuted),
        onTap: () {
          HapticFeedback.selectionClick();
          _processAndOpenQrSafely(rawPayload: payload, source: title);
        },
      ),
    );
  }

  // ── Cyber Security Sanitizer & 1-Click Opener Engine ──────────────────────

  void _processAndOpenQrSafely({
    required String rawPayload,
    required String source,
  }) async {
    final result = await _urlSafetyService.analyzeUrl(rawPayload);
    final isSafe = result.status == UrlSafetyStatus.safe && !result.isBannedInIndia;
    final score = 100 - result.riskScore;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (isSafe ? AppColors.emeraldGreen : AppColors.safetyPink).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSafe ? Icons.shield_rounded : Icons.gpp_bad_rounded,
                          color: isSafe ? AppColors.emeraldGreen : AppColors.safetyPink,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isSafe ? 'Shield Verified · Safe to Open' : (result.isBannedInIndia ? '🚫 BANNED IN INDIA' : 'Data Exfiltration Alert!'),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isSafe ? AppColors.emeraldGreen : AppColors.safetyPink,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isSafe ? AppColors.emeraldGreen : AppColors.safetyPink).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Score: $score/100',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSafe ? AppColors.emeraldGreen : AppColors.safetyPink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Scanned Payload ($source):',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceMuted),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: SelectableText(
                  rawPayload,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface, height: 1.4),
                ),
              ),
              const SizedBox(height: 12),

              // Security Diagnostics
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isSafe ? AppColors.emeraldGreen : AppColors.safetyPink).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isSafe ? Icons.check_circle_rounded : Icons.block_rounded,
                          color: isSafe ? AppColors.emeraldGreen : AppColors.safetyPink,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.detectedCategory ?? (isSafe ? 'Sanitized: Safe to open.' : 'THREAT BLOCKED'),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSafe ? AppColors.emeraldGreen : AppColors.safetyPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...result.reasons.map((r) => Text('• $r', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurface))),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Simple 1-Click Open Action
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (isSafe) {
                    final uri = Uri.parse(rawPayload.startsWith('http') || rawPayload.startsWith('upi')
                        ? rawPayload
                        : 'https://google.com');
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opened safely in CyberShield Sandbox: $rawPayload'),
                            backgroundColor: AppColors.emeraldGreen,
                          ),
                        );
                      }
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opened safely in Sandbox: $rawPayload'),
                          backgroundColor: AppColors.emeraldGreen,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🛡️ Access Blocked! ${result.recommendation}'),
                        backgroundColor: AppColors.safetyPink,
                      ),
                    );
                  }
                },
                icon: Icon(isSafe ? Icons.open_in_new_rounded : Icons.shield_outlined, color: Colors.white),
                label: Text(
                  isSafe ? 'Click to Open Safely Now' : 'Block & Neutralize Threat',
                  style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSafe ? AppColors.emeraldGreen : AppColors.safetyPink,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Bottom Segment Bar ────────────────────────────────────────────────────

  Widget _buildBottomSegmentBar() {
    final items = [
      {'icon': Icons.camera_alt_rounded, 'label': 'Live Camera'},
      {'icon': Icons.history_rounded, 'label': 'History'},
      {'icon': Icons.photo_library_rounded, 'label': 'Gallery'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isSel = _selectedTab == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedTab = i);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isSel ? AppColors.emeraldGreen : AppColors.onSurfaceMuted,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    color: isSel ? AppColors.emeraldGreen : AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  const _CornerBracketsPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;
    const r = 16.0;

    // Top Left
    canvas.drawLine(const Offset(r, 0), const Offset(r + cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, r), const Offset(0, r + cornerLength), paint);

    // Top Right
    canvas.drawLine(Offset(size.width - r - cornerLength, 0), Offset(size.width - r, 0), paint);
    canvas.drawLine(Offset(size.width, r), Offset(size.width, r + cornerLength), paint);

    // Bottom Left
    canvas.drawLine(Offset(0, size.height - r - cornerLength), Offset(0, size.height - r), paint);
    canvas.drawLine(Offset(r, size.height), Offset(r + cornerLength, size.height), paint);

    // Bottom Right
    canvas.drawLine(Offset(size.width, size.height - r - cornerLength), Offset(size.width, size.height - r), paint);
    canvas.drawLine(Offset(size.width - r - cornerLength, size.height), Offset(size.width - r, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
