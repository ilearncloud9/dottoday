import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

// docs/12-sounds.md §1, §5, §7: the manifest is the provenance record of
// every bundled sound. Nothing ships without an entry, no third-party entry
// lacks its source page and an allowed licence, every credited source is
// in CREDITS.md, and no sound is a duplicate of another (owner, phase 1:
// unique ids, names and file contents), and each category keeps its length
// and loudness (owner's levelling rule, mirrored from tool/sounds/build.py).
// The Sounds-screen footer is checked once its string exists (phase 4).
const _allowedLicenses = {'CC0-1.0', 'CC-BY-4.0'};
const _categories = {'dottoday', 'quiet', 'clear', 'start', 'play', 'done'};

/// Per category: (loudness target LUFS, shortest ms, longest ms).
const _rules = {
  'quiet': (lufs: -20.0, minMs: 1, maxMs: 1500),
  'clear': (lufs: -16.0, minMs: 1, maxMs: 4000),
  'play': (lufs: -16.0, minMs: 1, maxMs: 4000),
  'done': (lufs: -16.0, minMs: 1, maxMs: 4000),
  'start': (lufs: -14.0, minMs: 3000, maxMs: 20000),
};

/// Within a category, every built sound stays this close to its target.
const _spreadLu = 3.0;

/// Changes beyond the source-wide ones, recorded per entry for CC BY.
const _extraModifications = {'looped'};

/// Where the build puts each third-party sound (tool/sounds/build.py).
const _shippedDirs = [
  'assets/sounds',
  'android/app/src/main/res/raw',
  'ios/Runner/Sounds',
];

final _manifest =
    jsonDecode(File('assets/sounds/manifest.json').readAsStringSync())
        as Map<String, Object?>;
final _sources = (_manifest['sources']! as Map)
    .cast<String, Map<String, Object?>>();
final _sounds = (_manifest['sounds']! as List).cast<Map<String, Object?>>();
final _byFile = {for (final s in _sounds) s['file']! as String: s};

bool _isFirstParty(Map<String, Object?> s) => s['source'] == 'dottoday';

List<File> _soundFiles(String dir) => [
  for (final f in Directory(dir).listSync().whereType<File>())
    // Not sounds: the manifest, keep.xml, and dotfiles (.gitkeep).
    if (!f.path.endsWith('.json') &&
        !f.path.endsWith('.xml') &&
        !f.uri.pathSegments.last.startsWith('.'))
      f,
];

String _base(File f) {
  final name = f.uri.pathSegments.last;
  return name.substring(0, name.lastIndexOf('.'));
}

