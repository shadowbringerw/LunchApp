import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';

class WebAudioSfx {
  _AudioPool? _tick;
  _AudioPool? _winLow;
  _AudioPool? _winHigh;

  void tick() {
    (_tick ??= _AudioPool(_wavDataUrl(freqHz: 880, ms: 28, gain: 0.10))).play();
  }

  void win() {
    (_winLow ??= _AudioPool(_wavDataUrl(freqHz: 523, ms: 90, gain: 0.12))).play();
    Timer(const Duration(milliseconds: 110), () {
      (_winHigh ??= _AudioPool(_wavDataUrl(freqHz: 659, ms: 110, gain: 0.12)))
          .play();
    });
  }
}

class _AudioPool {
  _AudioPool(this.url, {this.size = 4})
      : _players = List.generate(size, (_) => html.AudioElement(url));

  final String url;
  final int size;
  final List<html.AudioElement> _players;
  int _idx = 0;

  void play() {
    final player = _players[_idx];
    _idx = (_idx + 1) % _players.length;
    try {
      player.currentTime = 0;
      unawaited(player.play());
    } catch (_) {
      // Ignore autoplay / timing issues.
    }
  }
}

String _wavDataUrl({
  required num freqHz,
  required int ms,
  required num gain,
}) {
  const sampleRate = 44100;
  final samples = (sampleRate * ms / 1000).clamp(1, 1 << 31).toInt();

  final attackSamples = (sampleRate * 0.010).round().clamp(1, samples);
  final releaseSamples = (sampleRate * 0.020).round().clamp(1, samples);

  final pcm = BytesBuilder(copy: false);
  for (int i = 0; i < samples; i++) {
    final t = i / sampleRate;

    final attack = math.min(1.0, i / attackSamples);
    final release = math.min(1.0, (samples - i) / releaseSamples);
    final env = attack * release;

    final v = math.sin(2 * math.pi * freqHz * t) * gain * env;
    final s = (v * 32767).round().clamp(-32768, 32767);
    pcm.addByte(s & 0xFF);
    pcm.addByte((s >> 8) & 0xFF);
  }

  final pcmBytes = pcm.toBytes();
  final bytes = BytesBuilder(copy: false);

  void u32(int v) {
    bytes.addByte(v & 0xFF);
    bytes.addByte((v >> 8) & 0xFF);
    bytes.addByte((v >> 16) & 0xFF);
    bytes.addByte((v >> 24) & 0xFF);
  }

  void u16(int v) {
    bytes.addByte(v & 0xFF);
    bytes.addByte((v >> 8) & 0xFF);
  }

  bytes.add(ascii.encode('RIFF'));
  u32(36 + pcmBytes.length);
  bytes.add(ascii.encode('WAVE'));

  bytes.add(ascii.encode('fmt '));
  u32(16); // PCM
  u16(1); // AudioFormat
  u16(1); // NumChannels
  u32(sampleRate);
  u32(sampleRate * 2); // ByteRate = sampleRate * blockAlign
  u16(2); // BlockAlign = channels * bytesPerSample
  u16(16); // BitsPerSample

  bytes.add(ascii.encode('data'));
  u32(pcmBytes.length);
  bytes.add(pcmBytes);

  final wav = bytes.takeBytes();
  return 'data:audio/wav;base64,${base64Encode(Uint8List.fromList(wav))}';
}
