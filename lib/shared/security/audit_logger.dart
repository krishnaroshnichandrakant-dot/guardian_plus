import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// Guardian Plus Security Audit Logger
/// Secure, tamper-evident log manager for local safety events and security logs.
///
/// Features:
///   • Append-only storage authenticated with HMAC-SHA-256 signatures
///   • Cryptographically signed log entries to detect any unauthorized modification
///   • Strictly local storage to protect user privacy (never uploaded)
/// ══════════════════════════════════════════════════════════════════════════
class AuditLogger {
  AuditLogger._();

  static const _boxName = 'gp_audit_log';
  static const _hmacKeyStorageKey = 'gp_audit_hmac_key';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static final _hmac = Hmac.sha256();

  static Box<Map>? _box;
  static SecretKey? _hmacKey;
  static bool _initialized = false;

  // ── Initialization ────────────────────────────────────────────────

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _box = await Hive.openBox<Map>(_boxName);
    _hmacKey = await _getOrCreateHmacKey();
    _initialized = true;
  }

  static Future<SecretKey> _getOrCreateHmacKey() async {
    final existing = await _storage.read(key: _hmacKeyStorageKey);
    if (existing != null) {
      return SecretKey(_hexToBytes(existing));
    }
    // Generate a cryptographically-secure 256-bit HMAC key
    final rng = Random.secure();
    final keyBytes = Uint8List.fromList(
      List<int>.generate(32, (_) => rng.nextInt(256)),
    );
    await _storage.write(
      key: _hmacKeyStorageKey,
      value: _bytesToHex(keyBytes),
    );
    return SecretKey(keyBytes);
  }

  // ── Log Entry ─────────────────────────────────────────────────────

  /// Append a signed security event to the audit log.
  static Future<void> log({
    required SecurityEvent event,
    String? detail,
  }) async {
    await _ensureInitialized();

    final timestamp = DateTime.now().toIso8601String();
    final entryData = {
      'ts': timestamp,
      'event': event.name,
      if (detail != null) 'detail': detail,
    };

    // Compute HMAC over the serialized entry
    final entryBytes = Uint8List.fromList(utf8.encode(jsonEncode(entryData)));
    final mac = await _hmac.calculateMac(entryBytes, secretKey: _hmacKey!);
    final hmacHex = _bytesToHex(Uint8List.fromList(mac.bytes));

    final signedEntry = {
      ...entryData,
      'hmac': hmacHex,
    };

    await _box!.add(signedEntry);
  }

  // ── Read & Verify ─────────────────────────────────────────────────

  /// Returns all audit log entries. Marks tampered entries.
  static Future<List<AuditEntry>> readLog() async {
    await _ensureInitialized();
    final entries = <AuditEntry>[];

    for (final raw in _box!.values) {
      final entry = Map<String, dynamic>.from(raw);
      final storedHmac = entry.remove('hmac') as String?;
      final entryBytes = Uint8List.fromList(
        utf8.encode(jsonEncode(entry)),
      );

      bool valid = false;
      if (storedHmac != null) {
        final mac = await _hmac.calculateMac(entryBytes, secretKey: _hmacKey!);
        final computed = _bytesToHex(Uint8List.fromList(mac.bytes));
        valid = _constantTimeEqual(computed, storedHmac);
      }

      entries.add(AuditEntry(
        timestamp: DateTime.parse(entry['ts'] as String),
        event: _parseEvent(entry['event'] as String),
        detail: entry['detail'] as String?,
        isTampered: !valid,
      ));
    }

    return entries;
  }

  /// Returns true if any log entry has been tampered with.
  static Future<bool> hasIntegrityViolation() async {
    final entries = await readLog();
    return entries.any((e) => e.isTampered);
  }

  // ── Utilities ─────────────────────────────────────────────────────

  static void import_secure_random(Uint8List buffer) {
    // In real code, use: final rng = Random.secure(); buffer[i] = rng.nextInt(256);
    // Simplified for scaffold — replace with proper secure RNG
    for (var i = 0; i < buffer.length; i++) {
      buffer[i] = (DateTime.now().microsecondsSinceEpoch + i * 31) & 0xFF;
    }
  }

  static SecurityEvent _parseEvent(String name) {
    return SecurityEvent.values.firstWhere(
      (e) => e.name == name,
      orElse: () => SecurityEvent.unknown,
    );
  }

  static bool _constantTimeEqual(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  static String _bytesToHex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}

// ── Event types ────────────────────────────────────────────────────────────

enum SecurityEvent {
  unknown,
  appStart,
  keyManagerInit,
  keyGenerated,
  keyRotated,
  keyWipe,
  biometricSuccess,
  biometricFailed,
  integrityCheck,
  runtimeAttackDetected,
  secureOpAborted,
  secureOpFailed,
  authSuccess,
  authFailed,
  bruteForceTriggered,
  devicePaired,
  deviceUnpaired,
  alertSent,
  alertReceived,
  sosTriggered,
  locationShareStarted,
  locationShareStopped,
  replayAttackBlocked,
  phishingBlocked,
  smsRiskDetected,
}

// ── Data class ─────────────────────────────────────────────────────────────

class AuditEntry {
  const AuditEntry({
    required this.timestamp,
    required this.event,
    this.detail,
    this.isTampered = false,
  });

  final DateTime timestamp;
  final SecurityEvent event;
  final String? detail;
  final bool isTampered;
}
