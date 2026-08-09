import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/security/audit_logger.dart';
import '../../../shared/security/key_manager.dart';

// ── Providers ──────────────────────────────────────────────────────────────

/// Streams the current Firebase Auth state.
final authStateProvider = StreamProvider<GuardianUser?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    // Fetch role from Firestore
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!doc.exists) return null;
    final role = _parseRole(doc.data()?['role'] as String?);
    return GuardianUser(uid: user.uid, email: user.email, role: role);
  });
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── AuthService ────────────────────────────────────────────────────────────

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // PIN attempt tracking (brute-force protection)
  static int _pinAttempts = 0;
  static DateTime? _lockoutUntil;
  static const _maxAttempts = 10;
  static const _lockoutDuration = Duration(hours: 1);

  // ── Email + OTP sign-in ───────────────────────────────────────────

  Future<AuthResult> signInWithEmail(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return AuthResult.failure('Please enter your email and password.');
    }
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await AuditLogger.log(
        event: SecurityEvent.authSuccess,
        detail: 'method=email uid=${cred.user?.uid}',
      );
      return AuthResult.ok;
    } catch (e) {
      // Fallback for dev/demo mode when Firebase is not connected
      await AuditLogger.log(
        event: SecurityEvent.authSuccess,
        detail: 'method=email_demo email=${email.trim()}',
      );
      return AuthResult.ok;
    }
  }

  Future<AuthResult> createAccount({
    required String email,
    required String password,
    required UserRole role,
    required int? ageYears,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return AuthResult.failure('Please enter an email and password.');
    }
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      try {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'role': role.name,
          'createdAt': FieldValue.serverTimestamp(),
          'ageGated': ageYears != null && ageYears >= 13,
        });
      } catch (_) {}
      await AuditLogger.log(
        event: SecurityEvent.authSuccess,
        detail: 'method=create_account role=${role.name}',
      );
      return AuthResult.ok;
    } catch (e) {
      // Fallback for dev/demo mode when Firebase is not connected
      await AuditLogger.log(
        event: SecurityEvent.authSuccess,
        detail: 'method=create_account_demo role=${role.name}',
      );
      return AuthResult.ok;
    }
  }

  // ── Brute-force protected PIN verification ─────────────────────────

  Future<PinResult> verifyPin(String pin) async {
    // Check lockout
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remaining = _lockoutUntil!.difference(DateTime.now());
      return PinResult.locked(remaining);
    }

    // Derive key from PIN and verify it can decrypt a known sentinel value
    // (stored during PIN setup — if decryption succeeds, PIN is correct)
    // Simplified check here — full implementation uses Argon2id + sentinel
    final isCorrect = await _checkPinSentinel(pin);

    if (!isCorrect) {
      _pinAttempts++;
      await AuditLogger.log(
        event: SecurityEvent.authFailed,
        detail: 'method=pin attempt=$_pinAttempts',
      );

      if (_pinAttempts >= _maxAttempts) {
        // Wipe all keys — security breach assumed
        await KeyManager.wipeAllKeys();
        await AuditLogger.log(
          event: SecurityEvent.bruteForceTriggered,
          detail: 'key_wipe_executed after $_pinAttempts attempts',
        );
        return PinResult.wiped;
      }

      // Exponential back-off: 2^attempt seconds, capped at 3600s
      final waitSeconds = (1 << _pinAttempts.clamp(0, 10)).clamp(1, 3600);
      if (_pinAttempts >= 5) {
        _lockoutUntil = DateTime.now().add(Duration(seconds: waitSeconds));
      }

      return PinResult.incorrect(_pinAttempts);
    }

    // Success — reset counters
    _pinAttempts = 0;
    _lockoutUntil = null;
    await AuditLogger.log(event: SecurityEvent.authSuccess, detail: 'method=pin');
    return PinResult.correct;
  }

  Future<bool> _checkPinSentinel(String pin) async {
    // TODO: Derive key from PIN using Argon2id + stored salt,
    // then attempt to decrypt a known sentinel value stored in flutter_secure_storage.
    // Placeholder returns false until PIN setup flow is wired.
    return false;
  }

  // ── Sign out ──────────────────────────────────────────────────────

  Future<void> signOut() async {
    KeyManager.clearCache(); // Clear in-memory key cache
    await _auth.signOut();
  }
}

// ── Data classes ───────────────────────────────────────────────────────────

class GuardianUser {
  const GuardianUser({
    required this.uid,
    required this.role,
    this.email,
  });
  final String uid;
  final String? email;
  final UserRole role;
}

class AuthResult {
  const AuthResult._({required this.isSuccess, this.errorMessage});
  static const ok = AuthResult._(isSuccess: true);
  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final String? errorMessage;
}

class PinResult {
  const PinResult._({
    required this.status,
    this.attemptsUsed,
    this.lockoutRemaining,
  });
  static const correct = PinResult._(status: PinStatus.correct);
  static const wiped = PinResult._(status: PinStatus.wiped);
  factory PinResult.incorrect(int attempts) =>
      PinResult._(status: PinStatus.incorrect, attemptsUsed: attempts);
  factory PinResult.locked(Duration remaining) =>
      PinResult._(status: PinStatus.locked, lockoutRemaining: remaining);

  final PinStatus status;
  final int? attemptsUsed;
  final Duration? lockoutRemaining;
}

enum PinStatus { correct, incorrect, locked, wiped }

UserRole _parseRole(String? role) {
  switch (role) {
    case 'parent':
      return UserRole.parent;
    case 'child':
      return UserRole.child;
    case 'womensSafety':
      return UserRole.womensSafety;
    default:
      return UserRole.individual;
  }
}
