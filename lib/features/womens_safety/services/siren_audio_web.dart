// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class SirenAudioImpl {
  static bool _isPlaying = false;

  static bool get isPlaying => _isPlaying;

  static void startSiren() {
    if (_isPlaying) return;
    _isPlaying = true;

    try {
      js.context.callMethod('eval', [r'''
        (function() {
          try {
            if (!window._sirenCtx) {
              window._sirenCtx = new (window.AudioContext || window.webkitAudioContext)();
            }
            if (window._sirenCtx.state === 'suspended') {
              window._sirenCtx.resume();
            }
            if (!window._sirenOsc) {
              var osc = window._sirenCtx.createOscillator();
              var gain = window._sirenCtx.createGain();
              osc.type = 'sawtooth';
              osc.frequency.value = 850;
              gain.gain.value = 0.5;
              osc.connect(gain);
              gain.connect(window._sirenCtx.destination);
              osc.start();
              window._sirenOsc = osc;
              window._sirenGain = gain;

              window._sirenTimer = setInterval(function() {
                if (!window._sirenOsc || !window._sirenCtx) return;
                var t = window._sirenCtx.currentTime;
                window._sirenOsc.frequency.cancelScheduledValues(t);
                window._sirenOsc.frequency.setValueAtTime(850, t);
                window._sirenOsc.frequency.linearRampToValueAtTime(1300, t + 0.3);
                window._sirenOsc.frequency.linearRampToValueAtTime(850, t + 0.6);
              }, 600);
            }
          } catch(err) {
            console.log('Siren JS error:', err);
          }
        })();
      ''']);
    } catch (e) {
      debugPrint('Web Audio Siren error: $e');
    }
  }

  static void stopSiren() {
    _isPlaying = false;
    try {
      js.context.callMethod('eval', [r'''
        (function() {
          try {
            if (window._sirenTimer) {
              clearInterval(window._sirenTimer);
              window._sirenTimer = null;
            }
            if (window._sirenOsc) {
              window._sirenOsc.stop();
              window._sirenOsc.disconnect();
              window._sirenOsc = null;
            }
          } catch(err) {}
        })();
      ''']);
    } catch (_) {}
  }
}
