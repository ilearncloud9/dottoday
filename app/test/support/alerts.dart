import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The confirm or prompt on screen: iOS's alert on Apple platforms,
/// Material's elsewhere (owner, native pass; the system's own needs a
/// host, so a test sees the app's fallback).
final findAlert = find.byWidgetPredicate(
  (w) => w is AlertDialog || w is CupertinoAlertDialog,
);

/// The alert's button labelled [label].
Finder alertButton(String label) => find.ancestor(
  of: find.descendant(of: findAlert, matching: find.text(label)),
  matching: find.byWidgetPredicate(
    (w) => w is ButtonStyleButton || w is CupertinoDialogAction,
  ),
);
