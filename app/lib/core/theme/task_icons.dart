import 'package:dottoday/core/theme/dot_glyphs.dart';
import 'package:dottoday/core/theme/svg_path.dart';

String _c(double cx, double cy, double r) => svgCircle(cx, cy, r);
String _r(double x, double y, double w, double h, double r) =>
    svgRect(x, y, w, h, r);

/// The 26 task icons of the picker, in picker order (docs/10 §3: the 24 of
/// the spec plus people and document, owner 2026-10-21). [key] is the
/// persisted `icon_key`.
///
/// `circle` (the column default) is the "no icon yet" state: the dot shows
/// its colour with no glyph. Stored keys outside this set stay valid data
/// (see `domain/entities/icon_keys.dart`).
enum TaskIcon {
  code,
  run,
  mail,
  call,
  meal,
  book,
  list,
  language,
  heart,
  travel,
  cart,
  home,
  tv,
  bag,
  music,
  meds,
  water,
  pet,
  gym,
  car,
  money,
  gift,
  camera,
  star,
  people,
  document,
  circle;

  /// The glyph to draw, or null for [circle] (a plain dot).
  DotGlyph? get glyph => _glyphs[this];

  /// Icon for new tasks and unknown keys (the `icon_key` column default).
  static const fallback = TaskIcon.circle;

  /// The 26 icons the picker offers (everything but [circle]).
  static List<TaskIcon> get picker => values.sublist(0, values.length - 1);

  static final _byKey = values.asNameMap();

  /// Persisted `icon_key` value.
  String get key => name;

  /// Parses a stored `icon_key`. Keys of the pre-Concept A icon set map to
  /// their nearest icon, anything else to [fallback].
  static TaskIcon fromKey(String? key) =>
      _byKey[key] ?? _legacy[key] ?? fallback;
}

/// The M3.1 curated set (docs/03 §3.4) mapped onto the 26 (ADR-0007).
const _legacy = <String, TaskIcon>{
  'work': TaskIcon.bag,
  'meeting': TaskIcon.people,
  'study': TaskIcon.book,
  'walk': TaskIcon.run,
  'bike': TaskIcon.run,
  'coffee': TaskIcon.meal,
  'sleep': TaskIcon.home,
  'medication': TaskIcon.meds,
  'clean': TaskIcon.home,
  'shopping': TaskIcon.cart,
  'commute': TaskIcon.car,
  'flight': TaskIcon.travel,
};

final _glyphs = <TaskIcon, DotGlyph>{
  TaskIcon.code: const DotGlyph('M9 8l-4 4 4 4M15 8l4 4-4 4'),
  TaskIcon.run: const DotGlyph('M4 14l4-4 3.5 3.5L16 9l4 4'),
  TaskIcon.mail: _mail,
  TaskIcon.call: _call,
  TaskIcon.meal: _meal,
  TaskIcon.book: _book,
  TaskIcon.list: _list,
  TaskIcon.language: _language,
  TaskIcon.heart: _heart,
  TaskIcon.travel: const DotGlyph('M22 2L11 13M22 2l-7 20-4-9-9-4z'),
  TaskIcon.cart: _cart,
  TaskIcon.home: const DotGlyph(
    'M3 10l9-7 9 7v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2zM9 22V12h6v10',
  ),
  TaskIcon.tv: _tv,
  TaskIcon.bag: _bag,
  TaskIcon.music: _music,
  TaskIcon.meds: _meds,
  TaskIcon.water: const DotGlyph(
    'M6 3h12l-1.6 17.2a2 2 0 0 1-2 1.8H9.6a2 2 0 0 1-2-1.8zM6.6 9h10.8',
  ),
  TaskIcon.pet: _pet,
  TaskIcon.gym: const DotGlyph('M6.5 6v12M17.5 6v12M3 9v6M21 9v6M6.5 12h11'),
  TaskIcon.car: _car,
  TaskIcon.money: _money,
  TaskIcon.gift: _gift,
  TaskIcon.camera: _camera,
  TaskIcon.star: _star,
  TaskIcon.people: _people,
  TaskIcon.document: _document,
};

