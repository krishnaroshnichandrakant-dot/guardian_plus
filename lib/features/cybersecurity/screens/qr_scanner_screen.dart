import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/design_tokens.dart';
import '../services/url_safety_service.dart';

/// QR Code Scanner screen with real-time safety analysis before opening links.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  UrlAnalysisResult? _lastResult;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: AppColors.onSurfaceMuted),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleQrDetect,
          ),

          // Scan overlay frame
          _buildScannerOverlay(),

          // Safety result sheet
          if (_lastResult != null) _buildResultSheet(_lastResult!),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(
            color: _lastResult == null
                ? AppColors.cyberBlue
                : (_lastResult!.status == UrlSafetyStatus.safe
                    ? AppColors.emeraldGreen
                    : AppColors.errorRed),
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing)
              const CircularProgressIndicator(color: AppColors.cyberBlue)
            else
              Text(
                'Align QR code inside box',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.02, 1.02),
            duration: 1.5.seconds,
          ),
    );
  }

  void _handleQrDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    final safetyService = ref.read(urlSafetyServiceProvider);
    final result = await safetyService.analyzeUrl(rawValue);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _lastResult = result;
      });
    }
  }

  Widget _buildResultSheet(UrlAnalysisResult result) {
    final isSafe = result.status == UrlSafetyStatus.safe;
    final color = isSafe
        ? AppColors.emeraldGreen
        : (result.status == UrlSafetyStatus.suspicious
            ? AppColors.warningAmber
            : AppColors.errorRed);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.screenPadding),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSafe ? Icons.verified_user_rounded : Icons.warning_rounded,
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: DesignTokens.spacingSm),
                Text(
                  isSafe ? 'Link Verified Safe' : 'Safety Warning (${result.riskScore}/100 Risk)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingSm),
            Text(
              result.url,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceMuted),
            ),
            const SizedBox(height: DesignTokens.spacingMd),
            ...result.reasons.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_right_rounded, size: 16, color: color),
                      Expanded(
                        child: Text(
                          r,
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurface),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: DesignTokens.spacingLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _lastResult = null),
                    child: const Text('Scan Another'),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingMd),
                if (isSafe)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Open in browser
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldGreen),
                      child: const Text('Open Link'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ).animate().slideY(begin: 0.3, end: 0, duration: DesignTokens.animNormal),
    );
  }
}
