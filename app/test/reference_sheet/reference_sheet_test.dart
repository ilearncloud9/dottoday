// Design-review sheet: each component golden beside its reference render
// (docs/10 §7.1, 08 §7). Not a pass/fail test; it writes PNGs for review.
// Run: REFERENCE_SHEET=1 flutter test --tags reference-sheet
// CI uploads build/reference_sheet/ as the `reference-sheet` artifact.
@Tags(['reference-sheet'])
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'reference_entries.dart';

const _out = 'build/reference_sheet';
const _refs = '../docs/design-references/png';

/// Gutter and caption band.
const double _gap = 24;
const double _caption = 64;

void main() {
  final enabled = Platform.environment.containsKey('REFERENCE_SHEET');

  setUpAll(loadAppFonts);

  testWidgets('write the reference sheet', (tester) async {
    await tester.runAsync(() async {
      Directory(_out).createSync(recursive: true);
      final pages = <String>[];
      for (final (i, e) in sheetEntries.indexed) {
        final golden = await _decode(File(e.golden).readAsBytesSync());
        final ref = await _decode(
          File('$_refs/${e.reference}').readAsBytesSync(),
        );
        final png = await _compose(e, golden, ref);
        final file =
            '${(i + 1).toString().padLeft(2, '0')}_${_slug(e.name)}.png';
        File('$_out/$file').writeAsBytesSync(png);
        pages.add(file);
      }
      File('$_out/index.txt').writeAsStringSync('${pages.join('\n')}\n');
    });
  }, skip: !enabled);
}

Future<ui.Image> _decode(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}

/// Golden on the left, reference crop on the right, at the same pixels per
/// point: renders are 2×, so 1× goldens are drawn at double size and 2×
/// ones as they are. Equal sizes on the sheet then mean equal sizes on
/// screen.
Future<Uint8List> _compose(SheetEntry e, ui.Image golden, ui.Image ref) async {
  final gScale = e.golden.endsWith('_1x.png') ? 2.0 : 1.0;
  final gw = golden.width * gScale;
  final gh = golden.height * gScale;
  final rw = e.crop.width;
  final rh = e.crop.height;
  final size = Size(gw + _gap * 3 + rw, math.max(gh, rh) + _caption + _gap);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEDEDEA));
  _text(canvas, 'Golden — ${e.name}', const Offset(_gap, 16));
  _text(canvas, 'Reference — ${e.reference}', Offset(gw + _gap * 2, 16));
  final top = _caption;
  canvas
    ..drawImageRect(
      golden,
      Offset.zero & Size(golden.width.toDouble(), golden.height.toDouble()),
      Rect.fromLTWH(_gap, top, gw, gh),
      Paint()..filterQuality = FilterQuality.high,
    )
    ..drawImageRect(
      ref,
      e.crop,
      Rect.fromLTWH(gw + _gap * 2, top, rw, rh),
      Paint()..filterQuality = FilterQuality.high,
    );
  final image = await recorder.endRecording().toImage(
    size.width.ceil(),
    size.height.ceil(),
  );
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void _text(Canvas canvas, String text, Offset at) {
  TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1C),
        ),
      ),
      textDirection: TextDirection.ltr,
    )
    ..layout()
    ..paint(canvas, at);
}

String _slug(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_|_$'), '');
