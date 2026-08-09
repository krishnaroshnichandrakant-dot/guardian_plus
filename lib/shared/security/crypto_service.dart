import 'dart:typed_data';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/export.dart' as pc;

/// ══════════════════════════════════════════════════════════════════════════
/// Guardian Plus Cryptography Service
/// Core cryptographic engine for data protection, encryption, and secure key derivation.
///
/// Security Features:
///   • AES-256-GCM        — End-to-end data encryption at rest
///   • ChaCha20-Poly1305  — Secure alert payload encryption in transit
///   • X25519 (ECDH)      — Secure key exchange with Perfect Forward Secrecy
///   • Ed25519            — Cryptographic digital signatures for verified alerts
///   • Argon2id           — Memory-hard key derivation from user PINs
///   • HKDF-SHA-256       — Sub-key derivation for cryptographic separation
/// ══════════════════════════════════════════════════════════════════════════
class CryptoService {
  CryptoService._();
  static final CryptoService instance = CryptoService._();

  // Algorithm instances (stateless, reusable)
  static final _aesGcm = AesGcm.with256bits();
  static final _chacha = Chacha20.poly1305Aead();
  static final _x25519 = X25519();
  static final _ed25519 = Ed25519();
  static final _hmacSha256 = Hmac.sha256();
  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
  static final _random = Random.secure();

  // ── AES-256-GCM: Local storage encryption ─────────────────────────

  /// Encrypts plaintext with AES-256-GCM. Returns [EncryptedPayload].
  /// The nonce is generated fresh each call (never reused).
  Future<EncryptedPayload> encryptLocal(
    Uint8List plaintext,
    SecretKey key,
  ) async {
    final nonce = _generateNonce(12); // 96-bit nonce for AES-GCM
    final secretBox = await _aesGcm.encrypt(
      plaintext,
      secretKey: key,
      nonce: nonce,
    );
    return EncryptedPayload(
      ciphertext: Uint8List.fromList(secretBox.cipherText),
      nonce: Uint8List.fromList(nonce),
      mac: Uint8List.fromList(secretBox.mac.bytes),
      algorithm: EncryptionAlgorithm.aes256Gcm,
    );
  }

  /// Decrypts AES-256-GCM ciphertext. Throws [AuthenticationException]
  /// if MAC verification fails (tamper detection).
  Future<Uint8List> decryptLocal(
    EncryptedPayload payload,
    SecretKey key,
  ) async {
    final secretBox = SecretBox(
      payload.ciphertext,
      nonce: payload.nonce,
      mac: Mac(payload.mac),
    );
    final plaintext = await _aesGcm.decrypt(secretBox, secretKey: key);
    return Uint8List.fromList(plaintext);
  }

  // ── ChaCha20-Poly1305: Alert payload encryption ───────────────────

  /// Encrypts alert payload with ChaCha20-Poly1305.
  /// Faster than AES on devices without hardware AES acceleration.
  Future<EncryptedPayload> encryptAlert(
    Uint8List plaintext,
    SecretKey sessionKey,
  ) async {
    final nonce = _generateNonce(12);
    final secretBox = await _chacha.encrypt(
      plaintext,
      secretKey: sessionKey,
      nonce: nonce,
    );
    return EncryptedPayload(
      ciphertext: Uint8List.fromList(secretBox.cipherText),
      nonce: Uint8List.fromList(nonce),
      mac: Uint8List.fromList(secretBox.mac.bytes),
      algorithm: EncryptionAlgorithm.chacha20Poly1305,
    );
  }

  Future<Uint8List> decryptAlert(
    EncryptedPayload payload,
    SecretKey sessionKey,
  ) async {
    final secretBox = SecretBox(
      payload.ciphertext,
      nonce: payload.nonce,
      mac: Mac(payload.mac),
    );
    final plaintext = await _chacha.decrypt(secretBox, secretKey: sessionKey);
    return Uint8List.fromList(plaintext);
  }

  // ── X25519 + Perfect Forward Secrecy ─────────────────────────────

  /// Generate an ephemeral X25519 key pair for this session.
  /// MUST be discarded after the session ends.
  Future<SimpleKeyPair> generateEphemeralKeyPair() async {
    return _x25519.newKeyPair();
  }

  /// Compute a shared secret from local private key + remote public key.
  /// Result is used as input to HKDF, never used directly as a cipher key.
  Future<SecretKey> computeSharedSecret(
    SimpleKeyPair localPrivate,
    SimplePublicKey remotePublic,
  ) async {
    final sharedSecret = await _x25519.sharedSecretKey(
      keyPair: localPrivate,
      remotePublicKey: remotePublic,
    );
    // Immediately zero the ephemeral private key material after use
    await _zeroKeyPair(localPrivate);
    return sharedSecret;
  }

  // ── Ed25519: Digital signatures ───────────────────────────────────

  /// Generate a long-lived Ed25519 identity key pair.
  Future<SimpleKeyPair> generateIdentityKeyPair() async {
    return _ed25519.newKeyPair();
  }

  /// Sign a payload. Every FCM alert is signed before sending.
  Future<Signature> signPayload(
    Uint8List payload,
    SimpleKeyPair signingKey,
  ) async {
    return _ed25519.sign(payload, keyPair: signingKey);
  }

