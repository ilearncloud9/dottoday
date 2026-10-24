// The platform parity checklist (R-13, docs/09 M8.4): PRD feature IDs ×
// iPhone, Android, macOS and web, each cell a status with its evidence.
// Pure Dart (no Flutter) so `dart run tool/parity_checklist.dart` and the
// policy test share it.
import 'dart:io';

/// The four release targets, in the order every table shows them.
enum Target {
  ios('iPhone'),
  android('Android'),
  macos('macOS'),
  web('Web');

  const Target(this.label);
  final String label;
}

/// How a feature is known to work on one target.
enum Status {
  /// Shared or platform-specific automated tests run in CI, and the target
  /// builds in CI (`app.yml` build matrix).
  auto('✓ CI'),

  /// Also run on a simulator, emulator, the Mac or Chrome (task and date in
  /// the note).
  device('✓ device'),

  /// Needs the owner: accounts, consoles or physical hardware (08 §6.1).
  owner('◐ owner'),

  /// Needs a person at the screen; a person check in 08 §6.1 E.
  manual('◐ manual'),

  /// Not built yet by plan: the note names the plan task.
  later('→ later'),

  /// Not on this target by spec (the note says which doc).
  na('— n/a'),

  /// Missing with no decision: the note names the plan task that closes it.
  gap('✗ gap');

  const Status(this.label);
  final String label;
}

/// One target's status with a short note (task id, test, gate).
class Cell {
  const Cell(this.status, [this.note = '']);
  final Status status;
  final String note;
}

/// One PRD feature's row. Targets without their own cell take [all].
class ParityRow {
  const ParityRow({
    required this.tests,
    required this.all,
    this.ios,
    this.android,
    this.macos,
    this.web,
    this.note = '',
  });

  /// Automated evidence: paths under `app/` (or `supabase/…`).
  final List<String> tests;
  final Cell all;
  final Cell? ios, android, macos, web;
  final String note;

  Cell cell(Target t) => switch (t) {
    Target.ios => ios ?? all,
    Target.android => android ?? all,
    Target.macos => macos ?? all,
    Target.web => web ?? all,
  };
}

/// A device or browser run recorded for the checklist.
class Run {
  const Run(this.date, this.target, this.what, this.result);
  final String date, what, result;
  final Target target;
}

/// A PRD feature bullet: `- [F1.4] …` under `## F1. …`.
class PrdFeature {
  const PrdFeature(this.id, this.section, this.text);
  final String id, section, text;

  /// The bullet cut to its first clause, for a table cell.
  String get summary {
    var s = text.replaceFirst(RegExp(r'^As a user I '), '');
    s = s.replaceAll('|', '/');
    final stop = RegExp(r'(\. |; | \(R-|: )').firstMatch(s);
    if (stop != null && stop.start > 20) s = s.substring(0, stop.start);
    if (s.length > 110) s = '${s.substring(0, 107).trimRight()}…';
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }
}

final _section = RegExp(r'^## (F\d+)\. (.+)$');
final _tagged = RegExp(r'^- \[(F\d+\.\d+)\] (.+)$');

/// The v1 features of [prd] in document order, plus problems (untagged
/// bullets, duplicates, an ID outside its section).
(List<PrdFeature>, List<String>) parsePrd(String prd) {
  final features = <PrdFeature>[];
  final problems = <String>[];
  String? section, title;
  for (final line in prd.split('\n')) {
    final s = _section.firstMatch(line);
    if (s != null) {
      (section, title) = (s.group(1), '${s.group(1)}. ${s.group(2)}');
      continue;
    }
    if (line.startsWith('## ')) section = null;
    if (section == null || !line.startsWith('- ')) continue;
    final m = _tagged.firstMatch(line);
    if (m == null) {
      if (!line.startsWith('- Clarified')) {
        problems.add(
          'untagged PRD bullet in $section: ${line.length > 40 ? line.substring(0, 40) : line}',
        );
      }
      continue;
    }
    final id = m.group(1)!;
    if (!id.startsWith('$section.')) problems.add('$id is under $section');
    if (features.any((f) => f.id == id)) problems.add('duplicate PRD id $id');
    features.add(PrdFeature(id, title!, m.group(2)!));
  }
  return (features, problems);
}

final _planId = RegExp(r'\bM\d+(?:\.\d+)?[a-z]?\b');
final _path = RegExp(
  r'`((?:test|integration_test|tool|lib|supabase|docs)/[^`\s]+)`',
);

/// Every problem that keeps the checklist from being true: a PRD ID with no
/// row (or a row with no ID), a cell without its evidence, a later/gap
/// cell whose plan task doesn't exist, or a cited file that doesn't exist.
/// [exists] answers for paths relative to `app/` (`supabase/`, `docs/`
/// relative to the repo root).
List<String> validate({
  required List<PrdFeature> features,
  required Map<String, ParityRow> rows,
  required String plan,
  required bool Function(String path) exists,
}) {
  final problems = <String>[];
  final ids = {for (final f in features) f.id};
  for (final id in ids.difference(rows.keys.toSet())) {
    problems.add('PRD $id has no parity row');
  }
  for (final id in rows.keys.toSet().difference(ids)) {
    problems.add('parity row $id is not in the PRD');
  }
  rows.forEach((id, row) {
    for (final t in row.tests) {
      if (!exists(t)) problems.add('$id: missing evidence file $t');
    }
    for (final m in _path.allMatches(row.note)) {
      if (!exists(m.group(1)!)) problems.add('$id: missing ${m.group(1)}');
    }
    for (final t in Target.values) {
      problems.addAll(
        _cellProblems('$id ${t.name}', row, row.cell(t), plan, exists),
      );
    }
  });
  return problems;
}

List<String> _cellProblems(
  String where,
  ParityRow row,
  Cell c,
  String plan,
  bool Function(String) exists,
) {
  final out = <String>[];
  if (c.status == Status.auto && row.tests.isEmpty) {
    out.add('$where: ✓ CI needs at least one test');
  }
  if (c.status != Status.auto && c.note.trim().isEmpty) {
    out.add('$where: ${c.status.name} needs a note (task, gate or reason)');
  }
  if (c.status == Status.later || c.status == Status.gap) {
    final ids = _planId.allMatches(c.note).map((m) => m.group(0)!);
    if (ids.isEmpty) out.add('$where: ${c.status.name} must name a plan task');
    for (final id in ids) {
      if (!plan.contains(
        RegExp('^- \\[[ x~]\\] ${RegExp.escape(id)} ', multiLine: true),
      )) {
        out.add('$where: plan task $id not found in docs/09');
      }
    }
  }
  for (final m in _path.allMatches(c.note)) {
    if (!exists(m.group(1)!)) out.add('$where: missing ${m.group(1)}');
  }
  return out;
}

/// Resolves an evidence path from `app/`.
bool evidenceExists(String path) {
  final fromRoot = path.startsWith('supabase/') || path.startsWith('docs/');
  final p = fromRoot ? '../$path' : path;
  return File(p).existsSync() || Directory(p).existsSync();
}

/// Shorthand for the commonest cell.
const ci = Cell(Status.auto);
