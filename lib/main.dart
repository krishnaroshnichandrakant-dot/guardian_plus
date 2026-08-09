import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/security/runtime_guard.dart';
import 'shared/security/integrity_guard.dart';
import 'shared/security/key_manager.dart';
import 'shared/security/audit_logger.dart';
import 'shared/services/background_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Security: Lock orientation ─────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Security: Runtime guard (anti-debug, Frida, integrity) ─────────
  try {
    await RuntimeGuard.initialize();
  } catch (e) {
    debugPrint('RuntimeGuard init note: $e');
  }

  // ── Firebase ──────────────────────────────────────────────────────
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase init note: $e');
  }

  // ── Local encrypted storage ──────────────────────────────────────
  await Hive.initFlutter();

  // ── Key Manager (Android Keystore) ───────────────────────────────
  try {
    await KeyManager.initialize();
  } catch (e) {
    debugPrint('KeyManager init note: $e');
  }

  // ── Integrity check (root/tamper detection) ───────────────────────
  try {
    final integrityResult = await IntegrityGuard.runCheck();
    await AuditLogger.log(
      event: SecurityEvent.appStart,
      detail: 'integrity=${integrityResult.name}',
    );
  } catch (e) {
    debugPrint('IntegrityGuard check note: $e');
  }

  // ── Background foreground service ─────────────────────────────────
  try {
    await GuardianBackgroundService.initialize();
  } catch (e) {
    debugPrint('BackgroundService init note: $e');
  }

  runApp(
    const ProviderScope(
      child: GuardianPlusApp(),
    ),
  );
}

class GuardianPlusApp extends ConsumerWidget {
  const GuardianPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Guardian Plus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
