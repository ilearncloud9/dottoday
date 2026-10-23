// Only the web installs as an app (docs/09 M5.7).
Stream<bool> installAvailability() => Stream.value(false);

Future<bool> promptInstall() async => false;

void dismissInstall() {}
