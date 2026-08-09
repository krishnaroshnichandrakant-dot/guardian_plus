import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationShareServiceProvider = Provider<LocationShareService>((ref) {
  return LocationShareService();
});

class LocationShareSession {
  const LocationShareSession({
    required this.sessionId,
    required this.startedAt,
    required this.duration,
    required this.active,
  });

  final String sessionId;
  final DateTime startedAt;
  final Duration duration;
  final bool active;

  DateTime get expiresAt => startedAt.add(duration);
}

class LocationShareService {
  LocationShareSession? _currentSession;
  Timer? _expirationTimer;

  LocationShareSession? get currentSession => _currentSession;

  /// Starts a time-boxed live location sharing session
  LocationShareSession startSharing(Duration duration) {
    _expirationTimer?.cancel();
    _currentSession = LocationShareSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      startedAt: DateTime.now(),
      duration: duration,
      active: true,
    );

    _expirationTimer = Timer(duration, () {
      stopSharing();
    });

    return _currentSession!;
  }

  void stopSharing() {
    _expirationTimer?.cancel();
    _currentSession = null;
  }
}
