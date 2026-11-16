import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/gen_app_icons.dart' as gen;
import '../../tool/icons/raster.dart';

// App icons and launch marks (docs/09 M8.6): every file is what
// tool/gen_app_icons.dart draws, in the Concept A colours, and every
// platform manifest names files that exist.

void main() {
  for (final job in gen.iconJobs()) {
    test('${job.path} matches the generator', () {
      final file = File(job.path);
      expect(file.existsSync(), isTrue, reason: 'run the generator');
      final png = decodePng(file.readAsBytesSync());
      final opaque = job.kind == gen.IconKind.fullBleed;
      expect(png.size, job.size);
      expect(png.opaque, opaque);
      expect(
        png.pixels,
        gen.drawIcon(job).bytes(opaque: opaque),
        reason: '${job.path} is stale: dart run tool/gen_app_icons.dart',
      );
    });
  }

  // The icon and launch colours stay the shipped brand until the brand
  // rollout (plan M22.4), so they are no longer tied to `DotPrimitives`.
  test('the platform launch colours match the generator', () {
    final accent = gen.accentHex();
    final day = File(
      'android/app/src/main/res/values/colors.xml',
    ).readAsStringSync();
    final night = File(
      'android/app/src/main/res/values-night/colors.xml',
    ).readAsStringSync();
    expect(day, contains('"ic_launcher_background">${accent.light}<'));
    expect(day, contains('"launch_background">${gen.paperHex}<'));
    expect(night, contains('"launch_background">${gen.nightHex}<'));
    expect(
      File('web/manifest.json').readAsStringSync(),
      contains('"background_color": "${gen.paperHex}"'),
    );
  });

  test('the App Store icon has no alpha channel', () {
    final job = gen.iconJobs().firstWhere((j) => j.size == 1024);
    expect(job.path, contains('ios/'));
    expect(decodePng(File(job.path).readAsBytesSync()).opaque, isTrue);
  });

  for (final dir in [
    'ios/Runner/Assets.xcassets/AppIcon.appiconset',
    'ios/Runner/Assets.xcassets/LaunchImage.imageset',
    'macos/Runner/Assets.xcassets/AppIcon.appiconset',
  ]) {
    test('$dir lists only generated files', () {
      final contents =
          jsonDecode(File('$dir/Contents.json').readAsStringSync())
              as Map<String, Object?>;
      final names = {
        for (final i
            in (contents['images']! as List).cast<Map<String, Object?>>())
          i['filename'] as String,
      };
      final generated = {
        for (final j in gen.iconJobs())
          if (j.path.startsWith(dir)) j.path.split('/').last,
      };
      expect(names, generated);
    });
  }

  test('Android uses the adaptive icon and its own splash', () {
    const res = 'android/app/src/main/res';
    final adaptive = File(
      '$res/mipmap-anydpi-v26/ic_launcher.xml',
    ).readAsStringSync();
    expect(adaptive, contains('@mipmap/ic_launcher_foreground'));
    expect(adaptive, contains('<monochrome'));
    for (final v in ['values-v31', 'values-night-v31']) {
      final styles = File('$res/$v/styles.xml').readAsStringSync();
      expect(
        styles,
        contains('windowSplashScreenAnimatedIcon">@drawable/splash_mark'),
      );
    }
    for (final d in ['drawable', 'drawable-v21']) {
      expect(
        File('$res/$d/launch_background.xml').readAsStringSync(),
        contains('@drawable/splash_mark'),
      );
    }
  });
}
