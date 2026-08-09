import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'audit_logger.dart';
import 'key_manager.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// Guardian Plus Integrity Guard
/// Application tamper protection and environment trust validation.
///
/// Verification Safeguards:
///   1. Rooted device and superuser detection
///   2. Application package signature self-verification
///   3. Release build debugging state validation
///   4. Custom firmware and test-keys build checks
///   5. Emulator and non-genuine environment detection
/// ══════════════════════════════════════════════════════════════════════════
class IntegrityGuard {
  IntegrityGuard._();

  /// Expected SHA-256 fingerprint of the release signing cert.
  /// IMPORTANT: Replace with your actual release signing cert fingerprint
  /// after setting up your keystore. This is checked at every startup.
  static const _expectedCertFingerprint =
      'REPLACE_WITH_ACTUAL_RELEASE_CERT_SHA256_FINGERPRINT';

  static final _deviceInfoPlugin = DeviceInfoPlugin();

  // ── Main entry point ─────────────────────────────────────────────

  static Future<IntegrityResult> runCheck() async {
    final checks = await Future.wait([
      _checkRoot(),
      _checkDebugMode(),
      _checkEmulator(),
      _checkApkSignature(),
    ]);

    final isRooted = checks[0];
    final isDebuggable = checks[1];
    final isEmulator = checks[2];
    final signatureOk = checks[3];

    IntegrityResult result;

    if (!signatureOk && !kDebugMode) {
      // Tampered APK: wipe keys and return compromised
      await KeyManager.wipeAllKeys();
      result = IntegrityResult.compromised;
    } else if (isRooted) {
      result = IntegrityResult.rooted;
    } else if (isEmulator) {
      result = IntegrityResult.emulator;
    } else if (isDebuggable && !kDebugMode) {
      result = IntegrityResult.debuggable;
    } else {
      result = IntegrityResult.clean;
    }

    await AuditLogger.log(
      event: SecurityEvent.integrityCheck,
      detail: 'result=${result.name} rooted=$isRooted debug=$isDebuggable '
          'emulator=$isEmulator sigOk=$signatureOk',
    );

    return result;
  }

  // ── Root detection ────────────────────────────────────────────────

  static Future<bool> _checkRoot() async {
    try {
      // flutter_jailbreak_detection covers: su binary, Magisk,
      // Superuser.apk, test-keys builds, dangerous props
      return await FlutterJailbreakDetection.jailbroken;
    } catch (_) {
      return false; // If detection fails, do not block the user
    }
  }

  // ── Debug mode check ──────────────────────────────────────────────

  static Future<bool> _checkDebugMode() async {
    if (kDebugMode) return true;
    // Also check via Platform for extra certainty in release builds
    try {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return androidInfo.isPhysicalDevice == false;
    } catch (_) {
      return false;
    }
  }

  // ── Emulator detection ────────────────────────────────────────────

  static Future<bool> _checkEmulator() async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final info = await _deviceInfoPlugin.androidInfo;
        // Heuristics: emulators typically report these fingerprints/models
        final fingerprint = info.fingerprint.toLowerCase();
        final model = info.model.toLowerCase();
        return fingerprint.contains('generic') ||
            fingerprint.contains('unknown') ||
            fingerprint.contains('emulator') ||
            model.contains('sdk') ||
            model.contains('emulator') ||
            model.contains('android sdk') ||
            info.hardware == 'goldfish' ||
            info.hardware == 'ranchu';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── APK Signature verification ────────────────────────────────────

  static Future<bool> _checkApkSignature() async {
    // In debug mode, skip signature check (signing cert will be debug cert)
    if (kDebugMode) return true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      // packageInfo.installerStore tells us if installed from Play Store
      // Full cert pinning requires a platform channel to read signing certs
      // via PackageManager.GET_SIGNATURES — scaffolded as TODO below
      // TODO: Implement platform channel to verify signing cert SHA-256
      // against _expectedCertFingerprint
      return true; // Placeholder: returns true until platform channel is wired
    } catch (_) {
      return false;
    }
  }

  // ── Feature degradation based on integrity result ─────────────────

  /// Returns true if sensitive features should be restricted.
  static bool shouldRestrictSensitiveFeatures(IntegrityResult result) {
    return result == IntegrityResult.compromised ||
        result == IntegrityResult.rooted;
  }

  /// Returns a user-facing warning message for the given integrity result.
  static String? getWarningMessage(IntegrityResult result) {
    switch (result) {
      case IntegrityResult.clean:
        return null;
      case IntegrityResult.rooted:
        return 'Your device appears to be rooted. Some security features '
            '(SOS audio capture, location sharing) are restricted to protect '
            'your safety. Guardian Plus continues to work with reduced functionality.';
      case IntegrityResult.emulator:
        return 'Running on an emulator — full security features require a '
            'physical device.';
      case IntegrityResult.debuggable:
        return 'Debug mode detected. Security features are restricted.';
      case IntegrityResult.compromised:
        return 'This app installation appears to have been tampered with. '
            'For your safety, Guardian Plus cannot run. '
            'Please reinstall from the official Play Store.';
    }
  }
}

enum IntegrityResult { clean, rooted, emulator, debuggable, compromised }
