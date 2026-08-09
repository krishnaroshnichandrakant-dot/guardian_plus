import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// Guardian Plus Background Service
/// Compliance requirement: §5 of the spec — persistent, non-dismissible
/// monitoring notification on any monitored (child) device.
///
/// This foreground service:
///   • Starts on device boot
///   • Posts a sticky notification that CANNOT be dismissed by the user
///   • Cannot be killed by the user from notification panel
///   • Required for Play Store stalkerware policy compliance
///   • The notification is transparent — it tells the child monitoring is active
/// ══════════════════════════════════════════════════════════════════════════
class GuardianBackgroundService {
  GuardianBackgroundService._();

  static const _notificationChannelId = 'gp_monitoring_channel';
  static const _notificationId = 1001;

  static final _notifications = FlutterLocalNotificationsPlugin();
  static final _service = FlutterBackgroundService();

  // ── Initialization ────────────────────────────────────────────────

  static Future<void> initialize() async {
    await _initializeNotifications();
    await _configureService();
  }

  static Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Create a high-importance channel that cannot be dismissed
    const androidChannel = AndroidNotificationChannel(
      _notificationChannelId,
      'Guardian Plus Monitoring',
      description: 'Guardian Plus parental monitoring is active on this device.',
      importance: Importance.low, // Low importance: no sound, but cannot be hidden
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  static Future<void> _configureService() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onServiceStart,
        autoStart: true,           // Starts on boot
        isForegroundMode: true,    // Foreground = persistent, non-dismissible
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'Guardian Plus is Active',
        initialNotificationContent:
            'Parental monitoring is enabled on this device.',
        foregroundServiceNotificationId: _notificationId,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
        autoStartOnBoot: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: _onServiceStart,
        onBackground: _iosBackground,
      ),
    );

    await _service.startService();
  }

  // ── Service entrypoint (runs in isolate) ──────────────────────────

  @pragma('vm:entry-point')
  static Future<void> _onServiceStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    // Update notification content periodically (heartbeat)
    Timer.periodic(const Duration(minutes: 5), (_) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Guardian Plus is Active',
          content:
              'Parental monitoring is enabled. Last checked: ${_timeString()}',
        );
      }
    });

    // Listen for stop commands from the parent app (triggers unpairing flow)
    service.on('stopMonitoring').listen((_) {
      // Do NOT silently stop — require explicit unpairing confirmation
      // Handled by the unpairing flow in features/parental/
    });

    service.on('updateStatus').listen((data) {
      if (data != null && service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Guardian Plus is Active',
          content: data['message'] as String? ??
              'Parental monitoring is enabled on this device.',
        );
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> _iosBackground(ServiceInstance service) async {
    return true;
  }

  static String _timeString() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  // ── Control methods ───────────────────────────────────────────────

  static Future<bool> isRunning() => _service.isRunning();

  static Future<void> updateNotificationMessage(String message) async {
    _service.invoke('updateStatus', {'message': message});
  }
}
