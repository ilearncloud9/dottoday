import 'package:analyzer/dart/ast/ast.dart';

import 'source_scan.dart';

const _pkg = 'package:dottoday/';
const _storagePackages = ['package:drift/', 'package:sqlite3/'];

/// Layer-boundary violations for the file at [libPath] (relative to `lib/`,
/// e.g. `features/inbox/x.dart`) with contents [source] (CLAUDE.md §3).
///
/// Forbidden: `features/X` → `features/Y`; `domain/` → Flutter (`package:
/// flutter/`, `dart:ui`); `shared/` → `features/`; `core/` → `features/`;
/// `package:drift`/`package:sqlite3` outside `data/` (rows never leave the
/// data layer, docs/04 §2).
List<String> importViolations(String libPath, String source) {
  final self = Uri.parse('$_pkg$libPath');
  final from = libPath.split('/');
  final violations = <String>[];
  for (final d in parseDart(
    source,
  ).directives.whereType<NamespaceDirective>()) {
    final raw = d.uri.stringValue;
    if (raw == null) continue;
    final target = self.resolve(raw).toString();
    final reason = _violation(from, target);
    if (reason != null) violations.add('$libPath → $target: $reason');
  }
  return violations;
}

String? _violation(List<String> from, String target) {
  final layer = from.first;
  if (layer != 'data' && _storagePackages.any(target.startsWith)) {
    return 'only data/ may use drift/sqlite3';
  }
  if (layer == 'domain' &&
      (target.startsWith('package:flutter/') || target == 'dart:ui')) {
    return 'domain must stay pure Dart';
  }
  if (!target.startsWith(_pkg)) return null;
  final to = target.substring(_pkg.length).split('/');
  if (to.first != 'features') return null;
  return switch (layer) {
    'shared' => 'shared must not import features',
    'core' => 'core must not import features',
    'features' when from.length > 2 && to.length > 2 && from[1] != to[1] =>
      'features may not import other features; go through domain/providers',
    _ => null,
  };
}
