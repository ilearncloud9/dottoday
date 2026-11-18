import 'package:dottoday/core/router/app_routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_return.g.dart';

/// Where the phones' Settings goes back to (ED-238: "Back and Close return
/// to the screen the user came from"): the address the "Settings and
/// account" button was pressed on; null opens Today.
@Riverpod(keepAlive: true)
class SettingsReturn extends _$SettingsReturn {
  @override
  String? build() => null;

  void from(String location) => state = location;

  /// The address to go back to, once.
  String take() {
    final back = state;
    state = null;
    return back ?? AppRoutes.today;
  }
}
