import 'siren_audio_stub.dart' if (dart.library.html) 'siren_audio_web.dart';

/// Cross-platform audible emergency distress siren synthesizer service.
/// Uses Web Audio API oscillator frequency sweep on Web for authentic loud alarm sound.
class SirenAudioService {
  SirenAudioService._();

  static bool get isPlaying => SirenAudioImpl.isPlaying;

  static void startSiren() {
    SirenAudioImpl.startSiren();
  }

  static void stopSiren() {
    SirenAudioImpl.stopSiren();
  }

  static void toggleSiren() {
    if (isPlaying) {
      stopSiren();
    } else {
      startSiren();
    }
  }
}