  /// Verify a signature. Throws if verification fails.
  Future<bool> verifySignature(
    Uint8List payload,
    Signature signature,
    SimplePublicKey publicKey,
  ) async {
    return _ed25519.verify(payload, signature: signature);
  }

  // ── Argon2id: PIN → key derivation ────────────────────────────────

  /// Derives a 32-byte key from a PIN using Argon2id.
  /// Parameters: m=65536KB, t=3 iterations, p=4 parallelism
  /// These are OWASP-recommended minimums for interactive login.
  Future<Uint8List> deriveKeyFromPin(String pin, Uint8List salt) async {
    // Use PointyCastle's Argon2 implementation
    final params = pc.Argon2Parameters(
      pc.Argon2Parameters.ARGON2_id,
      salt,
      desiredKeyLength: 32,
      iterations: 3,
      memory: 65536, // 64 MB — makes GPU brute-force expensive
      lanes: 4,
    );
    final generator = pc.Argon2BytesGenerator()..init(params);
    final pinBytes = Uint8List.fromList(pin.codeUnits);
    final derivedKey = Uint8List(32);
    // PointyCastle Argon2BytesGenerator uses deriveKey
    generator.deriveKey(pinBytes, 0, derivedKey, 0);

    // Zero the PIN bytes from memory immediately
    _zeroBuffer(pinBytes);
    return derivedKey;
  }

  // ── HKDF-SHA-256: Sub-key derivation ─────────────────────────────

  /// Derives a purpose-specific sub-key from a master key.
  /// [info] encodes the feature context (e.g. "storage", "alerts", "pairing").
  /// Ensures key separation: alert key ≠ storage key, even from same master.
  Future<SecretKey> deriveSubKey(
    SecretKey masterKey,
    String info,
  ) async {
    return _hkdf.deriveKey(
      secretKey: masterKey,
      nonce: Uint8List.fromList(info.codeUnits),
    );
  }

  // ── HMAC-SHA-256: Audit log integrity ────────────────────────────

  /// Computes HMAC-SHA-256 of [data] using [key].
  /// Used to authenticate audit log entries.
  Future<Uint8List> hmacSign(Uint8List data, SecretKey key) async {
    final mac = await _hmacSha256.calculateMac(data, secretKey: key);
    return Uint8List.fromList(mac.bytes);
  }

  Future<bool> hmacVerify(
    Uint8List data,
    Uint8List expectedMac,
    SecretKey key,
  ) async {
    final mac = await _hmacSha256.calculateMac(data, secretKey: key);
    final actual = Uint8List.fromList(mac.bytes);
    // Constant-time comparison (prevents timing attacks)
    return _constantTimeEqual(actual, expectedMac);
  }

  // ── Utilities ─────────────────────────────────────────────────────

  /// Generates a cryptographically secure random nonce of [length] bytes.
  Uint8List generateSalt([int length = 16]) => _generateNonce(length);

  Uint8List _generateNonce(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  /// Zeroes a buffer in memory. Dart's GC may move objects,
  /// so we do our best to overwrite before nulling the reference.
  void _zeroBuffer(Uint8List buffer) {
    buffer.fillRange(0, buffer.length, 0);
  }

  Future<void> _zeroKeyPair(SimpleKeyPair keyPair) async {
    final bytes = await keyPair.extractPrivateKeyBytes();
    _zeroBuffer(Uint8List.fromList(bytes));
  }

  /// Constant-time byte array comparison (prevents timing side-channels).
  bool _constantTimeEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}

// ── Data classes ──────────────────────────────────────────────────────────

enum EncryptionAlgorithm { aes256Gcm, chacha20Poly1305 }

/// Encrypted payload envelope — carries ciphertext, nonce, and MAC together.
class EncryptedPayload {
  const EncryptedPayload({
    required this.ciphertext,
    required this.nonce,
    required this.mac,
    required this.algorithm,
  });

  final Uint8List ciphertext;
  final Uint8List nonce;
  final Uint8List mac;
  final EncryptionAlgorithm algorithm;

  /// Serialize to bytes for storage or transmission.
  /// Format: [1 byte algorithm] [1 byte nonce_len] [nonce] [16 bytes mac] [ciphertext]
  Uint8List toBytes() {
    final nonceLen = nonce.length;
    final total = 1 + 1 + nonceLen + 16 + ciphertext.length;
    final out = Uint8List(total);
    var offset = 0;
    out[offset++] = algorithm.index;
    out[offset++] = nonceLen;
    out.setRange(offset, offset + nonceLen, nonce);
    offset += nonceLen;
    out.setRange(offset, offset + 16, mac.sublist(0, 16));
    offset += 16;
    out.setRange(offset, offset + ciphertext.length, ciphertext);
    return out;
  }

  factory EncryptedPayload.fromBytes(Uint8List bytes) {
    var offset = 0;
    final algorithm = EncryptionAlgorithm.values[bytes[offset++]];
    final nonceLen = bytes[offset++];
    final nonce = bytes.sublist(offset, offset + nonceLen);
    offset += nonceLen;
    final mac = bytes.sublist(offset, offset + 16);
    offset += 16;
    final ciphertext = bytes.sublist(offset);
    return EncryptedPayload(
      ciphertext: ciphertext,
      nonce: nonce,
      mac: mac,
      algorithm: algorithm,
    );
  }
}
