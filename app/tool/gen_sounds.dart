// Generates the bundled reminder sounds (docs/02 F6.6, plan M8.4d): short
// tones synthesised here, so Dottoday ships no third-party audio.
//
// Run from app/:  dart run tool/gen_sounds.dart
// Writes assets/sounds/reminder_<name>.wav (Apple platforms copy them to
// Library/Sounds; the web plays them in the in-app strip) and the same
// files as Android raw resources. 16-bit mono PCM WAV plays on all four
// targets. test/data/notifications/reminder_sounds_test.dart checks that
// every `ReminderSound` has both files and that they are what this writes.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Sample rate: plenty for short tones, a quarter of CD-size files.
const sampleRate = 22050;

/// A note: pitch (Hz), start and length (s), loudness 0–1.
typedef Note = ({double hz, double at, double len, double gain});

/// The sounds, by `ReminderSound` name. Pitches are plain equal-tempered
/// notes (A4 = 440 Hz), each with a soft attack and an exponential decay.
const sounds = <String, List<Note>>{
  // One soft ping (A5).
  'dot': [(hz: 880, at: 0, len: 0.9, gain: 0.6)],
  // Two notes, rising (E5 → A5).
  'chime': [
    (hz: 659.25, at: 0, len: 0.7, gain: 0.5),
    (hz: 880, at: 0.18, len: 1.0, gain: 0.5),
  ],
  // A small bell: one strike with inharmonic partials (C6).
  'bell': [
    (hz: 1046.5, at: 0, len: 1.4, gain: 0.45),
    (hz: 2510, at: 0, len: 0.6, gain: 0.12),
    (hz: 3870, at: 0, len: 0.35, gain: 0.06),
  ],
  // Three quick notes (C6 E6 G6).
  'ripple': [
    (hz: 1046.5, at: 0, len: 0.35, gain: 0.4),
    (hz: 1318.5, at: 0.11, len: 0.35, gain: 0.4),
    (hz: 1568, at: 0.22, len: 0.7, gain: 0.4),
  ],
};

const _outDirs = ['assets/sounds', 'android/app/src/main/res/raw'];

void main() {
  for (final MapEntry(key: name, value: notes) in sounds.entries) {
    final bytes = renderWav(notes);
    for (final dir in _outDirs) {
      File('$dir/reminder_$name.wav').writeAsBytesSync(bytes);
    }
    stdout.writeln('reminder_$name.wav  ${bytes.length} bytes');
  }
}

/// The WAV file for [notes]: deterministic, so a re-run is byte-identical.
Uint8List renderWav(List<Note> notes) {
  final seconds = notes.map((n) => n.at + n.len).reduce(math.max) + 0.05;
  final count = (seconds * sampleRate).ceil();
  final mix = Float64List(count);
  for (final n in notes) {
    _add(mix, n);
  }
  final peak = mix.fold<double>(0, (m, v) => math.max(m, v.abs()));
  final scale = peak > 0.9 ? 0.9 / peak : 1.0;
  final pcm = ByteData(count * 2);
  for (var i = 0; i < count; i++) {
    pcm.setInt16(i * 2, (mix[i] * scale * 32767).round(), Endian.little);
  }
  return _wav(pcm.buffer.asUint8List());
}

void _add(Float64List mix, Note n) {
  final start = (n.at * sampleRate).round();
  final length = (n.len * sampleRate).round();
  const attack = 0.006; // s, no click
  for (var i = 0; i < length && start + i < mix.length; i++) {
    final t = i / sampleRate;
    final rise = math.min(1, t / attack);
    final decay = math.exp(-5 * t / n.len);
    final tail = math.min(1, (length - i) / (0.01 * sampleRate));
    mix[start + i] +=
        n.gain * rise * decay * tail * math.sin(2 * math.pi * n.hz * t);
  }
}

Uint8List _wav(Uint8List pcm) {
  final header = ByteData(44);
  void ascii(int at, String s) {
    for (var i = 0; i < s.length; i++) {
      header.setUint8(at + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  header.setUint32(4, 36 + pcm.length, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  header
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // mono
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, sampleRate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  header.setUint32(40, pcm.length, Endian.little);
  return Uint8List.fromList([...header.buffer.asUint8List(), ...pcm]);
}
