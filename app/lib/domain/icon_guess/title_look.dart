import 'package:dottoday/domain/entities/icon_keys.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/task_color_keys.gen.dart';
import 'package:dottoday/domain/icon_guess/icon_guess.dart';

/// Lets an edited task's icon and colour follow its title ([guessIcon])
/// while they are still the plain defaults, for one editing session.
///
/// A task opened with its own icon never changes; one opened plain follows
/// the title until an icon is picked. The colour follows only when both
/// were plain, and stops once a colour is picked.
///
/// ```dart
/// final look = TitleLook(task);           // task.iconKey == 'circle'
/// look.retitle(task, 'Gym', language: 'en').iconKey; // 'gym'
/// ```
final class TitleLook {
  TitleLook(Occurrence opened)
    : _icon = opened.iconKey == defaultIconKey,
      _color =
          opened.iconKey == defaultIconKey &&
          opened.colorKey == defaultTaskColorKey;

  bool _icon;
  bool _color;

  /// [o] titled [title], with the look the title suggests where it may.
  Occurrence retitle(Occurrence o, String title, {required String language}) {
    if (!_icon && !_color) return o.copyWith(title: title);
    final look = guessIcon(title, language: language);
    return o.copyWith(
      title: title,
      iconKey: _icon ? look?.iconKey ?? defaultIconKey : o.iconKey,
      colorKey: _color ? look?.colorKey ?? defaultTaskColorKey : o.colorKey,
    );
  }

  /// [o] with the icon the user picked; the title no longer moves it.
  Occurrence pickIcon(Occurrence o, String key) {
    _icon = false;
    return o.copyWith(iconKey: key);
  }

  /// [o] with the colour the user picked; the title no longer moves it.
  Occurrence pickColor(Occurrence o, String key) {
    _color = false;
    return o.copyWith(colorKey: key);
  }
}
