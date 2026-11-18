import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'frosted_chrome.g.dart';

/// Whether Android's floating chrome may be frosted (ED-125, ED-128 D5):
/// Android 12 and later; older devices, a failed ask and every other
/// platform get the solid tonal fills.
@Riverpod(keepAlive: true)
Future<bool> frostedChrome(Ref ref) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
  try {
    return await const MethodChannel(
          'dottoday/display',
        ).invokeMethod<bool>('frosted') ??
        false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}
