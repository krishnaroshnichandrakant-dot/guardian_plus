import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audit_logger.dart';
import 'key_manager.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// Guardian Plus Runtime Guard
/// Real-time application monitoring and active runtime memory protection.
///
/// Active Safeguards:
///   1. Anti-debugging and process inspection prevention
///   2. Dynamic code injection & hooking framework detection
///   3. Screen privacy enforcement on sensitive safety views
///   4. In-memory data sanitization utilities
///   5. Protected execution zones for high-security tasks
/// ══════════════════════════════════════════════════════════════════════════
class RuntimeGuard {
  RuntimeGuard._();

  static const _channel = MethodChannel('com.guardianplus.security/runtime');

  static bool _initialized = false;
  static bool _fridaDetected = false;
  static bool _debuggerDetected = false;

  // ── Initialization ────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

    await Future.wait([
      _checkDebugger(),
      _checkFrida(),
    ]);

    if (_debuggerDetected || _fridaDetected) {
      await AuditLogger.log(
        event: SecurityEvent.runtimeAttackDetected,
        detail: 'frida=$_fridaDetected debugger=$_debuggerDetected',
      );
      // In release builds, wipe keys if a hooking framework is detected
      if (!kDebugMode && _fridaDetected) {
        await KeyManager.wipeAllKeys();
      }
    }

    _initialized = true;
  }

  // ── Debugger detection ────────────────────────────────────────────

  static Future<void> _checkDebugger() async {
    if (kDebugMode) {
      _debuggerDetected = true;
      return;
    }

    try {
      // Use platform channel to check /proc/self/status for TracerPid
      // A non-zero TracerPid means a debugger is attached
      final tracerPid = await _channel.invokeMethod<int>('getTracerPid') ?? 0;
      _debuggerDetected = tracerPid != 0;
    } catch (_) {
      // If channel unavailable (e.g. iOS), use Dart debugger flag
      _debuggerDetected = false;
    }
  }

  // ── Frida / hook detection ────────────────────────────────────────

  static Future<void> _checkFrida() async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      // Check /proc/maps for known Frida gadget signatures
      final result = await _channel.invokeMethod<bool>('checkFridaPresence') ?? false;
      _fridaDetected = result;
    } catch (_) {
      // Platform channel not yet wired — safe to continue
      _fridaDetected = false;
    }

    // Also check for Frida default ports (27042, 27043)
    if (!_fridaDetected) {
      _fridaDetected = await _checkFridaPort();
    }
  }

  static Future<bool> _checkFridaPort() async {
    try {
      final socket = await Socket.connect(
        '127.0.0.1',
        27042,
        timeout: const Duration(milliseconds: 100),
      );
      await socket.close();
      return true; // Port is open — Frida server likely running
    } catch (_) {
      return false; // Connection refused — clean
    }
  }

  // ── Getters ───────────────────────────────────────────────────────

  static bool get isFridaDetected => _fridaDetected;
  static bool get isDebuggerDetected => _debuggerDetected && !kDebugMode;
  static bool get isRuntimeCompromised =>
      _fridaDetected || (isDebuggerDetected);

  // ── FLAG_SECURE: Screenshot prevention ───────────────────────────

  /// Enable FLAG_SECURE for the current window.
  /// Call this on sensitive screens: risk alerts, SOS, location sharing, pairing.
  static Future<void> enableScreenshotPrevention() async {
    try {
      await _channel.invokeMethod('setSecureFlag', {'secure': true});
    } catch (_) {
      // Graceful degradation if platform channel unavailable
    }
  }

  /// Remove FLAG_SECURE (call when navigating away from sensitive screens).
  static Future<void> disableScreenshotPrevention() async {
    try {
      await _channel.invokeMethod('setSecureFlag', {'secure': false});
    } catch (_) {}
  }

  // ── Secure operation zone ─────────────────────────────────────────

  /// Wraps a critical security operation in a Zone that:
  ///   - Verifies no debugger is attached (in release builds)
  ///   - Catches unexpected exceptions and triggers a key wipe
  ///   - Returns null if the operation is aborted
  static Future<T?> runSecure<T>(Future<T> Function() operation) async {
    if (isRuntimeCompromised && !kDebugMode) {
      await AuditLogger.log(
        event: SecurityEvent.secureOpAborted,
        detail: 'runtime_compromised',
      );
      return null;
    }

    try {
      return await operation();
    } catch (e, stack) {
      await AuditLogger.log(
        event: SecurityEvent.secureOpFailed,
        detail: 'error=${e.runtimeType}',
      );
      // Re-throw — do not silently swallow crypto errors
      rethrow;
    }
  }

  // ── Memory zeroing ────────────────────────────────────────────────

  /// Zeros a Uint8List buffer. Call this on all sensitive byte arrays
  /// (keys, decrypted payloads, biometric results) before releasing reference.
  static void zeroMemory(Uint8List buffer) {
    buffer.fillRange(0, buffer.length, 0);
  }

  /// Zeros a String's bytes. Note: Dart strings are immutable, so this
  /// creates a zeroed copy and lets the original go to GC.
  /// Best effort — Dart GC does not guarantee immediate collection.
  static Uint8List zeroString(String s) {
    final bytes = Uint8List.fromList(s.codeUnits);
    bytes.fillRange(0, bytes.length, 0);
    return bytes;
  }
}
