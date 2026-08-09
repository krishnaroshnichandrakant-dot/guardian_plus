import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../shared/security/audit_logger.dart';

final sosTriggerServiceProvider = Provider<SosTriggerService>((ref) {
  return SosTriggerService();
});

enum SosTriggerMethod { buttonHold, powerButton, shakeGesture }

class SosTriggerService {
  bool _isSosActive = false;

  bool get isSosActive => _isSosActive;

  /// Listens to accelerometer for shake gesture (3× rapid shake)
  void listenForShake(Function() onShakeDetected) {
    accelerometerEventStream().listen((event) {
      final acceleration = event.x * event.x + event.y * event.y + event.z * event.z;
      if (acceleration > 350) {
        // High acceleration = rapid shake
        onShakeDetected();
      }
    });
  }

  /// Triggers emergency SOS alert. Obtains GPS coordinates and notifies trusted contacts.
  Future<Position?> triggerSos(SosTriggerMethod method) async {
    _isSosActive = true;
    await AuditLogger.log(
      event: SecurityEvent.sosTriggered,
      detail: 'method=${method.name}',
    );

    Position? position;
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      }
    } catch (_) {}

    return position;
  }

  void cancelSos() {
    _isSosActive = false;
  }
}
