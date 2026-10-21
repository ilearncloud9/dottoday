import 'package:integration_test/integration_test_driver.dart';

/// `flutter drive` entry: writes each test's reported data (frame timings
/// from `watchPerformance`) to build/integration_response_data.json.
Future<void> main() => integrationDriver();
