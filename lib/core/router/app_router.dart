import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/consent_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/pairing_screen.dart';
import '../../features/shared/screens/main_shell.dart';
import '../../features/cybersecurity/screens/cybersecurity_dashboard.dart';
import '../../features/cybersecurity/screens/qr_scanner_screen.dart';
import '../../features/cybersecurity/screens/permission_auditor_screen.dart';
import '../../features/parental/screens/parent_dashboard.dart';
import '../../features/womens_safety/screens/womens_dashboard.dart';

/// Direct-access GoRouter with login bypass enabled.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.cybersecurityDashboard,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // Login requirement explicitly bypassed — user has direct access
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const MainShell(initialIndex: 0),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const MainShell(initialIndex: 0),
      ),

      // Auth flow (accessible if explicitly pushed, but bypasses login requirement)
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
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
        ],
      ),

      // Primary Dashboards wrapped in MainShell for 1-tap navigation
      GoRoute(
        path: Routes.cybersecurityDashboard,
        builder: (_, __) => const MainShell(initialIndex: 0),
      ),
      GoRoute(
        path: Routes.parentDashboard,
        builder: (_, __) => const MainShell(initialIndex: 1),
      ),
      GoRoute(
        path: Routes.womensDashboard,
        builder: (_, __) => const MainShell(initialIndex: 2),
      ),
      GoRoute(
        path: Routes.permissionAuditor,
        builder: (_, __) => const MainShell(initialIndex: 3),
      ),
      GoRoute(
        path: Routes.qrScanner,
        builder: (_, __) => const QrScannerScreen(),
      ),
    ],
  );
});

/// Route name constants — single source of truth for all navigation paths.
class Routes {
  Routes._();
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const roleSelection = '/auth/role';
  static const consent = '/auth/consent';
  static const login = '/auth/login';
  static const pairing = '/auth/pairing';
  static const cybersecurityDashboard = '/dashboard/cybersecurity';
  static const qrScanner = '/cybersecurity/qr-scanner';
  static const permissionAuditor = '/cybersecurity/permission-auditor';
  static const parentDashboard = '/dashboard/parent';
  static const womensDashboard = '/dashboard/womens';
  static const settings = '/settings';
  static const securityAuditLog = '/settings/security-log';
}

enum UserRole { individual, parent, child, womensSafety }