void main() {
  test('every shipped sound file has a manifest entry', () {
    for (final dir in _shippedDirs) {
      for (final f in _soundFiles(dir)) {
        expect(_byFile, contains(_base(f)), reason: '${f.path}: no entry');
      }
    }
  });

  test('every third-party entry is built for all three targets', () {
    for (final s in _sounds.where((s) => !_isFirstParty(s))) {
      final file = s['file']! as String;
      for (final path in [
        'assets/sounds/$file.m4a',
        'android/app/src/main/res/raw/$file.m4a',
        'ios/Runner/Sounds/$file.caf',
      ]) {
        expect(File(path).existsSync(), isTrue, reason: '$path: run build.py');
      }
    }
  });

  test('third-party entries name their source page and an allowed licence', () {
    for (final s in _sounds.where((s) => !_isFirstParty(s))) {
      final id = s['id'];
      final source = _sources[s['source']];
      expect(source, isNotNull, reason: '$id: unknown source');
      expect(_allowedLicenses, contains(s['license']), reason: '$id');
      expect(s['license'], source!['license'], reason: '$id: source licence');
      final modified = s['modified'];
      expect(
        modified == true || _extraModifications.contains(modified),
        isTrue,
        reason: '$id: modified is true or one of $_extraModifications',
      );
      expect(source['modified'], isTrue, reason: '$id');
      // build.py loops only what the manifest says, and says so.
      expect(s.containsKey('loopToMs'), modified == 'looped', reason: '$id');
      for (final key in ['sourceUrl', 'fileUrl']) {
        final url = Uri.parse(s[key]! as String);
        expect(url.scheme, 'https', reason: '$id $key');
        expect(url.host, Uri.parse(source['url'] as String).host);
      }
      expect(s['sourceTitle'], isA<String>(), reason: '$id');
    }
  });

  test('first-party entries are ours: no source page, no credit', () {
    expect(_sources['dottoday']?['credit'], isFalse);
    for (final s in _sounds.where(_isFirstParty)) {
      expect(s.containsKey('sourceUrl'), isFalse, reason: '${s['id']}');
      expect(s['license'], 'first-party');
    }
  });

  test('ids, names and files are unique and well formed', () {
    final ids = _sounds.map((s) => s['id']! as String).toList();
    final names = _sounds.map((s) => (s['name']! as String).toLowerCase());
    expect(ids.toSet(), hasLength(ids.length), reason: 'duplicate id');
    expect(names.toSet(), hasLength(ids.length), reason: 'duplicate name');
    expect(_byFile, hasLength(ids.length), reason: 'duplicate file');
    for (final s in _sounds) {
      final id = s['id']! as String;
      expect(_categories, contains(s['category']), reason: id);
      // Android raw resource names: lower-case letter, then [a-z0-9_].
      expect(s['file'], matches(RegExp(r'^[a-z][a-z0-9_]*$')), reason: id);
      if (!_isFirstParty(s)) {
        expect(id, '${s['category']}.${id.split('.').last}');
        expect(s['file'], id.replaceAll('.', '_'), reason: id);
      }
    }
  });

  test('no two sound files have the same content', () {
    for (final dir in _shippedDirs) {
      final seen = <String, String>{};
      for (final f in _soundFiles(dir)) {
        final hash = sha256.convert(f.readAsBytesSync()).toString();
        expect(seen[hash], isNull, reason: '${f.path} == ${seen[hash]}');
        seen[hash] = f.path;
      }
    }
  });

  test('durations fit the category and the OS limits', () {
    for (final s in _sounds) {
      final id = s['id'];
      final ms = s['durationMs'];
      expect(ms, isA<int>(), reason: '$id: run build.py');
      // iOS plays the default sound instead of one longer than 30 s.
      expect(ms! as int, inInclusiveRange(1, 30000), reason: '$id');
      final rule = _rules[s['category']];
      if (rule == null || _isFirstParty(s)) continue;
      expect(ms, inInclusiveRange(rule.minMs, rule.maxMs), reason: '$id');
    }
  });

  test('every built sound is within ±3 LU of its category target', () {
    for (final s in _sounds.where((s) => !_isFirstParty(s))) {
      final id = s['id'];
      final lufs = s['loudnessLufs'];
      final peak = s['truePeakDbtp'];
      expect(lufs, isA<num>(), reason: '$id: run build.py');
      expect(peak, isA<num>(), reason: '$id: run build.py');
      final target = _rules[s['category']]!.lufs;
      final within = ((lufs! as num) - target).abs() <= _spreadLu;
      // loudnessAccepted: kept by the owner in the ear pass despite the
      // spread (2026-10-28, docs/12 §5). It must still be needed.
      expect(
        within,
        s['loudnessAccepted'] != true,
        reason: within
            ? '$id: within ±3 LU now; drop loudnessAccepted'
            : '$id: a quiet outlier for the ear pass (build.py lists them)',
      );
      // The limiter's ceiling; the manifest rounds to 0.1 dB.
      expect((peak! as num).toDouble(), lessThanOrEqualTo(-0.9), reason: '$id');
    }
  });

  test('every credited source is in the notice and in CREDITS.md', () {
    final credits = File('../CREDITS.md').readAsStringSync();
    for (final MapEntry(key: key, value: source) in _sources.entries) {
      if (source['credit'] != true) continue;
      final notice = source['notice'] as String;
      expect(notice, contains(source['name']), reason: key);
      // CC BY: the licence and that the files were changed (docs/12 §1).
      if (source['license'] == 'CC-BY-4.0') {
        expect(notice, contains('creativecommons.org/licenses/by/4.0'));
      }
      if (source['modified'] == true) {
        expect(notice, contains('trimmed'), reason: key);
        expect(notice, contains('loudness-normalised'), reason: key);
      }
      for (final extra in _extraModifications) {
        if (_sounds.any((s) => s['source'] == key && s['modified'] == extra)) {
          expect(notice, contains(extra), reason: '$key: $extra');
        }
      }
      expect(credits, contains(notice), reason: 'run tool/sounds/credits.py');
      for (final s in _sounds.where((s) => s['source'] == key)) {
        expect(credits, contains('<${s['sourceUrl']}>'), reason: '${s['id']}');
      }
    }
  });

  test('Android keeps every category prefix through resource shrinking', () {
    final keep = File(
      'android/app/src/main/res/raw/keep.xml',
    ).readAsStringSync();
    for (final category in _categories.difference({'dottoday'})) {
      expect(keep, contains('@raw/${category}_*'), reason: category);
    }
  });
}
