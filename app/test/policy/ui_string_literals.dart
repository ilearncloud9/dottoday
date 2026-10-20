import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'source_scan.dart';

/// Suppression marker; must be followed by a reason.
final _ignore = RegExp(r'//\s*l10n-ignore:\s*\S');

const _keyTypes = {'Key', 'ValueKey'};

/// 1-based line numbers of user-facing string literals in [source]
/// (CLAUDE.md §4: no hardcoded UI strings — use AppLocalizations).
///
/// Allowed: directives, annotations, `''`, `Key`/`ValueKey` arguments, and
/// lines ending in `// l10n-ignore: <reason>`.
List<int> uiStringLiteralLines(String source) {
  final unit = parseDart(source);
  final visitor = _LiteralVisitor();
  unit.accept(visitor);
  final lines = source.split('\n');
  return [
    for (final offset in visitor.offsets)
      if (!_ignore
          .hasMatch(lines[unit.lineInfo.getLocation(offset).lineNumber - 1]))
        unit.lineInfo.getLocation(offset).lineNumber,
  ];
}

class _LiteralVisitor extends RecursiveAstVisitor<void> {
  final offsets = <int>[];

  @override
  void visitImportDirective(ImportDirective node) {}

  @override
  void visitExportDirective(ExportDirective node) {}

  @override
  void visitPartDirective(PartDirective node) {}

  @override
  void visitPartOfDirective(PartOfDirective node) {}

  @override
  void visitAnnotation(Annotation node) {}

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.value.isNotEmpty) offsets.add(node.offset);
  }

  // Report the whole interpolation once; don't descend into its parts.
  @override
  void visitStringInterpolation(StringInterpolation node) =>
      offsets.add(node.offset);

  // Unresolved parse: `ValueKey('x')` is a MethodInvocation.
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null && _keyTypes.contains(node.methodName.name)) return;
    super.visitMethodInvocation(node);
  }

  // `const ValueKey('x')` / `ValueKey<String>('x')`.
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.constructorName.type.toSource().split('<').first;
    if (_keyTypes.contains(type)) return;
    super.visitInstanceCreationExpression(node);
  }
}
