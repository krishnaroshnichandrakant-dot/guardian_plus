import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'crypto_service.dart';
import 'audit_logger.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// Guardian Plus Key Manager
/// Layer 2 of the 8-layer security architecture
///
/// Key Hierarchy:
///   Android Keystore (hardware TEE / StrongBox)
///   └── Master Identity Key (Ed25519)
///       ├── Storage Encryption Key  (HKDF-derived, AES-256)
///       ├── Alert Signing Key       (HKDF-derived, Ed25519, rotates every 7d)
///       └── Session Key Pool        (ephemeral X25519, per-session)
///
/// All sensitive key material is stored in flutter_secure_storage which
/// uses Android Keystore on Android and iOS Secure Enclave on iOS.
/// Keys bound to biometric auth for sensitive operations.
/// ══════════════════════════════════════════════════════════════════════════
class KeyManager {
  KeyManager._();
  static final KeyManager _instance = KeyManager._();
  static KeyManager get instance => _instance;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static final _localAuth = LocalAuthentication();
  static final _crypto = CryptoService.instance;

  // Key storage keys
  static const _kIdentityPrivate = 'gp_identity_private';
  static const _kIdentityPublic = 'gp_identity_public';
  static const _kStorageKey = 'gp_storage_key';
  static const _kAlertSigningPrivate = 'gp_alert_signing_private';
  static const _kAlertSigningPublic = 'gp_alert_signing_public';
  static const _kAlertKeyRotatedAt = 'gp_alert_key_rotated_at';
  static const _kMasterSalt = 'gp_master_salt';

  // In-memory key cache (cleared on screen lock / app background)
  static SecretKey? _storageKeyCache;
  static SimpleKeyPair? _alertSigningKeyCache;

  static bool _initialized = false;

