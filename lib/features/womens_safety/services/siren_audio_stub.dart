import 'package:flutter/foundation.dart';

class SirenAudioImpl {
  static bool _isPlaying = false;
  static bool get isPlaying => _isPlaying;

  static void startSiren() {
    _isPlaying = true;
    debugPrint('Siren audio started (Native platform mode)');
  }

  static void stopSiren() {
    _isPlaying = false;
    debugPrint('Siren audio stopped (Native platform mode)');
  }
}
