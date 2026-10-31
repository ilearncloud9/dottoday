import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

// docs/15-alarms.md: AlarmKit plays only sounds in the app bundle, so every
// catalogue sound — the first-party tones too — has a `.caf` in the iOS
// Runner target (tool/xcode_add_sounds.rb; build.py writes the files). And
// iOS plays the default sound instead of one that is over 30 s or not a
// format it takes, so each file is IMA4, mono, 44.1 kHz (docs/12 §4, §5).
void main() {
  final manifest =
      jsonDecode(File('assets/sounds/manifest.json').readAsStringSync())
          as Map<String, Object?>;
  final files = [
    for (final s in (manifest['sounds']! as List).cast<Map<String, Object?>>())
      '${s['file']}.caf',
  ];

  test('every catalogue sound is a .caf resource of the iOS Runner', () {
    final pbxproj = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();
    for (final name in files) {
      expect(
        File('ios/Runner/Sounds/$name').existsSync(),
        isTrue,
        reason: '$name: run tool/sounds/build.py',
      );
      expect(
        pbxproj,
        contains('/* $name in Resources */'),
        reason: '$name: run tool/xcode_add_sounds.rb',
      );
    }
  });

  test('every bundled .caf is IMA4, mono, 44.1 kHz and under 30 s', () {
    final cafs = Directory(
      'ios/Runner/Sounds',
    ).listSync().whereType<File>().where((f) => f.path.endsWith('.caf'));
    expect(cafs, isNotEmpty);
    for (final f in cafs) {
      final caf = _CafInfo.read(f.readAsBytesSync());
      final name = f.uri.pathSegments.last;
      expect(caf.format, 'ima4', reason: name);
      expect(caf.channels, 1, reason: name);
      expect(caf.sampleRate, 44100, reason: name);
      expect(caf.seconds, lessThan(30), reason: name);
    }
  });
}

/// The few header fields of a Core Audio Format file the OS checks.
final class _CafInfo {
  _CafInfo(this.sampleRate, this.format, this.channels, this.seconds);

  /// Reads the `desc` chunk, and the length from `pakt` (valid frames) or,
  /// for a constant-rate file without one, from the `data` size.
  factory _CafInfo.read(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    expect(ascii.decode(bytes.sublist(0, 4)), 'caff');
    double? rate;
    String? format;
    int? channels, bytesPerPacket, framesPerPacket, frames, dataBytes;
    var at = 8;
    while (at + 12 <= bytes.length) {
      final type = ascii.decode(bytes.sublist(at, at + 4));
      final size = data.getInt64(at + 4);
      final body = at + 12;
      switch (type) {
        case 'desc':
          rate = data.getFloat64(body);
          format = ascii.decode(bytes.sublist(body + 8, body + 12));
          bytesPerPacket = data.getUint32(body + 16);
          framesPerPacket = data.getUint32(body + 20);
          channels = data.getUint32(body + 24);
        case 'pakt':
          frames = data.getInt64(body + 8);
        case 'data':
          // -1: the data chunk runs to the end of the file; 4 = edit count.
          dataBytes = (size < 0 ? bytes.length - body : size) - 4;
      }
      if (size < 0) break;
      at = body + size;
    }
    frames ??= dataBytes! ~/ bytesPerPacket! * framesPerPacket!;
    return _CafInfo(rate!, format!, channels!, frames / rate);
  }

  final double sampleRate;
  final String format;
  final int channels;
  final double seconds;
}