final _mail = DotGlyph('${_r(3, 5, 18, 14, 2)}M3 7.5l9 6 9-6');
const _call = DotGlyph(
  'M21 16.4v2.8a1.9 1.9 0 0 1-2.1 1.9 18.8 18.8 0 0 1-8.2-2.9'
  'a18.5 18.5 0 0 1-5.7-5.7 18.8 18.8 0 0 1-2.9-8.2A1.9 1.9 0 0 1 4 2.2'
  'h2.8a1.9 1.9 0 0 1 1.9 1.6c.1.9.4 1.8.7 2.7a1.9 1.9 0 0 1-.4 2L7.8 9.7'
  'a15.2 15.2 0 0 0 5.7 5.7l1.2-1.2a1.9 1.9 0 0 1 2-.4c.9.3 1.8.6 2.7.7'
  'a1.9 1.9 0 0 1 1.6 1.9z',
);
const _meal = DotGlyph(
  'M4 2v7a2 2 0 0 0 2 2h2a2 2 0 0 0 2-2V2M7 2v20'
  'M20 15V2a4 4 0 0 0-4 4v7a2 2 0 0 0 2 2h2zm0 0v7',
);
const _book = DotGlyph(
  'M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20',
);
const _list = DotGlyph('M9 6h12M9 12h12M9 18h12M4 6h.01M4 12h.01M4 18h.01');
const _language = DotGlyph(
  'M5 8l6 6M4 14l6-6 2-3M2 5h12M7 2h1M22 22l-5-10-5 10M14 18h6',
);
const _heart = DotGlyph(
  'M19 14c1.5-1.5 3-3.2 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.8 0-3 .5-4.5 2'
  '-1.5-1.5-2.7-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4 3 5.5l7 7z',
);
final _cart = DotGlyph(
  '${_c(8, 21, 1)}${_c(19, 21, 1)}'
  'M2 2h2l2.7 12.4a2 2 0 0 0 2 1.6h9.7a2 2 0 0 0 2-1.6L22 7H5.1',
);
final _tv = DotGlyph('${_r(2, 7, 20, 15, 2)}M17 2l-5 5-5-5');
const _bag = DotGlyph(
  'M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4zM3 6h18M16 10a4 4 0 0 1-8 0',
);
final _music = DotGlyph('M9 18V5l12-2v13${_c(6, 18, 3)}${_c(18, 16, 3)}');
const _meds = DotGlyph(
  'M10.5 19.5l9-9a4.25 4.25 0 1 0-6-6l-9 9a4.25 4.25 0 1 0 6 6zM8.5 7.5l8 8',
);
final _pet = DotGlyph(
  '${_c(11, 4, 2)}${_c(18, 8, 2)}${_c(20, 16, 2)}'
  'M9 10a5 5 0 0 1 5 5v3.5a3.5 3.5 0 0 1-6.8 1.2 3.3 3.3 0 0 0-2-2'
  'A3.5 3.5 0 0 1 6.5 10z',
);
final _car = DotGlyph(
  'M5 17H3v-5l2-5h14l2 5v5h-2M9.5 17h5${_c(7.5, 17, 2)}${_c(16.5, 17, 2)}',
);
final _money = DotGlyph(
  '${_r(2, 6, 20, 12, 2)}${_c(12, 12, 2)}M6 12h.01M18 12h.01',
);
final _gift = DotGlyph(
  '${_r(3, 8, 18, 4, 1)}M12 8v13M19 12v7a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-7'
  'M7.5 8a2.5 2.5 0 0 1 0-5C10 3 12 8 12 8c0 0 2-5 4.5-5a2.5 2.5 0 0 1 0 5',
);
final _camera = DotGlyph(
  'M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9'
  'a2 2 0 0 0-2-2h-3z${_c(12, 13, 3)}',
);
const _star = DotGlyph(
  'M12 2l3.1 6.3 6.9 1-5 4.9 1.2 6.8-6.2-3.2-6.2 3.2L7 14.2 2 9.3l6.9-1z',
);
final _people = DotGlyph(
  '${_c(9, 7, 4)}M3 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2'
  'M16 3.1a4 4 0 0 1 0 7.8M21 21v-2a4 4 0 0 0-3-3.9',
);
const _document = DotGlyph(
  'M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'
  'M14 2v6h6M16 13H8M16 17H8M10 9H8',
);