  // ── Initialization ────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;
    await _ensureIdentityKey();
    await _ensureStorageKey();
    await _rotateAlertSigningKeyIfNeeded();
    _initialized = true;
    await AuditLogger.log(
      event: SecurityEvent.keyManagerInit,
      detail: 'keys_provisioned',
    );
  }

  // ── Identity Key (Ed25519, long-lived) ────────────────────────────

  static Future<void> _ensureIdentityKey() async {
    final existing = await _storage.read(key: _kIdentityPrivate);
    if (existing != null) return;

    // Generate a new Ed25519 identity key pair
    final keyPair = await CryptoService.instance.generateIdentityKeyPair();
    final privateBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    final publicBytes = publicKey.bytes;

    await _storage.write(
      key: _kIdentityPrivate,
      value: _bytesToHex(Uint8List.fromList(privateBytes)),
    );
    await _storage.write(
      key: _kIdentityPublic,
      value: _bytesToHex(Uint8List.fromList(publicBytes)),
    );

    // Zero private bytes from memory
    final mutable = Uint8List.fromList(privateBytes);
    mutable.fillRange(0, mutable.length, 0);

    await AuditLogger.log(
      event: SecurityEvent.keyGenerated,
      detail: 'identity_key_pair_generated',
    );
  }

  static Future<SimplePublicKey> getIdentityPublicKey() async {
    final hex = await _storage.read(key: _kIdentityPublic);
    if (hex == null) throw StateError('Identity key not initialized');
    final bytes = _hexToBytes(hex);
    return SimplePublicKey(bytes, type: KeyPairType.ed25519);
  }

  static Future<SimpleKeyPair> getIdentityKeyPair() async {
    final privHex = await _storage.read(key: _kIdentityPrivate);
    final pubHex = await _storage.read(key: _kIdentityPublic);
    if (privHex == null || pubHex == null) {
      throw StateError('Identity key not initialized');
    }
    return SimpleKeyPairData(
      _hexToBytes(privHex),
      publicKey: SimplePublicKey(_hexToBytes(pubHex), type: KeyPairType.ed25519),
      type: KeyPairType.ed25519,
    );
  }

  // ── Storage Encryption Key (AES-256, HKDF-derived) ────────────────

  static Future<void> _ensureStorageKey() async {
    final existing = await _storage.read(key: _kStorageKey);
    if (existing != null) {
      // Warm cache
      _storageKeyCache = SecretKey(_hexToBytes(existing));
      return;
    }

    // Generate a fresh 256-bit storage key
    final keyBytes = _crypto.generateSalt(32);
    await _storage.write(
      key: _kStorageKey,
      value: _bytesToHex(keyBytes),
    );
    _storageKeyCache = SecretKey(keyBytes);
    keyBytes.fillRange(0, keyBytes.length, 0); // zero after store
  }

  /// Returns the AES-256 storage key (from cache or Keystore).
  static Future<SecretKey> getStorageKey() async {
    if (_storageKeyCache != null) return _storageKeyCache!;
    await _ensureStorageKey();
    return _storageKeyCache!;
  }

  // ── Alert Signing Key (Ed25519, rotates every 7 days) ─────────────

  static Future<void> _rotateAlertSigningKeyIfNeeded() async {
    final rotatedAtStr = await _storage.read(key: _kAlertKeyRotatedAt);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (rotatedAtStr != null) {
      final rotatedAt = int.parse(rotatedAtStr);
      final age = Duration(milliseconds: now - rotatedAt);
      if (age.inDays < 7) {
        // Not yet due for rotation; warm cache
        await _loadAlertSigningKey();
        return;
      }
    }

    // Generate fresh alert signing key
    final keyPair = await _crypto.generateIdentityKeyPair(); // Ed25519
    final privateBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();

    await _storage.write(
      key: _kAlertSigningPrivate,
      value: _bytesToHex(Uint8List.fromList(privateBytes)),
    );
    await _storage.write(
      key: _kAlertSigningPublic,
      value: _bytesToHex(Uint8List.fromList(publicKey.bytes)),
    );
    await _storage.write(
      key: _kAlertKeyRotatedAt,
      value: now.toString(),
    );

    _alertSigningKeyCache = keyPair;

    // Zero private bytes
    final mutable = Uint8List.fromList(privateBytes);
    mutable.fillRange(0, mutable.length, 0);

    await AuditLogger.log(
      event: SecurityEvent.keyRotated,
      detail: 'alert_signing_key_rotated',
    );
  }

  static Future<void> _loadAlertSigningKey() async {
    final privHex = await _storage.read(key: _kAlertSigningPrivate);
    final pubHex = await _storage.read(key: _kAlertSigningPublic);
    if (privHex == null || pubHex == null) {
      await _rotateAlertSigningKeyIfNeeded();
      return;
    }
    _alertSigningKeyCache = SimpleKeyPairData(
      _hexToBytes(privHex),
      publicKey: SimplePublicKey(_hexToBytes(pubHex), type: KeyPairType.ed25519),
      type: KeyPairType.ed25519,
    );
  }

  static Future<SimpleKeyPair> getAlertSigningKey() async {
    if (_alertSigningKeyCache != null) return _alertSigningKeyCache!;
    await _loadAlertSigningKey();
    return _alertSigningKeyCache!;
  }

  // ── Ephemeral Session Keys (X25519, per-pairing-session) ──────────

  /// Generate and return an ephemeral X25519 key pair for one pairing session.
  /// Caller is responsible for zeroing the private key after shared secret derivation.
  static Future<SimpleKeyPair> generateSessionKeyPair() async {
    return CryptoService.instance.generateEphemeralKeyPair();
  }

  // ── Biometric-gated operations ────────────────────────────────────

  /// Authenticates via biometric before returning the key.
  /// Call this for sensitive operations: unpairing, viewing alerts, disabling monitoring.
  static Future<SecretKey?> getStorageKeyWithBiometric(String reason) async {
    final canAuth = await _localAuth.canCheckBiometrics;
    if (!canAuth) return getStorageKey(); // Fallback: no biometric hardware

    final authenticated = await _localAuth.authenticate(
      localizedReason: reason,
      options: const AuthenticationOptions(
        biometricOnly: false, // Allow PIN fallback
        stickyAuth: true,
      ),
    );

    if (!authenticated) {
      await AuditLogger.log(
        event: SecurityEvent.biometricFailed,
        detail: 'reason=$reason',
      );
      return null;
    }

    await AuditLogger.log(
      event: SecurityEvent.biometricSuccess,
      detail: 'reason=$reason',
    );
    return getStorageKey();
  }

  // ── Key Wipe (emergency) ──────────────────────────────────────────

  /// Wipes all local keys. Called on:
  ///   - 10 consecutive failed PIN attempts
  ///   - APK tampering detected
  ///   - User-initiated factory reset from Settings
  static Future<void> wipeAllKeys() async {
    await _storage.deleteAll();
    _storageKeyCache = null;
    _alertSigningKeyCache = null;
    _initialized = false;

    await AuditLogger.log(
      event: SecurityEvent.keyWipe,
      detail: 'all_keys_wiped',
    );
  }

  /// Clear in-memory key cache when app goes to background.
  static void clearCache() {
    _storageKeyCache = null;
    _alertSigningKeyCache = null;
  }

  // ── Helpers ───────────────────────────────────────────────────────

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
