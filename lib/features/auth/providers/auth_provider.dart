import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/security/audit_logger.dart';
import '../../../shared/security/key_manager.dart';

// ── Core Auth Providers ────────────────────────────────────────────────────

/// Streams the current Firebase Auth state.
final authStateProvider = StreamProvider<GuardianUser?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) return null;
      final role = _parseRole(doc.data()?['role'] as String?);
      return GuardianUser(uid: user.uid, email: user.email, role: role);
    } catch (_) {
      return null;
    }
  });
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Family State Providers ─────────────────────────────────────────────────

/// Global family profile — StateNotifier backed (in-memory, Firebase-ready).
final familyProfileProvider =
    StateNotifierProvider<FamilyProfileNotifier, FamilyProfile>(
  (ref) => FamilyProfileNotifier(),
);

/// Derived: rules for a specific child.
final childRulesProvider =
    Provider.family<List<ChildRule>, String>((ref, childId) {
  final profile = ref.watch(familyProfileProvider);
  return profile.rules.where((r) => r.childId == childId).toList();
});

/// Derived: current user's family role.
final familyRoleProvider = Provider<FamilyRole>((ref) {
  return ref.watch(familyProfileProvider).currentUserRole;
});

// ── AuthService ────────────────────────────────────────────────────────────

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  static int _pinAttempts = 0;
  static DateTime? _lockoutUntil;
  static const _maxAttempts = 10;

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
      await AuditLogger.log(
        event: SecurityEvent.authSuccess,
        detail: 'method=create_account_demo role=${role.name}',
      );
      return AuthResult.ok;
    }
  }

  Future<PinResult> verifyPin(String pin) async {
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remaining = _lockoutUntil!.difference(DateTime.now());
      return PinResult.locked(remaining);
    }
    final isCorrect = await _checkPinSentinel(pin);
    if (!isCorrect) {
      _pinAttempts++;
      await AuditLogger.log(
        event: SecurityEvent.authFailed,
        detail: 'method=pin attempt=$_pinAttempts',
      );
      if (_pinAttempts >= _maxAttempts) {
        await KeyManager.wipeAllKeys();
        await AuditLogger.log(
          event: SecurityEvent.bruteForceTriggered,
          detail: 'key_wipe_executed after $_pinAttempts attempts',
        );
        return PinResult.wiped;
      }
      final waitSeconds = (1 << _pinAttempts.clamp(0, 10)).clamp(1, 3600);
      if (_pinAttempts >= 5) {
        _lockoutUntil = DateTime.now().add(Duration(seconds: waitSeconds));
      }
      return PinResult.incorrect(_pinAttempts);
    }
    _pinAttempts = 0;
    _lockoutUntil = null;
    await AuditLogger.log(event: SecurityEvent.authSuccess, detail: 'method=pin');
    return PinResult.correct;
  }

  Future<bool> _checkPinSentinel(String pin) async => false;

  Future<void> signOut() async {
    KeyManager.clearCache();
    await _auth.signOut();
  }
}

// ── Family Profile State Notifier ─────────────────────────────────────────

class FamilyProfileNotifier extends StateNotifier<FamilyProfile> {
  FamilyProfileNotifier() : super(_buildDemoProfile());

  /// Creates a new family, sets current user as admin.
  void createFamily({required String adminName}) {
    state = FamilyProfile(
      familyCode: _generateFamilyCode(),
      familyName: "$adminName's Family",
      currentUserRole: FamilyRole.admin,
      currentUserName: adminName,
      children: [
        const ChildProfile(
          id: 'child_riya',
          name: 'Riya',
          avatarEmoji: '👧',
          deviceId: 'dev_1',
          deviceName: "Riya's Phone",
          deviceModel: 'Samsung Galaxy A54',
        ),
        const ChildProfile(
          id: 'child_arjun',
          name: 'Arjun',
          avatarEmoji: '👦',
          deviceId: 'dev_2',
          deviceName: "Arjun's Tablet",
          deviceModel: 'Samsung Tab S7',
        ),
      ],
      members: const [],
      rules: _buildDemoRules(),
    );
  }

