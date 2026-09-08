import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/consent_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/pairing_screen.dart';
import '../../features/shared/screens/main_shell.dart';
import '../../features/cybersecurity/screens/qr_scanner_screen.dart';
import '../../features/cybersecurity/screens/permission_auditor_screen.dart';
import '../../features/womens_safety/screens/safe_route_screen.dart';
import '../../features/family/screens/family_setup_screen.dart';

/// Routes where authentication is NOT required.
const _publicRoutes = {
  Routes.splash,
  Routes.onboarding,
  Routes.roleSelection,
  Routes.consent,
  Routes.login,
  Routes.pairing,
};

/// Default landing route per role after successful authentication.
String _defaultRouteForRole(UserRole role) {
  switch (role) {
    case UserRole.individual:
    case UserRole.womensSafety:
      return Routes.guardianHome;
    case UserRole.parent:
      return Routes.guardianHome;
    case UserRole.child:
      return Routes.childHome;
  }
}

/// Riverpod-aware GoRouter with full auth + role-based redirect guards.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

      // Still loading auth state — stay on splash
      if (authAsync.isLoading) {
        return state.matchedLocation == Routes.splash ? null : Routes.splash;
      }

      final user = authAsync.valueOrNull;
      final isAuthenticated = user != null;

      // ── Unauthenticated → send to role selection ──────────────────
      if (!isAuthenticated && !isPublicRoute) {
        return Routes.roleSelection;
      }

      // ── Authenticated on a public route → send to home ────────────
      if (isAuthenticated && isPublicRoute) {
        return _defaultRouteForRole(user.role);
      }

      // ── Role-based access control ─────────────────────────────────
      if (isAuthenticated) {
        final role = user.role;
        final loc = state.matchedLocation;

        // Parent-only routes: family, fraud
        if ((loc.startsWith('/family') || loc.startsWith('/fraud')) &&
            role != UserRole.parent) {
          return _defaultRouteForRole(role);
        }

        // Child-only routes: link detective, child home
        if ((loc.startsWith('/link-detective') || loc.startsWith('/home/child')) &&
            role != UserRole.child) {
          return _defaultRouteForRole(role);
        }

        // Child cannot access parent dashboard or family setup
        if ((loc.startsWith('/family') || loc == Routes.parentDashboardLegacy) &&
            role == UserRole.child) {
          return Routes.childHome;
        }
      }

      return null;
    },
    routes: [
      // ── Splash ────────────────────────────────────────────────────
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ── Auth flow ─────────────────────────────────────────────────
      GoRoute(
        path: Routes.roleSelection,
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: Routes.consent,
        builder: (context, state) {
          final role = state.extra as UserRole?;
          return ConsentScreen(role: role ?? UserRole.individual);
        },
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) {
          final role = state.extra as UserRole?;
          return LoginScreen(role: role ?? UserRole.individual);
        },
      ),
      GoRoute(
        path: Routes.pairing,
        builder: (_, __) => const PairingScreen(),
      ),

      // ── Family Setup (parent must complete before accessing family tab) ──
      GoRoute(
        path: Routes.familySetup,
        builder: (_, __) => const FamilySetupScreen(),
      ),

      // ── Primary Shell (role-gated tabs inside MainShell) ──────────
      GoRoute(
        path: Routes.guardianHome,
        builder: (_, __) => const MainShell(initialIndex: 0),
      ),

      // Guardian Safety
      GoRoute(
        path: Routes.guardianSafety,
        builder: (_, __) => const MainShell(initialIndex: 1),
      ),

      // CyberShield
      GoRoute(
        path: Routes.cyberShield,
        builder: (_, __) => const MainShell(initialIndex: 2),
      ),

      // ScamGuard (parent only)
      GoRoute(
        path: Routes.scamGuard,
        builder: (_, __) => const MainShell(initialIndex: 3),
      ),

      // Guardian Family (parent only)
      GoRoute(
        path: Routes.guardianFamily,
        builder: (_, __) => const MainShell(initialIndex: 3),
      ),

      // Guardian Identity
      GoRoute(
        path: Routes.guardianIdentity,
        builder: (_, __) => const MainShell(initialIndex: 4),
      ),

      // Child home
      GoRoute(
        path: Routes.childHome,
        builder: (_, __) => const MainShell(initialIndex: 0),
      ),

      // Link Detective (child only)
      GoRoute(
        path: Routes.linkDetective,
        builder: (_, __) => const MainShell(initialIndex: 3),
      ),

      // ── Detail screens (push, not shell tabs) ─────────────────────
      GoRoute(
        path: Routes.safeRoute,
        builder: (_, __) => const SafeRouteScreen(),
      ),
      GoRoute(
        path: Routes.qrScanner,
        builder: (_, __) => const QrScannerScreen(),
      ),
      GoRoute(
        path: Routes.permissionAuditor,
        builder: (_, __) => const PermissionAuditorScreen(),
      ),

      // ── Legacy route (backward compat for any existing deep links) ─
      GoRoute(
        path: Routes.parentDashboardLegacy,
        redirect: (_, __) => Routes.guardianFamily,
      ),
      GoRoute(
        path: Routes.cybersecurityDashboardLegacy,
        redirect: (_, __) => Routes.cyberShield,
      ),
      GoRoute(
        path: Routes.womensDashboardLegacy,
        redirect: (_, __) => Routes.guardianSafety,
      ),
    ],
  );
});

/// Route name constants — single source of truth for all navigation paths.
class Routes {
  Routes._();

  // Auth
  static const splash          = '/';
  static const onboarding      = '/onboarding';
  static const roleSelection   = '/auth/role';
  static const consent         = '/auth/consent';
  static const login           = '/auth/login';
  static const pairing         = '/auth/pairing';

  // Family setup
  static const familySetup     = '/family/setup';

  // Primary experiences (role-gated)
  static const guardianHome    = '/home';
  static const childHome       = '/home/child';
  static const guardianSafety  = '/safety';
  static const cyberShield     = '/cyber';
  static const scamGuard       = '/fraud';
  static const guardianFamily  = '/family';
  static const guardianIdentity = '/identity';
  static const linkDetective   = '/link-detective';

  // Detail screens
  static const safeRoute       = '/safety/safe-route';
  static const qrScanner       = '/cyber/qr-scanner';
  static const permissionAuditor = '/cyber/permission-auditor';
  static const settings        = '/settings';
  static const securityAuditLog = '/settings/security-log';

  // Legacy routes (redirect to new paths)
  static const parentDashboardLegacy       = '/dashboard/parent';
  static const cybersecurityDashboardLegacy = '/dashboard/cybersecurity';
  static const womensDashboardLegacy        = '/dashboard/womens';
}

/// Application-level user role. Stored in Firestore `users/{uid}.role`
/// and enforced server-side via Firestore Security Rules + Cloud Functions.
/// NEVER trust a client-declared role for privileged actions without
/// server-side re-validation.
enum UserRole { individual, parent, child, womensSafety }

extension UserRoleExt on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.individual:   return 'Individual';
      case UserRole.parent:       return 'Parent';
      case UserRole.child:        return 'Child';
      case UserRole.womensSafety: return 'Personal Safety';
    }
  }

  bool get isIndividualOrWomen =>
      this == UserRole.individual || this == UserRole.womensSafety;

  bool get isParent => this == UserRole.parent;
  bool get isChild  => this == UserRole.child;
}
