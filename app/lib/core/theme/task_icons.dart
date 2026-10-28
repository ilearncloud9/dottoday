import 'package:dottoday/core/theme/dot_glyphs.dart';

part 'task_icons.gen.dart';

// The library itself (enum, categories, drawings) is generated from
// assets/design/task_icons.json by tool/gen_task_icons.dart (docs/10 §3,
// ADR-0012): Structured's icon names drawn from Lucide (ISC) and Tabler
// (MIT) in the Concept A stroke, Concept A's own 26, and Dottoday's
// planning set.

final _byKey = {for (final i in TaskIcon.values) i.key: i};

final _picker = List<TaskIcon>.unmodifiable(
  TaskIcon.values.where((i) => i.glyph != null),
);

TaskIcon _fromKey(String? key) =>
    _byKey[key] ?? _legacy[key] ?? TaskIcon.fallback;