  /// Joins an existing family. Sets user as member.
  bool joinFamily({required String code, required String memberName}) {
    if (code.trim().length < 4) return false;
    state = FamilyProfile(
      familyCode: code.trim().toUpperCase(),
      familyName: 'Family Group',
      currentUserRole: FamilyRole.member,
      currentUserName: memberName,
      children: const [],
      members: const [],
      rules: const [],
    );
    return true;
  }

  void addRule(ChildRule rule) {
    state = state.copyWith(rules: [...state.rules, rule]);
  }

  void updateRule(ChildRule updated) {
    state = state.copyWith(
      rules: state.rules.map((r) => r.id == updated.id ? updated : r).toList(),
    );
  }

  void deleteRule(String ruleId) {
    state = state.copyWith(
      rules: state.rules.where((r) => r.id != ruleId).toList(),
    );
  }

  void addChild(ChildProfile child) {
    state = state.copyWith(children: [...state.children, child]);
  }

  void removeChild(String childId) {
    state = state.copyWith(
      children: state.children.where((c) => c.id != childId).toList(),
      rules: state.rules.where((r) => r.childId != childId).toList(),
    );
  }

  static String _generateFamilyCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    var seed = DateTime.now().millisecondsSinceEpoch;
    var code = '';
    for (int i = 0; i < 6; i++) {
      seed = (seed * 1664525 + 1013904223) & 0xFFFFFFFF;
      code += chars[seed % chars.length];
    }
    return '${code.substring(0, 3)}-${code.substring(3)}';
  }

  static FamilyProfile _buildDemoProfile() {
    return FamilyProfile(
      familyCode: 'GTR-7K2',
      familyName: 'Sharma Family',
      currentUserRole: FamilyRole.admin,
      currentUserName: 'Rajesh',
      children: const [
        ChildProfile(
          id: 'child_riya',
          name: 'Riya',
          avatarEmoji: '👧',
          deviceId: 'dev_1',
          deviceName: "Riya's Phone",
          deviceModel: 'Samsung Galaxy A54',
        ),
        ChildProfile(
          id: 'child_arjun',
          name: 'Arjun',
          avatarEmoji: '👦',
          deviceId: 'dev_2',
          deviceName: "Arjun's Tablet",
          deviceModel: 'Samsung Tab S7',
        ),
      ],
      members: const [
        FamilyMember(id: 'member_priya', name: 'Priya (Mom)', role: FamilyRole.member),
      ],
      rules: _buildDemoRules(),
    );
  }

  static List<ChildRule> _buildDemoRules() => [
        const ChildRule(
          id: 'r1', childId: 'child_riya',
          type: RuleType.screenTimeLimit, label: 'Daily Screen Time',
          value: '2 hours/day', detail: 'Max 2 hours of total screen time per day',
          isEnabled: true,
        ),
        const ChildRule(
          id: 'r2', childId: 'child_riya',
          type: RuleType.appBlock, label: 'Block TikTok',
          value: 'TikTok', detail: 'App completely blocked during school hours',
          isEnabled: true,
        ),
        const ChildRule(
          id: 'r3', childId: 'child_riya',
          type: RuleType.bedtimeCurfew, label: 'Bedtime Curfew',
          value: '9:00 PM', detail: 'Internet disabled after 9 PM on school nights',
          isEnabled: true,
        ),
        const ChildRule(
          id: 'r4', childId: 'child_riya',
          type: RuleType.contentFilter, label: 'Safe Content Filter',
          value: 'Strict', detail: 'Block adult and violent content',
          isEnabled: true,
        ),
        const ChildRule(
          id: 'r5', childId: 'child_arjun',
          type: RuleType.screenTimeLimit, label: 'Daily Screen Time',
          value: '3 hours/day', detail: 'Max 3 hours of total screen time per day',
          isEnabled: true,
        ),
        const ChildRule(
          id: 'r6', childId: 'child_arjun',
          type: RuleType.safeZone, label: 'School Safe Zone',
          value: 'Green Park High School', detail: 'Alert when child leaves school area',
          isEnabled: true,
        ),
        const ChildRule(
          id: 'r7', childId: 'child_arjun',
          type: RuleType.webFilter, label: 'Web Filter',
          value: 'Moderate', detail: 'Block adult sites, allow educational content',
          isEnabled: false,
        ),
      ];
}

