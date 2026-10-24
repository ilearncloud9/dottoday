import 'dart:io';

import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/notifications/reminder_sound.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Every bundled notification sound file: the alarm chime (M6.5.4) and the
/// reminder set (F6.6, M8.4d).
List<String> get bundledSoundFiles => [
  alarmSoundFile,
  for (final s in ReminderSound.values) reminderSoundFile(s),
];

/// Copies the bundled sounds to `<container>/Library/Sounds`, where iOS
/// looks up a notification's sound by file name (docs/09 M6.5.4, 11 A0).
/// Not on macOS: the sandbox can't write there, so the Mac app bundles them
/// (`tool/xcode_add_sounds.rb`, M8.5). Idempotent: an identical file is left alone. A failure
/// is logged and that sound falls back to the default one — never a reason
/// not to deliver.
Future<void> installAlarmSound({
  required Logger logger,
  AssetBundle? bundle,
  Future<Directory> Function() library = getLibraryDirectory,
  List<String>? files,
}) async {
  try {
    final dir = Directory('${(await library()).path}/Sounds');
    for (final name in files ?? bundledSoundFiles) {
      final data = await (bundle ?? rootBundle).load('assets/sounds/$name');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final file = File('${dir.path}/$name');
      if (file.existsSync() && file.lengthSync() == bytes.length) continue;
      await dir.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
    }
  } on Exception catch (e, s) {
    logger.warn('notifications.alarm_sound_failed', error: e, stackTrace: s);
  }
}
