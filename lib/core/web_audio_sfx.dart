import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:math' as math;

class WebAudioSfx {
  Object? _ctx;

  Object? _ensure() {
    _ctx ??= _newAudioContext();
    return _ctx;
  }

  void tick() => _beep(freqHz: 880, ms: 28, gain: 0.03);

  void win() {
    _beep(freqHz: 523, ms: 90, gain: 0.05);
    Timer(const Duration(milliseconds: 110), () {
      _beep(freqHz: 659, ms: 110, gain: 0.05);
    });
  }

  Object? _newAudioContext() {
    try {
      final ctor = js_util.getProperty<Object?>(html.window, 'AudioContext');
      if (ctor != null) {
        return js_util.callConstructor<Object>(ctor, const []);
      }
      final webkit = js_util.getProperty<Object?>(html.window, 'webkitAudioContext');
      if (webkit != null) {
        return js_util.callConstructor<Object>(webkit, const []);
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  void _beep({
    required num freqHz,
    required int ms,
    required num gain,
  }) {
    final ctx = _ensure();
    if (ctx == null) return;

    try {
      final now = (js_util.getProperty(ctx, 'currentTime') as num?) ?? 0;
      final osc = js_util.callMethod<Object>(ctx, 'createOscillator', const []);
      final g = js_util.callMethod<Object>(ctx, 'createGain', const []);
      final dest = js_util.getProperty<Object>(ctx, 'destination');

      js_util.setProperty(osc, 'type', 'sine');

      final freqParam = js_util.getProperty<Object?>(osc, 'frequency');
      if (freqParam != null) {
        js_util.callMethod(freqParam, 'setValueAtTime', [freqHz, now]);
      }

      final gainParam = js_util.getProperty<Object?>(g, 'gain');
      if (gainParam != null) {
        js_util.callMethod(gainParam, 'setValueAtTime', [0, now]);
        js_util.callMethod(gainParam, 'linearRampToValueAtTime', [gain, now + 0.005]);
        js_util.callMethod(gainParam, 'exponentialRampToValueAtTime', [
          math.max(0.0001, gain / 25),
          now + (ms / 1000.0),
        ]);
      }

      js_util.callMethod(osc, 'connect', [g]);
      js_util.callMethod(g, 'connect', [dest]);

      js_util.callMethod(osc, 'start', [now]);
      js_util.callMethod(osc, 'stop', [now + (ms / 1000.0) + 0.02]);
    } catch (e) {
      print('[WebAudioSfx] beep failed: $e');
    }
  }
}