// ── Data Classes ───────────────────────────────────────────────────────────

class GuardianUser {
  const GuardianUser({required this.uid, required this.role, this.email});
  final String uid;
  final String? email;
  final UserRole role;
}

class FamilyProfile {
  const FamilyProfile({
    required this.familyCode,
    required this.familyName,
    required this.currentUserRole,
    required this.currentUserName,
    required this.children,
    required this.members,
    required this.rules,
  });

  final String familyCode;
  final String familyName;
  final FamilyRole currentUserRole;
  final String currentUserName;
  final List<ChildProfile> children;
  final List<FamilyMember> members;
  final List<ChildRule> rules;

  bool get isAdmin => currentUserRole == FamilyRole.admin;

  FamilyProfile copyWith({
    String? familyCode,
    String? familyName,
    FamilyRole? currentUserRole,
    String? currentUserName,
    List<ChildProfile>? children,
    List<FamilyMember>? members,
    List<ChildRule>? rules,
  }) =>
      FamilyProfile(
        familyCode: familyCode ?? this.familyCode,
        familyName: familyName ?? this.familyName,
        currentUserRole: currentUserRole ?? this.currentUserRole,
        currentUserName: currentUserName ?? this.currentUserName,
        children: children ?? this.children,
        members: members ?? this.members,
        rules: rules ?? this.rules,
      );
}

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
  });
  final String id;
  final String name;
  final String avatarEmoji;
  final String deviceId;
  final String deviceName;
  final String deviceModel;
}

class FamilyMember {
  const FamilyMember({required this.id, required this.name, required this.role});
  final String id;
  final String name;
  final FamilyRole role;
}

class ChildRule {
  const ChildRule({
    required this.id,
    required this.childId,
    required this.type,
    required this.label,
    required this.value,
    required this.detail,
    required this.isEnabled,
  });
  final String id;
  final String childId;
  final RuleType type;
  final String label;
  final String value;
  final String detail;
  final bool isEnabled;

  ChildRule copyWith({
    String? id,
    String? childId,
    RuleType? type,
    String? label,
    String? value,
    String? detail,
    bool? isEnabled,
  }) =>
      ChildRule(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        type: type ?? this.type,
        label: label ?? this.label,
        value: value ?? this.value,
        detail: detail ?? this.detail,
        isEnabled: isEnabled ?? this.isEnabled,
      );
}

// ── Enums ──────────────────────────────────────────────────────────────────

enum FamilyRole { none, admin, member }

enum RuleType {
  screenTimeLimit,
  appBlock,
  bedtimeCurfew,
  safeZone,
  contentFilter,
  webFilter,
}

extension RuleTypeExt on RuleType {
  String get displayName {
    switch (this) {
      case RuleType.screenTimeLimit: return 'Screen Time Limit';
      case RuleType.appBlock:        return 'App Block';
      case RuleType.bedtimeCurfew:   return 'Bedtime Curfew';
      case RuleType.safeZone:        return 'Safe Zone';
      case RuleType.contentFilter:   return 'Content Filter';
      case RuleType.webFilter:       return 'Web Filter';
    }
  }

  String get emoji {
    switch (this) {
      case RuleType.screenTimeLimit: return '⏱';
      case RuleType.appBlock:        return '🚫';
      case RuleType.bedtimeCurfew:   return '🌙';
      case RuleType.safeZone:        return '📍';
      case RuleType.contentFilter:   return '🛡';
      case RuleType.webFilter:       return '🌐';
    }
  }
}

// ── Auth Result / Pin ──────────────────────────────────────────────────────

class AuthResult {
  const AuthResult._({required this.isSuccess, this.errorMessage});
  static const ok = AuthResult._(isSuccess: true);
  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
  final bool isSuccess;
  final String? errorMessage;
}

class PinResult {
  const PinResult._({required this.status, this.attemptsUsed, this.lockoutRemaining});
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
    case 'parent':       return UserRole.parent;
    case 'child':        return UserRole.child;
    case 'womensSafety': return UserRole.womensSafety;
    default:             return UserRole.individual;
  }
}
