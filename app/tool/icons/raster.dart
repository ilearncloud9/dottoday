// A tiny anti-aliased rasteriser and PNG codec for tool/gen_app_icons.dart:
// shapes are signed distance functions in pixels, coverage is analytic
// (half a pixel either side of the edge). Pure Dart (dart:io's zlib), so
// the icons need no image package and no design tool (docs/09 M8.6).
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// A straight (not premultiplied) colour, channels 0–1.
typedef Rgba = ({double r, double g, double b, double a});

/// [hex] like `#3B6CF6` with alpha [a].
Rgba rgb(String hex, [double a = 1]) {
  final v = int.parse(hex.replaceFirst('#', ''), radix: 16);
  return (
    r: (v >> 16 & 0xFF) / 255,
    g: (v >> 8 & 0xFF) / 255,
    b: (v & 0xFF) / 255,
    a: a,
  );
}

/// Signed distance in pixels from (x, y) to a shape: negative inside.
typedef Sdf = double Function(double x, double y);

/// A square RGBA canvas, premultiplied while painting.
final class Raster {
  Raster(this.size) : _px = Float64List(size * size * 4);

  final int size;
  final Float64List _px;

  /// Paints [shape] in [colour] over what is there ("source over").
  void fill(Sdf shape, Rgba colour) {
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final cover = (0.5 - shape(x + 0.5, y + 0.5)).clamp(0.0, 1.0);
        if (cover > 0) _over(x, y, colour, cover * colour.a);
      }
    }
  }

  /// Paints a soft shadow: [alpha] inside [shape], fading to 0 over [blur] px.
  void shadow(Sdf shape, Rgba colour, double blur) {
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final t = (shape(x + 0.5, y + 0.5) / blur).clamp(0.0, 1.0);
        final a = colour.a * (1 - t) * (1 - t);
        if (a > 0) _over(x, y, colour, a);
      }
    }
  }

  void _over(int x, int y, Rgba c, double a) {
    final i = (y * size + x) * 4;
    final keep = 1 - a;
    _px[i] = c.r * a + _px[i] * keep;
    _px[i + 1] = c.g * a + _px[i + 1] * keep;
    _px[i + 2] = c.b * a + _px[i + 2] * keep;
    _px[i + 3] = a + _px[i + 3] * keep;
  }

  /// 8-bit straight RGBA (or RGB when [opaque]), row by row.
  Uint8List bytes({bool opaque = false}) {
    final channels = opaque ? 3 : 4;
    final out = Uint8List(size * size * channels);
    for (var p = 0; p < size * size; p++) {
      final a = _px[p * 4 + 3];
      for (var c = 0; c < 3; c++) {
        final v = a == 0 ? 0.0 : _px[p * 4 + c] / (opaque ? 1 : a);
        out[p * channels + c] = (v * 255).round().clamp(0, 255);
      }
      if (!opaque) out[p * 4 + 3] = (a * 255).round().clamp(0, 255);
    }
    return out;
  }
}

/// Circle of radius [r] at ([cx], [cy]).
Sdf circle(double cx, double cy, double r) =>
    (x, y) => math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy)) - r;

/// Ring of centre-line radius [r] and stroke [w].
Sdf ring(double cx, double cy, double r, double w) =>
    (x, y) => (circle(cx, cy, r)(x, y)).abs() - w / 2;

/// Arc of a ring from 12 o'clock clockwise through [turns] (0–1), with
/// round caps.
Sdf arc(double cx, double cy, double r, double w, double turns) {
  final sweep = turns * 2 * math.pi;
  final ex = cx + r * math.sin(sweep), ey = cy - r * math.cos(sweep);
  return (x, y) {
    final dx = x - cx, dy = y - cy;
    var angle = math.atan2(dx, -dy);
    if (angle < 0) angle += 2 * math.pi;
    if (angle <= sweep) return (math.sqrt(dx * dx + dy * dy) - r).abs() - w / 2;
    final toStart = math.sqrt(dx * dx + (y - (cy - r)) * (y - (cy - r)));
    final toEnd = math.sqrt((x - ex) * (x - ex) + (y - ey) * (y - ey));
    return math.min(toStart, toEnd) - w / 2;
  };
}

/// Rounded square of side [side] and corner [radius], centred.
Sdf roundedSquare(double cx, double cy, double side, double radius) => (x, y) {
  final qx = (x - cx).abs() - (side / 2 - radius);
  final qy = (y - cy).abs() - (side / 2 - radius);
  final ox = math.max(qx, 0.0), oy = math.max(qy, 0.0);
  return math.sqrt(ox * ox + oy * oy) +
      math.min(math.max(qx, qy), 0.0) -
      radius;
};

/// The whole canvas.
Sdf everywhere() =>
    (_, _) => -1e9;

/// PNG of [pixels] (`Raster.bytes`): 8-bit, filter 0 on every row.
Uint8List encodePng(int size, Uint8List pixels, {bool opaque = false}) {
  final channels = opaque ? 3 : 4;
  final raw = BytesBuilder();
  for (var y = 0; y < size; y++) {
    raw
      ..addByte(0)
      ..add(pixels.sublist(y * size * channels, (y + 1) * size * channels));
  }
  final header = ByteData(13)
    ..setUint32(0, size)
    ..setUint32(4, size)
    ..setUint8(8, 8)
    ..setUint8(9, opaque ? 2 : 6);
  return (BytesBuilder()
        ..add(const [137, 80, 78, 71, 13, 10, 26, 10])
        ..add(_chunk('IHDR', header.buffer.asUint8List()))
        ..add(_chunk('IDAT', ZLibCodec(level: 9).encode(raw.takeBytes())))
        ..add(_chunk('IEND', Uint8List(0))))
      .takeBytes();
}

/// Size, colour type and pixels of a PNG this file wrote (tests compare
/// pixels, not compressed bytes, so a zlib update can't fail them).
({int size, bool opaque, Uint8List pixels}) decodePng(Uint8List png) {
  final data = ByteData.sublistView(png);
  var at = 8, size = 0, opaque = false;
  final idat = BytesBuilder();
  while (at < png.length) {
    final length = data.getUint32(at);
    final type = String.fromCharCodes(png.sublist(at + 4, at + 8));
    final body = png.sublist(at + 8, at + 8 + length);
    if (type == 'IHDR') {
      size = ByteData.sublistView(body).getUint32(0);
      opaque = body[9] == 2;
    }
    if (type == 'IDAT') idat.add(body);
    at += 12 + length;
  }
  final raw = ZLibCodec().decode(idat.takeBytes());
  final row = size * (opaque ? 3 : 4);
  final pixels = BytesBuilder();
  for (var y = 0; y < size; y++) {
    pixels.add(raw.sublist(y * (row + 1) + 1, (y + 1) * (row + 1)));
  }
  return (size: size, opaque: opaque, pixels: pixels.takeBytes());
}

Uint8List _chunk(String type, List<int> body) {
  final typed = [...type.codeUnits, ...body];
  final out = ByteData(12 + body.length)..setUint32(0, body.length);
  final bytes = out.buffer.asUint8List()..setAll(4, typed);
  out.setUint32(8 + body.length, _crc32(typed));
  return bytes;
}

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}
