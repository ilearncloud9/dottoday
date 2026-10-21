import 'dart:ui';

/// Parses the SVG path subset the icon set is written in: `M L H V C Q A Z`
/// and their relative forms, on a 24-unit grid.
///
/// Throws [FormatException] on anything else, so a typo in an icon fails
/// its golden test instead of drawing half a glyph.
///
/// ```dart
/// final check = parseSvgPath('M5 12.5l4.5 4.5L19 7.5');
/// ```
Path parseSvgPath(String d) => _Parser(d).parse();

/// A circle as path data: two half arcs (SVG has no circle command).
String svgCircle(double cx, double cy, double r) =>
    'M${cx - r} ${cy}a$r $r 0 1 0 ${2 * r} 0a$r $r 0 1 0 ${-2 * r} 0';

/// A rounded rectangle as path data.
String svgRect(double x, double y, double w, double h, double r) =>
    'M${x + r} ${y}h${w - 2 * r}a$r $r 0 0 1 $r ${r}v${h - 2 * r}'
    'a$r $r 0 0 1 ${-r} ${r}h${-(w - 2 * r)}a$r $r 0 0 1 ${-r} ${-r}'
    'v${-(h - 2 * r)}a$r $r 0 0 1 $r ${-r}z';

final _token = RegExp(r'[MmLlHhVvCcQqAaZz]|-?(?:\d+\.?\d*|\.\d+)(?:e-?\d+)?');

final class _Parser {
  _Parser(String d)
    : _tokens = _token.allMatches(d).map((m) => m[0]!).toList() {
    // Anything the tokenizer skipped (an `s` command, a stray letter) would
    // silently shift every later number, so reject it.
    final rest = d.replaceAll(_token, '').replaceAll(RegExp(r'[\s,]'), '');
    if (rest.isNotEmpty) throw FormatException('unsupported path data: $rest');
    if (_tokens.isEmpty || _tokens.first.toUpperCase() != 'M') {
      throw const FormatException('path must start with M');
    }
  }

  final List<String> _tokens;
  final _path = Path();
  var _i = 0;
  var _cur = Offset.zero;
  var _start = Offset.zero;
  String? _cmd;

  Path parse() {
    while (_i < _tokens.length) {
      if (_isCommand(_tokens[_i])) _cmd = _tokens[_i++];
      final cmd = _cmd;
      if (cmd == null) throw const FormatException('path must start with M');
      _apply(cmd);
      // After a move, further coordinate pairs are implicit line-tos.
      if (cmd == 'M') _cmd = 'L';
      if (cmd == 'm') _cmd = 'l';
    }
    return _path;
  }

  static bool _isCommand(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);

  double _num() {
    if (_i >= _tokens.length || _isCommand(_tokens[_i])) {
      throw FormatException('expected a number at token $_i');
    }
    return double.parse(_tokens[_i++]);
  }

  Offset _point(bool relative) {
    final p = Offset(_num(), _num());
    return relative ? _cur + p : p;
  }

  void _apply(String cmd) {
    final rel = cmd == cmd.toLowerCase();
    switch (cmd.toUpperCase()) {
      case 'M':
        _cur = _start = _point(rel);
        _path.moveTo(_cur.dx, _cur.dy);
      case 'L':
        _lineTo(_point(rel));
      case 'H':
        final x = _num();
        _lineTo(Offset(rel ? _cur.dx + x : x, _cur.dy));
      case 'V':
        final y = _num();
        _lineTo(Offset(_cur.dx, rel ? _cur.dy + y : y));
      case 'C':
        final (a, b, c) = (_point(rel), _point(rel), _point(rel));
        _path.cubicTo(a.dx, a.dy, b.dx, b.dy, c.dx, c.dy);
        _cur = c;
      case 'Q':
        final (a, b) = (_point(rel), _point(rel));
        _path.quadraticBezierTo(a.dx, a.dy, b.dx, b.dy);
        _cur = b;
      case 'A':
        _arc(rel);
      case 'Z':
        _path.close();
        _cur = _start;
        _cmd = null;
      default:
        throw FormatException('unsupported path command $cmd');
    }
  }

  void _lineTo(Offset p) {
    _path.lineTo(p.dx, p.dy);
    _cur = p;
  }

  void _arc(bool rel) {
    final (rx, ry, rotation) = (_num(), _num(), _num());
    final (large, sweep) = (_num() != 0, _num() != 0);
    final end = _point(rel);
    _path.arcToPoint(
      end,
      radius: Radius.elliptical(rx, ry),
      rotation: rotation,
      largeArc: large,
      clockwise: sweep,
    );
    _cur = end;
  }
}
