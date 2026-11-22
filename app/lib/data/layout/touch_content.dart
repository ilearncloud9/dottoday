import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/primary_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'touch_content.g.dart';

/// Whether the browser's primary pointer is coarse, kept current while
/// the page is open; never on a native build (ED-261).
@Riverpod(keepAlive: true)
Stream<bool> coarsePointer(Ref ref) =>
    coarsePrimaryPointer() ?? const Stream<bool>.empty();

/// Whether the wide layouts use the touch content scale (ED-256, ED-261):
/// on iPad and Android tablets, and on the web while its primary pointer
/// is coarse. The Mac and a mouse-driven browser keep the pointer sizes.
/// A change re-lays out and never saves, discards or commits anything.
///
/// ```dart
/// final touch = watchTouchContent(context, ref); // iPad: true
/// ```
bool watchTouchContent(BuildContext context, WidgetRef ref) {
  if (webChrome(context)) {
    return ref.watch(coarsePointerProvider).value ?? false;
  }
  return _touchPlatform(context);
}

/// [watchTouchContent] read once, for a command run from a menu or a
/// shortcut (the review's presenter, ED-099).
bool readTouchContent(BuildContext context, ProviderContainer container) {
  if (webChrome(context)) {
    return container.read(coarsePointerProvider).value ?? false;
  }
  return _touchPlatform(context);
}

bool _touchPlatform(BuildContext context) {
  return switch (Theme.of(context).platform) {
    TargetPlatform.iOS || TargetPlatform.android => true,
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.fuchsia => false,
  };
}
