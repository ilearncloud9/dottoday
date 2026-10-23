import 'dart:io';

import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Copies the bundled alarm chime to `<container>/Library/Sounds`, where
/// iOS and macOS look up a notification's sound by file name (docs/09
/// M6.5.4, 11 A0). Idempotent: an identical file is left alone. A failure
/// is logged and loud dots fall back to the default sound — never a reason
/// not to deliver.
Future<void> installAlarmSound({
  required Logger logger,
  AssetBundle? bundle,
  Future<Directory> Function() library = getLibraryDirectory,
}) async {
  try {
    final data = await (bundle ?? rootBundle).load(
      'assets/sounds/$alarmSoundFile',
    );
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final dir = Directory('${(await library()).path}/Sounds');
    final file = File('${dir.path}/$alarmSoundFile');
    if (file.existsSync() && file.lengthSync() == bytes.length) return;
    await dir.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  } on Exception catch (e, s) {
    logger.warn('notifications.alarm_sound_failed', error: e, stackTrace: s);
  }
}
