import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dottoday/core/logging/logger.dart';

import 'source_scan.dart';

const _levels = {'debug', 'info', 'warn', 'error'};
final _loggerTarget = RegExp(r'(^|\.)_?(log|logger)$|loggerProvider\)');

/// 1-based lines violating `no_pii_in_logs` (docs/06 §8): a logger call whose
/// event is not a plain string-literal key, or any `print`/`debugPrint`.
List<int> piiLogViolationLines(String source) {
  final unit = parseDart(source);
  final visitor = _Visitor();
  unit.accept(visitor);
  return [
    for (final o in visitor.offsets) unit.lineInfo.getLocation(o).lineNumber,
  ];
}

class _Visitor extends RecursiveAstVisitor<void> {
  final offsets = <int>[];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    final name = node.methodName.name;
    if (target == null && (name == 'print' || name == 'debugPrint')) {
      offsets.add(node.offset);
    } else if (target != null &&
        _levels.contains(name) &&
        _loggerTarget.hasMatch(target.toSource()) &&
        !_isLiteralEvent(node.argumentList.arguments)) {
      offsets.add(node.offset);
    }
    super.visitMethodInvocation(node);
  }

  bool _isLiteralEvent(List<Expression> args) {
    final first = args.isEmpty ? null : args.first;
    return first is SimpleStringLiteral && isValidLogEvent(first.value);
  }
}
