import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The pixels under the `RepaintBoundary` keyed [boundary] as a PNG, at
/// [pixelRatio] — the share images of the weekly review and the year strip
/// (11 D1, D3) are exactly what the screen shows. Null when it isn't on
/// screen.
Future<Uint8List?> captureImage(
  GlobalKey boundary, {
  double pixelRatio = 3,
}) async {
  final box = boundary.currentContext?.findRenderObject();
  if (box is! RenderRepaintBoundary) return null;
  final image = await box.toImage(pixelRatio: pixelRatio);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
