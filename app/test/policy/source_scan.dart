import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Hand-written Dart files under [dir] (relative to the app root), skipping
/// generated code. Paths are returned relative to `lib/`, '/'-separated.
Map<String, String> readLibSources(String dir) {
  final root = Directory(dir);
  if (!root.existsSync()) return const {};
  final out = <String, String>{};
  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;
    final path = entity.path.replaceAll(r'\', '/');
    if (!path.endsWith('.dart') || _isGenerated(path)) continue;
    out[path.substring(path.indexOf('lib/') + 4)] = entity.readAsStringSync();
  }
  return out;
}

bool _isGenerated(String path) =>
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart') ||
    path.contains('/generated/');

/// Parses [source] without resolution; syntax errors don't throw.
CompilationUnit parseDart(String source) =>
    parseString(content: source, throwIfDiagnostics: false).unit;
